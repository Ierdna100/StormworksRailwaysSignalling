-- Prints log_msg to console
function Debug(log_msg)
	server.announce("[SRS DEBUG] [" .. msToTime(server.getTimeMillisec()) .. "]", log_msg)
end

-- Prints log_msg to console
function Log(header, log_msg)
	server.announce(header, log_msg)
end

-- Converts milliseconds to HH:MM:SS.Millisec
function msToTime(milliseconds)
	hours = math.floor(milliseconds / (60 * 60 * 1000))
	minutes = math.floor(milliseconds / (60 * 1000)) % 60
	seconds = math.floor(milliseconds / 1000) % 60
	milliseconds = milliseconds % 1000

	return string.format("%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds)
end

--- sends an HTTP debug log on port 666
--- @param data string input string
function dHTTP(data)
	query = "/?d=" .. data

	server.httpGet(666, query)
end
