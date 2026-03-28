-- InventorySystem.luau (ModuleScript)
-- Gerencia inventários dos jogadores no servidor

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemDefinitions = require(ReplicatedStorage.Shared.ItemDefinitions)
local Inventory = require(ReplicatedStorage.Shared.Inventory)

-- Remotes
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
end

local GetInventoryRemote = Instance.new("RemoteFunction")
GetInventoryRemote.Name = "GetInventory"
GetInventoryRemote.Parent = RemotesFolder

-- Armazenar inventários
local playerInventories = {}

-- Inicializar inventário do jogador
local function initPlayerInventory(player: Player)
	if not playerInventories[player] then
		playerInventories[player] = Inventory.new(1)
		-- Dar itens iniciais
		Inventory.addItem(playerInventories[player], "wood", 5, ItemDefinitions)
		Inventory.addItem(playerInventories[player], "stone", 3, ItemDefinitions)
		print("📦 Inventário criado para " .. player.Name)
	end
end

-- Obter inventário
GetInventoryRemote.OnServerInvoke = function(player: Player)
	if not playerInventories[player] then
		initPlayerInventory(player)
	end
	return playerInventories[player]
end

-- Cleanup
Players.PlayerAdded:Connect(initPlayerInventory)
Players.PlayerRemoving:Connect(function(player)
	playerInventories[player] = nil
end)

print("✅ InventorySystem carregado!")

local InventorySystem = {}
function InventorySystem.addItem(player: Player, itemId: string, quantity: number)
	if playerInventories[player] then
		return Inventory.addItem(playerInventories[player], itemId, quantity, ItemDefinitions)
	end
end

return InventorySystem
