local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Create the Fluent Window
local Window = Fluent:CreateWindow({
    Title = "Fluent " .. Fluent.Version,
    SubTitle = "by dawid",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "target" }) -- New Aimbot Tab
}

-- Variables
local highlightEnabled = false
local highlightColor = Color3.fromRGB(255, 0, 0) -- Default Red
local teamCheck = true
local fov = 70 -- Default FOV
local aimbotEnabled = false

-- Function to manage highlights
local function applyHighlights()
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local isEnemy = (player.Team ~= game.Players.LocalPlayer.Team) or not teamCheck
                local highlight = character:FindFirstChildOfClass("Highlight")

                if highlightEnabled and isEnemy then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "EnemyHighlight"
                        highlight.Parent = character
                    end
                    highlight.FillColor = highlightColor
                    highlight.OutlineColor = Color3.new(1, 1, 1) -- White outline for contrast
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                elseif highlight then
                    highlight:Destroy()
                end
            end
        end
    end
end

-- Aimbot logic (simplified for demonstration)
local function applyAimbot()
    if aimbotEnabled then
        -- Find nearest enemy within FOV
        local closestTarget, closestDistance = nil, math.huge
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Team ~= game.Players.LocalPlayer.Team then
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local distance = (character.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if distance < closestDistance and distance <= fov then
                        closestDistance = distance
                        closestTarget = character
                    end
                end
            end
        end
        
        -- Aim at the closest target if available
        if closestTarget then
            local targetPosition = closestTarget.HumanoidRootPart.Position
            -- Logic to aim at target (simplified)
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game.Players.LocalPlayer.Character.HumanoidRootPart.Position, targetPosition)
        end
    end
end

-- Aimbot updater (runs continuously)
task.spawn(function()
    while task.wait(0.1) do
        if aimbotEnabled then
            applyAimbot()
        end
    end
end)

-- FOV circle drawing
local fovCircle = Instance.new("CircleHandleAdornment")
fovCircle.Radius = fov / 2
fovCircle.Adornee = game.Workspace
fovCircle.Color3 = Color3.new(0, 1, 0) -- Green circle
fovCircle.Transparency = 0.5
fovCircle.ZIndex = 5
fovCircle.Parent = game.CoreGui

-- FOV updater
task.spawn(function()
    while task.wait(0.1) do
        fovCircle.Radius = fov / 2
    end
end)

-- GUI Elements
Tabs.Main:AddToggle("EnableHighlight", {
    Title = "Enable Enemy Highlights",
    Default = false,
    Callback = function(state)
        highlightEnabled = state
        if not state then
            -- Remove highlights when disabled
            for _, player in ipairs(game.Players:GetPlayers()) do
                local character = player.Character
                if character then
                    local highlight = character:FindFirstChild("EnemyHighlight")
                    if highlight then
                        highlight:Destroy()
                    end
                end
            end
        end
        print("Highlighting enabled:", state)
    end
})

Tabs.Main:AddColorpicker("HighlightColor", {
    Title = "Highlight Color",
    Default = highlightColor,
    Callback = function(newColor)
        highlightColor = newColor
        print("Highlight color changed:", newColor)
    end
})

Tabs.Main:AddToggle("TeamCheck", {
    Title = "Enable Team Check",
    Default = true,
    Callback = function(state)
        teamCheck = state
        print("Team check enabled:", state)
    end
})

-- Aimbot Tab
Tabs.Aimbot:AddToggle("EnableAimbot", {
    Title = "Enable Aimbot",
    Default = false,
    Callback = function(state)
        aimbotEnabled = state
        print("Aimbot enabled:", state)
    end
})

Tabs.Aimbot:AddSlider("FOV", {
    Title = "FOV",
    Default = fov,
    Min = 30,
    Max = 100,
    Rounding = 1,
    Callback = function(value)
        fov = value
        print("FOV changed:", fov)
    end
})

-- SaveManager and InterfaceManager Setup
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Auto-load Configs
SaveManager:LoadAutoloadConfig()

-- Finalize GUI
Window:SelectTab(1)

Fluent:Notify({
    Title = "Fluent",
    Content = "The script has been loaded.",
    Duration = 8
})

-- Auto-load config example
SaveManager:LoadAutoloadConfig()
