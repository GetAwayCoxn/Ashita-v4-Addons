interface = T{
    is_open = {false,},
    bg_alpha = 0.9,
    colors = {
        title = { 1.0, 0.65, 0.26, 0.9 },
        name = { 1.0, 1.0, 1.0, 0.9 },
        kihas = { 1.0, 1.0, 0.0, 0.9 },
        kidonthas = { .5, 0.0, 1.0, 0.9 },
        has = { 0.2, 0.9, 0.0, 0.9 },
        donthas = {0.5, 0.5, 0.5, 0.9 },
    },
    tradetime = os.time();
};
function interface.render()
    local party = AshitaCore:GetMemoryManager():GetParty();
    local player = AshitaCore:GetMemoryManager():GetPlayer();
    if (party:GetMemberIsActive(0) == 0 or party:GetMemberServerId(0) == 0) or player:GetIsZoning() ~= 0 then
        return;
    end
    local target = GetEntity(AshitaCore:GetMemoryManager():GetTarget():GetTargetIndex(0));
    
    if target ~= nil then
        if data.tradeitems:haskey(target.ServerId) and math.sqrt(target.Distance) < 5 and (os.time() - interface.tradetime > 3) then
            interface.tradetime = os.time()
            interface.dotrade();
        end
    end

    if  not interface.is_open[1] then
        return;
    end

    imgui.SetNextWindowSize({ 975, 615, });
    imgui.SetNextWindowBgAlpha(interface.bg_alpha);
    if (imgui.Begin('zenihelper', interface.is_open, ImGuiWindowFlags_NoDecoration)) then
        if imgui.IsWindowHovered(ImGuiHoveredFlags_RootAndChildWindows) then
            if imgui.IsMouseDoubleClicked(ImGuiMouseButton_Left) then
                interface.is_open[1] = not interface.is_open[1];
            end
        end
        imgui.BeginChild('NmPane', { 960, 560 }, true);
            imgui.BeginChild('TinninPane', { 310, 540}, true);
                imgui.Indent(100.0);
                imgui.TextColored(interface.colors.title, 'TINNIN PATH');
                imgui.Separator();

                interface.kiprint('Maroon Seal');
                imgui.Indent(-100.0);

                for k,v in pairs(data.items.tinnin.t1) do
                    imgui.TextColored(interface.colors.name, k);
                    if k == 'Cheese Hoarder Gigiroon' then
                        imgui.ShowHelp([[Alzadaal Undersea Ruins (F-9) first map]]);
                    end
                    if v[3] then imgui.TextColored(interface.colors.has, v[1]) else imgui.TextColored(interface.colors.donthas, v[1]) end
                    imgui.SameLine();imgui.Indent(135);imgui.TextColored(interface.colors.name, '|');imgui.SameLine();
                    if v[4] then imgui.TextColored(interface.colors.has, v[2]) else imgui.TextColored(interface.colors.donthas, v[2]) end;
                    imgui.Indent(-135);
                end

                imgui.Indent(80.0);
                interface.kiprint('Apple Green Seal');
                imgui.Indent(-80.0);

                for k,v in pairs(data.items.tinnin.t2) do
                    imgui.TextColored(interface.colors.name, k);
                    if k == 'Iriz Ima' then
                        imgui.ShowHelp([[Walk outside to Wajaom Woodlands, then go to J-8]]);
                    end
                    if v[3] then imgui.TextColored(interface.colors.has, v[1]) else imgui.TextColored(interface.colors.donthas, v[1]) end
                    imgui.SameLine();imgui.Indent(135);imgui.TextColored(interface.colors.name, '|');imgui.SameLine();
                    if v[4] then imgui.TextColored(interface.colors.has, v[2]) else imgui.TextColored(interface.colors.donthas, v[2]) end;
                    imgui.Indent(-135);
                end

                imgui.Indent(80.0);
                interface.kiprint('Charcoal Grey Seal');
                imgui.Indent(-80.0);

                imgui.TextColored(interface.colors.name, 'Armed Gears');
                imgui.ShowHelp([[Alzadaal Undersea Ruins (G-11) first map]]);
                if data.items.tinnin.t3['Armed Gears'][3] then
                    imgui.TextColored(interface.colors.has, data.items.tinnin.t3['Armed Gears'][1]);
                else 
                    imgui.TextColored(interface.colors.donthas, data.items.tinnin.t3['Armed Gears'][1]);
                end
                imgui.SameLine();imgui.Indent(135);imgui.TextColored(interface.colors.name, '|');imgui.SameLine();
                if data.items.tinnin.t3['Armed Gears'][4] then
                    imgui.TextColored(interface.colors.has, data.items.tinnin.t3['Armed Gears'][2]);
                else 
                    imgui.TextColored(interface.colors.donthas, data.items.tinnin.t3['Armed Gears'][2]);
                end;imgui.Indent(-135);

                imgui.Indent(80.0);
                interface.kiprint('Deep Purple Seal');
                imgui.Indent(-80.0);

                imgui.TextColored(interface.colors.name, 'Gotoh Zha the Redolent');
                imgui.ShowHelp([[Survival Guide to Wajaom Woodlands and Mount to (F-5)]]);
                if data.items.tinnin.t3['Gotoh Zha the Redolent'][3] then
                    imgui.TextColored(interface.colors.has, data.items.tinnin.t3['Gotoh Zha the Redolent'][1]);
                else 
                    imgui.TextColored(interface.colors.donthas, data.items.tinnin.t3['Gotoh Zha the Redolent'][1]);
                end
                imgui.SameLine();imgui.Indent(135);imgui.TextColored(interface.colors.name, '|');imgui.SameLine();
                if data.items.tinnin.t3['Gotoh Zha the Redolent'][4] then
                    imgui.TextColored(interface.colors.has, data.items.tinnin.t3['Gotoh Zha the Redolent'][2]);
                else 
                    imgui.TextColored(interface.colors.donthas, data.items.tinnin.t3['Gotoh Zha the Redolent'][2]);
                end;imgui.Indent(-135);

                imgui.Indent(70.0);
                interface.kiprint('Chestnut-colored Seal');
                imgui.Indent(-70.0);

                imgui.TextColored(interface.colors.name, 'Dea');
                imgui.ShowHelp([[Escape from Nyzul Isle or walk outside to Bhaflau Thickets, then go to F-7]]);
                if data.items.tinnin.t3['Dea'][3] then
                    imgui.TextColored(interface.colors.has, data.items.tinnin.t3['Dea'][1]);
                else 
                    imgui.TextColored(interface.colors.donthas, data.items.tinnin.t3['Dea'][1]);
                end
                imgui.SameLine();imgui.Indent(135);imgui.TextColored(interface.colors.name, '|');imgui.SameLine();
                if data.items.tinnin.t3['Dea'][4] then
                    imgui.TextColored(interface.colors.has, data.items.tinnin.t3['Dea'][2]);
                else 
                    imgui.TextColored(interface.colors.donthas, data.items.tinnin.t3['Dea'][2]);
                end;imgui.Indent(-135);
                
                imgui.Indent(80.0);
                interface.kiprint('Lilac-colored Seal');
                imgui.Indent(-80.0);

                imgui.TextColored(interface.colors.name, 'Tinnin');
                imgui.ShowHelp('Wajaom Woodlands (H-13) use Unity Warp 135 and a mount');
                if data.items.tinnin.t4['Tinnin'][3] then
                    imgui.TextColored(interface.colors.has, data.items.tinnin.t4['Tinnin'][1]);
                else 
                    imgui.TextColored(interface.colors.donthas, data.items.tinnin.t4['Tinnin'][1]);
                end
                imgui.SameLine();imgui.Indent(135);imgui.TextColored(interface.colors.name, '|');imgui.SameLine();
                if data.items.tinnin.t4['Tinnin'][4] then
                    imgui.TextColored(interface.colors.has, data.items.tinnin.t4['Tinnin'][2]);
                else 
                    imgui.TextColored(interface.colors.donthas, data.items.tinnin.t4['Tinnin'][2]);
                end;imgui.Indent(-135);
                imgui.Indent(80.0);
                interface.kiprint('Sicklemoon salt');
                imgui.Indent(-80.0);
            imgui.EndChild();
            imgui.SameLine();
            imgui.BeginChild('SarameyaPane', { 310, 540}, true);
                imgui.Indent(95.0);
                imgui.TextColored(interface.colors.title, 'SARAMEYA PATH');
                imgui.Indent(-95.0);
                imgui.Separator();

                imgui.Indent(100.0);
                interface.kiprint('Cerise Seal');
                imgui.Indent(-100.0);

                for k,v in pairs(data.items.sarameya.t1) do
                    imgui.TextColored(interface.colors.name, k);
                    if k == 'Ob' then
                        imgui.ShowHelp([[Alzadaal Undersea Ruins - Bhaflau Remnants Warp, then go to G-7]]);
                    end
                    if v[3] then imgui.TextColored(interface.colors.has, v[1]) else imgui.TextColored(interface.colors.donthas, v[1]) end
                    imgui.SameLine();imgui.Indent(135);imgui.TextColored(interface.colors.name, '|');imgui.SameLine();
                    if v[4] then imgui.TextColored(interface.colors.has, v[2]) else imgui.TextColored(interface.colors.donthas, v[2]) end;
                    imgui.Indent(-135);
                end

                imgui.Indent(80.0);
                interface.kiprint('Salmon-colored Seal');
                imgui.Indent(-80.0);

                for k,v in pairs(data.items.sarameya.t2) do
                    imgui.TextColored(interface.colors.name, k);
                    if k == 'Anantaboga' then
                        imgui.ShowHelp([[HP warp to Mount Z, then (E-6)]]);
                    end
                    if v[3] then imgui.TextColored(interface.colors.has, v[1]) else imgui.TextColored(interface.colors.donthas, v[1]) end
                    imgui.SameLine();imgui.Indent(135);imgui.TextColored(interface.colors.name, '|');imgui.SameLine();
                    if v[4] then imgui.TextColored(interface.colors.has, v[2]) else imgui.TextColored(interface.colors.donthas, v[2]) end;
                    imgui.Indent(-135);
                end

                imgui.Indent(80.0);
                interface.kiprint('Copper-colored Seal');
                imgui.Indent(-80.0);

                imgui.TextColored(interface.colors.name, 'Achamoth');
                imgui.ShowHelp([[Halvung Map 1 (G-4)

Option A:

    Zone in from the Voidwatch warp, the Survival Guide, or Runic portal to (L-7) in Mount Zhayolm and make the long trek to (G-4) on Halvung Map 1.

Option B:

    This allows you to double up and defeat a Dextrose (T2) right before an Achamoth (T3) if you have the pops.
    Take the Homepoint or Unity 135 warp to Mount Zhayolm and zone in to Halvung at (D-9).
        Take a left at the fork while entering the tunnel before the zone, and head north, not south.
    Once in Halvung, take a left at the fork again. Proceed over the 'bridge' over the lava at (F-8), and through the Cast Bronze Gate (just select it, no key required).
    Keep left and then bare right through another gate at (G-7), drop down the ledge, and then follow the path to the pop for Dextrose at (J-6).
    From there hug the left and head east until you drop down a ledge. Head up the hill through the gate, and the pop is right in front of you at the fork in the road before the lava bridge.]]);
                if data.items.sarameya.t3['Achamoth'][3] then
                    imgui.TextColored(interface.colors.has, data.items.sarameya.t3['Achamoth'][1]);
                else 
                    imgui.TextColored(interface.colors.donthas, data.items.sarameya.t3['Achamoth'][1]);
                end
                imgui.SameLine();imgui.Indent(135);imgui.TextColored(interface.colors.name, '|');imgui.SameLine();
                if data.items.sarameya.t3['Achamoth'][4] then
                    imgui.TextColored(interface.colors.has, data.items.sarameya.t3['Achamoth'][2]);
                else 
                    imgui.TextColored(interface.colors.donthas, data.items.sarameya.t3['Achamoth'][2]);
                end;imgui.Indent(-135);

                imgui.Indent(85.0);
                interface.kiprint('Gold-colored Seal');
                imgui.Indent(-85.0);
                
                imgui.TextColored(interface.colors.name, 'Khromasoul Bhurborlor');
                imgui.ShowHelp([[Mount Zhayolm (G/H-8)

Voidwatch warp to Mount Z and mount, dont go towards Cerb pop]]);
                if data.items.sarameya.t3['Khromasoul Bhurborlor'][3] then
                    imgui.TextColored(interface.colors.has, data.items.sarameya.t3['Khromasoul Bhurborlor'][1]);
                else 
                    imgui.TextColored(interface.colors.donthas, data.items.sarameya.t3['Khromasoul Bhurborlor'][1]);
                end
                imgui.SameLine();imgui.Indent(135);imgui.TextColored(interface.colors.name, '|');imgui.SameLine();
                if data.items.sarameya.t3['Khromasoul Bhurborlor'][4] then
                    imgui.TextColored(interface.colors.has, data.items.sarameya.t3['Khromasoul Bhurborlor'][2]);
                else 
                    imgui.TextColored(interface.colors.donthas, data.items.sarameya.t3['Khromasoul Bhurborlor'][2]);
                end;imgui.Indent(-135);
                
                imgui.Indent(80.0);
                interface.kiprint('Purplish Grey Seal');
                imgui.Indent(-80.0);

                imgui.TextColored(interface.colors.name, 'Nosferatu');
                imgui.ShowHelp([[Aydeewa Subterrance Map 2 (F-9)

Survival Guide to Aydeewa, then walk to F9]]);
                if data.items.sarameya.t3['Nosferatu'][3] then
                    imgui.TextColored(interface.colors.has, data.items.sarameya.t3['Nosferatu'][1]);
                else 
                    imgui.TextColored(interface.colors.donthas, data.items.sarameya.t3['Nosferatu'][1]);
                end
                imgui.SameLine();imgui.Indent(135);imgui.TextColored(interface.colors.name, '|');imgui.SameLine();
                if data.items.sarameya.t3['Nosferatu'][4] then
                    imgui.TextColored(interface.colors.has, data.items.sarameya.t3['Nosferatu'][2]);
                else 
                    imgui.TextColored(interface.colors.donthas, data.items.sarameya.t3['Nosferatu'][2]);
                end;imgui.Indent(-135);

                imgui.Indent(85.0);
                interface.kiprint('Bright Blue Seal');
                imgui.Indent(-85.0);

                imgui.TextColored(interface.colors.name, 'Sarameya');
                imgui.ShowHelp([[Mount Zhayolm (I-10)

Voidwatch warp to Mount Z and mount, dont go towards Cerb pop]]);
                if data.items.sarameya.t4['Sarameya'][3] then
                    imgui.TextColored(interface.colors.has, data.items.sarameya.t4['Sarameya'][1]);
                else 
                    imgui.TextColored(interface.colors.donthas, data.items.sarameya.t4['Sarameya'][1]);
                end
                imgui.SameLine();imgui.Indent(135);imgui.TextColored(interface.colors.name, '|');imgui.SameLine();
                if data.items.sarameya.t4['Sarameya'][4] then
                    imgui.TextColored(interface.colors.has, data.items.sarameya.t4['Sarameya'][2]);
                else 
                    imgui.TextColored(interface.colors.donthas, data.items.sarameya.t4['Sarameya'][2]);
                end;imgui.Indent(-135);
                imgui.Indent(85.0);
                interface.kiprint('Silver Sea salt');
                imgui.Indent(-85.0);
            imgui.EndChild();
            imgui.SameLine();
            imgui.BeginChild('TygerPane', { 310, 540}, true);
                imgui.Indent(110);
                imgui.TextColored(interface.colors.title, 'TYGER PATH');
                imgui.Indent(-110);
                imgui.Separator();

                imgui.Indent(90);
                interface.kiprint('Pine Green Seal');
                imgui.Indent(-90);

                for k,v in pairs(data.items.tyger.t1) do
                    imgui.TextColored(interface.colors.name, k);
                    if k == 'Chigre' then
                        imgui.ShowHelp([[Aydeewa Subterrance Map 2 (E-8)

Survival Guide to Aydeewa, then walk]]);
                    end
                    if v[3] then imgui.TextColored(interface.colors.has, v[1]) else imgui.TextColored(interface.colors.donthas, v[1]) end
                    imgui.SameLine();imgui.Indent(135);imgui.TextColored(interface.colors.name, '|');imgui.SameLine();
                    if v[4] then imgui.TextColored(interface.colors.has, v[2]) else imgui.TextColored(interface.colors.donthas, v[2]) end;
                    imgui.Indent(-135);
                end

                imgui.Indent(80);
                interface.kiprint('Amber-colored Seal');
                imgui.Indent(-80);

                for k,v in pairs(data.items.tyger.t2) do
                    imgui.TextColored(interface.colors.name, k);
                    if k == 'Wulgaru' then
                        imgui.ShowHelp([[Alzadaal Undersea Ruins (G-6) first map]]);
                    end
                    if v[3] then imgui.TextColored(interface.colors.has, v[1]) else imgui.TextColored(interface.colors.donthas, v[1]) end
                    imgui.SameLine();imgui.Indent(135);imgui.TextColored(interface.colors.name, '|');imgui.SameLine();
                    if v[4] then imgui.TextColored(interface.colors.has, v[2]) else imgui.TextColored(interface.colors.donthas, v[2]) end;
                    imgui.Indent(-135);
                end

                imgui.Indent(85);
                interface.kiprint('Taupe-colored Seal');
                imgui.Indent(-85);

                imgui.TextColored(interface.colors.name, 'Experimental Lamia');
                imgui.ShowHelp('Caedarva Mire (F-7) survival guide very close');
                if data.items.tyger.t3['Experimental Lamia'][3] then
                    imgui.TextColored(interface.colors.has, data.items.tyger.t3['Experimental Lamia'][1]);
                else 
                    imgui.TextColored(interface.colors.donthas, data.items.tyger.t3['Experimental Lamia'][1]);
                end
                imgui.SameLine();imgui.Indent(135);imgui.TextColored(interface.colors.name, '|');imgui.SameLine();
                if data.items.tyger.t3['Experimental Lamia'][4] then
                    imgui.TextColored(interface.colors.has, data.items.tyger.t3['Experimental Lamia'][2]);
                else 
                    imgui.TextColored(interface.colors.donthas, data.items.tyger.t3['Experimental Lamia'][2]);
                end;imgui.Indent(-135);

                imgui.Indent(80);
                interface.kiprint('Fallow-colored Seal');
                imgui.Indent(-80);

                imgui.TextColored(interface.colors.name, 'Mahjlaef the Paintorn');
                imgui.ShowHelp('Caedarva Mire (H-7) use Unity Warp 135 and a mount');
                if data.items.tyger.t3['Mahjlaef the Paintorn'][3] then
                    imgui.TextColored(interface.colors.has, data.items.tyger.t3['Mahjlaef the Paintorn'][1]);
                else 
                    imgui.TextColored(interface.colors.donthas, data.items.tyger.t3['Mahjlaef the Paintorn'][1]);
                end
                imgui.SameLine();imgui.Indent(135);imgui.TextColored(interface.colors.name, '|');imgui.SameLine();
                if data.items.tyger.t3['Mahjlaef the Paintorn'][4] then
                    imgui.TextColored(interface.colors.has, data.items.tyger.t3['Mahjlaef the Paintorn'][2]);
                else 
                    imgui.TextColored(interface.colors.donthas, data.items.tyger.t3['Mahjlaef the Paintorn'][2]);
                end;imgui.Indent(-135);

                imgui.Indent(80);
                interface.kiprint('Sienna-colored Seal');
                imgui.Indent(-80);

                imgui.TextColored(interface.colors.name, 'Nuhn');
                imgui.ShowHelp([[Survival Guide warp to Caedarva Mire, then go to Arrapago Reef, then G-6]]);
                if data.items.tyger.t3['Nuhn'][3] then
                    imgui.TextColored(interface.colors.has, data.items.tyger.t3['Nuhn'][1]);
                else 
                    imgui.TextColored(interface.colors.donthas, data.items.tyger.t3['Nuhn'][1]);
                end
                imgui.SameLine();imgui.Indent(135);imgui.TextColored(interface.colors.name, '|');imgui.SameLine();
                if data.items.tyger.t3['Nuhn'][4] then
                    imgui.TextColored(interface.colors.has, data.items.tyger.t3['Nuhn'][2]);
                else 
                    imgui.TextColored(interface.colors.donthas, data.items.tyger.t3['Nuhn'][2]);
                end;imgui.Indent(-135);

                imgui.Indent(70);
                interface.kiprint('Lavender-colored Seal');
                imgui.Indent(-70);

                imgui.TextColored(interface.colors.name, 'Tyger');
                imgui.ShowHelp('Caedarva Mire (H-6) use Unity Warp 135 and a mount');
                if data.items.tyger.t4['Tyger'][3] then
                    imgui.TextColored(interface.colors.has, data.items.tyger.t4['Tyger'][1]);
                else 
                    imgui.TextColored(interface.colors.donthas, data.items.tyger.t4['Tyger'][1]);
                end
                imgui.SameLine();imgui.Indent(135);imgui.TextColored(interface.colors.name, '|');imgui.SameLine();
                if data.items.tyger.t4['Tyger'][4] then
                    imgui.TextColored(interface.colors.has, data.items.tyger.t4['Tyger'][2]);
                else 
                    imgui.TextColored(interface.colors.donthas, data.items.tyger.t4['Tyger'][2]);
                end;imgui.Indent(-135);

                imgui.Indent(100);
                interface.kiprint('Cyan Deep salt');
                imgui.Indent(-100);
            imgui.EndChild();
        imgui.EndChild();

        imgui.BeginChild('PwPane', { 960, 35}, true);
            imgui.ShowHelp([[Basics:
/zh       -- show/hide
/zh trade -- with a correct ??? targeted and correct item in your 
             main inventory will attempt to spawn your ZNM
Colors:
White  -- NM Name
Grey   -- Missing Items (Pop | Trophy)
Green  -- Items you have (Pop | Trophy)
Purple -- Missing Key Iems
Yellow -- Key Items you have

Notes:
-Key Items update automatically
-Items and Jettons/Zeni amounts update each time the display is
    refreshed with /zh
-Double clicking anywhere will hide as well]]);
            imgui.SameLine();imgui.Indent(110);imgui.TextColored(interface.colors.title, 'Jettons: ' .. interface.comma_value(jettons));
            imgui.SameLine();imgui.Indent(280);
            if data.items.pw['Pandemonium Warden'][2] then
                imgui.TextColored(interface.colors.has, data.items.pw['Pandemonium Warden'][1]);
            else 
                imgui.TextColored(interface.colors.donthas, '>>> ' .. data.items.pw['Pandemonium Warden'][1] .. ' <<<');
            end
            
            imgui.SameLine();imgui.Indent(360);imgui.TextColored(interface.colors.title, 'Zeni: ' .. interface.comma_value(zeni));
        imgui.EndChild();
    end
    imgui.End();
end

function interface.kiprint(str)
    local player = AshitaCore:GetMemoryManager():GetPlayer();
    if player:HasKeyItem(data.keyitems[str]) then
        imgui.TextColored(interface.colors.kihas, str);
    else
        imgui.TextColored(interface.colors.kidonthas, str);
    end
end

function interface.update()
    for k,v in pairs(data.items.tinnin.t1) do
        local count1 = 0;
        local count2 = 0;
        local str1 = v[1];
        local str2 = v[2];
        local popitem = AshitaCore:GetResourceManager():GetItemByName(str1, 0);
        local trophy = AshitaCore:GetResourceManager():GetItemByName(str2, 0);
        for x = 0, 16 do
            for y = 0, AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) do
                local tempitem = AshitaCore:GetMemoryManager():GetInventory():GetContainerItem(x, y);
                if (popitem ~= nil and tempitem ~= nil and popitem.Id == tempitem.Id) then
                    v[3] = true;
                    count1 = count1 +1;
                end
                if (trophy ~= nil and tempitem ~= nil and trophy.Id == tempitem.Id) then
                    v[4] = true;
                    count2 = count2 +1;
                end
                if x == 16 and y == AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) then
                    if count1 == 0 then
                        data.items.tinnin.t1[k][3] = false;
                    end
                    if count2 == 0 then
                        data.items.tinnin.t1[k][4] = false;
                    end
                end
            end
        end
    end
    for k,v in pairs(data.items.tinnin.t2) do
        local count1 = 0;
        local count2 = 0;
        local str1 = v[1];
        local str2 = v[2];
        local popitem = AshitaCore:GetResourceManager():GetItemByName(str1, 0);
        local trophy = AshitaCore:GetResourceManager():GetItemByName(str2, 0);
        for x = 0, 16 do
            for y = 0, AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) do
                local tempitem = AshitaCore:GetMemoryManager():GetInventory():GetContainerItem(x, y);
                if (popitem ~= nil and tempitem ~= nil and popitem.Id == tempitem.Id) then
                    v[3] = true;
                    count1 = count1 +1;
                end
                if (trophy ~= nil and tempitem ~= nil and trophy.Id == tempitem.Id) then
                    v[4] = true;
                    count2 = count2 +1;
                end
                if x == 16 and y == AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) then
                    if count1 == 0 then
                        data.items.tinnin.t2[k][3] = false;
                    end
                    if count2 == 0 then
                        data.items.tinnin.t2[k][4] = false;
                    end
                end
            end
        end
    end
    for k,v in pairs(data.items.tinnin.t3) do
        local count1 = 0;
        local count2 = 0;
        local str1 = v[1];
        local str2 = v[2];
        local popitem = AshitaCore:GetResourceManager():GetItemByName(str1, 0);
        local trophy = AshitaCore:GetResourceManager():GetItemByName(str2, 0);
        for x = 0, 16 do
            for y = 0, AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) do
                local tempitem = AshitaCore:GetMemoryManager():GetInventory():GetContainerItem(x, y);
                if (popitem ~= nil and tempitem ~= nil and popitem.Id == tempitem.Id) then
                    v[3] = true;
                    count1 = count1 +1;
                end
                if (trophy ~= nil and tempitem ~= nil and trophy.Id == tempitem.Id) then
                    v[4] = true;
                    count2 = count2 +1;
                end
                if x == 16 and y == AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) then
                    if count1 == 0 then
                        data.items.tinnin.t3[k][3] = false;
                    end
                    if count2 == 0 then
                        data.items.tinnin.t3[k][4] = false;
                    end
                end
            end
        end
    end
    for k,v in pairs(data.items.tinnin.t4) do
        local count1 = 0;
        local count2 = 0;
        local str1 = v[1];
        local str2 = v[2];
        local popitem = AshitaCore:GetResourceManager():GetItemByName(str1, 0);
        local trophy = AshitaCore:GetResourceManager():GetItemByName(str2, 0);
        for x = 0, 16 do
            for y = 0, AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) do
                local tempitem = AshitaCore:GetMemoryManager():GetInventory():GetContainerItem(x, y);
                if (popitem ~= nil and tempitem ~= nil and popitem.Id == tempitem.Id) then
                    v[3] = true;
                    count1 = count1 +1;
                end
                if (trophy ~= nil and tempitem ~= nil and trophy.Id == tempitem.Id) then
                    v[4] = true;
                    count2 = count2 +1;
                end
                if x == 16 and y == AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) then
                    if count1 == 0 then
                        data.items.tinnin.t4[k][3] = false;
                    end
                    if count2 == 0 then
                        data.items.tinnin.t4[k][4] = false;
                    end
                end
            end
        end
    end

    for k,v in pairs(data.items.sarameya.t1) do
        local count1 = 0;
        local count2 = 0;
        local str1 = v[1];
        local str2 = v[2];
        local popitem = AshitaCore:GetResourceManager():GetItemByName(str1, 0);
        local trophy = AshitaCore:GetResourceManager():GetItemByName(str2, 0);
        for x = 0, 16 do
            for y = 0, AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) do
                local tempitem = AshitaCore:GetMemoryManager():GetInventory():GetContainerItem(x, y);
                if (popitem ~= nil and tempitem ~= nil and popitem.Id == tempitem.Id) then
                    v[3] = true;
                    count1 = count1 +1;
                end
                if (trophy ~= nil and tempitem ~= nil and trophy.Id == tempitem.Id) then
                    v[4] = true;
                    count2 = count2 +1;
                end
                if x == 16 and y == AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) then
                    if count1 == 0 then
                        data.items.sarameya.t1[k][3] = false;
                    end
                    if count2 == 0 then
                        data.items.sarameya.t1[k][4] = false;
                    end
                end
            end
        end
    end
    for k,v in pairs(data.items.sarameya.t2) do
        local count1 = 0;
        local count2 = 0;
        local str1 = v[1];
        local str2 = v[2];
        local popitem = AshitaCore:GetResourceManager():GetItemByName(str1, 0);
        local trophy = AshitaCore:GetResourceManager():GetItemByName(str2, 0);
        for x = 0, 16 do
            for y = 0, AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) do
                local tempitem = AshitaCore:GetMemoryManager():GetInventory():GetContainerItem(x, y);
                if (popitem ~= nil and tempitem ~= nil and popitem.Id == tempitem.Id) then
                    v[3] = true;
                    count1 = count1 +1;
                end
                if (trophy ~= nil and tempitem ~= nil and trophy.Id == tempitem.Id) then
                    v[4] = true;
                    count2 = count2 +1;
                end
                if x == 16 and y == AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) then
                    if count1 == 0 then
                        data.items.sarameya.t2[k][3] = false;
                    end
                    if count2 == 0 then
                        data.items.sarameya.t2[k][4] = false;
                    end
                end
            end
        end
    end
    for k,v in pairs(data.items.sarameya.t3) do
        local count1 = 0;
        local count2 = 0;
        local str1 = v[1];
        local str2 = v[2];
        local popitem = AshitaCore:GetResourceManager():GetItemByName(str1, 0);
        local trophy = AshitaCore:GetResourceManager():GetItemByName(str2, 0);
        for x = 0, 16 do
            for y = 0, AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) do
                local tempitem = AshitaCore:GetMemoryManager():GetInventory():GetContainerItem(x, y);
                if (popitem ~= nil and tempitem ~= nil and popitem.Id == tempitem.Id) then
                    v[3] = true;
                    count1 = count1 +1;
                end
                if (trophy ~= nil and tempitem ~= nil and trophy.Id == tempitem.Id) then
                    v[4] = true;
                    count2 = count2 +1;
                end
                if x == 16 and y == AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) then
                    if count1 == 0 then
                        data.items.sarameya.t3[k][3] = false;
                    end
                    if count2 == 0 then
                        data.items.sarameya.t3[k][4] = false;
                    end
                end
            end
        end
    end
    for k,v in pairs(data.items.sarameya.t4) do
        local count1 = 0;
        local count2 = 0;
        local str1 = v[1];
        local str2 = v[2];
        local popitem = AshitaCore:GetResourceManager():GetItemByName(str1, 0);
        local trophy = AshitaCore:GetResourceManager():GetItemByName(str2, 0);
        for x = 0, 16 do
            for y = 0, AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) do
                local tempitem = AshitaCore:GetMemoryManager():GetInventory():GetContainerItem(x, y);
                if (popitem ~= nil and tempitem ~= nil and popitem.Id == tempitem.Id) then
                    v[3] = true;
                    count1 = count1 +1;
                end
                if (trophy ~= nil and tempitem ~= nil and trophy.Id == tempitem.Id) then
                    v[4] = true;
                    count2 = count2 +1;
                end
                if x == 16 and y == AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) then
                    if count1 == 0 then
                        data.items.sarameya.t4[k][3] = false;
                    end
                    if count2 == 0 then
                        data.items.sarameya.t4[k][4] = false;
                    end
                end
            end
        end
    end

    for k,v in pairs(data.items.tyger.t1) do
        local count1 = 0;
        local count2 = 0;
        local str1 = v[1];
        local str2 = v[2];
        local popitem = AshitaCore:GetResourceManager():GetItemByName(str1, 0);
        local trophy = AshitaCore:GetResourceManager():GetItemByName(str2, 0);
        for x = 0, 16 do
            for y = 0, AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) do
                local tempitem = AshitaCore:GetMemoryManager():GetInventory():GetContainerItem(x, y);
                if (popitem ~= nil and tempitem ~= nil and popitem.Id == tempitem.Id) then
                    v[3] = true;
                    count1 = count1 +1;
                end
                if (trophy ~= nil and tempitem ~= nil and trophy.Id == tempitem.Id) then
                    v[4] = true;
                    count2 = count2 +1;
                end
                if x == 16 and y == AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) then
                    if count1 == 0 then
                        data.items.tyger.t1[k][3] = false;
                    end
                    if count2 == 0 then
                        data.items.tyger.t1[k][4] = false;
                    end
                end
            end
        end
    end
    for k,v in pairs(data.items.tyger.t2) do
        local count1 = 0;
        local count2 = 0;
        local str1 = v[1];
        local str2 = v[2];
        local popitem = AshitaCore:GetResourceManager():GetItemByName(str1, 0);
        local trophy = AshitaCore:GetResourceManager():GetItemByName(str2, 0);
        for x = 0, 16 do
            for y = 0, AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) do
                local tempitem = AshitaCore:GetMemoryManager():GetInventory():GetContainerItem(x, y);
                if (popitem ~= nil and tempitem ~= nil and popitem.Id == tempitem.Id) then
                    v[3] = true;
                    count1 = count1 +1;
                end
                if (trophy ~= nil and tempitem ~= nil and trophy.Id == tempitem.Id) then
                    v[4] = true;
                    count2 = count2 +1;
                end
                if x == 16 and y == AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) then
                    if count1 == 0 then
                        data.items.tyger.t2[k][3] = false;
                    end
                    if count2 == 0 then
                        data.items.tyger.t2[k][4] = false;
                    end
                end
            end
        end
    end
    for k,v in pairs(data.items.tyger.t3) do
        local count1 = 0;
        local count2 = 0;
        local str1 = v[1];
        local str2 = v[2];
        local popitem = AshitaCore:GetResourceManager():GetItemByName(str1, 0);
        local trophy = AshitaCore:GetResourceManager():GetItemByName(str2, 0);
        for x = 0, 16 do
            for y = 0, AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) do
                local tempitem = AshitaCore:GetMemoryManager():GetInventory():GetContainerItem(x, y);
                if (popitem ~= nil and tempitem ~= nil and popitem.Id == tempitem.Id) then
                    v[3] = true;
                    count1 = count1 +1;
                end
                if (trophy ~= nil and tempitem ~= nil and trophy.Id == tempitem.Id) then
                    v[4] = true;
                    count2 = count2 +1;
                end
                if x == 16 and y == AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) then
                    if count1 == 0 then
                        data.items.tyger.t3[k][3] = false;
                    end
                    if count2 == 0 then
                        data.items.tyger.t3[k][4] = false;
                    end
                end
            end
        end
    end
    for k,v in pairs(data.items.tyger.t4) do
        local count1 = 0;
        local count2 = 0;
        local str1 = v[1];
        local str2 = v[2];
        local popitem = AshitaCore:GetResourceManager():GetItemByName(str1, 0);
        local trophy = AshitaCore:GetResourceManager():GetItemByName(str2, 0);
        for x = 0, 16 do
            for y = 0, AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) do
                local tempitem = AshitaCore:GetMemoryManager():GetInventory():GetContainerItem(x, y);
                if (popitem ~= nil and tempitem ~= nil and popitem.Id == tempitem.Id) then
                    v[3] = true;
                    count1 = count1 +1;
                end
                if (trophy ~= nil and tempitem ~= nil and trophy.Id == tempitem.Id) then
                    v[4] = true;
                    count2 = count2 +1;
                end
                if x == 16 and y == AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) then
                    if count1 == 0 then
                        data.items.tyger.t4[k][3] = false;
                    end
                    if count2 == 0 then
                        data.items.tyger.t4[k][4] = false;
                    end
                end
            end
        end
    end
    for k,v in pairs(data.items.pw) do
        local count1 = 0;
        local str1 = v[1];
        local popitem = AshitaCore:GetResourceManager():GetItemByName(str1, 0);
        for x = 0, 16 do
            for y = 0, AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) do
                local tempitem = AshitaCore:GetMemoryManager():GetInventory():GetContainerItem(x, y);
                if (popitem ~= nil and tempitem ~= nil and popitem.Id == tempitem.Id) then
                    v[2] = true;
                    count1 = count1 +1;
                end
                if x == 16 and y == AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) then
                    if count1 == 0 then
                        data.items.pw[k][2] = false;
                    end
                end
            end
        end
    end
end

function interface.itemcheck(str)
    local item = AshitaCore:GetResourceManager():GetItemByName(str, 0);
    for x = 0, 1 do
        for y = 0, AshitaCore:GetMemoryManager():GetInventory():GetContainerCountMax(x) do
            local tempitem = AshitaCore:GetMemoryManager():GetInventory():GetContainerItem(x, y);
            if (item ~= nil and tempitem ~= nil and item.Id == tempitem.Id) then
                return true;
            end
        end
    end
    
    return false;
end

function interface.dotrade()
    local target = GetEntity(AshitaCore:GetMemoryManager():GetTarget():GetTargetIndex(0));
    if target == nil then
        print(chat.header(addon.name) .. chat.message('Nothing targeted'));
        return;
    end

    for k,v in pairs(data.tradeitems) do
        if target.ServerId == k then
            if math.sqrt(target.Distance) > 6 then
                print(chat.header(addon.name) .. chat.message('Target is too far away'));
                return;
            else
                if not interface.itemcheck(v) then
                    print(chat.header(addon.name) .. chat.message('Missing ' .. v .. ' in inventory'));
                return;
                else
                    AshitaCore:GetChatManager():QueueCommand(1, '/item "' .. v .. '" <t>');
                    print(chat.header(addon.name) .. chat.message('Trading ' .. v));
                    return;
                end
            end
        end
    end
    print(chat.header(addon.name) .. chat.message('No trade Zeni NM ??? targeted'));
end

function interface.comma_value(n) --credit--http://richard.warburton.it
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

return interface;