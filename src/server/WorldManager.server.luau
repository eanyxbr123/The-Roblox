-- WorldManager.server.luau
-- Gerencia o mundo, chunks e blocos

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WorldGenerator = require(ReplicatedStorage.Shared.WorldGenerator)
local BlockDefinitions = require(ReplicatedStorage.Shared.BlockDefinitions)

print("🌍 WorldManager iniciado...")

-- Armazenar chunks em memória
local loadedChunks = {}

-- Pasta de blocos no mundo
local worldFolder = Instance.new("Folder")
worldFolder.Name = "World"
worldFolder.Parent = workspace

-- Criar ou carregar um chunk
local function getOrCreateChunk(chunkX, chunkZ)
	local key = WorldGenerator.getChunkKey(chunkX, chunkZ)
	
	if not loadedChunks[key] then
		print("📦 Gerando chunk " .. key)
		loadedChunks[key] = WorldGenerator.generateChunk(chunkX, chunkZ, 12345)
		renderChunk(chunkX, chunkZ)
	end
	
	return loadedChunks[key]
end

-- Renderizar um chunk no mundo
function renderChunk(chunkX, chunkZ)
	local chunk = loadedChunks[WorldGenerator.getChunkKey(chunkX, chunkZ)]
	if not chunk then return end
	
	local chunkFolder = Instance.new("Folder")
	chunkFolder.Name = "Chunk_" .. chunkX .. "_" .. chunkZ
	chunkFolder.Parent = worldFolder
	
	for key, blockType in pairs(chunk.blocks) do
		local localX, y, localZ = key:match("(.+),(.+),(.+)")
		localX, y, localZ = tonumber(localX), tonumber(y), tonumber(localZ)
		
		local worldX = chunkX * WorldGenerator.CHUNK_SIZE + localX
		local worldZ = chunkZ * WorldGenerator.CHUNK_SIZE + localZ
		
		local blockDef = BlockDefinitions[blockType]
		if blockDef then
			local block = Instance.new("Part")
			block.Name = blockType
			block.Shape = Enum.PartType.Block
			block.Size = Vector3.new(WorldGenerator.BLOCK_SIZE, WorldGenerator.BLOCK_SIZE, WorldGenerator.BLOCK_SIZE)
			block.Color = blockDef.color
			block.Position = Vector3.new(
				WorldGenerator.getWorldCoords(worldX, 0, 0),
				WorldGenerator.getWorldCoords(0, y, 0),
				WorldGenerator.getWorldCoords(0, 0, worldZ)
			)
			block.CanCollide = blockDef.walkable
			block.TopSurface = Enum.SurfaceType.Smooth
			block.BottomSurface = Enum.SurfaceType.Smooth
			
			block:SetAttribute("blockType", blockType)
			block:SetAttribute("worldX", worldX)
			block:SetAttribute("worldY", y)
			block:SetAttribute("worldZ", worldZ)
			block:SetAttribute("health", blockDef.health)
			
			block.Parent = chunkFolder
		end
	end
	
	print("✅ Chunk renderizado: " .. chunkX .. "," .. chunkZ)
end

-- Carregar chunks em volta do jogador
local function loadChunksAroundPlayer(player, radius)
	if not player.Character then return end
	
	local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end
	
	local pos = humanoidRootPart.Position
	local blockSize = WorldGenerator.BLOCK_SIZE
	local chunkSize = WorldGenerator.CHUNK_SIZE * blockSize
	
	local chunkX = math.floor(pos.X / chunkSize)
	local chunkZ = math.floor(pos.Z / chunkSize)
	
	for x = chunkX - radius, chunkX + radius do
		for z = chunkZ - radius, chunkZ + radius do
			getOrCreateChunk(x, z)
		end
	end
end

-- Spawnar primeiro chunk
getOrCreateChunk(0, 0)
getOrCreateChunk(1, 0)
getOrCreateChunk(0, 1)
getOrCreateChunk(-1, 0)
getOrCreateChunk(0, -1)

-- Carregar chunks em volta de jogadores a cada segundo
game:GetService("RunService").Heartbeat:Connect(function()
	for _, player in pairs(game:GetService("Players"):GetPlayers()) do
		loadChunksAroundPlayer(player, 2)
	end
end)

print("✅ WorldManager pronto!")
