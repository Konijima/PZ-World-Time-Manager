--- Load Server
local Server = require 'WorldTimeManager/Server';

---Handle receiving SetTime command from a client
---@param player IsoPlayer
---@param args table
function Server.Commands.SetTime(player, args)
    if Server.Utils.IsSinglePlayer() or player:getAccessLevel() == "Admin" then
        Server.Modules.WorldTime.SetTime(args.hour, args.minute);
    end
end
