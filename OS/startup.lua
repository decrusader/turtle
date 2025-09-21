-- startup.lua
-- CoreLogic OS met automatische updates + resume-functie

-- Download functie
local function downloadFile(url, filename)
    term.clear()
    term.setCursorPos(1,1)
    print("Downloading: " .. filename)

    local response = http.get(url)
    if response then
        local content = response.readAll()
        response.close()

        local f = fs.open(filename, "w")
        f.write(content)
        f.close()
    else
        print("Fout: kon " .. filename .. " niet downloaden!")
        sleep(2)
    end
end

-- Altijd opnieuw te downloaden bestanden
local files = {
    { url = "https://raw.githubusercontent.com/<username>/<repo>/main/animation.lua", name = "animation.lua" },
    { url = "https://raw.githubusercontent.com/<username>/<repo>/main/PP.lua",        name = "PP.lua" },
    { url = "https://raw.githubusercontent.com/<username>/<repo>/main/resume.lua",    name = "resume.lua" }
}

-- Download alle bestanden
for _, file in ipairs(files) do
    downloadFile(file.url, file.name)
end

-- Resume check
if fs.exists("session.dat") then
    local f = fs.open("session.dat", "r")
    local program = f.readLine()
    f.close()

    if program and fs.exists(program) then
        shell.run(program)
        return
    end
end

-- Start normale animatie
local animation = dofile("animation.lua")
animation.play()

term.clear()
term.setCursorPos(1,1)
print("CoreLogic OS klaar voor gebruik!")
print("Typ een programma om te starten, bv:")
print(" resume PP.lua")
