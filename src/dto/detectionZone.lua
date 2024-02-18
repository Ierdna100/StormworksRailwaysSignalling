---@class DetectionZone
---@field tf Transform
---@field size Vector3
---@field updateData DetectionZoneUpdateData[]
---@field occupiedBy Train[]
---@field previouslyOccupiedBy Train[]
---@field tick function

---@class DetectionZoneUpdateData
---@field block Block
---@field reversed boolean

DetectionZone = {}

---@type DetectionZone[]
DetectionZone.detectionZones = {}

---@param tf Transform
---@param size Vector3
---@return DetectionZone
function DetectionZone:new(tf, size)
    return {
        tf = tf,
        size = size,
        updateData = {},
        blocksToUpdate = {},
        occupiedBy = {},
        previouslyOccupiedBy = {},
        tick = DetectionZone.tick
    }
end

function DetectionZone.tickAll()
    for _, zone in ipairs(DetectionZone.detectionZones) do
        zone:tick()
    end
end

---@param self DetectionZone
function DetectionZone:tick()
    ---@type Train[]
    trainsLeaving = {}
    for _, train in ipairs(self.previouslyOccupiedBy) do
        trainLeft = true
        for _, train2 in ipairs(self.occupiedBy) do
            if train2.vehicleId == train.vehicleId then
                trainLeft = false
                break
            end
        end

        if trainLeft then
            table.insert(trainsLeaving, train)
        end
    end

    for _, train in ipairs(trainsLeaving) do
        trainVelocityAngle = train.surfaceVelocity
        zoneAngle = mathc.angleToVec2(mathc.eulerFromTransform(self.tf).x)

        dotP = mathc.dotProduct2D(trainVelocityAngle, zoneAngle)

        for _, detectionZone in ipairs(self.updateData) do
            if dotP > 0 and not detectionZone.reversed then
                table.insert(detectionZone.block.occupiedBy, train)
                log("Train entered block ".. detectionZone.block.id)
            elseif dotP > 0 and detectionZone.reversed then
                idx = detectionZone.block:getTrainId(train.vehicleId)
                log("Train exited block ".. detectionZone.block.id)
                table.remove(detectionZone.block.occupiedBy, idx)
            elseif dotP < 0 and not detectionZone.reversed then
                idx = detectionZone.block:getTrainId(train.vehicleId)
                table.remove(detectionZone.block.occupiedBy, idx)
                log("Train exited block ".. detectionZone.block.id)
            elseif dotP < 0 and detectionZone.reversed then
                table.insert(detectionZone.block.occupiedBy, train)
                log("Train entered block ".. detectionZone.block.id)
            end
        end
    end

    self.previouslyOccupiedBy = self.occupiedBy
    self.occupiedBy = {}
end