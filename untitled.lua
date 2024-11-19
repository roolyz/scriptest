local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Game Utility Script",
    SubTitle = "by dawid",
    TabWidth = 140,
    Size = UDim2.fromOffset(450, 400),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    ESP = Window:AddTab({ Title = "ESP", Icon = "" }),
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local espEnabled = false
local espColor = Color3.fromRGB(255, 0, 0)
local espTeamCheck = true

local aimbotEnabled = false
local aimbotSmoothing = 0.5
local aimbotTargetPart = "Head"
local aimbotRadius = 100 -- Default targeting radius (in studs)
local showFOV = true

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Transparency = 1
fovCircle.Thickness = 2
fovCircle.Color = Color3.fromRGB(0, 255, 0)
fovCircle.Filled = false

local function updateFOVCircle()
    local camera = Workspace.CurrentCamera
    local screenSize = camera.ViewportSize
    fovCircle.Position = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
    fovCircle.Radius = aimbotRadius
    fovCircle.Visible = showFOV
end

game:GetService("RunService").RenderStepped:Connect(function()
    if showFOV then
        updateFOVCircle()
    end
end)

local function createHighlight(player)
    if not espEnabled or (espTeamCheck and player.Team == game.Players.LocalPlayer.Team) then
        return
    end

    local character = player.Character
    if character and not character:FindFirstChild("ESPHighlight") then
        local highlight = Instance.new("Highlight")
        highlight.Parent = character
        highlight.Name = "ESPHighlight"
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0.2
        highlight.FillColor = espColor
        highlight.OutlineColor = Color3.new(1, 1, 1)
    end
end

local function updateHighlights()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            createHighlight(player)
        end
    end
end

game.Players.PlayerAdded:Connect(updateHighlights)
game.Players.PlayerRemoving:Connect(function(player)
    local character = player.Character
    if character and character:FindFirstChild("ESPHighlight") then
        character.ESPHighlight:Destroy()
    end
end)

local function getClosestEnemy()
    local localPlayer = game.Players.LocalPlayer
    local camera = game.Workspace.CurrentCamera
    local closestEnemy = nil
    local shortestDistance = aimbotRadius

    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Team ~= localPlayer.Team then
            local character = player.Character
            if character and character:FindFirstChild(aimbotTargetPart) then
                local part = character[aimbotTargetPart]
                local screenPoint, onScreen = camera:WorldToScreenPoint(part.Position)
                local mouseLocation = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mouseLocation).Magnitude

                if distance < shortestDistance and onScreen then
                    shortestDistance = distance
                    closestEnemy = part
                end
            end
        end
    end

    return closestEnemy
end

local function aimbotStep()
    if aimbotEnabled then
        local closestEnemy = getClosestEnemy()
        if closestEnemy then
            local camera = game.Workspace.CurrentCamera
            local targetPosition = closestEnemy.Position
            local direction = (targetPosition - camera.CFrame.Position).Unit
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, camera.CFrame.Position + direction), aimbotSmoothing)
        end
    end
end

game:GetService("RunService").RenderStepped:Connect(aimbotStep)

Tabs.ESP:AddToggle("EnableESP", {
    Title = "Enable ESP",
    Default = false,
    Callback = function(state)
        espEnabled = state
        if not state then
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("ESPHighlight") then
                    player.Character.ESPHighlight:Destroy()
                end
            end
        else
            updateHighlights()
        end
    end
})

Tabs.ESP:AddColorpicker("ESPColor", {
    Title = "ESP Color",
    Default = espColor,
    Callback = function(newColor)
        espColor = newColor
        updateHighlights()
    end
})

Tabs.ESP:AddToggle("ESPTeamCheck", {
    Title = "Team Check",
    Default = true,
    Callback = function(state)
        espTeamCheck = state
        updateHighlights()
    end
})

Tabs.Aimbot:AddToggle("EnableAimbot", {
    Title = "Enable Aimbot",
    Default = false,
    Callback = function(state)
        aimbotEnabled = state
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
    end
})

Tabs.Aimbot:AddSlider("AimbotRadius", {
    Title = "Aimbot Radius",
    Min = 1,
    Max = 100,
    Default = aimbotRadius,
    Rounding = 0,
    Callback = function(value)
        aimbotRadius = value
        updateFOVCircle()
    end
})

Tabs.Aimbot:AddDropdown("TargetPart", {
    Title = "Target Part",
    Values = { "Head", "Torso", "HumanoidRootPart" },
    Default = aimbotTargetPart,
    Callback = function(part)
        aimbotTargetPart = part
    end
})

Tabs.Aimbot:AddToggle("ShowFOV", {
    Title = "Show FOV Circle",
    Default = true,
    Callback = function(state)
        showFOV = state
        fovCircle.Visible = state
    end
})

Tabs.Aimbot:AddColorpicker("FOVColor", {
    Title = "FOV Color",
    Default = Color3.fromRGB(0, 255, 0),
    Callback = function(color)
        fovCircle.Color = color
    end
})
