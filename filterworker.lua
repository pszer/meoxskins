-- holds an instance of an actively open filter the user is using and
-- updates the preview only when new parameters are given
--
-- TODO
--
-- fix filters not working on layer other than base
--
--

local filter_worker = {
	active_worker = nil,
	commit_flag = false,
	silent_commit = false,
	preview_on = true,

	history = {}
}

function filter_worker:new(filter, layer, args, silent_commit)
	local fw = {
		filter=filter,
		layer=layer,
		params={},

		_update_preview=true,
	}
	filter_worker.silent_commit = silent_commit

	function fw:result()
		return fw.filter:apply(fw.layer.texture, fw.params)
	end

	-- returns layer, old texture, new texture
	function fw:state()
		return fw.layer, fw.layer.texture, fw:result()
	end

	function fw:discard()
		layer.discard_preview()
		self._update_preview=false
		self.filter=nil
		self.layer=nil
		self.params={}
	end

	function fw:update_args(args)
		local table_eq = nil
		table_eq = function(a,b)
			if not a and not b then return true end
			if not a then return false end
			if not b then return false end
			if type(a)~=type(b) then return false end
			for i,v in ipairs(a) do
				if type(v) == "table" then
					if not table_eq(v,b[i]) then return false end
				else
					if v~=b[i] then return false end
				end
			end
			return true
		end

		for i,v in pairs(args) do
			if type(v) == "table" then
				if not table_eq(v,self.params[i]) then
					self.params[i] = v
					self._update_preview = true
				end
			elseif self.params[i] ~= v then
				self.params[i] = v
				self._update_preview = true
			end
		end
	end

	function fw:preview()
		if not self._update_preview then return end
		fw.layer.open_preview(fw:result())
		self._update_preview = false
	end

	for i,v in pairs(args) do
		fw.params[i]=v
	end

	filter_worker.active_worker = fw
	return fw
end

function filter_worker:add_to_history(fw)
	if filter_worker.silent_commit then return end

	fw = fw or filter_worker.active_worker
	table.insert(filter_worker.history, 1, {filter=fw.filter,params=fw.params})
	if #filter_worker.history >= 20 then
		table.remove(filter_worker.history, 20)
	end
end

function filter_worker:discard()
	filter_worker.active_worker:discard()
	filter_worker:set_commit(false)
	filter_worker.active_worker = nil
	filter_worker.silent_commit = false
end
function filter_worker:set_commit(f)
	filter_worker.commit_flag = f
end
function filter_worker:is_commit()
	return filter_worker.commit_flag
end

function filter_worker:update_args(args)
	if filter_worker.active_worker then
		filter_worker.active_worker:update_args(args)
	end
end

function filter_worker:is_active()
	return filter_worker.active_worker~=nil
end

function filter_worker:preview_state(s)
	if not s then return filter_worker.active_worker~=nil and filter_worker.preview_on end
	filter_worker.preview_on = s
end

return filter_worker
