--
-- generates a histogram for a given canvas
--

local histogram = {
	channel_func = {
		["value"] = function(r,g,b,a) return math.max(r,g,b) end,
		["red"] = function(r,g,b,a) return r end,
		["green"] = function(r,g,b,a) return g end,
		["blue"] = function(r,g,b,a) return b end,
		["alpha"] = function(r,g,b,a) return a end,
	}
}

--
-- channel = value, red, green, blue
--
-- returns sorted list {{channel value, x,y} , ...}, percentile(percent), interval(value, range)
--
function histogram.retrieve(image, channel)
	channel = channel or "value"
	channel = histogram.channel_func[channel]

	local image_data = image
	if type(image_data)~="ImageData" then
		image_data = image_data:newImageData()
	end

	local w,h = image_data:getDimensions()
	local sorted = {}
	local sorted_N = 0

	local function sort_in(P,...)
    local lo, hi = 1, sorted_N
    while lo <= hi do
        local mid = math.floor((lo + hi) / 2)
        if P < sorted[mid][1] then
            hi = mid - 1
        else
            lo = mid + 1
        end
    end
    table.insert(sorted, lo, {P,...})
		sorted_N = sorted_N + 1
	end

	for i = 0, w*h - 1 do
		local x,y = i % w, math.floor(i/w)
		local R,G,B,A = image_data:getPixel(x,y)

		if A > 0.0 then -- ignore blank pixels
			local P = channel(image_data:getPixel(R,G,B,A))
			sort_in(P, x,y)
		end
	end

	local function percentile(percent)
		percent = math.max(0.0,math.min(percent,100.0))
		if sorted_N == 0 then return percent/100.0 end -- 0.0 for 0% and 1.0 for 100%
		local i = math.ceil(sorted_N * percent/100.0)
		return sorted[i][1], i
	end

	local function interval(value, range, start_i)
		if sorted_N == 0 then return 0 end

		local i = start_i or 1
		local count = 0
		while i <= sorted_N do
			if sorted[i][1] >= value+range then break end
			if sorted[i][1] >= value then count=count+1 end
			i=i+1
		end

		return count,i
	end

	return sorted, percentile, interval
end

return histogram
