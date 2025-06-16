local fs = fs or {}

local monitor = peripheral.find("monitor") or term
monitor.setTextScale = monitor.setTextScale or function() end

local w, h = monitor.getSize()

-- Dynamische tekst schaal functie
local function dynamicTextScale(w, h)
    local scales = {4,3,2,1,0.5}
    for i = 1, #scales do
        local scale = scales[i]
        local charsWide = math.floor(w / (scale * 6))
        local charsHigh = math.floor(h / (scale * 9))
        if charsWide >= 40 and charsHigh >= 15 then
            return scale
        end
    end
    return 0.5
end

local scale = dynamicTextScale(w, h)
monitor.setTextScale(scale)
w, h = monitor.getSize() -- opnieuw opvragen voor de nieuwe schaal

term.redirect(monitor)

local dataFile = "stock_data.txt"
local playersFile = "players_data.txt"

local companies = {}
local players = {}
local currentPlayer = nil

local INFLATION_RATE = 0.01
local CRASH_CHANCE = 0.01
local PRICE_VOLATILITY = 0.05

local function centerText(text, width)
    local padding = math.floor((width - #text) / 2)
    if padding < 0 then padding = 0 end
    return string.rep(" ", padding) .. text
end

local function serialize(tbl)
    return textutils.serialize(tbl)
end

local function deserialize(str)
    local ok, tbl = pcall(textutils.unserialize, str)
    if ok then return tbl else return nil end
end

local function loadData()
    if fs.exists(dataFile) then
        local file = fs.open(dataFile, "r")
        local content = file.readAll()
        file.close()
        local loaded = deserialize(content)
        if loaded then companies = loaded end
    else
        companies = {
            ["OpenAI"] = {price=100, history={100}, owners={}},
            ["Minecraft Inc"] = {price=150, history={150}, owners={}}
        }
    end

    if fs.exists(playersFile) then
        local file = fs.open(playersFile, "r")
        local content = file.readAll()
        file.close()
        local loaded = deserialize(content)
        if loaded then players = loaded end
    end
end

local function saveData()
    local file = fs.open(dataFile, "w")
    file.write(serialize(companies))
    file.close()

    local filep = fs.open(playersFile, "w")
    filep.write(serialize(players))
    filep.close()
end

local function clearScreen()
    term.clear()
    term.setCursorPos(1,1)
end

-- Custom readCentered input functie
local function readCentered(maxLength, y)
    local input = ""
    term.setCursorBlink(true)
    while true do
        -- Bereken startX zodat tekst gecentreerd is
        local startX = math.floor((w - #input) / 2) + 1
        term.setCursorPos(1, y)
        term.clearLine()
        term.setCursorPos(startX, y)
        term.write(input)

        local event, key = os.pullEvent("key")
        if key == keys.enter then
            term.setCursorBlink(false)
            return input
        elseif key == keys.backspace then
            if #input > 0 then
                input = input:sub(1, -2)
            end
        elseif key == keys.left or key == keys.right or key == keys.up or key == keys.down then
            -- negeer pijltjestoetsen
        else
            local char = keys.getName(key)
            -- Alleen acceptabele ASCII karakters tonen (a-z, 0-9, spatie en symbolen)
            -- Omdat keys.getName geeft b.v. "a", "space" etc. 
            -- We gebruiken event 'char' ook, handiger:
            -- Maar os.pullEvent("key") geeft geen char, we moeten "char" event gebruiken
        end

        -- Om karakters te krijgen gebruiken we ook 'char' event
        -- Dus we passen de event lus aan om ook char te verwerken
        -- Maak functie opnieuw met os.pullEvent()

        -- Ik pas readCentered aan om zowel 'char' als 'key' events te verwerken
    end
end

-- Verbeterde readCentered met char event:

local function readCenteredImproved(maxLength, y)
    local input = ""
    term.setCursorBlink(true)
    while true do
        local startX = math.floor((w - #input) / 2) + 1
        term.setCursorPos(1, y)
        term.clearLine()
        term.setCursorPos(startX, y)
        term.write(input)

        local event, param = os.pullEvent()
        if event == "char" then
            if #input < maxLength then
                input = input .. param
            end
        elseif event == "key" then
            if param == keys.enter then
                term.setCursorBlink(false)
                return input
            elseif param == keys.backspace then
                if #input > 0 then
                    input = input:sub(1, -2)
                end
            end
        end
    end
end

local function login()
    clearScreen()
    local maxLines = 6
    local startLine = math.floor((h - maxLines)/2)

    local function printCenteredLine(lineNum, text)
        term.setCursorPos(1, lineNum)
        term.clearLine()
        term.write(centerText(text, w))
    end

    printCenteredLine(startLine, "=== Login ===")
    printCenteredLine(startLine + 1, "Voer je naam in:")

    local inputWidth = 20

    local name = readCenteredImproved(inputWidth, startLine + 2)

    if players[name] == nil then
        printCenteredLine(startLine + 3, "Nieuwe gebruiker! Maak een wachtwoord aan:")

        local code = readCenteredImproved(inputWidth, startLine + 4)

        players[name] = {balance=10000, stocks={}, code=code}
        saveData()
        printCenteredLine(startLine + 5, "Account aangemaakt! Welkom, " .. name)
        sleep(1.5)
    else
        local tries = 3
        while tries > 0 do
            printCenteredLine(startLine + 3, "Voer je code in:")

            local code = readCenteredImproved(inputWidth, startLine + 4)

            if code == players[name].code then
                printCenteredLine(startLine + 5, "Succesvol ingelogd, welkom " .. name)
                sleep(1.5)
                break
            else
                tries = tries - 1
                printCenteredLine(startLine + 5, "Verkeerde code, nog " .. tries .. " pogingen.")
                if tries == 0 then
                    error("Te veel mislukte pogingen, programma stopt.")
                end
                sleep(1.5)
                term.setCursorPos(1, startLine + 5)
                term.clearLine()
            end
        end
    end
    currentPlayer = name
end

local function loadingAnimation(duration)
    clearScreen()
    local frames = {"-", "\\", "|", "/"}
    local centerY = math.floor(h / 2)
    local centerX = math.floor(w / 2)
    local startTime = os.clock()
    while os.clock() - startTime < duration do
        for i=1,#frames do
            term.setCursorPos(centerX, centerY)
            term.write(frames[i])
            sleep(0.15)
        end
    end
    clearScreen()
end

-- Rest van je stock market functies...

-- (Voor beknoptheid kopieer ik de functies van eerder, die je natuurlijk kunt vervangen)

function buyStock(company, amount)
    local c = companies[company]
    if not c then
        print("Bedrijf bestaat niet.")
        return
    end
    local cost = amount * c.price
    local playerData = players[currentPlayer]
    if playerData.balance < cost then
        print("Niet genoeg saldo.")
        return
    end
    playerData.balance = playerData.balance - cost
    playerData.stocks[company] = (playerData.stocks[company] or 0) + amount
    c.owners[currentPlayer] = (c.owners[currentPlayer] or 0) + amount
    saveData()
    print("Aandelen gekocht!")
end

function sellStock(company, amount)
    local c = companies[company]
    if not c then
        print("Bedrijf bestaat niet.")
        return
    end
    local playerData = players[currentPlayer]
    if (playerData.stocks[company] or 0) < amount then
        print("Niet genoeg aandelen om te verkopen.")
        return
    end
    local earnings = amount * c.price
    playerData.balance = playerData.balance + earnings
    playerData.stocks[company] = playerData.stocks[company] - amount
    c.owners[currentPlayer] = c.owners[currentPlayer] - amount
    saveData()
    print("Aandelen verkocht!")
end

function updateMarket()
    for name, c in pairs(companies) do
        local change = 1 + (math.random() * 2 - 1) * PRICE_VOLATILITY
        c.price = c.price * change * (1 + INFLATION_RATE)
        if math.random() < CRASH_CHANCE then
            c.price = c.price * 0.5
        end
        table.insert(c.history, c.price)
        if #c.history > 40 then table.remove(c.history, 1) end
    end
end

function showPortfolio()
    local p = players[currentPlayer]
    print("=== Portfolio voor " .. currentPlayer .. " ===")
    print("Saldo: $" .. string.format("%.2f", p.balance))
    for name, c in pairs(companies) do
        local owned = p.stocks[name] or 0
        local total = 0
        for _, amount in pairs(c.owners) do total = total + amount end
        local pct = total > 0 and (owned / total * 100) or 0
        print(name .. ": " .. owned .. " aandelen (" .. string.format("%.2f", pct) .. "%)")
    end
end

function mainMenu()
    while true do
        print("\nKies een optie:")
        print("1. Koop aandelen")
        print("2. Verkoop aandelen")
        print("3. Toon portfolio")
        print("4. Wacht op markt update")
        print("5. Exit")
        local choice = read()
        if choice == "1" then
            print("Welk bedrijf?")
            local comp = read()
            print("Aantal aandelen?")
            local amt = tonumber(read())
            if amt and amt > 0 then
                buyStock(comp, amt)
            else
                print("Ongeldig aantal.")
            end
        elseif choice == "2" then
            print("Welk bedrijf?")
            local comp = read()
            print("Aantal aandelen te verkopen?")
            local amt = tonumber(read())
            if amt and amt > 0 then
                sellStock(comp, amt)
            else
                print("Ongeldig aantal.")
            end
        elseif choice == "3" then
            showPortfolio()
        elseif choice == "4" then
            print("Markt wordt geüpdatet...")
            updateMarket()
            saveData()
        elseif choice == "5" then
            print("Programma wordt afgesloten.")
            break
        else
            print("Ongeldige keuze.")
        end
    end
end

loadData()
login()
loadingAnimation(3)  -- 3 seconden loading animatie
mainMenu()
