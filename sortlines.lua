-- sortlines - Sort lines in a file.
-- Copyright 2026 Jeff Miller
-- https://github.com/milnak/micro-sortlines
-- MIT license

-- GetInstalledPluginVersion returns the string of the exported VERSION variable of a loaded plugin
VERSION = "1.0.2"

local micro = import("micro")
local config = import("micro/config")
local strings = import("strings")
local buffer = import("micro/buffer")
local util = import("micro/util")

function init()
    config.AddRuntimeFile("sortlines", config.RTHelp, "help/sort-lines.md")

    config.MakeCommand("sortlines",
        function(bp, args) SortCommand(bp, args, { caseInsensitive = true, unique = true }) end,
        config.NoComplete)

    -- sortNormal - Sort lines (ascending, case sensitive)
    config.MakeCommand("sortnormal",
        function(bp, args) SortCommand(bp, args, {}) end,
        config.NoComplete)

    -- sortUnique - Sort lines (unique ascending, case sensitive)
    config.MakeCommand("sortunique",
        function(bp, args) SortCommand(bp, args, { unique = true }) end,
        config.NoComplete)

    -- sortCaseInsensitive - Sort lines (ascending, case insensitive)
    config.MakeCommand("sortcaseinsensitive",
        function(bp, args) SortCommand(bp, args, { caseInsensitive = true }) end,
        config.NoComplete)

    -- sortCaseInsensitiveUnique - Sort lines (unique ascending, case insensitive)
    config.MakeCommand("sortcaseinsensitiveunique",
        function(bp, args) SortCommand(bp, args, { caseInsensitive = true, unique = true }) end,
        config.NoComplete)

    -- sortReverse - Sort lines (descending, case sensitive)
    config.MakeCommand("sortreverse",
        function(bp, args) SortCommand(bp, args, { descending = true }) end,
        config.NoComplete)

    -- sortReverseUnique - Sort lines (unique descending, case sensitive)
    config.MakeCommand("sortreverseunique",
        function(bp, args) SortCommand(bp, args, { descending = true, unique = true }) end,
        config.NoComplete)

    -- sortReverseCaseInsensitive - Sort lines (descending, case insensitive)
    config.MakeCommand("sortreversecaseinsensitive",
        function(bp, args) SortCommand(bp, args, { descending = true, caseInsensitive = true }) end,
        config.NoComplete)

    -- sortReverseCaseInsensitiveUnique - Sort lines (unique descending, case insensitive)
    config.MakeCommand("sortreversecaseinsensitiveunique",
        function(bp, args) SortCommand(bp, args, { descending = true, caseInsensitive = true, unique = true }) end,
        config.NoComplete)
end

function SortLines(lines, opts)
    local keys = {}
    local seen = {}
    for position, line in ipairs(lines) do
        local key = opts.caseInsensitive and strings.ToLower(line) or line
        if not opts.unique or not seen[key] then
            table.insert(keys, { text = line, key = key, position = position })
            seen[key] = true
        end
    end

    table.sort(keys, function(left, right)
        if left.key == right.key then
            return left.position < right.position
        end
        if opts.descending then
            return left.key > right.key
        end
        return left.key < right.key
    end)

    local sorted = {}
    for _, entry in ipairs(keys) do
        table.insert(sorted, entry.text)
    end
    return sorted
end

function GetLines(buf, firstLine, lastLine)
    local lines = {}
    for lineNo = firstLine, lastLine do
        table.insert(lines, buf:Line(lineNo))
    end
    return lines
end

function SortCommand(pane, args, opts)
    if args ~= nil and #args > 0 then
        micro.InfoBar():Error("Usage: sortlines (no arguments)")
        return
    end

    local buf = pane.Buf
    if buf.Type.Readonly then
        micro.InfoBar():Error("sortlines: buffer is read-only")
        return
    end

    local cursor = pane.Cursor
    local hasSelection = cursor:HasSelection()
    local backward = false
    local firstLine = 0
    local lastLine = buf:LinesNum() - 1

    if hasSelection then
        local start = cursor.CurSelection[1]
        local finish = cursor.CurSelection[2]
        backward = start.Y > finish.Y or (start.Y == finish.Y and start.X > finish.X)
        if backward then
            start, finish = finish, start
        end
        firstLine, lastLine = start.Y, finish.Y
        if finish.X == 0 and lastLine > firstLine then
            lastLine = lastLine - 1
        end
    elseif lastLine > 0 and buf:Line(lastLine) == "" then
        lastLine = lastLine - 1
    end

    local from = buffer.Loc(0, firstLine)
    local to = buffer.Loc(util.CharacterCountInString(buf:Line(lastLine)), lastLine)
    local terminated = lastLine < buf:LinesNum() - 1
    if terminated then
        to = buffer.Loc(0, lastLine + 1)
    end

    local oldLines = GetLines(buf, firstLine, lastLine)
    local sortedLines = SortLines(oldLines, opts)
    local originalText = table.concat(oldLines, "\n")
    local sortedText = table.concat(sortedLines, "\n")
    if sortedText == originalText then
        return
    end
    if terminated then
        sortedText = sortedText .. "\n"
    end
    buf:Replace(from, to, sortedText)

    if hasSelection then
        local selectionEnd
        if terminated then
            selectionEnd = buffer.Loc(0, firstLine + #sortedLines)
        else
            selectionEnd = buffer.Loc(util.CharacterCountInString(sortedLines[#sortedLines]),
                firstLine + #sortedLines - 1)
        end
        local anchor, head = from, selectionEnd
        if backward then
            anchor, head = head, anchor
        end
        cursor:SetSelectionStart(anchor)
        cursor:SetSelectionEnd(head)
        -- cursor.OrigSelection = cursor.CurSelection
        cursor:GotoLoc(head)
    else
        cursor:Relocate()
        cursor:StoreVisualX()
    end
end
