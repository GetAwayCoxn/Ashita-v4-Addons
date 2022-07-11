addon.name      = 'wstracker';
addon.author    = 'GetAwayCoxn';
addon.version   = '1.0';
addon.desc      = 'Tracks WS breaking, only  mythic/ergon for now.';
addon.link      = 'https://github.com/GetAwayCoxn/';

local fonts = require('fonts');

local fontdefaults = {
	visible = true,
	font_family = 'Arial',
	font_height = 12,
	color = 0xFFFFFFFF,
	position_x = 600,
	position_y = 600,
	background = {
		visible = true,
		color = 0xFF000000,
	}
};
local display = {};
local data = {
    ['Sturdy Axe'] = 'King\'s Justice',
    ['Burning Fists'] = 'Ascetic\'s Fury',
    ['Werebuster'] = 'Mystic Boon',
    ['Mage\'s Staff'] = 'Vidohunir',
    ['Vorpal Sword'] = 'Death Blossom',
    ['Swordbreaker'] = 'Mandalic Stab',
    ['Brave Blade'] = 'Atonement',
    ['Death Sickle'] = 'Insurgency',
    ['Double Axe'] = 'Primal Rend',
    ['Dancing Dagger'] = 'Mordant Rime',
    ['Killer Bow'] = 'Trueflight',
    ['Windslicer'] = 'Tachi: Rana',
    ['Sasuke Katana'] = 'Blade: Kamu',
    ['Radiant Lance'] = 'Drakesbane',
    ['Scepter Staff'] = 'Garland of Bliss',
    ['Wightslayer'] = 'Expiacion',
    ['Quicksilver'] = 'Leaden Salute',
    ['Inferno Claws'] = 'Stringing Pummel',
    ['Main Gauche'] = 'Pyrrhic Kleos',
    ['Elder Staff'] = 'Omniscience',
    ['Trial Wand'] = 'Exudation',
    ['Trial Blade'] = 'Dimidiation',
};

ashita.events.register('load', 'load_cb', function()
	display = fonts.new(fontdefaults);
end );

ashita.events.register('unload', 'unload_cb', function()
    if (display ~= nil) then
		display:destroy();
	end
end );

ashita.events.register('d3d_present', 'present_cb', function ()
    local player = AshitaCore:GetMemoryManager():GetPlayer();
    local main = get_equipped_item(0);
    local range = get_equipped_item(2);
    local check = false;
    local name = {};


    for k,v in pairs(data) do
        if range ~= nil and range.Name[1] == k then
            name = AshitaCore:GetResourceManager():GetAbilityByName(v, 0);
            if player:HasWeaponSkill(name.Id) then
                check = true;
            end
            display.text = ' WS: ' .. name.Name[1] .. '   Check: ' .. tostring(check);
            return;
        elseif main ~= nil and main.Name[1] == k then
            name = AshitaCore:GetResourceManager():GetAbilityByName(v, 0);
            if player:HasWeaponSkill(name.Id) then
                check = true;
            end
            display.text = ' WS: ' .. name.Name[1] .. '   Check: ' .. tostring(check);
            return;
        end
    end

	display.text = '';
end);

function get_equipped_item(slot)--modified function from atom0s's equipmon Ashita v4 addon
    local inv = AshitaCore:GetMemoryManager():GetInventory();

    local eitem = inv:GetEquippedItem(slot);
    if (eitem == nil or eitem.Index == 0) then
        return nil;
    end

    local iitem = inv:GetContainerItem(bit.band(eitem.Index, 0xFF00) / 0x0100, eitem.Index % 0x0100);
    if(iitem == nil or T{ nil, 0, -1, 65535 }:hasval(iitem.Id)) then return nil; end

    local str = AshitaCore:GetResourceManager():GetItemById(iitem.Id);
    return str;
end