-- PlayerStatsSystem.server.luau
-- Gerencia stats dos jogadores

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PlayerStatsModule = require(ReplicatedStorage.Shared.PlayerStats)

print("📊 PlayerStatsSystem iniciado...")

local playerStats = {}

-- Remotes
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
end

local GetStatsRemote = Instance.new("RemoteFunction")
GetStatsRemote.Name = "GetStats"
GetStatsRemote.Parent = RemotesFolder

local StatsChangedEvent = Instance.new("RemoteEvent")
StatsChangedEvent.Name = "StatsChanged"
StatsChangedEvent.Parent = RemotesFolder

-- Inicializar stats
local function initPlayerStats(player)
	if not playerStats[player] then
		playerStats[player] = PlayerStatsModule.new()
		print("📊 Stats iniciado para " .. player.Name)
	end
end

-- Obter stats
GetStatsRemote.OnServerInvoke = function(player)
	if not playerStats[player] then
		initPlayerStats(player)
	end
	return playerStats[player]
end

-- Atualizar fome e vida periodicamente
RunService.Heartbeat:Connect(function()
	for player, stats in pairs(playerStats) do
		if player.Parent then
			-- Diminui fome a cada segundo
			stats.hunger = stats.hunger - 0.1
			if stats.hunger < 0 then stats.hunger = 0 end
			
			-- Se fome = 0, perde vida
			if stats.hunger == 0 then
				stats:takeDamage(0.1)
			end
			
			-- Se vida = 0, jogador morre
			if stats.health <= 0 then
				print("💀 " .. player.Name .. " morreu")
				-- TODO: Respawnar no lobby
			end
			
			-- Notificar cliente
			if math.random() < 0.1 then -- A cada ~10 frames
				StatsChangedEvent:FireClient(player, stats)
			end
		end
	end
end)

-- Cleanup
Players.PlayerAdded:Connect(initPlayerStats)
Players.PlayerRemoving:Connect(function(player)
	playerStats[player] = nil
end)

print("✅ PlayerStatsSystem pronto!")
