addon.name      = 'luopantime';
addon.author    = 'GetAwayCoxn';
addon.version   = '1.0';
addon.desc      = 'Light weight count down timer for Luopans';
addon.link      = 'https://github.com/GetAwayCoxn/Ashita-v4-Addons';

require('common');
local fonts = require('fonts');
local settings = require('settings');

local display = {};
local osd = {};
local newpet = true;
local casttime = nil;
local defaults = T{
	visible = true,
	font_family = 'Arial',
	font_height = 14,
	color = 0xFFFFFFFF,
	position_x = 500,
	position_y = 500,
	background = T{
		visible = true,
		color = 0xFF000000,
	}
};

ashita.events.register('load', 'load_cb', function()
    osd.settings = settings.load(defaults);
    
    display = fonts.new(osd.settings);
end);

ashita.events.register('unload', 'unload_cb', function()
    settings.save();

    if (display ~= nil) then
		display:destroy();
	end
end);

ashita.events.register('d3d_present', 'present_cb', function ()
    local player = AshitaCore:GetMemoryManager():GetPlayer();
    local petID = AshitaCore:GetMemoryManager():GetEntity():GetPetTargetIndex(AshitaCore:GetMemoryManager():GetParty():GetMemberTargetIndex(0));
    local output = 'Luopan Time: ';
    local petHP = 0;

    if player:GetMainJob() ~= 21 then return end;

    if (petID == 0 or petID == nil) then
        display.visible = false;
    else
        display.visible = true;
        petHP = AshitaCore:GetMemoryManager():GetEntity():GetHPPercent(petID);
    end

    if petHP <= 0 and newpet == false then
        newpet = true;
    end
    if petHP >= 0 and newpet == true then
        newpet = false;
        casttime = os.clock();
        display.color = 0xFFFFFFFF;
    end

    if casttime ~= nil then
        output = output .. '  ' .. remaining(casttime);
    end

    display.text = output;

    if display.position_x ~= osd.settings.position_x or display.position_y ~= osd.settings.position_y then
        osd.settings.position_x = display.position_x;
        osd.settings.position_y = display.position_y;
        settings.save();
    end
end);

function remaining(casttime)
    local t = os.clock() - casttime;
    local m = string.format("%02i", (600 - t)/60);
    local s = string.format("%02i", (600-(60*m)) - t);
    local str = m .. ':' .. s;
    if m == '00' and s == '45' then
        display.color = 0xFFFFFF00;
    elseif m == '00' and s == '15' then
        display.color = 0xFFFF0000;
    end
    return str;
end