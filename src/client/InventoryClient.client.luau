-- InventoryClient.client.luau
-- GUI de inventário no cliente

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local ItemDefinitions = require(ReplicatedStorage.Shared.ItemDefinitions)
local CraftRecipes = require(ReplicatedStorage.Shared.CraftRecipes)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Carregar remotes da pasta shared
local CraftRemote = require(ReplicatedStorage.Shared.Remotes.CraftItem)
local GetInventoryRemote = require(ReplicatedStorage.Shared.Remotes.GetInventory)
local AddItemRemote = require(ReplicatedStorage.Shared.Remotes.AddItem)

-- UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InventoryGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

print("📦 ScreenGui criado e parentado ao PlayerGui")

-- Criar janela de inventário
local inventoryWindow = Instance.new("Frame")
inventoryWindow.Name = "InventoryWindow"
inventoryWindow.Size = UDim2.new(0, 400, 0, 500)
inventoryWindow.Position = UDim2.new(0.5, -200, 0.5, -250)
inventoryWindow.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
inventoryWindow.BorderSizePixel = 0
inventoryWindow.Parent = screenGui

print("📦 InventoryWindow criado e parentado ao ScreenGui")

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = inventoryWindow

-- Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "📦 INVENTORY"
titleLabel.Parent = inventoryWindow

-- ScrollFrame para itens
local itemScroll = Instance.new("ScrollingFrame")
itemScroll.Name = "ItemScroll"
itemScroll.Size = UDim2.new(1, -20, 0.6, -50)
itemScroll.Position = UDim2.new(0, 10, 0, 50)
itemScroll.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
itemScroll.BorderSizePixel = 0
itemScroll.ScrollBarThickness = 8
itemScroll.Parent = inventoryWindow

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = itemScroll

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingLeft = UDim.new(0, 5)
UIPadding.PaddingRight = UDim.new(0, 5)
UIPadding.PaddingTop = UDim.new(0, 5)
UIPadding.PaddingBottom = UDim.new(0, 5)
UIPadding.Parent = itemScroll

-- Craft section
local craftLabel = Instance.new("TextLabel")
craftLabel.Name = "CraftLabel"
craftLabel.Size = UDim2.new(1, 0, 0, 30)
craftLabel.Position = UDim2.new(0, 0, 0.6, 0)
craftLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
craftLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
craftLabel.TextSize = 14
craftLabel.Font = Enum.Font.GothamBold
craftLabel.Text = "🔨 CRAFT"
craftLabel.Parent = inventoryWindow

-- ScrollFrame para receitas
local recipeScroll = Instance.new("ScrollingFrame")
recipeScroll.Name = "RecipeScroll"
recipeScroll.Size = UDim2.new(1, -20, 0.35, -40)
recipeScroll.Position = UDim2.new(0, 10, 0.65, 0)
recipeScroll.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
recipeScroll.BorderSizePixel = 0
recipeScroll.ScrollBarThickness = 8
recipeScroll.Parent = inventoryWindow

local recipeListLayout = Instance.new("UIListLayout")
recipeListLayout.Padding = UDim.new(0, 5)
recipeListLayout.Parent = recipeScroll

local recipePadding = Instance.new("UIPadding")
recipePadding.PaddingLeft = UDim.new(0, 5)
recipePadding.PaddingRight = UDim.new(0, 5)
recipePadding.PaddingTop = UDim.new(0, 5)
recipePadding.PaddingBottom = UDim.new(0, 5)
recipePadding.Parent = recipeScroll

-- Função para atualizar inventário
local function updateInventory()
	-- Limpar itens antigos
	for _, child in pairs(itemScroll:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end

	local inv = GetInventoryRemote:InvokeServer()

	-- Mostrar itens
	for slotNum = 1, inv.maxSlots do
		local slot = inv.slots[slotNum]
		if slot then
			local itemDef = ItemDefinitions[slot.item]
			
			local itemFrame = Instance.new("Frame")
			itemFrame.Name = slot.item .. "_" .. slotNum
			itemFrame.Size = UDim2.new(1, 0, 0, 40)
			itemFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			itemFrame.BorderSizePixel = 0
			itemFrame.Parent = itemScroll

			local textLabel = Instance.new("TextLabel")
			textLabel.Size = UDim2.new(0.7, 0, 1, 0)
			textLabel.BackgroundTransparency = 1
			textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			textLabel.TextSize = 12
			textLabel.Font = Enum.Font.Gotham
			textLabel.TextXAlignment = Enum.TextXAlignment.Left
			textLabel.Text = itemDef.name .. " x" .. slot.quantity
			textLabel.Parent = itemFrame
		end
	end

	-- Atualizar receitas
	for _, child in pairs(recipeScroll:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end

	for recipeId, recipe in pairs(CraftRecipes) do
		local canCraft = true
		local inputText = ""

		-- Verificar se pode craftar
		for itemId, needed in pairs(recipe.inputs) do
			local have = 0
			for slotNum = 1, inv.maxSlots do
				if inv.slots[slotNum] and inv.slots[slotNum].item == itemId then
					have += inv.slots[slotNum].quantity
				end
			end
			
			local rarity = have >= needed and "✓" or "✗"
			inputText = inputText .. itemId .. "(" .. have .. "/" .. needed .. ") "
			
			if have < needed then
				canCraft = false
			end
		end

		local recipeFrame = Instance.new("Frame")
		recipeFrame.Name = recipeId
		recipeFrame.Size = UDim2.new(1, 0, 0, 50)
		recipeFrame.BackgroundColor3 = canCraft and Color3.fromRGB(60, 80, 60) or Color3.fromRGB(80, 40, 40)
		recipeFrame.BorderSizePixel = 0
		recipeFrame.Parent = recipeScroll

		local recipeText = Instance.new("TextLabel")
		recipeText.Size = UDim2.new(0.65, 0, 1, 0)
		recipeText.BackgroundTransparency = 1
		recipeText.TextColor3 = Color3.fromRGB(255, 255, 255)
		recipeText.TextSize = 10
		recipeText.Font = Enum.Font.Gotham
		recipeText.TextXAlignment = Enum.TextXAlignment.Left
		recipeText.TextWrapped = true
		recipeText.Text = recipe.name .. "\n" .. inputText
		recipeText.Parent = recipeFrame

		local craftButton = Instance.new("TextButton")
		craftButton.Name = "CraftBtn"
		craftButton.Size = UDim2.new(0.3, -5, 1, 0)
		craftButton.Position = UDim2.new(0.65, 5, 0, 0)
		craftButton.BackgroundColor3 = canCraft and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(100, 100, 100)
		craftButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		craftButton.TextSize = 11
		craftButton.Font = Enum.Font.GothamBold
		craftButton.Text = "CRAFT"
		craftButton.Active = canCraft
		craftButton.Parent = recipeFrame

		craftButton.MouseButton1Click:Connect(function()
			local result = CraftRemote:InvokeServer(recipeId)
			if result.success then
				print("✅ " .. result.message)
				wait(0.5)
				updateInventory()
			else
				print("❌ " .. result.message)
			end
		end)
	end
end

-- Função para alternar inventário
local function toggleInventory(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		print("🎮 Tecla I pressionada via ContextAction! Alternando visibilidade")
		inventoryWindow.Visible = not inventoryWindow.Visible
		print("📦 Inventário visível:", inventoryWindow.Visible)
		if inventoryWindow.Visible then
			updateInventory()
		end
	end
	return Enum.ContextActionResult.Sink -- Bloqueia outras ações
end

-- Registrar ação com prioridade alta
ContextActionService:BindAction("ToggleInventory", toggleInventory, false, Enum.KeyCode.I)
ContextActionService:SetTitle("ToggleInventory", "Abrir/Fechar Inventário")
ContextActionService:SetPosition("ToggleInventory", UDim2.new(0, 0, 0, 0))

-- Inicializar
inventoryWindow.Visible = false
updateInventory()

print("✅ Inventory Client carregado! Pressione I para abrir")
print("📦 Inventário criado:", inventoryWindow and "SIM" or "NÃO")
print("🎮 ContextActionService:", ContextActionService and "SIM" or "NÃO")
