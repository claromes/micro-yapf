VERSION = "1.0.0"

local config = import("micro/config")
local shell = import("micro/shell")
local filepath = import("path/filepath")
local micro = import("micro")

local fmtCommands = {}
fmtCommands["python"] = "yapf -i"

function init()
    config.RegisterCommonOption("yapf", "onsave", true)
    config.MakeCommand("yapf", tryFmt, config.NoComplete)
    config.AddRuntimeFile("yapf", config.RTHelp, "help/yapf.md")
end

function onSave(bp)
 	if bp.Buf.Settings["yapf.onsave"] == false then
    	return
    end
    tryFmt(bp)
end

function tryFmt(bp)
	if fmtCommands[bp.Buf:FileType()] ~= nil then
	    doFmt(bp, fmtCommands[bp.Buf:FileType()])
	end
end

function doFmt(bp, fmtCmd)
    bp:Save()
    local dirPath, _ = filepath.Split(bp.Buf.AbsPath)
    local _, err = os.execute("cd \"" .. dirPath .. "\"; " .. fmtCmd .. " " .. bp.Buf.AbsPath)
    if err ~= nil then
        micro.InfoBar():Error(err)
        return
    end
    bp.Buf:ReOpen()
end