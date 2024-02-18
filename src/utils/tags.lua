---@class Tag
---@field key string
---@field value string

--- @param rawTags table
--- @return Tag[] table
function parseTags(rawTags)
	parsedTags = {}

	for i, v in ipairs(rawTags) do
		local indexOfColon
		v = tostring(v)

		for i2 = 1, #v, 1 do
			if string.sub(v, i2, i2) == ":" then
				indexOfColon = i2
				break
			end
		end

		if indexOfColon ~= nil then
			table.insert(parsedTags, { key = string.sub(v, 1, indexOfColon - 1), value = string.sub(v, indexOfColon + 1, -1) })
		else
			table.insert(parsedTags, { value = v })
		end
	end

	return parsedTags
end

---Returns a tag with selected key
---@param tags Tag[]
---@param key string
---@return Tag | nil
function findTagWithKey(tags, key)
    for i, tag in ipairs(tags) do
        if tag.key == key then
            return tag
        end
    end

    return nil
end

---Returns a tag with selected key
---@param tags Tag[]
---@param key string
---@return Tag[]
function findTagsWithKey(tags, key)
    outputTags = {}

    for i, tag in ipairs(tags) do
        if tag.key == key then
            table.insert(outputTags, tag)
        end
    end

    return outputTags
end
