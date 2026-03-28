-- SoundSystem.server.luau
-- Rastreia volume de áudio no servidor

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

print("🔊 SoundSystem iniciado...")

-- Remotes
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
end

local SoundChangedEvent = Instance.new("RemoteEvent")
SoundChangedEvent.Name = "SoundChanged"
SoundChangedEvent.Parent = RemotesFolder

local ReportSoundRemote = Instance.new("RemoteFunction")
ReportSoundRemote.Name = "ReportSound"
ReportSoundRemote.Parent = RemotesFolder

-- Rastrear som de cada jogador
local playerSounds = {}

-- Reportar som
ReportSoundRemote.OnServerInvoke = function(player, soundLevel, position)
	playerSounds[player] = {
		level = soundLevel, -- 1-100
		position = position,
		timestamp = tick(),
	}
	
	-- Notificar mobs próximos
	local mobs = workspace:FindFirstChild("World") and workspace.World:GetChildren() or {}
	for _, mob in pairs(mobs) do
		if mob:FindFirstChild("Humanoid") then
			local mobPos = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChildOfClass("Part")
			if mobPos then
				local dist = (mobPos.Position - position).Magnitude
				-- Mob ouve som se soundLevel é alto E está próximo
				if soundLevel > 50 and dist < soundLevel * 2 then
					-- TODO: Mob vai investigar
					print("🔊 Mob ouviu som! Level: " .. soundLevel)
				end
			end
		end
	end
	
	return {success = true}
end

print("✅ SoundSystem pronto!")
