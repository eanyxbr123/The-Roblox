-- WorldGenerator.luau
-- Gera mundo procedural com noise

local WorldGenerator = {}

-- Configuração
local CHUNK_SIZE = 16
local BLOCK_SIZE = 4
local NOISE_SCALE = 0.1
local WATER_LEVEL = 10

function WorldGenerator.getChunkKey(chunkX, chunkZ)
	return chunkX .. "," .. chunkZ
end

function WorldGenerator.getWorldCoords(blockX, blockY, blockZ)
	return blockX * BLOCK_SIZE, blockY * BLOCK_SIZE, blockZ * BLOCK_SIZE
end

function WorldGenerator.getBlockType(x, y, z, seed)
	seed = seed or 0
	
	-- Usar Perlin noise para gerar altura
	local noiseValue = math.noise(x * NOISE_SCALE, z * NOISE_SCALE, seed)
	local height = math.floor(20 + noiseValue * 10)
	
	if y > height then
		return "air"
	elseif y == height then
		if noiseValue > 0.3 then
			return "tree"  -- Árvores em áreas elevadas
		else
			return "grass"
		end
	elseif y > height - 3 then
		return "dirt"
	else
		return "stone"
	end
end

function WorldGenerator.generateChunk(chunkX, chunkZ, seed)
	local blocks = {}
	
	for localX = 0, CHUNK_SIZE - 1 do
		for localZ = 0, CHUNK_SIZE - 1 do
			for y = 0, 30 do
				local worldX = chunkX * CHUNK_SIZE + localX
				local worldZ = chunkZ * CHUNK_SIZE + localZ
				
				local blockType = WorldGenerator.getBlockType(worldX, y, worldZ, seed)
				
				if blockType ~= "air" then
					local key = localX .. "," .. y .. "," .. localZ
					blocks[key] = blockType
				end
			end
		end
	end
	
	return {
		chunkX = chunkX,
		chunkZ = chunkZ,
		blocks = blocks,
		size = CHUNK_SIZE,
	}
end

WorldGenerator.CHUNK_SIZE = CHUNK_SIZE
WorldGenerator.BLOCK_SIZE = BLOCK_SIZE

return WorldGenerator
