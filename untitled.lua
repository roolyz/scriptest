-- Fluent UI Library
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Create the Fluent Window
local Window = Fluent:CreateWindow({
    Title = "Enemy Highlighter & Aimbot",
    SubTitle = "by dawid",
    TabWidth = 140, -- Adjusted for mobile
    Size = UDim2.fromOffset(450, 320), -- Smaller size for mobile
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Default keybind
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "target" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Variables
local highlightEnabled = false
local highlightColor = Color3.fromRGB(255, 0, 0) -- Default Red
local teamCheckHighlight = true
local teamCheckAimbot = true
local fovCircleEnabled = false
local fovRadius = 1000
local bodyPart = "Torso"
local smoothing = 10 -- Smoothing for aimbot movement
local aimbotEnabled = false -- Flag to keep aimbot always on if toggled

-- Function to manage highlights
local function applyHighlights()
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local isEnemy = (player.Team ~= game.Players.LocalPlayer.Team) or not teamCheckHighlight
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

-- FOV Circle Drawing
local fovCircle = nil
local function updateFovCircle()
    if fovCircle then
        fovCircle:Remove() -- Remove the previous circle if exists
    end
    if fovCircleEnabled then
        fovCircle = Drawing.new("Circle")
        fovCircle.Thickness = 2
        fovCircle.Color = Color3.fromRGB(255, 255, 255) -- White color for the FOV circle
        fovCircle.Radius = fovRadius
        fovCircle.Position = workspace.CurrentCamera.ViewportSize / 2
        fovCircle.Filled = false
    end
end

-- Update FOV circle on slider change
Tabs.Aimbot:AddSlider("FOV", {
    Title = "Aimbot FOV",
    Min = 100,
    Max = 1000,
    Default = 1000,
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

-- Dropdown to choose target body part (Head/Torso)
Tabs.Aimbot:AddDropdown("BodyPart", {
    Title = "Aimbot Body Part",
    Default = "Torso",
    List = { "Head", "Torso" },
    Callback = function(selected)
        bodyPart = selected
    end
})

-- Function for Aimbot (aims at closest enemy within FOV)
local function aimAtTarget(target)
    local camera = workspace.CurrentCamera
    local mouse = game.Players.LocalPlayer:GetMouse()
    local targetPos = target.Character[bodyPart].Position
    local aimAt = camera:WorldToScreenPoint(targetPos)

    -- Calculate the delta to move the mouse
    local deltaX = aimAt.X - mouse.X
    local deltaY = aimAt.Y - mouse.Y

    -- Smooth aimbot movement
    mousemoveabs(mouse.X + deltaX / smoothing, mouse.Y + deltaY / smoothing)
end

-- Helper function to simulate mouse movement (for aimbot)
function mousemoveabs(x, y)
    -- This function moves the mouse based on screen coordinates, creating a smoother aimbot effect
    game:GetService("VirtualUser"):ClickButton1(Vector2.new(x, y))
end

-- Function to get the closest enemy (Aimbot logic)
local function closestEnemy()
    local maxDist, nearest = math.huge
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game:GetService("Players").LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            if (player.Team ~= game:GetService("Players").LocalPlayer.Team or not teamCheckAimbot) then
                local pos, vis = workspace.CurrentCamera:WorldToScreenPoint(player.Character[bodyPart].Position)
                if vis then
                    local dist = math.sqrt((pos.X - workspace.CurrentCamera.ViewportSize.X / 2) ^ 2 + (pos.Y - workspace.CurrentCamera.ViewportSize.Y / 2) ^ 2)
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

-- Always active aimbot (no need for key press)
game:GetService("RunService").RenderStepped:Connect(function()
    if highlightEnabled then
        applyHighlights() -- Apply highlights if enabled
    end
    if aimbotEnabled then
        local target = closestEnemy()
        if target then
            aimAtTarget(target)
        end
    end
end)

-- GUI elements for highlighting and aimbot settings
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
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        highlightColor = color
    end
})

Tabs.Settings:AddToggle("TeamCheckHighlight", {
    Title = "Team Check for Highlights",
    Default = true,
    Callback = function(state)
        teamCheckHighlight = state
    end
})

Tabs.Settings:AddToggle("TeamCheckAimbot", {
    Title = "Team Check for Aimbot",
    Default = true,
    Callback = function(state)
        teamCheckAimbot = state
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
