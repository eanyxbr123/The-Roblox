-- AchievementClient.client.luau
-- UI de conquistas

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remotes
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local GetAchievementsRemote = RemotesFolder:FindFirstChild("GetAchievements")
local AchievementUnlockedEvent = RemotesFolder:FindFirstChild("AchievementUnlocked")

print("🏆 AchievementClient pronto")

if not GetAchievementsRemote then
	warn("⚠️  GetAchievementsRemote não encontrado")
	return
end

-- Criar UI
local screenGui = playerGui:FindFirstChild("InventoryGui")
if not screenGui then
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "InventoryGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
end

local achievementFrame = Instance.new("Frame")
achievementFrame.Name = "AchievementFrame"
achievementFrame.Size = UDim2.new(0.5, 0, 0.8, 0)
achievementFrame.Position = UDim2.new(0.25, 0, 0.1, 0)
achievementFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
achievementFrame.BorderSizePixel = 0
achievementFrame.Visible = false
achievementFrame.Parent = screenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = achievementFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Text = "🏆 CONQUISTAS"
title.Parent = achievementFrame

local achievementList = Instance.new("ScrollingFrame")
achievementList.Size = UDim2.new(1, -20, 1, -70)
achievementList.Position = UDim2.new(0, 10, 0, 60)
achievementList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
achievementList.BorderSizePixel = 0
achievementList.ScrollBarThickness = 8
achievementList.Parent = achievementFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = achievementList

-- Atualizar conquistas
local function refreshAchievements()
	for _, item in pairs(achievementList:GetChildren()) do
		if item:IsA("Frame") then
			item:Destroy()
		end
	end
	
	local achievements = GetAchievementsRemote:InvokeServer()
	if not achievements then return end
	
	for _, achievement in pairs(achievements) do
		local achFrame = Instance.new("Frame")
		achFrame.Size = UDim2.new(1, -10, 0, 50)
		achFrame.BackgroundColor3 = achievement.completed and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(80, 80, 80)
		achFrame.BorderSizePixel = 0
		achFrame.Parent = achievementList
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextSize = 12
		label.Font = Enum.Font.Gotham
		label.Text = achievement.icon .. " " .. achievement.name .. " (" .. achievement.progress .. "/" .. achievement.requirement .. ")"
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = achFrame
	end
	
	achievementList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end

-- Abrir/fechar com A
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.A then
		achievementFrame.Visible = not achievementFrame.Visible
		if achievementFrame.Visible then
			refreshAchievements()
			print("✅ Conquistas abertas")
		end
	end
end)

-- Notificação ao desbloquear
if AchievementUnlockedEvent then
	AchievementUnlockedEvent.OnClientEvent:Connect(function(achievement)
		print("🏆 Conquistado: " .. achievement.name)
		
		local notif = Instance.new("TextLabel")
		notif.Size = UDim2.new(0, 300, 0, 50)
		notif.Position = UDim2.new(0.5, -150, 0.8, 0)
		notif.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
		notif.TextColor3 = Color3.fromRGB(255, 255, 255)
		notif.TextSize = 14
		notif.Font = Enum.Font.GothamBold
		notif.Text = "🏆 " .. achievement.name
		notif.Parent = screenGui
		
		game:GetService("Debris"):AddItem(notif, 3)
	end)
end
