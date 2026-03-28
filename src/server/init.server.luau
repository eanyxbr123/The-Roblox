-- init.server.luau
-- Servidor principal - carrega todos os sistemas

print("🚀 Iniciando servidor do jogo...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Carregar sistemas do servidor
local serverFolder = ServerScriptService:FindFirstChild("Server")
if serverFolder then
	-- Todos os scripts .server.luau são carregados automaticamente
	-- Os ModuleScript precisam de require
	local inventorySystemModule = serverFolder:FindFirstChild("InventorySystem")
	if inventorySystemModule and inventorySystemModule:IsA("ModuleScript") then
		local InventorySystem = require(inventorySystemModule)
		print("✅ InventorySystem carregado")
	end
end

print("")
print("🎮 === 99 NOITES SURVIVAL ===")
print("✅ Todos os sistemas carregados!")
print("")
print("📋 Sistemas Ativos:")
print("  🌍 WorldManager - Mundo procedural")
print("  ⛏️  BlockInteraction - Mineração")
print("  📦 InventorySystem - Inventário")
print("  🔨 CraftingSystem - Crafting")
print("  📊 PlayerStatsSystem - Stats")
print("  🌙 DayNightSystem - Ciclo dia/noite")
print("  👹 MobSpawner - Mobs dinâmicos")
print("  🔊 SoundSystem - Sistema de som")
print("  🎮 LobbyManager - Lobby e matchmaking")
print("")
