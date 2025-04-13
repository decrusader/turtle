-- startup.lua
term.clear()
print("programmas om uit te kiezen:")
print("-----------------------------------------------------")
print("mine")

while true do
    if fs.exists("main.lua") then
        local ok, err = pcall(function()
            shell.run("main.lua")
        end)

        if not ok then
            print("Fout bij uitvoeren van main.lua: " .. tostring(err))
        end
    else
        print("Wacht op 'main.lua' om ontvangen te worden...")
    end

    os.sleep(2) -- kleine pauze voor herstart of wachten op verzending
end
