-- Stock Market Program for CC:Tweaked with Redstone Spurs System
-- Advanced Computer + Monitor support, full adaptive UI
-- Save as: startup.lua

-- USER DATA AND SETTINGS
local users = {}
local settings = {
    companyName = "SpurCorp",
    stockValue = 10,
    stockHistory = {10, 10.2, 10.4, 10.6, 10.8, 11.0},
    stocksAvailable = 1000,
    stockSoldPercentage = 0,
    stocksNeededForBuyout = 500,
    redstoneSides = {
        spur1 = "left",
        spur10 = "right",
        spur100 = "back"
    }
}

-- TERMINAL AND MONITOR SETUP
local termNative = term
local monitor = peripheral.find("monitor")
if monitor then monitor.setTextScale(0.5) end

local function sync(fn)
    fn(termNative)
    if monitor then fn(monitor) end
end

local function setCursorPos(x, y)
    sync(function(d) d.setCursorPos(x, y) end)
end

local function writeText(text)
    sync(function(d) d.write(text) end)
end

local function setTextColor(color)
    sync(function(d) d.setTextColor(color) end)
end

local function setBackgroundColor(color)
    sync(function(d) d.setBackgroundColor(color) end)
end

local function clearScreen()
    setBackgroundColor(colors.black)
    sync(function(d) d.clear() end)
    setCursorPos(1, 1)
end

local function draw(text, x, y, color)
    if color then setTextColor(color) end
    setCursorPos(x, y)
    writeText(text)
end

local function centerPrint(y, text, color)
    local w = termNative.getSize()
    local x = math.floor((w - #text) / 2)
    draw(text, x, y, color)
end

local function readInput(prompt, hide)
    setTextColor(colors.white)
    writeText(prompt)
    return hide and read("*") or read()
end

local function loadingScreen()
    clearScreen()
    centerPrint(5, "Loading", colors.yellow)
    for i = 1, 3 do
        sleep(0.3)
        writeText(".")
    end
    sleep(0.5)
end

local function drawGraph(xStart, yStart, width, height)
    local maxVal = 0
    for _, v in ipairs(settings.stockHistory) do
        if v > maxVal then maxVal = v end
    end
    for i = 1, math.min(width, #settings.stockHistory) do
        local val = settings.stockHistory[#settings.stockHistory - width + i] or 0
        local heightPercent = val / maxVal
        local barHeight = math.floor(heightPercent * height)
        for j = 0, barHeight - 1 do
            setCursorPos(xStart + i - 1, yStart + height - j)
            setTextColor(colors.green)
            writeText("|")
        end
    end
end

local function updateSpursFromRedstone()
    for _, user in pairs(users) do
        if redstone.getInput("left") == true then user.spurs = (user.spurs or 0) + 1 end
        if redstone.getInput("right") == true then user.spurs = (user.spurs or 0) + 10 end
        if redstone.getInput("back") == true then user.spurs = (user.spurs or 0) + 100 end
    end
end

local function stockMenu(user)
    while true do
        updateSpursFromRedstone()
        clearScreen()
        local w, h = termNative.getSize()
        drawGraph(2, 2, math.min(w - 4, #settings.stockHistory), 10)

        setTextColor(colors.cyan)
        draw("Bedrijf: " .. settings.companyName, 2, 13)
        draw("Waarde per aandeel: " .. settings.stockValue .. " Spurs", 2, 14)
        draw("Je Spurs: " .. (user.spurs or 0), 2, 15)
        draw("Je Aandelen: " .. (user.stocks or 0), 2, 16)

        setTextColor(colors.white)
        draw("[1] Koop  [2] Verkoop  [3] Terug", 2, 18)
        local choice = read()

        if choice == "1" or choice == "2" then
            draw("Aantal? (1/10/100/c): ", 2, 20)
            local amountInput = read()
            local amount = (amountInput == "c") and tonumber(readInput("Custom aantal: ")) or tonumber(amountInput)

            if amount and amount > 0 then
                if choice == "1" then
                    local cost = amount * settings.stockValue
                    if user.spurs >= cost and settings.stocksAvailable >= amount then
                        user.spurs = user.spurs - cost
                        user.stocks = (user.stocks or 0) + amount
                        settings.stocksAvailable = settings.stocksAvailable - amount
                        table.insert(settings.stockHistory, settings.stockValue + math.random(-5, 5) / 10)
                    else
                        draw("Niet genoeg spurs of aandelen.", 2, 23, colors.red)
                    end
                else
                    if user.stocks >= amount then
                        user.stocks = user.stocks - amount
                        user.spurs = user.spurs + amount * settings.stockValue
                        settings.stocksAvailable = settings.stocksAvailable + amount
                        table.insert(settings.stockHistory, settings.stockValue + math.random(-5, 5) / 10)
                    else
                        draw("Niet genoeg aandelen.", 2, 23, colors.red)
                    end
                end
                sleep(1.5)
            end
        elseif choice == "3" then
            break
        end
    end
end

local function login()
    clearScreen()
    centerPrint(3, "LOGIN", colors.yellow)
    local username = readInput("Gebruikersnaam: ")
    local code = readInput("Pincode: ", true)

    if not users[username] then
        users[username] = { code = code, spurs = 0, stocks = 0 }
    elseif users[username].code ~= code then
        centerPrint(7, "Foute pincode!", colors.red)
        sleep(2)
        return
    end

    loadingScreen()
    stockMenu(users[username])
end

local function configureRedstoneSides()
    draw("Kies kant voor 1 Spur: ", 2, 9)
    settings.redstoneSides.spur1 = read()
    draw("Kies kant voor 10 Spurs: ", 2, 10)
    settings.redstoneSides.spur10 = read()
    draw("Kies kant voor 100 Spurs: ", 2, 11)
    settings.redstoneSides.spur100 = read()
end

local function settingsMenu()
    clearScreen()
    centerPrint(2, "Instellingen", colors.orange)
    draw("[1] Verander naam", 2, 4)
    draw("[2] Stock split", 2, 5)
    draw("[3] Verkocht % instellen", 2, 6)
    draw("[4] Aandelen voor overname", 2, 7)
    draw("[5] Redstone inputs", 2, 8)
    draw("[6] Terug", 2, 9)

    local c = read()
    if c == "1" then
        draw("Nieuwe naam: ", 2, 11)
        settings.companyName = read()
    elseif c == "2" then
        settings.stocksAvailable = settings.stocksAvailable * 2
        settings.stockValue = math.max(1, settings.stockValue / 2)
    elseif c == "3" then
        draw("Nieuw percentage: ", 2, 11)
        settings.stockSoldPercentage = tonumber(read()) or 0
    elseif c == "4" then
        draw("Nieuw aandelen doel: ", 2, 11)
        settings.stocksNeededForBuyout = tonumber(read()) or 500
    elseif c == "5" then
        configureRedstoneSides()
    end
end

-- MAIN LOOP
while true do
    updateSpursFromRedstone()
    clearScreen()
    centerPrint(3, "Stock Market", colors.green)
    draw("[1] Instellingen", 4, 5)
    draw("[2] Login", 4, 6)
    draw("[3] Exit", 4, 7)

    local c = read()
    if c == "1" then settingsMenu()
    elseif c == "2" then login()
    elseif c == "3" then break end
end
