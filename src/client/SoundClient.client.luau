-- SoundClient.client.luau
-- Gera som ao andar, correr, etc

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Remotes
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local ReportSoundRemote = RemotesFolder:FindFirstChild("ReportSound")

print("🔊 SoundClient pronto")

if not ReportSoundRemote then
	warn("⚠️  ReportSoundRemote não encontrado")
	return
end

-- Estado
local currentSoundLevel = 0
local isRunning = false
local lastReportTime = 0

-- Detectar movimento
local keysPressed = {}
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.A or
	   input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.D then
		keysPressed[input.KeyCode] = true
	end
	
	-- Correr com SHIFT
	if input.KeyCode == Enum.KeyCode.LeftShift then
		isRunning = true
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.A or
	   input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.D then
		keysPressed[input.KeyCode] = false
	end
	
	if input.KeyCode == Enum.KeyCode.LeftShift then
		isRunning = false
	end
end)

-- Loop de som
RunService.Heartbeat:Connect(function()
	-- Calcular som baseado em movimento
	local soundLevel = 0
	
	-- Verificar se está movendo
	local isMoving = false
	for _, pressed in pairs(keysPressed) do
		if pressed then
			isMoving = true
			break
		end
	end
	
	if isMoving then
		if isRunning then
			soundLevel = 70  -- Correr = bem barulhento
		else
			soundLevel = 30  -- Andar = pouco barulho
		end
	end
	
	currentSoundLevel = soundLevel
	
	-- Reportar ao servidor a cada 0.5 segundos
	if tick() - lastReportTime > 0.5 and soundLevel > 0 then
		lastReportTime = tick()
		
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if humanoidRootPart then
			pcall(function()
				ReportSoundRemote:InvokeServer(soundLevel, humanoidRootPart.Position)
			end)
		end
	end
end)
