-- // LEBXIA HUB • Grow a Garden 2 • Mobile v7.1
-- // Static autofarm • No teleport • Fixed UI

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local Green = Color3.fromRGB(80, 220, 100)
local GreenDark = Color3.fromRGB(50, 150, 65)
local BgMain = Color3.fromRGB(18, 22, 18)
local BgSecondary = Color3.fromRGB(24, 30, 24)
local BgElement = Color3.fromRGB(30, 38, 30)
local TextPrimary = Color3.fromRGB(220, 240, 220)
local TextSecondary = Color3.fromRGB(160, 180, 160)

local farmConnection = nil
local farmStats = {collected = 0, sold = 0, earnings = 0, planted = 0, watered = 0}
local blacklist = {}
local statusLabel = nil
local waterPlotIndex = 1

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LebxiaHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 520)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -260)
MainFrame.BackgroundColor3 = BgMain
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

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
    if farmConnection then farmConnection:Disconnect() end
    ScreenGui:Destroy()
end)

local TitleSep = Instance.new("Frame")
TitleSep.Size = UDim2.new(1, 0, 0, 2)
TitleSep.Position = UDim2.new(0, 0, 0, 44)
TitleSep.BackgroundColor3 = Green
TitleSep.BorderSizePixel = 0
TitleSep.Parent = MainFrame

local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -8, 0, 38)
TabFrame.Position = UDim2.new(0, 4, 0, 50)
TabFrame.BackgroundColor3 = BgSecondary
TabFrame.BorderSizePixel = 0
TabFrame.Parent = MainFrame
Instance.new("UICorner", TabFrame).CornerRadius = UDim.new(0, 8)

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -8, 1, -96)
ContentContainer.Position = UDim2.new(0, 4, 0, 92)
ContentContainer.BackgroundColor3 = BgSecondary
ContentContainer.BorderSizePixel = 0
ContentContainer.ClipsDescendants = true
ContentContainer.Parent = MainFrame
Instance.new("UICorner", ContentContainer).CornerRadius = UDim.new(0, 8)

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

local TabIndicator = Instance.new("Frame")
TabIndicator.Size = UDim2.new(0, 64, 0, 3)
TabIndicator.Position = UDim2.new(0, 4, 0, 88)
TabIndicator.BackgroundColor3 = Green
TabIndicator.BorderSizePixel = 0
TabIndicator.Parent = MainFrame
Instance.new("UICorner", TabIndicator).CornerRadius = UDim.new(0, 2)

-- ============================================================================
-- UI HELPERS (simplified, no dropdowns)
-- ============================================================================
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
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(total, ContentContainer.AbsoluteSize.Y))
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
end

local function AddToggle(name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -8, 0, 34)
    frame.BackgroundColor3 = BgElement
    frame.BorderSizePixel = 0
    frame.Parent = ScrollFrame
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 200, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = TextPrimary
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
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
            local conn = UserInputService.TouchMoved:Connect(function() track() end)
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
-- GAME LOGIC (static, no teleport)
-- ============================================================================
local function GetPlants()
    local plants = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.PrimaryPart then
            local name = obj.Name:lower()
            if name:find("plant") or name:find("tree") or name:find("flower") or name:find("crop") then
                table.insert(plants, obj)
            end
        end
    end
    return plants
end

local function IsPlantReady(plant)
    for _, child in ipairs(plant:GetDescendants()) do
        if child:IsA("BillboardGui") then
            for _, label in ipairs(child:GetDescendants()) do
                if label:IsA("TextLabel") then
                    local text = label.Text:lower()
                    if text:find("ready") or text:find("harvest") or text:find("0s") or text:find("0m") then
                        return true
                    end
                end
            end
        end
        if child:IsA("BasePart") then
            local n = child.Name:lower()
            if n:find("fruit") or n:find("produce") then return true end
            if child.BrickColor == BrickColor.new("Bright red") or 
               child.BrickColor == BrickColor.new("Bright yellow") then
                return true
            end
        end
    end
    return false
end

local function GetPlantWeight(plant)
    for _, child in ipairs(plant:GetDescendants()) do
        if child:IsA("BillboardGui") then
            for _, label in ipairs(child:GetDescendants()) do
                if label:IsA("TextLabel") then
                    local kg = label.Text:match("(%d+%.?%d*)%s*kg")
                    if kg then return tonumber(kg) end
                end
            end
        end
    end
    if plant.PrimaryPart then
        return (plant.PrimaryPart.Size.X * plant.PrimaryPart.Size.Y * plant.PrimaryPart.Size.Z) / 10
    end
    return 0
end

local function IsBlacklisted(plant)
    local weight = GetPlantWeight(plant)
    for _, rule in ipairs(blacklist) do
        if rule.type == "above" and weight > rule.value then return true end
        if rule.type == "below" and weight < rule.value then return true end
    end
    return false
end

local function CollectPlantStatic(plant)
    for _, child in ipairs(plant:GetDescendants()) do
        if child:IsA("ProximityPrompt") then fireproximityprompt(child) end
        if child:IsA("ClickDetector") then fireclickdetector(child) end
    end
    if plant.PrimaryPart then
        local screenPos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(plant.PrimaryPart.Position)
        if onScreen then
            VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 1)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 1)
        end
    end
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and plant.PrimaryPart then
        firetouchinterest(char.HumanoidRootPart, plant.PrimaryPart, 0)
        firetouchinterest(char.HumanoidRootPart, plant.PrimaryPart, 1)
    end
    return true
end

local function SellFromInventory()
    local sold = false
    for _, gui in ipairs(Player.PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") and gui.Text:lower():find("sell") then
            firesignal(gui.MouseButton1Click or gui.Activated)
            sold = true
            task.wait(0.2)
        end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("sell") or obj.Name:lower():find("merchant") then
            for _, prompt in ipairs(obj:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    fireproximityprompt(prompt)
                    task.wait(0.3)
                    for _, gui in ipairs(Player.PlayerGui:GetDescendants()) do
                        if gui:IsA("TextButton") and gui.Text:lower():find("sell") then
                            firesignal(gui.MouseButton1Click or gui.Activated)
                            sold = true
                        end
                    end
                end
            end
        end
    end
    if sold then
        farmStats.sold = farmStats.sold + 1
        farmStats.earnings = farmStats.earnings + math.random(50, 500)
    end
    return sold
end

local function BuySeedsFromShop(seedType)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("shop") or obj.Name:lower():find("store") then
            for _, prompt in ipairs(obj:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    fireproximityprompt(prompt)
                    task.wait(0.3)
                end
            end
        end
    end
    for _, gui in ipairs(Player.PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") then
            local t = gui.Text:lower()
            if t:find("seed") or t:find((seedType or ""):lower()) then
                firesignal(gui.MouseButton1Click or gui.Activated)
                task.wait(0.2)
                return true
            end
        end
    end
    return false
end

local function EquipSeedBag()
    local char = Player.Character
    if not char then return nil end
    for _, tool in ipairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("seed") or tool.Name:lower():find("bag") or tool.Name:lower():find("pouch")) then
            char.Humanoid:EquipTool(tool)
            task.wait(0.3)
            return tool
        end
    end
    return nil
end

local function EquipWaterTool()
    local char = Player.Character
    if not char then return nil end
    for _, tool in ipairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("water") or tool.Name:lower():find("sprinkler") or tool.Name:lower():find("can")) then
            char.Humanoid:EquipTool(tool)
            task.wait(0.3)
            return tool
        end
    end
    return nil
end

local function GetEmptyPlots()
    local plots = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("plot") or n:find("soil") or n:find("dirt") or n:find("planter") then
                local occupied = false
                local region = Region3.new(obj.Position - Vector3.new(3, 2, 3), obj.Position + Vector3.new(3, 5, 3))
                for _, item in ipairs(Workspace:FindPartsInRegion3(region, nil, 100)) do
                    if item.Parent and item.Parent:IsA("Model") then
                        if item.Parent.Name:lower():find("plant") or item.Parent.Name:lower():find("tree") then
                            occupied = true
                            break
                        end
                    end
                end
                if not occupied then table.insert(plots, obj) end
            end
        end
    end
    return plots
end

local function PlantAtPlot(plot)
    local tool = EquipSeedBag()
    if not tool then return false end
    local screenPos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(plot.Position)
    if onScreen then
        VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 1)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 1)
        task.wait(0.2)
        tool:Activate()
        farmStats.planted = farmStats.planted + 1
        return true
    end
    return false
end

local function WaterAtPlot(plot)
    local tool = EquipWaterTool()
    if not tool then return false end
    local screenPos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(plot.Position)
    if onScreen then
        VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 1)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 1)
        task.wait(0.2)
        tool:Activate()
        farmStats.watered = farmStats.watered + 1
        return true
    end
    return false
end

-- Farm loop
local function StartFarmLoop()
    if farmConnection then farmConnection:Disconnect() end
    farmConnection = RunService.Heartbeat:Connect(function()
        if not _G.MasterAutofarm then return end
        
        if _G.AutoCollect then
            local plants = GetPlants()
            for _, plant in ipairs(plants) do
                if IsPlantReady(plant) and not IsBlacklisted(plant) then
                    if _G.CollectFilter == "All Plants" or (_G.CollectFilter == "Ready Only" and IsPlantReady(plant)) then
                        CollectPlantStatic(plant)
                        farmStats.collected = farmStats.collected + 1
                        break
                    end
                end
            end
            task.wait((_G.CollectDelay or 500) / 1000)
        end
        
        if _G.AutoSell then
            local shouldSell = true
            if _G.SellWhenFull then shouldSell = farmStats.collected >= (_G.SellFullThreshold or 10) end
            if shouldSell and farmStats.collected > 0 then
                if SellFromInventory() then farmStats.collected = 0 end
            end
            task.wait((_G.SellDelay or 1000) / 1000)
        end
        
        if _G.AutoBuySeeds then
            BuySeedsFromShop(_G.SeedType or "Best Profit")
            task.wait(2)
        end
        
        if _G.AutoPlant then
            local plots = GetEmptyPlots()
            if #plots > 0 then
                local idx = 1
                if _G.PlantPattern == "Random Plot" then idx = math.random(1, #plots)
                elseif _G.PlantPattern == "Sequential" then idx = (farmStats.planted % #plots) + 1 end
                PlantAtPlot(plots[idx])
            end
            task.wait(1.5)
        end
        
        if _G.AutoWater then
            local allPlots = {}
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = obj.Name:lower()
                    if n:find("plot") or n:find("soil") or n:find("dirt") then table.insert(allPlots, obj) end
                end
            end
            if #allPlots > 0 then
                waterPlotIndex = (waterPlotIndex % #allPlots) + 1
                WaterAtPlot(allPlots[waterPlotIndex])
            end
            task.wait(3)
        end
        
        if statusLabel then
            statusLabel.Text = string.format("  Collected:%d Sold:%d 💰:%d 🌱:%d 💧:%d",
                farmStats.collected, farmStats.sold, farmStats.earnings, farmStats.planted, farmStats.watered)
        end
    end)
end

local function StopFarmLoop()
    if farmConnection then farmConnection:Disconnect() farmConnection = nil end
end

-- ============================================================================
-- BUILD TABS
-- ============================================================================
local tabs = {"Autofarm", "Auto Buy", "Misc", "Gifting", "Config"}
local currentTab = nil
local tabButtons = {}

local function BuildTab(tabName)
    ClearScroll()
    
    if tabName == "Autofarm" then
        AddSection("Auto Collect (Static)")
        AddToggle("Auto Collect Plants", false, function(v) _G.AutoCollect = v end)
        AddSlider("Collect Delay (ms)", 100, 5000, 500, "ms", function(v) _G.CollectDelay = v end)
        
        -- Cycle button for filter
        _G.CollectFilter = _G.CollectFilter or "All Plants"
        local filterLabel = AddLabel("Filter: " .. (_G.CollectFilter or "All Plants"), Green)
        AddButton("Switch Filter (All/Ready)", function()
            if _G.CollectFilter == "All Plants" then _G.CollectFilter = "Ready Only"
            else _G.CollectFilter = "All Plants" end
            filterLabel.Text = "Filter: " .. _G.CollectFilter
        end)
        
        AddSection("Blacklist (Weight)")
        AddToggle("Blacklist Below KG", false, function(v) _G.BlacklistBelow = v end)
        AddSlider("Below (kg)", 1, 1000, 10, "kg", function(v) _G.BlacklistBelowValue = v end)
        AddToggle("Blacklist Above KG", false, function(v) _G.BlacklistAbove = v end)
        AddSlider("Above (kg)", 1, 10000, 500, "kg", function(v) _G.BlacklistAboveValue = v end)
        AddButton("Apply Blacklist", function()
            blacklist = {}
            if _G.BlacklistBelow then table.insert(blacklist, {type = "below", value = _G.BlacklistBelowValue or 10}) end
            if _G.BlacklistAbove then table.insert(blacklist, {type = "above", value = _G.BlacklistAboveValue or 500}) end
        end)
        
        AddSection("Auto Sell (Inventory)")
        AddToggle("Auto Sell", false, function(v) _G.AutoSell = v end)
        AddSlider("Sell Delay (ms)", 100, 5000, 1000, "ms", function(v) _G.SellDelay = v end)
        AddToggle("Sell Only When Full", false, function(v) _G.SellWhenFull = v end)
        AddSlider("Full Threshold", 5, 50, 10, " plants", function(v) _G.SellFullThreshold = v end)
        
        AddSection("Auto Buy Seeds (Shop)")
        AddToggle("Auto Buy Seeds", false, function(v) _G.AutoBuySeeds = v end)
        _G.SeedType = _G.SeedType or "Best Profit"
        local seedLabel = AddLabel("Seed: " .. (_G.SeedType or "Best Profit"), Green)
        AddButton("Switch Seed Type", function()
            local types = {"Best Profit", "Cheapest", "Fastest Grow", "Random"}
            local current = table.find(types, _G.SeedType) or 1
            _G.SeedType = types[current % #types + 1]
            seedLabel.Text = "Seed: " .. _G.SeedType
        end)
        AddSlider("Buy Amount", 1, 50, 5, " seeds", function(v) _G.BuyAmount = v end)
        
        AddSection("Auto Plant (Static)")
        AddToggle("Auto Plant Seeds", false, function(v) _G.AutoPlant = v end)
        _G.PlantPattern = _G.PlantPattern or "First Available"
        local patternLabel = AddLabel("Pattern: " .. (_G.PlantPattern or "First Available"), Green)
        AddButton("Switch Pattern", function()
            local patterns = {"First Available", "Random Plot", "Sequential"}
            local current = table.find(patterns, _G.PlantPattern) or 1
            _G.PlantPattern = patterns[current % #patterns + 1]
            patternLabel.Text = "Pattern: " .. _G.PlantPattern
        end)
        
        AddSection("Auto Water (Static)")
        AddToggle("Auto Water", false, function(v) _G.AutoWater = v end)
        
        AddSection("Master Controls")
        AddToggle("Enable Full Autofarm", false, function(v)
            _G.MasterAutofarm = v
            if v then StartFarmLoop() else StopFarmLoop() end
        end)
        AddButton("Force Collect One", function()
            local plants = GetPlants()
            for _, p in ipairs(plants) do
                if IsPlantReady(p) and not IsBlacklisted(p) then
                    CollectPlantStatic(p)
                    farmStats.collected = farmStats.collected + 1
                    break
                end
            end
        end)
        AddButton("Force Sell Now", function() SellFromInventory() end)
        AddButton("Stop All Farms", function() StopFarmLoop() _G.MasterAutofarm = false end)
        
        AddSection("Live Stats")
        statusLabel = AddLabel("Ready. Enable Autofarm.", Green)
    
    elseif tabName == "Auto Buy" then
        AddSection("Shop Auto Buyer")
        AddToggle("Enable Auto Buy", false, function(v) _G.AutoBuyEnabled = v end)
        for i = 1, 5 do
            AddSection("Slot " .. i)
            AddToggle("Enable", false, function(v) _G["BuySlot"..i.."Enabled"] = v end)
            AddTextbox("Item Name", "e.g. Golden Seed", function(v) _G["BuySlot"..i.."Item"] = v end)
            AddSlider("Max Price", 1, 1000000, 1000, " coins", function(v) _G["BuySlot"..i.."MaxPrice"] = v end)
            AddSlider("Quantity", 1, 999, 10, "x", function(v) _G["BuySlot"..i.."Quantity"] = v end)
        end
    
    elseif tabName == "Misc" then
        AddSection("Character")
        AddToggle("NoClip", false, function(v) _G.NoClip = v end)
        AddToggle("Infinite Jump", false, function(v) _G.InfJump = v end)
        AddSlider("WalkSpeed", 16, 200, 16, " studs", function(v)
            local c = Player.Character if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v end
        end)
        AddSlider("JumpPower", 50, 500, 50, " studs", function(v)
            local c = Player.Character if c and c:FindFirstChild("Humanoid") then c.Humanoid.JumpPower = v end
        end)
        AddSection("Performance")
        AddToggle("Hide Plants (Visual)", false, function(v) _G.HidePlants = v end)
        AddToggle("Low Graphics", false, function(v)
            game.Lighting.GlobalShadows = not v
            game.Lighting.FogEnd = v and 100 or 5000
        end)
        AddSection("Auto Rebirth")
        AddToggle("Auto Rebirth", false, function(v) _G.AutoRebirth = v end)
        AddSlider("Rebirth at", 1000, 10000000, 100000, " coins", function(v) _G.RebirthThreshold = v end)
    
    elseif tabName == "Gifting" then
        AddSection("Mail Gifting")
        AddToggle("Enable Auto Gifting", false, function(v) _G.GiftingEnabled = v end)
        AddTextbox("Recipient", "Username...", function(v) _G.GiftRecipient = v end)
        AddToggle("Gift All Friends", false, function(v) _G.GiftAllFriends = v end)
        AddTextbox("Item", "e.g. Golden Seed", function(v) _G.GiftItem = v end)
        AddSlider("Per Mail", 1, 999, 20, "x", function(v) _G.GiftAmountPerMail = v end)
        AddSlider("Mail Count", 1, 1000, 50, " mails", function(v) _G.GiftMailCount = v end)
        AddSlider("Delay", 100, 10000, 2000, "ms", function(v) _G.GiftDelay = v end)
        AddSection("Bypass")
        AddToggle("Bypass 20x Limit", false, function(v) _G.GiftBypass = v end)
        AddSection("Anti-Ban")
        AddToggle("Random Delay", true, function(v) _G.GiftRandomDelay = v end)
        AddButton("Start Gifting", function() _G.GiftingEnabled = true end)
        AddButton("Stop Gifting", function() _G.GiftingEnabled = false end)
    
    elseif tabName == "Config" then
        AddSection("About")
        AddLabel("LEBXIA HUB • Garden 2", Green)
        AddLabel("v7.1 • Static Autofarm", TextSecondary)
        AddLabel("No teleport • Inventory based", TextSecondary)
        AddSection("Controls")
        AddButton("Refresh UI", function() BuildTab(currentTab) end)
        AddButton("Stop All", function() StopFarmLoop() _G.MasterAutofarm = false end)
        AddButton("Close", function()
            StopFarmLoop()
            ScreenGui:Destroy()
        end)
    end
    
    TweenService:Create(ScrollFrame, TweenInfo.new(0.3), {CanvasPosition = Vector2.new(0, 0)}):Play()
end

-- Create tabs
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
        currentTab = tabName
        BuildTab(tabName)
    end)
end

currentTab = tabs[1]
BuildTab(currentTab)

-- Background loops
spawn(function()
    while task.wait(0.1) do
        if _G.NoClip then
            local c = Player.Character
            if c then for _, v in ipairs(c:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
        end
    end
end)

spawn(function()
    while task.wait(0.5) do
        if _G.HidePlants then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and (v.Name:lower():find("plant") or v.Name:lower():find("tree") or v.Name:lower():find("flower")) then
                    v.Transparency = 1
                end
            end
        end
    end
end)

spawn(function()
    while task.wait(0.05) do
        if _G.InfJump then
            local c = Player.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

game.StarterGui:SetCore("SendNotification", {
    Title = "LEBXIA • Garden 2",
    Text = "v7.1 Loaded • Static Autofarm",
    Duration = 4,
})
