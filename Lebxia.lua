-- ============================================================
-- 🐾 .KenzyPets – Auto Pet Buyer + Rejoin (Inventory Check)
-- ============================================================
-- CONFIG
local WALK_SPEED = 35
local CONFIRM_TIMEOUT = 4
local MAX_APPROACH_ATTEMPTS = 10
local PROXIMITY_REQUIRED = 10
local SCAN_INTERVAL = 1.0
local CONSECUTIVE_EMPTY = 3

-- Wait after confirming all pets are bought – gives time for inventory to update
local INVENTORY_WAIT = 3
-- ============================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

print("🚀 .KenzyPets loaded.")

-- ============================================================
-- 🖥️ IMPROVED GUI .KenzyPets
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "KenzyPetsGUI"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 380)
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
scroll.Size = UDim2.new(1, -10, 1, -80)
scroll.Position = UDim2.new(0, 5, 0, 65)
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

local function addPetLabel(name)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = name .. " – Queued"
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = scroll
    return label
end

local function updateStatus(text)
    statusLabel.Text = "Status: " .. text
end

-- ============================================================
-- 🧹 INSTANT HIDE OTHER GARDENS
-- ============================================================
local function hideGarden(garden)
    pcall(function()
        if garden:IsA("Folder") or garden:IsA("Model") then
            for _, child in ipairs(garden:GetDescendants()) do
                if child:IsA("BasePart") then
                    child.Transparency = 1
                    child.CanCollide = false
                    child.CanQuery = false
                    child.CanTouch = false
                    child.Material = Enum.Material.Plastic
                elseif child:IsA("Decal") then
                    child.Transparency = 1
                elseif child:IsA("ParticleEmitter") or child:IsA("Trail") or child:IsA("Beam") then
                    child.Enabled = false
                elseif child:IsA("Fire") or child:IsA("Smoke") or child:IsA("Sparkles") then
                    child.Enabled = false
                elseif child:IsA("BillboardGui") or child:IsA("SurfaceGui") then
                    child.Enabled = false
                end
            end
            if garden:IsA("Model") and garden.PrimaryPart then
                garden.PrimaryPart.Transparency = 1
            end
        end
    end)
end

local function startHidingGardens()
    local localName = LocalPlayer.Name
    local Gardens = Workspace:FindFirstChild("Gardens")
    if not Gardens then return end

    for _, garden in ipairs(Gardens:GetChildren()) do
        if garden.Name ~= localName then
            hideGarden(garden)
        end
    end

    Gardens.ChildAdded:Connect(function(newGarden)
        if newGarden.Name ~= localName then
            hideGarden(newGarden)
        end
    end)
    print("🧹 Garden hiding active.")
end

startHidingGardens()

-- ============================================================
-- 🔍 Remote and pet detection
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

-- Get current pet count from player attributes or a folder
local function getPetCount()
    -- Try attribute first
    local count = LocalPlayer:GetAttribute("PetCount")
    if type(count) == "number" then
        return count
    end
    -- Fallback: count tools in backpack that have "Pet" attribute
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
-- 🚶 Walk with consistent speed, follow moving pets
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
-- 🎯 Main buying cycle – scan until no pets left + inventory wait
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

    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end

    local petLabels = {}
    local boughtParts = {}

    -- Track pet count before buying
    local initialPetCount = getPetCount()
    print("📊 Current pet count:", initialPetCount)

    local resultConnection
    if resultRemote then
        resultConnection = resultRemote.OnClientEvent:Connect(function(part, userId)
            if userId == LocalPlayer.UserId and part and part:IsA("BasePart") then
                if not boughtParts[part] then
                    boughtParts[part] = true
                    if petLabels[part] then
                        petLabels[part].Text = part.Name .. " – ✅ Bought"
                        petLabels[part].TextColor3 = Color3.fromRGB(100, 255, 100)
                    end
                    print("✅ Confirmed: " .. part.Name)
                end
            end
        end)
    end

    local function purchasePet(part)
        if boughtParts[part] then return true end

        if petLabels[part] then
            petLabels[part].Text = part.Name .. " – Moving"
        end

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
                            print("   Pet moved, re‑approaching...")
                            task.wait(0.2)
                        end
                    end
                end
            end
        end

        if not gotClose then
            if petLabels[part] then
                petLabels[part].Text = part.Name .. " – ⚠️ Too far"
            end
            return false
        end

        if petLabels[part] then
            petLabels[part].Text = part.Name .. " – Buying"
        end

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
            petLabels[part].Text = part.Name .. " – Waiting..."
        end

        local startTime = os.clock()
        local confirmed = false
        while os.clock() - startTime < CONFIRM_TIMEOUT do
            if boughtParts[part] then
                confirmed = true
                break
            end
            if part:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
                boughtParts[part] = true
                if petLabels[part] then
                    petLabels[part].Text = part.Name .. " – ✅ Bought"
                    petLabels[part].TextColor3 = Color3.fromRGB(100, 255, 100)
                end
                confirmed = true
                break
            end
            task.wait(0.2)
        end

        if confirmed then
            return true
        else
            if petLabels[part] then
                petLabels[part].Text = part.Name .. " – ❌ Not Confirmed"
                petLabels[part].TextColor3 = Color3.fromRGB(255, 100, 100)
            end
            return false
        end
    end

    local emptyCount = 0
    while true do
        local parts = getPetParts()
        local tamable = {}
        for _, part in ipairs(parts) do
            if isTamable(part) then
                table.insert(tamable, part)
            end
        end

        if #tamable == 0 then
            emptyCount = emptyCount + 1
            updateStatus("Scanning... (" .. emptyCount .. "/" .. CONSECUTIVE_EMPTY .. ")")
            if emptyCount >= CONSECUTIVE_EMPTY then
                updateStatus("✅ No pets left – checking inventory...")
                -- Wait until pet count increases or timeout (INVENTORY_WAIT)
                local startWait = os.clock()
                local finalPetCount = getPetCount()
                while os.clock() - startWait < INVENTORY_WAIT do
                    local newCount = getPetCount()
                    if newCount > initialPetCount then
                        finalPetCount = newCount
                        break
                    end
                    task.wait(0.2)
                end
                print("📊 Pet count before: " .. initialPetCount .. ", after: " .. finalPetCount)
                updateStatus("✅ Inventory updated – rejoining")
                if resultConnection then resultConnection:Disconnect() end
                return true
            end
            task.wait(SCAN_INTERVAL)
        else
            emptyCount = 0
            updateStatus("Buying " .. #tamable .. " pets...")
            print("🔍 Found " .. #tamable .. " tamable pet(s). Buying...")
            for _, part in ipairs(tamable) do
                if not petLabels[part] then
                    local label = addPetLabel(part.Name)
                    petLabels[part] = label
                end
            end

            for _, part in ipairs(tamable) do
                purchasePet(part)
            end

            task.wait(SCAN_INTERVAL)
        end
    end
end

-- ============================================================
-- 🚀 AUTO‑EXECUTE LOOP (moves as soon as root exists)
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
        task.wait(3)
    end
end
