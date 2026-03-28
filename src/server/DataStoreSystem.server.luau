-- DataStoreSystem.server.luau
-- Salvar e carregar dados dos jogadores

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

print("💾 DataStoreSystem iniciado...")

-- Criar DataStore
local playerDataStore = DataStoreService:GetDataStore("PlayerData")

-- Estrutura padrão
local defaultPlayerData = {
	nightsSurvived = 0,
	money = 1000,
	crystals = 50,
	unlockedClasses = {police = true},
	stats = {
		totalKills = 0,
		totalBlocksMined = 0,
		totalItemsCrafted = 0,
	},
}

-- Salvar dados
local function savePlayerData(player)
	local userId = player.UserId
	
	-- TODO: Coletar dados do jogador
	local playerData = defaultPlayerData
	
	xpcall(function()
		playerDataStore:SetAsync("Player_" .. userId, playerData)
		print("💾 Dados salvos para " .. player.Name)
	end, function(err)
		warn("❌ Erro ao salvar dados: " .. err)
	end)
end

-- Carregar dados
local function loadPlayerData(player)
	local userId = player.UserId
	
	xpcall(function()
		local data = playerDataStore:GetAsync("Player_" .. userId)
		if data then
			print("✅ Dados carregados para " .. player.Name)
			return data
		else
			print("📝 Novos dados para " .. player.Name)
			return defaultPlayerData
		end
	end, function(err)
		warn("❌ Erro ao carregar dados: " .. err)
		return defaultPlayerData
	end)
end

-- Auto-save a cada 5 minutos
Players.PlayerAdded:Connect(function(player)
	spawn(function()
		while player.Parent do
			wait(300)
			savePlayerData(player)
		end
	end)
end)

-- Salvar ao sair
Players.PlayerRemoving:Connect(function(player)
	savePlayerData(player)
end)

print("✅ DataStoreSystem pronto!")
