-- ArmorClient.client.luau
-- UI de armaduras

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remotes
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local GetArmorRemote = RemotesFolder:FindFirstChild("GetArmor")
local EquipArmorRemote = RemotesFolder:FindFirstChild("EquipArmor")

-- Modules
local ArmorDefinitions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ArmorDefinitions"))

print("🛡️ ArmorClient pronto")

if not GetArmorRemote then
	warn("⚠️  GetArmorRemote não encontrado")
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

local armorFrame = Instance.new("Frame")
armorFrame.Name = "ArmorFrame"
armorFrame.Size = UDim2.new(0.4, 0, 0.6, 0)
armorFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
armorFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
armorFrame.BorderSizePixel = 0
armorFrame.Visible = false
armorFrame.Parent = screenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = armorFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.TextColor3 = Color3.fromRGB(200, 100, 200)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Text = "🛡️ ARMADURAS"
title.Parent = armorFrame

local equippedLabel = Instance.new("TextLabel")
equippedLabel.Size = UDim2.new(1, 0, 0, 40)
equippedLabel.Position = UDim2.new(0, 0, 0, 50)
equippedLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
equippedLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
equippedLabel.TextSize = 12
equippedLabel.Font = Enum.Font.Gotham
equippedLabel.Text = "Equipado: Nenhum"
equippedLabel.Parent = armorFrame

local armorList = Instance.new("ScrollingFrame")
armorList.Size = UDim2.new(1, -20, 1, -120)
armorList.Position = UDim2.new(0, 10, 0, 100)
armorList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
armorList.BorderSizePixel = 0
armorList.ScrollBarThickness = 8
armorList.Parent = armorFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = armorList

-- Atualizar UI
local function refreshArmor()
	-- Limpar lista
	for _, item in pairs(armorList:GetChildren()) do
		if item:IsA("TextButton") then
			item:Destroy()
		end
	end
	
	-- Equipado
	local equipped = GetArmorRemote:InvokeServer()
	if equipped then
		equippedLabel.Text = "Equipado: " .. equipped.icon .. " " .. equipped.name .. " (DEF+" .. equipped.defense .. ")"
	else
		equippedLabel.Text = "Equipado: Nenhum"
	end
	
	-- Lista de armaduras
	for armorId, armor in pairs(ArmorDefinitions) do
		local armorBtn = Instance.new("TextButton")
		armorBtn.Size = UDim2.new(1, -10, 0, 60)
		armorBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
		armorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		armorBtn.TextSize = 12
		armorBtn.Font = Enum.Font.Gotham
		armorBtn.Text = armor.icon .. " " .. armor.name .. " (DEF+" .. armor.defense .. ") | 💰" .. armor.price.money .. " 💎" .. armor.price.crystals
		armorBtn.Parent = armorList
		
		armorBtn.MouseButton1Click:Connect(function()
			local result = EquipArmorRemote:InvokeServer(armorId)
			if result and result.success then
				print("✅ " .. result.message)
				refreshArmor()
			end
		end)
	end
	
	armorList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end

-- Abrir com E (se não ocupado)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.E then
		armorFrame.Visible = not armorFrame.Visible
		if armorFrame.Visible then
			refreshArmor()
			print("✅ Armaduras abertas")
		end
	end
end)
