--[[
	AdminScript.lua
	-----------------------------------
	Author: ThunderGemios10
--]]

-- SERVICES
local Players = game:GetService("Players")
local GroupService = game:GetService("GroupService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- DEFINITIONS
local Gui = script:WaitForChild("AdminGui")
local remoteEvent = Instance.new("RemoteEvent")
remoteEvent.Parent = ReplicatedStorage
local clientEvent = Instance.new("RemoteEvent")
clientEvent.Name = "ClientEvent"
clientEvent.Parent = ReplicatedStorage

-- VARIABLES
local groupId = 0000000 -- Group ID [[0000000]] 
local role = 255 -- Minimum role that can access the admin panel.
local groupInfo = GroupService:GetGroupInfoAsync(groupId)

-- TABLES
local remoteEvents = {}
local admins = {}
local orders = {}

-- SCRIPT
local function playerAdded(player)
	local rank = player:GetRankInGroup(groupId)
	
	-- Check if they are an admin.
	if admins[tostring(player.UserId)] or rank >= role then
		admins[tostring(player.UserId)] = tick()
		
		-- Gui
		local clone = Gui:Clone()
		clone.Parent = player.PlayerGui
	end
end

local function getValueFromTable(tableName, input)
	for index, value in pairs(tableName) do
		if value == input then
			return value
		end
	end
end

local function getPlayerByName(input)
	for _, player in pairs(Players:GetPlayers()) do
		if player.Name == input then
			return player
		end
	end
end

local function createNewOrder(player, dishName)
	local PlayerGui = player:WaitForChild("PlayerGui")
	local adminGui = PlayerGui:WaitForChild("AdminGui")
	
	local frame = Instance.new("Frame")
	frame.Name = player.Name
	frame.BackgroundColor3 = Color3.new(255, 255, 255)
	frame.BorderSizePixel = 0
	frame.Size = UDim2.new(0, 300, 0, 100)
	frame.LayoutOrder = #orders + 1
	frame.Parent = adminGui.Panel.Menu.Orders.Inbox
	
	local avatar = Instance.new("ImageLabel")
	avatar.Name = "Avatar"
	avatar.BackgroundColor3 = Color3.new(255, 255, 255)
	avatar.BackgroundTransparency = 1
	avatar.BorderSizePixel = 0
	avatar.Position = UDim2.new(0, 10, 0, 0)
	avatar.Size = UDim2.new(0, 60, 0, 60)
	avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png"
	avatar.ZIndex = 2
	avatar.Parent = frame
	
	local username = Instance.new("TextLabel")
	username.Name = "Player"
	username.BackgroundColor3 = Color3.new(255, 255, 255)
	username.BackgroundTransparency = 1
	username.Font = Enum.Font.GothamBold
	username.Text = player.Name
	username.TextSize = 24
	username.TextWrapped = true
	username.Position = UDim2.new(0.5, -90, 0, 10)
	username.Size = UDim2.new(0, 240, 0, 50)
	username.ZIndex = 2
	username.Parent = frame
	
	local dish = Instance.new("TextLabel")
	dish.Name = "Dish"
	dish.BackgroundColor3 = Color3.new(255, 255, 255)
	dish.BackgroundTransparency = 1
	dish.Font = Enum.Font.GothamBold
	dish.Text = dishName
	dish.TextSize = 14
	dish.TextWrapped = true
	dish.Position = UDim2.new(0.5, -90, 1, -50)
	dish.Size = UDim2.new(0, 240, 0, 50)
	dish.ZIndex = 2
	dish.Parent = frame
	
	local button = Instance.new("ImageButton")
	button.Name = "Button"
	button.BackgroundColor3 = Color3.new(255, 255, 255)
	button.BorderSizePixel = 0
	button.Size = UDim2.new(1, 0, 1, 0)
	button.ZIndex = 1
	button.ImageTransparency = 1
	button.Parent = frame
	
	table.insert(orders, 1, frame.LayoutOrder)
	
	-- CONNECTIONS
	button.MouseButton1Click:Connect(function()
		clientEvent:FireClient(player, "acceptOrder", frame.LayoutOrder)
		table.remove(orders, getValueFromTable(orders, frame.LayoutOrder))
	end)
end 

-- REMOTE EVENTS
remoteEvents.Order = function(player, dish)
	for admin, timeStamp in pairs(admins) do
		admin = Players:GetPlayerByUserId(admin)
		createNewOrder(admin, dish)
	end
end

remoteEvents.giveDish = function(player, targetPlayer, dish)
	local dishes = ServerStorage:WaitForChild("Dishes")
	dish = dishes:WaitForChild(dish)
	targetPlayer = getPlayerByName(targetPlayer)
	
	local clone = dish:Clone()
	clone.Parent = targetPlayer.Backpack
	
	clientEvent:FireClient(targetPlayer, "sendMessage", "You have been served by "..player.Name, targetPlayer)
end

-- EXEC
for _, player in pairs(Players:GetPlayers()) do
	playerAdded(player)
end
remoteEvent.OnServerEvent:Connect(function(player, event, ...)
	if admins[tostring(player.UserId)] ~= nil then
		remoteEvents[event](player, ...)
	end
end)

-- CONNECTIONS
Players.PlayerAdded:Connect(playerAdded)