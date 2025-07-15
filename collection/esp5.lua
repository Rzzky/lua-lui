-- Roblox ESP Script with Username TextLabel

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local highlightColor = Color3.fromRGB(0, 0, 255) -- Change this color as needed
local highlightDistance = 100 -- Maximum distance to highlight players

local function createHighlight(player)
    -- Create the highlight effect
    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character
    highlight.FillColor = highlightColor
    highlight.OutlineColor = Color3.new(0, 0, 0)
    highlight.Enabled = true
    highlight.Parent = player.Character
end

local function removeHighlight(player)
    -- Remove the highlight effect
    if player.Character then
        local highlight = player.Character:FindFirstChildOfClass("Highlight")
        if highlight then
            highlight:Destroy()
        end
    end
end

local function createUsernameLabel(player)
    -- Create a BillboardGui to hold the username label
    if player.Character and player.Character:FindFirstChild("Head") then
        local head = player.Character.Head
        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Adornee = head
        billboardGui.Size = UDim2.new(0, 100, 0, 50)  -- Adjust size of label
        billboardGui.StudsOffset = Vector3.new(0, 3, 0)  -- Position above the head
        billboardGui.Parent = head

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)  -- Fill the entire BillboardGui
        textLabel.BackgroundTransparency = 1  -- Make background transparent
        textLabel.Text = player.Name  -- Display the player's username
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)  -- White text color
        textLabel.TextStrokeTransparency = 0.5  -- Slight stroke to improve visibility
        textLabel.TextSize = 14  -- Adjust text size
        textLabel.Parent = billboardGui
    end
end

local function removeUsernameLabel(player)
    -- Remove the username label from the player's head
    if player.Character then
        local head = player.Character:FindFirstChild("Head")
        if head then
            local billboardGui = head:FindFirstChildOfClass("BillboardGui")
            if billboardGui then
                billboardGui:Destroy()
            end
        end
    end
end

local function refreshHighlights()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (Camera.CFrame.Position - player.Character.HumanoidRootPart.Position).magnitude
            if distance <= highlightDistance then
                createHighlight(player)
                createUsernameLabel(player)
            else
                removeHighlight(player)
                removeUsernameLabel(player)
            end
        end
    end
end

-- Refresh highlights and username labels every second
while true do
    refreshHighlights()
    wait(1)
end
