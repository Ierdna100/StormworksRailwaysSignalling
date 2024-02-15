--[[
HOW TO TEST:
1. Save code in IDE
2. Run '?reload_scripts' in Stormworks
3. Load signals in with the addon editor's area editor. WARNING: ALWAYS LOAD THE ADDON WHEN OPENING THE MENU OR YOU RISK SAVING OLD CODE OVER IN THIS FILE
4. Run '?init' WARNING: RUNNING INIT TWICE CRASHES THE GAME. UNTIL WE CAN SOLVE THAT, DONT DO THAT
5. (Re)spawn in any vehicle you are using to test the addon with

Current TODO (from ierdna on 6th sept. 2023)
- Last and first signals do not get assigned properly when exiting/entering their block
- Switches, make them work maybe
- UI
- commands
- settings
- place zones
- make signal vehicles and switches vehicles
- make small script in onTick() that refills the batteries of the signals so they dont run out

]]

-- DO NOT USE g_savedata FOR TESTING. IT WILL DESTROY YOUR MEMORY AND WHATEVER RELIES ON IT IN THE CODE. IMPLEMENT LAST.
g_savedata = {}

--[[ Stores all blocks in level
blocks = {
	{
		blockID = 12,
		detectionZones = {
			{
				zoneID = 1,
				zoneTf = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16},
				zoneSize = {x = 1, y = 2, z = 3},
				zoneReversed = true
			},
			{
				zoneID = 2,
				zoneTf = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16},
				zoneSize = {x = 1, y = 2, z = 3},
				zoneReversed = false
			}
		},
		listeningSignals = {
			{
				blockID = 12,
				vehicleID = 144
			}
		},
		aspect = 2,
		nextBlockID = 13,
		occupied = false
	}
}
]]
blocks = {}

--[[ Stores all signals in level, I dunno if this needs to stay up after initialization 
signals = {
	{
		blockID = 12,
		vehicleID = 144
	},
	{
		blockID = 13,
		vehicleID = 145
	}
}
]]
signals = {}

--[[ Stores all active trains (vehicles containing "SRS" in the name) in the level to see if they enter or exit a zone
trains = {
	{ID = 1}, -- Actual vehicle_ID to be able to refer to it
	{ID = 2}
}
]]
trains = {}

--[[ Zones currently occupied, will be checked against a newly made table every tick and the difference means the zone was exited (therefore we must update the linked block)
occupiedZones = {
	{
		blockID = 12,
		zoneData = {
			zoneID = 1,
			zoneTf = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16},
			zoneSize = {x = 1, y = 2, z = 3},
			zoneReversed = true
		},
		trainID = 2
	}
}
]]
occupiedZones = {}

--[[ Blocks currently occupied
-- Not currently in use
]]
occupiedBlocks = {}

-- Stupid aspects, change later for something more sensical. Also individually for every type of signal 
aspects = {
	offline = 1,
	stop = 2,
	stopThenProceedOnSight = 3,
	stopAtNext = 4,
	stopAtNextProceedWithSpeedRestriction = 5,
	stopIn2 = 6,
	stopIn2ProceedWithSpeedRestriction = 7,
	proceed = 8,
	proceedWithSpeedRestriction = 9
}

-- use like this: aspectToAspect[currentaspect], it allows us to convert from a current aspect to the next aspect on the next signal (e.g. our signal shows Stop so the next should be StopAtNext) 
aspectToAspect = {
	aspects.stopAtNext, --0
	aspects.stopAtNext, --1
	aspects.stopAtNext, --2
	aspects.stopIn2, --3
	aspects.stopIn2, --4
	aspects.proceed, --5
	aspects.proceed, --6
	aspects.proceed, --7
	aspects.proceed --8
}

-- Level of freedom of movement of aspects (KEEP IN THE SAME ORDER AS THE aspects TABLE!). A freedom level of 0 means the train must stop, anything above means more and more "freedom" of movement 
freedomLevel = {
	0, --offline
	0, --stop
	1, --stopThenProceedOnSight
	2, --stopAtNext
	2, --stopAtNextWithSpeedRestriction
	3, --stopIn2
	3, --stopIn2ProceedWithSpeedRestriction
	4, --proceed
	4  --proceedWithSpeedRestriction
}

-- UI stuff for debugging and clearing UI elements
ui = {}

function onTick()
	--check zones to see if occupied
	currentlyOccupiedZones = {}

	-- First checks every train, and if it is found then we check if it is in any zones. If it is, then we add that zone to the list of currentlyOccupiedZones
	for i, train in ipairs(trains) do
		trainFound = false
		trainPos = server.getVehiclePos(train.ID)

		for i2, block in ipairs(blocks) do
			for i3, zone in ipairs(block.detectionZones) do
				zoneOccupied = server.isInTransformArea(trainPos, zone.zoneTf, zone.zoneSize.x, zone.zoneSize.y, zone.zoneSize.z)

				if zoneOccupied then
					table.insert(currentlyOccupiedZones, {
						blockID = block.blockID,
						zoneData = zone,
						trainID = train.ID
					})
				end
			end
		end
	end

	--find differences in occupiedZones then store the results in exitedZones
	exitedZones = {}

	for i, occupiedZone in ipairs(occupiedZones) do
		foundMatchingZone = false

		for i2, currentlyOccupiedZone in ipairs(currentlyOccupiedZones) do
			if occupiedZone.blockID == currentlyOccupiedZone.blockID and occupiedZone.zoneData.zoneID == currentlyOccupiedZone.zoneData.zoneID then
				foundMatchingZone = true
				break
			end
 		end

		if not foundMatchingZone then
			table.insert(exitedZones, occupiedZone)
		end
	end

	-- Check every exited zone to determine what direction the train has left it.
	for i, zone in ipairs(exitedZones) do
		--some fucky stuff happens here, for some reason zonePos and resultant are 90 degrees off
		zonePos = { x, y, z }
		zonePos.x, zonePos.y, zonePos.z = matrix.position(zone.zoneData.zoneTf)

		trainPos = { x, y, z }
		vPos = server.getVehiclePos(zone.trainID)
		trainPos.x, trainPos.y, trainPos.z = matrix.position(vPos)

		-- ZonePos - TrainPos leaves us with the trainPos as if the block was the origin (0, 0, 0), then we store it in 2D because we dont care about altitude
		resultant = Vec3Subtract(zonePos, trainPos)
		resultant = { x = resultant.x, y = resultant.z }

		-- Get the rotation of the zone, its wrong by 90 degrees, maybe I fucked up the math. Check the function for the link I referred to when writing the math.
		zoneRotation = EulerFromTransform(zone.zoneData.zoneTf)
		zoneRotation = AngleToVec2(zoneRotation.x + math.rad(90)) --why is it off by 90 deg

		-- DotP of the resultant and zoneRotation, this tells us if the train has exited TOWARDS the zone or AWAY from the zone's rotation vector.
		dotP = DotProduct2D(resultant, zoneRotation)

		-- Block that we are updating
		blockChangingState = getBlockByID(zone.blockID)

		if dotP > 0 then
			if zone.zoneData.zoneReversed then
				updateSignalsOnBlock(blockChangingState, aspects.proceed)
			else
				updateSignalsOnBlock(blockChangingState, aspects.stop)
			end
		else
			if zone.zoneData.zoneReversed then
				updateSignalsOnBlock(blockChangingState, aspects.stop)
			else
				updateSignalsOnBlock(blockChangingState, aspects.proceed)
			end
		end
	end

	-- Set for next tick calculations
	occupiedZones = currentlyOccupiedZones
end

-- ONLY USE FOR DEBUGGING, UNLESS YOU IMPLEMENT UI PROPERLY
function drawPoint(x, y, name)
	ui_id = server.getMapID()

	table.insert(ui, ui_id)

	server.addMapLabel(-1, ui_id, 1, name, x, y)
end

function onCreate(firstLoad)
	--server.httpGet(666, "/restart") for ierdna's pesonal http debugger, sends on http://localhost:666/restart

	if firstLoad then
		newSettings = {}

		--[[ Types of signals
			-1. Disabled
			0. Modern british (feather + 4 lights)
			1. 1850s british semaphores (Main, entry, approch, etc.)
			2. Yugoslavia semaphores
			3. France semaphores
			4. Modern french
			5. Modern Canadian (North American)
			6. Norwegian Modern
			7. Italian Modern
			8. Japanese Modern
			9. Russian Modern
		]]
		newSettings.signalTypeDonkk = property.slider("Donkk Islands signal type", -1, 9, 1, 0)
		newSettings.signalTypeSawyer = property.slider("Sawyer Islands signal type", -1, 9, 1, 0)
		newSettings.signalTypeArid = property.slider("Arid Islands signal type", -1, 9, 1, 0)

		--[[
			Short blocks: every signal is spawned, block distance depends on island size
			Longer blocks: Only half of all signals are spawned (for modern signals, only half the signal boxes are spawned in semaphore signals)
		]]
		newSettings.blockLengthDonkk = property.checkbox("Longer blocks on Donkk Islands", false)
		newSettings.blockLengthSawyer = property.checkbox("Longer blocks on Sawyer Islands", false)
		newSettings.blockLengthArid = property.checkbox("Longer blocks on Arid Islands", false)
		newSettings.blockLengthBridges = property.checkbox("Longer blocks on bridges connecting islands", true)

		-- If bridges are signalled at all
		newSettings.enableBridgeSignalling = property.checkbox("Enable bridge signalling (may take a few minutes to spawn in all signals)", true)

		-- If CTC should be allowed by players
		newSettings.allowPlayerCTC = property.checkbox("Allow player CTC", true)
		-- If CTC is allowed by chat, only toggleable when PlayerCTC is on, otherwise true
		newSettings.allowChatCTC = property.checkbox("Allow CTC from chat (If allow player CTC is off this will be forced on)", true)
		-- If joining CTC requires being on a whitelist
		newSettings.CTCWhitelisting = property.checkbox("Enable CTC whitelist", false)
		-- If debugging message are enabled
		newSettings.enableDebugging = property.checkbox("Enable debugging", false)
		-- If signals are shown on the map with their speed limits and such
		newSettings.showSignalStatusOnMap = property.checkbox("Show signal aspects on map", true)
		-- If PTC is active upon loading the addon. PTC == All signals red unless otherwise, NTC = all signals green unless block is occupied.
		newSettings.PTC = property.checkbox("PTC by default", true)

		g_savedata = {
			settings = newSettings
		}
	end
end

--[[
	Commands to implement later:

	?help 
	?docs - Sends link or instructions on how to acquire documentation on the map
	?switch [ID] [Right/left] - Sets switch direction to left/right
	?switch [ID] [Main/siding] - Sets switch direction to main/siding
	?switch [ID] - Toggles switch direction
	?signal [ID] - Opens PTC signal until train passes
	?route [Beginning signal ID] [End signal ID] - Creates route for train from a signal to a signal
	?ctcwhitelist add [peer_id] - Adds peer ID to CTC whitelist
	?ctcwhitelist remove [peer_id] - Removes peer ID to CTC whitelist
	?ctcwhitelist clear [peer_id] - Removes all peer IDs from CTC whitelist
	?settings [setting*] [state] - Changes setting
	?clear_block [ID] - Clears block in case something gets stuck
	?ctc - join/leave CTC
]]
function onCustomCommand(full, peer_id, admin, authed, command, ...)
	args = { ... }

	-- DEBUG INITIALIZER
	if command == "?init" then
		initAddon()

	-- EVERYTHING BELOW IS JUNK I USE TO TEST, FEEL FREE TO DELETE IT AND ADD YOUR OWN SHIT
	elseif command == "?pos" then
		pos = server.getVehiclePos(trains[#trains].ID)
		x, y, z = EulerFromTransform(pos)
		x2, z2 = AngleToVec2(x)
		--dotP = DotProduct2D(x2, z2, 0, 1) --tests against (0, 1), the spawn vector of Northern Terminal
		--Log("EULER", dotP)
	elseif command == "?p" then
		dHTTP(serializeTableToJSON(blocks))
	elseif command == "?clear" then
		for i, v in ipairs(ui) do
			server.removeMapID(-1, v)
		end
		ui = {}
	elseif command == "?rs" then
		server.httpGet(666, "/restart")
	elseif command == "?http" then

	end
end

function onSpawnAddonComponent(id, name, type, addon_index)
	Log("Addon indices", addon_index .. " " .. server.getAddonIndex())
	-- THE LINE BELOW IS COMMENTED BECAUSE WE CANNOT COMPARE ADDON_INDEX UNTIL IT IS PUBLISHED ON THE WORKSHOP FOR SOME INHUMANE REASON, LEAVE IT AT TRUE
	--if addon_index == server.getAddonIndex() then
	if true then 
		-- If we are a vehicle and contain the tag "SRS:SIGNAL" then we are a signal. Add to signals table
		if type == "vehicle" then

			vData = server.getVehicleData(id)
			tags = parseTags(vData.tags)

			if tags[1].key == "SRS" and tags[1].value == "SIGNAL" then
				Log("Signal spawned, VID:", id)
				table.insert(signals, {
					blockID = findTagWithName(tags, "BLOCK_ID"),
					vehicleID = id
				})
			end
		end
	end
end


function onVehicleSpawn(id, peer_id, x, y, z, cost)
	-- If we are vehicle not from Addon and we contain the substring "SRS" in our name, we are train, so track us to see what blocks we may be in.
	vName = server.getVehicleName(id)
	Log("VEHICLE SPAWNED", vName)
	found = string.find(vName, "SRS")

	if found ~= nil then --if "SRS" is at any point in the vehicle name
		table.insert(trains, {
			ID = id
		})
	end
end

--[[ Tags are comma-separated, e.g: "ZONE,1,2" will create an object:
	tags = {
		"ZONE",
		"1",
		"2"
	}
]]
function initAddon()
	-- Initialize all zones (also creates blocks)
	ZONE_LIST = server.getZones()

	if ZONE_LIST == nil then
		Debug("No zones found! Could not initialize SRS addon.")
		return
	end

	-- Only parse if we have tag "SRS:ZONE"
	for i, v in ipairs(ZONE_LIST) do
		tags = parseTags(v.tags)
		if tags[1].key == "SRS" and tags[1].value == "ZONE" then
			IsZone(v)
		end
	end

	-- Assign block.prevBlockID
	for i, block in ipairs(blocks) do
		if block.nextBlockID ~= nil then
			changingBlock = getBlockByID(block.nextBlockID)

			if changingBlock == nil then
				Debug("Couldn't find block with ID " .. block.nextBlockID)
			else
				changingBlock.prevBlockID = block.blockID
			end
		end
	end

	-- Initialize all signals
	for block_idx, block in ipairs(blocks) do
		for signal_idx, signal in ipairs(signals) do
			if block.blockID == signal.blockID then
				table.insert(block.listeningSignals, signal)
				break
			end
		end

		updateSignalsOnBlock(block, aspects.proceed)
	end

	--dHTTP(serializeTableToJSON(blocks))
end

-- Initializes a zone
function IsZone(zone)
	local tags = parseTags(zone.tags)
	-- Parse each tag
	for i, v2 in ipairs(tags) do
		alreadyExists = false
		reversed = false

		-- If the tag has a key of EXIT or ENTRY, then it defines how the zone interacts with a block
		if v2.key == "EXIT" or v2.key == "ENTRY" then
			if v2.key == "EXIT" then
				-- Reversed means the dotP will be backwards, as the rotation vector faces away (when reversing through a block for instance)
				reversed = true
			end

			-- If the block already exists, then only add the zone to the existing block
			for i2, block in ipairs(blocks) do
				if (block.blockID == v2.value) then
					table.insert(block.detectionZones,
					{
						zoneID = #block.detectionZones + 1,
						zoneTf = zone.transform,
						zoneSize = zone.size,
						zoneReversed = reversed
					})

					if block.nextBlockID == nil and (not reversed) then
						block.nextBlockID = findTagWithName(tags, "NEXT_BLOCK_ID")
					end

					alreadyExists = true
					break
				end
			end

			-- If it does not exist, add one and create a block
			if not alreadyExists then
			table.insert(blocks, {
				blockID = v2.value,
				detectionZones = {
					{
						zoneID = 1,
						zoneTf = zone.transform,
						zoneSize = zone.size,
						zoneReversed = reversed
					}
				},
				listeningSignals = {},
				aspect = aspects.offline,
				nextBlockID = findTagWithName(tags, "NEXT_BLOCK_ID"),
				occupied = false
			})
			end
		end
	end
end

--- Parses mission object tags into an object
--[[ Example:
"SRS:ZONE,ENTRY:1,EXIT:2" will be turned into:
table = {
	{key = "SRS", value = "ZONE"},
	{key = "ENTRY", value = 1},
	{key = "EXIT", value = 2}
}
]]
--- @param tags table
--- @return table
function parseTags(tags)
	parsedTags = {}

	for i, v in ipairs(tags) do
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
			table.insert(parsedTags, { value = v})
		end
	end

	return parsedTags
end

--- Returns a value from a key from custom tags format OR nil if it hasn't found a tag with that key
--- @param tags table custom tags table
--- @param name string search name
function findTagWithName(tags, name)
	for i, v in ipairs(tags) do
		if tags[i].key == name then
			return tags[i].value
		end
	end

	return nil
end

--[[ Updates all the signals on the block specified.
]]
function updateSignalsOnBlock(block, aspect)
	-- If state doesnt change, dont change anything
	if aspect == block.aspect then
		--Debug("EXITING AT STATUS 1")
		return
	end

	--If nextBlockID is null, then we are the last signal. Aspect should be most restrictive.
	if block.nextBlockID == nil then
		--Debug("EXITING AT STATUS 2")
		return
	else
	-- If state is already more restrictive than next signal, dont change
		blockToCompareTo = getBlockByID(block.nextBlockID)
		if aspectIsMoreRestrictive(aspect, blockToCompareTo.aspect) then
			--Debug("EXITING AT STATUS 3")
			return
		end
	end

	-- Set aspect
	block.aspect = aspect

	-- Set signals
	for i, signal in ipairs(block.listeningSignals) do
		Log("KEYPAD:", block.aspect)
		server.setVehicleKeypad(signal.vehicleID, "Aspect", block.aspect)
	end

	-- Update all previous signals until they arrive at the least restrictive signal
	if block.prevBlockID ~= nil then
		updateSignalsOnBlock(getBlockByID(block.prevBlockID), aspectToAspect[block.aspect])
	end
end

-- Returns a block from its ID OR nil if one doesn't exist
function getBlockByID(blockID)
	for i, block in ipairs(blocks) do
		if block.blockID == blockID then
			return block
		end
	end

	return nil
end

--- If aspect is more restrictive (for example a Stop is more restrictive than a Proceed)
--- @param aspect1 integer
---	@param aspect2 integer
--- @return boolean
function aspectIsMoreRestrictive(aspect1, aspect2)
	return freedomLevel[aspect1] < freedomLevel[aspect2]
end