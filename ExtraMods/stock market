function drawGraph(company, x, y, width, height)
  local maxPrice = 1
  for _, p in ipairs(company.history) do
    if p > maxPrice then maxPrice = p end
  end

  -- Raster + grafiek
  for i = 0, height - 1 do
    local gy = y + i
    monitor.setCursorPos(x, gy)
    monitor.setTextColor(colors.gray)
    monitor.write("|")
  end

  for i = 1, math.min(#company.history - 1, width - 2) do
    local px = x + i
    local value = company.history[i]
    local py = y + height - math.floor((value / maxPrice) * height)

    monitor.setCursorPos(px, py)
    if company.history[i+1] >= value then
      monitor.setTextColor(colors.lime)
    else
      monitor.setTextColor(colors.red)
    end
    monitor.write("█")
  end

  -- Laatste prijs
  local lastPx = x + math.min(#company.history, width - 2)
  local lastPy = y + height - math.floor((company.history[#company.history] / maxPrice) * height)
  monitor.setCursorPos(lastPx, lastPy)
  monitor.setTextColor(colors.white)
  monitor.write("●")
end

function drawUI()
  monitor.setBackgroundColor(colors.black)
  monitor.clear()

  -- Titel
  monitor.setCursorPos(1, 1)
  monitor.setTextColor(colors.cyan)
  monitor.write("=== Minecraft Stock Market ===")

  monitor.setCursorPos(1, 2)
  monitor.setTextColor(colors.white)
  monitor.write("Balance: ")
  monitor.setTextColor(colors.green)
  monitor.write("$" .. math.floor(player.balance))

  -- Bedrijfsgrafieken
  local sectionHeight = math.floor((monHeight - 3) / #companies)
  for i, c in ipairs(companies) do
    local y = 3 + (i - 1) * sectionHeight

    -- Naam + prijs
    monitor.setCursorPos(1, y)
    monitor.setTextColor(colors.yellow)
    monitor.write(c.name .. " - $" .. c.price)

    -- Aandelen
    monitor.setCursorPos(1, y + 1)
    monitor.setTextColor(colors.lightGray)
    monitor.write("Aandelen: " .. player.shares[i])

    -- Grafiek
    drawGraph(c, 18, y, monWidth - 18, sectionHeight - 2)
  end
end
