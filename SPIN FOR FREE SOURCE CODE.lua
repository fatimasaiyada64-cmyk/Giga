local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove old GUI if it already exists
if playerGui:FindFirstChild("GameAutomationGUI") then
    playerGui.GameAutomationGUI:Destroy()
end

-- Create GUI Screen
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GameAutomationGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 420)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
title.Text = "Game Automation Panel"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

-- Container for toggles and dropdowns
local container = Instance.new("ScrollingFrame")
container.Size = UDim2.new(1, -20, 1, -55)
container.Position = UDim2.new(0, 10, 0, 45)
container.BackgroundTransparency = 1
container.CanvasSize = UDim2.new(0, 0, 0, 480)
container.ScrollBarThickness = 4
container.Parent = mainFrame

local uiList = Instance.new("UIListLayout")
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Padding = UDim.new(0, 10)
uiList.Parent = container

-- Function to create Toggle Buttons
local function createToggle(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    btn.TextSize, btn.Font = 14, Enum.Font.GothamSemibold
    btn.Parent = container
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn
    
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            btn.Text = name .. ": ON"
            btn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            btn.Text = name .. ": OFF"
            btn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        callback(enabled)
    end)
end

-- State variables
local autoFlyEnabled = false
local autoClaimEnabled = false
local autoSpinEnabled = false
local autoGlassEnabled = false
local selectedSpinType = "NORMAL SPIN"

-- 1. Auto Flight Toggle
createToggle("Auto Fly to Target", function(state)
    autoFlyEnabled = state
    if autoFlyEnabled then
        task.spawn(function()
            while autoFlyEnabled do
                local character = player.Character or player.CharacterAdded:Wait()
                local humanoid = character:WaitForChild("Humanoid")
                local root = character:WaitForChild("HumanoidRootPart")

                local destination = Vector3.new(24.7, -5, -375.9)
                local approachPoint = destination + Vector3.new(0, 8, 0)
                local speed = 55

                local attachment = Instance.new("Attachment")
                attachment.Parent = root

                local flight = Instance.new("LinearVelocity")
                flight.Attachment0 = attachment
                flight.RelativeTo = Enum.ActuatorRelativeTo.World
                flight.ForceLimitsEnabled = false
                flight.VectorVelocity = Vector3.zero
                flight.Parent = root

                local wasPlatformStanding = humanoid.PlatformStand
                humanoid.PlatformStand = true

                local function flyTo(target)
                    while root.Parent and autoFlyEnabled do
                        local delta = target - root.Position
                        local distance = delta.Magnitude
                        if distance < 1 then break end
                        local dt = RunService.Heartbeat:Wait()
                        flight.VectorVelocity = delta.Unit * math.min(speed, distance / dt)
                    end
                    flight.VectorVelocity = Vector3.zero
                end

                flyTo(approachPoint)
                if autoFlyEnabled then flyTo(destination) end

                flight:Destroy()
                attachment:Destroy()
                humanoid.PlatformStand = wasPlatformStanding
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

                task.wait(5)
            end
        end)
    end
end)

-- 2. Auto Claim Playtime Rewards Toggle
createToggle("Auto Claim Playtime", function(state)
    autoClaimEnabled = state
    if autoClaimEnabled then
        task.spawn(function()
            local Event = ReplicatedStorage:FindFirstChild("Modules") 
                and ReplicatedStorage.Modules:FindFirstChild("PlaytimeRewards") 
                and ReplicatedStorage.Modules.PlaytimeRewards:FindFirstChild("Remote")

            while autoClaimEnabled and Event do
                for rewardId = 1, 9 do
                    if not autoClaimEnabled then break end
                    pcall(function()
                        Event:FireServer(rewardId)
                    end)
                    task.wait(0.5)
                end
                task.wait(5)
            end
        end)
    end
end)

-- 3. Auto Glass Obby Toggle (Placeholder / Target Navigation)
createToggle("Auto Complete Glass Obby", function(state)
    autoGlassEnabled = state
    if autoGlassEnabled then
        task.spawn(function()
            while autoGlassEnabled do
                -- Add your specific glass obby coordinates or chunk bypass logic here
                pcall(function()
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        -- Example checkpoint logic loop
                        -- char.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
                    end
                end)
                task.wait(1)
            end
        end)
    end
end)

-- --- SPIN SECTION ---
local spinLabel = Instance.new("TextLabel")
spinLabel.Size = UDim2.new(1, 0, 0, 25)
spinLabel.BackgroundTransparency = 1
spinLabel.Text = "Select Spin Type:"
spinLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
spinLabel.TextSize, spinLabel.Font = 13, Enum.Font.GothamMedium
spinLabel.TextXAlignment = Enum.TextXAlignment.Left
spinLabel.Parent = container

-- Dropdown Button to Open List
local dropdownBtn = Instance.new("TextButton")
dropdownBtn.Size = UDim2.new(1, 0, 0, 35)
dropdownBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
dropdownBtn.Text = "NORMAL SPIN v"
dropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dropdownBtn.TextSize, dropdownBtn.Font = 13, Enum.Font.Gotham
dropdownBtn.Parent = container

local dCorner = Instance.new("UICorner")
dCorner.CornerRadius = UDim.new(0, 8)
dCorner.Parent = dropdownBtn

-- Scrolling Frame for Spin Options
local spinListFrame = Instance.new("ScrollingFrame")
spinListFrame.Size = UDim2.new(1, 0, 0, 150)
spinListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
spinListFrame.Visible = false
spinListFrame.CanvasSize = UDim2.new(0, 0, 0, 350)
spinListFrame.ScrollBarThickness = 4
spinListFrame.Parent = container

local spinListLayout = Instance.new("UIListLayout")
spinListLayout.SortOrder = Enum.SortOrder.LayoutOrder
spinListLayout.Parent = spinListFrame

local spinTypes = {
    "NORMAL SPIN", "GREEN SPIN", "YELLOW SPIN", "PURPLE SPIN",
    "ORANGE SPIN", "RED SPIN", "RAINBOW SPIN", "VOID SPIN",
    "MILLION SPIN", "LUCKY SPIN", "ADMIN SPIN", "FIFTY-FIFTY SPIN", "SPINNER SPIN"
}

for _, spinName in ipairs(spinTypes) do
    local optBtn = Instance.new("TextButton")
    optBtn.Size = UDim2.new(1, 0, 0, 30)
    optBtn.BackgroundTransparency = 1
    optBtn.Text = spinName
    optBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    optBtn.TextSize, optBtn.Font = 12, Enum.Font.Gotham
    optBtn.Parent = spinListFrame
    
    optBtn.MouseButton1Click:Connect(function()
        selectedSpinType = spinName
        dropdownBtn.Text = spinName .. " v"
        spinListFrame.Visible = false
    end)
end

dropdownBtn.MouseButton1Click:Connect(function()
    spinListFrame.Visible = not spinListFrame.Visible
end)

-- 4. Auto Spin Toggle
createToggle("Auto Spin Selected", function(state)
    autoSpinEnabled = state
    if autoSpinEnabled then
        task.spawn(function()
            local SpinEvent = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Spin")
            while autoSpinEnabled and SpinEvent do
                pcall(function()
                    SpinEvent:FireServer(selectedSpinType)
                end)
                task.wait(1)
            end
        end)
    end
end)
