-- startup.lua
-- Start CoreLogic OS en speel animatie af

local animation = dofile("animation.lua")  -- laad animation.lua
animation.play()                            -- speel animatie af

-- Hier kan je je eigen main menu of OS starten
-- bijvoorbeeld: dofile("main.lua")
