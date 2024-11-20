-- Fluent UI Library
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Create the Fluent Window
local Window = Fluent:CreateWindow({
    Title = "Enemy Highlighter & Aimbot",
    SubTitle = "by dawid",
    TabWidth = 140,
    Size = UDim2.fromOffset(450, 320),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main" }),
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "target" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- Variables
local highlightEnabled = false
local highlightColor = Color3.fromRGB(255, 0, 0)
local teamCheckHighlight = true
local teamCheckAimbot = true
local fovCircleEnabled = false
local fovRadius = 1000
local bodyPart = "Torso"
local smoothing = 10
local aimbotEnabled = false

-- Function to apply highlights
local function applyHighlights()
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local isEnemy = (player.Team ~= game.Players.LocalPlayer.Team) or not teamCheckHighlight
                local highlight = character:FindFirstChild("EnemyHighlight")

                if highlightEnabled and isEnemy then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "EnemyHighlight"
                        highlight.Parent = character
                    end
                    highlight.FillColor = highlightColor
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                elseif highlight then
                    highlight:Destroy()
                end
            end
        end
    end
end

-- Highlight updater
task.spawn(function()
    while task.wait(0.1) do
        if highlightEnabled then
            applyHighlights()
        end
    end
end)

-- FOV Circle
local fovCircle
local function updateFovCircle()
    if fovCircle then
        fovCircle:Remove()
    end
    if fovCircleEnabled then
        fovCircle = Drawing.new("Circle")
        fovCircle.Thickness = 2
        fovCircle.Color = Color3.fromRGB(255, 255, 255)
        fovCircle.Radius = fovRadius
        fovCircle.Position = workspace.CurrentCamera.ViewportSize / 2
        fovCircle.Filled = false
    end
end

-- GUI Elements
Tabs.Aimbot:AddSlider("FOV", {
    Title = "Aimbot FOV",
    Min = 100,
    Max = 1000,
    Default = fovRadius,
    Callback = function(value)
        fovRadius = value
        updateFovCircle()
    end
})

Tabs.Aimbot:AddToggle("ShowFOV", {
    Title = "Show FOV Circle",
    Default = false,
    Callback = function(state)
        fovCircleEnabled = state
        updateFovCircle()
    end
})

Tabs.Aimbot:AddDropdown("BodyPart", {
    Title = "Aimbot Body Part",
    Default = bodyPart,
    List = { "Head", "Torso" },
    Callback = function(selected)
        bodyPart = selected
    end
})

Tabs.Main:AddToggle("EnableHighlight", {
    Title = "Enable Enemy Highlights",
    Default = false,
    Callback = function(state)
        highlightEnabled = state
    end
})

Tabs.Aimbot:AddToggle("EnableAimbot", {
    Title = "Enable Aimbot",
    Default = false,
    Callback = function(state)
        aimbotEnabled = state
    end
})

Tabs.Main:AddColorPicker("HighlightColor", {
    Title = "Highlight Color",
    Default = highlightColor,
    Callback = function(color)
        highlightColor = color
    end
})

Tabs.Settings:AddToggle("TeamCheckHighlight", {
    Title = "Team Check for Highlights",
    Default = teamCheckHighlight,
    Callback = function(state)
        teamCheckHighlight = state
    end
})

Tabs.Settings:AddToggle("TeamCheckAimbot", {
    Title = "Team Check for Aimbot",
    Default = teamCheckAimbot,
    Callback = function(state)
        teamCheckAimbot = state
    end
})

-- Aimbot Logic
local function closestEnemy()
    local maxDist, nearest = math.huge, nil
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            local isEnemy = (player.Team ~= game.Players.LocalPlayer.Team) or not teamCheckAimbot
            if isEnemy then
                local pos, vis = workspace.CurrentCamera:WorldToScreenPoint(player.Character[bodyPart].Position)
                if vis then
                    local dist = (Vector2.new(pos.X, pos.Y) - workspace.CurrentCamera.ViewportSize / 2).Magnitude
                    if dist < maxDist and dist < fovRadius then
                        maxDist = dist
                        nearest = player
                    end
                end
            end
        end
    end
    return nearest
end

local function aimAtTarget(target)
    if target and target.Character and target.Character:FindFirstChild(bodyPart) then
        local camera = workspace.CurrentCamera
        local targetPos = camera:WorldToScreenPoint(target.Character[bodyPart].Position)
        mousemoveabs(targetPos.X, targetPos.Y)
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = closestEnemy()
        if target then
            aimAtTarget(target)
        end
    end
end)

-- Notifications
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
SaveManager:LoadAutoloadConfig()

Window:SelectTab(1)
