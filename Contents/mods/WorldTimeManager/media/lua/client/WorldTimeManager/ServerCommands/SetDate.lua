--- Load Client
local Client = require 'WorldTimeManager/Client';

---Handle receiving SetTime command from the server
---@param args table
function Client.Commands.SetDate(args)
    Client.Modules.WorldTime.SetDate(args.year, args.month, args.day);
end
