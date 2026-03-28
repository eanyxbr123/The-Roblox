-- ItemDefinitions.luau
-- Define todos os itens do jogo

local ItemDefinitions = {
	wood = {
		name = "Wood",
		rarity = "common",
		stackable = true,
		maxStack = 99,
		weight = 1,
	},
	stone = {
		name = "Stone",
		rarity = "common",
		stackable = true,
		maxStack = 99,
		weight = 1.5,
	},
	cloth = {
		name = "Cloth",
		rarity = "uncommon",
		stackable = true,
		maxStack = 50,
		weight = 0.5,
	},
	mushroom = {
		name = "Mushroom",
		rarity = "uncommon",
		stackable = true,
		maxStack = 20,
		weight = 0.3,
	},
	-- Ferramentas
	wooden_pickaxe = {
		name = "Picareta de Madeira",
		rarity = "uncommon",
		stackable = false,
		maxStack = 1,
		weight = 5,
	},
	stone_pickaxe = {
		name = "Picareta de Pedra",
		rarity = "uncommon",
		stackable = false,
		maxStack = 1,
		weight = 6,
	},
	sword = {
		name = "Espada",
		rarity = "uncommon",
		stackable = false,
		maxStack = 1,
		weight = 4,
	},
	wooden_axe = {
		name = "Machado de Madeira",
		rarity = "uncommon",
		stackable = false,
		maxStack = 1,
		weight = 5,
	},
	-- Armas
	pistol = {
		name = "Pistola 9mm",
		rarity = "rare",
		stackable = false,
		maxStack = 1,
		weight = 2,
	},
	bullet = {
		name = "Munição",
		rarity = "common",
		stackable = true,
		maxStack = 100,
		weight = 0.1,
	},
	bow = {
		name = "Arco",
		rarity = "rare",
		stackable = false,
		maxStack = 1,
		weight = 2,
	},
	arrow = {
		name = "Flecha",
		rarity = "common",
		stackable = true,
		maxStack = 100,
		weight = 0.1,
	},
	-- Alimentos e itens de classe
	medkit = {
		name = "Medkit",
		rarity = "rare",
		stackable = true,
		maxStack = 10,
		weight = 2,
	},
	adrenaline = {
		name = "Adrenalina",
		rarity = "epic",
		stackable = true,
		maxStack = 5,
		weight = 0.5,
	},
	raw_meat = {
		name = "Carne Crua",
		rarity = "common",
		stackable = true,
		maxStack = 20,
		weight = 1,
	},
	cooked_meat = {
		name = "Carne Cozida",
		rarity = "uncommon",
		stackable = true,
		maxStack = 20,
		weight = 1,
	},
	fiber = {
		name = "Fibra",
		rarity = "common",
		stackable = true,
		maxStack = 50,
		weight = 0.3,
	},
	-- Estruturas
	wooden_wall = {
		name = "Parede de Madeira",
		rarity = "common",
		stackable = true,
		maxStack = 50,
		weight = 3,
	},
}

return ItemDefinitions
