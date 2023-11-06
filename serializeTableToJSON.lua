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