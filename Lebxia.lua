-- // AXION HUB • Grow a Garden 2 • Mobile Native UI v4.0
-- // Green theme • Animated tabs • Smooth scrolling

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Color palette
local Green = Color3.fromRGB(80, 220, 100)
local GreenDark = Color3.fromRGB(50, 150, 65)
local BgMain = Color3.fromRGB(18, 22, 18)
local BgSecondary = Color3.fromRGB(24, 30, 24)
local BgElement = Color3.fromRGB(30, 38, 30)
local TextPrimary = Color3.fromRGB(220, 240, 220)
local TextSecondary = Color3.fromRGB(160, 180, 160)
local AccentGlow = Color3.fromRGB(100, 240, 120)

-- Create main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AxionHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Drop shadow effect
local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 20, 1, 20)
Shadow.Position = UDim2.new(0, -10, 0, -10)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://6015897843"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.6
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)

-- Main frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 360, 0, 480)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -240)
MainFrame.BackgroundColor3 = BgMain
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Rounded corners via UIStroke
local MainStroke = Instance.new("UICorner")
MainStroke.CornerRadius = UDim.new(0, 10)
MainStroke.Parent = MainFrame

Shadow.Parent = MainFrame

-- Draggable
local dragging = false
local dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
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

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🌱  AXION  •  Garden 2"
TitleLabel.TextColor3 = Green
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Close button
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

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    task.wait(0.25)
    ScreenGui:Destroy()
end)

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -68, 0, 8)
MinBtn.BackgroundColor3 = BgElement
MinBtn.Text = "─"
MinBtn.TextColor3 = TextPrimary
MinBtn.TextSize = 14
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 360, 0, 44)
        }):Play()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 360, 0, 480)
        }):Play()
    end
end)

-- Separator line under title
local TitleSep = Instance.new("Frame")
TitleSep.Size = UDim2.new(1, 0, 0, 2)
TitleSep.Position = UDim2.new(0, 0, 0, 44)
TitleSep.BackgroundColor3 = Green
TitleSep.BorderSizePixel = 0
TitleSep.Parent = MainFrame

-- Tab buttons container
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -8, 0, 38)
TabFrame.Position = UDim2.new(0, 4, 0, 50)
TabFrame.BackgroundColor3 = BgSecondary
TabFrame.BorderSizePixel = 0
TabFrame.Parent = MainFrame

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 8)
TabCorner.Parent = TabFrame

-- Content container
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -8, 1, -96)
ContentContainer.Position = UDim2.new(0, 4, 0, 92)
ContentContainer.BackgroundColor3 = BgSecondary
ContentContainer.BorderSizePixel = 0
ContentContainer.ClipsDescendants = true
ContentContainer.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentContainer

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

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.Parent = ScrollFrame

-- Helper functions
local function ClearScroll()
    for _, v in ipairs(ScrollFrame:GetChildren()) do
        if v:IsA("Frame") or v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("ImageLabel") then
            v:Destroy()
        end
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end

local function UpdateCanvas()
    local totalHeight = 0
    for _, v in ipairs(ScrollFrame:GetChildren()) do
        if v:IsA("Frame") or v:IsA("TextButton") or v:IsA("TextLabel") then
            totalHeight = totalHeight + v.Size.Y.Offset + 4
        end
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(totalHeight, 0))
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
    label.Size = UDim2.new(0, 0, 0, 20)
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

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

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

    -- Toggle switch
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 40, 0, 20)
    toggleBg.Position = UDim2.new(1, -50, 0, 7)
    toggleBg.BackgroundColor3 = default and Green or Color3.fromRGB(60, 60, 60)
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = frame

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBg

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = default and UDim2.new(0, 23, 0, 3) or UDim2.new(0, 3, 0, 3)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = toggleBg

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot

    local enabled = default
    local function setState(val)
        enabled = val
        local targetBg = val and Green or Color3.fromRGB(60, 60, 60)
        local targetPos = val and UDim2.new(0, 23, 0, 3) or UDim2.new(0, 3, 0, 3)
        TweenService:Create(toggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetBg}):Play()
        TweenService:Create(dot, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = targetPos}):Play()
        callback(val)
    end

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, 0, 1, 0)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = ""
    toggleBtn.Parent = toggleBg
    toggleBtn.MouseButton1Click:Connect(function() setState(not enabled) end)

    -- Hover effect
    frame.MouseEnter:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 48, 40)}):Play()
    end)
    frame.MouseLeave:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.15), {BackgroundColor3 = BgElement}):Play()
    end)

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

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Green}):Play()
        task.wait(0.1)
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = GreenDark}):Play()
        callback()
    end)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Green}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = GreenDark}):Play()
    end)

    UpdateCanvas()
    return btn
end

local function AddLabel(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -8, 0, 22)
    label.BackgroundColor3 = BgElement
    label.Text = "  " .. text
    label.TextColor3 = TextSecondary
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BorderSizePixel = 0
    label.Parent = ScrollFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = label

    UpdateCanvas()
    return label
end

-- Tab system with animation
local tabs = {"🌱 Autofarm", "🛒 Auto Buy", "🔧 Misc", "🎁 Gifting", "⚙️ Config"}
local currentTab = nil
local tabButtons = {}
local tabIndicators = {}

-- Tab indicator bar
local TabIndicator = Instance.new("Frame")
TabIndicator.Size = UDim2.new(0, 64, 0, 3)
TabIndicator.Position = UDim2.new(0, 4, 0, 88)
TabIndicator.BackgroundColor3 = Green
TabIndicator.BorderSizePixel = 0
TabIndicator.Parent = MainFrame

local IndCorner = Instance.new("UICorner")
IndCorner.CornerRadius = UDim.new(0, 2)
IndCorner.Parent = TabIndicator

local function BuildTab(tabName)
    ClearScroll()
    local cleanName = tabName:gsub("[%p%s%a]* ", "") -- strip emoji

    if cleanName == "Autofarm" then
        AddSection("Auto Collect")
        AddToggle("Auto Collect Plants", false, function(v) _G.AutoCollect = v end)
        AddToggle("Auto Sell", false, function(v) _G.AutoSell = v end)
        AddToggle("Sell Only When Full", false, function(v) _G.SellWhenFull = v end)
        AddSection("Auto Buy Seeds")
        AddToggle("Auto Buy Seeds", false, function(v) _G.AutoBuySeeds = v end)
        AddSection("Auto Plant")
        AddToggle("Auto Plant Seeds", false, function(v) _G.AutoPlant = v end)
        AddSection("Auto Care")
        AddToggle("Auto Water", false, function(v) _G.AutoWater = v end)
        AddToggle("Auto Fertilize", false, function(v) _G.AutoFertilize = v end)
        AddSection("Master Controls")
        AddToggle("Enable Full Autofarm Loop", false, function(v) _G.MasterAutofarm = v end)
        AddButton("Force Collect Now", function() end)
        AddButton("Force Sell Now", function() end)

    elseif cleanName == "Auto Buy" then
        AddSection("Item Purchasing")
        AddToggle("Enable Auto Buy", false, function(v) _G.AutoBuyEnabled = v end)
        for i = 1, 5 do
            AddSection("Buy Slot #" .. i)
            AddToggle("Enable Slot " .. i, false, function(v) _G["BuySlot"..i.."Enabled"] = v end)
            AddButton("Configure Slot " .. i, function() end)
        end

    elseif cleanName == "Misc" then
        AddSection("Character")
        AddToggle("NoClip", false, function(v) _G.NoClip = v end)
        AddToggle("Infinite Jump", false, function(v) _G.InfJump = v end)
        AddSection("Performance")
        AddToggle("Hide All Plants (Visual)", false, function(v) _G.HidePlants = v end)
        AddToggle("Remove Decorations", false, function(v) _G.RemoveDecor = v end)
        AddToggle("Low Graphics Mode", false, function(v)
            _G.LowGraphics = v
            if v then
                game.Lighting.GlobalShadows = false
                game.Lighting.FogEnd = 100
            else
                game.Lighting.GlobalShadows = true
                game.Lighting.FogEnd = 5000
            end
        end)
        AddSection("Teleports")
        AddButton("Teleport to Shop", function() end)
        AddButton("Teleport to Garden", function() end)
        AddButton("Teleport to Trading Hub", function() end)
        AddSection("Auto Rebirth")
        AddToggle("Auto Rebirth", false, function(v) _G.AutoRebirth = v end)

    elseif cleanName == "Gifting" then
        AddSection("Mail Gifting")
        AddToggle("Enable Auto Gifting", false, function(v) _G.GiftingEnabled = v end)
        AddSection("Bypass")
        AddToggle("Bypass 20x Limit", false, function(v) _G.GiftBypass = v end)
        AddSection("Anti-Ban")
        AddToggle("Randomize Delay", true, function(v) _G.GiftRandomDelay = v end)
        AddToggle("Stop if Flagged", true, function(v) _G.GiftStopFlagged = v end)
        AddLabel("📊 Status: Idle")
        AddLabel("📦 Mails Sent: 0")
        AddButton("▶ Start Gifting", function() _G.GiftingEnabled = true end)
        AddButton("⏹ Stop Gifting", function() _G.GiftingEnabled = false end)

    elseif cleanName == "Config" then
        AddSection("About")
        AddLabel("🌱 AXION HUB • Garden 2")
        AddLabel("📱 Mobile Native UI v4.0")
        AddLabel("🎨 Green Theme • Animated")
        AddSection("Controls")
        AddButton("🔄 Refresh UI", function() BuildTab(currentTab) end)
        AddButton("❌ Close UI", function()
            TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0)
            }):Play()
            task.wait(0.3)
            ScreenGui:Destroy()
        end)
    end

    -- Smooth scroll to top with tween
    TweenService:Create(ScrollFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        CanvasPosition = Vector2.new(0, 0)
    }):Play()
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

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabBtn

    tabButtons[i] = tabBtn

    tabBtn.MouseButton1Click:Connect(function()
        if currentTab == tabName then return end
        local cleanName = tabName:gsub("[%p%s%a]* ", "")

        -- Update button colors
        for j, btn in ipairs(tabButtons) do
            TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(35, 45, 35)
            }):Play()
        end
        TweenService:Create(tabBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = GreenDark
        }):Play()

        -- Animate indicator
        TweenService:Create(TabIndicator, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, (i - 1) * 70 + 6, 0, 88)
        }):Play()

        -- Fade out content
        TweenService:Create(ContentContainer, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 0.8
        }):Play()

        task.wait(0.15)

        currentTab = tabName
        BuildTab(tabName)

        -- Fade in content
        TweenService:Create(ContentContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 0
        }):Play()
    end)
end

-- Initial build
currentTab = tabs[1]
BuildTab(currentTab)

-- Entrance animation
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 360, 0, 480),
    Position = UDim2.new(0.5, -180, 0.5, -240)
}):Play()

-- Background loops
spawn(function()
    while task.wait(0.1) do
        if _G.NoClip then
            local char = Player.Character
            if char then
                for _, v in ipairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end
    end
end)

spawn(function()
    while task.wait(0.5) do
        if _G.HidePlants then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and (v.Name:lower():find("plant") or v.Name:lower():find("flower")) then
                    v.Transparency = 1
                end
            end
        end
    end
end)

spawn(function()
    while _G.InfJump and task.wait(0.05) do
        if _G.InfJump then
            local char = Player.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- Notification
game.StarterGui:SetCore("SendNotification", {
    Title = "AXION • Garden 2",
    Text = "UI v4.0 Loaded • Green Theme",
    Duration = 4,
})
