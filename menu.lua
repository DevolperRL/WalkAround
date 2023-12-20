--[[
	WalkAround plugin for Xplane-12
	Version 2.3 29/01/2023
	CopyRight by Raoul Origa
]]

size = { 25, 25 }

local imageMenueCL = sasl.gl.loadImage("Images/button_1.png")

function draw()
    sasl.gl.drawTexture(imageMenueCL, 0, 0, 30, 30)
end

function onMouseDown(component, x, y, button, parentX, parentY)
    if button == MB_LEFT then
        win:setIsVisible(true)
    end
    return false
end