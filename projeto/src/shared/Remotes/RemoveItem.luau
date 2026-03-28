-- RemoveItem.luau
-- RemoteFunction para remover itens

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoveItemRemote = Instance.new("RemoteFunction")
RemoveItemRemote.Name = "RemoveItem"
RemoveItemRemote.Parent = script.Parent

return RemoveItemRemote