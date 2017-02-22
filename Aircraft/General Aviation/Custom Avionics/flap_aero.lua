defineProperty("cl", globalPropertyf("sim/aircraft/controls/acf_flap_cl"))
defineProperty("cd", globalPropertyf("sim/aircraft/controls/acf_flap_cd"))
defineProperty("cm", globalPropertyf("sim/aircraft/controls/acf_flap_cm"))
defineProperty("flap", globalPropertyf("sim/cockpit2/controls/flap_ratio"))


function update()
flapratio = get(flap)
flapcl = 1.1 * flapratio
flapcd = 0.05 * flapratio
flapcm = -1.0 * flapratio
set(cl , flapcl)
set(cd , flapcd)
set(cm , flapcm)
end
