-- ALIXID HUB - Aimbot + RGB ESP + FOV + UI Buttons

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CONFIG
local aimbotEnabled = true
local holdingE = false
local fovRadius = 100
local aimbotSmoothness = 0.2
local targetPartName = "Head"
local espEnabled = true
local fovVisible = true
local highlights = {}

-- UI Setup
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "ALIXID_HUB"
ScreenGui.ResetOnSpawn = false

-- Animated Intro
local IntroFrame = Instance.new("Frame", ScreenGui)
IntroFrame.Size = UDim2.new(1, 0, 1, 0)
IntroFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

local IntroText = Instance.new("TextLabel", IntroFrame)
IntroText.Size = UDim2.new(1, 0, 1, 0)
IntroText.Position = UDim2.new(0, 0, 0, 0)
IntroText.BackgroundTransparency = 1
IntroText.Text = "ALIXID HUB"
IntroText.Font = Enum.Font.GothamBlack
IntroText.TextScaled = true
IntroText.TextColor3 = Color3.new(1, 1, 1)

TweenService:Create(IntroText, TweenInfo.new(2), {TextTransparency = 0}):Play()
task.wait(2)
TweenService:Create(IntroText, TweenInfo.new(2), {TextTransparency = 1}):Play()
local tween = TweenService:Create(IntroFrame, TweenInfo.new(1), {BackgroundTransparency = 1})
tween:Play()
tween.Completed:Wait()
IntroFrame:Destroy()

-- Main Panel
local Panel = Instance.new("Frame", ScreenGui)
Panel.Size = UDim2.new(0, 250, 0, 300)
Panel.Position = UDim2.new(0.5, -125, 0.5, -150)
Panel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Panel.BorderSizePixel = 0
Panel.Active = true
Panel.Draggable = true

local Title = Instance.new("TextLabel", Panel)
Title.Size = UDim2.new(1, 0, 0, 20)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ALIXID HUB"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

local HideBtn = Instance.new("TextButton", Panel)
HideBtn.Size = UDim2.new(0, 60, 0, 20)
HideBtn.Position = UDim2.new(1, -65, 0, 0)
HideBtn.Text = "Hide"
HideBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
HideBtn.TextColor3 = Color3.new(1, 1, 1)
HideBtn.MouseButton1Click:Connect(function()
    Panel.Visible = false
    StarterGui:SetCore("SendNotification", {
        Title = "ALIXID HUB",
        Text = "Press 'K' to show the panel again.",
        Duration = 5
    })
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.K then
        Panel.Visible = true
    elseif input.KeyCode == Enum.KeyCode.E then
        holdingE = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then
        holdingE = false
    end
end)

spawn(function()
    while true do
        local hue = tick() % 5 / 5
        Panel.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        task.wait(0.05)
    end
end)

-- UI Buttons
local function createToggle(labelText, defaultState, posY, callback)
    local btn = Instance.new("TextButton", Panel)
    btn.Size = UDim2.new(0.8, 0, 0, 25)
    btn.Position = UDim2.new(0.1, 0, 0, posY)
    btn.Text = labelText .. ": " .. (defaultState and "ON" or "OFF")
    btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14

    local state = defaultState
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = labelText .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

createToggle("Aimbot", aimbotEnabled, 30, function(state) aimbotEnabled = state end)
createToggle("ESP", espEnabled, 65, function(state) espEnabled = state end)
createToggle("FOV Circle", fovVisible, 100, function(state) fovVisible = state end)

local SmoothLabel = Instance.new("TextLabel", Panel)
SmoothLabel.Size = UDim2.new(0.8, 0, 0, 20)
SmoothLabel.Position = UDim2.new(0.1, 0, 0, 140)
SmoothLabel.BackgroundTransparency = 1
SmoothLabel.TextColor3 = Color3.new(1, 1, 1)
SmoothLabel.Text = "Smoothness: " .. tostring(aimbotSmoothness)
SmoothLabel.TextSize = 14
SmoothLabel.Font = Enum.Font.SourceSans

local SmoothSlider = Instance.new("TextButton", Panel)
SmoothSlider.Size = UDim2.new(0.8, 0, 0, 20)
SmoothSlider.Position = UDim2.new(0.1, 0, 0, 165)
SmoothSlider.Text = "Change Smoothness"
SmoothSlider.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
SmoothSlider.TextColor3 = Color3.new(1, 1, 1)
SmoothSlider.Font = Enum.Font.SourceSans
SmoothSlider.TextSize = 14

SmoothSlider.MouseButton1Click:Connect(function()
    aimbotSmoothness = aimbotSmoothness + 0.1
    if aimbotSmoothness > 1 then aimbotSmoothness = 0.1 end
    SmoothLabel.Text = "Smoothness: " .. string.format("%.1f", aimbotSmoothness)
end)

-- RGB ESP Outline Only (No fill)
RunService.Heartbeat:Connect(function()
    if espEnabled then
        for i, hl in ipairs(highlights) do
            local adornee = hl.Adornee
            if adornee and adornee:FindFirstChild("HumanoidRootPart") then
                local color = Color3.fromHSV((tick() + i * 0.1) % 1, 1, 1)
                hl.OutlineColor = color
                hl.FillTransparency = 1
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if aimbotEnabled and holdingE then
        local closest, distance = nil, math.huge
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and (player.Team ~= LocalPlayer.Team or not LocalPlayer.Team) and player.Character and player.Character:FindFirstChild(targetPartName) then
                local part = player.Character[targetPartName]
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                local mousePos = UserInputService:GetMouseLocation()
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                if onScreen and mag < distance and mag <= fovRadius then
                    closest = part
                    distance = mag
                end
            end
        end
        if closest then
            local camPos = Camera.CFrame.Position
            local direction = (closest.Position - camPos).Unit
            local targetCF = CFrame.new(camPos, camPos + direction)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, aimbotSmoothness)
        end
    end
end)

local circle = Drawing.new("Circle")
circle.Color = Color3.fromRGB(255, 255, 255)
circle.Thickness = 1
circle.Filled = false
circle.Radius = fovRadius
circle.Visible = true

RunService.RenderStepped:Connect(function()
    local pos = UserInputService:GetMouseLocation()
    circle.Position = Vector2.new(pos.X, pos.Y)
    circle.Radius = fovRadius
    circle.Visible = fovVisible
end)

local function updateESP()
    for _, v in pairs(highlights) do v:Destroy() end
    table.clear(highlights)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and (player.Team ~= LocalPlayer.Team or not LocalPlayer.Team) then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local highlight = Instance.new("Highlight")
                highlight.Adornee = char
                highlight.FillColor = Color3.new(0, 0, 0)
                highlight.FillTransparency = 1
                highlight.OutlineTransparency = 0
                highlight.Parent = char
                table.insert(highlights, highlight)
            end
        end
    end
end

RunService.Stepped:Connect(function()
    if espEnabled then
        updateESP()
    end
end)

updateESP()
