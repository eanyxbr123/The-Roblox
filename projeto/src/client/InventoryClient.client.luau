-- InventoryClient.client.luau
-- Inventário com drag & drop completo

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

local ItemDefinitions = require(ReplicatedStorage.Shared.ItemDefinitions)
local CraftRecipes = require(ReplicatedStorage.Shared.CraftRecipes)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()

-- Remotes
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local collectItemRemote = RemotesFolder:WaitForChild("CollectItem")
local itemCollectedEvent = RemotesFolder:WaitForChild("ItemCollected")
local GetInventoryRemote = RemotesFolder:WaitForChild("GetInventory")
local CraftRemote = RemotesFolder:WaitForChild("CraftItem")

-- GUI
local screenGui = playerGui:WaitForChild("InventoryGui")
local inventoryWindow = screenGui:WaitForChild("InventoryWindow")
local inventoryGrid = inventoryWindow:WaitForChild("InventoryGrid")
local titleLabel = inventoryWindow:WaitForChild("Title")
local craftingArea = inventoryWindow:WaitForChild("CraftingArea")
local craftingGrid = craftingArea:WaitForChild("CraftingGrid")
local resultSlot = craftingArea:WaitForChild("ResultSlot")
local craftButton = craftingArea:WaitForChild("CraftButton")

print("✅ GUI carregada")

-- =============================================
-- ESTADO LOCAL
-- =============================================
local currentInv = nil
local craftingSlots = {}   -- ["R_C"] = itemId

-- Estado do drag
local dragActive = false
local dragSource = nil     -- {type="inv", slot=N} ou {type="craft", key="R_C"}
local dragItemId = nil
local dragLabel = nil

-- =============================================
-- CORES POR RARIDADE
-- =============================================
local RARITY_COLORS = {
	common    = Color3.fromRGB(180, 180, 180),
	uncommon  = Color3.fromRGB(100, 200, 100),
	rare      = Color3.fromRGB(100, 150, 255),
	epic      = Color3.fromRGB(200, 100, 255),
	legendary = Color3.fromRGB(255, 200, 50),
}

local function getRarityColor(itemId)
	local def = ItemDefinitions[itemId]
	if not def then return Color3.fromRGB(150, 150, 150) end
	return RARITY_COLORS[def.rarity] or RARITY_COLORS.common
end

local function getItemName(itemId)
	local def = ItemDefinitions[itemId]
	return def and def.name or itemId
end

-- =============================================
-- ATUALIZAR SLOT DO INVENTÁRIO
-- =============================================
local function refreshInvSlot(slotNum)
	local slotUI = inventoryGrid:FindFirstChild("Slot" .. slotNum)
	if not slotUI then return end

	local img = slotUI:FindFirstChild("ItemImage")
	local qty = slotUI:FindFirstChild("Quantity")
	local data = currentInv and currentInv.slots[slotNum]

	if img then
		img.Visible = data ~= nil
		if data then
			img.BackgroundColor3 = getRarityColor(data.item)
			img.BackgroundTransparency = 0.3
			img.Image = "rbxassetid://0"
		end
	end

	if qty then
		qty.Text = (data and data.quantity > 1) and tostring(data.quantity) or ""
	end

	-- Highlight amarelo quando é a origem do drag
	local isDragSrc = dragSource and dragSource.type == "inv" and dragSource.slot == slotNum
	slotUI.BorderColor3 = isDragSrc and Color3.fromRGB(255, 220, 0) or Color3.fromRGB(80, 80, 80)
end

-- =============================================
-- ATUALIZAR SLOT DE CRAFT
-- =============================================
local function refreshCraftSlot(key)
	local slotUI = craftingGrid:FindFirstChild("CraftSlot_" .. key)
	if not slotUI then return end

	local img = slotUI:FindFirstChild("ItemImage")
	local itemId = craftingSlots[key]

	if img then
		img.Visible = itemId ~= nil
		if itemId then
			img.BackgroundColor3 = getRarityColor(itemId)
			img.BackgroundTransparency = 0.3
		end
	end

	local isDragSrc = dragSource and dragSource.type == "craft" and dragSource.key == key
	slotUI.BorderColor3 = isDragSrc and Color3.fromRGB(255, 220, 0) or Color3.fromRGB(80, 80, 80)
end

-- =============================================
-- VERIFICAR RECEITA E ATUALIZAR RESULT
-- =============================================
local function checkAndUpdateResult()
	local resultImg = resultSlot:FindFirstChild("ResultImage")
	local resultQty = resultSlot:FindFirstChild("ResultQuantity")

	local pattern = {}
	for row = 1, 3 do
		pattern[row] = {}
		for col = 1, 3 do
			pattern[row][col] = craftingSlots[row .. "_" .. col] or nil
		end
	end

	local matchedRecipe = nil
	for _, recipe in pairs(CraftRecipes) do
		if recipe.pattern then
			local ok = true
			for row = 1, 3 do
				for col = 1, 3 do
					local need = recipe.pattern[row] and recipe.pattern[row][col] or nil
					local have = pattern[row][col]
					if need ~= have then ok = false; break end
				end
				if not ok then break end
			end
			if ok then matchedRecipe = recipe; break end
		end
	end

	if matchedRecipe then
		if resultImg then
			resultImg.Visible = true
			resultImg.BackgroundColor3 = getRarityColor(matchedRecipe.output.item)
			resultImg.BackgroundTransparency = 0.3
		end
		if resultQty then
			resultQty.Text = matchedRecipe.output.quantity > 1
				and tostring(matchedRecipe.output.quantity) or ""
		end
		craftButton.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
		craftButton.Text = "✅ CRAFT"
		craftButton.Active = true
		craftButton:SetAttribute("RecipeId", matchedRecipe.id)
	else
		if resultImg then resultImg.Visible = false end
		if resultQty then resultQty.Text = "" end
		craftButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		craftButton.Text = "CRAFT"
		craftButton.Active = false
		craftButton:SetAttribute("RecipeId", "")
	end
end

-- =============================================
-- REDESENHAR TUDO
-- =============================================
local function refreshAll()
	if not currentInv then return end

	for i = 1, 45 do
		refreshInvSlot(i)
	end
	for row = 1, 3 do
		for col = 1, 3 do
			refreshCraftSlot(row .. "_" .. col)
		end
	end
	checkAndUpdateResult()

	local w = string.format("%.1f/%.1f kg", currentInv.totalWeight or 0, currentInv.maxWeight or 0)
	titleLabel.Text = "📦 INVENTORY | " .. w
end

-- =============================================
-- DRAG VISUAL
-- =============================================
local function createDragLabel(itemId)
	if dragLabel then dragLabel:Destroy() end

	dragLabel = Instance.new("Frame")
	dragLabel.Name = "DragLabel"
	dragLabel.Size = UDim2.new(0, 44, 0, 44)
	dragLabel.BackgroundColor3 = getRarityColor(itemId)
	dragLabel.BackgroundTransparency = 0.15
	dragLabel.BorderSizePixel = 2
	dragLabel.BorderColor3 = Color3.fromRGB(255, 220, 0)
	dragLabel.ZIndex = 20
	dragLabel.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = dragLabel

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.TextSize = 9
	lbl.Font = Enum.Font.GothamBold
	lbl.Text = getItemName(itemId)
	lbl.TextWrapped = true
	lbl.ZIndex = 21
	lbl.Parent = dragLabel

	-- Posicionar já no mouse
	dragLabel.Position = UDim2.new(0, mouse.X - 22, 0, mouse.Y - 22)
end

local function destroyDragLabel()
	if dragLabel then
		dragLabel:Destroy()
		dragLabel = nil
	end
end

-- =============================================
-- INICIAR DRAG
-- =============================================
local function startDrag(source, itemId)
	dragActive = true
	dragSource = source
	dragItemId = itemId
	createDragLabel(itemId)

	if source.type == "inv" then
		refreshInvSlot(source.slot)
	else
		refreshCraftSlot(source.key)
	end
end

-- =============================================
-- SOLTAR EM UM DESTINO
-- =============================================
local function dropOn(target)
	if not dragActive or not dragSource then return end

	if target.type == "inv" then
		if dragSource.type == "inv" then
			-- INV ↔ INV: trocar
			local a, b = dragSource.slot, target.slot
			if a ~= b then
				local temp = currentInv.slots[b]
				currentInv.slots[b] = currentInv.slots[a]
				currentInv.slots[a] = temp
				refreshInvSlot(a)
				refreshInvSlot(b)
			end

		elseif dragSource.type == "craft" then
			-- CRAFT → INV: tirar do craft (item já está no inv, só limpa o slot visual)
			local key = dragSource.key
			craftingSlots[key] = nil
			refreshCraftSlot(key)
			checkAndUpdateResult()
		end

	elseif target.type == "craft" then
		local key = target.key

		if dragSource.type == "inv" then
			-- INV → CRAFT: colocar item no grid de craft
			local slotData = currentInv and currentInv.slots[dragSource.slot]
			if not slotData then return end

			craftingSlots[key] = slotData.item
			refreshCraftSlot(key)
			checkAndUpdateResult()

		elseif dragSource.type == "craft" then
			-- CRAFT ↔ CRAFT: trocar slots
			local srcKey = dragSource.key
			if srcKey ~= key then
				local temp = craftingSlots[key]
				craftingSlots[key] = craftingSlots[srcKey]
				craftingSlots[srcKey] = temp
				refreshCraftSlot(srcKey)
				refreshCraftSlot(key)
				checkAndUpdateResult()
			end
		end
	end
end

-- =============================================
-- CANCELAR DRAG
-- =============================================
local function cancelDrag()
	if not dragActive then return end

	local prev = dragSource
	dragActive = false
	dragSource = nil
	dragItemId = nil
	destroyDragLabel()

	if prev then
		if prev.type == "inv" then refreshInvSlot(prev.slot)
		else refreshCraftSlot(prev.key) end
	end
end

-- =============================================
-- MOUSE MOVE → MOVER DRAG LABEL
-- =============================================
UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement and dragLabel then
		dragLabel.Position = UDim2.new(0, mouse.X - 22, 0, mouse.Y - 22)
	end
end)

-- Botão esquerdo solto sem cair em slot: cancela
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and dragActive then
		cancelDrag()
	end
end)

-- =============================================
-- CONECTAR SLOTS DO INVENTÁRIO
-- =============================================
for _, slotUI in pairs(inventoryGrid:GetChildren()) do
	if slotUI:IsA("Frame") and slotUI.Name:match("^Slot%d+$") then
		local slotNum = tonumber(slotUI.Name:match("%d+"))

		slotUI.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if dragActive then
					dropOn({type = "inv", slot = slotNum})
					cancelDrag()
				else
					local data = currentInv and currentInv.slots[slotNum]
					if data then
						startDrag({type = "inv", slot = slotNum}, data.item)
					end
				end

			elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
				cancelDrag()
			end
		end)
	end
end

-- =============================================
-- CONECTAR SLOTS DE CRAFT
-- =============================================
for _, slotUI in pairs(craftingGrid:GetChildren()) do
	if slotUI:IsA("Frame") and slotUI.Name:match("^CraftSlot_%d+_%d+$") then
		local row, col = slotUI.Name:match("CraftSlot_(%d+)_(%d+)")
		local key = row .. "_" .. col

		slotUI.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if dragActive then
					dropOn({type = "craft", key = key})
					cancelDrag()
				else
					local itemId = craftingSlots[key]
					if itemId then
						startDrag({type = "craft", key = key}, itemId)
					end
				end

			elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
				-- Botão direito: limpar slot de craft
				if craftingSlots[key] then
					craftingSlots[key] = nil
					refreshCraftSlot(key)
					checkAndUpdateResult()
				end
				cancelDrag()
			end
		end)
	end
end

-- =============================================
-- BOTÃO CRAFT
-- =============================================
craftButton.MouseButton1Click:Connect(function()
	local recipeId = craftButton:GetAttribute("RecipeId")
	if not recipeId or recipeId == "" then return end

	local result = CraftRemote:InvokeServer(recipeId)
	if result and result.success then
		print("✅ Craftado: " .. recipeId)
		craftingSlots = {}
		for row = 1, 3 do
			for col = 1, 3 do
				refreshCraftSlot(row .. "_" .. col)
			end
		end
		task.wait(0.3)
		currentInv = GetInventoryRemote:InvokeServer()
		refreshAll()
	else
		print("❌ Craft falhou: " .. (result and result.message or "erro desconhecido"))
	end
end)

-- =============================================
-- SYNC COM SERVIDOR
-- =============================================
local function syncInventory(inv)
	if not inv or not inv.maxSlots then
		warn("❌ syncInventory: inventário inválido ou maxSlots nil")
		return
	end
	currentInv = inv
	refreshAll()
end

itemCollectedEvent.OnClientEvent:Connect(function(inv)
	syncInventory(inv)
end)

-- =============================================
-- COLETA DE ITENS DO MUNDO
-- =============================================
local function connectWorldItem(item)
	if item:IsA("Part") then
		local click = item:FindFirstChild("ClickDetector")
		if click then
			click.MouseClick:Connect(function()
				collectItemRemote:InvokeServer(item.Name)
			end)
		end
	end
end

local spawnedItems = workspace:WaitForChild("SpawnedItems")
spawnedItems.ChildAdded:Connect(connectWorldItem)
for _, item in pairs(spawnedItems:GetChildren()) do
	connectWorldItem(item)
end

-- =============================================
-- ABRIR / FECHAR COM I
-- =============================================
local function toggle(_, state)
	if state == Enum.UserInputState.Begin then
		inventoryWindow.Visible = not inventoryWindow.Visible
		if inventoryWindow.Visible then
			currentInv = GetInventoryRemote:InvokeServer()
			refreshAll()
		else
			cancelDrag()
		end
	end
end

ContextActionService:BindAction("inv", toggle, false, Enum.KeyCode.I)
inventoryWindow.Visible = false

print("✅ InventoryClient pronto")
print("   🖱️  Clique e arraste itens entre slots")
print("   🔨 Arraste para o grid de craft")
print("   🖱️  Botão direito nos slots de craft para remover")
