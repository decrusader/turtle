local chatBox = peripheral.find("chatBox")
local monitor = peripheral.find("monitor")
 
-- Instellingen
monitor.setTextScale(1)
monitor.clear()
monitor.setCursorPos(1,1)
 
local running = true
local x = ""
 
-- Functie om knoppen te tekenen
local function drawButtons()
    monitor.clear()
 
    -- Knop: Wijzig Bericht
    monitor.setCursorPos(2, 2)
    monitor.setBackgroundColor(colors.green)
    monitor.setTextColor(colors.black)
    monitor.write(" Wijzig Bericht ")
 
    -- Knop: Stop
    monitor.setCursorPos(2, 4)
    monitor.setBackgroundColor(colors.red)
    monitor.setTextColor(colors.white)
    monitor.write("   Stop        ")
 
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.white)
end
 
-- Functie om op knoppen te klikken
local function getClick()
    while true do
        local event, side, xPos, yPos = os.pullEvent("monitor_touch")
 
        if yPos == 2 then
            return "change"
        elseif yPos == 4 then
            return "stop"
        end
    end
end
 
-- Hoofdlus
drawButtons()
print("Typ een bericht om te verzenden:")
x = read()
 
parallel.waitForAny(
    function() -- UI-handling
        while running do
            local action = getClick()
            if action == "change" then
                print("Nieuw bericht:")
                x = read()
            elseif action == "stop" then
                running = false
                print("Gestopt via knop.")
            end
        end
    end,
    function() -- Bericht sturen
        while running do
            if x ~= "" then
                chatBox.sendMessage(x, "#add")
            end
            sleep(300)
        end
    end
)
