-- CraftingSystem.server.luau
-- Sistema de crafting

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CraftRecipes = require(ReplicatedStorage.Shared.CraftRecipes)
local ItemDefinitions = require(ReplicatedStorage.Shared.ItemDefinitions)
local Inventory = require(ReplicatedStorage.Shared.Inventory)

print("🔨 CraftingSystem iniciado...")

-- Remotes
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
end

local CraftRemote = Instance.new("RemoteFunction")
CraftRemote.Name = "Craft"
CraftRemote.Parent = RemotesFolder

-- Carregar InventorySystem
local serverFolder = game:GetService("ServerScriptService"):FindFirstChild("Server")
local InventorySystem = nil
if serverFolder then
	local invModule = serverFolder:FindFirstChild("InventorySystem")
	if invModule and invModule:IsA("ModuleScript") then
		InventorySystem = require(invModule)
	end
end

-- Crafting logic
CraftRemote.OnServerInvoke = function(player, recipeId)
	local recipe = CraftRecipes[recipeId]
	if not recipe then
		return {success = false, message = "Receita não encontrada"}
	end
	
	if not InventorySystem then
		return {success = false, message = "Sistema indisponível"}
	end
	
	-- Verificar itens
	local playerInv = InventorySystem.getInventory(player)
	local hasItems = Inventory.hasItems(playerInv, ItemDefinitions, recipe)
	
	if not hasItems then
		return {success = false, message = "Itens insuficientes"}
	end
	
	-- Remover inputs
	for itemId, needed in pairs(recipe.inputs) do
		Inventory.removeItem(playerInv, itemId, needed, ItemDefinitions)
	end
	
	-- Adicionar output
	local result = Inventory.addItem(playerInv, recipe.output.item, recipe.output.quantity, ItemDefinitions)
	
	if result.success then
		print("✅ " .. player.Name .. " craftou: " .. recipe.name)
		return {success = true, message = "Crafted: " .. recipe.name}
	else
		-- Reverter se não conseguir adicionar
		for itemId, needed in pairs(recipe.inputs) do
			Inventory.addItem(playerInv, itemId, needed, ItemDefinitions)
		end
		return {success = false, message = "Espaço insuficiente"}
	end
end

print("✅ CraftingSystem pronto!")
