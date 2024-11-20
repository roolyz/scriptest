local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()

local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()



local Window = Fluent:CreateWindow({

    Title = "Universal Aimbot and ESP",

    SubTitle = "reminisense",

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



-- Variables

local espEnabled = false

local espColor = Color3.fromRGB(255, 0, 0) -- Default Red

local espTeamCheck = true


local aimbotEnabled = false

local aimbotSmoothing = 0.5

local aimbotTargetPart = "Head"

local aimbotRadius = 35 -- Default targeting radius (in studs)

local showFOV = false

local fovCircleColor = Color3.fromRGB(0, 255, 0) -- Default Green



local fovCircle = Drawing.new("Circle")

fovCircle.Visible = false

fovCircle.Transparency = 1

fovCircle.Thickness = 2

fovCircle.Color = fovCircleColor

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



-- ESP
local function createHighlight()
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local isEnemy = (player.Team ~= game.Players.LocalPlayer.Team) or not espeamCheck
                local highlight = character:FindFirstChildOfClass("Highlight")

                if highlightEnabled and isEnemy then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "ESPHighlight"
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
        if espEnabled then
            createHighlights()
        end
    end
end)


-- Get Closest Enemy

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



-- Aimbot Logic

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



-- ESP Tab

Tabs.ESP:AddToggle("EnableESP", {

    Title = "Enable ESP",

    Default = false,

    Callback = function(state)

        espEnabled = state

        if not state then
        -- remove esp when turned off
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

     end

})



-- Aimbot Tab

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



Tabs.Aimbot:AddColorpicker("FOVCircleColor", {

    Title = "FOV Circle Color",

    Default = fovCircleColor,

    Callback = function(newColor)

        fovCircleColor = newColor

        fovCircle.Color = newColor

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

    Default = false,

    Callback = function(state)

        showFOV = state

        fovCircle.Visible = state

    end

})



-- Addons:

-- SaveManager (Allows you to have a configuration system)

-- InterfaceManager (Allows you to have an interface management system)



-- Hand the library over to our managers

SaveManager:SetLibrary(Fluent)

InterfaceManager:SetLibrary(Fluent)



-- Ignore keys that are used by ThemeManager.

-- (we don't want configs to save themes, do we?)

SaveManager:IgnoreThemeSettings()



-- You can add indexes of elements the save manager should ignore

SaveManager:SetIgnoreIndexes({})



-- use case for doing it this way:

-- a script hub could have themes in a global folder

-- and game configs in a separate folder per game

InterfaceManager:SetFolder("FluentScriptHub")

SaveManager:SetFolder("FluentScriptHub/specific-game")



InterfaceManager:BuildInterfaceSection(Tabs.Settings)

SaveManager:BuildConfigSection(Tabs.Settings)



-- Select the first tab

Window:SelectTab(1)



-- Notify the user when the script has loaded

Fluent:Notify({

    Title = "Universal Aimbot and ESP",

    Content = "The script has been loaded.",

    Duration = 5

})



-- You can use the SaveManager:LoadAutoloadConfig() to load a config

-- which has been marked to be one that auto loads!

SaveManager:LoadAutoloadConfig()
