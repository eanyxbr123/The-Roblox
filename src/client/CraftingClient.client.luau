-- CraftingClient.client.luau
-- Interface de crafting

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local CraftRecipes = require(ReplicatedStorage.Shared.CraftRecipes)
local ItemDefinitions = require(ReplicatedStorage.Shared.ItemDefinitions)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remotes
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local GetInventoryRemote = RemotesFolder:WaitForChild("GetInventory")
local CraftRemote = RemotesFolder:FindFirstChild("Craft")

if not CraftRemote then
	warn("⚠️  CraftRemote não encontrado")
	return
end

print("🔨 CraftingClient pronto")

-- Criar UI de crafting
local screenGui = playerGui:FindFirstChild("InventoryGui")
if not screenGui then
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "InventoryGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
end

local craftFrame = Instance.new("Frame")
craftFrame.Name = "CraftFrame"
craftFrame.Size = UDim2.new(0, 300, 0.7, 0)
craftFrame.Position = UDim2.new(1, -320, 0, 100)
craftFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
craftFrame.BorderSizePixel = 0
craftFrame.Visible = false
craftFrame.Parent = screenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = craftFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.TextColor3 = Color3.fromRGB(255, 200, 0)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Text = "🔨 CRAFTING"
title.Parent = craftFrame

local listFrame = Instance.new("Frame")
listFrame.Name = "ListFrame"
listFrame.Size = UDim2.new(1, -20, 1, -60)
listFrame.Position = UDim2.new(0, 10, 0, 50)
listFrame.BackgroundTransparency = 1
listFrame.Parent = craftFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = listFrame

-- Atualizar lista de crafting
local function refreshCraftList()
	for _, item in pairs(listFrame:GetChildren()) do
		if item:IsA("Frame") then
			item:Destroy()
		end
	end
	
	local inv = GetInventoryRemote:InvokeServer()
	if not inv then return end
	
	for _, recipe in pairs(CraftRecipes) do
		-- Verificar se tem itens
		local canCraft = true
		for itemId, needed in pairs(recipe.inputs) do
			local count = 0
			for i = 1, inv.maxSlots do
				if inv.slots[i] and inv.slots[i].item == itemId then
					count = count + inv.slots[i].quantity
				end
			end
			if count < needed then
				canCraft = false
				break
			end
		end
		
		-- Criar item de crafting
		local recipeFrame = Instance.new("Frame")
		recipeFrame.Name = recipe.id
		recipeFrame.Size = UDim2.new(1, 0, 0, 50)
		recipeFrame.BackgroundColor3 = canCraft and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(80, 80, 80)
		recipeFrame.BorderSizePixel = 0
		recipeFrame.Parent = listFrame
		
		local recipeName = Instance.new("TextLabel")
		recipeName.Size = UDim2.new(0.6, 0, 1, 0)
		recipeName.BackgroundTransparency = 1
		recipeName.TextColor3 = Color3.fromRGB(255, 255, 255)
		recipeName.TextSize = 12
		recipeName.Font = Enum.Font.Gotham
		recipeName.Text = recipe.name
		recipeName.TextXAlignment = Enum.TextXAlignment.Left
		recipeName.Parent = recipeFrame
		
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(0.4, -5, 1, -5)
		button.Position = UDim2.new(0.6, 5, 0, 2.5)
		button.BackgroundColor3 = Color3.fromRGB(100, 150, 100)
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.TextSize = 12
		button.Font = Enum.Font.GothamBold
		button.Text = canCraft and "CRAFT" or "🔒"
		button.Parent = recipeFrame
		
		if canCraft then
			button.MouseButton1Click:Connect(function()
				local result = CraftRemote:InvokeServer(recipe.id)
				if result.success then
					print("✅ " .. result.message)
					refreshCraftList()
				else
					print("❌ " .. result.message)
				end
			end)
		end
	end
end

-- Abrir/fechar com C
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.C then
		craftFrame.Visible = not craftFrame.Visible
		if craftFrame.Visible then
			refreshCraftList()
			print("✅ Crafting aberto")
		end
	end
end)
