function initializeBlocks()
    zones = server.getZones()

    for _, zone in ipairs(zones) do
        tags = parseTags(zone.tags)

        isSRSZone = findTagWithKey(tags, "SRS")

        if isSRSZone == nil then
            goto continue
        end

        ---@type DetectionZone
        detectionZone = DetectionZone:new(zone.transform, zone.size)

        for i, tag in ipairs(tags) do
            if tag.key == "ENTRY" or tag.key == "EXIT" then
                block, isSuccess = checkExistAndCreateBlock(tag.value)
                if not isSuccess then
                    warn("Zone has invalid entrypoint!")
                    goto continue
                end

                ---@type DetectionZoneUpdateData
                data = {
                    block = block,
                    reversed = tag.key == "EXIT"
                }
                table.insert(detectionZone.updateData, data)
            end
            ::continue::
        end

        table.insert(DetectionZone.detectionZones, detectionZone)
        ::continue::
    end
end

---@param id string
---@return Block block
---@return boolean isSuccess
function checkExistAndCreateBlock(id)
    blockId = tonumber(id)
    if blockId == nil then
        ---@diagnostic disable-next-line: return-type-mismatch
        return nil, false
    end

    existingBlock = Block.findBlockWithId(math.floor(blockId))

    if existingBlock == nil then
        newBlock = Block:new(blockId)
        table.insert(g_savedata.blocks, newBlock)
        return newBlock, true
    else
        return existingBlock, true
    end
end