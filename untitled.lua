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
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "target" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Variables for Enemy Highlighting
local highlightEnabled = false
local highlightColor = Color3.fromRGB(255, 0, 0) -- Default Red
local teamCheck = true

-- Variables for Aimbot
local fov = 100
local fovCircle
local showFOV = true  -- Default to showing FOV circle
local SC = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
local Inset = game:GetService("GuiService"):GetGuiInset()
local aimbotTarget = "Head" -- Default target is Head

-- Function to update FOV circle size
local function updateFovCircle()
    if fovCircle then
        fovCircle.Size = UDim2.new(0, fov * 2, 0, fov * 2) -- Update the FOV circle size
        fovCircle.Position = UDim2.new(0, SC.X - fov, 0, SC.Y - fov) -- Center the circle on the screen
    end
end

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

-- Aimbot Functions
local function ClosestHoe()
    local MaxDist, Nearest = math.huge
    for I,V in pairs(game:GetService("Players"):GetPlayers()) do
        if V ~= game:GetService("Players").LocalPlayer and V.Character and V.Character:FindFirstChild("Humanoid") then
            local targetPart
            if aimbotTarget == "Head" then
                targetPart = V.Character:FindFirstChild("Head")
            elseif aimbotTarget == "Torso" then
                targetPart = V.Character:FindFirstChild("HumanoidRootPart") -- Using HumanoidRootPart as torso equivalent
            end

            if targetPart then
                local Pos, Vis = workspace.CurrentCamera:WorldToScreenPoint(targetPart.Position)
                if Vis then
                    local Diff = math.sqrt((Pos.X - SC.X) ^ 2 + (Pos.Y + Inset.Y - SC.Y) ^ 2)
                    if Diff < MaxDist and Diff < fov then
                        MaxDist = Diff
                        Nearest = V
                    end
                end
            end
        end
    end
    return Nearest
end

game:GetService("RunService").RenderStepped:Connect(function()
    if showFOV and fovCircle then
        updateFovCircle() -- Update the FOV circle size every frame
    end
end)

-- GUI Elements for Enemy Highlighting
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

-- GUI Elements for Aimbot
Tabs.Aimbot:AddToggle("ShowFOV", {
    Title = "Show FOV Circle",
    Default = true,
    Callback = function(state)
        showFOV = state
        if state then
            -- Show FOV circle
            if not fovCircle then
                fovCircle = Instance.new("Frame")
                fovCircle.Parent = game:GetService("CoreGui")
                fovCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Red color
                fovCircle.BorderSizePixel = 0
                fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
                fovCircle.Position = UDim2.new(0, SC.X - fov, 0, SC.Y - fov) -- Center the circle
                fovCircle.Size = UDim2.new(0, fov * 2, 0, fov * 2)
                fovCircle.ZIndex = 100
                fovCircle.BackgroundTransparency = 0.5
            end
        else
            -- Hide FOV circle
            if fovCircle then
                fovCircle:Destroy()
                fovCircle = nil
            end
        end
    end
})

Tabs.Aimbot:AddSlider("FOV", {
    Title = "Aimbot FOV",
    Min =  1,
    Max = 100,
    Default = fov,
    Callback = function(value)
        fov = value
        updateFovCircle()  -- Update the circle size when FOV changes
    end
})

Tabs.Aimbot:AddDropdown("AimbotTarget", {
    Title = "Aimbot Target",
    Options = {"Head", "Torso"},
    Default = 1, -- Default to "Head"
    Callback = function(selected)
        aimbotTarget = selected
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
