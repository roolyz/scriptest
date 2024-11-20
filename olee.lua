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
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "crosshair" })
}

-- Variables
local highlightEnabled = false
local highlightColor = Color3.fromRGB(255, 0, 0) -- Default Red
local teamCheck = true
-- Aimbot Variables
local targetPart = "Head" -- Default to targeting the head
local fov = 150
local smoothing = 1
local teamCheck = false
local aimbotEnabled = false
-- FOV Ring
local FOVring = Drawing.new("Circle")
FOVring.Visible = true
FOVring.Thickness = 1.5
FOVring.Radius = fov
FOVring.Transparency = 1
FOVring.Color = Color3.fromRGB(255, 128, 128)

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

-- Aimbot functionality
local function getClosest(cframe)
    local ray = Ray.new(cframe.Position, cframe.LookVector).Unit
    local target = nil
    local mag = math.huge

    for _, v in pairs(game.Players:GetPlayers()) do
        if v.Character and v.Character:FindFirstChild("Humanoid") and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild(targetPart) and v ~= game.Players.LocalPlayer and (v.Team ~= game.Players.LocalPlayer.Team or (not teamCheck)) then
            local magBuf = (v.Character[targetPart].Position - ray:ClosestPoint(v.Character[targetPart].Position)).Magnitude
            if magBuf < mag then
                mag = magBuf
                target = v
            end
        end
    end

    return target
end

-- Main loop
RunService.RenderStepped:Connect(function()
    FOVring.Position = workspace.CurrentCamera.ViewportSize / 2

    local cam = workspace.CurrentCamera
    local zz = workspace.CurrentCamera.ViewportSize / 2

    local curTar = getClosest(cam.CFrame)
    if curTar then
        local ssTargetPoint = cam:WorldToScreenPoint(curTar.Character[targetPart].Position)
        ssTargetPoint = Vector2.new(ssTargetPoint.X, ssTargetPoint.Y)
        if (ssTargetPoint - zz).Magnitude < fov then
            workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(CFrame.new(cam.CFrame.Position, curTar.Character[targetPart].Position), smoothing)
        end
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

local Toggle = Tabs.Aimbot:AddToggle("aimbotEnabled", { Title = "Aimbot", Default = false })
Toggle:OnChanged(function()

    Options.AimbotEnabled:SetValue(false)


local Dropdown = Tabs.Aimbot:AddDropdown("targetPart", {
	Title = "Aimbot Target"
	Values = { "Head, Body" },
	multi = false
	default= 1,
	})
	
	Dropdown:setValue = "Head"

	Dropdown:OnChanged(function(Value)
	end)

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
