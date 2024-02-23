require "prop"

local MapEditCom = {}
MapEditCom.__index = MapEditCom

function MapEditCom:define(prototype, action, undo)
	local p = Props:prototype(prototype)
	local obj = {
		new = function(self, props)
			local this = {
				props  = p(props),
				__action = action,
				__undo   = undo,

				commit = function(self)
					self.__action(self.props)
				end,

				undo = function(self)
					self.__undo(self.props)
				end
			}

			return this
		end
	}

	return obj
end

function MapEditCom:compose(coms)
	local this = {
		props  = nil,

		commit = function(self)
			local I = #coms
			for i=1,I do
				coms[i]:commit()
			end
		end,

		undo = function(self)
			local I = #coms
			for i=I,1,-1 do
				coms[i]:undo()
			end
		end
	}

	return this
end

return MapEditCom
