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
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "target" }), -- New Aimbot tab
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- Add an example button and UI elements for the "Main" tab
Tabs.Main:AddButton({
    Title = "Test Button",
    Description = "This is a test button",
    Callback = function()
        print("Button clicked!")
    end
})

-- Aimbot section
do
    local ToggleAimbot = Tabs.Aimbot:AddToggle("AimbotToggle", {
        Title = "Enable Aimbot",
        Default = false,
    })

    ToggleAimbot:OnChanged(function()
        if ToggleAimbot.Value then
            print("Aimbot enabled.")
            -- Here you would add the code to enable aimbot functionality
        else
            print("Aimbot disabled.")
            -- Disable aimbot functionality
        end
    end)

    -- Additional controls (if needed)
    Tabs.Aimbot:AddSlider("FovSlider", {
        Title = "Aimbot FOV",
        Min = 0,
        Max = 180,
        Default = 90,
        Callback = function(Value)
            print("FOV set to:", Value)
            -- Adjust the aimbot FOV (Field of View)
        end
    })

    -- Example of a simple aimbot feature (simplified):
    task.spawn(function()
        while true do
            wait(0.1)  -- Adjust aim every 0.1 seconds

            if ToggleAimbot.Value then
                -- Aimbot logic here (simplified)
                local target = nil  -- Variable to store the target (enemy)

                -- Loop through potential targets (e.g., NPCs, players)
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                        -- Check for enemy NPCs (this can be modified to suit your needs)
                        local targetPos = obj:FindFirstChild("Head") and obj.Head.Position
                        if targetPos then
                            target = obj
                            break  -- Once target is found, exit the loop
                        end
                    end
                end

                -- If a target is found, aim at it (simplified approach)
                if target then
                    -- Example aimbot: adjust camera to look at the target
                    local camera = game:GetService("Workspace").CurrentCamera
                    camera.CFrame = CFrame.new(camera.CFrame.Position, target.Head.Position)
                    -- You can add additional code to shoot, aim, or perform other actions
                    print("Aiming at target:", target)
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
