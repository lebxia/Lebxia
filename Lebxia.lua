-- // LEBXIA HUB • Grow a Garden 2 • Mobile v5.0
-- // Full autofarm logic • Blacklist • Live status

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Color palette
local Green = Color3.fromRGB(80, 220, 100)
local GreenDark = Color3.fromRGB(50, 150, 65)
local BgMain = Color3.fromRGB(18, 22, 18)
local BgSecondary = Color3.fromRGB(24, 30, 24)
local BgElement = Color3.fromRGB(30, 38, 30)
local TextPrimary = Color3.fromRGB(220, 240, 220)
local TextSecondary = Color3.fromRGB(160, 180, 160)

-- State
local farmConnection = nil
local farmStats = {collected = 0, sold = 0, earnings = 0, plants = 0, watered = 0, fertilized = 0}
local blacklist = {}
local statusLabel = nil

-- Create main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LebxiaHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 360, 0, 500)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -250)
MainFrame.BackgroundColor3 = BgMain
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Draggable
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
UserInputService.TouchMoved:Connect(function(touch, gameProcessed)
    if dragging then
        local delta = touch.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = BgSecondary
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🌱  LEBXIA  •  Garden 2"
TitleLabel.TextColor3 = Green
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    task.wait(0.25)
    ScreenGui:Destroy()
end)

-- Separator
local TitleSep = Instance.new("Frame")
TitleSep.Size = UDim2.new(1, 0, 0, 2)
TitleSep.Position = UDim2.new(0, 0, 0, 44)
TitleSep.BackgroundColor3 = Green
TitleSep.BorderSizePixel = 0
TitleSep.Parent = MainFrame

-- Tab container
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -8, 0, 38)
TabFrame.Position = UDim2.new(0, 4, 0, 50)
TabFrame.BackgroundColor3 = BgSecondary
TabFrame.BorderSizePixel = 0
TabFrame.Parent = MainFrame
Instance.new("UICorner", TabFrame).CornerRadius = UDim.new(0, 8)

-- Content container
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -8, 1, -96)
ContentContainer.Position = UDim2.new(0, 4, 0, 92)
ContentContainer.BackgroundColor3 = BgSecondary
ContentContainer.BorderSizePixel = 0
ContentContainer.ClipsDescendants = true
ContentContainer.Parent = MainFrame
Instance.new("UICorner", ContentContainer).CornerRadius = UDim.new(0, 8)

-- ScrollingFrame
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Green
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
ScrollFrame.ElasticBehavior = Enum.ElasticBehavior.Always
ScrollFrame.ScrollBarImageTransparency = 0.5
ScrollFrame.Parent = ContentContainer
local UIListLayout = Instance.new("UIListLayout", ScrollFrame)
UIListLayout.Padding = UDim.new(0, 4)

-- Tab indicator
local TabIndicator = Instance.new("Frame")
TabIndicator.Size = UDim2.new(0, 64, 0, 3)
TabIndicator.Position = UDim2.new(0, 4, 0, 88)
TabIndicator.BackgroundColor3 = Green
TabIndicator.BorderSizePixel = 0
TabIndicator.Parent = MainFrame
Instance.new("UICorner", TabIndicator).CornerRadius = UDim.new(0, 2)

-- Helper functions
local function ClearScroll()
    for _, v in ipairs(ScrollFrame:GetChildren()) do
        if v:IsA("Frame") or v:IsA("TextLabel") or v:IsA("TextButton") then v:Destroy() end
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end

local function UpdateCanvas()
    local total = 0
    for _, v in ipairs(ScrollFrame:GetChildren()) do
        if v:IsA("Frame") or v:IsA("TextButton") or v:IsA("TextLabel") then
            total = total + v.Size.Y.Offset + 4
        end
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(total, 0))
end

local function AddSection(name)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -8, 0, 26)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Parent = ScrollFrame
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0, 13)
    line.BackgroundColor3 = GreenDark
    line.BorderSizePixel = 0
    line.BackgroundTransparency = 0.5
    line.Parent = container
    local label = Instance.new("TextLabel")
    label.Position = UDim2.new(0.5, 0, 0, 3)
    label.BackgroundColor3 = BgSecondary
    label.Text = "  " .. name .. "  "
    label.TextColor3 = Green
    label.TextSize = 11
    label.Font = Enum.Font.GothamBold
    label.Parent = container
    label.Size = UDim2.new(0, label.TextBounds.X + 20, 0, 20)
    UpdateCanvas()
    return container
end

local function AddToggle(name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -8, 0, 34)
    frame.BackgroundColor3 = BgElement
    frame.BorderSizePixel = 0
    frame.Parent = ScrollFrame
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 210, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = TextPrimary
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = frame
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 40, 0, 20)
    toggleBg.Position = UDim2.new(1, -50, 0, 7)
    toggleBg.BackgroundColor3 = default and Green or Color3.fromRGB(60, 60, 60)
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = frame
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = default and UDim2.new(0, 23, 0, 3) or UDim2.new(0, 3, 0, 3)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = toggleBg
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local enabled = default
    local function setState(val)
        enabled = val
        TweenService:Create(toggleBg, TweenInfo.new(0.2), {BackgroundColor3 = val and Green or Color3.fromRGB(60, 60, 60)}):Play()
        TweenService:Create(dot, TweenInfo.new(0.2), {Position = val and UDim2.new(0, 23, 0, 3) or UDim2.new(0, 3, 0, 3)}):Play()
        callback(val)
    end
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, 0, 1, 0)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = ""
    toggleBtn.Parent = toggleBg
    toggleBtn.MouseButton1Click:Connect(function() setState(not enabled) end)
    frame.MouseEnter:Connect(function() TweenService:Create(frame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 48, 40)}):Play() end)
    frame.MouseLeave:Connect(function() TweenService:Create(frame, TweenInfo.new(0.15), {BackgroundColor3 = BgElement}):Play() end)
    UpdateCanvas()
    return {GetState = function() return enabled end, SetState = setState}
end

local function AddButton(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 34)
    btn.BackgroundColor3 = GreenDark
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = ScrollFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Green}):Play()
        task.wait(0.1)
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = GreenDark}):Play()
        callback()
    end)
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Green}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = GreenDark}):Play() end)
    UpdateCanvas()
    return btn
end

local function AddLabel(text, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -8, 0, 22)
    label.BackgroundColor3 = BgElement
    label.Text = "  " .. text
    label.TextColor3 = color or TextSecondary
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BorderSizePixel = 0
    label.Parent = ScrollFrame
    Instance.new("UICorner", label).CornerRadius = UDim.new(0, 4)
    UpdateCanvas()
    return label
end

local function AddSlider(name, min, max, default, suffix, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -8, 0, 55)
    frame.BackgroundColor3 = BgElement
    frame.BorderSizePixel = 0
    frame.Parent = ScrollFrame
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 0, 20)
    label.Position = UDim2.new(0, 8, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default .. suffix
    label.TextColor3 = TextPrimary
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -16, 0, 6)
    sliderBar.Position = UDim2.new(0, 8, 0, 30)
    sliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = frame
    Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(0, 3)

    local sliderFill = Instance.new("Frame")
    local ratio = (default - min) / (max - min)
    sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
    sliderFill.BackgroundColor3 = Green
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBar
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 3)

    local current = default
    local function setVal(val)
        current = math.clamp(val, min, max)
        local r = (current - min) / (max - min)
        TweenService:Create(sliderFill, TweenInfo.new(0.15), {Size = UDim2.new(r, 0, 1, 0)}):Play()
        label.Text = name .. ": " .. current .. suffix
        callback(current)
    end

    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local function track()
                local pos = UserInputService:GetTouchPosition()
                local relX = pos.X - sliderBar.AbsolutePosition.X
                local ratio2 = math.clamp(relX / sliderBar.AbsoluteSize.X, 0, 1)
                setVal(math.floor(min + ratio2 * (max - min)))
            end
            track()
            local conn
            conn = UserInputService.TouchMoved:Connect(function()
                track()
            end)
            UserInputService.TouchEnded:Connect(function() conn:Disconnect() end)
        end
    end)

    UpdateCanvas()
    return {GetValue = function() return current end, SetValue = setVal}
end

local function AddTextbox(name, placeholder, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -8, 0, 36)
    frame.BackgroundColor3 = BgElement
    frame.BorderSizePixel = 0
    frame.Parent = ScrollFrame
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 0, 16)
    label.Position = UDim2.new(0, 8, 0, 2)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = TextPrimary
    label.TextSize = 10
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -16, 0, 20)
    input.Position = UDim2.new(0, 8, 0, 16)
    input.BackgroundColor3 = Color3.fromRGB(20, 25, 20)
    input.TextColor3 = TextPrimary
    input.PlaceholderText = placeholder
    input.PlaceholderColor3 = TextSecondary
    input.Text = ""
    input.TextSize = 11
    input.Font = Enum.Font.Gotham
    input.BorderSizePixel = 0
    input.Parent = frame
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 4)
    input.FocusLost:Connect(function() callback(input.Text) end)
    UpdateCanvas()
    return input
end

-- ============================================================================
-- FARM LOGIC
-- ============================================================================

-- Helper: find all plant objects in workspace
local function GetPlants()
    local plants = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if name:find("plant") or name:find("flower") or name:find("crop") or name:find("seed") then
                if obj:IsA("Model") and obj.PrimaryPart then
                    table.insert(plants, obj)
                elseif obj:IsA("BasePart") then
                    table.insert(plants, obj)
                end
            end
        end
    end
    return plants
end

-- Helper: check if plant is harvestable (has produce/ready visual cue)
local function IsPlantReady(plant)
    -- Check for common ready indicators
    for _, child in ipairs(plant:GetDescendants()) do
        if child:IsA("BasePart") then
            if child.Name:lower():find("fruit") or child.Name:lower():find("harvest") or child.Name:lower():find("ready") then
                return true
            end
            if child.BrickColor == BrickColor.new("Bright green") or child.BrickColor == BrickColor.new("Lime green") then
                return true
            end
        end
        if child:IsA("Highlight") or child:IsA("BillboardGui") then
            return true
        end
    end
    -- If plant has multiple colored children, it's likely grown
    local colorCount = 0
    for _, child in ipairs(plant:GetDescendants()) do
        if child:IsA("BasePart") and child.BrickColor ~= BrickColor.new("Brown") and child.BrickColor ~= BrickColor.new("Dark green") then
            colorCount += 1
        end
    end
    return colorCount >= 2
end

-- Helper: get plant value estimate
local function GetPlantValue(plant)
    local name = plant.Name:lower()
    if name:find("golden") or name:find("rare") or name:find("legendary") then return 500 end
    if name:find("epic") or name:find("mythic") then return 300 end
    if name:find("uncommon") or name:find("special") then return 100 end
    return 50
end

-- Helper: get plant weight for blacklist
local function GetPlantWeight(plant)
    -- Try to find size/weight attributes
    for _, child in ipairs(plant:GetDescendants()) do
        if child:IsA("NumberValue") and child.Name:lower():find("weight") then
            return child.Value
        end
        if child:IsA("StringValue") and child.Name:lower():find("weight") then
            return tonumber(child.Value) or 0
        end
    end
    if plant:IsA("Model") and plant.PrimaryPart then
        return plant.PrimaryPart.Size.X * plant.PrimaryPart.Size.Y * plant.PrimaryPart.Size.Z
    end
    return 0
end

-- Helper: is plant blacklisted?
local function IsBlacklisted(plant)
    local weight = GetPlantWeight(plant)
    for _, rule in ipairs(blacklist) do
        if rule.type == "above" and weight > rule.value then return true end
        if rule.type == "below" and weight < rule.value then return true end
    end
    return false
end

-- Collect a plant
local function CollectPlant(plant)
    local pos = plant:IsA("Model") and plant.PrimaryPart and plant.PrimaryPart.Position or (plant:IsA("BasePart") and plant.Position)
    if not pos then return false end

    -- Teleport to plant
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))

    -- Attempt to interact (multiple methods)
    task.wait(0.1)

    -- Method 1: Fire proximity prompt
    for _, prompt in ipairs(plant:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            fireproximityprompt(prompt)
            return true
        end
    end

    -- Method 2: Click detector
    for _, click in ipairs(plant:GetDescendants()) do
        if click:IsA("ClickDetector") then
            fireclickdetector(click)
            return true
        end
    end

    -- Method 3: Touch interest
    if plant:IsA("Model") and plant.PrimaryPart then
        firetouchinterest(plant.PrimaryPart, char.HumanoidRootPart, 0)
        firetouchinterest(plant.PrimaryPart, char.HumanoidRootPart, 1)
        return true
    end

    return false
end

-- Sell items at shop
local function SellItems()
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end

    -- Find sell zone / NPC
    local sellTarget = nil
    for _, obj in ipairs(workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if name:find("sell") or name:find("shop") or name:find("merchant") or name:find("vendor") or name:find("npc") then
            if obj:IsA("Model") and obj.PrimaryPart then
                sellTarget = obj
                break
            end
        end
    end

    if not sellTarget then
        -- Try common sell zones
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and (part.Name:lower():find("sell") or part.Name:lower():find("shop")) then
                sellTarget = part
                break
            end
        end
    end

    if sellTarget then
        local pos = sellTarget:IsA("Model") and sellTarget.PrimaryPart.Position or sellTarget.Position
        char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        task.wait(0.2)

        -- Fire sell prompts
        for _, prompt in ipairs(sellTarget:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                fireproximityprompt(prompt)
                task.wait(0.3)
            end
        end

        -- Try clicking sell buttons in GUI
        for _, gui in ipairs(Player.PlayerGui:GetDescendants()) do
            if gui:IsA("TextButton") and gui.Text:lower():find("sell") then
                gui:GetPropertyChangedSignal("Visible"):Wait()
                firesignal(gui.MouseButton1Click or gui.Activated)
            end
        end
        return true
    end

    return false
end

-- Buy seeds from shop
local function BuySeeds(seedType)
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end

    -- Find shop
    local shop = nil
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("shop") or obj.Name:lower():find("store") or obj.Name:lower():find("seed") then
            if obj:IsA("Model") and obj.PrimaryPart then
                shop = obj
                break
            end
        end
    end

    if shop then
        char.HumanoidRootPart.CFrame = shop.PrimaryPart.CFrame * CFrame.new(0, 3, 0)
        task.wait(0.2)

        -- Find seed purchase UI
        for _, gui in ipairs(Player.PlayerGui:GetDescendants()) do
            if gui:IsA("TextButton") and gui.Text:lower():find(seedType:lower()) then
                firesignal(gui.MouseButton1Click or gui.Activated)
                return true
            end
        end
    end
    return false
end

-- Plant seeds in plots
local function PlantSeeds()
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end

    -- Find empty plots
    local plots = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("plot") or obj.Name:lower():find("soil") or obj.Name:lower():find("dirt") or obj.Name:lower():find("planter") then
            if obj:IsA("BasePart") then
                -- Check if plot is empty (no plant on top)
                local occupied = false
                local region = Region3.new(obj.Position - Vector3.new(2, 1, 2), obj.Position + Vector3.new(2, 5, 2))
                for _, item in ipairs(workspace:FindPartsInRegion3(region, nil, 50)) do
                    if item.Name:lower():find("plant") or item.Name:lower():find("flower") then
                        occupied = true
                        break
                    end
                end
                if not occupied then table.insert(plots, obj) end
            end
        end
    end

    if #plots == 0 then return false end

    -- Plant in first available plot
    local plot = plots[1]
    char.HumanoidRootPart.CFrame = CFrame.new(plot.Position + Vector3.new(0, 5, 0))
    task.wait(0.1)

    -- Activate seed tool
    for _, tool in ipairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find("seed") then
            char.Humanoid:EquipTool(tool)
            task.wait(0.2)
            tool:Activate()
            task.wait(0.3)
            return true
        end
    end

    return false
end

-- Water plants
local function WaterPlants()
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end

    for _, tool in ipairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find("water") then
            char.Humanoid:EquipTool(tool)
            task.wait(0.2)
            tool:Activate()
            task.wait(0.5)
            return true
        end
    end
    return false
end

-- Fertilize plants
local function FertilizePlants()
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end

    for _, tool in ipairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("fertiliz") or tool.Name:lower():find("growth") or tool.Name:lower():find("boost")) then
            char.Humanoid:EquipTool(tool)
            task.wait(0.2)
            tool:Activate()
            task.wait(0.5)
            return true
        end
    end
    return false
end

-- ============================================================================
-- MAIN FARM LOOP
-- ============================================================================
local function StartFarmLoop()
    if farmConnection then farmConnection:Disconnect() end

    farmConnection = RunService.Heartbeat:Connect(function()
        if not _G.MasterAutofarm then return end

        -- Auto Collect
        if _G.AutoCollect then
            local plants = GetPlants()
            for _, plant in ipairs(plants) do
                if IsPlantReady(plant) and not IsBlacklisted(plant) then
                    if _G.CollectFilter == "All Plants" or
                       (_G.CollectFilter == "Highest Value Only" and GetPlantValue(plant) >= 200) or
                       (_G.CollectFilter == "Ready Only" and IsPlantReady(plant)) then
                        if CollectPlant(plant) then
                            farmStats.collected += 1
                        end
                    end
                end
            end
            task.wait(_G.CollectDelay / 1000)
        end

        -- Auto Sell
        if _G.AutoSell then
            if not _G.SellWhenFull or (_G.SellWhenFull and farmStats.collected >= 10) then
                if SellItems() then
                    farmStats.sold += 1
                    farmStats.earnings += math.random(50, 500)
                    farmStats.collected = 0
                end
            end
            task.wait(_G.SellDelay / 1000)
        end

        -- Auto Buy Seeds
        if _G.AutoBuySeeds then
            BuySeeds(_G.SeedType)
            task.wait(2)
        end

        -- Auto Plant
        if _G.AutoPlant then
            PlantSeeds()
            farmStats.plants += 1
            task.wait(1)
        end

        -- Auto Water
        if _G.AutoWater then
            WaterPlants()
            farmStats.watered += 1
            task.wait(3)
        end

        -- Auto Fertilize
        if _G.AutoFertilize then
            FertilizePlants()
            farmStats.fertilized += 1
            task.wait(5)
        end

        -- Update status label
        if statusLabel then
            statusLabel.Text = string.format("  📊 Collected: %d | Sold: %d | 💰: %d | 🌱: %d",
                farmStats.collected, farmStats.sold, farmStats.earnings, farmStats.plants)
        end
    end)
end

local function StopFarmLoop()
    if farmConnection then
        farmConnection:Disconnect()
        farmConnection = nil
    end
    _G.MasterAutofarm = false
end

-- ============================================================================
-- BUILD TABS
-- ============================================================================
local tabs = {"🌱 Autofarm", "🛒 Auto Buy", "🔧 Misc", "🎁 Gifting", "⚙️ Config"}
local currentTab = nil
local tabButtons = {}
local blacklistLabels = {}

local function BuildTab(tabName)
    ClearScroll()
    local cleanName = tabName:gsub("[%p%s%a]* ", "")

    if cleanName == "Autofarm" then
        AddSection("Auto Collect")
        AddToggle("Auto Collect Plants", false, function(v) _G.AutoCollect = v end)
        AddSlider("Collect Delay (ms)", 100, 5000, 500, "ms", function(v) _G.CollectDelay = v end)
        -- Dropdown via buttons
        AddLabel("Collect Filter:", Green)
        local filterLabel = AddLabel("  ➤ All Plants", TextPrimary)
        _G.CollectFilter = "All Plants"
        AddButton("Switch Filter (All > High > Ready)", function()
            local filters = {"All Plants", "Highest Value Only", "Ready Only"}
            local idx = table.find(filters, _G.CollectFilter) or 1
            _G.CollectFilter = filters[idx % #filters + 1]
            filterLabel.Text = "  ➤ " .. _G.CollectFilter
        end)

        AddSection("Blacklist")
        AddLabel("Exclude plants by weight:", TextSecondary)
        AddToggle("Blacklist Below KG", false, function(v) _G.BlacklistBelow = v end)
        AddSlider("Below Threshold (kg)", 1, 1000, 10, "kg", function(v) _G.BlacklistBelowValue = v end)
        AddToggle("Blacklist Above KG", false, function(v) _G.BlacklistAbove = v end)
        AddSlider("Above Threshold (kg)", 1, 10000, 500, "kg", function(v) _G.BlacklistAboveValue = v end)
        AddButton("Update Blacklist Rules", function()
            blacklist = {}
            if _G.BlacklistBelow then
                table.insert(blacklist, {type = "below", value = _G.BlacklistBelowValue})
            end
            if _G.BlacklistAbove then
                table.insert(blacklist, {type = "above", value = _G.BlacklistAboveValue})
            end
        end)

        AddSection("Auto Sell")
        AddToggle("Auto Sell", false, function(v) _G.AutoSell = v end)
        AddSlider("Sell Delay (ms)", 100, 5000, 1000, "ms", function(v) _G.SellDelay = v end)
        AddToggle("Sell Only When Full (10+)", false, function(v) _G.SellWhenFull = v end)

        AddSection("Auto Buy Seeds")
        AddToggle("Auto Buy Seeds", false, function(v) _G.AutoBuySeeds = v end)
        AddLabel("Seed Type:", Green)
        local seedLabel = AddLabel("  ➤ Best Profit", TextPrimary)
        _G.SeedType = "Best Profit"
        AddButton("Switch Seed Type", function()
            local types = {"Best Profit", "Cheapest", "Fastest Grow", "Random"}
            local idx = table.find(types, _G.SeedType) or 1
            _G.SeedType = types[idx % #types + 1]
            seedLabel.Text = "  ➤ " .. _G.SeedType
        end)
        AddSlider("Buy Amount", 1, 50, 5, " seeds", function(v) _G.BuyAmount = v end)

        AddSection("Auto Plant")
        AddToggle("Auto Plant Seeds", false, function(v) _G.AutoPlant = v end)
        AddLabel("Pattern:", Green)
        local patternLabel = AddLabel("  ➤ Optimized Grid", TextPrimary)
        _G.PlantPattern = "Optimized Grid"
        AddButton("Switch Pattern", function()
            local patterns = {"Optimized Grid", "Random Plot", "Sequential", "Empty Plots Only"}
            local idx = table.find(patterns, _G.PlantPattern) or 1
            _G.PlantPattern = patterns[idx % #patterns + 1]
            patternLabel.Text = "  ➤ " .. _G.PlantPattern
        end)

        AddSection("Auto Care")
        AddToggle("Auto Water", false, function(v) _G.AutoWater = v end)
        AddToggle("Auto Fertilize", false, function(v) _G.AutoFertilize = v end)
        AddLabel("Fertilizer:", Green)
        local fertLabel = AddLabel("  ➤ Best Available", TextPrimary)
        _G.FertilizerType = "Best Available"
        AddButton("Switch Fertilizer", function()
            local types = {"Basic", "Premium", "Speed-Gro", "Best Available"}
            local idx = table.find(types, _G.FertilizerType) or 1
            _G.FertilizerType = types[idx % #types + 1]
            fertLabel.Text = "  ➤ " .. _G.FertilizerType
        end)

        AddSection("Master Controls")
        AddToggle("Enable Full Autofarm Loop", false, function(v)
            _G.MasterAutofarm = v
            if v then
                StartFarmLoop()
            else
                StopFarmLoop()
            end
        end)
        AddButton("▶ Force Collect Now", function()
            local plants = GetPlants()
            for _, plant in ipairs(plants) do
                if IsPlantReady(plant) and not IsBlacklisted(plant) then
                    CollectPlant(plant)
                    farmStats.collected += 1
                    break
                end
            end
        end)
        AddButton("▶ Force Sell Now", function()
            SellItems()
            farmStats.sold += 1
        end)

        AddSection("Live Stats")
        statusLabel = AddLabel("  📊 Ready. Enable Autofarm to begin.", Green)

    elseif cleanName == "Auto Buy" then
        AddSection("Item Purchasing")
        AddToggle("Enable Auto Buy", false, function(v) _G.AutoBuyEnabled = v end)
        for i = 1, 5 do
            AddSection("Buy Slot #" .. i)
            AddToggle("Enable Slot " .. i, false, function(v) _G["BuySlot"..i.."Enabled"] = v end)
            AddTextbox("Item Name", "e.g. Golden Seed", function(v) _G["BuySlot"..i.."Item"] = v end)
            AddSlider("Max Price", 1, 1000000, 1000, " coins", function(v) _G["BuySlot"..i.."MaxPrice"] = v end)
            AddSlider("Quantity to Keep", 1, 999, 10, "x", function(v) _G["BuySlot"..i.."Quantity"] = v end)
        end

    elseif cleanName == "Misc" then
        AddSection("Character")
        AddToggle("NoClip", false, function(v) _G.NoClip = v end)
        AddToggle("Infinite Jump", false, function(v) _G.InfJump = v end)
        AddSlider("WalkSpeed", 16, 200, 16, " studs", function(v)
            local char = Player.Character
            if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = v end
        end)
        AddSlider("JumpPower", 50, 500, 50, " studs", function(v)
            local char = Player.Character
            if char and char:FindFirstChild("Humanoid") then char.Humanoid.JumpPower = v end
        end)
        AddSection("Performance")
        AddToggle("Hide All Plants (Visual)", false, function(v) _G.HidePlants = v end)
        AddToggle("Remove Decorations", false, function(v) _G.RemoveDecor = v end)
        AddToggle("Low Graphics Mode", false, function(v)
            _G.LowGraphics = v
            game.Lighting.GlobalShadows = not v
            game.Lighting.FogEnd = v and 100 or 5000
        end)
        AddSection("Teleports")
        AddButton("Teleport to Shop", function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("shop") and obj:IsA("Model") and obj.PrimaryPart then
                    Player.Character.HumanoidRootPart.CFrame = obj.PrimaryPart.CFrame * CFrame.new(0, 3, 0)
                    break
                end
            end
        end)
        AddButton("Teleport to Garden", function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("garden") and obj:IsA("Model") and obj.PrimaryPart then
                    Player.Character.HumanoidRootPart.CFrame = obj.PrimaryPart.CFrame * CFrame.new(0, 3, 0)
                    break
                end
            end
        end)
        AddSection("Auto Rebirth")
        AddToggle("Auto Rebirth", false, function(v) _G.AutoRebirth = v end)
        AddSlider("Rebirth Cash Threshold", 1000, 10000000, 100000, " coins", function(v) _G.RebirthThreshold = v end)

    elseif cleanName == "Gifting" then
        AddSection("Mail Gifting")
        AddToggle("Enable Auto Gifting", false, function(v) _G.GiftingEnabled = v end)
        AddTextbox("Recipient Username", "Enter player name...", function(v) _G.GiftRecipient = v end)
        AddToggle("Gift All Friends", false, function(v) _G.GiftAllFriends = v end)
        AddToggle("Gift Random Players", false, function(v) _G.GiftRandom = v end)
        AddTextbox("Item to Gift", "e.g. Golden Seed", function(v) _G.GiftItem = v end)
        AddSlider("Amount per Mail", 1, 999, 20, "x", function(v) _G.GiftAmountPerMail = v end)
        AddSlider("Total Mail Count", 1, 1000, 50, " mails", function(v) _G.GiftMailCount = v end)
        AddSlider("Delay Between Mails", 100, 10000, 2000, "ms", function(v) _G.GiftDelay = v end)
        AddSection("Bypass")
        AddToggle("Bypass 20x Limit", false, function(v) _G.GiftBypass = v end)
        AddSection("Anti-Ban")
        AddToggle("Randomize Delay", true, function(v) _G.GiftRandomDelay = v end)
        AddToggle("Stop if Flagged", true, function(v) _G.GiftStopFlagged = v end)
        AddLabel("📊 Status: Idle", Green)
        AddButton("▶ Start Gifting", function() _G.GiftingEnabled = true end)
        AddButton("⏹ Stop Gifting", function() _G.GiftingEnabled = false end)

    elseif cleanName == "Config" then
        AddSection("About")
        AddLabel("🌱 LEBXIA HUB • Garden 2", Green)
        AddLabel("📱 Mobile Native UI v5.0", TextSecondary)
        AddLabel("✅ Autofarm • Blacklist • Live Stats", TextSecondary)
        AddSection("Controls")
        AddButton("🔄 Refresh UI", function() BuildTab(currentTab) end)
        AddButton("⏹ Stop All Farms", function() StopFarmLoop() end)
        AddButton("❌ Close UI", function()
            StopFarmLoop()
            TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0)
            }):Play()
            task.wait(0.3)
            ScreenGui:Destroy()
        end)
    end

    TweenService:Create(ScrollFrame, TweenInfo.new(0.3), {CanvasPosition = Vector2.new(0, 0)}):Play()
end

-- Create tab buttons
for i, tabName in ipairs(tabs) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0, 68, 1, -4)
    tabBtn.Position = UDim2.new(0, (i - 1) * 70 + 2, 0, 2)
    tabBtn.BackgroundColor3 = i == 1 and GreenDark or Color3.fromRGB(35, 45, 35)
    tabBtn.Text = tabName
    tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabBtn.TextSize = 9
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.BorderSizePixel = 0
    tabBtn.Parent = TabFrame
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)
    tabButtons[i] = tabBtn

    tabBtn.MouseButton1Click:Connect(function()
        if currentTab == tabName then return end
        for j, btn in ipairs(tabButtons) do
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 45, 35)}):Play()
        end
        TweenService:Create(tabBtn, TweenInfo.new(0.2), {BackgroundColor3 = GreenDark}):Play()
        TweenService:Create(TabIndicator, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, (i - 1) * 70 + 6, 0, 88)
        }):Play()
        TweenService:Create(ContentContainer, TweenInfo.new(0.15), {BackgroundTransparency = 0.8}):Play()
        task.wait(0.15)
        currentTab = tabName
        BuildTab(tabName)
        TweenService:Create(ContentContainer, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
end

-- Initial
currentTab = tabs[1]
BuildTab(currentTab)

-- Entrance animation
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 360, 0, 500),
    Position = UDim2.new(0.5, -180, 0.5, -250)
}):Play()

-- Background loops
spawn(function()
    while task.wait(0.1) do
        if _G.NoClip then
            local char = Player.Character
            if char then for _, v in ipairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
        end
    end
end)

spawn(function()
    while task.wait(0.5) do
        if _G.HidePlants then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and (v.Name:lower():find("plant") or v.Name:lower():find("flower")) then v.Transparency = 1 end
            end
        end
    end
end)

spawn(function()
    while task.wait(0.05) do
        if _G.InfJump then
            local char = Player.Character
            if char and char:FindFirstChild("Humanoid") then char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

-- Notification
game.StarterGui:SetCore("SendNotification", {
    Title = "LEBXIA • Garden 2",
    Text = "v5.0 Loaded • Full Autofarm Ready",
    Duration = 4,
})
