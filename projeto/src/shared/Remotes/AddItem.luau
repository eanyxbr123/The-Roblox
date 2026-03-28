-- AddItem.luau
-- RemoteFunction para adicionar itens

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AddItemRemote = Instance.new("RemoteFunction")
AddItemRemote.Name = "AddItem"
AddItemRemote.Parent = script.Parent

return AddItemRemote
