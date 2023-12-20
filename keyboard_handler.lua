-- keyboard_handler.lua
--[[
	WalkAround plugin for Xplane-12
	Version 2.3 29/01/2023
	CopyRight by Raoul Origa
]]

local handler

function registerHandler(handle)
	if handler then
		return false
	else
		handler = handle
		return true
	end
end

local function keyHandler(charCode, virtualKeyCode, shiftDown, ctrlDown, altOptDown, event)
	if handler then
		local release = handler(charCode, virtualKeyCode, shiftDown, ctrlDown, altOptDown, event)
		if release then
			handler = false
		end
		return true
	end
	return false
end

registerGlobalKeyHandler(keyHandler)