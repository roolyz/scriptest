local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Create the Fluent Window
local Window = Fluent:CreateWindow({
    Title = "Game Utility Script",
    SubTitle = "by dawid",
    TabWidth = 140,
    Size = UDim2.fromOffset(450, 400),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Tabs for the script
local Tabs = {
    ESP = Window:AddTab({ Title = "ESP", Icon = "" }),
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- ESP Variables
local espEnabled = false
local espColor = Color3.fromRGB(255, 0, 0) -- Default Red
local espTeamCheck = true

-- Aimbot Variables
local aimbotEnabled = false
local aimbotSmoothing = 0.5
local aimbotTargetPart = "Head"
local aimbotRadius = 100 -- Default targeting radius (in studs)

-- Function to get the closest enemy within the aimbot radius
local function getClosestEnemy()
    local localPlayer = game.Players.LocalPlayer
    local mouseLocation = game.Workspace.CurrentCamera.CFrame.Position
    local closestEnemy = nil
    local shortestDistance = aimbotRadius

    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Team ~= localPlayer.Team then
            local character = player.Character
            if character and character:FindFirstChild(aimbotTargetPart) then
                local part = character[aimbotTargetPart]
                local distance = (part.Position - mouseLocation).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestEnemy = part
                end
            end
        end
    end
    return closestEnemy
end

-- Aimbot Functionality
local function aimbotStep()
    if aimbotEnabled then
        local closestEnemy = getClosestEnemy()
        if closestEnemy then
            local camera = game.Workspace.CurrentCamera
            local targetPosition = closestEnemy.Position

            -- Smooth aiming logic
            local direction = (targetPosition - camera.CFrame.Position).Unit
            local newCFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, camera.CFrame.Position + direction), aimbotSmoothing)
            camera.CFrame = newCFrame
        end
    end
end

-- Connect the aimbot functionality to render step
game:GetService("RunService").RenderStepped:Connect(aimbotStep)

-- ESP Updater
task.spawn(function()
    while task.wait(0.1) do
        if espEnabled then
            for _, player in ipairs(game.Players:GetPlayers()) do
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local isEnemy = (player.Team ~= game.Players.LocalPlayer.Team) or not espTeamCheck
                    local highlight = character:FindFirstChildOfClass("Highlight")

                    if espEnabled and isEnemy then
                        if not highlight then
                            highlight = Instance.new("Highlight")
                            highlight.Name = "ESPHighlight"
                            highlight.Parent = character
                        end
                        highlight.FillColor = espColor
                        highlight.OutlineColor = Color3.new(1, 1, 1) -- White outline
                        highlight.FillTransparency = 0.5
                        highlight.OutlineTransparency = 0
                    elseif highlight then
                        highlight:Destroy()
                    end
                end
            end
        end
    end
end)

-- ESP Tab Elements
Tabs.ESP:AddToggle("EnableESP", {
    Title = "Enable ESP",
    Default = false,
    Callback = function(state)
        espEnabled = state
        if not state then
            for _, player in ipairs(game.Players:GetPlayers()) do
                local character = player.Character
                if character then
                    local highlight = character:FindFirstChild("ESPHighlight")
                    if highlight then
                        highlight:Destroy()
                    end
                end
            end
        end
        print("ESP Enabled:", state)
    end
})

Tabs.ESP:AddColorpicker("ESPColor", {
    Title = "ESP Color",
    Default = espColor,
    Callback = function(newColor)
        espColor = newColor
        print("ESP Color Changed:", newColor)
    end
})

Tabs.ESP:AddToggle("ESPTeamCheck", {
    Title = "Team Check",
    Default = true,
    Callback = function(state)
        espTeamCheck = state
        print("ESP Team Check Enabled:", state)
    end
})

-- Aimbot Tab Elements
Tabs.Aimbot:AddToggle("EnableAimbot", {
    Title = "Enable Aimbot",
    Default = false,
    Callback = function(state)
        aimbotEnabled = state
        print("Aimbot Enabled:", state)
    end
})

Tabs.Aimbot:AddSlider("AimbotSmoothing", {
    Title = "Smoothing",
    Min = 0,
    Max = 1,
    Rounding = 2,
    Default = aimbotSmoothing,
    Callback = function(value)
        aimbotSmoothing = value
        print("Aimbot Smoothing Changed:", value)
    end
})

Tabs.Aimbot:AddSlider("AimbotRadius", {
    Title = "Aimbot Radius",
    Min = 50,
    Max = 300,
    Default = aimbotRadius,
    Rounding = 0,
    Callback = function(value)
        aimbotRadius = value
        print("Aimbot Radius Changed:", value)
    end
})

Tabs.Aimbot:AddDropdown("TargetPart", {
    Title = "Target Part",
    Values = { "Head", "Torso", "HumanoidRootPart" },
    Default = aimbotTargetPart,
    Callback = function(part)
        aimbotTargetPart = part
        print("Aimbot Target Part Changed:", part)
    end
})

-- SaveManager and InterfaceManager Setup
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("GameUtility")
SaveManager:SetFolder("GameUtility/Configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Auto-load Configs
SaveManager:LoadAutoloadConfig()

-- Finalize GUI
Window:SelectTab(1)

-- Notification
Fluent:Notify({
    Title = "Utility Script",
    Content = "Script Loaded Successfully!",
    Duration = 5
})
