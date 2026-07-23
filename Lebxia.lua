
game.StarterGui:SetCore("SendNotification", {
    Title = "AXION TEST",
    Text = "Script executed successfully.",
    Duration = 5,
})

-- Attempt Orion load
local success, OrionLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
end)

if not success then
    game.StarterGui:SetCore("SendNotification", {
        Title = "ERROR",
        Text = "Orion failed to load: " .. tostring(OrionLib),
        Duration = 8,
    })
    return
end

-- Minimal window
local Window = OrionLib:MakeWindow({
    Name = "AXION • Garden 2",
    HidePremium = false,
    SaveConfig = false,
    IntroEnabled = false,
})

local TestTab = Window:MakeTab({
    Name = "Test",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

TestTab:AddButton({
    Name = "Click Me",
    Callback = function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "AXION",
            Text = "Button works.",
            Duration = 3,
        })
    end,
})

TestTab:AddToggle({
    Name = "Test Toggle",
    Default = false,
    Callback = function(Value)
        game.StarterGui:SetCore("SendNotification", {
            Title = "Toggle",
            Text = "Value: " .. tostring(Value),
            Duration = 3,
        })
    end,
})

OrionLib:Init()

game.StarterGui:SetCore("SendNotification", {
    Title = "AXION",
    Text = "UI should be visible now.",
    Duration = 5,
})
