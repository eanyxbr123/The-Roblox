-- DayNightSystem.server.luau
-- Controla ciclo dia/noite

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

print("🌙 DayNightSystem iniciado...")

local DayNightSystem = {}

-- Configuração
DayNightSystem.cycleDuration = 60 -- 60 segundos por ciclo
DayNightSystem.dayDuration = 30
DayNightSystem.nightDuration = 30
DayNightSystem.isNight = false
DayNightSystem.currentNight = 0
DayNightSystem.maxNights = 99

-- Remotes
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
end

local DayNightChangedEvent = Instance.new("RemoteEvent")
DayNightChangedEvent.Name = "DayNightChanged"
DayNightChangedEvent.Parent = RemotesFolder

-- Mudar para noite
local function setNight(night)
	DayNightSystem.isNight = true
	DayNightSystem.currentNight = night
	
	-- Mudar lighting
	Lighting.Brightness = 0.2
	Lighting.Ambient = Color3.fromRGB(100, 100, 150)
	
	print("🌙 Noite " .. night .. " / " .. DayNightSystem.maxNights)
	DayNightChangedEvent:FireAllClients({
		isNight = true,
		night = night,
		maxNights = DayNightSystem.maxNights,
	})
end

-- Mudar para dia
local function setDay()
	DayNightSystem.isNight = false
	
	-- Mudar lighting
	Lighting.Brightness = 1.5
	Lighting.Ambient = Color3.fromRGB(200, 200, 200)
	
	print("☀️ Dia começou")
	DayNightChangedEvent:FireAllClients({
		isNight = false,
		night = DayNightSystem.currentNight,
		maxNights = DayNightSystem.maxNights,
	})
end

-- Loop de ciclo
local elapsedTime = 0
game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
	elapsedTime = elapsedTime + deltaTime
	
	if elapsedTime >= DayNightSystem.cycleDuration then
		elapsedTime = 0
		
		if DayNightSystem.isNight then
			setDay()
		else
			DayNightSystem.currentNight = DayNightSystem.currentNight + 1
			if DayNightSystem.currentNight > DayNightSystem.maxNights then
				DayNightSystem.currentNight = 1
			end
			setNight(DayNightSystem.currentNight)
		end
	end
end)

-- Começar com dia
setDay()

print("✅ DayNightSystem pronto!")
return DayNightSystem
