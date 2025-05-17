-- Debug Status Editor
local args = {...}
local statusFile = args[1] or "/programs/status.json"
local programs = {
    "Master",
    "Music",
}

local function loadStatus()
    if not fs.exists(statusFile) then return {} end
    local f = fs.open(statusFile, "r")
    local d = f.readAll()
    f.close()
    return textutils.unserializeJSON(d) or {}
end

local function saveStatus(data)
    local f = fs.open(statusFile, "w")
    f.write(textutils.serializeJSON(data))
    f.close()
end

local function menu()
    local status = loadStatus()
    while true do
        term.clear()
        term.setCursorPos(1,1)
        print("=== Status Debug ===")
        for i, name in ipairs(programs) do
            print(i .. ". " .. name .. " [" .. (status[name] or "Unknown") .. "]")
        end
        print("Q. Quit")
        write("Select #: ")
        local input = read()
        if input:lower() == "q" then return end
        local num = tonumber(input)
        if num and programs[num] then
            write("Enter new status for '" .. programs[num] .. "': ")
            local newStatus = read()
            status[programs[num]] = newStatus
            saveStatus(status)
            print("Status updated.")
            sleep(1)
        end
    end
end

menu()
