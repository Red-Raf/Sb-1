local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local AutoGrab = false
local GunNotify = false
local SuccessNotify = false
local SpeedGlitch = false
local SpeedValue = 50
local FireAura = false
local FireColor = Color3.fromRGB(255, 255, 255)

local isGrabbing = false
local fireObjects = {}
local root, humanoid

local function getParent()
    local p
    pcall(function()
        if gethui then p = gethui() end
    end)
    if not p then
        pcall(function() p = game:GetService("CoreGui") end)
    end
    if not p then
        p = LocalPlayer:WaitForChild("PlayerGui", 5)
    end
    return p
end

local function notify(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 3
        })
    end)
end

local function hasGun()
    local char = LocalPlayer.Character
    return LocalPlayer.Backpack:FindFirstChild("Gun") or (char and char:FindFirstChild("Gun"))
end

local function GrabGun()
    if isGrabbing or hasGun() then return end
    isGrabbing = true

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        isGrabbing = false
        return
    end

    for i = 1, 45 do
        if hasGun() then break end
        local drop = Workspace:FindFirstChild("GunDrop", true)
        if drop then
            pcall(function()
                local target = hrp.CFrame * CFrame.new(0, 1.15, 0)
                if drop:IsA("BasePart") then
                    drop.Anchored = false
                    drop.CanCollide = false
                    drop.CFrame = target
                else
                    local part = drop:FindFirstChild("Handle") or drop:FindFirstChildWhichIsA("BasePart") or drop.PrimaryPart
                    if part then
                        part.Anchored = false
                        part.CanCollide = false
                        part.CFrame = target
                    end
                end
            end)
        end
        task.wait(0.03)
    end

    if hasGun() and SuccessNotify then
        notify("GrabGun", "Пистолет взят")
    end
    isGrabbing = false
end

Workspace.DescendantAdded:Connect(function(obj)
    if obj.Name == "GunDrop" then
        task.wait(0.1)
        if GunNotify then
            notify("Gun Drop", "Пистолет выпал")
        end
        if AutoGrab then
            task.spawn(GrabGun)
        end
    end
end)

local function clearFire()
    for _, v in ipairs(fireObjects) do
        pcall(function() v:Destroy() end)
    end
    table.clear(fireObjects)
end

local function applyFire()
    clearFire()
    local char = LocalPlayer.Character
    if not FireAura or not char then return end

    local count = 0
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Name \~= "HumanoidRootPart" then
            count += 1
            if count > 6 then break end

            local att = Instance.new("Attachment")
            att.Parent = part

            local em = Instance.new("ParticleEmitter")
            em.Texture = "rbxasset://textures/particles/fire_main.dds"
            em.Color = ColorSequence.new(FireColor)
            em.Size = NumberSequence.new(0.65)
            em.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.25),
                NumberSequenceKeypoint.new(1, 1)
            })
            em.Lifetime = NumberRange.new(0.4, 0.75)
            em.Rate = 11
            em.Speed = NumberRange.new(1, 2.2)
            em.SpreadAngle = Vector2.new(18, 18)
            em.LightEmission = 0.55
            em.Parent = att

            table.insert(fireObjects, em)
            table.insert(fireObjects, att)
        end
    end
end

local function setFireColor(color)
    FireColor = color
    for _, em in ipairs(fireObjects) do
        if em:IsA("ParticleEmitter") then
            em.Color = ColorSequence.new(color)
        end
    end
end

local function onCharacter(char)
    root = char:WaitForChild("HumanoidRootPart", 2)
    humanoid = char:WaitForChild("Humanoid", 2)
    clearFire()
    if FireAura then
        task.delay(0.4, applyFire)
    end
end

LocalPlayer.CharacterAdded:Connect(onCharacter)
if LocalPlayer.Character then
    task.spawn(onCharacter, LocalPlayer.Character)
end

RunService.Heartbeat:Connect(function()
    if SpeedGlitch and root and humanoid and humanoid.FloorMaterial == Enum.Material.Air then
        local dir = humanoid.MoveDirection
        if dir.Magnitude > 0.05 then
            local vel = root.AssemblyLinearVelocity
            root.AssemblyLinearVelocity = Vector3.new(dir.X * SpeedValue, vel.Y, dir.Z * SpeedValue)
        end
    end
end)

-- UI
local gui = Instance.new("ScreenGui")
gui.Name = "Hub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.Parent = getParent()

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 190, 0, 350)
frame.Position = UDim2.new(0.5, -95, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 26)
title.BackgroundTransparency = 1
title.Text = "Hub"
title.TextColor3 = Color3.fromRGB(0, 255, 120)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local function makeToggle(name, y, callback)
    local state = false
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 160, 0, 26)
    b.Position = UDim2.new(0.5, -80, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    b.Text = name .. ": OFF"
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.Parent = frame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

    b.MouseButton1Click:Connect(function()
        state = not state
        b.Text = name .. (state and ": ON" or ": OFF")
        b.BackgroundColor3 = state and Color3.fromRGB(0, 150, 60) or Color3.fromRGB(50, 50, 50)
        callback(state)
    end)
end

makeToggle("Auto Grab", 35, function(v) AutoGrab = v end)
makeToggle("Gun Notify", 65, function(v) GunNotify = v end)
makeToggle("Success Notify", 95, function(v) SuccessNotify = v end)
makeToggle("Speed Glitch", 125, function(v) SpeedGlitch = v end)

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0, 75, 0, 24)
speedBox.Position = UDim2.new(0, 15, 0, 158)
speedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedBox.Text = "50"
speedBox.TextColor3 = Color3.new(1, 1, 1)
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 12
speedBox.Parent = frame
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 5)

local applyBtn = Instance.new("TextButton")
applyBtn.Size = UDim2.new(0, 75, 0, 24)
applyBtn.Position = UDim2.new(0, 100, 0, 158)
applyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 150)
applyBtn.Text = "Apply"
applyBtn.TextColor3 = Color3.new(1, 1, 1)
applyBtn.Font = Enum.Font.Gotham
applyBtn.TextSize = 12
applyBtn.Parent = frame
Instance.new("UICorner", applyBtn).CornerRadius = UDim.new(0, 5)
applyBtn.MouseButton1Click:Connect(function()
    local n = tonumber(speedBox.Text)
    if n and n > 0 then SpeedValue = n end
end)

makeToggle("Fire Aura", 195, function(v)
    FireAura = v
    if v then applyFire() else clearFire() end
end)

local colors = {
    {Color3.fromRGB(255, 255, 255), "W"},
    {Color3.fromRGB(0, 140, 255), "B"},
    {Color3.fromRGB(0, 220, 200), "C"},
    {Color3.fromRGB(0, 200, 70), "G"},
    {Color3.fromRGB(255, 200, 0), "Y"},
    {Color3.fromRGB(255, 50, 50), "R"},
}

for i, data in ipairs(colors) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 26, 0, 22)
    b.Position = UDim2.new(0, 14 + (i-1)*28, 0, 230)
    b.BackgroundColor3 = data[1]
    b.Text = data[2]
    b.TextColor3 = Color3.new(0, 0, 0)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.Parent = frame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.MouseButton1Click:Connect(function()
        setFireColor(data[1])
    end)
end

local grabBtn = Instance.new("TextButton")
grabBtn.Size = UDim2.new(0, 75, 0, 28)
grabBtn.Position = UDim2.new(0, 15, 0, 270)
grabBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 180)
grabBtn.Text = "Grab"
grabBtn.TextColor3 = Color3.new(1, 1, 1)
grabBtn.Font = Enum.Font.Gotham
grabBtn.TextSize = 13
grabBtn.Parent = frame
Instance.new("UICorner", grabBtn).CornerRadius = UDim.new(0, 6)
grabBtn.MouseButton1Click:Connect(function()
    task.spawn(GrabGun)
end)

local statusBtn = Instance.new("TextButton")
statusBtn.Size = UDim2.new(0, 75, 0, 28)
statusBtn.Position = UDim2.new(0, 100, 0, 270)
statusBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
statusBtn.Text = "Status"
statusBtn.TextColor3 = Color3.new(1, 1, 1)
statusBtn.Font = Enum.Font.Gotham
statusBtn.TextSize = 13
statusBtn.Parent = frame
Instance.new("UICorner", statusBtn).CornerRadius = UDim.new(0, 6)
statusBtn.MouseButton1Click:Connect(function()
    local has = hasGun()
    local drop = Workspace:FindFirstChild("GunDrop", true)
    notify("Status", has and "Gun в инвентаре" or (drop and "GunDrop на карте" or "Нет пистолета"))
end)

notify("Hub", "Загружен")
print("Full Hub loaded")
