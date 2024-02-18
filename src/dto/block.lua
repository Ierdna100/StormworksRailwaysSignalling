---@class Tickable
---@field tick function

---@class Block : Tickable
---@field id integer
---@field occupiedBy Train[]
---@field findBlockWithId function
---@field getTrainId function

Block = {}

function Block.tickAll()
    for i, block in ipairs(g_savedata.blocks) do
        block:tick()
    end
end

---@param searchId integer
---@return Block?
function Block.findBlockWithId(searchId)
    for i, block in ipairs(g_savedata.blocks) do
        if block.id == searchId then
            return block
        end
    end
    return nil
end

---@return Block
function Block:new(id)
    return {
        id = id,
        occupiedBy = {},
        tick = Block.tick,
        getTrainId = Block.getTrainId
    }
end

---@param self Block
function Block:tick()

end

---@param self Block
function Block:getTrainId(searchId)
    for idx, train in ipairs(self.occupiedBy) do
        if train.vehicleId == searchId then
            return idx
        end
    end
end