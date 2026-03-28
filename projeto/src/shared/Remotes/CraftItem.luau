-- CraftItem.luau
-- RemoteFunction para craft de itens

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CraftRemote = Instance.new("RemoteFunction")
CraftRemote.Name = "CraftItem"
CraftRemote.Parent = script.Parent

return CraftRemote