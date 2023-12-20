--[[
	WalkAround plugin for Xplane-12
	Version 2.3 29/01/2023
	CopyRight by Raoul Origa
]]

--[[require("bit")

local band = bit.band

local view_id = 7

local CAMERA_STATUS_TRANSISION_IN_PROGRESS = 16 -- bit 5 indicates that a transition is in progress
local CAMERA_STATUS_CONTROL_PANEL_OPEN = 8 -- Bit 4 indicates that the control panel is open
local AIRPORT_CAMERA = 4		-- Bit 3 of the camera status indicates it is an airport camera
local CAMERA_SELECTED = 2		-- Bit 2 indicates the camera is selected
local CAMERA_PRESENT = 1		-- Bit 1 indicates camera is present
local CAMERA_PRESENT_AND_SELECTED = CAMERA_SELECTED + CAMERA_PRESENT

local CAMERA_X = globalPropertyf("SRS/X-Camera/integration/effect_script_x_offset")
local CAMERA_Y = globalPropertyf("SRS/X-Camera/integration/effect_script_y_offset")
local CAMERA_Z = globalPropertyf("SRS/X-Camera/integration/effect_script_z_offset")
local CAMERA_ROLL = globalPropertyf("SRS/X-Camera/integration/effect_script_roll_offset")
local CAMERA_HEADING = globalPropertyf("SRS/X-Camera/integration/effect_script_heading_offset")
local CAMERA_PITCH = globalPropertyf("SRS/X-Camera/integration/effect_script_pitch_offset")
local CAMERA_STATUS = globalPropertyf("SRS/X-Camera/integration/effect_script_id")
local Key_W = globalPropertyf("sim/general/right")

local GLOBAL_STATUS = globalPropertyf("SRS/X-Camera/integration/overall_status")]]

cameraHeading = 0.0
cameraPitch = 0.0
cameraDistance = 200.0
cameraAdvance = 0.2

local walkSpeed = 5
--local walkDirection = heading
local forward = 0.1
local forwardX = 0.1
local forwardZ = 0.1
local back = 0.1
local left = 0.1
local right = 0.1

local tmp = 0

local black	    = {0, 0, 0, 1}
local cyan	    = {0, 1, 1, 1}
local magenta	= {1, 0, 1, 1}
local yellow	= {1, 1, 0, 1}
local red       = {1, 0, 0, 1}
local white     = {1, 1, 1, 1}

local fnt =  sasl.gl.loadFont(getXPlanePath() .. "Resources/fonts/DejaVuSansMono.ttf")
local enabled = "Start Walking"

local cameraShake = "Disable"

local test = get("sim/flightmodel/parts/tire_y_no_deflection")

local elevation = 0

--local elevation = get(globalPropertyf("sim/flightmodel/position/y_agl"))
--local elevation = get(globalPropertyf("sim/graphics/view/view_elevation_agl_mtrs"))

local walk = 0

local iswalking = false

walkSound = sasl.al.loadSample("Sounds/WalkSound.wav")

local keys = {
	false, -- Key W
	false, -- Key S
	false, -- Key A
	false, -- Key D
}

--Midle position mouse 960	528

local path = sasl.findPluginByPath("Resources/plugins/X-Camera")

local pAdjust = 0
local angle = 0
local sinX = 0
local sinY = 0
local sinZ = 0
local sinWalk = 0

local both = false

local cabinHeight = get(globalPropertyf("sim/aircraft/view/acf_door_y"))
local currentHeight = 0
local initialPilotHeight = 0
local statusHeight = 1


local maxHeight = 1.75
local minHeight = 0.7
local middleHeight = (maxHeight + minHeight) / 2

local xp_pilot_head_y = globalPropertyf("sim/graphics/view/pilots_head_y")
initialPilotHeight = get(xp_pilot_head_y)

--Costum datarefs
local leftArm_Anim = createGlobalPropertyi("Human/Body/Arms", .5)

--print("\ncurrent: " .. currentHeight .. "\n" .. "initial: " .. initialPilotHeight .. "\n" .. "elevation: " .. elevation .. "\n" .. "max: " .. maxHeight)

local switch = {
	[1] = function()	-- for case 1
		print(initialPilotHeight)
		currentHeight = (initialPilotHeight - elevation) +  maxHeight
		statusHeight = statusHeight + 1
		print(currentHeight)
	end,
	[2] = function()    -- for case 2
		currentHeight = (initialPilotHeight - elevation) + middleHeight
		statusHeight = statusHeight + 1
	end,
	[3] = function()    -- for case 3
		currentHeight = (initialPilotHeight - elevation) +  minHeight
		statusHeight = 1
	end
}

--switch[statusHeight]()

function draw()
	sasl.gl.drawRectangle ( -35, 19, 250, 35, white)
	sasl.gl.drawRectangle ( -95, -30, 370, 40, white)
	sasl.gl.drawRectangle ( -100, 90, 390, 200, white)
	drawText(fnt, 90, 25, enabled, 30, false, false, TEXT_ALIGN_CENTER, black)
	drawText(fnt, 90, -10, "Follow me on my youtube chanel", 15, false, false, TEXT_ALIGN_CENTER, black)
	drawText(fnt, 90, -25, "https://www.youtube.com/@plane.spotting", 15, false, false, TEXT_ALIGN_CENTER, black)
	drawText(fnt, 100, 320, "WalkAround", 50, false, false, TEXT_ALIGN_CENTER, white)
	drawText(fnt, 85, 260, "Description", 20, false, false, TEXT_ALIGN_CENTER, red)
	drawText(fnt, 95, 230, "W, S, A, D is for movement", 20, false, false, TEXT_ALIGN_CENTER, black)
	drawText(fnt, 27, 200, "F is for crouch", 20, false, false, TEXT_ALIGN_CENTER, black)
	drawText(fnt, 80, 170, "Esc for disable the walk", 20, false, false, TEXT_ALIGN_CENTER, black)
	drawText(fnt, 93, 140, "For start click start walk", 20, false, false, TEXT_ALIGN_CENTER, black)
	drawText(fnt, 300, -75, "Version: 2.4", 10, false, false, TEXT_ALIGN_CENTER, white)
	drawText(fnt, 300, -90, "04/07/2023", 10, false, false, TEXT_ALIGN_CENTER, white)
	drawText(fnt, -100, -90, "by Raoul Origa", 10, false, false, TEXT_ALIGN_CENTER, white)
end

local function process_key(char, vkey, shiftDown, ctrlDown, altOptDown, event)
	if event == KB_DOWN_EVENT then
		if char == SASL_KEY_ESCAPE or char == SASL_KEY_RETURN then
			enabled = "Start Walking"
			return true
		end

		if vkey == SASL_VK_F then
			local acf_peY = globalPropertyf("sim/graphics/view/pilots_head_y")

			local f = switch[statusHeight]
			
			if f then
				f()
			end
			set(acf_peY, currentHeight)
		end
	end

	if shiftDown then
		if vkey == SASL_VK_W then
			keys[1] = true
		end
	
		if vkey == SASL_VK_S then
			keys[2] = true
		end

		if vkey == SASL_VK_A then
			keys[3] = true
		end

		if vkey == SASL_VK_D then
			keys[4] = true
		end
	end

	if event == KB_UP_EVENT then
		iswalking = false
		walk = 0
		both = false
		if vkey == SASL_VK_W then
			keys[1] = false -- Key W
		end
	
		if vkey == SASL_VK_S then
			keys[2] = false -- Key S
		end

		if vkey == SASL_VK_A then
			keys[3] = false -- Key A
		end
	
		if vkey == SASL_VK_D then
			keys[4] = false -- Key D
		end
	end

	return false
end

function onMouseDown(button)
	enabled = "Stop Walking"
	registerHandler(process_key)
	return true
end

obj = sasl.loadObject("Objects/Person.obj")
ballInst = sasl.createInstance(obj, {})

--[[local leftArm_Anim = coroutine.create(function()
	for i = 0, 1, .1 do
		coroutine.yield()
		sleep(1)
		print("Work")
		--set(get(leftArm_Anim), i)
	end
end)]]

local frame = globalPropertyf("sim/time/framerate_period")

function sleep(n)
	local time1 = os.clock()
	local time2 = time1
	while os.difftime(time2, time1) < 1 do 
		time2 = os.clock()
	end

	--[[print(os.clock())

	if os.clock() - time <= n then 
		coroutine.resume(leftArm_Anim)
	end]]
end

function leftArm_Anim()
	--sleep(1)
	for i = 0, 1, .1 do
		--print("Work")
		--set(get(leftArm_Anim), i)
	end
end

local cPos = { }

local frameNum = 0

function update()
	--[[local f = get(frame) * 100
	print(f)
	frameNum = frameNum + .03
	
	if frameNum < f / 1.5 then
		return
	end

	if frameNum == f then
		frameNum = 0
	end]]
	--------------------------------------------------------------------------------------------------------------------------------------
	if elevation == 0 or elevation == nil then
		--local checkPara = 
		if isProperty(globalPropertyf("sim/graphics/view/view_elevation_agl_mtrs")) then
			logDebug("metri")
			local meter = globalPropertyf("sim/graphics/view/view_elevation_agl_mtrs")
			elevation = get(meter)
			switch[1]()
			--print(elevation)
		else
			logDebug("piedi")
			local feet = globalPropertyf("sim/flightmodel/position/y_agl")
			elevation = get(feet) * 0.3048
			switch[1]()
			--print(elevation)
		end
	end
	
	if iswalking == true and settings.sound == true then
		if not isSamplePlaying(walkSound) then playSample(walkSound) end
	else
		stopSample(walkSound)
	end
	--------------------------------------------------------------------------------------------------------------------------------------
	--print("W: " .. tostring(keys[1]), "S: " .. tostring(keys[2]), "A: " .. tostring(keys[3]), "D: " .. tostring(keys[4]))
	if keys[1] and not both then
		local distance = .04
		local theta = globalPropertyf("sim/flightmodel/position/theta")
		local phi = globalPropertyf("sim/graphics/view/pilots_head_phi")
		local acf_peX = globalPropertyf("sim/graphics/view/pilots_head_x")
		local acf_peZ = globalPropertyf("sim/graphics/view/pilots_head_z")
		local acf_peY = globalPropertyf("sim/graphics/view/pilots_head_y")
		local heading = globalPropertyf("sim/graphics/view/pilots_head_psi")
		local roll = globalPropertyf("sim/graphics/view/field_of_view_roll_deg")
		
		local x = get(acf_peX)
		local z = get(acf_peZ)
		local y = get(acf_peY)
		local hdg = get(heading)
		local rol = get(roll)
		
		y = currentHeight
		angle = math.rad( hdg - 90 )
		sinX = x + distance * math.cos( angle )
		sinZ = z + distance * math.sin( angle )
		iswalking = true
		sinWalk = math.sin(walk)
		walk = walk + .6

		set(theta, 0)
		set(roll, 0)
		set(acf_peZ, sinZ)
		set(acf_peX, sinX)
		--print(y)

		if settings.walk_movement == true then
			set(acf_peY, y + (sinWalk * .015))
		else
			set(acf_peY, y)
		end
		--x, y, z = sasl.modelToLocal(-sinX, 0, -sinZ)
		--sasl.setInstancePosition(ballInst, x, y, z, 0, angle, 0, {})
		
		leftArm_Anim()
	end
	--------------------------------------------------------------------------------------------------------------------------------------
	if keys[2] and not both then
		local distance = .04
		--sim/flightmodel/position/theta
		local p_theta = globalPropertyf("sim/flightmodel/position/true_theta")
		local phi = globalPropertyf("sim/graphics/view/pilots_head_phi")
		local acf_peX = globalPropertyf("sim/graphics/view/pilots_head_x")
		local acf_peZ = globalPropertyf("sim/graphics/view/pilots_head_z")
		local acf_peY = globalPropertyf("sim/graphics/view/pilots_head_y")
		local heading = globalPropertyf("sim/graphics/view/pilots_head_psi")
		local roll = globalPropertyf("sim/graphics/view/field_of_view_roll_deg")

		local p = get(phi)
		local theta = get(p_theta) * (-1)
		local x = get(acf_peX)
		local z = get(acf_peZ)
		local y = get(acf_peY)
		local hdg = get(heading)
		local rol = get(roll)

		angle = math.rad( hdg - 90 )
		sinX = x - distance * math.cos( angle )
		sinZ = z - distance * math.sin( angle )
		iswalking = true
		sinWalk = math.sin(walk)
		walk = walk + .6

		set(p, theta)
		set(roll, 0)
		set(acf_peZ, sinZ)
		set(acf_peX, sinX)
		--set(acf_peY, currentHeight)

		if settings.walk_movement == true then
			set(acf_peY, currentHeight + (sinWalk * .015))
		else
			set(acf_peY, currentHeight)
		end
		--x, y, z = sasl.modelToLocal(-sinX, 0, -sinZ)
		--sasl.setInstancePosition(ballInst, x, y, z, 0, angle, 0, {})
		--cPos = {x, y, z}
	end
	--------------------------------------------------------------------------------------------------------------------------------------
	if keys[3] and not both then
		local distance = .04
		--sim/flightmodel/position/theta
		local p_theta = globalPropertyf("sim/flightmodel/position/true_theta")
		local phi = globalPropertyf("sim/graphics/view/pilots_head_phi")
		local acf_peX = globalPropertyf("sim/graphics/view/pilots_head_x")
		local acf_peZ = globalPropertyf("sim/graphics/view/pilots_head_z")
		local acf_peY = globalPropertyf("sim/graphics/view/pilots_head_y")
		local heading = globalPropertyf("sim/graphics/view/pilots_head_psi")
		local roll = globalPropertyf("sim/graphics/view/field_of_view_roll_deg")

		local p = get(phi)
		local theta = get(p_theta) * (-1)
		local x = get(acf_peX)
		local z = get(acf_peZ)
		--local y = get(acf_peY)
		local hdg = get(heading)
		local rol = get(roll)

		angle = math.rad( hdg )
		sinX = x - distance * math.cos( angle )
		sinZ = z - distance * math.sin( angle )
		iswalking = true
		sinWalk = math.sin(walk)
		walk = walk + .6

		set(p, theta)
		set(roll, 0)
		set(acf_peZ, sinZ)
		set(acf_peX, sinX)
		set(acf_peY, 0.5)

		if settings.walk_movement == true then
			set(acf_peY, currentHeight + (sinWalk * .015))
		else
			set(acf_peY, currentHeight)
		end
		--x, y, z = sasl.modelToLocal(-sinX, 0, -sinZ)
		--sasl.setInstancePosition(ballInst, x, y, z, 0, angle, 0, {})

	end
	--------------------------------------------------------------------------------------------------------------------------------------
	if keys[4] and not both then
		local distance = .04
		--sim/flightmodel/position/theta
		local p_theta = globalPropertyf("sim/flightmodel/position/true_theta")
		local phi = globalPropertyf("sim/graphics/view/pilots_head_phi")
		local acf_peX = globalPropertyf("sim/graphics/view/pilots_head_x")
		local acf_peZ = globalPropertyf("sim/graphics/view/pilots_head_z")
		local acf_peY = globalPropertyf("sim/graphics/view/pilots_head_y")
		local heading = globalPropertyf("sim/graphics/view/pilots_head_psi")
		local roll = globalPropertyf("sim/graphics/view/field_of_view_roll_deg")

		local p = get(phi)
		local theta = get(p_theta) * (-1)
		local x = get(acf_peX)
		local z = get(acf_peZ)
		--local y = get(acf_peY)
		local hdg = get(heading)
		local rol = get(roll)

		angle = math.rad( hdg )
		sinX = x + distance * math.cos( angle )
		sinZ = z + distance * math.sin( angle )
		--iswalking = true
		sinWalk = math.sin(walk)
		walk = walk + .6

		set(p, theta)
		set(roll, 0)
		set(acf_peZ, sinZ)
		set(acf_peX, sinX)
		--set(acf_peY, 0.5)

		if settings.walk_movement == true then
			set(acf_peY, currentHeight + (sinWalk * .015))
		else
			set(acf_peY, currentHeight)
		end
		--x, y, z = sasl.modelToLocal(-sinX, 0, -sinZ)
		--sasl.setInstancePosition(ballInst, x, y, z, 0, angle, 0, {})
	end
	--------------------------------------------------------------------------------------------------------------------------------------
	if keys[1] and keys[4] then
		both = true
		local distance = .04
		--sim/flightmodel/position/theta
		local p_theta = globalPropertyf("sim/flightmodel/position/true_theta")
		local phi = globalPropertyf("sim/graphics/view/pilots_head_phi")
		local acf_peX = globalPropertyf("sim/graphics/view/pilots_head_x")
		local acf_peZ = globalPropertyf("sim/graphics/view/pilots_head_z")
		local acf_peY = globalPropertyf("sim/graphics/view/pilots_head_y")
		local heading = globalPropertyf("sim/graphics/view/pilots_head_psi")
		local roll = globalPropertyf("sim/graphics/view/field_of_view_roll_deg")

		local p = get(phi)
		local theta = get(p_theta) * (-1)
		local x = get(acf_peX)
		local z = get(acf_peZ)
		local y = get(acf_peY)
		local hdg = get(heading)
		local rol = get(roll)

		angle = math.rad( hdg + 135 )
		sinX = x - distance * math.cos( angle )
		sinZ = z - distance * math.sin( angle )
		iswalking = true
		sinWalk = math.sin(walk)
		walk = walk - .7

		set(p, theta)
		set(roll, 0)
		set(acf_peZ, sinZ)
		set(acf_peX, sinX)
		set(acf_peY, 0.5)

		if settings.walk_movement == true then
			set(acf_peY, currentHeight + (sinWalk * .015))
		else
			set(acf_peY, currentHeight)
		end
		--x, y, z = sasl.modelToLocal(-sinX, 0, -sinZ)
		--sasl.setInstancePosition(ballInst, x, y, z, 0, angle, 0, {})
	end
	--------------------------------------------------------------------------------------------------------------------------------------
	if keys[1] and keys[3] then
		both = true
		local distance = .04
		--sim/flightmodel/position/theta
		local p_theta = globalPropertyf("sim/flightmodel/position/true_theta")
		local phi = globalPropertyf("sim/graphics/view/pilots_head_phi")
		local acf_peX = globalPropertyf("sim/graphics/view/pilots_head_x")
		local acf_peZ = globalPropertyf("sim/graphics/view/pilots_head_z")
		local acf_peY = globalPropertyf("sim/graphics/view/pilots_head_y")
		local heading = globalPropertyf("sim/graphics/view/pilots_head_psi")
		local roll = globalPropertyf("sim/graphics/view/field_of_view_roll_deg")

		local p = get(phi)
		local theta = get(p_theta) * (-1)
		local x = get(acf_peX)
		local z = get(acf_peZ)
		local y = get(acf_peY)
		local hdg = get(heading)
		local rol = get(roll)

		angle = math.rad( hdg - 135 )
		sinX = x + distance * math.cos( angle )
		sinZ = z + distance * math.sin( angle )
		iswalking = true
		sinWalk = math.sin(walk)
		walk = walk - .7

		set(p, theta)
		set(roll, 0)
		set(acf_peZ, sinZ)
		set(acf_peX, sinX)
		set(acf_peY, 0.5)

		if settings.walk_movement == true then
			set(acf_peY, currentHeight + (sinWalk * .015))
		else
			set(acf_peY, currentHeight)
		end
		--x, y, z = sasl.modelToLocal(-sinX, 0, -sinZ)
		--sasl.setInstancePosition(ballInst, x, y, z, 0, angle, 0, {})
	end
	--------------------------------------------------------------------------------------------------------------------------------------
	if keys[2] and keys[3] then
		both = true
		local distance = .04
		--sim/flightmodel/position/theta
		local p_theta = globalPropertyf("sim/flightmodel/position/true_theta")
		local phi = globalPropertyf("sim/graphics/view/pilots_head_phi")
		local acf_peX = globalPropertyf("sim/graphics/view/pilots_head_x")
		local acf_peZ = globalPropertyf("sim/graphics/view/pilots_head_z")
		local acf_peY = globalPropertyf("sim/graphics/view/pilots_head_y")
		local heading = globalPropertyf("sim/graphics/view/pilots_head_psi")
		local roll = globalPropertyf("sim/graphics/view/field_of_view_roll_deg")

		local p = get(phi)
		local theta = get(p_theta) * (-1)
		local x = get(acf_peX)
		local z = get(acf_peZ)
		local y = get(acf_peY)
		local hdg = get(heading)
		local rol = get(roll)

		angle = math.rad( hdg - 45 )
		sinX = x - distance * math.cos( angle )
		sinZ = z - distance * math.sin( angle )
		iswalking = true
		sinWalk = math.sin(walk)
		walk = walk - .7

		set(p, theta)
		set(roll, 0)
		set(acf_peZ, sinZ)
		set(acf_peX, sinX)
		set(acf_peY, 0.5)

		if settings.walk_movement == true then
			set(acf_peY, currentHeight + (sinWalk * .015))
		else
			set(acf_peY, currentHeight)
		end
	--	x, y, z = sasl.modelToLocal(-sinX, 0, -sinZ)
	--	sasl.setInstancePosition(ballInst, x, y, z, 0, angle, 0, {})
	end
	--------------------------------------------------------------------------------------------------------------------------------------
	if keys[2] and keys[4] then
		both = true
		local distance = .04
		--sim/flightmodel/position/theta
		local p_theta = globalPropertyf("sim/flightmodel/position/true_theta")
		local phi = globalPropertyf("sim/graphics/view/pilots_head_phi")
		local acf_peX = globalPropertyf("sim/graphics/view/pilots_head_x")
		local acf_peZ = globalPropertyf("sim/graphics/view/pilots_head_z")
		local acf_peY = globalPropertyf("sim/graphics/view/pilots_head_y")
		local heading = globalPropertyf("sim/graphics/view/pilots_head_psi")
		local roll = globalPropertyf("sim/graphics/view/field_of_view_roll_deg")

		local p = get(phi)
		local theta = get(p_theta) * (-1)
		local x = get(acf_peX)
		local z = get(acf_peZ)
		local y = get(acf_peY)
		local hdg = get(heading)
		local rol = get(roll)

		angle = math.rad( hdg - 135 )
		sinX = x - distance * math.cos( angle )
		sinZ = z - distance * math.sin( angle )
		iswalking = true
		sinWalk = math.sin(walk)
		walk = walk - .7

		set(p, theta)
		set(roll, 0)
		set(acf_peZ, sinZ)
		set(acf_peX, sinX)
		set(acf_peY, 0.5)

		if settings.walk_movement == true then
			set(acf_peY, currentHeight + (sinWalk * .015))
		else
			set(acf_peY, currentHeight)
		end
		--x, y, z = sasl.modelToLocal(-sinX, 0, -sinZ)
		--sasl.setInstancePosition(ballInst, x, y, z, 0, angle, 0, {})
	end
	--------------------------------------------------------------------------------------------------------------------------------------
	--if not iswalking then
		local heading = globalPropertyf("sim/graphics/view/pilots_head_psi")

		local hdg = get(heading)

		x, y, z = sasl.modelToLocal(-sinX, 0, -sinZ)
		sasl.setInstancePosition(ballInst, x, y, z, 0, hdg, 0, {})
	--end
end