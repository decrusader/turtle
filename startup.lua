-- Turtle code
local function executeCommand(command)
    if command == "stop" then
        -- Verhindert de turtle van werken (onbeweeglijk maken)
        os.pullEvent("monitor_touch")  -- Verhindert dat de turtle verder werkt
    elseif command == "go" then
        -- Zet de turtle aan om weer te werken
        print("Turtle geactiveerd")
    elseif string.match(command, "run") then
        local programName = string.match(command, "run (.+)")
        if programName and fs.exists("/rom/programs/" .. programName) then
            -- Voer het programma uit
            shell.run("/rom/programs/" .. programName)
            print("Programma " .. programName .. " uitgevoerd.")
        else
            print("Programma niet gevonden.")
        end
    end
end

-- Luister naar commando's
while true do
    -- Luister naar commando's van de master computer
    os.pullEvent("monitor_touch")
end
