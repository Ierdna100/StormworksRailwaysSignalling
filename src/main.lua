---@param fullMessage string Contains entire message including spaces.
---@param userPeerId integer ID of peer sending command. `-1` if command was executed by script.
---@param isAdmin boolean True if executer is administrator.
---@param isAuth boolean True if executer is authenticated.
---@param command string First parameter including the `?`, e.g.: `?command`.
function onCustomCommand(fullMessage, userPeerId, isAdmin, isAuth, command, ...)
    args = table.pack(...)
end
