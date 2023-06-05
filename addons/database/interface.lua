interface = T{
    manager = require('manager'),
    settings = require('settings'),
    is_open = { true, },
    timestamps = 1, -- 1 if you use the timestamps addon, 0 if not, this will affect the automatic reading from Oboro, Paparoon, etc.
    progress_defaults = require('progress_defaults'),
    defaults = require('defaults'),
    colors = {
        error = { 1.0, 0.4, 0.4, 1.0 },
        header = { 1.0, 0.65, 0.26, 1.0 },
        warning = { 0.9, 0.9, 0.0, 1.0 },
        green = { 0.2, 0.9, 0.0, 1.0 }, --bright green
        blue = { 0.5, 0.9, 1.0, 1.0 }, --light blue
    },
};

function interface.Load()
    interface.data = interface.settings.load(interface.progress_defaults);

    interface.settings.register('settings', 'settings_update', function (s)
        if(s ~= nil) then
            interface.data = s;
        end
        interface.settings.save();
    end);
end

function interface.Unload()
    interface.settings.save();
end

function interface.RenderJobPointsTab()
    imgui.BeginGroup();
        imgui.BeginChild('JPpane', { 0, -imgui.GetFrameHeightWithSpacing(), }, true);
            interface.manager.DisplayJobs();
        imgui.EndChild();
    imgui.EndGroup();
end

function interface.RenderWeaponsTab()
    imgui.BeginGroup();
        imgui.BeginChild('WeaponsPane', { 0, -imgui.GetFrameHeightWithSpacing(), }, true);
            if (imgui.BeginTabBar('weapons_tabbar', ImGuiTabBarFlags_NoCloseWithMiddleMouseButton)) then
                if (imgui.BeginTabItem('RELICS', nil)) then
                    interface.manager.DisplayRelics();
                imgui.EndTabItem();
                end

                if (imgui.BeginTabItem('MYTHICS', nil)) then
                    interface.manager.DisplayMythics();
                imgui.EndTabItem();
                end

                if (imgui.BeginTabItem('EMPYREANS', nil)) then
                    interface.manager.DisplayEmpyreans();
                imgui.EndTabItem();
                end

                if (imgui.BeginTabItem('ERGONS', nil)) then
                    interface.manager.DisplayErgons();
                imgui.EndTabItem();
                end

                if (imgui.BeginTabItem('PRIMES', nil)) then
                    interface.manager.DisplayPrimes();
                imgui.EndTabItem();
                end

                if (imgui.BeginTabItem('AMBUSCADE', nil)) then
                    interface.manager.DisplayAmbuWeps();
                imgui.EndTabItem();
                end

            imgui.EndTabBar();
            end
        imgui.EndChild();

        if (imgui.Button('Update All Weapons')) then
            interface.manager.UpdateWeapons();
            print(chat.header(addon.name) .. chat.message('Updated All Weapons'));
        end
    imgui.EndGroup();
end

function interface.RenderGearTab()
    imgui.BeginGroup();
        imgui.BeginChild('GearPane', { 0, -imgui.GetFrameHeightWithSpacing(), }, true);
            if (imgui.BeginTabBar('gear_tabbar', ImGuiTabBarFlags_NoCloseWithMiddleMouseButton)) then
                if (imgui.BeginTabItem('AF', nil)) then
                    if (imgui.BeginTabBar('af_tabbar', ImGuiTabBarFlags_NoCloseWithMiddleMouseButton)) then
                        if (imgui.BeginTabItem('AF HAVE', nil)) then
                            interface.manager.DisplayAFGear();
                        imgui.EndTabItem();
                        end
                        if (imgui.BeginTabItem('AF NEED', nil)) then 
                            interface.manager.DisplayAFGearNeed();
                        imgui.EndTabItem();
                        end
                    imgui.EndTabBar();
                    end
                imgui.EndTabItem();
                end

                if (imgui.BeginTabItem('RELIC', nil)) then
                    if (imgui.BeginTabBar('relic_tabbar', ImGuiTabBarFlags_NoCloseWithMiddleMouseButton)) then
                        if (imgui.BeginTabItem('RELIC HAVE', nil)) then
                            interface.manager.DisplayRelicGear();
                        imgui.EndTabItem();
                        end
                        if (imgui.BeginTabItem('RELIC NEED', nil)) then
                            interface.manager.DisplayRelicGearNeed();
                        imgui.EndTabItem();
                        end
                        if (imgui.BeginTabItem('SHARDS NEED', nil)) then
                            interface.manager.DisplayRelicShardsNeed();
                        imgui.EndTabItem();
                        end
                    imgui.EndTabBar();
                    end
                imgui.EndTabItem();
                end

                if (imgui.BeginTabItem('EMPYREAN', nil)) then
                    if (imgui.BeginTabBar('empy_tabbar', ImGuiTabBarFlags_NoCloseWithMiddleMouseButton)) then
                        if (imgui.BeginTabItem('EMPYREAN HAVE', nil)) then
                            interface.manager.DisplayEmpyGear();
                        imgui.EndTabItem();
                        end
                        if (imgui.BeginTabItem('EMPYREAN BASE NEED', nil)) then
                            interface.manager.DisplayEmpyBaseGearNeed();
                        imgui.EndTabItem();
                        end
                        if (imgui.BeginTabItem('EMPYREAN REFORGED NEED', nil)) then
                            interface.manager.DisplayEmpyReforgedGearNeed()
                        imgui.EndTabItem();
                        end
                    imgui.EndTabBar();
                    end
                imgui.EndTabItem();
                end

                if (imgui.BeginTabItem('AMBUSCADE', nil)) then
                    interface.manager.DisplayAmbuGear();
                    interface.manager.DisplayAmbuGearNeed();
                imgui.EndTabItem();
                end

                if (imgui.BeginTabItem('UNITY', nil)) then
                imgui.BeginChild('UnityPane', { 0, 600, }, true);
                    if (imgui.BeginTabBar('gear_tabbar', ImGuiTabBarFlags_NoCloseWithMiddleMouseButton)) then
                        if (imgui.BeginTabItem('SCALE', nil)) then
                            interface.manager.DisplayScaleGear();
                        imgui.EndTabItem();
                        end

                        if (imgui.BeginTabItem('HIDE', nil)) then
                            interface.manager.DisplayHideGear();
                        imgui.EndTabItem();
                        end

                        if (imgui.BeginTabItem('WING', nil)) then
                            interface.manager.DisplayWingGear();
                        imgui.EndTabItem();
                        end
                    imgui.EndTabBar();
                    end
                imgui.EndChild();
                imgui.EndTabItem();
                end

                if (imgui.BeginTabItem('ODYSSEA', nil)) then
                imgui.BeginChild('OdyGearPane', { 0, 600, }, true);
                    if (imgui.BeginTabBar('ody_gear_tabbar', ImGuiTabBarFlags_NoCloseWithMiddleMouseButton)) then
                        if (imgui.BeginTabItem('Tier 1/2', nil)) then
                            interface.manager.DisplaySheolGear1();
                        imgui.EndTabItem();
                        end

                        if (imgui.BeginTabItem('Tier 3/4', nil)) then
                            interface.manager.DisplaySheolGear2();
                        imgui.EndTabItem();
                        end
                    imgui.EndTabBar();
                    end
                imgui.EndChild();
                imgui.EndTabItem();
                end

            imgui.EndTabBar();
            end
        imgui.EndChild();

        if (imgui.Button('Update All Gear')) then
            interface.manager.UpdateGear();
            -- interface.manager.Test();
        end
        imgui.ShowHelp('This may cause you to lag hard for a moment')
    imgui.EndGroup();
end

function interface.RenderAMBUPointsTab()
    imgui.BeginGroup();
        imgui.BeginChild('AMBUPointsPane', { 0, -imgui.GetFrameHeightWithSpacing(), }, true);
            if (imgui.BeginTabBar('points_tabbar', ImGuiTabBarFlags_NoCloseWithMiddleMouseButton)) then
                if (imgui.BeginTabItem('HALLMARKS', nil)) then
                    interface.manager.DisplayHallmarks();
                imgui.EndTabItem();
                end
                if (imgui.BeginTabItem('GALLANTRY', nil)) then
                    interface.manager.DisplayGallantry();
                imgui.EndTabItem();
                end
            imgui.EndTabBar();
            end
        imgui.EndChild();
        if (imgui.Button('Reset Monthly AMBU')) then
            print(chat.header(addon.name) .. chat.message('Ambu points reset'));
            interface.manager.ResetAMBU();
        end
        imgui.SameLine();imgui.ShowHelp('Click to reset to default, cannot undo this action, this will also update the AMBU weapons section');
    imgui.EndGroup();
end

function interface.RenderPricesTab()
    imgui.BeginGroup();
        imgui.BeginChild('prices_mainpane', { 0, -imgui.GetFrameHeightWithSpacing(), }, true);
            if (imgui.BeginTabBar('prices', ImGuiTabBarFlags_NoCloseWithMiddleMouseButton)) then
                if (imgui.BeginTabItem('COMMON', nil)) then
                    imgui.InputInt('Pluton', interface.data.prices['Pluton'], 100, 1000);
                    imgui.InputInt('Beitetsu', interface.data.prices['Beitetsu'], 100, 1000);
                    imgui.InputInt('Riftborn Boulder', interface.data.prices['Riftborn Boulder'], 100, 1000);
                    imgui.InputInt('Sad. Crystals', interface.data.prices['Sad. Crystals'], 1000, 10000);
                imgui.EndTabItem();
                end
                if (imgui.BeginTabItem('DYNA CURRENCY', nil)) then
                    imgui.InputInt('Byne Bills', interface.data.prices['Byne Bills'], 100, 1000);
                    imgui.InputInt('Bronze Pieces', interface.data.prices['Bronze Pieces'], 100, 1000);
                    imgui.InputInt('T. Whiteshells', interface.data.prices['T. Whiteshells'], 100, 1000);
                    imgui.InputInt('Umbral Marrow', interface.data.prices['Umbral Marrow'], 10000, 100000);
                imgui.EndTabItem();
                end
                if (imgui.BeginTabItem('MYTHIC CURRENCY', nil)) then
                    imgui.InputInt('Alexandrite', interface.data.prices['Alexandrite'], 100, 1000);
                    imgui.InputInt('Mulcibar\'s Scoria', interface.data.prices['Mulcibar\'s Scoria'], 10000, 100000);
                imgui.EndTabItem();
                end
                if (imgui.BeginTabItem('EMPYREAN CURRENCY', nil)) then
                    imgui.InputInt('Riftcinder', interface.data.prices['Riftcinder'], 1000, 10000);
                    imgui.InputInt('Riftdross', interface.data.prices['Riftdross'], 1000, 10000);
                    imgui.InputInt('Heavy Metal Plates', interface.data.prices['Heavy Metal Plates'], 1000, 10000);
                imgui.EndTabItem();
                end
                if (imgui.BeginTabItem('ERGON CURRENCY', nil)) then
                    imgui.InputInt('H-P Bayld', interface.data.prices['H-P Bayld'], 100, 1000);
                imgui.EndTabItem();
                end
                if (imgui.BeginTabItem('ODY ITEMS', nil)) then
                    imgui.InputInt('Lustreless Scales', interface.data.prices['Lustreless Scales'], 100, 1000);
                    imgui.InputInt('Lustreless Hides', interface.data.prices['Lustreless Hides'], 100, 1000);
                    imgui.InputInt('Lustreless Wings', interface.data.prices['Lustreless Wings'], 100, 1000);
                imgui.EndTabItem();
                end
            imgui.EndTabBar();
            end
        imgui.EndChild();
    imgui.EndGroup();
end


function interface.Render()
    if (not interface.is_open[1]) or (AshitaCore:GetMemoryManager():GetPlayer():GetIsZoning() ~= 0) then
        return;
    end

    imgui.SetNextWindowSize({ 1000, 750, });
    imgui.SetNextWindowSizeConstraints({ 1000, 750, }, { FLT_MAX, FLT_MAX, });
    if (imgui.Begin('Database', interface.is_open, ImGuiWindowFlags_NoResize)) then
        if (imgui.BeginTabBar('##database_tabbar', ImGuiTabBarFlags_NoCloseWithMiddleMouseButton)) then
            if (imgui.BeginTabItem('JOBS', nil)) then
                interface.RenderJobPointsTab();
                interface.manager.UpdateJobs();
                imgui.EndTabItem();
            end
            if (imgui.BeginTabItem('WEAPONS', nil)) then
                interface.RenderWeaponsTab();
                imgui.EndTabItem();
            end
            if (imgui.BeginTabItem('GEAR', nil)) then
                interface.RenderGearTab();
                imgui.EndTabItem();
            end
            if (imgui.BeginTabItem('AMBU POINTS', nil)) then
                interface.RenderAMBUPointsTab();
                imgui.EndTabItem();
            end
            if (imgui.BeginTabItem('PRICES', nil)) then
                interface.RenderPricesTab();
                imgui.EndTabItem();
            end
            imgui.EndTabBar();
        end
    end
    imgui.End();
end

return interface;