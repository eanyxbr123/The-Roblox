-- ItemDefinitions.luau
-- Sistema de definição de itens estilo Rust

export type Item = {
	id: string,
	name: string,
	description: string,
	maxStack: number,
	weight: number,
	rarity: "common" | "uncommon" | "rare" | "epic" | "legendary",
	icon: string,
	properties: {[string]: any}?
}

local Items: {[string]: Item} = {
	-- Recursos Básicos
	wood = {
		id = "wood",
		name = "Wood",
		description = "Basic wood resource",
		maxStack = 1000,
		weight = 0.5,
		rarity = "common",
		icon = "rbxasset://textures/Ui/Icons/wood"
	},
	stone = {
		id = "stone",
		name = "Stone",
		description = "Basic stone resource",
		maxStack = 1000,
		weight = 1,
		rarity = "common",
		icon = "rbxasset://textures/Ui/Icons/stone"
	},
	metal = {
		id = "metal",
		name = "Metal Ore",
		description = "Metal resource",
		maxStack = 500,
		weight = 1.5,
		rarity = "uncommon",
		icon = "rbxasset://textures/Ui/Icons/metal"
	},
	cloth = {
		id = "cloth",
		name = "Cloth",
		description = "Fabric material",
		maxStack = 500,
		weight = 0.2,
		rarity = "common",
		icon = "rbxasset://textures/Ui/Icons/cloth"
	},
	mushroom = {
		id = "mushroom",
		name = "Mushroom",
		description = "Edible mushroom",
		maxStack = 100,
		weight = 0.1,
		rarity = "common",
		icon = "rbxasset://textures/Ui/Icons/mushroom"
	},
	leather = {
		id = "leather",
		name = "Leather",
		description = "Animal leather",
		maxStack = 300,
		weight = 0.3,
		rarity = "uncommon",
		icon = "rbxasset://textures/Ui/Icons/leather"
	},

	-- Ferramentas
	stone_pickaxe = {
		id = "stone_pickaxe",
		name = "Stone Pickaxe",
		description = "Basic mining tool",
		maxStack = 1,
		weight = 5,
		rarity = "common",
		icon = "rbxasset://textures/Ui/Icons/pickaxe",
		properties = {
			durability = 100,
			miningSpeed = 1
		}
	},
	metal_pickaxe = {
		id = "metal_pickaxe",
		name = "Metal Pickaxe",
		description = "Better mining tool",
		maxStack = 1,
		weight = 4,
		rarity = "uncommon",
		icon = "rbxasset://textures/Ui/Icons/metal_pickaxe",
		properties = {
			durability = 200,
			miningSpeed = 2
		}
	},
	axe = {
		id = "axe",
		name = "Axe",
		description = "Cutting tool",
		maxStack = 1,
		weight = 4,
		rarity = "common",
		icon = "rbxasset://textures/Ui/Icons/axe",
		properties = {
			durability = 100,
			chopSpeed = 1
		}
	},

	-- Armaduras
	cloth_armor = {
		id = "cloth_armor",
		name = "Cloth Armor",
		description = "Basic protection",
		maxStack = 1,
		weight = 2,
		rarity = "common",
		icon = "rbxasset://textures/Ui/Icons/cloth_armor",
		properties = {
			defense = 5
		}
	},
	leather_armor = {
		id = "leather_armor",
		name = "Leather Armor",
		description = "Better protection",
		maxStack = 1,
		weight = 3,
		rarity = "uncommon",
		icon = "rbxasset://textures/Ui/Icons/leather_armor",
		properties = {
			defense = 10
		}
	},

	-- Armas
	stone_spear = {
		id = "stone_spear",
		name = "Stone Spear",
		description = "Basic melee weapon",
		maxStack = 1,
		weight = 3,
		rarity = "common",
		icon = "rbxasset://textures/Ui/Icons/spear",
		properties = {
			damage = 15,
			durability = 50
		}
	},
	metal_sword = {
		id = "metal_sword",
		name = "Metal Sword",
		description = "Better melee weapon",
		maxStack = 1,
		weight = 2.5,
		rarity = "uncommon",
		icon = "rbxasset://textures/Ui/Icons/sword",
		properties = {
			damage = 30,
			durability = 150
		}
	},

	-- Materiais processados
	planks = {
		id = "planks",
		name = "Wood Planks",
		description = "Processed wood material",
		maxStack = 1000,
		weight = 0.3,
		rarity = "common",
		icon = "rbxasset://textures/Ui/Icons/planks"
	},
	sticks = {
		id = "sticks",
		name = "Sticks",
		description = "Wooden sticks",
		maxStack = 1000,
		weight = 0.1,
		rarity = "common",
		icon = "rbxasset://textures/Ui/Icons/sticks"
	},

	-- Ferramentas adicionais
	wooden_pickaxe = {
		id = "wooden_pickaxe",
		name = "Wooden Pickaxe",
		description = "Basic wooden pickaxe",
		maxStack = 1,
		weight = 3,
		rarity = "common",
		icon = "rbxasset://textures/Ui/Icons/wooden_pickaxe",
		properties = {
			durability = 60,
			miningSpeed = 0.8
		}
	},

	-- Armas adicionais
	wooden_spear = {
		id = "wooden_spear",
		name = "Wooden Spear",
		description = "Basic wooden spear",
		maxStack = 1,
		weight = 2.5,
		rarity = "common",
		icon = "rbxasset://textures/Ui/Icons/wooden_spear",
		properties = {
			damage = 8,
			durability = 30
		}
	}
}

return Items
