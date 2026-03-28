-- MultiplayerSystem.server.luau
-- Sincroniza jogadores no mundo

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

print("👥 MultiplayerSystem iniciado...")

-- Remotes
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
end

local PlayerPositionEvent = Instance.new("RemoteEvent")
PlayerPositionEvent.Name = "PlayerPosition"
PlayerPositionEvent.Parent = RemotesFolder

-- Rastrear posições
local playerPositions = {}

-- Atualizar posições a cada frame
RunService.Heartbeat:Connect(function()
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character then
			local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
			if humanoidRootPart then
				playerPositions[player.UserId] = {
					position = humanoidRootPart.Position,
					orientation = humanoidRootPart.Orientation,
				}
			end
		end
	end
	
	-- Notificar todos os clientes
	if math.random() < 0.1 then -- A cada ~10 frames para não sobrecarregar
		for _, player in pairs(Players:GetPlayers()) do
			PlayerPositionEvent:FireClient(player, playerPositions)
		end
	end
end)

print("✅ MultiplayerSystem pronto!")
