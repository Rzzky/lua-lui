-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Local Variables
local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local oldCFrame = hrp.CFrame
local leaderstats = lp:FindFirstChild("leaderstats")
local shecklesStat = leaderstats and leaderstats:FindFirstChild("Sheckles")
local seedRemote = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuySeedStock")
local gearRemote = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyGearStock")
local easterRemote = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyEasterStock")
local seedPath = lp.PlayerGui.Seed_Shop.Frame.ScrollingFrame
local gearPath = lp.PlayerGui.Gear_Shop.Frame.ScrollingFrame
local gearicon = Players.LocalPlayer.PlayerGui.Teleport_UI.Frame.Gear
local dmRemote = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyEventShopStock")
local bmPath = lp.PlayerGui.EventShop_UI.Frame.ScrollingFrame
local seedItems = {"Carrot","Strawberry","Blueberry","Orange Tulip","Tomato","Corn","Daffodil","Watermelon","Pumpkin","Apple","Bamboo","Coconut","Cactus","Dragon Fruit","Mango","Grape","Mushroom","Pepper","Cacao","Beanstalk"}
local gearItems = {"Watering Can","Trowel","Recall Wrench","Basic Sprinkler","Advanced Sprinkler","Godly Sprinkler","Lightning Rod","Master Sprinkler","Favorite Tool"}
local autoBuyEnabled = false
local autoBuyEnabledE = false
local selectedSeeds, selectedGears = {}, {}
local farms = {}
local plants = {}
local mutationOptions = {"Wet","Gold","Frozen","Rainbow","Choc","Chilled","Shocked","Moonlit","Bloodlit","Celestial"}
local selectedMutations = {"Gold","Frozen","Rainbow","Choc","Chilled","Shocked","Moonlit","Bloodlit","Celestial"}
local seedNames = {"Apple","Banana","Bamboo","Blueberry","Candy Blossom","Candy Sunflower","Carrot","Cactus","Chocolate Carrot","Chocolate Sprinkler","Coconut","Corn","Cranberry","Cucumber","Cursed Fruit","Candy Blossom","Daffodil","Dragon Fruit","Durian","Easter Egg","Eggplant","Grape","Lemon","Lotus","Mango","Mushroom","Pepper","Orange Tulip","Papaya","Passionfruit","Peach","Pear","Pineapple","Pumpkin","Raspberry","Red Lollipop","Soul Fruit","Strawberry","Tomato","Venus Fly Trap","Watermelon","Cacao","Beanstalk"}
local dmRemote = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyEventShopStock")
local bmPath = lp.PlayerGui.EventShop_UI.Frame.ScrollingFrame
local bmItems = {"Mysterious Crate","Night Egg","Night Seed Pack","Blood Banana","Moon Melon","Star Caller","Blood Hedgehog","Blood Kiwi","Blood Owl"}
local selectedSeeds, selectedGears, selectedBMItems = {}, {}, {}

gearicon.Active = true
gearicon.Visible = true
gearicon.ImageColor3 = Color3.fromRGB(255, 255, 255)

lp.PlayerGui.Hud_UI.SideBtns.Spin.Visible = true
lp.PlayerGui.Hud_UI.SideBtns.StarterPack.Visible = true
lp.PlayerGui.Teleport_UI.Frame.Pets.Visible = true

-- Utility Functions
local function parseMoney(moneyStr)
    if not moneyStr then return 0 end
    moneyStr = tostring(moneyStr):gsub("Ã‚Â¢", ""):gsub(",", ""):gsub(" ", ""):gsub("%$", "")
    local multiplier = 1
    if moneyStr:lower():find("k") then
        multiplier = 1000
        moneyStr = moneyStr:lower():gsub("k", "")
    elseif moneyStr:lower():find("m") then
        multiplier = 1000000
        moneyStr = moneyStr:lower():gsub("m", "")
    end
    return (tonumber(moneyStr) or 0) * multiplier
end

local function getPlayerMoney()
    return parseMoney((shecklesStat and shecklesStat.Value) or 0)
end

local function isInventoryFull()
    return #lp.Backpack:GetChildren() >= 200
end

-- Auto Farm Functions
local autoFarmEnabled = false
local farmThread

local function updateFarmData()
    farms = {}
    plants = {}
    for _, farm in pairs(workspace:FindFirstChild("Farm"):GetChildren()) do
        local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
        if data and data:FindFirstChild("Owner") and data.Owner.Value == lp.Name then
            table.insert(farms, farm)
            local plantsFolder = farm.Important:FindFirstChild("Plants_Physical")
            if plantsFolder then
                for _, plantModel in pairs(plantsFolder:GetChildren()) do
                    for _, part in pairs(plantModel:GetDescendants()) do
                        if part:IsA("BasePart") and part:FindFirstChildOfClass("ProximityPrompt") then
                            table.insert(plants, part)
                            break
                        end
                    end
                end
            end
        end
    end
end

local function glitchTeleport(pos)
    if not lp.Character then return end
    local root = lp.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local tween = TweenService:Create(root, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {CFrame=CFrame.new(pos + Vector3.new(0, 5, 0))})
    tween:Play()
end

local function instantFarm()
    if farmThread then task.cancel(farmThread) end
    farmThread = task.spawn(function()
        while autoFarmEnabled do
            while isInventoryFull() do
                if not autoFarmEnabled then return end
                task.wait(1)
            end
            if not autoFarmEnabled then return end
            updateFarmData()
            for _, part in pairs(plants) do
                if not autoFarmEnabled then return end
                if isInventoryFull() then break end
                if part and part.Parent then
                    local prompt = part:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then
                        glitchTeleport(part.Position)
                        task.wait(0.2)
                        for _, farm in pairs(farms) do
                            if not autoFarmEnabled or isInventoryFull() then break end
                            for _, obj in pairs(farm:GetDescendants()) do
                                if obj:IsA("ProximityPrompt") then
                                    local str = tostring(obj.Parent)
                                    if not (str:find("Grow_Sign") or str:find("Core_Part")) then
                                        fireproximityprompt(obj, 1)
                                    end
                                end
                            end
                        end
                        if not autoFarmEnabled then return end
                        task.wait(0.2)
                    end
                end
            end
            if autoFarmEnabled then task.wait(0.1) end
        end
    end)
end

-- Auto Collect Functions
local fastClickEnabled = false
local fastClickThread
local CLICK_DELAY = 0.00000001
local MAX_DISTANCE = 50

local function isValidPrompt(prompt)
    local parent = prompt.Parent
    if not parent then return false end
    local name = parent.Name:lower()
    return not (name:find("sign") or name:find("core"))
end

local function getNearbyPrompts()
    local nearby = {}
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nearby end

    for _, farm in pairs(workspace.Farm:GetChildren()) do
        local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
        if data and data:FindFirstChild("Owner") and data.Owner.Value == lp.Name then
            for _, obj in pairs(farm:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and isValidPrompt(obj) then
                    local part = obj.Parent
                    if part:IsA("BasePart") then
                        local dist = (hrp.Position - part.Position).Magnitude
                        if dist <= MAX_DISTANCE then
                            table.insert(nearby, obj)
                        end
                    end
                end
            end
        end
    end
    return nearby
end

local function fastClickFarm()
    if fastClickThread then task.cancel(fastClickThread) end
    fastClickThread = task.spawn(function()
        while fastClickEnabled do
            if isInventoryFull() then
                task.wait(1)
                continue
            end
            local prompts = getNearbyPrompts()
            for _, prompt in pairs(prompts) do
                if not fastClickEnabled then return end
                if isInventoryFull() then break end
                fireproximityprompt(prompt, 1)
                task.wait(CLICK_DELAY)
            end
            task.wait(0.1)
        end
    end)
end

-- Auto Sell Functions
local autoSellEnabled = false
local autoSellThread

local function sellItems()
    local steven = workspace.NPCS:FindFirstChild("Steven")
    if not steven then return false end

    local char = lp.Character
    if not char then return false end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local originalPosition = hrp.CFrame
    hrp.CFrame = steven.HumanoidRootPart.CFrame * CFrame.new(0, 3, 3)
    task.wait(0.5)

    for _ = 1, 5 do
        pcall(function()
            ReplicatedStorage.GameEvents.Sell_Inventory:FireServer()
        end)
        task.wait(0.15)
    end

    hrp.CFrame = originalPosition
    return true
end

-- Harvest Functions
local HarvestEnabled = false
local HarvestConnection = nil

local function FindGarden()
    local farm = workspace:FindFirstChild("Farm")
    if not farm then return nil end

    for _, plot in ipairs(farm:GetChildren()) do
        local data = plot:FindFirstChild("Important") and plot.Important:FindFirstChild("Data")
        local owner = data and data:FindFirstChild("Owner")
        if owner and owner.Value == lp.Name then
            return plot
        end
    end
    return nil
end

local function CanHarvest(part)
    local prompt = part:FindFirstChild("ProximityPrompt")
    return prompt and prompt.Enabled
end

local function Harvest()
    if not HarvestEnabled then return end
    if isInventoryFull() then return end

    local garden = FindGarden()
    if not garden then return end

    local plants = garden:FindFirstChild("Important") and garden.Important:FindFirstChild("Plants_Physical")
    if not plants then return end

    for _, plant in ipairs(plants:GetChildren()) do
        if not HarvestEnabled then break end
        local fruits = plant:FindFirstChild("Fruits")
        if fruits then
            for _, fruit in ipairs(fruits:GetChildren()) do
                if not HarvestEnabled then break end
                for _, part in ipairs(fruit:GetChildren()) do
                    if not HarvestEnabled then break end
                    if part:IsA("BasePart") and CanHarvest(part) then
                        local prompt = part.ProximityPrompt
                        local pos = part.Position + Vector3.new(0, 3, 0)
                        if lp.Character and lp.Character.PrimaryPart then
                            lp.Character:SetPrimaryPartCFrame(CFrame.new(pos))
                            task.wait(0.1)
                            if not HarvestEnabled then break end
                            prompt:InputHoldBegin()
                            task.wait(0.1)
                            if not HarvestEnabled then break end
                            prompt:InputHoldEnd()
                            task.wait(0.1)
                        end
                    end
                end
            end
        end
    end
end

local function ToggleHarvest(state)
    if HarvestConnection then
        HarvestConnection:Disconnect()
        HarvestConnection = nil
    end
    HarvestEnabled = state
    if state then
        HarvestConnection = RunService.Heartbeat:Connect(function()
            if HarvestEnabled then
                Harvest()
            else
                HarvestConnection:Disconnect()
                HarvestConnection = nil
            end
        end)
    end
end

-- Movement Functions
local flyEnabled = false
local flySpeed = 48
local bodyVelocity, bodyGyro
local flightConnection

local function Fly(state)
    flyEnabled = state
    if flyEnabled then
        local character = lp.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        bodyGyro = Instance.new("BodyGyro")
        bodyVelocity = Instance.new("BodyVelocity")
        bodyGyro.P = 9000
        bodyGyro.maxTorque = Vector3.new(8999999488, 8999999488, 8999999488)
        bodyGyro.cframe = character.HumanoidRootPart.CFrame
        bodyGyro.Parent = character.HumanoidRootPart

        bodyVelocity.velocity = Vector3.new(0, 0, 0)
        bodyVelocity.maxForce = Vector3.new(8999999488, 8999999488, 8999999488)
        bodyVelocity.Parent = character.HumanoidRootPart
        humanoid.PlatformStand = true

        flightConnection = RunService.Heartbeat:Connect(function()
            if not flyEnabled or not character:FindFirstChild("HumanoidRootPart") then
                if flightConnection then flightConnection:Disconnect() end
                return
            end

            local cam = workspace.CurrentCamera.CFrame
            local moveVec = Vector3.new()

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveVec = moveVec + cam.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveVec = moveVec - cam.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveVec = moveVec - cam.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveVec = moveVec + cam.RightVector
            end

            if moveVec.Magnitude > 0 then
                moveVec = moveVec.Unit * flySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveVec = moveVec + Vector3.new(0, flySpeed, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveVec = moveVec + Vector3.new(0, -flySpeed, 0)
            end

            bodyVelocity.velocity = moveVec
            bodyGyro.cframe = cam
        end)
    else
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end

        local character = lp.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.PlatformStand = false
            end
        end

        if flightConnection then
            flightConnection:Disconnect()
            flightConnection = nil
        end
    end
end

-- NoClip Functions
local noclip = false

RunService.Stepped:Connect(function()
    if noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                part.CanCollide = false
            end
        end
    end
end)

local function ToggleNoclip(state)
    noclip = state
end

-- Infinite Jump Functions
local infJump = false

UserInputService.JumpRequest:Connect(function()
    if infJump and char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local function ToggleInfJump(state)
    infJump = state
end

-- Shop Functions
local function OpenShop()
    local shop = lp.PlayerGui.Seed_Shop
    shop.Enabled = not shop.Enabled
end

local function OpenGearShop()
    local gear = lp.PlayerGui.Gear_Shop
    gear.Enabled = not gear.Enabled
end

local function OpenEaster()
    local easter = lp.PlayerGui.Easter_Shop
    easter.Enabled = not easter.Enabled
end

local function OpenQuest()
    local quest = lp.PlayerGui.DailyQuests_UI
    quest.Enabled = not quest.Enabled
end

local function OpenTravelMer()
    local quest = lp.PlayerGui.TravellingMerchant_Shop
    quest.Enabled = not quest.Enabled
end

local function EggShop1()
    fireproximityprompt(workspace.NPCS["Pet Stand"].EggLocations["Common Egg"].ProximityPrompt)
end

local function EggShop2()
    fireproximityprompt(workspace.NPCS["Pet Stand"].EggLocations:GetChildren()[6].ProximityPrompt)
end

local function EggShop3()
    fireproximityprompt(workspace.NPCS["Pet Stand"].EggLocations:GetChildren()[5].ProximityPrompt)
end

-- Auto Buy Egg
local Autoegg_npc = workspace:WaitForChild("NPCS"):WaitForChild("Pet Stand")
local Autoegg_timer = Autoegg_npc.Timer.SurfaceGui:WaitForChild("ResetTimeLabel")
local Autoegg_eggLocations = Autoegg_npc:WaitForChild("EggLocations")
local Autoegg_events = game:GetService("ReplicatedStorage"):WaitForChild("GameEvents")

local Autoegg_autoBuyEnabled = false
local Autoegg_firstRun = true

local player = game.Players.LocalPlayer
local originalCFrame = player.Character and player.Character:WaitForChild("HumanoidRootPart").CFrame or CFrame.new()
local targetCFrame = CFrame.new(-255.12291, 2.99999976, -1.13749218, -0.0163238496, 1.05261321e-07, 0.999866784, -5.92361182e-09, 1, -1.0537206e-07, -0.999866784, -7.64290053e-09, -0.0163238496)

local function Autoegg_safeFirePrompt(prompt)
    if prompt then
        pcall(function()
            fireproximityprompt(prompt)
        end)
    end
end

local function Autoegg_safeFireServer(id)
    pcall(function()
        Autoegg_events:WaitForChild("BuyPetEgg"):FireServer(id)
    end)
end

local function Autoegg_setAlwaysShow()
    for _, obj in ipairs(Autoegg_eggLocations:GetChildren()) do
        for _, child in ipairs(obj:GetDescendants()) do
            if child:IsA("ProximityPrompt") then
                child.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
            end
        end
    end
end

local function Autoegg_autoBuyEggs()
    if Autoegg_autoBuyEnabled then
        if not Autoegg_firstRun then
            while Autoegg_timer.Text ~= "00:00:00" do
                task.wait(0.1)
            end
            task.wait(3)
        else
            Autoegg_firstRun = false
        end

        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        player.Character.HumanoidRootPart.CFrame = targetCFrame

        Autoegg_setAlwaysShow()

        local commonEggPrompt = Autoegg_eggLocations:FindFirstChild("Common Egg")
        if commonEggPrompt then
            Autoegg_safeFirePrompt(commonEggPrompt:FindFirstChild("ProximityPrompt"))
            task.wait(0.3)
            Autoegg_safeFireServer(1)
        end

        local eggSlot6 = Autoegg_eggLocations:GetChildren()[6]
        if eggSlot6 then
            Autoegg_safeFirePrompt(eggSlot6:FindFirstChild("ProximityPrompt"))
            task.wait(0.3)
            Autoegg_safeFireServer(2)
        end

        local eggSlot5 = Autoegg_eggLocations:GetChildren()[5]
        if eggSlot5 then
            Autoegg_safeFirePrompt(eggSlot5:FindFirstChild("ProximityPrompt"))
            task.wait(0.3)
            Autoegg_safeFireServer(3)
        end

        player.Character.HumanoidRootPart.CFrame = originalCFrame
    end
end

spawn(function()
    while true do
        task.wait(0.5)
        if Autoegg_autoBuyEnabled then
            Autoegg_autoBuyEggs()
        end
    end
end)

-- Sell Functions
local function SellAll()
    local steven = workspace.NPCS:FindFirstChild("Steven")
    if steven then
        hrp.CFrame = steven.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        wait(0.2)
        ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Sell_Inventory"):FireServer()

        local farms = workspace:WaitForChild("Farm"):GetChildren()
        for _, farm in pairs(farms) do
            local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
            if data and data:FindFirstChild("Owner") and data.Owner.Value == lp.Name then
                local spawn = farm:FindFirstChild("Spawn_Point")
                if spawn then
                    hrp.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
                    break
                end
            end
        end
    end
end

local function HSell()
    local steven = workspace.NPCS:FindFirstChild("Steven")
    if steven then
        hrp.CFrame = steven.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        wait(0.2)
        ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Sell_Item"):FireServer()

        local farms = workspace:WaitForChild("Farm"):GetChildren()
        for _, farm in pairs(farms) do
            local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
            if data and data:FindFirstChild("Owner") and data.Owner.Value == lp.Name then
                local spawn = farm:FindFirstChild("Spawn_Point")
                if spawn then
                    hrp.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
                    break
                end
            end
        end
    end
end

local autoMoon = false

local function AutoGiveFruitMoon(State)
    autoMoon = State

    task.spawn(function()
        while autoMoon do
            local player = game:GetService("Players").LocalPlayer
            local backpack = player:FindFirstChild("Backpack")
            local character = player.Character or player.CharacterAdded:Wait()

            if backpack and character then
                for _, tool in pairs(backpack:GetChildren()) do
                    if typeof(tool) == "Instance" and tool:IsA("Tool") and string.find(tool.Name, "%[Moonlit%]") then
                        tool.Parent = character
                        wait(0.5)

                        for i = 1, 10 do
                            game:GetService("ReplicatedStorage").GameEvents.NightQuestRemoteEvent:FireServer("SubmitHeldPlant")
                        end

                        wait(0.5)
                    end
                end
            end

            wait(0.5)
        end
    end)
end

local function OpenBloodShop()
    local Bs = lp.PlayerGui.EventShop_UI
    Bs.Enabled = not Bs.Enabled
end

-- Auto Collect V2 Functions
local spamE = false
local RANGE = 50
local promptTracker = {}
local collectionThread
local descendantConnection

local function modifyPrompt(prompt, show)
    pcall(function()
        prompt.RequiresLineOfSight = not show
        prompt.Exclusivity = show and Enum.ProximityPromptExclusivity.AlwaysShow or Enum.ProximityPromptExclusivity.One
    end)
end

local function isInsideFarm(part)
    for _, farm in pairs(farms) do
        if part:IsDescendantOf(farm) then
            return true
        end
    end
    return false
end

local function handleNewPrompt(prompt)
    if not prompt:IsA("ProximityPrompt") then return end
    if not isInsideFarm(prompt) then return end

    if not promptTracker[prompt] then
        promptTracker[prompt] = {
            originalRequiresLOS = prompt.RequiresLineOfSight,
            originalExclusivity = prompt.Exclusivity
        }
    end

    modifyPrompt(prompt, spamE)
    prompt.AncestryChanged:Connect(function(_, parent)
        if parent == nil then
            promptTracker[prompt] = nil
        end
    end)
end

-- One Click Remove Functions
local enabled = false

local function OneClickRemove(state)
    enabled = state
    local confirmFrame = Players.LocalPlayer.PlayerGui:FindFirstChild("ShovelPrompt")
    if confirmFrame and confirmFrame:FindFirstChild("ConfirmFrame") then
        confirmFrame.ConfirmFrame.Visible = not state
    end
end

-- Destroy Sign Function
local function DestroySign()
    for _, farm in pairs(workspace.Farm:GetChildren()) do
        local sign = farm:FindFirstChild("Sign")
        if sign then
            local core = sign:FindFirstChild("Core_Part")
            if core then
                for _, obj in pairs(core:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") then
                        obj:Destroy()
                    end
                end
            end
        end

        local growSign = farm:FindFirstChild("Grow_Sign")
        if growSign then
            for _, obj in pairs(growSign:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    obj:Destroy()
                end
            end
        end
    end
end

local BananaDupe
local BAnanaDupeE = false

local function DupeBanana()
    if BananaDupe then task.cancel(BananaDupe) end
    BananaDupe = task.spawn(function()
        while BAnanaDupeE do
            ReplicatedStorage.GameEvents.BuySeedStock:FireServer("Banana")
            task.wait(1)
        end
    end)
end

-- Auto Favorite Functions
local favoriteEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Favorite_Item")
local connection = nil
local autoFavoriteEnabled = false

local function toolMatchesMutation(toolName)
    for _, mutation in ipairs(selectedMutations) do
        if string.find(toolName, mutation) then
            return true
        end
    end
    return false
end

local function isToolFavorited(tool)
    return tool:GetAttribute("Favorite") or (tool:FindFirstChild("Favorite") and tool.Favorite.Value)
end

local function favoriteToolIfMatches(tool)
    if toolMatchesMutation(tool.Name) and not isToolFavorited(tool) then
        favoriteEvent:FireServer(tool)
        task.wait(0.1)
    end
end

local function processBackpack()
    local backpack = lp:FindFirstChild("Backpack") or lp:WaitForChild("Backpack")
    for _, tool in ipairs(backpack:GetChildren()) do
        favoriteToolIfMatches(tool)
    end
end

local function setupAutoFavorite()
    if connection then connection:Disconnect() end

    local backpack = lp:WaitForChild("Backpack")

    connection = backpack.ChildAdded:Connect(function(tool)
        task.wait(0.1)
        favoriteToolIfMatches(tool)
    end)

    processBackpack()
end

-- Auto Claim Premium Seeds Functions
local autoClaimToggle = false
local claimConnection = nil

local function claimPremiumSeed()
    ReplicatedStorage.GameEvents.SeedPackGiverEvent:FireServer("ClaimPremiumPack")
end

local function toggleAutoClaim(newState)
    autoClaimToggle = newState
    if claimConnection then
        claimConnection:Disconnect()
        claimConnection = nil
    end
    if autoClaimToggle then
        claimConnection = RunService.Heartbeat:Connect(function()
            claimPremiumSeed()
            task.wait()
        end)
    end
end

-- Auto Open Crate Functions
local autoSkipEnabled = false

local function toggleAutoSkip()
    autoSkipEnabled = not autoSkipEnabled
    if autoSkipEnabled then
        task.spawn(function()
            local character = lp.Character
            local backpack = lp:FindFirstChild("Backpack")
            local seedTool
            if backpack then
                for _, tool in ipairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool.Name:find("Basic Seed Pack") then
                        seedTool = tool
                        break
                    end
                end
            end
            if seedTool and character then
                seedTool.Parent = character
            end

            while autoSkipEnabled do
                local PlayerGui = lp:FindFirstChild("PlayerGui")
                local RollCrate_UI = PlayerGui and PlayerGui:FindFirstChild("RollCrate_UI")
                local character = lp.Character
                local equippedTool = character and character:FindFirstChildOfClass("Tool")
                local holdingSeed = equippedTool and equippedTool.Name:find("Basic Seed Pack")

                if RollCrate_UI then
                    if RollCrate_UI.Enabled then
                        local Frame = RollCrate_UI:FindFirstChild("Frame")
                        local Button = Frame and Frame:FindFirstChild("Skip")
                        if Button and Button:IsA("ImageButton") and Button.Visible then
                            GuiService.SelectedObject = Button
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                        end
                    elseif holdingSeed then
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end

-- Server Hop Function
local function ServerHop()
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local PlaceId = game.PlaceId
    local servers = {}
    local cursor = nil

    -- Fetch servers
    local function GetServers(cursor)
        local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor then
            url = url .. "&cursor=" .. cursor
        end
        return HttpService:JSONDecode(game:HttpGet(url))
    end

    -- Collect all servers
    repeat
        local data = GetServers(cursor)
        for _, server in ipairs(data.data) do
            table.insert(servers, server.id)
        end
        cursor = data.nextPageCursor
    until not cursor or #servers > 0

    -- Notify if no servers are found
    if #servers == 0 then
        warn("No available servers found.")
        return
    end

    -- Select a random server
    local targetServer = servers[math.random(1, #servers)]
    TeleportService:TeleportToPlaceInstance(PlaceId, targetServer, game.Players.LocalPlayer)
end

-- Auto Plant Functions
local plantRemote = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Plant_RE")
local AutoPlanting = false
local CurrentlyPlanting = false
local SelectedSeeds = {}

local function getPlayerPosition()
    local char = lp.Character or lp.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    return root and root.Position or Vector3.zero
end

local function getCurrentSeedsInBackpack()
    local result = {}
    for _, tool in ipairs(lp.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local base = tool.Name:match("^(.-) Seed")
            if base and table.find(SelectedSeeds, base) then
                result[#result + 1] = {BaseName = base, Tool = tool}
            end
        end
    end
    return result
end

local function plantEquippedSeed(seedName)
    local pos = getPlayerPosition()
    plantRemote:FireServer(pos, seedName)
end

local function equipTool(tool)
    if not tool or not tool:IsDescendantOf(lp.Backpack) then return end

    pcall(function()
        lp.Character.Humanoid:UnequipTools()
        task.wait(0.1)
        tool.Parent = lp.Character
        while not lp.Character:FindFirstChild(tool.Name) do
            task.wait(0.1)
        end
    end)
end

local function startAutoPlanting()
    if CurrentlyPlanting then return end
    CurrentlyPlanting = true

    task.spawn(function()
        while AutoPlanting do
            local seeds = getCurrentSeedsInBackpack()
            for _, data in ipairs(seeds) do
                local tool = data.Tool
                local seedName = data.BaseName

                if not table.find(SelectedSeeds, seedName) then continue end

                if tool and tool:IsA("Tool") and tool:IsDescendantOf(lp.Backpack) then
                    equipTool(tool)
                    task.wait(0.5)

                    while AutoPlanting and lp.Character:FindFirstChild(tool.Name) do
                        if not table.find(SelectedSeeds, seedName) then break end
                        plantEquippedSeed(seedName)
                        task.wait(0.2)
                    end
                end
            end
            task.wait(0.5)
        end
        CurrentlyPlanting = false
    end)
end

-- Destroy Others Farm Function
local function DestoryOthersFarm()
    local farms = workspace:FindFirstChild("Farm")
    if not farms then return end

    for _, farm in pairs(farms:GetChildren()) do
        local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
        if data and data:FindFirstChild("Owner") and data.Owner.Value ~= lp.Name then
            local plants = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Plants_Physical")
            if plants then
                for _, obj in pairs(plants:GetChildren()) do
                    obj:Destroy()
                end
            end
        end
    end
end

-- Rayfield UI Creation
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Grow a Garden | RzkyO",
   Icon = 0,
   LoadingTitle = "Grow a Garden OP",
   LoadingSubtitle = "by RzkyO",
   Theme = "default",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "Kijok Hub"
   },

   Discord = {
      Enabled = false,
      Invite = "dmBzVaRrD3",
      RememberJoins = true
   },

   KeySystem = false,
   KeySettings = {
   Title = "",
   Subtitle = "",
   Note = "",
   FileName = "",
   SaveKey = true,
   GrabKeyFromSite = false,
   Key = {
      "tolol",
   }
}
})

-- Centralized webhook URL
local WEBHOOK_URL = ""

-- Function to send Discord webhook
local function sendWebhook(data)
    if not data or type(data) ~= "table" then
        return -- Silently return instead of warning
    end

    -- Most executors provide a JSON encode function, e.g., `syn.JSONEncode` or built-in JSON encoding
    local json
    if syn and syn.JSONEncode then
        json = syn.JSONEncode(data)
    elseif http and http.JSONEncode then
        json = http.JSONEncode(data)
    else
        -- Fallback: Assume the executor has a built-in JSON encoder
        local success, result = pcall(function()
            return game:GetService("HttpService"):JSONEncode(data) -- This will fail on client, used for JSON simulation
        end)
        if not success then
            return -- Silently return instead of warning
        end
        json = result
    end

    -- Use executor’s request function
    local request = (syn and syn.request) or (http and http.request) or (http_request) or (request)
    if not request then
        return -- Silently return instead of warning
    end

    local success, response = pcall(request, {
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = json
    })

    if success then
        if response.StatusCode and response.StatusCode >= 200 and response.StatusCode < 300 then
        else
        end
    else
    end
end

-- Function to check game version and handle logic
local function CheckVersion()
    local version = game.PlaceVersion
    local supportedVersions = {1233, 1224, 1223, 1226, 1232, 1222, 1221, 1225, 1227, 1228, 1229, 1220}
    local unsupportedVersions = {1231, 1236, 1246, 1247}

    print("Checking for place version: " .. version)

    local status, message
    local playerCount = game.Players.NumPlayers
    local maxPlayers = game.Players.MaxPlayers
    local playerCountText = string.format("%d/%d", playerCount, maxPlayers)

    -- Validate variables
    if type(game.PlaceId) ~= "number" then
        warn("Error: game.PlaceId is not a number, got", game.PlaceId)
        return
    end
    if type(game.JobId) ~= "string" then
        warn("Error: game.JobId is not a string, got", game.JobId)
        return
    end
    if type(version) ~= "number" then
        warn("Error: version is not a number, got", version)
        return
    end

    if table.find(supportedVersions, version) then
        status = "Supported"
        message = "Congrats! You're in a supported version (" .. version .. ") for Easter Shop Buyer. Have fun!"
        local mobileCode = string.format("game:GetService('TeleportService'):TeleportToPlaceInstance(%d, '%s')", game.PlaceId, game.JobId)
        local embed = {
            title = "🛒 Easter Shop Buyer - Working Server Found!",
            description = string.format(
                "**Server Details**\n- **Place ID**: %d\n- **Job ID**: %s\n- **Player Count**: %s\n\n**PC Join Code**:\n```game:GetService('TeleportService'):TeleportToPlaceInstance(%d, '%s')```",
                game.PlaceId, game.JobId, playerCountText, game.PlaceId, game.JobId
            ),
            color = 0x00FF00,
            footer = { text = "Easter Shop Buyer | Version " .. version }
        }
        sendWebhook({
            content = string.format("<@&1374268088891080796>\n**Mobile Join Code**: `%s`", mobileCode),
            username = "Easter Shop Buyer",
            embeds = { embed }
        })

        local hasSentBloodMoonWebhook = false
        spawn(function()
            while wait(1) do
                local isBloodMoon = workspace:GetAttribute("BloodMoonEvent") == true
                if isBloodMoon and not hasSentBloodMoonWebhook then
                    local playerCount = game.Players.NumPlayers
                    local maxPlayers = game.Players.MaxPlayers
                    local playerCountText = string.format("%d/%d", playerCount, maxPlayers)
                    local bloodMoonMobileCode = string.format("game:GetService('TeleportService'):TeleportToPlaceInstance(%d, '%s')", game.PlaceId, game.JobId)
                    local bloodMoonEmbed = {
                        title = "🌙 BloodMoon Server Detected!",
                        description = string.format(
                            "**BloodMoon Server Details**\n- **Place ID**: %d\n- **Job ID**: %s\n- **Player Count**: %s\n\n**PC Join Code**:\n```game:GetService('TeleportService'):TeleportToPlaceInstance(%d, '%s')```",
                            game.PlaceId, game.JobId, playerCountText, game.PlaceId, game.JobId
                        ),
                        color = 0xFF0000,
                        footer = { text = "BloodMoon Event | Version " .. version }
                    }
                    sendWebhook({
                        content = string.format("<@&1374268039993884722>\n**Mobile Join Code**: `%s`", bloodMoonMobileCode),
                        username = "BloodMoon Alert",
                        embeds = { bloodMoonEmbed }
                    })
                    hasSentBloodMoonWebhook = true
                elseif not isBloodMoon and hasSentBloodMoonWebhook then
                    hasSentBloodMoonWebhook = false
                end
            end
        end)
    elseif table.find(unsupportedVersions, version) then
        status = "Unsupported"
        message = "The server's version (" .. version .. ") is not supported for Easter Shop Buyer."
    else
        status = "Unknown"
        message = "The current server version (" .. version .. ") is not recognized for Easter Shop Buyer."
    end

    print("Current version: " .. version .. " | Status: " .. status .. " | Players: " .. playerCountText)
    print(status .. " Version", message)
end

CheckVersion()

local MainTab = Window:CreateTab("Main", "flower")
local ShopTab = Window:CreateTab("Shop", "shopping-cart")
local PlayerTab = Window:CreateTab("Players", "user")
local MiscTab = Window:CreateTab("Miscellaneous", "list")
local VisualsTab = Window:CreateTab("Visuals", "eye")

MainTab:CreateSection("Auto Farm")

MainTab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Callback = function(state)
        autoFarmEnabled = state
        if autoFarmEnabled then
            instantFarm()
        elseif farmThread then
            task.cancel(farmThread)
            farmThread = nil
        end
    end
})

MainTab:CreateToggle({
    Name = "Auto Farm v2",
    Info = "Make sure you look down! May not collect sometimes. Bad for packed areas!",
    CurrentValue = false,
    Callback = ToggleHarvest
})

MainTab:CreateToggle({
    Name = "Auto Collect",
    CurrentValue = false,
    Callback = function(state)
        fastClickEnabled = state
        if fastClickEnabled then
            fastClickFarm()
        elseif fastClickThread then
            task.cancel(fastClickThread)
            fastClickThread = nil
        end
    end
})

MainTab:CreateToggle({
    Name = "Auto Collect V2",
    Info = "Automatically collects fruits near you",
    CurrentValue = false,
    Callback = function(Value)
        spamE = Value
        updateFarmData()

        for _, farm in pairs(farms) do
            for _, obj in ipairs(farm:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    handleNewPrompt(obj)
                end
            end
        end

        if spamE then
            collectionThread = task.spawn(function()
                while spamE and task.wait(0.1) do
                    if not isInventoryFull() then
                        local plr = game.Players.LocalPlayer
                        local char = plr and plr.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")

                        if root then
                            for prompt, _ in pairs(promptTracker) do
                                if prompt:IsA("ProximityPrompt") and prompt.Enabled and prompt.KeyboardKeyCode == Enum.KeyCode.E then
                                    local targetPos
                                    local parent = prompt.Parent

                                    if parent:IsA("BasePart") then
                                        targetPos = parent.Position
                                    elseif parent:IsA("Model") and parent:FindFirstChild("HumanoidRootPart") then
                                        targetPos = parent.HumanoidRootPart.Position
                                    end

                                    if targetPos and (root.Position - targetPos).Magnitude <= RANGE then
                                        pcall(function()
                                            fireproximityprompt(prompt, 1, true)
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        else
            for prompt, data in pairs(promptTracker) do
                if prompt:IsA("ProximityPrompt") then
                    pcall(function()
                        prompt.RequiresLineOfSight = data.originalRequiresLOS
                        prompt.Exclusivity = data.originalExclusivity
                    end)
                end
            end

            if collectionThread then
                task.cancel(collectionThread)
                collectionThread = nil
            end
        end
    end
})

descendantConnection = workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("ProximityPrompt") and isInsideFarm(obj) then
        handleNewPrompt(obj)
    end
end)

for _, farm in pairs(farms) do
    for _, obj in ipairs(farm:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            handleNewPrompt(obj)
        end
    end
end

MainTab:CreateToggle({
    Name = "Auto Sell",
    Info = "Automatically sells when inventory is full (200)",
    CurrentValue = false,
    Callback = function(Value)
        autoSellEnabled = Value
        if autoSellEnabled then
            autoSellThread = task.spawn(function()
                while autoSellEnabled and task.wait(1) do
                    if isInventoryFull() then
                        sellItems()
                    end
                end
            end)
        elseif autoSellThread then
            task.cancel(autoSellThread)
        end
    end
})
local MainTabSect = MainTab:CreateSection("Insta Sell")

MainTab:CreateButton({
    Name = "Insta Sell",
    Callback = SellAll
})

MainTab:CreateButton({
    Name = "Insta Sell Hand",
    Callback = HSell
})

MainTab:CreateSection("Others")

MainTab:CreateDropdown({
    Name = "Select Mutations",
    Options = mutationOptions,
    CurrentOption = selectedMutations,
    MultipleOptions = true,
    Callback = function(Options)
        selectedMutations = Options
        if autoFavoriteEnabled then
            processBackpack()
        end
    end
})

MainTab:CreateToggle({
    Name = "Auto-Favorite",
    CurrentValue = false,
    Callback = function(Value)
        autoFavoriteEnabled = Value
        if Value then
            setupAutoFavorite()
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end
})
local function Unfavall()
    local backpack = lp:FindFirstChild("Backpack") or lp:WaitForChild("Backpack")
    for _, tool in ipairs(backpack:GetChildren()) do
        local isFavorited = tool:GetAttribute("Favorite") or (tool:FindFirstChild("Favorite") and tool.Favorite.Value)
        if isFavorited then
            favoriteEvent:FireServer(tool)
            task.wait()
        end
    end
end

MainTab:CreateButton({
    Name = "Unfav all",
    Callback = Unfavall
})

MainTab:CreateToggle({
    Name = "One Click Plant Remove",
    Info = "Be careful! Hope you don't delete something you needed!",
    CurrentValue = false,
    Callback = OneClickRemove
})

MainTab:CreateButton({
    Name = "Stop Grow-ALL Pop-up",
    Callback = DestroySign
})

-- Configuration
local mutationOptions = {
    "Wet", "Gold", "Frozen", "Rainbow", "Choc",
    "Chilled", "Shocked", "Moonlit", "Bloodlit", "Celestial"
}

local mutationColors = {
    Wet = Color3.fromRGB(0, 0, 255),        -- Blue
    Gold = Color3.fromRGB(255, 215, 0),      -- Gold
    Frozen = Color3.fromRGB(135, 206, 250),  -- Light Blue
    Rainbow = Color3.fromRGB(255, 255, 255), -- White
    Choc = Color3.fromRGB(139, 69, 19),      -- Brown
    Chilled = Color3.fromRGB(0, 255, 255),   -- Cyan
    Shocked = Color3.fromRGB(255, 255, 100), -- Bright Yellow
    Moonlit = Color3.fromRGB(128, 0, 128),   -- Purple
    Bloodlit = Color3.fromRGB(200, 0, 0),    -- Deep Red
    Celestial = Color3.fromRGB(200, 150, 255) -- Light Purple
}

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- State Management
local state = {
    selectedMutations = {"Bloodlit", "Celestial"}, -- Default
    espEnabled = false,
    espBillboards = {}, -- Tracks BillboardGui and Highlight instances
    espHighlights = {}
}

-- Creates or updates ESP for a single fruit model
local function createESP(fruitModel)
    -- Clean up existing ESP
    if state.espBillboards[fruitModel] then
        state.espBillboards[fruitModel]:Destroy()
        state.espBillboards[fruitModel] = nil
    end
    if state.espHighlights[fruitModel] then
        state.espHighlights[fruitModel]:Destroy()
        state.espHighlights[fruitModel] = nil
    end

    if not state.espEnabled then return end

    -- Collect active mutations
    local activeMutations = {}
    for _, mutation in ipairs(mutationOptions) do
        if table.find(state.selectedMutations, mutation) and fruitModel:GetAttribute(mutation) then
            table.insert(activeMutations, mutation)
        end
    end

    if #activeMutations == 0 then return end

    -- Build display text
    local text = fruitModel.Name
    if #activeMutations > 0 then
        text = text .. " - " .. table.concat(activeMutations, ", ")
    end

    -- Use the first mutation's color for outline and text
    local espColor = mutationColors[activeMutations[1]] or Color3.fromRGB(255, 255, 255)

    -- Create Highlight (outline only)
    local highlight = Instance.new("Highlight")
    highlight.Name = "MutationESP_Highlight"
    highlight.FillTransparency = 1
    highlight.OutlineColor = espColor
    highlight.OutlineTransparency = 0
    highlight.Adornee = fruitModel
    highlight.Parent = fruitModel
    state.espHighlights[fruitModel] = highlight

    -- Create BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "MutationESP"
    billboard.Adornee = fruitModel.PrimaryPart or fruitModel:FindFirstChildWhichIsA("BasePart")
    billboard.Size = UDim2.fromOffset(100, 20)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.fromScale(1, 1)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "{" .. text .. "}"
    textLabel.TextColor3 = espColor
    textLabel.TextScaled = true
    textLabel.TextStrokeTransparency = 0.5
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboard

    billboard.Parent = fruitModel
    state.espBillboards[fruitModel] = billboard
end

-- Updates ESP for all fruits in the player's plots
local function updateESP()
    -- Clear existing ESP
    for _, billboard in pairs(state.espBillboards) do
        billboard:Destroy()
    end
    for _, highlight in pairs(state.espHighlights) do
        highlight:Destroy()
    end
    table.clear(state.espBillboards)
    table.clear(state.espHighlights)

    if not state.espEnabled or not Workspace:FindFirstChild("Farm") then return end

    -- Find player's plots
    local farms = {}
    for _, farm in ipairs(Workspace.Farm:GetChildren()) do
        local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
        if data and data:FindFirstChild("Owner") and data.Owner.Value == LocalPlayer.Name then
            table.insert(farms, farm)
        end
    end

    -- Process fruits in each plot
    for _, farm in ipairs(farms) do
        local plantsFolder = farm.Important:FindFirstChild("Plants_Physical")
        if plantsFolder then
            for _, plantModel in ipairs(plantsFolder:GetChildren()) do
                if plantModel:IsA("Model") then
                    local fruitsFolder = plantModel:FindFirstChild("Fruits")
                    if fruitsFolder then
                        for _, fruitModel in ipairs(fruitsFolder:GetChildren()) do
                            if fruitModel:IsA("Model") then
                                createESP(fruitModel)
                            end
                        end
                    end
                end
            end
        end
    end
end

VisualsTab:CreateSection("ESP")

-- Dropdown for mutation selection
VisualsTab:CreateDropdown({
    Name = "Select Mutations",
    Options = mutationOptions,
    CurrentOption = state.selectedMutations,
    MultipleOptions = true,
    Flag = "MutationDropdown",
    Callback = function(options)
        state.selectedMutations = options
        updateESP()
    end
})

-- Toggle for ESP
VisualsTab:CreateToggle({
    Name = "Enable Mutation ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(value)
        state.espEnabled = value
        updateESP()
    end
})

-- Section for Mutation Counts
local CountSection = VisualsTab:CreateSection("Mutation Stats")
local CountLabel = VisualsTab:CreateLabel("Mutation Stats")

-- Function to update mutation counts
local function updateMutationCounts()
    local mutationCounts = {}
    for _, mutation in pairs(mutationOptions) do
        mutationCounts[mutation] = 0
    end

    -- Find player's plots
    local farms = {}
    for _, farm in pairs(Workspace.Farm:GetChildren()) do
        local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
        if data and data:FindFirstChild("Owner") and data.Owner.Value == LocalPlayer.Name then
            table.insert(farms, farm)
        end
    end

    -- Count mutations on fruits
    for _, farm in pairs(farms) do
        local plantsFolder = farm.Important:FindFirstChild("Plants_Physical")
        if plantsFolder then
            for _, plantModel in pairs(plantsFolder:GetChildren()) do
                if plantModel:IsA("Model") then
                    local fruitsFolder = plantModel:FindFirstChild("Fruits")
                    if fruitsFolder then
                        for _, fruitModel in pairs(fruitsFolder:GetChildren()) do
                            if fruitModel:IsA("Model") then
                                for _, mutation in pairs(mutationOptions) do
                                    if fruitModel:GetAttribute(mutation) then
                                        mutationCounts[mutation] = mutationCounts[mutation] + 1
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Format counts
    local countText = ""
    for _, mutation in pairs(mutationOptions) do
        if mutationCounts[mutation] > 0 then
            countText = countText .. mutation .. ": " .. mutationCounts[mutation] .. ", "
        end
    end
    countText = countText:sub(1, -3) -- Remove trailing comma and space
    if countText == "" then
        countText = "No mutations found"
    end

    CountLabel:Set(countText)
end

-- Handle fruit additions dynamically
Workspace.Farm.DescendantAdded:Connect(function(descendant)
    if state.espEnabled and descendant:IsA("Model") and descendant.Parent == "Fruits" then
        local plantModel = descendant.Parent.Parent
        local farm = plantModel:FindFirstAncestorOfClass("Model")
        local data = farm and farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
        if data and data:FindFirstChild("Owner") and data.Owner.Value == LocalPlayer.Name then
            createESP(descendant)
            updateMutationCounts()
        end
    end
end)

-- Update counts periodically
RunService.Heartbeat:Connect(function()
    updateMutationCounts()
end)

-- Initial updates
updateESP()
updateMutationCounts()

local EasterShopItems = {
    "Chocolate Carrot",
    "Red Lollipop",
    "Candy Sunflower",
    "Easter Egg",
    "Chocolate Sprinkler",
    "Candy Blossom"
}

local EasterShopSelectedItems1 = {
    "Chocolate Carrot",
    "Red Lollipop",
    "Candy Sunflower",
    "Easter Egg",
    "Chocolate Sprinkler",
    "Candy Blossom"
}

local EasterShopBuyEnabled = false

local EasterShopBuyEvent = game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuyEventShopStock")

local EasterShopDropdown = ShopTab:CreateDropdown({
    Name = "Easter Shop Items",
    Options = EasterShopItems,
    CurrentOption = EasterShopSelectedItems1,
    MultipleOptions = true,
    Callback = function(options)
        if #options == 0 then
            EasterShopSelectedItems = EasterShopSelectedItems1
        else
            EasterShopSelectedItems = options
        end
    end
}, "Dropdown")

local EasterShopToggle = ShopTab:CreateToggle({
    Name = "Auto Buy Easter Items",
    Description = "Needs BloodMoon",
    CurrentValue = false,
    Callback = function(value)
        EasterShopBuyEnabled = value
    end
}, "Toggle")

task.spawn(function()
    while task.wait(0.1) do
        if EasterShopBuyEnabled and workspace:GetAttribute("BloodMoonEvent") == true then
            for _, itemName in ipairs(EasterShopSelectedItems1) do
                if itemName ~= "None" then
                    pcall(function()
                        EasterShopBuyEvent:FireServer(itemName)
                    end)
                end
            end
        end
    end
end)

-- Placeholder Product ID (replace with your actual product ID)
local ProductId = 3268187638 -- CHANGE THIS TO YOUR VALID PRODUCT ID

-- Create a button to trigger the purchase
ShopTab:CreateButton({
    Name = "Buy Candy Blossom With Robux (for rich people xd)",
    Info = "Click to purchase",
    Callback = function()
        -- Access MarketplaceService
        local MarketplaceService = game:GetService("MarketplaceService")
        local Players1 = game:GetService("Players")
        local player1 = Players1.LocalPlayer
        -- Attempt to prompt the purchase
        local success, errorMessage = pcall(function()
            MarketplaceService:PromptProductPurchase(player1, ProductId)
        end)
        end
   }
)

ShopTab:CreateButton({
    Name = "AntiAfk (Press Once Only)",
    Callback = function()
        -- Execute the FindServer.lua script
        local success, error = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/hassanxzayn-lua/Anti-afk/main/antiafkbyhassanxzyn"))()
        end)
        if success then
            Rayfield:Notify({
                Title = "Anti Afk",
                Content = "Anti Afk script executed successfully!",
                Duration = 5,
                Image = "rewind" -- Using Lucide Icon
            })
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Failed to execute Server Anti Afk script: " .. tostring(error),
                Duration = 5,
                Image = "alert-triangle"
            })
        end
    end,
})

ShopTab:CreateButton({
    Name = "ServerHop",
    Callback = function()
        -- Execute the FindServer.lua script
        local success, error = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Spectrum-Trash/Addons/refs/heads/main/FindServer.lua"))()
        end)
        if success then
            Rayfield:Notify({
                Title = "Server Finder",
                Content = "Server Finder script executed successfully!",
                Duration = 5,
                Image = "rewind" -- Using Lucide Icon
            })
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Failed to execute Server Finder script: " .. tostring(error),
                Duration = 5,
                Image = "alert-triangle"
            })
        end
    end,
})

-- Create Server Hop Button
ShopTab:CreateButton({
    Name = "ServerHop V2",
    Callback = function()
        ServerHop()
    end
})

local SeedCurrent = {
    "Beanstalk",
    "Pepper"
}

local GearCurrent = {
    "Master Sprinkler",
    "Godly Sprinkler"
}

ShopTab:CreateSection("Auto Buy")

ShopTab:CreateDropdown({
    Name = "Select Seeds",
    Info = "Choose which seeds to auto buy",
    Options = seedItems,
    CurrentOption = SeedCurrent,
    MultipleOptions = true,
    Callback = function(Options)
        selectedSeeds = Options
    end
})

ShopTab:CreateDropdown({
    Name = "Select Gear",
    Info = "Choose which gear to auto buy",
    Options = gearItems,
    CurrentOption = GearCurrent,
    MultipleOptions = true,
    Callback = function(Options)
        selectedGears = Options
    end
})

ShopTab:CreateToggle({
    Name = "Auto Buy",
    CurrentValue = false,
    Callback = function(Value)
        autoBuyEnabled = Value
    end
})

ShopTab:CreateToggle({
    Name = "Auto Buy Eggs",
    CurrentValue = false,
    Callback = function(value)
        Autoegg_autoBuyEnabled = value
        if Autoegg_autoBuyEnabled then
            Autoegg_firstRun = true
            Autoegg_autoBuyEggs()
        end
    end
})
-- Auto Buy Logic
local function getItemPrice(path, item)
    local container = path:FindFirstChild(item)
    if not container then return math.huge end
    local frame = container:FindFirstChild("Frame")
    if not frame then return math.huge end
    local buyBtn = frame:FindFirstChild("Sheckles_Buy")
    if not buyBtn then return math.huge end
    local inStock = buyBtn:FindFirstChild("In_Stock")
    if not inStock then return math.huge end
    local costText = inStock:FindFirstChild("Cost_Text")
    if not costText or not costText.Text then return math.huge end
    return parseMoney(costText.Text)
end

local function tryPurchase(path, remote, item)
    local itemPrice = getItemPrice(path, item)
    local playerMoney = getPlayerMoney()
    if playerMoney > 0 and itemPrice > 0 and playerMoney >= itemPrice then
        local container = path:FindFirstChild(item)
        if container and container:FindFirstChild("Frame") then
            local buyBtn = container.Frame:FindFirstChild("Sheckles_Buy")
            if buyBtn and buyBtn:FindFirstChild("In_Stock") and buyBtn.In_Stock.Visible then
                remote:FireServer(item)
                return true
            end
        end
    end
    return false
end

task.spawn(function()
    while task.wait(0.5) do
        if autoBuyEnabledE then
            for _, seed in ipairs(selectedSeeds) do
                tryPurchase(seedPath, seedRemote, seed)
            end
            for _, gear in ipairs(selectedGears) do
                tryPurchase(gearPath, gearRemote, gear)
            end
            for _, item in ipairs(selectedBMItems) do
                tryPurchase(bmPath, dmRemote, item)
            end
        end
    end
end)

ShopTab:CreateDropdown({
    Name = "Blood Moon Items",
    Description = "Choose which Blood Moon items to auto buy",
    Options = bmItems,
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(Options)
        selectedBMItems = Options
    end
}, "AutoBuyBloodMoon")
ShopTab:CreateToggle({
    Name = "Auto Buy BloodMoon Items",
    CurrentValue = false,
    Callback = function(Value)
        autoBuyEnabledE = Value
    end
})

ShopTab:CreateSection("Menu's (You Gotta Press it again to close or manually close it)")

ShopTab:CreateButton({
    Name = "Open Egg Shop 1",
    Info = "Click again to close",
    Callback = EggShop1
})

ShopTab:CreateButton({
    Name = "Open Egg Shop 2",
    Info = "Click again to close",
    Callback = EggShop2
})

ShopTab:CreateButton({
    Name = "Open Egg Shop 3",
    Info = "Click again to close",
    Callback = EggShop3
})

ShopTab:CreateButton({
    Name = "Open Seed Shop",
    Info = "Click again to close",
    Callback = OpenShop
})

ShopTab:CreateButton({
    Name = "Open Gear Shop",
    Info = "Click again to close",
    Callback = OpenGearShop
})

ShopTab:CreateButton({
    Name = "Open Quest",
    Info = "Click again to close",
    Callback = OpenQuest
})
ShopTab:CreateButton({
    Name = "Opens BloodShop",
    Callback = OpenBloodShop
})

PlayerTab:CreateSection("Movement")

PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = Fly
})

PlayerTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Callback = ToggleNoclip
})

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = ToggleInfJump
})

PlayerTab:CreateSlider({
    Name = "Player Speed",
    Range = {0, 200},
    Increment = 4,
    Suffix = "Speed",
    CurrentValue = 16,
    Callback = function(value)
        local char = lp.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").WalkSpeed = value
        end
    end
})

PlayerTab:CreateSlider({
    Name = "Jump Height",
    Range = {0, 200},
    Increment = 10,
    Suffix = "Height",
    CurrentValue = 50,
    Callback = function(value)
        local char = lp.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").JumpPower = value
        end
    end
})

MiscTab:CreateSection("Buy Banana (only works for old/working servers)")

MiscTab:CreateToggle({
    Name = "Buy Banana",
    CurrentValue = false,
    Info = "It costs 850k!!! Game made it so we don't get every stock reset I think!!",
    Callback = function(Value)
        BAnanaDupeE = Value
        if Value then
            DupeBanana()
        end
    end
})

MiscTab:CreateSection("Plants")

MiscTab:CreateDropdown({
    Name = "Select Seeds to Plant",
    Info = "Seeds to plant",
    Options = seedNames,
    CurrentOption = {},
    MultiSelection = true,
    Callback = function(opts)
        SelectedSeeds = opts
    end
})

MiscTab:CreateToggle({
    Name = "Auto Plant",
    Info = "Fly and No Clip recommended to avoid glitches from growing crops",
    CurrentValue = false,
    Callback = function(state)
        AutoPlanting = state
        if state then
            startAutoPlanting()
        end
    end
})
MiscTab:CreateToggle({
    Name = "Auto Summit Plant",
    CurrentValue = false,
    Flag = "AutoMoonToggle",
    Callback = function(Value)
        AutoGiveFruitMoon(Value)
    end
})

VisualsTab:CreateSection("Visuals")

VisualsTab:CreateButton({
    Name = "Remove Others' Plants",
    Info = "Removes everyone else's plants except yours",
    Callback = DestoryOthersFarm
})

VisualsTab:CreateInput({
    Name = "Fake Money",
    PlaceholderText = "Enter Amount",
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        local amount = tonumber(value)
        if not amount then return end

        if lp and lp:FindFirstChild("leaderstats") and lp.leaderstats:FindFirstChild("Sheckles") then
            lp.leaderstats.Sheckles.Value = amount
        end

        local function formatCommas(n)
            local negative = n < 0
            n = tostring(math.abs(n))
            local left, num, right = string.match(n, "^([^%d]*%d)(%d*)(.-)$")
            local formatted = left .. (num:reverse():gsub("(%d%d%d)", "%1,"):reverse()) .. right
            return (negative and "-" or "") .. formatted .. "Â¢"
        end

        local function shortenNumber(n)
            local scales = {
                {1000000000000000000, "Qi"},
                {999999986991104, "Qa"},
                {999999995904, "T"},
                {1000000000, "B"},
                {1000000, "M"},
                {1000, "K"}
            }
            local negative = n < 0
            n = math.abs(n)
            if n < 1000 then
                return (negative and "-" or "") .. tostring(math.floor(n))
            end

            for i = 1, #scales do
                local scale, label = scales[i][1], scales[i][2]
                if n >= scale then
                    local value = n / scale
                    if value % 1 == 0 then
                        return (negative and "-" or "") .. string.format("%.0f%s", value, label)
                    else
                        return (negative and "-" or "") .. string.format("%.2f%s", value, label)
                    end
                end
            end
            return (negative and "-" or "") .. tostring(n)
        end

        local formattedDealer = formatCommas(amount)
        local formattedBoard = shortenNumber(amount)

        local shecklesUI = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("Sheckles_UI")
        if shecklesUI and shecklesUI:FindFirstChild("TextLabel") then
            shecklesUI.TextLabel.Text = formattedDealer
        end

        local dealerBoard = workspace:FindFirstChild("DealerBoard")
        if dealerBoard and dealerBoard:FindFirstChild("BillboardGui") and dealerBoard.BillboardGui:FindFirstChild("TextLabel") then
            dealerBoard.BillboardGui.TextLabel.Text = formattedBoard
        end
    end
})

-- Optional: Add a Button to Destroy UI
VisualsTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        Rayfield:Destroy()
    end
})

-- Auto Buy Logic
local function getItemPrice(path, item)
    local container = path:FindFirstChild(item)
    if not container then return math.huge end

    local frame = container:FindFirstChild("Frame")
    if not frame then return math.huge end

    local buyBtn = frame:FindFirstChild("Sheckles_Buy")
    if not buyBtn then return math.huge end

    local inStock = buyBtn:FindFirstChild("In_Stock")
    if not inStock then return math.huge end

    local costText = inStock:FindFirstChild("Cost_Text")
    if not costText or not costText.Text then return math.huge end

    return parseMoney(costText.Text)
end

local function tryPurchase(path, remote, item)
    local itemPrice = getItemPrice(path, item)
    local playerMoney = getPlayerMoney()

    if playerMoney >= itemPrice then
        local container = path:FindFirstChild(item)
        if container and container:FindFirstChild("Frame") then
            local buyBtn = container.Frame:FindFirstChild("Sheckles_Buy")
            if buyBtn and buyBtn:FindFirstChild("In_Stock") and buyBtn.In_Stock.Visible then
                remote:FireServer(item)
                return true
            end
        end
    end
    return false
end

task.spawn(function()
    while task.wait(0.5) do
        if autoBuyEnabled then
            for _, seed in ipairs(selectedSeeds) do
                tryPurchase(seedPath, seedRemote, seed)
            end
            for _, gear in ipairs(selectedGears) do
                tryPurchase(gearPath, gearRemote, gear)
            end
        end
    end
end)

-- Cleanup on Script End
local function cleanup()
    if descendantConnection then
        descendantConnection:Disconnect()
    end
    if collectionThread then
        task.cancel(collectionThread)
    end
    for prompt, data in pairs(promptTracker) do
        if prompt:IsA("ProximityPrompt") then
            pcall(function()
                prompt.RequiresLineOfSight = data.originalRequiresLOS
                prompt.Exclusivity = data.originalExclusivity
            end)
        end
    end
end

Rayfield:LoadConfiguration()
