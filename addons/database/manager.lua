local modifind = require('modifind');
local manager = T{
    nuggets = true;
    gems = true;
    animas = true;
    matters = true;
    guilditemsgil = 0;
    plasm = 0;
    pointsmap = {50, 80, 120, 170, 220, 280, 340, 410, 480, 560, 650, 750, 860, 980};
    expmap = {2500,5550,8721,11919,15122,18327,21532,24737,27942,31147,41205,48130,53677,58618,63292,67848,72353,76835,81307,85775,109112,127014,141329,153277,163663,173018,181692,189917,197845,205578,258409,307400,353012,395691,435673,473392,509085,542995,575336,606296,769426,951369,1154006,1379407,1629848,1907833,2216116,2557728,2936001,3354601,3817561};
    jobs = {};
};

function manager.UpdateJobs()
    local player = AshitaCore:GetMemoryManager():GetPlayer();
    local jobleveltotal = 0.0;
    local JPspenttotal = 0.0;
    local masterexpspent = 0.0;
    local masterexptotal = 0.0;
    local joblevelmax = 99.0 * #interface.defaults.jobsabrv;
    local JPmax = 2100.0 * #interface.defaults.jobsabrv;
    
    for n = 1, #interface.defaults.jobsabrv do
        local mLV = player:GetJobMasterLevel(n);
        for x = 1, #manager.expmap do
            masterexptotal = masterexptotal + manager.expmap[x];
        end
        manager.jobs[n] = {player:GetJobLevel(n),player:GetJobPointsSpent(n),mLV,player:GetJobPoints(n)};
        jobleveltotal = jobleveltotal + player:GetJobLevel(n);
        JPspenttotal = JPspenttotal + player:GetJobPointsSpent(n);
        for l = mLV, 1, -1 do
            if l == mLV then
                masterexpspent = masterexpspent + player:GetMasteryExp();
            else
                masterexpspent = masterexpspent + manager.expmap[mLV];
            end
        end
    end
    interface.data.progress.jobs = {(jobleveltotal / joblevelmax),(JPspenttotal / JPmax),(masterexpspent / masterexptotal)};
end

function manager.DisplayJobs()
    imgui.BeginTable('jobs table', 5, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'JOB');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Job Level');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Job Points Spent');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Master Level');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Job Points Current');

        for n=1, #interface.defaults.jobsabrv do
            imgui.TableNextRow();imgui.TableNextColumn();imgui.TextColored(interface.colors.header, interface.defaults.jobsabrv[n]);
            for x = 1, 4 do 
                local t = T{};
                imgui.TableNextColumn();
                if (manager.jobs[n] ~= nil) then
                    t:merge(manager.jobs[n], true);
                    if ((x == 1) and (t[x] == 99)) or ((x == 2) and (t[x] == 2100)) or ((x == 3) and (t[x] == 50)) or ((x == 4) and (t[x] == 500)) then
                        imgui.TextColored(interface.colors.green, tostring(t[x]));
                    else
                        imgui.Text(tostring(t[x]));
                    end
                    
                else
                    imgui.Text('0');
                end
            end
        end
    imgui.EndTable();
    imgui.NewLine();imgui.Separator();imgui.NewLine();
    imgui.TextColored(interface.colors.green, 'Total JOB Level Completion:');
    imgui.ProgressBar(interface.data.progress.jobs[1], 10);imgui.NewLine();
    imgui.TextColored(interface.colors.green, 'Total JOB Points Completion:');
    imgui.ProgressBar(interface.data.progress.jobs[2], 10);imgui.NewLine();
    imgui.TextColored(interface.colors.green, 'Total JOB Master Level Completion:');
    imgui.ProgressBar(interface.data.progress.jobs[3], 100);imgui.NewLine();
    if (imgui.Button('Update Jobs')) then
        print(chat.header(addon.name) .. chat.message('Updated Jobs'));
        manager.UpdateJobs();
    end
end

function manager.UpdateRelics()
    local itemcounts = {0,0,0,0,0}; --{bynes, bronze, shells, marrows, plutons,}
    local itemcountsIDs = {1455,1452,1449,3502,4059};
    local itemcountsIDsHundos = {1456,1453,1450};
    local itemcountsIDsThousands = {1457,1454,1451};

    for weapon = 1, #interface.defaults.weapons.relics do
        -- for stage = #interface.defaults.weapons.relics[weapon],1,-1 do
            local stage = modifind.searchIdTable(interface.defaults.weapons.relics[weapon]:reverse());
            if (stage) then
            -- if (modifind.searchId(interface.defaults.weapons.relics[weapon][stage])) then
                if (stage == #interface.defaults.weapons.relics[weapon]) then
                    interface.data.progress.weapons.relics[weapon][3] = modifind.checkItemRankInfo(interface.defaults.weapons.relics[weapon][stage]);
                    interface.data.progress.weapons.relics[weapon][2] = stage;
                    -- break;
                else
                    interface.data.progress.weapons.relics[weapon][2] = stage;
                    for x = stage + 1, #interface.defaults.weapons.relics[weapon] do
                        for c = 1, #itemcounts do
                            itemcounts[c] = itemcounts[c] + interface.defaults.weapons.relicsreq[x][weapon][c];
                        end
                    end
                    -- break;
                end
            else
            -- elseif (stage == 1) and (modifind.searchId(interface.defaults.weapons.relics[weapon][stage]) == false) then
                for x = 1, #interface.defaults.weapons.relics[weapon] do
                    for c = 1, #itemcounts do
                        itemcounts[c] = itemcounts[c] + interface.defaults.weapons.relicsreq[x][weapon][c];
                    end
                end
            end
        -- end
    end

    for c = 1, #itemcounts do
        interface.data.progress.weapons.relicsneeds[c] = itemcounts[c] - modifind.countItemId(itemcountsIDs[c]);
        if c <= 3 then
            interface.data.progress.weapons.relicsneeds[c] = interface.data.progress.weapons.relicsneeds[c] - 100*modifind.countItemId(itemcountsIDsHundos[c]);
            interface.data.progress.weapons.relicsneeds[c] = interface.data.progress.weapons.relicsneeds[c] - 10000*modifind.countItemId(itemcountsIDsThousands[c]);
        end
    end

    local points = 0;
    for weapon = 1, #interface.data.progress.weapons.relics do
        if interface.data.progress.weapons.relics[weapon][3] == 0 then
            for stage = interface.data.progress.weapons.relics[weapon][3] + 1, #manager.pointsmap do
                points = points + manager.pointsmap[stage];
            end
        else
            for stage = interface.data.progress.weapons.relics[weapon][3], #manager.pointsmap do
                points = points + manager.pointsmap[stage];
            end
        end
    end
    interface.data.progress.weapons.relicsneeds[6] = (points / 10) - modifind.countItemId(9875);
end

function manager.DisplayRelics()
    imgui.BeginTable('relics table', 11, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'WEAPONS');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Base Wep');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Stage 2');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Stage 3');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Stage 4');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv. 75');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv. 95');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv. 99');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv.119 I');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv.119 III');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Augmented');
        imgui.TableNextRow();

        for w = 1, #interface.defaults.weapons.relics do
            for i = 1, 10 do
                if (w == 15 and i == 1) then
                    imgui.TableNextRow(ImGuiTableRowFlags_Headers);
                    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'SPECIALS');
                    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Base Wep');
                    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Stage 2');
                    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Stage 3');
                    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Stage 4');
                    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv. 75');
                    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv. 95');
                    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv. 99');
                    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv. 99 GLOW');
                    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, '');
                    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, '');
                end

                if i == 1 then
                    imgui.TableNextColumn();
                    imgui.TextColored(interface.colors.header, interface.data.progress.weapons.relics[w][1]);
                    imgui.TableNextColumn();
                    if interface.data.progress.weapons.relics[w][2] >= i then
                        imgui.TextColored(interface.colors.green,'Yup');
                    else
                        imgui.TextColored(interface.colors.error,'Nupe');
                    end
                elseif w >= 15 and i >= 9 then
                    imgui.TableNextColumn();
                elseif i <= 9 then
                    imgui.TableNextColumn();
                    if interface.data.progress.weapons.relics[w][2] >= i then
                        imgui.TextColored(interface.colors.green,'Yup');
                    else
                        imgui.TextColored(interface.colors.error,'Nupe');
                    end
                else
                    imgui.TableNextColumn();
                    if interface.data.progress.weapons.relics[w][3] == 15 then
                        imgui.TextColored(interface.colors.green, '15');
                    elseif interface.data.progress.weapons.relics[w][3] > 0 then
                        imgui.TextColored(interface.colors.warning, tostring(interface.data.progress.weapons.relics[w][3]));
                    else
                        imgui.TextColored(interface.colors.error, '0');
                    end
                end
            end
        end
    imgui.EndTable();
    imgui.NewLine();imgui.Separator();imgui.NewLine();
    imgui.BeginTable('relic needed table', 7, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Relic Need:');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Bynes');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Bronze');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Shells');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Marrows');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Plutons');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Sad Crystals');
        imgui.TableNextColumn();
        for a = 1, 6 do
            imgui.TableNextColumn();imgui.Text(tostring(interface.manager.comma_value(interface.data.progress.weapons.relicsneeds[a])));
        end
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Est. Gils:');
        imgui.TableNextColumn();imgui.Text(tostring(interface.manager.comma_value(interface.data.prices['Byne Bills'][1] * interface.data.progress.weapons.relicsneeds[1])));
        imgui.TableNextColumn();imgui.Text(tostring(interface.manager.comma_value(interface.data.prices['Bronze Pieces'][1] * interface.data.progress.weapons.relicsneeds[2])));
        imgui.TableNextColumn();imgui.Text(tostring(interface.manager.comma_value(interface.data.prices['T. Whiteshells'][1] * interface.data.progress.weapons.relicsneeds[3])));
        imgui.TableNextColumn();imgui.Text(tostring(interface.manager.comma_value(interface.data.prices['Umbral Marrow'][1] * interface.data.progress.weapons.relicsneeds[4])));
        imgui.TableNextColumn();imgui.Text(tostring(interface.manager.comma_value(interface.data.prices['Pluton'][1] * interface.data.progress.weapons.relicsneeds[5])));
        imgui.TableNextColumn();imgui.Text(tostring(interface.manager.comma_value(interface.data.prices['Sad. Crystals'][1] * interface.data.progress.weapons.relicsneeds[6])));
    imgui.EndTable();
    imgui.NewLine();imgui.NewLine();
    imgui.TextColored(interface.colors.header, 'Current Weapon Remaining Items (not currency):');
    imgui.InputInt(--[[interface.data.current['Relic'][1] ..]] 'Relic Pluton', interface.data.current['Pluton']);imgui.SameLine();
    if (interface.data.current['Pluton'][1] < 0) then
        interface.data.current['Pluton'][1] =  0;
    elseif (interface.data.current['Pluton'][1] > 10000) then
        interface.data.current['Pluton'][1] = 10000;
    end
    imgui.Text('Est. $: ');imgui.SameLine();
    imgui.Text(tostring(interface.manager.comma_value(interface.data.prices['Pluton'][1] * interface.data.current['Pluton'][1])));
    interface.data.current['Temp Sads'][1] = interface.data.current['Sad. Crystals'][1];--[1] for relics
    imgui.InputInt('Sad. Crystals', interface.data.current['Temp Sads']);imgui.SameLine();
    if (interface.data.current['Temp Sads'][1] < 0) then
        interface.data.current['Sad. Crystals'][1] =  0;
    elseif (interface.data.current['Temp Sads'][1] > 596) then
        interface.data.current['Sad. Crystals'][1] = 596;
    else
        interface.data.current['Sad. Crystals'][1] = interface.data.current['Temp Sads'][1];
    end
    imgui.Text('Est. $: ');imgui.SameLine();
    imgui.Text(tostring(interface.manager.comma_value(interface.data.prices['Sad. Crystals'][1] * interface.data.current['Sad. Crystals'][1])));
    imgui.NewLine();
    imgui.TextColored(interface.colors.header, 'Total Gil Est: ');imgui.SameLine();
    imgui.Text(tostring(interface.manager.comma_value(interface.data.prices['Pluton'][1] * interface.data.current['Pluton'][1] + interface.data.prices['Sad. Crystals'][1] * interface.data.current['Sad. Crystals'][1])));
    imgui.NewLine();
    if (imgui.Button('Update Relics')) then
        print(chat.header(addon.name) .. chat.message('Updating Relic Weapons'));
        interface.manager.UpdateRelics();
    end
end

function manager.UpdateMythics()
    local itemcounts = {0,0,0}; --{Alex,Scoria,Beitetsu}
    local itemcountsIDs = {2488,3503,4060};

    for weapon = 1, #interface.defaults.weapons.mythics do
        -- for stage = #interface.defaults.weapons.mythics[weapon],1,-1 do
            local stage = modifind.searchIdTable(interface.defaults.weapons.mythics[weapon]:reverse());
            if (stage) then
            -- if (modifind.searchId(interface.defaults.weapons.mythics[weapon][stage])) then
                if (stage == #interface.defaults.weapons.mythics[weapon]) then
                    interface.data.progress.weapons.mythics[weapon][3] = modifind.checkItemRankInfo(interface.defaults.weapons.mythics[weapon][stage]);
                    interface.data.progress.weapons.mythics[weapon][2] = stage;
                    -- break;
                else
                    interface.data.progress.weapons.mythics[weapon][2] = stage;
                    for x = stage + 1, #interface.defaults.weapons.mythics[weapon] do
                        for c = 1, #itemcounts do
                            itemcounts[c] = itemcounts[c] + interface.defaults.weapons.mythicsreq[x][weapon][c];
                        end
                    end
                    -- break;
                end
            else
            -- elseif (stage == 1) and (modifind.searchId(interface.defaults.weapons.mythics[weapon][stage]) == false) then
                for x = 1, #interface.defaults.weapons.mythics[weapon] do
                    for c = 1, #itemcounts do
                        itemcounts[c] = itemcounts[c] + interface.defaults.weapons.mythicsreq[x][weapon][c];
                    end
                end
            end
        -- end
    end

    for c = 1, #itemcounts do
        interface.data.progress.weapons.mythicsneeds[c] = itemcounts[c] - modifind.countItemId(itemcountsIDs[c]);
    end

    local points = 0;
    for weapon = 1, #interface.data.progress.weapons.mythics do
        if interface.data.progress.weapons.mythics[weapon][3] == 0 then
            for i = interface.data.progress.weapons.mythics[weapon][3] + 1, #manager.pointsmap do
                points = points + manager.pointsmap[i];
            end
        else
            for i = interface.data.progress.weapons.mythics[weapon][3], #manager.pointsmap do
                points = points + manager.pointsmap[i];
            end
        end
    end
    interface.data.progress.weapons.mythicsneeds[4] = (points / 10) - modifind.countItemId(9875);
end

function manager.DisplayMythics()
    if check == true then --bool that gets set true on first load and once again whenever the display is first rendered after being disabled
        AshitaCore:GetPacketManager():AddOutgoingPacket(0x10F, { 0x00, 0x00, 0x00, 0x00 });--update currency1
        -- print('Currency Test')
        check = false;
    end
    imgui.BeginTable('mythics table', 10, ImGuiTableFlags_Borders);
    imgui.TableNextRow(ImGuiTableRowFlags_Headers);
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'WEAPONS');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv. 75');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv. 80');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv. 85');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv. 90');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv. 95');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv. 99');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv.119 I');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv.119 III');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Augmented');
    imgui.TableNextRow();
    for w = 1, #interface.defaults.weapons.mythics, 1 do
        for i = 1, 9 do
            if i == 1 then
                imgui.TableNextColumn();
                imgui.TextColored(interface.colors.header, interface.data.progress.weapons.mythics[w][1]);
                imgui.TableNextColumn();
                if interface.data.progress.weapons.mythics[w][2] >= i then
                    imgui.TextColored(interface.colors.green,'Yup');
                else
                    imgui.TextColored(interface.colors.error,'Nupe');
                end
            elseif i <= 8 then
                imgui.TableNextColumn();
                if interface.data.progress.weapons.mythics[w][2] >= i then
                    imgui.TextColored(interface.colors.green,'Yup');
                else
                    imgui.TextColored(interface.colors.error,'Nupe');
                end
            else
                imgui.TableNextColumn();
                if interface.data.progress.weapons.mythics[w][3] == 15 then
                    imgui.TextColored(interface.colors.green, '15');
                elseif interface.data.progress.weapons.mythics[w][3] > 0 then
                    imgui.TextColored(interface.colors.warning, tostring(interface.data.progress.weapons.mythics[w][3]));
                else
                    imgui.TextColored(interface.colors.error, '0');
                end
            end
        end
    end
    imgui.EndTable();
    imgui.NewLine();imgui.Separator();imgui.NewLine();
    imgui.BeginTable('mythic needed table', 5, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Mythic Need:');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Alex');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Mulcibar\'s Scoria');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Beitetsu');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Sad Crystals');
        imgui.TableNextColumn();
        imgui.TableNextColumn();imgui.Text(tostring(interface.manager.comma_value(interface.data.progress.weapons.mythicsneeds[1])));
        imgui.TableNextColumn();imgui.Text(tostring(interface.manager.comma_value(interface.data.progress.weapons.mythicsneeds[2])));
        imgui.TableNextColumn();imgui.Text(tostring(interface.manager.comma_value(interface.data.progress.weapons.mythicsneeds[3])));
        imgui.TableNextColumn();imgui.Text(tostring(interface.manager.comma_value(interface.data.progress.weapons.mythicsneeds[4])));
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Est. Gils:');
        imgui.TableNextColumn();imgui.Text(tostring(interface.manager.comma_value(interface.data.prices['Alexandrite'][1] * interface.data.progress.weapons.mythicsneeds[1])));
        imgui.TableNextColumn();imgui.Text(tostring(interface.manager.comma_value(interface.data.prices['Mulcibar\'s Scoria'][1] * interface.data.progress.weapons.mythicsneeds[2])));
        imgui.TableNextColumn();imgui.Text(tostring(interface.manager.comma_value(interface.data.prices['Beitetsu'][1] * interface.data.progress.weapons.mythicsneeds[3])));
        imgui.TableNextColumn();imgui.Text(tostring(interface.manager.comma_value(interface.data.prices['Sad. Crystals'][1] * interface.data.progress.weapons.mythicsneeds[4])));
    imgui.EndTable();
    imgui.NewLine();
    imgui.TextColored(interface.colors.header, 'Current Weapon Remaining Items:');
    imgui.TextColored(interface.colors.header, 'Tokens: ');imgui.SameLine();imgui.Text(interface.manager.comma_value(150000 - interface.data.current['Tokens'][1]));imgui.SameLine();
    imgui.Text('(Est. Runs:');imgui.SameLine();
    if (interface.data.current['Tokens'][1] < 150000) then
        imgui.Text(tostring(tonumber(('%2i'):fmt((150000 - interface.data.current['Tokens'][1])/1500)) .. ')'));imgui.SameLine();
    else
        imgui.Text('0)');imgui.SameLine();
    end
    imgui.TextColored(interface.colors.header, '     Ichor: ')imgui.SameLine();imgui.Text(interface.manager.comma_value(100000 - interface.data.current['Ichor'][1]));imgui.SameLine();
    imgui.Text('(Est. Runs:');imgui.SameLine();
    if (interface.data.current['Ichor'][1] < 100000) then
        imgui.Text(tostring(tonumber(('%2i'):fmt((100000 - interface.data.current['Ichor'][1])/1920)) .. ')'));imgui.SameLine();
    else
        imgui.Text('0)');imgui.SameLine();
    end
    imgui.NewLine();
    imgui.InputInt(--[[interface.data.current['Mythic'][1] .. ]]'Alexandrite', interface.data.current['Alexandrite']);imgui.SameLine();
    if (interface.data.current['Alexandrite'][1] < 0) then
        interface.data.current['Alexandrite'][1] =  0;
    elseif (interface.data.current['Alexandrite'][1] > 30000) then
        interface.data.current['Alexandrite'][1] = 30000;
    end
    imgui.Text('Est. $: ');imgui.SameLine();
    imgui.Text(tostring(interface.manager.comma_value(interface.data.prices['Alexandrite'][1] * interface.data.current['Alexandrite'][1])));
    imgui.InputInt(--[[interface.data.current['Mythic'][2] ..]] 'Mythic Beitetsu', interface.data.current['Beitetsu']);imgui.SameLine();
    if (interface.data.current['Beitetsu'][1] < 0) then
        interface.data.current['Beitetsu'][1] =  0;
    elseif (interface.data.current['Beitetsu'][1] > 10000) then
        interface.data.current['Beitetsu'][1] = 10000;
    end
    imgui.Text('Est. $: ');imgui.SameLine();
    imgui.Text(tostring(interface.manager.comma_value(interface.data.prices['Beitetsu'][1] * interface.data.current['Beitetsu'][1])));
    interface.data.current['Temp Sads'][1] = interface.data.current['Sad. Crystals'][2];--[2] for mythics
    imgui.InputInt('Sad. Crystals', interface.data.current['Temp Sads']);imgui.SameLine();
    if (interface.data.current['Temp Sads'][1] < 0) then
        interface.data.current['Sad. Crystals'][2] =  0;
    elseif (interface.data.current['Temp Sads'][1] > 596) then
        interface.data.current['Sad. Crystals'][2] = 596;
    else
        interface.data.current['Sad. Crystals'][2] = interface.data.current['Temp Sads'][1];
    end
    imgui.Text('Est. $: ');imgui.SameLine();
    imgui.Text(tostring(interface.manager.comma_value(interface.data.prices['Sad. Crystals'][1] * interface.data.current['Sad. Crystals'][2])));
    imgui.NewLine();
    imgui.TextColored(interface.colors.header, 'Total Gil Est: ');imgui.SameLine();
    imgui.Text(tostring(interface.manager.comma_value(interface.data.prices['Alexandrite'][1] * interface.data.current['Alexandrite'][1] + interface.data.prices['Beitetsu'][1] * interface.data.current['Beitetsu'][1] + interface.data.prices['Sad. Crystals'][1] * interface.data.current['Sad. Crystals'][1])));
    if (imgui.Button('Update Mythics')) then
        print(chat.header(addon.name) .. chat.message('Updated Mythic Weapons'));
        interface.manager.UpdateMythics();
    end
end

function manager.UpdateEmpyreans()
    local itemcounts = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}; --{chloris,glavoid,briareus,cara,fistule,kukulkan,ironplates,ulhuadshi,itzpapalotl,sobek,lanterns,bukhis,sedna,colorless soul,dragua,orthus,apademak,isgebind,alfard,azdaja,HMP,dross,cinder,boulders}
    local itemcountsIDs = {2928,2927,2929,2930,2931,2932,3293,2963,2962,2964,2965,2966,2967,3294,3288,3287,3289,3290,3291,3292,3509,3498,3499,4061};

    for weapon = 1, #interface.defaults.weapons.empyreans do
        -- for i = #interface.defaults.weapons.empyreans[weapon],1,-1 do
            local stage = modifind.searchIdTable(interface.defaults.weapons.empyreans[weapon]:reverse());
            if (stage) then
            -- if (modifind.searchId(interface.defaults.weapons.empyreans[weapon][i])) then
                if (stage == #interface.defaults.weapons.empyreans[weapon]) then
                    interface.data.progress.weapons.empyreans[weapon][3] = modifind.checkItemRankInfo(interface.defaults.weapons.empyreans[weapon][stage]);
                    interface.data.progress.weapons.empyreans[weapon][2] = stage;
                    -- break;
                elseif (weapon == 15 or weapon == 16) and (stage == 2) then
                -- elseif (w == 15 or w == 16) and (i == 2) and (modifind.searchId(interface.defaults.weapons.empyreans[weapon][i])) then
                    if (modifind.checkItemRankInfo(interface.defaults.weapons.empyreans[weapon][stage]) == true) then --leave the == true here explicitly for empy shield/harp
                        interface.data.progress.weapons.empyreans[weapon][2] = stage;
                        for x = stage, #interface.defaults.weapons.empyreans[weapon] do
                            for c = 1, #itemcounts do
                                itemcounts[c] = itemcounts[c] + interface.defaults.weapons.empyreansreq[x][weapon][c];
                            end
                        end
                    else
                        interface.data.progress.weapons.empyreans[weapon][2] = stage;
                        for x = 1, #interface.defaults.weapons.empyreans[weapon] do
                            for c = 1, #itemcounts do
                                itemcounts[c] = itemcounts[c] + interface.defaults.weapons.empyreansreq[x][weapon][c];
                            end
                        end
                    end
                    -- break;
                else
                    interface.data.progress.weapons.empyreans[weapon][2] = stage;
                    for x = stage + 1, #interface.defaults.weapons.empyreans[weapon] do
                        for c = 1, #itemcounts do
                            itemcounts[c] = itemcounts[c] + interface.defaults.weapons.empyreansreq[x][weapon][c];
                        end
                    end
                    -- break;
                end
            else
            -- elseif (i == 1) and (modifind.searchId(interface.defaults.weapons.empyreans[weapon][i]) == false) then
                for x = 1, #interface.defaults.weapons.empyreans[weapon] do
                    for c = 1, #itemcounts do
                        itemcounts[c] = itemcounts[c] + interface.defaults.weapons.empyreansreq[x][weapon][c];
                    end
                end
            end
        -- end
    end

    for c = 1, #itemcounts do
        interface.data.progress.weapons.empyreansneeds[c] = itemcounts[c] - modifind.countItemId(itemcountsIDs[c]);
    end

    local points = 0;
    for weapon = 1, #interface.data.progress.weapons.empyreans do
        if interface.data.progress.weapons.empyreans[weapon][3] == 0 then
            for i = interface.data.progress.weapons.empyreans[weapon][3] + 1, #manager.pointsmap do
                points = points + manager.pointsmap[i];
            end
        else
            for i = interface.data.progress.weapons.empyreans[weapon][3], #manager.pointsmap do
                points = points + manager.pointsmap[i];
            end
        end
    end
    interface.data.progress.weapons.empyreansneeds[25] = (points / 10) - modifind.countItemId(9875);
end

function manager.DisplayEmpyreans()
    imgui.BeginTable('empyreans table', 9, ImGuiTableFlags_Borders);
    imgui.TableNextRow(ImGuiTableRowFlags_Headers);
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'WEAPONS');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv. 80');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv. 85');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv. 90');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv. 95');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv. 99');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv.119 I');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv.119 III');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Augment Rank');
    imgui.TableNextRow();
    for w = 1, #interface.defaults.weapons.empyreans -2, 1 do
        for i = 1, 8 do
            if i == 1 then
                imgui.TableNextColumn();
                imgui.TextColored(interface.colors.header, interface.data.progress.weapons.empyreans[w][1]);
                imgui.TableNextColumn();
                if interface.data.progress.weapons.empyreans[w][2] >= i then
                    imgui.TextColored(interface.colors.green,'Yup');
                else
                    imgui.TextColored(interface.colors.error,'Nupe');
                end
            elseif i <= 7 then
                imgui.TableNextColumn();
                if interface.data.progress.weapons.empyreans[w][2] >= i then
                    imgui.TextColored(interface.colors.green,'Yup');
                else
                    imgui.TextColored(interface.colors.error,'Nupe');
                end
            else
                imgui.TableNextColumn();
                if interface.data.progress.weapons.empyreans[w][3] == 15 then
                    imgui.TextColored(interface.colors.green, '15');
                elseif interface.data.progress.weapons.empyreans[w][3] > 0 then
                    imgui.TextColored(interface.colors.warning, tostring(interface.data.progress.weapons.empyreans[w][3]));
                else
                    imgui.TextColored(interface.colors.error, '0');
                end
            end
        end
    end
    imgui.TableNextRow(ImGuiTableRowFlags_Headers);
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'SPECIALS');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Base');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Base v2');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv. 85');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv. 90');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv. 95');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv. 99');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lv. 99 Glow');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, '');
    for s = #interface.defaults.weapons.empyreans -1, #interface.defaults.weapons.empyreans do
        for i = 1, 8 do
            if i == 1 then
                imgui.TableNextColumn();
                imgui.TextColored(interface.colors.header, interface.data.progress.weapons.empyreans[s][1]);
                imgui.TableNextColumn();
                if interface.data.progress.weapons.empyreans[s][2] >= i then
                    imgui.TextColored(interface.colors.green,'Yup');
                else
                    imgui.TextColored(interface.colors.error,'Nupe');
                end
            elseif i <= 7 then
                imgui.TableNextColumn();
                if interface.data.progress.weapons.empyreans[s][2] >= i then 
                    imgui.TextColored(interface.colors.green,'Yup');
                else
                    imgui.TextColored(interface.colors.error,'Nupe');
                end
            else
                imgui.TableNextColumn();
            end
        end
    end
    imgui.EndTable();
    imgui.NewLine();imgui.Separator();imgui.NewLine();
    imgui.BeginTable('aby1 needed table', 8, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Abyssea Need:');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Chloris');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Glavoid');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Briareus');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Cara');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Fistule');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Kukulkan');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Iron Plates');
        imgui.TableNextColumn();
        for a = 1, 7 do
            imgui.TableNextColumn();imgui.Text(tostring(interface.data.progress.weapons.empyreansneeds[a]));
        end
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Ulhuadshi');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Itzpapalotl');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Sobek');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Lanterns');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Bukhis');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Sedna');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Souls');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'HMP');
        for b = 8, 14 do
            imgui.TableNextColumn();imgui.Text(tostring(interface.data.progress.weapons.empyreansneeds[b]));
        end
        imgui.TableNextColumn();imgui.Text(tostring(interface.manager.comma_value(interface.data.progress.weapons.empyreansneeds[21])));
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Dragua');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Orthrus');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Apademak');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Isgebind');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Alfard');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Azdaja');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Riftdross');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Riftcinder');
        for c = 15, 20 do
            imgui.TableNextColumn();imgui.Text(tostring(interface.data.progress.weapons.empyreansneeds[c]));
        end
        imgui.TableNextColumn();imgui.Text(tostring(interface.manager.comma_value(interface.data.progress.weapons.empyreansneeds[22])));
        imgui.TableNextColumn();imgui.Text(tostring(interface.manager.comma_value(interface.data.progress.weapons.empyreansneeds[23])));
    imgui.EndTable();
    imgui.NewLine();
    imgui.TextColored(interface.colors.header, 'Sad Crystals Needed: ');imgui.SameLine();
    imgui.Text(tostring(interface.manager.comma_value(interface.data.progress.weapons.empyreansneeds[25])));
    imgui.TextColored(interface.colors.header, 'Est. Gil Needed: ');imgui.SameLine();
    imgui.Text(tostring(interface.manager.comma_value(interface.data.prices['Sad. Crystals'][1] * interface.data.progress.weapons.empyreansneeds[25])));
    imgui.NewLine();
    if (imgui.Button('Update Empyreans')) then
        print(chat.header(addon.name) .. chat.message('Updated Empyrean Weapons'));
        interface.manager.UpdateEmpyreans();
    end
end

function manager.UpdateErgons()
    interface.data.progress.weapons.ergonNeeds = {26198,8600000,20000,1192};--{bayld,plasm,beitetsu,sad crystals}

    for weapon = 1, #interface.data.progress.weapons.ergons do
        -- key item and item checks relating to each ergon
        for c = 2, #interface.data.progress.weapons.ergons[weapon] do
            if c <= 6 then
                local check = modifind.searchKeyItemName(interface.defaults.weapons.ergons[weapon][c]);
                if (check == false) and (c > 2) then
                    check = modifind.searchId(interface.defaults.weapons.ergons[weapon+2][c]);
                end
                interface.data.progress.weapons.ergons[weapon][c] = check;
                if check == true then
                    for b = c -1, 2, -1 do
                        interface.data.progress.weapons.ergons[weapon][b] = check;
                    end
                end
            elseif c <= 8 then
                local check = modifind.searchId(interface.defaults.weapons.ergons[weapon][c]);
                interface.data.progress.weapons.ergons[weapon][c] = check;
                if check == true then
                    for b = c -1, 2, -1 do
                        interface.data.progress.weapons.ergons[weapon][b] = check;
                    end
                end
            elseif c == 9 then
                interface.data.progress.weapons.ergons[weapon][c] = modifind.checkItemRankInfo(interface.defaults.weapons.ergons[weapon][c - 1]);
            end
        end
    end

    for weapon = 1, #interface.data.progress.weapons.ergons do
        local needs = {{0,0,100,500,2500,9999,0,0,0},{0,0,0,900000,900000,2500000,0,0,0},{0,0,0,0,0,0,0,10000,0},{0,0,0,0,0,0,0,0,596}};--{bayld,plasm,beitetsu,sad crystals} needed for each of the nine stages
        -- local map = {50, 80, 120, 170, 220, 280, 340, 410, 480, 560, 650, 750, 960, 980};--points required for each rank, sad crystals worth 10 points each...
        for x = #interface.data.progress.weapons.ergons[weapon], 2, -1 do
            if x == 9 then
                for m = 1, #manager.pointsmap do
                    if interface.data.progress.weapons.ergons[weapon][x] > m then
                        needs[4][x] = needs[4][x] - manager.pointsmap[m];
                    end
                    if interface.data.progress.weapons.ergons[weapon][x] == #manager.pointsmap then
                        needs[4][x] = 0;
                    end
                end
            elseif interface.data.progress.weapons.ergons[weapon][x] == true then
                for n = 1, #interface.data.progress.weapons.ergonNeeds do
                    local count = 0;
                    for c = x, 2, -1 do
                        count = count + needs[n][c];
                        needs[n][c] = 0;
                    end
                    interface.data.progress.weapons.ergonNeeds[n] = interface.data.progress.weapons.ergonNeeds[n] - count;
                end
            end
        end
    end
end

function manager.DisplayErgons()
    if check == true then --bool that gets set true on first load and once again whenever the display is first rendered after being disabled
        AshitaCore:GetPacketManager():AddOutgoingPacket(0x115, { 0x00, 0x00, 0x00, 0x00 });--update currency2
        -- print('Currency Test')
        check = false;
    end
    imgui.BeginTable('ergon table', #interface.defaults.weapons.ergons[1], ImGuiTableFlags_Borders);
    imgui.TableNextRow(ImGuiTableRowFlags_Headers);
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'WEAPONS');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Quest');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Part 1');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Part 2');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Part 3');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Part 4');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Base Ergon');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Afterglow');
    imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Augmented');
    imgui.TableNextRow();
    for w = 1, 2 do
        for c = 1, #interface.defaults.weapons.ergons[w] do
            if c == 1 then
                imgui.TableNextColumn();
                imgui.TextColored(interface.colors.header,tostring(interface.defaults.weapons.ergons[w][1]));
            elseif c <= 8 then
                imgui.TableNextColumn();
                if interface.data.progress.weapons.ergons[w][c] == true then
                    imgui.TextColored(interface.colors.green,'Yup');
                else
                    imgui.TextColored(interface.colors.error,'Nupe');
                end
            else
                imgui.TableNextColumn();
                local rank = interface.data.progress.weapons.ergons[w][9];
                local rankstring = tostring(rank);
                if rank == 0 then
                    imgui.TextColored(interface.colors.error, rankstring);
                elseif rank <= 14 then
                    imgui.TextColored(interface.colors.warning, rankstring);
                else
                    imgui.TextColored(interface.colors.green, rankstring);
                end
            end
        end
    end
    imgui.EndTable();
    imgui.NewLine();imgui.Separator();imgui.NewLine();
    imgui.BeginTable('ergon needed table', 5, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Ergon Need:');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Plasm');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'HP Bayld');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Beitetsu');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Sad Crystals');
        imgui.TableNextColumn();
        imgui.TableNextColumn();imgui.Text(manager.comma_value(interface.data.progress.weapons.ergonNeeds[1]));
        imgui.TableNextColumn();imgui.Text(manager.comma_value(interface.data.progress.weapons.ergonNeeds[2]));
        imgui.TableNextColumn();imgui.Text(manager.comma_value(interface.data.progress.weapons.ergonNeeds[3]));
        imgui.TableNextColumn();imgui.Text(manager.comma_value(interface.data.progress.weapons.ergonNeeds[4]));
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Est. Gils:');
        imgui.TableNextColumn();imgui.Text('Current: ' .. manager.comma_value(interface.data.current['Plasm'][1]));
        imgui.TableNextColumn();imgui.Text(tostring(interface.manager.comma_value(interface.data.prices['H-P Bayld'][1] * interface.data.progress.weapons.ergonNeeds[1])));
        imgui.TableNextColumn();imgui.Text(tostring(interface.manager.comma_value(interface.data.prices['Beitetsu'][1] * interface.data.progress.weapons.ergonNeeds[3])));
        imgui.TableNextColumn();imgui.Text(tostring(interface.manager.comma_value(interface.data.prices['Sad. Crystals'][1] * interface.data.progress.weapons.ergonNeeds[4])));
    imgui.EndTable();
    imgui.NewLine();
    imgui.TextColored(interface.colors.header, 'Current Weapon Remaining Items:');
    imgui.InputInt(--[[interface.data.current['H-P Bayld'][1] .. ]]'Traded H-P Bayld', interface.data.current['H-P Bayld']);imgui.SameLine();
    if (interface.data.current['H-P Bayld'][1] < 0) then
        interface.data.current['H-P Bayld'][1] =  0;
    elseif (interface.data.current['H-P Bayld'][1] > 30000) then
        interface.data.current['H-P Bayld'][1] = 30000;
    end
    imgui.Text('Est. $: ');imgui.SameLine();
    imgui.Text(tostring(interface.manager.comma_value(interface.data.prices['H-P Bayld'][1] * interface.data.current['H-P Bayld'][1])));
    interface.data.current['Temp Beit'][1] = interface.data.current['Beitetsu'][2];--[2] for ergons
    imgui.InputInt(--[[interface.data.current['Ergon'][1] ..]] 'Ergon Beitetsu', interface.data.current['Temp Beit']);imgui.SameLine();
    if (interface.data.current['Temp Beit'][1] < 0) then
        interface.data.current['Beitetsu'][2] =  0;
    elseif (interface.data.current['Temp Beit'][1] > 10000) then
        interface.data.current['Beitetsu'][2] = 10000;
    else
        interface.data.current['Beitetsu'][2] = interface.data.current['Temp Beit'][1];
    end
    imgui.Text('Est. $: ');imgui.SameLine();
    imgui.Text(tostring(interface.manager.comma_value(interface.data.prices['Beitetsu'][1] * interface.data.current['Beitetsu'][2])));
    interface.data.current['Temp Sads'][1] = interface.data.current['Sad. Crystals'][4];--[4] for ergons
    imgui.InputInt('Sad. Crystals', interface.data.current['Temp Sads']);imgui.SameLine();
    if (interface.data.current['Temp Sads'][1] < 0) then
        interface.data.current['Sad. Crystals'][4] =  0;
    elseif (interface.data.current['Temp Sads'][1] > 596) then
        interface.data.current['Sad. Crystals'][4] = 596;
    else
        interface.data.current['Sad. Crystals'][4] = interface.data.current['Temp Sads'][1];
    end
    imgui.Text('Est. $: ');imgui.SameLine();
    imgui.Text(tostring(interface.manager.comma_value(interface.data.prices['Sad. Crystals'][1] * interface.data.current['Sad. Crystals'][4])));
    imgui.NewLine();
    imgui.TextColored(interface.colors.header, 'Total Gil Est: ');imgui.SameLine();
    imgui.Text(tostring(interface.manager.comma_value(interface.data.prices['H-P Bayld'][1] * interface.data.current['H-P Bayld'][1] + interface.data.prices['Beitetsu'][1] * interface.data.current['Beitetsu'][2] + interface.data.prices['Sad. Crystals'][1] * interface.data.current['Sad. Crystals'][4])));
    imgui.NewLine();
    if (imgui.Button('Update Ergons')) then
        print(chat.header(addon.name) .. chat.message('Updated Ergon Weapons'));
        interface.manager.UpdateErgons();
    end
end

function manager.UpdatePrimes()
    local itemcounts = {0,0}; --{Gallimaufry,Eikondrite}
    local itemcountsIDs = {0,9929,};

    for weapon = 1, #interface.defaults.weapons.primes do
        local stage = modifind.searchIdTable(interface.defaults.weapons.primes[weapon]:reverse());
        if (stage) then
            if (stage == #interface.defaults.weapons.primes[weapon]) then
                -- interface.data.progress.weapons.primes[weapon][3] = modifind.checkItemRankInfo(interface.defaults.weapons.primes[weapon][stage]);
                interface.data.progress.weapons.primes[weapon][2] = stage;
            else
                interface.data.progress.weapons.primes[weapon][2] = stage;
                for x = stage + 1, #interface.defaults.weapons.primes[weapon] do
                    for c = 1, #itemcounts do
                        itemcounts[c] = itemcounts[c] + interface.defaults.weapons.primesreq[x][weapon][c];
                    end
                end
            end
        else
            for x = 1, #interface.defaults.weapons.primes[weapon] do
                for c = 1, #itemcounts do
                    itemcounts[c] = itemcounts[c] + interface.defaults.weapons.primesreq[x][weapon][c];
                end
            end
        end
    end

    for c = 1, #itemcounts do
        interface.data.progress.weapons.primesneeds[c] = itemcounts[c] - modifind.countItemId(itemcountsIDs[c]);
    end

    -- local points = 0;
    -- for weapon = 1, #interface.data.progress.weapons.primes do
    --     if interface.data.progress.weapons.primes[weapon][3] == 0 then
    --         for i = interface.data.progress.weapons.primes[weapon][3] + 1, #manager.pointsmap do
    --             points = points + manager.pointsmap[i];
    --         end
    --     else
    --         for i = interface.data.progress.weapons.primes[weapon][3], #manager.pointsmap do
    --             points = points + manager.pointsmap[i];
    --         end
    --     end
    -- end
    -- interface.data.progress.weapons.primesneeds[4] = (points / 10) - modifind.countItemId(9875);
end

function manager.DisplayPrimes()
    if check == true then --bool that gets set true on first load and once again whenever the display is first rendered after being disabled
        AshitaCore:GetPacketManager():AddOutgoingPacket(0x115, { 0x00, 0x00, 0x00, 0x00 });--update currency2galli
        check = false;
    end
    imgui.BeginTable('primes table', 3, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'WEAPONS');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Base Wep');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Stage 2');
        imgui.TableNextRow();
        for weapon = 1, #interface.defaults.weapons.primes do
            for stage = 1, 2 do
                if stage == 1 then
                    imgui.TableNextColumn();
                    imgui.TextColored(interface.colors.header, interface.data.progress.weapons.primes[weapon][1]);
                    imgui.TableNextColumn();
                    if interface.data.progress.weapons.primes[weapon][2] >= stage then
                        imgui.TextColored(interface.colors.green,'Yup');
                    else
                        imgui.TextColored(interface.colors.error,'Nupe');
                    end
                else--if stage <= 9 then
                    imgui.TableNextColumn();
                    if interface.data.progress.weapons.primes[weapon][2] >= stage then
                        imgui.TextColored(interface.colors.green,'Yup');
                    else
                        imgui.TextColored(interface.colors.error,'Nupe');
                    end
                -- else
                --     imgui.TableNextColumn();
                --     if interface.data.progress.weapons.primes[weapon][3] == 15 then
                --         imgui.TextColored(interface.colors.green, '15');
                --     elseif interface.data.progress.weapons.primes[weapon][3] > 0 then
                --         imgui.TextColored(interface.colors.warning, tostring(interface.data.progress.weapons.primes[weapon][3]));
                --     else
                --         imgui.TextColored(interface.colors.error, '0');
                --     end
                end
            end
        end
    imgui.EndTable();
    imgui.NewLine();imgui.Separator();imgui.NewLine();
    imgui.BeginTable('prime needed table', 3, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Primes Needs:');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Gallimaufry');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Eikondrite');
        imgui.TableNextColumn();
        imgui.TableNextColumn();imgui.Text(manager.comma_value(interface.data.progress.weapons.primesneeds[1]));
        imgui.TableNextColumn();imgui.Text(manager.comma_value(interface.data.progress.weapons.primesneeds[2]));
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Est. Gils:');
        imgui.TableNextColumn();imgui.Text('Current: ' .. manager.comma_value(interface.data.current['Gallimaufry'][1]));
    imgui.EndTable();
    imgui.NewLine();
    if (imgui.Button('Update Primes')) then
        print(chat.header(addon.name) .. chat.message('Updated Prime Weapons'));
        interface.manager.UpdatePrimes();
    end
end

function manager.UpdateAmbuWeps()
    for a = 1, #interface.defaults.weapons.ambu do
        local count = 1;
        if interface.data.progress.weapons.ambu[a][1] == #interface.defaults.weapons.ambu[a] then
            count = #interface.defaults.weapons.ambu[a] + 1;
        elseif interface.data.progress.weapons.ambu[a][1] == 0 then
        else count = interface.data.progress.weapons.ambu[a][1] end
        for b = count, #interface.defaults.weapons.ambu[a] do
            if (modifind.searchId(interface.defaults.weapons.ambu[a][b])) then
                interface.data.progress.weapons.ambu[a][1] = b;
            end
        end
    end
end

function manager.DisplayAmbuWeps()
    local items = T{0,0,0,0,0,0}; --voucher,nugget,gem,anima,matter,pulse,
    for a = 1, #interface.data.progress.weapons.ambu do
        if (interface.data.progress.weapons.ambu[a][1] < 5) then
            items[6] = items[6] + 1;
            items[5] = items[5] + 5;
        end
        if (interface.data.progress.weapons.ambu[a][1] < 4) then
            items[4] = items[4] + 5;
        end
        if (interface.data.progress.weapons.ambu[a][1] < 3) then
            items[3] = items[3] + 5;
        end
        if (interface.data.progress.weapons.ambu[a][1] < 2) then
            items[2] = items[2] + 5;
        end
        if (interface.data.progress.weapons.ambu[a][1] < 1) then
            items[1] = items[1] + 1;
        end
    end
    imgui.BeginTable('ambu weps table', 1, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'WEAPONS');
        for a = 1, #interface.data.progress.weapons.ambu do
            imgui.TableNextColumn();
            local temp = {interface.data.progress.weapons.ambu[a][1]};
            if (imgui.Combo(interface.data.progress.weapons.ambu[a][2], temp, 'None\0Tokko\0Ajja\0Eletta\0Kaja\0Complete\0')) then
                interface.data.progress.weapons.ambu[a][1] = temp[1];
            end
        end
    imgui.EndTable();
    imgui.NewLine();imgui.Separator();imgui.NewLine();
    imgui.BeginTable('ambu weps need', 6, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'NEEDED:');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Vouchers');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Nuggets');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Gems:');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Animas');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Matters');
        imgui.TableNextColumn();

        for b = 1, (#items -1) do
            imgui.TableNextColumn();
            imgui.Text(tostring(items[b]));
        end
        local pulsecount = 0;
        for i = 1, #interface.defaults.weapons.pulse do
            pulsecount = pulsecount + modifind.countItemId(interface.defaults.weapons.pulse[i]);
        end
        if (pulsecount > items[6]) then
            items[6] = 0
        else
            items[6] = items[6] - pulsecount;
        end
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Need Pulse Weapons:  ');
        imgui.TableNextColumn();imgui.Text(tostring(items[6]));

        interface.data.progress.weapons.ambuWepItems = items:merge(items, true);
    imgui.EndTable();
    imgui.NewLine();
    if (imgui.Button('Update Ambu Weps')) then
        print(chat.header(addon.name) .. chat.message('Updated Ambu Weapons'));
        interface.manager.UpdateAmbuWeps();
    end
end

function manager.UpdateWeapons()
	manager.UpdateRelics();
    manager.UpdateEmpyreans();
    manager.UpdateMythics();
    manager.UpdateErgons();
    manager.UpdatePrimes();
    manager.UpdateAmbuWeps();
end

function manager.UpdateAFGear()
    local countgear = 0;
    local totalgear = #interface.defaults.gear.af * #interface.defaults.gear.af[1] * #interface.defaults.gear.af[1][1];

    for job = 1, (#interface.defaults.gear.af - 1) do
        for slot = 1, #interface.defaults.gear.af[job] do
            local index;
            local myIndex = AshitaCore:GetMemoryManager():GetParty():GetMemberTargetIndex(0);
	        local my = GetEntity(myIndex);
            if job == 19 and (my.Race == 2 or my.Race == 4 or my.Race == 6 or my.Race == 7) then
                index = modifind.searchIdTable(interface.defaults.gear.af[23][slot]:reverse());
            else
                index = modifind.searchIdTable(interface.defaults.gear.af[job][slot]:reverse());
            end
            if (index) then
                if job == 21 or job == 22 then
                    interface.data.progress.gear.af[job][slot][1] = index + 2;--offset for geo and run for gear starting at 109
                else
                    interface.data.progress.gear.af[job][slot][1] = index;
                end
            end
            countgear = countgear + interface.data.progress.gear.af[job][slot][1];
        end
    end

    interface.data.progress.gear.afProgress[1] = countgear/totalgear;
    manager.CountAFGear();
end

function manager.CountAFGearInv(items)
    if items == nil then return end
    local chap1 = 0;local chap2 = 0;local slot1 = 0;local slot2 = 0;local slot3 = 0;
    
    for y=1, #items[1] do
        if y == 1 then -- set IDs for some of the variables
            chap1 = 4064;
            chap2 = 4069;
            slot1 = 844;
            slot2 = 8720;
            slot3 = 8983;
        elseif y == 2 then
            chap1 = 4065;
            chap2 = 4070;
            slot1 = 837;
            slot2 = 8722;
            slot3 = 8986;
        elseif y == 3 then
            chap1 = 4066;
            chap2 = 4071;
            slot1 = 1110;
            slot2 = 8724;
            slot3 = 8979;
        elseif y == 4 then
            chap1 = 4067;
            chap2 = 4072;
            slot1 = 836;
            slot2 = 8726;
            slot3 = 8988;
        elseif y == 5 then
            chap1 = 4068;
            chap2 = 4073;
            slot1 = 1311;
            slot2 = 8728;
            slot3 = 8981;
        end
        items[1][y][1] = 0 - modifind.countItemId(chap1); --countchapt 1-5
        items[2][y][1] = 0 - modifind.countItemId(chap2); --countchapt 6-10
        items[1][y][2] = 0 - modifind.countItemId(slot1); --count 109slot
        items[2][y][2] = 0 - modifind.countItemId(slot2); --count 1191slot
        items[3][y][1] = 0 - modifind.countItemId(slot3); --count 1192slot
    end

    local checks1 = {0,0,855,823,2340,2288,1699,752,664,657}; -- lv109 extra items in order of default array: blank,blank,tiger leather,gold thread,imp.silk cloth,karakul cloth,scarlet linen,gold sheet,DS sheet,Tama Hagane
    local checks2 = {0,0,862,2476,1132,2200,1313,668,758,658}; -- lv119+1 extra items in order of default array: blank,blank,behe leather, plat silk thread, raxa, twill damask, siren's hair, ori sheet, durium sheet, dama. ingot
    for i = 3, #items[1][1] do
        items[1][1][i] = 0 - modifind.countItemId(checks1[i]);
        items[2][1][i] = 0 - modifind.countItemId(checks2[i]);
    end

    local checks3 = {0,9253,9245,9251,9257,9255,9249,9247};-- lv119+1 extra items in order of default array: blank,S.Faulpie Leather,Cypress Log,Khoma Thread,Azure Leaf,Cyan Coral,Ruthenium Ore,Niobium Ore,
    for i = 3, #items[3][1] do
        items[3][1][i] = 0 - modifind.countItemId(checks3[i]);
    end

    local checks4 = {9303,9305,9304,9307,9306,9253,9245,9246,9251,9252,9258,9256,9250,9248,9254};-- lv119+1 extra items in order of default array: kin,kei,gin,fu,kyou,S.Faulpie Leather,Cypress Log,cypress Lbr,Khoma Thread,khoma cloth,Azure Cermet,Cyan Orb,Ruthenium Ingot,Niobium Ingot,Faulpie Leather
    for i = 3, #items[4][1] do
        items[4][1][i] = 0 - modifind.countItemId(checks4[i]);
    end

    return items;
end

function manager.CountAFGear()
    local cards = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    interface.data.progress.gear.afneed = {
        {{0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0}},
        {{0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0}},
        {{0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0}},
        {{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}}, 
    };
    interface.data.progress.gear.afneed = manager.CountAFGearInv(interface.data.progress.gear.afneed);

    for x = 1, #interface.data.progress.gear.af do
        for y = 1, #interface.data.progress.gear.af[x] do
            if interface.data.progress.gear.af[x][y][1] <= 2 then
                if interface.data.progress.gear.af[x][y][1] <= 1 then
                    interface.data.progress.gear.afneed[1][y][1] = interface.data.progress.gear.afneed[1][y][1] + 10;
                else
                    interface.data.progress.gear.afneed[1][y][1] = interface.data.progress.gear.afneed[1][y][1] + 5;
                end
                interface.data.progress.gear.afneed[1][y][2] = interface.data.progress.gear.afneed[1][y][2] + 1;
                if (x == 1) or (x == 9) then
                    interface.data.progress.gear.afneed[1][y][3] = interface.data.progress.gear.afneed[1][y][3] + 1;
                elseif (x == 2) or (x == 6) or (x == 19) then
                    interface.data.progress.gear.afneed[1][y][4] = interface.data.progress.gear.afneed[1][y][4] + 1;
                elseif (x == 3) or (x == 10) or (x == 16) then
                    interface.data.progress.gear.afneed[1][y][5] = interface.data.progress.gear.afneed[1][y][5] + 1;
                elseif (x == 4) or (x == 11) or (x == 17) or (x == 18) then
                    interface.data.progress.gear.afneed[1][y][6] = interface.data.progress.gear.afneed[1][y][6] + 1;
                elseif (x == 5) or (x == 15) or (x == 20) then
                    interface.data.progress.gear.afneed[1][y][7] = interface.data.progress.gear.afneed[1][y][7] + 1;
                elseif (x == 7) or (x == 14) then
                    interface.data.progress.gear.afneed[1][y][8] = interface.data.progress.gear.afneed[1][y][8] + 1;
                elseif (x == 8) then
                    interface.data.progress.gear.afneed[1][y][9] = interface.data.progress.gear.afneed[1][y][9] + 1;
                elseif (x == 12) or (x == 13) then
                    interface.data.progress.gear.afneed[1][y][10] = interface.data.progress.gear.afneed[1][y][10] + 1;
                end
            end
            if interface.data.progress.gear.af[x][y][1] <= 3 then
                interface.data.progress.gear.afneed[2][y][1] = interface.data.progress.gear.afneed[2][y][1] + 8;
                interface.data.progress.gear.afneed[2][y][2] = interface.data.progress.gear.afneed[2][y][2] + 1;
                if (x == 1) or (x == 9) then
                    interface.data.progress.gear.afneed[2][y][3] = interface.data.progress.gear.afneed[2][y][3] + 1;
                elseif (x == 2) or (x == 6) or (x == 19) then
                    interface.data.progress.gear.afneed[2][y][4] = interface.data.progress.gear.afneed[2][y][4] + 1;
                elseif (x == 3) or (x == 10) or (x == 16) or (x == 21) then
                    interface.data.progress.gear.afneed[2][y][5] = interface.data.progress.gear.afneed[2][y][5] + 1;
                elseif (x == 4) or (x == 11) or (x == 17) or (x == 18) then
                    interface.data.progress.gear.afneed[2][y][6] = interface.data.progress.gear.afneed[2][y][6] + 1;
                elseif (x == 5) or (x == 15) or (x == 20) then
                    interface.data.progress.gear.afneed[2][y][7] = interface.data.progress.gear.afneed[2][y][7] + 1;
                elseif (x == 7) or (x == 14) then
                    interface.data.progress.gear.afneed[2][y][8] = interface.data.progress.gear.afneed[2][y][8] + 1;
                elseif (x == 8) then
                    interface.data.progress.gear.afneed[2][y][9] = interface.data.progress.gear.afneed[2][y][9] + 1;
                elseif (x == 12) or (x == 13) or (x == 22) then
                    interface.data.progress.gear.afneed[2][y][10] = interface.data.progress.gear.afneed[2][y][10] + 1;
                end
            end
            if interface.data.progress.gear.af[x][y][1] <= 4 then
                interface.data.progress.gear.afneed[3][y][1] = interface.data.progress.gear.afneed[3][y][1] + 1;
                if (x == 1) or (x == 9) or (x == 11) then
                    interface.data.progress.gear.afneed[3][y][2] = interface.data.progress.gear.afneed[3][y][2] + 1;
                elseif (x == 2) or (x == 6) or (x == 19) then
                    interface.data.progress.gear.afneed[3][y][3] = interface.data.progress.gear.afneed[3][y][3] + 1;
                elseif (x == 3) or (x == 10) or (x == 16) or (x == 21) then
                    interface.data.progress.gear.afneed[3][y][4] = interface.data.progress.gear.afneed[3][y][4] + 1;
                elseif (x == 4) or (x == 17) or (x == 18) then
                    interface.data.progress.gear.afneed[3][y][5] = interface.data.progress.gear.afneed[3][y][5] + 1;
                elseif (x == 5) or (x == 15) or (x == 20) then
                    interface.data.progress.gear.afneed[3][y][6] = interface.data.progress.gear.afneed[3][y][6] + 1;
                elseif (x == 7) or (x == 14) then
                    interface.data.progress.gear.afneed[3][y][7] = interface.data.progress.gear.afneed[3][y][7] + 1;
                elseif (x == 8) or (x == 12) or (x == 13) or (x == 22) then
                    interface.data.progress.gear.afneed[3][y][8] = interface.data.progress.gear.afneed[3][y][8] + 1;
                end
                if (y == 1) then
                    cards[x] = cards[x] + 8;
                elseif (y == 2) then
                    cards[x] = cards[x] + 10;
                elseif (y == 3) then
                    cards[x] = cards[x] + 7;
                elseif (y == 4) then
                    cards[x] = cards[x] + 9;
                elseif (y == 5) then
                    cards[x] = cards[x] + 6;
                end
            end
            if interface.data.progress.gear.af[x][y][1] <= 5 then
                if (x == 1) or (x == 2) or (x == 7) or (x == 8) or (x == 12) then
                    interface.data.progress.gear.afneed[4][y][1] = interface.data.progress.gear.afneed[4][y][1] + 1;
                elseif (x == 2) or (x == 3) or (x == 4) or (x == 16) or (x == 20) then
                    interface.data.progress.gear.afneed[4][y][2] = interface.data.progress.gear.afneed[4][y][2] + 1;
                elseif (x == 6) or (x == 13) or (x == 19) or (x == 22) then
                    interface.data.progress.gear.afneed[4][y][3] = interface.data.progress.gear.afneed[4][y][3] + 1;
                elseif (x == 9) or (x == 14) or (x == 15) or (x == 18) then
                    interface.data.progress.gear.afneed[4][y][4] = interface.data.progress.gear.afneed[4][y][4] + 1;
                elseif (x == 10) or (x == 11) or (x == 17) or (x == 21) then
                    interface.data.progress.gear.afneed[4][y][5] = interface.data.progress.gear.afneed[4][y][5] + 1;
                end
                if (y == 1) then
                    interface.data.progress.gear.afneed[4][y][6] = interface.data.progress.gear.afneed[4][y][6] + 1;
                    interface.data.progress.gear.afneed[4][y][10] = interface.data.progress.gear.afneed[4][y][10] + 1;
                    interface.data.progress.gear.afneed[4][y][12] = interface.data.progress.gear.afneed[4][y][12] + 2;
                elseif (y == 2) then
                    interface.data.progress.gear.afneed[4][y][8] = interface.data.progress.gear.afneed[4][y][8] + 1;
                    interface.data.progress.gear.afneed[4][y][12] = interface.data.progress.gear.afneed[4][y][12] + 3;
                    interface.data.progress.gear.afneed[4][y][14] = interface.data.progress.gear.afneed[4][y][14] + 1;
                elseif (y == 3)  then
                    interface.data.progress.gear.afneed[4][y][15] = interface.data.progress.gear.afneed[4][y][15] + 3;
                    interface.data.progress.gear.afneed[4][y][7] = interface.data.progress.gear.afneed[4][y][7] + 1;
                    interface.data.progress.gear.afneed[4][y][12] = interface.data.progress.gear.afneed[4][y][12] + 1;
                elseif (y == 4) then
                    interface.data.progress.gear.afneed[4][y][8] = interface.data.progress.gear.afneed[4][y][8] + 1;
                    interface.data.progress.gear.afneed[4][y][12] = interface.data.progress.gear.afneed[4][y][12] + 2;
                    interface.data.progress.gear.afneed[4][y][13] = interface.data.progress.gear.afneed[4][y][13] + 1;
                elseif (y == 5) then
                    interface.data.progress.gear.afneed[4][y][9] = interface.data.progress.gear.afneed[4][y][9] + 1;
                    interface.data.progress.gear.afneed[4][y][11] = interface.data.progress.gear.afneed[4][y][11] + 3;
                    interface.data.progress.gear.afneed[4][y][12] = interface.data.progress.gear.afneed[4][y][12] + 1;
                end
                if (y == 1) then
                    cards[x] = cards[x] + 40;
                elseif (y == 2) then
                    cards[x] = cards[x] + 50;
                elseif (y == 3) then
                    cards[x] = cards[x] + 35;
                elseif (y == 4) then
                    cards[x] = cards[x] + 45;
                elseif (y == 5) then
                    cards[x] = cards[x] + 30;
                end
            end
        end
    end
    
    for l = 1, #interface.data.progress.gear.jobcards do
        interface.data.progress.gear.jobcards[l] = cards[l]
    end
end

function manager.DisplayAFGear()
    imgui.BeginTable('af gear has', 5, ImGuiTableFlags_Borders);
    for a = 1, #interface.data.progress.gear.af do
        for b = 1, #interface.data.progress.gear.af[a] do
            imgui.TableNextColumn();
            local temp = {interface.data.progress.gear.af[a][b][1]};
            if (imgui.Combo(interface.data.progress.gear.af[a][b][2], temp, 'None\0NQ\0+1\0lv109\0lv119+1\0lv119+2\0lv119+3\0')) then
                interface.data.progress.gear.af[a][b][1] = temp[1];
            end
        end
    end
    imgui.EndTable();
    imgui.NewLine();
    
    imgui.TextColored(interface.colors.header, 'Progress: ');imgui.SameLine();imgui.ProgressBar(interface.data.progress.gear.afProgress[1],10);
    imgui.NewLine();
    if (imgui.Button('Update AF Gear')) then
        print(chat.header(addon.name) .. chat.message('Updated AF Gear'));
        interface.manager.UpdateAFGear();
    end
end

function manager.DisplayAFGearNeed()
    manager.guilditemsgil = 0;

    imgui.BeginTable('chapters', 11, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Chapters');imgui.TableNextColumn();
        for t = 1, 10 do
            imgui.TextColored(interface.colors.header,'Chap. ' .. t);imgui.TableNextColumn();
        end
        imgui.TableNextColumn();
        for i = 1, 5 do
            imgui.Text(tostring(interface.data.progress.gear.afneed[1][i][1]));imgui.TableNextColumn();
        end
        for i = 1, 5 do
            imgui.Text(tostring(interface.data.progress.gear.afneed[2][i][1]));
            if (i ~= 5) then imgui.TableNextColumn() end
        end
    imgui.EndTable();

    imgui.BeginTable('109slot', 6, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Lv109');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Head');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Body');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Hands');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Legs');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Feet');imgui.TableNextColumn();
        imgui.Text('Slot');imgui.TableNextColumn();
        imgui.Text('Phx. Feather');imgui.TableNextColumn();
        imgui.Text('Mal. Fiber');imgui.TableNextColumn();
        imgui.Text('Btl. Blood');imgui.TableNextColumn();
        imgui.Text('Damas. Cloth');imgui.TableNextColumn();
        imgui.Text('Oxblood');imgui.TableNextColumn();
        imgui.Text('Items');imgui.TableNextColumn();
        for i = 1, #interface.data.progress.gear.afneed[1] do
            imgui.Text(tostring(interface.data.progress.gear.afneed[1][i][2]));
            if (i ~= #interface.data.progress.gear.afneed[1]) then imgui.TableNextColumn() end
        end
    imgui.EndTable();

    imgui.BeginTable('109job', 9, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Lv109');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'WAR/BST');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'MNK/THF/DNC');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'WHM/BRD/BLU');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'BLM/RNG/COR/PUP');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'RDM/SMN/SCH');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'PLD/DRG');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'DRK');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'SAM/NIN');imgui.TableNextColumn();
        imgui.Text('Job Spec.');imgui.TableNextColumn();
        imgui.Text('Tgr Leather');imgui.TableNextColumn();
        imgui.Text('Gld Thread');imgui.TableNextColumn();
        imgui.Text('Imp Slk Cloth');imgui.TableNextColumn();
        imgui.Text('Kara. Cloth');imgui.TableNextColumn();
        imgui.Text('Scarlet Linen');imgui.TableNextColumn();
        imgui.Text('Gld Sheet');imgui.TableNextColumn();
        imgui.Text('Drkstl Sheet');imgui.TableNextColumn();
        imgui.Text('Tama-Hagane');imgui.TableNextColumn();
        imgui.Text('Items');imgui.TableNextColumn();
        for x = 3, #interface.data.progress.gear.afneed[1][1] do
            local count = 0;
            for i = 1, #interface.data.progress.gear.afneed[1] do
                count = count + interface.data.progress.gear.afneed[1][i][x];
            end
            imgui.Text(tostring(count));
            if (x ~= #interface.data.progress.gear.afneed[1][1]) then imgui.TableNextColumn() end
        end
    imgui.EndTable();

    imgui.BeginTable('1191slot', 6, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Lv119+1');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Head');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Body');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Hands');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Legs');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Feet');imgui.TableNextColumn();
        imgui.Text('Slot');imgui.TableNextColumn();
        imgui.Text('Maliy. Orb');imgui.TableNextColumn();
        imgui.Text('Hepa. Ingot');imgui.TableNextColumn();
        imgui.Text('Bery. Ingot');imgui.TableNextColumn();
        imgui.Text('Exalt. Lbr.');imgui.TableNextColumn();
        imgui.Text('Sif\'s Macarame');imgui.TableNextColumn();
        imgui.Text('Items');imgui.TableNextColumn();
        for i = 1, #interface.data.progress.gear.afneed[2] do
            imgui.Text(tostring(interface.data.progress.gear.afneed[2][i][2]));
            if (i ~= #interface.data.progress.gear.afneed[2]) then imgui.TableNextColumn() end
        end
    imgui.EndTable();

    imgui.BeginTable('1191job', 9, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Lv119+1');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'WAR/BST');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'MNK/THF/DNC');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'WHM/BRD/BLU/GEO');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'BLM/RNG/COR/PUP');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'RDM/SMN/SCH');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'PLD/DRG');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'DRK');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'SAM/NIN/RUN');imgui.TableNextColumn();
        imgui.Text('Job Spec.');imgui.TableNextColumn();
        imgui.Text('Behe Leather');imgui.TableNextColumn();
        imgui.Text('Plt Slk Thrd');imgui.TableNextColumn();
        imgui.Text('Raxa');imgui.TableNextColumn();
        imgui.Text('Twill Damask');imgui.TableNextColumn();
        imgui.Text('Siren\'s Hair');imgui.TableNextColumn();
        imgui.Text('Ocl. Sheet');imgui.TableNextColumn();
        imgui.Text('Durium Sheet');imgui.TableNextColumn();
        imgui.Text('Dama Ingot');imgui.TableNextColumn();
        imgui.Text('Items');imgui.TableNextColumn();
        for x = 3, #interface.data.progress.gear.afneed[2][1] do
            local count = 0;
            for i = 1, #interface.data.progress.gear.afneed[2] do
                count = count + interface.data.progress.gear.afneed[2][i][x];
            end
            imgui.Text(tostring(count));
            if (x ~= #interface.data.progress.gear.afneed[2][1]) then imgui.TableNextColumn() end
        end
    imgui.EndTable();

    imgui.BeginTable('cards', (#interface.defaults.jobsabrv +1), ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Cards');imgui.TableNextColumn();
        for j = 1, #interface.defaults.jobsabrv do
            imgui.TextColored(interface.colors.header, interface.defaults.jobsabrv[j]);imgui.TableNextColumn();
        end
        imgui.TableNextColumn();
        for c = 1, #interface.data.progress.gear.jobcards do
            imgui.Text(tostring(interface.data.progress.gear.jobcards[c]));
            if (c ~= #interface.data.progress.gear.jobcards) then imgui.TableNextColumn() end
        end
    imgui.EndTable();

    imgui.BeginTable('1192slot', 6, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Lv119+2');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Head (8/40 cards)');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Body (10/50 cards)');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Hands (7/35 cards)');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Legs (9/45 cards)');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Feet (6/30 cards)');imgui.TableNextColumn();
        imgui.Text('Slot');imgui.TableNextColumn();
        imgui.Text('Emp Artho Shell');imgui.TableNextColumn();
        imgui.Text('Joyous Moss');imgui.TableNextColumn();
        imgui.Text('Imperator Wing');imgui.TableNextColumn();
        imgui.Text('Warblade Beak Hide');imgui.TableNextColumn();
        imgui.Text('Abyssdiver Feather');imgui.TableNextColumn();
        imgui.Text('Items');imgui.TableNextColumn();
        for i = 1, #interface.data.progress.gear.afneed[3] do
            imgui.Text(tostring(interface.data.progress.gear.afneed[3][i][1]));
            if (i ~= #interface.data.progress.gear.afneed[3]) then imgui.TableNextColumn() end
        end
    imgui.EndTable();

    imgui.BeginTable('1192job', 8, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Lv119+2');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'WAR/BST/RNG');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'MNK/THF/DNC');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'WHM/BRD/BLU/GEO');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'BLM/COR/PUP');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'RDM/SMN/SCH');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'PLD/DRG');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'DRK/SAM/NIN/RUN');imgui.TableNextColumn();
        imgui.Text('Job Spec.');imgui.TableNextColumn();
        imgui.Text('S.Faulpie Lthr');imgui.TableNextColumn();
        imgui.Text('Cypress Log');imgui.TableNextColumn();
        imgui.Text('Khoma Thread');imgui.TableNextColumn();
        imgui.Text('Azure Leaf');imgui.TableNextColumn();
        imgui.Text('Cyan Coral');imgui.TableNextColumn();
        imgui.Text('Ruth. Ore');imgui.TableNextColumn();
        imgui.Text('Niob. Ore');imgui.TableNextColumn();
        imgui.Text('Items');imgui.TableNextColumn();
        for x = 2, #interface.data.progress.gear.afneed[3][1] do
            local count = 0;
            for i = 1, #interface.data.progress.gear.afneed[3] do
                count = count + interface.data.progress.gear.afneed[3][i][x];
            end
            imgui.Text(tostring(count));
            manager.guilditemsgil = manager.guilditemsgil + (count * 1126125);
            if (x ~= #interface.data.progress.gear.afneed[3][1]) then imgui.TableNextColumn() end
        end
    imgui.EndTable();

    imgui.BeginTable('1193scales', 6, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Lv119+3 Scales');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Kin(WAR/MNK/PLD/DRK/SAM)');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Kei(WHM/BLM/RDM/BLU/SCH)');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Gin (THF/NIN/DNC/RUN)');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Fu (BST/DRG/SMN/PUP)');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Kyou (BRD/RNG/COR/GEO)');imgui.TableNextColumn();imgui.TableNextColumn();
        for x = 1, 5 do
            local count = 0;
            for i = 1, #interface.data.progress.gear.afneed[4] do
                count = count + interface.data.progress.gear.afneed[4][i][x];
            end
            imgui.Text(tostring(count));
            if (x ~= 5) then imgui.TableNextColumn() end
        end
    imgui.EndTable();

    imgui.BeginTable('1193items', 5, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Lv119+3 Items');imgui.TableNextRow();imgui.TableNextColumn();
        imgui.Text('Faulpie Lthr');imgui.TableNextColumn();
        imgui.Text('Cypress Log');imgui.TableNextColumn();
        imgui.Text('Cypress Lbr');imgui.TableNextColumn();
        imgui.Text('Khoma Thread');imgui.TableNextColumn();
        imgui.Text('Khoma Cloth');imgui.TableNextColumn();
        for x = 6, 10 do
            local count = 0;
            for i = 1, #interface.data.progress.gear.afneed[4] do
                count = count + interface.data.progress.gear.afneed[4][i][x];
            end
            imgui.Text(tostring(count));imgui.TableNextColumn();
            if x == 10 then
                count = count + (count * 2);--accounting for cloth needing three threads
            end
            manager.guilditemsgil = manager.guilditemsgil + (count * 1126125);
        end
        imgui.Text('Azure Cermet');imgui.TableNextColumn();
        imgui.Text('Cyan Orb');imgui.TableNextColumn();
        imgui.Text('Ruthenium Ingot');imgui.TableNextColumn();
        imgui.Text('Niobium Ingot');imgui.TableNextColumn();
        imgui.Text('Faulpie Leather');imgui.TableNextColumn();
        for x =11, #interface.data.progress.gear.afneed[4][1] do
            local count = 0;
            for i = 1, #interface.data.progress.gear.afneed[4] do
                count = count + interface.data.progress.gear.afneed[4][i][x];
            end
            imgui.Text(tostring(count));
            if x == 13 or x == 14 then
                count = count + (count * 3);--accounting for the ingots needing four ores
            end
            manager.guilditemsgil = manager.guilditemsgil + (count * 1126125);
            if x~= #interface.data.progress.gear.afneed[4][1] then imgui.TableNextColumn() end
        end
    imgui.EndTable();

    imgui.Text('Est. Needed Gil for Guild Items:  ');imgui.SameLine();imgui.TextColored(interface.colors.header, manager.comma_value(manager.guilditemsgil));
end

function manager.UpdateRelicGear()
    --one time count of relic unlock KI's, also set global check to false for safety of not spamming currency packets accidently
    -- AshitaCore:GetPacketManager():AddOutgoingPacket(0x115, { 0x00, 0x00, 0x00, 0x00 });--update currency2 (removed here for safety due to potential button spam)
    for k,v in ipairs(interface.defaults.gear.relicUnlockKeyItems) do
        if (modifind.searchKeyItemName(v)) then
            interface.data.progress.gear.relicUnlocks[k] = true;
        end
    end
    check = false;

    local countgear = 0;
    local totalgear = #interface.defaults.gear.relic * #interface.defaults.gear.relic[1] * #interface.defaults.gear.relic[1][1];
    for job = 1, #interface.defaults.gear.relic do
        for slot = 1, #interface.defaults.gear.relic[job] do
            local index = modifind.searchIdTable(interface.defaults.gear.relic[job][slot]:reverse());
            if (index) then
                if job == 21 or job == 22 then
                    interface.data.progress.gear.relic[job][slot][1] = index + 3;--offset for geo and run for gear starting at 109
                else
                    interface.data.progress.gear.relic[job][slot][1] = index;
                end
            end
            countgear = countgear + interface.data.progress.gear.relic[job][slot][1];
        end
    end
    interface.data.progress.gear.relicProgress[1] = countgear/totalgear;
    manager.CountRelicGear();
end

function manager.CountRelicGearInv(items)
    if items == nil then return end

    local forgottenIDs = {3493,3494,3495,3496,3497};
    for i = 1, #forgottenIDs do
        items[1][i] = items[1][i] - modifind.countItemId(forgottenIDs[i]);
    end

    local checks1 = {0,0,1469,1516,1470,1458,1466,1464};--{blank,blank,wootze ore,griffon hide,sparkling stone,mammoth tusk,relic iron,lancewood log,}
    for i = 3, #checks1 do
        items[2][1][i] = items[2][1][i] - modifind.countItemId(checks1[i]);
    end

    local checks2 = {0,0,3447,3492,3491,3490,3445,3449};--{blank,blank,voidwrought plate,kaggen's cuticle,akvan's pennon,pil's tuille,hahava's mail,celaeno's cloth'}
    for i = 3, #checks2 do
        items[3][1][i] = items[3][1][i] - modifind.countItemId(checks2[i]);
    end

    local checks3 = {0,9253,9245,9251,9257,9255,9249,9247};--{blank,S.Faulpie Leather,Cypress Log,Khoma Thread,Azure Leaf,Cyan Coral,Ruthenium Ore,Niobium Ore,}
    for i = 3, #checks3 do
        items[4][1][i] = items[4][1][i] - modifind.countItemId(checks3[i]);
    end

    for j = 1, #items[5] do
        for s = 1, #items[5][j] do
            items[5][j][s][1] = 0 - modifind.countItemId(interface.defaults.gear.relicshards[s][j]);
            items[5][j][s][2] = 0 - modifind.countItemId(interface.defaults.gear.relicvoids[s][j]);
        end
    end

    return items;
end

function manager.CountRelicGear()
    interface.data.progress.gear.relicneed = {
        {0,0,0,0,0},
        {{0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0}},
        {{0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0}},
        {{0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0}},
        {   {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}},{{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}},{{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}},
            {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}},{{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}},{{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}},
            {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}},{{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}},{{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}},
            {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}},{{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}},{{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}},
            {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}},{{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}},{{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}},
            {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}},{{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}},{{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}},
            {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}},{{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}},{{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}},
            {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}}
        },
    };
    interface.data.progress.gear.relicneed = manager.CountRelicGearInv(interface.data.progress.gear.relicneed);

    for x = 1, #interface.data.progress.gear.relic do
        for y = 1, #interface.data.progress.gear.relic[x] do
            if interface.data.progress.gear.relic[x][y][1] <= 2 then
                if interface.data.progress.gear.relic[x][y][1] <= 1 then
                    interface.data.progress.gear.relicneed[1][y] = interface.data.progress.gear.relicneed[1][y] + 50;
                else
                    interface.data.progress.gear.relicneed[1][y] = interface.data.progress.gear.relicneed[1][y] + 30;
                end
            end
            if interface.data.progress.gear.relic[x][y][1] <= 3 then
                if interface.data.progress.gear.relic[x][y][1] <= 2 then
                    interface.data.progress.gear.relicneed[2][y][1] = interface.data.progress.gear.relicneed[2][y][1] + 10;
                else
                    interface.data.progress.gear.relicneed[2][y][1] = interface.data.progress.gear.relicneed[2][y][1] + 5;
                end
                interface.data.progress.gear.relicneed[2][y][2] = interface.data.progress.gear.relicneed[2][y][2] + 1;
                if (x == 1) or (x == 7) or (x == 8) then
                    interface.data.progress.gear.relicneed[2][y][3] = interface.data.progress.gear.relicneed[2][y][3] + 1;
                elseif (x == 2) or (x == 5) or (x == 6) or (x == 10) or (x == 11) or (x == 14) or (x == 16) then
                    interface.data.progress.gear.relicneed[2][y][4] = interface.data.progress.gear.relicneed[2][y][4] + 1;
                elseif (x == 3) or (x == 4) or (x == 17) then
                    interface.data.progress.gear.relicneed[2][y][5] = interface.data.progress.gear.relicneed[2][y][5] + 1;
                elseif (x == 9) or (x == 19) then
                    interface.data.progress.gear.relicneed[2][y][6] = interface.data.progress.gear.relicneed[2][y][6] + 1;
                elseif (x == 12) or (x == 13) then
                    interface.data.progress.gear.relicneed[2][y][7] = interface.data.progress.gear.relicneed[2][y][7] + 1;
                elseif (x == 15) or (x == 18) or (x == 20) then
                    interface.data.progress.gear.relicneed[2][y][8] = interface.data.progress.gear.relicneed[2][y][8] + 1;
                end
            end
            if interface.data.progress.gear.relic[x][y][1] <= 4 then
                interface.data.progress.gear.relicneed[3][y][1] = interface.data.progress.gear.relicneed[3][y][1] + 8;
                interface.data.progress.gear.relicneed[3][y][2] = interface.data.progress.gear.relicneed[3][y][2] + 1;
                if (x == 1) or (x == 13) or (x == 14) then
                    interface.data.progress.gear.relicneed[3][y][3] = interface.data.progress.gear.relicneed[3][y][3] + 1;
                elseif (x == 2) or (x == 6) or (x == 10) or (x == 17) then
                    interface.data.progress.gear.relicneed[3][y][4] = interface.data.progress.gear.relicneed[3][y][4] + 1;
                elseif (x == 3) or (x == 4) or (x == 20) or (x == 21) then
                    interface.data.progress.gear.relicneed[3][y][5] = interface.data.progress.gear.relicneed[3][y][5] + 1;
                elseif (x == 5) or (x == 7) or (x == 8) or (x == 12) or (x == 16) then
                    interface.data.progress.gear.relicneed[3][y][6] = interface.data.progress.gear.relicneed[3][y][6] + 1;
                elseif (x == 9) or (x == 15) or (x == 18) then
                    interface.data.progress.gear.relicneed[3][y][7] = interface.data.progress.gear.relicneed[3][y][7] + 1;
                elseif (x == 11) or (x == 19) or (x == 22) then
                    interface.data.progress.gear.relicneed[3][y][8] = interface.data.progress.gear.relicneed[3][y][8] + 1;
                end
            end
            if interface.data.progress.gear.relic[x][y][1] <= 5 then
                interface.data.progress.gear.relicneed[5][x][y][1] = interface.data.progress.gear.relicneed[5][x][y][1] + 2;
                interface.data.progress.gear.relicneed[4][y][1] = interface.data.progress.gear.relicneed[4][y][1] + 3;
                if (x == 1) or (x == 9) or (x == 11) then
                    interface.data.progress.gear.relicneed[4][y][2] = interface.data.progress.gear.relicneed[4][y][2] + 1;
                elseif (x == 2) or (x == 6) or (x == 19) then
                    interface.data.progress.gear.relicneed[4][y][3] = interface.data.progress.gear.relicneed[4][y][3] + 1;
                elseif (x == 3) or (x == 10) or (x == 16) or (x == 21) then
                    interface.data.progress.gear.relicneed[4][y][4] = interface.data.progress.gear.relicneed[4][y][4] + 1;
                elseif (x == 4) or (x == 17) or (x == 18) then
                    interface.data.progress.gear.relicneed[4][y][5] = interface.data.progress.gear.relicneed[4][y][5] + 1;
                elseif (x == 5) or (x == 15) or (x == 20) then
                    interface.data.progress.gear.relicneed[4][y][6] = interface.data.progress.gear.relicneed[4][y][6] + 1;
                elseif (x == 7) or (x == 14) then
                    interface.data.progress.gear.relicneed[4][y][7] = interface.data.progress.gear.relicneed[4][y][7] + 1;
                elseif (x == 8) or (x == 12) or (x == 13) or (x == 22) then
                    interface.data.progress.gear.relicneed[4][y][8] = interface.data.progress.gear.relicneed[4][y][8] + 1;
                end
            end
            if interface.data.progress.gear.relic[x][y][1] <= 6 then
                interface.data.progress.gear.relicneed[5][x][y][1] = interface.data.progress.gear.relicneed[5][x][y][1] + 3;
                interface.data.progress.gear.relicneed[5][x][y][2] = interface.data.progress.gear.relicneed[5][x][y][2] + 3;
                interface.data.progress.gear.relicneed[5][x][y][3] = interface.data.progress.gear.relicneed[5][x][y][3] + 3;
            end
        end
    end
end

function manager.DisplayRelicGear()
    if check == true then -- global that gets set true on first addon load and once again whenever the display is first rendered after being disabled
        AshitaCore:GetPacketManager():AddOutgoingPacket(0x115, { 0x00, 0x00, 0x00, 0x00 });--update currency2
        for k,v in ipairs(interface.defaults.gear.relicUnlockKeyItems) do
            if (modifind.searchKeyItemName(v)) then
                interface.data.progress.gear.relicUnlocks[k] = 1;
            end
        end
        check = false;
    end
    imgui.BeginTable('relic gear has', 5, ImGuiTableFlags_Borders);
    for a = 1, #interface.data.progress.gear.relic do
        for b = 1, #interface.data.progress.gear.relic[a] do
            imgui.TableNextColumn();
            local temp = {interface.data.progress.gear.relic[a][b][1]};
            if (imgui.Combo(interface.data.progress.gear.relic[a][b][2], temp, 'None\0NQ\0+1\0+2\0lv109\0lv119+1\0lv119+2\0lv119+3\0')) then
                interface.data.progress.gear.relic[a][b][1] = temp[1];
            end
        end
    end
    imgui.EndTable();
    imgui.NewLine();
    imgui.TextColored(interface.colors.header, 'Relic Unlocks (+3):    ');
    for k,v in ipairs(interface.defaults.jobsabrv) do
        if (interface.data.progress.gear.relicUnlocks[k]) then
            imgui.SameLine();imgui.TextColored(interface.colors.green,v .. ' ');
        else
            imgui.SameLine();imgui.Text(v .. ' ');
        end
    end
    imgui.TextColored(interface.colors.header, 'Progress: ');imgui.SameLine();imgui.ProgressBar(interface.data.progress.gear.relicProgress[1]);
    if (imgui.Button('Update Relic Gear')) then
        print(chat.header(addon.name) .. chat.message('Updated Relic Gear'));
        manager.UpdateRelicGear();
    end
end

function manager.DisplayRelicGearNeed()
    manager.guilditemsgil = 0;
    manager.plasm = 0;

    imgui.BeginTable('Forgotten', 6, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Forgotten');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Thought');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Hope');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Touch');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Journey');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Step');imgui.TableNextColumn();
        imgui.TableNextColumn();
        for i = 1, #interface.data.progress.gear.relicneed[1] do
            imgui.Text(tostring(interface.data.progress.gear.relicneed[1][i]));
            if (i ~= #interface.data.progress.gear.relicneed[1]) then imgui.TableNextColumn() end
        end
    imgui.EndTable();

    imgui.BeginTable('chapters', 11, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Chapters');imgui.TableNextColumn();
        for t = 1, 10 do
            imgui.TextColored(interface.colors.header,'Chap. ' .. t);imgui.TableNextColumn();
        end
        imgui.TableNextColumn();
        for i = 1, 5 do
            imgui.Text(tostring(interface.data.progress.gear.relicneed[2][i][1]));imgui.TableNextColumn();
        end
        for i = 1, 5 do
            imgui.Text(tostring(interface.data.progress.gear.relicneed[3][i][1]));
            if (i ~= 5) then imgui.TableNextColumn() end
        end
    imgui.EndTable();

    imgui.BeginTable('109slot', 6, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Lv109');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Head');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Body');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Hands');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Legs');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Feet');imgui.TableNextColumn();
        imgui.Text('Slot');imgui.TableNextColumn();
        imgui.Text('Phx. Feather');imgui.TableNextColumn();
        imgui.Text('Mal. Fiber');imgui.TableNextColumn();
        imgui.Text('Btl. Blood');imgui.TableNextColumn();
        imgui.Text('Damas. Cloth');imgui.TableNextColumn();
        imgui.Text('Oxblood');imgui.TableNextColumn();
        imgui.Text('Items');imgui.TableNextColumn();
        for i = 1, #interface.data.progress.gear.relicneed[2] do
            imgui.Text(tostring(interface.data.progress.gear.relicneed[2][i][2]));
            if (i ~= #interface.data.progress.gear.relicneed[2]) then imgui.TableNextColumn() end
        end
    imgui.EndTable();

    imgui.BeginTable('109job', 7, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Lv109');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'WAR/PLD/DRK');imgui.TableNextColumn();
        --imgui.TextColored(interface.colors.header, 'MNK/RDM/THF/BRD/RNG/DRG/BLU');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'ALL ELSE');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'WHM/BLM/COR');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'BST/DNC');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'SAM/NIN');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'SMN/PUP/SCH');imgui.TableNextColumn();
        imgui.Text('Job Spec.');imgui.TableNextColumn();
        imgui.Text('Wootz Ore');imgui.TableNextColumn();
        imgui.Text('Griffon Hide');imgui.TableNextColumn();
        imgui.Text('Sparkling Stone');imgui.TableNextColumn();
        imgui.Text('Mammoth Tusk');imgui.TableNextColumn();
        imgui.Text('Relic Iron');imgui.TableNextColumn();
        imgui.Text('Lancewood Log');imgui.TableNextColumn();
        imgui.Text('Items');imgui.TableNextColumn();
        for x = 3, #interface.data.progress.gear.relicneed[2][1] do
            local count = 0;
            for i = 1, #interface.data.progress.gear.relicneed[1] do
                count = count + interface.data.progress.gear.relicneed[2][i][x];
            end
            imgui.Text(tostring(count));
            if (x ~= #interface.data.progress.gear.relicneed[2][1]) then imgui.TableNextColumn() end
        end
    imgui.EndTable();

    imgui.BeginTable('1191slot', 6, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Lv119+1');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Head');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Body');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Hands');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Legs');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Feet');imgui.TableNextColumn();
        imgui.Text('Slot');imgui.TableNextColumn();
        imgui.Text('Gabbrath Horn');imgui.TableNextColumn();
        imgui.Text('Yggdreant Bole');imgui.TableNextColumn();
        imgui.Text('Bztavian Stinger');imgui.TableNextColumn();
        imgui.Text('Waktza Rostrum');imgui.TableNextColumn();
        imgui.Text('Rockfin Tooth');imgui.TableNextColumn();
        imgui.Text('Items');imgui.TableNextColumn();
        for i = 1, #interface.data.progress.gear.relicneed[3] do
            local count = 0;
            count = count + interface.data.progress.gear.relicneed[3][i][2];
            imgui.Text(tostring(interface.data.progress.gear.relicneed[3][i][2]));
            manager.plasm = manager.plasm + (count * 300000);
            if (i ~= #interface.data.progress.gear.relicneed[3]) then imgui.TableNextColumn() end
        end
    imgui.EndTable();

    imgui.BeginTable('1191job', 7, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Lv119+1');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'WAR/NIN/DRG');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'MNK/THF/BRD/COR');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'WHM/BLM/SCH/GEO');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'RDM/PLD/DRK/SAM/BLU');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'BST/SMN/PUP');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'RNG/DNC/RUN');imgui.TableNextColumn();
        imgui.Text('Job Spec.');imgui.TableNextColumn();
        imgui.Text('Voidwrought Plate');imgui.TableNextColumn();
        imgui.Text('Kaggen\'s Cuticle');imgui.TableNextColumn();
        imgui.Text('Akvan\'s Pennon');imgui.TableNextColumn();
        imgui.Text('Pil\'s Tuille');imgui.TableNextColumn();
        imgui.Text('Hahava\'s Mail');imgui.TableNextColumn();
        imgui.Text('Celaeno\'s Cloth');imgui.TableNextColumn();
        imgui.Text('Items');imgui.TableNextColumn();
        for x = 3, #interface.data.progress.gear.relicneed[3][1] do
            local count = 0;
            for i = 1, #interface.data.progress.gear.relicneed[3] do
                count = count + interface.data.progress.gear.relicneed[3][i][x];
            end
            imgui.Text(tostring(count));
            if (x ~= #interface.data.progress.gear.relicneed[3][1]) then imgui.TableNextColumn() end
        end
    imgui.EndTable();

    imgui.BeginTable('1192slot', 6, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Lv119+2');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Head (3 ea.)');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Body (3 ea.)');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Hands (3 ea.)');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Legs (3 ea.)');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Feet (3 ea.)');imgui.TableNextColumn();
        imgui.Text('Slot');imgui.TableNextColumn();
        imgui.Text('Gabbrath Horn');imgui.TableNextColumn();
        imgui.Text('Yggdreant Bole');imgui.TableNextColumn();
        imgui.Text('Bztavian Stinger');imgui.TableNextColumn();
        imgui.Text('Waktza Rostrum');imgui.TableNextColumn();
        imgui.Text('Rockfin Tooth');imgui.TableNextColumn();
        imgui.Text('Items');imgui.TableNextColumn();
        for i = 1, #interface.data.progress.gear.relicneed[4] do
            local count = 0;
            count = count + interface.data.progress.gear.relicneed[4][i][1];
            imgui.Text(tostring(interface.data.progress.gear.relicneed[4][i][1]));
            manager.plasm = manager.plasm + (count * 300000);
            if (i ~= #interface.data.progress.gear.relicneed[4]) then imgui.TableNextColumn() end
        end
    imgui.EndTable();

    imgui.BeginTable('1192job', 8, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Lv119+2');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'WAR/BST/RNG');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'MNK/THF/DNC');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'WHM/BRD/BLU/GEO');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'BLM/COR/PUP');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'RDM/SMN/SCH');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'PLD/DRG');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'DRK/SAM/NIN/RUN');imgui.TableNextColumn();
        imgui.Text('Job Spec.');imgui.TableNextColumn();
        imgui.Text('S.Faulpie Lthr');imgui.TableNextColumn();
        imgui.Text('Cypress Log');imgui.TableNextColumn();
        imgui.Text('Khoma Thread');imgui.TableNextColumn();
        imgui.Text('Azure Leaf');imgui.TableNextColumn();
        imgui.Text('Cyan Coral');imgui.TableNextColumn();
        imgui.Text('Ruth. Ore');imgui.TableNextColumn();
        imgui.Text('Niob. Ore');imgui.TableNextColumn();
        imgui.Text('Items');imgui.TableNextColumn();
        for x = 2, #interface.data.progress.gear.relicneed[4][1] do
            local count = 0;
            for i = 1, #interface.data.progress.gear.relicneed[4] do
                count = count + interface.data.progress.gear.relicneed[4][i][x];
            end
            imgui.Text(tostring(count));
            manager.guilditemsgil = manager.guilditemsgil + (count * 1126125);
            if (x ~= #interface.data.progress.gear.relicneed[4][1]) then imgui.TableNextColumn() end
        end
    imgui.EndTable();

    imgui.BeginTable('1193slot', 6, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Lv119+3');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Head (3 ea.)');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Body (3 ea.)');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Hands (3 ea.)');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Legs (3 ea.)');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Feet (3 ea.)');imgui.TableNextColumn();
        imgui.Text('Slot');imgui.TableNextColumn();
        imgui.Text('Defiant Scarf');imgui.TableNextColumn();
        imgui.Text('Hades Claw');imgui.TableNextColumn();
        imgui.Text('Macuil Plating');imgui.TableNextColumn();
        imgui.Text('Tartarian Soul');imgui.TableNextColumn();
        imgui.Text('Plovid Flesh');imgui.TableNextColumn();
        imgui.Text('Items');imgui.TableNextColumn();
        for h = 1, #interface.data.progress.gear.relicneed[5][1] do
            for i = 3, #interface.data.progress.gear.relicneed[5][1][h] do
                local count = 0;
                for j = 1, #interface.data.progress.gear.relicneed[5] do
                    count = count + interface.data.progress.gear.relicneed[5][j][h][i];
                end
                imgui.Text(tostring(count));
                if (h ~= #interface.data.progress.gear.relicneed[5][1]) then imgui.TableNextColumn() end
            end
        end
    imgui.EndTable();

    imgui.NewLine();
    imgui.Text('Est. Needed Gil for Guild Items:  ');imgui.SameLine();imgui.TextColored(interface.colors.header, manager.comma_value(manager.guilditemsgil));
    imgui.Text('Est. Needed Plasm:  ');imgui.SameLine();imgui.TextColored(interface.colors.header, manager.comma_value(manager.plasm));imgui.SameLine();
    imgui.Text('(curr: ' .. manager.comma_value(interface.data.current['Plasm'][1]) .. ')')

    imgui.NewLine();
    if (imgui.Button('Update Relic Gear')) then
        print(chat.header(addon.name) .. chat.message('Updated Relic Gear'));
        manager.UpdateRelicGear();
    end
    imgui.ShowHelp('119+2 and +3 items also need various shards and voids, see the next tab for display of those needs');
end

function manager.DisplayRelicShardsNeed()
    local bm = 0 -- modifind.countItemId(9539);
    local km = 0 -- modifind.countItemId(9541);

    imgui.BeginTable('Shards', 12, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'SHARDS:');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Head');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Body');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Hands');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Legs');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Feet');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'VOIDS:');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Head');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Body');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Hands');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Legs');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Feet');imgui.TableNextColumn();
        for j = 1, #interface.defaults.jobsabrv do
            -- shards
            imgui.TextColored(interface.colors.header, interface.defaults.jobsabrv[j]);imgui.TableNextColumn();
            for s = 1, #interface.data.progress.gear.relicneed[5][j] do
                bm = bm + interface.data.progress.gear.relicneed[5][j][s][1];
                if (interface.data.progress.gear.relicneed[5][j][s][1] >= 5) then
                    imgui.TextColored(interface.colors.error, tostring(interface.data.progress.gear.relicneed[5][j][s][1]));imgui.TableNextColumn();
                elseif (interface.data.progress.gear.relicneed[5][j][s][1] <= 0) then
                    imgui.TextColored(interface.colors.green, tostring(interface.data.progress.gear.relicneed[5][j][s][1]));imgui.TableNextColumn();
                else
                    imgui.TextColored(interface.colors.warning, tostring(interface.data.progress.gear.relicneed[5][j][s][1]));imgui.TableNextColumn();
                end
            end
            --voids
            imgui.TextColored(interface.colors.header, interface.defaults.jobsabrv[j]);imgui.TableNextColumn();
            for v = 1, #interface.data.progress.gear.relicneed[5][j] do
                km = km + interface.data.progress.gear.relicneed[5][j][v][2];
                if (interface.data.progress.gear.relicneed[5][j][v][2] >= 3) then
                    imgui.TextColored(interface.colors.error, tostring(interface.data.progress.gear.relicneed[5][j][v][2]));
                elseif (interface.data.progress.gear.relicneed[5][j][v][2] <= 0) then
                    imgui.TextColored(interface.colors.green, tostring(interface.data.progress.gear.relicneed[5][j][v][2]));
                else
                    imgui.TextColored(interface.colors.warning, tostring(interface.data.progress.gear.relicneed[5][j][v][2]));
                end
                if v == #interface.data.progress.gear.relicneed[5][j] and j == #interface.defaults.jobsabrv then 
                else
                    imgui.TableNextColumn();
                end
            end
        end
    imgui.EndTable();

    imgui.Separator();
    
    -- No longer displaying needed medals as the shard prices have dropped
    -- imgui.Text('Needed Beastmen\'s Medals:  ' .. bm);
    -- imgui.Text('Needed Kindred\'s Medals:  ' .. km);

    if (imgui.Button('Update Relic Gear')) then
        print(chat.header(addon.name) .. chat.message('Updated Relic Gear'));
        manager.UpdateRelicGear();
    end
end

function manager.UpdateEmpyGear()
    --one time count of empy unlock KI's, also set global check to false for safety of not spamming currency packets accidently
    for k,v in ipairs(interface.defaults.gear.empyUnlockKeyItems) do
        if (modifind.searchKeyItemName(v)) then
            interface.data.progress.gear.empyUnlocks[k] = true;
        end
    end
    check = false;

    local countgear = 0;
    local totalgear = #interface.defaults.gear.empyrean * #interface.defaults.gear.empyrean[1] * #interface.defaults.gear.empyrean[1][1];
    for job = 1, #interface.defaults.gear.empyrean do
        for slot = 1, #interface.defaults.gear.empyrean[job] do
            local index = modifind.searchIdTable(interface.defaults.gear.empyrean[job][slot]:reverse());
            if (index) then
                if job == 21 or job == 22 then
                    interface.data.progress.gear.empyrean[job][slot][1] = index + 3;--offset for geo and run for gear starting at 109
                else
                    interface.data.progress.gear.empyrean[job][slot][1] = index;
                end
            end
            countgear = countgear + interface.data.progress.gear.empyrean[job][slot][1];
        end
    end
    interface.data.progress.gear.empyProgress[1] = countgear/totalgear;
    interface.manager.CountEmpyGear();
end

function manager.CountEmpyGearInv(items)
    if items == nil then return end
    local slot1 = 0;local slot2 = 0;local slot3 = 0;local slot4 = 0;
    local dropids = {2929,2962,3287,2927,2965,3291,2932,2930,3288,2963,3289,2966,3292,3290,2964,2928,2967};-- {briareus,itzpapalotl,orthus,glavoid,lanterns,alfard,kukulkan,cara,dragua,ulhuadshi,apademak,bukhis,azdaja,isgebind,sobek,chloris,sedna}
    for y=1, #items[1] do
        if y == 1 then
            slot1 = 3210;
            slot2 = 3212;
            slot3 = 3211;
            slot4 = 3213;
        elseif y == 2 then
            slot1 = 3214;
            slot2 = 3216;
            slot3 = 3215;
            slot4 = 3217;
        elseif y == 3 then
            slot1 = 3218;
            slot2 = 3220;
            slot3 = 3219;
            slot4 = 3221;
        elseif y == 4 then
            slot1 = 3222;
            slot2 = 3224;
            slot3 = 3223;
            slot4 = 3225;
        elseif y == 5 then
            slot1 = 3226;
            slot2 = 3228;
            slot3 = 3227;
            slot4 = 3229;
        end
        items[1][y][1] = 0 - modifind.countItemId(slot1); --count stones
        items[1][y][2] = 0 - modifind.countItemId(slot2); --count jewels
        items[1][y][3] = 0 - modifind.countItemId(slot3); --count coins
        items[1][y][4] = 0 - modifind.countItemId(slot4); --count cards
    end

    --count NM items
    for i = 3, #items[2][1] do
        items[2][1][i] = items[2][1][i] - modifind.countItemId(dropids[i-2]);
    end

    return items;
end

function manager.CountEmpyBaseGear()
    for j = 1, #interface.data.progress.gear.empyrean do
        --head
        if (j == 1) or (j == 3) or (j == 6) or (j == 10) or (j == 11) then
            if (interface.data.progress.gear.empyrean[j][1][1] <= 2) then
                interface.data.progress.gear.empyneed[1][1][1] = interface.data.progress.gear.empyneed[1][1][1] + 6;
            end
        elseif (j == 2) or (j == 5) or (j == 12) or (j == 17) or (j == 18) then
            if (interface.data.progress.gear.empyrean[j][1][1] <= 2) then
                interface.data.progress.gear.empyneed[1][1][2] = interface.data.progress.gear.empyneed[1][1][2] + 6;
            end
        elseif (j == 4) or (j == 8) or (j == 9) or (j == 13) or (j == 15) then
            if (interface.data.progress.gear.empyrean[j][1][1] <= 2) then
                interface.data.progress.gear.empyneed[1][1][3] = interface.data.progress.gear.empyneed[1][1][3] + 6;
            end
        elseif (j == 7) or (j == 14) or (j == 16) or (j == 19) or (j == 20) then
            if (interface.data.progress.gear.empyrean[j][1][1] <= 2) then
                interface.data.progress.gear.empyneed[1][1][4] = interface.data.progress.gear.empyneed[1][1][4] + 6;
            end
        end
        --body
        if (j == 1) or (j == 7) or (j == 10) or (j == 13) or (j == 16) then
            if (interface.data.progress.gear.empyrean[j][2][1] <= 2) then
                interface.data.progress.gear.empyneed[1][2][1] = interface.data.progress.gear.empyneed[1][2][1] + 9;
            end
        elseif (j == 4) or (j == 5) or (j == 12) or (j == 18) or (j == 19) then
            if (interface.data.progress.gear.empyrean[j][2][1] <= 2) then
                interface.data.progress.gear.empyneed[1][2][2] = interface.data.progress.gear.empyneed[1][2][2] + 9;
            end
        elseif (j == 6) or (j == 8) or (j == 11) or (j == 15) or (j == 17) then
            if (interface.data.progress.gear.empyrean[j][2][1] <= 2) then
                interface.data.progress.gear.empyneed[1][2][3] = interface.data.progress.gear.empyneed[1][2][3] + 9;
            end
        elseif (j == 2) or (j == 3) or (j == 9) or (j == 14) or (j == 20) then
            if (interface.data.progress.gear.empyrean[j][2][1] <= 2) then
                interface.data.progress.gear.empyneed[1][2][4] = interface.data.progress.gear.empyneed[1][2][4] + 9;
            end
        end
        --hands
        if (j == 1) or (j == 5) or (j == 6) or (j == 9) or (j == 20) then
            if (interface.data.progress.gear.empyrean[j][3][1] <= 2) then
                interface.data.progress.gear.empyneed[1][3][1] = interface.data.progress.gear.empyneed[1][3][1] + 6;
            end
        elseif (j == 2) or (j == 4) or (j == 10) or (j == 12) or (j == 15) then
            if (interface.data.progress.gear.empyrean[j][3][1] <= 2) then
                interface.data.progress.gear.empyneed[1][3][2] = interface.data.progress.gear.empyneed[1][3][2] + 6;
            end
        elseif (j == 3) or (j == 8) or (j == 11) or (j == 16) or (j == 19) then
            if (interface.data.progress.gear.empyrean[j][3][1] <= 2) then
                interface.data.progress.gear.empyneed[1][3][3] = interface.data.progress.gear.empyneed[1][3][3] + 6;
            end
        elseif (j == 7) or (j == 13) or (j == 14) or (j == 17) or (j == 18) then
            if (interface.data.progress.gear.empyrean[j][3][1] <= 2) then
                interface.data.progress.gear.empyneed[1][3][4] = interface.data.progress.gear.empyneed[1][3][4] + 6;
            end
        end
        --legs
        if (j == 1) or (j == 4) or (j == 13) or (j == 16) or (j == 18) then
            if (interface.data.progress.gear.empyrean[j][4][1] <= 2) then
                interface.data.progress.gear.empyneed[1][4][1] = interface.data.progress.gear.empyneed[1][4][1] + 6;
            end
        elseif (j == 2) or (j == 9) or (j == 11) or (j == 12) or (j == 20) then
            if (interface.data.progress.gear.empyrean[j][4][1] <= 2) then
                interface.data.progress.gear.empyneed[1][4][2] = interface.data.progress.gear.empyneed[1][4][2] + 6;
            end
        elseif (j == 5) or (j == 6) or (j == 7) or (j == 8) or (j == 10) then
            if (interface.data.progress.gear.empyrean[j][4][1] <= 2) then
                interface.data.progress.gear.empyneed[1][4][3] = interface.data.progress.gear.empyneed[1][4][3] + 6;
            end
        elseif (j == 3) or (j == 14) or (j == 15) or (j == 17) or (j == 19) then
            if (interface.data.progress.gear.empyrean[j][4][1] <= 2) then
                interface.data.progress.gear.empyneed[1][4][4] = interface.data.progress.gear.empyneed[1][4][4] + 6;
            end
        end
        --feet
        if (j == 1) or (j == 5) or (j == 7) or (j == 15) or (j == 19) then
            if (interface.data.progress.gear.empyrean[j][5][1] <= 2) then
                interface.data.progress.gear.empyneed[1][5][1] = interface.data.progress.gear.empyneed[1][5][1] + 6;
            end
        elseif (j == 3) or (j == 6) or (j == 10) or (j == 12) or (j == 18) then
            if (interface.data.progress.gear.empyrean[j][5][1] <= 2) then
                interface.data.progress.gear.empyneed[1][5][2] = interface.data.progress.gear.empyneed[1][5][2] + 6;
            end
        elseif (j == 2) or (j == 8) or (j == 16) or (j == 17) or (j == 20) then
            if (interface.data.progress.gear.empyrean[j][5][1] <= 2) then
                interface.data.progress.gear.empyneed[1][5][3] = interface.data.progress.gear.empyneed[1][5][3] + 6;
            end
        elseif (j == 4) or (j == 9) or (j == 11) or (j == 13) or (j == 14) then
            if (interface.data.progress.gear.empyrean[j][5][1] <= 2) then
                interface.data.progress.gear.empyneed[1][5][4] = interface.data.progress.gear.empyneed[1][5][4] + 6;
            end
        end
    end
end

function manager.CountEmpyGear()
    interface.data.progress.gear.empyneed = {
        {{0,0,0,0,},{0,0,0,0,},{0,0,0,0,},{0,0,0,0,},{0,0,0,0,}},
        {{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}},
        {{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}},
        {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}},
    };
    interface.data.progress.gear.empyneed = manager.CountEmpyGearInv(interface.data.progress.gear.empyneed);
    manager.CountEmpyBaseGear();

    for x = 1, #interface.data.progress.gear.empyrean do
        for y = 1, #interface.data.progress.gear.empyrean[x] do
            if interface.data.progress.gear.empyrean[x][y][1] <= 3 then
                if interface.data.progress.gear.empyrean[x][y][1] <= 2 then
                    interface.data.progress.gear.empyneed[2][y][1] = interface.data.progress.gear.empyneed[2][y][1] + 10;
                else
                    interface.data.progress.gear.empyneed[2][y][1] = interface.data.progress.gear.empyneed[2][y][1] + 5;
                end
                interface.data.progress.gear.empyneed[2][y][2] = interface.data.progress.gear.empyneed[2][y][2] + 1;

                if (x == 1) or (x == 8) then
                    interface.data.progress.gear.empyneed[2][y][3] = interface.data.progress.gear.empyneed[2][y][3] + 1;
                elseif (x == 2) then
                    interface.data.progress.gear.empyneed[2][y][4] = interface.data.progress.gear.empyneed[2][y][4] + 1;
                elseif (x == 3) then
                    interface.data.progress.gear.empyneed[2][y][5] = interface.data.progress.gear.empyneed[2][y][5] + 1;
                elseif (x == 4) then
                    interface.data.progress.gear.empyneed[2][y][6] = interface.data.progress.gear.empyneed[2][y][6] + 1;
                elseif (x == 5) then
                    interface.data.progress.gear.empyneed[2][y][7] = interface.data.progress.gear.empyneed[2][y][7] + 1;
                elseif (x == 6) then
                    interface.data.progress.gear.empyneed[2][y][8] = interface.data.progress.gear.empyneed[2][y][8] + 1;
                elseif (x == 7) then
                    interface.data.progress.gear.empyneed[2][y][9] = interface.data.progress.gear.empyneed[2][y][9] + 1;
                elseif (x == 9) or (x == 15) or (x == 18) then
                    interface.data.progress.gear.empyneed[2][y][10] = interface.data.progress.gear.empyneed[2][y][10] + 1;
                elseif (x == 10) then
                    interface.data.progress.gear.empyneed[2][y][11] = interface.data.progress.gear.empyneed[2][y][11] + 1;
                elseif (x == 11) then
                    interface.data.progress.gear.empyneed[2][y][12] = interface.data.progress.gear.empyneed[2][y][12] + 1;
                elseif (x == 12) then
                    interface.data.progress.gear.empyneed[2][y][13] = interface.data.progress.gear.empyneed[2][y][13] + 1;
                elseif (x == 13) then
                    interface.data.progress.gear.empyneed[2][y][14] = interface.data.progress.gear.empyneed[2][y][14] + 1;
                elseif (x == 14) then
                    interface.data.progress.gear.empyneed[2][y][15] = interface.data.progress.gear.empyneed[2][y][15] + 1;
                elseif (x == 16) then
                    interface.data.progress.gear.empyneed[2][y][16] = interface.data.progress.gear.empyneed[2][y][16] + 1;
                elseif (x == 17) then
                    interface.data.progress.gear.empyneed[2][y][17] = interface.data.progress.gear.empyneed[2][y][17] + 1;
                elseif (x == 19) then
                    interface.data.progress.gear.empyneed[2][y][18] = interface.data.progress.gear.empyneed[2][y][18] + 1;
                elseif (x == 20) then
                    interface.data.progress.gear.empyneed[2][y][19] = interface.data.progress.gear.empyneed[2][y][19] + 1;
                end
            end
            if interface.data.progress.gear.empyrean[x][y][1] <= 4 then
                interface.data.progress.gear.empyneed[3][y][1] = interface.data.progress.gear.empyneed[3][y][1] + 8;
                interface.data.progress.gear.empyneed[3][y][2] = interface.data.progress.gear.empyneed[3][y][2] + 1;
                if (y == 1) then
                    interface.data.progress.gear.empyneed[3][y][3] = interface.data.progress.gear.empyneed[3][y][3] + 15;
                elseif (y == 2) then
                    interface.data.progress.gear.empyneed[3][y][3] = interface.data.progress.gear.empyneed[3][y][3] + 25;
                elseif (y == 3) then
                    interface.data.progress.gear.empyneed[3][y][3] = interface.data.progress.gear.empyneed[3][y][3] + 15;
                elseif (y == 4) then
                    interface.data.progress.gear.empyneed[3][y][3] = interface.data.progress.gear.empyneed[3][y][3] + 20;
                elseif (y == 5) then
                    interface.data.progress.gear.empyneed[3][y][3] = interface.data.progress.gear.empyneed[3][y][3] + 15;
                end
            end
        end
    end
end

function manager.DisplayEmpyGear()
    if check == true then --bool that gets set true on first load and once again whenever the display is first rendered after being disabled
        for k,v in ipairs(interface.defaults.gear.empyUnlockKeyItems) do
            if (modifind.searchKeyItemName(v)) then
                interface.data.progress.gear.empyUnlocks[k] = 1;
            end
        end
        check = false;
    end

    imgui.BeginTable('empy gear has', 5, ImGuiTableFlags_Borders);
    for a = 1, #interface.data.progress.gear.empyrean do
        for b = 1, #interface.data.progress.gear.empyrean[a] do
            imgui.TableNextColumn();
            local temp = {interface.data.progress.gear.empyrean[a][b][1]};
            if (imgui.Combo(interface.data.progress.gear.empyrean[a][b][2], temp, 'None\0NQ\0+1\0+2\0lv109\0lv119+1\0lv119+2\0lv119+3\0')) then
                interface.data.progress.gear.empyrean[a][b][1] = temp[1];
            end
        end
    end
    imgui.EndTable();
    imgui.NewLine();
    imgui.TextColored(interface.colors.header, 'Sortie Unlocks (+3):    ');
    for k,v in ipairs(interface.defaults.jobsabrv) do
        if (interface.data.progress.gear.empyUnlocks[k]) then
            imgui.SameLine();imgui.TextColored(interface.colors.green,v .. ' ');
        else
            imgui.SameLine();imgui.Text(v .. ' ');
        end
    end
    imgui.TextColored(interface.colors.header, 'Progress: ');imgui.SameLine();imgui.ProgressBar(interface.data.progress.gear.empyProgress[1]);
    if (imgui.Button('Update Empy Gear')) then
        print(chat.header(addon.name) .. chat.message('Updated Empyrean Gear'));
        interface.manager.UpdateEmpyGear();
    end
end

function manager.DisplayEmpyBaseGearNeed()
    imgui.BeginTable('empy seals need', 12, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'SEALS');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'HEAD');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'BODY');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'HANDS');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'LEGS');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'FEET');imgui.TableNextColumn();
        imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'HEAD');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'BODY');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'HANDS');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'LEGS');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'FEET');imgui.TableNextColumn();
        for j = 1, #interface.defaults.jobsabrv do
            imgui.Text(interface.defaults.jobsabrv[j]);imgui.TableNextColumn();
            for p = 1, #interface.data.progress.gear.empyrean[j] do
                if (interface.data.progress.gear.empyrean[j][p][1] <= 1) then
                    if (p == 2) then
                        imgui.Text('10');imgui.TableNextColumn();
                    else
                        imgui.Text('8');
                        if (j == #interface.defaults.jobsabrv) and (p == 5) then 
                        else imgui.TableNextColumn() end
                    end
                else
                    imgui.Text('0');
                    if (j == #interface.defaults.jobsabrv) and (p == 5) then 
                    else imgui.TableNextColumn() end
                end
            end
        end
    imgui.EndTable();

    imgui.BeginTable('empy head need', 5, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'HEAD NEEDS:');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'STONE');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'JEWEL');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'COIN');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'CARD');imgui.TableNextColumn();
        imgui.Text('Vision');imgui.TableNextColumn();
        imgui.Text('WAR/WHM/THF/BRD/RNG');imgui.TableNextColumn();
        imgui.Text('MNK/RDM/SAM/COR/PUP');imgui.TableNextColumn();
        imgui.Text('BLM/DRK/BST/NIN/SMN');imgui.TableNextColumn();
        imgui.Text('PLD/DRG/BLU/DNC/SCH');imgui.TableNextColumn();
        imgui.TableNextColumn();
        for i = 1, #interface.data.progress.gear.empyneed[1][1] do
            imgui.Text(tostring(interface.data.progress.gear.empyneed[1][1][i]));
            if i ~= #interface.data.progress.gear.empyneed[1][1] then imgui.TableNextColumn() end
        end
    imgui.EndTable();

    imgui.BeginTable('empy body need', 5, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'BODY NEEDS:');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'STONE');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'JEWEL');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'COIN');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'CARD');imgui.TableNextColumn();
        imgui.Text('Ardor');imgui.TableNextColumn();
        imgui.Text('WAR/PLD/BRD/NIN/BLU');imgui.TableNextColumn();
        imgui.Text('BLM/RDM/SAM/PUP/DNC');imgui.TableNextColumn();
        imgui.Text('THF/DRK/RNG/SMN/COR');imgui.TableNextColumn();
        imgui.Text('MNK/WHM/BST/DRG/SCH');imgui.TableNextColumn();
        imgui.TableNextColumn();
        for i = 1, #interface.data.progress.gear.empyneed[1][2] do
            imgui.Text(tostring(interface.data.progress.gear.empyneed[1][2][i]));
            if i ~= #interface.data.progress.gear.empyneed[1][2] then imgui.TableNextColumn() end
        end
    imgui.EndTable();

    imgui.BeginTable('empy hands need', 5, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'HANDS NEEDS:');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'STONE');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'JEWEL');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'COIN');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'CARD');imgui.TableNextColumn();
        imgui.Text('Wieldance');imgui.TableNextColumn();
        imgui.Text('WAR/RDM/THF/BST/SCH');imgui.TableNextColumn();
        imgui.Text('MNK/BLM/BRD/SAM/SMN');imgui.TableNextColumn();
        imgui.Text('WHM/DRK/RNG/BLU/DNC');imgui.TableNextColumn();
        imgui.Text('PLD/NIN/DRG/COR/PUP');imgui.TableNextColumn();
        imgui.TableNextColumn();
        for i = 1, #interface.data.progress.gear.empyneed[1][3] do
            imgui.Text(tostring(interface.data.progress.gear.empyneed[1][3][i]));
            if i ~= #interface.data.progress.gear.empyneed[1][3] then imgui.TableNextColumn() end
        end
    imgui.EndTable();

    imgui.BeginTable('empy legs need', 5, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'LEGS NEEDS:');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'STONE');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'JEWEL');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'COIN');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'CARD');imgui.TableNextColumn();
        imgui.Text('Balance');imgui.TableNextColumn();
        imgui.Text('WAR/BLM/NIN/BLU/PUP');imgui.TableNextColumn();
        imgui.Text('MNK/BST/RNG/SAM/SCH');imgui.TableNextColumn();
        imgui.Text('RDM/THF/PLD/DRK/BRD');imgui.TableNextColumn();
        imgui.Text('WHM/DRG/SMN/COR/DNC');imgui.TableNextColumn();
        imgui.TableNextColumn();
        for i = 1, #interface.data.progress.gear.empyneed[1][4] do
            imgui.Text(tostring(interface.data.progress.gear.empyneed[1][4][i]));
            if i ~= #interface.data.progress.gear.empyneed[1][4] then imgui.TableNextColumn() end
        end
    imgui.EndTable();

    imgui.BeginTable('empy feet need', 5, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'FEET NEEDS:');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'STONE');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'JEWEL');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'COIN');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'CARD');imgui.TableNextColumn();
        imgui.Text('Voyage');imgui.TableNextColumn();
        imgui.Text('WAR/RDM/PLD/SMN/DNC');imgui.TableNextColumn();
        imgui.Text('WHM/THF/BRD/SAM/PUP');imgui.TableNextColumn();
        imgui.Text('MNK/DRK/BLU/COR/SCH');imgui.TableNextColumn();
        imgui.Text('BLM/BST/RNG/NIN/DRG');imgui.TableNextColumn();
        imgui.TableNextColumn();
        for i = 1, #interface.data.progress.gear.empyneed[1][5] do
            imgui.Text(tostring(interface.data.progress.gear.empyneed[1][5][i]));
            if i ~= #interface.data.progress.gear.empyneed[1][5] then imgui.TableNextColumn() end
        end
    imgui.EndTable();
    if (imgui.Button('Update Empy Gear')) then
        print(chat.header(addon.name) .. chat.message('Updated Empyrean Gear'));
        interface.manager.UpdateEmpyGear();
    end
end

function manager.DisplayEmpyReforgedGearNeed()
    imgui.BeginTable('chapters', 11, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Chapters');imgui.TableNextColumn();
        for t = 1, 10 do
            imgui.TextColored(interface.colors.header,'Chap. ' .. t);imgui.TableNextColumn();
        end
        imgui.TableNextColumn();
        for i = 1, 5 do
            imgui.Text(tostring(interface.data.progress.gear.empyneed[2][i][1]));imgui.TableNextColumn();
        end
        for i = 1, 5 do
            imgui.Text(tostring(interface.data.progress.gear.empyneed[3][i][1]));
            if (i ~= 5) then imgui.TableNextColumn() end
        end
    imgui.EndTable();

    imgui.BeginTable('109slot', 6, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Lv109');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Head');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Body');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Hands');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Legs');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Feet');imgui.TableNextColumn();
        imgui.Text('Slot');imgui.TableNextColumn();
        imgui.Text('Phx. Feather');imgui.TableNextColumn();
        imgui.Text('Mal. Fiber');imgui.TableNextColumn();
        imgui.Text('Btl. Blood');imgui.TableNextColumn();
        imgui.Text('Damas. Cloth');imgui.TableNextColumn();
        imgui.Text('Oxblood');imgui.TableNextColumn();
        imgui.Text('Items');imgui.TableNextColumn();
        for i = 1, #interface.data.progress.gear.empyneed[2] do
            imgui.Text(tostring(interface.data.progress.gear.empyneed[2][i][2]));
            if (i ~= #interface.data.progress.gear.empyneed[2]) then imgui.TableNextColumn() end
        end
    imgui.EndTable();

    imgui.BeginTable('109job', 6, ImGuiTableFlags_Borders);
        local names = {'Briareus','Itzpapalotl','Orthrus','Glavoid','Cirein-croin','Alfard','Kukulkan','Carabosse','Dragua','Ulhuadshi','Apademak','Bukhis','Azdaja','Isgebind','Sobek','Chloris','Sedna'};
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Lv109 Job Items');imgui.TableNextColumn();
        imgui.TableNextRow();imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'WAR/DRK');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'MNK');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'WHM');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'BLM');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'RDM');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'THF');imgui.TableNextColumn();
        for x = 3, 8 do
            local count = 0;
            for i = 1, #interface.data.progress.gear.empyneed[2] do
                count = count + interface.data.progress.gear.empyneed[2][i][x];
            end
            imgui.Text(tostring(count) .. '   ' .. names[x-2]);imgui.TableNextColumn();
        end
        imgui.TextColored(interface.colors.header, 'PLD');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'BST/SMN/PUP');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'BRD');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'RNG');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'SAM');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'NIN');imgui.TableNextColumn();
        for x = 9, 14 do
            local count = 0;
            for i = 1, #interface.data.progress.gear.empyneed[2] do
                count = count + interface.data.progress.gear.empyneed[2][i][x];
            end
            imgui.Text(tostring(count) .. '   ' .. names[x-2]);imgui.TableNextColumn();
        end
        imgui.TextColored(interface.colors.header, 'DRG');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'BLU');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'COR');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'DNC');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'SCH');imgui.TableNextColumn();
        imgui.TableNextColumn();
        for x = 15, 19 do
            local count = 0;
            for i = 1, #interface.data.progress.gear.empyneed[2] do
                count = count + interface.data.progress.gear.empyneed[2][i][x];
            end
            imgui.Text(tostring(count) .. '   ' .. names[x-2]);
            if x ~= 19 then imgui.TableNextColumn() end
        end
    imgui.EndTable();

    imgui.BeginTable('119slot', 6, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Lv119');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Head');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Body');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Hands');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Legs');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Feet');imgui.TableNextColumn();
        imgui.Text('Slot');imgui.TableNextColumn();
        imgui.Text('Defiant Sweat');imgui.TableNextColumn();
        imgui.Text('Dark Matter');imgui.TableNextColumn();
        imgui.Text('Macuil Horn');imgui.TableNextColumn();
        imgui.Text('Tartarian Chain');imgui.TableNextColumn();
        imgui.Text('Plovid Effluvium');imgui.TableNextColumn();
        imgui.Text('Items');imgui.TableNextColumn();
        for i = 1, #interface.data.progress.gear.empyneed[3] do
            imgui.Text(tostring(interface.data.progress.gear.empyneed[3][i][2]));
            if (i ~= #interface.data.progress.gear.empyneed[3]) then imgui.TableNextColumn() end
        end
    imgui.EndTable();

    imgui.BeginTable('119memories', 6, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Total Etched Mems');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Head (15/ea)');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Body (25/ea)');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Hands (15/ea)');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Legs (20/ea)');imgui.TableNextColumn();
        imgui.TextColored(interface.colors.header, 'Feet (15/ea)');imgui.TableNextColumn();
        local count = 0;
        for i = 1, #interface.data.progress.gear.empyneed[3] do
            count = count + interface.data.progress.gear.empyneed[3][i][3];
            if (i == #interface.data.progress.gear.empyneed[3]) then
                imgui.Text(tostring(count));imgui.TableNextColumn();
            end
        end
        for i = 1, #interface.data.progress.gear.empyneed[3] do
            imgui.Text(tostring(interface.data.progress.gear.empyneed[3][i][3]));
            if (i ~= #interface.data.progress.gear.empyneed[3]) then imgui.TableNextColumn() end
        end
    imgui.EndTable();
    if (imgui.Button('Update Empy Gear')) then
        print(chat.header(addon.name) .. chat.message('Updated Empyrean Gear'));
        interface.manager.UpdateEmpyGear();
    end
end

function manager.UpdateAmbuGear()
    for set = 1, #interface.defaults.gear.ambu do
        for slot = 1, #interface.defaults.gear.ambu[set] do
            local count = 1;
            if interface.data.progress.gear.ambu[set][slot][1] == #interface.defaults.gear.ambu[set][slot] then
                count = #interface.defaults.gear.ambu[set][slot] + 1;
            elseif interface.data.progress.gear.ambu[set][slot][1] == 0 then
            else count = interface.data.progress.gear.ambu[set][slot][1] end
            for c = 1, #interface.defaults.gear.ambu[set][slot] do
                if (modifind.searchId(interface.defaults.gear.ambu[set][slot][c])) then
                    interface.data.progress.gear.ambu[set][slot][1] = c;
                end
            end
        end
    end
end

function manager.DisplayAmbuGear()
    imgui.BeginTable('ambu gear has', 5, ImGuiTableFlags_Borders);
    for a = 1, #interface.data.progress.gear.ambu do
        for b = 1, #interface.data.progress.gear.ambu[a] do
            imgui.TableNextColumn();
            local temp = {interface.data.progress.gear.ambu[a][b][1]};
            if (imgui.Combo(interface.data.progress.gear.ambu[a][b][2], temp, 'None\0NQ\0+1\0+2\0')) then
                interface.data.progress.gear.ambu[a][b][1] = temp[1];
            end
            if a == 5 then
                imgui.NewLine();imgui.Separator();imgui.NewLine();
            end
        end
    end
    imgui.EndTable();
end

function manager.DisplayAmbuGearNeed()
    local headvouchers = 0;local bodyvouchers = 0;local handvouchers = 0;local legvouchers = 0;local feetvouchers = 0;local headtokens = 0;local bodytokens = 0;local handtokens = 0;local legtokens = 0;local feettokens = 0;
    local countmetals = modifind.countItemId(9270);
    local countfibers = modifind.countItemId(9271);
    interface.data.progress.gear.ambuProgress[1] = 0.0;
    local metals = 0;
    local fibers = 0;

    for s = 1, #interface.data.progress.gear.ambu do 
        for p = 1, #interface.data.progress.gear.ambu[s] do
            if (interface.data.progress.gear.ambu[s][p][1] == -1) or (interface.data.progress.gear.ambu[s][p][1] == 0) then
                if (s < 6) then
                    if (p == 1) then
                        headvouchers = headvouchers + 1;
                    elseif (p == 2) then
                        bodyvouchers = bodyvouchers + 1;
                    elseif (p == 3) then
                        handvouchers = handvouchers + 1;
                    elseif (p == 4) then
                        legvouchers = legvouchers + 1;
                    elseif (p == 5) then
                        feetvouchers = feetvouchers + 1;
                    end
                    metals = metals + 15;
                else
                    if (p == 1) then
                        headtokens = headtokens + 1;
                    elseif (p == 2) then
                        bodytokens = bodytokens + 1;
                    elseif (p == 3) then
                        handtokens = handtokens + 1;
                    elseif (p == 4) then
                        legtokens = legtokens + 1;
                    elseif (p == 5) then
                        feettokens = feettokens + 1;
                    end
                    fibers = fibers + 15;
                end
            elseif (interface.data.progress.gear.ambu[s][p][1] == 1) then
                if (s < 6) then
                    metals = metals + 15;
                else
                    fibers = fibers + 15;
                end
            elseif (interface.data.progress.gear.ambu[s][p][1] == 2) then
                if (s < 6) then
                    metals = metals + 10;
                else
                    fibers = fibers + 10;
                end
            end
        end
    end
    interface.data.progress.gear.ambuProgress[1] = (750-(fibers+metals))/750;
    if countmetals > metals then
        metals = 0;
    else
        metals = metals - countmetals;
    end
    if countfibers > fibers then
        fibers = 0;
    else
        fibers = fibers - countfibers;
    end

    imgui.NewLine();imgui.NewLine();imgui.Separator();imgui.NewLine();imgui.NewLine();

    imgui.TextColored(interface.colors.green, 'Total AMBU Gear Completion:');imgui.ShowHelp('Inaccurate but close, quick progress calc based on remaining metals/fibers needed');
    imgui.ProgressBar(interface.data.progress.gear.ambuProgress[1]);
    imgui.NewLine();imgui.NewLine();
    imgui.BeginTable('ambu gear need', 6, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Ambu Gear Slips Need:');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Head');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Body');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Hands');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Legs');
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Feet');
                        
        imgui.TableNextColumn();imgui.Text('A. Vouchers:');
        imgui.TableNextColumn();imgui.Text(tostring(headvouchers));
        imgui.TableNextColumn();imgui.Text(tostring(bodyvouchers));
        imgui.TableNextColumn();imgui.Text(tostring(handvouchers));
        imgui.TableNextColumn();imgui.Text(tostring(legvouchers));
        imgui.TableNextColumn();imgui.Text(tostring(feetvouchers));

        imgui.TableNextColumn();imgui.Text('A. Tokens:');
        imgui.TableNextColumn();imgui.Text(tostring(headtokens));
        imgui.TableNextColumn();imgui.Text(tostring(bodytokens));
        imgui.TableNextColumn();imgui.Text(tostring(handtokens));
        imgui.TableNextColumn();imgui.Text(tostring(legtokens));
        imgui.TableNextColumn();imgui.Text(tostring(feettokens));

        imgui.TableNextRow(ImGuiTableRowFlags_Headers);
        imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Upgrade Items Need:');
        imgui.TableNextColumn();
        imgui.TableNextColumn();
        imgui.TableNextColumn();
        imgui.TableNextColumn();
        imgui.TableNextColumn();

        imgui.TableNextColumn();imgui.Text('Abdhaljs Metals:');
        imgui.TableNextColumn();imgui.Text(tostring(metals));
        imgui.TableNextColumn();imgui.TableNextColumn();imgui.TableNextColumn();imgui.TableNextColumn();

        imgui.TableNextColumn();imgui.Text('Abdhaljs Fibers:');
        imgui.TableNextColumn();imgui.Text(tostring(fibers));
    imgui.EndTable();
    imgui.NewLine();
    if (imgui.Button('Update Ambu Gear')) then
        print(chat.header(addon.name) .. chat.message('Updated Ambuscade Gear'));
        interface.manager.UpdateAmbuGear();
    end
end

function manager.DisplayScaleGear()
    local estmats = 0;
    local estgil = 0;
    imgui.BeginGroup();
        if (imgui.BeginTabBar('gear_tabbar', ImGuiTabBarFlags_NoCloseWithMiddleMouseButton)) then
            if (imgui.BeginTabItem('Scale Working', nil)) then
                imgui.BeginChild('topscaleworking', { 0, 400, }, true);
                    imgui.BeginTable('scale gear working', 4, ImGuiTableFlags_Borders);
                        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, 'List of Tracked Items');imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, 'Status');imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, 'Est. Mats');imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, 'Est. Gil');
                        for i = 1, #interface.data.progress.gear.unm.scale do
                            local track = {interface.data.progress.gear.unm.scale[i][2]};
                            local done = interface.data.progress.gear.unm.scale[i][3];
                            local own = interface.data.progress.gear.unm.scale[i][4];
                            if done == true then track[1] = false end;--dont allow tracking of completed gears
                            if track[1] == true then
                                imgui.TableNextColumn();
                                imgui.Checkbox(interface.data.progress.gear.unm.scale[i][1], track);imgui.TableNextColumn();
                                interface.data.progress.gear.unm.scale[i][2] = track[1];
                                if (own == true) then
                                    imgui.TextColored(interface.colors.warning, 'Rank: ' .. tostring(interface.data.progress.gear.unm.scale[i][5]));
                                    imgui.TableNextColumn();
                                    if interface.data.progress.gear.unm.scale[i][5] == 0 then
                                    estmats = estmats + interface.data.progress.gear.unm.scale[i][6] - modifind.countItemId(4086) +1;
                                    imgui.TextColored(interface.colors.warning, tostring(interface.data.progress.gear.unm.scale[i][6] - modifind.countItemId(4086) +1));
                                    else
                                    estmats = estmats + interface.data.progress.gear.unm.scale[i][6] - modifind.countItemId(4086);
                                    imgui.TextColored(interface.colors.warning, tostring(interface.data.progress.gear.unm.scale[i][6] - modifind.countItemId(4086)));
                                    end
                                    imgui.TableNextColumn();
                                    estgil = estgil + interface.data.progress.gear.unm.scale[i][7];
                                    imgui.TextColored(interface.colors.warning, tostring(manager.comma_value(interface.data.progress.gear.unm.scale[i][7])));
                                else
                                    imgui.TextColored(interface.colors.error, 'HQ NOT OWNED');
                                    imgui.TableNextColumn();
                                    estmats = estmats + interface.data.progress.gear.unm.scale[i][6] - modifind.countItemId(4086) +1;
                                    imgui.TextColored(interface.colors.warning, tostring(interface.data.progress.gear.unm.scale[i][6]- modifind.countItemId(4086) +1));
                                    imgui.TableNextColumn();
                                    estgil = estgil + interface.data.progress.gear.unm.scale[i][7];
                                    imgui.TextColored(interface.colors.warning, tostring(manager.comma_value(interface.data.progress.gear.unm.scale[i][7])));
                                end
                            end
                        end
                    imgui.EndTable();
                imgui.EndChild();

                imgui.BeginChild('bottomscaleworking', { 0, -imgui.GetFrameHeightWithSpacing(), }, true);
                    imgui.BeginTable('scale gear working totals', 5, ImGuiTableFlags_Borders);
                        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();imgui.TableNextColumn();imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, '      Working Totals');imgui.TableNextColumn();
                        imgui.TableNextColumn();imgui.TableNextColumn();imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.warning, 'Scales:  ' .. tostring(manager.comma_value(estmats)));imgui.TableNextColumn();imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.warning, 'Gil:  ' .. tostring(manager.comma_value(estgil)));
                    imgui.EndTable();
                imgui.EndChild();
            imgui.EndTabItem();
            end

            if (imgui.BeginTabItem('Scale Other', nil)) then
                imgui.BeginChild('topscaleother', { 0, 300, }, true);
                    imgui.BeginTable('scale gear other', 3, ImGuiTableFlags_Borders);
                        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, 'Click to Track');imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, 'Status');imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, 'Est. Mats');
                        for i = 1, #interface.data.progress.gear.unm.scale do
                            local track = {interface.data.progress.gear.unm.scale[i][2]};
                            local done = interface.data.progress.gear.unm.scale[i][3];
                            local own = interface.data.progress.gear.unm.scale[i][4];
                            if done == true then track[1] = false end;--dont allow tracking of completed gears
                            if track[1] == false and done == false then
                                imgui.TableNextColumn();
                                imgui.Checkbox(interface.data.progress.gear.unm.scale[i][1], track);imgui.TableNextColumn();
                                interface.data.progress.gear.unm.scale[i][2] = track[1];
                                if (own == true) then
                                    local display = 'Rank: ' .. tostring(interface.data.progress.gear.unm.scale[i][5]);
                                    imgui.TextColored(interface.colors.warning, display);
                                    imgui.TableNextColumn();
                                    imgui.TextColored(interface.colors.warning, tostring(interface.data.progress.gear.unm.scale[i][6]- modifind.countItemId(4086)));
                                else
                                    imgui.TextColored(interface.colors.error, 'HQ NOT OWNED');
                                    interface.data.progress.gear.unm.scale[i][6] = 1191;
                                    imgui.TableNextColumn();
                                    imgui.TextColored(interface.colors.warning, tostring(interface.data.progress.gear.unm.scale[i][6]- modifind.countItemId(4086)));
                                end
                            end
                        end
                    imgui.EndTable();
                imgui.EndChild();

                imgui.BeginChild('bottomscaleother', { 0, -imgui.GetFrameHeightWithSpacing(), }, true);
                    imgui.BeginTable('scale gear completed', 3, ImGuiTableFlags_Borders);
                        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, 'Completed Gears');
                        imgui.TableNextColumn();imgui.TableNextColumn();
                        for i = 1, #interface.data.progress.gear.unm.scale do
                            local track = {interface.data.progress.gear.unm.scale[i][2]};
                            local done = interface.data.progress.gear.unm.scale[i][3];
                            if done == true then track[1] = false end;--dont allow tracking of completed gears
                            if track[1] == false and done == true then
                                imgui.TableNextColumn();
                                imgui.Checkbox(interface.data.progress.gear.unm.scale[i][1], track);imgui.TableNextColumn();
                                interface.data.progress.gear.unm.scale[i][2] = track[1];
                                imgui.TextColored(interface.colors.green, 'COMPLETED');
                                imgui.TableNextColumn();
                            end
                        end
                    imgui.EndTable();
                imgui.EndChild();
            imgui.EndTabItem();
            end
        imgui.EndTabBar();
        end
    imgui.EndGroup();
    if (imgui.Button('Update Scale Gear')) then
        print(chat.header(addon.name) .. chat.message('Updated Scale Gear'));
        manager.UpdateScaleGear();
    end
end

function manager.UpdateScaleGear()
    local temptracked = {};

    for t = 1, #interface.data.progress.gear.unm.scale do
        temptracked[t] = {interface.data.progress.gear.unm.scale[t][2],interface.data.progress.gear.unm.scale[t][3]};
    end

    for l = 1, #interface.defaults.gear.unm.scale do
        interface.data.progress.gear.unm.scale[l]:merge(interface.defaults.gear.unm.scale[l], true);
    end

    for x = 1, #interface.defaults.gear.unm.scale do
        interface.data.progress.gear.unm.scale[x][1] = interface.defaults.gear.unm.scale[x][1];
        interface.data.progress.gear.unm.scale[x][2] = temptracked[x][1];
        interface.data.progress.gear.unm.scale[x][3] = temptracked[x][2];

        if interface.data.progress.gear.unm.scale[x][3] == true then
            --temp
        elseif interface.data.progress.gear.unm.scale[x][4] == false then--force update if HQ not owned
            interface.data.progress.gear.unm.scale[x][4] = modifind.searchId(interface.defaults.gear.unm.scale[x][2]);
            if interface.data.progress.gear.unm.scale[x][4] == true then
                interface.data.progress.gear.unm.scale[x][5] = modifind.checkItemRankInfo(interface.defaults.gear.unm.scale[x][2]);
                if interface.data.progress.gear.unm.scale[x][5] == 15 then
                    interface.data.progress.gear.unm.scale[x][3] = true;
                end
            end
        else
            --update Rank
            interface.data.progress.gear.unm.scale[x][5] = modifind.checkItemRankInfo(interface.defaults.gear.unm.scale[x][2]);
            if interface.data.progress.gear.unm.scale[x][5] == 15 then
                interface.data.progress.gear.unm.scale[x][3] = true;
                interface.data.progress.gear.unm.scale[x][6] = 0;
            else
            --update Mats
            local points = 0;
                if interface.data.progress.gear.unm.scale[x][5] == 0 then
                    for i = interface.data.progress.gear.unm.scale[x][5] + 1, #manager.pointsmap do
                        points = points + manager.pointsmap[i];
                    end
                else
                    for i = interface.data.progress.gear.unm.scale[x][5], #manager.pointsmap do
                        points = points + manager.pointsmap[i];
                    end
                end
            interface.data.progress.gear.unm.scale[x][6] = (points / 5);
            end
            --update gil
            interface.data.progress.gear.unm.scale[x][7] = interface.data.prices['Lustreless Scales'][1] * interface.data.progress.gear.unm.scale[x][6];
        end
    end
end

function manager.DisplayHideGear()
    local estmats = 0;
    local estgil = 0;
    imgui.BeginGroup();
        if (imgui.BeginTabBar('gear_tabbar', ImGuiTabBarFlags_NoCloseWithMiddleMouseButton)) then
            if (imgui.BeginTabItem('Hide Working', nil)) then
                imgui.BeginChild('tophideworking', { 0, 400, }, true);
                    imgui.BeginTable('hide gear working', 4, ImGuiTableFlags_Borders);
                        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, 'List of Tracked Items');imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, 'Status');imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, 'Est. Mats');imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, 'Est. Gil');
                        for i = 1, #interface.data.progress.gear.unm.hide do
                            local track = {interface.data.progress.gear.unm.hide[i][2]};
                            local done = interface.data.progress.gear.unm.hide[i][3];
                            local own = interface.data.progress.gear.unm.hide[i][4];
                            if done == true then track[1] = false end;--dont allow tracking of completed gears
                            if track[1] == true then
                                imgui.TableNextColumn();
                                imgui.Checkbox(interface.data.progress.gear.unm.hide[i][1], track);imgui.TableNextColumn();
                                interface.data.progress.gear.unm.hide[i][2] = track[1];
                                if (own == true) then
                                    imgui.TextColored(interface.colors.warning, 'Rank: ' .. tostring(interface.data.progress.gear.unm.hide[i][5]));
                                    imgui.TableNextColumn();
                                    if interface.data.progress.gear.unm.hide[i][5] == 0 then
                                    estmats = estmats + interface.data.progress.gear.unm.hide[i][6] - modifind.countItemId(4087) +1;
                                    imgui.TextColored(interface.colors.warning, tostring(interface.data.progress.gear.unm.hide[i][6] - modifind.countItemId(4087) +1));
                                    else
                                    estmats = estmats + interface.data.progress.gear.unm.hide[i][6] - modifind.countItemId(4087);
                                    imgui.TextColored(interface.colors.warning, tostring(interface.data.progress.gear.unm.hide[i][6] - modifind.countItemId(4087)));
                                    end
                                    imgui.TableNextColumn();
                                    estgil = estgil + interface.data.progress.gear.unm.hide[i][7];
                                    imgui.TextColored(interface.colors.warning, tostring(manager.comma_value(interface.data.progress.gear.unm.hide[i][7])));
                                else
                                    imgui.TextColored(interface.colors.error, 'HQ NOT OWNED');
                                    imgui.TableNextColumn();
                                    estmats = estmats + interface.data.progress.gear.unm.hide[i][6] - modifind.countItemId(4087) +1;
                                    imgui.TextColored(interface.colors.warning, tostring(interface.data.progress.gear.unm.hide[i][6]- modifind.countItemId(4087) +1));
                                    imgui.TableNextColumn();
                                    estgil = estgil + interface.data.progress.gear.unm.hide[i][7];
                                    imgui.TextColored(interface.colors.warning, tostring(manager.comma_value(interface.data.progress.gear.unm.hide[i][7])));
                                end
                            end
                        end
                    imgui.EndTable();
                imgui.EndChild();

                imgui.BeginChild('bottomhideworking', { 0, -imgui.GetFrameHeightWithSpacing(), }, true);
                    imgui.BeginTable('hide gear working totals', 5, ImGuiTableFlags_Borders);
                        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();imgui.TableNextColumn();imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, '      Working Totals');imgui.TableNextColumn();
                        imgui.TableNextColumn();imgui.TableNextColumn();imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.warning, 'Hides:  ' .. tostring(manager.comma_value(estmats)));imgui.TableNextColumn();imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.warning, 'Gil:  ' .. tostring(manager.comma_value(estgil)));
                    imgui.EndTable();
                imgui.EndChild();
            imgui.EndTabItem();
            end

            if (imgui.BeginTabItem('Hide Other', nil)) then
                imgui.BeginChild('tophideother', { 0, 300, }, true);
                    imgui.BeginTable('hide gear other', 3, ImGuiTableFlags_Borders);
                        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, 'Click to Track');imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, 'Status');imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, 'Est. Mats');
                        for i = 1, #interface.data.progress.gear.unm.hide do
                            local track = {interface.data.progress.gear.unm.hide[i][2]};
                            local done = interface.data.progress.gear.unm.hide[i][3];
                            local own = interface.data.progress.gear.unm.hide[i][4];
                            if done == true then track[1] = false end;--dont allow tracking of completed gears
                            if track[1] == false and done == false then
                                imgui.TableNextColumn();
                                imgui.Checkbox(interface.data.progress.gear.unm.hide[i][1], track);imgui.TableNextColumn();
                                interface.data.progress.gear.unm.hide[i][2] = track[1];
                                if (own == true) then
                                    local display = 'Rank: ' .. tostring(interface.data.progress.gear.unm.hide[i][5]);
                                    imgui.TextColored(interface.colors.warning, display);
                                    imgui.TableNextColumn();
                                    imgui.TextColored(interface.colors.warning, tostring(interface.data.progress.gear.unm.hide[i][6]- modifind.countItemId(4087)));
                                else
                                    imgui.TextColored(interface.colors.error, 'HQ NOT OWNED');
                                    interface.data.progress.gear.unm.hide[i][6] = 1191;
                                    imgui.TableNextColumn();
                                    imgui.TextColored(interface.colors.warning, tostring(interface.data.progress.gear.unm.hide[i][6]- modifind.countItemId(4087)));
                                end
                            end
                        end
                    imgui.EndTable();
                imgui.EndChild();

                imgui.BeginChild('bottomhideother', { 0, -imgui.GetFrameHeightWithSpacing(), }, true);
                    imgui.BeginTable('hide gear completed', 3, ImGuiTableFlags_Borders);
                        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, 'Completed Gears');
                        imgui.TableNextColumn();imgui.TableNextColumn();
                        for i = 1, #interface.data.progress.gear.unm.hide do
                            local track = {interface.data.progress.gear.unm.hide[i][2]};
                            local done = interface.data.progress.gear.unm.hide[i][3];
                            if done == true then track[1] = false end;--dont allow tracking of completed gears
                            if track[1] == false and done == true then
                                imgui.TableNextColumn();
                                imgui.Checkbox(interface.data.progress.gear.unm.hide[i][1], track);imgui.TableNextColumn();
                                interface.data.progress.gear.unm.hide[i][2] = track[1];
                                imgui.TextColored(interface.colors.green, 'COMPLETED');
                                imgui.TableNextColumn();
                            end
                        end
                    imgui.EndTable();
                imgui.EndChild();
            imgui.EndTabItem();
            end
        imgui.EndTabBar();
        end
    imgui.EndGroup();
    if (imgui.Button('Update Hide Gear')) then
        print(chat.header(addon.name) .. chat.message('Updated Hide Gear'));
        manager.UpdateHideGear();
    end
end

function manager.UpdateHideGear()
    local temptracked = {};

    for t = 1, #interface.data.progress.gear.unm.hide do
        temptracked[t] = {interface.data.progress.gear.unm.hide[t][2],interface.data.progress.gear.unm.hide[t][3]};
    end

    for l = 1, #interface.defaults.gear.unm.hide do
        interface.data.progress.gear.unm.hide[l]:merge(interface.defaults.gear.unm.hide[l], true);
    end

    for x = 1, #interface.defaults.gear.unm.hide do
        interface.data.progress.gear.unm.hide[x][1] = interface.defaults.gear.unm.hide[x][1];
        interface.data.progress.gear.unm.hide[x][2] = temptracked[x][1];
        interface.data.progress.gear.unm.hide[x][3] = temptracked[x][2];

        if interface.data.progress.gear.unm.hide[x][3] == true then
            --temp
        elseif interface.data.progress.gear.unm.hide[x][4] == false then--force update if HQ not owned
            interface.data.progress.gear.unm.hide[x][4] = modifind.searchId(interface.defaults.gear.unm.hide[x][2]);
            if interface.data.progress.gear.unm.hide[x][4] == true then
                interface.data.progress.gear.unm.hide[x][5] = modifind.checkItemRankInfo(interface.defaults.gear.unm.hide[x][2]);
                if interface.data.progress.gear.unm.hide[x][5] == 15 then
                    interface.data.progress.gear.unm.hide[x][3] = true;
                end
            end
        else
            --update Rank
            interface.data.progress.gear.unm.hide[x][5] = modifind.checkItemRankInfo(interface.defaults.gear.unm.hide[x][2]);
            if interface.data.progress.gear.unm.hide[x][5] == 15 then
                interface.data.progress.gear.unm.hide[x][3] = true;
                interface.data.progress.gear.unm.hide[x][6] = 0;
            else
            --update Mats
            local points = 0;
                if interface.data.progress.gear.unm.hide[x][5] == 0 then
                    for i = interface.data.progress.gear.unm.hide[x][5] + 1, #manager.pointsmap do
                        points = points + manager.pointsmap[i];
                    end
                else
                    for i = interface.data.progress.gear.unm.hide[x][5], #manager.pointsmap do
                        points = points + manager.pointsmap[i];
                    end
                end
            interface.data.progress.gear.unm.hide[x][6] = (points / 5);
            end
            --update gil
            interface.data.progress.gear.unm.hide[x][7] = interface.data.prices['Lustreless Hides'][1] * interface.data.progress.gear.unm.hide[x][6];
        end
    end
end

function manager.DisplayWingGear()
    local estmats = 0;
    local estgil = 0;
    imgui.BeginGroup();
        if (imgui.BeginTabBar('gear_tabbar', ImGuiTabBarFlags_NoCloseWithMiddleMouseButton)) then
            if (imgui.BeginTabItem('Wing Working', nil)) then
                imgui.BeginChild('topwingworking', { 0, 400, }, true);
                    imgui.BeginTable('wing gear working', 4, ImGuiTableFlags_Borders);
                        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, 'List of Tracked Items');imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, 'Status');imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, 'Est. Mats');imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, 'Est. Gil');
                        for i = 1, #interface.data.progress.gear.unm.wing do
                            local track = {interface.data.progress.gear.unm.wing[i][2]};
                            local done = interface.data.progress.gear.unm.wing[i][3];
                            local own = interface.data.progress.gear.unm.wing[i][4];
                            if done == true then track[1] = false end;--dont allow tracking of completed gears
                            if track[1] == true then
                                imgui.TableNextColumn();
                                imgui.Checkbox(interface.data.progress.gear.unm.wing[i][1], track);imgui.TableNextColumn();
                                interface.data.progress.gear.unm.wing[i][2] = track[1];
                                if (own == true) then
                                    imgui.TextColored(interface.colors.warning, 'Rank: ' .. tostring(interface.data.progress.gear.unm.wing[i][5]));
                                    imgui.TableNextColumn();
                                    if interface.data.progress.gear.unm.wing[i][5] == 0 then
                                    estmats = estmats + interface.data.progress.gear.unm.wing[i][6] - modifind.countItemId(4088) +1;
                                    imgui.TextColored(interface.colors.warning, tostring(interface.data.progress.gear.unm.wing[i][6] - modifind.countItemId(4088) +1));
                                    else
                                    estmats = estmats + interface.data.progress.gear.unm.wing[i][6] - modifind.countItemId(4088);
                                    imgui.TextColored(interface.colors.warning, tostring(interface.data.progress.gear.unm.wing[i][6] - modifind.countItemId(4088)));
                                    end
                                    imgui.TableNextColumn();
                                    estgil = estgil + interface.data.progress.gear.unm.wing[i][7];
                                    imgui.TextColored(interface.colors.warning, tostring(manager.comma_value(interface.data.progress.gear.unm.wing[i][7])));
                                else
                                    imgui.TextColored(interface.colors.error, 'HQ NOT OWNED');
                                    imgui.TableNextColumn();
                                    estmats = estmats + interface.data.progress.gear.unm.wing[i][6] - modifind.countItemId(4088) +1;
                                    imgui.TextColored(interface.colors.warning, tostring(interface.data.progress.gear.unm.wing[i][6]- modifind.countItemId(4088) +1));
                                    imgui.TableNextColumn();
                                    estgil = estgil + interface.data.progress.gear.unm.wing[i][7];
                                    imgui.TextColored(interface.colors.warning, tostring(manager.comma_value(interface.data.progress.gear.unm.wing[i][7])));
                                end
                            end
                        end
                    imgui.EndTable();
                imgui.EndChild();

                imgui.BeginChild('bottomwingworking', { 0, -imgui.GetFrameHeightWithSpacing(), }, true);
                    imgui.BeginTable('wing gear working totals', 5, ImGuiTableFlags_Borders);
                        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();imgui.TableNextColumn();imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, '      Working Totals');imgui.TableNextColumn();
                        imgui.TableNextColumn();imgui.TableNextColumn();imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.warning, 'wings:  ' .. tostring(manager.comma_value(estmats)));imgui.TableNextColumn();imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.warning, 'Gil:  ' .. tostring(manager.comma_value(estgil)));
                    imgui.EndTable();
                imgui.EndChild();
            imgui.EndTabItem();
            end

            if (imgui.BeginTabItem('Wing Other', nil)) then
                imgui.BeginChild('topwingother', { 0, 300, }, true);
                    imgui.BeginTable('wing gear other', 3, ImGuiTableFlags_Borders);
                        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, 'Click to Track');imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, 'Status');imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, 'Est. Mats');
                        for i = 1, #interface.data.progress.gear.unm.wing do
                            local track = {interface.data.progress.gear.unm.wing[i][2]};
                            local done = interface.data.progress.gear.unm.wing[i][3];
                            local own = interface.data.progress.gear.unm.wing[i][4];
                            if done == true then track[1] = false end;--dont allow tracking of completed gears
                            if track[1] == false and done == false then
                                imgui.TableNextColumn();
                                imgui.Checkbox(interface.data.progress.gear.unm.wing[i][1], track);imgui.TableNextColumn();
                                interface.data.progress.gear.unm.wing[i][2] = track[1];
                                if (own == true) then
                                    local display = 'Rank: ' .. tostring(interface.data.progress.gear.unm.wing[i][5]);
                                    imgui.TextColored(interface.colors.warning, display);
                                    imgui.TableNextColumn();
                                    imgui.TextColored(interface.colors.warning, tostring(interface.data.progress.gear.unm.wing[i][6]- modifind.countItemId(4088)));
                                else
                                    imgui.TextColored(interface.colors.error, 'HQ NOT OWNED');
                                    interface.data.progress.gear.unm.wing[i][6] = 1191;
                                    imgui.TableNextColumn();
                                    imgui.TextColored(interface.colors.warning, tostring(interface.data.progress.gear.unm.wing[i][6]- modifind.countItemId(4088)));
                                end
                            end
                        end
                    imgui.EndTable();
                imgui.EndChild();

                imgui.BeginChild('bottomwingother', { 0, -imgui.GetFrameHeightWithSpacing(), }, true);
                    imgui.BeginTable('wing gear completed', 3, ImGuiTableFlags_Borders);
                        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();
                        imgui.TextColored(interface.colors.header, 'Completed Gears');
                        imgui.TableNextColumn();imgui.TableNextColumn();
                        for i = 1, #interface.data.progress.gear.unm.wing do
                            local track = {interface.data.progress.gear.unm.wing[i][2]};
                            local done = interface.data.progress.gear.unm.wing[i][3];
                            if done == true then track[1] = false end;--dont allow tracking of completed gears
                            if track[1] == false and done == true then
                                imgui.TableNextColumn();
                                imgui.Checkbox(interface.data.progress.gear.unm.wing[i][1], track);imgui.TableNextColumn();
                                interface.data.progress.gear.unm.wing[i][2] = track[1];
                                imgui.TextColored(interface.colors.green, 'COMPLETED');
                                imgui.TableNextColumn();
                            end
                        end
                    imgui.EndTable();
                imgui.EndChild();
            imgui.EndTabItem();
            end
        imgui.EndTabBar();
        end
    imgui.EndGroup();
    if (imgui.Button('Update Wing Gear')) then
        print(chat.header(addon.name) .. chat.message('Updated Wing Gear'));
        manager.UpdateWingGear();
    end
end

function manager.UpdateWingGear()
    local temptracked = {};

    for t = 1, #interface.data.progress.gear.unm.wing do
        temptracked[t] = {interface.data.progress.gear.unm.wing[t][2],interface.data.progress.gear.unm.wing[t][3]};
    end

    for l = 1, #interface.defaults.gear.unm.wing do
        interface.data.progress.gear.unm.wing[l]:merge(interface.defaults.gear.unm.wing[l], true);
    end

    for x = 1, #interface.defaults.gear.unm.wing do
        interface.data.progress.gear.unm.wing[x][1] = interface.defaults.gear.unm.wing[x][1];
        interface.data.progress.gear.unm.wing[x][2] = temptracked[x][1];
        interface.data.progress.gear.unm.wing[x][3] = temptracked[x][2];

        if interface.data.progress.gear.unm.wing[x][3] == true then
            --temp
        elseif interface.data.progress.gear.unm.wing[x][4] == false then--force update if HQ not owned
            interface.data.progress.gear.unm.wing[x][4] = modifind.searchId(interface.defaults.gear.unm.wing[x][2]);
            if interface.data.progress.gear.unm.wing[x][4] == true then
                interface.data.progress.gear.unm.wing[x][5] = modifind.checkItemRankInfo(interface.defaults.gear.unm.wing[x][2]);
                if interface.data.progress.gear.unm.wing[x][5] == 15 then
                    interface.data.progress.gear.unm.wing[x][3] = true;
                end
            end
        else
            --update Rank
            interface.data.progress.gear.unm.wing[x][5] = modifind.checkItemRankInfo(interface.defaults.gear.unm.wing[x][2]);
            if interface.data.progress.gear.unm.wing[x][5] == 15 then
                interface.data.progress.gear.unm.wing[x][3] = true;
                interface.data.progress.gear.unm.wing[x][6] = 0;
            else
            --update Mats
            local points = 0;
                if interface.data.progress.gear.unm.wing[x][5] == 0 then
                    for i = interface.data.progress.gear.unm.wing[x][5] + 1, #manager.pointsmap do
                        points = points + manager.pointsmap[i];
                    end
                else
                    for i = interface.data.progress.gear.unm.wing[x][5], #manager.pointsmap do
                        points = points + manager.pointsmap[i];
                    end
                end
            interface.data.progress.gear.unm.wing[x][6] = (points / 5);
            end
            --update gil
            interface.data.progress.gear.unm.wing[x][7] = interface.data.prices['Lustreless wings'][1] * interface.data.progress.gear.unm.wing[x][6];
        end
    end
end

function manager.DisplaySheolAGear();

end

function manager.UpdateSheolAGear();

end

function manager.DisplaySheolBGear();

end

function manager.UpdateSheolBGear();

end

function manager.DisplaySheolCGear();

end

function manager.UpdateSheolCGear();

end

-- this update all gear function not currently used
function manager.UpdateGear()
	manager.UpdateAmbuGear();
    manager.UpdateEmpyGear();
    manager.UpdateRelicGear();
    manager.UpdateAFGear();
end

function manager.DisplayHallmarks()
    local total = 0;
    for k,v in pairs(interface.data.points.hallmarks) do
        if (v[1] == false) then
            total = total + v[2];
        end
    end

    imgui.NewLine();
    imgui.TextColored(interface.colors.header, 'NEEDED HALLMARK POINTS:');imgui.SameLine();imgui.Text('    ' .. interface.manager.comma_value(total) .. '    ');
    imgui.NewLine();imgui.Separator();imgui.NewLine();

    imgui.BeginTable('Weps', 8, ImGuiTableFlags_Borders);
    imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Wep Items');imgui.TableNextRow();imgui.TableNextColumn(); 
        imgui.Checkbox('Nuggets(10)', interface.data.points.hallmarks.nuggets);imgui.TableNextColumn();
            if (interface.data.progress.weapons.ambuWepItems[2] == 0) then interface.data.points.hallmarks.nuggets[1] = true end
            if (interface.data.points.hallmarks.nuggets[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.hallmarks.nuggets[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('Gems(10)', interface.data.points.hallmarks.gems);imgui.TableNextColumn();
            if (interface.data.progress.weapons.ambuWepItems[3] == 0) then interface.data.points.hallmarks.gems[1] = true end
            if (interface.data.points.hallmarks.gems[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.hallmarks.gems[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('Animas(10)', interface.data.points.hallmarks.animas);imgui.TableNextColumn();
            if (interface.data.progress.weapons.ambuWepItems[4] == 0) then interface.data.points.hallmarks.animas[1] = true end
            if (interface.data.points.hallmarks.animas[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.hallmarks.animas[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('Matters(10)', interface.data.points.hallmarks.matters);imgui.TableNextColumn();
            if (interface.data.progress.weapons.ambuWepItems[5] == 0) then interface.data.points.hallmarks.matters[1] = true end
            if (interface.data.points.hallmarks.matters[1]) then
                imgui.Text('    0');
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.hallmarks.matters[2])));
            end
    imgui.EndTable();
    imgui.NewLine();
    imgui.BeginTable('Capes', 10, ImGuiTableFlags_Borders);
    imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Cape Items');imgui.TableNextRow();imgui.TableNextColumn();
        imgui.Checkbox('Threads(40)', interface.data.points.hallmarks.threads);imgui.TableNextColumn();
            if (interface.data.points.hallmarks.threads[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.hallmarks.threads[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('Dusts(40)', interface.data.points.hallmarks.dusts);imgui.TableNextColumn();
            if (interface.data.points.hallmarks.dusts[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.hallmarks.dusts[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('Saps(40)', interface.data.points.hallmarks.saps);imgui.TableNextColumn();
            if (interface.data.points.hallmarks.saps[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.hallmarks.saps[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('Dyes(15)', interface.data.points.hallmarks.dyes);imgui.TableNextColumn();
            if (interface.data.points.hallmarks.dyes[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.hallmarks.dyes[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('Resins(10)', interface.data.points.hallmarks.resins);imgui.TableNextColumn();
            if (interface.data.points.hallmarks.resins[1]) then
                imgui.Text('    0');
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.hallmarks.resins[2])));
            end
    imgui.EndTable();
    imgui.NewLine();
    imgui.BeginTable('DynaCurrency', 6, ImGuiTableFlags_Borders);
    imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Dyna Currency');imgui.TableNextRow();imgui.TableNextColumn();
        imgui.Checkbox('1 Byne(150)', interface.data.points.hallmarks.bynes1);imgui.TableNextColumn();
            if (interface.data.points.hallmarks.bynes1[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.hallmarks.bynes1[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('O.Bronze(150)', interface.data.points.hallmarks.bronze1);imgui.TableNextColumn();
            if (interface.data.points.hallmarks.bronze1[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.hallmarks.bronze1[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('T.Shells(150)', interface.data.points.hallmarks.shells1);imgui.TableNextColumn();
            if (interface.data.points.hallmarks.shells1[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.hallmarks.shells1[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('100Byne(2)', interface.data.points.hallmarks.bynes2);imgui.TableNextColumn();
            if (interface.data.points.hallmarks.bynes2[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.hallmarks.bynes2[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('M.Bronze(2)', interface.data.points.hallmarks.bronze2);imgui.TableNextColumn();
            if (interface.data.points.hallmarks.bronze2[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.hallmarks.bronze2[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('L.Shells(2)', interface.data.points.hallmarks.shells2);imgui.TableNextColumn();
            if (interface.data.points.hallmarks.shells2[1]) then
                imgui.Text('    0');
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.hallmarks.shells2[2])));
            end
    imgui.EndTable();
    imgui.NewLine();
    imgui.BeginTable('MISC', 8, ImGuiTableFlags_Borders);
    imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'MISC');imgui.TableNextRow();imgui.TableNextColumn();
        imgui.Checkbox('Marrows(2)', interface.data.points.hallmarks.marrows);imgui.TableNextColumn();
            if (interface.data.points.hallmarks.marrows[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.hallmarks.marrows[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('Scorias(1)', interface.data.points.hallmarks.scorias);imgui.TableNextColumn();
            if (interface.data.points.hallmarks.scorias[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.hallmarks.scorias[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('R.Dross(3)', interface.data.points.hallmarks.drosses);imgui.TableNextColumn();
            if (interface.data.points.hallmarks.drosses[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.hallmarks.drosses[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('R.Cinders(3)', interface.data.points.hallmarks.cinders);imgui.TableNextColumn();
            if (interface.data.points.hallmarks.cinders[1]) then
                imgui.Text('    0');
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.hallmarks.cinders[2])));
            end
    imgui.EndTable();
    imgui.NewLine();
    imgui.BeginTable('ROCKS', 6, ImGuiTableFlags_Borders);
    imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'ROCKS');imgui.TableNextRow();imgui.TableNextColumn();
        imgui.Checkbox('Plutons(500)', interface.data.points.hallmarks.plutons);imgui.TableNextColumn();
            if (interface.data.points.hallmarks.plutons[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.hallmarks.plutons[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('Boulders(500)', interface.data.points.hallmarks.boulders);imgui.TableNextColumn();
            if (interface.data.points.hallmarks.boulders[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.hallmarks.boulders[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('Beitetsu(500)', interface.data.points.hallmarks.beitetsu);imgui.TableNextColumn();
            if (interface.data.points.hallmarks.beitetsu[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.hallmarks.beitetsu[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('HPBayld(750)', interface.data.points.hallmarks.baylds);imgui.TableNextColumn();
            if (interface.data.points.hallmarks.baylds[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.hallmarks.baylds[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('HMPs(100)', interface.data.points.hallmarks.hmp);imgui.TableNextColumn();
            if (interface.data.points.hallmarks.hmp[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.hallmarks.hmp[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('Alex(1750)', interface.data.points.hallmarks.alex);imgui.TableNextColumn();
            if (interface.data.points.hallmarks.alex[1]) then
                imgui.Text('    0');
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.hallmarks.alex[2])));
            end
    imgui.EndTable();
end

function manager.DisplayGallantry()
    local total = 0;
    for k,v in pairs(interface.data.points.gallantry) do
        total = total + v[2];
        if (v[1] == true) then
            total = total - v[2];
        end
    end

    imgui.NewLine();
    imgui.TextColored(interface.colors.header, 'NEEDED GALLANTRY POINTS:');imgui.SameLine();imgui.Text('    ' .. interface.manager.comma_value(total));
    imgui.NewLine();imgui.Separator();imgui.NewLine();

    imgui.BeginTable('Weps', 8, ImGuiTableFlags_Borders);
    imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Wep Items');imgui.TableNextRow();imgui.TableNextColumn();
        imgui.Checkbox('Nuggets(5)', interface.data.points.gallantry.nuggets);imgui.TableNextColumn();
            if (interface.data.progress.weapons.ambuWepItems[2] == 0) then interface.data.points.gallantry.nuggets[1] = true end
            if (interface.data.points.gallantry.nuggets[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.gallantry.nuggets[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('Gems(5)', interface.data.points.gallantry.gems);imgui.TableNextColumn();
            if (interface.data.progress.weapons.ambuWepItems[3] == 0) then interface.data.points.gallantry.gems[1] = true end
            if (interface.data.points.gallantry.gems[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.gallantry.gems[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('Animas(5)', interface.data.points.gallantry.animas);imgui.TableNextColumn();
            if (interface.data.progress.weapons.ambuWepItems[4] == 0) then interface.data.points.gallantry.animas[1] = true end
            if (interface.data.points.gallantry.animas[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.gallantry.animas[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('Matters(5)', interface.data.points.gallantry.matters);imgui.TableNextColumn();
            if (interface.data.progress.weapons.ambuWepItems[5] == 0) then interface.data.points.gallantry.matters[1] = true end
            if (interface.data.points.gallantry.matters[1]) then
                imgui.Text('    0');
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.gallantry.matters[2])));
            end
    imgui.EndTable();
    imgui.NewLine();
    imgui.BeginTable('Capes', 12, ImGuiTableFlags_Borders);
    imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Cape Items');imgui.TableNextRow();imgui.TableNextColumn();
        imgui.Checkbox('Threads(20)', interface.data.points.gallantry.threads);imgui.TableNextColumn();
            if (interface.data.points.gallantry.threads[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.gallantry.threads[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('Dusts(20)', interface.data.points.gallantry.dusts);imgui.TableNextColumn();
            if (interface.data.points.gallantry.dusts[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.gallantry.dusts[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('Saps(10)', interface.data.points.gallantry.saps);imgui.TableNextColumn();
            if (interface.data.points.gallantry.saps[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.gallantry.saps[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('Dyes(5)', interface.data.points.gallantry.dyes);imgui.TableNextColumn();
            if (interface.data.points.gallantry.dyes[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.gallantry.dyes[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('Resins(5)', interface.data.points.gallantry.resins);imgui.TableNextColumn();
            if (interface.data.points.gallantry.resins[1]) then
                imgui.Text('    0');imgui.TableNextColumn();
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.gallantry.resins[2])));imgui.TableNextColumn();
            end
        imgui.Checkbox('Needles(2)', interface.data.points.gallantry.needles);imgui.TableNextColumn();
            if (interface.data.points.gallantry.needles[1]) then
                imgui.Text('    0');
            else
                imgui.Text(tostring(interface.manager.comma_value(interface.data.points.gallantry.needles[2])));
            end
    imgui.EndTable();
    imgui.NewLine();imgui.NewLine();imgui.Separator();imgui.NewLine();imgui.NewLine();
    local month = {interface.data.points.gallantry.month[1],};
    if (imgui.Combo('Pick the current gallantry month', month, ' \0Relic\0Mythic\0Empyrean\0')) then
        if (month[1] == 0) then
            month[1] = interface.data.points.gallantry.month[1];
        else
            interface.data.points.gallantry.month[1] = month[1];
        end
        if (interface.data.points.gallantry.month[1] == 1) then
            interface.data.points.gallantry.alex[1] = true;interface.data.points.gallantry.baylds[1] = true;interface.data.points.gallantry.beitetsu[1] = true;interface.data.points.gallantry.scorias[1] = true;
            interface.data.points.gallantry.drosses[1] = true;interface.data.points.gallantry.cinders[1] = true;interface.data.points.gallantry.hmp[1] = true;interface.data.points.gallantry.boulders[1] = true;
            interface.data.points.gallantry.plutons[1] = false;interface.data.points.gallantry.marrows[1] = false;interface.data.points.gallantry.bynes1[1] = false;interface.data.points.gallantry.bynes2[1] = false;
            interface.data.points.gallantry.bronze1[1] = false;interface.data.points.gallantry.bronze2[1] = false;interface.data.points.gallantry.shells1[1] = false;interface.data.points.gallantry.shells2[1] = false;
        elseif (interface.data.points.gallantry.month[1] == 2) then
            interface.data.points.gallantry.plutons[1] = true;interface.data.points.gallantry.marrows[1] = true;interface.data.points.gallantry.bynes1[1] = true;interface.data.points.gallantry.bynes2[1] = true;
            interface.data.points.gallantry.bronze1[1] = true;interface.data.points.gallantry.bronze2[1] = true;interface.data.points.gallantry.shells1[1] = true;interface.data.points.gallantry.shells2[1] = true;
            interface.data.points.gallantry.drosses[1] = true;interface.data.points.gallantry.cinders[1] = true;interface.data.points.gallantry.hmp[1] = true;interface.data.points.gallantry.boulders[1] = true;
            interface.data.points.gallantry.alex[1] = false;interface.data.points.gallantry.baylds[1] = false;interface.data.points.gallantry.beitetsu[1] = false;interface.data.points.gallantry.scorias[1] = false;
        elseif (interface.data.points.gallantry.month[1] == 3) then
            interface.data.points.gallantry.plutons[1] = true;interface.data.points.gallantry.marrows[1] = true;interface.data.points.gallantry.bynes1[1] = true;interface.data.points.gallantry.bynes2[1] = true;
            interface.data.points.gallantry.bronze1[1] = true;interface.data.points.gallantry.bronze2[1] = true;interface.data.points.gallantry.shells1[1] = true;interface.data.points.gallantry.shells2[1] = true;
            interface.data.points.gallantry.alex[1] = true;interface.data.points.gallantry.baylds[1] = true;interface.data.points.gallantry.beitetsu[1] = true;interface.data.points.gallantry.scorias[1] = true;
            interface.data.points.gallantry.drosses[1] = false;interface.data.points.gallantry.cinders[1] = false;interface.data.points.gallantry.hmp[1] = false;interface.data.points.gallantry.boulders[1] = false;
        end
    end
    imgui.NewLine();imgui.NewLine();
    if (interface.data.points.gallantry.month[1] == 1) then
        imgui.BeginTable('Relics', 6, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Relics');imgui.TableNextRow();imgui.TableNextColumn();
            imgui.Checkbox('1 Byne(75)', interface.data.points.gallantry.bynes1);imgui.TableNextColumn();
                if (interface.data.points.gallantry.bynes1[1]) then
                    imgui.Text('    0');imgui.TableNextColumn();
                else
                    imgui.Text(tostring(interface.manager.comma_value(interface.data.points.gallantry.bynes1[2])));imgui.TableNextColumn();
                end
            imgui.Checkbox('O.Bronze(75)', interface.data.points.gallantry.bronze1);imgui.TableNextColumn();
                if (interface.data.points.gallantry.bronze1[1]) then
                    imgui.Text('    0');imgui.TableNextColumn();
                else
                    imgui.Text(tostring(interface.manager.comma_value(interface.data.points.gallantry.bronze1[2])));imgui.TableNextColumn();
                end
            imgui.Checkbox('T.Shells(75)', interface.data.points.gallantry.shells1);imgui.TableNextColumn();
                if (interface.data.points.gallantry.shells1[1]) then
                    imgui.Text('    0');imgui.TableNextColumn();
                else
                    imgui.Text(tostring(interface.manager.comma_value(interface.data.points.gallantry.shells1[2])));imgui.TableNextColumn();
                end
            imgui.Checkbox('100Byne(1)', interface.data.points.gallantry.bynes2);imgui.TableNextColumn();
                if (interface.data.points.gallantry.bynes2[1]) then
                    imgui.Text('    0');imgui.TableNextColumn();
                else
                    imgui.Text(tostring(interface.manager.comma_value(interface.data.points.gallantry.bynes2[2])));imgui.TableNextColumn();
                end
            imgui.Checkbox('M.Bronze(1)', interface.data.points.gallantry.bronze2);imgui.TableNextColumn();
                if (interface.data.points.gallantry.bronze2[1]) then
                    imgui.Text('    0');imgui.TableNextColumn();
                else
                    imgui.Text(tostring(interface.manager.comma_value(interface.data.points.gallantry.bronze2[2])));imgui.TableNextColumn();
                end
            imgui.Checkbox('L.Shell(1)', interface.data.points.gallantry.shells2);imgui.TableNextColumn();
                if (interface.data.points.gallantry.shells2[1]) then
                    imgui.Text('    0');imgui.TableNextColumn();
                else
                    imgui.Text(tostring(interface.manager.comma_value(interface.data.points.gallantry.shells2[2])));imgui.TableNextColumn();
                end
            imgui.Checkbox('Plutons(250)', interface.data.points.gallantry.plutons);imgui.TableNextColumn();
                if (interface.data.points.gallantry.plutons[1]) then
                    imgui.Text('    0');imgui.TableNextColumn();
                else
                    imgui.Text(tostring(interface.manager.comma_value(interface.data.points.gallantry.plutons[2])));imgui.TableNextColumn();
                end
            imgui.Checkbox('Marrow(1)', interface.data.points.gallantry.marrows);imgui.TableNextColumn();
                if (interface.data.points.gallantry.marrows[1]) then
                    imgui.Text('    0');
                else
                    imgui.Text(tostring(interface.manager.comma_value(interface.data.points.gallantry.marrows[2])));
                end
        imgui.EndTable();
    elseif (interface.data.points.gallantry.month[1] == 2) then
        imgui.BeginTable('Mythics', 8, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Mythics');imgui.TableNextRow();imgui.TableNextColumn();
            imgui.Checkbox('Alex(875)', interface.data.points.gallantry.alex);imgui.TableNextColumn();
                if (interface.data.points.gallantry.alex[1]) then
                    imgui.Text('    0');imgui.TableNextColumn();
                else
                    imgui.Text(tostring(interface.manager.comma_value(interface.data.points.gallantry.alex[2])));imgui.TableNextColumn();
                end
            imgui.Checkbox('HP Bayld(375)', interface.data.points.gallantry.baylds);imgui.TableNextColumn();
                if (interface.data.points.gallantry.baylds[1]) then
                    imgui.Text('    0');imgui.TableNextColumn();
                else
                    imgui.Text(tostring(interface.manager.comma_value(interface.data.points.gallantry.baylds[2])));imgui.TableNextColumn();
                end
            imgui.Checkbox('Beitetsu(250)', interface.data.points.gallantry.beitetsu);imgui.TableNextColumn();
                if (interface.data.points.gallantry.beitetsu[1]) then
                    imgui.Text('    0');imgui.TableNextColumn();
                else
                    imgui.Text(tostring(interface.manager.comma_value(interface.data.points.gallantry.beitetsu[2])));imgui.TableNextColumn();
                end
            imgui.Checkbox('Scorias(1)', interface.data.points.gallantry.scorias);imgui.TableNextColumn();
                if (interface.data.points.gallantry.scorias[1]) then
                    imgui.Text('    0');
                else
                    imgui.Text(tostring(interface.manager.comma_value(interface.data.points.gallantry.scorias[2])));
                end
        imgui.EndTable();
    elseif (interface.data.points.gallantry.month[1] == 3) then
        imgui.BeginTable('Empys', 8, ImGuiTableFlags_Borders);
        imgui.TableNextRow(ImGuiTableRowFlags_Headers);imgui.TableNextColumn();imgui.TextColored(interface.colors.header, 'Empyreans');imgui.TableNextRow();imgui.TableNextColumn();
            imgui.Checkbox('R.Dross(2)', interface.data.points.gallantry.drosses);imgui.TableNextColumn();
                if (interface.data.points.gallantry.drosses[1]) then
                    imgui.Text('    0');imgui.TableNextColumn();
                else
                    imgui.Text(tostring(interface.manager.comma_value(interface.data.points.gallantry.drosses[2])));imgui.TableNextColumn();
                end
            imgui.Checkbox('Cinders(2)', interface.data.points.gallantry.cinders);imgui.TableNextColumn();
                if (interface.data.points.gallantry.cinders[1]) then
                    imgui.Text('    0');imgui.TableNextColumn();
                else
                    imgui.Text(tostring(interface.manager.comma_value(interface.data.points.gallantry.cinders[2])));imgui.TableNextColumn();
                end
            imgui.Checkbox('Boulders(250)', interface.data.points.gallantry.boulders);imgui.TableNextColumn();
                if (interface.data.points.gallantry.boulders[1]) then
                    imgui.Text('    0');imgui.TableNextColumn();
                else
                    imgui.Text(tostring(interface.manager.comma_value(interface.data.points.gallantry.boulders[2])));imgui.TableNextColumn();
                end
            imgui.Checkbox('HMP(50)', interface.data.points.gallantry.hmp);imgui.TableNextColumn();
                if (interface.data.points.gallantry.hmp[1]) then
                    imgui.Text('    0');
                else
                    imgui.Text(tostring(interface.manager.comma_value(interface.data.points.gallantry.hmp[2])));
                end
        imgui.EndTable();
    end
    
end

function manager.ResetAMBU()
    interface.manager.UpdateAmbuWeps();
    local function delay()
    interface.data.points = interface.data.points:merge(interface.defaults.points, true);
    end;
    delay:once(3);--add delay to give time for weapons to update to correctly display/not display needed weapon upgrade items
end

function manager.HandleOboro(e)
    local words = e.message:args();
    if (not e.injected) and (string.match(e.message, 'You\'ve given me ')) then
        if (words[12] == 'Another') then 
            local chars = words[20]:split("")--Need to account for multi names here, Death Penalty for example
            local weaponArr = {}
            local weapon = ''
            for x=1, #chars do
                if string.match(chars[x], "%a") then--or string.match(chars[x], "%s") then
                    weaponArr[#weaponArr +1] = chars[x]
                end
            end
            
            for y = 1, #weaponArr do
                weapon = weapon .. weaponArr[y]
            end
            -- print(chat.header(addon.name) .. chat.message(words[9]));

            local found = false
            
            for w = 1, #interface.defaults.ergons do
                if interface.defaults.ergons[w] == weapon then
                    interface.data.current['Ergon'][1] = weapon
                    interface.data.current['Beitetsu'][2] = tonumber(words[13])--rocks remaining [2] for ergon
                    found = true
                end
            end

            if found == false then
                for w = 1, #interface.defaults.relics do
                    if interface.defaults.relics[w] == weapon then
                        interface.data.current['Relic'][1] = weapon
                        interface.data.current['Pluton'][1] = tonumber(words[13])--rocks remaining
                        found = true
                    end
                end
            end
            if found == false then
                for w = 1, #interface.defaults.mythics do
                    if interface.defaults.mythics[w] == weapon then
                        interface.data.current['Mythic'][2] = weapon -- [2] for oboro mythic, [1] is paparoon mythic
                        interface.data.current['Beitetsu'][1] = tonumber(words[13])--rocks remaining
                        found = true
                    end
                end
            end
            if found == false then
                for w = 1, #interface.defaults.empyreans do
                    if interface.defaults.empyreans[w] == weapon then
                        interface.data.current['Empyrean'][1] = weapon
                        interface.data.current['Riftborn Boulder'][1] = tonumber(words[13]) --Need to add offset for empy rocks remaining
                        found = true
                    end
                end
            end
        end
    end
    
end

function manager.HandlePaparoon(e)
    local words = e.message:args();
    if (not e.injected) and (string.match(e.message, 'Yooo find Paparoon ')) then
        if (words[7] == 'more') then
            interface.data.current['Alexandrite'][1] = tonumber(words[6])
        end
    end
end

function manager.PacketInCurrency(e)
    interface.data.current['Tokens'][1] = struct.unpack("I", e.data, 0x94)/256;
    interface.data.current['Ichor'][1] = struct.unpack("I", e.data, 0xA0)/256;
end

function manager.PacketInCurrency2(e)
    interface.data.current['Plasm'][1] = struct.unpack("I", e.data, 0x14)/256;
    interface.data.current['Gallimaufry'][1] = struct.unpack("I", e.data, 0x90)/256;
end

function manager.comma_value(n) --credit--http://richard.warburton.it
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function manager.Test()
    -- AshitaCore:GetChatManager():QueueCommand(-1, '/db reset');
    local myIndex = AshitaCore:GetMemoryManager():GetParty():GetMemberTargetIndex(0);
	local my = GetEntity(myIndex);
    -- print(tostring(my.Race))
end

return manager;