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
    config.MakeCommand("sortlines", SortlinesCommand, config.NoComplete)
end

local function getLineRange(bufPane)
    local buf, cursor = bufPane.Buf, bufPane.Cursor
    local firstLine, lastLine = 0, buf:LinesNum() - 1
    if cursor:HasSelection() then
        local startPos, endPos = cursor.CurSelection[1], cursor.CurSelection[2]
        if startPos:GreaterThan(endPos) then
            startPos, endPos = endPos, startPos
        end
        firstLine, lastLine = startPos.Y, endPos.Y
        -- A selection ending at column zero excludes that line.
        if endPos.X == 0 and lastLine > firstLine then
            lastLine = lastLine - 1
        end
    elseif lastLine > 0 and buf:Line(lastLine) == "" then
        -- The final empty buffer line represents a terminating newline.
        lastLine = lastLine - 1
    end
    return firstLine, lastLine
end

function SortUniqueAscendingCaseInsensitive(lines)
    local originals, keys = {}, {}
    for _, line in ipairs(lines) do
        local key = strings.ToLower(line)
        if originals[key] == nil then
            originals[key] = line
            table.insert(keys, key)
        end
    end

    table.sort(keys)
    local unique = {}
    for _, key in ipairs(keys) do
        table.insert(unique, originals[key])
    end
    return unique
end

function SortlinesCommand(bufPane, args)
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
    local lines = {}
    for lineNo = firstLine, lastLine do
        table.insert(lines, buf:Line(lineNo))
    end
    local sorted = SortUniqueAscendingCaseInsensitive(lines)
    local oldText, newText = table.concat(lines, "\n"), table.concat(sorted, "\n")
    if oldText == newText then
        return
    end

    local startPos = micro_buffer.Loc(0, firstLine)
    local endPos = buf:End()
    local terminated = lastLine < buf:LinesNum() - 1
    if terminated then
        endPos = micro_buffer.Loc(0, lastLine + 1)
        newText = newText .. "\n"
    end
    local hadSelection = cursor:HasSelection()
    buf:Replace(startPos, endPos, newText)

    if hadSelection then
        local newEnd = buf:End()
        if terminated then
            newEnd = micro_buffer.Loc(0, firstLine + #sorted)
        end
        cursor:SetSelectionStart(startPos)
        cursor:SetSelectionEnd(newEnd)
        cursor.OrigSelection = cursor.CurSelection
        cursor.Loc = newEnd
    end
    cursor:Relocate()
    cursor:StoreVisualX()
    bufPane:Relocate()
end
