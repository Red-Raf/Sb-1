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

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DustWayUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = CoreGui

-- Кнопка-логотип (шестиугольник)
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 70, 0, 70)
openBtn.Position = UDim2.new(0, 20, 0.5, -35)
openBtn.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
openBtn.Text = "N"
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.TextScaled = true
openBtn.Font = Enum.Font.GothamBlack
openBtn.BorderSizePixel = 0
openBtn.Parent = screenGui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 12)

local btnStroke = Instance.new("UIStroke", openBtn)
btnStroke.Color = Color3.fromRGB(60, 60, 80)
btnStroke.Thickness = 1.5

-- Основное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 700, 0, 460)
mainFrame.Position = UDim2.new(0.5, -350, 0.5, -230)
mainFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)

local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(40, 40, 55)
mainStroke.Thickness = 1.5

-- Левая панель (sidebar)
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 180, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 14)

local sideGrad = Instance.new("UIGradient")
sideGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 8, 12)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(3, 3, 6))
})
sideGrad.Rotation = 90
sideGrad.Parent = sidebar

-- Логотип в sidebar
local logoFrame = Instance.new("Frame")
logoFrame.Size = UDim2.new(0, 55, 0, 55)
logoFrame.Position = UDim2.new(0, 15, 0, 15)
logoFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
logoFrame.BorderSizePixel = 0
logoFrame.Parent = sidebar
Instance.new("UICorner", logoFrame).CornerRadius = UDim.new(0, 10)

local logoStroke = Instance.new("UIStroke", logoFrame)
logoStroke.Color = Color3.fromRGB(80, 80, 110)
logoStroke.Thickness = 1.5

local logoLabel = Instance.new("TextLabel")
logoLabel.Size = UDim2.new(1, 0, 1, 0)
logoLabel.BackgroundTransparency = 1
logoLabel.Text = "N"
logoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
logoLabel.TextScaled = true
logoLabel.Font = Enum.Font.GothamBlack
logoLabel.Parent = logoFrame

-- Разделитель
local divider = Instance.new("Frame")
divider.Size = UDim2.new(0.85, 0, 0, 1)
divider.Position = UDim2.new(0.075, 0, 0, 85)
divider.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
divider.BorderSizePixel = 0
divider.Parent = sidebar

-- Контейнер для кнопок вкладок
local navContainer = Instance.new("Frame")
navContainer.Size = UDim2.new(1, -20, 1, -180)
navContainer.Position = UDim2.new(0, 10, 0, 100)
navContainer.BackgroundTransparency = 1
navContainer.Parent = sidebar

local navLayout = Instance.new("UIListLayout", navContainer)
navLayout.Padding = UDim.new(0, 6)
navLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Нижняя часть sidebar (онлайн)
local bottomFrame = Instance.new("Frame")
bottomFrame.Size = UDim2.new(1, -20, 0, 45)
bottomFrame.Position = UDim2.new(0, 10, 1, -55)
bottomFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
bottomFrame.BorderSizePixel = 0
bottomFrame.Parent = sidebar
Instance.new("UICorner", bottomFrame).CornerRadius = UDim.new(0, 8)

local onlineDot = Instance.new("Frame")
onlineDot.Size = UDim2.new(0, 8, 0, 8)
onlineDot.Position = UDim2.new(0, 12, 0.5, -4)
onlineDot.BackgroundColor3 = Color3.fromRGB(0, 220, 100)
onlineDot.BorderSizePixel = 0
onlineDot.Parent = bottomFrame
Instance.new("UICorner", onlineDot).CornerRadius = UDim.new(1, 0)

local onlineLabel = Instance.new("TextLabel")
onlineLabel.Size = UDim2.new(1, -30, 1, 0)
onlineLabel.Position = UDim2.new(0, 26, 0, 0)
onlineLabel.BackgroundTransparency = 1
onlineLabel.Text = "Онлайн"
onlineLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
onlineLabel.TextScaled = true
onlineLabel.Font = Enum.Font.Gotham
onlineLabel.TextXAlignment = Enum.TextXAlignment.Left
onlineLabel.Parent = bottomFrame

-- Правая часть (контент)
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -180, 1, 0)
contentArea.Position = UDim2.new(0, 180, 0, 0)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainFrame

-- Заголовок страницы
local pageTitle = Instance.new("TextLabel")
pageTitle.Size = UDim2.new(1, -60, 0, 45)
pageTitle.Position = UDim2.new(0, 30, 0, 20)
pageTitle.BackgroundTransparency = 1
pageTitle.Text = "Главная"
pageTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
pageTitle.TextScaled = true
pageTitle.Font = Enum.Font.GothamBold
pageTitle.TextXAlignment = Enum.TextXAlignment.Left
pageTitle.Parent = contentArea

local pageSubtitle = Instance.new("TextLabel")
pageSubtitle.Size = UDim2.new(1, -60, 0, 20)
pageSubtitle.Position = UDim2.new(0, 30, 0, 60)
pageSubtitle.BackgroundTransparency = 1
pageSubtitle.Text = "Здесь вы можете управлять настройками."
pageSubtitle.TextColor3 = Color3.fromRGB(120, 120, 140)
pageSubtitle.TextScaled = true
pageSubtitle.Font = Enum.Font.Gotham
pageSubtitle.TextXAlignment = Enum.TextXAlignment.Left
pageSubtitle.Parent = contentArea

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -50, 0, 20)
closeBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = contentArea
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

openBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Перетаскивание окна
local dragging, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
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

-- Контейнер контента
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -60, 1, -110)
contentFrame.Position = UDim2.new(0, 30, 0, 90)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = contentArea

local contentScroll = Instance.new("ScrollingFrame")
contentScroll.Size = UDim2.new(1, 0, 1, 0)
contentScroll.BackgroundTransparency = 1
contentScroll.BorderSizePixel = 0
contentScroll.ScrollBarThickness = 3
contentScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
contentScroll.Parent = contentFrame

local contentLayout = Instance.new("UIListLayout", contentScroll)
contentLayout.Padding = UDim.new(0, 10)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Создание кнопки вкладки
local function createNavButton(name, icon, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.LayoutOrder = order
    btn.Parent = navContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 30, 1, 0)
    iconLabel.Position = UDim2.new(0, 10, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
    iconLabel.TextScaled = true
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Parent = btn

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -45, 1, 0)
    label.Position = UDim2.new(0, 40, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(150, 150, 170)
    label.TextScaled = true
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btn

    btn.MouseButton1Click:Connect(function()
        for _, child in pairs(navContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundTransparency = 1
                for _, c in pairs(child:GetChildren()) do
                    if c:IsA("TextLabel") then
                        c.TextColor3 = Color3.fromRGB(150, 150, 170)
                    end
                end
            end
        end
        btn.BackgroundTransparency = 0
        btn.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
        iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        callback(name)
    end)

    return btn
end

-- Создание карточки (плитки)
local function createCard(parent, title, desc, icon, order, callback)
    local card = Instance.new("TextButton")
    card.Size = UDim2.new(0.48, 0, 0, 110)
    card.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    card.Text = ""
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.Color = Color3.fromRGB(30, 30, 45)
    cardStroke.Thickness = 1.2

    local iconFrame = Instance.new("Frame")
    iconFrame.Size = UDim2.new(0, 36, 0, 36)
    iconFrame.Position = UDim2.new(0, 15, 0, 15)
    iconFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
    iconFrame.BorderSizePixel = 0
    iconFrame.Parent = card
    Instance.new("UICorner", iconFrame).CornerRadius = UDim.new(0, 8)

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(1, 0, 1, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    iconLabel.TextScaled = true
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Parent = iconFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -30, 0, 20)
    titleLabel.Position = UDim2.new(0, 15, 0, 58)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = card

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -30, 0, 30)
    descLabel.Position = UDim2.new(0, 15, 0, 78)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = desc
    descLabel.TextColor3 = Color3.fromRGB(120, 120, 140)
    descLabel.TextScaled = true
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextWrapped = true
    descLabel.Parent = card

    card.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return card
end

-- Создание переключателя
local function createToggle(parent, name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 42)
    frame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(30, 30, 45)
    stroke.Thickness = 1

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 230)
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 24)
    btn.Position = UDim2.new(1, -65, 0.5, -12)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(35, 35, 50)
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 18, 0, 18)
    dot.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = btn
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(35, 35, 50)
        dot.Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        if callback then callback(state) end
    end)
end

-- Создание слайдера
local function createSlider(parent, name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 58)
    frame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(30, 30, 45)
    stroke.Thickness = 1

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30, 0, 20)
    label.Position = UDim2.new(0, 15, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.fromRGB(220, 220, 230)
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(0.9, 0, 0, 6)
    sliderBg.Position = UDim2.new(0.05, 0, 0, 36)
    sliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
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
    dragBtn.Size = UDim2.new(0, 16, 0, 16)
    dragBtn.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    dragBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dragBtn.Text = ""
    dragBtn.BorderSizePixel = 0
    dragBtn.Parent = sliderBg
    Instance.new("UICorner", dragBtn).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function update(input)
        local relX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local val = math.round(min + relX * (max - min))
        fill.Size = UDim2.new(relX, 0, 1, 0)
        dragBtn.Position = UDim2.new(relX, -8, 0.5, -8)
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
            update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Функции игры
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

-- Заполнение контента по вкладкам
local function fillMain()
    pageTitle.Text = "Главная"
    pageSubtitle.Text = "Здесь вы можете управлять своим аккаунтом и настроить всё под себя."

    createCard(contentScroll, "Профиль", "Просмотр и настройка профиля", "👤", 1, function()
        pageTitle.Text = "Профиль"
        pageSubtitle.Text = "Имя: " .. LocalPlayer.Name .. " | ID: " .. LocalPlayer.UserId
    end)
    createCard(contentScroll, "Настройки", "Изменение параметров приложения", "⚙️", 2, function()
        pageTitle.Text = "Настройки"
        pageSubtitle.Text = "Выберите параметр для настройки"
    end)
    createCard(contentScroll, "Инвентарь", "Ваши предметы и ресурсы", "📦", 3, function()
        pageTitle.Text = "Инвентарь"
        pageSubtitle.Text = "Просмотр инвентаря"
    end)
    createCard(contentScroll, "Статистика", "Ваши достижения", "📊", 4, function()
        pageTitle.Text = "Статистика"
        pageSubtitle.Text = "Статистика игрока"
    end)
end

local function fillVisual()
    pageTitle.Text = "Визуал"
    pageSubtitle.Text = "Настройки ESP и подсветки игроков."

    createToggle(contentScroll, "ESP Вкл", false, function(v)
        _G.DustWay.ESPEnabled = v
        if v then for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
        else ClearESP() end
    end)
    createToggle(contentScroll, "Показывать убийцу", true, function(v) _G.DustWay.ShowMurderer = v end)
    createToggle(contentScroll, "Показывать шерифа", true, function(v) _G.DustWay.ShowSheriff = v end)
    createToggle(contentScroll, "Показывать героя", true, function(v) _G.DustWay.ShowHero = v end)
    createToggle(contentScroll, "Показывать невинных", true, function(v) _G.DustWay.ShowInnocent = v end)
    createToggle(contentScroll, "Показывать себя", true, function(v) _G.DustWay.ShowSelf = v end)
    createToggle(contentScroll, "ESP оружия", true, function(v) _G.DustWay.GunESP = v; if not v then ClearGunESP() end end)
end

local function fillCombat()
    pageTitle.Text = "Бой"
    pageSubtitle.Text = "Авто-шот, флинг и бросок ножа."

    createToggle(contentScroll, "Авто-шот убийцы", false, function(v) _G.DustWay.AutoShoot = v end)
    createToggle(contentScroll, "Ping Prediction", false, function(v) _G.DustWay.PingPrediction = v end)
    createCard(contentScroll, "Выстрелить", "Выстрелить в убийцу", "🔫", 1, function()
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
    createCard(contentScroll, "Бросить нож", "Бросок ножа в убийцу", "🔪", 2, function()
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
    createCard(contentScroll, "Флинг убийцы", "Выбросить убийцу за карту", "💥", 3, function()
        local murderer = GetMurderer()
        if murderer then FlingPlayer(murderer) end
    end)
    createCard(contentScroll, "Флинг шерифа", "Выбросить шерифа за карту", "💥", 4, function()
        local sheriff = GetSheriff()
        if sheriff then FlingPlayer(sheriff) end
    end)
end

local function fillMovement()
    pageTitle.Text = "Движение"
    pageSubtitle.Text = "Скорость, полёт и anti-fling."

    createSlider(contentScroll, "WalkSpeed", 16, 100, 16, function(v)
        _G.DustWay.WalkSpeed = v
        if LocalPlayer.Character then local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed = v end end
    end)
    createToggle(contentScroll, "Speed Glitch", false, function(v) _G.DustWay.SpeedGlitch = v; if v then StartSpeedGlitch() else StopSpeedGlitch() end end)
    createSlider(contentScroll, "Speed Glitch Speed", 50, 600, 200, function(v) _G.DustWay.SpeedGlitchSpeed = v end)
    createToggle(contentScroll, "Полёт (WASD + Space)", false, function(v) _G.DustWay.FlyEnabled = v; if v then StartFly() else StopFly() end end)
    createSlider(contentScroll, "Скорость полёта", 10, 200, 50, function(v) _G.DustWay.FlySpeed = v end)
    createToggle(contentScroll, "Anti-Fling", false, function(v) _G.DustWay.AntiFling = v; if v then StartAntiFling() else StopAntiFling() end end)
    createSlider(contentScroll, "Velocity Cap", 50, 500, 200, function(v) _G.DustWay.VelocityCap = v end)
end

local function fillMisc()
    pageTitle.Text = "Разное"
    pageSubtitle.Text = "Графика, скины и дополнительные утилиты."

    createCard(contentScroll, "Восстановить небо", "Сбросить skybox к стандартному", "🌌", 1, function()
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
    createToggle(contentScroll, "Низкая графика", false, function(v)
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
    createToggle(contentScroll, "Высокая графика", false, function(v)
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
    createCard(contentScroll, "Infinite Yield", "Загрузить админ-скрипт", "⚡", 1, function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end)
    createCard(contentScroll, "Emotes GUI", "Загрузить GUI эмоций", "😀", 2, function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua'))()
    end)
end

-- Обработка клика по вкладке
local navButtons = {}
local function switchTab(name)
    for _, child in pairs(contentScroll:GetChildren()) do
        if not child:IsA("UIListLayout") then child:Destroy() end
    end

    if name == "Главная" then fillMain()
    elseif name == "Визуал" then fillVisual()
    elseif name == "Бой" then fillCombat()
    elseif name == "Движение" then fillMovement()
    elseif name == "Разное" then fillMisc()
    end
end

createNavButton("Главная", "🏠", 1, switchTab)
createNavButton("Визуал", "👁", 2, switchTab)
createNavButton("Бой", "⚔", 3, switchTab)
createNavButton("Движение", "✈", 4, switchTab)
createNavButton("Разное", "⚙", 5, switchTab)

-- Автовыбор первой вкладки
task.wait(0.1)
for _, child in pairs(navContainer:GetChildren()) do
    if child:IsA("TextButton") then
        for _, c in pairs(child:GetChildren()) do
            if c:IsA("TextLabel") and c.Text == "Главная" then
                child.BackgroundTransparency = 0
                child.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
                c.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        end
    end
end
switchTab("Главная")

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

print("[DustWay] загружен. Нажми на кнопку N слева для открытия меню.")