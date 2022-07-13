---@class Config
local Config = {

    ModName = "WorldTimeManager",
    ModVersion = "1.0.0",
    ModInfo = {
        Author = "Konijima",
        Discord = "Konijima#9279",
    },

    --- Define Global ModData tables to create on the client
    --- if true, it will always be requested/overwritten by the server
    --- if false, it will only be local
    ClientModData = {

    },

    --- Define Global ModData tables to create on the server
    ServerModData = {

    },

    --- Define custom events to add on the client
    ClientEvents = {
        "OnDateSet",
        "OnTimeSet",
    },

    --- Define custom events to add on the server
    ServerEvents = {
        "OnDateSet",
        "OnTimeSet",
    },

};

print("--------------------------------------------------------------------")
print("Initializing " .. Config.ModName .. " version " .. Config.ModVersion);
for k, v in pairs(Config.ModInfo) do
    print(k .. ": " .. v); --- print each mod info to the console log
end
print("--------------------------------------------------------------------")

return Config;
