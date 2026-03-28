-- CombatClient.client.luau
-- Cliente para combate

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Remotes
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local AttackRemote = RemotesFolder:FindFirstChild("Attack")
local TakeDamageEvent = RemotesFolder:FindFirstChild("TakeDamage")

print("⚔️ CombatClient pronto")

if not AttackRemote then
	warn("⚠️  AttackRemote não encontrado")
	return
end

-- Combate ao clique
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if mouse.Target then
			local target = mouse.Target
			
			-- Se clicou em um mob
			if target.Parent and target.Parent:FindFirstChild("Humanoid") then
				local mob = target.Parent
				print("⚔️ Atacando mob...")
				
				local result = AttackRemote:InvokeServer("mob", mob)
				if result and result.success then
					print("✅ " .. (result.killed and "Mob morreu!" or "Danificou mob"))
				end
			end
		end
	end
end)

-- Listener para dano recebido
if TakeDamageEvent then
	TakeDamageEvent.OnClientEvent:Connect(function(targetType, target, damage)
		print("💔 Recebeu " .. damage .. " de dano")
	end)
end
