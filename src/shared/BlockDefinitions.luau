-- BlockDefinitions.luau
-- Define tipos de blocos e suas propriedades

local BlockDefinitions = {
	grass = {
		id = 1,
		name = "Grama",
		color = Color3.fromRGB(34, 139, 34),
		health = 1,
		drop = "none",
		walkable = true,
	},
	dirt = {
		id = 2,
		name = "Terra",
		color = Color3.fromRGB(139, 69, 19),
		health = 1,
		drop = "none",
		walkable = true,
	},
	stone = {
		id = 3,
		name = "Pedra",
		color = Color3.fromRGB(128, 128, 128),
		health = 3,
		drop = "stone",
		walkable = true,
	},
	tree = {
		id = 4,
		name = "Árvore",
		color = Color3.fromRGB(139, 69, 19),
		health = 5,
		drop = "wood",
		walkable = false,
	},
	water = {
		id = 5,
		name = "Água",
		color = Color3.fromRGB(64, 164, 223),
		health = math.huge,
		drop = "none",
		walkable = false,
	},
}

-- Índice reverso para lookup por ID
local idToBlock = {}
for key, def in pairs(BlockDefinitions) do
	idToBlock[def.id] = key
end

function BlockDefinitions.getByID(id)
	return BlockDefinitions[idToBlock[id]]
end

function BlockDefinitions.getID(name)
	return BlockDefinitions[name] and BlockDefinitions[name].id or nil
end

return BlockDefinitions
