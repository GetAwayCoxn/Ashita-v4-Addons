addon.name      = 'auctioneer';
addon.author    = 'Ivaar, ported to Ashita v4 by GetAwayCoxn';
addon.version   = '1.0';
addon.desc      = 'auctioneer';
addon.link      = 'https://github.com/GetAwayCoxn/Ashita-v4-Addons';

require('common');
local settings = require('settings');
local fonts = require('fonts');
local chat = require('chat');

local zones = T{'Bastok Mines', 'Bastok Markets', 'Norg', 'Southern San d\'Oria', 'Port San d\'Oria', 'Raboa', 'Windurst Woods', 'Windurst Walls', 'Kazham', 'Lower Jeuno', 'Ru\'Lude Gardens', 'Port Jeuno', 'Upper Jeuno', 'Aht Urhgan Whitegate', 'Al Zahbi', 'Nashmau', 'Tavnazian Safehold', 'Western Adoulin', 'Eastern Adoulin'};
local display = {};
local osd = {};
local defaults = T{
	visible = true,
	font_family = 'Futura',
	font_height = 12,
	color = 0xFFFFFFFF,
	position_x = 700,
	position_y = 700,
	background = T{
		visible = true,
		color = 0xFF000000,
	},
    auction_list = {
        visibility=true,
        timer=true,
        date=true,
        price=true,
        empty=false,
        slot=true,
    },
};

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

ashita.events.register('packet_in', 'packet_in_callback1', function (e)
    if (e.id == 0x04C) then
        local pType = e.data:byte(5);
        if (pType == 0x04) then
            local slot = find_empty_slot()
            local fee = struct.unpack('i', e.data, 9)
            if (last4E ~= nil and e.data:byte(7) == 0x01 and slot ~= nil and last4E ~= nil and last4E:byte(5) == 0x04 and e.data:sub(13,17) == last4E:sub(13,17) and AshitaCore:GetMemoryManager():GetInventory():GetContainerItem(0, 0).Count >= fee) then				
                local sell_confirm = struct.pack("bbxxbbxxbbbbbbxxbi32i11", 0x4E,0x1E,0x0B,slot,last4E:byte(9),last4E:byte(10),last4E:byte(11),last4E:byte(12),e.data:byte(13),e.data:byte(14),last4E:byte(17),0x00,0x00):totable();
                last4E = nil
                local send = function()
                    --print(string.format('modified %s  size [%d]',table.tostring(sell_confirm ,'%.2X ')));
                    AshitaCore:GetPacketManager():AddOutgoingPacket(0x4E, sell_confirm);
                end;
                send:once(math.random());
            end
        elseif (pType == 0x0A) then
            if (e.data:byte(7) == 0x01) then
                if (auction_box == nil) then auction_box = {}; end
                if (auction_box[e.data:byte(6)] == nil) then auction_box[e.data:byte(6)] = {}; end
                update_sales_status(e.data);
            end
        elseif (pType == 0x0B or pType == 0x0C or pType == 0x0D or pType == 0x10) then
            if (e.data:byte(7) == 0x01) then
                update_sales_status(e.data);
            end
        elseif (pType == 0x0E) then
            if (e.data:byte(7) == 0x01) then
                print(chat.header(addon.name) .. chat.message('Bid Success'));
            elseif (e.data:byte(7) == 0xC5) then
                print(chat.header(addon.name) .. chat.message('Bid Failed'));
            end
        end
    elseif (e.id == 0x00B) then
        if (e.data:byte(5) == 0x01) then
            auction_box = nil;
        end
    end
end);

ashita.events.register('d3d_present', 'present_cb', function ()
    local player = AshitaCore:GetMemoryManager():GetPlayer();
    if player:GetIsZoning() ~= 0 then 
        display.text = '';
        return;
    end

    if (auction_box ~= nil and display.auction_list.visibility == true) then
        display.text = display_box();
        display.auction_list.visibility = true;
    else
        display.auction_list.visibility = false;
    end

    if display.position_x ~= osd.position_x or display.position_y ~= osd.position_y then
        osd.position_x = display.position_x;
        osd.position_y = display.position_y;
        settings.save();
    end
end);

ashita.events.register('command', 'command_cb', function (e)
	local args = e.command:args();
    if (#args < 1) or ((args[1] ~= '/auctioneer') and (args[1] ~= '/ah')) then
        return;
    end

    e.blocked = true;

    local zone = AshitaCore:GetResourceManager():GetString('zones.names', AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0));
    local now = os.clock();
    local lclock = nil;

    if (zones:contains(zone) and (lclock == nil or lclock < now)) then
        if args[2] == 'bid' then args[2] = 'buy' end;--lazy fix to add bid for now
        if (args[2] == 'sell' or args[2] == 'buy') then
            if (#args < 5) then return end
            if ah_proposal(string.lower(args[2]),args[3]--[[table.concat(args,' ',3,#args-2)]],args[#args-1],args[#args]) == true then lclock = now+3; end
        elseif (args[2] == 'outbox' or args[2] == 'obox') then
            local obox = struct.pack("bbxxbbbbbbbbbbbbbbbb", 0x4B,0x0A,0x0D,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x01,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF):totable();
            --print(string.format('modified %s  size [%d]',table.tostring(obox, '%.2X '),#obox));
            AshitaCore:GetPacketManager():AddIncomingPacket(0x4B, obox);
        elseif (args[2] == 'inbox' or args[2] == 'ibox') then
            local ibox = struct.pack("bbxxbbbbbbbbbbbbbbbb", 0x4B,0x0A,0x0E,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x01,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF):totable();
            --print(string.format('modified %s  size [%d]',table.tostring(ibox, '%.2X '),#ibox));
            AshitaCore:GetPacketManager():AddIncomingPacket(0x4B, ibox);
        elseif (#args == 1 or string.lower(args[2]) == 'menu') then
            lclock = now+3;
            AshitaCore:GetPacketManager():AddIncomingPacket(0x4C, struct.pack("bbbbbbbi32i21", 0x4C,0x1E,0x00,0x00,0x02,0x00,0x01,0x00,0x00):totable());
            local s = function()
                display.auction_list.visibility = true;
                display.visible = true;
            end
            s:once(2);
        elseif (args[2] == 'clear') then
            lclock = now+3; 
            clear_sales();
        end
    end
    
    if (args[2] == 'show') then
        if (#args == 2) then
            display.auction_list.visibility = true;
            display.visible = true;
        elseif display.auction_list[string.lower(args[3])] ~= nil then
            display.auction_list[string.lower(args[3])] = true
        end
    elseif (args[2] == 'hide') then
        if (#args == 2) then
            display.visible = false;
        elseif display.auction_list[string.lower(args[3])] ~= nil then
            display.auction_list[string.lower(args[3])] = false
        end
    elseif (args[2] == 'reset') then
        if (display ~= nil) then
		    display:destroy();
	    end
        settings.reset();
        osd = settings.load(defaults);
        display = fonts.new(osd);
    elseif (args[2] == 'test') then
        test();
    end
end);

function table.find(t, val)
    for k, v in pairs(t) do
        if (v == val) then return k; end
    end
    return nil;
end;

function table.tostring(t, form)
    str = '';
    for x = 1,#t do
        str = str..string.format(form,t[x]);
    end
    return str;
end;

function has_flag(n, flag)
    return bit.band(n, flag) == flag;
end;

function item_name(id)
    return AshitaCore:GetResourceManager():GetItemById(tonumber(id)).Name[1];
end;

function timef(ts)
    --return string.format('%.2d:%.2d:%.2d',ts/(60*60), ts/60%60, ts%60);
    return string.format('%d days %.2d:%.2d:%.2d',ts/(60*60*24), ts/(60*60)%24, ts/60%60, ts%60);
end;

function display_box()
    local outstr = '';
    for x = 0,6 do
        if (auction_box[x] ~= nil) then
            local str = '';
            if (display.auction_list.empty == true or auction_box[x].status ~= 'Empty') then
                if (display.auction_list.slot) == true then
                    str = str..string.format(' Slot# %s: ', x+1);
                end
                str = str..string.format('*** %s ***',auction_box[x].status);
            end
            if (auction_box[x].status ~= 'Empty') then
                local timer = auction_box[x].status == 'On auction' and auction_box[x].timestamp+829440 or auction_box[x].timestamp;
                if (display.auction_list.timer) then
                    str = str..string.format(' %s',(auction_box[x].status == 'On auction' and os.time()-timer > 0) and 'Expired' or timef(math.abs(os.time()-timer)));
                end
                if (display.auction_list.date) then
                    str = str..string.format(' [%s]',os.date('%c', timer));
                end
                str = str..string.format(' %s ',auction_box[x].item);
                if (auction_box[x].count ~= 1) then
                    str = str..string.format('x%d ',auction_box[x].count);
                end
                if (display.auction_list.price) then
                    str = str..string.format('[%s] ',comma_value(auction_box[x].price));
                end
            end
            if (str ~= '') then 
                outstr = outstr ~= '' and outstr .. '\n' .. str or str;
            end
        end
    end
    return outstr;
end;

function update_sales_status(packet)
    local slot = packet:byte(0x05+1);
    local status = packet:byte(0x14+1);
    if (auction_box ~= nil and slot ~= 7 and status ~= 0x02 and status ~= 0x04 and status ~= 0x10) then
        if (status == 0x00) then
            auction_box[slot] = {};
            auction_box[slot].status = 'Empty';
        else
            if (status == 0x03) then
                auction_box[slot].status = 'On auction';
            elseif (status == 0x0A or status == 0x0C or status == 0x15) then
                auction_box[slot].status = 'Sold';
            elseif (status == 0x0B or status == 0x0D or status == 0x16) then
                auction_box[slot].status = 'Not Sold';
            end
            auction_box[slot].item = item_name(struct.unpack('h', packet, 0x28+1));
            auction_box[slot].count = packet:byte(0x2A+1);
            auction_box[slot].price = struct.unpack('i', packet, 0x2C+1);
            auction_box[slot].timestamp = struct.unpack('i', packet, 0x38+1);
        end
    end
end;

function find_empty_slot()
    if (auction_box ~= nil) then
        for slot = 0,6 do
            if (auction_box[slot] ~= nil and auction_box[slot].status == 'Empty') then
                return slot;
            end
        end
    end
    return nil;
end;

function comma_value(n) -- credit http://richard.warburton.it
    local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$');
    return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right;
end;

function find_item(item_id, item_count)
    local items = AshitaCore:GetMemoryManager():GetInventory();
    for ind = 1,items:GetContainerCountMax(0) do
        local item = items:GetContainerItem(0, ind);
        if (item ~= nil and item.Id == item_id and item.Flags == 0 and item.Count >= item_count) then
            return item.Index;
        end
    end
    return nil;
end;

function clear_sales()
    if (auction_box == nil) then return end;
    for slot=0,6 do
        if (auction_box[slot] ~= nil) and (auction_box[slot].status == 'Sold' or auction_box[slot].status == 'Not Sold') then
            local isold = struct.pack("bbxxbbi32i22", 0x4E,0x1E,0x10,slot,0x00,0x00):totable();
            --print(string.format('modified %s  size [%d]',table.tostring(isold, '%.2X '),#isold));
            AshitaCore:GetPacketManager():AddOutgoingPacket(0x4E, isold);
        end
    end
end;

function ah_proposal(bid, name, vol, price)
    name = AshitaCore:GetChatManager():ParseAutoTranslate(name, false);
    local item = AshitaCore:GetResourceManager():GetItemByName(name, 2);
    if (item == nil) then
        print(chat.header(addon.name) .. chat.message(string.format('"%s" not a valid item name',name)));
        return false; 
    end

    if (has_flag(item.Flags, 0x0040) == true) then
        print(chat.header(addon.name) .. chat.message(string.format('%s is not purchasable via the auction house',item.Name[1])));
        return false;
    end

    local single;
    if (item.StackSize ~= 1) and (vol == '1' or vol == 'stack') then
        single = 0;
    elseif (vol == '0' or vol == 'single') then
        single = 1;
    else
        print(chat.header(addon.name) .. chat.message('Specify single or stack'));
        return false;
    end
    
    price = price:gsub('%p', '');
    if (price == nil) or
      (string.match(price,'%a') ~= nil) or
      (tonumber(price) == nil) or
      (tonumber(price) < 1) or
      (bid == 'sell' and tonumber(price) > 999999999) or
      (bid == 'buy' and tonumber(price) > AshitaCore:GetMemoryManager():GetInventory():GetContainerItem(0,0).Count) then
        print(chat.header(addon.name) .. chat.message('Invalid price'));
        return false;
    end
    price = tonumber(price);

    local trans;
    if (bid == 'buy') then
        local slot = find_empty_slot() == nil and 0x07 or find_empty_slot();
        trans = struct.pack("bbxxihxx", 0x0E, slot, price, item.Id);
        print(chat.header(addon.name) .. chat.message(string.format('%s "%s" %s %s ID:%s',bid, item.Name[1], comma_value(price),single == 1 and '[Single]' or '[Stack]',item.Id)));
    elseif (bid == 'sell') then
        if (auction_box == nil) then
            print(chat.header(addon.name) .. chat.message('Click auction counter or use /ah to initialize sales'));
            return false;
        end
        if (find_empty_slot() == nil) then
            print(chat.header(addon.name) .. chat.message('No empty slots available'));
            return false;
        end
        local index = find_item(item.Id, single == 1 and single or item.StackSize);
        if (index == nil) then
            print(chat.header(addon.name) .. chat.message(string.format('%s of %s not found in inventory.',single == 1 and 'Single' or 'Stack',item.Name[1])));
            return false;
        end
        trans = struct.pack("bxxxihh", 0x04, price, index, item.Id);
        print(chat.header(addon.name) .. chat.message(string.format('%s "%s" %s %s ID:%d Ind:%d',bid, item.Name[1], comma_value(price),single == 1 and '[Single]' or '[Stack]',item.Id,index)));
    else return false; end
    trans = struct.pack("bbxx", 0x4E, 0x1E) .. trans .. struct.pack("bi32i11", single, 0x00, 0x00);
    if (bid == 'sell') then
        last4E = trans
    end
    trans = trans:totable()
    --print(string.format('modified %s  size [%d]',table.tostring(trans, '%.2X '),#trans));
    AshitaCore:GetPacketManager():AddOutgoingPacket(0x4E, trans);
    return true;
end;

function test()
end;