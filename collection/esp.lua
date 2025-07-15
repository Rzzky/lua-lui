_G.CustomTheme = {
    Tab_Color = Color3.fromRGB(255, 255, 255),
    Tab_Text_Color = Color3.fromRGB(0, 0, 0),
    Description_Color = Color3.fromRGB(255, 255, 255),
    Description_Text_Color = Color3.fromRGB(0, 0, 0),
    Container_Color = Color3.fromRGB(255, 255, 255),
    Container_Text_Color = Color3.fromRGB(0, 0, 0),
    Button_Text_Color = Color3.fromRGB(0, 0, 0),
    Toggle_Box_Color = Color3.fromRGB(243, 243, 243),
    Toggle_Inner_Color = Color3.fromRGB(94, 255, 180),
    Toggle_Text_Color = Color3.fromRGB(0, 0, 0),
    Toggle_Border_Color = Color3.fromRGB(225, 225, 225),
    Slider_Bar_Color = Color3.fromRGB(243, 243, 243),
    Slider_Inner_Color = Color3.fromRGB(94, 255, 180),
    Slider_Text_Color = Color3.fromRGB(0, 0, 0),
    Slider_Border_Color = Color3.fromRGB(255, 255, 255),
    Dropdown_Text_Color = Color3.fromRGB(0, 0, 0),
    Dropdown_Option_BorderSize = 1,
    Dropdown_Option_BorderColor = Color3.fromRGB(235, 235, 235),
    Dropdown_Option_Color = Color3.fromRGB(255, 255, 255),
    Dropdown_Option_Text_Color = Color3.fromRGB(0, 0, 0)
}

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/preztel/AzureLibrary/master/uilib.lua", true))()


local ExploitTab = Library:CreateTab("Exploit", "This is An script that will give u inf jump", true) 
local FunnyTab = Library:CreateTab("Funny", "Funny Stuff", true) 

--true means darkmode is enabled and false means its disabled
--if you leave it empty you have a custom theme.

-- Create the toggle button for Infinite Jump
ExploitTab:CreateToggle("Enable Inf Jump", function(arg) 
    if arg then
        print("Infinite Jump is now: Enabled")
        
        
        -- Enable Infinite Jump
        _G.InfJump = true
        local UserInputService = game:GetService("UserInputService")
        local Player = game:GetService("Players").LocalPlayer

        _G.JumpConnection = UserInputService.JumpRequest:Connect(function()
            if _G.InfJump and Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
                Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)

    else
        print("Infinite Jump is now: Disabled")
        
        -- Disable Infinite Jump
        _G.InfJump = false
        if _G.JumpConnection then
            _G.JumpConnection:Disconnect()
            _G.JumpConnection = nil
        end
    end
end)



-- Create the Aimbot tab
local AimbotTab = Library:CreateTab("Aimbot", "Modify your Aimbot settings", true)


-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Aimbot Settings
_G.AimbotEnabled = false
_G.AimbotLocking = false
_G.FovRadius = 150
_G.AimbotSmoothness = 3 -- Lower = Faster, Higher = Smoother (more human-like)
_G.VisibleCheck = false -- Toggle for visibility check
_G.PredictionEnabled = false -- Toggle for prediction
_G.PredictionStrength = 0.1 -- Higher = More prediction

-- Create FOV Circle
local FovCircle = Drawing.new("Circle")
FovCircle.Color = Color3.fromRGB(255, 0, 0)
FovCircle.Thickness = 1
FovCircle.NumSides = 50
FovCircle.Filled = false
FovCircle.Transparency = 1
FovCircle.Visible = false

-- Function to update the FOV circle
local function UpdateFovCircle()
    FovCircle.Position = UserInputService:GetMouseLocation()
    FovCircle.Radius = _G.FovRadius
end

-- Function to check if a player is an enemy
local function IsEnemy(player)
    return player ~= LocalPlayer and (not LocalPlayer.Team or player.Team ~= LocalPlayer.Team)
end

-- Function to check visibility
local function IsVisible(target)
    if not _G.VisibleCheck then return true end
    local origin = Camera.CFrame.Position
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = game.Workspace:Raycast(origin, (target.Position - origin).Unit * (target.Position - origin).Magnitude, raycastParams)
    return result == nil or result.Instance:IsDescendantOf(target.Parent)
end

-- Function to check if target is within FOV
local function IsInFov(targetPosition)
    local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPosition)
    local mousePos = UserInputService:GetMouseLocation()

    if onScreen then
        local distanceFromMouse = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
        return distanceFromMouse <= _G.FovRadius
    end
    return false
end

-- Function to predict target movement (Smooth Prediction Fix)
local function PredictTargetPosition(target)
    if not _G.PredictionEnabled then
        return target.Position
    end

    local humanoidRootPart = target.Parent:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local predictedPosition = target.Position + (humanoidRootPart.Velocity * _G.PredictionStrength)
        
        -- Smoothly blend between actual position and predicted position
        return target.Position:Lerp(predictedPosition, 0.5)
    end
    return target.Position
end

-- Get the nearest enemy inside FOV
local function GetNearestEnemy()
    local nearestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Head") and IsEnemy(player) then
            local head = player.Character.Head
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
            if humanoid and humanoid.Health > 0 and IsInFov(head.Position) and IsVisible(head) then
                local predictedPosition = PredictTargetPosition(head)
                local distance = (predictedPosition - Camera.CFrame.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    nearestPlayer = player
                end
            end
        end
    end
    return nearestPlayer
end

-- Aimbot Toggle
AimbotTab:CreateToggle("Enable Aimbot", function(arg)
    _G.AimbotEnabled = arg
    FovCircle.Visible = arg
    if not arg then
        _G.AimbotLocking = false
    end
end)

-- Prediction Toggle
AimbotTab:CreateToggle("Enable Prediction(Buggy)", function(arg)
    _G.PredictionEnabled = arg
end)

-- Prediction Strength Slider
AimbotTab:CreateSlider("Prediction Strength", 0, 1, function(arg)
    _G.PredictionStrength = arg
end)

-- Visible Check Toggle
AimbotTab:CreateToggle("Visible Check(Buggy)", function(arg)
    _G.VisibleCheck = arg
end)

-- FOV Slider
AimbotTab:CreateSlider("FOV Size", 50, 600, function(arg)
    _G.FovRadius = arg
end)

-- Smoothness Slider
AimbotTab:CreateSlider("Smoothness", 1, 20, function(arg)
    _G.AimbotSmoothness = arg
end)

-- Right Click Detection
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 and _G.AimbotEnabled then
        _G.AimbotLocking = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        _G.AimbotLocking = false
    end
end)

-- Mouse Aimbot Logic (Fixed Flickering)
RunService.RenderStepped:Connect(function()
    if _G.AimbotEnabled then
        UpdateFovCircle()
        if _G.AimbotLocking then
            local targetPlayer = GetNearestEnemy()
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
                local head = targetPlayer.Character.Head
                local predictedPosition = PredictTargetPosition(head)
                local headScreenPos, onScreen = Camera:WorldToViewportPoint(predictedPosition)

                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local targetPos = Vector2.new(headScreenPos.X, headScreenPos.Y)
                    
                    -- Apply Smooth Prediction Movement
                    local moveX = (targetPos.X - mousePos.X) / _G.AimbotSmoothness
                    local moveY = (targetPos.Y - mousePos.Y) / _G.AimbotSmoothness

                    mousemoverel(moveX, moveY)
                end
            end
        end
    end
end)



-- Create the ESP tab
local ESPTab = Library:CreateTab("ESP", "Modify ESP settings", true)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Drawing = Drawing -- Using Drawing API for ESP

-- ESP Toggle
_G.ESPEnabled = false
local ESPBoxes = {}

-- Function to check if a player is an enemy
local function IsEnemy(player)
    if LocalPlayer.Team and player.Team then
        return LocalPlayer.Team ~= player.Team
    end
    return true -- If no teams exist, target all players
end

-- Function to create a box for a player
local function CreateBox(player)
    if ESPBoxes[player] then return end -- Prevent duplicate boxes

    local box = Drawing.new("Square")
    box.Color = Color3.fromRGB(0, 255, 0) -- Green
    box.Thickness = 1.5
    box.Filled = false
    box.Transparency = 1

    ESPBoxes[player] = box
end

-- Function to remove a player's box when they leave
local function RemoveBox(player)
    if ESPBoxes[player] then
        ESPBoxes[player]:Remove()
        ESPBoxes[player] = nil
    end
end

-- Function to update ESP boxes
local function UpdateESP()
    if not _G.ESPEnabled then
        for _, box in pairs(ESPBoxes) do
            box.Visible = false
        end
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsEnemy(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head")

            local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
            local footPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))

            if onScreen then
                local box = ESPBoxes[player]
                if not box then
                    CreateBox(player)
                    box = ESPBoxes[player]
                end
                
                local height = math.abs(headPos.Y - footPos.Y)
                local width = height / 2

                box.Size = Vector2.new(width, height)
                box.Position = Vector2.new(screenPos.X - width / 2, screenPos.Y - height / 2)
                box.Visible = true
            else
                if ESPBoxes[player] then
                    ESPBoxes[player].Visible = false
                end
            end
        elseif ESPBoxes[player] then
            ESPBoxes[player].Visible = false
        end
    end
end

-- Toggle ESP On/Off
ESPTab:CreateToggle("Enable ESP", function(arg)
    _G.ESPEnabled = arg

    if _G.ESPEnabled then
        print("ESP is now: Enabled")
    else
        print("ESP is now: Disabled")
    end
end)

-- Remove ESP when players leave
Players.PlayerRemoving:Connect(RemoveBox)

-- Update ESP on every frame
RunService.RenderStepped:Connect(UpdateESP)


-- Create Infinite Ammo Toggle
ExploitTab:CreateToggle("Enable Infinite Ammo", function(arg)
    _G.InfiniteAmmoEnabled = arg

    if _G.InfiniteAmmoEnabled then
        print("Infinite Ammo is now: Enabled")
    else
        print("Infinite Ammo is now: Disabled")
    end
end)

-- Function to Apply Infinite Ammo
local function ApplyInfiniteAmmo()
    while _G.InfiniteAmmoEnabled do
        for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
            if v:IsA("Tool") and v:FindFirstChild("Ammo") then
                v.Ammo.Value = 99999 -- Set Ammo to a High Value
            end
        end
        wait(0.1) -- Prevents lag, updates every 0.1 seconds
    end
end

-- Monitor Infinite Ammo Toggle
spawn(function()
    while true do
        if _G.InfiniteAmmoEnabled then
            ApplyInfiniteAmmo()
        end
        wait(1) -- Checks if Infinite Ammo is enabled every second
    end
end)

-- Mega Explosion Upon Death
FunnyTab:CreateToggle("Enable Mega Explosion Upon Death", function(arg)
    _G.MegaExplosionEnabled = arg
    if _G.MegaExplosionEnabled then
        print("Mega Explosion Upon Death is now: Enabled")
    else
        print("Mega Explosion Upon Death is now: Disabled")
    end
end)

-- Function to trigger Mega Explosion on death
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid").Died:Connect(function()
        if _G.MegaExplosionEnabled then
            local explosion = Instance.new("Explosion")
            explosion.Position = character.HumanoidRootPart.Position
            explosion.BlastRadius = 10
            explosion.BlastPressure = 10000
            explosion.Visible = true
            explosion.Parent = workspace
            local confetti = Instance.new("ParticleEmitter")
            confetti.Parent = explosion
            confetti.Texture = "rbxassetid://12345678" -- Add your own confetti texture here
            print("Mega Explosion triggered!")
        end
    end)
end)

-- FunnyTab: Create new toggles and dropdowns for fun features

-- Slow Motion Mode
FunnyTab:CreateToggle("Enable Slow Motion Mode", function(arg)
    _G.SlowMotionEnabled = arg
    if _G.SlowMotionEnabled then
        print("Slow Motion Mode is now: Enabled")
        -- Set time scale to slow motion
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.SlowMotionEnabled then
                game:GetService("TweenService"):SetTimeScale(0.1)  -- Slow down time
            else
                game:GetService("TweenService"):SetTimeScale(1)  -- Normal time scale
            end
        end)
    else
        print("Slow Motion Mode is now: Disabled")
        -- Reset time scale to normal
        game:GetService("TweenService"):SetTimeScale(1)
    end
end)

-- Zero Gravity Mode
FunnyTab:CreateToggle("Enable Zero Gravity", function(arg)
    _G.ZeroGravityEnabled = arg
    if _G.ZeroGravityEnabled then
        print("Zero Gravity Mode is now: Enabled")
        -- Set gravity to zero
        game:GetService("Workspace").Gravity = 0
    else
        print("Zero Gravity Mode is now: Disabled")
        -- Reset gravity to normal
        game:GetService("Workspace").Gravity = 196.2  -- Default gravity
    end
end)

-- Shapeshifter Mode (Dropdown to select a player to shapeshift into)
FunnyTab:CreateDropDown("Shapeshift into Player", {}, function(arg)
    if arg then
        local targetPlayer = game.Players:FindFirstChild(arg)
        if targetPlayer then
            local character = game.Players.LocalPlayer.Character
            local targetCharacter = targetPlayer.Character
            if targetCharacter then
                -- Clone target player's character model to shapeshift into
                local clonedCharacter = targetCharacter:Clone()
                clonedCharacter.Parent = game.Workspace
                clonedCharacter:SetPrimaryPartCFrame(character.HumanoidRootPart.CFrame)  -- Position the cloned character in the same place
                
                -- Make the player’s model invisible while in shapeshift mode
                character:Destroy()
                
                -- Set the new cloned model as the player’s character
                game.Players.LocalPlayer.Character = clonedCharacter
                
                -- Optional: You can adjust this to restore the original character later if needed.
            end
        end
    end
end)

-- Update the dropdown list with players' names dynamically
game.Players.PlayerAdded:Connect(function(player)
    -- Update the dropdown list when a new player joins
    local dropdownList = FunnyTab:FindFirstChild("Shapeshift into Player")
    if dropdownList then
        local playerNames = {}
        for _, plr in ipairs(game.Players:GetPlayers()) do
            table.insert(playerNames, plr.Name)
        end
        dropdownList:SetOptions(playerNames)
    end
end)

-- Handle removing the dropdown and cleaning up when the player leaves
game.Players.PlayerRemoving:Connect(function(player)
    local dropdownList = FunnyTab:FindFirstChild("Shapeshift into Player")
    if dropdownList then
        local playerNames = {}
        for _, plr in ipairs(game.Players:GetPlayers()) do
            table.insert(playerNames, plr.Name)
        end
        dropdownList:SetOptions(playerNames)
    end
end)


-- FunnyTab: Add more wacky features to the FunnyTab

-- Walking on Walls Mode
FunnyTab:CreateToggle("Enable Wall Walking", function(arg)
    _G.WallWalkingEnabled = arg
    local character = game.Players.LocalPlayer.Character
    local humanoid = character:WaitForChild("Humanoid")
    if _G.WallWalkingEnabled then
        print("Wall Walking Mode is now: Enabled")
        humanoid.PlatformStand = true
        -- Make the player walk on walls
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.WallWalkingEnabled then
                local raycastResult = workspace:Raycast(character.HumanoidRootPart.Position, Vector3.new(0, -10, 0))
                if raycastResult and raycastResult.Instance then
                    humanoidRootPart.CFrame = CFrame.new(character.HumanoidRootPart.Position, raycastResult.Instance.Position)
                end
            end
        end)
    else
        print("Wall Walking Mode is now: Disabled")
        humanoid.PlatformStand = false
    end
end)

-- Magnetic Mode
FunnyTab:CreateToggle("Enable Magnetic Mode", function(arg)
    _G.MagneticModeEnabled = arg
    if _G.MagneticModeEnabled then
        print("Magnetic Mode is now: Enabled")
        -- Attract objects to the player
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.MagneticModeEnabled then
                for _, part in ipairs(workspace:GetChildren()) do
                    if part:IsA("Part") and part.Position.magnitude < 50 then
                        local direction = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - part.Position).unit
                        part.Velocity = direction * 10  -- Adjust this multiplier for magnetic strength
                    end
                end
            end
        end)
    else
        print("Magnetic Mode is now: Disabled")
    end
end)

FunnyTab:CreateToggle("Enable Dinosaur Mode", function(arg)
    _G.DinosaurModeEnabled = arg
    if _G.DinosaurModeEnabled then
        print("Dinosaur Mode is now: Enabled")
        -- Change character appearance to a dinosaur model
        local dinosaurModels = {"rbxassetid://123532497290766", "rbxassetid://123532497290766"}  -- Replace with actual asset IDs for dinos
        local chosenDino = dinosaurModels[math.random(1, #dinosaurModels)]
        local dino = Instance.new("Model")
        dino.Parent = game.Players.LocalPlayer.Character
        dino:SetPrimaryPartCFrame(game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame)
        -- Add your dino assets here
    else
        print("Dinosaur Mode is now: Disabled")
        -- Revert back to the default character
        game.Players.LocalPlayer.Character:ClearAllChildren()
    end
end)


FunnyTab:CreateToggle("Enable Alien Abduction Mode", function(arg)
    _G.AlienAbductionEnabled = arg
    if _G.AlienAbductionEnabled then
        print("Alien Abduction Mode is now: Enabled")
        -- Abduct every few seconds
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.AlienAbductionEnabled and math.random() < 0.01 then
                -- Simulate alien abduction with a spaceship animation
                local spaceship = Instance.new("Part")
                spaceship.Size = Vector3.new(20, 5, 20)
                spaceship.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 50, 0)
                spaceship.Anchored = true
                spaceship.CanCollide = false
                spaceship.BrickColor = BrickColor.new("Bright green")
                spaceship.Parent = game.Workspace
                wait(2)
                spaceship:Destroy()
            end
        end)
    else
        print("Alien Abduction Mode is now: Disabled")
    end
end)

FunnyTab:CreateToggle("Enable Sticky Fingers Mode", function(arg)
    _G.StickyFingersEnabled = arg
    if _G.StickyFingersEnabled then
        print("Sticky Fingers Mode is now: Enabled")
        -- Attach sticky fingers behavior
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.StickyFingersEnabled then
                for _, part in ipairs(workspace:GetChildren()) do
                    if part:IsA("BasePart") and part.Position:Distance(game.Players.LocalPlayer.Character.HumanoidRootPart.Position) < 5 then
                        -- Make the part stick to your hands
                        part.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
                        part.Anchored = true
                    end
                end
            end
        end)
    else
        print("Sticky Fingers Mode is now: Disabled")
    end
end)


FunnyTab:CreateToggle("Enable Giant Foot Mode", function(arg)
    _G.GiantFootEnabled = arg
    if _G.GiantFootEnabled then
        print("Giant Foot Mode is now: Enabled")
        -- Resize the character's feet to absurd proportions
        game.Players.LocalPlayer.Character.HumanoidRootPart.Size = Vector3.new(10, 1, 10)
        -- Add an effect for the giant feet
        game:GetService("RunService").Heartbeat:Connect(function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.Size = Vector3.new(10, 1, 10)
        end)
    else
        print("Giant Foot Mode is now: Disabled")
        -- Reset character feet size
        game.Players.LocalPlayer.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 2)
    end
end)

FunnyTab:CreateToggle("Enable Freeze Time Mode", function(arg)
    _G.FreezeTimeEnabled = arg
    if _G.FreezeTimeEnabled then
        print("Freeze Time Mode is now: Enabled")
        -- Freeze time by disabling time-dependent functions
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.FreezeTimeEnabled then
                -- Simulate the freeze by preventing game updates
                game:GetService("TweenService"):Create(game.Workspace, TweenInfo.new(0), {TimeOfDay = game.Lighting.TimeOfDay})
            end
        end)
    else
        print("Freeze Time Mode is now: Disabled")
    end
end)



FunnyTab:CreateToggle("Enable Laser Eyes Mode", function(arg)
    _G.LaserEyesEnabled = arg
    if _G.LaserEyesEnabled then
        print("Laser Eyes Mode is now: Enabled")
        -- Shoot lasers from eyes
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.LaserEyesEnabled then
                -- Create laser effect when the player looks at something
                local laser = Instance.new("Part")
                laser.Size = Vector3.new(0.2, 0.2, 5)
                laser.Position = game.Players.LocalPlayer.Character.Head.Position + game.Players.LocalPlayer.Character.Head.CFrame.LookVector * 2
                laser.Anchored = true
                laser.CanCollide = false
                laser.BrickColor = BrickColor.new("Bright red")
                laser.Parent = game.Workspace
                wait(0.2)
                laser:Destroy()
            end
        end)
    else
        print("Laser Eyes Mode is now: Disabled")
    end
end)


FunnyTab:CreateToggle("Enable Slime Trail Mode", function(arg)
    _G.SlimeTrailEnabled = arg
    if _G.SlimeTrailEnabled then
        print("Slime Trail Mode is now: Enabled")
        -- Leave slime trail as you walk
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.SlimeTrailEnabled then
                local slime = Instance.new("Part")
                slime.Size = Vector3.new(5, 0.2, 5)
                slime.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(0, 1, 0)
                slime.Anchored = false
                slime.CanCollide = false
                slime.Material = Enum.Material.SmoothPlastic
                slime.BrickColor = BrickColor.new("Bright green")
                slime.Parent = game.Workspace
                -- Slime physics effect
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(5000, 5000, 5000)
                bodyVelocity.Velocity = Vector3.new(math.random(), 0, math.random()) * 10
                bodyVelocity.Parent = slime
                wait(1)
                slime:Destroy()
            end
        end)
    else
        print("Slime Trail Mode is now: Disabled")
    end
end)


FunnyTab:CreateToggle("Enable Lollipop Mode", function(arg)
    _G.LollipopModeEnabled = arg
    if _G.LollipopModeEnabled then
        print("Lollipop Mode is now: Enabled")
        -- Turn character into a giant lollipop
        local lollipop = Instance.new("Part")
        lollipop.Size = Vector3.new(5, 20, 5)
        lollipop.Shape = Enum.PartType.Cylinder
        lollipop.Color = Color3.fromRGB(255, 100, 100)  -- Lollipop color
        lollipop.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
        lollipop.Anchored = false
        lollipop.Parent = game.Workspace
        game.Players.LocalPlayer.Character = lollipop
    else
        print("Lollipop Mode is now: Disabled")
        -- Reset to normal
    end
end)

FunnyTab:CreateToggle("Enable Clone Mode", function(arg)
    _G.CloneModeEnabled = arg
    if _G.CloneModeEnabled then
        print("Clone Mode is now: Enabled")
        -- Clone the player
        local clone = game.Players.LocalPlayer.Character:Clone()
        clone.Parent = game.Workspace
        clone:SetPrimaryPartCFrame(game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame)
        -- Make the clone do random movements
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.CloneModeEnabled then
                clone.HumanoidRootPart.CFrame = clone.HumanoidRootPart.CFrame + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
            end
        end)
    else
        print("Clone Mode is now: Disabled")
        -- Destroy the clone
        if clone then
            clone:Destroy()
        end
    end
end)

FunnyTab:CreateToggle("Enable Rubberband Mode", function(arg)
    _G.RubberbandModeEnabled = arg
    if _G.RubberbandModeEnabled then
        print("Rubberband Mode is now: Enabled")
        -- Make the character elastic
        local rubberband = Instance.new("BodyVelocity")
        rubberband.MaxForce = Vector3.new(5000, 5000, 5000)
        rubberband.Velocity = Vector3.new(0, 50, 0)
        rubberband.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
        -- Stretch and pull effect
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.RubberbandModeEnabled then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, math.sin(tick()) * 2, 0)
            end
        end)
    else
        print("Rubberband Mode is now: Disabled")
        -- Remove the stretching effect
        if rubberband then
            rubberband:Destroy()
        end
    end
end)

FunnyTab:CreateToggle("Enable Water Balloon Mode", function(arg)
    _G.WaterBalloonEnabled = arg
    if _G.WaterBalloonEnabled then
        print("Water Balloon Mode is now: Enabled")
        -- Create water balloons when jumping
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.WaterBalloonEnabled then
                local waterBalloon = Instance.new("Part")
                waterBalloon.Size = Vector3.new(2, 2, 2)
                waterBalloon.Shape = Enum.PartType.Ball
                waterBalloon.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
                waterBalloon.BrickColor = BrickColor.new("Bright blue")
                waterBalloon.Material = Enum.Material.SmoothPlastic
                waterBalloon.Parent = game.Workspace
                wait(0.5)
                waterBalloon:Destroy()
            end
        end)
    else
        print("Water Balloon Mode is now: Disabled")
    end
end)

FunnyTab:CreateToggle("Enable Dizzy Mode", function(arg)
    _G.DizzyModeEnabled = arg
    if _G.DizzyModeEnabled then
        print("Dizzy Mode is now: Enabled")
        -- Apply dizziness by rotating the camera
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.DizzyModeEnabled then
                game.Workspace.CurrentCamera.CFrame = game.Workspace.CurrentCamera.CFrame * CFrame.Angles(0, math.rad(10), 0)
            end
        end)
    else
        print("Dizzy Mode is now: Disabled")
        -- Reset camera rotation
        game.Workspace.CurrentCamera.CFrame = game.Workspace.CurrentCamera.CFrame * CFrame.Angles(0, 0, 0)
    end
end)

FunnyTab:CreateToggle("Enable Banana Peel Mode", function(arg)
    _G.BananaPeelEnabled = arg
    if _G.BananaPeelEnabled then
        print("Banana Peel Mode is now: Enabled")
        -- Leave banana peels behind while walking
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.BananaPeelEnabled then
                local bananaPeel = Instance.new("Part")
                bananaPeel.Size = Vector3.new(3, 0.2, 3)
                bananaPeel.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
                bananaPeel.BrickColor = BrickColor.new("Bright yellow")
                bananaPeel.Anchored = true
                bananaPeel.CanCollide = true
                bananaPeel.Parent = game.Workspace
                -- Make others slip when they touch the peel
                bananaPeel.Touched:Connect(function(hit)
                    if hit and hit.Parent:FindFirstChild("Humanoid") then
                        hit.Parent.Humanoid.PlatformStand = true
                        wait(1)
                        hit.Parent.Humanoid.PlatformStand = false
                    end
                end)
                wait(2)
                bananaPeel:Destroy()
            end
        end)
    else
        print("Banana Peel Mode is now: Disabled")
    end
end)


FunnyTab:CreateToggle("Enable Slow Motion Walk", function(arg)
    _G.SlowMotionWalkEnabled = arg
    if _G.SlowMotionWalkEnabled then
        print("Slow Motion Walk is now: Enabled")
        -- Slow down character's movement
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.SlowMotionWalkEnabled then
                game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 5
                game:GetService("Workspace").Gravity = 10
            end
        end)
    else
        print("Slow Motion Walk is now: Disabled")
        -- Reset walk speed and gravity
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
        game:GetService("Workspace").Gravity = 196.2
    end
end)

FunnyTab:CreateToggle("Enable Floating Head Mode", function(arg)
    _G.FloatingHeadEnabled = arg
    if _G.FloatingHeadEnabled then
        print("Floating Head Mode is now: Enabled")
        -- Make head float around
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.FloatingHeadEnabled then
                local head = game.Players.LocalPlayer.Character.Head
                head.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
                wait(0.1)
            end
        end)
    else
        print("Floating Head Mode is now: Disabled")
    end
end)

FunnyTab:CreateToggle("Enable Ragdoll Mode", function(arg)
    _G.RagdollEnabled = arg
    if _G.RagdollEnabled then
        print("Ragdoll Mode is now: Enabled")
        -- Activate ragdoll effect
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.RagdollEnabled then
                game.Players.LocalPlayer.Character.Humanoid.PlatformStand = true
                game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, -10, 0)
            end
        end)
    else
        print("Ragdoll Mode is now: Disabled")
        -- Deactivate ragdoll effect
        game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false
    end
end)

FunnyTab:CreateSlider("Gravity Control", -100, 100, function(arg)
    _G.GravityLevel = arg
    game:GetService("Workspace").Gravity = _G.GravityLevel
    print("Gravity is now set to: " .. _G.GravityLevel)
end)

FunnyTab:CreateToggle("Enable Trampoline Mode", function(arg)
    _G.TrampolineEnabled = arg
    if _G.TrampolineEnabled then
        print("Trampoline Mode is now: Enabled")
        -- Add trampoline effect to jumping
        game:GetService("UserInputService").InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
                game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 200, 0)  -- Trampoline jump
            end
        end)
    else
        print("Trampoline Mode is now: Disabled")
    end
end)


FunnyTab:CreateToggle("Enable Fling Mode(Troll)", function(arg)
    _G.FlingEnabled = arg
    if _G.FlingEnabled then
        print("Fling Mode is now: Enabled")
        
        -- Function to fling players when touched
        game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Touched:Connect(function(hit)
            local character = hit.Parent
            if character:IsA("Model") and character:FindFirstChild("Humanoid") then
                -- Ensure it's not the player's own character being touched
                if character ~= game.Players.LocalPlayer.Character then
                    -- Fling the other player
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    if humanoidRootPart then
                        local flingForce = Vector3.new(math.random(-100, 100), 500, math.random(-100, 100))  -- Random fling direction
                        humanoidRootPart.Velocity = flingForce
                    end
                end
            end
        end)
    else
        print("Fling Mode is now: Disabled")
    end
end)


local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local Camera = game:GetService("Workspace").CurrentCamera

-- Table to store all drawings
local Drawings = {}

local function DrawLine()
    local l = Drawing.new("Line")
    l.Visible = false
    l.From = Vector2.new(0, 0)
    l.To = Vector2.new(1, 1)
    l.Color = Color3.fromRGB(255, 0, 0)
    l.Thickness = 1
    l.Transparency = 1
    return l
end

local function DrawESP(plr)
    repeat wait() until plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil
    local limbs = {}
    local R15 = (plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R15) and true or false
    if R15 then 
        limbs = {
            -- Spine
            Head_UpperTorso = DrawLine(),
            UpperTorso_LowerTorso = DrawLine(),
            -- Left Arm
            UpperTorso_LeftUpperArm = DrawLine(),
            LeftUpperArm_LeftLowerArm = DrawLine(),
            LeftLowerArm_LeftHand = DrawLine(),
            -- Right Arm
            UpperTorso_RightUpperArm = DrawLine(),
            RightUpperArm_RightLowerArm = DrawLine(),
            RightLowerArm_RightHand = DrawLine(),
            -- Left Leg
            LowerTorso_LeftUpperLeg = DrawLine(),
            LeftUpperLeg_LeftLowerLeg = DrawLine(),
            LeftLowerLeg_LeftFoot = DrawLine(),
            -- Right Leg
            LowerTorso_RightUpperLeg = DrawLine(),
            RightUpperLeg_RightLowerLeg = DrawLine(),
            RightLowerLeg_RightFoot = DrawLine(),
        }
    else 
        limbs = {
            Head_Spine = DrawLine(),
            Spine = DrawLine(),
            LeftArm = DrawLine(),
            LeftArm_UpperTorso = DrawLine(),
            RightArm = DrawLine(),
            RightArm_UpperTorso = DrawLine(),
            LeftLeg = DrawLine(),
            LeftLeg_LowerTorso = DrawLine(),
            RightLeg = DrawLine(),
            RightLeg_LowerTorso = DrawLine()
        }
    end

    -- Store the limbs in the Drawings table
    Drawings[plr.Name] = limbs

    local function Visibility(state)
        for i, v in pairs(limbs) do
            v.Visible = state and _G.SkeletonESPEnabled
        end
    end

    local function Colorize(color)
        for i, v in pairs(limbs) do
            v.Color = color
        end
    end

    local function UpdaterR15()
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if _G.SkeletonESPEnabled and plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") ~= nil and plr.Character.Humanoid.Health > 0 then
                local HUM, vis = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if vis then
                    -- Head
                    local H = Camera:WorldToViewportPoint(plr.Character.Head.Position)
                    if limbs.Head_UpperTorso.From ~= Vector2.new(H.X, H.Y) then
                        --Spine
                        local UT = Camera:WorldToViewportPoint(plr.Character.UpperTorso.Position)
                        local LT = Camera:WorldToViewportPoint(plr.Character.LowerTorso.Position)
                        -- Left Arm
                        local LUA = Camera:WorldToViewportPoint(plr.Character.LeftUpperArm.Position)
                        local LLA = Camera:WorldToViewportPoint(plr.Character.LeftLowerArm.Position)
                        local LH = Camera:WorldToViewportPoint(plr.Character.LeftHand.Position)
                        -- Right Arm
                        local RUA = Camera:WorldToViewportPoint(plr.Character.RightUpperArm.Position)
                        local RLA = Camera:WorldToViewportPoint(plr.Character.RightLowerArm.Position)
                        local RH = Camera:WorldToViewportPoint(plr.Character.RightHand.Position)
                        -- Left leg
                        local LUL = Camera:WorldToViewportPoint(plr.Character.LeftUpperLeg.Position)
                        local LLL = Camera:WorldToViewportPoint(plr.Character.LeftLowerLeg.Position)
                        local LF = Camera:WorldToViewportPoint(plr.Character.LeftFoot.Position)
                        -- Right leg
                        local RUL = Camera:WorldToViewportPoint(plr.Character.RightUpperLeg.Position)
                        local RLL = Camera:WorldToViewportPoint(plr.Character.RightLowerLeg.Position)
                        local RF = Camera:WorldToViewportPoint(plr.Character.RightFoot.Position)

                        --Head
                        limbs.Head_UpperTorso.From = Vector2.new(H.X, H.Y)
                        limbs.Head_UpperTorso.To = Vector2.new(UT.X, UT.Y)

                        --Spine
                        limbs.UpperTorso_LowerTorso.From = Vector2.new(UT.X, UT.Y)
                        limbs.UpperTorso_LowerTorso.To = Vector2.new(LT.X, LT.Y)

                        -- Left Arm
                        limbs.UpperTorso_LeftUpperArm.From = Vector2.new(UT.X, UT.Y)
                        limbs.UpperTorso_LeftUpperArm.To = Vector2.new(LUA.X, LUA.Y)

                        limbs.LeftUpperArm_LeftLowerArm.From = Vector2.new(LUA.X, LUA.Y)
                        limbs.LeftUpperArm_LeftLowerArm.To = Vector2.new(LLA.X, LLA.Y)

                        limbs.LeftLowerArm_LeftHand.From = Vector2.new(LLA.X, LLA.Y)
                        limbs.LeftLowerArm_LeftHand.To = Vector2.new(LH.X, LH.Y)

                        -- Right Arm
                        limbs.UpperTorso_RightUpperArm.From = Vector2.new(UT.X, UT.Y)
                        limbs.UpperTorso_RightUpperArm.To = Vector2.new(RUA.X, RUA.Y)

                        limbs.RightUpperArm_RightLowerArm.From = Vector2.new(RUA.X, RUA.Y)
                        limbs.RightUpperArm_RightLowerArm.To = Vector2.new(RLA.X, RLA.Y)

                        limbs.RightLowerArm_RightHand.From = Vector2.new(RLA.X, RLA.Y)
                        limbs.RightLowerArm_RightHand.To = Vector2.new(RH.X, RH.Y)

                        -- Left Leg
                        limbs.LowerTorso_LeftUpperLeg.From = Vector2.new(LT.X, LT.Y)
                        limbs.LowerTorso_LeftUpperLeg.To = Vector2.new(LUL.X, LUL.Y)

                        limbs.LeftUpperLeg_LeftLowerLeg.From = Vector2.new(LUL.X, LUL.Y)
                        limbs.LeftUpperLeg_LeftLowerLeg.To = Vector2.new(LLL.X, LLL.Y)

                        limbs.LeftLowerLeg_LeftFoot.From = Vector2.new(LLL.X, LLL.Y)
                        limbs.LeftLowerLeg_LeftFoot.To = Vector2.new(LF.X, LF.Y)

                        -- Right Leg
                        limbs.LowerTorso_RightUpperLeg.From = Vector2.new(LT.X, LT.Y)
                        limbs.LowerTorso_RightUpperLeg.To = Vector2.new(RUL.X, RUL.Y)

                        limbs.RightUpperLeg_RightLowerLeg.From = Vector2.new(RUL.X, RUL.Y)
                        limbs.RightUpperLeg_RightLowerLeg.To = Vector2.new(RLL.X, RLL.Y)

                        limbs.RightLowerLeg_RightFoot.From = Vector2.new(RLL.X, RLL.Y)
                        limbs.RightLowerLeg_RightFoot.To = Vector2.new(RF.X, RF.Y)
                    end

                    if limbs.Head_UpperTorso.Visible ~= true then
                        Visibility(true)
                    end
                else 
                    if limbs.Head_UpperTorso.Visible ~= false then
                        Visibility(false)
                    end
                end
            else 
                if limbs.Head_UpperTorso.Visible ~= false then
                    Visibility(false)
                end
                if game.Players:FindFirstChild(plr.Name) == nil then 
                    for i, v in pairs(limbs) do
                        v:Remove()
                    end
                    connection:Disconnect()
                end
            end
        end)
    end

    local function UpdaterR6()
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if _G.SkeletonESPEnabled and plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") ~= nil and plr.Character.Humanoid.Health > 0 then
                local HUM, vis = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if vis then
                    local H = Camera:WorldToViewportPoint(plr.Character.Head.Position)
                    if limbs.Head_Spine.From ~= Vector2.new(H.X, H.Y) then
                        local T_Height = plr.Character.Torso.Size.Y/2 - 0.2
                        local UT = Camera:WorldToViewportPoint((plr.Character.Torso.CFrame * CFrame.new(0, T_Height, 0)).p)
                        local LT = Camera:WorldToViewportPoint((plr.Character.Torso.CFrame * CFrame.new(0, -T_Height, 0)).p)

                        local LA_Height = plr.Character["Left Arm"].Size.Y/2 - 0.2
                        local LUA = Camera:WorldToViewportPoint((plr.Character["Left Arm"].CFrame * CFrame.new(0, LA_Height, 0)).p)
                        local LLA = Camera:WorldToViewportPoint((plr.Character["Left Arm"].CFrame * CFrame.new(0, -LA_Height, 0)).p)

                        local RA_Height = plr.Character["Right Arm"].Size.Y/2 - 0.2
                        local RUA = Camera:WorldToViewportPoint((plr.Character["Right Arm"].CFrame * CFrame.new(0, RA_Height, 0)).p)
                        local RLA = Camera:WorldToViewportPoint((plr.Character["Right Arm"].CFrame * CFrame.new(0, -RA_Height, 0)).p)

                        local LL_Height = plr.Character["Left Leg"].Size.Y/2 - 0.2
                        local LUL = Camera:WorldToViewportPoint((plr.Character["Left Leg"].CFrame * CFrame.new(0, LL_Height, 0)).p)
                        local LLL = Camera:WorldToViewportPoint((plr.Character["Left Leg"].CFrame * CFrame.new(0, -LL_Height, 0)).p)

                        local RL_Height = plr.Character["Right Leg"].Size.Y/2 - 0.2
                        local RUL = Camera:WorldToViewportPoint((plr.Character["Right Leg"].CFrame * CFrame.new(0, RL_Height, 0)).p)
                        local RLL = Camera:WorldToViewportPoint((plr.Character["Right Leg"].CFrame * CFrame.new(0, -RL_Height, 0)).p)

                        -- Head
                        limbs.Head_Spine.From = Vector2.new(H.X, H.Y)
                        limbs.Head_Spine.To = Vector2.new(UT.X, UT.Y)

                        --Spine
                        limbs.Spine.From = Vector2.new(UT.X, UT.Y)
                        limbs.Spine.To = Vector2.new(LT.X, LT.Y)

                        --Left Arm
                        limbs.LeftArm.From = Vector2.new(LUA.X, LUA.Y)
                        limbs.LeftArm.To = Vector2.new(LLA.X, LLA.Y)

                        limbs.LeftArm_UpperTorso.From = Vector2.new(UT.X, UT.Y)
                        limbs.LeftArm_UpperTorso.To = Vector2.new(LUA.X, LUA.Y)

                        --Right Arm
                        limbs.RightArm.From = Vector2.new(RUA.X, RUA.Y)
                        limbs.RightArm.To = Vector2.new(RLA.X, RLA.Y)

                        limbs.RightArm_UpperTorso.From = Vector2.new(UT.X, UT.Y)
                        limbs.RightArm_UpperTorso.To = Vector2.new(RUA.X, RUA.Y)

                        --Left Leg
                        limbs.LeftLeg.From = Vector2.new(LUL.X, LUL.Y)
                        limbs.LeftLeg.To = Vector2.new(LLL.X, LLL.Y)

                        limbs.LeftLeg_LowerTorso.From = Vector2.new(LT.X, LT.Y)
                        limbs.LeftLeg_LowerTorso.To = Vector2.new(LUL.X, LUL.Y)

                        --Right Leg
                        limbs.RightLeg.From = Vector2.new(RUL.X, RUL.Y)
                        limbs.RightLeg.To = Vector2.new(RLL.X, RLL.Y)

                        limbs.RightLeg_LowerTorso.From = Vector2.new(LT.X, LT.Y)
                        limbs.RightLeg_LowerTorso.To = Vector2.new(RUL.X, RUL.Y)
                    end

                    if limbs.Head_Spine.Visible ~= true then
                        Visibility(true)
                    end
                else 
                    if limbs.Head_Spine.Visible ~= false then
                        Visibility(false)
                    end
                end
            else 
                if limbs.Head_Spine.Visible ~= false then
                    Visibility(false)
                end
                if game.Players:FindFirstChild(plr.Name) == nil then 
                    for i, v in pairs(limbs) do
                        v:Remove()
                    end
                    connection:Disconnect()
                end
            end
        end)
    end

    if R15 then
        coroutine.wrap(UpdaterR15)()
    else 
        coroutine.wrap(UpdaterR6)()
    end
end

-- Function to initialize ESP for all players
local function InitializeESP()
    for i, v in pairs(game:GetService("Players"):GetPlayers()) do
        if v.Name ~= Player.Name then
            DrawESP(v)
        end
    end
end

-- Function to handle player added event
local function OnPlayerAdded(newplr)
    if newplr.Name ~= Player.Name then
        DrawESP(newplr)
    end
end

-- Connect to PlayerAdded event
game.Players.PlayerAdded:Connect(OnPlayerAdded)

-- Initialize ESP for existing players
InitializeESP()

-- Toggle functionality
ESPTab:CreateToggle("Enable Skeleton ESP", function(arg)
    _G.SkeletonESPEnabled = arg
    
    if _G.SkeletonESPEnabled then
        print("Skeleton ESP is now: Enabled")
        InitializeESP()
    else
        print("Skeleton ESP is now: Disabled")
        for _, Skeleton in pairs(Drawings) do
            for _, Line in pairs(Skeleton) do
                Line.Visible = false
            end
        end
    end
end)


-- Weapon ESP Toggle
FunnyTab:CreateToggle("Enable Weapon ESP", function(arg)
    _G.WeaponESPEnabled = arg
    if _G.WeaponESPEnabled then
        print("Weapon ESP is now: Enabled")
        game:GetService("RunService").Heartbeat:Connect(function()
            for _, player in pairs(game.Players:GetPlayers()) do
                if player.Character then
                    for _, part in pairs(player.Character:GetChildren()) do
                        if part:IsA("Tool") then
                            local weapon = part
                            -- Show weapon ESP (a box around the weapon)
                            local screenPos = workspace.CurrentCamera:WorldToScreenPoint(weapon.Position)
                            local weaponBox = Drawing.new("Square")
                            weaponBox.Size = Vector2.new(50, 50)  -- Adjust size based on the weapon
                            weaponBox.Position = Vector2.new(screenPos.X - 25, screenPos.Y - 25)
                            weaponBox.Color = Color3.fromRGB(255, 0, 0)  -- Red color for the weapon
                            weaponBox.Thickness = 1
                            weaponBox.Filled = false
                            weaponBox.Visible = _G.WeaponESPEnabled
                        end
                    end
                end
            end
        end)
    else
        print("Weapon ESP is now: Disabled")
    end
end)


-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Drawing = Drawing
local Workspace = game:GetService("Workspace")

-- ESP Variables
_G.InvisibleWallESPEnabled = false
local InvisibleWallESP = {}

-- Function to check for invisible walls
local function CheckInvisibleWalls()
    for _, part in pairs(Workspace:GetChildren()) do
        if part:IsA("Part") and part.Name == "InvisibleWall" then -- This assumes invisible walls are named "InvisibleWall"
            if not InvisibleWallESP[part] then
                local wallBox = Drawing.new("Square")
                wallBox.Color = Color3.fromRGB(255, 0, 0)
                wallBox.Thickness = 2
                wallBox.Filled = false
                wallBox.Transparency = 1
                InvisibleWallESP[part] = wallBox
            end
        end
    end
end

-- Function to update Invisible Wall ESP
local function UpdateInvisibleWallESP()
    for part, box in pairs(InvisibleWallESP) do
        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)

        if onScreen then
            local size = Camera:WorldToViewportPoint(part.Position + part.Size) - screenPos
            box.Size = Vector2.new(size.X, size.Y)
            box.Position = Vector2.new(screenPos.X - size.X / 2, screenPos.Y - size.Y / 2)
            box.Visible = _G.InvisibleWallESPEnabled
        else
            box.Visible = false
        end
    end
end

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Humanoid = LocalPlayer.Character and LocalPlayer.Character:WaitForChild("Humanoid")

-- Variable to store the last death position
local lastDeathPosition = nil

-- Enable Invincibility Toggle
ExploitTab:CreateToggle("Enable Invincibility", function(arg)
    if arg then
        -- Prevent death by keeping health above 0
        if Humanoid then
            Humanoid.HealthChanged:Connect(function()
                if Humanoid.Health <= 0 then
                    -- Prevent death, resetting health to a non-zero value
                    Humanoid.Health = 10
                end
            end)
        end
        print("Invincibility is now: Enabled")
    else
        print("Invincibility is now: Disabled")
    end
end)

-- Track death and store the last position
if Humanoid then
    Humanoid.Died:Connect(function()
        -- Save position when the player dies
        lastDeathPosition = LocalPlayer.Character.HumanoidRootPart.Position
        print("You died at: " .. tostring(lastDeathPosition))
    end)
end

-- Teleport to Last Death Location Toggle
ExploitTab:CreateToggle("Teleport to Last Death Location", function(arg)
    if arg then
        -- If there's a saved death location, teleport the player there
        if lastDeathPosition then
            -- Ensure the player's character has spawned
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(lastDeathPosition))
                print("Teleported to last death location!")
            else
                print("Character not available to teleport!")
            end
        else
            print("No death location saved!")
        end
    else
        print("Teleport to last death location: Disabled")
    end
end)




-- Toggle Invisible Wall ESP
ESPTab:CreateToggle("Enable Invisible Wall ESP", function(arg)
    _G.InvisibleWallESPEnabled = arg
    if _G.InvisibleWallESPEnabled then
        print("Invisible Wall ESP is now: Enabled")
    else
        print("Invisible Wall ESP is now: Disabled")
    end
end)

-- Update Invisible Wall ESP every frame
RunService.RenderStepped:Connect(function()
    if _G.InvisibleWallESPEnabled then
        CheckInvisibleWalls()
        UpdateInvisibleWallESP()
    end
end)




FunnyTab:CreateToggle("Enable Lava Floor Mode", function(arg)
    _G.LavaFloorEnabled = arg
    if _G.LavaFloorEnabled then
        print("Lava Floor Mode is now: Enabled")
        -- Change the floor to lava
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.LavaFloorEnabled then
                for _, part in ipairs(workspace:GetChildren()) do
                    if part:IsA("BasePart") and part.Position.Y < 10 then
                        part.BrickColor = BrickColor.new("Bright red")
                    end
                end
            end
        end)
    else
        print("Lava Floor Mode is now: Disabled")
        -- Reset the floor to normal
        for _, part in ipairs(workspace:GetChildren()) do
            if part:IsA("BasePart") then
                part.BrickColor = BrickColor.new("Medium stone grey")
            end
        end
    end
end)


FunnyTab:CreateToggle("Enable Twerk Mode", function(arg)
    _G.TwerkModeEnabled = arg
    if _G.TwerkModeEnabled then
        print("Twerk Mode is now: Enabled")
        -- Activate the twerk animation
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.TwerkModeEnabled then
                -- Insert twerk animation or just make the character move in an odd way
                local twerkAnim = Instance.new("Animation")
                twerkAnim.AnimationId = "rbxassetid://1122334455"  -- Replace with a twerking animation ID
                game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(twerkAnim):Play()
            end
        end)
    else
        print("Twerk Mode is now: Disabled")
        -- Stop the animation
        game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(nil)
    end
end)



-- Troll Mode (Changes character every 5 seconds)
FunnyTab:CreateToggle("Enable Troll Mode", function(arg)
    _G.TrollModeEnabled = arg
    if _G.TrollModeEnabled then
        print("Troll Mode is now: Enabled")
        -- Change character every 5 seconds
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.TrollModeEnabled then
                wait(5)  -- Wait 5 seconds before changing character
                local targetPlayer = game.Players:GetPlayers()[math.random(1, #game.Players:GetPlayers())]
                if targetPlayer and targetPlayer.Character then
                    local characterClone = targetPlayer.Character:Clone()
                    characterClone.Parent = game.Workspace
                    game.Players.LocalPlayer.Character:Destroy()
                    game.Players.LocalPlayer.Character = characterClone
                    characterClone:SetPrimaryPartCFrame(game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame)  -- Keep the same position
                end
            end
        end)
    else
        print("Troll Mode is now: Disabled")
    end
end)

-- Flying Cows Mode
FunnyTab:CreateToggle("Enable Flying Cows Mode", function(arg)
    _G.FlyingCowsEnabled = arg
    if _G.FlyingCowsEnabled then
        print("Flying Cows Mode is now: Enabled")
        -- Create flying cows every few seconds
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.FlyingCowsEnabled then
                local cow = Instance.new("Part")
                cow.Size = Vector3.new(4, 4, 4)
                cow.Position = Vector3.new(math.random(-50, 50), 100, math.random(-50, 50))  -- Random high position
                cow.Anchored = true
                cow.CanCollide = true
                cow.Shape = Enum.PartType.Ball
                cow.Color = Color3.fromRGB(255, 255, 255)  -- White cow
                cow.Parent = game.Workspace
                -- Apply floating force to simulate flying
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Velocity = Vector3.new(0, math.random(50, 100), 0)  -- Random floating upwards force
                bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)  -- High force to counteract gravity
                bodyVelocity.Parent = cow
                -- Add random cow-like behavior (move in random directions)
                game:GetService("RunService").Heartbeat:Connect(function()
                    if cow and cow.Parent then
                        local randomDirection = Vector3.new(math.random(-10, 10), 0, math.random(-10, 10))
                        cow.Velocity = randomDirection
                    end
                end)
            end
        end)
    else
        print("Flying Cows Mode is now: Disabled")
    end
end)


-- FunnyTab: Add more zany features to keep the laughter going!

-- Ghost Mode
FunnyTab:CreateToggle("Enable Ghost Mode", function(arg)
    _G.GhostModeEnabled = arg
    local character = game.Players.LocalPlayer.Character
    if _G.GhostModeEnabled then
        print("Ghost Mode is now: Enabled")
        -- Phase through walls
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.GhostModeEnabled then
                for _, part in ipairs(workspace:GetChildren()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false  -- Pass through everything
                    end
                end
            end
        end)
    else
        print("Ghost Mode is now: Disabled")
        -- Re-enable collisions
        for _, part in ipairs(workspace:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end)

-- Shrink Ray Mode
FunnyTab:CreateToggle("Enable Shrink Ray Mode", function(arg)
    _G.ShrinkRayEnabled = arg
    if _G.ShrinkRayEnabled then
        print("Shrink Ray Mode is now: Enabled")
        -- Shrink nearby players
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.ShrinkRayEnabled then
                for _, player in ipairs(game.Players:GetPlayers()) do
                    if player.Character and player.Character ~= game.Players.LocalPlayer.Character then
                        local character = player.Character
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            -- Shrink the character
                            character:SetPrimaryPartCFrame(character.PrimaryPart.CFrame)
                            character:SetScale(Vector3.new(0.1, 0.1, 0.1))  -- Shrink the player down
                        end
                    end
                end
            end
        end)
    else
        print("Shrink Ray Mode is now: Disabled")
        -- Reset the player size
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player.Character then
                local character = player.Character
                character:SetPrimaryPartCFrame(character.PrimaryPart.CFrame)
                character:SetScale(Vector3.new(1, 1, 1))  -- Reset the player size
            end
        end
    end
end)

-- Slow Motion Mode (Full Effect)
FunnyTab:CreateToggle("Enable Slow Motion Mode", function(arg)
    _G.SlowMotionEnabled = arg
    if _G.SlowMotionEnabled then
        print("Slow Motion Mode is now: Enabled")
        -- Slow down the entire game
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.SlowMotionEnabled then
                game:GetService("TweenService"):Create(game:GetService("Workspace"), TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {TimeScale = 0.1}):Play()
            end
        end)
    else
        print("Slow Motion Mode is now: Disabled")
        -- Reset to normal speed
        game:GetService("TweenService"):Create(game:GetService("Workspace"), TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {TimeScale = 1}):Play()
    end
end)

-- Boomerang Mode
FunnyTab:CreateToggle("Enable Boomerang Mode", function(arg)
    _G.BoomerangModeEnabled = arg
    if _G.BoomerangModeEnabled then
        print("Boomerang Mode is now: Enabled")
        -- Make objects boomerang back to the player when thrown
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.BoomerangModeEnabled then
                -- Example of a thrown object (can be modified to other types)
                local player = game.Players.LocalPlayer
                local character = player.Character
                local weapon = character:FindFirstChild("Weapon")  -- Adjust this to any throwable object
                if weapon then
                    local originalPosition = weapon.Position
                    local direction = (character.HumanoidRootPart.Position - originalPosition).unit
                    -- Make it return
                    weapon.Velocity = direction * -50  -- Boomerang velocity
                end
            end
        end)
    else
        print("Boomerang Mode is now: Disabled")
    end
end)

-- Random Object Spawn Mode
FunnyTab:CreateToggle("Enable Random Object Spawn", function(arg)
    _G.RandomObjectSpawnEnabled = arg
    if _G.RandomObjectSpawnEnabled then
        print("Random Object Spawn Mode is now: Enabled")
        -- Spawn random objects in random places
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.RandomObjectSpawnEnabled then
                local randomObject = Instance.new("Part")
                randomObject.Size = Vector3.new(math.random(5, 20), math.random(5, 20), math.random(5, 20))
                randomObject.Position = Vector3.new(math.random(-50, 50), math.random(10, 50), math.random(-50, 50))
                randomObject.Anchored = true
                randomObject.CanCollide = true
                randomObject.BrickColor = BrickColor.Random()  -- Random color
                randomObject.Parent = game.Workspace
                game:GetService("Debris"):AddItem(randomObject, 10)  -- Remove object after 10 seconds
            end
        end)
    else
        print("Random Object Spawn Mode is now: Disabled")
    end
end)

-- Silly Sound Effects Mode
FunnyTab:CreateToggle("Enable Silly Sound Effects Mode", function(arg)
    _G.SillySoundEffectsEnabled = arg
    if _G.SillySoundEffectsEnabled then
        print("Silly Sound Effects Mode is now: Enabled")
        -- Play random sound effects with each action
        local sounds = {"rbxassetid://123456789", "rbxassetid://987654321", "rbxassetid://1122334455"}  -- Replace with actual sound IDs
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.SillySoundEffectsEnabled then
                local randomSound = Instance.new("Sound")
                randomSound.SoundId = sounds[math.random(1, #sounds)]
                randomSound.Parent = game.Players.LocalPlayer.Character
                randomSound:Play()
                -- Delete sound after it plays
                game:GetService("Debris"):AddItem(randomSound, 5)
            end
        end)
    else
        print("Silly Sound Effects Mode is now: Disabled")
    end
end)



-- Big Head Mode
FunnyTab:CreateToggle("Enable Big Head Mode", function(arg)
    _G.BigHeadModeEnabled = arg
    if _G.BigHeadModeEnabled then
        print("Big Head Mode is now: Enabled")
        game.Players.LocalPlayer.Character:WaitForChild("Head").Size = Vector3.new(5, 5, 5)  -- Make head giant
    else
        print("Big Head Mode is now: Disabled")
        game.Players.LocalPlayer.Character:WaitForChild("Head").Size = Vector3.new(2, 2, 2)  -- Reset to normal size
    end
end)


-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Variables
local silentAimActive = false -- Default to off
local fovRadius = 100 -- Adjustable FOV radius

-- FOV Circle using Drawing API
local fovCircle = Drawing.new("Circle")
fovCircle.Radius = fovRadius
fovCircle.Thickness = 1
fovCircle.Color = Color3.fromRGB(255, 0, 0)
fovCircle.Filled = false
fovCircle.Transparency = 1

-- Update FOV Circle position
RunService.RenderStepped:Connect(function()
    local mouseLocation = UserInputService:GetMouseLocation()
    fovCircle.Position = Vector2.new(mouseLocation.X, mouseLocation.Y)
    fovCircle.Radius = fovRadius -- Update radius dynamically
    fovCircle.Visible = silentAimActive
end)

-- Function to get the nearest target's head within FOV
local function getNearestHead()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mouseLocation = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local screenPosition, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            local distanceFromMouse = (Vector2.new(screenPosition.X, screenPosition.Y) - mouseLocation).Magnitude
            
            if onScreen and distanceFromMouse < fovRadius and distanceFromMouse < shortestDistance then
                shortestDistance = distanceFromMouse
                closestPlayer = player
            end
        end
    end

    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Head") then
        return closestPlayer.Character.Head
    end

    return nil
end

-- Silent aim functionality with headshots
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and silentAimActive then
        local targetHead = getNearestHead()
        if targetHead then
            local aimPosition = targetHead.Position
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPosition)
            ReplicatedStorage.Remotes.Attack:FireServer(targetHead)
        end
    end
end)

-- Toggle for Silent Aim
AimbotTab:CreateToggle("Silent Aim(Rivals)", function(arg)
    silentAimActive = arg
    fovCircle.Visible = arg
    if arg then
        print("Silent Aim is now: Enabled")
    else
        print("Silent Aim is now: Disabled")
    end
end)



-- Slider for FOV Radius
AimbotTab:CreateSlider("Fov Radius", 0, 600, function(arg)
    fovRadius = arg
    print("Fov Radius is set to:", arg)
end)


-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()

-- Variables
local triggerbotActive = false
local clickDelay = 0
local lastClickTime = 0

-- Function to simulate mouse click
local function simulateClick()
    mouse1click()
end

-- Function to check if the hovered part belongs to another player
local function isHoveringPlayer()
    local target = mouse.Target
    if target then
        local character = target:FindFirstAncestorOfClass("Model")
        if character and Players:GetPlayerFromCharacter(character) then
            return true
        end
    end
    return false
end

-- Function to create a notification
local function createNotification(message)
    StarterGui:SetCore("SendNotification", {
        Title = "Triggerbot",
        Text = message,
        Duration = 2,  
    })
end

-- Mouse movement detection
mouse.Move:Connect(function()
    if triggerbotActive and isHoveringPlayer() then
        local currentTime = tick()
        if currentTime - lastClickTime >= clickDelay then
            simulateClick()
            lastClickTime = currentTime
        end
    end
end)

-- Toggle for Triggerbot
AimbotTab:CreateToggle("Triggerbot", function(arg)
    triggerbotActive = arg
    createNotification("Triggerbot is now " .. (arg and "Enabled" or "Disabled"))
    print("Triggerbot is now:", arg and "Enabled" or "Disabled")
end)

-- Slider for Click Delay
AimbotTab:CreateSlider("Click Delay", 0, 1, function(arg)
    clickDelay = arg
    print("Click Delay is set to:", arg)
end)



-- Name ESP Toggle
_G.NameESPEnabled = false
local NameESPObjects = {}

-- Function to check if a player is an enemy
local function IsEnemy(player)
    if LocalPlayer.Team and player.Team then
        return LocalPlayer.Team ~= player.Team
    end
    return true -- If no teams exist, target all players
end

-- Function to create a Name ESP label
local function CreateNameESP(player)
    if NameESPObjects[player] then return end -- Prevent duplicate labels

    local nameTag = Drawing.new("Text")
    nameTag.Color = Color3.fromRGB(255, 255, 255) -- White Text
    nameTag.Size = 16
    nameTag.Outline = true
    nameTag.Center = true
    nameTag.Visible = false

    NameESPObjects[player] = nameTag
end

-- Function to remove a player's Name ESP when they leave
local function RemoveNameESP(player)
    if NameESPObjects[player] then
        NameESPObjects[player]:Remove()
        NameESPObjects[player] = nil
    end
end

-- Function to update Name ESP positions
local function UpdateNameESP()
    if not _G.NameESPEnabled then
        for _, nameTag in pairs(NameESPObjects) do
            nameTag.Visible = false
        end
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsEnemy(player) and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))

            if onScreen then
                local nameTag = NameESPObjects[player]
                if not nameTag then
                    CreateNameESP(player)
                    nameTag = NameESPObjects[player]
                end
                
                nameTag.Position = Vector2.new(screenPos.X, screenPos.Y)
                nameTag.Text = player.Name
                nameTag.Visible = true
            else
                if NameESPObjects[player] then
                    NameESPObjects[player].Visible = false
                end
            end
        elseif NameESPObjects[player] then
            NameESPObjects[player].Visible = false
        end
    end
end

-- Add Name ESP Toggle to ESP Tab
ESPTab:CreateToggle("Enable Name ESP", function(arg)
    _G.NameESPEnabled = arg

    if _G.NameESPEnabled then
        print("Name ESP is now: Enabled")
    else
        print("Name ESP is now: Disabled")
    end
end)

-- Remove Name ESP when players leave
Players.PlayerRemoving:Connect(RemoveNameESP)

-- Update Name ESP on every frame
RunService.RenderStepped:Connect(UpdateNameESP)


-- Rainbow Chams Toggle
_G.RainbowChamsEnabled = false
local RainbowChamsObjects = {}

-- Function to generate a rainbow color based on time
local function GetRainbowColor()
    local hue = tick() % 5 / 5 -- Generates smooth color transitions over time
    return Color3.fromHSV(hue, 1, 1)
end

-- Function to check if a player is an enemy
local function IsEnemy(player)
    if LocalPlayer.Team and player.Team then
        return LocalPlayer.Team ~= player.Team
    end
    return true -- If no teams exist, target all players
end

-- Function to create a Chams effect
local function CreateChams(player)
    if RainbowChamsObjects[player] then return end -- Prevent duplicate chams

    local highlight = Instance.new("Highlight")
    highlight.Parent = player.Character
    highlight.FillTransparency = 0.5 -- Adjust visibility
    highlight.OutlineTransparency = 0
    highlight.Adornee = player.Character

    RainbowChamsObjects[player] = highlight
end

-- Function to remove Chams when player leaves
local function RemoveChams(player)
    if RainbowChamsObjects[player] then
        RainbowChamsObjects[player]:Destroy()
        RainbowChamsObjects[player] = nil
    end
end

-- Function to update Chams color dynamically
local function UpdateChams()
    if not _G.RainbowChamsEnabled then
        for _, chams in pairs(RainbowChamsObjects) do
            chams.FillTransparency = 1 -- Hide when disabled
        end
        return
    end

    local rainbowColor = GetRainbowColor()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsEnemy(player) and player.Character then
            local chams = RainbowChamsObjects[player]
            if not chams then
                CreateChams(player)
                chams = RainbowChamsObjects[player]
            end
            
            chams.FillColor = rainbowColor
            chams.OutlineColor = rainbowColor
        end
    end
end

-- Add Rainbow Chams Toggle to ESP Tab
ESPTab:CreateToggle("Enable Rainbow Chams", function(arg)
    _G.RainbowChamsEnabled = arg

    if _G.RainbowChamsEnabled then
        print("Rainbow Chams is now: Enabled")
    else
        print("Rainbow Chams is now: Disabled")
    end
end)

-- Remove Chams when players leave
Players.PlayerRemoving:Connect(RemoveChams)

-- Update Chams color every frame
RunService.RenderStepped:Connect(UpdateChams)


-- Infinite Health Settings
_G.InfHealthEnabled = false

-- Create Toggle for Infinite Health
ExploitTab:CreateToggle("Enable Infinite Health", function(arg)
    _G.InfHealthEnabled = arg

    if _G.InfHealthEnabled then
        print("Infinite Health is now: Enabled")
    else
        print("Infinite Health is now: Disabled")
    end
end)

-- Function to continuously set player's health to max
RunService.Heartbeat:Connect(function()
    if _G.InfHealthEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        if humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth -- Set health to maximum
        end
    end
end)



-- Invisibility Settings
_G.InvisibleEnabled = false

-- Create Toggle for Invisibility
ExploitTab:CreateToggle("Enable Invisibility", function(arg)
    _G.InvisibleEnabled = arg

    if _G.InvisibleEnabled then
        print("Invisibility is now: Enabled")
        -- Make the character invisible
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Transparency = 1  -- Set transparency to 1 (invisible)
                part.CanCollide = false  -- Disable collision for invisibility
            end
        end
    else
        print("Invisibility is now: Disabled")
        -- Restore character visibility
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Transparency = 0  -- Restore normal transparency
                part.CanCollide = true  -- Enable collision
            end
        end
    end
end)

-- Function to update invisibility when the character respawns
LocalPlayer.CharacterAdded:Connect(function(character)
    if _G.InvisibleEnabled then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
                part.CanCollide = false
            end
        end
    end
end)



-- Flight Settings
_G.FlyEnabled = false
_G.FlySpeed = 50
_G.IsFlying = false
_G.BodyVelocity = nil
_G.Humanoid = nil

-- Create Toggle for Fly Mode
ExploitTab:CreateToggle("Enable Fly Mode", function(arg)
    _G.FlyEnabled = arg

    if _G.FlyEnabled then
        print("Fly Mode is now: Enabled")
    else
        print("Fly Mode is now: Disabled")
        DisableFly()
    end
end)

-- Function to start flying
local function StartFlying()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local humanoidRootPart = character.HumanoidRootPart
        _G.Humanoid = character:FindFirstChild("Humanoid")

        -- Create BodyVelocity to simulate flying
        _G.BodyVelocity = Instance.new("BodyVelocity")
        _G.BodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
        _G.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        _G.BodyVelocity.Parent = humanoidRootPart
        _G.IsFlying = true
    end
end

-- Function to stop flying
local function DisableFly()
    if _G.BodyVelocity then
        _G.BodyVelocity:Destroy()
        _G.BodyVelocity = nil
    end
    _G.IsFlying = false
end

-- Detect when the player presses F to toggle flight
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.F and _G.FlyEnabled then
        if _G.IsFlying then
            DisableFly()  -- Disable flight if it's already enabled
        else
            StartFlying()  -- Start flying if not already flying
        end
    end
end)

-- Update the BodyVelocity to allow controlled flight while pressing F
RunService.RenderStepped:Connect(function()
    if _G.IsFlying then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = character.HumanoidRootPart

            -- Adjust the velocity based on player movement (WASD + space)
            local velocity = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                velocity = velocity + humanoidRootPart.CFrame.LookVector * _G.FlySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                velocity = velocity - humanoidRootPart.CFrame.LookVector * _G.FlySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                velocity = velocity - humanoidRootPart.CFrame.RightVector * _G.FlySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                velocity = velocity + humanoidRootPart.CFrame.RightVector * _G.FlySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                velocity = velocity + Vector3.new(0, _G.FlySpeed, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                velocity = velocity - Vector3.new(0, _G.FlySpeed, 0)
            end

            -- Apply the velocity to the player's humanoidRootPart to simulate flight
            if _G.BodyVelocity then
                _G.BodyVelocity.Velocity = velocity
            end
        end
    end
end)


-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Default Speed
_G.Speed = 16

-- Function to Apply WalkSpeed
local function ApplyWalkSpeed()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = _G.Speed
    end
end

-- Create Slider for WalkSpeed
ExploitTab:CreateSlider("Walk Speed", 16, 100, function(value)
    _G.Speed = value
    print("Walk Speed set to:", _G.Speed)
    ApplyWalkSpeed() -- Update speed when slider is changed
end)

-- Apply WalkSpeed on Character Respawn
LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid") -- Ensure Humanoid exists
    ApplyWalkSpeed()
end)

-- Constantly Monitor & Reset WalkSpeed if Changed
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        if humanoid.WalkSpeed ~= _G.Speed then
            humanoid.WalkSpeed = _G.Speed
        end
    end
end)

-- Apply Speed if Character Exists
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
    ApplyWalkSpeed()
end



-- Anti Kick
_G.AntiKickEnabled = false

-- Create Toggle for Anti Kick
ExploitTab:CreateToggle("Enable Anti Kick(stopable", function(arg)
    _G.AntiKickEnabled = arg

    if _G.AntiKickEnabled then
        print("Anti Kick is now: Enabled")
    else
        print("Anti Kick is now: Disabled")
    end
end)

-- Function to prevent player from being kicked
local function PreventKick()
    -- Listen for when the player is about to leave the game
    game.Players.PlayerRemoving:Connect(function(player)
        if _G.AntiKickEnabled and player == LocalPlayer then
            -- Prevent the player from being kicked by reconnecting them instantly
            game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)  -- Teleport back to the same place
            print("Anti-Kick activated: Preventing kick...")
        end
    end)

    -- Prevent character reset (being removed)
    game:GetService("Players").PlayerAdded:Connect(function(player)
        if _G.AntiKickEnabled and player == LocalPlayer then
            local character = player.Character or player.CharacterAdded:Wait()

            -- Keep character from being destroyed
            character:WaitForChild("Humanoid").Died:Connect(function()
                if _G.AntiKickEnabled then
                    print("Anti-Kick activated: Preventing death kick...")
                    -- You can add a respawn mechanic here if needed
                end
            end)
        end
    end)
end

-- Keep checking if Anti Kick is enabled
game:GetService("RunService").Heartbeat:Connect(function()
    if _G.AntiKickEnabled then
        PreventKick()  -- Start monitoring anti-kick behavior
    end
end)


_G.ChatSpamEnabled = false
_G.Message = "Hello, world!"

ExploitTab:CreateToggle("Enable Chat Spam", function(arg)
    _G.ChatSpamEnabled = arg

    if _G.ChatSpamEnabled then
        print("Chat Spam is now: Enabled")
    else
        print("Chat Spam is now: Disabled")
    end
end)

-- Spam chat
while _G.ChatSpamEnabled do
    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(_G.Message, "All")
    wait(1)  -- Send message every 1 second
end


-- Get the nearest enemy function (team check and not dead)
local function GetNearestEnemy()
    local nearestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        -- Check if the player is not the local player, is alive, and is on a different team
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            -- Team check (make sure they are on a different team)
            if player.Team ~= game.Players.LocalPlayer.Team then
                -- Check if the player is alive (they must have a Humanoid and it must not be dead)
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local targetPos = player.Character.Head.Position
                    local distance = (targetPos - game.Workspace.CurrentCamera.CFrame.Position).Magnitude

                    if distance < shortestDistance then
                        shortestDistance = distance
                        nearestPlayer = player
                    end
                end
            end
        end
    end
    return nearestPlayer
end

-- Teleport Above Enemy and Camera Look Down
local teleportConnection
ExploitTab:CreateToggle("Teleport Above Enemy", function(arg)
    if arg then
        -- Start teleporting every 0.1 seconds
        teleportConnection = game:GetService("RunService").Heartbeat:Connect(function()
            local nearestEnemy = GetNearestEnemy()
            if nearestEnemy and nearestEnemy.Character then
                local enemyHead = nearestEnemy.Character:FindFirstChild("Head")
                if enemyHead then
                    -- Calculate the position above the enemy's head
                    local aboveHeadPos = enemyHead.Position + Vector3.new(0, 10, 0) -- Adjust the 10 value to set how high above the enemy
                    game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(aboveHeadPos))

                    -- Set camera to look down on the enemy
                    game.Workspace.CurrentCamera.CFrame = CFrame.new(aboveHeadPos + Vector3.new(0, -10, 0), enemyHead.Position)
                end
            else
                -- If the nearest enemy is dead or no valid enemy is found, teleport to another enemy
                print("Nearest enemy is dead or not valid, finding another one.")
                local anotherEnemy = GetNearestEnemy()
                if anotherEnemy and anotherEnemy.Character then
                    local enemyHead = anotherEnemy.Character:FindFirstChild("Head")
                    if enemyHead then
                        -- Calculate the position above the new enemy's head
                        local aboveHeadPos = enemyHead.Position + Vector3.new(0, 10, 0) -- Adjust the 10 value to set how high above the enemy
                        game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(aboveHeadPos))

                        -- Set camera to look down on the enemy
                        game.Workspace.CurrentCamera.CFrame = CFrame.new(aboveHeadPos + Vector3.new(0, -10, 0), enemyHead.Position)
                    end
                end
            end
        end)
    else
        -- Stop teleporting when toggle is off
        if teleportConnection then
            teleportConnection:Disconnect()
            teleportConnection = nil
        end
    end
end)


-- Create a toggle for "Super Small"
ExploitTab:CreateToggle("Super Small", function(arg)
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if arg then
        print("Super Small is now: Enabled")

        -- Find the player's model in Workspace by name
        local playerModel = workspace:FindFirstChild(LocalPlayer.Name)

        if playerModel then
            -- Resize all parts in the model to a very small size
            for _, part in pairs(playerModel:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Size = part.Size / 10  -- Make the body parts 1/10th of their original size
                    part.Position = part.Position + Vector3.new(0, 5, 0)  -- Adjust position to not clip with the ground
                end
            end
        end
    else
        print("Super Small is now: Disabled")

        -- Restore the player's original size
        if character then
            local playerModel = workspace:FindFirstChild(LocalPlayer.Name)
            if playerModel then
                for _, part in pairs(playerModel:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Size = part.Size * 10  -- Restore size back to normal
                        part.Position = part.Position - Vector3.new(0, 5, 0)  -- Adjust position back
                    end
                end
            end
        end
    end
end)


-- Spinbot Speed Slider in Exploit Tab
ExploitTab:CreateSlider("Spinbot Speed", 1, 100, function(arg)
    _G.SpinbotSpeed = arg
    print("Spinbot speed set to:", _G.SpinbotSpeed)
end)

-- Spinbot Toggle
ExploitTab:CreateToggle("Enable Spinbot", function(arg)
    _G.SpinbotEnabled = arg
    if _G.SpinbotEnabled then
        print("Spinbot is now: Enabled")
    else
        print("Spinbot is now: Disabled")
    end
end)

-- Function to make the character spin
local function ApplySpinbot()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        while _G.SpinbotEnabled do
            -- Apply a constant rotation to the HumanoidRootPart
            character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(_G.SpinbotSpeed), 0)
            wait(0.05) -- Small delay to prevent the loop from running too fast
        end
    end
end

-- Run Spinbot logic when enabled
game:GetService("RunService").RenderStepped:Connect(function()
    if _G.SpinbotEnabled then
        -- Start spinning the character (while camera stays normal)
        ApplySpinbot()
    end
end)



-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Drawing = Drawing -- Using Drawing API for ESP

-- ESP Toggle
_G.DistanceESPEnabled = false
local DistanceTexts = {}

-- Function to check if a player is an enemy
local function IsEnemy(player)
    return player ~= LocalPlayer and (not LocalPlayer.Team or player.Team ~= LocalPlayer.Team)
end

-- Function to create a distance text for a player
local function CreateDistanceText(player)
    if DistanceTexts[player] then return end -- Prevent duplicate texts

    local text = Drawing.new("Text")
    text.Color = Color3.new(1, 1, 1) -- White
    text.Size = 16
    text.Center = true
    text.Outline = true
    text.Visible = false

    DistanceTexts[player] = text
end

-- Function to remove distance text when player leaves
local function RemoveDistanceText(player)
    if DistanceTexts[player] then
        DistanceTexts[player]:Remove()
        DistanceTexts[player] = nil
    end
end

-- Function to update distance ESP
local function UpdateDistanceESP()
    if not _G.DistanceESPEnabled then
        for _, text in pairs(DistanceTexts) do
            text.Visible = false
        end
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and IsEnemy(player) then
            local rootPart = player.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

            if onScreen then
                local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude) or 0
                local textData = DistanceTexts[player]
                if not textData then
                    CreateDistanceText(player)
                    textData = DistanceTexts[player]
                end

                textData.Position = Vector2.new(screenPos.X, screenPos.Y + 15)
                textData.Text = string.format("%.1fM", distance)
                textData.Visible = true
            else
                if DistanceTexts[player] then
                    DistanceTexts[player].Visible = false
                end
            end
        elseif DistanceTexts[player] then
            DistanceTexts[player].Visible = false
        end
    end
end

-- Toggle for Distance ESP
ESPTab:CreateToggle("Distance ESP", function(state)
    _G.DistanceESPEnabled = state
end)

-- Remove distance text when player leaves
Players.PlayerRemoving:Connect(RemoveDistanceText)

-- Update distance ESP every frame
RunService.RenderStepped:Connect(UpdateDistanceESP)




local player = game.Players.LocalPlayer
local spectatingPlayer = nil
local spectating = false

-- Function to switch to spectate a specific player
local function SpectatePlayer(targetPlayer)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
        -- Set the camera's subject to the selected player's humanoid (their viewpoint)
        game.Workspace.CurrentCamera.CameraSubject = targetPlayer.Character.Humanoid
        -- Change CameraType to Custom, which allows full control over the camera (left, right, up, down)
        game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        -- Optionally, adjust the camera's field of view if needed
        game.Workspace.CurrentCamera.FieldOfView = 70  -- Default FOV, you can change this
    end
end

-- Function to switch to the next player to spectate
local function CycleSpectate()
    local players = game.Players:GetPlayers()
    local playerIndex = nil

    -- Find the current player in the players list
    for i, p in ipairs(players) do
        if p == spectatingPlayer then
            playerIndex = i
            break
        end
    end

    -- If no player is spectated or this is the last player, spectate the first player
    if playerIndex == nil or playerIndex == #players then
        spectatingPlayer = players[1]
    else
        spectatingPlayer = players[playerIndex + 1]
    end

    -- Spectate the selected player
    SpectatePlayer(spectatingPlayer)
end

-- Function to check if the spectated player has died
local function CheckForDeath()
    if spectatingPlayer and spectatingPlayer.Character then
        local humanoid = spectatingPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health <= 0 then
            -- Switch to another player if the current player is dead
            print(spectatingPlayer.Name .. " died. Switching spectate to another player.")
            CycleSpectate()
        end
    end
end

-- Toggle for enabling/disabling the spectate mode
ESPTab:CreateToggle("Enable Spectate Mode", function(state)
    spectating = state
    if spectating then
        -- If spectating, make sure to switch the camera to the selected player
        if spectatingPlayer then
            SpectatePlayer(spectatingPlayer)
        end
    else
        -- Stop spectating and return the camera to the player's own humanoid
        game.Workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
        game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end
end)

-- Button to cycle through and spectate the next player
ESPTab:CreateButton("Cycle Spectate", function()
    CycleSpectate()
end)

-- Monitor the player's health and auto-switch when they die
game:GetService("RunService").RenderStepped:Connect(function()
    if spectating and spectatingPlayer then
        CheckForDeath()
    end
end)



local player = game.Players.LocalPlayer
local teleportButton = ESPTab:CreateButton("Teleport All Players (Except You)", function()
    -- Loop through all players in the game
    for _, targetPlayer in ipairs(game.Players:GetPlayers()) do
        -- Make sure it's not the local player (you)
        if targetPlayer ~= player then
            local targetCharacter = targetPlayer.Character
            if targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart") then
                -- Generate a random position within the workspace
                local randomPosition = Vector3.new(
                    math.random(-100, 100),  -- Random X value
                    50,                      -- Y value (height above ground, adjust as needed)
                    math.random(-100, 100)   -- Random Z value
                )
                
                -- Teleport the player to the random position
                targetCharacter:SetPrimaryPartCFrame(CFrame.new(randomPosition))
            end
        end
    end
end)

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Drawing = Drawing -- Using Drawing API for the FOV circle

-- Local Player
local LocalPlayer = Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera

-- Rotation Settings
_G.RotationAngle = 0 -- Default rotation angle (in degrees)
_G.RotationEnabled = false -- Default: rotation is disabled

-- ExploitTab Toggle for enabling/disabling rotation
ExploitTab:CreateToggle("Enable Character Rotation", function(value)
    _G.RotationEnabled = value
    print("Character Rotation Enabled: ", value)
end)

-- ExploitTab Slider for rotating character
ExploitTab:CreateSlider("Character Rotation", -180, 180, function(value)
    _G.RotationAngle = value
    print("Character rotation set to:", value)
end)

-- Function to rotate the character based on the slider value
local function RotateCharacter()
    if _G.RotationEnabled then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            -- Apply rotation to the HumanoidRootPart (the main part controlling orientation)
            local rootPart = character.HumanoidRootPart
            -- Convert degrees to radians for CFrame rotation
            local angleInRadians = math.rad(_G.RotationAngle)
            -- Create a new CFrame that applies the rotation around the Y-axis (vertical axis)
            local rotatedCFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, angleInRadians, 0)
            -- Update the HumanoidRootPart CFrame to rotate the character
            rootPart.CFrame = rotatedCFrame
        end
    end
end

-- Update the character rotation every frame
RunService.RenderStepped:Connect(function()
    -- Call RotateCharacter to apply the current rotation angle to the character if enabled
    RotateCharacter()
end)
-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Drawing = Drawing -- Using Drawing API for the FOV circle

-- Local Player
local LocalPlayer = Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera





-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Local Player
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Fake Lag Settings
local forwardTeleportDistance = 10 -- Distance to teleport forward when pressing W (or any movement key)
local backwardTeleportDistance = 5 -- Distance to teleport back to simulate lag
local cooldownTime = 5 -- Cooldown time before the fake lag can occur again (in seconds)
local teleportInterval = 0.1 -- Interval between teleports when W is held (in seconds)

-- Variables for timing and cooldown tracking
local lastTriggered = 0 -- Time of the last fake lag trigger
local isCoolingDown = false -- Whether the cooldown is active
local isTeleporting = false -- Whether teleportation is active

-- Function to move player with fake lag (forward and backward teleportation)
local function FakeLagMove()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) and not isCoolingDown then
        local currentTime = tick()

        -- Trigger teleportation every 0.1 seconds when W is held
        if not isTeleporting then
            isTeleporting = true
            spawn(function()
                while UserInputService:IsKeyDown(Enum.KeyCode.W) and not isCoolingDown do
                    local direction = HumanoidRootPart.CFrame.LookVector * forwardTeleportDistance
                    HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + direction

                    wait(teleportInterval)

                    -- Simulate lag by teleporting backward
                    direction = HumanoidRootPart.CFrame.LookVector * -backwardTeleportDistance
                    HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + direction

                    wait(teleportInterval)
                end
                isTeleporting = false
            end)
        end
    end
end

-- Function to trigger cooldown after teleporting
local function StartCooldown()
    isCoolingDown = true
    wait(cooldownTime) -- Wait for cooldown duration
    isCoolingDown = false
end

-- Function to enable fake lag (teleport movement)
ExploitTab:CreateToggle("Enable Fake Lag", function(state)
    if state then
        -- Enable the fake lag effect
        RunService.RenderStepped:Connect(function()
            if not isCoolingDown then
                FakeLagMove() -- Teleport the player on each frame if "W" is pressed and cooldown allows
            end
        end)
        print("Fake Lag Enabled")
    else
        -- Disable the fake lag effect
        isCoolingDown = false
        print("Fake Lag Disabled")
    end
end)

-- Detect when the W key is released to trigger cooldown
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.W then
        -- Start cooldown when W is released
        StartCooldown()
    end
end)

-- Anti-Aim Variables
_G.AntiAimEnabled = false
_G.AntiAimIntensity = 30 -- Default jitter intensity

-- Function to Randomize Character Rotation
local function AntiAimLoop()
    while _G.AntiAimEnabled do
        local Character = game.Players.LocalPlayer.Character
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            local RandomRotation = math.random(-_G.AntiAimIntensity, _G.AntiaAimIntensity)
            Character.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(RandomRotation), 0)
        end
        wait(0.1) -- Adjust frequency of jitter
    end
end

-- Toggle for Anti-Aim
ExploitTab:CreateToggle("Enable Anti-Aim", function(state)
    _G.AntiAimEnabled = state
    if state then
        spawn(AntiAimLoop) -- Start Anti-Aim when enabled
    end
end)

-- Slider for Jitter Intensity
ExploitTab:CreateSlider("Anti-Aim Intensity", 10, 90, function(value)
    _G.AntiAimIntensity = value
end)


-- Services
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Function to stop the player from leaving
local function BlockLeave(state)
    if state then
        -- Prevent player from leaving when they try
        game.Players.PlayerRemoving:Connect(function(player)
            if player == LocalPlayer then
                -- Block player from leaving by teleporting them back
                print("Player is trying to leave the game, preventing it.")
                game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
            end
        end)

        -- Block the "X" button (close window button) by intercepting gamepad and keyboard input
        local function blockCloseWindow()
            local userInputService = game:GetService("UserInputService")
            userInputService.InputBegan:Connect(function(input, processed)
                if input.KeyCode == Enum.KeyCode.Escape then
                    -- Prevent Escape from closing the game window
                    print("Escape key pressed, preventing window closure.")
                end
            end)

            -- Block Gamepad close attempt
            GuiService.GamepadInputBegan:Connect(function(input, gameProcessed)
                if input.KeyCode == Enum.KeyCode.ButtonB then
                    print("Gamepad close attempt blocked.")
                    return Enum.ContextActionResult.Sink -- Block close action
                end
            end)
        end
        blockCloseWindow()

        -- Monitor the player GUI for the leave button and prevent it from working
        PlayerGui.ChildAdded:Connect(function(child)
            if child.Name == "PlayerStatus" then
                local playerStatus = child:FindFirstChild("PlayerLeave")
                if playerStatus then
                    playerStatus.MouseButton1Click:Connect(function()
                        -- Prevent leave button click
                        print("Leave button clicked, but the action is being prevented.")
                    end)
                end
            end
        end)
    else
        print("Block Leave Disabled, Player can leave freely.")
    end
end




-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Drawing = Drawing -- Using Drawing API for ESP

-- ESP Toggle
_G.HealthESPEnabled = false
local HealthBars = {}

-- Function to check if a player is an enemy
local function IsEnemy(player)
    return player ~= LocalPlayer and (not LocalPlayer.Team or player.Team ~= LocalPlayer.Team)
end

-- Function to create a health bar for a player
local function CreateHealthBar(player)
    if HealthBars[player] then return end -- Prevent duplicate bars

    -- Background (Black)
    local bar = Drawing.new("Square")
    bar.Color = Color3.new(0, 0, 0) -- Black
    bar.Filled = true
    bar.Thickness = 1
    bar.Transparency = 1
    bar.Visible = false

    -- Health Fill (Dynamic Color)
    local healthFill = Drawing.new("Square")
    healthFill.Filled = true
    healthFill.Thickness = 1
    healthFill.Transparency = 1
    healthFill.Visible = false

    HealthBars[player] = {bar, healthFill}
end

-- Function to remove health bar when player leaves
local function RemoveHealthBar(player)
    if HealthBars[player] then
        for _, obj in pairs(HealthBars[player]) do
            obj:Remove()
        end
        HealthBars[player] = nil
    end
end

-- Function to update health bars
local function UpdateHealthESP()
    if not _G.HealthESPEnabled then
        for _, bar in pairs(HealthBars) do
            bar[1].Visible = false
            bar[2].Visible = false
        end
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not IsEnemy(player) then continue end -- Team Check

            local rootPart = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head")
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

            if not head or not humanoid then continue end

            local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
            local footPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))

            if onScreen then
                local barData = HealthBars[player]
                if not barData then
                    CreateHealthBar(player)
                    barData = HealthBars[player]
                end

                local boxHeight = math.abs(headPos.Y - footPos.Y)
                local boxWidth = boxHeight / 2

                local barWidth = 6  -- Fixed width for health bar
                local xOffset = -10 -- Moves the bar slightly left of the box

                -- Background Bar (Black, full height)
                local bar = barData[1]
                bar.Size = Vector2.new(barWidth, boxHeight)
                bar.Position = Vector2.new(screenPos.X - boxWidth / 2 + xOffset, screenPos.Y - boxHeight / 2)
                bar.Visible = true

                -- Health Fill (Changes based on HP)
                local healthFill = barData[2]
                local healthRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)

                healthFill.Size = Vector2.new(barWidth - 2, boxHeight * healthRatio)
                healthFill.Position = Vector2.new(bar.Position.X + 1, bar.Position.Y + (boxHeight * (1 - healthRatio)))

                -- Color changes based on health
                if healthRatio > 0.6 then
                    healthFill.Color = Color3.new(0, 1, 0) -- Green
                elseif healthRatio > 0.3 then
                    healthFill.Color = Color3.new(1, 1, 0) -- Yellow
                else
                    healthFill.Color = Color3.new(1, 0, 0) -- Red
                end

                healthFill.Visible = true
            else
                if HealthBars[player] then
                    HealthBars[player][1].Visible = false
                    HealthBars[player][2].Visible = false
                end
            end
        elseif HealthBars[player] then
            HealthBars[player][1].Visible = false
            HealthBars[player][2].Visible = false
        end
    end
end

-- Toggle for Health ESP
ESPTab:CreateToggle("Health ESP", function(state)
    _G.HealthESPEnabled = state

    if _G.HealthESPEnabled then
        print("Health ESP is now: Enabled")
    else
        print("Health ESP is now: Disabled")
    end
end)

-- Remove health bar when player leaves
Players.PlayerRemoving:Connect(RemoveHealthBar)

-- Update health ESP every frame
RunService.RenderStepped:Connect(UpdateHealthESP)



-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Drawing = Drawing -- Using Drawing API for ESP

-- ESP Toggle
_G.Box3DESPEnabled = false
local Box3D = {}

-- Function to check if a player is an enemy
local function IsEnemy(player)
    return player ~= LocalPlayer and (not LocalPlayer.Team or player.Team ~= LocalPlayer.Team)
end

-- Function to create a 3D box for a player
local function Create3DBox(player)
    if Box3D[player] then return end -- Prevent duplicate boxes
    
    local lines = {}
    for i = 1, 12 do
        local line = Drawing.new("Line")
        line.Color = Color3.new(1, 1, 1) -- White
        line.Thickness = 1
        line.Transparency = 1
        line.Visible = false
        table.insert(lines, line)
    end
    Box3D[player] = lines
end

-- Function to remove 3D box when player leaves
local function Remove3DBox(player)
    if Box3D[player] then
        for _, line in pairs(Box3D[player]) do
            line:Remove()
        end
        Box3D[player] = nil
    end
end

-- Function to update 3D box ESP
local function Update3DBoxESP()
    if not _G.Box3DESPEnabled then
        for _, box in pairs(Box3D) do
            for _, line in pairs(box) do
                line.Visible = false
            end
        end
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not IsEnemy(player) then continue end
            
            local rootPart = player.Character.HumanoidRootPart
            local size = Vector3.new(4, 6, 4) -- Box size around character
            local corners = {
                rootPart.Position + Vector3.new(size.X, size.Y, size.Z) / 2,
                rootPart.Position + Vector3.new(size.X, size.Y, -size.Z) / 2,
                rootPart.Position + Vector3.new(-size.X, size.Y, -size.Z) / 2,
                rootPart.Position + Vector3.new(-size.X, size.Y, size.Z) / 2,
                rootPart.Position + Vector3.new(size.X, -size.Y, size.Z) / 2,
                rootPart.Position + Vector3.new(size.X, -size.Y, -size.Z) / 2,
                rootPart.Position + Vector3.new(-size.X, -size.Y, -size.Z) / 2,
                rootPart.Position + Vector3.new(-size.X, -size.Y, size.Z) / 2
            }
            
            local screenCorners = {}
            local onScreen = false
            
            for i, corner in ipairs(corners) do
                local screenPos, vis = Camera:WorldToViewportPoint(corner)
                screenCorners[i] = screenPos
                if vis then onScreen = true end
            end
            
            if onScreen then
                local boxData = Box3D[player]
                if not boxData then
                    Create3DBox(player)
                    boxData = Box3D[player]
                end
                
                local connections = {
                    {1, 2}, {2, 3}, {3, 4}, {4, 1}, -- Top Square
                    {5, 6}, {6, 7}, {7, 8}, {8, 5}, -- Bottom Square
                    {1, 5}, {2, 6}, {3, 7}, {4, 8}  -- Vertical Lines
                }
                
                for i, connection in ipairs(connections) do
                    local startPos = screenCorners[connection[1]]
                    local endPos = screenCorners[connection[2]]
                    boxData[i].From = Vector2.new(startPos.X, startPos.Y)
                    boxData[i].To = Vector2.new(endPos.X, endPos.Y)
                    boxData[i].Visible = true
                end
            else
                for _, line in pairs(Box3D[player]) do
                    line.Visible = false
                end
            end
        elseif Box3D[player] then
            for _, line in pairs(Box3D[player]) do
                line.Visible = false
            end
        end
    end
end

-- Toggle for 3D Box ESP
ESPTab:CreateToggle("3D Box ESP", function(state)
    _G.Box3DESPEnabled = state
end)

-- Remove 3D box when player leaves
Players.PlayerRemoving:Connect(Remove3DBox)

-- Update 3D Box ESP every frame
RunService.RenderStepped:Connect(Update3DBoxESP)



-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Aim Assist Settings
_G.AimAssistEnabled = false
_G.RightClickHeld = false

-- Function to check if a player is an enemy
local function IsEnemy(player)
    return player ~= LocalPlayer and (not LocalPlayer.Team or player.Team ~= LocalPlayer.Team)
end

-- Get the closest enemy to the mouse
local function GetClosestEnemy()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Head") and IsEnemy(player) then
            local head = player.Character.Head
            local headScreenPos, onScreen = Camera:WorldToViewportPoint(head.Position)

            if onScreen then
                local distance = (Vector2.new(headScreenPos.X, headScreenPos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

-- Right Click Detection
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        _G.RightClickHeld = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        _G.RightClickHeld = false
    end
end)

-- Aim Assist Logic (Subtle Nudge)
RunService.RenderStepped:Connect(function()
    if _G.AimAssistEnabled and _G.RightClickHeld then
        local targetPlayer = GetClosestEnemy()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
            local head = targetPlayer.Character.Head
            local headScreenPos, onScreen = Camera:WorldToViewportPoint(head.Position)

            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local targetPos = Vector2.new(headScreenPos.X, headScreenPos.Y)

                -- Subtle Aim Assist (very weak nudge)
                local moveX = (targetPos.X - mousePos.X) * 0.02 -- Adjust strength (lower = weaker)
                local moveY = (targetPos.Y - mousePos.Y) * 0.02
                mousemoverel(moveX, moveY)
            end
        end
    end
end)

-- Toggle for Aim Assist
AimbotTab:CreateToggle("Enable Aim Assist", function(state)
    _G.AimAssistEnabled = state
end)


-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Drawing = Drawing -- Using Drawing API

-- Snapline Settings
_G.SnaplinesEnabled = false
local Snaplines = {}

-- Function to check if a player is an enemy
local function IsEnemy(player)
    return player ~= LocalPlayer and (not LocalPlayer.Team or player.Team ~= LocalPlayer.Team)
end

-- Function to create a Snapline for a player
local function CreateSnapline(player)
    if not Snaplines[player] then
        Snaplines[player] = Drawing.new("Line")
        Snaplines[player].Color = Color3.fromRGB(255, 0, 0)
        Snaplines[player].Thickness = 1.5
        Snaplines[player].Transparency = 1
        Snaplines[player].Visible = false
    end
end

-- Function to remove Snapline when a player leaves
local function RemoveSnapline(player)
    if Snaplines[player] then
        Snaplines[player]:Remove()
        Snaplines[player] = nil
    end
end

-- Function to update Snaplines
local function UpdateSnaplines()
    if not _G.SnaplinesEnabled then
        for _, line in pairs(Snaplines) do
            line.Visible = false
        end
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsEnemy(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            CreateSnapline(player)

            local rootPart = player.Character.HumanoidRootPart
            local rootScreenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

            if onScreen then
                local line = Snaplines[player]
                line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) -- Bottom center of screen
                line.To = Vector2.new(rootScreenPos.X, rootScreenPos.Y)
                line.Visible = true
            else
                Snaplines[player].Visible = false
            end
        elseif Snaplines[player] then
            Snaplines[player].Visible = false
        end
    end
end

-- Update Snaplines every frame
RunService.RenderStepped:Connect(UpdateSnaplines)

-- Remove Snaplines when players leave
Players.PlayerRemoving:Connect(RemoveSnapline)

-- Toggle for Snaplines
ESPTab:CreateToggle("Enable Snaplines", function(state)
    _G.SnaplinesEnabled = state
end)


-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Drawing = Drawing -- Using Drawing API for ESP

-- Friend ESP Toggle
_G.FriendESPEnabled = false
local FriendESP = {}

-- Function to check if a player is a friend
local function IsFriend(player)
    return player:IsFriendsWith(LocalPlayer.UserId)
end

-- Function to create Friend ESP
local function CreateFriendESP(player)
    if FriendESP[player] then return end -- Prevent duplicates

    local text = Drawing.new("Text")
    text.Color = Color3.fromRGB(0, 0, 255) -- Blue color
    text.Size = 15
    text.Outline = true
    text.Center = true
    text.Visible = false

    FriendESP[player] = text
end

-- Function to remove ESP when a player leaves
local function RemoveFriendESP(player)
    if FriendESP[player] then
        FriendESP[player]:Remove()
        FriendESP[player] = nil
    end
end

-- Function to update Friend ESP
local function UpdateFriendESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if not IsFriend(player) then continue end -- Check if the player is a friend

            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)

            if _G.FriendESPEnabled and onScreen then
                local friendText = FriendESP[player]
                if not friendText then
                    CreateFriendESP(player)
                    friendText = FriendESP[player]
                end

                friendText.Position = Vector2.new(screenPos.X, screenPos.Y + 20) -- Position below Distance ESP
                friendText.Text = "Friend"
                friendText.Visible = true
            elseif FriendESP[player] then
                FriendESP[player].Visible = false
            end
        else
            if FriendESP[player] then
                FriendESP[player].Visible = false
            end
        end
    end
end

-- Toggle for Friend ESP
ESPTab:CreateToggle("Friend Check Esp", function(state)
    _G.FriendESPEnabled = state
end)

-- Remove ESP when player leaves
Players.PlayerRemoving:Connect(RemoveFriendESP)

-- Update ESP every frame
RunService.RenderStepped:Connect(UpdateFriendESP)



-- Create the Toggle in ExploitTab
ExploitTab:CreateToggle("Bypass Kick(stopable)", function(state)
    BlockLeave(state)  -- Call BlockLeave function with the toggle state
end)


-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Function to delete a player model
local function DeletePlayerModel(player)
    if player.Character then
        -- Delete all parts in the player's character
        for _, part in pairs(player.Character:GetChildren()) do
            if part:IsA("BasePart") or part:IsA("Accessory") then
                part:Destroy()
            end
        end
        -- Optionally remove humanoid, so player can't move
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:Destroy()  -- Remove humanoid to stop movement
        end
    end
end

-- Function to kick the player
local function KickPlayer(player)
    -- Kicks the player with a message
    player:Kick("You have been kicked from the game.")
end

-- Function to check if the player is still valid (alive, has character, etc.)
local function IsPlayerValid(player)
    return player.Character and player.Character:FindFirstChild("Humanoid")
end

-- Function to delete every player's model and kick them
local function DeleteAndKickPlayers(state)
    if state then
        -- Delete all player models except for LocalPlayer
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                -- Delete their character models
                DeletePlayerModel(player)
                -- Kick the player out of the game
                KickPlayer(player)
            end
        end
        print("All players have been deleted and kicked.")
    else
        print("Delete and kick players is turned off.")
    end
end

-- Create a Toggle to delete and kick players in the ExploitTab
ExploitTab:CreateToggle("Delete & Kick All Players", function(state)
    DeleteAndKickPlayers(state)  -- Call function with toggle state
end)

-- Optional: Continuously check to prevent any new player models from reappearing (optional safeguard)
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if ExploitTab:GetToggle("Delete & Kick All Players") then
            -- Immediately delete and kick the new player
            DeletePlayerModel(player)
            KickPlayer(player)
        end
    end)
end)
