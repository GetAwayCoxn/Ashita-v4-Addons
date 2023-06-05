addon.name      = 'Database';
addon.author    = 'GetAwayCoxn';
addon.version   = '1.0';
addon.desc      = 'Tracks and displays a variety of needed items, gil, and points for various things, see ReadMe for details.';
addon.link      = 'https://github.com/GetAwayCoxn/';

require('common');
chat = require('chat');
local interface = require('interface');
imgui = require('imgui');
check = true;
lastPacketOut = os.time()

ashita.events.register('load', 'load_cb', interface.Load);

ashita.events.register('unload', 'unload_cb', interface.Unload);

ashita.events.register('d3d_present', 'present_cb', interface.Render);

ashita.events.register('text_in', 'text_in_cb', function(e)
    if not e.injected and e.message:contains('Paparoon') then
        interface.manager.HandlePaparoon(e)
    elseif not e.injected and e.message:contains('Oboro') then
        interface.manager.HandleOboro(e)
    end
end);

ashita.events.register("packet_in", "packet_in_cb", function(e)
    if (e.id == 0x113) then
        interface.manager.PacketInCurrency(e)
    elseif (e.id == 0x118) then
        interface.manager.PacketInCurrency2(e)
    end
end);

ashita.events.register('command', 'command_cb', function (e)
    local args = e.command:args();
    if (#args == 0) then
        return;
    end
    if (args[1] ~= '/database') and (args[1] ~= '/db') then
        return;
    end

    e.blocked = true;
    
    if (#args == 1 or (#args >= 2 and args[2]:any('interface'))) then
        if not interface.is_open[1] then 
            check = true;--bool that gets set true on first load and once again whenever the display is first rendered after being disabled
            if os.time() - lastPacketOut > 10 then
                AshitaCore:GetPacketManager():AddOutgoingPacket(0x10F, { 0x00, 0x00, 0x00, 0x00 });--update currency1
                local function Currency2()
                    AshitaCore:GetPacketManager():AddOutgoingPacket(0x115, { 0x00, 0x00, 0x00, 0x00 });--update currency2
                    lastPacketOut = os.time() -- Just in case, reset this again
                end
                lastPacketOut = os.time()
                Currency2:once(3)
            end
        end
        interface.is_open[1] = not interface.is_open[1];
    elseif (args[2] == 'reset') then
        interface.settings.reset();
        interface.data = interface.settings.load(interface.progress_defaults);
    elseif (args[2] == 'test') then
        interface.manager.Test();
    end
end);