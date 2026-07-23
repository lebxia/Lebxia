-- // AXION HUB • Grow a Garden 2 • Mobile Native UI
-- // No external libraries. Pure Roblox GUI.

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Create main GUI container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AxionHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Main frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 350, 0, 450)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "AXION • Garden 2"
Title.TextColor3 = Color3.fromRGB(255, 100, 150)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Tab buttons container
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, 0, 0, 35)
TabFrame.Position = UDim2.new(0, 0, 0, 40)
TabFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TabFrame.BorderSizePixel = 0
TabFrame.Parent = MainFrame

-- Content frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -10, 1, -85)
ContentFrame.Position = UDim2.new(0, 5, 0, 80)
ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

-- Scrolling frame for content
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 100, 150)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = ContentFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ScrollFrame

-- Helper to create UI elements
local function ClearScroll()
    for _, v in ipairs(ScrollFrame:GetChildren()) do
        if v:IsA("Frame") or v:IsA("TextLabel") or v:IsA("TextButton") then
            v:Destroy()
        end
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end

local function AddLabel(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 100, 150)
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = ScrollFrame
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ScrollFrame.CanvasSize.Y.Offset + 30)
    return label
end

local function AddToggle(name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 30)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.BorderSizePixel = 0
    frame.Parent = ScrollFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 200, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 36, 0, 20)
    toggle.Position = UDim2.new(1, -44, 0, 5)
    toggle.BackgroundColor3 = default and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(80, 80, 80)
    toggle.Text = ""
    toggle.BorderSizePixel = 0
    toggle.Parent = frame

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = default and UDim2.new(0, 20, 0, 4) or UDim2.new(0, 4, 0, 4)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = toggle

    local enabled = default
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.BackgroundColor3 = enabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(80, 80, 80)
        dot.Position = enabled and UDim2.new(0, 20, 0, 4) or UDim2.new(0, 4, 0, 4)
        callback(enabled)
    end)

    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ScrollFrame.CanvasSize.Y.Offset + 35)
    return {Toggle = function() enabled = not enabled toggle.BackgroundColor3 = enabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(80, 80, 80) dot.Position = enabled and UDim2.new(0, 20, 0, 4) or UDim2.new(0, 4, 0, 4) callback(enabled) end, GetState = function() return enabled end}
end

local function AddButton(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = ScrollFrame
    btn.MouseButton1Click:Connect(callback)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ScrollFrame.CanvasSize.Y.Offset + 37)
    return btn
end

local function AddSection(name)
    local sec = Instance.new("TextLabel")
    sec.Size = UDim2.new(1, -10, 0, 22)
    sec.BackgroundTransparency = 1
    sec.Text = "— " .. name .. " —"
    sec.TextColor3 = Color3.fromRGB(255, 100, 150)
    sec.TextSize = 12
    sec.Font = Enum.Font.GothamBold
    sec.TextXAlignment = Enum.TextXAlignment.Center
    sec.Parent = ScrollFrame
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ScrollFrame.CanvasSize.Y.Offset + 27)
end

-- Build tabs
local tabs = {"Autofarm", "Auto Buy", "Misc", "Gifting", "Config"}
local currentTab = "Autofarm"

local function BuildTab(tab)
    ClearScroll()
    currentTab = tab

    if tab == "Autofarm" then
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
        AddSection("Master")
        AddToggle("Full Autofarm Loop", false, function(v) _G.MasterAutofarm = v end)
        AddButton("Force Collect Now", function() end)
        AddButton("Force Sell Now", function() end)

    elseif tab == "Auto Buy" then
        AddSection("Item Purchasing")
        AddToggle("Enable Auto Buy", false, function(v) _G.AutoBuyEnabled = v end)
        for i = 1, 5 do
            AddSection("Buy Slot #" .. i)
            AddToggle("Enable Slot " .. i, false, function(v) _G["BuySlot"..i.."Enabled"] = v end)
        end

    elseif tab == "Misc" then
        AddSection("Character")
        AddToggle("NoClip", false, function(v) _G.NoClip = v end)
        AddSection("Performance")
        AddToggle("Hide All Plants (Visual)", false, function(v) _G.HidePlants = v end)
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
        AddSection("Auto Rebirth")
        AddToggle("Auto Rebirth", false, function(v) _G.AutoRebirth = v end)

    elseif tab == "Gifting" then
        AddSection("Mail Gifting")
        AddToggle("Enable Auto Gifting", false, function(v) _G.GiftingEnabled = v end)
        AddSection("Bypass")
        AddToggle("Bypass 20x Limit", false, function(v) _G.GiftBypass = v end)
        AddSection("Anti-Ban")
        AddToggle("Randomize Delay", true, function(v) _G.GiftRandomDelay = v end)
        AddToggle("Stop if Flagged", true, function(v) _G.GiftStopFlagged = v end)
        AddLabel("Status: Idle")
        AddButton("Start Gifting", function() _G.GiftingEnabled = true end)
        AddButton("Stop Gifting", function() _G.GiftingEnabled = false end)

    elseif tab == "Config" then
        AddSection("Credits")
        AddLabel("AXION HUB • Garden 2")
        AddLabel("Mobile Native UI v3.0")
        AddLabel("Zero dependencies")
        AddSection("Controls")
        AddButton("Close UI", function() ScreenGui:Destroy() end)
    end
end

-- Create tab buttons
for i, tabName in ipairs(tabs) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0, 68, 1, 0)
    tabBtn.Position = UDim2.new(0, (i - 1) * 70, 0, 0)
    tabBtn.BackgroundColor3 = tabName == "Autofarm" and Color3.fromRGB(255, 100, 150) or Color3.fromRGB(40, 40, 50)
    tabBtn.Text = tabName
    tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabBtn.TextSize = 10
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.BorderSizePixel = 0
    tabBtn.Parent = TabFrame

    tabBtn.MouseButton1Click:Connect(function()
        for _, child in ipairs(TabFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            end
        end
        tabBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
        BuildTab(tabName)
    end)
end

-- Initial build
BuildTab("Autofarm")

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

-- Notify
game.StarterGui:SetCore("SendNotification", {
    Title = "AXION • Garden 2",
    Text = "UI Loaded. Native mobile GUI.",
    Duration = 5,
})
