-- PP.lua
-- Presentatie Player (blijft loopen tot key of muis)

local slides = {}

-- Functie om input te vragen (met zichtbare prompt en cursor)
local function ask(question)
    term.write(question .. " ")
    return read()
end

-- Tekst + duur invoeren
while true do
    term.clear()
    term.setCursorPos(1,1)
    print("=== Presentatie Builder ===")
    print("Typ de tekst voor de dia, of 'klaar' om te stoppen.")
    term.write("Tekst: ")
    local text = read()

    if text == "klaar" then break end
    if text == "" then
        print("Lege tekst is niet toegestaan!")
        sleep(1)
    else
        term.write("Duur (seconden): ")
        local duration = tonumber(read())

        if not duration or duration <= 0 then
            print("Ongeldige tijd, probeer opnieuw.")
            sleep(1)
        else
            table.insert(slides, {text=text, time=duration})
            print("Dia toegevoegd! ("..text.." - "..duration.."s)")
            sleep(1)
        end
    end
end

-- Presentatie starten
if #slides == 0 then
    term.clear()
    term.setCursorPos(1,1)
    print("Geen dia's toegevoegd, afsluiten...")
    return
end

term.clear()
term.setCursorPos(1,1)
print("Presentatie start over 2 seconden...")
sleep(2)

-- Functie om presentatie 1x af te spelen
local function playSlides()
    for i, slide in ipairs(slides) do
        term.clear()
        local w, h = term.getSize()
        local x = math.floor((w - #slide.text) / 2)
        local y = math.floor(h / 2)

        term.setCursorPos(x, y)
        print(slide.text)

        sleep(slide.time)
    end
end

-- Blijf de presentatie loopen tot een toets of muis-click
parallel.waitForAny(
    function()
        while true do
            playSlides()
        end
    end,
    function()
        os.pullEvent("key") -- stop bij toets
    end,
    function()
        os.pullEvent("mouse_click") -- stop bij klik
    end
)

-- Stop
term.clear()
term.setCursorPos(1,1)
print("Presentatie gestopt.")
