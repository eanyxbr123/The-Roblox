-- Inventory.luau
-- Sistema compartilhado de inventário

export type InventorySlot = {
	item: string?,
	quantity: number,
	durability: number?
}

export type InventoryData = {
	slots: {[number]: InventorySlot},
	columns: number,
	rows: number,
	maxSlots: number,
	totalWeight: number,
	maxWeight: number,
	backpackLevel: number
}

local Inventory = {}

-- Configurações de mochila por nível
local BACKPACK_CONFIGS = {
	[1] = {columns = 5, rows = 4, maxWeight = 50},   -- Mochila básica
	[2] = {columns = 6, rows = 5, maxWeight = 75},   -- Mochila pequena
	[3] = {columns = 7, rows = 6, maxWeight = 100},  -- Mochila média
	[4] = {columns = 8, rows = 7, maxWeight = 150},  -- Mochila grande
	[5] = {columns = 9, rows = 8, maxWeight = 250},  -- Mochila máxima
}

function Inventory.new(backpackLevel: number): InventoryData
	local config = BACKPACK_CONFIGS[backpackLevel] or BACKPACK_CONFIGS[1]
	local maxSlots = config.columns * config.rows

	return {
		slots = {},
		columns = config.columns,
		rows = config.rows,
		maxSlots = maxSlots,
		totalWeight = 0,
		maxWeight = config.maxWeight,
		backpackLevel = backpackLevel
	}
end

function Inventory.upgradeBackpack(inv: InventoryData): boolean
	if inv.backpackLevel >= 5 then
		return false -- Já é nível máximo
	end

	inv.backpackLevel += 1
	local config = BACKPACK_CONFIGS[inv.backpackLevel]
	inv.columns = config.columns
	inv.rows = config.rows
	inv.maxSlots = config.columns * config.rows
	inv.maxWeight = config.maxWeight

	return true
end

function Inventory.addItem(inv: InventoryData, itemId: string, quantity: number, items: {[string]: any}): {success: boolean, remaining: number}
	if not items[itemId] then
		return {success = false, remaining = quantity}
	end

	local item = items[itemId]
	local remaining = quantity

	-- Calcular peso total que seria adicionado
	local totalWeightToAdd = remaining * item.weight
	if inv.totalWeight + totalWeightToAdd > inv.maxWeight then
		-- Ajustar quantidade baseada no peso disponível
		local availableWeight = inv.maxWeight - inv.totalWeight
		local maxQuantity = math.floor(availableWeight / item.weight)
		remaining = math.min(remaining, maxQuantity)
		totalWeightToAdd = remaining * item.weight
	end

	if remaining <= 0 then
		return {success = false, remaining = quantity}
	end

	-- Tentar adicionar a slots existentes
	for slotNum = 1, inv.maxSlots do
		if inv.slots[slotNum] and inv.slots[slotNum].item == itemId then
			local canAdd = math.min(remaining, item.maxStack - inv.slots[slotNum].quantity)
			inv.slots[slotNum].quantity += canAdd
			remaining -= canAdd
			inv.totalWeight += canAdd * item.weight

			if remaining == 0 then
				return {success = true, remaining = 0}
			end
		end
	end

	-- Adicionar a novos slots
	for slotNum = 1, inv.maxSlots do
		if not inv.slots[slotNum] then
			local toAdd = math.min(remaining, item.maxStack)
			inv.slots[slotNum] = {
				item = itemId,
				quantity = toAdd,
				durability = item.properties and item.properties.durability or nil
			}
			remaining -= toAdd
			inv.totalWeight += toAdd * item.weight

			if remaining == 0 then
				return {success = true, remaining = 0}
			end
		end
	end

	return {success = remaining < quantity, remaining = remaining}
end

function Inventory.removeItem(inv: InventoryData, itemId: string, quantity: number, items: {[string]: any}): boolean
	local remaining = quantity

	for slotNum = 1, inv.maxSlots do
		if inv.slots[slotNum] and inv.slots[slotNum].item == itemId then
			local toRemove = math.min(remaining, inv.slots[slotNum].quantity)
			inv.slots[slotNum].quantity -= toRemove
			remaining -= toRemove
			inv.totalWeight -= toRemove * items[itemId].weight

			if inv.slots[slotNum].quantity <= 0 then
				inv.slots[slotNum] = nil
			end

			if remaining == 0 then
				return true
			end
		end
	end

	return remaining == 0
end

function Inventory.hasItems(inv: InventoryData, items: {[string]: any}, recipe: any): boolean
	for itemId, needed in pairs(recipe.inputs) do
		local found = 0
		for slotNum = 1, inv.maxSlots do
			if inv.slots[slotNum] and inv.slots[slotNum].item == itemId then
				found += inv.slots[slotNum].quantity
			end
		end
		if found < needed then
			return false
		end
	end
	return true
end

function Inventory.getItemCount(inv: InventoryData, itemId: string): number
	local count = 0
	for slotNum = 1, inv.maxSlots do
		if inv.slots[slotNum] and inv.slots[slotNum].item == itemId then
			count += inv.slots[slotNum].quantity
		end
	end
	return count
end

function Inventory.getSlotPosition(inv: InventoryData, slotNum: number): {row: number, col: number}
	local row = math.floor((slotNum - 1) / inv.columns) + 1
	local col = ((slotNum - 1) % inv.columns) + 1
	return {row = row, col = col}
end

function Inventory.getSlotFromPosition(inv: InventoryData, row: number, col: number): number
	return (row - 1) * inv.columns + col
end

return Inventory
