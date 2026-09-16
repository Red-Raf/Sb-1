-- ============================================================
-- DustWay Hub v2.0 — MM2
-- UI: WindUI (Obsidian style)
-- Features: ESP, Combat, AutoFarm, Visuals, Teleport, Optimization
-- ============================================================

-- ===== 1. ЗАГРУЗКА WINDUI =====
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua"))()

if not WindUI then
    warn("[DustWay] Не удалось загрузить WindUI")
    return
end

-- ===== 2. ЗАЩИТА ОТ ДВОЙНОГО ЗАПУСКА =====
if getgenv().DustWayLoaded then
    warn("[DustWay] Уже запущен!")
    return
end
getgenv().DustWayLoaded = true

-- ===== 3. SERVICES =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ===== 4. НАСТРОЙКИ =====
local Settings = {
    AutoFarmEnabled = false,
    FarmMode = "Underground",
    TweenSpeed = 25,
    AutoReset = true,
    AvoidMurder = true,
    UndergroundOffset = 4,
    MaxDistance = 600,
    CoinLimit = 40,
}

local ChinaHatSettings = {
    enabled = true,
    hatColor = Color3.fromRGB(255, 105, 180),
    lightColor = Color3.fromRGB(255, 105, 180),
    lightBrightness = 0,
    lightRange = 12,
    scale = Vector3.new(1.7, 1.1, 1.7),
}

-- ===== 5. СОСТОЯНИЯ (из OnyxHub) =====
local State = {
    isFarming = false,
    isActivelyFlying = false,
    currentTargetCoin = nil,
    ignoredCoins = {},
    currentTween = nil,
}

local ESP_STATES = {
    ESPName = false,
    MurdererName = true,
    SheriffName = true,
    HeroName = true,
    InnocentName = true
}

local ESP_HIGHLIGHT_STATES = {
    ESPHighlight = false,
    ESPHighlightMurderer = true,
    ESPHighlightSheriff = true,
    ESPHighlightHero = true,
    ESPHighlightInnocent = true
}

local ESP_LINE_STATES = {
    ESPLine = false,
    MurdererLine = true,
    SheriffLine = true,
    HeroLine = true,
    InnocentLine = true,
    LineThickness = 1.4,
    LineTransparency = 1
}

local KillAll = {Enabled = false, AttackDelay = 0.5}
local Movement = {
    SpeedWalk = {Enabled = false, Value = 16},
    JumpPower = {Enabled = false, Value = 50}
}
local AntiFling = {Enabled = false, Connections = nil}
local Performance = {Enabled = false, Overlay = nil, Position = nil}
local AutoFarm = {
    Enabled = false,
    Farming = false,
    BagFull = false,
    Resetting = false,
    StartPosition = nil
}

local ROLE_COLORS = {
    Murderer = Color3.fromRGB(255, 0, 0),
    Sheriff = Color3.fromRGB(0, 0, 255),
    Hero = Color3.fromRGB(255, 255, 0),
    Innocent = Color3.fromRGB(0, 255, 0)
}

local VALID_TARGET_ROLES = {"Sheriff", "Hero", "Innocent"}
local DEFAULT_WALK_SPEED = 16
local DEFAULT_JUMP_POWER = 50
local MAIN_COLOR = Color3.fromRGB(150, 100, 255)

-- ===== 6. ПЕРЕМЕННЫЕ ESP =====
local ESP = {
    billboards = {},
    currentRoles = {},
    LineDrawings = {},
    Camera = workspace.CurrentCamera,
    Connections = {},
    RolesData = {},
    RolesCacheTime = 0,
}

-- ===== 7. FARM STATS =====
local FarmStats = {
    CoinsCollected = 0,
    StartTime = 0,
    IsRunning = false
}

local RemoteEvents = {
    CoinCollected = nil,
    RoundStart = nil,
    RoundEnd = nil
}

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

local function getHRP()
    local char = LocalPlayer.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function getTorso(char)
    if not char then return nil end
    return char:FindFirstChild("Torso") or char:FindFirstChild("LowerTorso") or char:FindFirstChild("HumanoidRootPart")
end

-- ============================================================
-- ESP FUNCTIONS (перенесено из OnyxHub)
-- ============================================================

local function IsPlayerOnScreen(player)
    if not ESP.Camera then return true end
    local char = player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local pos, onScreen = ESP.Camera:WorldToViewportPoint(hrp.Position)
    if onScreen then
        local vs = ESP.Camera.ViewportSize
        return pos.X >= -50 and pos.X <= vs.X + 50 and pos.Y >= -50 and pos.Y <= vs.Y + 50
    end
    return false
end

local function GetRolesData()
    if tick() - ESP.RolesCacheTime < 0.5 then
        return ESP.RolesData
    end
    
    local ok, result = pcall(function()
        local getData = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
        if getData and getData:IsA("RemoteFunction") then
            return getData:InvokeServer()
        end
        return {}
    end)
    
    if ok and result then
        ESP.RolesData = result
        ESP.RolesCacheTime = tick()
    end
    return ESP.RolesData
end

local function IsAlive(player, roles)
    if not roles then return false end
    local data = roles[player.Name]
    if data then
        return not data.Killed and not data.Dead
    end
    return false
end

local function getPlayerRole(player, roles)
    if not roles then return nil, false end
    local data = roles[player.Name]
    if not data then return nil, false end
    return data.Role, IsAlive(player, roles)
end

local function GetPlayerColorByRole(role, alive)
    if not alive then return Color3.fromRGB(150, 150, 150) end
    if role == "Murderer" then return Color3.fromRGB(255, 0, 0) end
    if role == "Sheriff" then return Color3.fromRGB(0, 0, 255) end
    if role == "Hero" then return Color3.fromRGB(255, 255, 0) end
    if role == "Innocent" then return Color3.fromRGB(0, 255, 0) end
    return Color3.fromRGB(255, 255, 255)
end

local function ShouldShowLineForRole(role)
    if not ESP_LINE_STATES.ESPLine then return false end
    if role == "Murderer" and ESP_LINE_STATES.MurdererLine then return true end
    if role == "Sheriff" and ESP_LINE_STATES.SheriffLine then return true end
    if role == "Hero" and ESP_LINE_STATES.HeroLine then return true end
    if role == "Innocent" and ESP_LINE_STATES.InnocentLine then return true end
    return false
end

local function updatePlayerBillboard(player, role, alive)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local color = GetPlayerColorByRole(role, alive)
    local billboard = hrp:FindFirstChild("DustWayBillboard")
    
    if billboard then
        local nameLabel = billboard:FindFirstChild("PlayerName")
        if nameLabel then
            nameLabel.TextColor3 = color
            nameLabel.Text = player.Name
            return
        end
    else
        local bb = Instance.new("BillboardGui")
        bb.Name = "DustWayBillboard"
        bb.Adornee = hrp
        bb.AlwaysOnTop = true
        bb.Size = UDim2.new(0, 100, 0, 30)
        bb.StudsOffset = Vector3.new(0, 2.5, 0)
        bb.ResetOnSpawn = false
        
        local label = Instance.new("TextLabel")
        label.Name = "PlayerName"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = player.Name
        label.TextColor3 = color
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextStrokeTransparency = 0.5
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.Parent = bb
        bb.Parent = hrp
        ESP.billboards[player] = bb
    end
end

local function removePlayerBillboard(player)
    if player == LocalPlayer then return end
    if ESP.billboards[player] then
        ESP.billboards[player]:Destroy()
        ESP.billboards[player] = nil
    end
    local char = player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bb = hrp:FindFirstChild("DustWayBillboard")
            if bb then bb:Destroy() end
        end
    end
end

local function clearAllESP()
    for _, bb in pairs(ESP.billboards) do
        if bb and bb.Parent then bb:Destroy() end
    end
    ESP.billboards = {}
end

local function updatePlayerHighlight(player, role, alive)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    
    local highlight = char:FindFirstChild("DustWayHighlight")
    if not highlight or not highlight:IsA("Highlight") then
        if highlight then highlight:Destroy() end
        highlight = Instance.new("Highlight")
        highlight.Name = "DustWayHighlight"
        highlight.Adornee = char
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0.4
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.Parent = char
    end
    
    local color = GetPlayerColorByRole(role, alive)
    highlight.FillColor = color
end

local function removePlayerHighlight(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if char then
        local h = char:FindFirstChild("DustWayHighlight")
        if h then h:Destroy() end
    end
end

local function clearAllHighlights()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            removePlayerHighlight(player)
        end
    end
end

local function updateESP()
    if not ESP_STATES.ESPName then
        clearAllESP()
        return
    end
    
    local roles = GetRolesData()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not char or not hrp then
                removePlayerBillboard(player)
            elseif not IsPlayerOnScreen(player) then
                removePlayerBillboard(player)
            else
                local role, alive = getPlayerRole(player, roles)
                local show = false
                
                if role == "Murderer" and ESP_STATES.MurdererName then show = true
                elseif role == "Sheriff" and ESP_STATES.SheriffName then show = true
                elseif role == "Hero" and ESP_STATES.HeroName then show = true
                elseif role == "Innocent" and ESP_STATES.InnocentName then show = true
                elseif not role then show = true
                end
                
                if show then
                    updatePlayerBillboard(player, role, alive)
                else
                    removePlayerBillboard(player)
                end
            end
        end
    end
end

local function updateHighlights()
    if not ESP_HIGHLIGHT_STATES.ESPHighlight then
        clearAllHighlights()
        return
    end
    
    local roles = GetRolesData()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not player.Character or not IsPlayerOnScreen(player) then
                removePlayerHighlight(player)
            else
                local role, alive = getPlayerRole(player, roles)
                local show = false
                
                if role == "Murderer" and ESP_HIGHLIGHT_STATES.ESPHighlightMurderer then show = true
                elseif role == "Sheriff" and ESP_HIGHLIGHT_STATES.ESPHighlightSheriff then show = true
                elseif role == "Hero" and ESP_HIGHLIGHT_STATES.ESPHighlightHero then show = true
                elseif role == "Innocent" and ESP_HIGHLIGHT_STATES.ESPHighlightInnocent then show = true
                end
                
                if show then
                    updatePlayerHighlight(player, role, alive)
                else
                    removePlayerHighlight(player)
                end
            end
        end
    end
end

-- Tracers (линии)
local function InitializePlayerLines(player)
    if not pcall(function() return Drawing.new("Line") end) then
        warn("[DustWay] Drawing API не поддерживается")
        return nil
    end
    
    if not ESP.LineDrawings[player.Name] then
        local d = Drawing.new("Line")
        d.Visible = false
        d.Color = Color3.fromRGB(255, 255, 255)
        d.Thickness = ESP_LINE_STATES.LineThickness
        d.Transparency = ESP_LINE_STATES.LineTransparency
        ESP.LineDrawings[player.Name] = d
    end
    
    local cachedRole, cachedAlive
    
    return RunService.RenderStepped:Connect(function()
        if not ESP_LINE_STATES.ESPLine then
            if ESP.LineDrawings[player.Name] then
                ESP.LineDrawings[player.Name].Visible = false
            end
            return
        end
        
        ESP.Camera = workspace.CurrentCamera
        
        local check = player and player.Character and player.Character:FindFirstChild("Humanoid") 
            and player.Character:FindFirstChild("HumanoidRootPart") 
            and player.Name ~= LocalPlayer.Name 
            and player.Character.Humanoid.Health > 0
        
        if check then
            if tick() - ESP.RolesCacheTime >= 0.1 then
                local roles = GetRolesData()
                cachedRole, cachedAlive = getPlayerRole(player, roles)
            end
            
            if not ShouldShowLineForRole(cachedRole) or not cachedAlive then
                if ESP.LineDrawings[player.Name] then
                    ESP.LineDrawings[player.Name].Visible = false
                end
                return
            end
            
            local pos, onScreen = ESP.Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local d = ESP.LineDrawings[player.Name]
                if d then
                    d.From = Vector2.new(ESP.Camera.ViewportSize.X / 2, ESP.Camera.ViewportSize.Y / 2)
                    d.To = Vector2.new(pos.X, pos.Y)
                    d.Color = GetPlayerColorByRole(cachedRole, cachedAlive)
                    d.Thickness = ESP_LINE_STATES.LineThickness
                    d.Transparency = ESP_LINE_STATES.LineTransparency
                    d.Visible = true
                end
            elseif ESP.LineDrawings[player.Name] then
                ESP.LineDrawings[player.Name].Visible = false
            end
        elseif ESP.LineDrawings[player.Name] then
            ESP.LineDrawings[player.Name].Visible = false
        end
    end)
end

local function StopAllLines()
    for _, conn in ipairs(ESP.Connections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    ESP.Connections = {}
    
    for _, d in pairs(ESP.LineDrawings) do
        if d then d:Remove() end
    end
    ESP.LineDrawings = {}
end

local function StartAllLines()
    StopAllLines()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local conn = InitializePlayerLines(player)
            if conn then table.insert(ESP.Connections, conn) end
        end
    end
end

-- ============================================================
-- AUTO FARM (перенесено + из OnyxHub)
-- ============================================================

local function getCurrentCoins()
    local ok, res = pcall(function()
        local gui = LocalPlayer.PlayerGui:FindFirstChild("MainGUI")
        if not gui then return 0 end
        local gameGui = gui:FindFirstChild("Game")
        if not gameGui then return 0 end
        local coinBags = gameGui:FindFirstChild("CoinBags")
        if not coinBags then return 0 end
        local container = coinBags:FindFirstChild("Container")
        if not container then return 0 end
        local coin = container:FindFirstChild("Coin")
        if not coin then return 0 end
        local cf = coin:FindFirstChild("CurrencyFrame")
        if not cf then return 0 end
        local icon = cf:FindFirstChild("Icon")
        if not icon then return 0 end
        local coinsText = icon:FindFirstChild("Coins")
        if not coinsText then return 0 end
        return coinsText.Text
    end)
    return ok and (tonumber(res) or 0) or 0
end

local function isRoundOver()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not pGui then return false end
    local victoryGui = pGui:FindFirstChild("Victory")
    if victoryGui then
        for _, child in pairs(victoryGui:GetChildren()) do
            if child:IsA("GuiObject") and child.Visible then return true end
        end
    end
    return false
end

local function isBagFull()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        local mainGui = pGui:FindFirstChild("MainGUI")
        if mainGui and mainGui:FindFirstChild("Lobby") and mainGui.Lobby:FindFirstChild("Dock") then
            local coinBags = mainGui.Lobby.Dock:FindFirstChild("CoinBags")
            if coinBags then
                local n = coinBags:FindFirstChild("FullBagNotification")
                if n and n.Visible then return true end
            end
        end
    end
    return false
end

local function hasNearbyMurderer()
    if not Settings.AvoidMurder then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local otherHRP = player.Character:FindFirstChild("HumanoidRootPart")
            local backpack = player:FindFirstChild("Backpack")
            if otherHRP and (otherHRP.Position - hrp.Position).Magnitude <= 10 then
                if player.Character:FindFirstChild("Knife") then return true end
                if backpack and backpack:FindFirstChild("Knife") then return true end
            end
        end
    end
    return false
end

local function getNearestCoin(torso)
    local container = nil
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "CoinContainer" then
            container = obj
            break
        end
    end
    if not container then return nil end
    
    local nearest, minDist = nil, math.huge
    for _, coin in pairs(container:GetChildren()) do
        if coin.Name == "Coin_Server" and coin:IsA("BasePart") and not State.ignoredCoins[coin] then
            local dist = (torso.Position - coin.Position).Magnitude
            if dist < minDist and dist <= Settings.MaxDistance then
                minDist = dist
                nearest = coin
            end
        end
    end
    return nearest
end

local function applyFlightPhysics(char)
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return CFrame.Angles(0,0,0) end
    
    local bv = hrp:FindFirstChild("FarmBV")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "FarmBV"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp
    end
    
    local bg = hrp:FindFirstChild("FarmBG")
    if not bg then
        bg = Instance.new("BodyGyro")
        bg.Name = "FarmBG"
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 50000
        bg.Parent = hrp
        local _, rotY, _ = hrp.CFrame:ToOrientation()
        bg.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, rotY, 0) * CFrame.Angles(math.rad(-90), 0, 0)
    end
    return bg.CFrame.Rotation
end

local function removePhysics()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        if hrp:FindFirstChild("FarmBV") then hrp.FarmBV:Destroy() end
        if hrp:FindFirstChild("FarmBG") then hrp.FarmBG:Destroy() end
        if hrp.Anchored then hrp.Anchored = false end
    end
end

local function setupNoclip()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if hum then hum.PlatformStand = true end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end

local function flyToPoint(targetPos, targetCoin, hrp, torso, lockedRotation)
    local dist = (torso.Position - targetPos).Magnitude
    local tween = TweenService:Create(hrp, TweenInfo.new(dist / Settings.TweenSpeed, Enum.EasingStyle.Linear), {
        CFrame = CFrame.new(targetPos) * lockedRotation
    })
    State.currentTween = tween
    local reached = false
    tween:Play()
    
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not State.isFarming or not targetCoin or not targetCoin:IsDescendantOf(workspace) then
            tween:Cancel()
            if conn then conn:Disconnect() end
            return
        end
        if firetouchinterest then
            pcall(function()
                firetouchinterest(torso, targetCoin, 0)
                firetouchinterest(torso, targetCoin, 1)
            end)
        end
        if (torso.Position - targetPos).Magnitude <= 1.5 then
            reached = true
            tween:Cancel()
            if conn then conn:Disconnect() end
        end
    end)
    
    while conn and conn.Connected do
        RunService.Heartbeat:Wait()
    end
    return reached
end

local function tweenToCoin(coin)
    if not coin or not coin.Parent or not coin:FindFirstChild("TouchInterest") then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return false end
    
    local target = coin.Position + Vector3.new(0, 2, 0)
    if (hrp.Position - target).Magnitude < 5 then return true end
    if State.currentTween then pcall(function() State.currentTween:Cancel() end) end
    
    State.currentTween = TweenService:Create(hrp,
        TweenInfo.new((hrp.Position - target).Magnitude / Settings.TweenSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {CFrame = CFrame.new(target)})
    hum.Sit = true
    State.currentTween:Play()
    
    local done = false
    local c
    c = State.currentTween.Completed:Connect(function()
        done = true
        if c then c:Disconnect() end
    end)
    
    local t0 = tick()
    while not done and State.isFarming do
        task.wait(0.1)
        if not coin or not coin.Parent or not coin:FindFirstChild("TouchInterest") then
            if State.currentTween then pcall(function() State.currentTween:Cancel() end) end
            hum.Sit = false
            return false
        end
        if tick() - t0 > 30 then
            if State.currentTween then pcall(function() State.currentTween:Cancel() end) end
            hum.Sit = false
            return false
        end
    end
    hum.Sit = false
    return done
end

local function collectCoin(coin)
    if not coin or not coin.Parent then return end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    pcall(function()
        firetouchinterest(hrp, coin, 0)
        task.wait(0.05)
        firetouchinterest(hrp, coin, 1)
    end)
end

local function startFarming()
    if State.isFarming then return end
    State.isFarming = true
    table.clear(State.ignoredCoins)
    
    task.spawn(function()
        while State.isFarming do
            task.wait()
            local success = pcall(function()
                if hasNearbyMurderer() then
                    State.isActivelyFlying = false
                    State.currentTargetCoin = nil
                    removePhysics()
                    local char = LocalPlayer.Character
                    if char then
                        local hum = char:FindFirstChild("Humanoid")
                        if hum then hum.Sit = false end
                    end
                    task.wait(1)
                    return
                end
                
                local char = LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local torso = getTorso(char)
                local hum = char:FindFirstChild("Humanoid")
                if not hrp or not torso or not hum or hum.Health <= 0 then
                    State.isActivelyFlying = false
                    State.currentTargetCoin = nil
                    removePhysics()
                    task.wait(1)
                    return
                end
                
                if isRoundOver() or isBagFull() then
                    State.isActivelyFlying = false
                    State.currentTargetCoin = nil
                    removePhysics()
                    if hum then hum.Sit = false end
                    task.wait(1)
                    return
                end
                
                if Settings.AutoReset then
                    local coins = getCurrentCoins()
                    if coins >= Settings.CoinLimit then
                        hum.Health = 0
                        task.wait(5)
                        return
                    end
                end
                
                local targetCoin = getNearestCoin(torso)
                if not targetCoin or not targetCoin:IsDescendantOf(workspace) then
                    State.isActivelyFlying = false
                    State.currentTargetCoin = nil
                    removePhysics()
                    if hum then hum.Sit = false end
                    task.wait(0.5)
                    return
                end
                
                State.isActivelyFlying = true
                State.currentTargetCoin = targetCoin
                local reached = false
                
                if Settings.FarmMode == "Underground" then
                    setupNoclip()
                    local rot = applyFlightPhysics(char)
                    local pos = targetCoin.Position - Vector3.new(0, Settings.UndergroundOffset, 0)
                    reached = flyToPoint(pos, targetCoin, hrp, torso, rot)
                elseif Settings.FarmMode == "Sit" then
                    reached = tweenToCoin(targetCoin)
                    if reached and State.isFarming and hum.Health > 0 then
                        collectCoin(targetCoin)
                    end
                end
                
                if reached and State.isFarming and hum.Health > 0 then
                    State.ignoredCoins[targetCoin] = true
                    task.delay(5, function() State.ignoredCoins[targetCoin] = nil end)
                    task.wait(0.2)
                end
                State.currentTargetCoin = nil
            end)
            
            if not success then
                State.isActivelyFlying = false
                State.currentTargetCoin = nil
                removePhysics()
                task.wait(1)
            end
        end
    end)
end

local function stopFarming()
    State.isFarming = false
    State.isActivelyFlying = false
    State.currentTargetCoin = nil
    if State.currentTween then
        pcall(function() State.currentTween:Cancel() end)
        State.currentTween = nil
    end
    removePhysics()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum.Sit = false
        end
    end
end

-- ============================================================
-- KILL ALL (из OnyxHub)
-- ============================================================

local function getPlayerRoleFromServer(player)
    local getData = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
    if getData and getData:IsA("RemoteFunction") then
        local data = getData:InvokeServer()
        if data and data[player.Name] then
            return data[player.Name].Role
        end
    end
    return nil
end

local function hasKnife()
    local char = LocalPlayer.Character
    if not char then return false end
    if char:FindFirstChild("Knife") then return true end
    local knife = LocalPlayer.Backpack:FindFirstChild("Knife")
    if knife then
        knife.Parent = char
        return true
    end
    return false
end

local function equipKnife()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character
    if not char then return false end
    local knife = (backpack and backpack:FindFirstChild("Knife")) or char:FindFirstChild("Knife")
    if knife then
        if char ~= knife.Parent then knife.Parent = char end
        return true
    end
    return false
end

local function getAllValidTargets()
    local targets = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local role = getPlayerRoleFromServer(player)
            local hum = player.Character:FindFirstChild("Humanoid")
            if role and hum and hum.Health > 0 and table.find(VALID_TARGET_ROLES, role) then
                table.insert(targets, player)
            end
        end
    end
    return targets
end

local function killAllPlayers()
    if not KillAll.Enabled then return end
    if not equipKnife() then return end
    task.wait(0.1)
    
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        local gameplay = remotes:FindFirstChild("Gameplay")
        if gameplay then
            remotes = gameplay:FindFirstChild("KillEvent")
        end
    end
    local killEvent = remotes
    if not killEvent then return end
    
    local targets = getAllValidTargets()
    local hrp = getHRP()
    if not hrp then return end
    
    for _, player in ipairs(targets) do
        if not KillAll.Enabled then return end
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, -3)
            pcall(function()
                killEvent:FireServer(player.Name, Color3.new(1, 0, 0))
            end)
            task.wait(KillAll.AttackDelay or 0.2)
        end
    end
end

-- ============================================================
-- ANTI-FLING (из OnyxHub)
-- ============================================================

local function enableAntiFling()
    if AntiFling.Enabled then return end
    AntiFling.Enabled = true
    
    local lp = LocalPlayer
    local char = lp.Character or lp.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    
    local function disableCollisions()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= lp and player.Character then
                for _, desc in ipairs(player.Character:GetDescendants()) do
                    if desc:IsA("BasePart") and not desc.Anchored then
                        desc.CanCollide = false
                    end
                end
            end
        end
    end
    
    disableCollisions()
    
    local thread = task.spawn(function()
        while AntiFling.Enabled do
            task.wait(0.3)
            if not char or not char.Parent then
                char = lp.Character
                if char then
                    hum = char:FindFirstChild("Humanoid")
                    if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end
                end
            end
            disableCollisions()
        end
    end)
    
    local playerAddedConn = Players.PlayerAdded:Connect(function(p)
        if p ~= lp then
            p.CharacterAdded:Connect(function(c)
                task.wait(0.2)
                if AntiFling.Enabled then
                    for _, desc in ipairs(c:GetDescendants()) do
                        if desc:IsA("BasePart") and not desc.Anchored then
                            desc.CanCollide = false
                        end
                    end
                end
            end)
        end
    end)
    
    local charAddedConn = lp.CharacterAdded:Connect(function(c)
        char = c
        hum = char:FindFirstChild("Humanoid")
        if hum and AntiFling.Enabled then
            hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        end
        task.wait(0.2)
        if AntiFling.Enabled then disableCollisions() end
    end)
    
    AntiFling.Connections = {
        task = thread,
        playerAdded = playerAddedConn,
        characterAdded = charAddedConn
    }
end

local function disableAntiFling()
    if not AntiFling.Enabled then return end
    AntiFling.Enabled = false
    local c = AntiFling.Connections
    if c then
        if c.task then task.cancel(c.task) end
        if c.playerAdded then c.playerAdded:Disconnect() end
        if c.characterAdded then c.characterAdded:Disconnect() end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, desc in ipairs(player.Character:GetDescendants()) do
                if desc:IsA("BasePart") then desc.CanCollide = true end
            end
        end
    end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end
    end
    AntiFling.Connections = nil
end

-- ============================================================
-- SPEED / JUMP (из OnyxHub)
-- ============================================================

local function updateWalkSpeed()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = Movement.SpeedWalk.Enabled and Movement.SpeedWalk.Value or DEFAULT_WALK_SPEED
        end
    end
end

local function updateJumpPower()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.JumpPower = Movement.JumpPower.Enabled and Movement.JumpPower.Value or DEFAULT_JUMP_POWER
        end
    end
end

-- ============================================================
-- GRAB GUN (из OnyxHub)
-- ============================================================

local function grabGun()
    local hrp = getHRP()
    if not hrp then return false end
    for _, child in pairs(workspace:GetChildren()) do
        if child:IsA("Model") and child:FindFirstChild("GunDrop") then
            local gun = child.GunDrop
            firetouchinterest(hrp, gun, 0)
            task.wait(0.1)
            firetouchinterest(hrp, gun, 1)
            return true
        end
    end
    return false
end

-- ============================================================
-- SHOOT MURDERER (из OnyxHub)
-- ============================================================

local function getMurderer()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Backpack:FindFirstChild("Knife") then
            return player
        end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Knife") then
            return player
        end
    end
    return nil
end

local function getSheriff()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Backpack:FindFirstChild("Gun") then
            return player
        end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Gun") then
            return player
        end
    end
    return nil
end

local function shootMurderer()
    if getSheriff() ~= LocalPlayer then return end
    local murderer = getMurderer()
    if not murderer or not murderer.Character then return end
    if not LocalPlayer.Character then return end
    
    local gun = LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
    if not gun then return end
    if LocalPlayer.Character ~= gun.Parent then
        LocalPlayer.Character.Humanoid:EquipTool(gun)
        task.wait(0.05)
    end
    
    local targetHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end
    
    local predicted = targetHRP.Position + targetHRP.AssemblyLinearVelocity * Vector3.new(0.75, 0.5, 0.75) * (2.8 / 15) + murderer.Character.Humanoid.MoveDirection * 2.8
    local hand = LocalPlayer.Character:FindFirstChild("RightHand")
    if not hand then return end
    
    local shoot = gun:WaitForChild("Shoot")
    pcall(function()
        shoot:FireServer(CFrame.new(hand.Position), CFrame.new(predicted))
    end)
end

-- ============================================================
-- FAKE BOMB JUMP (из OnyxHub)
-- ============================================================

local function fakeBombJump()
    local char = LocalPlayer.Character
    if not char then return end
    local backpack = LocalPlayer.Backpack
    
    local bomb = backpack:FindFirstChild("FakeBomb") or char:FindFirstChild("FakeBomb")
    if not bomb then
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local extras = remotes:FindFirstChild("Extras")
            if extras then
                local rep = extras:FindFirstChild("ReplicateToy")
                if rep then
                    pcall(function() rep:InvokeServer("FakeBomb") end)
                end
            end
        end
        bomb = backpack:WaitForChild("FakeBomb", 5)
        if not bomb then return end
    end
    
    bomb.Parent = char
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hum and hrp then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        hum.JumpPower = 53
        if bomb:FindFirstChild("Remote") then
            bomb.Remote:FireServer(hrp.CFrame * CFrame.new(0, -3, 0), 50)
        end
        task.wait(0.3)
        if bomb and char == bomb.Parent then
            bomb.Parent = backpack
        end
        if hum then hum.JumpPower = 51 end
    end
end

-- ============================================================
-- ANTI-AFK (из OnyxHub)
-- ============================================================

local function enableAntiAFK()
    local vu = cloneref and cloneref(game:GetService("VirtualUser")) or game:GetService("VirtualUser")
    local cam = workspace.CurrentCamera
    if vu and cam then
        pcall(function()
            vu:Button2Down(Vector2.new(0, 0), cam.CFrame)
            task.wait(0.1)
            vu:Button2Up(Vector2.new(0, 0), cam.CFrame)
        end)
    end
end

local AntiAFKThread = nil
local function toggleAntiAFK(enabled)
    if enabled then
        if AntiAFKThread then task.cancel(AntiAFKThread) end
        AntiAFKThread = task.spawn(function()
            while true do
                task.wait(300)
                enableAntiAFK()
            end
        end)
    else
        if AntiAFKThread then
            task.cancel(AntiAFKThread)
            AntiAFKThread = nil
        end
    end
end

-- ============================================================
-- TELEPORT (из OnyxHub)
-- ============================================================

local function joinAnotherServer()
    local TS = game:GetService("TeleportService")
    local ok = pcall(function()
        local code = TS:ReserveServer(game.PlaceId)
        if code then
            TS:TeleportToPrivateServer(game.PlaceId, code, {LocalPlayer})
            return
        end
        TS:Teleport(game.PlaceId, LocalPlayer)
    end)
    if not ok then
        pcall(function() TS:Teleport(game.PlaceId, LocalPlayer) end)
    end
end

local function rejoinServer()
    local TS = game:GetService("TeleportService")
    pcall(function()
        TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)
end

-- ============================================================
-- PERFORMANCE OVERLAY (из OnyxHub)
-- ============================================================

local function createPerformanceOverlay(parentGui)
    if Performance.Overlay then return end
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "DustWayStats"
    sg.Parent = CoreGui
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Global
    sg.DisplayOrder = 95
    sg.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Name = "StatsFrame"
    frame.Size = UDim2.new(0, 100, 0, 40)
    frame.Position = Performance.Position or UDim2.new(0.5, -50, 0.5, -20)
    frame.BackgroundColor3 = Color3.fromRGB(30, 20, 40)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.ZIndex = 5
    frame.Parent = sg
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    
    local pingLabel = Instance.new("TextLabel")
    pingLabel.Name = "PingLabel"
    pingLabel.Size = UDim2.new(1, -4, 0.5, 0)
    pingLabel.Position = UDim2.new(0, 2, 0, 2)
    pingLabel.BackgroundTransparency = 1
    pingLabel.TextColor3 = Color3.fromRGB(245, 235, 255)
    pingLabel.TextSize = 10
    pingLabel.RichText = true
    pingLabel.Text = "<font color='rgb(150, 100, 255)'>●</font> Ping: ..."
    pingLabel.Parent = frame
    
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Name = "FPSLabel"
    fpsLabel.Size = UDim2.new(1, -4, 0.5, 0)
    fpsLabel.Position = UDim2.new(0, 2, 0.5, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.TextColor3 = Color3.fromRGB(245, 235, 255)
    fpsLabel.TextSize = 10
    fpsLabel.RichText = true
    fpsLabel.Text = "<font color='rgb(150, 100, 255)'>●</font> FPS: ..."
    fpsLabel.Parent = frame
    
    -- Перетаскивание
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    local frames = 0
    local lastTime = tick()
    
    local conn = RunService.RenderStepped:Connect(function()
        frames = frames + 1
        if tick() - lastTime >= 1 then
            local ok, ping = pcall(function()
                return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            if ok then
                local color = ping < 50 and "rgb(100, 255, 100)" or ping < 100 and "rgb(255, 255, 100)" or ping < 200 and "rgb(255, 150, 100)" or "rgb(255, 100, 100)"
                pingLabel.Text = string.format("<font color='rgb(150, 100, 255)'>●</font> Ping: <font color='%s'>%d</font>", color, ping)
            else
                pingLabel.Text = "<font color='rgb(150, 100, 255)'>●</font> Ping: ..."
            end
            
            local fpsColor = frames >= 60 and "rgb(100, 255, 100)" or frames >= 30 and "rgb(255, 255, 100)" or "rgb(255, 100, 100)"
            fpsLabel.Text = string.format("<font color='rgb(150, 100, 255)'>●</font> FPS: <font color='%s'>%d</font>", fpsColor, frames)
            frames = 0
            lastTime = tick()
        end
    end)
    
    Performance.Overlay = {
        gui = sg,
        frame = frame,
        destroy = function()
            if conn then conn:Disconnect() end
            if sg then sg:Destroy() end
            Performance.Overlay = nil
        end
    }
end

-- ============================================================
-- CHINA HAT
-- ============================================================

local function CreateHat(Character)
    local Head = Character:FindFirstChild("Head")
    if not Head then return end

    local Cone = Instance.new("Part")
    Cone.Size = Vector3.new(1, 1, 1)
    Cone.BrickColor = BrickColor.new("Hot pink")
    Cone.Material = Enum.Material.Neon
    Cone.Transparency = 0.2
    Cone.Anchored = false
    Cone.CanCollide = false
    Cone.Color = ChinaHatSettings.hatColor
    Cone.Name = "DustWayHat"

    local Mesh = Instance.new("SpecialMesh")
    Mesh.MeshType = Enum.MeshType.FileMesh
    Mesh.MeshId = "rbxassetid://1033714"
    Mesh.Scale = ChinaHatSettings.scale
    Mesh.Parent = Cone

    local Weld = Instance.new("Weld")
    Weld.Part0 = Head
    Weld.Part1 = Cone
    Weld.C0 = CFrame.new(0, 0.9, 0)
    Weld.Parent = Cone

    local Light = Instance.new("PointLight")
    Light.Color = ChinaHatSettings.lightColor
    Light.Brightness = ChinaHatSettings.lightBrightness
    Light.Range = ChinaHatSettings.lightRange
    Light.Shadows = true
    Light.Parent = Cone

    Cone.Parent = Character
end

local function OnCharacterAdded(Character)
    if ChinaHatSettings.enabled then
        Character:WaitForChild("Head")
        CreateHat(Character)
    end
end

LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)
if LocalPlayer.Character then OnCharacterAdded(LocalPlayer.Character) end

-- ============================================================
-- REMOTE EVENTS TRACKING (из OnyxHub)
-- ============================================================

local function findRemoteEvents()
    for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
        if desc:IsA("RemoteEvent") then
            if desc.Name == "CoinCollected" then RemoteEvents.CoinCollected = desc
            elseif desc.Name == "RoundStart" then RemoteEvents.RoundStart = desc
            elseif desc.Name == "RoundEnd" then RemoteEvents.RoundEnd = desc
            end
        end
        if RemoteEvents.CoinCollected and RemoteEvents.RoundStart and RemoteEvents.RoundEnd then return end
    end
end

local function connectRemoteEvents()
    if RemoteEvents.CoinCollected then
        RemoteEvents.CoinCollected.OnClientEvent:Connect(function(_, a, b)
            if AutoFarm.Enabled then
                FarmStats.CoinsCollected = FarmStats.CoinsCollected + 1
            end
            if a == b and not AutoFarm.Resetting then
                AutoFarm.BagFull = true
                if AutoFarm.Enabled then task.spawn(function() end) end
            end
        end)
    end
    
    if RemoteEvents.RoundStart then
        RemoteEvents.RoundStart.OnClientEvent:Connect(function()
            AutoFarm.Farming = true
            AutoFarm.BagFull = false
            local hrp = getHRP()
            if hrp then AutoFarm.StartPosition = hrp.CFrame end
        end)
    end
    
    if RemoteEvents.RoundEnd then
        RemoteEvents.RoundEnd.OnClientEvent:Connect(function()
            AutoFarm.Farming = false
            KillAll.Enabled = false
        end)
    end
end

-- ============================================================
-- UI (WindUI)
-- ============================================================

local Window = WindUI:CreateWindow({
    Title = "DustWay",
    Icon = "sparkles",
    Author = "DustWay Hub",
    Folder = "DustWay",
    Size = UDim2.fromOffset(620, 500),
    Theme = "Dark",
    Acrylic = true,
    HideSearchBar = false,
    OpenButton = {
        Title = "DustWay",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 2,
        Enabled = true,
        OnlyMobile = false,
        Color = ColorSequence.new(Color3.fromHex('#a855f7'), Color3.fromHex('#7c3aed')),
    },
})

-- ===== MAIN TAB =====
local MainTab = Window:Tab({Title = "Main", Icon = "zap"})

MainTab:Paragraph({Title = "Auto Farm", Desc = "Automatic coin farming for MM2"})

MainTab:Toggle({
    Title = "Auto Farm",
    Desc = "Enable automatic coin farming",
    Default = Settings.AutoFarmEnabled,
    Callback = function(v)
        Settings.AutoFarmEnabled = v
        AutoFarm.Enabled = v
        if v then startFarming() else stopFarming() end
    end,
})

MainTab:Dropdown({
    Title = "Farm Mode",
    Desc = "Select farming method",
    Values = {"Underground", "Sit"},
    Value = Settings.FarmMode,
    Callback = function(v) Settings.FarmMode = v end,
})

MainTab:Slider({
    Title = "Tween Speed",
    Desc = "Movement speed (higher = faster)",
    Value = {Min = 10, Max = 100, Default = Settings.TweenSpeed},
    Callback = function(v) Settings.TweenSpeed = v end,
})

MainTab:Toggle({
    Title = "Auto Reset",
    Desc = "Reset when coin limit reached",
    Default = Settings.AutoReset,
    Callback = function(v) Settings.AutoReset = v end,
})

MainTab:Slider({
    Title = "Coin Limit",
    Desc = "Reset after collecting this many coins",
    Value = {Min = 10, Max = 100, Default = Settings.CoinLimit},
    Callback = function(v) Settings.CoinLimit = v end,
})

MainTab:Toggle({
    Title = "Avoid Murder",
    Desc = "Stop farming if murderer is nearby",
    Default = Settings.AvoidMurder,
    Callback = function(v) Settings.AvoidMurder = v end,
})

MainTab:Slider({
    Title = "Max Distance",
    Desc = "Max distance to search for coins",
    Value = {Min = 100, Max = 1000, Default = Settings.MaxDistance},
    Callback = function(v) Settings.MaxDistance = v end,
})

MainTab:Slider({
    Title = "Underground Offset",
    Desc = "How deep below ground to fly",
    Value = {Min = 1, Max = 10, Default = Settings.UndergroundOffset},
    Callback = function(v) Settings.UndergroundOffset = v end,
})

-- ===== ESP TAB =====
local ESPTab = Window:Tab({Title = "ESP", Icon = "eye"})

ESPTab:Paragraph({Title = "ESP Names", Desc = "Show player names by role"})

ESPTab:Toggle({
    Title = "ESP Name",
    Default = ESP_STATES.ESPName,
    Callback = function(v)
        ESP_STATES.ESPName = v
        if not v then clearAllESP() else updateESP() end
    end,
})

ESPTab:Toggle({
    Title = "Murderer Name",
    Default = ESP_STATES.MurdererName,
    Callback = function(v) ESP_STATES.MurdererName = v; if ESP_STATES.ESPName then updateESP() end end,
})
ESPTab:Toggle({
    Title = "Sheriff Name",
    Default = ESP_STATES.SheriffName,
    Callback = function(v) ESP_STATES.SheriffName = v; if ESP_STATES.ESPName then updateESP() end end,
})
ESPTab:Toggle({
    Title = "Hero Name",
    Default = ESP_STATES.HeroName,
    Callback = function(v) ESP_STATES.HeroName = v; if ESP_STATES.ESPName then updateESP() end end,
})
ESPTab:Toggle({
    Title = "Innocent Name",
    Default = ESP_STATES.InnocentName,
    Callback = function(v) ESP_STATES.InnocentName = v; if ESP_STATES.ESPName then updateESP() end end,
})

ESPTab:Divider()

ESPTab:Paragraph({Title = "ESP Highlight", Desc = "Highlight players by role"})

ESPTab:Toggle({
    Title = "ESP Highlight",
    Default = ESP_HIGHLIGHT_STATES.ESPHighlight,
    Callback = function(v)
        ESP_HIGHLIGHT_STATES.ESPHighlight = v
        if not v then clearAllHighlights() else updateHighlights() end
    end,
})

ESPTab:Toggle({
    Title = "Murderer Highlight",
    Default = ESP_HIGHLIGHT_STATES.ESPHighlightMurderer,
    Callback = function(v) ESP_HIGHLIGHT_STATES.ESPHighlightMurderer = v; if ESP_HIGHLIGHT_STATES.ESPHighlight then updateHighlights() end end,
})
ESPTab:Toggle({
    Title = "Sheriff Highlight",
    Default = ESP_HIGHLIGHT_STATES.ESPHighlightSheriff,
    Callback = function(v) ESP_HIGHLIGHT_STATES.ESPHighlightSheriff = v; if ESP_HIGHLIGHT_STATES.ESPHighlight then updateHighlights() end end,
})
ESPTab:Toggle({
    Title = "Hero Highlight",
    Default = ESP_HIGHLIGHT_STATES.ESPHighlightHero,
    Callback = function(v) ESP_HIGHLIGHT_STATES.ESPHighlightHero = v; if ESP_HIGHLIGHT_STATES.ESPHighlight then updateHighlights() end end,
})
ESPTab:Toggle({
    Title = "Innocent Highlight",
    Default = ESP_HIGHLIGHT_STATES.ESPHighlightInnocent,
    Callback = function(v) ESP_HIGHLIGHT_STATES.ESPHighlightInnocent = v; if ESP_HIGHLIGHT_STATES.ESPHighlight then updateHighlights() end end,
})

ESPTab:Divider()

ESPTab:Paragraph({Title = "ESP Tracers", Desc = "Lines from center to players"})

ESPTab:Toggle({
    Title = "ESP Tracer",
    Default = ESP_LINE_STATES.ESPLine,
    Callback = function(v)
        ESP_LINE_STATES.ESPLine = v
        if v then StartAllLines() else StopAllLines() end
    end,
})

ESPTab:Toggle({
    Title = "Murderer Tracer",
    Default = ESP_LINE_STATES.MurdererLine,
    Callback = function(v) ESP_LINE_STATES.MurdererLine = v; if ESP_LINE_STATES.ESPLine then StartAllLines() end end,
})
ESPTab:Toggle({
    Title = "Sheriff Tracer",
    Default = ESP_LINE_STATES.SheriffLine,
    Callback = function(v) ESP_LINE_STATES.SheriffLine = v; if ESP_LINE_STATES.ESPLine then StartAllLines() end end,
})
ESPTab:Toggle({
    Title = "Hero Tracer",
    Default = ESP_LINE_STATES.HeroLine,
    Callback = function(v) ESP_LINE_STATES.HeroLine = v; if ESP_LINE_STATES.ESPLine then StartAllLines() end end,
})
ESPTab:Toggle({
    Title = "Innocent Tracer",
    Default = ESP_LINE_STATES.InnocentLine,
    Callback = function(v) ESP_LINE_STATES.InnocentLine = v; if ESP_LINE_STATES.ESPLine then StartAllLines() end end,
})

-- ===== VISUALS TAB =====
local VisualsTab = Window:Tab({Title = "Visuals", Icon = "palette"})

VisualsTab:Paragraph({Title = "China Hat", Desc = "Cosmetic hat with glow"})

VisualsTab:Toggle({
    Title = "Enable China Hat",
    Default = ChinaHatSettings.enabled,
    Callback = function(v)
        ChinaHatSettings.enabled = v
        local char = LocalPlayer.Character
        if char then
            if v then
                char:WaitForChild("Head")
                CreateHat(char)
            else
                local hat = char:FindFirstChild("DustWayHat")
                if hat then hat:Destroy() end
            end
        end
    end,
})

VisualsTab:Colorpicker({
    Title = "Hat Color",
    Default = ChinaHatSettings.hatColor,
    Callback = function(c)
        ChinaHatSettings.hatColor = c
        local char = LocalPlayer.Character
        if char then
            local hat = char:FindFirstChild("DustWayHat")
            if hat then hat.Color = c end
        end
    end,
})

VisualsTab:Colorpicker({
    Title = "Light Color",
    Default = ChinaHatSettings.lightColor,
    Callback = function(c)
        ChinaHatSettings.lightColor = c
        local char = LocalPlayer.Character
        if char then
            local hat = char:FindFirstChild("DustWayHat")
            if hat then
                local light = hat:FindFirstChildOfClass("PointLight")
                if light then light.Color = c end
            end
        end
    end,
})

VisualsTab:Slider({
    Title = "Light Brightness",
    Value = {Min = 0, Max = 10, Default = ChinaHatSettings.lightBrightness},
    Callback = function(v)
        ChinaHatSettings.lightBrightness = v
        local char = LocalPlayer.Character
        if char then
            local hat = char:FindFirstChild("DustWayHat")
            if hat then
                local light = hat:FindFirstChildOfClass("PointLight")
                if light then light.Brightness = v end
            end
        end
    end,
})

VisualsTab:Slider({
    Title = "Light Range",
    Value = {Min = 1, Max = 30, Default = ChinaHatSettings.lightRange},
    Callback = function(v)
        ChinaHatSettings.lightRange = v
        local char = LocalPlayer.Character
        if char then
            local hat = char:FindFirstChild("DustWayHat")
            if hat then
                local light = hat:FindFirstChildOfClass("PointLight")
                if light then light.Range = v end
            end
        end
    end,
})

-- ===== COMBAT TAB =====
local CombatTab = Window:Tab({Title = "Combat", Icon = "swords"})

CombatTab:Paragraph({Title = "Shoot Murderer", Desc = "Auto-shoot murderer (only as Sheriff)"})

CombatTab:Toggle({
    Title = "Shoot Murderer Button",
    Default = false,
    Callback = function(v)
        if v then
            CombatTab:Button({
                Title = "Shoot Murderer",
                Callback = function() shootMurderer() end,
            })
        end
    end,
})

CombatTab:Divider()

CombatTab:Paragraph({Title = "Fake Bomb Jump", Desc = "Jump with fake bomb"})

CombatTab:Button({
    Title = "Fake Bomb Jump",
    Callback = function() fakeBombJump() end,
})

CombatTab:Divider()

CombatTab:Paragraph({Title = "Grabber", Desc = "Grab dropped gun"})

CombatTab:Button({
    Title = "Grab Gun",
    Callback = function() grabGun() end,
})

CombatTab:Toggle({
    Title = "Auto Grab Gun",
    Default = false,
    Callback = function(v)
        getgenv().AutoGrab = v
        if v then
            task.spawn(function()
                while getgenv().AutoGrab do
                    grabGun()
                    task.wait(0.2)
                end
            end)
        end
    end,
})

-- ===== AUTO FARM TAB =====
local AutoFarmTab = Window:Tab({Title = "Auto Farm", Icon = "coins"})

AutoFarmTab:Paragraph({Title = "Farming Statistics", Desc = "Track your farming progress"})

local statsLabel = AutoFarmTab:Label("Coins: 0 | Coins/hour: 0 | Time: 0h 0m 0s")

RunService.Heartbeat:Connect(function()
    if AutoFarm.Enabled then
        if not FarmStats.IsRunning then
            FarmStats.StartTime = tick()
            FarmStats.IsRunning = true
            FarmStats.CoinsCollected = 0
        end
        local elapsed = tick() - FarmStats.StartTime
        local h = math.floor(elapsed / 3600)
        local m = math.floor(elapsed % 3600 / 60)
        local s = math.floor(elapsed % 60)
        local cph = elapsed > 0 and math.floor(FarmStats.CoinsCollected / elapsed * 3600) or 0
        pcall(function()
            statsLabel:Set(string.format("Coins: %d | Coins/hour: %d | Time: %dh %dm %ds", FarmStats.CoinsCollected, cph, h, m, s))
        end)
    else
        FarmStats.IsRunning = false
    end
end)

AutoFarmTab:Divider()

AutoFarmTab:Paragraph({Title = "Kill All", Desc = "Auto kill all valid targets"})

AutoFarmTab:Toggle({
    Title = "Auto Kill All",
    Default = false,
    Callback = function(v)
        KillAll.Enabled = v
        if v then
            task.spawn(function()
                while KillAll.Enabled do
                    if hasKnife() then
                        killAllPlayers()
                        task.wait(3)
                    else
                        task.wait(1)
                    end
                end
            end)
        end
    end,
})

AutoFarmTab:Toggle({
    Title = "Anti-Fling",
    Default = false,
    Callback = function(v)
        if v then enableAntiFling() else disableAntiFling() end
    end,
})

-- ===== TELEPORT TAB =====
local TeleportTab = Window:Tab({Title = "Teleport", Icon = "map-pin"})

TeleportTab:Paragraph({Title = "Server Management", Desc = "Switch servers"})

TeleportTab:Button({
    Title = "Join Another Server",
    Callback = function() joinAnotherServer() end,
})

TeleportTab:Button({
    Title = "Rejoin Server",
    Callback = function() rejoinServer() end,
})

TeleportTab:Toggle({
    Title = "Anti-AFK",
    Desc = "Prevent kick for inactivity",
    Default = false,
    Callback = function(v) toggleAntiAFK(v) end,
})

-- ===== OPTIMIZATION TAB =====
local OptimizationTab = Window:Tab({Title = "Optimization", Icon = "settings"})

OptimizationTab:Paragraph({Title = "Player Info", Desc = "Your account details"})

OptimizationTab:Label("Display: " .. LocalPlayer.DisplayName)
OptimizationTab:Label("Username: @" .. LocalPlayer.Name)
OptimizationTab:Label("Player ID: " .. tostring(LocalPlayer.UserId))
OptimizationTab:Label("Game: Murder Mystery 2")
OptimizationTab:Label("Place ID: " .. tostring(game.PlaceId))

OptimizationTab:Divider()

OptimizationTab:Paragraph({Title = "Speed & Jump", Desc = "Adjust movement"})

OptimizationTab:Toggle({
    Title = "Speed Walk",
    Default = false,
    Callback = function(v)
        Movement.SpeedWalk.Enabled = v
        updateWalkSpeed()
    end,
})

OptimizationTab:Slider({
    Title = "Speed Value",
    Value = {Min = 16, Max = 116, Default = 16},
    Callback = function(v)
        Movement.SpeedWalk.Value = v
        if Movement.SpeedWalk.Enabled then updateWalkSpeed() end
    end,
})

OptimizationTab:Toggle({
    Title = "Jump Power",
    Default = false,
    Callback = function(v)
        Movement.JumpPower.Enabled = v
        updateJumpPower()
    end,
})

OptimizationTab:Slider({
    Title = "Jump Value",
    Value = {Min = 50, Max = 150, Default = 50},
    Callback = function(v)
        Movement.JumpPower.Value = v
        if Movement.JumpPower.Enabled then updateJumpPower() end
    end,
})

OptimizationTab:Toggle({
    Title = "Performance Overlay (Ping & FPS)",
    Default = false,
    Callback = function(v)
        Performance.Enabled = v
        if v then createPerformanceOverlay() else
            if Performance.Overlay then Performance.Overlay.destroy() end
        end
    end,
})

-- ============================================================
-- INITIALIZATION
-- ============================================================

findRemoteEvents()
connectRemoteEvents()

-- Слежение за фармом (уже в цикле startFarming)
-- Слежение за киллом (уже в цикле через toggle)

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.1)
    updateWalkSpeed()
    updateJumpPower()
end)

if LocalPlayer.Character then
    updateWalkSpeed()
    updateJumpPower()
end

-- ESP обновление
RunService.Heartbeat:Connect(function()
    if ESP_STATES.ESPName then updateESP() else clearAllESP() end
end)

RunService.Heartbeat:Connect(function()
    if ESP_HIGHLIGHT_STATES.ESPHighlight then updateHighlights() else clearAllHighlights() end
end)

-- Инициализация игроков
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            updateESP()
        end)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            updateESP()
        end)
        if ESP_LINE_STATES.ESPLine then
            local conn = InitializePlayerLines(player)
            if conn then table.insert(ESP.Connections, conn) end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if player ~= LocalPlayer then
        removePlayerBillboard(player)
        removePlayerHighlight(player)
        if ESP.LineDrawings[player.Name] then
            ESP.LineDrawings[player.Name]:Remove()
            ESP.LineDrawings[player.Name] = nil
        end
    end
end)

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    ESP.Camera = workspace.CurrentCamera
end)

-- Уведомление
WindUI:Notify({
    Title = "DustWay Hub",
    Content = "v2.0 loaded successfully!",
    Duration = 5,
    Icon = "check",
})

print("[DustWay] v2.0 loaded")