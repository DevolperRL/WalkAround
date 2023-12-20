--[[
	WalkAround plugin for Xplane-12
	Version 2.3 29/01/2023
	CopyRight by Raoul Origa
]]

defineProperty("action", function() logInfo "Default action" end)

local mouseOff = 1
local mouseHover = 2
local mouseDown = 3
local mouse_status = mouseOff

local white = {1, 1, 1, 1}

local button_image = {}
button_image[mouseOff] = sasl.gl.loadImage("Images/Normal_btn.png")
button_image[mouseHover] = sasl.gl.loadImage("Images/MouseOver_btn.png")
button_image[mouseDown] = sasl.gl.loadImage("Images/Clicked_btn.png")

local mouseOver = false

function onMouseMove(component, x, y, button, parentX, parentY)
    mouseOver = true
    return true
end

function onMouseDown(component, x, y, button, parentX, parentY)
    mouse_status = mouseDown
    get(action)
    return true
end

function onMouseUp(component, x, y, button, parentX, parentY)
    mouse_status = mouseHover
    return true
end

function onMouseHold (component, x, y, button, parentX, parentY)
    mouse_status = mouseDown
    return true
end

function onMouseEnter()
    if mouseOver == true then
        mouse_status = mouseHover
    else
        mouse_status = mouseOff
    end
end

function onMouseLeave()
    mouseOver = false
    mouse_status = mouseOff
end

function update()
    --print(mouseOver)
end

function draw()
    sasl.gl.drawTexture (button_image[mouse_status] , 0, 0, 170, 50, white)
end