--
-- map edit context menu
--

require "prop"

local guirender = require 'gui.guidraw'

local popup = require 'gui.popup'

local MapEditContext = {
	__type = "mapeditcontextmenu",
	buffer_info = {
		l  = 24,
		l_no_icon  = 4,
		r = 6,
		t = 5,
		b = 3,

		arrow_r = 20,
		arrow_t = 1,

		icon_l = 2,
		icon_t = 1,
	}
}
MapEditContext.__index = MapEditContext

--
-- prototype is a prop table prototype for the interal properties
-- each instance of this context menu can have, these then can
-- be dynamically filled out on instance creation
--
-- argument after that are the definitions for options in this context menu.
-- it's expected to be a function(props) that returns any number of options.
-- each option has the following format:
-- 1. {name, action = function, disable = bool, icon = string }
-- 2. {name, suboptions = function}
-- 3. {name}
--
-- in format (1), action is a function(self.props) that gets called when the option is clicked
-- if disable is set to true, the option is disabled from being clicked and is greyed out
--
-- in format (2), suboptions is a function(self.props) that when called returns
-- a table of options, these options are then displayed alongside the original context
-- menu. 
--
-- format (3) is simply text
--
-- the name argument for each option can either be a string or a table. a string argument
-- behaves as you'd expect. if it's a table the string to display is formatted using string.format,
-- the first argument in the table is the string format, arguments after that are the names for
-- properties found in this context menu's property table to feed into string.format OR a
-- function(self.props) that returns the desired datum. note that these strings are made upon
-- instanciation, so they cannot be dynamically changed.
-- look at mapeditguidraw.lua createDrawableText() for extra text formatting options
--
--
--
-- once a context menu is defined, instances of it can be created using
-- contextmenu:new({key=value,...}, x, y)
--

function MapEditContext:define(prototype, options)
	local buffer_info = self.buffer_info
	--local options = { ... }

	local p = Props:prototype(prototype)
	local obj = {
		new = function(self, props, X, Y)

			local last_mx, last_my = {}, {}
			last_mx[1],last_my[1]=love.mouse.getX(),love.mouse.getY()
			--local last_mx[2],last_my[2]=love.mouse.getX(),love.mouse.getY()

			local this = { -- this
				props  = p(props),
				options = {},
				x = X or love.mouse.getX(),
				y = Y or love.mouse.getY(),

				tooltip = nil,

				--
				-- this functions
				--

				release = function(self)
					-- recursively delete text&bg objects
					local function clr(opts, clr)
						for i,v in ipairs(opts) do
							if v.text then v.text:release() end
							if v.bg   then v.bg:release() end
							if v.suboptions then
								clr(v.suboptions, clr)
							end
						end
					end
					clr(self.options, clr)
				end,

				draw = function(self)
					local function draw_option_list(opts, draw_option_list)
						love.graphics.setColor(1,1,1,1)
						for i,v in ipairs(opts) do
							local x,y = v.x,v.y
							--draw_option(x,y,v)

							local state
							if v.hover and not v.disable and (v.action or v.suboptions) then
								state="hover"
							elseif v.disable then
								state="disable"
							else
								state="normal"
							end
							guirender:drawGenericOption(x,y,v.w,v.h, v.bg,v.text,v.icon, v.suboptions~=nil, state, MapEditContext.buffer_info)

							if v.suboptions and v.expand then
								draw_option_list(v.suboptions, draw_option_list)
							end
						end
					end
					draw_option_list(self.options,draw_option_list)
					if self.tooltip then
						self.tooltip:draw()
					end
				end,

				updateHoverInfo = function(self,mx,my)
					local mx = mx or love.mouse.getX()
					local my = my or love.mouse.getY()

					local function in_rect(u,v, x,y,w,h)
						return u >= x and u <= x+w and
						       v >= y and v <= y+h
					end

					local function test_options(opts, test_options)
						local hovered = false
						local skip = false
						for i,v in ipairs(opts) do
							local subopts  = v.suboptions

							if skip then
								v.hover = false
								v.expand = false
							elseif not subopts then
								local x,y,w,h = v.x, v.y, v.w, v.h
								local hov = in_rect(mx,my, x,y,w,h)
								if hov then
									skip = true -- skip checking all the other options, setting them
												-- all to v.hover = false
									v.hover = true
									v.expand = false
									hovered = true
								else
									v.hover = false
									v.expand = false
								end
							else
								local x,y,w,h = v.x, v.y, v.w, v.h
								local hov = in_rect(mx,my, x,y,w,h)
								if hov then
									skip = true
									v.hover = true
									v.expand = true
									hovered = true
									test_options(subopts, test_options)
								elseif v.expand then
									local suboptions_hovered = test_options(subopts, test_options)
									v.hover = false
									v.expand = suboptions_hovered
									skip = suboptions_hovered
									hovered = suboptions_hovered
								end
							end
						end
						return hovered
					end

					local result = test_options(self.options, test_options)

					if mx==(last_mx[15]or-1) and my==(last_my[15]or-1) then
						local h = self:getCurrentlyHoveredOption()
						if not self.tooltip and h and h.tooltip then
							self.tooltip = popup:throw(h.tooltip,10000)
						end
					else
						if self.tooltip then
							self.tooltip:release()
							self.tooltip = nil
						end
					end

					for i=15,2,-1 do
						last_mx[i]=last_mx[i-1]
						last_my[i]=last_my[i-1]
					end
					last_mx[1],last_my[1]=mx,my

					return result
				end,

				getCurrentlyHoveredOption = function(self)
					local function search(opts, search)
						for i,v in ipairs(opts) do
							if v.hover then return v end
							if v.suboptions then
								local r = search(v.suboptions, search)
								if r then return r end
							end
						end
						return nil
					end
					local found = search(self.options, search)
					if found and found.disable then return nil end
					return found
				end
			} -- this

			function this.setX(self,x)
				end
			function this.setY(self,y)
				end
			function this.setW(self,w)
				end
			function this.setH(self,h) -- height is fixed
				end

			local function fill_out_option(v, fill_out_option)
				local name = v[1]
				local action  = v.action
				local disable = v.disable
				local subopt  = v.suboptions
				local text_drawable = nil
				local icon = guirender.icons[v.icon] or nil
				local tooltip = v.tooltip

				assert(name, "MapEditContext:define(): no name given for an option")

				if action and subopt then
					error("MapEditContext:define(): option has both an action and suboption generator")
				end

				if type(disable) == "function" then
					v.disable = disable(this.props)
				end

				text_drawable = guirender:drawableFormatString(name, this.props)

				local w,h = text_drawable:getDimensions()
				if icon then
					w = w + buffer_info.l + buffer_info.r
				else
					w = w + buffer_info.l_no_icon + buffer_info.r
				end
				h = h + buffer_info.t + buffer_info.b

				local subopt_table = nil
				if subopt then
					subopt_table = {}
					subopt = subopt(this.props)
					for i,v in ipairs(subopt) do
						subopt_table[i] = fill_out_option(v, fill_out_option)
					end
				end

				local call_f = nil
				if action then
					call_f = function()
						return action(this.props)
					end
				end
				local o =
					{text=text_drawable,
				 	 action=call_f,
				 	 suboptions=subopt_table,
					 expand = false,
					 hover = false,
					 disable=disable,
					 w=w,
					 h=h,
					 x=0,
					 y=0,
					 bg=nil,
					 icon = icon,
					 tooltip=tooltip}
				return o
			end

			local function create_bgs(opts, create_bgs) 
				local arrow_pad = 0
				-- pad options by sub_r to fit an arrow
				-- if there are any suboptions in this option menu
				for i,v in ipairs(opts) do
					if v.suboptions then
						arrow_pad = buffer_info.arrow_r
						break
					end
				end

				local max_w = 30 -- minimum with of 30 for each option
				-- find max_w
				for i,v in ipairs(opts) do
					if v.suboptions then
						create_bgs(v.suboptions, create_bgs) -- recurse on any suboptions
					end
					if v.w > max_w then max_w = v.w end
				end
				-- create backgrounds and update w property to equal max_w
				for i,v in ipairs(opts) do
					v.w = max_w + arrow_pad
					v.bg = guirender:createContextMenuBackground(v.w,v.h)
				end
			end

			local function get_opts_total_height(opts) 
				local h = 0
				for i,v in ipairs(opts) do
					h=h+v.h
				end
				return h
			end

			local function get_opts_total_expanded_width(opts)
				local function recur(opts, recur)
					local maxw = 0
					local max_subopt_w = 0
					for i,v in ipairs(opts) do
						if v.w>maxw then maxw = v.w end
						if v.suboptions then
							local subw = recur(v.suboptions, recur)
							if subw > max_subopt_w then max_subopt_w = subw end
						end
					end
					return maxw + max_subopt_w
				end
				return recur(opts,recur)
			end

			local winw,winh = love.graphics.getDimensions()

			local options = {options()}
			if #options ~= 0 then
				for i,v in ipairs(options) do
					this.options[i] = fill_out_option(v, fill_out_option)
				end
				create_bgs(this.options, create_bgs)

				local totalh = get_opts_total_height(this.options)
				local totalw = get_opts_total_expanded_width(this.options)
				local Mx,My = this.x + totalw, this.y + totalh

				local expand_x_dir = 1
				local expand_y_dir = 1

				if Mx > winw then
					this.x = winw - this.options[1].w
					expand_x_dir = -1
				end
				if My > winh then
					this.y = winh - totalh
					expand_y_dir = -1
				end

				local function calc_xy(opts, x,y, calc_xy)
					for i,v in ipairs(opts) do
						v.x = x
						v.y = y
						if v.suboptions then
							local newx, newy
							if expand_x_dir == 1 then
								newx = x+v.w
							else
								if #v.suboptions ~= 0 then
									local child_w = v.suboptions[1].w
									newx = x-child_w
								else
									newx = 0
								end
							end
							local child_h = get_opts_total_height(v.suboptions)
							if expand_y_dir == 1 and not (v.y+child_h > winh) then
								newy = y
							else
								newy = y-child_h+v.h
							end

							calc_xy(v.suboptions, newx, newy, calc_xy) -- recurse on any suboptions
						end
						y = y + v.h
					end
				end

				calc_xy(this.options, this.x, this.y, calc_xy)
			end

			setmetatable(this, MapEditContext)
			return this
		end
	}

	return obj
end

return MapEditContext
