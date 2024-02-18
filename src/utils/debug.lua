-- Prints log_msg to console
function log(msg)
	server.announce("[SRS DEBUG] [" .. msToTime(server.getTimeMillisec()) .. "]", msg)
end

-- Prints log_msg to console
function warn(msg)
	server.announce("[SRS WARN] [" .. msToTime(server.getTimeMillisec()) .. "]", msg)
end

-- Prints log_msg to console
function error(msg)
	server.announce("[SRS ERROR] [" .. msToTime(server.getTimeMillisec()) .. "]", msg)
end

-- Prints log_msg to console
function cPrint(header, msg)
	server.announce(header, msg)
end

-- Converts milliseconds to HH:MM:SS.Millisec
function msToTime(milliseconds)
	hours = math.floor(milliseconds / (60 * 60 * 1000))
	minutes = math.floor(milliseconds / (60 * 1000)) % 60
	seconds = math.floor(milliseconds / 1000) % 60
	milliseconds = milliseconds % 1000

	return string.format("%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds)
end

--- sends an HTTP debug log on port 666
--- @param data string input string
function dHTTP(data)
	query = "/?d=" .. data

	server.httpGet(666, query)
end

--- Parse table `t`
--- @param t table table to parse
--- @return string
function serializeTableToJSON(t)
	local JSON = '{'

	local blockData, isList = __serializeTableToJSON(t)
	if isList then
		JSON = JSON .. '"table":'.. '[' .. blockData .. ']'
	else
		JSON = JSON .. '"table":' .. '{' .. blockData .. '}'
	end

	return JSON .. '}'
end

-- NEVER CALL THIS, call the one above
function __serializeTableToJSON(t)
	local JSON = ""
	local lastk

	for k, v in pairs(t) do
		lastk = k
		local kname = ""

		if type(k) ~= "number" then
			kname = '"' .. tostring(k) .. '":'
		end

		vtype = type(v)

		if vtype == 'nil' then
			JSON = JSON .. kname .. 'null,'
		elseif vtype == 'number' then
			JSON = JSON .. kname .. v .. ","
		elseif vtype == "string" then
			JSON = JSON .. kname .. '"' .. v .. '"' .. ","
		elseif vtype == "boolean" then
			JSON = JSON .. kname .. (v and 'true' or 'false') .. ","
		elseif vtype == "function" then
			JSON = JSON .. kname .. '"func",'
		elseif vtype == "table" then
			local blockData, isList = __serializeTableToJSON(v)
			if isList then
				JSON = JSON .. kname .. '[' .. blockData .. ']' .. ","
			else
				JSON = JSON .. kname .. '{' .. blockData .. '}' .. ","
			end
		end
	end

	JSON = string.sub(JSON, 1, -2)

	return JSON, type(lastk) == "number"
end
