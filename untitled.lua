local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Create the Fluent Window
local Window = Fluent:CreateWindow({
    Title = "Enemy Highlighter",
    SubTitle = "by dawid",
    TabWidth = 140, -- Adjusted for mobile
    Size = UDim2.fromOffset(450, 320), -- Smaller size for mobile
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Default keybind
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "target" }), -- New Aimbot tab
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Variables for Highlights
local highlightEnabled = false
local highlightColor = Color3.fromRGB(255, 0, 0) -- Default Red
local teamCheck = true

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

-- Highlight updater (runs continuously)
task.spawn(function()
    while task.wait(0.1) do
        if highlightEnabled then
            applyHighlights()
        end
    end
end)

-- GUI Elements for Main Tab
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
    end
})

Tabs.Main:AddColorpicker("HighlightColor", {
    Title = "Highlight Color",
    Default = highlightColor,
    Callback = function(newColor)
        highlightColor = newColor
    end
})

Tabs.Main:AddToggle("TeamCheck", {
    Title = "Enable Team Check",
    Default = true,
    Callback = function(state)
        teamCheck = state
    end
})

-- Variables for Aimbot
local aimbotEnabled = false
local fov = 500
local fovColor = Color3.fromRGB(255, 255, 0) -- Default Yellow
local teamCheckAimbot = true

-- Aimbot Logic
local function getClosestTarget()
    local nearest = nil
    local shortestDistance = math.huge

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if teamCheckAimbot and player.Team == game.Players.LocalPlayer.Team then
                continue
            end

            local screenPoint, onScreen = workspace.CurrentCamera:WorldToScreenPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - workspace.CurrentCamera.ViewportSize / 2).Magnitude
                if distance < shortestDistance and distance < fov then
                    nearest = player
                    shortestDistance = distance
                end
            end
        end
    end
    return nearest
end

-- Aimbot Updater
task.spawn(function()
    while task.wait() do
        if aimbotEnabled then
            local target = getClosestTarget()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Character.HumanoidRootPart.Position)
            end
        end
    end
end)

-- GUI Elements for Aimbot Tab
Tabs.Aimbot:AddToggle("EnableAimbot", {
    Title = "Enable Aimbot",
    Default = false,
    Callback = function(state)
        aimbotEnabled = state
    end
})

Tabs.Aimbot:AddSlider("FOV", {
    Title = "Aimbot FOV",
    Min = 100,
    Max = 1000,
    Default = fov,
    Callback = function(value)
        fov = value
    end
})

Tabs.Aimbot:AddToggle("TeamCheckAimbot", {
    Title = "Enable Team Check (Aimbot)",
    Default = true,
    Callback = function(state)
        teamCheckAimbot = state
    end
})

Tabs.Aimbot:AddColorpicker("FOVColor", {
    Title = "FOV Color",
    Default = fovColor,
    Callback = function(newColor)
        fovColor = newColor
    end
})

-- Notification for GUI Load
Fluent:Notify({
    Title = "Enemy Highlighter",
    Content = "Script Loaded Successfully!",
    Duration = 5
})

-- SaveManager and InterfaceManager Setup
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("EnemyHighlighter")
SaveManager:SetFolder("EnemyHighlighter/Configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Auto-load Configs
SaveManager:LoadAutoloadConfig()

-- Finalize GUI
Window:SelectTab(1)
