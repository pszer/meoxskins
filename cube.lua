local cube = {}

local function quadToTris(v1,v2,v3,v4)
	return v1,v2,v3,v1,v3,v4
end

-- uv_info is a table, takes in a table argument
--
-- pos = {x,y,z}
-- scale = {xw,yw,yz}
-- uv_info = {...}
-- origin = {x,y,z}
--
-- has 6 entries one for each face in the order
-- front, back, left, right, top, bottom
-- each entry is {xmin,ymin,xmax,ymax}

--local function cubeToTris(x,y,z, xw,yw,zw, uv_info, origin)
local function cubeToTris(args)
	local pos = args.pos or {0,0,0}
	local size = args.size
	local uv_info = args.uv_info
	local origin = args.origin or {0,0,0}

	if not size then error("cubeToTris(): no size given") end
	if not uv_info then error("cubeToTris(): no uv info given") end

	local x,y,z = pos[1],pos[2],pos[3]
	local xw,yw,zw = size[1],size[2],size[3]

	local verts = {}
--	local origin = origin or {0,0,0}

	local V = {}
	V[1] = {  x ,  y  ,  z  }
	V[2] = {x+xw, y+yw, z+zw}

	local verts_orders = {
		{{1,1,1}, {2,1,1}, {2,2,1}, {1,2,1}},
		{{2,1,2}, {1,1,2}, {1,2,2}, {2,2,2}},

		{{1,1,2}, {1,1,1}, {1,2,1}, {1,2,2}},
		{{2,1,1}, {2,1,2}, {2,2,2}, {2,2,1}},
		{{1,1,2}, {2,1,2}, {2,1,1}, {1,1,1}},
		{{2,2,2}, {1,2,2}, {1,2,1}, {2,2,1}},
	}

	local verts_normals = {
		{ 0 , 0 ,-1 },
		{ 0 , 0 , 1 },
		{-1 , 0 , 0 },
		{ 1 , 0 , 0 },
		{ 0 ,-1 , 0 },
		{ 0 , 1 , 0 },
	}

	local function get_vert(i,side)
		local v = {}
		v[1] = V[ verts_orders[side][i][1] ] [1]
		v[2] = V[ verts_orders[side][i][2] ] [2]
		v[3] = V[ verts_orders[side][i][3] ] [3]

		if side == 1 or side == 2 or side == 5 or side == 6 then
			if i==1 or i==4 then
				v[4] = uv_info[side][3]
			else
				v[4] = uv_info[side][1]
			end
		else
			if i==1 or i==4 then
				v[4] = uv_info[side][1]
			else
				v[4] = uv_info[side][3]
			end
		end

		if i==1 or i==2 then
			v[5] = uv_info[side][2]
		else
			v[5] = uv_info[side][4]
		end

		v[6] = verts_normals[side][1]
		v[7] = verts_normals[side][2]
		v[8] = verts_normals[side][3]

		return v
	end

	for i=1,6 do
		table.insert(verts, get_vert(1,i))
		table.insert(verts, get_vert(2,i))
		table.insert(verts, get_vert(3,i))
		table.insert(verts, get_vert(1,i))
		table.insert(verts, get_vert(3,i))
		table.insert(verts, get_vert(4,i))
	end

	for i,v in ipairs(verts) do
		v[1] = v[1] - origin[1]
		v[2] = v[2] - origin[2]
		v[3] = v[3] - origin[3]
	end

	return verts
end

return {
	quadToTris = quadToTris,
	cubeToTris = cubeToTris
}
