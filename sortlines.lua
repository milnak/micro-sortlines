-- sortlines - Sort lines in a file.
-- Copyright 2026 Jeff Miller
-- https://github.com/milnak/micro-sortlines
-- MIT license
VERSION = "1.0.0"

local micro = import("micro")
local micro_buffer = import("micro/buffer")
local config = import("micro/config")
local strings = import("strings")

function init()
    config.AddRuntimeFile("sortlines", config.RTHelp, "help/sort-lines.md")

    -- SortCommand args: bufPane, args, descending, caseInsensitive, unique

    -- sortNormal - Sort lines (ascending, case sensitive)
    config.MakeCommand("sortnormal",
        function(bp, args) SortCommand(bp, args, false, false, false) end,
        config.NoComplete)

    -- sortUnique - Sort lines (unique ascending, case sensitive)
    config.MakeCommand("sortunique",
        function(bp, args) SortCommand(bp, args, false, false, true) end,
        config.NoComplete)

    -- sortCaseInsensitive - Sort lines (ascending, case insensitive)
    config.MakeCommand("sortcaseinsensitive",
        function(bp, args) SortCommand(bp, args, false, true, false) end,
        config.NoComplete)

    -- sortCaseInsensitiveUnique - Sort lines (unique ascending, case insensitive)
    config.MakeCommand("sortcaseinsensitiveunique",
        function(bp, args) SortCommand(bp, args, false, true, true) end,
        config.NoComplete)

    -- sortReverse - Sort lines (descending, case sensitive)
    config.MakeCommand("sortreverse",
        function(bp, args) SortCommand(bp, args, true, false, false) end,
        config.NoComplete)

    -- sortReverseUnique - Sort lines (unique descending, case sensitive)
    config.MakeCommand("sortreverseunique",
        function(bp, args) SortCommand(bp, args, true, false, true) end,
        config.NoComplete)

    -- sortReverseCaseInsensitive - Sort lines (descending, case insensitive)
    config.MakeCommand("sortreversecaseinsensitive",
        function(bp, args) SortCommand(bp, args, true, true, false) end,
        config.NoComplete)

    -- sortReverseCaseInsensitiveUnique - Sort lines (unique descending, case insensitive)
    config.MakeCommand("sortreversecaseinsensitiveunique",
        function(bp, args) SortCommand(bp, args, true, true, true) end,
        config.NoComplete)
end

local function getLineRange(bufPane)
    local buf, cursor = bufPane.Buf, bufPane.Cursor
    local firstLine, lastLine = 0, buf:LinesNum() - 1

    if cursor:HasSelection() then
        local startPos, endPos = cursor.CurSelection[1], cursor.CurSelection[2]

        micro.Log("[sortlines] Selection: "
            .. tostring(startPos.Y) .. ":" .. tostring(startPos.X)
            .. " - "
            .. tostring(endPos.Y) .. ":" .. tostring(endPos.X))

        firstLine, lastLine = startPos.Y, endPos.Y

        -- A selection ending at column zero excludes that line.
        if endPos.X == 0 and lastLine > firstLine then
            lastLine = lastLine - 1
        end
    elseif lastLine > 0 and buf:Line(lastLine) == "" then
        -- The final empty buffer line represents a terminating newline.
        lastLine = lastLine - 1
    end

    micro.Log("[sortlines] Line range: " .. tostring(firstLine) .. " - " .. tostring(lastLine))
    return firstLine, lastLine
end

function SortLines(lines, descending, caseInsensitive, unique)
    micro.Log("[sortlines] SortLines invoked. "
        .. "descending=" .. tostring(descending)
        .. " caseInsensitive="
        .. tostring(caseInsensitive)
        .. " unique=" .. tostring(unique))

    micro.Log("[sortlines] Original lines:")
    for lineNo, line in ipairs(lines) do
        micro.Log(string.format("[sortlines] %d: %s", lineNo, line))
    end

    -- Copy lines to table for sortlines

    local keys = {}
    local seen = {}
    for _, line in ipairs(lines) do
        if unique then
            if caseInsensitive then
                line = string.lower(line)
            end

            if not seen[line] then
                table.insert(keys, line)
                seen[line] = true
            end
        else
            table.insert(keys, line)
        end
    end

    if caseInsensitive then
        -- case insensitive
        if descending then
            -- descending
            table.sort(keys, function(a, b) return strings.ToLower(a) > strings.ToLower(b) end)
        else
            -- ascending
            table.sort(keys, function(a, b) return strings.ToLower(a) < strings.ToLower(b) end)
        end
    else
        -- case sensitive
        if descending then
            -- descending
            table.sort(keys, function(a, b) return a > b end)
        else
            -- ascending
            table.sort(keys)
        end
    end

    micro.Log("[sortlines] Lines after sorting:")
    for lineNo, line in ipairs(keys) do
        micro.Log(string.format("[sortlines] %d: %s", lineNo, line))
    end

    return keys
end

function SortCommand(bufPane, args, descending, caseInsensitive, unique)
    if args ~= nil and #args > 0 then
        micro.InfoBar():Error("Usage: sortlines (no arguments)")
        return
    end

    local buf, cursor = bufPane.Buf, bufPane.Cursor
    if buf.Type.Readonly then
        micro.InfoBar():Error("sortlines: buffer is read-only")
        return
    end

    local firstLine, lastLine = getLineRange(bufPane)

    -- Copy the lines from the buffer into a table for sorting

    local lines = {}
    for lineNo = firstLine, lastLine do
        table.insert(lines, buf:Line(lineNo))
    end

    -- Do the actual sort

    local sorted = SortLines(lines, descending, caseInsensitive, unique)

    -- Replace the selected lines with the sorted lines

    for i, lineNo in ipairs(sorted) do
        micro.Log(string.format("[sortlines] Replacing line %d with: %s", firstLine + i - 1, lineNo))
        buf:Replace(micro_buffer.Loc(0, firstLine + i - 1), micro_buffer.Loc(0, firstLine + i), lineNo .. "\n")
    end

    cursor:Relocate()
    cursor:StoreVisualX()
    bufPane:Relocate()
end
