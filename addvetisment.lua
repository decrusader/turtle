local chatBox = peripheral.find("chatBox")
 
print("wat wil je sturen? ")
local x = read()
 
repeat
    chatBox.sendMessage(x,"#add")
    sleep(10)
until x == ""
