-- // AXION HUB • Grow a Garden 2
-- // Load via Delta / Potassium
-- // v1.0 — UI Framework

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "AXION • Garden 2",
    Icon = "flower",
    LoadingTitle = "AXION HUB",
    LoadingSubtitle = "Grow a Garden 2 • v1.0",
    Theme = "DarkBlue",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AxionHub_Garden2",
        FileName = "Garden2Config"
    },
    KeySystem = false,
})

local AutofarmTab = Window:CreateTab("🌱 Autofarm", "sprout")
local AutoBuyTab = Window:CreateTab("🛒 Auto Buy", "shopping-cart")
local MiscTab = Window:CreateTab("🔧 Misc", "wrench")
local GiftingTab = Window:CreateTab("🎁 Gifting", "gift")
local ConfigTab = Window:CreateTab("⚙️ Config", "settings")

-- // AUTOFARM TAB
AutofarmTab:CreateSection("Auto Collect")
AutofarmTab:CreateToggle({Name = "Auto Collect Plants", CurrentValue = false, Flag = "AutoCollect", Callback = function(Value) _G.AutoCollect = Value end})
AutofarmTab:CreateSlider({Name = "Collect Delay (ms)", Range = {100, 5000}, Increment = 100, Suffix = "ms", CurrentValue = 500, Flag = "CollectDelay", Callback = function(Value) _G.CollectDelay = Value end})
AutofarmTab:CreateDropdown({Name = "Collect Filter", Options = {"All Plants","Highest Value Only","Ready Only","Custom List"}, CurrentOption = {"All Plants"}, Flag = "CollectFilter", Callback = function(Options) _G.CollectFilter = Options[1] end})
AutofarmTab:CreateDivider()
AutofarmTab:CreateSection("Auto Sell")
AutofarmTab:CreateToggle({Name = "Auto Sell", CurrentValue = false, Flag = "AutoSell", Callback = function(Value) _G.AutoSell = Value end})
AutofarmTab:CreateSlider({Name = "Sell Delay (ms)", Range = {100, 5000}, Increment = 100, Suffix = "ms", CurrentValue = 1000, Flag = "SellDelay", Callback = function(Value) _G.SellDelay = Value end})
AutofarmTab:CreateToggle({Name = "Sell Only When Full", CurrentValue = false, Flag = "SellWhenFull", Callback = function(Value) _G.SellWhenFull = Value end})
AutofarmTab:CreateDropdown({Name = "Sell Filter", Options = {"All Items","Exclude Rare","Exclude Seeds","Custom"}, CurrentOption = {"All Items"}, Flag = "SellFilter", Callback = function(Options) _G.SellFilter = Options[1] end})
AutofarmTab:CreateDivider()
AutofarmTab:CreateSection("Auto Buy (Plants/Seeds)")
AutofarmTab:CreateToggle({Name = "Auto Buy Seeds", CurrentValue = false, Flag = "AutoBuySeeds", Callback = function(Value) _G.AutoBuySeeds = Value end})
AutofarmTab:CreateDropdown({Name = "Seed Type", Options = {"Best Profit","Cheapest","Fastest Grow","Random","Custom"}, CurrentOption = {"Best Profit"}, Flag = "SeedType", Callback = function(Options) _G.SeedType = Options[1] end})
AutofarmTab:CreateSlider({Name = "Buy Amount", Range = {1, 50}, Increment = 1, Suffix = "seeds", CurrentValue = 5, Flag = "BuyAmount", Callback = function(Value) _G.BuyAmount = Value end})
AutofarmTab:CreateDivider()
AutofarmTab:CreateSection("Auto Plant")
AutofarmTab:CreateToggle({Name = "Auto Plant Seeds", CurrentValue = false, Flag = "AutoPlant", Callback = function(Value) _G.AutoPlant = Value end})
AutofarmTab:CreateDropdown({Name = "Planting Pattern", Options = {"Optimized Grid","Random Plot","Sequential","Empty Plots Only"}, CurrentOption = {"Optimized Grid"}, Flag = "PlantPattern", Callback = function(Options) _G.PlantPattern = Options[1] end})
AutofarmTab:CreateDivider()
AutofarmTab:CreateSection("Auto Fertilize / Water")
AutofarmTab:CreateToggle({Name = "Auto Water", CurrentValue = false, Flag = "AutoWater", Callback = function(Value) _G.AutoWater = Value end})
AutofarmTab:CreateToggle({Name = "Auto Fertilize", CurrentValue = false, Flag = "AutoFertilize", Callback = function(Value) _G.AutoFertilize = Value end})
AutofarmTab:CreateDropdown({Name = "Fertilizer Type", Options = {"Basic","Premium","Speed-Gro","Best Available"}, CurrentOption = {"Best Available"}, Flag = "FertilizerType", Callback = function(Options) _G.FertilizerType = Options[1] end})
AutofarmTab:CreateDivider()
AutofarmTab:CreateSection("Master Controls")
AutofarmTab:CreateToggle({Name = "Enable Full Autofarm Loop", CurrentValue = false, Flag = "MasterAutofarm", Callback = function(Value) _G.MasterAutofarm = Value end})
AutofarmTab:CreateButton("Force Collect Now", function() end)
AutofarmTab:CreateButton("Force Sell Now", function() end)

-- // AUTO BUY TAB
AutoBuyTab:CreateSection("Item Purchasing")
AutoBuyTab:CreateToggle({Name = "Enable Auto Buy", CurrentValue = false, Flag = "AutoBuyEnabled", Callback = function(Value) _G.AutoBuyEnabled = Value end})
for i = 1, 5 do
    AutoBuyTab:CreateDivider()
    AutoBuyTab:CreateSection("Buy Slot #" .. i)
    AutoBuyTab:CreateToggle({Name = "Enable Slot " .. i, CurrentValue = false, Flag = "BuySlot"..i.."Enabled", Callback = function(Value) _G["BuySlot"..i.."Enabled"] = Value end})
    AutoBuyTab:CreateTextbox({Na
