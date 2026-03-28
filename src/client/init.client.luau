-- init.client.luau
-- Cliente principal

print("🎮 Iniciando cliente do jogo...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Carregar sistemas do cliente
local systems = {
	"InventoryClient",
	"MiningClient",
	"CraftingClient",
	"HUDClient",
	"SoundClient",
	"LobbyClient",
}

for _, systemName in pairs(systems) do
	local systemScript = script:FindFirstChild(systemName)
	if systemScript then
		xpcall(function()
			require(systemScript)
		end, function(err)
			warn("❌ Erro ao carregar " .. systemName .. ": " .. err)
		end)
	end
end

print("")
print("🎮 === 99 NOITES SURVIVAL - CLIENTE ===")
print("✅ Todos os sistemas carregados!")
print("")
print("📋 Controles:")
print("  I - Inventário")
print("  C - Crafting")
print("  Clique esquerdo - Mineração/Ataque")
print("  W/A/S/D - Movimento")
print("  SHIFT - Correr (gera som!)")
print("")
