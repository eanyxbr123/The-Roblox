-- CraftRecipes.luau
-- Define todas as receitas do jogo

local CraftRecipes = {}

-- Ferramentas
CraftRecipes["wooden_pickaxe"] = {
	id = "wooden_pickaxe",
	name = "Picareta de Madeira",
	pattern = {
		{"wood", "wood", "wood"},
		{nil, "stone", nil},
		{nil, "stone", nil},
	},
	output = {item = "wooden_pickaxe", quantity = 1},
	inputs = {wood = 3, stone = 2},
}

CraftRecipes["stone_pickaxe"] = {
	id = "stone_pickaxe",
	name = "Picareta de Pedra",
	pattern = {
		{"stone", "stone", "stone"},
		{nil, "wood", nil},
		{nil, "wood", nil},
	},
	output = {item = "stone_pickaxe", quantity = 1},
	inputs = {stone = 3, wood = 2},
}

CraftRecipes["sword"] = {
	id = "sword",
	name = "Espada",
	pattern = {
		{nil, "stone", nil},
		{nil, "stone", nil},
		{nil, "wood", nil},
	},
	output = {item = "sword", quantity = 1},
	inputs = {stone = 2, wood = 1},
}

CraftRecipes["wooden_axe"] = {
	id = "wooden_axe",
	name = "Machado de Madeira",
	pattern = {
		{"wood", "wood", nil},
		{"wood", "stone", nil},
		{nil, "stone", nil},
	},
	output = {item = "wooden_axe", quantity = 1},
	inputs = {wood = 3, stone = 2},
}

-- Alimentos
CraftRecipes["cooked_meat"] = {
	id = "cooked_meat",
	name = "Carne Cozida",
	pattern = {
		{nil, "raw_meat", nil},
		{nil, nil, nil},
		{nil, nil, nil},
	},
	output = {item = "cooked_meat", quantity = 1},
	inputs = {raw_meat = 1},
}

-- Estruturas
CraftRecipes["wooden_wall"] = {
	id = "wooden_wall",
	name = "Parede de Madeira",
	pattern = {
		{"wood", "wood", nil},
		{"wood", "wood", nil},
		{nil, nil, nil},
	},
	output = {item = "wooden_wall", quantity = 1},
	inputs = {wood = 4},
}

return CraftRecipes
