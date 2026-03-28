-- HUDClient.client.luau
-- Mostra HUD com vida, fome, noite, som

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remotes
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local GetStatsRemote = RemotesFolder:FindFirstChild("GetStats")
local StatsChangedEvent = RemotesFolder:FindFirstChild("StatsChanged")
local DayNightChangedEvent = RemotesFolder:FindFirstChild("DayNightChanged")

print("📊 HUDClient pronto")

-- Criar HUD
local screenGui = playerGui:FindFirstChild("InventoryGui")
if not screenGui then
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "InventoryGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
end

-- HUD Container
local hudContainer = Instance.new("Frame")
hudContainer.Name = "HUDContainer"
hudContainer.Size = UDim2.new(0.3, 0, 0.25, 0)
hudContainer.Position = UDim2.new(0, 10, 0, 10)
hudContainer.BackgroundTransparency = 0.2
hudContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
hudContainer.BorderSizePixel = 0
hudContainer.Parent = screenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = hudContainer

-- HUD Labels
local hudLayout = Instance.new("UIListLayout")
hudLayout.Padding = UDim.new(0, 5)
hudLayout.Parent = hudContainer

local healthLabel = Instance.new("TextLabel")
healthLabel.Name = "HealthLabel"
healthLabel.Size = UDim2.new(1, -10, 0, 30)
healthLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
healthLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
healthLabel.TextSize = 12
healthLabel.Font = Enum.Font.Gotham
healthLabel.Text = "❤️ Vida: 100/100"
healthLabel.TextXAlignment = Enum.TextXAlignment.Left
healthLabel.Parent = hudContainer

local hungerLabel = Instance.new("TextLabel")
hungerLabel.Name = "HungerLabel"
hungerLabel.Size = UDim2.new(1, -10, 0, 30)
hungerLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
hungerLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
hungerLabel.TextSize = 12
hungerLabel.Font = Enum.Font.Gotham
hungerLabel.Text = "🍗 Fome: 100/100"
hungerLabel.TextXAlignment = Enum.TextXAlignment.Left
hungerLabel.Parent = hudContainer

local nightLabel = Instance.new("TextLabel")
nightLabel.Name = "NightLabel"
nightLabel.Size = UDim2.new(1, -10, 0, 30)
nightLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
nightLabel.TextColor3 = Color3.fromRGB(150, 150, 255)
nightLabel.TextSize = 12
nightLabel.Font = Enum.Font.Gotham
nightLabel.Text = "🌙 Noite: 0/99"
nightLabel.TextXAlignment = Enum.TextXAlignment.Left
nightLabel.Parent = hudContainer

local soundLabel = Instance.new("TextLabel")
soundLabel.Name = "SoundLabel"
soundLabel.Size = UDim2.new(1, -10, 0, 30)
soundLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
soundLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
soundLabel.TextSize = 12
soundLabel.Font = Enum.Font.Gotham
soundLabel.Text = "🔊 Som: 0"
soundLabel.TextXAlignment = Enum.TextXAlignment.Left
soundLabel.Parent = hudContainer

-- Atualizar HUD
RunService.RenderStepped:Connect(function()
	if GetStatsRemote then
		local stats = GetStatsRemote:InvokeServer()
		if stats then
			healthLabel.Text = string.format("❤️ Vida: %.0f/%.0f", stats.health, stats.maxHealth)
			hungerLabel.Text = string.format("🍗 Fome: %.0f/%.0f", stats.hunger, stats.maxHunger)
			
			-- Mudar cor baseado na vida
			if stats.health < 30 then
				healthLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
			else
				healthLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
			end
		end
	end
end)

-- Listener para mudanças de dia/noite
if DayNightChangedEvent then
	DayNightChangedEvent.OnClientEvent:Connect(function(data)
		nightLabel.Text = string.format("🌙 Noite: %d/%d", data.night, data.maxNights)
		if data.isNight then
			nightLabel.TextColor3 = Color3.fromRGB(100, 100, 200)
		else
			nightLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
		end
	end)
end
