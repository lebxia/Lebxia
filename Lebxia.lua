-- // AXION HUB • Grow a Garden 2 • Mobile Compatible
-- // v2.0 — Orion Library

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({
    Name = "AXION • Garden 2",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "AxionHub_Garden2",
    IntroEnabled = true,
    IntroText = "AXION HUB"
})

-- // TABS
local AutofarmTab = Window:MakeTab({Name = "Autofarm", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local AutoBuyTab = Window:MakeTab({Name = "Auto Buy", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local MiscTab = Window:MakeTab({Name = "Misc", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local GiftingTab = Window:MakeTab({Name = "Gifting", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local ConfigTab = Window:MakeTab({Name = "Config", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- // =============== AUTOFARM ===============
AutofarmTab:AddSection("Auto Collect")
AutofarmTab:AddToggle({Name = "Auto Collect Plants", Default = false, Callback = function(Value) _G.AutoCollect = Value end})
AutofarmTab:AddSlider({Name = "Collect Delay (ms)", Min = 100, Max = 5000, Default = 500, Increment = 100, ValueName = "ms", Callback = function(Value) _G.CollectDelay = Value end})
AutofarmTab:AddDropdown({Name = "Collect Filter", Default = "All Plants", Options = {"All Plants","Highest Value Only","Ready Only","Custom List"}, Callback = function(Value) _G.CollectFilter = Value end})

AutofarmTab:AddSection("Auto Sell")
AutofarmTab:AddToggle({Name = "Auto Sell", Default = false, Callback = function(Value) _G.AutoSell = Value end})
AutofarmTab:AddSlider({Name = "Sell Delay (ms)", Min = 100, Max = 5000, Default = 1000, Increment = 100, ValueName = "ms", Callback = function(Value) _G.SellDelay = Value end})
AutofarmTab:AddToggle({Name = "Sell Only When Full", Default = false, Callback = function(Value) _G.SellWhenFull = Value end})
AutofarmTab:AddDropdown({Name = "Sell Filter", Default = "All Items", Options = {"All Items","Exclude Rare","Exclude Seeds","Custom"}, Callback = function(Value) _G.SellFilter = Value end})

AutofarmTab:AddSection("Auto Buy Seeds")
AutofarmTab:AddToggle({Name = "Auto Buy Seeds", Default = false, Callback = function(Value) _G.AutoBuySeeds = Value end})
AutofarmTab:AddDropdown({Name = "Seed Type", Default = "Best Profit", Options = {"Best Profit","Cheapest","Fastest Grow","Random","Custom"}, Callback = function(Value) _G.SeedType = Value end})
AutofarmTab:AddSlider({Name = "Buy Amount", Min = 1, Max = 50, Default = 5, Increment = 1, ValueName = "seeds", Callback = function(Value) _G.BuyAmount = Value end})

AutofarmTab:AddSection("Auto Plant")
AutofarmTab:AddToggle({Name = "Auto Plant Seeds", Default = false, Callback = function(Value) _G.AutoPlant = Value end})
AutofarmTab:AddDropdown({Name = "Planting Pattern", Default = "Optimized Grid", Options = {"Optimized Grid","Random Plot","Sequential","Empty Plots Only"}, Callback = function(Value) _G.PlantPattern = Value end})

AutofarmTab:AddSection("Auto Care")
AutofarmTab:AddToggle({Name = "Auto Water", Default = false, Callback = function(Value) _G.AutoWater = Value end})
AutofarmTab:AddToggle({Name = "Auto Fertilize", Default = false, Callback = function(Value) _G.AutoFertilize = Value end})
AutofarmTab:AddDropdown({Name = "Fertilizer Type", Default = "Best Available", Options = {"Basic","Premium","Speed-Gro","Best Available"}, Callback = function(Value) _G.FertilizerType = Value end})

AutofarmTab:AddSection("Master")
AutofarmTab:AddToggle({Name = "Enable Full Autofarm Loop", Default = false, Callback = function(Value) _G.MasterAutofarm = Value end})
AutofarmTab:AddButton({Name = "Force Collect Now", Callback = function() end})
AutofarmTab:AddButton({Name = "Force Sell Now", Callback = function() end})

-- // =============== AUTO BUY ===============
AutoBuyTab:AddSection("Item Purchasing")
AutoBuyTab:AddToggle({Name = "Enable Auto Buy", Default = false, Callback = function(Value) _G.AutoBuyEnabled = Value end})

for i = 1, 5 do
    AutoBuyTab:AddSection("Buy Slot #" .. i)
    AutoBuyTab:AddToggle({Name = "Enable Slot " .. i, Default = false, Callback = function(Value) _G["BuySlot"..i.."Enabled"] = Value end})
    AutoBuyTab:AddTextbox({Name = "Item Name", Default = "", TextDisappear = false, Callback = function(Value) _G["BuySlot"..i.."Item"] = Value end})
    AutoBuyTab:AddSlider({Name = "Max Price", Min = 1, Max = 1000000, Default = 1000, Increment = 100, ValueName = "coins", Callback = function(Value) _G["BuySlot"..i.."MaxPrice"] = Value end})
    AutoBuyTab:AddSlider({Name = "Quantity to Keep", Min = 1, Max = 999, Default = 10, Increment = 1, ValueName = "x", Callback = function(Value) _G["BuySlot"..i.."Quantity"] = Value end})
    AutoBuyTab:AddSlider({Name = "Buy Delay (ms)", Min = 100, Max = 5000, Default = 1000, Increment = 100, ValueName = "ms", Callback = function(Value) _G["BuySlot"..i.."Delay"] = Value end})
end

-- // =============== MISC ===============
MiscTab:AddSection("Character")
MiscTab:AddToggle({Name = "NoClip", Default = false, Callback = function(Value) _G.NoClip = Value end})
MiscTab:AddSlider({Name = "WalkSpeed", Min = 16, Max = 200, Default = 16, Increment = 1, ValueName = "studs", Callback = function(Value) local char = game.Players.LocalPlayer.Character if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = Value end end})
MiscTab:AddSlider({Name = "JumpPower", Min = 50, Max = 500, Default = 50, Increment = 5, ValueName = "studs", Callback = function(Value) local char = game.Players.LocalPlayer.Character if char and char:FindFirstChild("Humanoid") then char.Humanoid.JumpPower = Value end end})

MiscTab:AddSection("Performance")
MiscTab:AddToggle({Name = "Hide All Plants (Visual)", Default = false, Callback = function(Value) _G.HidePlants = Value end})
MiscTab:AddToggle({Name = "Remove Decorations", Default = false, Callback = function(Value) _G.RemoveDecor = Value end})
MiscTab:AddToggle({Name = "Low Graphics Mode", Default = false, Callback = function(Value)
    _G.LowGraphics = Value
    if Value then
        sethiddenproperty(game.Lighting, "Technology", 1)
        game.Lighting.GlobalShadows = false
        game.Lighting.FogEnd = 100
    else
        sethiddenproperty(game.Lighting, "Technology", 3)
        game.Lighting.GlobalShadows = true
        game.Lighting.FogEnd = 5000
    end
end})
MiscTab:AddSlider({Name = "FPS Cap", Min = 15, Max = 120, Default = 60, Increment = 5, ValueName = "FPS", Callback = function(Value) setfpscap(Value) end})

MiscTab:AddSection("Teleports")
MiscTab:AddButton({Name = "Teleport to Shop", Callback = function() end})
MiscTab:AddButton({Name = "Teleport to Garden", Callback = function() end})
MiscTab:AddButton({Name = "Teleport to Trading Hub", Callback = function() end})

MiscTab:AddSection("Auto Rebirth")
MiscTab:AddToggle({Name = "Auto Rebirth", Default = false, Callback = function(Value) _G.AutoRebirth = Value end})
MiscTab:AddSlider({Name = "Rebirth Cash Threshold", Min = 1000, Max = 10000000, Default = 100000, Increment = 1000, ValueName = "coins", Callback = function(Value) _G.RebirthThreshold = Value end})

-- // =============== GIFTING ===============
GiftingTab:AddSection("Mail Gifting")
GiftingTab:AddToggle({Name = "Enable Auto Gifting", Default = false, Callback = function(Value) _G.GiftingEnabled = Value end})

GiftingTab:AddSection("Recipient")
GiftingTab:AddTextbox({Name = "Recipient Username", Default = "", TextDisappear = false, Callback = function(Value) _G.GiftRecipient = Value end})
GiftingTab:AddToggle({Name = "Gift All Friends", Default = false, Callback = function(Value) _G.GiftAllFriends = Value end})
GiftingTab:AddToggle({Name = "Gift Random Players", Default = false, Callback = function(Value) _G.GiftRandom = Value end})

GiftingTab:AddSection("Gift Settings")
GiftingTab:AddTextbox({Name = "Item to Gift", Default = "", TextDisappear = false, Callback = function(Value) _G.GiftItem = Value end})
GiftingTab:AddSlider({Name = "Amount per Mail", Min = 1, Max = 999, Default = 20, Increment = 1, ValueName = "x", Callback = function(Value) _G.GiftAmountPerMail = Value end})
GiftingTab:AddSlider({Name = "Total Mail Count", Min = 1, Max = 1000, Default = 50, Increment = 1, ValueName = "mails", Callback = function(Value) _G.GiftMailCount = Value end})
GiftingTab:AddSlider({Name = "Delay Between Mails (ms)", Min = 100, Max = 10000, Default = 2000, Increment = 100, ValueName = "ms", Callback = function(Value) _G.GiftDelay = Value end})

GiftingTab:AddSection("Bypass")
GiftingTab:AddToggle({Name = "Bypass 20x Limit", Default = false, Callback = function(Value) _G.GiftBypass = Value end})
GiftingTab:AddDropdown({Name = "Bypass Method", Default = "Auto-Detect", Options = {"Counter Reset","Multi-Mail Object","Session Spoof","Auto-Detect"}, Callback = function(Value) _G.BypassMethod = Value end})

GiftingTab:AddSection("Anti-Ban")
GiftingTab:AddToggle({Name = "Randomize Delay", Default = true, Callback = function(Value) _G.GiftRandomDelay = Value end})
GiftingTab:AddToggle({Name = "Stop if Flagged", Default = true, Callback = function(Value) _G.GiftStopFlagged = Value end})

GiftingTab:AddSection("Controls")
GiftingTab:AddLabel("Status: Idle")
GiftingTab:AddButton({Name = "Start Gifting", Callback = function() _G.GiftingEnabled = true end})
GiftingTab:AddButton({Name = "Stop Gifting", Callback = function() _G.GiftingEnabled = false end})

-- // =============== CONFIG ===============
ConfigTab:AddSection("Save / Load")
ConfigTab:AddButton({Name = "Save Config", Callback = function() OrionLib:SaveConfig() end})
ConfigTab:AddButton({Name = "Load Config", Callback = function() OrionLib:LoadConfig() end})

ConfigTab:AddSection("Reset")
ConfigTab:AddButton({Name = "Destroy UI", Callback = function() OrionLib:Destroy() end})

ConfigTab:AddSection("Credits")
ConfigTab:AddLabel("AXION HUB • Garden 2")
ConfigTab:AddLabel("Mobile • Delta / Potassium")
ConfigTab:AddLabel("v2.0 • Orion Library")

-- // =============== BACKGROUND LOOPS ===============
spawn(function()
    while task.wait(0.1) do
        if _G.NoClip then
            local char = game.Players.LocalPlayer.Character
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
                if v:IsA("BasePart") and (v.Name:lower():find("plant") or v.Name:lower():find("flower") or v.Name:lower():find("seed")) then
                    v.Transparency = 1
                end
            end
        end
    end
end)

OrionLib:Init()
