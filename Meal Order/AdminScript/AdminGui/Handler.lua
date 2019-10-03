--[[
	Handler.lua
	-----------------------------------
	Author: ThunderGemios10
--]]

-- SERVICES
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- DEFINITIONS
local localPlayer = Players.LocalPlayer
local Gui = script.Parent
local frameButtons = Gui:WaitForChild("Buttons")
local framePanel = Gui:WaitForChild("Panel")
local frameMenu = framePanel:WaitForChild("Menu")
local frameOrders = frameMenu:WaitForChild("Orders")
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent")
local clientEvent = ReplicatedStorage:WaitForChild("ClientEvent")

-- VARIABLES
local remoteEvents = {}

-- SCRIPT
local function init()
	-- CONNECTIONS
	frameButtons.Toggle.MouseButton1Click:Connect(function()
		framePanel.Visible = not framePanel.Visible
	end)
	framePanel.Buttons.Orders.MouseButton1Click:Connect(function()
		frameMenu.Orders.Visible = not frameMenu.Orders.Visible
	end)
end

local function acceptOrder(value)
	local targetPlayer = nil
	local dish = nil
	
	for _, order in pairs(frameOrders.Inbox:GetChildren()) do
		if order:IsA("Frame") and order.LayoutOrder == value then
			targetPlayer = order.Player.Text
			dish = order.Dish.Text
			order:Destroy()
		end
	end
	
	remoteEvent:FireServer("giveDish", targetPlayer, dish)
end

local function createNewMessage(message, targetPlayer)
	local playerGui = targetPlayer:WaitForChild("PlayerGui")
	
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundColor3 = Color3.new(255, 255, 255)
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Text = message
	textLabel.TextSize = 14
	textLabel.TextWrapped = true
	textLabel.Parent = playerGui:WaitForChild("OrderGui"):WaitForChild("Message")
	
	return textLabel
end

-- REMOTE EVENTS
remoteEvents.acceptOrder = function(order)
	acceptOrder(order)
end

remoteEvents.sendMessage = function(message, targetPlayer)
	Debris:AddItem(createNewMessage(message, targetPlayer), 5)
end

-- INIT
spawn(init)
clientEvent.OnClientEvent:Connect(function(event, ...)
	remoteEvents[event](...)
end)