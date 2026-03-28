-- PlayerStats.server.luau
-- Gerencia estatísticas de sobrevivência ... vida, fome, sede, stamina, sanidade e nível.

local Players = game:GetService("Players")

local function createValue(parent, name, value)
	local v = Instance.new("NumberValue")
	v.Name = name
	v.Value = value
	v.Parent = parent
	return v
end

local function initializePlayer(player)
	local statsFolder = Instance.new("Folder")
	statsFolder.Name = "Stats"
	statsFolder.Parent = player

	createValue(statsFolder, "Health", 100)
	createValue(statsFolder, "Hunger", 100)
	createValue(statsFolder, "Thirst", 100)
	createValue(statsFolder, "Stamina", 100)
	createValue(statsFolder, "Sanity", 100)
	createValue(statsFolder, "Level", 1)
	createValue(statsFolder, "XP", 0)

	-- Metodo util para aplicar dano
	player:GetAttributeChangedSignal("Health"):Connect(function()
		-- talvez sincronização futura
	end)
end

local function onPlayerAdded(player)
	initializePlayer(player)

	local hunger = player.Stats:WaitForChild("Hunger")
	local thirst = player.Stats:WaitForChild("Thirst")
	local health = player.Stats:WaitForChild("Health")
	local stamina = player.Stats:WaitForChild("Stamina")
	local sanity = player.Stats:WaitForChild("Sanity")

	-- Cada 10s: if fome/sede <=0 perde saúde
	spawn(function()
		while player.Parent do
			wait(10)
			if hunger.Value > 0 then hunger.Value = math.max(0, hunger.Value - 2) end
			if thirst.Value > 0 then thirst.Value = math.max(0, thirst.Value - 3) end
			if hunger.Value <= 0 or thirst.Value <= 0 then
				health.Value = math.max(0, health.Value - 5)
			end
			if stamina.Value < 100 then stamina.Value = math.min(100, stamina.Value + 1) end
			if sanity.Value > 0 then sanity.Value = math.max(0, sanity.Value - 1) end
			if health.Value <= 0 then
				print("[PlayerStats] "..player.Name.." morreu de exaustão")
				local character = player.Character
				if character then
					local humanoid = character:FindFirstChildOfClass("Humanoid")
					if humanoid then humanoid.Health = 0 end
				end
				break
			end
		end
	end)
end

local function init()
	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in ipairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end
end

return {
	init = init,
}