--[[
-- type checked table of properties with input validation and default values
-- ]]
--

require "provtype"
require "id"
require "propvalids"

Props = {}
Props.__index = Props
Props.__type  = "proptableprototype"

--
-- IMPORTANT: the purpose of property tables is for pseudo-OOP, input validity, default values and
-- organisation. There's overhead in creating new instances and a little bit of overhead
-- in reading/writing to them; they're unsuitable for performance-critical code e.g. you wouldn't
-- use them to define vector/matrix classes. Any place where property tables are used with a very
-- short lifespan is a place to look for a better solution.
--

-- creates a prototype property table that can
-- be reused several times
-- takes in a table of arguments, with each
-- argument being a table for a row in the property table
-- {key, type, default, valid, options}
-- key       - key for the property
-- type      - lua type for the property, if nil then there is no type checking,
--             functions are not allowed as property types, if a property table instance is
--             passed a function as a value to a property then that function is called and
--             it's result used as the value
-- default   - default value for the property
-- valid     - function called when setting the value of a property to check validity
--             if nil then there is no input validity checking
-- info      - a string of information of what the property is for (optional)
--
-- possible options (all optional), multiple options can be used by combining options into one string eg "readonly+callonly"
-- readonly  - if set to true then the property is unchangable after initial construction
-- callonly  - if set to true and the property is a function, it is called with no arguments when indexed
--
-- validity checking functions work as follows
-- they take 1 argument, which is what the property is being asked to be set to
-- they should return true/false and the value that the property will be set to
-- if it returns false as first argument then an error is raised
--
--
function Props:prototype(arg)
	local p = {}

	for _,row in pairs(arg) do
		-- the property will be stored in p as
		-- p[key] = {type, default, valid}
		local property = {row[2], row[3], row[4], row[5] or row[1],
			row[6]~=nil and string.find(row[6], "readonly"),
			row[6]~=nil and string.find(row[6], "callonly"),
			}
		setmetatable(property, PropsPrototypeRowMeta)
		p[row[1]] = property
	end

	setmetatable(p, Props)

	return p
end

-- takes an existing property table and clones it, adding in new rows
-- from the given argument
function Props:extend(arg)
	local p = {}

	for key,row in pairs(self) do
		p[key] = row
	end

	for _,row in pairs(arg) do
		local property = {row[2], row[3], row[4], row[5] or row[1],
			row[6]~=nil and string.find(row[6], "readonly"),
			row[6]~=nil and string.find(row[6], "callonly"),
			}
		setmetatable(property, PropsPrototypeRowMeta)
		p[row[1]] = property
	end

	setmetatable(p, Props)

	return p
end

-- this metatable allows for accessing the info for a row
-- in a property prototype as follows
-- prototype.key.type
-- prototype.key.default
-- prototype.key.valid
PropsPrototypeRowMeta = {
	type = 1, default = 2, valid = 3, info = 4, readonly = 5, callonly = 6}
PropsPrototypeRowMeta.__index = function (row, k)
	return rawget(row, rawget(PropsPrototypeRowMeta, k))
end

__props_inst_mt = {
	__newindex = function (p, key, val)
		local proto = rawget(p, "__proto")
		local row = proto[key]
		if row == nil then
			error("property [" .. tostring(key) .. "] does not exist")
		end

		if row.readonly and enforce_read_only then
			error("property [" .. tostring(key) .. "] is read only")
		end

		local validvalue = val
		if row.valid then
			local good
			good, validvalue = row.valid(val)
			if not good then
				error("value " .. tostring(val) .. " is invalid for property [" .. tostring(key) .. "]")
			end
		end

		local vvaltype = provtype(validvalue)
		if row.type ~= nil and row.type ~= vvaltype then
			error("property [" .. tostring(key) .. "] is a " .. row.type .. ", tried to assign a " .. provtype(val)
			       .. " (" .. tostring(val) .. ")")
		end

		--if row.type == "link" and vvaltype ~= "link" then
		--	(rawget(p, key)[2]) (validvalue)
		--end

		rawset(p, key, validvalue)
	end,

	__index = function (p, key)
		local v = rawget(p, key)
		local proto = rawget(p, "__proto")
		if v ~= nil then
			--if provtype(v) == "function" and p.__proto[key].callonly then
			--if type(v) == "function" and p.__proto[key].callonly then
			--	return v()
			--elseif provtype(v) == "link" then
			--	return v[1]()
			--else
			--	return v
			--end
			return v
		else
			local prot = proto[key]
			if prot then
				return prot.default
			else
				error("key " .. tostring(key) .. "doesn't exist")
				return nil
			end
		end
	end,

	__call = function (props, t)
		for k,v in pairs(t) do
			props[k]=v
		end
	end,

	__pairs = function (p)
		return pairs(p)
	end,

	__tostring = function (p)
		local result = ""
		for k,v in pairs(p) do
			result = result .. tostring(k) .. " = " .. tostring(v) .. "\n"
		end
		return result
	end
}

-- once a prototype is created, it can be called like a function
-- to give an instance of a prototype table
-- initial values of properties can be given through the optional init argument
-- i.e init = {"prop1" = 0, "prop2" = 1} will assign 0 and 1 to properties prop0 and prop1
--
-- all instances of a property table have ["__proto"] that points to their prototype
-- if that information is required
--
-- an instance of a property table can be read and written to like a regular table but
-- it has the type checking and validity checking of the prototype table in place
Props.__call = function (proto, init)
	local props = { }
	local enforce_read_only = false -- we ignore readonly when creating a property table

	props.__proto = proto
	props.__type = "proptable"

	--[[function props.rawget(key)
		return rawget(p, key)
	end

	function props.rawset(key, value)
		return rawset(p, key, value)
	end--]]

	setmetatable(props, __props_inst_mt)

	for key,row in pairs(proto) do
		--local function clone(t, recur)
		--	local result = {}
		--	for i,v in pairs(t) do
		--		local element = v
		--		if type(v) == "table" then
		--			element = recur(v, recur)
		--		end
		--		result[i] = element
		--	end
		--	return result
		--end
		--local function clone(t)
		--	local result = {}
		--	for i,v in pairs(t) do
		--		result[i] = v
		--	end
		--	return result
		--end
		local init_value = (init and init[key])
		if not init_value and proto[key].type == "table" and proto[key].valid then
			local a,b = proto[key].valid(nil)
			init_value = b
		elseif init_value and type(init_value) == "function" and proto[key].type == "table" then
			init_value = init_value()
		end
		props[key] = init_value or proto[key].default
	end

	--enforce_read_only = true
	return props
end
