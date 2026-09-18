--[[
    AuroraHub - Murder Mystery 2 Script
    Created by aurorahud
    Features: Kill All (as Murderer), Kill 1v1, Auto Kill Loop,
    ESP with roles & distance, Gun Aimbot, Fly, Anti-AFK, and more.
    
    This script is open source and free to use or modify.
    Give credit if you want, but it's not required.
]]

-- ============================================================
-- LOAD CHECK
-- ============================================================
if not game:IsLoaded() then
    local s = pcall(function() game.Loaded:Wait() end)
    if not s then repeat task.wait() until game:IsLoaded() end
end
if game.PlaceId ~= 142823291 then return end -- MM2 only

-- ============================================================
-- ORION UI LIBRARY
-- ============================================================
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Backlostunking/ScriptLua/refs/heads/main/Orion-GB-V2.Lua"))()
local executor = identifyexecutor and identifyexecutor() or getexecutorname and getexecutorname() or "Unknown"
local GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
local Window = OrionLib:MakeWindow({
    IntroText = "Script Made By aurorahud",
    IntroIcon = "rbxassetid://7733955511",
    Name = ("AuroraHub • " .. GameName .. " ✓ Executor " .. executor),
    IntroToggleIcon = "rbxassetid://4335489011",
    HidePremium = false,
    SaveConfig = false,
    IntroEnabled = true,
    ConfigFolder = "AuroraHubMM2"
})

-- ============================================================
-- TABS
-- ============================================================
local MainTab    = Window:MakeTab({Name = "Main",     Icon = "rbxassetid://4483345998", PremiumOnly = false})
local MurderTab  = Window:MakeTab({Name = "Murderer", Icon = "rbxassetid://4335489011", PremiumOnly = false})
local PlayerTab  = Window:MakeTab({Name = "Local",    Icon = "rbxassetid://4335489011", PremiumOnly = false})
local MiscTab    = Window:MakeTab({Name = "Misc",     Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- ============================================================
-- SERVICES & VARIABLES
-- ============================================================
local env = getgenv and getgenv() or getrenv and getrenv() or getfenv and getfenv(0) or _G
local cloneref = cloneref or (function()
    local s, func = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Backlostunking/Open-Source/refs/heads/main/cloneref-TheCloneVM"))()
    end)
    return s and func or function(s) return s end
end)()

local Players           = cloneref(game:GetService("Players"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Tween             = cloneref(game:GetService("TweenService"))
local RunService        = cloneref(game:GetService("RunService"))
local Workspace         = cloneref(game:GetService("Workspace"))
local UserInputService  = cloneref(game:GetService("UserInputService"))
local HttpService       = cloneref(game:GetService("HttpService"))

local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local backpack    = LocalPlayer:FindFirstChild("Backpack") or LocalPlayer:WaitForChild("Backpack")
local Char        = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Hum         = Char and Char:FindFirstChildWhichIsA("Humanoid")
local Root        = (Hum and Hum.RootPart) or Char:FindFirstChild("HumanoidRootPart")

-- Auto-update on respawn
LocalPlayer.CharacterAdded:Connect(function()
    repeat task.wait()
        LocalPlayer = Players.LocalPlayer
        backpack    = LocalPlayer:FindFirstChild("Backpack") or LocalPlayer:WaitForChild("Backpack")
        Char        = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        Hum         = Char and Char:FindFirstChildWhichIsA("Humanoid")
        Root        = (Hum and Hum.RootPart) or Char:FindFirstChild("HumanoidRootPart")
    until LocalPlayer and backpack and Char and Hum and Root
end)

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================
local function notify(title, content, time)
    OrionLib:MakeNotification({
        Name    = title or "AuroraHub",
        Content = content or "",
        Image   = "rbxassetid://7733658504",
        Time    = time or 3
    })
end

local function getRoles()
    local ok, data = pcall(function()
        return ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
    end)
    if not ok or not data then return {} end
    local roles = {}
    for plr, plrData in pairs(data) do
        if not plrData.Dead then
            roles[plr] = plrData.Role
        end
    end
    return roles
end

local function getMyRole()
    local roles = getRoles()
    return roles[LocalPlayer.Name]
end

local function isMurderer()
    return getMyRole() == "Murderer"
end

local function getMurdererHRP()
    local data
    local ok, res = pcall(function()
        data = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
    end)
    if not ok then return nil, false end
    for plr, plrData in pairs(data) do
        if plrData.Role == "Murderer" then
            local player = Players:FindFirstChild(plr)
            if player then
                if player == LocalPlayer then return nil, true end
                local char = player.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then return hrp.Position, false end
                    local head = char:FindFirstChild("Head")
                    if head then return head.Position, false end
                end
            end
        end
    end
    return nil, false
end

-- ============================================================
-- FLING FUNCTION (improved)
-- ============================================================
local function SHubFling(TargetPlayer)
    if not (Char and Hum and Root) then return end
    local TCharacter = TargetPlayer.Character
    if not TCharacter then return end
    local THumanoid  = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart  = THumanoid and THumanoid.RootPart
    local THead      = TCharacter:FindFirstChild("Head")
    local Accessory  = TCharacter:FindFirstChildOfClass("Accessory")
    local Handle     = Accessory and Accessory:FindFirstChild("Handle")
    env.OldPos = Root.CFrame

    repeat task.wait()
        Workspace.CurrentCamera.CameraSubject = THead or Handle or THumanoid
    until Workspace.CurrentCamera.CameraSubject == (THead or Handle or THumanoid)

    local function FPos(BasePart, Pos, Ang)
        local targetCF = CFrame.new(BasePart.Position) * Pos * Ang
        Root.CFrame = targetCF
        Char:SetPrimaryPartCFrame(targetCF)
        Root.Velocity = Vector3.new(9e7, 9e8, 9e7)
        Root.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
    end

    local function SFBasePart(BasePart)
        local start = tick()
        local angle = 0
        env.timeout = env.timeout or 2.5
        repeat
            if Root and THumanoid then
                angle += 100
                for _, offset in ipairs{
                    CFrame.new(0, 1.5, 0), CFrame.new(0, -1.5, 0),
                    CFrame.new(2.25, 1.5, -2.25), CFrame.new(-2.25, -1.5, 2.25)
                } do
                    FPos(BasePart, offset + THumanoid.MoveDirection, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                end
            end
        until BasePart.Velocity.Magnitude > 500 or tick() - start > env.timeout
    end

    local BV = Instance.new("BodyVelocity")
    BV.Name     = "SeYyyVel!?"
    BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
    BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    BV.Parent   = Root
    Hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

    local target = TRootPart or THead or Handle
    if target then SFBasePart(target) end

    BV:Destroy()
    Hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)

    repeat task.wait()
        Workspace.CurrentCamera.CameraSubject = Hum
    until Workspace.CurrentCamera.CameraSubject == Hum

    repeat
        local cf = env.OldPos * CFrame.new(0, .5, 0)
        Root.CFrame = cf
        Char:SetPrimaryPartCFrame(cf)
        Hum:ChangeState("GettingUp")
        for _, part in ipairs(Char:GetChildren()) do
            if part:IsA("BasePart") then
                part.Velocity, part.RotVelocity = Vector3.zero, Vector3.zero
            end
        end
        task.wait()
    until (Root.Position - env.OldPos.p).Magnitude < 25
end

-- ============================================================
-- KNIFE KILL FUNCTION (for Murderer)
-- ============================================================
local function getKnifeRemote()
    local knife = Char and (Char:FindFirstChild("Knife") or Char:FindFirstChild("ClassicKnife"))
    if not knife then return nil end
    local knifeScript = knife:FindFirstChild("KnifeLocal") or knife:FindFirstChild("LocalScript")
    if not knifeScript then return nil end
    local cb = knifeScript:FindFirstChild("CreateBeam") or knifeScript:FindFirstChild("Beam")
    return cb and cb:FindFirstChildWhichIsA("RemoteFunction") or cb and cb:FindFirstChildWhichIsA("RemoteEvent")
end

local function throwKnifeAt(targetPos)
    if not targetPos then return end
    local remote = getKnifeRemote()
    if not remote then return end
    pcall(function()
        if remote:IsA("RemoteFunction") then
            remote:InvokeServer(1, targetPos, "AH2")
        else
            remote:FireServer(1, targetPos, "AH2")
        end
    end)
end

-- Teleport behind player then throw knife (1v1 kill)
local function killPlayer(targetPlayer)
    if not targetPlayer or targetPlayer == LocalPlayer then return end
    local tChar = targetPlayer.Character
    if not tChar then return end
    local tHRP = tChar:FindFirstChild("HumanoidRootPart")
    if not tHRP or not Root then return end

    -- Teleport close to target
    local offset = CFrame.new(0, 0, -2)
    Root.CFrame = tHRP.CFrame * offset
    task.wait(0.05)

    -- Throw knife
    throwKnifeAt(tHRP.Position)
end

-- ============================================================
-- HOOK CHECK (for aimbot)
-- ============================================================
local function check()
    local success, hookFunc = false, nil
    if not getnamecallmethod or not checkcaller then return success end
    local mt = getrawmetatable and getrawmetatable(game) or debug and debug.getmetatable and debug.getmetatable(game)
    local function handleNamecall(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if not checkcaller() then
            if method == "InvokeServer" and tostring(self) == "RemoteFunction" and env.enabledGunBot then
                return nil
            end
        end
        return hookFunc(self, unpack(args))
    end
    if hookmetamethod and newcclosure then
        hookFunc = hookmetamethod(game, "__namecall", newcclosure(handleNamecall))
        success = true
    elseif mt and setreadonly and newcclosure then
        setreadonly(mt, false)
        hookFunc = mt.__namecall
        mt.__namecall = newcclosure(handleNamecall)
        setreadonly(mt, true)
        success = true
    elseif hookmetamethod then
        hookFunc = hookmetamethod(game, "__namecall", handleNamecall)
        success = true
    elseif mt and setreadonly then
        setreadonly(mt, false)
        hookFunc = mt.__namecall
        mt.__namecall = handleNamecall
        setreadonly(mt, true)
        success = true
    end
    return success
end
local isUseHook = check()

-- ============================================================
-- PLAYER NAMES HELPER
-- ============================================================
local function getPlayerNames()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

-- ============================================================
-- ████████████  MAIN TAB  ████████████
-- ============================================================

-- ── ESP Player (Role & Name) ──────────────────────────────
MainTab:AddToggle({
    Name = "Esp Player (Role & Name)",
    Default = false,
    Callback = function(Value)
        env.ESP_ENABLED = Value
        local updateLoop = nil
        local roleColors = {
            Murderer  = Color3.fromRGB(255, 0, 0),
            Sheriff   = Color3.fromRGB(0, 80, 255),
            Hero      = Color3.fromRGB(255, 220, 0),
            Innocent  = Color3.fromRGB(0, 220, 0),
            Default   = Color3.fromRGB(200, 200, 200)
        }

        local function clearESP()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        local esp = head:FindFirstChild("RoleESP")
                        if esp then esp:Destroy() end
                    end
                    local hl = player.Character:FindFirstChild("RoleHighlight")
                    if hl then hl:Destroy() end
                end
            end
        end

        local function applyHighlight(character, role)
            local existing = character:FindFirstChild("RoleHighlight")
            if existing then existing:Destroy() end
            local hl = Instance.new("Highlight")
            hl.Name               = "RoleHighlight"
            hl.FillColor          = roleColors[role] or roleColors.Default
            hl.OutlineColor       = Color3.new(1, 1, 1)
            hl.DepthMode          = Enum.HighlightDepthMode.AlwaysOnTop
            hl.FillTransparency   = 0.4
            hl.OutlineTransparency = 0
            hl.Parent             = character
        end

        local function createBillboard(head, role, playerName, dist)
            local esp = Instance.new("BillboardGui")
            esp.Name        = "RoleESP"
            esp.Adornee     = head
            esp.Size        = UDim2.new(5, 0, 5, 0)
            esp.AlwaysOnTop = true
            esp.Parent      = head

            local label = Instance.new("TextLabel")
            label.Name                  = "RoleLabel"
            label.Parent                = esp
            label.Size                  = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextStrokeTransparency = 0
            label.TextSize              = 14
            label.TextColor3            = roleColors[role] or roleColors.Default
            label.Font                  = Enum.Font.FredokaOne
            label.Text                  = ("Role: %s\n%s\n%.0f studs"):format(role, playerName, dist or 0)
        end

        local function updateESP()
            local roles = getRoles()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        local role = roles[player.Name] or "Default"
                        local dist = Root and (head.Position - Root.Position).Magnitude or 0
                        if not head:FindFirstChild("RoleESP") then
                            createBillboard(head, role, player.Name, dist)
                        else
                            local label = head.RoleESP:FindFirstChild("RoleLabel")
                            if label then
                                label.Text      = ("Role: %s\n%s\n%.0f studs"):format(role, player.Name, dist)
                                label.TextColor3 = roleColors[role] or roleColors.Default
                            end
                        end
                        local light = player.Character:FindFirstChild("RoleHighlight")
                        if not light then
                            applyHighlight(player.Character, role)
                        else
                            light.FillColor = roleColors[role] or roleColors.Default
                        end
                    end
                end
            end
        end

        local function startESP()
            if updateLoop then return end
            updateLoop = task.spawn(function()
                while env.ESP_ENABLED do
                    pcall(updateESP)
                    task.wait(0.25)
                end
                clearESP()
                updateLoop = nil
            end)
        end

        if Value then startESP() else clearESP() end
    end
})

-- ── ESP Gun ──────────────────────────────────────────────
MainTab:AddToggle({
    Name = "Esp Gun",
    Default = false,
    Callback = function(Value)
        env.GunEsp = Value
        local gun = Workspace:FindFirstChild("GunDrop", true)
        if not env.GunEsp then
            if gun then
                local gh = gun:FindFirstChild("GunHighlight")
                if gh then gh:Destroy() end
                local ge = gun:FindFirstChild("GunEsp")
                if ge then ge:Destroy() end
            end
        end
        while env.GunEsp do
            gun = Workspace:FindFirstChild("GunDrop", true)
            if gun then
                if not gun:FindFirstChild("GunHighlight") then
                    local gunh = Instance.new("Highlight", gun)
                    gunh.Name               = "GunHighlight"
                    gunh.FillColor          = Color3.new(1, 1, 0)
                    gunh.OutlineColor       = Color3.new(1, 1, 1)
                    gunh.DepthMode          = Enum.HighlightDepthMode.AlwaysOnTop
                    gunh.FillTransparency   = 0.4
                    gunh.OutlineTransparency = 0.5
                end
                if not gun:FindFirstChild("GunEsp") then
                    local esp  = Instance.new("BillboardGui")
                    esp.Name        = "GunEsp"
                    esp.Adornee     = gun
                    esp.Size        = UDim2.new(5, 0, 5, 0)
                    esp.AlwaysOnTop = true
                    esp.Parent      = gun
                    local text = Instance.new("TextLabel", esp)
                    text.Name                  = "GunLabel"
                    text.Size                  = UDim2.new(1, 0, 1, 0)
                    text.BackgroundTransparency = 1
                    text.TextStrokeTransparency = 0
                    text.TextColor3            = Color3.fromRGB(255, 255, 0)
                    text.Font                  = Enum.Font.FredokaOne
                    text.TextSize              = 16
                    text.Text                  = "🔫 Gun Drop"
                end
            end
            task.wait(0.1)
        end
    end
})

-- ── Grab Gun ──────────────────────────────────────────────
MainTab:AddButton({
    Name = "Grab Gun",
    Callback = function()
        if not (Char and Root) then return end
        local gun = Workspace:FindFirstChild("GunDrop", true)
        if gun then
            if firetouchinterest then
                firetouchinterest(Root, gun, 0)
                firetouchinterest(Root, gun, 1)
            else
                gun.CFrame = Root.CFrame
            end
            notify("Grab Gun", "Gun grabbed!", 2)
        else
            notify("Grab Gun", "No gun found on map.", 2)
        end
    end
})

-- ── Auto Grab Gun ─────────────────────────────────────────
MainTab:AddToggle({
    Name = "Auto Grab Gun",
    Default = false,
    Callback = function(Value)
        env.AGG = Value
        while env.AGG do
            if Char and Root then
                local gun = Workspace:FindFirstChild("GunDrop", true)
                if gun then
                    if firetouchinterest then
                        firetouchinterest(Root, gun, 0)
                        firetouchinterest(Root, gun, 1)
                    else
                        gun.CFrame = Root.CFrame
                    end
                end
            end
            task.wait(0.1)
        end
    end
})

-- ── Steal Gun ─────────────────────────────────────────────
MainTab:AddButton({
    Name = "Steal Gun (Sheriff & Hero)",
    Callback = function()
        if not (Char and Hum and backpack) then return end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                if p.Character and p.Character:FindFirstChild("Gun") then
                    p.Character:FindFirstChild("Gun").Parent = Char
                    Hum:EquipTool(Char:FindFirstChild("Gun"))
                    Hum:UnequipTools()
                    notify("Steal Gun", "Stolen from " .. p.Name, 2)
                elseif p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Gun") then
                    p.Backpack:FindFirstChild("Gun").Parent = backpack
                    Hum:EquipTool(backpack:FindFirstChild("Gun"))
                    Hum:UnequipTools()
                    notify("Steal Gun", "Stolen from " .. p.Name, 2)
                end
            end
        end
    end
})

-- ── Shoot Murder Button (floating GUI) ───────────────────
MainTab:AddToggle({
    Name = "Shoot Murder Button",
    Default = false,
    Callback = function(Value)
        local guip, CoreGui = nil, game:FindService("CoreGui")
        if gethui then
            guip = gethui()
        elseif CoreGui and CoreGui:FindFirstChild("RobloxGui") then
            guip = CoreGui.RobloxGui
        elseif CoreGui then
            guip = CoreGui
        else
            guip = LocalPlayer:FindFirstChild("PlayerGui")
        end

        if Value then
            if not guip:FindFirstChild("GunW") then
                local GunGui = Instance.new("ScreenGui", guip)
                GunGui.Name = "GunW"
                local TextButton = Instance.new("TextButton", GunGui)
                TextButton.Draggable              = true
                TextButton.Position               = UDim2.new(0.5, 187, 0.5, -176)
                TextButton.Size                   = UDim2.new(0, 50, 0, 40)
                TextButton.TextStrokeTransparency = 0
                TextButton.BackgroundTransparency = 0.2
                TextButton.BackgroundColor3       = Color3.fromRGB(44, 44, 45)
                TextButton.BorderColor3           = Color3.new(1, 1, 1)
                TextButton.Text                   = "Shoot\nMurder"
                TextButton.TextColor3             = Color3.new(1, 1, 1)
                TextButton.TextSize               = 8
                TextButton.Visible                = true
                TextButton.AnchorPoint            = Vector2.new(0.4, 0.2)
                TextButton.Active                 = true
                TextButton.TextWrapped            = true
                Instance.new("UICorner", TextButton)
                local UIStroke = Instance.new("UIStroke", TextButton)
                UIStroke.Color       = Color3.new(0, 0, 0)
                UIStroke.Thickness   = 4
                UIStroke.Transparency = 0.4
                local UIGradient = Instance.new("UIGradient", TextButton)
                UIGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.new(0.3, 0.3, 0.3)),
                    ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
                }
                local function rotateGradient()
                    local tween = Tween:Create(UIGradient, TweenInfo.new(2, Enum.EasingStyle.Linear), {Rotation = UIGradient.Rotation + 360})
                    tween:Play()
                    tween.Completed:Connect(rotateGradient)
                end
                rotateGradient()
                TextButton.MouseButton1Click:Connect(function()
                    if Char:FindFirstChild("Gun") then
                        pcall(function()
                            Char.Gun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(1, getMurdererHRP(), "AH2")
                        end)
                    end
                end)
            end
        else
            local existing = guip:FindFirstChild("GunW")
            if existing then existing:Destroy() end
        end
    end
})

-- ── Gun Aimbot ────────────────────────────────────────────
local AimbotMem = MainTab:AddToggle({
    Name = "Gun Aimbot",
    Default = false,
    Callback = function(Value)
        if isUseHook then
            env.enabledGunBot  = Value
            env.GunBotConnection = env.GunBotConnection or {}
            local function setupGunBot(character)
                if not character then return end
                local gun = character:FindFirstChild("Gun")
                if not gun then
                    if env.GunBotConnection.Connection then
                        env.GunBotConnection.Connection:Disconnect()
                        env.GunBotConnection.Connection = nil
                    end
                    return
                end
                local knifeScript = gun:FindFirstChild("KnifeLocal")
                local cb          = knifeScript and knifeScript:FindFirstChild("CreateBeam")
                local remote      = cb and cb:FindFirstChild("RemoteFunction")
                if not knifeScript or not cb or not remote then return end
                if env.enabledGunBot then
                    if env.GunBotConnection.Connection then
                        env.GunBotConnection.Connection:Disconnect()
                        env.GunBotConnection.Connection = nil
                    end
                    env.GunBotConnection.Connection = gun.Activated:Connect(function()
                        local targetPos, isSelf = getMurdererHRP()
                        if not targetPos or isSelf or not remote then return end
                        remote:InvokeServer(1, targetPos, "AH2")
                    end)
                else
                    if env.GunBotConnection.Connection then
                        env.GunBotConnection.Connection:Disconnect()
                        env.GunBotConnection.Connection = nil
                    end
                end
            end
            while env.enabledGunBot do
                if Char and Char:FindFirstChild("Gun") then
                    setupGunBot(Char)
                end
                task.wait(0.25)
            end
            if env.GunBotConnection and env.GunBotConnection.Connection then
                env.GunBotConnection.Connection:Disconnect()
                env.GunBotConnection.Connection = nil
            end
        else
            if not env.AsChange then return end
            if env.AsChange.Value then
                env.AsChange:Set(false)
                notify("Not Supported", "Your executor doesn't support this", 3)
            end
        end
    end
})
env.AsChange = AimbotMem

-- ── Seconds Life (Godmode) ────────────────────────────────
MainTab:AddToggle({
    Name = "Seconds Life (Godmode)",
    Default = false,
    Callback = function(Value)
        local godcon, deathcon
        env.enableGodmode = Value
        local function UpdateGod()
            if godcon then godcon:Disconnect(); godcon = nil end
            if Hum then
                godcon = Hum.HealthChanged:Connect(function()
                    if env.enableGodmode and Hum.Health < Hum.MaxHealth then
                        Hum.Health = Hum.MaxHealth
                    end
                end)
            end
        end
        if deathcon then deathcon:Disconnect() end
        deathcon = LocalPlayer.CharacterAdded:Connect(function(newChar)
            Char = newChar
            Hum  = Char:WaitForChild("Humanoid")
            UpdateGod()
        end)
        UpdateGod()
        task.spawn(function()
            if not env.enableGodmode then
                if godcon then godcon:Disconnect(); godcon = nil end
            else
                if not godcon then UpdateGod() end
            end
        end)
    end
})

-- ── Touch Fling ───────────────────────────────────────────
MainTab:AddToggle({
    Name = "Touch Fling",
    Default = false,
    Callback = function(Value)
        env.isTouchfling = Value
        local vel, movel = nil, 0.1
        while env.isTouchfling do
            RunService.Heartbeat:Wait()
            vel = Root.Velocity
            Root.Velocity = vel * 9e8 + Vector3.new(0, 9e8, 0)
            RunService.RenderStepped:Wait()
            if Char and Char.Parent and Root and Root.Parent then
                Root.Velocity = vel
            end
            RunService.Stepped:Wait()
            if Char and Char.Parent and Root and Root.Parent then
                Root.Velocity = vel + Vector3.new(0, movel, 0)
                movel = movel * -1
            end
        end
    end
})

-- ── Noclip Players (Anti-Fling) ───────────────────────────
MainTab:AddToggle({
    Name = "Noclip Players (AntiFling)",
    Default = false,
    Callback = function(value)
        env.NoclipPlr = value
        if not env.NoclipPlr then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    for _, v in pairs(player.Character:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = true end
                    end
                end
            end
        end
        while env.NoclipPlr do
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    for _, v in pairs(player.Character:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end
            end
            task.wait()
        end
    end
})

-- ── Teleport Buttons ──────────────────────────────────────
MainTab:AddButton({
    Name = "Teleport To Map",
    Callback = function()
        local map = Workspace:FindFirstChild("CoinContainer", true)
        if map and map.Parent then
            local part  = map:FindFirstChildWhichIsA("BasePart", true)
            local parts = map.Parent:FindFirstChildWhichIsA("BasePart", true)
            if Char and part then
                Char:PivotTo(part.CFrame * CFrame.new(0, 2, 0))
            elseif Char and parts then
                Char:PivotTo(parts.CFrame * CFrame.new(0, 2, 0))
            elseif Root and part then
                Root.CFrame = part.CFrame * CFrame.new(0, 2, 0)
            elseif Root and parts then
                Root.CFrame = parts.CFrame * CFrame.new(0, 2, 0)
            end
        end
    end
})

MainTab:AddButton({
    Name = "Teleport To Lobby",
    Callback = function()
        local lobby = Workspace:FindFirstChild("Lobby", true)
        if lobby and lobby.Parent then
            local part  = lobby:FindFirstChildWhichIsA("BasePart", true)
            local parts = lobby.Parent:FindFirstChildWhichIsA("BasePart", true)
            if Char and part then
                Char:PivotTo(part.CFrame * CFrame.new(0, 2, 0))
            elseif Char and parts then
                Char:PivotTo(parts.CFrame * CFrame.new(0, 2, 0))
            elseif Root and part then
                Root.CFrame = part.CFrame * CFrame.new(0, 2, 0)
            elseif Root and parts then
                Root.CFrame = parts.CFrame * CFrame.new(0, 2, 0)
            end
        end
    end
})

-- ── Fling Timeout Slider ──────────────────────────────────
MainTab:AddSlider({
    Name    = "Set Timeout Fling",
    Min     = 0.5,
    Max     = 10,
    Default = 2.5,
    Color   = Color3.fromRGB(255, 255, 255),
    Increment = 0.1,
    ValueName = "Timeout",
    Callback = function(Value)
        env.timeout = Value
    end
})

-- ── Fling Buttons ─────────────────────────────────────────
MainTab:AddButton({
    Name = "Fling Murderer",
    Callback = function()
        local Murderer = nil
        for plr, role in getRoles() do
            if role == "Murderer" then
                Murderer = Players:FindFirstChild(plr)
                break
            end
        end
        if Murderer and Murderer ~= LocalPlayer then
            SHubFling(Murderer)
        else
            notify("Fling", "Murderer not found or you are the murderer.", 2)
        end
    end
})

MainTab:AddButton({
    Name = "Fling Sheriff/Hero",
    Callback = function()
        local Target = nil
        for plr, role in getRoles() do
            if role == "Sheriff" or role == "Hero" then
                Target = Players:FindFirstChild(plr)
                break
            end
        end
        if Target and Target ~= LocalPlayer then
            SHubFling(Target)
        else
            notify("Fling", "Sheriff/Hero not found.", 2)
        end
    end
})

-- ── Player Dropdown & Fling/Teleport/Kill ─────────────────
local TargetPlayer   = nil
local PlayerDropdown = MainTab:AddDropdown({
    Name     = "Select Player",
    Default  = nil,
    Options  = getPlayerNames(),
    Callback = function(Value)
        TargetPlayer = Value
    end
})

local function updateDropdown()
    PlayerDropdown:Refresh(getPlayerNames(), true)
    PlayerDropdown:Set(TargetPlayer)
end
Players.PlayerAdded:Connect(updateDropdown)
Players.PlayerRemoving:Connect(updateDropdown)

MainTab:AddButton({
    Name = "Fling Selected Player",
    Callback = function()
        if TargetPlayer then
            local get = Players:FindFirstChild(TargetPlayer)
            if get and get ~= LocalPlayer then
                SHubFling(get)
            end
        else
            notify("Fling", "No player selected.", 2)
        end
    end
})

MainTab:AddButton({
    Name = "Teleport To Selected Player",
    Callback = function()
        if not TargetPlayer then notify("Teleport", "No player selected.", 2); return end
        local target = Players:FindFirstChild(TargetPlayer)
        if not target or not target.Character then notify("Teleport", "Player not found.", 2); return end
        local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
        if tHRP and Root then
            Root.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3)
            notify("Teleport", "Teleported to " .. TargetPlayer, 2)
        end
    end
})

-- ============================================================
-- ████████████  MURDERER TAB  ████████████
-- ============================================================

-- Role display
MurderTab:AddLabel("⚠️ These features only work when you are the Murderer")

-- ── Kill 1v1 (kill one selected player) ──────────────────
local KillTargetPlayer = nil
local KillDropdown = MurderTab:AddDropdown({
    Name    = "Select Kill Target",
    Default = nil,
    Options = getPlayerNames(),
    Callback = function(Value)
        KillTargetPlayer = Value
    end
})
Players.PlayerAdded:Connect(function()
    KillDropdown:Refresh(getPlayerNames(), true)
end)
Players.PlayerRemoving:Connect(function()
    KillDropdown:Refresh(getPlayerNames(), true)
end)

MurderTab:AddButton({
    Name = "Kill Selected (1v1)",
    Callback = function()
        if not isMurderer() then
            notify("Kill 1v1", "You are not the Murderer!", 3)
            return
        end
        if not KillTargetPlayer then
            notify("Kill 1v1", "No target selected.", 2)
            return
        end
        local target = Players:FindFirstChild(KillTargetPlayer)
        if target and target ~= LocalPlayer then
            killPlayer(target)
            notify("Kill 1v1", "Kill attempt on " .. KillTargetPlayer, 2)
        end
    end
})

-- ── Kill All (kill every player one by one) ──────────────
MurderTab:AddToggle({
    Name    = "Auto Kill All (Murderer)",
    Default = false,
    Callback = function(Value)
        env.AutoKillAll = Value
        if Value and not isMurderer() then
            notify("Kill All", "You are not the Murderer!", 3)
            env.AutoKillAll = false
            return
        end
        task.spawn(function()
            while env.AutoKillAll do
                if not isMurderer() then
                    notify("Kill All", "Role changed, stopping.", 2)
                    env.AutoKillAll = false
                    break
                end
                for _, player in ipairs(Players:GetPlayers()) do
                    if not env.AutoKillAll then break end
                    if player ~= LocalPlayer then
                        local tChar = player.Character
                        local tHum  = tChar and tChar:FindFirstChildWhichIsA("Humanoid")
                        if tChar and tHum and tHum.Health > 0 then
                            killPlayer(player)
                            task.wait(env.KillDelay or 0.5)
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    end
})

MurderTab:AddSlider({
    Name      = "Kill Delay (seconds)",
    Min       = 0.1,
    Max       = 3,
    Default   = 0.5,
    Color     = Color3.fromRGB(255, 60, 60),
    Increment = 0.1,
    ValueName = "Sec",
    Callback  = function(Value)
        env.KillDelay = Value
    end
})

-- ── Knife Teleport Kill (TP + knife) ─────────────────────
MurderTab:AddButton({
    Name = "Knife Teleport Kill (Selected)",
    Callback = function()
        if not isMurderer() then notify("Knife Kill", "You are not the Murderer!", 3); return end
        if not KillTargetPlayer then notify("Knife Kill", "No target selected.", 2); return end
        local target = Players:FindFirstChild(KillTargetPlayer)
        if not target then notify("Knife Kill", "Player not found.", 2); return end
        local tChar = target.Character
        local tHRP  = tChar and tChar:FindFirstChild("HumanoidRootPart")
        if not tHRP or not Root then return end
        -- TP very close
        Root.CFrame = tHRP.CFrame * CFrame.new(0, 0, -1.5)
        task.wait(0.1)
        throwKnifeAt(tHRP.Position)
        notify("Knife Kill", "Knife thrown at " .. target.Name, 2)
    end
})

-- ── Fling All ─────────────────────────────────────────────
MurderTab:AddButton({
    Name = "Fling All Innocents",
    Callback = function()
        if not isMurderer() then notify("Fling All", "You are not the Murderer!", 3); return end
        local roles = getRoles()
        for plr, role in pairs(roles) do
            if role == "Innocent" then
                local player = Players:FindFirstChild(plr)
                if player and player ~= LocalPlayer then
                    task.spawn(function()
                        SHubFling(player)
                    end)
                    task.wait(0.3)
                end
            end
        end
    end
})

-- ── Auto Kill Murderer role (loop knife) ──────────────────
MurderTab:AddToggle({
    Name    = "Auto Kill Loop (Nearest First)",
    Default = false,
    Callback = function(Value)
        env.AutoKillLoop = Value
        task.spawn(function()
            while env.AutoKillLoop do
                if not isMurderer() then task.wait(1); continue end
                -- Find nearest alive player
                local nearest, nearestDist = nil, math.huge
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local tHum = player.Character:FindFirstChildWhichIsA("Humanoid")
                        local tHRP = player.Character:FindFirstChild("HumanoidRootPart")
                        if tHum and tHum.Health > 0 and tHRP and Root then
                            local dist = (tHRP.Position - Root.Position).Magnitude
                            if dist < nearestDist then
                                nearestDist = dist
                                nearest     = player
                            end
                        end
                    end
                end
                if nearest then
                    killPlayer(nearest)
                end
                task.wait(env.KillDelay or 0.5)
            end
        end)
    end
})

-- ============================================================
-- ████████████  LOCAL (PLAYER) TAB  ████████████
-- ============================================================

PlayerTab:AddToggle({
    Name    = "Infinity Jump",
    Default = false,
    Callback = function(Value)
        env.InfiniteJump = Value
        UserInputService.JumpRequest:Connect(function()
            if env.InfiniteJump and Char and Hum then
                Hum:ChangeState("Jumping")
            end
        end)
    end
})

PlayerTab:AddToggle({
    Name    = "Noclip",
    Default = false,
    Callback = function(value)
        env.Noclip = value
        if not env.Noclip and Char then
            for _, c in pairs(Char:GetChildren()) do
                if c:IsA("BasePart") then c.CanCollide = true end
            end
        end
        while env.Noclip do
            if Char then
                for _, c in pairs(Char:GetChildren()) do
                    if c:IsA("BasePart") then c.CanCollide = false end
                end
            end
            task.wait()
        end
    end
})

-- WalkSpeed
PlayerTab:AddSlider({
    Name      = "WalkSpeed",
    Min       = 16,
    Max       = 350,
    Default   = env.Walkspeed or 16,
    Color     = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "WalkSpeed",
    Callback  = function(Value)
        if Char and Hum then Hum.WalkSpeed = Value end
        env.Walkspeed = Value
    end
})
PlayerTab:AddTextbox({
    Name         = "WalkSpeed (Manual)",
    Default      = tostring(env.Walkspeed or 16),
    TextDisappear = false,
    Callback     = function(Value)
        local v = tonumber(Value) or 16
        if Char and Hum then Hum.WalkSpeed = v end
        env.Walkspeed = v
    end
})
PlayerTab:AddToggle({
    Name    = "WalkSpeed Auto Set",
    Default = false,
    Callback = function(Value)
        env.KeepWalkspeed = Value
        while env.KeepWalkspeed do
            if Char and Hum and Hum.WalkSpeed ~= env.Walkspeed then
                Hum.WalkSpeed = env.Walkspeed
            end
            task.wait()
        end
    end
})

-- JumpPower
PlayerTab:AddSlider({
    Name      = "JumpPower",
    Min       = 50,
    Max       = 500,
    Default   = env.Jumppower or 50,
    Color     = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "JumpPower",
    Callback  = function(Value)
        if Char and Hum then Hum.JumpPower = Value end
        env.Jumppower = Value
    end
})
PlayerTab:AddTextbox({
    Name         = "JumpPower (Manual)",
    Default      = tostring(env.Jumppower or 50),
    TextDisappear = false,
    Callback     = function(Value)
        local v = tonumber(Value) or 50
        if Char and Hum then Hum.JumpPower = v end
        env.Jumppower = v
    end
})
PlayerTab:AddToggle({
    Name    = "JumpPower Auto Set",
    Default = false,
    Callback = function(Value)
        env.KeepJumppower = Value
        while env.KeepJumppower do
            if Char and Hum and Hum.JumpPower ~= env.Jumppower then
                Hum.JumpPower = env.Jumppower
            end
            task.wait()
        end
    end
})

-- ── Speed Boost (temporary) ───────────────────────────────
PlayerTab:AddButton({
    Name = "Speed Boost (5 sec)",
    Callback = function()
        if not (Char and Hum) then return end
        local original = Hum.WalkSpeed
        Hum.WalkSpeed  = 100
        notify("Speed Boost", "Running at 100 for 5 seconds!", 5)
        task.delay(5, function()
            if Hum then Hum.WalkSpeed = original end
        end)
    end
})

-- ── Fly ───────────────────────────────────────────────────
PlayerTab:AddToggle({
    Name    = "Fly",
    Default = false,
    Callback = function(Value)
        env.FlyEnabled = Value
        if not Value then
            if env.FlyBP and env.FlyBP.Parent then env.FlyBP:Destroy() end
            if env.FlyBG and env.FlyBG.Parent then env.FlyBG:Destroy() end
            return
        end
        if not (Char and Root and Hum) then return end

        local speed = env.FlySpeed or 60
        local bp = Instance.new("BodyPosition")
        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bp.D        = 1000
        bp.P        = 10000
        bp.Position = Root.Position
        bp.Parent   = Root
        env.FlyBP   = bp

        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.D         = 400
        bg.P         = 10000
        bg.CFrame    = Root.CFrame
        bg.Parent    = Root
        env.FlyBG    = bg

        Hum.PlatformStand = true

        task.spawn(function()
            while env.FlyEnabled and bp.Parent and bg.Parent do
                local cam = Workspace.CurrentCamera
                local cf  = cam.CFrame
                local move = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cf.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cf.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cf.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cf.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
                if move.Magnitude > 0 then
                    bp.Position = bp.Position + move.Unit * speed * 0.05
                end
                bg.CFrame = cf
                RunService.RenderStepped:Wait()
            end
            if Hum then Hum.PlatformStand = false end
        end)
    end
})

PlayerTab:AddSlider({
    Name      = "Fly Speed",
    Min       = 10,
    Max       = 300,
    Default   = 60,
    Color     = Color3.fromRGB(255, 255, 255),
    Increment = 5,
    ValueName = "Speed",
    Callback  = function(Value)
        env.FlySpeed = Value
    end
})

-- ============================================================
-- ████████████  MISC TAB  ████████████
-- ============================================================

-- ── Print My Role ─────────────────────────────────────────
MiscTab:AddButton({
    Name = "Show My Role",
    Callback = function()
        local role = getMyRole() or "Unknown"
        notify("Your Role", "You are: " .. role, 4)
    end
})

-- ── Print All Roles ───────────────────────────────────────
MiscTab:AddButton({
    Name = "Print All Roles (Console)",
    Callback = function()
        local roles = getRoles()
        print("===== MM2 ROLES =====")
        for plr, role in pairs(roles) do
            print(plr .. " → " .. role)
        end
        print("=====================")
        notify("Roles", "Roles printed to console!", 2)
    end
})

-- ── Rejoin ────────────────────────────────────────────────
MiscTab:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

-- ── Collect Coins ─────────────────────────────────────────
MiscTab:AddToggle({
    Name    = "Auto Collect Coins",
    Default = false,
    Callback = function(Value)
        env.AutoCoins = Value
        while env.AutoCoins do
            for _, coin in ipairs(Workspace:GetDescendants()) do
                if coin:IsA("BasePart") and (coin.Name == "Coin" or coin.Name == "Coins") then
                    if Root then
                        if firetouchinterest then
                            firetouchinterest(Root, coin, 0)
                            firetouchinterest(Root, coin, 1)
                        else
                            Root.CFrame = coin.CFrame
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end
})

-- ── Chat Spam ─────────────────────────────────────────────
local ChatMessage = ""
MiscTab:AddTextbox({
    Name         = "Chat Message",
    Default      = "Hello!",
    TextDisappear = false,
    Callback     = function(Value)
        ChatMessage = Value
    end
})

MiscTab:AddButton({
    Name = "Send Chat Message",
    Callback = function()
        if ChatMessage ~= "" then
            local chatEvents = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents", true)
            if chatEvents then
                local sayRequest = chatEvents:FindFirstChild("SayMessageRequest", true)
                if sayRequest then
                    sayRequest:FireServer(ChatMessage, "All")
                end
            end
        end
    end
})

-- ── Anti AFK ─────────────────────────────────────────────
MiscTab:AddToggle({
    Name    = "Anti AFK",
    Default = true,
    Callback = function(Value)
        env.AntiAFK = Value
        if Value then
            local VirtualUser = game:GetService("VirtualUser")
            game:GetService("Players").LocalPlayer.Idled:Connect(function()
                if env.AntiAFK then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end
            end)
            notify("Anti AFK", "Anti AFK enabled!", 2)
        end
    end
})

-- -- Credits --
MiscTab:AddLabel("AuroraHub MM2 Script | Made by aurorahud")

-- ============================================================
-- INIT NOTIFICATION
-- ============================================================
notify(
    "AuroraHub MM2",
    ("Loaded on %s | Role: %s"):format(executor, getMyRole() or "Unknown"),
    5
)