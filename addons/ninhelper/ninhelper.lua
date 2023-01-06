addon.name      = 'NINhelper';
addon.author    = 'GetAwayCoxn';
addon.version   = '1.00';
addon.desc      = 'Does ninja things.';
addon.link      = 'https://github.com/GetAwayCoxn/';

require('common');
imgui = require('imgui');
chat = require('chat');

-- Default settings
vars = {
    is_open = {true,},
    size = {380,160},
    text_color = { 1.0, 0.75, 0.25, 1.0 },
    enabled = 'Disabled',
    delay = 4, --delay between attemping spells/actions, adjust to prevent spam
    needHaste = {false},
    useShikaShadows = {false},
    doShadows = {false},
    doMigawari = {false},
    doMyoshu = {false},
    doKakka = {false},
    doGekka = {false},
    doYain = {false},
    doYonin = {false},
    doInnin = {false},
    -- dont touch these ones
    hasHaste = false,
    hasShadows = false,
    hasMigawari = false,
    migawariMessage = false,
    hasMyoshu = false,
    hasKakka = false,
    hasGekka = false,
    hasYain = false,
    hasYonin = false,
    hasInnin = false,
};

-- Constants, dont touch these either
enums = {
    shihei = 1179,
    inoshishinofuda = 2971,
    shikanofuda = 2972,
    chonofuda = 2973,
    shiheiBags = 5314,
    inoshishinofudaBags = 5867,
    shikanofudaBags = 5868,
    chonofudaBags = 5869,
    ichi = 338,
    ni = 339,
    san = 340,
    migawari = 510,
    myoshu = 507,
    kakka = 509,
    gekka = 505,
    yain = 506,
};
towns = T{'Tavnazian Safehold','Al Zahbi','Aht Urhgan Whitegate','Nashmau','Southern San d\'Oria [S]','Bastok Markets [S]','Windurst Waters [S]','San d\'Oria-Jeuno Airship','Bastok-Jeuno Airship','Windurst-Jeuno Airship','Kazham-Jeuno Airship','Southern San d\'Oria','Northern San d\'Oria','Port San d\'Oria','Chateau d\'Oraguille','Bastok Mines','Bastok Markets','Port Bastok','Metalworks','Windurst Waters','Windurst Walls','Port Windurst','Windurst Woods','Heavens Tower','Ru\'Lude Gardens','Upper Jeuno','Lower Jeuno','Port Jeuno','Rabao','Selbina','Mhaura','Kazham','Norg','Mog Garden','Celennia Memorial Library','Western Adoulin','Eastern Adoulin',};
lastTime = os.time();

-- functions/events, dont touch anything below this line
ashita.events.register('d3d_present', 'present_cb', function ()

    local area = AshitaCore:GetResourceManager():GetString("zones.names", AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0));
    local player = AshitaCore:GetMemoryManager():GetPlayer();
    local myStatus = AshitaCore:GetMemoryManager():GetEntity():GetStatus(AshitaCore:GetMemoryManager():GetParty():GetMemberTargetIndex(0))

    -- Force Disabled under these conditions
    if (player:GetIsZoning() ~= 0) or (area == nil) or (towns:contains(area)) or (player:GetMainJob() ~= 13) or (myStatus == 2 or myStatus == 3) then 
		vars.enabled = 'Disabled';
	end

    -- Also force gui hide when zoning
    if (player:GetIsZoning() ~= 0) then
        return;
    end

    -- Do Work here if Enabled and Engaged before the is_open check
    if (vars.enabled == 'Enabled') and (myStatus == 1) then
        -- Count and check required buffs
        if not CheckBuffs(player) then return end
        if vars.needHaste[1] and not vars.hasHaste then return end

        local target = GetEntity(AshitaCore:GetMemoryManager():GetTarget():GetTargetIndex(0));

        -- Basic checks and delay before actual work
        if target and os.time() - lastTime > vars.delay and target.HPPercent < 98 and target.HPPercent > 2 then

            -- Do buffs
            if vars.doShadows[1] and not vars.hasShadows then
                local utsuTeir = ''
                if player:HasSpell(enums.san) and CheckSpellRecast(enums.san) == 0 then
                    utsuTeir = 'San';
                elseif player:HasSpell(enums.ni) and CheckSpellRecast(enums.ni) == 0 then
                    utsuTeir = 'Ni';
                elseif player:HasSpell(enums.ichi) and CheckSpellRecast(enums.ichi) == 0 then
                    utsuTeir = 'Ichi';
                end

                if CheckTools(enums.shihei) then
                    AshitaCore:GetChatManager():QueueCommand(1, '/ma "Utsusemi: ' .. utsuTeir .. '" <me>');
                elseif CheckTools(enums.shiheiBags) then
                    AshitaCore:GetChatManager():QueueCommand(1, '/item "Toolbag (Shihe)" <me>');
                elseif vars.useShikaShadows then
                    if CheckTools(enums.shikanofuda) then
                        AshitaCore:GetChatManager():QueueCommand(1, '/ma "Utsusemi: ' .. utsuTeir .. '" <me>');
                    elseif CheckTools(enums.shikanofudaBags) then
                        AshitaCore:GetChatManager():QueueCommand(1, '/item "Toolbag (Shika)" <me>');
                    end
                else
                    Message('Out of Tools and Bags for SHADOWS!');
                    vars.doShadows[1] = false;
                end
            elseif vars.doMigawari[1] then 
                if not vars.hasMigawari and player:HasSpell(enums.migawari) then
                    local migaCast = CheckSpellRecast(enums.migawari);
                    if migaCast > 0 and vars.migawariMessage then
                        Message('Careful, MIGAWARI is down! Recast in ' .. migaCast .. ' seconds!');
                    elseif CheckTools(enums.shikanofuda) then
                        AshitaCore:GetChatManager():QueueCommand(1, '/ma "Migawari: Ichi" <me>');
                    elseif CheckTools(enums.shikanofudaBags) then
                        AshitaCore:GetChatManager():QueueCommand(1, '/item "Toolbag (Shika)" <me>');
                    else
                        Message('Out of Shikanofuda Tools and Bags for MIGAWARI!');
                        vars.doMigawari[1] = false;
                    end
                    vars.migawariMessage = false;
                else
                    vars.migawariMessage = true;
                end
            elseif vars.doMyoshu[1] and not vars.hasMyoshu and player:HasSpell(enums.myoshu) then
                if CheckTools(enums.shikanofuda) then
                    AshitaCore:GetChatManager():QueueCommand(1, '/ma "Myoshu: Ichi" <me>');
                elseif CheckTools(enums.shikanofudaBags) then
                    AshitaCore:GetChatManager():QueueCommand(1, '/item "Toolbag (Shika)" <me>');
                else
                    Message('Out of Shikanofuda Tools and Bags for MYOSHU!');
                    vars.doMyoshu[1] = false;
                end
            elseif vars.doKakka[1] and not vars.hasKakka and player:HasSpell(enums.kakka) then
                if CheckTools(enums.shikanofuda) then
                    AshitaCore:GetChatManager():QueueCommand(1, '/ma "Kakka: Ichi" <me>');
                elseif CheckTools(enums.shikanofudaBags) then
                    AshitaCore:GetChatManager():QueueCommand(1, '/item "Toolbag (Shika)" <me>');
                else
                    Message('Out of Shikanofuda Tools and Bags for KAKKA!');
                    vars.doKakka[1] = false;
                end
            elseif vars.doGekka[1] and not vars.hasGekka and player:HasSpell(enums.gekka) then
                if CheckTools(enums.shikanofuda) then
                    AshitaCore:GetChatManager():QueueCommand(1, '/ma "Gekka: Ichi" <me>');
                elseif CheckTools(enums.shikanofudaBags) then
                    AshitaCore:GetChatManager():QueueCommand(1, '/item "Toolbag (Shika)" <me>');
                else
                    Message('Out of Shikanofuda Tools and Bags for GEKKA!');
                    vars.doGekka[1] = false;
                end
            elseif vars.doYain[1] and not vars.hasYain and player:HasSpell(enums.yain) then
                if CheckTools(enums.shikanofuda) then
                    AshitaCore:GetChatManager():QueueCommand(1, '/ma "Yain: Ichi" <me>');
                elseif CheckTools(enums.shikanofudaBags) then
                    AshitaCore:GetChatManager():QueueCommand(1, '/item "Toolbag (Shika)" <me>');
                else
                    Message('Out of Shikanofuda Tools and Bags for YAIN!');
                    vars.doYain[1] = false;
                end
            elseif vars.doYonin[1] and not vars.hasYonin and CheckAbilityRecast('Yonin') == 0 then
                AshitaCore:GetChatManager():QueueCommand(1, '/ja "Yonin" <me>');
            elseif vars.doInnin[1] and not vars.hasInnin and CheckAbilityRecast('Innin') == 0 then
                AshitaCore:GetChatManager():QueueCommand(1, '/ja "Innin" <me>');
            end

            lastTime = os.time()
        end
    end

    -- Draw control
    if (not vars.is_open[1]) or (player:GetMainJob() ~= 13) then
        return;
    end

    -- Draw things
    imgui.SetNextWindowSize(vars.size);
    if imgui.IsWindowHovered(ImGuiHoveredFlags_AnyWindow) then
        if imgui.IsMouseDoubleClicked(ImGuiMouseButton_Left) then
            vars.is_open[1] = not vars.is_open[1];
        end
    end
    if (imgui.Begin('NINhelper', vars.is_open, ImGuiWindowFlags_NoDecoration)) then
        imgui.TextColored(vars.text_color, 'NINhelper! /nh or double click to hide');imgui.ShowHelp('Will disable while in a town, while zoning, or while not NIN main job');imgui.SameLine();

        if (imgui.Button(vars.enabled)) then
            if (vars.enabled == 'Disabled') then
                vars.enabled = 'Enabled';
            else
                vars.enabled = 'Disabled';
            end
        end

        imgui.Separator();

        imgui.Checkbox('Require Haste', vars.needHaste);imgui.ShowHelp('Enable to ensure you have at least 1 haste/march buff');imgui.SameLine();
        imgui.Indent(190);imgui.Checkbox('Shika Shadows', vars.useShikaShadows);imgui.ShowHelp('Enable to be able to use shika tools for shadows if no shihei tools/bags in inventory');
        imgui.Unindent(190);imgui.Checkbox('Shadows', vars.doShadows);
        imgui.ShowHelp('VERY basic, will cast your highest teir Utsu spell available when shadows are already down');imgui.SameLine();
        imgui.Indent(190);imgui.Checkbox('Migawari', vars.doMigawari);imgui.ShowHelp('Should cast shadows first then migawari, suggested to use with Require Haste enabled');
            if vars.doMigawari[1] and not player:HasSpell(enums.migawari) then vars.doMigawari[1] = false end;
        imgui.Unindent(190);imgui.Checkbox('Myoshu (Subtle Blow)', vars.doMyoshu);imgui.SameLine();
            if vars.doMyoshu[1] and not player:HasSpell(enums.myoshu) then vars.doMyoshu[1] = false end;
        imgui.Indent(190);imgui.Checkbox('Kakka (Store TP)', vars.doKakka);
            if vars.doKakka[1] and not player:HasSpell(enums.kakka) then vars.doKakka[1] = false end;
        imgui.Unindent(190);imgui.Checkbox('Gekka (Enmity +)', vars.doGekka);imgui.SameLine();
            if vars.doGekka[1] and not player:HasSpell(enums.gekka) then vars.doGekka[1] = false end;
            if vars.doGekka[1] then vars.doYain[1] = false end
        imgui.Indent(190);imgui.Checkbox('Yain (Enmity -)', vars.doYain);
            if vars.doYain[1] and not player:HasSpell(enums.yain) then vars.doYain[1] = false end;
            if vars.doYain[1] then vars.doGekka[1] = false end
        imgui.Unindent(190);imgui.Checkbox('Yonin', vars.doYonin);imgui.SameLine();
            if vars.doYonin[1] then vars.doInnin[1] = false end
        imgui.Indent(190);imgui.Checkbox('Innin', vars.doInnin);
            if vars.doInnin[1] then vars.doYonin[1] = false end
    end
    imgui.End();
end);

ashita.events.register('command', 'command_cb', function (e)
    local args = e.command:args();
    if (#args == 0) or ((args[1] ~= '/ninhelper') and (args[1] ~= '/nh')) then
        return;
    end

    e.blocked = true;

    if (#args <= 1) and ((args[1] == '/ninhelper') or (args[1] == '/nh')) then
        vars.is_open[1] = not vars.is_open[1];
    elseif (#args >= 2 and args[2]:any('toggle')) then
        if (vars.enabled == 'Enabled') then
            vars.enabled = 'Disabled';
        elseif (vars.enabled == 'Disabled') then
            vars.enabled = 'Enabled';
        end
    end
end);

function CheckAbilityRecast(str)
	local recastTime = 0;
	for x = 0, 31 do
		local id = AshitaCore:GetMemoryManager():GetRecast():GetAbilityTimerId(x);
		local timer = AshitaCore:GetMemoryManager():GetRecast():GetAbilityTimer(x);

		if ((id ~= 0 or x == 0) and timer > 0) then
			local ability = AshitaCore:GetResourceManager():GetAbilityByTimerId(id);
            
			if (ability ~= nil and ability.Name[1] == str) then
				recastTime = timer;
			end
		end
	end
	return recastTime;
end

function CheckSpellRecast(id)
	return AshitaCore:GetMemoryManager():GetRecast():GetSpellTimer(id) / 60;
end

function CheckBuffs(player)
    local foundShadows = false;
    local foundMigawari = false;
    local foundMyoshu = false;
    local foundKakka = false;
    local foundGekka = false;
    local foundYain = false;
    local foundHaste = false;
    local foundYonin = false;
    local foundInnin = false;
    local buffs = player:GetBuffs();

    for _, buff in pairs(buffs) do
        local buffString = AshitaCore:GetResourceManager():GetString("buffs.names", buff);
        if (buffString ~= nil) then
            if (buffString == 'Mounted') then
                vars.enabled = 'Disabled';
                return false;
            elseif (buffString == 'Sleep') or (buffString == 'Charm') or (buffString == 'Terror') or (buffString == 'Petrification') or (buffString == 'Stun') then
                return false;
            elseif buffString:contains('Copy Image') then foundShadows = true;
            elseif buffString == 'Migawari' then foundMigawari = true;
            elseif buffString == 'Subtle Blow Plus' then foundMyoshu = true;
            elseif buffString == 'Store TP' then foundKakka = true;
            elseif buffString == 'Enmity Boost' then foundGekka = true;
            elseif buffString == 'Pax' then foundYain = true;
            elseif buffString == 'Yonin' then foundYonin = true;
            elseif buffString == 'Innin' then foundInnin = true;
            elseif buffString == 'Haste' or buffString == 'March' then foundHaste = true;
            end
        end
    end

    vars.hasShadows = foundShadows;
    vars.hasMigawari = foundMigawari;
    vars.hasMyoshu = foundMyoshu;
    vars.hasKakka = foundKakka;
    vars.hasGekka = foundGekka;
    vars.hasYain = foundYain;
    vars.hasHaste = foundHaste;
    vars.hasYonin = foundYonin;
    vars.hasInnin = foundInnin;

    return true;
end

function CheckTools(id)
    for i = 1, 81 do
        local item = AshitaCore:GetMemoryManager():GetInventory():GetContainerItem(0, i);
        if item ~= nil and item.Id == id then
            return true;
        end
    end
    return false;
end

function Message(str)
    str = tostring(str)
    print(chat.header(addon.name):append(chat.message(str)));
end
