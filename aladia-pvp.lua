local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
 
local AimEnabled = false
local Smoothness = 1
local AimbotMode = "Instant"
local FOV = 4
 
local function getTargetPart(character)
    local head = character:FindFirstChild("Head")
    local neck = character:FindFirstChild("Neck")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
 
    local upperTorso = character:FindFirstChild("UpperTorso")
    local neckAttachment = upperTorso and upperTorso:FindFirstChild("NeckAttachment")
 
    if head then
        return head.Position
    elseif neck then
        return neck.CFrame.Position
    elseif neckAttachment then
        return neckAttachment.WorldPosition
    elseif humanoidRootPart then
        return humanoidRootPart.Position
    end
    return nil
end
 
local function getClosestPlayer()
    local closestTarget = nil
    local shortestDistance = math.huge
 
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                humanoid.Died:Connect(function()
                    player.Character = player.CharacterAdded:Wait()
                end)
                local targetPos = getTargetPart(character)
                if targetPos then
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - targetPos).Magnitude
 
                    local screenPoint, onScreen = Camera:WorldToScreenPoint(targetPos)
                    if onScreen then
                        local toTarget = (targetPos - Camera.CFrame.Position).unit
                        local cameraForward = Camera.CFrame.LookVector
                        local angle = math.acos(cameraForward:Dot(toTarget)) * (180 / math.pi)
 
                        if angle <= FOV and distance < shortestDistance then
                            shortestDistance = distance
                            closestTarget = targetPos
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end
 
local function aimAtTarget()
    local target = getClosestPlayer()
    if target then
        if AimbotMode == "Instant" then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target)
        elseif AimbotMode == "Smooth" then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target), Smoothness)
        end
    end
end
 
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimEnabled = true
    end
end)
 
UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimEnabled = false
    end
end)
 
RunService.RenderStepped:Connect(function()
    if AimEnabled then
        aimAtTarget()
    end
end)
