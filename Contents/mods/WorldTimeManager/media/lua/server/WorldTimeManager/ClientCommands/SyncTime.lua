--- Load Server
local Server = require 'WorldTimeManager/Server';

---Handle receiving SyncTime command from a client
---@param player IsoPlayer
---@param args table
function Server.Commands.SyncTime(player, args)
    if Server.Utils.IsSinglePlayer() or player:getAccessLevel() == "Admin" then
        Server.Modules.WorldTime.SyncSystemTime();
    end
end
