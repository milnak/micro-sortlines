-- sortlines - Sort lines in a file.
-- Copyright 2026 Jeff Miller
-- https://github.com/milnak/micro-sortlines
-- MIT license
VERSION = "1.0.0"

local micro = import("micro")
local micro_buffer = import("micro/buffer")
local config = import("micro/config")
local strings = import("strings")
local buffer = import("micro/buffer")

function init()
    config.AddRuntimeFile("sortlines", config.RTHelp, "help/sort-lines.md")

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
    micro.Log("[sortlines] SortLines invoked. "
        .. "descending=" .. tostring(opts.descending)
        .. " caseInsensitive=" .. tostring(opts.caseInsensitive)
        .. " unique=" .. tostring(opts.unique))

    micro.Log("[sortlines] Original lines:")
    for lineNo, line in ipairs(lines) do
        micro.Log(string.format("[sortlines] %d: %s", lineNo, line))
    end

    -- Copy lines to table for sortlines

    local keys = {}
    local seen = {}
    for _, line in ipairs(lines) do
        if opts.unique then
            if not seen[line] then
                table.insert(keys, line)
                seen[line] = true
            end
        else
            table.insert(keys, line)
        end
    end

    if opts.caseInsensitive then
        -- case insensitive
        if opts.descending then
            -- descending
            table.sort(keys, function(a, b) return string.lower(a) > string.lower(b) end)
        else
            -- ascending
            table.sort(keys, function(a, b) return string.lower(a) < string.lower(b) end)
        end
    else
        -- case sensitive
        if opts.descending then
            -- descending
            table.sort(keys, function(a, b) return a > b end)
        else
            -- ascending
            table.sort(keys, function(a, b) return a < b end)
        end
    end

    micro.Log("[sortlines] Lines after sorting:")
    for lineNo, line in ipairs(keys) do
        micro.Log(string.format("[sortlines] %d: %s", lineNo, line))
    end

    return keys
end

function GetLines(from, to)
    local buf = micro.CurPane().Buf
    local lines = { buf:Line(from.Y):sub(from.X + 1) }

    if from.Y == to.Y then
        return lines
    end

    for lineNo = from.Y + 1, to.Y - 1 do
        table.insert(lines, buf:Line(lineNo))
    end

    table.insert(lines, buf:Line(to.Y):sub(1, to.X))

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

    local from, to

    if cursor:HasSelection() then
        -- Use lines from the selection
        from, to = cursor.CurSelection[1], cursor.CurSelection[2]

        micro.Log("[sortlines] Selection: " ..
            tostring(from.Y) .. ":" .. tostring(from.X) .. " - " .. tostring(to.Y) .. ":" .. tostring(to.X))

        -- Adjust the selection to cover whole line
        from.X = 0
        to.X = string.len(pane.Buf:Line(to.Y))

        from, to = buffer.Loc(from.X, from.Y), buffer.Loc(to.X, to.Y)
    else
        -- No selection, use all text
        local lastLine = pane.Buf:LinesNum() - 1
        local lastLineLen = string.len(pane.Buf:Line(lastLine))
        from, to = buffer.Loc(0, 0), buffer.Loc(lastLineLen, lastLine)
    end

    micro.Log("[sortlines] Normalized: " ..
        tostring(from.Y) .. ":" .. tostring(from.X) .. " - " .. tostring(to.Y) .. ":" .. tostring(to.X))

    if from.Y == to.Y then
        return micro.InfoBar():Message("You have to select lines of text first.")
    end

    -- Copy the lines from the buffer into a table for sorting

    local oldLines = GetLines(from, to)

    -- Do the actual sort

    local sortedText = SortLines(oldLines, opts)

    -- Replace the selected lines with the sorted lines

    pane.Buf:Replace(from, to, table.concat(sortedText, "\n"))
end
