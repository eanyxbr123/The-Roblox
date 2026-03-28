-- InventoryClient.client.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")

local ItemDefinitions = require(ReplicatedStorage.Shared.ItemDefinitions)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remotes
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local collectItemRemote = RemotesFolder:WaitForChild("CollectItem")
local itemCollectedEvent = RemotesFolder:WaitForChild("ItemCollected")

-- GUI
local screenGui = playerGui:WaitForChild("InventoryGui")
local inventoryWindow = screenGui:WaitForChild("InventoryWindow")
local inventoryGrid = inventoryWindow:WaitForChild("InventoryGrid")
local titleLabel = inventoryWindow:WaitForChild("Title")

print("✅ GUI carregada")

-- 🧠 Atualizar grid
local function updateInventoryGrid(inv)

	for _, slot in pairs(inventoryGrid:GetChildren()) do
		if slot:IsA("Frame") then
			local img = slot:FindFirstChild("ItemImage")
			local qty = slot:FindFirstChild("Quantity")

			if img then img.Visible = false end
			if qty then qty.Text = "" end
		end
	end

	for i = 1, inv.maxSlots do
		local slotUI = inventoryGrid:FindFirstChild("Slot" .. i)
		local data = inv.slots[i]

		if slotUI and data then
			local img = slotUI:FindFirstChild("ItemImage")
			local qty = slotUI:FindFirstChild("Quantity")

			if img and qty then
				img.Visible = true
				img.Image = "rbxassetid://0"

				if data.quantity > 1 then
					qty.Text = tostring(data.quantity)
				end
			end
		end
	end

	titleLabel.Text = "📦 INVENTORY"
end

-- ⚡ TEMPO REAL
itemCollectedEvent.OnClientEvent:Connect(function(inv)
	updateInventoryGrid(inv)
end)

-- 🎯 COLETA
local function setupItems()

	local function connect(item)
		if item:IsA("Part") then
			local click = item:FindFirstChild("ClickDetector")

			if click then
				click.MouseClick:Connect(function()
					collectItemRemote:InvokeServer(item.Name)
				end)
			end
		end
	end

	workspace.SpawnedItems.ChildAdded:Connect(connect)

	for _, item in pairs(workspace.SpawnedItems:GetChildren()) do
		connect(item)
	end
end

setupItems()

-- 🔘 abrir inventário
local function toggle(_, state)
	if state == Enum.UserInputState.Begin then
		inventoryWindow.Visible = not inventoryWindow.Visible
	end
end

ContextActionService:BindAction("inv", toggle, false, Enum.KeyCode.I)

inventoryWindow.Visible = false

print("✅ InventoryClient pronto (tempo real)")