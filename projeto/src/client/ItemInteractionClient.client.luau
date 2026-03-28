-- ItemInteractionClient.client.luau
-- Sistema de interacao com itens no chao (coletar, arrastar)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Estado do sistema
local hoveredItem = nil
local draggingItem = nil
local dragStartPosition = nil
local dragOffset = Vector3.new(0, 1, 0) -- Offset acima do chao
local isMouseDown = false

-- Configuracao
local RAYCAST_DISTANCE = 100
local MAX_DRAG_DISTANCE = 30 -- Maximo de distancia para arrastar
local HOVER_DISTANCE = 8

-- Criar GUI para prompt de interacao
local PlayerGui = player:WaitForChild("PlayerGui")
local interactionGui = Instance.new("ScreenGui")
interactionGui.Name = "ItemInteractionGui"
interactionGui.ResetOnSpawn = false
interactionGui.Parent = PlayerGui

local promptLabel = Instance.new("TextLabel")
promptLabel.Name = "PromptLabel"
promptLabel.Size = UDim2.new(0, 200, 0, 50)
promptLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
promptLabel.BackgroundTransparency = 0.5
promptLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
promptLabel.TextSize = 14
promptLabel.Font = Enum.Font.Gotham
promptLabel.Visible = false
promptLabel.ZIndex = 100
promptLabel.Parent = interactionGui

local promptCorner = Instance.new("UICorner")
promptCorner.CornerRadius = UDim.new(0, 4)
promptCorner.Parent = promptLabel

-- Criacao de parte visual para preview do arrasto
local dragPreview = nil

-- Funcao para atualizar hover
local function updateHover()
	local camera = workspace.CurrentCamera
	local rayOrigin = camera.CFrame.Position
	local rayDirection = (mouse.Hit.Position - rayOrigin).Unit * RAYCAST_DISTANCE

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
	
	-- Encontrar todos os itens spawnados
	local spawnedItemsFolder = workspace:FindFirstChild("SpawnedItems")
	if spawnedItemsFolder then
		raycastParams.FilterDescendantsInstances = {spawnedItemsFolder}
	end

	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

	-- Limpar hover anterior
	if hoveredItem and hoveredItem ~= (raycastResult and raycastResult.Instance) then
		hoveredItem = nil
		promptLabel.Visible = false
	end

	-- Novo hover
	if raycastResult and raycastResult.Instance:FindFirstChild("ItemId") then
		hoveredItem = raycastResult.Instance
		local itemId = hoveredItem:FindFirstChild("ItemId")
		local amount = hoveredItem:FindFirstChild("Amount")

		if itemId and amount then
			-- Atualizar posicao do prompt
			promptLabel.Position = UDim2.new(0, mouse.X + 10, 0, mouse.Y - 30)
			promptLabel.Text = "[DRAG] " .. itemId.Value .. " x" .. amount.Value
			promptLabel.Visible = true
		end
	end
end

-- Funcao para iniciar arrasto
local function startDrag()
	if not hoveredItem then return end

	draggingItem = hoveredItem
	dragStartPosition = draggingItem.Position
	isMouseDown = true

	print("Iniciado arrasto do item: " .. draggingItem.Name)

	-- Desabilitar fisica durante arrasto
	if draggingItem:FindFirstChild("BodyVelocity") then
		draggingItem:FindFirstChild("BodyVelocity"):Destroy()
	end

	-- Criar preview visual
	if not dragPreview then
		dragPreview = Instance.new("Part")
		dragPreview.Name = "DragPreview"
		dragPreview.Size = draggingItem.Size
		dragPreview.Color = Color3.fromRGB(100, 200, 100)
		dragPreview.Material = Enum.Material.Neon
		dragPreview.CanCollide = false
		dragPreview.Anchored = true
		dragPreview.Transparency = 0.3
		dragPreview.CFrame = draggingItem.CFrame
		dragPreview.Parent = workspace
	end
end

-- Funcao de atualizacao durante arrasto
local function updateDrag()
	if not draggingItem or not isMouseDown then return end

	local camera = workspace.CurrentCamera
	local rayOrigin = camera.CFrame.Position
	local rayDirection = (mouse.Hit.Position - rayOrigin).Unit * RAYCAST_DISTANCE

	-- Fazer raycast no chao para encontrar altura
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {draggingItem}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
	local targetPosition = rayOrigin + rayDirection

	if raycastResult then
		targetPosition = raycastResult.Position + dragOffset
	else
		-- Se nao acertar, usar mouse.Hit
		targetPosition = mouse.Hit.Position + dragOffset
	end

	-- Verificacao de distancia maxima
	local distance = (targetPosition - dragStartPosition).Magnitude
	if distance > MAX_DRAG_DISTANCE then
		local direction = (targetPosition - dragStartPosition).Unit
		targetPosition = dragStartPosition + direction * MAX_DRAG_DISTANCE
	end

	-- Atualizar preview
	if dragPreview then
		dragPreview.CFrame = CFrame.new(targetPosition)
	end

	-- Atualizar item (visualmente no cliente)
	draggingItem.CFrame = CFrame.new(targetPosition)
end

-- Funcao para finalizar arrasto
local function endDrag()
	if not draggingItem then return end

	isMouseDown = false
	local finalPosition = draggingItem.Position

	print("Arrasto finalizado. Item em: " .. tostring(finalPosition))

	-- Enviar para servidor para validacao e coleta
	if draggingItem:FindFirstChild("ItemId") then
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
		local CollectItemRemote = RemotesFolder and RemotesFolder:FindFirstChild("CollectItem")
		local ItemCollectedEvent = RemotesFolder and RemotesFolder:FindFirstChild("ItemCollected")
		
		if CollectItemRemote then
			-- Invocar remota para coletar
			local itemName = draggingItem.Name
			local success = pcall(function()
				local result = CollectItemRemote:InvokeServer(itemName)
			end)
		end
	end

	-- Limpar preview
	if dragPreview then
		dragPreview:Destroy()
		dragPreview = nil
	end

	draggingItem = nil
	promptLabel.Visible = false
end

-- Conectar eventos de mouse
mouse.Button1Down:Connect(function()
	startDrag()
end)

mouse.Button1Up:Connect(function()
	endDrag()
end)

-- Loop de atualizacao
RunService.RenderStepped:Connect(function()
	updateHover()
	if isMouseDown then
		updateDrag()
	end
end)

-- Conectar ao evento ItemCollected do servidor
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if RemotesFolder then
	local ItemCollectedEvent = RemotesFolder:FindFirstChild("ItemCollected")
	if ItemCollectedEvent then
		ItemCollectedEvent.OnClientEvent:Connect(function(itemId, amount)
			-- Chamar AddItem remote para adicionar ao inventario
			local AddItemRemote = RemotesFolder:FindFirstChild("AddItem")
			if AddItemRemote then
				AddItemRemote:InvokeServer(itemId, amount)
				print("Item " .. itemId .. " adicionado ao inventario!")
			end
		end)
	end
end

print("Item Interaction Client loaded! Hover near items and drag to collect")
