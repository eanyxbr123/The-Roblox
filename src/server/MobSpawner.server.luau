-- MobSpawner.server.luau
-- Spawna mobs durante noite

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

print("👹 MobSpawner iniciado...")

-- Remotes
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
local DayNightChangedEvent = RemotesFolder and RemotesFolder:FindFirstChild("DayNightChanged")

local spawnedMobs = {}
local isNight = false

-- Criar mob
local function spawnMob()
	local mobFolder = Instance.new("Folder")
	mobFolder.Name = "Mob_" .. tick()
	mobFolder.Parent = workspace
	
	-- Corpo do mob
	local body = Instance.new("Part")
	body.Shape = Enum.PartType.Ball
	body.Size = Vector3.new(2, 2, 2)
	body.Color = Color3.fromRGB(200, 50, 50)
	body.Position = Vector3.new(math.random(-100, 100), 5, math.random(-100, 100))
	body.CanCollide = true
	body.Parent = mobFolder
	
	-- Humanoid
	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = 20
	humanoid.Health = 20
	humanoid.Parent = mobFolder
	
	local mob = {
		folder = mobFolder,
		body = body,
		humanoid = humanoid,
		health = 20,
		lastAttackTime = 0,
	}
	
	table.insert(spawnedMobs, mob)
	print("👹 Mob spawned: " .. mobFolder.Name)
	
	return mob
end

-- Destruir mob
local function killMob(mob)
	if mob.folder.Parent then
		mob.folder:Destroy()
	end
	table.remove(spawnedMobs, table.find(spawnedMobs, mob))
	print("💀 Mob morreu")
end

-- Ao mudar dia/noite
if DayNightChangedEvent then
	DayNightChangedEvent.OnServerEvent:Connect(function(data)
		isNight = data.isNight
		
		if isNight then
			print("👹 Spawning mobs...")
			for i = 1, 5 do
				spawnMob()
			end
		else
			print("☀️ Removendo mobs...")
			for _, mob in pairs(spawnedMobs) do
				killMob(mob)
			end
		end
	end)
end

-- AI simples dos mobs (perseguir jogadores)
RunService.Heartbeat:Connect(function()
	local players = game:GetService("Players"):GetPlayers()
	
	for _, mob in pairs(spawnedMobs) do
		if mob.body and mob.body.Parent then
			-- Encontrar jogador mais próximo
			local closest = nil
			local minDist = math.huge
			
			for _, player in pairs(players) do
				if player.Character then
					local charPos = player.Character:FindFirstChild("HumanoidRootPart")
					if charPos then
						local dist = (mob.body.Position - charPos.Position).Magnitude
						if dist < minDist and dist < 50 then
							minDist = dist
							closest = charPos
						end
					end
				end
			end
			
			-- Mover em direção ao jogador
			if closest then
				local direction = (closest.Position - mob.body.Position).Unit
				mob.body.Velocity = direction * 30
			end
		end
	end
end)

print("✅ MobSpawner pronto!")
