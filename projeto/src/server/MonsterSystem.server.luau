-- MonsterSystem.server.luau
-- Sistema de monstros/canibais estilo The Forest

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MonsterSystem = {}

-- Lazy load do DayNightSystem
local function getDayNightSystem()
	return require(game.ServerScriptService.Server.DayNightSystem)
end

-- Configurações de monstros
local MONSTER_CONFIG = {
	cannibal = {
		name = "Cannibal",
		health = 100,
		damage = 25,
		speed = 12,
		detectionRange = 30,
		attackRange = 3,
		spawnChance = 0.6,
		lightFearLevel = 1, -- 1-10, quanto maior menos medo de luz
	},

	mutant = {
		name = "Mutant",
		health = 150,
		damage = 40,
		speed = 16,
		detectionRange = 40,
		attackRange = 4,
		spawnChance = 0.3,
		lightFearLevel = 3,
	},

	virginia = {
		name = "Virginia",
		health = 300,
		damage = 60,
		speed = 20,
		detectionRange = 50,
		attackRange = 5,
		spawnChance = 0.1,
		lightFearLevel = 5,
	}
}

-- Estado do sistema
local activeMonsters = {}
local monsterFolder = Instance.new("Folder")
monsterFolder.Name = "Monsters"
monsterFolder.Parent = workspace

-- Função para criar modelo de monstro procedural
function MonsterSystem.createMonsterModel(monsterType: string, config: table)
	local monsterModel = Instance.new("Model")
	monsterModel.Name = config.name

	-- Corpo principal
	local body = Instance.new("Part")
	body.Name = "HumanoidRootPart"
	body.Size = Vector3.new(2, 2, 1)
	body.Anchored = false
	body.CanCollide = true
	body.BrickColor = BrickColor.new("Reddish brown")
	body.Parent = monsterModel

	-- Cabeça
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1, 1, 1)
	head.Position = body.Position + Vector3.new(0, 1.5, 0)
	head.Anchored = false
	head.CanCollide = true
	head.BrickColor = BrickColor.new("Light orange")
	head.Parent = monsterModel

	-- Adicionar Humanoid
	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = config.health
	humanoid.Health = config.health
	humanoid.WalkSpeed = config.speed
	humanoid.Parent = monsterModel

	-- Weld head to body
	local neckWeld = Instance.new("Weld")
	neckWeld.Part0 = body
	neckWeld.Part1 = head
	neckWeld.C0 = CFrame.new(0, 1, 0)
	neckWeld.C1 = CFrame.new(0, -0.5, 0)
	neckWeld.Parent = body

	-- Adicionar dados do monstro
	local typeData = Instance.new("StringValue")
	typeData.Name = "MonsterType"
	typeData.Value = monsterType
	typeData.Parent = monsterModel

	local configData = Instance.new("StringValue")
	configData.Name = "Config"
	configData.Value = game:GetService("HttpService"):JSONEncode(config)
	configData.Parent = monsterModel

	return monsterModel
end

-- Função para spawnar monstro
function MonsterSystem.spawnMonster(monsterType: string, position: Vector3)
	local config = MONSTER_CONFIG[monsterType]
	if not config then return nil end

	local monsterModel = MonsterSystem.createMonsterModel(monsterType, config)
	monsterModel:MoveTo(position)

	-- Adicionar à lista de monstros ativos
	table.insert(activeMonsters, monsterModel)

	-- Sistema de IA
	local aiScript = Instance.new("Script")
	aiScript.Name = "MonsterAI"
	aiScript.Source = [[
		local monster = script.Parent
		local humanoid = monster:FindFirstChild("Humanoid")
		local rootPart = monster:FindFirstChild("HumanoidRootPart")
		local config = game:GetService("HttpService"):JSONDecode(monster.Config.Value)

		local target = nil
		local lastAttack = 0
		local wanderDirection = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)).Unit

		while humanoid and humanoid.Health > 0 do
			local isNight = getDayNightSystem().isNight()
			local nightCount = getDayNightSystem().getNightCount()

			if isNight then
				-- Durante a noite, monstros são ativos
				local nearestPlayer = nil
				local nearestDistance = config.detectionRange

				-- Procurar jogadores próximos
				for _, player in pairs(game.Players:GetPlayers()) do
					if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
						local playerRoot = player.Character.HumanoidRootPart
						local distance = (playerRoot.Position - rootPart.Position).Magnitude

						if distance < nearestDistance then
							-- Verificar medo de luz
							local lightFear = config.lightFearLevel
							if nightCount <= 10 then
								lightFear = lightFear + (10 - nightCount) -- Mais medo nos primeiros dias
							end

							local isInLight = false
							local lightLevel = game:GetService("Lighting").Brightness

							-- Verificar se jogador está em área iluminada
							if lightLevel > 0.3 or player.Character:FindFirstChild("Torch") then
								isInLight = true
							end

							if not isInLight or math.random() > (lightFear / 10) then
								nearestPlayer = player
								nearestDistance = distance
							end
						end
					end
				end

				if nearestPlayer then
					target = nearestPlayer
					local direction = (target.Character.HumanoidRootPart.Position - rootPart.Position).Unit
					humanoid:MoveTo(rootPart.Position + direction * 5)

					-- Ataque se estiver próximo
					if nearestDistance < config.attackRange and tick() - lastAttack > 2 then
						target.Character.Humanoid:TakeDamage(config.damage)
						lastAttack = tick()

						-- Som de ataque
						local attackSound = Instance.new("Sound")
						attackSound.SoundId = "rbxasset://sounds/sword_slash.wav"
						attackSound.Volume = 0.7
						attackSound.Parent = rootPart
						attackSound:Play()
						wait(1)
						attackSound:Destroy()
					end
				else
					-- Wander aleatoriamente
					target = nil
					if math.random() < 0.02 then -- Mudar direção ocasionalmente
						wanderDirection = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)).Unit
					end
					humanoid:MoveTo(rootPart.Position + wanderDirection * 10)
				end
			else
				-- Durante o dia, monstros ficam parados ou fogem
				humanoid:MoveTo(rootPart.Position)
			end

			wait(0.5)
		end

		-- Monstro morreu
		require(game.ServerScriptService.Server.MonsterSystem).onMonsterDeath(monster)
	]]
	aiScript.Parent = monsterModel

	monsterModel.Parent = monsterFolder

	print("👹 Spawned " .. config.name .. " at " .. tostring(position))
	return monsterModel
end

-- Função chamada quando monstro morre
function MonsterSystem.onMonsterDeath(monster: Model)
	-- Remover da lista de ativos
	for i, activeMonster in pairs(activeMonsters) do
		if activeMonster == monster then
			table.remove(activeMonsters, i)
			break
		end
	end

	-- Dropar itens
	local position = monster:GetPivot().Position
	local ItemSpawner = require(game.ServerScriptService.Server.ItemSpawner)

	-- Chance de dropar cloth ou outros itens
	if math.random() < 0.3 then
		ItemSpawner.spawnItemAt("cloth", math.random(1, 3), position)
	end

	-- Destruir modelo após um tempo
	task.delay(5, function()
		if monster and monster.Parent then
			monster:Destroy()
		end
	end)

	print("💀 Monster died and dropped items")
end

-- Função para spawnar monstros em área
function MonsterSystem.spawnMonstersInArea(center: Vector3, radius: number)
	if not getDayNightSystem().isNight() then return end

	local maxMonsters = 5
	local spawned = 0

	for i = 1, maxMonsters do
		local angle = math.random() * math.pi * 2
		local distance = math.random(20, radius)
		local offset = Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)
		local position = center + offset

		-- Verificar se posição é válida
		local raycastResult = workspace:Raycast(position + Vector3.new(0, 10, 0), Vector3.new(0, -20, 0))
		if raycastResult then
			position = raycastResult.Position + Vector3.new(0, 2, 0)

			-- Escolher tipo de monstro baseado na chance
			local rand = math.random()
			local monsterType = "cannibal"

			if rand < MONSTER_CONFIG.mutant.spawnChance then
				monsterType = "mutant"
			elseif rand < MONSTER_CONFIG.mutant.spawnChance + MONSTER_CONFIG.virginia.spawnChance then
				monsterType = "virginia"
			end

			if MonsterSystem.spawnMonster(monsterType, position) then
				spawned += 1
			end
		end
	end
end

-- Sistema de spawn automático durante a noite
function MonsterSystem.startAutoSpawn()
	getDayNightSystem().onNightStart(function(nightCount)
		task.spawn(function()
			while getDayNightSystem().isNight() do
				-- Spawn monsters perto de jogadores
				for _, player in pairs(game.Players:GetPlayers()) do
					if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
						local rootPart = player.Character.HumanoidRootPart
						MonsterSystem.spawnMonstersInArea(rootPart.Position, 100)
					end
				end

				wait(30) -- Spawn a cada 30 segundos durante a noite
			end
		end)
	end)
end

-- Função para limpar monstros quando amanhece
function MonsterSystem.clearMonstersOnDay()
	getDayNightSystem().onDayStart(function(dayCount)
		for _, monster in pairs(activeMonsters) do
			if monster and monster.Parent then
				monster:Destroy()
			end
		end
		activeMonsters = {}
		print("☀️ Cleared all monsters for day " .. dayCount)
	end)
end

-- Inicialização
function MonsterSystem.init()
	MonsterSystem.startAutoSpawn()
	MonsterSystem.clearMonstersOnDay()
	print("👹 Monster system initialized")
end

return MonsterSystem