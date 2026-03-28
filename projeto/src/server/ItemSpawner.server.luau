-- ItemSpawner.server.luau
-- Sistema de spawn de itens no chão estilo Rust/The Forest

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemDefinitions = require(ReplicatedStorage.Shared.ItemDefinitions)

local ItemSpawner = {}

-- Configurações de spawn
local SPAWN_CONFIG = {
	-- Itens que spawnam no chão
	groundItems = {
		{itemId = "wood", chance = 0.4, minAmount = 1, maxAmount = 3},
		{itemId = "stone", chance = 0.3, minAmount = 1, maxAmount = 2},
		{itemId = "cloth", chance = 0.2, minAmount = 1, maxAmount = 2},
		{itemId = "mushroom", chance = 0.1, minAmount = 1, maxAmount = 1},
	},

	-- Configurações gerais
	mapSpawnArea = {
		center = Vector3.new(0, 0, 0),
		radius = 100, -- Grande área do mapa (100 studs raio)
	},
	initialItemsToSpawn = 20, -- Itens spawnados no startup do mapa
	maxItemsPerArea = 30, -- Máximo de itens por área
	spawnInterval = 45, -- Segundos entre respawns
	itemLifetime = 300, -- Segundos que o item fica no chão
}

-- Pasta para armazenar itens spawnados
local SpawnedItemsFolder = Instance.new("Folder")
SpawnedItemsFolder.Name = "SpawnedItems"
SpawnedItemsFolder.Parent = workspace

-- Função para spawnar item aleatório
function ItemSpawner.spawnRandomItem(position: Vector3)
	local itemConfig = SPAWN_CONFIG.groundItems[math.random(1, #SPAWN_CONFIG.groundItems)]

	if math.random() <= itemConfig.chance then
		local itemDef = ItemDefinitions[itemConfig.itemId]
		if itemDef then
			local amount = math.random(itemConfig.minAmount, itemConfig.maxAmount)
			ItemSpawner.spawnItemAt(itemConfig.itemId, amount, position)
		end
	end
end

-- Função para spawnar item específico em posição
function ItemSpawner.spawnItemAt(itemId: string, amount: number, position: Vector3)
	local itemDef = ItemDefinitions[itemId]
	if not itemDef then return end

	-- Criar parte física do item
	local itemPart = Instance.new("Part")
	itemPart.Name = itemId .. "_item"
	itemPart.Size = Vector3.new(1, 0.2, 1)
	itemPart.Position = position + Vector3.new(0, 0.1, 0)
	itemPart.Anchored = false
	itemPart.CanCollide = true

	-- Adicionar física
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new(math.random(-2, 2), 5, math.random(-2, 2))
	bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
	bodyVelocity.Parent = itemPart

	-- Remover física após um tempo
	task.delay(0.5, function()
		if bodyVelocity then bodyVelocity:Destroy() end
	end)

	-- Adicionar aparência baseada na raridade
	local color = Color3.fromRGB(150, 150, 150) -- comum
	if itemDef.rarity == "uncommon" then
		color = Color3.fromRGB(100, 200, 100)
	elseif itemDef.rarity == "rare" then
		color = Color3.fromRGB(100, 150, 255)
	elseif itemDef.rarity == "epic" then
		color = Color3.fromRGB(200, 100, 255)
	elseif itemDef.rarity == "legendary" then
		color = Color3.fromRGB(255, 200, 100)
	end

	itemPart.Color = color

	-- Adicionar brilho para itens raros
	if itemDef.rarity ~= "common" then
		local highlight = Instance.new("Highlight")
		highlight.FillColor = color
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 0.3
		highlight.Parent = itemPart
	end

	-- Adicionar texto flutuante
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 100, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.Parent = itemPart

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextStrokeTransparency = 0
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.TextSize = 14
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Text = itemDef.name .. (amount > 1 and " x" .. amount or "")
	textLabel.Parent = billboard

	-- Adicionar dados do item
	local itemData = Instance.new("StringValue")
	itemData.Name = "ItemId"
	itemData.Value = itemId
	itemData.Parent = itemPart

	local amountData = Instance.new("IntValue")
	amountData.Name = "Amount"
	amountData.Value = amount
	amountData.Parent = itemPart

	-- Adicionar ao workspace
	itemPart.Parent = SpawnedItemsFolder
	
	-- Nota: A coleta de itens agora é feita pelo cliente usando arrasto
	-- (veja ItemInteractionClient.client.luau)

	-- Remover item após tempo de vida
	task.delay(SPAWN_CONFIG.itemLifetime, function()
		if itemPart and itemPart.Parent then
			itemPart:Destroy()
		end
	end)

	print("✅ Spawned " .. amount .. "x " .. itemId .. " at " .. tostring(position))
end

-- Sistema de spawn automático
function ItemSpawner.startAutoSpawn()
	-- Spawn inicial de itens no mapa
	print("🌍 Spawning initial items on map...")
	for i = 1, SPAWN_CONFIG.initialItemsToSpawn do
		local angle = math.random() * math.pi * 2
		local distance = math.random() * SPAWN_CONFIG.mapSpawnArea.radius
		local offset = Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)
		local position = SPAWN_CONFIG.mapSpawnArea.center + offset
		
		-- Raycast para encontrar chão
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
		raycastParams.FilterDescendantsInstances = {SpawnedItemsFolder}
		
		local raycastResult = workspace:Raycast(position + Vector3.new(0, 50, 0), Vector3.new(0, -100, 0), raycastParams)
		if raycastResult and raycastResult.Material ~= Enum.Material.Water then
			ItemSpawner.spawnRandomItem(raycastResult.Position)
		end
	end
	
	-- Respawn periódico (mantém itens ativos)
	task.spawn(function()
		while true do
			wait(SPAWN_CONFIG.spawnInterval)
			
			-- Contar itens ativos
			local activeItems = #SpawnedItemsFolder:GetChildren()
			
			-- Se houver menos itens, spawnar mais
			if activeItems < SPAWN_CONFIG.initialItemsToSpawn * 0.5 then
				local itemsToSpawn = math.ceil(SPAWN_CONFIG.initialItemsToSpawn * 0.3)
				for i = 1, itemsToSpawn do
					local angle = math.random() * math.pi * 2
					local distance = math.random() * SPAWN_CONFIG.mapSpawnArea.radius
					local offset = Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)
					local position = SPAWN_CONFIG.mapSpawnArea.center + offset
					
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
					raycastParams.FilterDescendantsInstances = {SpawnedItemsFolder}
					
					local raycastResult = workspace:Raycast(position + Vector3.new(0, 50, 0), Vector3.new(0, -100, 0), raycastParams)
					if raycastResult and raycastResult.Material ~= Enum.Material.Water then
						ItemSpawner.spawnRandomItem(raycastResult.Position)
					end
				end
			end
		end
	end)
end

-- Função para coletar item (chamada do cliente via remote)
function ItemSpawner.collectItem(player: Player, itemPart: Part)
	if not itemPart or not itemPart.Parent then return false end

	local itemId = itemPart:FindFirstChild("ItemId")
	local amount = itemPart:FindFirstChild("Amount")

	if itemId and amount then
		-- Usar remote para adicionar ao inventário
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local AddItemRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("AddItem")
		
		if not AddItemRemote then
			warn("AddItem remote not found")
			return false
		end

		local success = pcall(function()
			AddItemRemote:InvokeClient(player, itemId.Value, amount.Value)
		end)
		
		if not success then
			warn("Failed to call AddItem remote")
			return false
		end

		if success then
			-- Recompensa de experiência por coletar itens
			local stats = player:FindFirstChild("Stats")
			if stats then
				local xpValue = stats:FindFirstChild("XP")
				local levelValue = stats:FindFirstChild("Level")
				if xpValue and levelValue then
					xpValue.Value = xpValue.Value + amount.Value * 5
					local needed = levelValue.Value * 100
					if xpValue.Value >= needed then
						levelValue.Value = levelValue.Value + 1
						xpValue.Value = xpValue.Value - needed
						print("🏆 " .. player.Name .. " reached level " .. levelValue.Value)
					end
				end
			end

			itemPart:Destroy()
			return true
		end
	end

	return false
end

return ItemSpawner