addon.name      = 'boxhelper'
addon.author    = 'GetAwayCoxn'
addon.version   = '1.0'
addon.desc      = 'Helps open brown treasure boxes'
addon.link      = 'https://github.com/GetAwayCoxn/Ashita-v4-Addons'

require('common')
local chat = require('chat')
local imgui = require('imgui')

--defaults
local listening = false
local newBox = true
local newGuess = true
local bestGuess = 0
local odds = "0"
local offset = 0
local options = T{}
local chances = 0
local settings = T{
    is_open = {true},
    size = { 360, 220 },
    debug_size = { 360, 255 },
    debug = false,
    text_color = { 1.0, 0.75, 0.25, 1.0 },
}
local debugMessage = ''

ashita.events.register('load', 'load_cb', function()
    ResetOptions('first load message')
end)

ashita.events.register('d3d_present', 'present_cb', function ()
    local player = AshitaCore:GetMemoryManager():GetPlayer()

    if player:GetIsZoning() ~= 0 then
        ResetOptions()
        return
    end

    if not settings.is_open[1] or newBox then
        return
    end

    if settings.debug then
        imgui.SetNextWindowSize(settings.debug_size)
    else
        imgui.SetNextWindowSize(settings.size)
    end

    if imgui.Begin('BoxHelper', settings.is_open, ImGuiWindowFlags_NoResize) then
        imgui.Text('chances: ')
        imgui.SameLine()
        if chances == 1 then
            imgui.Text("last chance!")
        elseif chances > 1 then
            imgui.Text(odds .. " %")
        else
            imgui.Text("waiting for new box")
        end
        if settings.debug then
            imgui.Text('newBox: ' .. tostring(newBox) .. ' ')
            imgui.SameLine()
            imgui.Text('listening: ' .. tostring(listening) .. ' ')
            imgui.SameLine()
            imgui.Text('bestGuess: ' .. tostring(bestGuess) .. ' ')            
        end

        if newGuess then
            SetBestGuess()
            if chances > 0 then
                chances = chances - 1
            end
        end

        imgui.BeginTable('jobs table', 10, ImGuiTableFlags_Borders)
        imgui.TableNextRow()
        for k, v in pairs(options) do
            imgui.TableNextColumn()
            if v then
                if k == bestGuess then
                    imgui.TextColored(settings.text_color, tostring(k))
                else
                    imgui.Text(tostring(k))
                end
            else
                imgui.Text('  ')
            end
            if (k-9) % 10 == 0 and k ~= 99 then
                imgui.TableNextRow()
            end
        end
        imgui.EndTable()
        if settings.debug then imgui.Text(debugMessage) end
    end
    imgui.End()
end)

ashita.events.register('packet_in', 'packet_in_callback1', function(e)
    -- Borrowed this logic from https://github.com/zechs6437/boxdestroyer-ashita-addon
    if e.id == 0x34 then
        local box_id = struct.unpack('H' , e.data, 41)
        if AshitaCore:GetMemoryManager():GetEntity():GetName(box_id) == 'Treasure Casket' then
            local guesses = e.data:byte(9)
            if guesses > 0 and guesses < 7 then
                chances = guesses
            else
                chances = 0
            end
        end
    end
end)

ashita.events.register('text_in', 'text_in_callback1', function (e)
    if string.match(e.message, 'You have a hunch') and listening then
        listening = false
        local words = e.message:args()
        offset = 0
        if words[5] == 'hunch' then
            offset = 1
            if settings.debug then
                print("found offset")
            end
        end
        if string.match(e.message, 'the first digit is') then
            ProcessFirst(words, offset)
        elseif string.match(e.message, 'the second digit is') then
            ProcessSecond(words,offset)
        elseif string.match(e.message, 'one of the two digits is') then
            ProcessTwoDigits(words,offset)
        elseif string.match(e.message, 'lock\'s combination is greater than') then
            ProcessGreaterThan(words[12 + offset])
        elseif string.match(e.message, 'lock\'s combination is less than') then
            ProcessLessThan(words[12 + offset])
        elseif string.match(e.message, 'greater than') and string.match(e.message, 'less than') then
            ProcessBetween(words,offset)
        elseif string.match(e.message, 'the combination is greater than') then
            ProcessGreaterThan(words[11 + offset])
        elseif string.match(e.message, 'the combination is less than') then
            ProcessLessThan(words[11 + offset])
        end
    elseif string.match(e.message, 'chest is locked') then
        listening = true
        if newBox then
            newBox = false
        end
    elseif string.match(e.message, 'succeeded in opening') then
        ResetOptions('succeeded')
    elseif string.match(e.message, 'failed to open the lock.') then
        ResetOptions('failed')
    end
end)

function ResetOptions(s)
    s = s or 'resetting options'
    chances = 0
    listening = false
    newBox = true
    newGuess = true
    options = options:clear()
    for x = 10, 99 do
        options[x] = true
    end
    if s then debugMessage='Found ' .. s .. ' message' end
end

function SetBestGuess()
    newGuess = false
    local remainingGuessesCount = 0
    local guesses = T{}
    for k, v in pairs(options) do
        if v then
            guesses:append(k)
            remainingGuessesCount = remainingGuessesCount + 1
        end
    end
    local i = math.ceil(guesses:length() / 2)
    bestGuess = guesses[i]
    local neededGuesses = 0
    while remainingGuessesCount > 1 do
        neededGuesses = neededGuesses + 1
        remainingGuessesCount = remainingGuessesCount / 2
    end
    if chances >= neededGuesses then
        odds = "100.00 %"
    else
        odds = string.format("%.2f %%", chances / neededGuesses * 100)
    end

    if settings.debug then
        print("odds: " .. tostring(odds))
        print("neededGuesses: " .. tostring(neededGuesses))
    end
end

function ProcessFirst(words,o)
    if words[10 + o]:contains('even') then
        debugMessage = 'found first even'
        for k in pairs(options) do
            local firstDigit = math.floor(k / 10)
            if firstDigit % 2 ~= 0 then
                options[k] = false
            end
        end
        newGuess = true
    elseif words[10 + o]:contains('odd') then
        debugMessage = 'found first odd'
        for k in pairs(options) do
            local firstDigit = math.floor(k / 10)
            if firstDigit % 2 == 0 then
                options[k] = false
            end
        end
        newGuess = true
    else
        debugMessage = 'found first triple message'
        local first = words[10 + o][1]
        local second = words[11 + o][1]
        local third = words[13 + o][1]

        debugMessage = first .. ' ' .. second .. ' ' .. third .. ' '

        for k in pairs(options) do
            local firstDigit = tostring(k)[1]
            if firstDigit ~= first and firstDigit ~= second and firstDigit ~= third then
                options[k] = false
            end
        end
        newGuess = true
    end
end

function ProcessSecond(words, o)
    if words[10 + o]:contains('even') then
        debugMessage = 'found second even'
        for k in pairs(options) do
            local secondDigit = k % 10
            if secondDigit % 2 ~= 0 then
                options[k] = false
            end
        end
        newGuess = true
    elseif words[10 + o]:contains('odd') then
        debugMessage = 'found second odd'
        for k in pairs(options) do
            local secondDigit = k % 10
            if secondDigit % 2 == 0 then
                options[k] = false
            end
        end
        newGuess = true
    else
        debugMessage = 'found second triple message'
        local first = words[10 + o][1]
        local second = words[11 + o][1]
        local third = words[13 + o][1]

        debugMessage = first .. ' ' .. second .. ' ' .. third .. ' '

        for k in pairs(options) do
            local secondDigit = tostring(k)[2]
            if not (secondDigit == first or secondDigit == second or secondDigit == third) then
                options[k] = false
            end
        end
        newGuess = true
    end
end

function ProcessTwoDigits(words, o)
    debugMessage = 'Two digits found: ' .. words[12 + o]

    local num = words[12+o][1]
    for k in pairs(options) do
        local firstDigit = tostring(k)[1]
        local secondDigit = tostring(k)[2]
        if firstDigit ~= num and secondDigit ~= num then
            options[k] = false
        end
    end
    newGuess = true
end

function ProcessGreaterThan(numStr)
    debugMessage = 'GreaterThan found: ' .. numStr
    local fStr = string.sub(numStr,1,2)
    local n = tonumber(fStr)
    for k in pairs(options) do
        if k <= n then
            options[k] = false
        end
    end
    newGuess = true
end

function ProcessLessThan(numStr)
    debugMessage = 'LessThan found: ' .. numStr
    local fStr = string.sub(numStr,1,2)
    local n = tonumber(fStr)
    for k in pairs(options) do
        if k >= n then
            options[k] = false
        end
    end
    newGuess = true
end

function ProcessBetween(words, o)
    debugMessage = 'found: ' .. words[11 + o] .. ' and ' .. words[15 + o] .. ' formated: ' .. string.sub(words[15 + o],1,2)

    local min = tonumber(words[11 + o])
    for k in pairs(options) do
        if k <= min then
            options[k] = false
        end
    end

    local fStr = string.sub(words[15 + o],1,2)
    local max = tonumber(fStr)
    for k in pairs(options) do
        if k >= max then
            options[k] = false
        end
    end
    newGuess = true
end

function Message(str)
    print(chat.header(addon.name):append(chat.message(str)))
end
