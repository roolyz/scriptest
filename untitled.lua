local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fluent " .. Fluent.Version,
    SubTitle = "by dawid",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Define tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "target" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- Highlighter (Main) section
do
    local ToggleHighlight = Tabs.Main:AddToggle("HighlightToggle", {
        Title = "Enable Highlights",
        Default = false,
    })

    ToggleHighlight:OnChanged(function()
        if ToggleHighlight.Value then
            print("Highlighting enabled.")
            -- Highlight logic here
        else
            print("Highlighting disabled.")
            -- Remove highlights
        end
    end)

    -- Color picker for highlight customization
    Tabs.Main:AddColorPicker("HighlightColor", {
        Title = "Highlight Color",
        Default = Color3.fromRGB(255, 0, 0),
        Callback = function(color)
            print("Highlight color set to:", color)
            -- Update highlight color logic
        end
    })
end

-- Aimbot section (Updated)
do
    local ToggleAimbot = Tabs.Aimbot:AddToggle("AimbotToggle", {
        Title = "Enable Aimbot",
        Default = false,
    })

    ToggleAimbot:OnChanged(function()
        if ToggleAimbot.Value then
            print("Aimbot enabled.")
        else
            print("Aimbot disabled.")
        end
    end)

    -- FOV Slider for controlling the aimbot's range
    local fovSlider = Tabs.Aimbot:AddSlider("FovSlider", {
        Title = "Aimbot FOV",
        Min = 0,
        Max = 100,
        Default = 50,
        Callback = function(Value)
            print("FOV set to:", Value)
            -- Update the FOV circle radius based on the slider value
            UpdateFovCircle(Value)
        end
    })

    -- Show FOV Toggle
    local showFovToggle = Tabs.Aimbot:AddToggle("ShowFovToggle", {
        Title = "Show FOV Circle",
        Default = false,
    })

    showFovToggle:OnChanged(function()
        if showFovToggle.Value then
            print("FOV Circle Visible")
            FovCircle.Visible = true
        else
            print("FOV Circle Hidden")
            FovCircle.Visible = false
        end
    end)

    -- Initialize FOV Circle
    local FovCircle = Instance.new("Frame")
    FovCircle.Size = UDim2.fromOffset(100, 100)
    FovCircle.Position = UDim2.fromScale(0.5, 0.5)
    FovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    FovCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    FovCircle.BackgroundTransparency = 0.5
    FovCircle.Visible = false
    FovCircle.Parent = game:GetService("CoreGui")

    -- Function to update the FOV circle size based on the slider
    function UpdateFovCircle(radius)
        local screenSize = game:GetService("Workspace").CurrentCamera.ViewportSize
        local scale = screenSize.X / 1920  -- Assuming base resolution is 1920x1080
        local size = radius * scale  -- Adjust size to match FOV slider
        FovCircle.Size = UDim2.fromOffset(size, size)
    end

    -- Aimbot logic with FOV check
    task.spawn(function()
        while true do
            wait(0.1)  -- Adjust every 0.1 seconds

            if ToggleAimbot.Value then
                -- Aimbot logic (only targets within the FOV circle)
                local camera = game:GetService("Workspace").CurrentCamera
                local mousePosition = game:GetService("Players").LocalPlayer:GetMouse().Hit.p
                local closestTarget = nil
                local closestDistance = math.huge
                local maxDistance = fovSlider.Value * 10  -- Scale distance by slider value

                -- Loop through potential targets (humanoid models)
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                        local head = obj:FindFirstChild("Head")
                        if head then
                            -- Calculate the distance from the mouse (or crosshair)
                            local targetPos = head.Position
                            local screenPos = camera:WorldToScreenPoint(targetPos)
                            local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePosition.X, mousePosition.Y)).Magnitude

                            -- Check if the target is within the FOV and the closest one
                            if distance <= maxDistance and distance < closestDistance then
                                closestTarget = obj
                                closestDistance = distance
                            end
                        end
                    end
                end

                -- Aim at the closest target within FOV
                if closestTarget then
                    camera.CFrame = CFrame.new(camera.CFrame.Position, closestTarget.Head.Position)
                    print("Aiming at target:", closestTarget)
                end
            end
        end
    end)
end

-- Settings section (existing)
Tabs.Settings:AddSlider("Slider", {
    Title = "Slider",
    Min = 0,
    Max = 5,
    Default = 2,
    Callback = function(Value)
        print("Slider value:", Value)
    end
})

-- Final setup and UI configuration
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Fluent",
    Content = "The script has been loaded.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
