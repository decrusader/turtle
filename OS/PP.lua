-- PP.lua
-- Simpel presentatieprogramma (Presentatie Player)

local slides = {}

-- Functie om input te vragen
local function ask(question)
    io.write(question .. " ")
    return read()
end

-- Tekst + duur invoeren
while true do
    local text = ask("Voer de tekst in (of typ 'klaar' om te stoppen):")
    if text == "klaar" then break end

    local duration = tonumber(ask("Hoelang moet deze tekst zichtbaar zijn (in seconden)?"))
    if not duration or duration <= 0 then
        print("Ongeldige tijd, probeer opnieuw.")
    else
        table.insert(slides, {text=text, time=duration})
    end
end

-- Presentatie starten
if #slides == 0 then
    print("Geen dia's toegevoegd, afsluiten...")
    return
end

term.clear()
term.setCursorPos(1,1)
print("Presentatie start over 2 seconden...")
sleep(2)

for i, slide in ipairs(slides) do
    term.clear()
    local w, h = term.getSize()
    local x = math.floor((w - #slide.text) / 2)
    local y = math.floor(h / 2)

    term.setCursorPos(x, y)
    print(slide.text)

    sleep(slide.time)
end

term.clear()
term.setCursorPos(1,1)
print("Presentatie afgelopen!")
