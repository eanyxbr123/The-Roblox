-- GetInventory.luau
-- RemoteFunction para obter inventário

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GetInventoryRemote = Instance.new("RemoteFunction")
GetInventoryRemote.Name = "GetInventory"
GetInventoryRemote.Parent = script.Parent

return GetInventoryRemote