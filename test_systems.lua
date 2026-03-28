-- test_systems.lua
-- Test script for all survival systems

print("🧪 Testing Survival Systems...")

-- Test ItemDefinitions
local success1, ItemDefinitions = pcall(function()
	return require(game.ReplicatedStorage.Shared.ItemDefinitions)
end)
print("✅ ItemDefinitions: " .. (success1 and "LOADED" or "FAILED"))

-- Test Inventory
local success2, Inventory = pcall(function()
	return require(game.ReplicatedStorage.Shared.Inventory)
end)
print("✅ Inventory: " .. (success2 and "LOADED" or "FAILED"))

-- Test CraftRecipes
local success3, CraftRecipes = pcall(function()
	return require(game.ReplicatedStorage.Shared.CraftRecipes)
end)
print("✅ CraftRecipes: " .. (success3 and "LOADED" or "FAILED"))

-- Test server systems (lazy loading)
print("\n🔧 Testing Server Systems...")

local function testServerSystem(name, path)
	local success, system = pcall(function()
		return require(path)
	end)
	print("✅ " .. name .. ": " .. (success and "LOADED" or "FAILED"))
	return success
end

testServerSystem("InventorySystem", game.ServerScriptService.Server.InventorySystem)
testServerSystem("ItemSpawner", game.ServerScriptService.Server.ItemSpawner)
testServerSystem("TreeSpawner", game.ServerScriptService.Server.TreeSpawner)
testServerSystem("DayNightSystem", game.ServerScriptService.Server.DayNightSystem)
testServerSystem("MonsterSystem", game.ServerScriptService.Server.MonsterSystem)
testServerSystem("ConstructionSystem", game.ServerScriptService.Server.ConstructionSystem)

print("\n🎮 All systems test completed!")