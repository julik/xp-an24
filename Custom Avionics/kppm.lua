size = {200, 200}

-- define property table
-- source
defineProperty("gyro_curse", globalPropertyf("sim/custom/xap/An24_gauges/GIK_curse"))  -- gyro curse from GIK
defineProperty("frame_time", globalPropertyf("sim/custom/xap/An24_time/frame_time")) -- time for frames
defineProperty("flight_time", globalPropertyf("sim/time/total_running_time_sec")) -- sim time


defineProperty("hor_def", globalPropertyf("sim/custom/xap/An24_gauges/curs_1"))
defineProperty("vert_def", globalPropertyf("sim/custom/xap/An24_gauges/glide_1"))
defineProperty("curs_flag", globalPropertyf("sim/custom/xap/An24_gauges/k1_flag"))
defineProperty("glide_flag", globalPropertyf("sim/custom/xap/An24_gauges/g1_flag"))

defineProperty("SC_master", globalPropertyi("scp/api/ismaster")) -- status of SmartCopilot
defineProperty("scale_angle_smartcopilot", globalPropertyf("sim/custom/xap/An24_gauges/scale_angle_1_smartcopilot")) -- dataref for SmartCopilot synchronisation
defineProperty("rotate_dir_smartcopilot", globalPropertyi("sim/custom/xap/An24_gauges/rotate_dir_1_smartcopilot")) -- dataref for SmartCopilot synchronisation
defineProperty("sc_curse_angle", globalPropertyf("sim/custom/xap/An24_gauges/sc_KPPM_1_curse_angle")) -- dataref for SmartCopilot synchronisation
-- signals to autopilot
--defineProperty("ap_curse") -- curse for autopilot

-- images
defineProperty("scale", loadImage("kppm.png", -0.5, 0.5, 196, 196))
defineProperty("curse_needle", loadImage("kppm.png", 202.5, 12, 22, 172))
defineProperty("scale_triangle", loadImage("kppm.png", 30, 223, 13, 23))
defineProperty("v_plank_img", loadImage("kppm.png", 200, 0, 2, 110))
defineProperty("h_plank_img", loadImage("kppm.png", 0, 200, 110, 2)) 
defineProperty("flag_img", loadImage("kppm.png", 2, 224, 22, 22)) 
defineProperty("knob_img", loadImage("needles.png", 344, 89, 51, 51)) 

-- local variables
local scale_angle = 0
local curse_angle = 0
local rotate_dir = 0
local curse_plank = 0
local glide_plank = 0
local curse_flag_vis = true
local glide_flag_vis = true

-- postframe calculaions
function update()
	-- time calculations
	local passed = get(frame_time)
-- time bug workaround
if passed > 0 then
	-- rotate scale
	if get(SC_master) ~= 1 then
		scale_angle = scale_angle + (rotate_dir + get(rotate_dir_smartcopilot)) * passed * 20 	
		if scale_angle > 180 then 
			scale_angle = scale_angle - 360
		elseif scale_angle < -180 then
			scale_angle = scale_angle + 360
		end
		set(scale_angle_smartcopilot, scale_angle)
	else
		scale_angle = get(scale_angle_smartcopilot)
	end

	if get(SC_master) == 1 then
		curse_angle = get(sc_curse_angle)
	else
		local v = get(gyro_curse) + scale_angle     
		local delta = v - curse_angle
		if delta > 180 then delta = delta - 360
		elseif delta < -180 then delta = delta + 360 end
		curse_angle = curse_angle + 5 * delta * passed
		if curse_angle > 180 then curse_angle = curse_angle - 360
		elseif curse_angle < -180 then curse_angle = curse_angle + 360 end
		set(sc_curse_angle,curse_angle)
	end
	
    -- set curse for AP
    --set(ap_curse, curse_angle)
    
    -- smooth move of course plank
    local cur = get(hor_def) * 15
    local cur_delta = cur - curse_plank
    curse_plank = curse_plank + 3 * cur_delta * passed
    --print(cur, curse_plank)
	
    -- smooth move of glideslope plank
    local glide = -get(vert_def) * 15
    local glide_delta = glide - glide_plank
    glide_plank = glide_plank + 3 * glide_delta * passed   
       
    -- set limits
    --[[
    if curse_plank < -20 then curse_plank = -20
    elseif curse_plank > 20 then curse_plank = 20 end
	if glide_plank < -20 then glide_plank = -20
	elseif glide_plank > 20 then glide_plank = 20 end --]]
	
	-- flag visibility
	curse_flag_vis = get(curs_flag) == 1
	glide_flag_vis = get(glide_flag) == 1
    
end

end


components = {
	-- position gauge
--[[	rectangle {
		position = {99, 99, 2, 2},
		color = {1, 0, 0, 1},
	}, --]]
	
	-- course flag
	texture {
		position = {109, 110, 18, 18},
		image = get(flag_img),
		visible = function()
			return curse_flag_vis
		end
	},

	-- glide flag
	texture {
		position = {72.5, 73, 18, 18},
		image = get(flag_img),
		visible = function()
			return glide_flag_vis
		end
	},	
	
    -- vertical plank
    free_texture {
        image = get(v_plank_img),
        position_x = function() 
             return 99 + curse_plank
             end,
        position_y = 45,
        width = 2,
        height = 110, 
    },
	
    -- horizontal plank
    free_texture {
        image = get(h_plank_img),
        position_x = 45,
        position_y = function() 
             return 99 + glide_plank
             end,
        width = 110,
        height = 2, 
    },	
	
	-- scale
	needle {
		position = {2, 2, 196, 196,},
		image = get(scale),
		angle = function()
			return scale_angle
		end 
	},
	
	-- curse needle
	needle {
		position = {15, 15, 170, 170,},
		image = get(curse_needle),
		angle = function()
			return curse_angle
		end 
	},	

	-- position triangle
	texture {
		position = {94, 177, 12, 23},
		image = get(scale_triangle),
	
	},

	-- knob
	needle {
		position = {167, 2, 31, 31},
		image = get(knob_img),
		angle = function()
			return -scale_angle * 5
		end 
	},	
	
	-- scale rotary
	clickable {
        position = {169, 5, 15, 27},  -- search and set right
        
       cursor = { 
            x = 16, 
            y = 32,  
            width = 16, 
            height = 16, 
            shape = loadImage("rotateleft.png")
        },  
        
       	onMouseClick = function() 
			rotate_dir = 1
			set(rotate_dir_smartcopilot, 1)
			return true
		end,
		onMouseUp = function()
			rotate_dir = 0
			set(rotate_dir_smartcopilot, 0)			
			return true		
		end
		
    },
	clickable {
        position = {184, 5, 15, 27},  -- search and set right
        
       cursor = { 
            x = 16, 
            y = 32, 
            width = 16, 
            height = 16, 
            shape = loadImage("rotateright.png")
        },  
        
       	onMouseClick = function() 
			rotate_dir = -1
			set(rotate_dir_smartcopilot, -1)
			return true
		end,
		onMouseUp = function()
			rotate_dir = 0	
			set(rotate_dir_smartcopilot, 0)
			return true		
		end
    },




}