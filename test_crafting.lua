-- test_crafting.lua
-- Test script for crafting system

local ItemDefinitions = require("ItemDefinitions")
local CraftRecipes = require("CraftRecipes")
local Inventory = require("Inventory")

print("🧪 Testing Crafting System...")

-- Test inventory creation
local inv = Inventory.new(1)
print("✅ Created inventory with " .. inv.maxSlots .. " slots")

-- Add some items
local result1 = Inventory.addItem(inv, "wood", 5, ItemDefinitions)
local result2 = Inventory.addItem(inv, "stone", 3, ItemDefinitions)
print("✅ Added wood: " .. (result1.success and "success" or "failed"))
print("✅ Added stone: " .. (result2.success and "success" or "failed"))

-- Test crafting pattern matching
print("\n🔨 Testing crafting patterns...")
for recipeId, recipe in pairs(CraftRecipes) do
    if recipe.pattern then
        print("Recipe: " .. recipe.name)
        print("  Pattern exists: ✅")
        if Inventory.hasItems(inv, ItemDefinitions, recipe) then
            print("  Has items: ✅")
        else
            print("  Has items: ❌")
        end
    end
end

-- Test backpack upgrade
local upgraded = Inventory.upgradeBackpack(inv)
print("\n📦 Backpack upgrade: " .. (upgraded and "✅" or "❌"))
print("New max slots: " .. inv.maxSlots)

print("\n✅ All tests completed!")