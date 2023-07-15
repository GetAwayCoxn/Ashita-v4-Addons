addon.name      = 'mountme'
addon.author    = 'GetAwayCoxn'
addon.version   = '1.0'
addon.desc      = 'mountme'
addon.link      = 'https://github.com/GetAwayCoxn/Ashita-v4-Addons'

require('common')

local MOUNTS = {
    [3072] = "Chocobo",
    [3073] = "Raptor",
    [3074] = "Tiger",
    [3075] = "Crab",
    [3076] = "Red crab",
    [3077] = "Bomb",
    [3078] = "Sheep",
    [3079] = "Morbol",
    [3080] = "Crawler",
    [3081] = "Fenrir",
    [3082] = "Beetle",
    [3083] = "Moogle",
    [3084] = "Magic pot",
    [3085] = "Tulfaire",
    [3086] = "Warmachine",
    [3087] = "Xzomit",
    [3088] = "Hippogryph",
    [3089] = "Spectral chair",
    [3090] = "Spheroid",
    [3091] = "Omega",
    [3092] = "Coeurl",
    [3093] = "Goobbue",
    [3094] = "Raaz",
    [3095] = "Levitus",
    [3096] = "Adamantoise",
    [3097] = "Dhalmel",
    [3098] = "Doll",
    [3099] = "Golden Bomb",
    [3100] = "Buffalo",
    [3101] = "Wivre",
    [3102] = "Red Raptor",
    [3103] = "Iron Giant",
    [3104] = "Byakko",
    [3105] = "Noble Chocobo",
    [3106] = "Ixion",
    [3107] = "Phuabo",
}
local myMounts = T{}

ashita.events.register('command', 'command_cb', function (e)
	local args = e.command:args()
    if #args == 0 or args[1] ~= '/mountme' then
        return
    end

    e.blocked = true

    if #args == 1 then
        PickMount()
    end
end)

function UpdateMountList()
    myMounts:clear()
    local player = AshitaCore:GetMemoryManager():GetPlayer()
    local count = 1
    for i = 3072, 3107 do
        if player:HasKeyItem(i) then
            myMounts[count] = MOUNTS[i]
            count = count + 1
        end
    end
end

function PickMount()
    UpdateMountList()
    math.randomseed(os.time())
    local idx = math.random(#myMounts)
    AshitaCore:GetChatManager():QueueCommand(1, '/mount "' .. myMounts[idx] .. '"')
end