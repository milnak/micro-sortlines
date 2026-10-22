local commands = {}
local errors = {}
local lowercaseCalls = 0

local function loc(column, row)
    return { X = column, Y = row }
end

local function characterCount(text)
    local count = 0
    for _, codepoint in utf8.codes(text) do
        if codepoint < 0x300 or codepoint > 0x36f then
            count = count + 1
        end
    end
    return count
end

local modules = {
    micro = {
        InfoBar = function()
            return { Error = function(_, message) table.insert(errors, message) end }
        end,
    },
    ["micro/buffer"] = { Loc = loc },
    ["micro/util"] = { CharacterCountInString = characterCount },
    ["micro/config"] = {
        AddRuntimeFile = function(plugin, filetype, path) end,
        MakeCommand = function(name, command, completion) commands[name] = command end,
    },
    strings = {
        ToLower = function(text)
            lowercaseCalls = lowercaseCalls + 1
            return (text:lower():gsub("\195\137", "\195\169"))
        end,
    },
}

function import(name)
    return assert(modules[name], "Unexpected import: " .. name)
end

local testDirectory = arg[0]:match("^(.*[/\\])") or ""
dofile(testDirectory .. "../sortlines.lua")
init()

local function equal(actual, expected, label)
    assert(actual == expected, label .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
end

local function split(text)
    local lines = {}
    for line in (text .. "\n"):gmatch("(.-)\n") do
        table.insert(lines, line)
    end
    return lines
end

local function paneFor(text, selection)
    local buf = { text = text, Type = {}, replacements = 0 }
    function buf:Line(row)
        local line = split(self.text)[row + 1]
        assert(line, "Invalid line")
        return line
    end
    function buf:LinesNum()
        return #split(self.text)
    end
    function buf:Replace(from, to, replacement)
        equal(from.X, 0, "Replacement starts at a line boundary")
        local lines = split(self.text)
        local prefix = {}
        for lineNo = 1, from.Y do
            table.insert(prefix, lines[lineNo] .. "\n")
        end
        local suffix = {}
        if to.X == 0 then
            for lineNo = to.Y + 1, #lines do
                table.insert(suffix, lines[lineNo])
            end
        else
            equal(to.Y, #lines - 1, "Nonzero endpoint is EOF")
            equal(to.X, characterCount(lines[#lines]), "EOF uses character coordinates")
        end
        self.text = table.concat(prefix) .. replacement .. table.concat(suffix, "\n")
        self.replacements = self.replacements + 1
    end

    local cursor = { CurSelection = selection or { loc(0, 0), loc(0, 0) } }
    function cursor:HasSelection()
        local start, finish = self.CurSelection[1], self.CurSelection[2]
        return start.X ~= finish.X or start.Y ~= finish.Y
    end
    function cursor:SetSelectionStart(position) self.CurSelection[1] = position end
    function cursor:SetSelectionEnd(position) self.CurSelection[2] = position end
    function cursor:GotoLoc(position) self.position = position end
    function cursor:Relocate() self.relocated = true end
    function cursor:StoreVisualX() end
    return { Buf = buf, Cursor = cursor }
end

local cases = {
    { "trailing newline", "b\na\n", "a\nb\n" },
    { "no trailing newline", "b\na", "a\nb" },
    { "first spelling", "Banana\napple\nAPPLE\n", "apple\nBanana\n" },
    { "blank lines", "b\n\na\n\n", "\na\nb\n" },
    { "Unicode lowercase", "\195\137\n\195\169\n", "\195\137\n" },
    { "Unicode EOF", "\195\169\nb", "b\n\195\169" },
    { "combining EOF", "z\ne\204\129", "e\204\129\nz" },
    { "empty buffer", "", "", nil, 0 },
    { "single line", "a\n", "a\n", nil, 0 },
    { "already sorted", "a\nb\n", "a\nb\n", nil, 0 },
    { "forward selection", "keep\nb\na\ntail", "keep\na\nb\ntail", { loc(1, 1), loc(1, 2) } },
    { "backward selection", "keep\nb\na\ntail", "keep\na\nb\ntail", { loc(1, 2), loc(1, 1) } },
    { "column zero", "keep\nb\na\ntail", "keep\na\nb\ntail", { loc(0, 1), loc(0, 3) } },
    { "backward column zero", "keep\nb\na\ntail", "keep\na\nb\ntail", { loc(0, 3), loc(0, 1) } },
    { "selection shrinks", "keep\nb\nB\na\ntail", "keep\na\nb\ntail", { loc(0, 1), loc(0, 4) } },
    { "selection at EOF", "keep\nb\nB\na", "keep\na\nb", { loc(0, 1), loc(1, 3) } },
}

for _, case in ipairs(cases) do
    local originalStart = case[4] and loc(case[4][1].X, case[4][1].Y)
    local originalFinish = case[4] and loc(case[4][2].X, case[4][2].Y)
    local pane = paneFor(case[2], case[4])
    local savedStart, savedFinish = pane.Cursor.CurSelection[1], pane.Cursor.CurSelection[2]
    commands.sortlines(pane, {})
    equal(pane.Buf.text, case[3], case[1])
    equal(pane.Buf.replacements, case[5] or 1, case[1] .. " replacement count")
    if case[4] then
        equal(savedStart.X, originalStart.X, "Original start column not mutated")
        equal(savedStart.Y, originalStart.Y, "Original start row not mutated")
        equal(savedFinish.X, originalFinish.X, "Original end column not mutated")
        equal(savedFinish.Y, originalFinish.Y, "Original end row not mutated")
        local backward = originalStart.Y > originalFinish.Y
        local anchor, head = pane.Cursor.CurSelection[1], pane.Cursor.CurSelection[2]
        local first, last = anchor, head
        if backward then first, last = head, anchor end
        equal(first.Y, 1, "Selection starts at first sorted line")
        equal(first.X, 0, "Selection starts at column zero")
        equal(last.Y, case[1] == "selection at EOF" and 2 or 3, "Selection end row")
        equal(last.X, case[1] == "selection at EOF" and 1 or 0, "Selection end column")
        equal(pane.Cursor.position, head, "Cursor follows selection direction")
    end
end

local modes = {
    { "sortnormal", "B\na\na\nb" },
    { "sortunique", "B\na\nb" },
    { "sortcaseinsensitive", "a\na\nb\nB" },
    { "sortcaseinsensitiveunique", "a\nb" },
    { "sortreverse", "b\na\na\nB" },
    { "sortreverseunique", "b\na\nB" },
    { "sortreversecaseinsensitive", "b\nB\na\na" },
    { "sortreversecaseinsensitiveunique", "b\na" },
}
for _, mode in ipairs(modes) do
    local pane = paneFor("b\nB\na\na")
    commands[mode[1]](pane, {})
    equal(pane.Buf.text, mode[2], mode[1])
end

local pane = paneFor("b\na")
pane.Buf.Type.Readonly = true
commands.sortlines(pane, {})
equal(pane.Buf.replacements, 0, "Read-only buffer")
equal(#errors, 1, "Read-only error")
pane.Buf.Type.Readonly = false
commands.sortlines(pane, { "unexpected" })
equal(pane.Buf.replacements, 0, "Arguments rejected")
equal(#errors, 2, "Usage error")

local unchanged = paneFor("a\nb", { loc(1, 0), loc(1, 1) })
local savedSelection = unchanged.Cursor.CurSelection
commands.sortlines(unchanged, {})
equal(unchanged.Buf.replacements, 0, "Sorted selection is untouched")
equal(unchanged.Cursor.CurSelection, savedSelection, "Sorted selection is preserved")

lowercaseCalls = 0
equal(table.concat(SortLines({ "B", "b", "a" }, { caseInsensitive = true }), "\n"),
    "a\nB\nb", "Stable lowercase keys")
equal(lowercaseCalls, 3, "Lowercase keys computed once per input line")

print("Passed " .. #cases .. " range cases, " .. #modes .. " command modes, and guard/stability checks")
