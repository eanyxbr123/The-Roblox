-- MiningClient.client.luau
-- Cliente para mineração de blocos

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Remotes
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local MineBlockRemote = RemotesFolder:WaitForChild("MineBlock")

print("⛏️  MiningClient pronto")

-- Sistema de clique para mineração
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if mouse.Target then
			local target = mouse.Target
			
			-- Se é um bloco no mundo
			if target:GetAttribute("blockType") then
				print("🎯 Clicou em bloco: " .. target.Name)
				
				local result = MineBlockRemote:InvokeServer(target)
				
				if result and result.success then
					print("✅ " .. result.message)
				else
					print("❌ " .. (result and result.message or "Erro desconhecido"))
				end
			end
		end
	end
end)
