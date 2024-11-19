local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Create the Fluent Window
local Window = Fluent:CreateWindow({
    Title = "Enemy Highlighter and Aimbot",
    SubTitle = "by dawid",
    TabWidth = 140, -- Reduced width for better mobile fit
    Size = UDim2.fromOffset(450, 320), -- Smaller size for mobile screens
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
local FOV = 30 -- Default FOV
local aimSpeed = 5
local showFOV = false -- Whether to show the FOV circle

-- GUI Elements
Tabs.Main:AddToggle("EnableHighlight", {
    Title = "Enable Enemy Highlights",
    Default = false,
    Callback = function(state)
        highlightEnabled = state
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

Tabs.Main:AddSlider("FOVSlider", {
    Title = "FOV (0-100)",
    Min = 0,
    Max = 100,
    Default = FOV,
    Callback = function(value)
        FOV = value
        print("FOV changed to:", value)
    end
})

Tabs.Main:AddToggle("ShowFOV", {
    Title = "Show FOV Circle",
    Default = false,
    Callback = function(state)
        showFOV = state
        print("FOV circle shown:", state)
    end
})

-- Aimbot Variables and Functions
local Camera = game.Workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Function to find the closest enemy
local function getClosestEnemy()
    local closestEnemy = nil
    local closestDistance = math.huge
    local myCharacter = game.Players.LocalPlayer.Character
    if myCharacter then
        local myHead = myCharacter:FindFirstChild("Head")
        if myHead then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local enemy = player.Character
                    local enemyHead = enemy:FindFirstChild("Head")
                    -- Team check
                    if enemyHead and player.Team ~= game.Players.LocalPlayer.Team then
                        local distance = (myHead.Position - enemyHead.Position).Magnitude
                        if distance < closestDistance then
                            closestDistance = distance
                            closestEnemy = enemy
                        end
                    end
                end
            end
        end
    end
    return closestEnemy
end

-- Function to check if the enemy is within the FOV
local function isInFOV(targetPosition)
    local cameraDirection = Camera.CFrame.LookVector
    local directionToTarget = (targetPosition - Camera.CFrame.Position).unit
    local dotProduct = cameraDirection:Dot(directionToTarget)
    local angle = math.acos(dotProduct) * (180 / math.pi)
    return angle <= FOV
end

-- Function to aim at the closest enemy if it's within the FOV
local function aimAtEnemy()
    local closestEnemy = getClosestEnemy()
    if closestEnemy then
        local enemyHead = closestEnemy:FindFirstChild("Head")
        if enemyHead and isInFOV(enemyHead.Position) then
            local direction = (enemyHead.Position - Camera.CFrame.Position).unit
            local targetCFrame = Camera.CFrame * CFrame.new(direction * 10)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, aimSpeed * RunService.Heartbeat:Wait())
        end
    end
end

-- Aiming at the enemy when the right mouse button is held down
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) do
                aimAtEnemy()
                wait(0.01)
            end
        end
    end
end)

-- FOV Circle Drawing
local fovCircle = Instance.new("Frame")
fovCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fovCircle.BackgroundTransparency = 0.6
fovCircle.Size = UDim2.new(0, FOV * 2, 0, FOV * 2)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.Visible = showFOV
fovCircle.Parent = game.Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui")

-- Update FOV circle size based on FOV setting
task.spawn(function()
    while true do
        if showFOV then
            fovCircle.Size = UDim2.new(0, FOV * 2, 0, FOV * 2)
        end
        wait(0.1)
    end
end)

-- Highlighting Logic (Enemy Highlight)
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

-- SaveManager and InterfaceManager Setup
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("EnemyHighlighterAndAimbot")
SaveManager:SetFolder("EnemyHighlighterAndAimbot/Configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Auto-load Configs
SaveManager:LoadAutoloadConfig()

-- Finalize GUI
Window:SelectTab(1)

-- Notification for GUI Load
Fluent:Notify({
    Title = "Enemy Highlighter and Aimbot",
    Content = "Script Loaded Successfully!",
    Duration = 5
})
