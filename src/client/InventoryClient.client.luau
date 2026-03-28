-- InventoryClient.client.luau
-- Inventário simples sem drag-drop visual

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

local ItemDefinitions = require(ReplicatedStorage.Shared.ItemDefinitions)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remotes
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local GetInventoryRemote = RemotesFolder:WaitForChild("GetInventory")
local ItemCollectedEvent = RemotesFolder:FindFirstChild("ItemCollected")

if not ItemCollectedEvent then
	warn("⚠️  ItemCollectedEvent não encontrado")
end

-- Criar GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InventoryGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "InventoryFrame"
frame.Size = UDim2.new(0, 400, 0, 300)
frame.Position = UDim2.new(0.5, -200, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = screenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.TextColor3 = Color3.fromRGB(255, 200, 0)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Text = "📦 INVENTÁRIO"
title.Parent = frame

local listFrame = Instance.new("Frame")
listFrame.Name = "ListFrame"
listFrame.Size = UDim2.new(1, -20, 1, -60)
listFrame.Position = UDim2.new(0, 10, 0, 50)
listFrame.BackgroundTransparency = 1
listFrame.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = listFrame

-- Estado
local currentInv = nil
local selectedSlot = nil

-- Refresh UI
local function refreshUI()
	if not currentInv then return end
	
	-- Limpar items antigos
	for _, item in pairs(listFrame:GetChildren()) do
		if item:IsA("Frame") then
			item:Destroy()
		end
	end
	
	-- Mostrar itens
	for i = 1, currentInv.maxSlots do
		local data = currentInv.slots[i]
		if data then
			local itemFrame = Instance.new("Frame")
			itemFrame.Name = "Item_" .. i
			itemFrame.Size = UDim2.new(1, 0, 0, 30)
			itemFrame.BackgroundColor3 = selectedSlot == i and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(50, 50, 50)
			itemFrame.BorderSizePixel = 0
			itemFrame.Parent = listFrame
			
			local itemName = Instance.new("TextLabel")
			itemName.Size = UDim2.new(0.5, 0, 1, 0)
			itemName.BackgroundTransparency = 1
			itemName.TextColor3 = Color3.fromRGB(255, 255, 255)
			itemName.TextSize = 14
			itemName.Font = Enum.Font.Gotham
			itemName.Text = ItemDefinitions[data.item].name .. " x" .. data.quantity
			itemName.TextXAlignment = Enum.TextXAlignment.Left
			itemName.Parent = itemFrame
			
			local button = Instance.new("TextButton")
			button.Size = UDim2.new(0.5, 0, 1, 0)
			button.Position = UDim2.new(0.5, 0, 0, 0)
			button.BackgroundTransparency = 1
			button.TextColor3 = Color3.fromRGB(100, 200, 100)
			button.TextSize = 12
			button.Font = Enum.Font.GothamBold
			button.Text = "Usar"
			button.Parent = itemFrame
			
			button.MouseButton1Click:Connect(function()
				print("🎯 Clicou em: " .. ItemDefinitions[data.item].name)
				selectedSlot = i
				refreshUI()
			end)
		end
	end
	
	-- Atualizar peso
	title.Text = string.format("📦 INVENTÁRIO | %.1f/%.1f kg", currentInv.totalWeight, currentInv.maxWeight)
end

-- Listener para quando item é coletado
if ItemCollectedEvent then
	ItemCollectedEvent.OnClientEvent:Connect(function(itemId, quantity)
		print("🎁 Item coletado: " .. itemId .. " x" .. quantity)
		
		-- Atualizar inventário
		currentInv = GetInventoryRemote:InvokeServer()
		if frame.Visible then
			refreshUI()
		end
		
		-- Mostrar notificação
		local notif = Instance.new("TextLabel")
		notif.Size = UDim2.new(0, 300, 0, 40)
		notif.Position = UDim2.new(0.5, -150, 0, 20)
		notif.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
		notif.TextColor3 = Color3.fromRGB(255, 255, 255)
		notif.TextSize = 14
		notif.Font = Enum.Font.GothamBold
		notif.Text = "✅ " .. itemId .. " x" .. quantity
		notif.Parent = screenGui
		
		game:GetService("Debris"):AddItem(notif, 2)
	end)
end

-- Abrir/fechar com I
local function toggle(_, state)
	if state == Enum.UserInputState.Begin then
		frame.Visible = not frame.Visible
		if frame.Visible then
			currentInv = GetInventoryRemote:InvokeServer()
			selectedSlot = nil
			refreshUI()
			print("✅ Inventário aberto")
		else
			print("❌ Inventário fechado")
		end
	end
end

ContextActionService:BindAction("inv_toggle", toggle, false, Enum.KeyCode.I)

print("✅ InventoryClient pronto")
