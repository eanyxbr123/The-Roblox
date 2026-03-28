-- ShopClient.client.luau
-- UI da loja

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remotes
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local GetShopRemote = RemotesFolder:FindFirstChild("GetShop")
local BuyItemRemote = RemotesFolder:FindFirstChild("BuyItem")

print("🛍️ ShopClient pronto")

if not GetShopRemote then
	warn("⚠️  GetShopRemote não encontrado")
	return
end

-- Criar UI da loja
local screenGui = playerGui:FindFirstChild("InventoryGui")
if not screenGui then
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "InventoryGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
end

local shopFrame = Instance.new("Frame")
shopFrame.Name = "ShopFrame"
shopFrame.Size = UDim2.new(0.4, 0, 0.8, 0)
shopFrame.Position = UDim2.new(0.3, 0, 0.1, 0)
shopFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
shopFrame.BorderSizePixel = 0
shopFrame.Visible = false
shopFrame.Parent = screenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = shopFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.TextColor3 = Color3.fromRGB(255, 200, 100)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Text = "🛍️ LOJA"
title.Parent = shopFrame

local shopList = Instance.new("ScrollingFrame")
shopList.Size = UDim2.new(1, -20, 1, -70)
shopList.Position = UDim2.new(0, 10, 0, 60)
shopList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
shopList.BorderSizePixel = 0
shopList.ScrollBarThickness = 8
shopList.Parent = shopFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = shopList

-- Atualizar loja
local function refreshShop()
	for _, item in pairs(shopList:GetChildren()) do
		if item:IsA("Frame") then
			item:Destroy()
		end
	end
	
	local shopItems = GetShopRemote:InvokeServer()
	if not shopItems then return end
	
	for _, item in pairs(shopItems) do
		local itemFrame = Instance.new("TextButton")
		itemFrame.Name = item.id
		itemFrame.Size = UDim2.new(1, -10, 0, 60)
		itemFrame.BackgroundColor3 = item.available and Color3.fromRGB(50, 80, 120) or Color3.fromRGB(80, 80, 80)
		itemFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
		itemFrame.TextSize = 12
		itemFrame.Font = Enum.Font.GothamBold
		itemFrame.Text = (item.available and "✅ " or "❌ ") .. item.name .. " | 💰" .. item.price.money .. " 💎" .. item.price.crystals
		itemFrame.Parent = shopList
		
		if item.available then
			itemFrame.MouseButton1Click:Connect(function()
				local result = BuyItemRemote:InvokeServer(item.id)
				if result and result.success then
					print("✅ " .. result.message)
					refreshShop()
				else
					print("❌ " .. (result and result.message or "Erro"))
				end
			end)
		end
	end
	
	shopList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end

-- Abrir/fechar com S
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.S then
		shopFrame.Visible = not shopFrame.Visible
		if shopFrame.Visible then
			refreshShop()
			print("✅ Loja aberta")
		end
	end
end)
