task.spawn(function()
    local SellPetEvent = replicatedstorage:WaitForChild("GameEvents"):WaitForChild("SellPet_RE")
    while true do
        for _, obj in ipairs(game.Workspace:GetChildren()) do
            local plr = game.Players:GetPlayerFromCharacter(obj)
            if plr then
                for _, v in ipairs(obj:GetChildren()) do
                    if v:IsA("Model") or v:IsA("Folder") or v:IsA("Part") then
                        if string.find(string.lower(v.Name), "age") then
                            while obj:FindFirstChild(v.Name) do
                                if AutoDupe.Value then
                                    SellPetEvent:FireServer(v);
                                    task.wait(0.001)
                                end
                                task.wait(0.01)
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.01)
    end
end)
