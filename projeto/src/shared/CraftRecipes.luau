-- CraftRecipes.luau
-- Sistema de receitas de craft

export type Recipe = {
	id: string,
	name: string,
	description: string,
	output: {item: string, quantity: number},
	inputs: {[string]: number}, -- {itemId: quantidade}
	pattern: {{string?}}?, -- padrão visual 3x3 (opcional)
	craftTime: number, -- segundos
	category: string,
	level: number -- nível mínimo de craft
}

local Recipes: {[string]: Recipe} = {
	-- Ferramentas básicas
	wooden_pickaxe = {
		id = "wooden_pickaxe",
		name = "Wooden Pickaxe",
		description = "Basic mining tool",
		output = {item = "wooden_pickaxe", quantity = 1},
		inputs = {wood = 3, stone = 2},
		pattern = {
			{"wood", "wood", "wood"},
			{nil, "stone", nil},
			{nil, "stone", nil}
		},
		craftTime = 3,
		category = "tools",
		level = 1
	},
	stone_pickaxe = {
		id = "stone_pickaxe",
		name = "Stone Pickaxe",
		description = "Better mining tool",
		output = {item = "stone_pickaxe", quantity = 1},
		inputs = {wood = 2, stone = 3},
		pattern = {
			{"stone", "stone", "stone"},
			{nil, "wood", nil},
			{nil, "wood", nil}
		},
		craftTime = 5,
		category = "tools",
		level = 1
	},
	metal_pickaxe = {
		id = "metal_pickaxe",
		name = "Metal Pickaxe",
		description = "Advanced mining tool",
		output = {item = "metal_pickaxe", quantity = 1},
		inputs = {wood = 2, metal = 3},
		pattern = {
			{"metal", "metal", "metal"},
			{nil, "wood", nil},
			{nil, "wood", nil}
		},
		craftTime = 8,
		category = "tools",
		level = 3
	},

	-- Armaduras
	cloth_armor = {
		id = "cloth_armor",
		name = "Cloth Armor",
		description = "Basic protection",
		output = {item = "cloth_armor", quantity = 1},
		inputs = {cloth = 5},
		pattern = {
			{"cloth", nil, "cloth"},
			{"cloth", "cloth", "cloth"},
			{"cloth", nil, "cloth"}
		},
		craftTime = 4,
		category = "armor",
		level = 1
	},
	leather_armor = {
		id = "leather_armor",
		name = "Leather Armor",
		description = "Better protection",
		output = {item = "leather_armor", quantity = 1},
		inputs = {leather = 4, cloth = 2},
		pattern = {
			{"leather", nil, "leather"},
			{"cloth", "leather", "cloth"},
			{"leather", nil, "leather"}
		},
		craftTime = 6,
		category = "armor",
		level = 2
	},

	-- Armas
	wooden_spear = {
		id = "wooden_spear",
		name = "Wooden Spear",
		description = "Basic melee weapon",
		output = {item = "wooden_spear", quantity = 1},
		inputs = {wood = 4, stone = 1},
		pattern = {
			nil, {"wood"}, nil,
			nil, {"wood"}, nil,
			nil, {"stone"}, nil
		},
		craftTime = 3,
		category = "weapons",
		level = 1
	},
	stone_spear = {
		id = "stone_spear",
		name = "Stone Spear",
		description = "Better melee weapon",
		output = {item = "stone_spear", quantity = 1},
		inputs = {wood = 3, stone = 2},
		pattern = {
			nil, {"stone"}, nil,
			nil, {"wood"}, nil,
			nil, {"wood"}, nil
		},
		craftTime = 5,
		category = "weapons",
		level = 1
	},
	metal_sword = {
		id = "metal_sword",
		name = "Metal Sword",
		description = "Powerful melee weapon",
		output = {item = "metal_sword", quantity = 1},
		inputs = {wood = 1, metal = 2},
		pattern = {
			nil, {"metal"}, nil,
			nil, {"metal"}, nil,
			nil, {"wood"}, nil
		},
		craftTime = 7,
		category = "weapons",
		level = 3
	},

	-- Materiais processados
	planks = {
		id = "planks",
		name = "Wood Planks",
		description = "Processed wood",
		output = {item = "planks", quantity = 4},
		inputs = {wood = 1},
		pattern = {
			{"wood"}
		},
		craftTime = 1,
		category = "materials",
		level = 1
	},
	sticks = {
		id = "sticks",
		name = "Sticks",
		description = "Wooden sticks",
		output = {item = "sticks", quantity = 4},
		inputs = {planks = 2},
		pattern = {
			{"planks"},
			{"planks"}
		},
		craftTime = 1,
		category = "materials",
		level = 1
	}
}

return Recipes
