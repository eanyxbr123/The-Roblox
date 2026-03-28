-- MultiplayerClient.client.luau
-- Renderizar outros jogadores

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Remotes
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local PlayerPositionEvent = RemotesFolder:FindFirstChild("PlayerPosition")

print("👥 MultiplayerClient pronto")

if not PlayerPositionEvent then
	warn("⚠️  PlayerPositionEvent não encontrado")
	return
end

-- Rastrear modelos dos outros jogadores
local otherPlayerModels = {}

-- Criar modelo visual para outro jogador
local function createPlayerModel(userId)
	if otherPlayerModels[userId] then return end
	
	local model = Instance.new("Model")
	model.Name = "RemotePlayer_" .. userId
	
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(2, 2, 2)
	head.Color = Color3.fromRGB(255, 200, 150)
	head.Parent = model
	
	local humanoidRootPart = Instance.new("Part")
	humanoidRootPart.Name = "HumanoidRootPart"
	humanoidRootPart.Shape = Enum.PartType.Block
	humanoidRootPart.Size = Vector3.new(2, 5, 2)
	humanoidRootPart.Transparency = 1
	humanoidRootPart.CanCollide = true
	humanoidRootPart.Parent = model
	
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
	bodyVelocity.Parent = humanoidRootPart
	
	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = 100
	humanoid.Health = 100
	humanoid.Parent = model
	
	model.Parent = workspace
	
	otherPlayerModels[userId] = {
		model = model,
		humanoidRootPart = humanoidRootPart,
		bodyVelocity = bodyVelocity,
		head = head,
	}
	
	print("✅ Modelo criado para jogador " .. userId)
end

-- Atualizar posições
if PlayerPositionEvent then
	PlayerPositionEvent.OnClientEvent:Connect(function(playerPositions)
		for userId, pos in pairs(playerPositions) do
			if userId ~= player.UserId then
				if not otherPlayerModels[userId] then
					createPlayerModel(userId)
				end
				
				local model = otherPlayerModels[userId]
				if model and model.humanoidRootPart then
					model.humanoidRootPart.Position = pos.position
					model.humanoidRootPart.Orientation = pos.orientation
				end
			end
		end
	end)
end

-- Cleanup ao sair
Players.PlayerRemoving:Connect(function(p)
	if otherPlayerModels[p.UserId] then
		otherPlayerModels[p.UserId].model:Destroy()
		otherPlayerModels[p.UserId] = nil
	end
end)
