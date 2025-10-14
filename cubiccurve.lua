--
-- generates a cubic curve mapping, used in curve tool
--

require 'table'

local cubiccurve = {}

function cubiccurve.generate(X, Y, sample_count, samples_table, clamp)
	local samples = samples_table or {}

	local function get_i(x)
		return math.floor(math.min(1.0,math.max(0.0,x))*sample_count)+1 end
	local function get_sample(x)
		x = math.min(1.0,math.max(0.0,x))*(sample_count-1)+1
		return (samples[math.floor(x)]+samples[math.ceil(x)])*0.5
	end

	local points = {}
	local points_N = #X
	for i = 1,#X do points[i]={X[i],Y[i],x=X[i],y=Y[i]} end
	table.sort(points, function(a,b) return a[1]<b[1] end)

	-- create flattened ends
	local start_i, last_i = get_i(points[1][1]), get_i(points[points_N][1])
	for i=1,start_i-1 do
		samples[i] = points[1][2]
	end
	for i=last_i,sample_count do
		samples[i] = points[points_N][2]
	end

	if start_i == last_i then return samples, get_sample end

	-- use linear interpolation if not enough points
	--if #points == 2 then
	--	local step = (points[points_N][2] - points[1][2]) / (last_i-start_i)
	--	for i = start_i,last_i do
	--		local r = (i-start_i) / (last_i-start_i)
	--		samples[i] = points[1][2] + r*step
	--	end
	--	return samples, get_sample
	--end

	function catmullRomXY(points, x)
    local n = #points
    if n < 2 then return points[1].y end
    -- find segment p1–p2 such that x1 <= x <= x2
    local i = 1
    for j = 2, n do
        if x <= points[j].x then i = j-1 break end
    end
    local p0 = points[math.max(i-1, 1)]
    local p1 = points[i]
    local p2 = points[i+1]
    local p3 = points[math.min(i+2, n)]

    local m1 = (p2.y - p0.y) / (p2.x - p0.x)
    local m2 = (p3.y - p1.y) / (p3.x - p1.x)
    local t = (x - p1.x) / (p2.x - p1.x)

    local t2 = t*t
    local t3 = t2*t
    return (2*t3 - 3*t2 + 1)*p1.y
         + (t3 - 2*t2 + t)*m1*(p2.x - p1.x)
         + (-2*t3 + 3*t2)*p2.y
         + (t3 - t2)*m2*(p2.x - p1.x)
	end

	for i = start_i, last_i-1 do
		local x = i/sample_count
		samples[i] = catmullRomXY(points,x)

		if clamp then
			--samples[i] = math.min(1.0, math.max(0.0, samples[i]))
		end
	end

	return samples, get_sample
end

return cubiccurve
