local modelv = require 'modelverts'
--local cpml   = require 'cpml'
local mat    = require 'mat4'

v_format = {
	{"VertexPosition", "float", 3},
	{"VertexTexCoord", "float", 2},
	{"VertexNormal", "float", 3},
}

local model = {

	parts = {
		head    = love.graphics.newMesh(v_format, modelv.head   , "triangles", "static"),
		head_o  = love.graphics.newMesh(v_format, modelv.head_o , "triangles", "static"),
		torso   = love.graphics.newMesh(v_format, modelv.torso  , "triangles", "static"),
		torso_o = love.graphics.newMesh(v_format, modelv.torso_o, "triangles", "static"),

		leg_l = love.graphics.newMesh(v_format, modelv.leg_l, "triangles", "static"),
		leg_l_o = love.graphics.newMesh(v_format, modelv.leg_l_o, "triangles", "static"),
		leg_r = love.graphics.newMesh(v_format, modelv.leg_r, "triangles", "static"),
		leg_r_o = love.graphics.newMesh(v_format, modelv.leg_r_o, "triangles", "static"),

		arm_slim_r   = love.graphics.newMesh(v_format, modelv.arm_slim_r, "triangles", "static"),
		arm_slim_r_o = love.graphics.newMesh(v_format, modelv.arm_slim_r_o, "triangles", "static"),
		arm_slim_l   = love.graphics.newMesh(v_format, modelv.arm_slim_l, "triangles", "static"),
		arm_slim_l_o = love.graphics.newMesh(v_format, modelv.arm_slim_l_o, "triangles", "static"),

		arm_wide_r   = love.graphics.newMesh(v_format, modelv.arm_wide_r, "triangles", "static"),
		arm_wide_r_o = love.graphics.newMesh(v_format, modelv.arm_wide_r_o, "triangles", "static"),
		arm_wide_l   = love.graphics.newMesh(v_format, modelv.arm_wide_l, "triangles", "static"),
		arm_wide_l_o = love.graphics.newMesh(v_format, modelv.arm_wide_l_o, "triangles", "static"),
	},

	draw_order = {
		"head",
		"torso",
		"arm_slim_r",
		"arm_slim_l",
		"arm_wide_r",
		"arm_wide_l",
		"leg_l",
		"leg_r",

		"head_o",
		"torso_o",
		"arm_slim_r_o",
		"arm_slim_l_o",
		"arm_wide_r_o",
		"arm_wide_l_o",
		"leg_l_o",
		"leg_r_o",
	},

	visible = {
		["head"]   = true,
		["head_o"] = true,

		["torso"]  = true,
		["torso_o"]  = true,

		["arm_slim_r"]  = false,
		["arm_slim_r_o"]  = false,
		["arm_slim_l"]  = false,
		["arm_slim_l_o"]  = false,

		["arm_wide_r"]  = true,
		["arm_wide_r_o"]  = true,
		["arm_wide_l"]  = true,
		["arm_wide_l_o"]  = true,

		["leg_l"]  = true,
		["leg_l_o"]  = true,

		["leg_r"]  = true,
		["leg_r_o"]  = true,
	},

	model_mats = {
		["head"] = {
			mat = mat.new(),
			pos = mat.trans{0,-6,0},
			rot = mat.rot  {0,0,0},
		},

		["torso"] = {
			mat = mat.new(),
			pos = mat.trans{0,-6,-2},
			rot = mat.rot  {0,0,0},
		},

		["leg_l"] = {
			mat = mat.new(),
			pos = mat.trans{-2,6,-2},
			rot = mat.rot  {0,0,0.05},
		},

		["leg_r"] = {
			mat = mat.new(),
			pos = mat.trans{2, 6,-2},
			rot = mat.rot  {0,0,-0.05},
		},

		["arm_slim_r"] = {
			mat = mat.new(),
			pos = mat.trans{6,-6,-2},
			rot = mat.rot  {0,0,-0.1},
		},

		["arm_slim_l"] = {
			mat = mat.new(),
			pos = mat.trans{-6,-6,-2},
			rot = mat.rot  {0,0,0.1},
		},

		["arm_wide_r"] = {
			mat = mat.new(),
			pos = mat.trans{6,-6,-2},
			rot = mat.rot  {0,0,-0.1},
		},

		["arm_wide_l"] = {
			mat = mat.new(),
			pos = mat.trans{-6,-6,-2},
			rot = mat.rot  {0,0,0.1},
		},
	}
}

-- overlays share transform with base parts
model.model_mats.head_o = model.model_mats.head
model.model_mats.torso_o = model.model_mats.torso
model.model_mats.arm_slim_r_o = model.model_mats.arm_slim_r
model.model_mats.arm_wide_r_o = model.model_mats.arm_wide_r
model.model_mats.arm_slim_l_o = model.model_mats.arm_slim_l
model.model_mats.arm_wide_l_o = model.model_mats.arm_wide_l
model.model_mats.leg_l_o = model.model_mats.leg_l
model.model_mats.leg_r_o = model.model_mats.leg_r

function model:applyLayerTexture(tex, shader)
	local shader = shader or love.graphics.getShader()
	if shader:hasUniform("SkinTexture") then
		shader:send("SkinTexture", tex)
	end
end

function model:getVisibleParts()
	local t = {}
	for i,label in ipairs(self.draw_order) do
		if self.visible[label] then
			table.insert(t, {
				mesh = self.parts[label],
				mat  = self:getModelMatrix(label)
			})
		end
	end
	return t
end

function model:generateModelMatrix(label)
	if label then
		local T = self.model_mats[label]
		T.mat = T.pos * T.rot
	else
		for label,v in pairs(self.model_mats) do
			self:generateModelMatrix(label)
		end
	end
end

function model:getModelMatrix(label)
	return self.model_mats[label].mat
end

function model:setupVisibility(mode)
	local mode = mode or "wide"

	if mode == "wide" then
		self.visible = {
			["head"]   = true,
			["head_o"] = true,

			["torso"]  = true,
			["torso_o"]  = true,

			["arm_slim_r"]  = false,
			["arm_slim_r_o"]  = false,
			["arm_slim_l"]  = false,
			["arm_slim_l_o"]  = false,

			["arm_wide_r"]  = true,
			["arm_wide_r_o"]  = true,
			["arm_wide_l"]  = true,
			["arm_wide_l_o"]  = true,

			["leg_l"]  = true,
			["leg_l_o"]  = true,

			["leg_r"]  = true,
			["leg_r_o"]  = true,
		}
	else
		self.visible = {
			["head"]   = true,
			["head_o"] = true,

			["torso"]  = true,
			["torso_o"]  = true,

			["arm_slim_r"]  = true,
			["arm_slim_r_o"]  = true,
			["arm_slim_l"]  = true,
			["arm_slim_l_o"]  = true,

			["arm_wide_r"]  = false,
			["arm_wide_r_o"]  = false,
			["arm_wide_l"]  = false,
			["arm_wide_l_o"]  = false,

			["leg_l"]  = true,
			["leg_l_o"]  = true,

			["leg_r"]  = true,
			["leg_r_o"]  = true,
		}
	end
end

return model
