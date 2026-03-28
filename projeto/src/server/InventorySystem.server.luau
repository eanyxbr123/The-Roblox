-- InventorySystem.server.luau
-- Sistema de inventário e craft no servidor

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemDefinitions = require(ReplicatedStorage.Shared.ItemDefinitions)
local CraftRecipes = require(ReplicatedStorage.Shared.CraftRecipes)
local Inventory = require(ReplicatedStorage.Shared.Inventory)

-- Criar pasta Remotes se não existir
local InventoryFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not InventoryFolder then
	InventoryFolder = Instance.new("Folder")
	InventoryFolder.Name = "Remotes"
	InventoryFolder.Parent = ReplicatedStorage
end

-- Remotes
local CraftRemote = Instance.new("RemoteFunction")
CraftRemote.Name = "CraftItem"
CraftRemote.Parent = InventoryFolder

local AddItemRemote = Instance.new("RemoteFunction")
AddItemRemote.Name = "AddItem"
AddItemRemote.Parent = InventoryFolder

local RemoveItemRemote = Instance.new("RemoteFunction")
RemoveItemRemote.Name = "RemoveItem"
RemoveItemRemote.Parent = InventoryFolder

local GetInventoryRemote = Instance.new("RemoteFunction")
GetInventoryRemote.Name = "GetInventory"
GetInventoryRemote.Parent = InventoryFolder

-- Armazenar inventários dos jogadores
local playerInventories: {[Player]: any} = {}

-- Inicializar inventário do jogador
local function initPlayerInventory(player: Player)
	if not playerInventories[player] then
		playerInventories[player] = Inventory.new(30, 250) -- 30 slots, peso máximo 250
		
		-- Dar alguns itens iniciais
		Inventory.addItem(playerInventories[player], "wood", 50, ItemDefinitions)
		Inventory.addItem(playerInventories[player], "stone", 30, ItemDefinitions)
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

	-- Verificar se tem os itens necessários
	if not Inventory.hasItems(inv, ItemDefinitions, recipe) then
		return {success = false, message = "Itens insuficientes"}
	end

	-- Remover itens de entrada
	for itemId, needed in pairs(recipe.inputs) do
		Inventory.removeItem(inv, itemId, needed)
	end

	-- Adicionar item de saída
	local outputSuccess = Inventory.addItem(inv, recipe.output.item, recipe.output.quantity, ItemDefinitions)

	if not outputSuccess then
		-- Se falhar em adicionar o output, devolver os inputs
		for itemId, needed in pairs(recipe.inputs) do
			Inventory.addItem(inv, itemId, needed, ItemDefinitions)
		end
		return {success = false, message = "Espaço insuficiente no inventário"}
	end

	print(player.Name .. " craftou " .. recipe.name)
	return {success = true, message = "Item craftado com sucesso!", recipe = recipe}
end

-- Adicionar item (admin/system)
AddItemRemote.OnServerInvoke = function(player: Player, itemId: string, quantity: number)
	if not playerInventories[player] then
		initPlayerInventory(player)
	end

	if not ItemDefinitions[itemId] then
		return {success = false, message = "Item não encontrado"}
	end

	local success = Inventory.addItem(playerInventories[player], itemId, quantity, ItemDefinitions)
	return {success = success, message = success and "Item adicionado" or "Espaço insuficiente"}
end

-- Remover item
RemoveItemRemote.OnServerInvoke = function(player: Player, itemId: string, quantity: number)
	if not playerInventories[player] then
		return {success = false, message = "Inventário não inicializado"}
	end

	local success = Inventory.removeItem(playerInventories[player], itemId, quantity)
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
