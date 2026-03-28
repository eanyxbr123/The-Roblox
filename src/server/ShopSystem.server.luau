-- ShopSystem.server.luau
-- Sistema de loja com items rotativos

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClassDefinitions = require(ReplicatedStorage.Shared.ClassDefinitions)

print("🛍️ ShopSystem iniciado...")

-- Remotes
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
end

local GetShopRemote = Instance.new("RemoteFunction")
GetShopRemote.Name = "GetShop"
GetShopRemote.Parent = RemotesFolder

local BuyItemRemote = Instance.new("RemoteFunction")
BuyItemRemote.Name = "BuyItem"
BuyItemRemote.Parent = RemotesFolder

-- Items na loja (rotativos)
local shopItems = {
	{id = "police", type = "class", name = "Police", price = {money = 0, crystals = 0}, available = true},
	{id = "medic", type = "class", name = "Medic", price = {money = 2000, crystals = 0}, available = true},
	{id = "builder", type = "class", name = "Builder", price = {money = 1500, crystals = 0}, available = true},
	{id = "hunter", type = "class", name = "Hunter", price = {money = 3000, crystals = 50}, available = math.random() > 0.5},
	{id = "explorer", type = "class", name = "Explorer", price = {money = 2500, crystals = 30}, available = math.random() > 0.5},
	{id = "cyborg", type = "class", name = "Cyborg", price = {money = 5000, crystals = 100}, available = false},
	{id = "berserker", type = "class", name = "Berserker", price = {money = 4000, crystals = 80}, available = math.random() > 0.7},
}

-- Obter loja
GetShopRemote.OnServerInvoke = function(player)
	return shopItems
end

-- Comprar item
BuyItemRemote.OnServerInvoke = function(player, itemId)
	for _, item in pairs(shopItems) do
		if item.id == itemId then
			if not item.available then
				return {success = false, message = "Item esgotado"}
			end
			
			-- TODO: Verificar dinheiro do jogador
			print("✅ " .. player.Name .. " comprou " .. item.name)
			return {success = true, message = "Comprado com sucesso!"}
		end
	end
	
	return {success = false, message = "Item não encontrado"}
end

-- Rotacionar items a cada hora
local lastRotation = tick()
game:GetService("RunService").Heartbeat:Connect(function()
	if tick() - lastRotation > 3600 then
		lastRotation = tick()
		print("🔄 Rotacionando itens da loja...")
		for _, item in pairs(shopItems) do
			item.available = math.random() > 0.3
		end
	end
end)

print("✅ ShopSystem pronto!")
