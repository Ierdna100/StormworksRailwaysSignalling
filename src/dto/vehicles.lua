---Called when a vehicle is spawned. Vehicles must still loading in locally to start simulating.
---@param vehicleId integer ID of group that spawned.
---@param peerId integer ID of peer that spawned vehicle. If spawned by script, will be `-1`.
---@param x number Spawn X
---@param y number Spawn Y
---@param z number Spawn Z
---@param groupCost number Cost of group that spawned. Only calculated for player-spawned groups.
---@param groupId integer ID of group that spawned.
function onVehicleSpawn(vehicleId, peerId, x, y, z, groupCost, groupId)
    if peerId == -1 then
        return
    end

    if not Train.exists(vehicleId) then
        table.insert(Train.possibleTrainIds, vehicleId)
    end
end

---@param vehicleId integer
function onVehicleLoad(vehicleId)
    vehicleLoaded = false
    for i, id in ipairs(Train.possibleTrainIds) do
        if id == vehicleId then
            vehicleLoaded = true
            table.remove(Train.possibleTrainIds, i)
            break
        end
    end

    if not vehicleLoaded then
        return
    end

    vehicleData, isSuccess = server.getVehicleSign(vehicleId, "SRS")

    if not isSuccess then
        return
    end

    log("Train spawned with SRS compatibility")
    table.insert(g_savedata.trains, Train:new(vehicleId))
end

---@param vehicleId integer
function onVehicleUnload(vehicleId)

end

---@param vehicleId integer
function onVehicleDespawn(vehicleId, peerId)
    if peerId == -1 then
        return
    end

    trainExists, idx = Train.exists(vehicleId)
    if trainExists then
        table.remove(g_savedata.trains, idx)
        log("Train with SRS support despawned!")
    end
end
