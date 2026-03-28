-- init.server.luau
-- Inicialização do servidor

print("🚀 Initializing Survival Game Server...")

local ServerScriptService = game:GetService("ServerScriptService")
local serverFolder = ServerScriptService:FindFirstChild("Server") or ServerScriptService

local function findModuleByName(root, name)
	if not root then return nil end
	local lowerName = name:lower()
	for _, descendant in ipairs(root:GetDescendants()) do
		if (descendant:IsA("ModuleScript") or descendant:IsA("Script")) then
			local descendantName = descendant.Name:lower()
			if descendantName == lowerName or descendantName == lowerName .. ".server" or descendantName == lowerName .. ".server.luau" or descendantName:find(lowerName, 1, true) then
				return descendant
			end
		end
	end
	return nil
end

local function findInServer(name)
	local roots = {
		serverFolder,
		ServerScriptService,
		game:GetService("ReplicatedStorage"),
		game:GetService("ServerStorage"),
	}
	local candidatesNames = {
		name,
		name .. ".server",
		name .. ".server.luau",
		name .. ".luau",
	}

	print("[init] Searching module '", name, "' in service roots")
	print("[init] serverFolder: ", serverFolder:GetFullName())

	for _, root in ipairs(roots) do
		if root then
			print("[init] root = ", root:GetFullName())
			for _, c in ipairs(candidatesNames) do
				local inst = root:FindFirstChild(c)
				if inst then
					print("[init] candidate by exact name found: ", inst:GetFullName(), "(class=", inst.ClassName, ")")
					if inst:IsA("ModuleScript") then
						return inst
					else
						warn("[init] found Script named '"..c.."'; DayNightSystem/MonsterSystem/etc devem ser ModuleScript.")
					end
				end
			end
		end
	end

	local targetLower = name:lower()
	for _, root in ipairs(roots) do
		if root then
			for _, descendant in ipairs(root:GetDescendants()) do
				if descendant:IsA("ModuleScript") or descendant:IsA("Script") then
					local descendantName = descendant.Name:lower()
					if descendantName == targetLower
						or descendantName == targetLower .. ".server"
						or descendantName == targetLower .. ".server.luau"
						or descendantName:find(targetLower, 1, true)
					then
						print("[init] candidate by recursive found: ", descendant:GetFullName(), " (class=", descendant.ClassName, ")")
					if descendant:IsA("ModuleScript") then
						return descendant
					else
						warn("[init] candidate is Script, not ModuleScript; ignore. Convert to ModuleScript for require() to work.")
					end
					end
				end
			end
		end
	end

	-- Debug plus for troubleshooting
	warn("[init] module not found: " .. tostring(name) .. ". listing all script/module names in Server folder and root...")
	for _, root in ipairs({serverFolder, ServerScriptService}) do
		if root then
			for _, descendant in ipairs(root:GetDescendants()) do
				if descendant:IsA("ModuleScript") or descendant:IsA("Script") then
					print("[init] available candidate: ", descendant:GetFullName(), " (", descendant.Name, ")")
				end
			end
		end
	end

	return nil
end

local function getModule(name)
	local inst = findInServer(name)
	if not inst then
		warn("[init] module not found: " .. tostring(name) .. " in ServerScriptService (or Server subfolder)")
		return nil
	end
	print("[init] loaded module: " .. name .. " from " .. inst:GetFullName())
	return require(inst)
end

local function getItemSpawner()
	return getModule("ItemSpawner")
end

local function getTreeSpawner()
	return getModule("TreeSpawner")
end

local function getDayNightSystem()
	return getModule("DayNightSystem")
end

local function getMonsterSystem()
	return getModule("MonsterSystem")
end

local function getConstructionSystem()
	return getModule("ConstructionSystem")
end

-- Inicializar sistemas na ordem correta
local dayNightSystem = getDayNightSystem()
if dayNightSystem then
	dayNightSystem.init()
end

local monsterSystem = getMonsterSystem()
if monsterSystem then
	monsterSystem.init()
end

local itemSpawner = getItemSpawner()
if itemSpawner then
	itemSpawner.startAutoSpawn()
end

local treeSpawner = getTreeSpawner()
if treeSpawner then
	treeSpawner.startAutoSpawn()
end

local playerStats = getModule("PlayerStats")
if playerStats then
	playerStats.init()
end

local itemInteraction = getModule("ItemInteraction")
if itemInteraction then
	print("✅ Item Interaction system loaded")
end

-- Configurar remotes de construção
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BuildStructureRemote = require(ReplicatedStorage.Shared.Remotes.BuildStructure)
local GetAvailableStructuresRemote = require(ReplicatedStorage.Shared.Remotes.GetAvailableStructures)

BuildStructureRemote.OnServerInvoke = function(player, structureId, position)
	local constructionSystem = getConstructionSystem()
	if not constructionSystem then
		return false, "Construction system unavailable"
	end
	return constructionSystem.buildStructure(player, structureId, position)
end

GetAvailableStructuresRemote.OnServerInvoke = function(player)
	local constructionSystem = getConstructionSystem()
	if not constructionSystem then
		return {}
	end
	return constructionSystem.getAvailableStructures(player)
end

print("✅ All systems initialized!")
print("🌍 Survival game is ready!")
print("📋 Features:")
print("  - Item spawning system")
print("  - Tree cutting with physics")
print("  - Day/Night cycle with night counter")
print("  - Monster spawning during night")
print("  - Construction system with snap-to-grid")
