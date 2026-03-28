-- ItemInteraction.luau
-- Sistema de interacao com itens (server-side validation e coleta)
-- ⚠️  Este arquivo deve ser um ModuleScript no Roblox Studio

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemInteraction = {}

-- ✅ InventorySystem é injetado pelo init.server.luau via ItemInteraction.init()
--    Isso evita require() circular ou require() de Script (.server.luau)
local _inventorySystem = nil

function ItemInteraction.init(inventorySystem)
	_inventorySystem = inventorySystem
end

-- Criar remotes para coleta de itens
local function initializeRemotes()
	local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
	if not RemotesFolder then
		RemotesFolder = Instance.new("Folder")
		RemotesFolder.Name = "Remotes"
		RemotesFolder.Parent = ReplicatedStorage
	end

	local collectItemRemote = RemotesFolder:FindFirstChild("CollectItem")
	if not collectItemRemote then
		collectItemRemote = Instance.new("RemoteFunction")
		collectItemRemote.Name = "CollectItem"
		collectItemRemote.Parent = RemotesFolder

		collectItemRemote.OnServerInvoke = function(player, itemPartName)
			return ItemInteraction.handleItemCollection(player, itemPartName)
		end
	end

	local itemCollectedEvent = RemotesFolder:FindFirstChild("ItemCollected")
	if not itemCollectedEvent then
		itemCollectedEvent = Instance.new("RemoteEvent")
		itemCollectedEvent.Name = "ItemCollected"
		itemCollectedEvent.Parent = RemotesFolder
	end

	print("✅ Item Interaction remotes initialized")
end

-- Manipular coleta de item
function ItemInteraction.handleItemCollection(player: Player, itemPartName: string)
	if not player or not player.Character then return false end

	local spawnedItemsFolder = workspace:FindFirstChild("SpawnedItems")
	if not spawnedItemsFolder then return false end

	local itemPart = nil
	for _, part in pairs(spawnedItemsFolder:GetChildren()) do
		if part.Name == itemPartName then
			itemPart = part
			break
		end
	end

	if not itemPart or not itemPart.Parent then
		warn("Item part not found: " .. itemPartName)
		return false
	end

	local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return false end

	local distance = (itemPart.Position - rootPart.Position).Magnitude
	if distance > 35 then
		warn(player.Name .. " tentou coletar item muito distante (" .. distance .. " studs)")
		return false
	end

	local itemId = itemPart:FindFirstChild("ItemId")
	local amount = itemPart:FindFirstChild("Amount")
	if not itemId or not amount then return false end

	-- ✅ Adicionar ao inventário ANTES de destruir o item
	if _inventorySystem then
		local addSuccess = _inventorySystem.addItemToPlayer(player, itemId.Value, amount.Value)
		if not addSuccess then
			warn("❌ Inventário cheio para " .. player.Name .. " — item não coletado")
			return false
		end

		-- ✅ Enviar inventário atualizado para o cliente
		local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
		local itemCollectedEvent = RemotesFolder and RemotesFolder:FindFirstChild("ItemCollected")
		if itemCollectedEvent then
			local updatedInv = _inventorySystem.getInventory(player)
			itemCollectedEvent:FireClient(player, updatedInv)
		end
	else
		warn("❌ ItemInteraction: InventorySystem não foi injetado via init()")
	end

	-- Recompensa de experiência
	local stats = player:FindFirstChild("Stats")
	if stats then
		local xpValue = stats:FindFirstChild("XP")
		local levelValue = stats:FindFirstChild("Level")
		if xpValue and levelValue then
			xpValue.Value = xpValue.Value + amount.Value * 5
			local needed = levelValue.Value * 100
			if xpValue.Value >= needed then
				levelValue.Value = levelValue.Value + 1
				xpValue.Value = xpValue.Value - needed
				print("🏆 " .. player.Name .. " reached level " .. levelValue.Value)
			end
		end
	end

	itemPart:Destroy()
	print("👜 " .. player.Name .. " collected " .. amount.Value .. "x " .. itemId.Value)
	return true
end

initializeRemotes()

return ItemInteraction
