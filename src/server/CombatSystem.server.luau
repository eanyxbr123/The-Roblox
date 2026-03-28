-- CombatSystem.server.luau
-- Sistema de combate e dano

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

print("⚔️ CombatSystem iniciado...")

-- Remotes
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
end

local AttackRemote = Instance.new("RemoteFunction")
AttackRemote.Name = "Attack"
AttackRemote.Parent = RemotesFolder

local TakeDamageEvent = Instance.new("RemoteEvent")
TakeDamageEvent.Name = "TakeDamage"
TakeDamageEvent.Parent = RemotesFolder

-- Carregar sistemas
local serverFolder = game:GetService("ServerScriptService"):FindFirstChild("Server")
local PlayerStatsModule = require(ReplicatedStorage.Shared.PlayerStats)
local playerStats = {}

-- Inicializar stats
local function getPlayerStats(player)
	if not playerStats[player] then
		playerStats[player] = PlayerStatsModule.new()
	end
	return playerStats[player]
end

-- Sistema de ataque
AttackRemote.OnServerInvoke = function(player, targetType, target)
	if not player.Character then return {success = false} end
	
	local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return {success = false} end
	
	local stats = getPlayerStats(player)
	local damage = 10 -- Dano padrão
	
	-- Se tem espada/machado equipado, aumenta dano
	if stats.currentWeapon then
		if stats.currentWeapon:match("pickaxe") then
			damage = 15
		elseif stats.currentWeapon:match("axe") then
			damage = 18
		elseif stats.currentWeapon == "sword" then
			damage = 20
		elseif stats.currentWeapon == "pistol" then
			damage = 25
		end
	end
	
	-- Ataque em mob
	if targetType == "mob" and target then
		if target:IsDescendantOf(workspace) and target:FindFirstChild("Humanoid") then
			local mobHumanoid = target:FindFirstChild("Humanoid")
			local dist = (humanoidRootPart.Position - target.Position).Magnitude
			
			if dist < 50 then
				mobHumanoid.Health = math.max(0, mobHumanoid.Health - damage)
				print("⚔️ " .. player.Name .. " atacou mob por " .. damage .. " de dano")
				TakeDamageEvent:FireClient(player, "mob", target, damage)
				
				if mobHumanoid.Health <= 0 then
					print("💀 Mob morreu")
					stats.money = stats.money + 50
					return {success = true, killed = true, reward = 50}
				end
				return {success = true}
			end
		end
	end
	
	-- Ataque em jogador
	if targetType == "player" and target then
		local targetPlayer = Players:GetPlayerFromCharacter(target.Parent)
		if targetPlayer then
			local targetStats = getPlayerStats(targetPlayer)
			local finalDamage = targetStats:takeDamage(damage, 1)
			print("⚔️ " .. player.Name .. " atacou " .. targetPlayer.Name)
			
			if finalDamage <= 0 then
				print("💀 " .. targetPlayer.Name .. " morreu")
				return {success = true, killed = true}
			end
			return {success = true}
		end
	end
	
	return {success = false, message = "Alvo inválido"}
end

-- Evento de ganho de XP ao matar
Players.PlayerAdded:Connect(function(player)
	playerStats[player] = PlayerStatsModule.new()
end)

Players.PlayerRemoving:Connect(function(player)
	playerStats[player] = nil
end)

print("✅ CombatSystem pronto!")
