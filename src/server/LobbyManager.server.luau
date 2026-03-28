-- LobbyManager.server.luau
-- Gerencia lobby e matchmaking

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

print("🎮 LobbyManager iniciado...")

-- Criar Lobby no workspace
local lobbyFolder = Instance.new("Folder")
lobbyFolder.Name = "Lobby"
lobbyFolder.Parent = workspace

-- Remotes
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
end

local EnterGameRemote = Instance.new("RemoteFunction")
EnterGameRemote.Name = "EnterGame"
EnterGameRemote.Parent = RemotesFolder

-- Matchmaking zones
local zones = {}
for i = 1, 3 do
	zones[i] = {
		id = i,
		name = "Zone" .. i,
		players = {},
		maxPlayers = 10,
		countdownTime = 15,
		isCountingDown = false,
	}
	
	-- Criar zona visual
	local zoneModel = Instance.new("Part")
	zoneModel.Name = "Zone_" .. i
	zoneModel.Shape = Enum.PartType.Block
	zoneModel.Size = Vector3.new(50, 1, 50)
	zoneModel.Position = Vector3.new((i - 2) * 80, 5, 0)
	zoneModel.CanCollide = false
	zoneModel.Transparency = 0.5
	zoneModel.BrickColor = BrickColor.new("Neon green")
	zoneModel.Parent = lobbyFolder
	zoneModel:SetAttribute("zoneId", i)
end

-- Entrar na zona
EnterGameRemote.OnServerInvoke = function(player, zoneId, groupSize)
	local zone = zones[zoneId]
	if not zone then
		return {success = false, message = "Zona inválida"}
	end
	
	if #zone.players >= zone.maxPlayers then
		return {success = false, message = "Zona cheia"}
	end
	
	table.insert(zone.players, player)
	print("✅ " .. player.Name .. " entrou na " .. zone.name .. " (jogadores: " .. #zone.players .. ")")
	
	-- Iniciar countdown se requisitado
	if groupSize and #zone.players >= groupSize then
		if not zone.isCountingDown then
			zone.isCountingDown = true
			print("🎮 Iniciando matchmaking...")
			-- TODO: Começar jogo
		end
	end
	
	return {success = true, message = "Entrou na zona", zone = zone}
end

print("✅ LobbyManager pronto!")
