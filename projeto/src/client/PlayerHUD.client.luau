-- PlayerHUD.client.luau
-- HUD básico de sobrevivência: vida, fome, sede, stamina, sanidade, nível

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local hud = Instance.new("ScreenGui")
hud.Name = "SurvivalHUD"
hud.ResetOnSpawn = false
hud.Parent = playerGui

local function createStatBar(name, color, position)
	local frame = Instance.new("Frame")
	frame.Name = name .. "Bar"
	frame.Size = UDim2.new(0, 220, 0, 26)
	frame.Position = position
	frame.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
	frame.BorderSizePixel = 1
	frame.Parent = hud

	local label = Instance.new("TextLabel")
	label.Name = name .. "Label"
	label.Size = UDim2.new(0, 80, 1, 0)
	label.Position = UDim2.new(0, 4, 0, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 14
	label.Font = Enum.Font.GothamBold
	label.Text = name
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local fill = Instance.new("Frame")
	fill.Name = name .. "Fill"
	fill.Size = UDim2.new(1, -86, 1, -6)
	fill.Position = UDim2.new(0, 82, 0, 3)
	fill.BackgroundColor3 = color
	fill.BorderSizePixel = 0
	fill.Parent = frame

	local value = Instance.new("TextLabel")
	value.Name = name .. "Value"
	value.Size = UDim2.new(1, 0, 1, 0)
	value.Position = UDim2.new(0, 0, 0, 0)
	value.BackgroundTransparency = 1
	value.TextColor3 = Color3.fromRGB(255, 255, 255)
	value.TextSize = 14
	value.Font = Enum.Font.Gotham
	value.Text = "0/100"
	value.Parent = fill

	return {
		frame = frame,
		fill = fill,
		value = value,
	}
end

local bars = {
	Health = createStatBar("Health", Color3.fromRGB(210, 40, 40), UDim2.new(0, 20, 0, 20)),
	Hunger = createStatBar("Hunger", Color3.fromRGB(220, 150, 30), UDim2.new(0, 20, 0, 52)),
	Thirst = createStatBar("Thirst", Color3.fromRGB(60, 170, 230), UDim2.new(0, 20, 0, 84)),
	Stamina = createStatBar("Stamina", Color3.fromRGB(80, 220, 80), UDim2.new(0, 20, 0, 116)),
	Sanity = createStatBar("Sanity", Color3.fromRGB(170, 60, 210), UDim2.new(0, 20, 0, 148)),
}

local levelLabel = Instance.new("TextLabel")
levelLabel.Name = "LevelLabel"
levelLabel.Size = UDim2.new(0, 220, 0, 26)
levelLabel.Position = UDim2.new(0, 20, 0, 190)
levelLabel.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
levelLabel.BorderSizePixel = 1
levelLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
levelLabel.TextSize = 14
levelLabel.Font = Enum.Font.GothamBold
levelLabel.Text = "Level: 1  XP: 0"
levelLabel.TextXAlignment = Enum.TextXAlignment.Left
levelLabel.Parent = hud

local function getStatsFolder()
	local stats = player:FindFirstChild("Stats")
	local timeout = 30
	local elapsed = 0
	while not stats and elapsed < timeout do
		stats = player:FindFirstChild("Stats")
		task.wait(0.1)
		elapsed += 0.1
	end

	if not stats then
		warn("PlayerHUD: Stats folder não encontrado dentro do timeout, criando fallback")
		stats = Instance.new("Folder")
		stats.Name = "Stats"
		stats.Parent = player
		local defaults = {Health = 100, Hunger = 100, Thirst = 100, Stamina = 100, Sanity = 100, Level = 1, XP = 0}
		for k, v in pairs(defaults) do
			local value = Instance.new("IntValue")
			value.Name = k
			value.Value = v
			value.Parent = stats
		end
	end

	return stats
end

local statsFolder = getStatsFolder()

local function updateBar(statName)
	local stat = statsFolder:FindFirstChild(statName)
	if not stat then return end
	local current = stat.Value
	local percent = math.clamp(current / 100, 0, 1)
	local bar = bars[statName]
	if bar then
		bar.fill.Size = UDim2.new(percent, -86, 1, -6)
		bar.value.Text = string.format("%d/100", current)
	end
end

RunService.RenderStepped:Connect(function()
	if not statsFolder.Parent then return end
	updateBar("Health")
	updateBar("Hunger")
	updateBar("Thirst")
	updateBar("Stamina")
	updateBar("Sanity")

	local level = statsFolder:FindFirstChild("Level")
	local xp = statsFolder:FindFirstChild("XP")
	if level and xp then
		levelLabel.Text = string.format("Level: %d  XP: %d", level.Value, xp.Value)
	end
end)

print("📊 Survival HUD loaded")