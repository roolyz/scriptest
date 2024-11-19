-- Load Fluent UI and required Addons
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Create the Fluent Window
local Window = Fluent:CreateWindow({
    Title = "Enemy Highlighter",
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

-- Draggable Button Integration

-- Create Draggable Frame (squircle style)
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TextButton = Instance.new("TextButton")
local UITextSizeConstraint = Instance.new("UITextSizeConstraint")

-- Set Parent for ScreenGui
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Frame Properties (for the draggable button)
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
Frame.BackgroundTransparency = 0.5
Frame.Position = UDim2.new(0.85, 0, 0.03, 0) -- Top-right corner
Frame.Size = UDim2.new(0.1, 0, 0.1, 0) -- Small squircle size
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.ZIndex = 999 -- Always on top

-- Make Frame draggable
local dragging = false
local dragStartPos, dragStartMousePos
Frame.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStartPos = Frame.Position
        dragStartMousePos = input.Position
        input.Consumed = true
    end
end)

Frame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartMousePos
        Frame.Position = UDim2.new(dragStartPos.X.Scale, dragStartPos.X.Offset + delta.X, dragStartPos.Y.Scale, dragStartPos.Y.Offset + delta.Y)
    end
end)

Frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- TextButton Properties
TextButton.Parent = Frame
TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextButton.BackgroundTransparency = 1.0
TextButton.Size = UDim2.new(1, 0, 1, 0)
TextButton.Font = Enum.Font.SourceSans
TextButton.Text = "Toggle UI"
TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
TextButton.TextScaled = true
TextButton.TextSize = 50.0
TextButton.TextStrokeTransparency = 0.0

-- Add Text Size Constraint
UITextSizeConstraint.Parent = TextButton
UITextSizeConstraint.MaxTextSize = 30

-- Squircle shape (rounded corners)
Frame.BorderRadius = UDim.new(0, 12)  -- Creates rounded corners

-- Button click function that simulates LeftCtrl key event (toggle GUI visibility)
TextButton.MouseButton1Down:Connect(function()
    -- Simulate LeftCtrl keypress to toggle GUI
    game:GetService("VirtualInputManager"):SendKeyEvent(
        true, -- Press down
        Enum.KeyCode.LeftControl, -- Simulate LeftCtrl
        false, -- No repeat
        nil -- Player input (not needed here)
    )
    game:GetService("VirtualInputManager"):SendKeyEvent(
        false, -- Release
        Enum.KeyCode.LeftControl,
        false,
        nil
    )
end)
