-- ClassDefinitions.luau
-- Define as classes disponíveis

local ClassDefinitions = {
	police = {
		id = "police",
		name = "🚨 Policial",
		description = "Começa com pistola e munição",
		startItems = {
			pistol = 1,
			bullet = 15,
		},
		bonuses = {
			health = 10,
		},
		unlocked = true,
		price = {money = 0, crystals = 0},
	},
	medic = {
		id = "medic",
		name = "🏥 Médico",
		description = "Começa com medkits e adrenalina",
		startItems = {
			medkit = 2,
			adrenaline = 1,
		},
		bonuses = {
			revive = true,
		},
		unlocked = true,
		price = {money = 2000, crystals = 0},
	},
	builder = {
		id = "builder",
		name = "🏗️ Construtor",
		description = "Começa com madeira, pedra e fibra",
		startItems = {
			wood = 20,
			stone = 20,
			fiber = 20,
		},
		bonuses = {
			carryCapacity = 10,
		},
		unlocked = true,
		price = {money = 1500, crystals = 0},
	},
	hunter = {
		id = "hunter",
		name = "🏹 Caçador",
		description = "Extra dano em animais",
		startItems = {
			bow = 1,
			arrow = 20,
		},
		bonuses = {
			animalDamage = 1.5,
		},
		unlocked = false,
		price = {money = 3000, crystals = 50},
	},
	explorer = {
		id = "explorer",
		name = "🧭 Explorador",
		description = "Mais velocidade e visão",
		startItems = {},
		bonuses = {
			speed = 1.3,
			visionRange = 1.5,
		},
		unlocked = false,
		price = {money = 2500, crystals = 30},
	},
	cyborg = {
		id = "cyborg",
		name = "🤖 Cyborg",
		description = "Alta resistência",
		startItems = {},
		bonuses = {
			health = 50,
			armor = 0.5,
		},
		unlocked = false,
		price = {money = 5000, crystals = 100},
	},
	berserker = {
		id = "berserker",
		name = "🔥 Berserker",
		description = "Dano alto, perde vida",
		startItems = {},
		bonuses = {
			damage = 2.0,
			healthDecay = 0.5,
		},
		unlocked = false,
		price = {money = 4000, crystals = 80},
	},
}

return ClassDefinitions
