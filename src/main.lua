---@class g_savedata
---@field blocks Block[]
---@field settings GSettings
---@field trains Train[]

---@class GSettings
---@field CTCWhitelisting boolean,
---@field PTC boolean
---@field allowChatCTC boolean
---@field allowPlayerCTC boolean
---@field enableBridgeSignalling boolean
---@field longBlocksArid boolean
---@field longBlocksBridges boolean
---@field longBlocksDonkk boolean
---@field longBlocksSawyer boolean
---@field showSignalStatusOnMap boolean

function onTick(tickrate)
    -- MAINTAIN ORDER OF EXECUTION!
    Train.tickAll()
    DetectionZone.tickAll()
    Block.tickAll()
end

