-- ArmorDefinitions.luau
-- Definições de armaduras

return {
	Leather = {
		id = "leather",
		name = "Armadura de Couro",
		icon = "🛡️",
		defense = 5,
		price = {money = 100, crystals = 0},
		rarity = "common",
	},
	IronArmor = {
		id = "iron",
		name = "Armadura de Ferro",
		icon = "⚙️",
		defense = 15,
		price = {money = 300, crystals = 10},
		rarity = "uncommon",
	},
	DiamondArmor = {
		id = "diamond",
		name = "Armadura de Diamante",
		icon = "💎",
		defense = 25,
		price = {money = 500, crystals = 50},
		rarity = "rare",
	},
	GoldenArmor = {
		id = "gold",
		name = "Armadura Dourada",
		icon = "✨",
		defense = 30,
		price = {money = 1000, crystals = 100},
		rarity = "epic",
	},
}
