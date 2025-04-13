-- startup.lua

while true do
    local ok, err = pcall(function()
        shell.run("main.lua")
    end)
    
    if not ok then
        print("Fout bij uitvoeren: " .. tostring(err))
    end

    os.sleep(0.1) -- kleine pauze voor herstart
end
