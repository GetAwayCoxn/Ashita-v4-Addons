addon.name      = 'zenihelper';
addon.author    = 'GetAwayCoxn';
addon.version   = '1.02';
addon.desc      = 'Track and displays what ZNM pops/trophies/KI\'s you have and assists in popping the NMs at the ???';
addon.link      = 'https://github.com/GetAwayCoxn/Zeni-Helper';

require('common');
local interface = require('interface');
imgui = require('imgui');
data = require('data');
chat = require('chat');
zeni,jettons = 0,0;

ashita.events.register('d3d_present', 'present_cb', interface.render);

ashita.events.register("packet_in", "packet_in_cb", function (e)
    if (e.id == 0x113) then
        zeni = struct.unpack("I", e.data, 0x98)/256;
		jettons = struct.unpack("I", e.data, 0x9C)/256;
    end
end);

ashita.events.register('command', 'command_cb', function (e)
	local args = e.command:args();
    if (#args == 0) or ((args[1] ~= '/zenihelper') and (args[1] ~= '/zh')) then
        return;
    end

    e.blocked = true;

    if (#args <= 1) and ((args[1] == '/zenihelper') or (args[1] == '/zh')) then
        if not interface.is_open[1] then 
            AshitaCore:GetPacketManager():AddOutgoingPacket(0x10F, { 0x00, 0x00, 0x00, 0x00 });
            interface.update();
        end
        interface.is_open[1] = not interface.is_open[1];
    elseif (#args == 2 and args[2]:any('trade')) then
        interface.dotrade();
    end
end);