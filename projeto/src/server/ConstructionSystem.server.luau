-- ConstructionSystem.server.luau
-- Sistema de construção estilo The Forest

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemDefinitions = require(ReplicatedStorage.Shared.ItemDefinitions)

local ConstructionSystem = {}

local function getInventorySystem()
	local service = game:GetService("ServerScriptService")
	local inventorySystemModule = nil
	if service:FindFirstChild("Server") and service.Server:FindFirstChild("InventorySystem") then
		inventorySystemModule = service.Server.InventorySystem
	elseif service:FindFirstChild("InventorySystem") then
		inventorySystemModule = service.InventorySystem
	end

	if not inventorySystemModule then
		warn("[ConstructionSystem] InventorySystem module not found")
		return nil
	end

	return require(inventorySystemModule)
end

-- Configurações de construção
local CONSTRUCTION_CONFIG = {
	-- Culinária
	cooking = {
		{
			id = "campfire",
			name = "Campfire",
			description = "Basic cooking fire",
			requiredItems = {wood = 5, stone = 3},
			model = "CampfireModel",
			snapPoints = {},
			category = "cooking"
		},
		{
			id = "pot",
			name = "Cooking Pot",
			description = "Used with campfire for cooking",
			requiredItems = {metal = 2, sticks = 4},
			model = "PotModel",
			snapPoints = {campfire = true},
			category = "cooking"
		},
		{
			id = "stove",
			name = "Stove",
			description = "Advanced cooking station",
			requiredItems = {metal = 5, planks = 8, stone = 10},
			model = "StoveModel",
			snapPoints = {},
			category = "cooking"
		}
	},

	-- Defesa
	defense = {
		{
			id = "wooden_spike_wall",
			name = "Wooden Spike Wall",
			description = "Defensive wall with spikes",
			requiredItems = {wood = 8, sticks = 12},
			model = "SpikeWallModel",
			snapPoints = {wooden_spike_wall = true},
			category = "defense"
		},
		{
			id = "bear_trap",
			name = "Bear Trap",
			description = "Traps enemies",
			requiredItems = {metal = 3, sticks = 6},
			model = "BearTrapModel",
			snapPoints = {},
			category = "defense"
		}
	},

	-- Geral
	shelter = {
		{
			id = "wooden_wall",
			name = "Wooden Wall",
			description = "Basic wall",
			requiredItems = {planks = 6, sticks = 4},
			model = "WoodenWallModel",
			snapPoints = {wooden_wall = true, wooden_door = true},
			category = "shelter"
		},
		{
			id = "wooden_door",
			name = "Wooden Door",
			description = "Door for shelter",
			requiredItems = {planks = 8, sticks = 6},
			model = "WoodenDoorModel",
			snapPoints = {wooden_wall = true},
			category = "shelter"
		},
		{
			id = "wooden_floor",
			name = "Wooden Floor",
			description = "Floor for shelter",
			requiredItems = {planks = 12, sticks = 8},
			model = "WoodenFloorModel",
			snapPoints = {wooden_wall = true, wooden_floor = true},
			category = "shelter"
		}
	}
}

-- Estado do sistema
local builtStructures = {}
local structuresFolder = Instance.new("Folder")
structuresFolder.Name = "BuiltStructures"
structuresFolder.Parent = workspace

-- Função para criar modelo de estrutura procedural (fallback)
function ConstructionSystem.createProceduralStructure(structureId: string, config: table, position: CFrame)
	local structureModel = Instance.new("Model")
	structureModel.Name = config.name

	-- Parte principal baseada no tipo
	local mainPart
	if structureId:find("wall") then
		mainPart = Instance.new("Part")
		mainPart.Size = Vector3.new(0.2, 4, 4)
		mainPart.BrickColor = BrickColor.new("Brown")
	elseif structureId:find("floor") then
		mainPart = Instance.new("Part")
		mainPart.Size = Vector3.new(4, 0.2, 4)
		mainPart.BrickColor = BrickColor.new("Brown")
	elseif structureId:find("campfire") then
		mainPart = Instance.new("Part")
		mainPart.Size = Vector3.new(2, 0.5, 2)
		mainPart.BrickColor = BrickColor.new("Black")
		-- Adicionar fogo
		local fire = Instance.new("Fire")
		fire.Size = 5
		fire.Parent = mainPart
	elseif structureId:find("pot") then
		mainPart = Instance.new("Part")
		mainPart.Size = Vector3.new(1, 0.5, 1)
		mainPart.BrickColor = BrickColor.new("Dark stone grey")
	elseif structureId:find("trap") then
		mainPart = Instance.new("Part")
		mainPart.Size = Vector3.new(2, 0.2, 2)
		mainPart.BrickColor = BrickColor.new("Really black")
	else
		mainPart = Instance.new("Part")
		mainPart.Size = Vector3.new(2, 2, 2)
		mainPart.BrickColor = BrickColor.new("Brown")
	end

	mainPart.Anchored = true
	mainPart.CanCollide = true
	mainPart.Position = position.Position
	mainPart.CFrame = position
	mainPart.Parent = structureModel

	-- Adicionar dados da estrutura
	local idData = Instance.new("StringValue")
	idData.Name = "StructureId"
	idData.Value = structureId
	idData.Parent = structureModel

	local configData = Instance.new("StringValue")
	configData.Name = "Config"
	configData.Value = game:GetService("HttpService"):JSONEncode(config)
	configData.Parent = structureModel

	return structureModel
end

-- Função para verificar se jogador tem itens necessários
function ConstructionSystem.hasRequiredItems(player: Player, requiredItems: table): boolean
	local InventorySystem = getInventorySystem()
	if not InventorySystem then return false end

	for itemId, amount in pairs(requiredItems) do
		local playerAmount = InventorySystem.getItemCount(player, itemId)
		if playerAmount < amount then
			return false
		end
	end

	return true
end

-- Função para remover itens do jogador
function ConstructionSystem.removeRequiredItems(player: Player, requiredItems: table): boolean
	local InventorySystem = getInventorySystem()
	if not InventorySystem then return false end

	for itemId, amount in pairs(requiredItems) do
		if not InventorySystem.removeItem(player, itemId, amount) then
			return false
		end
	end

	return true
end

-- Função para encontrar ponto de snap próximo
function ConstructionSystem.findSnapPoint(position: Vector3, structureId: string, config: table): CFrame?
	-- Procurar estruturas próximas que podem fazer snap
	for _, structure in pairs(builtStructures) do
		if structure.Parent and structure:FindFirstChild("StructureId") then
			local otherId = structure.StructureId.Value
			local otherConfig = game:GetService("HttpService"):JSONDecode(structure.Config.Value)

			-- Verificar se pode fazer snap
			if config.snapPoints[otherId] or otherConfig.snapPoints[structureId] then
				local distance = (structure:GetPivot().Position - position).Magnitude
				if distance < 6 then -- Raio de snap
					-- Calcular posição de snap (simplificado)
					local direction = (position - structure:GetPivot().Position).Unit
					local snapPosition = structure:GetPivot().Position + direction * 4
					return CFrame.new(snapPosition) * (structure:GetPivot().Rotation)
				end
			end
		end
	end

	return nil
end

-- Função para construir estrutura
function ConstructionSystem.buildStructure(player: Player, structureId: string, position)
	-- Accept Vector3 or CFrame
	if typeof(position) == "Vector3" then
		position = CFrame.new(position)
	elseif typeof(position) == "CFrame" then
		-- nothing
	else
		warn("Invalid position type for buildStructure: " .. typeof(position))
		return false
	end

	-- Encontrar configuração da estrutura
	local config = nil
	local category = nil

	for catName, categoryItems in pairs(CONSTRUCTION_CONFIG) do
		for _, item in pairs(categoryItems) do
			if item.id == structureId then
				config = item
				category = catName
				break
			end
		end
		if config then break end
	end

	if not config then
		print("❌ Structure config not found: " .. structureId)
		return false
	end

	-- Verificar itens necessários
	if not ConstructionSystem.hasRequiredItems(player, config.requiredItems) then
		print("❌ Player doesn't have required items for " .. structureId)
		return false
	end

	-- Aplicar snap se possível
	local snapPosition = ConstructionSystem.findSnapPoint(position.Position, structureId, config)
	if snapPosition then
		position = snapPosition
	end

	-- Criar modelo da estrutura
	local structureModel

	-- Tentar usar modelo customizado se existir
	local customModel = workspace:FindFirstChild(config.model)
	if customModel and customModel:IsA("Model") then
		structureModel = customModel:Clone()
		structureModel:PivotTo(position)
	else
		-- Usar modelo procedural
		structureModel = ConstructionSystem.createProceduralStructure(structureId, config, position)
	end

	if structureModel then
		-- Remover itens do jogador
		if not ConstructionSystem.removeRequiredItems(player, config.requiredItems) then
			structureModel:Destroy()
			return false
		end

		-- Adicionar à lista de estruturas construídas
		table.insert(builtStructures, structureModel)

		structureModel.Parent = structuresFolder

		-- Sistema de interação (para estruturas especiais)
		if structureId == "campfire" then
			local interactScript = Instance.new("Script")
			interactScript.Name = "CampfireLogic"
			interactScript.Source = [[
				local campfire = script.Parent
				local fire = campfire:FindFirstChildWhichIsA("Fire")

				-- Luz da fogueira
				local light = Instance.new("PointLight")
				light.Brightness = 0.5
				light.Range = 15
				light.Color = Color3.fromRGB(255, 150, 50)
				light.Parent = campfire

				-- Manter fogo aceso
				while true do
					if fire then
						fire.Enabled = true
					end
					wait(1)
				end
			]]
			interactScript.Parent = structureModel
		end

		print("🏗️ " .. player.Name .. " built " .. config.name .. " at " .. tostring(position.Position))
		return true
	end

	return false
end

-- Função para destruir estrutura
function ConstructionSystem.destroyStructure(player: Player, structureModel: Model): boolean
	if not structureModel or not structureModel.Parent then return false end

	-- Remover da lista
	for i, structure in pairs(builtStructures) do
		if structure == structureModel then
			table.remove(builtStructures, i)
			break
		end
	end

	-- Dropar alguns materiais de volta
	local config = game:GetService("HttpService"):JSONDecode(structureModel.Config.Value)
	local itemSpawnerModule = nil
	local service = game:GetService("ServerScriptService")
	if service:FindFirstChild("Server") and service.Server:FindFirstChild("ItemSpawner") then
		itemSpawnerModule = service.Server.ItemSpawner
	elseif service:FindFirstChild("ItemSpawner") then
		itemSpawnerModule = service.ItemSpawner
	end

	if not itemSpawnerModule then
		warn("[ConstructionSystem] ItemSpawner module not found")
		return false
	end

	local ItemSpawner = require(itemSpawnerModule)

	for itemId, amount in pairs(config.requiredItems) do
		local dropAmount = math.floor(amount * 0.5) -- 50% de retorno
		if dropAmount > 0 then
			ItemSpawner.spawnItemAt(itemId, dropAmount, structureModel:GetPivot().Position)
		end
	end

	structureModel:Destroy()
	print("💥 " .. player.Name .. " destroyed a structure")
	return true
end

-- Função para obter estruturas disponíveis para construção
function ConstructionSystem.getAvailableStructures(player: Player): table
	local available = {}

	for categoryName, category in pairs(CONSTRUCTION_CONFIG) do
		available[categoryName] = {}

		for _, structure in pairs(category) do
			local canBuild = ConstructionSystem.hasRequiredItems(player, structure.requiredItems)
			local entry = table.clone(structure)
			entry.canBuild = canBuild
			table.insert(available[categoryName], entry)
		end
	end

	return available
end

return ConstructionSystem