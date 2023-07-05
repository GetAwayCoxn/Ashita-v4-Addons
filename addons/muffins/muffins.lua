addon.name      = 'muffins'
addon.author    = 'GetAwayCoxn'
addon.version   = '1.00'
addon.desc      = 'quick display of how many gallimaufry you are getting in sortie'
addon.link      = 'https://github.com/GetAwayCoxn/Ashita-v4-Addons'

require('common')
local fonts = require('fonts')

local totalMuffs = "0"
local currentMuffs = 0
local newrun = true
local display = nil
local defaults = {
	visible = false,
	font_family = 'Arial',
	font_height = 12,
	color = 0xFFFFFFFF,
	position_x = 750,
	position_y = 100,
	background = {
		visible = true,
		color = 0xFF000000,
	}
}

ashita.events.register('load', 'load_cb', function()
    display = fonts.new(defaults)
end)

ashita.events.register('unload', 'unload_cb', function()
    if display then display:destroy() end
end)

ashita.events.register('d3d_present', 'present_cb', function()
    local area = AshitaCore:GetResourceManager():GetString("zones.names", AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0))
    display.text = "Total Gallimaufry: " .. totalMuffs .. "  Earned this run: " .. tostring(currentMuffs)
    if not newrun then
        display.visible = true
        if not string.match(area,"Outer Ra'Kaznar ") then
            display.text = display.text .. "\nclose this window with /muffs reset"
        end
    end
end)

ashita.events.register('command', 'command_cb', function (e)
	local args = e.command:args()
    if (#args == 0) or ((args[1] ~= '/muffins') and (args[1] ~= '/muffs')) then
        return
    end

    e.blocked = true

    if args[2]:any('reset') then
        newrun = true
        display.visible = false
        currentMuffs = 0
    end
end)

ashita.events.register('text_in', 'text_in_callback1', function (e)
    if (not e.blocked and not e.injected) then
        if e.message:contains("received") and e.message:contains("gallimaufry") then
            local words = e.message:args()
            local offset = 0
            if words[3] == "received" then offset = 1 end
            if newrun then newrun = false end
            totalMuffs = string.sub(words[9+offset],1,(string.len(words[9+offset]) -3))
            currentMuffs = currentMuffs + tonumber(words[3+offset])
        end
    end
end)
