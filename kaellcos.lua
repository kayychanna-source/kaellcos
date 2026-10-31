local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer

local toggles = {
    AutoEat = false,
    AutoDrink = false,
    AutoGrow = false,
    AutoMushroom = false,
    AutoEvent = false,
    AutoBreath = false,
    Hitbox = false,
    ESP = false,
    Speed = false,
    InfJump = false
}

local function safeFire(remote, ...)
    if not remote then return end
    task.spawn(function()
        pcall(function()
            task.wait(math.random(15, 40) / 100)
            remote:FireServer(...)
        end)
    end)
end

local function getRemote(name)
    local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("RemoteEvents")
    if remotesFolder then
        local remote = remotesFolder:FindFirstChild(name, true)
        if remote then return remote end
    end
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name:lower():match(name:lower()) then
            return v
        end
    end
    return nil
end

-- Pakai CoreGui biar gak dihapus game
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CoS_Hub_Updated"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LP:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 240, 0, 450)
Main.Position = UDim2.new(0.5, -120, 0.1, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Title.BackgroundTransparency = 0.5
Title.Text = "CoS Hub | v3.0"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = Main

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -50)
Scroll.Position = UDim2.new(0, 5, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 2
Scroll.Parent = Main

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = Scroll

local function createToggle(name, key, isDefaultOn)
    toggles[key] = isDefaultOn or false
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BackgroundColor3 = toggles[key] and Color3.fromRGB(20, 80, 60) or Color3.fromRGB(40, 40, 50)
    Btn.TextColor3 = toggles[key] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 12
    Btn.Text = name .. " : [" .. (toggles[key] and "ON" or "OFF") .. "]"
    Btn.Parent = Scroll

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = Btn

    Btn.MouseButton1Click:Connect(function()
        toggles[key] = not toggles[key]
        Btn.Text = name .. " : [" .. (toggles[key] and "ON" or "OFF") .. "]"
        Btn.TextColor3 = toggles[key] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(200, 200, 200)
        Btn.BackgroundColor3 = toggles[key] and Color3.fromRGB(20, 80, 60) or Color3.fromRGB(40, 40, 50)
    end)
end

createToggle("Auto Eat", "AutoEat")
createToggle("Auto Drink", "AutoDrink")
createToggle("Auto Grow", "AutoGrow")
createToggle("Auto Mushroom", "AutoMushroom")
createToggle("Auto Event (TP)", "AutoEvent")
createToggle("Auto Breath (Spam)", "AutoBreath")
createToggle("Hitbox Expander", "Hitbox")
createToggle("Player ESP", "ESP")
createToggle("Speed (Client)", "Speed")
createToggle("Infinite Jump", "InfJump")

-- LOGIC 1: Auto Eat/Drink/Grow/Breath
task.spawn(function()
    while task.wait(1) do
        if toggles.AutoEat then safeFire(getRemote("Eat")) end
        if toggles.AutoDrink then safeFire(getRemote("Drink")) end
        if toggles.AutoGrow then safeFire(getRemote("Grow") or getRemote("Age")) end
    end
end)

task.spawn(function()
    while task.wait(0.8) do
        if toggles.AutoBreath then
            safeFire(getRemote("Breath") or getRemote("Ability") or getRemote("Attack"))
        end
    end
end)

-- LOGIC 2: Auto Farm Mushroom (Radius)
task.spawn(function()
    while task.wait(0.5) do
        if toggles.AutoMushroom then
            local char = LP.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
            
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    local parentName = obj.Parent.Name:lower()
                    local actionText = obj.ActionText:lower()
                    local objName = obj.Name:lower()
                    
                    if parentName:match("mushroom") or objName:match("mushroom") or actionText:match("eat") or actionText:match("collect") then
                        local dist = (LP.Character.HumanoidRootPart.Position - obj.Parent.Position).Magnitude
                        if dist < 20 then
                            pcall(function()
                                obj.HoldDuration = 0
                                fireproximityprompt(obj)
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- LOGIC 3: Auto Event (Teleport)
task.spawn(function()
    while task.wait(2) do
        if toggles.AutoEvent then
            local char = LP.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
            
            local originalPos = char.HumanoidRootPart.CFrame
            local foundEvent = false

            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    local pName = obj.Parent.Name:lower()
                    local oName = obj.Name:lower()
                    local aText = obj.ActionText:lower()
                    
                    -- Deteksi keyword event Pony Town (CoS)
                    if pName:match("event") or pName:match("gacha") or pName:match("merchant") or pName:match("meteor") 
                    or oName:match("event") or oName:match("gacha") or oName:match("merchant") or oName:match("meteor")
                    or aText:match("open") or aText:match("claim") or aText:match("collect") then
                        
                        foundEvent = true
                        local targetPos = obj.Parent.Position
                        
                        -- Teleport ke event
                        pcall(function()
                            char.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
                        end)
                        
                        task.wait(0.5) -- Tunggu loading map
                        
                        -- Ambil reward
                        pcall(function()
                            obj.HoldDuration = 0
                            fireproximityprompt(obj)
                        end)
                        
                        task.wait(0.5)
                        break -- Fokus ke satu event dulu
                    end
                end
            end
            
            -- Balik ke posisi awal kalau udah selesai ambil event
            if foundEvent then
                task.wait(1)
                pcall(function()
                    char.HumanoidRootPart.CFrame = originalPos
                end)
            end
        end
    end
end)

-- LOGIC 4: Speed
RunService.Heartbeat:Connect(function()
    if toggles.Speed then
        local char = LP.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 65
        end
    else
        local char = LP.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 16
        end
    end
end)

-- LOGIC 5: Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if toggles.InfJump then
        local char = LP.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- LOGIC 6: Hitbox Expander
task.spawn(function()
    while task.wait(0.2) do
        if toggles.Hitbox then
            for _, v in pairs(Workspace:GetChildren()) do
                if v:IsA("Model") and v ~= LP.Character and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                    pcall(function()
                        v.HumanoidRootPart.Size = Vector3.new(20, 20, 20)
                        v.HumanoidRootPart.Transparency = 0.5
                        v.HumanoidRootPart.CanCollide = false
                        v.HumanoidRootPart.BrickColor = BrickColor.new("Really red")
                    end)
                end
            end
        else
            for _, v in pairs(Workspace:GetChildren()) do
                if v:IsA("Model") and v ~= LP.Character and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                    pcall(function()
                        v.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                        v.HumanoidRootPart.Transparency = 1
                        v.HumanoidRootPart.CanCollide = true
                        v.HumanoidRootPart.BrickColor = BrickColor.new("Medium stone grey")
                    end)
                end
            end
        end
    end
end)

-- LOGIC 7: ESP
local highlights = {}
RunService.Heartbeat:Connect(function()
    if toggles.ESP then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                if not highlights[plr] then
                    local h = Instance.new("Highlight")
                    h.Adornee = plr.Character
                    h.FillColor = Color3.fromRGB(255, 0, 0)
                    h.OutlineColor = Color3.fromRGB(255, 255, 255)
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Parent = plr.Character
                    highlights[plr] = h
                end
            end
        end
    else
        for plr, h in pairs(highlights) do
            if h then h:Destroy() end
            highlights[plr] = nil
        end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if highlights[plr] then
        highlights[plr]:Destroy()
        highlights[plr] = nil
    end
end)

print("CoS Hub v3.0 Loaded!")
