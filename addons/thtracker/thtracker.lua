addon.name      = 'thtracker';
addon.author    = 'GetAwayCoxn';
addon.version   = '1.0';
addon.desc      = 'Tracks TH on mobs, this is not a port';
addon.link      = 'https://github.com/GetAwayCoxn/';

require('common');
local fonts = require('fonts');
local settings = require('settings');

local display = T{};
local osd = T{};
local mobs = T{};-- [id] = {name,HPP,THcount}
local defaults = T{
	visible = true,
    displayTime = 15,
    deadColor = '|cFFFF0000|';
    fightColor = '|cFFFFFF00|';
	font_family = 'Arial',
	font_height = 12,
	color = 0xFFFFFFFF,
	position_x = 500,
	position_y = 500,
	background = T{
		visible = true,
		color = 0xFF000000,
	}
};

settings.register('settings', 'settings_update', function (s)
    if (s ~= nil) then
        osd = s;
    end
    settings.save();
end);

ashita.events.register('load', 'load_cb', function()
	osd = settings.load(defaults);
    
    display = fonts.new(osd);
end);

ashita.events.register('unload', 'unload_cb', function()
	settings.save();

    if (display ~= nil) then
		display:destroy();
	end
end);

ashita.events.register('text_in', 'text_in_cb', function(e)
    local me = AshitaCore:GetMemoryManager():GetParty():GetMemberName(0);
    local player = AshitaCore:GetMemoryManager():GetPlayer();

    if e.message:contains('Treasure Hunter') or e.message:contains('AE: TH') then
        local index = AshitaCore:GetMemoryManager():GetTarget():GetTargetIndex(0);
        if index == nil then return end;
	    local target = GetEntity(index);
        if AshitaCore:GetMemoryManager():GetEntity():GetType(index) ~= 2 then return end;
        local count = tonumber(string.match(e.message,'%d+'));
        mobs[index] = {target.Name, target.HPPercent, count, true, os.time()};
    elseif (e.message:contains('hit') or e.message:contains('ranged attack') or e.message:contains('RA')) and e.message:contains(me) then
        local index = AshitaCore:GetMemoryManager():GetTarget():GetTargetIndex(0);
        if index == nil then return end;
	    local target = GetEntity(index);
        if AshitaCore:GetMemoryManager():GetEntity():GetType(index) ~= 2 then return end;
        if mobs[index] ~= nil and mobs[index][3] >=9 then return end;--kick out if already at TH9 or above
        local count = 0;
        if player:GetMainJob(0) == 6 then--need to add a offset for gear bonus then adjust the for checks below,for now assumes max TH gear if THF main @99, and no TH gear otherwise
            if player:GetMainJobLevel(0) >= 90 then
                count = 8;
            else
                count = 4;
            end
        else
            count = 4;
        end
        if target == nil then return end;
        if mobs[index] ~= nil then 
            if count > mobs[index][3] then
                mobs[index] = {target.Name, target.HPPercent, count, true, os.time()};
            end
        else
            mobs[index] = {target.Name, target.HPPercent, count, true, os.time()};
        end
    end
end);

ashita.events.register('d3d_present', 'present_cb', function ()
    local player = AshitaCore:GetMemoryManager():GetPlayer();
	if (player:GetIsZoning() ~= 0) then
        mobs = T{};
		return;
	end

    local t = 0;
    display.text = '';

    if not osd.visible then
        return;
    end

    for k,v in pairs(mobs) do
        
        t = t + 1;
        
        if t == 1 then
            display.text = 'THtracker Tracking Mobs: ';
        end
        
        local mob = GetEntity(k);

        if v[2] == 0 then
            display.text = display.text .. osd.deadColor .. '\n' .. v[1] .. '(' .. tostring(k) .. ')  HPP: ' .. tostring(v[2]) .. '  TH: ' .. tostring(v[3]);
        else
            display.text = display.text .. osd.fightColor .. '\n' .. v[1] .. '(' .. tostring(k) .. ')  HPP: ' .. tostring(v[2]) .. '  TH: ' .. tostring(v[3]);
        end
        
    end

	if display.position_x ~= osd.position_x or display.position_y ~= osd.position_y then--force settings save when dragging the text box
        osd.position_x = display.position_x;
        osd.position_y = display.position_y;
        settings.save();
    end

    update();
end);

ashita.events.register('command', 'command_cb', function (e)
    local args = e.command:args();
    
    if args[1] ~= '/thtracker' and args[1] ~= '/tht' then
        return;
    end

    e.blocked = true;

    if #args == 1 then
        osd.visible = not osd.visible;
    elseif args[2] == 'time' then
        osd.displayTime = tonumber(args[3]) or defaults.displayTime;
    end
end);

function update()
    for k,v in pairs(mobs) do
        v[2] = AshitaCore:GetMemoryManager():GetEntity():GetHPPercent(k) or 0;
        
        if tonumber(('%2i'):fmt(math.sqrt(AshitaCore:GetMemoryManager():GetEntity():GetDistance(k)))) > 50 then v[2] = 0 end;
        
        for m = 0, 17 do
            if AshitaCore:GetMemoryManager():GetParty():GetMemberName(m) == v[1] then
                mobs[k] = nil
            end
        end

        if v[2] == 0 and v[4] then 
            v[4] = not v[4]
            v[5] = os.time();
        end

        if os.time() - v[5] > osd.displayTime and v[2] == 0 then mobs[k] = nil end;
    end
end