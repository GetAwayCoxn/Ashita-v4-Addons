addon.name      = 'nomnom';
addon.author    = 'GetAwayCoxn';
addon.version   = '1.04';
addon.desc      = 'Eats food.';
addon.link      = 'https://github.com/GetAwayCoxn/';

require('common');
local imgui = require('imgui');
local chat = require('chat');

local trytime = os.time();
local now = os.time();

local settings = T{
    is_open = {false,},
    size = {310,90},
    text_color = { 1.0, 0.75, 0.25, 1.0 },
    enabled = 'Disabled',
    update = 'Update Foods',
    menu_holder = {-1,},
    list = 'None\0',
    foods = T{},
};
local towns = T{'Tavnazian Safehold','Al Zahbi','Aht Urhgan Whitegate','Nashmau','Southern San d\'Oria [S]','Bastok Markets [S]','Windurst Waters [S]','San d\'Oria-Jeuno Airship','Bastok-Jeuno Airship','Windurst-Jeuno Airship','Kazham-Jeuno Airship','Southern San d\'Oria','Northern San d\'Oria','Port San d\'Oria','Chateau d\'Oraguille','Bastok Mines','Bastok Markets','Port Bastok','Metalworks','Windurst Waters','Windurst Walls','Port Windurst','Windurst Woods','Heavens Tower','Ru\'Lude Gardens','Upper Jeuno','Lower Jeuno','Port Jeuno','Rabao','Selbina','Mhaura','Kazham','Norg','Mog Garden','Celennia Memorial Library','Western Adoulin','Eastern Adoulin',
};
local exclusions = T{--array containing item names to be excluded
    'Air Rider','Brilliant Snow','Crackler','Festive Fan','Gysahl Bomb','Kongou Inaho','Marine Bliss','Muteppo','Popper','Shisai Kaboku','Spirit Masque','Airborne','Bubble Breeze','Datechochin','Flarelet','Ichinintousen Koma','Konron Hassen','Meifu Goma','Ouka Ranman','Popstar','Slime Rocket','Spore Bomb','Angelwing','Cracker','Falling Star','Goshikitenge','Komanezumi','Little Comet','Mog Missile','Papillion','Rengedama','Sparkling Hand','Spriggan Spark','Summer Fan','Twinkle Shower',
};

ashita.events.register('load', 'load_cb', function()
    settings.food = FindFood();  -- need to test on first login
end);

ashita.events.register('d3d_present', 'present_cb', function ()
    local area = AshitaCore:GetResourceManager():GetString("zones.names", AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0));
    local player = AshitaCore:GetMemoryManager():GetPlayer();
    local myIndex = AshitaCore:GetMemoryManager():GetParty():GetMemberTargetIndex(0);
	local myTarget = AshitaCore:GetMemoryManager():GetTarget():GetTargetIndex(myIndex);
    local me = GetEntity(myIndex);
    local full = false;
    now = os.time();

    -- Force Disabled under these conditions
    if (player:GetIsZoning() ~= 0) or (area == nil) or (towns:contains(area)) then 
		settings.enabled = 'Disabled';
	end

    -- Also force gui hide when zoning
    if (player:GetIsZoning() ~= 0) or (me == nil) then
        return;
    end
    
    -- Do Work here if Enabled and before the is_open check
    if (settings.enabled == 'Enabled') then
        -- Find out if full already or not and other bad things
        local buffs = AshitaCore:GetMemoryManager():GetPlayer():GetBuffs();
        for _, buff in pairs(buffs) do
            local buffString = AshitaCore:GetResourceManager():GetString("buffs.names", buff);
			if (buffString ~= nil) and (buffString == 'Food') and not full then
                full = true;
            end
            if (buffString ~= nil) and ((buffString == 'Mounted') or (buffString == 'Weakness') or (buffString == 'Sleep') or (buffString == 'Charm') or (buffString == 'Terror') or (buffString == 'Paralysis') or (buffString == 'Stun') or (buffString == 'Petrification') or me.HPPercent <= 5) then
                return;
            end
        end
        --Kick out if no food selected on menu, else eat food since no Food buff found
        if settings.menu_holder[1] >= 0 and not full and settings.enabled == 'Enabled' then
            if (settings.food[settings.menu_holder[1]+1][2]) > 0 then
                if (now - trytime) > 5 then --and myTarget.IsPlayerMoving == 0 then
                    AshitaCore:GetChatManager():QueueCommand(1, '/item "' .. settings.food[settings.menu_holder[1]+1][1] .. '" <me>');
                    trytime = os.time()
                    settings.food = FindFood();
                end
            else
                --no food in Inv 
                print(chat.header('NomNom'):append(chat.message('Yikes! No more ' .. settings.food[settings.menu_holder[1]+1][1])));
                settings.enabled = 'Disabled';
            end
        end
    end

    if (not settings.is_open[1]) then
        return;
    end

    imgui.SetNextWindowSize(settings.size);
    if imgui.IsWindowHovered(ImGuiHoveredFlags_AnyWindow) then
        if imgui.IsMouseDoubleClicked(ImGuiMouseButton_Left) then
            settings.is_open[1] = not settings.is_open[1];
        end
    end
    if (imgui.Begin('NomNom', settings.is_open, ImGuiWindowFlags_NoDecoration)) then
        imgui.Indent(100);imgui.TextColored(settings.text_color, 'Nom Nom !');
        imgui.Indent(-100);
        imgui.Spacing();
        local selection = {settings.menu_holder[1] + 1};
        local name = ' Quantity: 0';
        if settings.food[settings.menu_holder[1]+1] then
            name = ' Quantity: ' .. settings.food[settings.menu_holder[1]+1][2];
        end
        if (imgui.Combo(name, selection, settings.list)) then
            settings.menu_holder[1] = selection[1] - 1;
        end
        imgui.Spacing();imgui.Spacing();
        if (imgui.Button(settings.update)) then
            if (settings.update == 'Update Foods') then
                settings.update = 'Update Foods';
            else
                settings.update = 'Update Foods';
            end
            settings.food = FindFood();
        end
        imgui.ShowHelp('Foods update with button and when hiding/unhiding');
        imgui.SameLine();
        imgui.Indent(205);
        if (imgui.Button(settings.enabled)) then
            if (settings.enabled == 'Disabled') then
                settings.enabled = 'Enabled';
            else
                settings.enabled = 'Disabled';
            end
        end
        imgui.ShowHelp('Can use /nomnom toggle or /nn toggle as well');
    end
    imgui.End();
end);

function CountItemId(id)
    local total = 0;
    for i = 1, 81 do
        local item = AshitaCore:GetMemoryManager():GetInventory():GetContainerItem(0, i); --0 for actual inventory only
        if (item ~= nil and item.Id == id) then
            total = total + item.Count;
        end
    end
    return total;
end

function CountItemName(str)--Might add cmd to add food by name
    local total = 0;
    str = tostring(str);
    for i = 1, 81 do
        local item = AshitaCore:GetMemoryManager():GetInventory():GetContainerItem(0, i); --0 for actual inventory only
        if (item ~= nil and item.Name[1] == str) then
            total = total + item.Count;
        end
    end
    return total;
end

function FindFood()
    local foods = T{};
    local list = 'None\0';
    for i = 1, 81 do
        local item = AshitaCore:GetMemoryManager():GetInventory():GetContainerItem(0, i); --0 for actual inventory only
        if (item ~= nil) then
            local check = AshitaCore:GetResourceManager():GetItemById(item.Id);
            if check ~= nil and check.Flags == 1548 and NotExcluded(check) then
                foods[#foods + 1] = {check.Name[1],CountItemId(item.Id)};
                if not list:contains(check.Name[1]) then
                    list = list .. check.Name[1] .. '\0';
                end
            end
        end
    end
    settings.list = list;
    return foods;
end

function NotExcluded(item)--exclusion checks, return false if dont want in the foods list
    if item.Name[1]:contains('Crystal') or item.Name[1]:contains('Cluster') or item.Name[1]:contains('Egg') or exclusions:contains(item.Name[1]) then
        return false;
    end
    return true;
end

ashita.events.register('command', 'command_cb', function (e)
    local args = e.command:args();
    if (#args == 0) or ((args[1] ~= '/nomnom') and (args[1] ~= '/nn')) then
        return;
    end

    e.blocked = true;

    if (#args <= 1) then
        settings.is_open[1] = not settings.is_open[1];
        settings.food = FindFood();
    elseif (args[2]:any('toggle')) then
        if (settings.enabled == 'Enabled') then
            settings.enabled = 'Disabled';
        elseif (settings.enabled == 'Disabled') then
            settings.enabled = 'Enabled';
        end
    else
        print(chat.header('NomNom'):append(chat.message('Invalid Command')));
    end
end);