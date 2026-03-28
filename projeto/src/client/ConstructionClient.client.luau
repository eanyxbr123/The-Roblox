-- ConstructionClient.client.luau
-- Cliente do sistema de construção estilo The Forest

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local BuildStructureRemote = require(ReplicatedStorage.Shared.Remotes.BuildStructure)
local GetAvailableStructuresRemote = require(ReplicatedStorage.Shared.Remotes.GetAvailableStructures)
local ItemDefinitions = require(ReplicatedStorage.Shared.ItemDefinitions)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function createPreviewModel(structure, cframe)
	local model = Instance.new("Model")
	model.Name = "ConstructionPreview"

	local part = Instance.new("Part")
	part.Size = structure.size or Vector3.new(4, 2, 4)
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 0.5
	part.Color = structure.color or Color3.fromRGB(170, 170, 170)
	part.Parent = model

	local mesh = Instance.new("BlockMesh")
	mesh.Parent = part

	model.PrimaryPart = part
	return model
end

local function snapToGrid(position, gridSize)
	gridSize = gridSize or 4
	return Vector3.new(
		math.round(position.X / gridSize) * gridSize,
		math.round(position.Y / gridSize) * gridSize,
		math.round(position.Z / gridSize) * gridSize
	)
end

-- Criar GUI do menu radial
local radialMenu = Instance.new("ScreenGui")
radialMenu.Name = "ConstructionRadialMenu"
radialMenu.ResetOnSpawn = false
radialMenu.Enabled = false
radialMenu.Parent = playerGui

-- Background escuro
local background = Instance.new("Frame")
background.Name = "Background"
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
background.BackgroundTransparency = 0.7
background.Parent = radialMenu

-- Container do menu radial
local radialContainer = Instance.new("Frame")
radialContainer.Name = "RadialContainer"
radialContainer.Size = UDim2.new(0, 400, 0, 400)
radialContainer.Position = UDim2.new(0.5, -200, 0.5, -200)
radialContainer.BackgroundTransparency = 1
radialContainer.Parent = radialMenu

-- Centro do menu
local centerButton = Instance.new("TextButton")
centerButton.Name = "CenterButton"
centerButton.Size = UDim2.new(0, 80, 0, 80)
centerButton.Position = UDim2.new(0.5, -40, 0.5, -40)
centerButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
centerButton.Text = "🏗️"
centerButton.TextSize = 24
centerButton.Parent = radialContainer

local centerCorner = Instance.new("UICorner")
centerCorner.CornerRadius = UDim.new(1, 0)
centerCorner.Parent = centerButton

-- Botões das categorias
local categories = {
	{name = "Culinária", key = "cooking", icon = "🍳", color = Color3.fromRGB(255, 150, 50)},
	{name = "Defesa", key = "defense", icon = "🛡️", color = Color3.fromRGB(150, 50, 50)},
	{name = "Abrigo", key = "shelter", icon = "🏠", color = Color3.fromRGB(100, 150, 255)},
}

local categoryButtons = {}

for i, category in ipairs(categories) do
	local angle = (i - 1) * (360 / #categories) - 90 -- Começar do topo
	local radian = math.rad(angle)
	local distance = 120

	local button = Instance.new("TextButton")
	button.Name = category.name .. "Button"
	button.Size = UDim2.new(0, 60, 0, 60)
	button.Position = UDim2.new(0.5, math.cos(radian) * distance - 30, 0.5, math.sin(radian) * distance - 30)
	button.BackgroundColor3 = category.color
	button.Text = category.icon
	button.TextSize = 20
	button.Parent = radialContainer

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = button

	categoryButtons[category.name] = button
end

-- Menu de itens de construção (inicialmente invisível)
local itemMenu = Instance.new("Frame")
itemMenu.Name = "ItemMenu"
itemMenu.Size = UDim2.new(0, 300, 0, 400)
itemMenu.Position = UDim2.new(0.5, 250, 0.5, -200)
itemMenu.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
itemMenu.BorderSizePixel = 2
itemMenu.Visible = false
itemMenu.Parent = radialMenu

local itemCorner = Instance.new("UICorner")
itemCorner.CornerRadius = UDim.new(0, 8)
itemCorner.Parent = itemMenu

local itemScroll = Instance.new("ScrollingFrame")
itemScroll.Name = "ItemScroll"
itemScroll.Size = UDim2.new(1, -20, 1, -60)
itemScroll.Position = UDim2.new(0, 10, 0, 50)
itemScroll.BackgroundTransparency = 1
itemScroll.ScrollBarThickness = 6
itemScroll.Parent = itemMenu

local itemListLayout = Instance.new("UIListLayout")
itemListLayout.Padding = UDim.new(0, 5)
itemListLayout.Parent = itemScroll

local itemTitle = Instance.new("TextLabel")
itemTitle.Name = "Title"
itemTitle.Size = UDim2.new(1, 0, 0, 40)
itemTitle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
itemTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
itemTitle.TextSize = 16
itemTitle.Font = Enum.Font.GothamBold
itemTitle.Text = "Selecione Item"
itemTitle.Parent = itemMenu

-- Estado do sistema
local isMenuOpen = false
local selectedCategory = nil
local selectedStructure = nil
local previewModel = nil

-- Função para abrir/fechar menu radial
local function toggleRadialMenu()
	isMenuOpen = not isMenuOpen
	radialMenu.Enabled = isMenuOpen

	if not isMenuOpen then
		itemMenu.Visible = false
		selectedCategory = nil
		selectedStructure = nil
		if previewModel then
			previewModel:Destroy()
			previewModel = nil
		end
	end
end

-- Função para mostrar itens de uma categoria
local function showCategoryItems(categoryName, categoryKey)
	selectedCategory = categoryKey
	itemTitle.Text = categoryName

	-- Limpar itens anteriores
	for _, child in pairs(itemScroll:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end

	-- Obter estruturas disponíveis do servidor
	local availableStructures = GetAvailableStructuresRemote:InvokeServer()

	if availableStructures and availableStructures[categoryKey] then
		for _, structure in pairs(availableStructures[categoryKey]) do
			local itemButton = Instance.new("TextButton")
			itemButton.Name = structure.id
			itemButton.Size = UDim2.new(1, 0, 0, 50)
			itemButton.BackgroundColor3 = structure.canBuild and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(80, 80, 80)
			itemButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			itemButton.TextSize = 14
			itemButton.Font = Enum.Font.Gotham
			itemButton.Text = structure.name .. (structure.canBuild and "" or " (recursos insuficientes)")
			itemButton.AutoButtonColor = structure.canBuild
			itemButton.Parent = itemScroll

			local buttonCorner = Instance.new("UICorner")
			buttonCorner.CornerRadius = UDim.new(0, 4)
			buttonCorner.Parent = itemButton

			-- Hover effect
			itemButton.MouseEnter:Connect(function()
				if structure.canBuild then
					itemButton.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
				end
			end)

			itemButton.MouseLeave:Connect(function()
				if structure.canBuild then
					itemButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
				end
			end)

			-- Selecionar item
			itemButton.MouseButton1Click:Connect(function()
				if not structure.canBuild then
					print("❌ Recursos insuficientes para " .. structure.name)
					return
				end

				selectedStructure = structure
				itemMenu.Visible = false
				radialMenu.Enabled = false
				startPlacementMode(structure)
			end)
		end
	else
		local noItemsLabel = Instance.new("TextLabel")
		noItemsLabel.Size = UDim2.new(1, 0, 0, 30)
		noItemsLabel.BackgroundTransparency = 1
		noItemsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
		noItemsLabel.TextSize = 12
		noItemsLabel.Text = "Nenhum item disponível"
		noItemsLabel.Parent = itemScroll
	end

	itemMenu.Visible = true
end

-- Modo de colocação
function startPlacementMode(structure)
	print("🏗️ Placement mode: " .. structure.name)

	-- Criar preview
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		local rootPart = character.HumanoidRootPart

		-- Calcular posição à frente do jogador
		local forward = rootPart.CFrame.LookVector
		local position = rootPart.Position + forward * 5

		-- Criar preview model local simples
		previewModel = createPreviewModel(structure, CFrame.new(position))
		if previewModel then
			previewModel.Parent = workspace
		end
	end

	-- Conectar movimento do mouse para mover preview
	local mouse = player:GetMouse()

	local function updatePreview()
		if previewModel and selectedStructure then
			local character = player.Character
			if character and character:FindFirstChild("HumanoidRootPart") then
				local rootPart = character.HumanoidRootPart
				local forward = rootPart.CFrame.LookVector
				local position = rootPart.Position + forward * 5

			-- Aplicar snap no grid local
			local snapped = snapToGrid(position, 4)
			previewModel:PivotTo(CFrame.new(snapped))
			end
		end
	end

	-- Conectar eventos
	local moveConnection = mouse.Move:Connect(updatePreview)
	local clickConnection = mouse.Button1Down:Connect(function()
		-- Construir estrutura
		if previewModel and selectedStructure then
			local position = previewModel:GetPivot().Position
			local success, message = BuildStructureRemote:InvokeServer(selectedStructure.id, position)

			if success then
				print("✅ Built " .. selectedStructure.name)
			else
				print("❌ Failed to build " .. selectedStructure.name .. " (" .. tostring(message) .. ")")
			end
		end

		-- Limpar
		if previewModel then
			previewModel:Destroy()
			previewModel = nil
		end

		selectedStructure = nil
		moveConnection:Disconnect()
		clickConnection:Disconnect()
	end)

	-- Cancelar com botão direito
	local rightClickConnection = mouse.Button2Down:Connect(function()
		if previewModel then
			previewModel:Destroy()
			previewModel = nil
		end

		selectedStructure = nil
		moveConnection:Disconnect()
		clickConnection:Disconnect()
		rightClickConnection:Disconnect()
	end)
end

-- Conectar botões das categorias
for _, category in ipairs(categories) do
	local button = categoryButtons[category.name]
	if button then
		button.MouseButton1Click:Connect(function()
			showCategoryItems(category.name, category.key)
		end)
	end
end

-- Fechar menu ao clicar no centro
centerButton.MouseButton1Click:Connect(function()
	toggleRadialMenu()
end)

-- Fechar menu ao clicar no background
background.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		toggleRadialMenu()
	end
end)

-- Registrar tecla para abrir menu (B)
ContextActionService:BindAction("ToggleConstructionMenu", function(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		toggleRadialMenu()
	end
	return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.B)

ContextActionService:SetTitle("ToggleConstructionMenu", "Abrir Menu de Construção")
ContextActionService:SetPosition("ToggleConstructionMenu", UDim2.new(0, 0, 0, 0))

print("🏗️ Construction client loaded! Press B to open construction menu")