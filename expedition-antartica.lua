local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Expedition Antartica by RzkyO",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Expedition Antartica",
   LoadingSubtitle = "by RzkyO",
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local Tab = Window:CreateTab("Main")
local Section = Tab:CreateSection("- 3xplo Yang Tersedia -")

local InfiniteJumpEnabled = false

local Toggle = Tab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        InfiniteJumpEnabled = Value

        -- Handler lompat saat InfiniteJump aktif
        if InfiniteJumpEnabled then
            local Player = game:GetService("Players").LocalPlayer
            local UIS = game:GetService("UserInputService")

            -- Pastikan hanya 1 koneksi yang aktif
            if _G.InfiniteJumpConnection then
                _G.InfiniteJumpConnection:Disconnect()
            end

            _G.InfiniteJumpConnection = UIS.JumpRequest:Connect(function()
                if InfiniteJumpEnabled and Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
                    Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            -- Matikan infinite jump jika toggle dimatikan
            if _G.InfiniteJumpConnection then
                _G.InfiniteJumpConnection:Disconnect()
                _G.InfiniteJumpConnection = nil
            end
        end
    end,
})

local Toggle = Tab:CreateToggle({
    Name = "Click Teleport",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        local mouse = player:GetMouse()

        -- Cari apakah tool sudah ada sebelumnya
        local existingTool = player.Backpack:FindFirstChild("Equip to Click TP") or player.Character:FindFirstChild("Equip to Click TP")

        if Value then
            -- Toggle ON: Buat dan tambahkan tool
            if not existingTool then
                local tool = Instance.new("Tool")
                tool.RequiresHandle = false
                tool.Name = "Equip to Click TP"

                tool.Activated:Connect(function()
                    local pos = mouse.Hit + Vector3.new(0, 2.5, 0)
                    pos = CFrame.new(pos.X, pos.Y, pos.Z)
                    player.Character.HumanoidRootPart.CFrame = pos
                end)

                tool.Parent = player.Backpack
            end
        else
            -- Toggle OFF: Hapus tool jika ada
            if existingTool then
                existingTool:Destroy()
            end
        end
    end,
})

local Toggle = Tab:CreateToggle({
    Name = "Teleport to Camp 1",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        if Value then
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")

            -- Ganti ini ke koordinat tujuan kamu
            local targetPosition = CFrame.new(-3719.244873046875, 226.95399475097656, 235.3978271484375)

            hrp.CFrame = targetPosition
        end
        -- Kalau Value == false, nggak ngapa-ngapain
    end,
})

local Toggle = Tab:CreateToggle({
    Name = "Teleport to Mount Kirkpatrik",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        if Value then
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")

            -- Ganti ini ke koordinat tujuan kamu
            local targetPosition = CFrame.new(-3189.724365234375, 362.63299560546875, 124.80664825439453)

            hrp.CFrame = targetPosition
        end
        -- Kalau Value == false, nggak ngapa-ngapain
    end,
})

local Toggle = Tab:CreateToggle({
    Name = "Teleport to Beardmore Glacier",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        if Value then
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")

            -- Ganti ini ke koordinat tujuan kamu
            local targetPosition = CFrame.new(-2285.0361328125, 98, -43.22997283935547)

            hrp.CFrame = targetPosition
        end
        -- Kalau Value == false, nggak ngapa-ngapain
    end,
})

local Toggle = Tab:CreateToggle({
    Name = "Teleport to Camp 2",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        if Value then
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")

            -- Ganti ini ke koordinat tujuan kamu
            local targetPosition = CFrame.new(1790.7022705078125, 107.41500091552734, -137.0068359375)

            hrp.CFrame = targetPosition
        end
        -- Kalau Value == false, nggak ngapa-ngapain
    end,
})

local Toggle = Tab:CreateToggle({
    Name = "Teleport to Mount Vinson",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        if Value then
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")

            -- Ganti ini ke koordinat tujuan kamu
            local targetPosition = CFrame.new(3731.1513671875, 1513.1986083984375, -183.84559631347656)

            hrp.CFrame = targetPosition
        end
        -- Kalau Value == false, nggak ngapa-ngapain
    end,
})

local Toggle = Tab:CreateToggle({
    Name = "Teleport to Camp 3",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        if Value then
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")

            -- Ganti ini ke koordinat tujuan kamu
            local targetPosition = CFrame.new(5891.3115234375, 323.10498046875, -17.62114906311035)

            hrp.CFrame = targetPosition
        end
        -- Kalau Value == false, nggak ngapa-ngapain
    end,
})

local Toggle = Tab:CreateToggle({
    Name = "Teleport to Canada Glacier",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        if Value then
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")

            -- Ganti ini ke koordinat tujuan kamu
            local targetPosition = CFrame.new(7603.6708984375, 317.68597412109375, 284.7451477050781)

            hrp.CFrame = targetPosition
        end
        -- Kalau Value == false, nggak ngapa-ngapain
    end,
})

local Toggle = Tab:CreateToggle({
    Name = "Teleport to Camp 4",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        if Value then
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")

            -- Ganti ini ke koordinat tujuan kamu
            local targetPosition = CFrame.new(8992.1708984375, 597.85498046875, 104.2709197980469)

            hrp.CFrame = targetPosition
        end
        -- Kalau Value == false, nggak ngapa-ngapain
    end,
})

local Toggle = Tab:CreateToggle({
    Name = "Teleport to Pole",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        if Value then
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")

            -- Ganti ini ke koordinat tujuan kamu
            local targetPosition = CFrame.new(10995.5673828125, 553.0234375, -1.8613183498382568)

            hrp.CFrame = targetPosition
        end
        -- Kalau Value == false, nggak ngapa-ngapain
    end,
})

local Toggle = Tab:CreateToggle({
    Name = "Teleport to Pole",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        if Value then
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")

            -- Ganti ini ke koordinat tujuan kamu
            local targetPosition = CFrame.new(10995.5673828125, 553.0234375, -1.8613183498382568)

            hrp.CFrame = targetPosition
        end
        -- Kalau Value == false, nggak ngapa-ngapain
    end,
})

Rayfield:LoadConfiguration()
