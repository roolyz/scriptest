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
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Variables
local highlightEnabled = false
local highlightColor = Color3.fromRGB(255, 0, 0) -- Default Red
local teamCheck = true
local radius = 100
local fovCircle = nil

-- Highlighter Logic (Unchanged from original)
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

-- Aimbot Variables
local aimbotEnabled = false
local aimRadius = 100
local fov = nil

-- Create FOV Circle
local function createFOVCircle()
    if fovCircle then
        fovCircle:Destroy()
    end
    fovCircle = Instance.new("Frame")
    fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    fovCircle.Size = UDim2.fromOffset(aimRadius * 2, aimRadius * 2)
    fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0) -- Center on the screen (crosshair)
    fovCircle.BackgroundColor3 = Color3.new(0, 1, 0)
    fovCircle.BackgroundTransparency = 0.5
    fovCircle.BorderSizePixel = 0
    fovCircle.Parent = game.CoreGui
end

-- Update FOV Circle based on radius
local function updateFOVCircle()
    if fovCircle then
        fovCircle.Size = UDim2.fromOffset(aimRadius * 2, aimRadius * 2)
    end
end

-- Aimbot logic
local function aimbot()
    if not aimbotEnabled then return end
    local closestTarget = nil
    local shortestDistance = aimRadius

    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Team ~= game.Players.LocalPlayer.Team then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local rootPart = character.HumanoidRootPart
                local screenPos, onScreen = game.Workspace.CurrentCamera:WorldToScreenPoint(rootPart.Position)
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(game:GetService("UserInputService"):GetMouseLocation().X, game:GetService("UserInputService"):GetMouseLocation().Y)).Magnitude

                if onScreen and distance < shortestDistance then
                    closestTarget = player
                    shortestDistance = distance
                end
            end
        end
    end

    if closestTarget then
        local character = closestTarget.Character
        local rootPart = character.HumanoidRootPart
        game:GetService("UserInputService"):SetMouseLocation(game.Workspace.CurrentCamera:WorldToScreenPoint(rootPart.Position))
    end
end

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

Tabs.Main:AddToggle("EnableAimbot", {
    Title = "Enable Aimbot",
    Default = false,
    Callback = function(state)
        aimbotEnabled = state
        if state then
            createFOVCircle()
        else
            if fovCircle then
                fovCircle:Destroy()
            end
        end
    end
})

Tabs.Main:AddSlider("AimbotRadius", {
    Title = "Aimbot Radius",
    Min = 50,
    Max = 500,
    Default = aimRadius,
    Callback = function(value)
        aimRadius = value
        updateFOVCircle()
    end
})

Tabs.Main:AddToggle("ShowFOV", {
    Title = "Show FOV Circle",
    Default = false,
    Callback = function(state)
        if state then
            createFOVCircle()
        else
            if fovCircle then
                fovCircle:Destroy()
            end
        end
    end
})

-- Notification for GUI Load
Fluent:Notify({
    Title = "Enemy Highlighter & Aimbot",
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

-- Aimbot Update Loop
task.spawn(function()
    while task.wait(0.1) do
        aimbot()
    end
end)
