-- craft_sticks.lua
-- CC:Tweaked crafty turtle script to craft sticks from planks.
-- Defaults: input = "up" (suckUp), output = "down" (dropDown).
-- You can change INPUT/OUTPUT to "front", "up", or "down".

local INPUT  = "up"    -- "front", "up", or "down"
local OUTPUT = "down"  -- "front", "up", or "down"

-- helpers mapping sides to turtle functions
local suckFuncs = {
  front = turtle.suck,
  up    = turtle.suckUp,
  down  = turtle.suckDown
}
local dropFuncs = {
  front = turtle.drop,
  up    = turtle.dropUp,
  down  = turtle.dropDown
}

local function suckFrom(side)
  local f = suckFuncs[side]
  if not f then error("Invalid input side: "..tostring(side)) end
  -- try to suck until chest is empty or inventory full
  local pulled = false
  while true do
    local ok = f()
    if not ok then break end
    pulled = true
    -- if inventory full, stop trying
    local full = true
    for i=1,16 do
      if turtle.getItemCount(i) == 0 then full = false; break end
    end
    if full then break end
  end
  return pulled
end

local function dropTo(side, keepFilter)
  local f = dropFuncs[side]
  if not f then error("Invalid output side: "..tostring(side)) end
  for i=1,16 do
    local d = turtle.getItemDetail(i)
    if d then
      -- drop items that match keepFilter==nil or keepFilter(d) == true
      if not keepFilter or keepFilter(d) then
        turtle.select(i)
        -- we try dropFull, but drop returns false if there's no chest or it's full
        local ok = f()
        if not ok then
          -- try partial drops: drop 1 at a time to avoid losing items
          local cnt = turtle.getItemCount(i)
          for _=1,cnt do
            if not f() then break end
          end
        end
      end
    end
  end
end

local function hasPlanks()
  for i=1,16 do
    local d = turtle.getItemDetail(i)
    if d and (d.name:match("plank") or d.name:match("wood_plank") or d.name:match("planks")) then
      return true
    end
  end
  return false
end

-- check for craft capability
if not turtle.craft then
  error("turtle.craft is not available. You need a crafty turtle / CC:Tweaked with craft support.")
end

-- run loop
print("Craft sticks: input="..INPUT.." output="..OUTPUT)
local idleRounds = 0
while true do
  -- pull items from input chest
  local pulled = suckFrom(INPUT)

  if not hasPlanks() then
    if not pulled then
      idleRounds = idleRounds + 1
    else
      idleRounds = 0
    end
  else
    idleRounds = 0
  end

  if not hasPlanks() then
    if idleRounds >= 2 then
      print("No more planks detected. Exiting.")
      break
    end
  end

  -- try craft: this will craft as much as possible (up to one stack)
  local ok, err = turtle.craft()
  if not ok then
    -- craft may fail if items are not in the right positions or not enough materials
    print("turtle.craft() failed: ", tostring(err))
    -- If we have planks but craft failed, try to rearrange minimally:
    -- move any planks into the first two vertical slots (1 and 4) if possible
    local function moveToCraftSlots()
      -- try to consolidate planks into slots 1 and 4 (craft grid column 1)
      local targetSlots = {1,4}
      local found = {}
      for i=1,16 do
        local d = turtle.getItemDetail(i)
        if d and (d.name:match("plank") or d.name:match("planks")) then
          table.insert(found, i)
        end
      end
      local t = 1
      for _,slot in ipairs(found) do
        if t > #targetSlots then break end
        if slot ~= targetSlots[t] then
          turtle.select(slot)
          turtle.transferTo(targetSlots[t])
        end
        t = t + 1
      end
    end
    moveToCraftSlots()
    -- try craft again once
    ok, err = turtle.craft()
    if not ok then
      -- nothing we can do this cycle
      print("Craft still failed: "..tostring(err).." -- attempting again after pulling more items.")
    end
  else
    -- crafted something: move sticks to output
    dropTo(OUTPUT, function(d)
      -- drop anything that looks like a stick
      return (d.name:match("stick") ~= nil) or (d.name == "minecraft:stick")
    end)
  end

  -- small pause to avoid busy-looping
  os.sleep(0.5)
end

print("Done.")
