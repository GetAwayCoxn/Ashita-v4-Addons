addon.name      = 'nomnom'
addon.author    = 'GetAwayCoxn'
addon.version   = '1.09'
addon.desc      = 'Eats food.'
addon.link      = 'https://github.com/GetAwayCoxn/'

require('common')
local imgui = require('imgui')
local chat = require('chat')

local trytime = os.time()
local now = os.time()
local currentFood = nil
local settings = T{
    is_open = {false,},
    size = {310,90},
    text_color = { 1.0, 0.75, 0.25, 1.0 },
    enabled = 'Disabled',
    update = 'Update Foods',
    menu_holder = {-1,},
    list = 'None\0',
    foods = T{},
}
local exclusions = T{--array containing item names to be excluded
    'Air Rider','Brilliant Snow','Crackler','Festive Fan','Gysahl Bomb','Kongou Inaho','Marine Bliss','Muteppo',
    'Popper','Shisai Kaboku','Spirit Masque','Airborne','Bubble Breeze','Datechochin','Flarelet','Ichinintousen Koma',
    'Konron Hassen','Meifu Goma','Ouka Ranman','Popstar','Slime Rocket','Spore Bomb','Angelwing','Cracker','Falling Star',
    'Goshikitenge','Komanezumi','Little Comet','Mog Missile','Papillion','Rengedama','Sparkling Hand','Spriggan Spark',
    'Summer Fan','Twinkle Shower',}
local badBuffs = T{'Mounted', 'Weakness', 'Sleep', 'Charm', 'Terror', 'Paralysis', 'Stun', 'Petrification'}

ashita.events.register('load', 'load_cb', function()
    settings.food = FindFood()  -- need to test on first login
end)

ashita.events.register('d3d_present', 'present_cb', function ()
    local area = AshitaCore:GetResourceManager():GetString("zones.names", AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0))
    local player = AshitaCore:GetMemoryManager():GetPlayer()
    local full = false
    local hp = AshitaCore:GetMemoryManager():GetParty():GetMemberHP(0)
    now = os.time()

    -- Force Disabled under these conditions
    if player:GetIsZoning() ~= 0 or hp < 25 then
		settings.enabled = 'Disabled'
        return
	end
    
    -- Do Work here if Enabled and before the is_open check
    if settings.enabled == 'Enabled' then
        -- Find out if full already or not and other bad things
        local buffs = AshitaCore:GetMemoryManager():GetPlayer():GetBuffs()
        for _, buff in pairs(buffs) do
            local buffString = AshitaCore:GetResourceManager():GetString("buffs.names", buff)
			if buffString and buffString == 'Food' and not full then
                full = true
            end
            if buffString and badBuffs:contains(buffString) then
                return
            end
        end
        --Kick out if no food selected on menu, else eat food since no Food buff found
        if not full then
            local function recount()
                settings.food[settings.menu_holder[1]+1][2] = CountItemName(currentFood)
            end
            -- Make sure the count is still good in case inventory has moved around since last food try
            if settings.food[settings.menu_holder[1]+1] then
                recount()
            end
            if settings.food[settings.menu_holder[1]+1] and currentFood and settings.food[settings.menu_holder[1]+1][1] == currentFood and settings.food[settings.menu_holder[1]+1][2] > 0 then
                if (now - trytime) > 5 and AshitaCore:GetMemoryManager():GetTarget():GetIsPlayerMoving() == 0 then
                    AshitaCore:GetChatManager():QueueCommand(1, '/item "' .. currentFood .. '" <me>')
                    trytime = os.time()
                    recount:once(5) -- Delay here to accurately recount food after the current food is eaten
                end
            end
            if settings.food[settings.menu_holder[1]+1] and settings.food[settings.menu_holder[1]+1][2] == 0 then
                print(chat.header('NomNom'):append(chat.message('Yikes! No more ' .. currentFood .. 's! Disabling...')))
                settings.enabled = 'Disabled'
                settings.menu_holder = {-1,}
                currentFood = nil
                settings.food = FindFood:once(5) -- Delay here to accurately recount food after the current food is eaten
            end
        end
    end

    if not settings.is_open[1] then
        return
    end

    imgui.SetNextWindowSize(settings.size)
    if imgui.Begin('NomNom', settings.is_open, ImGuiWindowFlags_NoDecoration) then
        if imgui.IsWindowFocused() then
            if imgui.IsMouseDoubleClicked(ImGuiMouseButton_Left) then
                settings.is_open[1] = not settings.is_open[1]
            end
        end
        imgui.Indent(100)imgui.TextColored(settings.text_color, 'Nom Nom !')
        imgui.Indent(-100)
        local selection = {settings.menu_holder[1] + 1}
        if imgui.Combo('Select Food', selection, settings.list) then
            settings.menu_holder[1] = selection[1] - 1
            if settings.menu_holder[1] < 0 then
                print(chat.header('NomNom'):append(chat.message('Disabling due to no food chosen')))
                settings.enabled = 'Disabled'
            else 
                currentFood = settings.food[settings.menu_holder[1] + 1][1]
            end
        end
        if settings.menu_holder[1] >= 0 then
            imgui.Text(' Quantity: ' .. tostring(settings.food[settings.menu_holder[1]+1][2]))
        else
            imgui.Text("")
        end
        if imgui.Button('Update Foods') then
            settings.menu_holder = {-1,}
            currentFood = nil
            settings.food = FindFood()
            print(chat.header('NomNom'):append(chat.message('Updated food list')))
        end
        imgui.SameLine()
        imgui.Indent(205)
        if imgui.Button(settings.enabled) then
            if settings.enabled == 'Disabled' then
                settings.enabled = 'Enabled'
            else
                settings.enabled = 'Disabled'
            end
        end
        imgui.ShowHelp('Can use /nomnom toggle or /nn toggle as well')
    end
    imgui.End()
end)

function FindFood()
    local foods = T{}
    local list = 'None\0'
    for i = 0, 81 do
        local item = AshitaCore:GetMemoryManager():GetInventory():GetContainerItem(0, i) --0 for actual inventory only
        if item then
            local check = AshitaCore:GetResourceManager():GetItemById(item.Id)
            if check and check.Flags == 1548 and NotExcluded(check) then
                local hasFood = false
                for _,v in pairs(foods) do
                    if v[1] == check.Name[1] then
                        hasFood = true
                        v[2] = v[2] + item.Count
                    end
                end
                if not hasFood then
                    foods[#foods + 1] = {check.Name[1], item.Count}
                end
                if not list:contains(check.Name[1]) then
                    list = list .. check.Name[1] .. '\0'
                end
            end
        end
    end
    settings.list = list
    return foods
end

function CountItemName(str)
    local total = 0;
    local food = AshitaCore:GetResourceManager():GetItemByName(str, 0)
    for i = 1, 81 do
        local item = AshitaCore:GetMemoryManager():GetInventory():GetContainerItem(0, i); --0 for actual inventory only
        if item and food and item.Id == food.Id then
            total = total + item.Count;
        end
    end
    return total;
end

function NotExcluded(item)--exclusion checks, return false if dont want in the foods list
    if item.Name[1]:contains('Crystal') or item.Name[1]:contains('Cluster') or item.Name[1]:contains('Egg') or exclusions:contains(item.Name[1]) then
        return false
    end
    return true
end

ashita.events.register('command', 'command_cb', function (e)
    local args = e.command:args()
    if #args == 0 or (args[1] ~= '/nomnom' and args[1] ~= '/nn') then
        return
    end

    e.blocked = true

    if #args <= 1 then
        settings.is_open[1] = not settings.is_open[1]
    elseif args[2]:any('toggle') then
        if settings.menu_holder[1] < 0 and settings.enabled == 'Disabled' then
            print(chat.header('NomNom'):append(chat.message('Cannot toggle on without choosing a food')))
        else
            if settings.enabled == 'Disabled' then
                settings.enabled = 'Enabled'
            else
                settings.enabled = 'Disabled'
            end
        end
    end
end)