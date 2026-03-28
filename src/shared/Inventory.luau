-- Inventory.luau
-- Lógica de inventário compartilhada

local Inventory = {}
Inventory.__index = Inventory

function Inventory.new(backpackLevel: number)
	-- backpackLevel 1-5 = mais slots
	local slotsPerLevel = 20
	local maxSlots = slotsPerLevel * backpackLevel
	
	local self = setmetatable({
		slots = {},
		maxSlots = maxSlots,
		totalWeight = 0,
		maxWeight = 100 + (50 * backpackLevel),
	}, Inventory)
	
	-- Inicializar slots vazios
	for i = 1, maxSlots do
		self.slots[i] = nil
	end
	
	return self
end

function Inventory.addItem(inv: any, itemId: string, quantity: number, itemDefs: any): {success: boolean, message: string}
	local def = itemDefs[itemId]
	if not def then
		return {success = false, message = "Item não existe"}
	end
	
	local itemWeight = def.weight * quantity
	if inv.totalWeight + itemWeight > inv.maxWeight then
		return {success = false, message = "Inventário cheio"}
	end
	
	-- Tentar stackar em slot existente
	if def.stackable then
		for i = 1, inv.maxSlots do
			if inv.slots[i] and inv.slots[i].item == itemId then
				local canAdd = def.maxStack - inv.slots[i].quantity
				if canAdd > 0 then
					local toAdd = math.min(canAdd, quantity)
					inv.slots[i].quantity = inv.slots[i].quantity + toAdd
					inv.totalWeight = inv.totalWeight + (toAdd * def.weight)
					quantity = quantity - toAdd
					if quantity == 0 then
						return {success = true, message = "Item stackado"}
					end
				end
			end
		end
	end
	
	-- Colocar em slots vazios
	for i = 1, inv.maxSlots do
		if not inv.slots[i] then
			local add = def.stackable and math.min(def.maxStack, quantity) or 1
			inv.slots[i] = {item = itemId, quantity = add}
			inv.totalWeight = inv.totalWeight + (add * def.weight)
			quantity = quantity - add
			if quantity == 0 then
				return {success = true, message = "Item adicionado"}
			end
		end
	end
	
	return {success = false, message = "Não há espaço"}
end

function Inventory.removeItem(inv: any, itemId: string, quantity: number, itemDefs: any): boolean
	local def = itemDefs[itemId]
	if not def then return false end
	
	for i = 1, inv.maxSlots do
		if inv.slots[i] and inv.slots[i].item == itemId then
			if inv.slots[i].quantity <= quantity then
				quantity = quantity - inv.slots[i].quantity
				inv.totalWeight = inv.totalWeight - (inv.slots[i].quantity * def.weight)
				inv.slots[i] = nil
				if quantity == 0 then return true end
			else
				inv.slots[i].quantity = inv.slots[i].quantity - quantity
				inv.totalWeight = inv.totalWeight - (quantity * def.weight)
				return true
			end
		end
	end
	return false
end

function Inventory.hasItems(inv: any, itemDefs: any, recipe: any): boolean
	for itemId, needed in pairs(recipe.inputs) do
		local count = 0
		for i = 1, inv.maxSlots do
			if inv.slots[i] and inv.slots[i].item == itemId then
				count = count + inv.slots[i].quantity
			end
		end
		if count < needed then return false end
	end
	return true
end

return Inventory
