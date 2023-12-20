--[[
	WalkAround plugin for Xplane-12
	Version 2.3 29/01/2023
	CopyRight by Raoul Origa
]]

local imageMenueCL = sasl.gl.loadImage("Images/Setting-cog.png")

function draw()
    sasl.gl.drawTexture(imageMenueCL, 0, 0, 50, 50)
end

function onMouseDown(component, x, y, button, parentX, parentY)
    if button == MB_LEFT then
        setting:setIsVisible(true)
    end
    return false
end