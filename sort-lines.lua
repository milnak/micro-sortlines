-- sortlines - Sort lines in a file.
-- Copyright 2026 Jeff Miller
-- https://github.com/milnak/micro-sortlines
-- MIT license

VERSION = "1.0.0"

local micro = import("micro")
-- local config = import("micro/config")
-- local shell = import("micro/shell")
-- local filepath = import("path/filepath")

function init()
    config.AddRuntimeFile("sortlines", config.RTHelp, "help/sortlines.md")
    config.MakeCommand("sortlines", sortlinesCommand, config.NoComplete)
end

function sortlinesCommand(bp)
    -- local dirPath, _ = filepath.Split(bp.Buf.AbsPath)
    -- local _, err = os.execute("cd \"" .. dirPath .. "\"; " .. fmtCmd .. " " .. bp.Buf.AbsPath)
    -- if err ~= nil then
    --     micro.InfoBar():Error(err)
    --     return
    -- end
    if bp == nil or bp.Buf == nil or bp.Buf.Path == nil or bp.Buf.Path == "" then
        micro.InfoBar():Error("No file open or path unavailable")
        return
    end

    local filename = bp.Buf.Path
    micro.InfoBar():Message(string.format("File '%s'", filename))
end
