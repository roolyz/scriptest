local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Create Fluent Window
local Window = Fluent:CreateWindow({
    Title = "Enemy Highlighter",
    SubTitle = "by dawid",
    TabWidth = 140,
    Size = UDim2.fromOffset(450, 320),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Default keybind
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Floating Virtual Keybind Button
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VirtualKeybindGUI"
screenGui.Parent = playerGui

-- Floating Button Properties
local virtualKeybindButton = Instance.new("TextButton")
virtualKeybindButton.Name = "KeybindToggleButton"
virtualKeybindButton.Size = UDim2.new(0, 80, 0, 80) -- Button size
virtualKeybindButton.Position = UDim2.new(0.5, -40, 0.05, 0) -- Center-top of the screen
virtualKeybindButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
virtualKeybindButton.Text = "☰" -- Menu icon
virtualKeybindButton.TextScaled = true
virtualKeybindButton.Font = Enum.Font.SourceSansBold
virtualKeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
virtualKeybindButton.Parent = screenGui
virtualKeybindButton.ZIndex = 10 -- Ensure visibility

-- Make Button Draggable
local dragStart, startPos
local dragging = false
local function updateInput(input)
    local delta = input.Position - dragStart
    virtualKeybindButton.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

virtualKeybindButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = virtualKeybindButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

virtualKeybindButton.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateInput(input)
    end
end)

-- Toggle GUI Visibility on Button Click
virtualKeybindButton.MouseButton1Click:Connect(function()
    Window:SetVisible(not Window:GetVisible())
end)

-- GUI Elements
Tabs.Main:AddToggle("EnableHighlight", {
    Title = "Enable Enemy Highlights",
    Default = false,
    Callback = function(state)
        highlightEnabled = state
        if not state then
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

-- Notify user
Fluent:Notify({
    Title = "Enemy Highlighter",
    Content = "Script Loaded Successfully! Use ☰ button to toggle GUI.",
    Duration = 5
})
