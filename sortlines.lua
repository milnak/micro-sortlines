-- sortlines - Sort lines in a file.
-- Copyright 2026 Jeff Miller
-- https://github.com/milnak/micro-sortlines
-- MIT license
VERSION = "1.0.0"

local micro = import("micro")
local micro_buffer = import("micro/buffer")

function init()
    config.AddRuntimeFile("sortlines", config.RTHelp, "help/sortlines.md")
    config.MakeCommand("sortlines", sortlinesCommand, config.NoComplete)
end

-- Returns Loc tuple w/ current marked text or whole line (begin, end)
function getTextLoc()
    local curPane = micro.CurPane()
    local startPos, endPos = nil, nil
    local cursor = curPane.Cursor

    if cursor:HasSelection() then
        -- Text is selected, get selection bounds
        if cursor.CurSelection[1]:GreaterThan(-cursor.CurSelection[2]) then
            startPos, endPos = cursor.CurSelection[2], cursor.CurSelection[1]
        else
            startPos, endPos = cursor.CurSelection[1], cursor.CurSelection[2]
        end
    else
        -- Nothing selected
        local eol = string.len(curPane.Buf:Line(cursor.Loc.Y))
        startPos, endPos = cursor.Loc, micro_buffer.Loc(eol, cursor.Loc.Y)
    end

    -- type Loc struct { X, Y int }
    return micro_buffer.Loc(startPos.X, startPos.Y), micro_buffer.Loc(endPos.X, endPos.Y)
end

-- Returns the current marked text or whole line
function getText(startPos, endPos)
    local txt, buf = {}, micro.CurPane().Buf

    -- Editing a single line?
    if startPos.Y == endPos.Y then
        return buf:Line(startPos.Y):sub(startPos.X + 1, endPos.X)
    end

    -- Add first part of text selection (startPos.X+1 as Lua is 1-indexed)
    table.insert(txt, buf:Line(startPos.Y):sub(startPos.X + 1))

    -- Stuff in the middle
    for lineNo = startPos.Y + 1, endPos.Y - 1 do
        table.insert(txt, buf:Line(lineNo))
    end

    -- Insert last part of selection
    table.insert(txt, buf:Line(endPos.Y):sub(1, endPos.X))

    return table.concat(txt, "\n")
end

-- sort lines (unique ascending, case-insensitive)
function sortUniqueAscendingCaseInsensitive(lines)
    local seen = {}
    local unique = {}

    for _, line in ipairs(lines) do
        local lower = string.lower(line)
        if not seen[lower] then
            seen[lower] = true
            table.insert(unique, line)
        end
    end

    table.sort(unique, function(a, b)
        return string.lower(a) < string.lower(b)
    end)

    return unique
end

function sortlinesCommand(bufPane)
    debug("sortlinesCommand()")

    local startPos, endPos = getTextLoc()
    local oldTxt = getText(startPos, endPos)

end
