-- LobbyClient.client.luau
-- Cliente do lobby e matchmaking

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remotes
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local EnterGameRemote = RemotesFolder:FindFirstChild("EnterGame")

print("🎮 LobbyClient pronto")

if not EnterGameRemote then
	warn("⚠️  EnterGameRemote não encontrado")
	return
end

-- Criar UI do Lobby
local screenGui = playerGui:FindFirstChild("InventoryGui")
if not screenGui then
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "InventoryGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
end

local lobbyFrame = Instance.new("Frame")
lobbyFrame.Name = "LobbyFrame"
lobbyFrame.Size = UDim2.new(1, 0, 1, 0)
lobbyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
lobbyFrame.BorderSizePixel = 0
lobbyFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 80)
title.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
title.TextColor3 = Color3.fromRGB(255, 200, 0)
title.TextSize = 32
title.Font = Enum.Font.GothamBold
title.Text = "🎮 99 NOITES SURVIVAL"
title.Parent = lobbyFrame

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, 0, 0, 40)
subtitle.Position = UDim2.new(0, 0, 0, 80)
subtitle.BackgroundTransparency = 1
subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
subtitle.TextSize = 16
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "Escolha uma zona e um tamanho de grupo para começar"
subtitle.Parent = lobbyFrame

-- Container de zonas
local zonesContainer = Instance.new("Frame")
zonesContainer.Name = "ZonesContainer"
zonesContainer.Size = UDim2.new(1, 0, 0.6, 0)
zonesContainer.Position = UDim2.new(0, 0, 0, 130)
zonesContainer.BackgroundTransparency = 1
zonesContainer.Parent = lobbyFrame

local zoneLayout = Instance.new("UIGridLayout")
zoneLayout.CellSize = UDim2.new(0.25, -10, 0.5, -10)
zoneLayout.CellPadding = UDim2.new(0, 10, 0, 10)
zoneLayout.FillDirection = Enum.FillDirection.Horizontal
zoneLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
zoneLayout.VerticalAlignment = Enum.VerticalAlignment.Top
zoneLayout.Parent = zonesContainer

-- Criar botões de zonas
for i = 1, 3 do
	local zoneButton = Instance.new("TextButton")
	zoneButton.Name = "Zone" .. i
	zoneButton.BackgroundColor3 = Color3.fromRGB(50, 100, 150)
	zoneButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	zoneButton.TextSize = 20
	zoneButton.Font = Enum.Font.GothamBold
	zoneButton.Text = "🎯 ZONA " .. i
	zoneButton.Parent = zonesContainer
	
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 8)
	UICorner.Parent = zoneButton
	
	-- Sub-frame com opções de grupos
	local groupsFrame = Instance.new("Frame")
	groupsFrame.Name = "GroupsFrame"
	groupsFrame.Size = UDim2.new(1, -20, 0, 150)
	groupsFrame.Position = UDim2.new(0, 10, 0.5, 0)
	groupsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	groupsFrame.BorderSizePixel = 0
	groupsFrame.Visible = false
	groupsFrame.Parent = zoneButton
	
	local groupLayout = Instance.new("UIListLayout")
	groupLayout.Padding = UDim.new(0, 5)
	groupLayout.Parent = groupsFrame
	
	-- Botões de tamanho de grupo
	for groupSize = 1, 5 do
		local groupButton = Instance.new("TextButton")
		groupButton.Size = UDim2.new(1, -10, 0, 25)
		groupButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
		groupButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		groupButton.TextSize = 12
		groupButton.Font = Enum.Font.GothamBold
		groupButton.Text = "Grupo de " .. groupSize
		groupButton.Parent = groupsFrame
		
		groupButton.MouseButton1Click:Connect(function()
			print("🎮 Entrando na Zona " .. i .. " com grupo de " .. groupSize)
			local result = EnterGameRemote:InvokeServer(i, groupSize)
			if result.success then
				print("✅ " .. result.message)
			else
				print("❌ " .. result.message)
			end
		end)
	end
	
	-- Mostrar/esconder opções ao clicar
	zoneButton.MouseButton1Click:Connect(function()
		groupsFrame.Visible = not groupsFrame.Visible
	end)
end

print("✅ Lobby interface criado")
