addon.name      = 'thtracker';
addon.author    = 'GetAwayCoxn';
addon.version   = '1.05';
addon.desc      = 'Tracks TH on multiple mobs, this is not a port';
addon.link      = 'https://github.com/GetAwayCoxn/';

require('common');
local fonts = require('fonts');
local settings = require('settings');
local display = T{};
local osd = T{};
local mobs = T{};-- [id] = {name,HPP,THcount}
local defaults = T{
	visibleJob = T{[1] = true,[2] = true,[3] = true,[4] = true,[5] = true,[6] = true,[7] = true,[8] = true,[9] = true,[10] = true,[11] = true,[12] = true,[13] = true,[14] = true,[15] = true,[16] = true,[17] = true,[18] = true,[19] = true,[20] = true,[21] = true,[22] = true,},
    visible = true,
    displayTime = 15,
    color = 0xFFFFFFFF,
    mobcolor = '|cFFFFFFFF|',
	green = '|cFF00FF00|';
    red = '|cFFFF0000|',
    yellow = '|cFFFFFF00|',
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
local Towns = T{'Tavnazian Safehold','Al Zahbi','Aht Urhgan Whitegate','Nashmau','Southern San d\'Oria [S]','Bastok Markets [S]','Windurst Waters [S]','San d\'Oria-Jeuno Airship','Bastok-Jeuno Airship','Windurst-Jeuno Airship','Kazham-Jeuno Airship','Southern San d\'Oria','Northern San d\'Oria','Port San d\'Oria','Chateau d\'Oraguille','Bastok Mines','Bastok Markets','Port Bastok','Metalworks','Windurst Waters','Windurst Walls','Port Windurst','Windurst Woods','Heavens Tower','Ru\'Lude Gardens','Upper Jeuno','Lower Jeuno','Port Jeuno','Rabao','Selbina','Mhaura','Kazham','Norg','Mog Garden','Celennia Memorial Library','Western Adoulin','Eastern Adoulin'};
local area = '';
local gear = T{--keys are slot id's from enums, then itemId:THvalue
    [0] = T{--copy to [1] for sub slot
        [16480] = 1,
        [20618] = 1,
        [21573] = 1,
        [21574] = 2,
        [21575] = 3,
    },
    [1] = T{
        [16480] = 1,
        [20618] = 1,
        [21573] = 1,
        [21574] = 2,
        [21575] = 3,
    },
    [2] = T{},
    [3] = T{
        [22299] = 1,
    },
    [4] = T{
        [23713] = 1,
        [25679] = 1,
    },
    [5] = T{
        [23717] = 2,
    },
    [6] = T{
        [15107] = 1,
        [14914] = 1,
        [10695] = 2,
        [26986] = 2,
        [26987] = 3,
        [23202] = 3,
        [23537] = 4,
    },
    [7] = T{
        [23725] = 1,
    },
    [8] = T{
        [23729] = 1,
        [11149] = 1,
        [27421] = 2,
        [27422] = 3,
        [23358] = 4,
        [23693] = 5,
    },
    [9] = T{},
    [10] = T{
        [28450] = 1,
    },
    [11] = T{},
    [12] = T{},
    [13] = T{--copy to [14] for second ring slot
        [27585] = 1,
        [26197] = 1,
    },
    [14] = T{
        [27585] = 1,
        [26197] = 1,
    },
    [15] = T{},
};
local oseemgear = T{'Chironic','Herculean','Merlinic','Odyssean','Valorous'};

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
    area = AshitaCore:GetResourceManager():GetString("zones.names", AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0));
    if (player:GetIsZoning() ~= 0) or (area == nil) or (Towns:contains(area)) then
        mobs = T{};
		return;
	end
    if e.message:contains('Treasure Hunter') or e.message:contains('AE: TH') then
        local index = AshitaCore:GetMemoryManager():GetTarget():GetTargetIndex(0);
        if index == nil then return end;
	    local target = GetEntity(index);
        if AshitaCore:GetMemoryManager():GetEntity():GetType(index) ~= 2 then return end;
        local count = tonumber(string.match(e.message,'%d+'));
        mobs[index] = {target.Name, target.HPPercent, count, true, os.time()};
        display.mobcolor = display.yellow;
    elseif e.message:contains(me .. ' hits') or e.message:contains(me .. ' scores a critical') or (e.message:contains('[' .. me .. ']') and e.message:contains('hit')) or e.message:contains(me .. '\'s ranged attack') or (e.message:contains('[' .. me .. ']') and e.message:contains('RA')) then
        local index = AshitaCore:GetMemoryManager():GetTarget():GetTargetIndex(0);
        if index == nil then return end;
	    local target = GetEntity(index);
        if AshitaCore:GetMemoryManager():GetEntity():GetType(index) ~= 2 then return end;
        if mobs[index] ~= nil and mobs[index][3] >=9 then return end;--kick out if already at TH9 or above
        local count = 0;

        if player:GetMainJob(0) == 6 then
            if player:GetMainJobLevel(0) >= 90 then
                count = 3;
            elseif player:GetMainJobLevel(0) >= 45 then
                count = 2;
            elseif player:GetMainJobLevel(0) >= 15 then
                count = 1;
            end
        elseif player:GetSubJob(0) == 6 then
            if player:GetSubJobLevel(0) >= 45 then
                count = 2;
            elseif player:GetSubJobLevel(0) >= 15 then
                count = 1;
            end
        end
        
        count = count + countGear(player);
        if not count or count == 0 then return; end

        if target == nil then return end;
        if mobs[index] ~= nil then 
            if count > mobs[index][3] then
                display.mobcolor = display.yellow;
                mobs[index] = {target.Name, target.HPPercent, count, true, os.time()};
            end
        else
            display.mobcolor = display.yellow;
            mobs[index] = {target.Name, target.HPPercent, count, true, os.time()};
        end
    end
end);

ashita.events.register('d3d_present', 'present_cb', function ()
    local player = AshitaCore:GetMemoryManager():GetPlayer();
    local t = 0;
    display.text = '';
    area = AshitaCore:GetResourceManager():GetString("zones.names", AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0));

	if (player:GetIsZoning() ~= 0) or (area == nil) or (Towns:contains(area)) then
        mobs = T{};
		return;
	end

    if not osd.visibleJob[player:GetMainJob(0)] then
        return;
    end

    for k,v in pairs(mobs) do
        t = t + 1;
        
        if t == 1 then
            display.text = 'THtracker Tracking Mobs: ';
        end
        
        local mob = GetEntity(k);
        if v[2] == 0 then
            display.text = display.text .. display.red .. '\n' .. v[1] .. '(' .. tostring(k) .. ')  HPP: ' .. tostring(v[2]) .. '  TH: ' .. tostring(v[3]);
        else
            display.text = display.text .. display.mobcolor .. '\n' .. v[1] .. '(' .. tostring(k) .. ')  HPP: ' .. tostring(v[2]) .. '  TH: ' .. tostring(v[3]);
        end
    end

	if display.position_x ~= osd.position_x or display.position_y ~= osd.position_y then--force settings save when simply dragging the text box
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
        local playerJob = AshitaCore:GetMemoryManager():GetPlayer():GetMainJob(0);
        osd.visibleJob[playerJob] = not osd.visibleJob[playerJob];
    elseif args[2] == 'time' then
        osd.displayTime = tonumber(args[3]) or defaults.displayTime;
    elseif args[2] == 'test' then
        test();
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

function countGear(player)
    local inv = AshitaCore:GetMemoryManager():GetInventory();
    local total = 0;

    for slot = 0, 15 do
        local equippedItem = inv:GetEquippedItem(slot);
        local index = bit.band(equippedItem.Index, 0x00FF);
        local eqEntry = {};
        if (index ~= 0) then
            eqEntry.Container = bit.band(equippedItem.Index, 0xFF00) / 256;
            eqEntry.Item = inv:GetContainerItem(eqEntry.Container, index);
            if (eqEntry.Item.Id ~= 0) and (eqEntry.Item.Count ~= 0) then
                if gear[slot]:haskey(eqEntry.Item.Id) then
                    total = total + gear[slot][eqEntry.Item.Id]
                elseif (slot >= 4 and slot <= 8) then
                    local itm = AshitaCore:GetResourceManager():GetItemById(eqEntry.Item.Id);
                    if oseemgear:contains(itm.Name[1]:match("%w+")) then
                        total = total + checkAugment(eqEntry.Item);
                    end
                end
            end
        end
    end

    if player:GetMainJob(0) == 6 then
        if total > 5 then
            total = 5;
        end
    elseif player:GetSubJob(0) == 6 then
        if total > 4 then
            total = 4;
        end
    end

    return total;
end

function checkAugment(item)
    local augType = struct.unpack('B', item.Extra, 1);

    --kick out if gear not aug'd at all
    if (augType ~= 2) and (augType ~= 3) then 
        return 0;
    end

    local itemTable = item.Extra:totable();
    for i = 1,5,1 do
        local augId = ashita.bits.unpack_be(itemTable, (16 * i), 11);
        local augValue = ashita.bits.unpack_be(itemTable, (16 * i) + 11, 5);
        if augId == 147 then --ID for TH augs
            return augValue + 1; --offest for TH augs is 1
        end
    end

    return 0;
end