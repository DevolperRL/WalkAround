-- main.lua
--[[
	WalkAround plugin for Xplane-12
	Version 2.3 29/01/2023
	CopyRight by Raoul Origa
]]
sasl.options.setAircraftPanelRendering(true)
sasl.options.setInteractivity(true)
sasl.options.set3DRendering(true)
sasl.options.setRenderingMode2D(SASL_RENDER_2D_DEFAULT)
sasl.options.setPanelRenderingMode(SASL_RENDER_PANEL_DEFAULT)

include "keyboard_handler"

local window_width = get(globalPropertyf("sim/graphics/view/window_width"))
local window_height = get(globalPropertyf("sim/graphics/view/window_height"))

local popup_width = 500;
local popup_height = 500;

local window_center_x =  window_width / 2
local window_center_y =  window_height / 2

settings = {
	sound = true,
	walk_movement = true,
	window_button = true,
}

if not isFileExists("WalkAround.json") then 
	sasl.writeConfig ( "WalkAround.json" , "JSON" , settings )
end
settings = sasl.readConfig ( "WalkAround.json" , "JSON" )

setting = contextWindow {
	name		= "Settings",
	position	= { window_center_x - ( popup_width / 2), window_center_y - ( popup_height / 2), popup_width, popup_height},
	visible		= false,
	noResize	= true,
	vrAuto		= true,
	components	= {
        settingdec {position = { 150, 100, 100, 100}, bg = {1,0,0,1} },
		button { position={-90, 100, 500, 500}, bg = {1,0,0,1} },
	},
}

win = contextWindow {
	name		= "WalkAround",
	position	= { window_center_x - ( popup_width / 2), window_center_y - ( popup_height / 2), popup_width, popup_height},
	visible		= true,
	noResize	= true,
	vrAuto		= true,
	components	= {
		input {position = { 150, 100, 100, 100}, bg = {1,0,0,1} },
        settingbtn {position = { 445, 440, 50, 50}, bg = {1,0,0,1} },
	},
}

menuwin = subpanel {
    position     = { -130, 170, 200, 170 },
    noBackground = true,
    noResize     = true,
    noMove       = true,
    noClose      = true,
    visible      = settings.window_button,
    components = {
        menu { position = {150, 100, 100, 100} },
    }
}

local status = true

function change_menu()
	status = not status
	sasl.enableMenuItem(menu_main, menu_action, status and 1 or 0)
	sasl.setMenuItemName(menu_main, menu_option, status and "Disable show/hide" or "Enable show/hide")
	sasl.setMenuItemState(menu_main, menu_option, status and MENU_CHECKED or MENU_UNCHECKED)
end

function show_hide_gndservice() 
    win:setIsVisible(not win:isVisible())
end

local status = false

function change_menu()
	status = not status
	sasl.enableMenuItem(menu_main, menu_action, status and 1 or 0)
end

obj = sasl.loadObject("Objects/Person.obj")
ballInst = sasl.createInstance(obj, {})

function update()
    x, y, z = sasl.modelToLocal(2, 0, 2)
    sasl.setInstancePosition(ballInst, x, y, z, 0, 0, 0, {})
end

menu_master	= sasl.appendMenuItem (PLUGINS_MENU_ID, "WalkAround")
menu_main	= sasl.createMenu ("", PLUGINS_MENU_ID, menu_master)
menu_action	= sasl.appendMenuItem(menu_main, "Open WalkAround", show_hide_gndservice)
change_menu()