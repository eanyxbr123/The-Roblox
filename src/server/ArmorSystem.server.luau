-- ArmorSystem.server.luau
-- Sistema de armaduras

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Módulos
local ArmorDefinitions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ArmorDefinitions"))

-- Remotes
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")

local GetArmorRemote = RemotesFolder:FindFirstChild("GetArmor") or Instance.new("RemoteFunction")
GetArmorRemote.Name = "GetArmor"
GetArmorRemote.Parent = RemotesFolder

local EquipArmorRemote = RemotesFolder:FindFirstChild("EquipArmor") or Instance.new("RemoteFunction")
EquipArmorRemote.Name = "EquipArmor"
EquipArmorRemote.Parent = RemotesFolder

-- Rastrear armaduras equipadas
local playerArmor = {}

-- Estrutura de dados de armadura
local function createArmorData(armorId)
	local armor = ArmorDefinitions[armorId]
	if not armor then return nil end
	
	return {
		id = armor.id,
		name = armor.name,
		icon = armor.icon,
		defense = armor.defense,
		price = armor.price,
		rarity = armor.rarity,
	}
end

-- GetArmor - retorna armadura equipada
GetArmorRemote.OnServerInvoke = function(player)
	if not playerArmor[player.UserId] then
		playerArmor[player.UserId] = {equipped = nil}
	end
	return playerArmor[player.UserId].equipped
end

-- EquipArmor - equipar armadura
EquipArmorRemote.OnServerInvoke = function(player, armorId)
	local armor = createArmorData(armorId)
	if not armor then
		return {success = false, message = "Armadura não encontrada"}
	end
	
	-- Validar inventário (simplificado - verificar se tem dinheiro)
	local InventorySystem = require(ReplicatedStorage:WaitForChild("Server"):WaitForChild("InventorySystem"))
	
	if not playerArmor[player.UserId] then
		playerArmor[player.UserId] = {}
	end
	
	playerArmor[player.UserId].equipped = armor
	print("⚙️ " .. player.Name .. " equipou " .. armor.name)
	
	return {success = true, message = "Armadura equipada"}
end

-- Inicializar ao entrar
Players.PlayerAdded:Connect(function(player)
	playerArmor[player.UserId] = {equipped = nil}
end)

-- Limpar ao sair
Players.PlayerRemoving:Connect(function(player)
	playerArmor[player.UserId] = nil
end)

print("🛡️ ArmorSystem carregado (" .. #RemotesFolder:GetChildren() .. " remotes)")
