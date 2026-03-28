-- CreateInventoryGui.server.luau
-- Criar GUI do inventário no StarterGui

local StarterGui = game:GetService("StarterGui")

-- Criar ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InventoryGui"
screenGui.ResetOnSpawn = false

-- Criar InventoryWindow
local inventoryWindow = Instance.new("Frame")
inventoryWindow.Name = "InventoryWindow"
inventoryWindow.Size = UDim2.new(0, 600, 0, 500)
inventoryWindow.Position = UDim2.new(0.5, -300, 0.5, -250)
inventoryWindow.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
inventoryWindow.BorderSizePixel = 0
inventoryWindow.Visible = false
inventoryWindow.Parent = screenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = inventoryWindow

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "📦 INVENTORY"
titleLabel.Parent = inventoryWindow

-- Inventário em grid (lado esquerdo)
local inventoryGrid = Instance.new("Frame")
inventoryGrid.Name = "InventoryGrid"
inventoryGrid.Size = UDim2.new(0.6, -10, 0.7, -50)
inventoryGrid.Position = UDim2.new(0, 10, 0, 50)
inventoryGrid.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
inventoryGrid.BorderSizePixel = 0
inventoryGrid.Parent = inventoryWindow

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 50, 0, 50)
gridLayout.CellPadding = UDim2.new(0, 2, 0, 2)
gridLayout.FillDirection = Enum.FillDirection.Horizontal
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
gridLayout.Parent = inventoryGrid

-- Criar slots do inventário (serão preenchidos dinamicamente)
for i = 1, 45 do -- Máximo para level 5 (9x5)
	local slot = Instance.new("Frame")
	slot.Name = "Slot" .. i
	slot.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	slot.BorderSizePixel = 1
	slot.BorderColor3 = Color3.fromRGB(80, 80, 80)
	slot.Parent = inventoryGrid

	local slotCorner = Instance.new("UICorner")
	slotCorner.CornerRadius = UDim.new(0, 4)
	slotCorner.Parent = slot

	local itemImage = Instance.new("ImageLabel")
	itemImage.Name = "ItemImage"
	itemImage.Size = UDim2.new(0.8, 0, 0.8, 0)
	itemImage.Position = UDim2.new(0.1, 0, 0.1, 0)
	itemImage.BackgroundTransparency = 1
	itemImage.Visible = false
	itemImage.Parent = slot

	local quantityLabel = Instance.new("TextLabel")
	quantityLabel.Name = "Quantity"
	quantityLabel.Size = UDim2.new(0.3, 0, 0.3, 0)
	quantityLabel.Position = UDim2.new(0.7, -2, 0.7, -2)
	quantityLabel.BackgroundTransparency = 1
	quantityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	quantityLabel.TextSize = 10
	quantityLabel.Font = Enum.Font.GothamBold
	quantityLabel.TextXAlignment = Enum.TextXAlignment.Right
	quantityLabel.Text = ""
	quantityLabel.Parent = slot
end

-- Crafting area (lado direito)
local craftingArea = Instance.new("Frame")
craftingArea.Name = "CraftingArea"
craftingArea.Size = UDim2.new(0.35, -10, 0.7, -50)
craftingArea.Position = UDim2.new(0.65, 0, 0, 50)
craftingArea.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
craftingArea.BorderSizePixel = 0
craftingArea.Parent = inventoryWindow

local craftingTitle = Instance.new("TextLabel")
craftingTitle.Name = "CraftingTitle"
craftingTitle.Size = UDim2.new(1, 0, 0, 25)
craftingTitle.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
craftingTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
craftingTitle.TextSize = 14
craftingTitle.Font = Enum.Font.GothamBold
craftingTitle.Text = "🔨 CRAFTING"
craftingTitle.Parent = craftingArea

-- Crafting grid 3x3
local craftingGrid = Instance.new("Frame")
craftingGrid.Name = "CraftingGrid"
craftingGrid.Size = UDim2.new(0.8, 0, 0.6, 0)
craftingGrid.Position = UDim2.new(0.1, 0, 0.15, 0)
craftingGrid.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
craftingGrid.BorderSizePixel = 0
craftingGrid.Parent = craftingArea

local craftGridLayout = Instance.new("UIGridLayout")
craftGridLayout.CellSize = UDim2.new(0, 40, 0, 40)
craftGridLayout.CellPadding = UDim2.new(0, 1, 0, 1)
craftGridLayout.FillDirection = Enum.FillDirection.Horizontal
craftGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
craftGridLayout.VerticalAlignment = Enum.VerticalAlignment.Center
craftGridLayout.Parent = craftingGrid

-- Criar slots de crafting 3x3
for row = 1, 3 do
	for col = 1, 3 do
		local craftSlot = Instance.new("Frame")
		craftSlot.Name = "CraftSlot_" .. row .. "_" .. col
		craftSlot.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		craftSlot.BorderSizePixel = 1
		craftSlot.BorderColor3 = Color3.fromRGB(80, 80, 80)
		craftSlot.Parent = craftingGrid

		local slotCorner = Instance.new("UICorner")
		slotCorner.CornerRadius = UDim.new(0, 2)
		slotCorner.Parent = craftSlot

		local craftItemImage = Instance.new("ImageLabel")
		craftItemImage.Name = "ItemImage"
		craftItemImage.Size = UDim2.new(0.8, 0, 0.8, 0)
		craftItemImage.Position = UDim2.new(0.1, 0, 0.1, 0)
		craftItemImage.BackgroundTransparency = 1
		craftItemImage.Visible = false
		craftItemImage.Parent = craftSlot
	end
end

-- Result slot
local resultSlot = Instance.new("Frame")
resultSlot.Name = "ResultSlot"
resultSlot.Size = UDim2.new(0, 50, 0, 50)
resultSlot.Position = UDim2.new(0.5, -25, 0.8, 0)
resultSlot.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
resultSlot.BorderSizePixel = 2
resultSlot.BorderColor3 = Color3.fromRGB(100, 150, 255)
resultSlot.Parent = craftingArea

local resultCorner = Instance.new("UICorner")
resultCorner.CornerRadius = UDim.new(0, 4)
resultCorner.Parent = resultSlot

local resultImage = Instance.new("ImageLabel")
resultImage.Name = "ResultImage"
resultImage.Size = UDim2.new(0.8, 0, 0.8, 0)
resultImage.Position = UDim2.new(0.1, 0, 0.1, 0)
resultImage.BackgroundTransparency = 1
resultImage.Visible = false
resultImage.Parent = resultSlot

local resultQuantity = Instance.new("TextLabel")
resultQuantity.Name = "ResultQuantity"
resultQuantity.Size = UDim2.new(0.3, 0, 0.3, 0)
resultQuantity.Position = UDim2.new(0.7, -2, 0.7, -2)
resultQuantity.BackgroundTransparency = 1
resultQuantity.TextColor3 = Color3.fromRGB(255, 255, 255)
resultQuantity.TextSize = 10
resultQuantity.Font = Enum.Font.GothamBold
resultQuantity.TextXAlignment = Enum.TextXAlignment.Right
resultQuantity.Text = ""
resultQuantity.Parent = resultSlot

-- Craft button
local craftButton = Instance.new("TextButton")
craftButton.Name = "CraftButton"
craftButton.Size = UDim2.new(0.8, 0, 0, 30)
craftButton.Position = UDim2.new(0.1, 0, 0.9, 0)
craftButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
craftButton.TextColor3 = Color3.fromRGB(255, 255, 255)
craftButton.TextSize = 12
craftButton.Font = Enum.Font.GothamBold
craftButton.Text = "CRAFT"
craftButton.Parent = craftingArea

local craftCorner = Instance.new("UICorner")
craftCorner.CornerRadius = UDim.new(0, 4)
craftCorner.Parent = craftButton

-- Parent no StarterGui
screenGui.Parent = StarterGui

print("✅ GUI do inventário criada no StarterGui com grid e crafting visual")