-- filter resources
--

local filters = {

	defs = {
		["invert_hsl"] = {
			filter_implement = "shader",
			name = "Invert (HSL)",
			shader = "filter/invert.glsl",
			params = {},
			defaults = {},
		},
		["hsl_adjust"] = {
			filter_implement = "shader",
			name = "Adjust HSL",
			shader = "filter/hsl_adjust.glsl",
			params = {"hueShift","satScale","lumScale","lumCurvedRemap"},
			defaults = {hueShift=0.0,satScale=1.0,lumScale=1.0,lumCurvedRemap=1.0},
		},
		["contrast"] = {
			filter_implement = "shader",
			name = "Contrast/Brightness",
			shader = "filter/contrast.glsl",
			params = {"lumBrightness","lumContrast"},
			defaults = {lumBrightness=0.0,lumContrast=1.0},
		},
	},

	loaded = {

	},

}

function filters.get(name)
	local def = filters.defs[name]
	if not def then error("filters.get(): Undefined filter " .. tostring(name)) end

	if filters.loaded[name] then return filters.loaded[name] end

	local filter = require 'filter'
	local f

	if def.filter_implement == "shader" then
		f = filter:define_shader_filter(def.shader,def.params,def.defaults,def.name)
	else
		error("Unknown filter type " .. def.filter_implement)
	end

	filters.loaded[name] = f
	return f
end

return filters
