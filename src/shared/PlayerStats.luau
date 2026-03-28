-- PlayerStats.luau
-- Gerencia vida, fome, stamina, etc

local PlayerStats = {}
PlayerStats.__index = PlayerStats

function PlayerStats.new()
	local self = setmetatable({
		health = 100,
		maxHealth = 100,
		hunger = 100,
		maxHunger = 100,
		stamina = 100,
		maxStamina = 100,
		thirst = 100,
		maxThirst = 100,
		sanity = 100,
		maxSanity = 100,
		nightsSurvived = 0,
		money = 1000,
		crystals = 50,
		class = "police",
		unlockedClasses = {police = true},
		currentWeapon = nil,
		armor = 0,
	}, PlayerStats)
	
	return self
end

function PlayerStats.takeDamage(self, amount, armorReduce)
	armorReduce = armorReduce or 1.0
	local finalDamage = amount * (1 - self.armor * armorReduce)
	self.health = math.max(0, self.health - finalDamage)
	return self.health
end

function PlayerStats.heal(self, amount)
	self.health = math.min(self.maxHealth, self.health + amount)
	return self.health
end

function PlayerStats.decreaseHunger(self, amount)
	self.hunger = math.max(0, self.hunger - amount)
	if self.hunger <= 0 then
		self:takeDamage(1)
	end
	return self.hunger
end

function PlayerStats.eat(self, amount)
	self.hunger = math.min(self.maxHunger, self.hunger + amount)
	return self.hunger
end

return PlayerStats
