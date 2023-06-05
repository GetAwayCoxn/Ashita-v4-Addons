addon.name      = 'AutoChecker';
addon.author    = 'GetAwayCoxn';
addon.version   = '1.2';
addon.desc      = 'Automatically check mobs as you target them';
addon.link      = 'https://github.com/GetAwayCoxn/Ashita-v4-Addons';

require('common');
local chat = require('chat');

local active = true;
local lastMobIndex = 0;
local towns = T{'Tavnazian Safehold','Al Zahbi','Aht Urhgan Whitegate','Nashmau','Southern San d\'Oria [S]','Bastok Markets [S]','Windurst Waters [S]','San d\'Oria-Jeuno Airship','Bastok-Jeuno Airship','Windurst-Jeuno Airship','Kazham-Jeuno Airship','Southern San d\'Oria','Northern San d\'Oria','Port San d\'Oria','Chateau d\'Oraguille','Bastok Mines','Bastok Markets','Port Bastok','Metalworks','Windurst Waters','Windurst Walls','Port Windurst','Windurst Woods','Heavens Tower','Ru\'Lude Gardens','Upper Jeuno','Lower Jeuno','Port Jeuno','Rabao','Selbina','Mhaura','Kazham','Norg','Mog Garden','Celennia Memorial Library','Western Adoulin','Eastern Adoulin',};

ashita.events.register('d3d_present', 'present_cb', function ()
    if not active then return end

    local party = AshitaCore:GetMemoryManager():GetParty();
    local area = AshitaCore:GetResourceManager():GetString("zones.names", party:GetMemberZone(0));
    
    if (area == nil) or (towns:contains(area)) or (party:GetMemberHPPercent(0) < 1) then
        return
	end

    local targetIndex = AshitaCore:GetMemoryManager():GetTarget():GetTargetIndex(0);
    local myStatus = AshitaCore:GetMemoryManager():GetEntity():GetStatus(party:GetMemberTargetIndex(0))

    if not targetIndex or targetIndex == 0 or myStatus == 1 then
        lastMobIndex = 0
        return
    end
    
    if targetIndex == lastMobIndex then return end

    local targetEntity = GetEntity(targetIndex)
    if targetEntity then
        lastMobIndex = targetEntity.TargetIndex;
        if targetEntity.Type == 2 then
            AshitaCore:GetChatManager():QueueCommand(1, '/c <t>');
        end
    end
end);

ashita.events.register('command', 'command_cb', function (e)
	local args = e.command:args();
    if (#args == 0) or (args[1] ~= '/achecker' and args[1] ~= '/autochecker') then
        return;
    end

    e.blocked = true;

    active = not active;
    if active then
        print(chat.header(addon.name) .. chat.message('is now on'));
    else
        print(chat.header(addon.name) .. chat.message('is now off'));
    end
end);

