---@class Train
---@field tick function
---@field vehicleId integer
---@field oldTf Transform
---@field tf Transform
---@field surfaceVelocity Vector2

Train = {}

---@type integer[] 
Train.possibleTrainIds = {}

---@return Train
function Train:new(vehicleId)
    return {
        vehicleId = vehicleId,
        tick = Train.tick,
        tf = server.getVehicleData(vehicleId).transform,
        oldTf = server.getVehicleData(vehicleId).transform,
        surfaceVelocity = { x = 0, y = 0 }
    }
end

function Train.tickAll()
    for i, train in ipairs(g_savedata.trains) do
        train:tick()
    end
end

---@param id integer
---@return boolean trainExists
---@return integer tableIndex
function Train.exists(id)
    for i, train in ipairs(g_savedata.trains) do
        if train.vehicleId == id then
            return true, i
        end
    end
    return false, 0
end

---@param self Train
function Train:tick()
    self.tf = server.getVehicleData(self.vehicleId).transform

    for i, zone in ipairs(DetectionZone.detectionZones) do
        if server.isInTransformArea(self.tf, zone.tf, zone.size.x, zone.size.y, zone.size.z) then
            table.insert(zone.occupiedBy, self)
        end
    end

    oldVec3 = {}
    oldVec3.x, oldVec3.y, oldVec3.z = matrix.position(self.oldTf)
    currVec3 = {}
    currVec3.x, currVec3.y, currVec3.z = matrix.position(self.tf)
    velocity = mathc.vec3Subtract(oldVec3, currVec3)
    self.surfaceVelocity = { x = velocity.x, y = velocity.z }

    self.oldTf = self.tf
end
