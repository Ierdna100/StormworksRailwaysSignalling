function onCreate(firstLoad)
	--server.httpGet(666, "/restart") for ierdna's pesonal http debugger, sends on http://localhost:666/restart

	if firstLoad then
		newSettings = {}

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
		newSettings.CTCWhitelisting = property.checkbox("Enable CTC whitelist (If off anyone can be CTC)", false)
		-- If signals are shown on the map with their speed limits and such
		newSettings.showSignalStatusOnMap = property.checkbox("Show signal aspects on map", true)
		-- If PTC is active upon loading the addon. PTC == All signals red unless otherwise, NTC = all signals green unless block is occupied.
		newSettings.PTC = property.checkbox("Enable PTC (If off negative train control will be used) (Does not affect automatic signals)", true)

        -- Exclusive settings
        if not newSettings.allowPlayerCTC then
            newSettings.allowChatCTC = true
        end

		g_savedata = {
			settings = newSettings
		}
	end
end