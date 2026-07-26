-- ============================================================
-- 🐾 .KenzyPets – Auto Pet Buyer + FPS Boost + Smart Hide
-- ============================================================
-- CONFIG
local WALK_SPEED = 35
local CONFIRM_TIMEOUT = 2
local MAX_APPROACH_ATTEMPTS = 10
local PROXIMITY_REQUIRED = 20
local SCAN_INTERVAL = 1.0
local CONSECUTIVE_EMPTY = 3
local INVENTORY_TIMEOUT = 30
-- ============================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserSettings = game:GetService("UserSettings")

print("🚀 .KenzyPets loaded.")

-- ============================================================
-- ⚡ FPS BOOST – Graphics Optimization (Safe)
-- ============================================================
local function optimizeGraphics()
    pcall(function()
        local graphicsMode = UserSettings:GetService("UserGameSettings")
        if graphicsMode then
            graphicsMode.ClassicFramerateMode = 2
            graphicsMode.EnableFrameRateCap = true
            graphicsMode.MaximumFramerate = 60
        end
        Lighting.GlobalShadows = false
        Lighting.Brightness = 0.5
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        print("⚡ Graphics optimized.")
    end)
end
optimizeGraphics()
task.spawn(function()
    while true do
        task.wait(30)
        optimizeGraphics()
    end
end)

-- ============================================================
-- 🖥️ GUI – .KenzyPets (unchanged)
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "KenzyPetsGUI"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 420)
frame.Position = UDim2.new(0.5, -150, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.15
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local border = Instance.new("UIStroke")
border.Color = Color3.fromRGB(255, 200, 100)
border.Thickness = 1
border.Transparency = 0.5
border.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🐾 .KenzyPets"
title.TextColor3 = Color3.fromRGB(255, 200, 100)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 40)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = frame

local progressLabel = Instance.new("TextLabel")
progressLabel.Size = UDim2.new(1, 0, 0, 20)
progressLabel.Position = UDim2.new(0, 0, 0, 60)
progressLabel.BackgroundTransparency = 1
progressLabel.Text = "Progress: 0/0"
progressLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
progressLabel.TextSize = 12
progressLabel.Font = Enum.Font.Gotham
progressLabel.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -32, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -10, 1, -120)
scroll.Position = UDim2.new(0, 5, 0, 85)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 200, 100)
scroll.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scroll
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 2)

local function addPetLabel(name, status)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = name .. " – " .. (status or "Queued")
    label.TextColor3 = (status == "Bought") and Color3.fromRGB(100, 255, 100)
        or (status == "Moving" or status == "Buying" or status == "Waiting...") and Color3.fromRGB(255, 200, 100)
        or Color3.fromRGB(200, 200, 200)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = scroll
    return label
end

local function updateStatus(text)
    statusLabel.Text = "Status: " .. text
end

local function updateProgress(confirmed, total)
    progressLabel.Text = "Progress: " .. confirmed .. "/" .. total
end

-- ============================================================
-- 🧹 SMART HIDE – Only hide other players' gardens & fruits
-- ============================================================
local function hideObject(obj)
    pcall(function()
        if obj:IsA("BasePart") then
            obj.Transparency = 1
            obj.CanCollide = false
            obj.CanQuery = false
            obj.CanTouch = false
            obj.Material = Enum.Material.Plastic
        elseif obj:IsA("Decal") then
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            obj.Enabled = false
        elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = false
        elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
            obj.Enabled = false
        end
    end)
end

local function isOurGarden(garden)
    return garden.Name == LocalPlayer.Name
end

local function hideOtherGardens()
    local Gardens = Workspace:FindFirstChild("Gardens")
    if not Gardens then return end

    for _, garden in ipairs(Gardens:GetChildren()) do
        if garden:IsA("Folder") or garden:IsA("Model") then
            if not isOurGarden(garden) then
                for _, child in ipairs(garden:GetDescendants()) do
                    hideObject(child)
                end
                if garden:IsA("Model") and garden.PrimaryPart then
                    garden.PrimaryPart.Transparency = 1
                end
            end
        end
    end
end

local function hideFruitsAndPlants()
    local keywords = {"Fruit", "Berry", "Apple", "Plant", "Tree", "Seed", "Crop", "Vegetable", "Garden", "Flower"}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name ~= LocalPlayer.Name then
            local shouldHide = false
            for _, kw in ipairs(keywords) do
                if string.find(obj.Name, kw) then
                    shouldHide = true
                    break
                end
            end
            if shouldHide then
                -- Check if it's not the map or terrain (by parent)
                local parent = obj.Parent
                if parent and parent.Name ~= "Map" and parent.Name ~= "Terrain" and parent.Name ~= "WildPetRef" and parent.Name ~= "WildPetSpawns" then
                    for _, child in ipairs(obj:GetDescendants()) do
                        hideObject(child)
                    end
                end
            end
        end
    end
end

-- Initial hide after a delay
task.spawn(function()
    print("⏳ Waiting 3 seconds for gardens to load...")
    task.wait(3)
    print("🧹 Hiding other players' gardens and fruits...")
    hideOtherGardens()
    hideFruitsAndPlants()
    print("✅ Visual cleanup complete.")
end)

-- Watch for new objects
Workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.1)
    -- Check if it's a garden
    if obj:IsA("Folder") or obj:IsA("Model") then
        if obj.Name ~= LocalPlayer.Name and obj.Parent and obj.Parent.Name == "Gardens" then
            for _, child in ipairs(obj:GetDescendants()) do
                hideObject(child)
            end
        end
    end
    -- Check if it's a fruit/plant model outside gardens
    local keywords = {"Fruit", "Berry", "Apple", "Plant", "Tree", "Seed", "Crop", "Vegetable", "Garden", "Flower"}
    if obj:IsA("Model") and obj.Name ~= LocalPlayer.Name then
        for _, kw in ipairs(keywords) do
            if string.find(obj.Name, kw) then
                local parent = obj.Parent
                if parent and parent.Name ~= "Map" and parent.Name ~= "Terrain" and parent.Name ~= "WildPetRef" and parent.Name ~= "WildPetSpawns" then
                    for _, child in ipairs(obj:GetDescendants()) do
                        hideObject(child)
                    end
                end
                break
            end
        end
    end
end)

-- Periodic cleanup every 10 seconds
task.spawn(function()
    while true do
        task.wait(10)
        hideOtherGardens()
        hideFruitsAndPlants()
    end
end)

-- ============================================================
-- 🔍 Remote and pet detection (unchanged)
-- ============================================================
local function getTameRemote()
    local success, Networking = pcall(function()
        return require(ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("Networking"))
    end)
    if success and Networking and Networking.Pets and Networking.Pets.WildPetTame then
        return Networking.Pets.WildPetTame
    end
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name == "WildPetTame" then
            return obj
        end
    end
    return nil
end

local function getResultRemote()
    local success, Networking = pcall(function()
        return require(ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("Networking"))
    end)
    if success and Networking and Networking.Pets and Networking.Pets.WildPetTameResult then
        return Networking.Pets.WildPetTameResult
    end
    return nil
end

local function getPacketRemote()
    local remote = ReplicatedStorage:FindFirstChild("SharedModules")
    if remote then
        remote = remote:FindFirstChild("Packet")
        if remote then
            return remote:FindFirstChild("RemoteEvent")
        end
    end
    return nil
end

local PetModules = nil
local function getPetDisplayName(species)
    if not PetModules then
        local success, mod = pcall(function()
            return require(ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("PetModules"))
        end)
        if success then
            PetModules = mod
        end
    end
    if PetModules and PetModules[species] and PetModules[species].DisplayName then
        return PetModules[species].DisplayName
    end
    return species
end

local function getPetParts()
    local parts = {}
    local map = Workspace:FindFirstChild("Map")
    if not map then return parts end
    local folders = { "WildPetRef", "WildPetSpawns" }
    for _, name in ipairs(folders) do
        local folder = map:FindFirstChild(name)
        if folder and folder:IsA("Folder") then
            for _, child in ipairs(folder:GetChildren()) do
                if child:IsA("BasePart") then
                    table.insert(parts, child)
                end
            end
            break
        end
    end
    if #parts == 0 then
        for _, child in ipairs(map:GetDescendants()) do
            if child:IsA("BasePart") and child:GetAttribute("Price") ~= nil then
                table.insert(parts, child)
            end
        end
    end
    return parts
end

local function isTamable(part)
    local owner = part:GetAttribute("OwnerUserId")
    return owner == 0 or owner == nil
end

-- ============================================================
-- 📊 Get reliable pet count
-- ============================================================
local function getPetCount()
    local count = LocalPlayer:GetAttribute("PetCount")
    if type(count) == "number" then
        return count
    end
    local count2 = 0
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") and item:GetAttribute("Pet") ~= nil then
                count2 = count2 + 1
            end
        end
    end
    return count2
end

-- ============================================================
-- 🚶 Walk with consistent speed
-- ============================================================
local function walkTo(position)
    local character = LocalPlayer.Character
    if not character then return false end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end

    local dist = (root.Position - position).Magnitude
    if dist <= PROXIMITY_REQUIRED then
        return true
    end

    local duration = dist / WALK_SPEED
    if duration < 0.2 then duration = 0.2 end
    if duration > 5 then duration = 5 end

    humanoid.AutoRotate = false
    local targetCFrame = CFrame.new(position + Vector3.new(0, 0.5, 0))
    local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { CFrame = targetCFrame })
    tween:Play()
    tween.Completed:Wait()
    humanoid.AutoRotate = true
    return true
end

-- ============================================================
-- 🎯 Main buying cycle – with inventory timeout
-- ============================================================
local function runBuyingCycle()
    local tameRemote = getTameRemote()
    local resultRemote = getResultRemote()
    local packetRemote = getPacketRemote()
    local purchaseBuffer = buffer.fromstring("\t\1\8Purchase")

    if not tameRemote then
        print("❌ Tame remote not found. Retrying...")
        task.wait(3)
        return false
    end
    print("✅ Tame remote found.")

    -- Clear GUI
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end

    local pendingParts = {}
    local confirmedParts = {}
    local petLabels = {}

    local resultConnection
    if resultRemote then
        resultConnection = resultRemote.OnClientEvent:Connect(function(part, userId)
            if userId == LocalPlayer.UserId and part and part:IsA("BasePart") then
                if not confirmedParts[part] then
                    confirmedParts[part] = true
                    local species = part:GetAttribute("PetName") or part.Name
                    local displayName = getPetDisplayName(species)
                    if petLabels[part] then
                        petLabels[part].Text = displayName .. " – ✅ Bought"
                        petLabels[part].TextColor3 = Color3.fromRGB(100, 255, 100)
                    end
                    print("✅✅✅ PET BOUGHT: " .. displayName)
                    updateProgress(getConfirmedCount(), getPendingCount())
                end
            end
        end)
    end

    local function getPendingCount()
        local count = 0
        for _ in pairs(pendingParts) do count = count + 1 end
        return count
    end
    local function getConfirmedCount()
        local count = 0
        for _, v in pairs(confirmedParts) do if v then count = count + 1 end end
        return count
    end

    local function addPendingPet(part)
        if pendingParts[part] then return end
        pendingParts[part] = true
        local species = part:GetAttribute("PetName") or part.Name
        local displayName = getPetDisplayName(species)
        local label = addPetLabel(displayName, "Queued")
        petLabels[part] = label
        updateProgress(getConfirmedCount(), getPendingCount())
        print("📌 Added pending: " .. displayName)
    end

    local function purchasePet(part)
        if confirmedParts[part] then return true end
        local species = part:GetAttribute("PetName") or part.Name
        local displayName = getPetDisplayName(species)

        if petLabels[part] then
            petLabels[part].Text = displayName .. " – Moving"
        end
        print("🚶 Moving to " .. displayName)

        local attempts = 0
        local gotClose = false
        while attempts < MAX_APPROACH_ATTEMPTS do
            attempts = attempts + 1
            local petPos = part.Position
            walkTo(petPos)
            local character = LocalPlayer.Character
            if character then
                local root = character:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (root.Position - part.Position).Magnitude
                    if dist <= PROXIMITY_REQUIRED then
                        gotClose = true
                        break
                    else
                        if attempts < MAX_APPROACH_ATTEMPTS then
                            print("   Pet moved, re‑approaching... (attempt " .. attempts .. ")")
                            task.wait(0.2)
                        end
                    end
                end
            end
        end

        if not gotClose then
            if petLabels[part] then
                petLabels[part].Text = displayName .. " – ⚠️ Too far"
            end
            print("⚠️ Could not get close to " .. displayName)
            return false
        end

        if petLabels[part] then
            petLabels[part].Text = displayName .. " – Buying"
        end
        print("💰 Buying " .. displayName)

        local purchased = false
        pcall(function() tameRemote:FireServer(part) purchased = true end)
        if not purchased then pcall(function() tameRemote:Fire(part) purchased = true end) end
        if not purchased then
            local prompt = part:FindFirstChild("BuyPrompt")
            if prompt and prompt:IsA("ProximityPrompt") then
                pcall(function() prompt:Fire(LocalPlayer) purchased = true end)
                if not purchased then
                    pcall(function()
                        prompt:InputHoldBegin()
                        task.wait(prompt.HoldDuration or 0.5)
                        prompt:InputHoldEnd()
                        purchased = true
                    end)
                end
            end
        end
        if not purchased and packetRemote then
            pcall(function() packetRemote:FireServer(purchaseBuffer) purchased = true end)
        end

        if petLabels[part] then
            petLabels[part].Text = displayName .. " – Waiting..."
        end
        print("⏳ Waiting for confirmation for " .. displayName)

        local startTime = os.clock()
        local confirmed = false
        while os.clock() - startTime < CONFIRM_TIMEOUT do
            if confirmedParts[part] then
                confirmed = true
                break
            end
            if part:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
                confirmedParts[part] = true
                if petLabels[part] then
                    petLabels[part].Text = displayName .. " – ✅ Bought"
                    petLabels[part].TextColor3 = Color3.fromRGB(100, 255, 100)
                end
                print("✅✅✅ PET BOUGHT (attribute): " .. displayName)
                updateProgress(getConfirmedCount(), getPendingCount())
                confirmed = true
                break
            end
            task.wait(0.2)
        end

        if confirmed then
            return true
        else
            if petLabels[part] then
                petLabels[part].Text = displayName .. " – ❌ Not Confirmed"
                petLabels[part].TextColor3 = Color3.fromRGB(255, 100, 100)
            end
            print("❌ Purchase not confirmed for " .. displayName)
            return false
        end
    end

    local emptyScans = 0
    local initialPetCount = getPetCount()
    local totalIntended = 0
    updateStatus("Scanning for pets...")
    print("📊 Initial pet count: " .. initialPetCount)

    while true do
        local parts = getPetParts()
        local tamable = {}
        for _, part in ipairs(parts) do
            if isTamable(part) then
                table.insert(tamable, part)
            end
        end

        for _, part in ipairs(tamable) do
            if not pendingParts[part] then
                addPendingPet(part)
            end
        end

        totalIntended = getPendingCount()

        if #tamable == 0 then
            emptyScans = emptyScans + 1
            local confirmed = getConfirmedCount()
            updateStatus("Scanning... (" .. emptyScans .. "/" .. CONSECUTIVE_EMPTY .. ")")
            print("🔍 Empty scan #" .. emptyScans .. " | Pending: " .. totalIntended .. ", Confirmed: " .. confirmed)

            if emptyScans >= CONSECUTIVE_EMPTY then
                updateStatus("⏳ Waiting for inventory...")
                print("⏳ Waiting up to " .. INVENTORY_TIMEOUT .. "s for pet count to increase by " .. totalIntended .. "...")
                print("   Current pet count: " .. getPetCount() .. ", expected: " .. initialPetCount + totalIntended)

                local startWait = os.clock()
                local inventoryUpdated = false
                while os.clock() - startWait < INVENTORY_TIMEOUT do
                    local currentCount = getPetCount()
                    if currentCount >= initialPetCount + totalIntended then
                        inventoryUpdated = true
                        break
                    end
                    task.wait(0.5)
                end

                if inventoryUpdated then
                    updateStatus("✅ Inventory updated – rejoining")
                    print("✅ Inventory count increased to " .. getPetCount() .. " (from " .. initialPetCount .. "). Rejoining...")
                else
                    updateStatus("⚠️ Inventory timeout – rejoining")
                    print("⚠️ Timeout: only " .. getPetCount() .. " pets (expected " .. initialPetCount + totalIntended .. "). Rejoining...")
                end

                if resultConnection then resultConnection:Disconnect() end
                print("🔄 Rejoining now...")
                return true
            end
            task.wait(SCAN_INTERVAL)
        else
            emptyScans = 0
            updateStatus("Buying " .. #tamable .. " pets...")
            print("🛒 Buying " .. #tamable .. " pets (pending: " .. totalIntended .. ")")
            for part in pairs(pendingParts) do
                if not confirmedParts[part] then
                    purchasePet(part)
                end
            end
            task.wait(0.5)
        end
    end
end

-- ============================================================
-- 🚀 AUTO‑EXECUTE LOOP
-- ============================================================
print("🚀 .KenzyPets started. Waiting for character...")
while true do
    repeat
        task.wait(0.1)
    until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    print("✅ Character ready.")
    local success = runBuyingCycle()
    if success then
        updateStatus("Rejoining...")
        print("🔄 Rejoining...")
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
        task.wait(5)
    else
        updateStatus("⚠️ Retrying...")
        print("⚠️ Cycle failed, retrying...")
        task.wait(1)
    end
end
