-- DayNightSystem.server.luau
-- Sistema de contagem de dias e noites estilo 99 Nights

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DayNightSystem = {}

-- Configurações
local TIME_CONFIG = {
	dayLength = 600, -- segundos (10 minutos)
	nightLength = 300, -- segundos (5 minutos)
	dawnDuskLength = 60, -- segundos (1 minuto)
	totalCycleLength = 960, -- segundos totais por ciclo

	-- Eventos
	onNightStart = Instance.new("BindableEvent"),
	onDayStart = Instance.new("BindableEvent"),
	onNightPassed = Instance.new("BindableEvent"),
}

-- Estado do sistema
local currentTime = 0
local isNight = false
local nightCount = 0
local dayCount = 1

-- Valores remotos para sincronização com cliente
local TimeValue = Instance.new("NumberValue")
TimeValue.Name = "CurrentTime"
TimeValue.Value = 0
TimeValue.Parent = ReplicatedStorage

local IsNightValue = Instance.new("BoolValue")
IsNightValue.Name = "IsNight"
IsNightValue.Value = false
IsNightValue.Parent = ReplicatedStorage

local NightCountValue = Instance.new("IntValue")
NightCountValue.Name = "NightCount"
NightCountValue.Value = 0
NightCountValue.Parent = ReplicatedStorage

local DayCountValue = Instance.new("IntValue")
DayCountValue.Name = "DayCount"
DayCountValue.Value = 1
DayCountValue.Parent = ReplicatedStorage

-- Função para calcular se é noite baseado no tempo
local function calculateIsNight(time: number): boolean
	local cycleTime = time % TIME_CONFIG.totalCycleLength
	local dayTime = TIME_CONFIG.dayLength + TIME_CONFIG.dawnDuskLength

	return cycleTime >= dayTime
end

-- Função para atualizar iluminação baseada no tempo
local function updateLighting(time: number)
	local cycleTime = time % TIME_CONFIG.totalCycleLength
	local lighting = game:GetService("Lighting")

	if calculateIsNight(time) then
		-- Noite
		lighting.TimeOfDay = "00:00:00"
		lighting.Brightness = 0.1
		lighting.Ambient = Color3.fromRGB(50, 50, 80)
		lighting.OutdoorAmbient = Color3.fromRGB(30, 30, 50)
	else
		-- Dia
		local dayProgress = (cycleTime / TIME_CONFIG.dayLength)
		local brightness = 0.5 + (dayProgress * 0.5) -- 0.5 a 1.0

		lighting.TimeOfDay = "12:00:00"
		lighting.Brightness = brightness
		lighting.Ambient = Color3.fromRGB(150, 150, 200)
		lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 150)
	end
end

-- Função principal do loop de tempo
function DayNightSystem.startTimeLoop()
	task.spawn(function()
		while true do
			currentTime = currentTime + 1
			TimeValue.Value = currentTime

			local wasNight = isNight
			isNight = calculateIsNight(currentTime)

			-- Verificar transição noite/dia
			if isNight and not wasNight then
				-- Início da noite
				nightCount = nightCount + 1
				NightCountValue.Value = nightCount
				IsNightValue.Value = true

				TIME_CONFIG.onNightStart:Fire(nightCount)

				-- Mensagem para jogadores
				for _, player in pairs(game.Players:GetPlayers()) do
					local message = "🌙 Night " .. nightCount .. " has begun. Stay safe!"
					if nightCount <= 10 then
						message = message .. " (Monsters fear light... for now)"
					elseif nightCount == 11 then
						message = "⚠️ The cannibals seem less afraid of light now. SURVIVE!"
					end

					-- Enviar notificação (implementar sistema de UI depois)
					print("NOTIFICATION: " .. message)
				end

				print("🌙 Night " .. nightCount .. " started")

			elseif not isNight and wasNight then
				-- Início do dia
				dayCount = dayCount + 1
				DayCountValue.Value = dayCount
				IsNightValue.Value = false

				TIME_CONFIG.onDayStart:Fire(dayCount)

				-- Mensagem para jogadores
				for _, player in pairs(game.Players:GetPlayers()) do
					local message = "☀️ Day " .. dayCount .. " has begun. Gather resources!"
					print("NOTIFICATION: " .. message)
				end

				print("☀️ Day " .. dayCount .. " started")
			end

			-- Atualizar iluminação
			updateLighting(currentTime)

			wait(1) -- Atualizar a cada segundo
		end
	end)
end

-- Funções getter
function DayNightSystem.getCurrentTime()
	return currentTime
end

function DayNightSystem.getNightCount()
	return nightCount
end

function DayNightSystem.getDayCount()
	return dayCount
end

function DayNightSystem.isNight()
	return isNight
end

-- Eventos
function DayNightSystem.onNightStart(callback: (number) -> ())
	return TIME_CONFIG.onNightStart.Event:Connect(callback)
end

function DayNightSystem.onDayStart(callback: (number) -> ())
	return TIME_CONFIG.onDayStart.Event:Connect(callback)
end

function DayNightSystem.onNightPassed(callback: (number) -> ())
	return TIME_CONFIG.onNightPassed.Event:Connect(callback)
end

-- Inicialização
function DayNightSystem.init()
	DayNightSystem.startTimeLoop()
	print("⏰ Day/Night system initialized")
end

return DayNightSystem