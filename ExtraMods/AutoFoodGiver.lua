local manager = peripheral.find("inventoryManager")
 
print("where is the chest?")
local x = read()
i = 0
 
repeat
manager.addItemToPlayer(x, {name="minecraft:cooked_beef", toSlot=0, count=1})
until i == 1
