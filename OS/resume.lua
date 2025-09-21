-- resume.lua
-- Start een programma en onthoud het in session.dat

local args = {...}
if #args == 0 then
    print("Gebruik: resume <programma>")
    return
end

local program = args[1]

if not fs.exists(program) then
    print("Programma niet gevonden: " .. program)
    return
end

-- Sla huidige sessie op
local f = fs.open("session.dat", "w")
f.writeLine(program)
f.close()

-- Run programma
shell.run(program)

-- Als programma klaar is -> sessie wissen
if fs.exists("session.dat") then
    fs.delete("session.dat")
end
