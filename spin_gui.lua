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

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 320)
    mainFrame.Position = UDim2.new(0.5, -140, 0.5, -160)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    title.Text = "Automation Panel"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize, title.Font = 14, Enum.Font.GothamBold
    title.Parent = mainFrame

    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, -16, 1, -45)
    container.Position = UDim2.new(0, 8, 0, 40)
    container.BackgroundTransparency = 1
    container.CanvasSize = UDim2.new(0, 0, 0, 400)
    container.ScrollBarThickness = 3
    container.Parent = mainFrame

    local uiList = Instance.new("UIListLayout")
    uiList.SortOrder = Enum.SortOrder.LayoutOrder
    uiList.Padding = UDim.new(0, 8)
    uiList.Parent = container

    local function createToggle(name, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 35)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        btn.Text = name .. ": OFF"
        btn.TextColor3 = Color3.fromRGB(255, 100, 100)
        btn.TextSize, btn.Font = 13, Enum.Font.GothamSemibold
        btn.Parent = container
        
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
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

    local autoFlyEnabled, autoClaimEnabled, autoSpinEnabled = false, false, false
    local selectedSpinType = "NORMAL SPIN"

    -- 1. Auto Fly to Target (Flies, fires obby completion event, waits 2s, repeats)
    createToggle("Auto Fly to Target", function(state)
        autoFlyEnabled = state
        if autoFlyEnabled then
            task.spawn(function()
                local destination = Vector3.new(24.7, -5, -375.9)
                local speed = 65

                while autoFlyEnabled do
                    local character = player.Character or player.CharacterAdded:Wait()
                    local humanoid = character:WaitForChild("Humanoid", 2)
                    local root = character:WaitForChild("HumanoidRootPart", 2)
                    
                    if humanoid and root and humanoid.Health > 0 then
                        local wasPlatformStanding = humanoid.PlatformStand
                        humanoid.PlatformStand = true

                        -- Fly to destination
                        while autoFlyEnabled and root and humanoid.Health > 0 do
                            local currentPos = root.Position
                            local direction = destination - currentPos
                            local distance = direction.Magnitude
                            
                            if distance < 3 then 
                                break 
                            end

                            local dt = RunService.Heartbeat:Wait()
                            local step = math.min(speed * dt, distance)
                            root.CFrame = CFrame.new(currentPos + direction.Unit * step)
                        end

                        humanoid.PlatformStand = wasPlatformStanding
                        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

                        -- Fire the obby completion event upon arrival to trigger teleport back
                        pcall(function()
                            local obbyEvent = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Obby")
                            local winPartsFolder = Workspace:FindFirstChild("Obbies") and Workspace.Obbies:FindFirstChild("WinParts")
                            if obbyEvent and winPartsFolder and winPartsFolder:GetChildren()[3] then
                                obbyEvent:FireServer("ObbyCompleted", winPartsFolder:GetChildren()[3])
                            end
                        end)

                        -- Wait 2 seconds before looping to fly again
                        task.wait(2)
                    else
                        task.wait(1)
                    end
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

    -- Spin Dropdown UI
    local spinLabel = Instance.new("TextLabel")
    spinLabel.Size = UDim2.new(1, 0, 0, 20)
    spinLabel.BackgroundTransparency = 1
    spinLabel.Text = "Select Spin Type:"
    spinLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    spinLabel.TextSize, spinLabel.Font = 12, Enum.Font.GothamMedium
    spinLabel.TextXAlignment = Enum.TextXAlignment.Left
    spinLabel.Parent = container

    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Size = UDim2.new(1, 0, 0, 32)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    dropdownBtn.Text = "NORMAL SPIN v"
    dropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdownBtn.TextSize, dropdownBtn.Font = 12, Enum.Font.Gotham
    dropdownBtn.Parent = container

    local dCorner = Instance.new("UICorner")
    dCorner.CornerRadius = UDim.new(0, 6)
    dCorner.Parent = dropdownBtn

    local spinListFrame = Instance.new("ScrollingFrame")
    spinListFrame.Size = UDim2.new(1, 0, 0, 130)
    spinListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    spinListFrame.Visible = false
    spinListFrame.CanvasSize = UDim2.new(0, 0, 0, 400)
    spinListFrame.ScrollBarThickness = 3
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
        optBtn.Size = UDim2.new(1, 0, 0, 28)
        optBtn.BackgroundTransparency = 1
        optBtn.Text = spinName
        optBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
        optBtn.TextSize, optBtn.Font = 11, Enum.Font.Gotham
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
    warn("GUI Loading Error: " .. tostring(err))
end
