-- BlockInteraction.server.lua
-- Gerencia mineração e coleta de blocos

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockDefinitions = require(ReplicatedStorage.Shared.BlockDefinitions)

print("⛏️  BlockInteraction iniciado...")

-- Remotes
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
end

local MineBlockRemote = Instance.new("RemoteFunction")
MineBlockRemote.Name = "MineBlock"
MineBlockRemote.Parent = RemotesFolder

local ItemCollectedEvent = Instance.new("RemoteEvent")
ItemCollectedEvent.Name = "ItemCollected"
ItemCollectedEvent.Parent = RemotesFolder

-- Carregar InventorySystem
local serverFolder = game:GetService("ServerScriptService"):FindFirstChild("Server")
local InventorySystem = nil
if serverFolder then
	local invModule = serverFolder:FindFirstChild("InventorySystem")
	if invModule and invModule:IsA("ModuleScript") then
		InventorySystem = require(invModule)
	end
end

-- Estados dos blocos (para damage)
local blockHealth = {}

-- Mineração
MineBlockRemote.OnServerInvoke = function(player, block)
	if not block or not block:IsDescendantOf(workspace) then
		return {success = false, message = "Bloco não encontrado"}
	end
	
	local blockType = block:GetAttribute("blockType")
	local worldX = block:GetAttribute("worldX")
	local worldY = block:GetAttribute("worldY")
	local worldZ = block:GetAttribute("worldZ")
	
	if not blockType then
		return {success = false, message = "Bloco inválido"}
	end
	
	local blockDef = BlockDefinitions[blockType]
	if not blockDef then
		return {success = false, message = "Tipo de bloco desconhecido"}
	end
	
	-- Usar key única para rastrear health
	local key = worldX .. "," .. worldY .. "," .. worldZ
	blockHealth[key] = (blockHealth[key] or blockDef.health) - 1
	
	print("⛏️  " .. player.Name .. " minerou " .. blockType .. " (HP: " .. blockHealth[key] .. ")")
	
	-- Se bloco morreu
	if blockHealth[key] <= 0 then
		print("💀 Bloco destruído: " .. key)
		
		-- Dar item ao jogador
		local drop = blockDef.drop
		if drop and drop ~= "none" and InventorySystem then
			print("🎁 Drop: " .. drop)
			
			-- Adicionar ao inventário
			local result = InventorySystem.addItem(player, drop, 1)
			if result.success then
				print("✅ Item adicionado ao inventário: " .. drop)
				-- Notificar cliente que item foi coletado
				ItemCollectedEvent:FireClient(player, drop, 1)
			else
				print("❌ Erro ao adicionar item: " .. (result.message or "desconhecido"))
			end
		end
		
		-- Destruir o bloco
		block:Destroy()
		blockHealth[key] = nil
		
		return {success = true, message = "Bloco destruído!", drop = drop}
	else
		return {success = true, message = "Bloco danificado"}
	end
end

print("✅ BlockInteraction pronto!")
