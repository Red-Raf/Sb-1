local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer  = Players.LocalPlayer
local Camera       = workspace.CurrentCamera

-- ───────────────── AutoFarm logic (from autofarm_mm2.lua) ─────────────────

local Settings = {
    AutoFarmEnabled   = false,
    FarmMode          = "Underground",
    TweenSpeed        = 25,
    AutoReset         = true,
    AvoidMurder       = true,
    UndergroundOffset = 4,
    MaxDistance       = 600,
    CoinLimit         = 40,
}

local State = {
    isFarming         = false,
    isActivelyFlying  = false,
    currentTargetCoin = nil,
    ignoredCoins      = {},
    currentTween      = nil,
}

local function getTorso(char)
    if not char then return nil end
    return char:FindFirstChild("Torso") or char:FindFirstChild("LowerTorso") or char:FindFirstChild("HumanoidRootPart")
end

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
        local currencyFrame = coin:FindFirstChild("CurrencyFrame")
        if not currencyFrame then return 0 end
        local icon = currencyFrame:FindFirstChild("Icon")
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
                local notification = coinBags:FindFirstChild("FullBagNotification")
                if notification and notification.Visible then return true end
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
        if obj.Name == "CoinContainer" then container = obj break end
    end
    if not container then return nil end
    local nearestCoin = nil
    local minDist = math.huge
    for _, coin in pairs(container:GetChildren()) do
        if coin.Name == "Coin_Server" and coin:IsA("BasePart") and not State.ignoredCoins[coin] then
            local dist = (torso.Position - coin.Position).Magnitude
            if dist < minDist and dist <= Settings.MaxDistance then
                minDist = dist
                nearestCoin = coin
            end
        end
    end
    return nearestCoin
end

local function applyFlightPhysics(char)
    if not char then return CFrame.Angles(0,0,0) end
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
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then humanoid.PlatformStand = true end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end

local function flyToPoint(targetPos, targetCoin, hrp, torso, lockedRotation)
    local dist = (torso.Position - targetPos).Magnitude
    local tweenInfo = TweenInfo.new(dist / Settings.TweenSpeed, Enum.EasingStyle.Linear)
    local targetCFrame = CFrame.new(targetPos) * lockedRotation
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    State.currentTween = tween
    local reached = false
    tween:Play()
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not State.isFarming or not targetCoin or not targetCoin:IsDescendantOf(workspace) then
            tween:Cancel()
            if connection then connection:Disconnect() end
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
            if connection then connection:Disconnect() end
        end
    end)
    while connection and connection.Connected do
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
        {CFrame = CFrame.new(target)}
    )
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
            local success, _ = pcall(function()
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
                local humanoid = char:FindFirstChild("Humanoid")
                if not hrp or not torso or not humanoid or humanoid.Health <= 0 then
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
                    if humanoid then humanoid.Sit = false end
                    task.wait(1)
                    return
                end
                if Settings.AutoReset then
                    local coins = getCurrentCoins()
                    if coins >= Settings.CoinLimit then
                        humanoid.Health = 0
                        task.wait(5)
                        return
                    end
                end
                local targetCoin = getNearestCoin(torso)
                if not targetCoin or not targetCoin:IsDescendantOf(workspace) then
                    State.isActivelyFlying = false
                    State.currentTargetCoin = nil
                    removePhysics()
                    if humanoid then humanoid.Sit = false end
                    task.wait(0.5)
                    return
                end
                State.isActivelyFlying = true
                State.currentTargetCoin = targetCoin
                local reachedTarget = false
                if Settings.FarmMode == "Underground" then
                    setupNoclip()
                    local lockedRotation = applyFlightPhysics(char)
                    local targetPos = targetCoin.Position - Vector3.new(0, Settings.UndergroundOffset, 0)
                    reachedTarget = flyToPoint(targetPos, targetCoin, hrp, torso, lockedRotation)
                elseif Settings.FarmMode == "Sit" then
                    reachedTarget = tweenToCoin(targetCoin)
                    if reachedTarget and State.isFarming and humanoid.Health > 0 then
                        collectCoin(targetCoin)
                    end
                end
                if reachedTarget and State.isFarming and humanoid.Health > 0 then
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
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
            humanoid.Sit = false
        end
    end
end

RunService.Stepped:Connect(function()
    if not State.isFarming or not State.isActivelyFlying or Settings.FarmMode ~= "Underground" then return end
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then humanoid.PlatformStand = true end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end)

-- ─────────────── ESP logic (from Onyx_hub.lua) ───────────────

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ESP_STATES = {
    ESPName          = false,
    MurdererName     = true,
    SheriffName      = true,
    HeroName         = true,
    InnocentName     = true,
}

local ESP_HIGHLIGHT_STATES = {
    ESPHighlight          = false,
    ESPHighlightMurderer  = true,
    ESPHighlightSheriff   = true,
    ESPHighlightHero      = true,
    ESPHighlightInnocent  = true,
}

local ESP_LINE_STATES = {
    ESPLine          = false,
    MurdererLine     = true,
    SheriffLine      = true,
    HeroLine         = true,
    InnocentLine     = true,
    LineThickness    = 1.4,
}

local ROLE_COLORS = {
    Murderer  = Color3.fromRGB(255, 0, 0),
    Sheriff   = Color3.fromRGB(0, 0, 255),
    Hero      = Color3.fromRGB(255, 255, 0),
    Innocent  = Color3.fromRGB(0, 255, 0),
}

local espBillboards  = {}
local espHighlights  = {}
local espLineDrawings = {}
local espLineConns   = {}
local cachedRoles    = {}
local lastRoleFetch  = 0

local function getRolesData()
    if tick() - lastRoleFetch < 0.5 then return cachedRoles end
    local ok, result = pcall(function()
        local GetPlayerData = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
        if GetPlayerData and GetPlayerData:IsA("RemoteFunction") then
            return GetPlayerData:InvokeServer()
        end
        return {}
    end)
    if ok and result then
        cachedRoles = result
        lastRoleFetch = tick()
    end
    return cachedRoles
end

local function getPlayerRole(player, rolesData)
    if not rolesData then return nil, false end
    local data = rolesData[player.Name]
    if not data then return nil, false end
    local alive = not data.Killed and not data.Dead
    return data.Role, alive
end

local function getRoleColor(role, alive)
    if not alive then return Color3.fromRGB(150, 150, 150) end
    return ROLE_COLORS[role] or Color3.fromRGB(255, 255, 255)
end

local function shouldShowHighlight(role, alive)
    if not ESP_HIGHLIGHT_STATES.ESPHighlight or not alive then return false end
    if role == "Murderer"  then return ESP_HIGHLIGHT_STATES.ESPHighlightMurderer end
    if role == "Sheriff"   then return ESP_HIGHLIGHT_STATES.ESPHighlightSheriff end
    if role == "Hero"      then return ESP_HIGHLIGHT_STATES.ESPHighlightHero end
    if role == "Innocent"  then return ESP_HIGHLIGHT_STATES.ESPHighlightInnocent end
    return false
end

local function shouldShowLine(role)
    if not ESP_LINE_STATES.ESPLine then return false end
    if role == "Murderer"  then return ESP_LINE_STATES.MurdererLine end
    if role == "Sheriff"   then return ESP_LINE_STATES.SheriffLine end
    if role == "Hero"      then return ESP_LINE_STATES.HeroLine end
    if role == "Innocent"  then return ESP_LINE_STATES.InnocentLine end
    return false
end

local function removeHighlight(player)
    if espHighlights[player] then
        espHighlights[player]:Destroy()
        espHighlights[player] = nil
    end
end

local function removeBillboard(player)
    if espBillboards[player] then
        espBillboards[player]:Destroy()
        espBillboards[player] = nil
    end
    if player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bb = hrp:FindFirstChild("PlayerBillboard")
            if bb then bb:Destroy() end
        end
    end
end

local function removeLine(player)
    if espLineDrawings[player] then
        espLineDrawings[player].Visible = false
        espLineDrawings[player]:Remove()
        espLineDrawings[player] = nil
    end
    if espLineConns[player] then
        espLineConns[player]:Disconnect()
        espLineConns[player] = nil
    end
end

local function clearAllHighlights()
    for p, _ in pairs(espHighlights) do removeHighlight(p) end
end

local function clearAllBillboards()
    for p, _ in pairs(espBillboards) do removeBillboard(p) end
end

local function clearAllLines()
    for p, _ in pairs(espLineDrawings) do removeLine(p) end
end

local function mkHighlight(player, role, alive)
    removeHighlight(player)
    local char = player.Character
    if not char then return end
    local h = Instance.new("Highlight")
    h.Name = "PlayerHighlight"
    h.Adornee = char
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.FillTransparency = 0.7
    h.OutlineTransparency = 0.4
    h.OutlineColor = Color3.new(1, 1, 1)
    h.FillColor = getRoleColor(role, alive)
    h.Parent = char
    espHighlights[player] = h
end

local function mkBillboard(player, role, alive)
    removeBillboard(player)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local existing = hrp:FindFirstChild("PlayerBillboard")
    if existing then
        local lbl = existing:FindFirstChild("PlayerName")
        if lbl then
            lbl.TextColor3 = getRoleColor(role, alive)
            lbl.Text = player.Name
        end
        return
    end
    local bg = Instance.new("BillboardGui")
    bg.Name = "PlayerBillboard"
    bg.Adornee = hrp
    bg.AlwaysOnTop = true
    bg.Size = UDim2.new(0, 100, 0, 30)
    bg.StudsOffset = Vector3.new(0, 2.5, 0)
    bg.ResetOnSpawn = false
    local lbl = Instance.new("TextLabel")
    lbl.Name = "PlayerName"
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = player.Name
    lbl.TextColor3 = getRoleColor(role, alive)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextStrokeTransparency = 0.5
    lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
    lbl.Parent = bg
    bg.Parent = hrp
    espBillboards[player] = bg
end

local function mkLine(player)
    removeLine(player)
    local ok = pcall(function() return Drawing.new("Line") end)
    if not ok then return end
    local drawing = Drawing.new("Line")
    drawing.Visible = false
    drawing.Color = Color3.fromRGB(255, 255, 255)
    drawing.Thickness = ESP_LINE_STATES.LineThickness
    espLineDrawings[player] = drawing

    espLineConns[player] = RunService.RenderStepped:Connect(function()
        if not ESP_LINE_STATES.ESPLine then
            drawing.Visible = false
            return
        end
        local char = player.Character
        if not char or player == LocalPlayer then
            drawing.Visible = false
            return
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then
            drawing.Visible = false
            return
        end
        local rolesData = getRolesData()
        local role, alive = getPlayerRole(player, rolesData)
        if not shouldShowLine(role) or not alive then
            drawing.Visible = false
            return
        end
        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if onScreen then
            drawing.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            drawing.To = Vector2.new(screenPos.X, screenPos.Y)
            drawing.Color = getRoleColor(role, alive)
            drawing.Thickness = ESP_LINE_STATES.LineThickness
            drawing.Visible = true
        else
            drawing.Visible = false
        end
    end)
end

local function updateESP()
    if not ESP_STATES.ESPName then clearAllBillboards() return end
    local rolesData = getRolesData()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not char or not hrp then
                removeBillboard(player)
            else
                local role, alive = getPlayerRole(player, rolesData)
                local show = false
                if role == "Murderer"  and ESP_STATES.MurdererName  then show = true end
                if role == "Sheriff"   and ESP_STATES.SheriffName   then show = true end
                if role == "Hero"      and ESP_STATES.HeroName       then show = true end
                if role == "Innocent"  and ESP_STATES.InnocentName   then show = true end
                if not role then show = true end
                if show then mkBillboard(player, role, alive)
                else removeBillboard(player) end
            end
        end
    end
end

local function updateHighlights()
    if not ESP_HIGHLIGHT_STATES.ESPHighlight then clearAllHighlights() return end
    local rolesData = getRolesData()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not player.Character then
                removeHighlight(player)
            else
                local role, alive = getPlayerRole(player, rolesData)
                if shouldShowHighlight(role, alive) then
                    mkHighlight(player, role, alive)
                else
                    removeHighlight(player)
                end
            end
        end
    end
end

local function startAllLines()
    clearAllLines()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then mkLine(player) end
    end
end

local function initESPPlayer(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        updateESP()
        updateHighlights()
    end)
    player.CharacterRemoving:Connect(function()
        removeBillboard(player)
        removeHighlight(player)
    end)
    if player.Character then
        task.spawn(function()
            task.wait(0.5)
            updateESP()
            updateHighlights()
        end)
    end
end

for _, p in ipairs(Players:GetPlayers()) do initESPPlayer(p) end
Players.PlayerAdded:Connect(initESPPlayer)
Players.PlayerRemoving:Connect(function(p)
    removeBillboard(p)
    removeHighlight(p)
    removeLine(p)
end)

-- ───────────── Player features (from Onyx_hub.lua) ─────────────

local Movement = {
    SpeedWalk = { Enabled = false, Value = 16 },
    JumpPower = { Enabled = false, Value = 50 },
}

local infJumpEnabled = false
local noclipEnabled  = false
local speedConn      = nil
local jumpConn       = nil

local function updateWalkSpeed()
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = Movement.SpeedWalk.Enabled and Movement.SpeedWalk.Value or 16
    end
end

local function updateJumpPower()
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if Movement.JumpPower.Enabled then
            hum.JumpPower    = Movement.JumpPower.Value
            hum.UseJumpPower = true
        else
            hum.JumpPower    = 50
            hum.UseJumpPower = false
        end
    end
end

RunService.Stepped:Connect(function()
    if not noclipEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, d in pairs(char:GetDescendants()) do
        if d:IsA("BasePart") then d.CanCollide = false end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if not infJumpEnabled then return end
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.delay(0.5, function()
        updateWalkSpeed()
        updateJumpPower()
    end)
end)

-- ───────────── Kill All logic (from Onyx_hub.lua) ─────────────

local KillAll = { Enabled = false, AttackDelay = 0.2 }

local function equipKnife()
    local char = LocalPlayer.Character
    if not char then return false end
    if char:FindFirstChild("Knife") then return true end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        local knife = bp:FindFirstChild("Knife")
        if knife then
            knife.Parent = char
            return true
        end
    end
    return false
end

local function getPlayerRoleFromServer(player)
    local ok, result = pcall(function()
        local GetPlayerData = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
        if GetPlayerData and GetPlayerData:IsA("RemoteFunction") then
            local data = GetPlayerData:InvokeServer()
            if data and data[player.Name] then
                return data[player.Name].Role
            end
        end
        return nil
    end)
    return ok and result or nil
end

local VALID_TARGET_ROLES = {"Murderer"}

local function getAllValidTargets()
    local targets = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local role = getPlayerRoleFromServer(player)
            local hum  = player.Character:FindFirstChild("Humanoid")
            if role and hum and hum.Health > 0 and table.find(VALID_TARGET_ROLES, role) then
                table.insert(targets, player)
            end
        end
    end
    return targets
end

local function killAllPlayers()
    if not equipKnife() then return end
    task.wait(0.1)
    local Remotes  = ReplicatedStorage:FindFirstChild("Remotes")
    local killEvent
    if Remotes then
        local Gameplay = Remotes:FindFirstChild("Gameplay")
        if Gameplay then
            killEvent = Gameplay:FindFirstChild("KillEvent")
        end
    end
    if not killEvent then return end
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local targets = getAllValidTargets()
    for _, v in ipairs(targets) do
        if not KillAll.Enabled then return end
        local char = v.Character
        if char then
            local hum  = char:FindFirstChild("Humanoid")
            local hrp  = char:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp then
                hrp.CFrame = myHRP.CFrame * CFrame.new(0, 0, -3)
                pcall(function() killEvent:FireServer(v.Name, Color3.new(1, 0, 0)) end)
                task.wait(KillAll.AttackDelay)
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if KillAll.Enabled then
            task.spawn(killAllPlayers)
        end
    end
end)

-- ───────────── Shoot Murderer logic (from Onyx_hub.lua) ─────────────

local function findMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Knife") then return p end
        local bp = p:FindFirstChild("Backpack")
        if bp and bp:FindFirstChild("Knife") then return p end
    end
    return nil
end

local function findSheriff()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Gun") then return p end
        local bp = p:FindFirstChild("Backpack")
        if bp and bp:FindFirstChild("Gun") then return p end
    end
    return nil
end

local function shootMurderer()
    if findSheriff() ~= LocalPlayer then return end
    local murderer = findMurderer()
    if not murderer then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    if not myChar:FindFirstChild("Gun") then
        local hum = myChar:FindFirstChild("Humanoid")
        local bp  = LocalPlayer:FindFirstChild("Backpack")
        local gun = bp and bp:FindFirstChild("Gun")
        if not hum or not gun then return end
        hum:EquipTool(gun)
    end
    local mHRP = murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart")
    if not mHRP then return end
    local mVel = mHRP.AssemblyLinearVelocity
    local mDir = (murderer.Character:FindFirstChild("Humanoid") or {MoveDirection = Vector3.zero}).MoveDirection
    local predictedPos = mHRP.Position + mVel * Vector3.new(0.75, 0.5, 0.75) * (2.8 / 15) + mDir * 2.8
    local myRH = myChar:FindFirstChild("RightHand")
    if not myRH then return end
    local gun = myChar:FindFirstChild("Gun")
    if not gun then return end
    local shootRemote = gun:FindFirstChild("Shoot")
    if not shootRemote then return end
    pcall(function()
        shootRemote:FireServer(CFrame.new(myRH.Position), CFrame.new(predictedPos))
    end)
end

-- ─────────── Anti-AFK (from Onyx_hub.lua) ───────────

local antiAFKEnabled = false
local antiAFKTask    = nil

local function startAntiAFK()
    if antiAFKTask then task.cancel(antiAFKTask) end
    antiAFKTask = task.spawn(function()
        while antiAFKEnabled do
            task.wait(300)
            local vu = pcall(function() return game:GetService("VirtualUser") end) and game:GetService("VirtualUser")
            if vu then
                pcall(function()
                    vu:Button2Down(Vector2.new(0, 0), Camera.CFrame)
                    task.wait(0.1)
                    vu:Button2Up(Vector2.new(0, 0), Camera.CFrame)
                end)
            end
        end
    end)
end

-- ─────────── Teleport (from Onyx_hub.lua) ───────────

local TeleportService = game:GetService("TeleportService")

local function joinAnotherServer()
    pcall(function()
        local code = TeleportService:ReserveServer(game.PlaceId)
        TeleportService:TeleportToPrivateServer(game.PlaceId, code, {LocalPlayer})
    end)
end

local function rejoinServer()
    pcall(function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end

-- ───────────── WindUI ─────────────

local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

WindUI:AddTheme({
    Name                         = "PressureRed",
    Accent                       = Color3.fromHex("#DC2626"),
    Background                   = Color3.fromHex("#0A0A0C"),
    Outline                      = Color3.fromHex("#3B0A0A"),
    Text                         = Color3.fromHex("#F0F0F5"),
    Placeholder                  = Color3.fromHex("#7A4040"),
    Button                       = Color3.fromHex("#1F1010"),
    Icon                         = Color3.fromHex("#DC2626"),
    WindowBackground             = Color3.fromHex("#080809"),
    WindowShadow                 = Color3.fromHex("#000000"),
    DialogBackground             = Color3.fromHex("#0D0D10"),
    DialogBackgroundTransparency = 0,
    DialogTitle                  = Color3.fromHex("#F0F0F5"),
    DialogContent                = Color3.fromHex("#C0C0C5"),
    DialogIcon                   = Color3.fromHex("#DC2626"),
    WindowTopbarButtonIcon       = Color3.fromHex("#DC2626"),
    WindowTopbarTitle            = Color3.fromHex("#F0F0F5"),
    WindowTopbarAuthor           = Color3.fromHex("#7A4040"),
    WindowTopbarIcon             = Color3.fromHex("#DC2626"),
    TabBackground                = Color3.fromHex("#100808"),
    TabTitle                     = Color3.fromHex("#F0F0F5"),
    TabIcon                      = Color3.fromHex("#DC2626"),
    ElementBackground            = Color3.fromHex("#110A0A"),
    ElementTitle                 = Color3.fromHex("#F0F0F5"),
    ElementDesc                  = Color3.fromHex("#A08080"),
    ElementIcon                  = Color3.fromHex("#DC2626"),
    PopupBackground              = Color3.fromHex("#0D0D10"),
    PopupBackgroundTransparency  = 0,
    PopupTitle                   = Color3.fromHex("#F0F0F5"),
    PopupContent                 = Color3.fromHex("#C0C0C5"),
    PopupIcon                    = Color3.fromHex("#DC2626"),
})

WindUI:SetTheme("PressureRed")

local Window = WindUI:CreateWindow({
    Title         = "PressureHub",
    Author        = "MM2 Edition",
    Icon          = "zap",
    Folder        = "PressureHub",
    Size          = UDim2.fromOffset(580, 460),
    Theme         = "PressureRed",
    HideSearchBar = true,
    OpenButton    = {
        Title           = "PressureHub",
        CornerRadius    = UDim.new(0, 8),
        StrokeThickness = 2,
        Enabled         = true,
        Draggable       = true,
        OnlyMobile      = false,
        Color           = ColorSequence.new(
            Color3.fromHex("#DC2626"),
            Color3.fromHex("#7F1D1D")
        ),
    },
})

-- ──────────── Tab: AutoFarm ────────────

local TabFarm = Window:Tab({ Title = "AutoFarm", Icon = "coins" })

TabFarm:Toggle({
    Title    = "Auto Farm",
    Desc     = "Automatically collects coins",
    Icon     = "play",
    Default  = false,
    Callback = function(v)
        Settings.AutoFarmEnabled = v
        if v then startFarming() else stopFarming() end
    end,
})

TabFarm:Toggle({
    Title    = "Auto Reset",
    Desc     = "Reset at coin limit",
    Icon     = "refresh-cw",
    Default  = true,
    Callback = function(v) Settings.AutoReset = v end,
})

TabFarm:Toggle({
    Title    = "Avoid Murderer",
    Desc     = "Pauses if knife nearby",
    Icon     = "shield",
    Default  = true,
    Callback = function(v) Settings.AvoidMurder = v end,
})

TabFarm:Dropdown({
    Title    = "Farm Mode",
    Desc     = "Underground = noclip, Sit = tween",
    Icon     = "layers",
    Values   = { "Underground", "Sit" },
    Default  = "Underground",
    Callback = function(v) Settings.FarmMode = v end,
})

TabFarm:Slider({
    Title    = "Tween Speed",
    Desc     = "Movement speed toward coins",
    Icon     = "gauge",
    Value    = { Min = 5, Max = 30, Default = 25 },
    Callback = function(v) Settings.TweenSpeed = v end,
})

TabFarm:Button({
    Title    = "Stop Farm",
    Desc     = "Force stop farming",
    Icon     = "square",
    Callback = function()
        stopFarming()
        WindUI:Notification({ Title = "PressureHub", Content = "Farm stopped.", Icon = "x", Duration = 3 })
    end,
})

-- ──────────── Tab: Player ────────────

local TabPlayer = Window:Tab({ Title = "Player", Icon = "user" })

TabPlayer:Toggle({
    Title    = "Speed Walk",
    Desc     = "Custom movement speed",
    Icon     = "zap",
    Default  = false,
    Callback = function(v)
        Movement.SpeedWalk.Enabled = v
        updateWalkSpeed()
    end,
})

TabPlayer:Slider({
    Title    = "Speed Value",
    Desc     = "Walk speed amount",
    Icon     = "gauge",
    Value    = { Min = 1, Max = 200, Default = 16 },
    Callback = function(v)
        Movement.SpeedWalk.Value = v
        if Movement.SpeedWalk.Enabled then updateWalkSpeed() end
    end,
})

TabPlayer:Toggle({
    Title    = "Jump Power",
    Desc     = "Custom jump height",
    Icon     = "arrow-up",
    Default  = false,
    Callback = function(v)
        Movement.JumpPower.Enabled = v
        updateJumpPower()
    end,
})

TabPlayer:Slider({
    Title    = "Jump Power Value",
    Desc     = "Jump height amount",
    Icon     = "gauge",
    Value    = { Min = 1, Max = 500, Default = 50 },
    Callback = function(v)
        Movement.JumpPower.Value = v
        if Movement.JumpPower.Enabled then updateJumpPower() end
    end,
})

TabPlayer:Toggle({
    Title    = "Infinite Jump",
    Desc     = "Jump infinitely in air",
    Icon     = "arrow-up",
    Default  = false,
    Callback = function(v) infJumpEnabled = v end,
})

TabPlayer:Toggle({
    Title    = "Noclip",
    Desc     = "Phase through walls",
    Icon     = "layers",
    Default  = false,
    Callback = function(v) noclipEnabled = v end,
})

TabPlayer:Toggle({
    Title    = "Anti-AFK",
    Desc     = "Prevent AFK kick every 5 min",
    Icon     = "clock",
    Default  = false,
    Callback = function(v)
        antiAFKEnabled = v
        if v then startAntiAFK()
        elseif antiAFKTask then task.cancel(antiAFKTask) end
    end,
})

-- ──────────── Tab: Combat ────────────

local TabCombat = Window:Tab({ Title = "Combat", Icon = "crosshair" })

TabCombat:Toggle({
    Title    = "Kill All (Murderer)",
    Desc     = "Auto-kill murderers with knife",
    Icon     = "target",
    Default  = false,
    Callback = function(v) KillAll.Enabled = v end,
})

TabCombat:Slider({
    Title    = "Attack Delay",
    Desc     = "Delay between kills (seconds)",
    Icon     = "clock",
    Value    = { Min = 0, Max = 2, Default = 0 },
    Callback = function(v) KillAll.AttackDelay = v end,
})

TabCombat:Toggle({
    Title    = "Shoot Murderer",
    Desc     = "Auto-shoot murderer when sheriff",
    Icon     = "zap",
    Default  = false,
    Callback = function(v)
        if v then
            task.spawn(function()
                while v do
                    task.wait(0.5)
                    pcall(shootMurderer)
                end
            end)
        end
    end,
})

-- ──────────── Tab: ESP (Name) ────────────

local TabESPName = Window:Tab({ Title = "ESP Names", Icon = "type" })

TabESPName:Toggle({
    Title    = "ESP Name",
    Desc     = "Show names above all players",
    Icon     = "eye",
    Default  = false,
    Callback = function(v)
        ESP_STATES.ESPName = v
        if v then updateESP() else clearAllBillboards() end
    end,
})

TabESPName:Toggle({
    Title    = "Murderer Name",
    Desc     = "Show murderer name",
    Icon     = "user",
    Default  = true,
    Callback = function(v)
        ESP_STATES.MurdererName = v
        if ESP_STATES.ESPName then updateESP() end
    end,
})

TabESPName:Toggle({
    Title    = "Sheriff Name",
    Desc     = "Show sheriff name",
    Icon     = "user",
    Default  = true,
    Callback = function(v)
        ESP_STATES.SheriffName = v
        if ESP_STATES.ESPName then updateESP() end
    end,
})

TabESPName:Toggle({
    Title    = "Hero Name",
    Desc     = "Show hero name",
    Icon     = "user",
    Default  = true,
    Callback = function(v)
        ESP_STATES.HeroName = v
        if ESP_STATES.ESPName then updateESP() end
    end,
})

TabESPName:Toggle({
    Title    = "Innocent Name",
    Desc     = "Show innocent name",
    Icon     = "user",
    Default  = true,
    Callback = function(v)
        ESP_STATES.InnocentName = v
        if ESP_STATES.ESPName then updateESP() end
    end,
})

-- ──────────── Tab: ESP Highlight ────────────

local TabESPHL = Window:Tab({ Title = "ESP Highlight", Icon = "scan" })

TabESPHL:Toggle({
    Title    = "ESP Highlight",
    Desc     = "Highlight all players through walls",
    Icon     = "eye",
    Default  = false,
    Callback = function(v)
        ESP_HIGHLIGHT_STATES.ESPHighlight = v
        if v then updateHighlights() else clearAllHighlights() end
    end,
})

TabESPHL:Toggle({
    Title    = "Murderer Highlight",
    Desc     = "Highlight murderer (red)",
    Icon     = "square",
    Default  = true,
    Callback = function(v)
        ESP_HIGHLIGHT_STATES.ESPHighlightMurderer = v
        if ESP_HIGHLIGHT_STATES.ESPHighlight then updateHighlights() end
    end,
})

TabESPHL:Toggle({
    Title    = "Sheriff Highlight",
    Desc     = "Highlight sheriff (blue)",
    Icon     = "square",
    Default  = true,
    Callback = function(v)
        ESP_HIGHLIGHT_STATES.ESPHighlightSheriff = v
        if ESP_HIGHLIGHT_STATES.ESPHighlight then updateHighlights() end
    end,
})

TabESPHL:Toggle({
    Title    = "Hero Highlight",
    Desc     = "Highlight hero (yellow)",
    Icon     = "square",
    Default  = true,
    Callback = function(v)
        ESP_HIGHLIGHT_STATES.ESPHighlightHero = v
        if ESP_HIGHLIGHT_STATES.ESPHighlight then updateHighlights() end
    end,
})

TabESPHL:Toggle({
    Title    = "Innocent Highlight",
    Desc     = "Highlight innocent (green)",
    Icon     = "square",
    Default  = true,
    Callback = function(v)
        ESP_HIGHLIGHT_STATES.ESPHighlightInnocent = v
        if ESP_HIGHLIGHT_STATES.ESPHighlight then updateHighlights() end
    end,
})

-- ──────────── Tab: ESP Tracers ────────────

local TabESPLine = Window:Tab({ Title = "ESP Tracers", Icon = "arrow-right" })

TabESPLine:Toggle({
    Title    = "ESP Tracer",
    Desc     = "Draw lines to all players",
    Icon     = "eye",
    Default  = false,
    Callback = function(v)
        ESP_LINE_STATES.ESPLine = v
        if v then startAllLines() else clearAllLines() end
    end,
})

TabESPLine:Toggle({
    Title    = "Murderer Tracer",
    Desc     = "Line to murderer",
    Icon     = "arrow-right",
    Default  = true,
    Callback = function(v)
        ESP_LINE_STATES.MurdererLine = v
        if ESP_LINE_STATES.ESPLine then startAllLines() end
    end,
})

TabESPLine:Toggle({
    Title    = "Sheriff Tracer",
    Desc     = "Line to sheriff",
    Icon     = "arrow-right",
    Default  = true,
    Callback = function(v)
        ESP_LINE_STATES.SheriffLine = v
        if ESP_LINE_STATES.ESPLine then startAllLines() end
    end,
})

TabESPLine:Toggle({
    Title    = "Hero Tracer",
    Desc     = "Line to hero",
    Icon     = "arrow-right",
    Default  = true,
    Callback = function(v)
        ESP_LINE_STATES.HeroLine = v
        if ESP_LINE_STATES.ESPLine then startAllLines() end
    end,
})

TabESPLine:Toggle({
    Title    = "Innocent Tracer",
    Desc     = "Line to innocent",
    Icon     = "arrow-right",
    Default  = true,
    Callback = function(v)
        ESP_LINE_STATES.InnocentLine = v
        if ESP_LINE_STATES.ESPLine then startAllLines() end
    end,
})

TabESPLine:Slider({
    Title    = "Line Thickness",
    Desc     = "Tracer line thickness",
    Icon     = "minus",
    Value    = { Min = 1, Max = 5, Default = 1 },
    Callback = function(v) ESP_LINE_STATES.LineThickness = v end,
})

-- ──────────── Tab: Teleport ────────────

local TabTeleport = Window:Tab({ Title = "Teleport", Icon = "map-pin" })

TabTeleport:Button({
    Title    = "Join Another Server",
    Desc     = "Teleport to a new server",
    Icon     = "shuffle",
    Callback = function()
        joinAnotherServer()
    end,
})

TabTeleport:Button({
    Title    = "Rejoin Server",
    Desc     = "Rejoin current place",
    Icon     = "refresh-cw",
    Callback = function()
        rejoinServer()
    end,
})

-- ──────────── Tab: Settings ────────────

local TabSettings = Window:Tab({ Title = "Settings", Icon = "settings" })

TabSettings:Keybind({
    Title    = "Menu Keybind",
    Desc     = "Open / close PressureHub",
    Icon     = "keyboard",
    Default  = Enum.KeyCode.RightShift,
    Callback = function(key) Window:EditKeybind(key) end,
})

TabSettings:Button({
    Title    = "Unload",
    Desc     = "Remove UI and stop everything",
    Icon     = "trash-2",
    Callback = function()
        stopFarming()
        clearAllHighlights()
        clearAllBillboards()
        clearAllLines()
        WindUI:Destroy()
    end,
})

WindUI:Notification({
    Title    = "PressureHub",
    Content  = "Loaded! RightShift to open.",
    Icon     = "zap",
    Duration = 5,
})
