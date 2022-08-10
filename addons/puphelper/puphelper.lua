addon.name      = 'Puphelper';
addon.author    = 'GetAwayCoxn';
addon.version   = '1.07';
addon.desc      = 'Does puppetmaster things. Based on my runehelper addon for Ashita v4, inspired by pupper addon by Towbes for Ashita v3';
addon.link      = 'https://github.com/GetAwayCoxn/Pup-Helper';

require('common');
local imgui = require('imgui');

local Towns = T{'Tavnazian Safehold','Al Zahbi','Aht Urhgan Whitegate','Nashmau','Southern San d\'Oria [S]','Bastok Markets [S]','Windurst Waters [S]','San d\'Oria-Jeuno Airship','Bastok-Jeuno Airship','Windurst-Jeuno Airship','Kazham-Jeuno Airship','Southern San d\'Oria','Northern San d\'Oria','Port San d\'Oria','Chateau d\'Oraguille','Bastok Mines','Bastok Markets','Port Bastok','Metalworks','Windurst Waters','Windurst Walls','Port Windurst','Windurst Woods','Heavens Tower','Ru\'Lude Gardens','Upper Jeuno','Lower Jeuno','Port Jeuno','Rabao','Selbina','Mhaura','Kazham','Norg','Mog Garden','Celennia Memorial Library','Western Adoulin','Eastern Adoulin',
};
local now = os.time();
local deployTime = now;
local manTime = now;
local coolTime = now;
local repTime = now;

local manager = {
    is_open = {false,},
    size = {410,175},
    text_color = { 1.0, 0.75, 0.25, 1.0 },
    enabled = 'Disabled',
    maneuvers = {{'Dark Maneuver',0},{'Light Maneuver',0},{'Earth Maneuver',0},{'Wind Maneuver',0},{'Fire Maneuver',0},{'Ice Maneuver',0},{'Thunder Maneuver',0},{'Water Maneuver',0},{'Overload',0}},
    menu_holders = {-1,-1,-1},
    repair = {0,},
    autodeploy = {false,},
    autocooldown = {true,},
    autolight = {50,90},
    autorepairholder = {-1,},
};

ashita.events.register('d3d_present', 'present_cb', function ()
    local oils = CountItemId(19185); --automation oil +3 item ID
    local Area = AshitaCore:GetResourceManager():GetString("zones.names", AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0));
    local Player = AshitaCore:GetMemoryManager():GetPlayer();
    local PetID = AshitaCore:GetMemoryManager():GetEntity():GetPetTargetIndex(AshitaCore:GetMemoryManager():GetParty():GetMemberTargetIndex(0));
    local TargetID = AshitaCore:GetMemoryManager():GetTarget():GetTargetIndex(0);

    -- Force Disabled under these conditions
    if (Area == nil) or (Towns:contains(Area)) or (Player:GetIsZoning() ~= 0) or (PetID == 0) or (PetID == nil) or (Player:GetMainJob() ~= 18) or (AshitaCore:GetMemoryManager():GetParty():GetMemberHPPercent(0) < 1) then
		manager.enabled = 'Disabled';
	end

    -- Also force gui hide when zoning
    if (Player:GetIsZoning() ~= 0) then
        return;
    end
    now = os.time();
    -- Do Work here if Enabled and before the is_open check
    if (manager.enabled == 'Enabled') and (PetID ~= 0 or PetID ~= nil) then
        --Do auto Deploy
        if (TargetID ~= 0 or TargetID ~= nil) and (manager.autodeploy[1] == true) and (AshitaCore:GetMemoryManager():GetEntity():GetStatus(AshitaCore:GetMemoryManager():GetParty():GetMemberTargetIndex(0)) == 1) and (AshitaCore:GetMemoryManager():GetEntity():GetStatus(PetID) == 0) and (AshitaCore:GetMemoryManager():GetEntity():GetHPPercent(TargetID) > 10) and (now - deployTime > 5) then
            AshitaCore:GetChatManager():QueueCommand(1, '/ja "Deploy" <t>');
            deployTime = now;
        end

        --Set recasts, maneuvers dont work correcty however due to recasts addon i think, every maneuver is Fire? This works for our needs for now however
        local manrecast = CheckAbilityRecast('Fire Maneuver');
        local repairtime = CheckAbilityRecast('Repair');
        local cooldowntime = CheckAbilityRecast('Cooldown');

        --Count maneuvers, credit to Thorny here, this is from his luashitacast gData.GetBuffCount funtion, slightly modified for my specific use case
        local total = 0;
        for b = 1, #manager.maneuvers do
            manager.maneuvers[b][2] = 0;
            local buffs = AshitaCore:GetMemoryManager():GetPlayer():GetBuffs();
            for _, buff in pairs(buffs) do
                local buffString = AshitaCore:GetResourceManager():GetString("buffs.names", buff);
			    if (buffString ~= nil) and (buffString == manager.maneuvers[b][1]) then
                    manager.maneuvers[b][2] = manager.maneuvers[b][2] + 1;
                    total = total + 1;
                elseif (buffString ~= nil) and (buffString == 'Mounted') then
                    manager.enabled = 'Disabled';
                elseif (buffString ~= nil) and ((buffString == 'Sleep') or (buffString == 'Terror') or (buffString == 'Charm') or (buffString == 'Stun') or (buffString == 'Petrification') or (buffString == 'Amnesia')) then
                    return;
                end
            end
        end

        --Do cooldown things
        if (cooldowntime == 0) and (manager.maneuvers[9][2] ~= 0) and (manager.autocooldown[1] == true) and (now - coolTime > 2) then
            AshitaCore:GetChatManager():QueueCommand(1, '/ja "Cooldown" <me>');
            coolTime = now;
        end

        --Do autolight things
        if (AshitaCore:GetMemoryManager():GetEntity():GetHPPercent(PetID) < manager.autolight[1]) then
            manager.menu_holders[1] = 1;
        elseif (AshitaCore:GetMemoryManager():GetEntity():GetHPPercent(PetID) >= manager.autolight[2]) then
            manager.menu_holders[1] = manager.autorepairholder[1];
        end

        --Do the maneuver things
        if (manrecast == 0) and (manager.maneuvers[9][2] == 0) and (now - manTime > 2) then
            if (manager.menu_holders[1] ~= -1) then
                if (manager.maneuvers[manager.menu_holders[1] + 1][2] == 0) then
                    AshitaCore:GetChatManager():QueueCommand(1, '/ja "' .. manager.maneuvers[manager.menu_holders[1] + 1][1] .. '" <me>');
                end
            end
            if ((manager.menu_holders[2] ~= -1)) then
                if (manager.maneuvers[manager.menu_holders[2] + 1][2] == 0) then
                    AshitaCore:GetChatManager():QueueCommand(1, '/ja "' .. manager.maneuvers[manager.menu_holders[2] + 1][1] .. '" <me>');
                elseif (manager.maneuvers[manager.menu_holders[2] + 1][2] < 2) then
                    if (manager.menu_holders[1] ~= -1) and (manager.maneuvers[manager.menu_holders[1] + 1][1] == manager.maneuvers[manager.menu_holders[2] + 1][1]) then
                        AshitaCore:GetChatManager():QueueCommand(1, '/ja "' .. manager.maneuvers[manager.menu_holders[2] + 1][1] .. '" <me>');
                    elseif (manager.menu_holders[3] ~= -1) and (manager.maneuvers[manager.menu_holders[3] + 1][1] == manager.maneuvers[manager.menu_holders[2] + 1][1]) then
                        AshitaCore:GetChatManager():QueueCommand(1, '/ja "' .. manager.maneuvers[manager.menu_holders[2] + 1][1] .. '" <me>');
                    end
                end
            end
            if ((manager.menu_holders[3] ~= -1)) then
                if (manager.maneuvers[manager.menu_holders[3] + 1][2] == 0) then
                    AshitaCore:GetChatManager():QueueCommand(1, '/ja "' .. manager.maneuvers[manager.menu_holders[3] + 1][1] .. '" <me>');
                elseif (manager.maneuvers[manager.menu_holders[3] + 1][2] < 3) then
                    if (manager.menu_holders[1] ~= -1) and (manager.menu_holders[2] ~= -1) and (manager.maneuvers[manager.menu_holders[1] + 1][1] == manager.maneuvers[manager.menu_holders[3] + 1][1]) and (manager.maneuvers[manager.menu_holders[2] + 1][1] == manager.maneuvers[manager.menu_holders[3] + 1][1]) then
                        AshitaCore:GetChatManager():QueueCommand(1, '/ja "' .. manager.maneuvers[manager.menu_holders[3] + 1][1] .. '" <me>');
                    elseif (manager.menu_holders[1] ~= -1) and (manager.maneuvers[manager.menu_holders[3] + 1][1] == manager.maneuvers[manager.menu_holders[1] + 1][1]) and (manager.maneuvers[manager.menu_holders[3] + 1][2] < 2) then
                        AshitaCore:GetChatManager():QueueCommand(1, '/ja "' .. manager.maneuvers[manager.menu_holders[3] + 1][1] .. '" <me>');
                    elseif (manager.menu_holders[2] ~= -1) and (manager.maneuvers[manager.menu_holders[3] + 1][1] == manager.maneuvers[manager.menu_holders[2] + 1][1]) and (manager.maneuvers[manager.menu_holders[3] + 1][2] < 2) then
                        AshitaCore:GetChatManager():QueueCommand(1, '/ja "' .. manager.maneuvers[manager.menu_holders[3] + 1][1] .. '" <me>');
                    end
                end
            end
            manTime = now;
        end

        --Do the repair things
        if (repairtime == 0) and (oils > 0) and (now - repTime > 2) then
            if (AshitaCore:GetMemoryManager():GetEntity():GetHPPercent(PetID) < manager.repair[1]) and (tonumber(AshitaCore:GetMemoryManager():GetEntity():GetDistance(PetID)) < 20) then
                AshitaCore:GetChatManager():QueueCommand(1, '/ja "Repair" <me>');
                repTime = now;
            end
        end
    end

    if (not manager.is_open[1]) then
        return;
    end

    --Draw things
    imgui.SetNextWindowSize(manager.size);
    if (imgui.Begin('Puphelper', manager.is_open, ImGuiWindowFlags_NoDecoration)) then
        imgui.TextColored(manager.text_color, tostring(' +3 oils:  ' .. oils .. '                           Use /ph to hide'));

        local selection1 = {manager.menu_holders[1] + 1};
        if (imgui.Combo('Maneuver 1', selection1, 'None\0Dark\0Light\0Earth\0Wind\0Fire\0Ice\0Thunder\0Water\0')) then
            manager.menu_holders[1] = selection1[1] - 1;
            manager.autorepairholder[1] = manager.menu_holders[1];
        end
        
        local selection2 = {manager.menu_holders[2] + 1};
        if (imgui.Combo('Maneuver 2', selection2, 'None\0Dark\0Light\0Earth\0Wind\0Fire\0Ice\0Thunder\0Water\0')) then
            manager.menu_holders[2] = selection2[1] - 1;
        end
        
        local selection3 = {manager.menu_holders[3] + 1};
        if (imgui.Combo('Maneuver 3', selection3, 'None\0Dark\0Light\0Earth\0Wind\0Fire\0Ice\0Thunder\0Water\0')) then
            manager.menu_holders[3] = selection3[1] - 1;
        end

        if (imgui.InputInt('Auto Repair %',manager.repair)) then
            if (manager.repair[1] > 100) then manager.repair[1] = 100;
            elseif (manager.repair[1] < 0) then manager.repair[1] = 0 end
        end
        imgui.ShowHelp('Set the HP% of your pet you want repair to go off at, just 0 to disable');

        local lightmin = {manager.autolight[1],};
        local lightmax = {manager.autolight[2],};
        if (imgui.DragIntRange2('Auto Light %',lightmin,lightmax,1.0,0,100)) then
            manager.autolight[1] = lightmin[1];
            manager.autolight[2] = lightmax[1];
            if (manager.autolight[2] < manager.autolight[1]) then
                manager.autolight[2] = manager.autolight[1];
            end
        end
        imgui.ShowHelp('First entry is what HP% to force Manuever 1 to light, second entry is what HP% to go back to your previous Maneuver 1. First entry 0 to disable.');

        imgui.Checkbox('Auto Deploy', manager.autodeploy);imgui.SameLine();imgui.Checkbox('Auto Cooldown', manager.autocooldown);imgui.SameLine();imgui.Indent(300);
        if (imgui.Button(manager.enabled)) then
            if (manager.enabled == 'Disabled') then
                manager.enabled = 'Enabled';
            else
                manager.enabled = 'Disabled';
            end
        end
        imgui.ShowHelp('Will stay Disabled while in a town, while not PUP main, or while no puppet is called out');
    end
    imgui.End();
end);

function CheckAbilityRecast(check)
	local RecastTime = 0;

	for x = 0, 31 do
		local id = AshitaCore:GetMemoryManager():GetRecast():GetAbilityTimerId(x);
		local timer = AshitaCore:GetMemoryManager():GetRecast():GetAbilityTimer(x);

		if ((id ~= 0 or x == 0) and timer > 0) then
			local ability = AshitaCore:GetResourceManager():GetAbilityByTimerId(id);

			if ability ~= nil and ability.Name[1] ~= 'Unknown' and (ability.Name[1] == check) then
				RecastTime = timer;
			end
		end
	end
	return RecastTime;
end

function CountItemId(id)
    local total = 0;
    for x = 1, 9 do
        local c = 0;
        if x == 2 then -- offset to not check unwanted bags
            c = 8;
        elseif x > 2 then
            c = x + 7;
        end
        for i = 1, 81 do
            local item = AshitaCore:GetMemoryManager():GetInventory():GetContainerItem(c, i);
            if (item ~= nil and item.Id == id) then
                total = total + item.Count;
            end
        end
    end
    return total;
end

ashita.events.register('command', 'command_cb', function (e)
    local args = e.command:args();
    if (#args == 0) or ((args[1] ~= '/puphelper') and (args[1] ~= '/ph')) then
        return;
    end

    e.blocked = true;

    if (#args <= 1) and ((args[1] == '/puphelper') or (args[1] == '/ph')) then
        manager.is_open[1] = not manager.is_open[1];
    elseif (#args >= 2 and args[2]:any('toggle')) then
        if (manager.enabled == 'Enabled') then
            manager.enabled = 'Disabled';
        elseif (manager.enabled == 'Disabled') then
            manager.enabled = 'Enabled';
        end
    elseif (#args >= 2 and args[2]:any('set')) then
        local eles = {'dark','light','earth','wind','fire','ice','thunder','water'};
        for x = 1, #eles do
            for y = 1, #manager.menu_holders do
                if args[y+2] == nil then
                elseif string.lower(args[y+2]) == eles[x] then
                    manager.menu_holders[y] = x - 1;
                end
            end
        end
        manager.autorepairholder[1] = manager.menu_holders[1];
    end
end);