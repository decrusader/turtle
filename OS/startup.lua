-- startup.lua
-- CoreLogic OS met automatische updates + auto-resume state

-- Download functie
local function downloadFile(url, filename)
    term.clear()
    term.setCursorPos(1,1)
    print("Downloading: " .. filename)

    local response = http.get(url)
    if response then
        local content = response.readAll()
        response.close()

        if content and #content > 0 then
            local f = fs.open(filename, "w")
            f.write(content)
            f.close()
            print(filename .. " gedownload (" .. #content .. " bytes)")
        else
            print("Waarschuwing: " .. filename .. " is leeg!")
            sleep(2)
        end
    else
        print("Fout: kon " .. filename .. " niet downloaden!")
        sleep(2)
    end
end

-- Altijd opnieuw te downloaden bestanden
local files = {
    { url = "https://raw.githubusercontent.com/decrusader/turtle/refs/heads/main/OS/animation.lua", name = "animation.lua" },
    { url = "https://raw.githubusercontent.com/decrusader/turtle/refs/heads/main/OS/PP.lua",        name = "PP.lua" },
    { url = "https://raw.githubusercontent.com/decrusader/turtle/refs/heads/main/OS/mine.lua",      name = "mine.lua" },
    { url = "https://raw.githubusercontent.com/decrusader/turtle/refs/heads/main/OS/music.lua",     name = "music.lua" },
    { url = "https://raw.githubusercontent.com/decrusader/turtle/refs/heads/main/OS/chat.lua",      name = "chat.lua" },
    { url = "https://raw.githubusercontent.com/decrusader/turtle/refs/heads/main/OS/cobblestone_farm.lua", name = "cobblestone_farm.lua" }
}

-- Download alle bestanden
for _, file in ipairs(files) do
    downloadFile(file.url, file.name)
    sleep(0.5)
end

-- Resume check
if fs.exists("session.dat") then
    local f = fs.open("session.dat", "r")
    local program = f.readLine()
    f.close()

    if program and fs.exists(program) then
        print("Hervatten van sessie: " .. program)
        sleep(1)

        -- Speciaal geval: PP.lua
        if program == "PP.lua" then
            shell.run("PP.lua")
            return
        else
            shell.run(program)
            return
        end
    else
        print("Session bestand verwijst naar " .. tostring(program) .. " maar dat bestaat niet.")
        fs.delete("session.dat")
        sleep(2)
    end
end

-- Start normale animatie
if fs.exists("animation.lua") then
    local animation = dofile("animation.lua")
    animation.play()
end

term.clear()
term.setCursorPos(1,1)
print("CoreLogic OS klaar voor gebruik!")
print("Typ een programma om te starten, bv:")
print(" PP.lua")
print(" mine.lua")
print(" music.lua")
