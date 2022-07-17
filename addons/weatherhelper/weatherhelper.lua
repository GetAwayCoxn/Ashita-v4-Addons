addon.name      = 'weatherhelper';
addon.author    = 'GetAwayCoxn';
addon.version   = '1.0';
addon.desc      = 'Will play a call in party chat when your choice of weather pops and depops';
addon.link      = 'https://github.com/GetAwayCoxn/Ashita-v4-Addons';

require('common');
local chat = require('chat');
local vars = {
    valid = false;--no touchy
    good_call = 4;--the call number to play when your weather pops
    bad_call = 5;--the call number to play when your weather drops
};
local weathers = {
    [0] = 'Clear',
    [1] = 'Sunshine',
    [2] = 'Clouds',
    [3] = 'Fog',
    [4] = 'Fire',
    [5] = 'Fire',
    [6] = 'Water',
    [7] = 'Water',
    [8] = 'Earth',
    [9] = 'Earth',
    [10] = 'Wind',
    [11] = 'Wind',
    [12] = 'Ice',
    [13] = 'Ice',
    [14] = 'Thunder',
    [15] = 'Thunder',
    [16] = 'Light',
    [17] = 'Light',
    [18] = 'Dark',
    [19] = 'Dark',
};

ashita.events.register('load', 'load_cb', function()
    vars.pointer = ashita.memory.read_uint32(ashita.memory.find('FFXiMain.dll', 0, '66A1????????663D????72', 0, 0) + 0x02);
end);

ashita.events.register('unload', 'unload_cb', function()

end);

ashita.events.register('command', 'command_cb', function (e)
	local args = e.command:args();
    if (#args == 0) or ((args[1] ~= '/weatherhelper') and (args[1] ~= '/wh')) then
        return;
    end

    e.blocked = true;

    if #args == 2 then
        vars.check = args[2];
        Validate(vars.check);
    elseif #args > 3 or args[2] == 'help' then
        print(chat.header(addon.name) .. chat.message('Not a valid input'));
        print(chat.header(addon.name) .. chat.message('Only valid inputs are: /wh [Fire|Water|Earth|Wind|Ice|Thunder|Light|Dark]'));
    end
end);

ashita.events.register('d3d_present', 'present_cb', function ()
    local player = AshitaCore:GetMemoryManager():GetPlayer();

    -- Force reset if zoned
    if (player:GetIsZoning() ~= 0) then
        vars.old,vars.new = 0;
        vars.valid = false;
        return;
    end

    -- Dont do anything if a weather hasnt been set/validated since last reset
    if not vars.valid then
        return;
    end

    local t = os.clock() - vars.base;
    if t > 5 then
        vars.new = GetWeather();
    end
    if vars.old ~= vars.new then
        if weathers[vars.new] ~= nil and (string.lower(weathers[vars.new]) == vars.check) then
            AshitaCore:GetChatManager():QueueCommand(1, '/p <call' .. vars.good_call .. '>');
        elseif weathers[vars.old] ~= nil and string.lower(weathers[vars.old]) == vars.check then
            AshitaCore:GetChatManager():QueueCommand(1, '/p <call' .. vars.bad_call .. '>');
        end
        vars.old = vars.new;
    end
end);

function GetWeather()
    vars.base = os.clock();
    return ashita.memory.read_uint8(vars.pointer);
end

function Validate(w)
    w = string.lower(w);

    for k,v in pairs(weathers) do
        if w == string.lower(v) then
            print(chat.header(addon.name) .. chat.message('Checking for: ' .. v .. ' Weather.'));
            vars.valid = true;
            vars.old = GetWeather();
            if weathers[vars.old] ~= nil and (string.lower(weathers[vars.old]) == vars.check) then
                AshitaCore:GetChatManager():QueueCommand(1, '/p <call' .. vars.good_call .. '>');
                vars.new = vars.old;
            end
            return;
        end
    end
    print(chat.header(addon.name) .. chat.message('Not a valid input'));
    print(chat.header(addon.name) .. chat.message('Only valid inputs are: /wh [Fire|Water|Earth|Wind|Ice|Thunder|Light|Dark]'));
end