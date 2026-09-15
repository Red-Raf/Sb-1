local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImInsane-1337/neverlose-ui/refs/heads/main/source/library.lua"))()
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera
_G.DustWay_ESPEnabled = false
_G.DustWay_GunESP = true
_G.DustWay_AutoShoot = false
_G.DustWay_FlyEnabled = false
_G.DustWay_SpeedEnabled = false
_G.DustWay_AntiFling = false
_G.DustWay_PingPrediction = false
_G.DustWay_VelocityCap = 200
_G.DustWay_WalkSpeed = 16
_G.DustWay_FlySpeed = 50
_G.DustWay_SpeedGlitchSpeed = 200
local RoleColors = {Murderer = Color3.fromRGB(255,40,40), Sheriff = Color3.fromRGB(40,130,255), Hero = Color3.fromRGB(255,215,0), Innocent = Color3.fromRGB(0,220,0)}
local RoleToggles = {Murderer = true, Sheriff = true, Hero = true, Innocent = true, Self = true}
local ESPObjects = {}
local flying = false
local flyBV, flyBG, flyConnection
local flingActive = false
local speedConn
local antiFlingConn
local gunESP, gunESPBillboard, gunMarker
local n17 = 0.5
local n1 = 200
local n2 = 200
local n3 = 70
local Window = Library:Window({Name = "DustWay", SubName = "MM2 Ultimate", Logo = "1234567890", MenuKeybind = Enum.KeyCode.K, Size = UDim2.fromOffset(650,550)})
local MainPage = Window:Page({Name = "Главная", Icon = "home"})
local VisualPage = Window:Page({Name = "Визуал", Icon = "eye"})
local CombatPage = Window:Page({Name = "Бой", Icon = "sword"})
local MovementPage = Window:Page({Name = "Движение", Icon = "plane"})
local MiscPage = Window:Page({Name = "Разное", Icon = "settings"})
local ProfileSection = MainPage:Section({Name = "Профиль", Side = 1})
ProfileSection:Label({Name = "👤 " .. LocalPlayer.Name})
ProfileSection:Label({Name = "🖼️ ID: " .. LocalPlayer.UserId})
ProfileSection:Label({Name = "🎮 Игроков: " .. #Players:GetPlayers()})
local RoleSection = MainPage:Section({Name = "Роли", Side = 1})
local murdererLabel = RoleSection:Label({Name = "🔪 Убийца: поиск..."})
local sheriffLabel = RoleSection:Label({Name = "🔫 Шериф: поиск..."})
task.spawn(function()
    while task.wait(1) do
        local murderer, sheriff = nil, nil
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local bp = player:FindFirstChild("Backpack")
                local ch = player.Character
                if bp then
                    if bp:FindFirstChild("Knife") or (ch and ch:FindFirstChild("Knife")) then murderer = player.Name
                    elseif bp:FindFirstChild("Gun") or (ch and ch:FindFirstChild("Gun")) then sheriff = player.Name end
                end
            end
        end
        murdererLabel:Set("🔪 Убийца: " .. (murderer or "не найден"))
        sheriffLabel:Set("🔫 Шериф: " .. (sheriff or "не найден"))
    end
end)
local QuickSection = MainPage:Section({Name = "Быстрые действия", Side = 2})
QuickSection:Button({Name = "🔫 Выстрелить", Callback = function()
    local murderer = GetMurderer()
    if murderer and murderer.Character then
        local gun = LocalPlayer.Backpack:FindFirstChild("Gun") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun"))
        if gun then
            if LocalPlayer.Character ~= gun.Parent then LocalPlayer.Character.Humanoid:EquipTool(gun); task.wait() end
            local target = murderer.Character:FindFirstChild("UpperTorso") or murderer.Character:FindFirstChild("Torso") or murderer.Character:FindFirstChild("HumanoidRootPart")
            if target then
                local shoot = gun:FindFirstChild("Shoot")
                if shoot then pcall(function() shoot:FireServer(CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0,1,0), target.Position), CFrame.new(target.Position)) end) end
            end
        end
    end
end})
QuickSection:Button({Name = "🔪 Бросить нож", Callback = function()
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
                if _G.DustWay_PingPrediction then local ok, p = pcall(function() return LocalPlayer:GetNetworkPing() end); ping = ok and p or 0 end
                local throwPos = target.Position + Vector3.new(vel.X, 0, vel.Z) * (dist / 65 + ping * 0.5)
                pcall(function() knife.Events.KnifeThrown:FireServer(CFrame.new(hrp.Position, throwPos), CFrame.new(throwPos)) end)
            end
        end
    end
end})
QuickSection:Button({Name = "💥 Флинг убийцы", Callback = function()
    local murderer = GetMurderer()
    if murderer then FlingPlayer(murderer) end
end})
QuickSection:Button({Name = "🎯 Grab Gun", Callback = function()
    local gun = Workspace:FindFirstChild("GunDrop", true)
    if gun and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local pos = gun:IsA("BasePart") and gun.Position or (gun:FindFirstChild("Handle") and gun.Handle.Position) or gun:GetModelCFrame().Position
            if pos then
                local old = hrp.CFrame
                hrp.CFrame = CFrame.new(pos + Vector3.new(0,2,0))
                task.wait(0.2)
                hrp.CFrame = old
            end
        end
    end
end})
local ESPSection = VisualPage:Section({Name = "ESP", Side = 1})
ESPSection:Toggle({Name = "ESP Вкл", Flag = "ESPEnabled", Default = false, Callback = function(v)
    _G.DustWay_ESPEnabled = v
    if v then for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
    else ClearESP() end
end})
ESPSection:Toggle({Name = "Показывать убийцу", Flag = "ShowMurderer", Default = true, Callback = function(v) RoleToggles.Murderer = v end})
ESPSection:Toggle({Name = "Показывать шерифа", Flag = "ShowSheriff", Default = true, Callback = function(v) RoleToggles.Sheriff = v end})
ESPSection:Toggle({Name = "Показывать героя", Flag = "ShowHero", Default = true, Callback = function(v) RoleToggles.Hero = v end})
ESPSection:Toggle({Name = "Показывать невинных", Flag = "ShowInnocent", Default = true, Callback = function(v) RoleToggles.Innocent = v end})
ESPSection:Toggle({Name = "Показывать себя", Flag = "ShowSelf", Default = true, Callback = function(v) RoleToggles.Self = v end})
VisualPage:Section({Name = "ESP оружия", Side = 1}):Toggle({Name = "ESP выпавшего оружия", Flag = "GunESP", Default = true, Callback = function(v) _G.DustWay_GunESP = v; if not v then ClearGunESP() end end})
local ColorSection = VisualPage:Section({Name = "Цвета ролей", Side = 2})
ColorSection:ColorPicker({Name = "Убийца", Flag = "MurdererColor", Default = Color3.fromRGB(255,40,40), Callback = function(v) RoleColors.Murderer = v end})
ColorSection:ColorPicker({Name = "Шериф", Flag = "SheriffColor", Default = Color3.fromRGB(40,130,255), Callback = function(v) RoleColors.Sheriff = v end})
ColorSection:ColorPicker({Name = "Герой", Flag = "HeroColor", Default = Color3.fromRGB(255,215,0), Callback = function(v) RoleColors.Hero = v end})
ColorSection:ColorPicker({Name = "Невинный", Flag = "InnocentColor", Default = Color3.fromRGB(0,220,0), Callback = function(v) RoleColors.Innocent = v end})
local AutoShootSection = CombatPage:Section({Name = "Авто-шот", Side = 1})
AutoShootSection:Toggle({Name = "Авто-шот убийцы", Flag = "AutoShoot", Default = false, Callback = function(v) _G.DustWay_AutoShoot = v end})
AutoShootSection:Toggle({Name = "Ping Prediction", Flag = "PingPrediction", Default = false, Callback = function(v) _G.DustWay_PingPrediction = v end})
AutoShootSection:Button({Name = "🔫 Выстрелить сейчас", Callback = function()
    local murderer = GetMurderer()
    if murderer and murderer.Character then
        local gun = LocalPlayer.Backpack:FindFirstChild("Gun") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun"))
        if gun then
            if LocalPlayer.Character ~= gun.Parent then LocalPlayer.Character.Humanoid:EquipTool(gun); task.wait() end
            local target = murderer.Character:FindFirstChild("UpperTorso") or murderer.Character:FindFirstChild("Torso") or murderer.Character:FindFirstChild("HumanoidRootPart")
            if target then
                local shoot = gun:FindFirstChild("Shoot")
                if shoot then pcall(function() shoot:FireServer(CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0,1,0), target.Position), CFrame.new(target.Position)) end) end
            end
        end
    end
end})
local FlingSection = CombatPage:Section({Name = "Флинг", Side = 1})
FlingSection:Button({Name = "💥 Флинг убийцы", Callback = function() local m = GetMurderer(); if m then FlingPlayer(m) end end})
FlingSection:Button({Name = "💥 Флинг шерифа", Callback = function() local s = GetSheriff(); if s then FlingPlayer(s) end end})
local ThrowSection = CombatPage:Section({Name = "Бросок ножа", Side = 2})
ThrowSection:Button({Name = "🔪 Бросить нож", Callback = function()
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
                if _G.DustWay_PingPrediction then local ok, p = pcall(function() return LocalPlayer:GetNetworkPing() end); ping = ok and p or 0 end
                local throwPos = target.Position + Vector3.new(vel.X, 0, vel.Z) * (dist / 65 + ping * 0.5)
                pcall(function() knife.Events.KnifeThrown:FireServer(CFrame.new(hrp.Position, throwPos), CFrame.new(throwPos)) end)
            end
        end
    end
end})
ThrowSection:Button({Name = "🔪 Бросить с пингом", Callback = function()
    _G.DustWay_PingPrediction = true
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
                local ok, p = pcall(function() return LocalPlayer:GetNetworkPing() end)
                local ping = ok and p or 0
                local throwPos = target.Position + Vector3.new(vel.X, 0, vel.Z) * (dist / 65 + ping * 0.5)
                pcall(function() knife.Events.KnifeThrown:FireServer(CFrame.new(hrp.Position, throwPos), CFrame.new(throwPos)) end)
            end
        end
    end
    _G.DustWay_PingPrediction = false
end})
local SpeedSection = MovementPage:Section({Name = "Скорость", Side = 1})
SpeedSection:Slider({Name = "WalkSpeed", Flag = "WalkSpeed", Min = 16, Max = 100, Default = 16, Suffix = " studs", Callback = function(v)
    _G.DustWay_WalkSpeed = v
    if LocalPlayer.Character then local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed = v end end
end})
SpeedSection:Toggle({Name = "Speed Glitch", Flag = "SpeedGlitch", Default = false, Callback = function(v) _G.DustWay_SpeedEnabled = v; if v then StartSpeedGlitch() else StopSpeedGlitch() end end})
SpeedSection:Slider({Name = "Speed Glitch Speed", Flag = "SpeedGlitchSpeed", Min = 50, Max = 600, Default = 200, Suffix = " studs", Callback = function(v) _G.DustWay_SpeedGlitchSpeed = v end})
local FlySection = MovementPage:Section({Name = "Полёт", Side = 1})
FlySection:Toggle({Name = "Полёт (WASD + Space)", Flag = "FlyEnabled", Default = false, Callback = function(v) _G.DustWay_FlyEnabled = v; if v then StartFly() else StopFly() end end})
FlySection:Slider({Name = "Скорость полёта", Flag = "FlySpeed", Min = 10, Max = 200, Default = 50, Suffix = " studs", Callback = function(v) _G.DustWay_FlySpeed = v end})
local AntiFlingSection = MovementPage:Section({Name = "Anti-Fling", Side = 2})
AntiFlingSection:Toggle({Name = "Anti-Fling", Flag = "AntiFling", Default = false, Callback = function(v) _G.DustWay_AntiFling = v; if v then StartAntiFling() else StopAntiFling() end end})
AntiFlingSection:Dropdown({Name = "Velocity Cap", Flag = "VelocityCap", Options = {"50","100","150","200","300","500"}, Default = "200", Callback = function(v) _G.DustWay_VelocityCap = tonumber(v) or 200; n1 = _G.DustWay_VelocityCap end})
local SkyboxSection = MiscPage:Section({Name = "Skybox", Side = 1})
SkyboxSection:Button({Name = "🌌 Skybox Picker", Callback = function() end})
SkyboxSection:Button({Name = "🔄 Восстановить небо", Callback = function() RestoreSky() end})
local CrosshairSection = MiscPage:Section({Name = "Прицел", Side = 1})
CrosshairSection:Toggle({Name = "Кастомный прицел", Flag = "CustomCrosshair", Default = false, Callback = function(v) _G.DustWay_Crosshair = v end})
CrosshairSection:Button({Name = "🎯 Cursor Picker", Callback = function() end})
local GraphicsSection = MiscPage:Section({Name = "Графика", Side = 2})
GraphicsSection:Toggle({Name = "Низкая графика", Flag = "LowGraphics", Default = false, Callback = function(v) if v then LowGraphics() else RestoreGraphics() end end})
GraphicsSection:Toggle({Name = "Высокая графика", Flag = "HighGraphics", Default = false, Callback = function(v) if v then HighGraphics() else RestoreGraphics() end end})
GraphicsSection:Button({Name = "FOV Slider", Callback = function() CurrentCamera.FieldOfView = n3 end})
local ExtraSection = MiscPage:Section({Name = "Дополнительно", Side = 2})
ExtraSection:Button({Name = "Infinite Yield", Callback = function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end})
ExtraSection:Button({Name = "Emotes GUI", Callback = function() loadstring(game:HttpGet('https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua'))() end})

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
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    if ESPObjects[player] then for _, o in pairs(ESPObjects[player]) do o:Destroy() end; ESPObjects[player] = nil end
    local role = GetRole(player)
    if not RoleToggles[role] then return end
    if player == LocalPlayer and not RoleToggles.Self then return end
    local color = RoleColors[role] or Color3.fromRGB(0,220,0)
    local hl = Instance.new("Highlight")
    hl.Name = "DustWay_ESP"
    hl.Adornee = char
    hl.FillColor = color
    hl.FillTransparency = 0.7
    hl.OutlineColor = Color3.fromRGB(255,255,255)
    hl.OutlineTransparency = 0.15
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = char
    local bg = Instance.new("BillboardGui")
    bg.Size = UDim2.new(0,200,0,40)
    bg.AlwaysOnTop = true
    bg.Adornee = head
    bg.Parent = char
    local lbl = Instance.new("TextLabel", bg)
    lbl.Size = UDim2.new(1,0,1,0)
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
    gunESP.FillColor = Color3.fromRGB(255,215,0)
    gunESP.OutlineColor = Color3.fromRGB(255,255,255)
    gunESP.FillTransparency = 0.35
    gunESP.OutlineTransparency = 0
    gunESP.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    gunESP.Parent = gun
    gunMarker = Instance.new("Part")
    gunMarker.Size = Vector3.new(1.5,0.15,1.5)
    gunMarker.Anchored = true
    gunMarker.CanCollide = false
    gunMarker.CastShadow = false
    gunMarker.Material = Enum.Material.Neon
    gunMarker.Color = Color3.fromRGB(50,255,80)
    gunMarker.Transparency = 0.25
    gunMarker.CFrame = CFrame.new(part.Position)
    gunMarker.Parent = Workspace
    gunESPBillboard = Instance.new("BillboardGui")
    gunESPBillboard.Adornee = part
    gunESPBillboard.Size = UDim2.new(0,130,0,36)
    gunESPBillboard.StudsOffset = Vector3.new(0,4,0)
    gunESPBillboard.AlwaysOnTop = true
    gunESPBillboard.MaxDistance = 300
    gunESPBillboard.Parent = part
    local fr = Instance.new("Frame", gunESPBillboard)
    fr.Size = UDim2.new(1,0,1,0)
    fr.BackgroundColor3 = Color3.fromRGB(0,0,0)
    fr.BackgroundTransparency = 0.4
    fr.BorderSizePixel = 0
    Instance.new("UICorner", fr).CornerRadius = UDim.new(0,6)
    local st = Instance.new("UIStroke", fr)
    st.Color = Color3.fromRGB(255,215,0)
    st.Thickness = 1.5
    local tl = Instance.new("TextLabel", fr)
    tl.Size = UDim2.new(1,0,1,0)
    tl.BackgroundTransparency = 1
    tl.Text = "GUN ON MAP"
    tl.TextColor3 = Color3.fromRGB(255,215,0)
    tl.Font = Enum.Font.GothamBlack
    tl.TextSize = 13
end

function MonitorGunDrop()
    local conn
    conn = Workspace.DescendantAdded:Connect(function(d)
        if d.Name == "GunDrop" and _G.DustWay_GunESP then
            task.wait(0.1)
            CreateGunESP(d)
        end
    end)
    for _, d in pairs(Workspace:GetDescendants()) do
        if d.Name == "GunDrop" and _G.DustWay_GunESP then
            task.wait(0.1)
            CreateGunESP(d)
            break
        end
    end
end
MonitorGunDrop()

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
    Workspace.FallenPartsDestroyHeight = 0/0
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0,0,0)
    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
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
    flyBV.MaxForce = Vector3.new(1e5,1e5,1e5)
    flyBV.Velocity = Vector3.new(0,0,0)
    flyBV.Parent = hrp
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e9,1e9,1e9)
    flyBG.P = 9e4
    flyBG.CFrame = hrp.CFrame
    flyBG.Parent = hrp
    flyConnection = RunService.RenderStepped:Connect(function()
        if not _G.DustWay_FlyEnabled then return end
        if not hrp or not hrp.Parent then return end
        local moveDir = Vector3.new()
        local cam = Workspace.CurrentCamera
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0,1,0) end
        if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
        flyBV.Velocity = moveDir * _G.DustWay_FlySpeed
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
        if not _G.DustWay_SpeedEnabled then humanoid.WalkSpeed = 16; return end
        local state = humanoid:GetState()
        if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall then
            humanoid.WalkSpeed = humanoid.MoveDirection.Magnitude > 0 and n2 or 16
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
        if not _G.DustWay_AntiFling then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local vel = hrp.AssemblyLinearVelocity
            if vel.Magnitude > n1 then hrp.AssemblyLinearVelocity = vel.Unit * n1 end
        end
    end)
end

function StopAntiFling()
    if antiFlingConn then antiFlingConn:Disconnect(); antiFlingConn = nil end
end

function RestoreSky()
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
end

function LowGraphics()
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    Lighting.GlobalShadows = false
    Lighting.Brightness = 2
    for _, d in pairs(Workspace:GetDescendants()) do
        if d:IsA("BasePart") then d.Material = Enum.Material.SmoothPlastic; d.CastShadow = false end
        if d:IsA("Decal") or d:IsA("Texture") then d.Transparency = 1 end
    end
end

function HighGraphics()
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level21 end)
    Lighting.GlobalShadows = true
    Lighting.Brightness = 3.5
    if not Lighting:FindFirstChildOfClass("BloomEffect") then Instance.new("BloomEffect", Lighting) end
    if not Lighting:FindFirstChildOfClass("SunRaysEffect") then Instance.new("SunRaysEffect", Lighting) end
    if not Lighting:FindFirstChildOfClass("ColorCorrectionEffect") then Instance.new("ColorCorrectionEffect", Lighting) end
end

function RestoreGraphics()
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
    for _, c in pairs(Lighting:GetChildren()) do
        if c:IsA("BloomEffect") or c:IsA("SunRaysEffect") or c:IsA("ColorCorrectionEffect") then c:Destroy() end
    end
end

RunService.RenderStepped:Connect(function()
    if not _G.DustWay_ESPEnabled then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            if not ESPObjects[p] then CreateESP(p) end
            local hl = p.Character:FindFirstChild("DustWay_ESP")
            if hl then
                local role = GetRole(p)
                if not RoleToggles[role] then hl:Destroy() else hl.FillColor = RoleColors[role] end
            end
        end
    end
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        if _G.DustWay_ESPEnabled then CreateESP(p) end
    end)
end)

Library:Notification({Title = "DustWay", Content = "v1.0 загружен! Нажми K для меню.", Duration = 5})
print("[DustWay] v1.0 loaded.")