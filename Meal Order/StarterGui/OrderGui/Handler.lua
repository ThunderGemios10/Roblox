--[[
	Handler.lua
	-----------------------------------
	Author: ThunderGemios10
--]]

-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- DEFINITIONS
local localPlayer = Players.LocalPlayer
local Gui = script.Parent
local Config = Gui:WaitForChild("Config")
local guiButtons = Gui:WaitForChild("Buttons")
local frameWelcome = Gui:WaitForChild("Welcome")
local frameMenu = Gui:WaitForChild("Menu")
local frameButtons = frameMenu:WaitForChild("Buttons")
local frameMeals = frameMenu:WaitForChild("Meals")
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent")

-- IMPORT
local Settings = require(Config.Settings)

-- VARIABLES
local prefixMessage = "[OrderHandler] "

local buttons = {}
local menus = {}
local dishes = {}

-- SCRIPT
local function init()
	-- Initialize buttons and menus
	for category, dish in pairs(Settings.Items.Categories) do
		
		-- CATEGORIES
		local categoryButton = Instance.new("TextButton")
		-- DATA
		categoryButton.Name = category
		categoryButton.Size = Settings.TextButton.Size
		categoryButton.BackgroundColor3 = Settings.TextButton.BackgroundColor3
		categoryButton.BorderSizePixel = Settings.TextButton.Size
		categoryButton.Parent = frameButtons
		categoryButton.LayoutOrder = #buttons + 1
		table.insert(buttons, 1, categoryButton)
		
		-- TEXT
		categoryButton.Font = Enum.Font.GothamBold
		categoryButton.Text = category:upper()
		categoryButton.TextColor3 = Color3.new(255, 255, 255)
		categoryButton.TextSize = 14
		
		-- FRAME
		local scrollingFrame = Instance.new("ScrollingFrame")
		-- DATA
		scrollingFrame.Name = category
		scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
		scrollingFrame.BorderSizePixel = 0
		scrollingFrame.Parent = frameMeals
		scrollingFrame.Visible = false
		menus[categoryButton] = scrollingFrame
		
		local uiListLayout = Instance.new("UIListLayout")
		uiListLayout.Parent = scrollingFrame
		uiListLayout.Padding = UDim.new(0, 10)
		uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		print(categoryButton)
		
		-- DISHES
		for key, value in pairs(dish) do
			local dishButton = Instance.new("TextButton")
			-- DATA
			dishButton.Name = key
			dishButton.Size = Settings.TextButton.Size
			dishButton.BackgroundColor3 = Settings.TextButton.BackgroundColor3
			dishButton.BorderSizePixel = Settings.TextButton.BorderSizePixel
			dishButton.Parent = frameMeals:FindFirstChild(category)
			dishButton.LayoutOrder = #dishes + 1
			
			-- TEXT
			dishButton.Font = Enum.Font.GothamBold
			dishButton.Text = key:upper()
			dishButton.TextColor3 = Settings.TextButton.TextColor3
			dishButton.TextSize = Settings.TextButton.TextSize
			dishButton.TextWrapped = Settings.TextButton.TextWrapped
			table.insert(dishes, 1, dishButton)
			
			-- CONNECTIONS
			dishButton.MouseButton1Click:Connect(function()
				remoteEvent:FireServer("Order", key)
			end)
		end
	end
	
	-- CONNECTIONS
	for button, frame in pairs(menus) do
		button.MouseButton1Click:Connect(function()
			-- Check if ScrollingFrame is visible.
			if frame.Visible then
				-- If it is, then set its visibility to false.
				frame.Visible = false
				return
			end
			
			for _, v in pairs(menus) do
				v.Visible = v == frame
			end
		end)
	end
	
	-- CONNECTIONS
	guiButtons.Toggle.MouseButton1Click:Connect(function()
		frameWelcome.Visible = not frameWelcome.Visible
		guiButtons.Visible = not guiButtons.Visible
	end)
	frameMenu.Close.MouseButton1Click:Connect(function()
		frameMenu.Visible = false
		guiButtons.Visible = true
	end)
	frameWelcome.Next.MouseButton1Click:Connect(function()
		frameWelcome.Visible = false
		frameMenu.Visible = true
	end)
end

-- INIT
spawn(init)