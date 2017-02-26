--search and include KLN 90, if it exist in Custom Avionics

createGlobalPropertyi("sim/custom/kln_is_present", 0) -- поворот передней стойки шасси -70 влево, +70 вправо

defineProperty("kln_is_present", globalPropertyf("sim/custom/kln_is_present"))


createProp("sim/custom/kln_power", "int", 1);
defineProperty("kln_power", globalPropertyi("sim/custom/kln_power"));
defineProperty("bus_DC_27_volt", globalPropertyf("sim/custom/xap/An24_power/bus_DC_27_volt")) 

-- check if KLN main file is present and enable it if so.
if isFileExists(panelDir.."/Custom Avionics/KLN to connect/KLN90.lua") then
	print("Found the KLN90, trying to load it. Adding \"./Custom Avionics/KLN to connect\" to the SASL load paths.")

	-- for later: this would be really neat to do for user-friendliness
	-- print("Peeking outside the X-Plane dir to see if you got the KLN90 nav data and output files installed...")
	print("IMPORTANT: Make sure to copy the contents of `Install_into_main_XP_directory` into your X-Plane root directory,")
	print("these files contain the KLN navdata and the default flight plans")

	-- Add the KLN dir to the component search path. The path we add MUST be absolute to be considered by SASL.
	addSearchPath(panelDir.."/Custom Avionics/KLN to connect")

	-- Attempt to load them and fail loudly if nopes.
	include("KLN to connect/rectangle2.lua") 
	include("KLN to connect/KLN90_panel.lua") 
	include("KLN to connect/KLN90.lua")
	set(kln_is_present, 1)
	-- decided to exclude the 2D panel and use only 3D one.
end

function update()
	-- KLN power calculation
	if get(bus_DC_27_volt) > 19 then
		set(kln_power, 1)
	else
		set(kln_power, 1)
	end
end
