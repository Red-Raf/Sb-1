local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "DustWayUI" then v:Destroy() end
end

_G.DustWay = {
    ESPEnabled = false,
    ShowMurderer = true,
    ShowSheriff = true,
    ShowHero = true,
    ShowInnocent = true,
    ShowSelf = true,
    GunESP = true,
    AutoShoot = false,
    PingPrediction = false,
    FlyEnabled = false,
    FlySpeed = 50,
    SpeedGlitch = false,
    SpeedGlitchSpeed = 200,
    AntiFling = false,
    VelocityCap = 200,
    WalkSpeed = 16,
    ESPRange = 200,
    LowGraphics = false,
    HighGraphics = false,
}

local RoleColors = {
    Murderer = Color3.fromRGB(255, 40, 40),
    Sheriff = Color3.fromRGB(40, 130, 255),
    Hero = Color3.fromRGB(255, 215, 0),
    Innocent = Color3.fromRGB(0, 220, 0),
}

local ESPObjects = {}
local flying = false
local flyBV, flyBG, flyConnection
local flingActive = false
local speedConn
local antiFlingConn
local gunESP, gunESPBillboard, gunMarker
local n1 = 200
local n2 = 200

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DustWayUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = CoreGui

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 60, 0, 60)
openBtn.Position = UDim2.new(0, 20, 0.5, -30)
openBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
openBtn.Text = "🐍"
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.TextScaled = true
openBtn.Font = Enum.Font.GothamBold
openBtn.BorderSizePixel = 0
openBtn.Parent = screenGui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "DustWay"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 7)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

openBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

local dragging = false
local dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 35)
tabBar.Position = UDim2.new(0, 0, 0, 45)
tabBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
tabBar.BorderSizePixel = 0
tabBar.Parent = mainFrame

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -80)
contentFrame.Position = UDim2.new(0, 0, 0, 80)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local tabNames = {"Главная", "Визуал", "Бой", "Движение", "Разное"}
local tabs = {}
local currentTab = "Главная"

for i, name in ipairs(tabNames) do
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(0.2, 0, 1, 0)
    tab.Position = UDim2.new((i-1) * 0.2, 0, 0, 0)
    tab.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    tab.Text = name
    tab.TextColor3 = Color3.fromRGB(180, 180, 180)
    tab.TextScaled = true
    tab.Font = Enum.Font.GothamBold
    tab.BorderSizePixel = 0
    tab.Parent = tabBar
    tabs[name] = tab
    tab.MouseButton1Click:Connect(function()
        currentTab = name
        for n, t in pairs(tabs) do
            if n == name then
                t.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                t.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                t.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
                t.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
        end
        UpdateContent()
    end)
end

local function createToggle(parent, name, flag, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.92, 0, 0, 40)
    frame.Position = UDim2.new(0.04, 0, 0, #parent:GetChildren() * 45 + 5)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0.03, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 28)
    btn.Position = UDim2.new(1, -70, 0.5, -14)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(60, 60, 60)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(60, 60, 60)
        btn.Text = state and "ON" or "OFF"
        if callback then callback(state) end
    end)
end

local function createSlider(parent, name, flag, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.92, 0, 0, 55)
    frame.Position = UDim2.new(0.04, 0, 0, #parent:GetChildren() * 60 + 5)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 22)
    label.Position = UDim2.new(0, 10, 0, 3)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(0.9, 0, 0, 8)
    sliderBg.Position = UDim2.new(0.05, 0, 0, 30)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dragBtn = Instance.new("TextButton")
    dragBtn.Size = UDim2.new(0, 20, 0, 20)
    dragBtn.Position = UDim2.new((default - min) / (max - min), -10, 0.5, -10)
    dragBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dragBtn.Text = ""
    dragBtn.BorderSizePixel = 0
    dragBtn.Parent = sliderBg
    Instance.new("UICorner", dragBtn).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function updateSlider(input)
        local relX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local val = math.round(min + relX * (max - min))
        fill.Size = UDim2.new(relX, 0, 1, 0)
        dragBtn.Position = UDim2.new(relX, -10, 0.5, -10)
        label.Text = name .. ": " .. val
        if callback then callback(val) end
    end

    dragBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function createButton(parent, name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.92, 0, 0, 40)
    btn.Position = UDim2.new(0.04, 0, 0, #parent:GetChildren() * 45 + 5)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
end

function GetRole(player)
    if player:GetAttribute("Role") then return player:GetAttribute("Role") end
    local ls = player:FindFirstChild("leaderstats")
    if ls then local r = ls:FindFirstChild("Role"); if r then return r.Value end end
    local bp = player:FindFirstChild("Backpack")
    if bp then
        for _, t in pairs(bp:GetChildren()) do
            if t:IsA("Tool") then
                if t.Name:match("Knife") or t.Name:match("Dagger") then return "Murderer" end
                if t.Name:match("Gun") or t.Name:match("Pistol") then return "Sheriff" end
            end
        end
    end
    local ch = player.Character
    if ch then
        for _, t in pairs(ch:GetChildren()) do
            if t:IsA("Tool") then
                if t.Name:match("Knife") or t.Name:match("Dagger") then return "Murderer" end
                if t.Name:match("Gun") or t.Name:match("Pistol") then return "Sheriff" end
            end
        end
    end
    return "Innocent"
end

function GetMurderer()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            for _, t in pairs(p.Character:GetChildren()) do
                if t:IsA("Tool") and (t.Name:match("Knife") or t.Name:match("Dagger")) then return p end
            end
            local bp = p:FindFirstChild("Backpack")
            if bp then for _, t in pairs(bp:GetChildren()) do if t:IsA("Tool") and (t.Name:match("Knife") or t.Name:match("Dagger")) then return p end end end
        end
    end
    return nil
end

function GetSheriff()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            for _, t in pairs(p.Character:GetChildren()) do
                if t:IsA("Tool") and (t.Name:match("Gun") or t.Name:match("Pistol")) then return p end
            end
            local bp = p:FindFirstChild("Backpack")
            if bp then for _, t in pairs(bp:GetChildren()) do if t:IsA("Tool") and (t.Name:match("Gun") or t.Name:match("Pistol")) then return p end end end
        end
    end
    return nil
end

function CreateESP(player)
    if player == LocalPlayer and not _G.DustWay.ShowSelf then return end
    local char = player.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    if ESPObjects[player] then for _, o in pairs(ESPObjects[player]) do o:Destroy() end; ESPObjects[player] = nil end
    local role = GetRole(player)
    if role == "Murderer" and not _G.DustWay.ShowMurderer then return end
    if role == "Sheriff" and not _G.DustWay.ShowSheriff then return end
    if role == "Hero" and not _G.DustWay.ShowHero then return end
    if role == "Innocent" and not _G.DustWay.ShowInnocent then return end
    local color = RoleColors[role] or Color3.fromRGB(0, 220, 0)
    local hl = Instance.new("Highlight")
    hl.Name = "DustWay_ESP"
    hl.Adornee = char
    hl.FillColor = color
    hl.FillTransparency = 0.7
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.OutlineTransparency = 0.15
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = char
    local bg = Instance.new("BillboardGui")
    bg.Size = UDim2.new(0, 200, 0, 40)
    bg.AlwaysOnTop = true
    bg.Adornee = head
    bg.Parent = char
    local lbl = Instance.new("TextLabel", bg)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = player.Name .. " [" .. role .. "]"
    lbl.TextColor3 = color
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBold
    ESPObjects[player] = {hl, bg}
end

function ClearESP()
    for _, objs in pairs(ESPObjects) do for _, o in pairs(objs) do o:Destroy() end end
    ESPObjects = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            local hl = p.Character:FindFirstChild("DustWay_ESP")
            if hl then hl:Destroy() end
            local bg = p.Character:FindFirstChildOfClass("BillboardGui")
            if bg and bg:FindFirstChild("TextLabel") then bg:Destroy() end
        end
    end
end

function ClearGunESP()
    if gunESP then gunESP:Destroy(); gunESP = nil end
    if gunESPBillboard then gunESPBillboard:Destroy(); gunESPBillboard = nil end
    if gunMarker then gunMarker:Destroy(); gunMarker = nil end
end

function CreateGunESP(gun)
    ClearGunESP()
    local part = gun:IsA("BasePart") and gun or (gun:FindFirstChild("Handle") or gun:FindFirstChildWhichIsA("BasePart") or gun.PrimaryPart)
    if not part then return end
    gunESP = Instance.new("Highlight")
    gunESP.Adornee = gun
    gunESP.FillColor = Color3.fromRGB(255, 215, 0)
    gunESP.OutlineColor = Color3.fromRGB(255, 255, 255)
    gunESP.FillTransparency = 0.35
    gunESP.OutlineTransparency = 0
    gunESP.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    gunESP.Parent = gun
    gunMarker = Instance.new("Part")
    gunMarker.Size = Vector3.new(1.5, 0.15, 1.5)
    gunMarker.Anchored = true
    gunMarker.CanCollide = false
    gunMarker.CastShadow = false
    gunMarker.Material = Enum.Material.Neon
    gunMarker.Color = Color3.fromRGB(50, 255, 80)
    gunMarker.Transparency = 0.25
    gunMarker.CFrame = CFrame.new(part.Position)
    gunMarker.Parent = Workspace
    gunESPBillboard = Instance.new("BillboardGui")
    gunESPBillboard.Adornee = part
    gunESPBillboard.Size = UDim2.new(0, 130, 0, 36)
    gunESPBillboard.StudsOffset = Vector3.new(0, 4, 0)
    gunESPBillboard.AlwaysOnTop = true
    gunESPBillboard.MaxDistance = 300
    gunESPBillboard.Parent = part
    local fr = Instance.new("Frame", gunESPBillboard)
    fr.Size = UDim2.new(1, 0, 1, 0)
    fr.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    fr.BackgroundTransparency = 0.4
    fr.BorderSizePixel = 0
    Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 6)
    local st = Instance.new("UIStroke", fr)
    st.Color = Color3.fromRGB(255, 215, 0)
    st.Thickness = 1.5
    local tl = Instance.new("TextLabel", fr)
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.BackgroundTransparency = 1
    tl.Text = "GUN ON MAP"
    tl.TextColor3 = Color3.fromRGB(255, 215, 0)
    tl.Font = Enum.Font.GothamBlack
    tl.TextSize = 13
end

Workspace.DescendantAdded:Connect(function(d)
    if d.Name == "GunDrop" and _G.DustWay.GunESP then
        task.wait(0.1)
        CreateGunESP(d)
    end
end)

function FlingPlayer(target)
    if flingActive then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end
    local tChar = target.Character
    if not tChar then return end
    local tHumanoid = tChar:FindFirstChildOfClass("Humanoid")
    local tRoot = tHumanoid and tHumanoid.RootPart
    local tHead = tChar:FindFirstChild("Head")
    if not tRoot and not tHead then return end
    flingActive = true
    local oldPos = hrp.CFrame
    Workspace.FallenPartsDestroyHeight = 0 / 0
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = hrp
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    local targetPart = tHead or tRoot
    task.spawn(function()
        local startTime = tick()
        while tick() - startTime < 2.5 do
            if not targetPart or not targetPart.Parent then break end
            hrp.CFrame = CFrame.new(targetPart.Position) * CFrame.new(0, 1.5, 0) * CFrame.Angles(math.rad(90), 0, 0)
            hrp.Velocity = Vector3.new(9e7, 9e8, 9e7)
            hrp.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
            task.wait()
            hrp.CFrame = CFrame.new(targetPart.Position) * CFrame.new(0, -1.5, 0) * CFrame.Angles(0, 0, 0)
            hrp.Velocity = Vector3.new(9e7, 9e8, 9e7)
            hrp.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
            task.wait()
        end
    end)
    task.wait(2.5)
    bv:Destroy()
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    hrp.CFrame = oldPos * CFrame.new(0, 0.5, 0)
    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    for _, p in pairs(char:GetChildren()) do
        if p:IsA("BasePart") then p.Velocity = Vector3.new(); p.RotVelocity = Vector3.new() end
    end
    Workspace.FallenPartsDestroyHeight = -500
    flingActive = false
end

function StartFly()
    if flying then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end
    flying = true
    humanoid.PlatformStand = true
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBV.Velocity = Vector3.new(0, 0, 0)
    flyBV.Parent = hrp
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    flyBG.P = 9e4
    flyBG.CFrame = hrp.CFrame
    flyBG.Parent = hrp
    flyConnection = RunService.RenderStepped:Connect(function()
        if not _G.DustWay.FlyEnabled then return end
        if not hrp or not hrp.Parent then return end
        local moveDir = Vector3.new()
        local cam = Workspace.CurrentCamera
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0, 1, 0) end
        if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
        flyBV.Velocity = moveDir * _G.DustWay.FlySpeed
        flyBG.CFrame = cam.CFrame
    end)
end

function StopFly()
    flying = false
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if flyBV then flyBV:Destroy(); flyBV = nil end
    if flyBG then flyBG:Destroy(); flyBG = nil end
    local char = LocalPlayer.Character
    if char then
        local h = char:FindFirstChildOfClass("Humanoid")
        if h then h.PlatformStand = false end
    end
end

function StartSpeedGlitch()
    if speedConn then speedConn:Disconnect() end
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    speedConn = RunService.RenderStepped:Connect(function()
        if not _G.DustWay.SpeedGlitch then humanoid.WalkSpeed = 16; return end
        local state = humanoid:GetState()
        if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall then
            humanoid.WalkSpeed = humanoid.MoveDirection.Magnitude > 0 and _G.DustWay.SpeedGlitchSpeed or 16
        else
            humanoid.WalkSpeed = 16
        end
    end)
end

function StopSpeedGlitch()
    if speedConn then speedConn:Disconnect(); speedConn = nil end
    local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed = 16 end
end

function StartAntiFling()
    if antiFlingConn then antiFlingConn:Disconnect() end
    antiFlingConn = RunService.Heartbeat:Connect(function()
        if not _G.DustWay.AntiFling then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local vel = hrp.AssemblyLinearVelocity
            if vel.Magnitude > _G.DustWay.VelocityCap then hrp.AssemblyLinearVelocity = vel.Unit * _G.DustWay.VelocityCap end
        end
    end)
end

function StopAntiFling()
    if antiFlingConn then antiFlingConn:Disconnect(); antiFlingConn = nil end
end

function UpdateContent()
    for _, child in pairs(contentFrame:GetChildren()) do child:Destroy() end

    if currentTab == "Главная" then
        createButton(contentFrame, "🔫 Выстрелить в убийцу", function()
            local murderer = GetMurderer()
            if murderer and murderer.Character then
                local gun = LocalPlayer.Backpack:FindFirstChild("Gun") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun"))
                if gun then
                    if LocalPlayer.Character ~= gun.Parent then LocalPlayer.Character.Humanoid:EquipTool(gun); task.wait() end
                    local target = murderer.Character:FindFirstChild("UpperTorso") or murderer.Character:FindFirstChild("Torso") or murderer.Character:FindFirstChild("HumanoidRootPart")
                    if target then
                        local shoot = gun:FindFirstChild("Shoot")
                        if shoot then pcall(function() shoot:FireServer(CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 1, 0), target.Position), CFrame.new(target.Position)) end) end
                    end
                end
            end
        end)
        createButton(contentFrame, "🔪 Бросить нож", function()
            local murderer = GetMurderer()
            if murderer and murderer.Character then
                local knife = LocalPlayer.Backpack:FindFirstChild("Knife") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Knife"))
                if knife then
                    if LocalPlayer.Character ~= knife.Parent then LocalPlayer.Character.Humanoid:EquipTool(knife); task.wait() end
                    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local target = murderer.Character:FindFirstChild("UpperTorso") or murderer.Character:FindFirstChild("Torso") or murderer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and target then
                        local vel = target.AssemblyLinearVelocity
                        local dist = (target.Position - hrp.Position).Magnitude
                        local ping = 0
                        if _G.DustWay.PingPrediction then local ok, p = pcall(function() return LocalPlayer:GetNetworkPing() end); ping = ok and p or 0 end
                        local throwPos = target.Position + Vector3.new(vel.X, 0, vel.Z) * (dist / 65 + ping * 0.5)
                        pcall(function() knife.Events.KnifeThrown:FireServer(CFrame.new(hrp.Position, throwPos), CFrame.new(throwPos)) end)
                    end
                end
            end
        end)
        createButton(contentFrame, "💥 Флинг убийцы", function()
            local murderer = GetMurderer()
            if murderer then FlingPlayer(murderer) end
        end)
        createButton(contentFrame, "🎯 Grab Gun", function()
            local gun = Workspace:FindFirstChild("GunDrop", true)
            if gun and LocalPlayer.Character then
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local pos = gun:IsA("BasePart") and gun.Position or (gun:FindFirstChild("Handle") and gun.Handle.Position) or gun:GetModelCFrame().Position
                    if pos then
                        local old = hrp.CFrame
                        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
                        task.wait(0.2)
                        hrp.CFrame = old
                    end
                end
            end
        end)
    elseif currentTab == "Визуал" then
        createToggle(contentFrame, "ESP Вкл", "ESPEnabled", false, function(v)
            _G.DustWay.ESPEnabled = v
            if v then for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
            else ClearESP() end
        end)
        createToggle(contentFrame, "Убийца", "ShowMurderer", true, function(v) _G.DustWay.ShowMurderer = v end)
        createToggle(contentFrame, "Шериф", "ShowSheriff", true, function(v) _G.DustWay.ShowSheriff = v end)
        createToggle(contentFrame, "Герой", "ShowHero", true, function(v) _G.DustWay.ShowHero = v end)
        createToggle(contentFrame, "Невинные", "ShowInnocent", true, function(v) _G.DustWay.ShowInnocent = v end)
        createToggle(contentFrame, "Себя", "ShowSelf", true, function(v) _G.DustWay.ShowSelf = v end)
        createToggle(contentFrame, "ESP оружия", "GunESP", true, function(v) _G.DustWay.GunESP = v; if not v then ClearGunESP() end end)
    elseif currentTab == "Бой" then
        createToggle(contentFrame, "Авто-шот убийцы", "AutoShoot", false, function(v) _G.DustWay.AutoShoot = v end)
        createToggle(contentFrame, "Ping Prediction", "PingPrediction", false, function(v) _G.DustWay.PingPrediction = v end)
        createButton(contentFrame, "🔫 Выстрелить сейчас", function()
            local murderer = GetMurderer()
            if murderer and murderer.Character then
                local gun = LocalPlayer.Backpack:FindFirstChild("Gun") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun"))
                if gun then
                    if LocalPlayer.Character ~= gun.Parent then LocalPlayer.Character.Humanoid:EquipTool(gun); task.wait() end
                    local target = murderer.Character:FindFirstChild("UpperTorso") or murderer.Character:FindFirstChild("Torso") or murderer.Character:FindFirstChild("HumanoidRootPart")
                    if target then
                        local shoot = gun:FindFirstChild("Shoot")
                        if shoot then pcall(function() shoot:FireServer(CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 1, 0), target.Position), CFrame.new(target.Position)) end) end
                    end
                end
            end
        end)
        createButton(contentFrame, "💥 Флинг убийцы", function() local m = GetMurderer(); if m then FlingPlayer(m) end end)
        createButton(contentFrame, "💥 Флинг шерифа", function() local s = GetSheriff(); if s then FlingPlayer(s) end end)
    elseif currentTab == "Движение" then
        createSlider(contentFrame, "WalkSpeed", "WalkSpeed", 16, 100, 16, function(v)
            _G.DustWay.WalkSpeed = v
            if LocalPlayer.Character then local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed = v end end
        end)
        createToggle(contentFrame, "Speed Glitch", "SpeedGlitch", false, function(v) _G.DustWay.SpeedGlitch = v; if v then StartSpeedGlitch() else StopSpeedGlitch() end end)
        createSlider(contentFrame, "Speed Glitch Speed", "SpeedGlitchSpeed", 50, 600, 200, function(v) _G.DustWay.SpeedGlitchSpeed = v end)
        createToggle(contentFrame, "Полёт (WASD + Space)", "FlyEnabled", false, function(v) _G.DustWay.FlyEnabled = v; if v then StartFly() else StopFly() end end)
        createSlider(contentFrame, "Скорость полёта", "FlySpeed", 10, 200, 50, function(v) _G.DustWay.FlySpeed = v end)
        createToggle(contentFrame, "Anti-Fling", "AntiFling", false, function(v) _G.DustWay.AntiFling = v; if v then StartAntiFling() else StopAntiFling() end end)
        createSlider(contentFrame, "Velocity Cap", "VelocityCap", 50, 500, 200, function(v) _G.DustWay.VelocityCap = v end)
    elseif currentTab == "Разное" then
        createButton(contentFrame, "🌌 Восстановить небо", function()
            for _, c in pairs(Lighting:GetChildren()) do
                if c:IsA("Sky") or c:IsA("Atmosphere") or c:IsA("Clouds") then c:Destroy() end
            end
            local sky = Instance.new("Sky", Lighting)
            sky.SkyboxBk = "rbxassetid://159454299"
            sky.SkyboxDn = "rbxassetid://159454296"
            sky.SkyboxFt = "rbxassetid://159454293"
            sky.SkyboxLf = "rbxassetid://159454286"
            sky.SkyboxRt = "rbxassetid://159454300"
            sky.SkyboxUp = "rbxassetid://159454288"
        end)
        createToggle(contentFrame, "Низкая графика", "LowGraphics", false, function(v)
            if v then
                pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
                Lighting.GlobalShadows = false
                Lighting.Brightness = 2
                for _, d in pairs(Workspace:GetDescendants()) do
                    if d:IsA("BasePart") then d.Material = Enum.Material.SmoothPlastic; d.CastShadow = false end
                    if d:IsA("Decal") or d:IsA("Texture") then d.Transparency = 1 end
                end
            else
                pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
            end
        end)
        createToggle(contentFrame, "Высокая графика", "HighGraphics", false, function(v)
            if v then
                pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level21 end)
                Lighting.GlobalShadows = true
                Lighting.Brightness = 3.5
                if not Lighting:FindFirstChildOfClass("BloomEffect") then Instance.new("BloomEffect", Lighting) end
                if not Lighting:FindFirstChildOfClass("SunRaysEffect") then Instance.new("SunRaysEffect", Lighting) end
                if not Lighting:FindFirstChildOfClass("ColorCorrectionEffect") then Instance.new("ColorCorrectionEffect", Lighting) end
            else
                pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
                for _, c in pairs(Lighting:GetChildren()) do
                    if c:IsA("BloomEffect") or c:IsA("SunRaysEffect") or c:IsA("ColorCorrectionEffect") then c:Destroy() end
                end
            end
        end)
        createButton(contentFrame, "Infinite Yield", function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        end)
        createButton(contentFrame, "Emotes GUI", function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua'))()
        end)
    end
end

RunService.RenderStepped:Connect(function()
    if not _G.DustWay.ESPEnabled then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            if not ESPObjects[p] then CreateESP(p) end
        end
    end
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        if _G.DustWay.ESPEnabled then CreateESP(p) end
    end)
end)

tabs["Главная"].BackgroundColor3 = Color3.fromRGB(30, 30, 30)
tabs["Главная"].TextColor3 = Color3.fromRGB(255, 255, 255)
UpdateContent()

print("[DustWay] загружен. Нажми 🐍 для открытия меню.")