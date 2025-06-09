function get_material_limits_and_breeches()
    return {
        cast_iron = {
            max_charge = 2.0,
            breeches = {
                "Cast Iron Cannon End",
                "Cast Iron Sliding Breech",
                "Cast Iron Quick-Firing Breech"
            }
        },
        bronze = {
            max_charge = 4.0,
            breeches = { "Screw Breech" }
        },
        steel = {
            max_charge = 6.0,
            breeches = { "Sliding Breech", "Screw Breech" }
        },
        nethersteel = {
            max_charge = 8.0,
            breeches = { "Sliding Breech" }
        }
    }
end

function get_chamber_length(charge_power)
    if charge_power <= 1 then
        return 3
    elseif charge_power <= 2 then
        return 4
    elseif charge_power <= 4 then
        return 5
    elseif charge_power <= 6 then
        return 6
    else
        return 7
    end
end

function suggest_cannon(charge_power)
    local chamber_length = get_chamber_length(charge_power)
    print("\nDesigning a cannon for " .. charge_power .. " propellant charge(s)...\n")
    print("Recommended chamber length: " .. chamber_length .. " blocks\n")

    local materials = get_material_limits_and_breeches()

    for material, info in pairs(materials) do
        local max_charge = info.max_charge
        local breeches = table.concat(info.breeches, ", ")

        if charge_power > max_charge then
            print(material:gsub("^%l", string.upper) .. " cannot safely handle " .. charge_power .. " charges (max " .. max_charge .. ").\n")
        else
            local min_barrel_length = math.floor(charge_power * 1.5 + 0.9)
            local max_barrel_length = math.floor(charge_power * 2.5 + 0.9)

            print("Material: " .. material:gsub("^%l", string.upper))
            print("  - Minimum barrel length: " .. min_barrel_length .. " blocks")
            print("  - Maximum barrel length: " .. max_barrel_length .. " blocks")
            print("  - Breech types: " .. breeches .. "\n")
        end
    end
end

function main()
    io.write("How many propellant charges will your cannon use? ")
    local input = io.read()
    local charge = tonumber(input)

    if not charge or charge < 1 then
        print("Invalid number or value too low.")
        return
    end

    suggest_cannon(charge)
end

main()
