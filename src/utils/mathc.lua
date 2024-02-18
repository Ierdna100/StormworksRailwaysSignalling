---@class Vector3
---@field x number
---@field y number
---@field z number

---@class Vector2
---@field x number
---@field y number

mathc = {}

--[[ transform matrices in SW is formatted as such (indices shown):
	1  5  9  13
	2  6  10 14
	3  7  11 15
	4  8  12 16

	reference link: https://gamedev.stackexchange.com/a/50968
]]
---@param matrix Transform
---@return Vector3
function mathc.eulerFromTransform(matrix)
	if matrix[1] == 1 or matrix[1] == -1 then
		return { x = math.atan(matrix[9], matrix[15]), y = 0, z = 0 }
	else
		return { x = math.atan(-matrix[3], matrix[1]), y = math.asin(matrix[2]), z = math.atan(-matrix[10], matrix[6]) }
	end
end

-- Simple angle (radians) to vector2
---@param angle number
---@return Vector2
function mathc.angleToVec2(angle)
	return { x = math.cos(angle), y = math.sin(angle) }
end

---Simple dotP
---@param vec1 Vector2
---@param vec2 Vector2
---@return number
function mathc.dotProduct2D(vec1, vec2)
	return vec1.x * vec2.x + vec1.y * vec2.y
end

---@param vec1 Vector3
---@param vec2 Vector3
---@return Vector3
function mathc.vec3Subtract(vec1, vec2)
	return { x = vec1.x - vec2.x, y = vec1.y - vec2.y, z = vec1.z - vec2.z }
end