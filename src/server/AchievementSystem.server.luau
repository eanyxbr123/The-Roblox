-- AchievementSystem.server.luau
-- Sistema de conquistas

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

print("🏆 AchievementSystem iniciado...")

-- Remotes
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
end

local GetAchievementsRemote = Instance.new("RemoteFunction")
GetAchievementsRemote.Name = "GetAchievements"
GetAchievementsRemote.Parent = RemotesFolder

local AchievementUnlockedEvent = Instance.new("RemoteEvent")
AchievementUnlockedEvent.Name = "AchievementUnlocked"
AchievementUnlockedEvent.Parent = RemotesFolder

-- Conquistas
local achievements = {
	{id = "survive_10", name = "Dez Noites", description = "Sobreviva 10 noites", icon = "⭐", requirement = 10, type = "nights"},
	{id = "survive_20", name = "Vinte Noites", description = "Sobreviva 20 noites", icon = "⭐⭐", requirement = 20, type = "nights"},
	{id = "survive_70", name = "Setenta Noites", description = "Sobreviva 70 noites", icon = "⭐⭐⭐", requirement = 70, type = "nights"},
	{id = "kill_10_mobs", name = "Caçador", description = "Mate 10 mobs", icon = "🔫", requirement = 10, type = "kills"},
	{id = "craft_5", name = "Artesão", description = "Crie 5 items", icon = "🔨", requirement = 5, type = "crafts"},
	{id = "mine_100", name = "Minerador", description = "Minere 100 blocos", icon = "⛏️", requirement = 100, type = "blocks"},
	{id = "collect_all_classes", name = "Colecionador", description = "Desbloqueie todas as classes", icon = "👮", requirement = 7, type = "classes"},
}

local playerProgress = {}

-- Rastrear progresso
local function updateProgress(player, progressType, value)
	if not playerProgress[player] then
		playerProgress[player] = {}
	end
	
	playerProgress[player][progressType] = (playerProgress[player][progressType] or 0) + value
	
	-- Verificar conquistas
	for _, achievement in pairs(achievements) do
		if achievement.type == progressType then
			if playerProgress[player][progressType] >= achievement.requirement then
				print("🏆 " .. player.Name .. " desbloqueou: " .. achievement.name)
				AchievementUnlockedEvent:FireClient(player, achievement)
			end
		end
	end
end

-- Obter conquistas
GetAchievementsRemote.OnServerInvoke = function(player)
	local playerAchievements = {}
	for _, achievement in pairs(achievements) do
		local progress = playerProgress[player] and playerProgress[player][achievement.type] or 0
		table.insert(playerAchievements, {
			id = achievement.id,
			name = achievement.name,
			icon = achievement.icon,
			progress = progress,
			requirement = achievement.requirement,
			completed = progress >= achievement.requirement,
		})
	end
	return playerAchievements
end

-- Cleanup
Players.PlayerAdded:Connect(function(player)
	playerProgress[player] = {}
end)

Players.PlayerRemoving:Connect(function(player)
	playerProgress[player] = nil
end)

print("✅ AchievementSystem pronto!")
