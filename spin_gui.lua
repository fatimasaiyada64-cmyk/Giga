local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- Safe GUI container lookup for mobile executors
local guiParent = pcall(function() return gethui() end) and gethui() or (CoreGui:FindFirstChild("RobloxGui") and CoreGui) or player:WaitForChild("PlayerGui")

-- Clean up old instance if it exists
if guiParent:FindFirstChild("GameAutomationGUI") then
    guiParent.GameAutomationGUI:Destroy()
end

local success, err = pcall(function()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GameAutomationGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = guiParent

    -- Main Window Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 380)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -190)
    mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = mainFrame

    -- Subtle Border Stroke
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(45, 45, 65)
    mainStroke.Thickness = 1.5
    mainStroke.Parent = mainFrame

    -- Top Header Bar
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 42)
    header.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
    header.BorderSizePixel = 0
    header.Parent = mainFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = header

    -- Fix bottom corners of header so they are flat
    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 10)
    headerFix.Position = UDim2.new(0, 0, 1, -10)
    headerFix.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 14, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ Giga Automation Hub"
    title.TextColor3 = Color3.fromRGB(240, 240, 255)
    title.TextSize, title.Font = 14, Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -34, 0.5, -14)
    closeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
    closeBtn.TextSize, closeBtn.Font = 18, Enum.Font.GothamBold
    closeBtn.Parent = header

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Scrolling Content Container
    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, -20, 1, -56)
    container.Position = UDim2.new(0, 10, 0, 48)
    container.BackgroundTransparency = 1
    container.CanvasSize = UDim2.new(0, 0, 0, 420)
    container.ScrollBarThickness = 3
    container.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 100)
    container.Parent = mainFrame

    local uiList = Instance.new("UIListLayout")
    uiList.SortOrder = Enum.SortOrder.LayoutOrder
    uiList.Padding = UDim.new(0, 10)
    uiList.Parent = container

    -- Modern Toggle Creator Function
    local function createToggle(name, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 38)
        btn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Parent = container
        
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 8)
        c.Parent = btn

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(45, 45, 65)
        stroke.Thickness = 1
        stroke.Parent = btn
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -50, 1, 0)
        label.Position = UDim2.new(0, 14, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(200, 200, 215)
        label.TextSize, label.Font = 13, Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = btn

        local statusIndicator = Instance.new("Frame")
        statusIndicator.Size = UDim2.new(0, 26, 0, 14)
        statusIndicator.Position = UDim2.new(1, -38, 0.5, -7)
        statusIndicator.BackgroundColor3 = Color3.fromRGB(50, 50, 68)
        statusIndicator.Parent = btn

        local statusCorner = Instance.new("UICorner")
        statusCorner.CornerRadius = UDim.new(1, 0)
        statusCorner.Parent = statusIndicator

        local indicatorDot = Instance.new("Frame")
        indicatorDot.Size = UDim2.new(0, 10, 0, 10)
        indicatorDot.Position = UDim2.new(0, 2, 0.5, -5)
        indicatorDot.BackgroundColor3 = Color3.fromRGB(150, 150, 170)
        indicatorDot.Parent = statusIndicator

        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = indicatorDot
        
        local enabled = false
        btn.MouseButton1Click:Connect(function()
            enabled = not enabled
            if enabled then
                statusIndicator.BackgroundColor3 = Color3.fromRGB(70, 200, 120)
                indicatorDot.Position = UDim2.new(1, -12, 0.5, -5)
                indicatorDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            else
                statusIndicator.BackgroundColor3 = Color3.fromRGB(50, 50, 68)
                indicatorDot.Position = UDim2.new(0, 2, 0.5, -5)
                indicatorDot.BackgroundColor3 = Color3.fromRGB(150, 150, 170)
            end
            callback(enabled)
        end)
    end

    local autoFlyEnabled, autoClaimEnabled, autoSpinEnabled = false, false, false
    local selectedSpinType = "NORMAL SPIN"

    -- 1. Auto Fly to Target (Original Logic)
    createToggle("Auto Fly to Target", function(state)
        autoFlyEnabled = state
        if autoFlyEnabled then
            task.spawn(function()
                while autoFlyEnabled do
                    local character = player.Character or player.CharacterAdded:Wait()
                    local humanoid = character:WaitForChild("Humanoid", 5)
                    local root = character:WaitForChild("HumanoidRootPart", 5)
                    
                    if humanoid and root and humanoid.Health > 0 then
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
                            while root.Parent and autoFlyEnabled and humanoid.Health > 0 do
                                local delta = target - root.Position
                                local distance = delta.Magnitude
                                if distance < 3 then break end
                                local dt = RunService.Heartbeat:Wait()
                                flight.VectorVelocity = delta.Unit * math.min(speed, distance / dt)
                            end
                            flight.VectorVelocity = Vector3.zero
                        end

                        flyTo(approachPoint)
                        if autoFlyEnabled and humanoid.Health > 0 then 
                            flyTo(destination) 
                        end

                        flight:Destroy()
                        attachment:Destroy()
                        
                        if humanoid and humanoid.Parent then
                            humanoid.PlatformStand = wasPlatformStanding
                            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                        end

                        pcall(function()
                            local obbyEvent = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Obby")
                            local winPartsFolder = Workspace:FindFirstChild("Obbies") and Workspace.Obbies:FindFirstChild("WinParts")
                            if obbyEvent and winPartsFolder and winPartsFolder:GetChildren()[3] then
                                obbyEvent:FireServer("ObbyCompleted", winPartsFolder:GetChildren()[3])
                            end
                        end)
                    end
                    task.wait(2)
                end
            end)
        end
    end)

    -- 2. Auto Claim Playtime
    createToggle("Auto Claim Playtime", function(state)
        autoClaimEnabled = state
        if autoClaimEnabled then
            task.spawn(function()
                while autoClaimEnabled do
                    local modules = ReplicatedStorage:FindFirstChild("Modules")
                    local playtimeRewards = modules and modules:FindFirstChild("PlaytimeRewards")
                    local event = playtimeRewards and playtimeRewards:FindFirstChild("Remote")

                    if event then
                        for rewardId = 1, 9 do
                            if not autoClaimEnabled then break end
                            pcall(function() event:FireServer(rewardId) end)
                            task.wait(0.3)
                        end
                    end
                    task.wait(5)
                end
            end)
        end
    end)

    -- Spin Dropdown UI (Styled)
    local spinLabel = Instance.new("TextLabel")
    spinLabel.Size = UDim2.new(1, 0, 0, 20)
    spinLabel.BackgroundTransparency = 1
    spinLabel.Text = "SELECT SPIN TYPE"
    spinLabel.TextColor3 = Color3.fromRGB(130, 130, 160)
    spinLabel.TextSize, spinLabel.Font = 10, Enum.Font.GothamBold
    spinLabel.TextXAlignment = Enum.TextXAlignment.Left
    spinLabel.Parent = container

    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Size = UDim2.new(1, 0, 0, 36)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    dropdownBtn.Text = "  NORMAL SPIN ▾"
    dropdownBtn.TextColor3 = Color3.fromRGB(220, 220, 240)
    dropdownBtn.TextSize, dropdownBtn.Font = 12, Enum.Font.GothamMedium
    dropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
    dropdownBtn.Parent = container

    local dCorner = Instance.new("UICorner")
    dCorner.CornerRadius = UDim.new(0, 8)
    dCorner.Parent = dropdownBtn

    local dStroke = Instance.new("UIStroke")
    dStroke.Color = Color3.fromRGB(45, 45, 65)
    dStroke.Thickness = 1
    dStroke.Parent = dropdownBtn

    local spinListFrame = Instance.new("ScrollingFrame")
    spinListFrame.Size = UDim2.new(1, 0, 0, 130)
    spinListFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    spinListFrame.Visible = false
    spinListFrame.CanvasSize = UDim2.new(0, 0, 0, 400)
    spinListFrame.ScrollBarThickness = 3
    spinListFrame.Parent = container

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 8)
    listCorner.Parent = spinListFrame

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
        optBtn.Text = "  " .. spinName
        optBtn.TextColor3 = Color3.fromRGB(180, 180, 200)
        optBtn.TextSize, optBtn.Font = 11, Enum.Font.Gotham
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.Parent = spinListFrame
        
        optBtn.MouseButton1Click:Connect(function()
            selectedSpinType = spinName
            dropdownBtn.Text = "  " .. spinName .. " ▾"
            spinListFrame.Visible = false
        end)
    end

    dropdownBtn.MouseButton1Click:Connect(function()
        spinListFrame.Visible = not spinListFrame.Visible
    end)

    -- 3. Auto Spin Toggle
    createToggle("Auto Spin Selected", function(state)
        autoSpinEnabled = state
        if autoSpinEnabled then
            task.spawn(function()
                while autoSpinEnabled do
                    pcall(function()
                        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                        local spinEvent = remotes and remotes:FindFirstChild("Spin")
                        if spinEvent then
                            spinEvent:FireServer(selectedSpinType)
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end)
end)

if not success then
    warn("GUI Loading Error: " + tostring(err))
end
