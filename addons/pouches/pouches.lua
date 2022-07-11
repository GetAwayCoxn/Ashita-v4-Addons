addon.name      = 'Pouches';
addon.author    = 'getawaycoxn';
addon.version   = '1.0';
addon.desc      = 'Uses any silt and bead pouches in your main inventory';
addon.link      = 'https://github.com/GetAwayCoxn/Pouches';

--[[
    1.0 - Creation
    
    Known Issues
        - Quick/repeated use of start after stop will result in command line chat message errors in game and not using all items
          Worse with more pouches available for use due to how I implemented use_pouches() with :repeating, best to let it finish 
          once it has started for now.
]]


require('common');
local chat = require('chat');
local active = false;
local silt_total = 0;
local bead_total = 0;
local total = 0;

ashita.events.register('command', 'command_cb', function (e)
    local args = e.command:args();
    if (#args == 0) then
        return;
    end
    if (args[1] ~= '/pouches') then
        return;
    end

    e.blocked = true;

    if (args[2] == 'help') then
        print(chat.header(addon.name) .. chat.message('Pouches will use silt pouches and bead pouches from your inventory bag'));
        print(chat.header(addon.name) .. chat.message('The only commands are [start] and [stop]'));

    elseif (args[2] == 'start') then
        active = true;
        count_pouches();
        if total == 0 then
            print(chat.header(addon.name) .. chat.message('No pouches found, process aborted.'));
            return;
        end
        print(chat.header(addon.name) .. chat.message('Pouches starting ... ' .. silt_total .. ' silt pouches and ' .. bead_total .. ' bead pouches. Use "/pouches stop" to abort.'));
        use_pouches:repeating(0, total, 5);

    elseif (args[2] == 'stop') then
        active = false;
        print(chat.header(addon.name) .. chat.message('Pouches stopped.'));
    end
end);

function count_pouches()
    silt_total = 0;
    bead_total = 0;
    local silt = AshitaCore:GetResourceManager():GetItemByName('Silt Pouch',0);
    local bead = AshitaCore:GetResourceManager():GetItemByName('Bead Pouch',0);
    local inventory = AshitaCore:GetMemoryManager():GetInventory();

    for x = 0, inventory:GetContainerCountMax(0) do
        local item = inventory:GetContainerItem(0, x);
        if (item ~= nil and item.Id == silt.Id) then
            silt_total = silt_total + item.Count;
        end
    end

    for x = 0, inventory:GetContainerCountMax(0) do
        local item = inventory:GetContainerItem(0, x);
        if (item ~= nil and item.Id == bead.Id) then
            bead_total = bead_total + item.Count;
        end
    end

    total = silt_total + bead_total;
end

function use_pouches()
    if active ~= true then return end

    if (silt_total > 0) then
        AshitaCore:GetChatManager():QueueCommand(1, '/item "Silt Pouch" <me>');
        silt_total = silt_total -1;
    elseif (bead_total > 0) then
        AshitaCore:GetChatManager():QueueCommand(1, '/item "Bead Pouch" <me>');
        bead_total = bead_total - 1;
    end

    if silt_total == 0 and bead_total == 0 then
        active = false;
        print(chat.header(addon.name) .. chat.message('Pouches complete.'));
    end
end