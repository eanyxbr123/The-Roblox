-- InventorySystem.luau
-- ⚠️  Este arquivo deve ser um ModuleScript no Roblox Studio
--     (não .server.luau) para poder ser usado com require()
--     Nome no Studio: InventorySystem (ModuleScript)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemDefinitions = require(ReplicatedStorage.Shared.ItemDefinitions)
local CraftRecipes = require(ReplicatedStorage.Shared.CraftRecipes)
local Inventory = require(ReplicatedStorage.Shared.Inventory)

-- Criar pasta Remotes se não existir
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
end

-- Remotes
local CraftRemote = Instance.new("RemoteFunction")
CraftRemote.Name = "CraftItem"
CraftRemote.Parent = RemotesFolder

local AddItemRemote = Instance.new("RemoteFunction")
AddItemRemote.Name = "AddItem"
AddItemRemote.Parent = RemotesFolder

local RemoveItemRemote = Instance.new("RemoteFunction")
RemoveItemRemote.Name = "RemoveItem"
RemoveItemRemote.Parent = RemotesFolder

local GetInventoryRemote = Instance.new("RemoteFunction")
GetInventoryRemote.Name = "GetInventory"
GetInventoryRemote.Parent = RemotesFolder

-- Armazenar inventários dos jogadores
local playerInventories: {[Player]: any} = {}

-- Inicializar inventário do jogador
local function initPlayerInventory(player: Player)
	if not playerInventories[player] then
		-- ✅ Inventory.new() recebe backpackLevel (1-5), não (slots, peso)
		playerInventories[player] = Inventory.new(1) -- Nível 1 = 5x4 = 20 slots

		-- Dar alguns itens iniciais
		Inventory.addItem(playerInventories[player], "wood", 5, ItemDefinitions)
		Inventory.addItem(playerInventories[player], "stone", 3, ItemDefinitions)
	end
end

-- Craft de item
CraftRemote.OnServerInvoke = function(player: Player, recipeId: string)
	if not playerInventories[player] then
		initPlayerInventory(player)
	end

	local recipe = CraftRecipes[recipeId]
	if not recipe then
		return {success = false, message = "Receita não encontrada"}
	end

	local inv = playerInventories[player]

	if not Inventory.hasItems(inv, ItemDefinitions, recipe) then
		return {success = false, message = "Itens insuficientes"}
	end

	for itemId, needed in pairs(recipe.inputs) do
		Inventory.removeItem(inv, itemId, needed, ItemDefinitions)
	end

	local outputResult = Inventory.addItem(inv, recipe.output.item, recipe.output.quantity, ItemDefinitions)

	if not outputResult.success then
		for itemId, needed in pairs(recipe.inputs) do
			Inventory.addItem(inv, itemId, needed, ItemDefinitions)
		end
		return {success = false, message = "Espaço insuficiente no inventário"}
	end

	print(player.Name .. " craftou " .. recipe.name)
	return {success = true, message = "Item craftado com sucesso!", recipe = recipe}
end

-- Remover item
RemoveItemRemote.OnServerInvoke = function(player: Player, itemId: string, quantity: number)
	if not playerInventories[player] then
		return {success = false, message = "Inventário não inicializado"}
	end

	local success = Inventory.removeItem(playerInventories[player], itemId, quantity, ItemDefinitions)
	return {success = success, message = success and "Item removido" or "Item não encontrado"}
end

-- Obter inventário
GetInventoryRemote.OnServerInvoke = function(player: Player)
	if not playerInventories[player] then
		initPlayerInventory(player)
	end
	return playerInventories[player]
end

-- Cleanup ao sair
Players.PlayerRemoving:Connect(function(player: Player)
	playerInventories[player] = nil
end)

-- Inicializar ao entrar
Players.PlayerAdded:Connect(function(player: Player)
	initPlayerInventory(player)
end)

print("✅ Inventory System carregado!")

-- ✅ Retornar módulo com funções acessíveis por outros sistemas do servidor
local InventorySystem = {}

function InventorySystem.addItemToPlayer(player: Player, itemId: string, quantity: number): boolean
	if not playerInventories[player] then
		initPlayerInventory(player)
	end
	if not ItemDefinitions[itemId] then
		return false
	end
	local result = Inventory.addItem(playerInventories[player], itemId, quantity, ItemDefinitions)
	return result.success
end

function InventorySystem.getInventory(player: Player)
	if not playerInventories[player] then
		initPlayerInventory(player)
	end
	return playerInventories[player]
end

return InventorySystem
