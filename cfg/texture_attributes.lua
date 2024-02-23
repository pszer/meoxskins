local TEXTURE_ATTRIBUTES = {
	["nil"] = {
		texture_type = "2d",
		texture_animated = false
	},

	["dirt.png"] = {
		texture_wrap_mode = "repeat",
		texture_type      = "2d",
		texture_animated  = false
	},
	["dirt2.png"] = {
		texture_wrap_mode = "repeat",
		texture_type      = "2d",
		texture_animated  = false
	},

	["water.png"] = {
		texture_sequence = {1,2,3,4,3,2},
		texture_animation_delay = 8
	},

	["skyday01.png"] = {
		texture_type = "cube"
	}
}
return TEXTURE_ATTRIBUTES
