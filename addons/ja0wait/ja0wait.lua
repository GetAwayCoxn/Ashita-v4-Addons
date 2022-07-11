addon.name      = 'ja0wait';
addon.author    = 'zechs6437 (ported for v4 by GetAwayCoxn)';
addon.version   = '1.0';
addon.desc      = 'Ported from zechs ashita v3.';
addon.link      = 'https://github.com/GetAwayCoxn/ja0wait';
-- zechs6437's' v3 repo link: https://github.com/zechs6437/ja0wait-ashita

require('common');

---------------------------------------------------------------------------------------------------
-- ja0wait Table
---------------------------------------------------------------------------------------------------
local JA0WAIT = { };
local ENGAGE0WAIT = { };

--search bytes
JA0WAIT.pointer = ashita.memory.find('FFXiMain.dll', 0, '8B81FC00000040', 0x00, 0);
ENGAGE0WAIT.pointer = ashita.memory.find('FFXiMain.dll', 0, '66FF81????????66C781????????0807C3', 0x00, 0);

--patches
JA0PATCH = { 0x8B, 0x81, 0xFC, 0x00, 0x00, 0x00, 0x90 };
ENGAGEPATCH = { 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90 };

----------------------------------------------------------------------------------------------------
-- func: load
-- desc: Event called when the addon is being loaded.
----------------------------------------------------------------------------------------------------
ashita.events.register('load', 'load_cb', function()
    -- Validate the pointers..
    if (JA0WAIT.pointer == 0) then
        print('\31\200[\31\05' .. 'ja0wait'.. '\31\200]\30\01 ' .. '\30\68Failed to find ja0wait signature.\30\01');
        return;
    end
	if (ENGAGE0WAIT.pointer == 0) then
        print('\31\200[\31\05' .. 'ja0wait'.. '\31\200]\30\01 ' .. '\30\68Failed to find engage0wait signature.\30\01');
        return;
    end

    -- Backup bytes
	JA0WAIT.backup = ashita.memory.read_array(JA0WAIT.pointer, 7);
	ENGAGE0WAIT.backup = ashita.memory.read_array(ENGAGE0WAIT.pointer, 7);
	
    -- Overwrite bytes

    ashita.memory.write_array(JA0WAIT.pointer, JA0PATCH);
	ashita.memory.write_array(ENGAGE0WAIT.pointer, ENGAGEPATCH);
    print(string.format('\31\200[\31\05' .. 'ja0wait'.. '\31\200] \31\130Functions patched; slip and slide around all you want.'));
end);

----------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Event called when the addon is being unloaded.
----------------------------------------------------------------------------------------------------
ashita.events.register('unload', 'unload_cb', function()
    -- Restore original bytes
    if (JA0WAIT.backup ~= nil) then
        ashita.memory.write_array(JA0WAIT.pointer, JA0WAIT.backup);
    end
    if (ENGAGE0WAIT.backup ~= nil) then
        ashita.memory.write_array(ENGAGE0WAIT.pointer, ENGAGE0WAIT.backup);
    end
end);
