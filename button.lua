--[[
	WalkAround plugin for Xplane-12
	Version 2.3 29/01/2023
	CopyRight by Raoul Origa
]]

local black	    = {0, 0, 0, 1}
local cyan	    = {0, 1, 1, 1}
local magenta	= {1, 0, 1, 1}
local yellow	= {1, 1, 0, 1}
local red       = {1, 0, 0, 1}
local white     = {1, 1, 1, 1}

local fnt =  sasl.gl.loadFont(getXPlanePath() .. "Resources/fonts/DejaVuSansMono.ttf")

function WalkMovement()
    settings.walk_movement = not settings.walk_movement
end

function Sound()
    settings.sound = not settings.sound
end

function SaveConfig()
    print("salvato")
    sasl.writeConfig ( "WalkAround.json" , "JSON" , settings )
end

function Reboot()
    sasl.scheduleProjectReboot()
end

function OpenWindowButton()
    settings.window_button = not settings.window_button
end

components = {
    setting {position = {120, 110, 150, 40}, action = OpenWindowButton },
    setting {position = {120, 170, 150, 40}, action = Sound },
    setting {position = {120 ,225, 150, 40}, action = WalkMovement },
    setting {position = {120, 50, 150, 40}, action = SaveConfig },
    setting {position = {120, -10, 150, 40}, action = Reboot },
}

function draw()
    drawAll(components)
end