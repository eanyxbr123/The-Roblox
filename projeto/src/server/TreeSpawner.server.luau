-- TreeSpawner.server.luau
-- Sistema de spawn de árvores estilo The Forest

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TreeSpawner = {}

-- Lazy load do ItemSpawner (suporte ServerScriptService.Server ou raiz)
local function getItemSpawner()
	local service = game:GetService("ServerScriptService")
	local itemSpawnerModule = nil
	if service:FindFirstChild("Server") and service.Server:FindFirstChild("ItemSpawner") then
		itemSpawnerModule = service.Server.ItemSpawner
	elseif service:FindFirstChild("ItemSpawner") then
		itemSpawnerModule = service.ItemSpawner
	end

	if not itemSpawnerModule then
		error("ItemSpawner module not found")
		return nil
	end

	return require(itemSpawnerModule)
end

-- Configurações de spawn de árvores
local TREE_CONFIG = {
	treeTypes = {
		{
			name = "OakTree",
			modelName = "Arvore1",
			height = 8,
			radius = 3,
			logsDrop = 3,
			stickChance = 0.7,
			health = 100,
			respawnTime = 300 -- segundos
		},
		{
			name = "PineTree",
			modelName = "Arvore2",
			height = 12,
			radius = 2,
			logsDrop = 4,
			stickChance = 0.5,
			health = 120,
			respawnTime = 400
		},
		{
			name = "BirchTree",
			modelName = "Arvore3",
			height = 6,
			radius = 2,
			logsDrop = 2,
			stickChance = 0.8,
			health = 80,
			respawnTime = 250
		}
	},

	spawnRadius = 100, -- Raio de spawn inicial
	maxTreesPerArea = 15,
	minDistanceBetweenTrees = 8,
	spawnInterval = 60, -- Segundos entre verificações de spawn
}

-- Pasta para armazenar árvores
local TreesFolder = Instance.new("Folder")
TreesFolder.Name = "Trees"
TreesFolder.Parent = workspace

-- Armazenar posições de árvores existentes
local treePositions = {}

-- Função para criar modelo de árvore procedural (fallback)
function TreeSpawner.createProceduralTree(treeType: table, position: Vector3)
	local treeModel = Instance.new("Model")
	treeModel.Name = treeType.name

	-- Tronco
	local trunk = Instance.new("Part")
	trunk.Name = "Trunk"
	trunk.Size = Vector3.new(treeType.radius * 0.5, treeType.height, treeType.radius * 0.5)
	trunk.Position = position + Vector3.new(0, treeType.height/2, 0)
	trunk.Anchored = true
	trunk.CanCollide = true
	trunk.BrickColor = BrickColor.new("Brown")
	trunk.Material = Enum.Material.Wood
	trunk.Parent = treeModel

	-- Folhas (copa)
	local leaves = Instance.new("Part")
	leaves.Name = "Leaves"
	leaves.Size = Vector3.new(treeType.radius * 2, treeType.radius * 1.5, treeType.radius * 2)
	leaves.Position = position + Vector3.new(0, treeType.height + treeType.radius * 0.75, 0)
	leaves.Anchored = true
	leaves.CanCollide = false
	leaves.BrickColor = BrickColor.new("Bright green")
	leaves.Material = Enum.Material.Plastic
	leaves.Shape = Enum.PartType.Ball
	leaves.Parent = treeModel

	-- Adicionar física ao tronco
	local trunkWeld = Instance.new("WeldConstraint")
	trunkWeld.Part0 = trunk
	trunkWeld.Part1 = leaves
	trunkWeld.Parent = trunk

	return treeModel
end

-- Função para spawnar árvore
function TreeSpawner.spawnTree(treeType: table, position: Vector3)
	-- Verificar se já existe árvore próxima
	for _, existingPos in pairs(treePositions) do
		if (existingPos - position).Magnitude < TREE_CONFIG.minDistanceBetweenTrees then
			return nil
		end
	end

	local treeModel

	-- Tentar usar modelo customizado se existir
	local customModel = workspace:FindFirstChild(treeType.modelName)
	if customModel and customModel:IsA("Model") then
		treeModel = customModel:Clone()
		treeModel:MoveTo(position)
	else
		-- Usar modelo procedural
		treeModel = TreeSpawner.createProceduralTree(treeType, position)
	end

	if treeModel then
		-- Adicionar dados da árvore
		local treeData = Instance.new("StringValue")
		treeData.Name = "TreeType"
		treeData.Value = treeType.name
		treeData.Parent = treeModel

		local healthData = Instance.new("IntValue")
		healthData.Name = "Health"
		healthData.Value = treeType.health
		healthData.Parent = treeModel

		local logsData = Instance.new("IntValue")
		logsData.Name = "LogsDrop"
		logsData.Value = treeType.logsDrop
		logsData.Parent = treeModel

		local stickChanceData = Instance.new("NumberValue")
		stickChanceData.Name = "StickChance"
		stickChanceData.Value = treeType.stickChance
		stickChanceData.Parent = treeModel

		-- Sistema de dano (será usado pelo sistema de combate)
		local damageScript = Instance.new("Script")
		damageScript.Name = "TreeDamageHandler"
		damageScript.Source = [[
			local tree = script.Parent
			local health = tree.Health
			local logsDrop = tree.LogsDrop
			local stickChance = tree.StickChance

			tree.Touched:Connect(function(hit)
				local character = hit.Parent
				local humanoid = character:FindFirstChild("Humanoid")
				local player = game.Players:GetPlayerFromCharacter(character)

				if humanoid and player and humanoid.Health > 0 then
					-- Verificar se está segurando uma ferramenta de mineração
					local tool = character:FindFirstChildOfClass("Tool")
					if tool and (tool.Name:find("axe") or tool.Name:find("pickaxe")) then
						health.Value = health.Value - 10

						if health.Value <= 0 then
							-- Árvore caiu
						local path = game.ServerScriptService:FindFirstChild("Server") and game.ServerScriptService.Server:FindFirstChild("TreeSpawner") or game.ServerScriptService:FindFirstChild("TreeSpawner")
						if path then
							require(path).cutDownTree(tree, player)
						else
							warn("TreeSpawner module not found for cutDownTree")
						end
						else
							-- Efeito de dano
							local sound = Instance.new("Sound")
							sound.SoundId = "rbxasset://sounds/wood_hit.wav"
							sound.Volume = 0.5
							sound.Parent = tree.Trunk
							sound:Play()
							wait(1)
							sound:Destroy()
						end
					end
				end
			end)
		]]
		damageScript.Parent = treeModel

		treeModel.Parent = TreesFolder
		table.insert(treePositions, position)

		print("🌳 Spawned " .. treeType.name .. " at " .. tostring(position))
		return treeModel
	end

	return nil
end

-- Função para cortar árvore (chamada quando health <= 0)
function TreeSpawner.cutDownTree(treeModel: Model, player: Player)
	if not treeModel or not treeModel.Parent then return end

	local position = treeModel:GetPivot().Position
	local logsDrop = treeModel.LogsDrop.Value
	local stickChance = treeModel.StickChance.Value

	-- Animação de queda
	local trunk = treeModel:FindFirstChild("Trunk")
	if trunk then
		-- Tornar não ancorado para física
		trunk.Anchored = false

		-- Adicionar força para cair
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
		bodyVelocity.MaxForce = Vector3.new(10000, 0, 10000)
		bodyVelocity.Parent = trunk

		-- Remover física após animação
		task.delay(3, function()
			if bodyVelocity then bodyVelocity:Destroy() end
		end)

		-- Som de árvore caindo
		local fallSound = Instance.new("Sound")
		fallSound.SoundId = "rbxasset://sounds/wood_break.wav"
		fallSound.Volume = 1
		fallSound.Parent = trunk
		fallSound:Play()

		task.delay(5, function()
			if fallSound then fallSound:Destroy() end
		end)
	end

	-- Dropar logs
	for i = 1, logsDrop do
		local dropPos = position + Vector3.new(math.random(-2, 2), 1, math.random(-2, 2))
		getItemSpawner().spawnItemAt("wood", 1, dropPos)
	end

	-- Chance de dropar sticks
	if math.random() <= stickChance then
		local dropPos = position + Vector3.new(math.random(-2, 2), 1, math.random(-2, 2))
		getItemSpawner().spawnItemAt("sticks", math.random(1, 3), dropPos)
	end

	-- Remover árvore após animação
	task.delay(5, function()
		if treeModel and treeModel.Parent then
			treeModel:Destroy()
		end
	end)

	-- Agendar respawn
	local treeType = treeModel.TreeType.Value
	local respawnTime = 300 -- default
	for _, config in pairs(TREE_CONFIG.treeTypes) do
		if config.name == treeType then
			respawnTime = config.respawnTime
			break
		end
	end

	task.delay(respawnTime, function()
		-- Remover da lista de posições
		for i, pos in pairs(treePositions) do
			if pos == position then
				table.remove(treePositions, i)
				break
			end
		end

		-- Respawn da árvore
		local config = TREE_CONFIG.treeTypes[math.random(1, #TREE_CONFIG.treeTypes)]
		TreeSpawner.spawnTree(config, position)
	end)

	print("🪓 " .. player.Name .. " cut down a " .. treeType .. " and got " .. logsDrop .. " logs")
end

-- Função para spawnar árvores em área
function TreeSpawner.spawnTreesInArea(center: Vector3, radius: number)
	local spawned = 0
	local maxAttempts = 100

	for i = 1, maxAttempts do
		if spawned >= TREE_CONFIG.maxTreesPerArea then break end

		local angle = math.random() * math.pi * 2
		local distance = math.random(10, radius)
		local offset = Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)
		local position = center + offset

		-- Verificar se posição é válida
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
		raycastParams.FilterDescendantsInstances = {TreesFolder}

		local raycastResult = workspace:Raycast(position + Vector3.new(0, 50, 0), Vector3.new(0, -100, 0), raycastParams)

		if raycastResult and raycastResult.Material ~= Enum.Material.Water then
			local treeType = TREE_CONFIG.treeTypes[math.random(1, #TREE_CONFIG.treeTypes)]
			if TreeSpawner.spawnTree(treeType, raycastResult.Position) then
				spawned += 1
			end
		end
	end
end

-- Sistema de spawn automático
function TreeSpawner.startAutoSpawn()
	print("🌱 TreeSpawner started; spawning every " .. TREE_CONFIG.spawnInterval .. " seconds")
	task.spawn(function()
		while true do
			-- Spawn trees perto de jogadores
			for _, player in pairs(game.Players:GetPlayers()) do
				if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					local rootPart = player.Character.HumanoidRootPart
					TreeSpawner.spawnTreesInArea(rootPart.Position, TREE_CONFIG.spawnRadius)
				end
			end

			wait(TREE_CONFIG.spawnInterval)
		end
	end)
end

return TreeSpawner