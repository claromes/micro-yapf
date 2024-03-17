VERSION = "1.0.0"

local config = import("micro/config")
local shell = import("micro/shell")
local filepath = import("path/filepath")
local micro = import("micro")

local commonCommand = "prettier --write --log-level silent"

local fmtCommands = {
    javascript = commonCommand,
    jsx = commonCommand,
    typescript = commonCommand,
    css = commonCommand,
    html = commonCommand,
    json = commonCommand,
    markdown = commonCommand,
    yaml = commonCommand
}

function init()
    config.RegisterCommonOption("prettier", "onsave", true)
    config.MakeCommand("prettier", tryFmt, config.NoComplete)
    config.AddRuntimeFile("prettier", config.RTHelp, "help/prettier.md")
end

function onSave(bp)
 	if bp.Buf.Settings["prettier.onsave"] == false then
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