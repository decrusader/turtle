--Hier kan je iemand zijn player naam noteren(x) en krijg je iedere 10 seconden zijn precieze locatie in cords van die player op dit scherm.
--Detecteerd de player dector die nodig is voor het programma, plaats dit tegen de gewenste computer.
local detector = peripheral.find("playerDetector")

--Gewone input.
print("who do you want do track?")
local x = read()

--loop variable.
i = 1

--de loop
repeat
 
local pos = detector.getPlayerPos(x)
print("Position of " ..x .." " .. pos.x .. "," .. pos.y .. "," .. pos.z)
sleep(10)
 
until i == 0
