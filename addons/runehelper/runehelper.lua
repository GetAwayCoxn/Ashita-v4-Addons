addon.name      = 'Runehelper';
addon.author    = 'GetAwayCoxn';
addon.version   = '1.04';
addon.desc      = 'Does runefencer things.';
addon.link      = 'https://github.com/GetAwayCoxn/Rune-Helper';

require('common');
local imgui = require('imgui');

local Towns = T{'Tavnazian Safehold','Al Zahbi','Aht Urhgan Whitegate','Nashmau','Southern San d\'Oria [S]','Bastok Markets [S]','Windurst Waters [S]','San d\'Oria-Jeuno Airship','Bastok-Jeuno Airship','Windurst-Jeuno Airship','Kazham-Jeuno Airship','Southern San d\'Oria','Northern San d\'Oria','Port San d\'Oria','Chateau d\'Oraguille','Bastok Mines','Bastok Markets','Port Bastok','Metalworks','Windurst Waters','Windurst Walls','Port Windurst','Windurst Woods','Heavens Tower','Ru\'Lude Gardens','Upper Jeuno','Lower Jeuno','Port Jeuno','Rabao','Selbina','Mhaura','Kazham','Norg','Mog Garden','Celennia Memorial Library','Western Adoulin','Eastern Adoulin',
};
local now = os.time();
local runeTime = now;
local pulseTime = now;
local manager = {
    is_open = {false,},
    size = {410,175},
    text_color = { 1.0, 0.75, 0.25, 1.0 },
    enabled = 'Disabled',
    runes = {{'Ignis',0},{'Gelus',0},{'Flabra',0},{'Tellus',0},{'Sulpor',0},{'Unda',0},{'Lux',0},{'Tenebrae',0}},
    menu_holders = {-1,-1,-1},
    pulse = {70,},
};

ashita.events.register('d3d_present', 'present_cb', function ()

    local Area = AshitaCore:GetResourceManager():GetString("zones.names", AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0));
    local Player = AshitaCore:GetMemoryManager():GetPlayer();

    -- Force Disabled under these conditions
    if (Player:GetIsZoning() ~= 0) or (Area == nil) or (Towns:contains(Area)) or ((Player:GetMainJob() ~= 22) and (Player:GetSubJob() ~= 22)) or (AshitaCore:GetMemoryManager():GetParty():GetMemberHPPercent(0) < 1) then 
		manager.enabled = 'Disabled';
	end

    -- Also force gui hide when zoning
    if (Player:GetIsZoning() ~= 0) then
        return;
    end
    now = os.time();
    -- Do Work here if Enabled and before the is_open check
    if (manager.enabled == 'Enabled') then
        --Set recasts, runes dont work correcty however due to recasts addon i think, every rune is Ignis? This works for our needs for now however
        local runerecast = CheckAbilityRecast('Rune Enchantment');
        local pulserecast = CheckAbilityRecast('Vivacious Pulse');

        --Count runes, credit to Thorny here, this is from his luashitacast gData.GetBuffCount funtion, slightly modified for my specific use case
        local total = 0;
        for b = 1, #manager.runes do
            manager.runes[b][2] = 0;
            local buffs = AshitaCore:GetMemoryManager():GetPlayer():GetBuffs();
            for _, buff in pairs(buffs) do
                local buffString = AshitaCore:GetResourceManager():GetString("buffs.names", buff);
			    if (buffString ~= nil) and (buffString == manager.runes[b][1]) then
                    manager.runes[b][2] = manager.runes[b][2] + 1;
                    total = total + 1;
                elseif (buffString ~= nil) and (buffString == 'Mounted') then
                    manager.enabled = 'Disabled';
                elseif (buffString ~= nil) and ((buffString == 'Sleep') or (buffString == 'Charm') or (buffString == 'Terror') or (buffString == 'Petrification') or (buffString == 'Stun')) then
                    return;
                end
            end
        end

        --Do the rune things
        if (runerecast == 0) and (now - runeTime > 2) then
            if (manager.menu_holders[1] ~= -1) then
                if (manager.runes[manager.menu_holders[1] + 1][2] == 0) then
                    AshitaCore:GetChatManager():QueueCommand(1, '/ja "' .. manager.runes[manager.menu_holders[1] + 1][1] .. '" <me>');
                end
            end
            if ((manager.menu_holders[2] ~= -1)) then
                if (manager.runes[manager.menu_holders[2] + 1][2] == 0) then
                    AshitaCore:GetChatManager():QueueCommand(1, '/ja "' .. manager.runes[manager.menu_holders[2] + 1][1] .. '" <me>');
                elseif (manager.runes[manager.menu_holders[2] + 1][2] < 2) then
                    if (manager.menu_holders[1] ~= -1) and (manager.runes[manager.menu_holders[1] + 1][1] == manager.runes[manager.menu_holders[2] + 1][1]) then
                        AshitaCore:GetChatManager():QueueCommand(1, '/ja "' .. manager.runes[manager.menu_holders[2] + 1][1] .. '" <me>');
                    elseif (manager.menu_holders[3] ~= -1) and (manager.runes[manager.menu_holders[3] + 1][1] == manager.runes[manager.menu_holders[2] + 1][1]) then
                        AshitaCore:GetChatManager():QueueCommand(1, '/ja "' .. manager.runes[manager.menu_holders[2] + 1][1] .. '" <me>');
                    end
                end
            end
            if ((manager.menu_holders[3] ~= -1)) then
                if (manager.runes[manager.menu_holders[3] + 1][2] == 0) then
                    AshitaCore:GetChatManager():QueueCommand(1, '/ja "' .. manager.runes[manager.menu_holders[3] + 1][1] .. '" <me>');
                elseif (manager.runes[manager.menu_holders[3] + 1][2] < 3) then
                    if (manager.menu_holders[1] ~= -1) and (manager.menu_holders[2] ~= -1) and (manager.runes[manager.menu_holders[1] + 1][1] == manager.runes[manager.menu_holders[3] + 1][1]) and (manager.runes[manager.menu_holders[2] + 1][1] == manager.runes[manager.menu_holders[3] + 1][1]) then
                        AshitaCore:GetChatManager():QueueCommand(1, '/ja "' .. manager.runes[manager.menu_holders[3] + 1][1] .. '" <me>');
                    elseif (manager.menu_holders[1] ~= -1) and (manager.runes[manager.menu_holders[3] + 1][1] == manager.runes[manager.menu_holders[1] + 1][1]) and (manager.runes[manager.menu_holders[3] + 1][2] < 2) then
                        AshitaCore:GetChatManager():QueueCommand(1, '/ja "' .. manager.runes[manager.menu_holders[3] + 1][1] .. '" <me>');
                    elseif (manager.menu_holders[2] ~= -1) and (manager.runes[manager.menu_holders[3] + 1][1] == manager.runes[manager.menu_holders[2] + 1][1]) and (manager.runes[manager.menu_holders[3] + 1][2] < 2) then
                        AshitaCore:GetChatManager():QueueCommand(1, '/ja "' .. manager.runes[manager.menu_holders[3] + 1][1] .. '" <me>');
                    end
                end
            end
            runeTime = now;
        end

        --Do the pulse things
        if (pulserecast == 0) and (total == 3) and (now - pulseTime > 2) then
            local MPP = AshitaCore:GetMemoryManager():GetParty():GetMemberMPPercent(0);
            local HPP = AshitaCore:GetMemoryManager():GetParty():GetMemberHPPercent(0);
            if (manager.runes[8][2] == 3) and (MPP < manager.pulse[1]) then
                AshitaCore:GetChatManager():QueueCommand(1, '/ja "Vivacious Pulse" <me>');
            elseif (HPP < manager.pulse[1]) then
                AshitaCore:GetChatManager():QueueCommand(1, '/ja "Vivacious Pulse" <me>');
            end
            pulseTime = now;
        end
    end

    if (not manager.is_open[1]) then
        return;
    end

    --Draw things
    imgui.SetNextWindowSize(manager.size);
    if (imgui.Begin('RuneHelper', manager.is_open, ImGuiWindowFlags_NoDecoration)) then
        imgui.TextColored(manager.text_color, 'Use /runehelper or /rh to hide');

        imgui.Spacing();
        local selection1 = {manager.menu_holders[1] + 1};
        if (imgui.Combo('Rune 1', selection1, 'None\0Ignis (Fire/Ice)\0Gellus (Ice/Wind)\0Flabra (Wind/Earth)\0Tellus (Earth/Ltng)\0Sulpor (Ltng/Water)\0Unda (Water/Fire)\0Lux (Light/Dark)\0Tenebrae (Dark/Light)\0')) then
            manager.menu_holders[1] = selection1[1] - 1;
        end
        imgui.Spacing();
        local selection2 = {manager.menu_holders[2] + 1};
        if (imgui.Combo('Rune 2', selection2, 'None\0Ignis (Fire/Ice)\0Gellus (Ice/Wind)\0Flabra (Wind/Earth)\0Tellus (Earth/Ltng)\0Sulpor (Ltng/Water)\0Unda (Water/Fire)\0Lux (Light/Dark)\0Tenebrae (Dark/Light)\0')) then
            manager.menu_holders[2] = selection2[1] - 1;
        end
        imgui.Spacing();
        local selection3 = {manager.menu_holders[3] + 1};
        if (imgui.Combo('Rune 3', selection3, 'None\0Ignis (Fire/Ice)\0Gellus (Ice/Wind)\0Flabra (Wind/Earth)\0Tellus (Earth/Ltng)\0Sulpor (Ltng/Water)\0Unda (Water/Fire)\0Lux (Light/Dark)\0Tenebrae (Dark/Light)\0')) then
            manager.menu_holders[3] = selection3[1] - 1;
            if (Player:GetMainJob() ~= 22) then manager.menu_holders[3] = -1 end
        end
        imgui.ShowHelp('Rune 3 defaults to None if /RUN');

        imgui.Spacing();
        if (imgui.InputInt('Auto Pulse %',manager.pulse)) then
            if (manager.pulse[1] > 100) then manager.pulse[1] = 100;
            elseif (manager.pulse[1] < 0) then manager.pulse[1] = 0 end
            if (Player:GetMainJob() ~= 22) then manager.pulse[1] = 0 end
        end
        imgui.ShowHelp('Requires 3 runes, if all 3 are Tenebrae then this % is for MPP instead of HPP, default to 0 if /RUN');

        imgui.Spacing();
        if (imgui.Button(manager.enabled)) then
            if (manager.enabled == 'Disabled') then
                manager.enabled = 'Enabled';
            else
                manager.enabled = 'Disabled';
            end
        end
        imgui.ShowHelp('Will stay Disabled while in a town, while zoning, or while not RUN or /RUN');
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
            
			if (ability ~= nil and ability.Name[1] == check) then
				RecastTime = timer;
			end
		end
	end
	return RecastTime;
end

ashita.events.register('command', 'command_cb', function (e)
    local args = e.command:args();
    if (#args == 0) or ((args[1] ~= '/runehelper') and (args[1] ~= '/rh')) then
        return;
    end

    e.blocked = true;

    if (#args <= 1) and ((args[1] == '/runehelper') or (args[1] == '/rh')) then
        manager.is_open[1] = not manager.is_open[1];
    elseif (#args >= 2 and args[2]:any('toggle')) then
        if (manager.enabled == 'Enabled') then
            manager.enabled = 'Disabled';
        elseif (manager.enabled == 'Disabled') then
            manager.enabled = 'Enabled';
        end
    end
end);