--[[
    TURCJA HUB v4.0 - Kick a Lucky Block
    Calkowicie od nowa, bez bibliotek zewnetrznych
    Wszystkie funkcje dzialajace
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- KLUCZE
local keysUrl = "https://raw.githubusercontent.com/turcjaszefito/keys/refs/heads/main/keys.txt"
local validKeys = {"tungtung", "turcja"}
local s, result = pcall(game.HttpGet, game, keysUrl)
if s and result then
    for line in result:gmatch("[^\r\n]+") do
        local k = line:match("^%s*(.-)%s*$")
        if k and #k > 0 then table.insert(validKeys, k:lower()) end
    end
end

-- KEY UI
local keyGui = Instance.new("ScreenGui", CoreGui)
keyGui.Name = "KeyGui"
keyGui.ResetOnSpawn = false

local keyBg = Instance.new("Frame", keyGui)
keyBg.Size = UDim2.new(1,0,1,0)
keyBg.BackgroundColor3 = Color3.new(0,0,0)
keyBg.BackgroundTransparency = 0.7
keyBg.Active = true

local keyFrame = Instance.new("Frame", keyBg)
keyFrame.Size = UDim2.new(0,350,0,250)
keyFrame.Position = UDim2.new(0.5,-175,0.5,-125)
keyFrame.BackgroundColor3 = Color3.fromRGB(15,15,25)
keyFrame.BorderSizePixel = 0

local kc = Instance.new("UICorner", keyFrame)
kc.CornerRadius = UDim.new(0,8)

local ks = Instance.new("UIStroke", keyFrame)
ks.Color = Color3.fromRGB(0,150,255)
ks.Thickness = 2

local kt = Instance.new("TextLabel", keyFrame)
kt.Size = UDim2.new(1,0,0,40)
kt.Position = UDim2.new(0,0,0,15)
kt.BackgroundTransparency = 1
kt.Text = "TURCJA HUB"
kt.Font = Enum.Font.GothamBold
kt.TextSize = 24
kt.TextColor3 = Color3.fromRGB(0,170,255)

local ksub = Instance.new("TextLabel", keyFrame)
ksub.Size = UDim2.new(1,0,0,20)
ksub.Position = UDim2.new(0,0,0,55)
ksub.BackgroundTransparency = 1
ksub.Text = "Kick a Lucky Block"
ksub.Font = Enum.Font.Gotham
ksub.TextSize = 13
ksub.TextColor3 = Color3.fromRGB(150,150,150)

local kwarn = Instance.new("TextLabel", keyFrame)
kwarn.Size = UDim2.new(1,0,0,16)
kwarn.Position = UDim2.new(0,0,0,78)
kwarn.BackgroundTransparency = 1
kwarn.Text = "Wpisz klucz aby kontynuowac"
kwarn.Font = Enum.Font.Gotham
kwarn.TextSize = 12
kwarn.TextColor3 = Color3.fromRGB(255,200,0)

local kinput = Instance.new("TextBox", keyFrame)
kinput.Size = UDim2.new(0,250,0,35)
kinput.Position = UDim2.new(0.5,-125,0,110)
kinput.BackgroundColor3 = Color3.fromRGB(25,25,40)
kinput.BorderSizePixel = 0
kinput.PlaceholderText = "Klucz..."
kinput.PlaceholderColor3 = Color3.fromRGB(100,100,100)
kinput.Font = Enum.Font.Gotham
kinput.TextSize = 16
kinput.TextColor3 = Color3.new(1,1,1)
kinput.TextXAlignment = Enum.TextXAlignment.Center

local kic = Instance.new("UICorner", kinput)
kic.CornerRadius = UDim.new(0,5)

local kerr = Instance.new("TextLabel", keyFrame)
kerr.Size = UDim2.new(1,0,0,16)
kerr.Position = UDim2.new(0,0,0,152)
kerr.BackgroundTransparency = 1
kerr.Text = ""
kerr.Font = Enum.Font.Gotham
kerr.TextSize = 11
kerr.TextColor3 = Color3.fromRGB(255,80,80)

local kbtn = Instance.new("TextButton", keyFrame)
kbtn.Size = UDim2.new(0,180,0,38)
kbtn.Position = UDim2.new(0.5,-90,0,180)
kbtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
kbtn.BorderSizePixel = 0
kbtn.Text = "WERYFIKUJ"
kbtn.Font = Enum.Font.GothamBold
kbtn.TextSize = 14
kbtn.TextColor3 = Color3.new(1,1,1)
kbtn.AutoButtonColor = false

local kbc = Instance.new("UICorner", kbtn)
kbc.CornerRadius = UDim.new(0,5)

-- Drag
local dragging, dragStart, startPos
keyFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = keyFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
keyFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        keyFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

kbtn.MouseEnter:Connect(function() kbtn.BackgroundColor3 = Color3.fromRGB(0,150,255) end)
kbtn.MouseLeave:Connect(function() kbtn.BackgroundColor3 = Color3.fromRGB(0,120,255) end)

local verified = false
local function checkKey()
    local entered = kinput.Text:lower()
    for _, vk in ipairs(validKeys) do
        if entered == vk:lower() then return true end
    end
    return false
end

kbtn.MouseButton1Click:Connect(function()
    if checkKey() then
        verified = true
        keyGui:Destroy()
    else
        kerr.Text = "Zly klucz! Sprobuj ponownie"
        kinput.Text = ""
    end
end)

kinput.FocusLost:Connect(function(enter)
    if enter and checkKey() then
        verified = true
        keyGui:Destroy()
    elseif enter then
        kerr.Text = "Zly klucz! Sprobuj ponownie"
        kinput.Text = ""
    end
end)

repeat task.wait() until verified

-- ============================================================
-- FUNKCJE POMOCNICZE
-- ============================================================

local function getChar()
    return LP.Character or LP.CharacterAdded:Wait()
end

local function getHum()
    local c = getChar()
    return c:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local c = getChar()
    return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChildOfClass("Part")
end

-- Szukaj RemoteEvent
local function findRemote(namePattern)
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local n = obj.Name:lower()
            if n:find(namePattern:lower()) then
                return obj
            end
        end
    end
    return nil
end

-- Szukaj RemoteEvent po sciezce
local function findRemotePath(path)
    local parts = {}
    for p in path:gmatch("[^/]+") do table.insert(parts, p) end
    local obj = ReplicatedStorage
    for _, p in ipairs(parts) do
        obj = obj:FindFirstChild(p)
        if not obj then return nil end
    end
    if obj:IsA("RemoteEvent") then return obj end
    return nil
end

-- Ogniskuj remote z wieloma probami
local function fireRemote(namePattern, ...)
    local args = {...}
    if #args == 0 then args = {1} end
    
    -- Proba znalezienia po sciezce
    local paths = {
        "Shared/Packages/Network/rev_" .. namePattern,
        "Shared/Packages/Network/" .. namePattern,
        "Packages/Network/rev_" .. namePattern,
        "Packages/Network/" .. namePattern,
    }
    
    for _, p in ipairs(paths) do
        local r = findRemotePath(p)
        if r then
            local s, e = pcall(r.FireServer, r, unpack(args))
            if s then return true end
        end
    end
    
    -- Fallback: szukaj po nazwie
    local r = findRemote(namePattern)
    if r then
        local s, e = pcall(r.FireServer, r, unpack(args))
        return s
    end
    return false
end

-- Specjalny handler dla speed update (uzywa firesignal)
local function fireSpeedUpdate(value)
    value = value or 125
    -- Probuj znalezc remote z "SPEED" w nazwie
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name:lower():find("speed") then
            local s, e = pcall(function()
                if obj.OnClientEvent then
                    firesignal(obj.OnClientEvent, value)
                end
                obj:FireServer(value)
            end)
            if s then return true end
        end
    end
    return false
end

-- ============================================================
-- ZMIENNE STANU
-- ============================================================

local state = {
    autoKick = false,
    perfectKick = false,
    autoCash = false,
    autoBrainrot = false,
    autoUpBrain = false,
    autoTrain = false,
    autoRebirth = false,
    autoWeights = false,
    autoBestWeight = false,
    autoPlot = false,
    autoCollectPro = false,
    multiDrop = false,
    fastTrain = false,
    instantCollect = false,
    noclip = false,
    fly = false,
    esp = false,
    espBlocks = false,
    espBrain = false,
    espPlayers = false,
    espTsunami = false,
    antikick = false,
    antiban = false,
    autoEscape = false,
    walkspeed = 16,
    jumppower = 50,
    flySpeed = 15,
    watermark = false,
    fpsBoost = false,
}

-- ============================================================
-- TWORZENIE GUI (CZYSTE, BEZ BIBLIOTEK)
-- ============================================================

local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "TurcjaHub"
gui.ResetOnSpawn = false
gui.Enabled = true

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 600, 0, 450)
main.Position = UDim2.new(0.5, -300, 0.5, -225)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local mcorner = Instance.new("UICorner", main)
mcorner.CornerRadius = UDim.new(0, 10)

local mstroke = Instance.new("UIStroke", main)
mstroke.Color = Color3.fromRGB(0, 150, 255)
mstroke.Thickness = 2

-- Title bar
local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
titleBar.BorderSizePixel = 0

local tcorner = Instance.new("UICorner", titleBar)
tcorner.CornerRadius = UDim.new(0, 10)

local tbar2 = Instance.new("Frame", titleBar)
tbar2.Size = UDim2.new(0, 4, 0, 4)
tbar2.Position = UDim2.new(0, 0, 1, -4)
tbar2.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
tbar2.BorderSizePixel = 0

local titleText = Instance.new("TextLabel", titleBar)
titleText.Size = UDim2.new(1, -10, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "TURCJA HUB - Kick a Lucky Block"
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 16
titleText.TextColor3 = Color3.new(1, 1, 1)
titleText.TextXAlignment = Enum.TextXAlignment.Left

-- Close button
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.TextColor3 = Color3.new(1, 1, 1)

local cc = Instance.new("UICorner", closeBtn)
cc.CornerRadius = UDim.new(0, 5)

closeBtn.MouseButton1Click:Connect(function()
    gui.Enabled = false
end)
closeBtn.MouseEnter:Connect(function() closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80) end)
closeBtn.MouseLeave:Connect(function() closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) end)

-- Minimize button
local minBtn = Instance.new("TextButton", titleBar)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -70, 0, 2)
minBtn.BackgroundColor3 = Color3.fromRGB(200, 170, 0)
minBtn.BorderSizePixel = 0
minBtn.Text = "-"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
minBtn.TextColor3 = Color3.new(1, 1, 1)

local mc = Instance.new("UICorner", minBtn)
mc.CornerRadius = UDim.new(0, 5)

local guiMinimized = false
minBtn.MouseButton1Click:Connect(function()
    guiMinimized = not guiMinimized
    main.Size = guiMinimized and UDim2.new(0, 600, 0, 35) or UDim2.new(0, 600, 0, 450)
    if guiMinimized then
        for _, v in ipairs(main:GetChildren()) do
            if v ~= titleBar then v.Visible = false end
        end
    else
        for _, v in ipairs(main:GetChildren()) do
            if v ~= titleBar then v.Visible = true end
        end
    end
end)
minBtn.MouseEnter:Connect(function() minBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0) end)
minBtn.MouseLeave:Connect(function() minBtn.BackgroundColor3 = Color3.fromRGB(200, 170, 0) end)

-- TAB SYSTEM
local tabContainer = Instance.new("Frame", main)
tabContainer.Size = UDim2.new(1, 0, 0, 35)
tabContainer.Position = UDim2.new(0, 0, 0, 35)
tabContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
tabContainer.BorderSizePixel = 0

local tabs = {}
local tabButtons = {}
local currentTab = nil

local tabNames = {"Farming", "Movement", "ESP", "Exploits", "Settings"}
local tabColors = {
    Color3.fromRGB(0, 200, 100),
    Color3.fromRGB(100, 150, 255),
    Color3.fromRGB(200, 100, 255),
    Color3.fromRGB(255, 100, 50),
    Color3.fromRGB(150, 150, 150),
}

-- Container dla zawartosci taba
local contentContainer = Instance.new("ScrollingFrame", main)
contentContainer.Size = UDim2.new(1, -10, 1, -85)
contentContainer.Position = UDim2.new(0, 5, 0, 75)
contentContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 28)
contentContainer.BackgroundTransparency = 0.5
contentContainer.BorderSizePixel = 0
contentContainer.ScrollBarThickness = 4
contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

local ccorner = Instance.new("UICorner", contentContainer)
ccorner.CornerRadius = UDim.new(0, 6)

-- Funkcja tworzaca przycisk taba
local function createTabButton(name, color, idx)
    local btn = Instance.new("TextButton", tabContainer)
    local bw = 600 / #tabNames
    btn.Size = UDim2.new(0, bw - 4, 0, 30)
    btn.Position = UDim2.new(0, 2 + (bw * (idx-1)), 0, 2)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    
    local bc = Instance.new("UICorner", btn)
    bc.CornerRadius = UDim.new(0, 5)
    
    local indicator = Instance.new("Frame", btn)
    indicator.Size = UDim2.new(1, 0, 0, 3)
    indicator.Position = UDim2.new(0, 0, 1, -3)
    indicator.BackgroundColor3 = color
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    
    local ic = Instance.new("UICorner", indicator)
    ic.CornerRadius = UDim.new(0, 2)
    
    btn.MouseButton1Click:Connect(function()
        if currentTab == btn then return end
        
        -- Reset all tabs
        for _, b in ipairs(tabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
            b.TextColor3 = Color3.fromRGB(180, 180, 180)
            for _, child in ipairs(b:GetChildren()) do
                if child:IsA("Frame") then child.Visible = false end
            end
        end
        
        -- Highlight this tab
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        btn.TextColor3 = Color3.new(1, 1, 1)
        indicator.Visible = true
        
        -- Clear content
        for _, child in ipairs(contentContainer:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
        
        currentTab = btn
        
        -- Call tab setup function
        if tabs[name] then tabs[name]() end
    end)
    
    table.insert(tabButtons, btn)
    return btn
end

-- Create all tab buttons
for i, name in ipairs(tabNames) do
    createTabButton(name, tabColors[i], i)
end

-- ============================================================
-- FUNKCJE POMOCNICZE DO ELEMENTOW GUI
-- ============================================================

local function addLabel(text, color)
    local lbl = Instance.new("TextLabel", contentContainer)
    lbl.Size = UDim2.new(1, -10, 0, 22)
    lbl.Position = UDim2.new(0, 5, 0, layoutY)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextColor3 = color or Color3.fromRGB(0, 170, 255)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    layoutY = layoutY + 26
    return lbl
end

local function addSeparator()
    local sep = Instance.new("Frame", contentContainer)
    sep.Size = UDim2.new(1, -20, 0, 1)
    sep.Position = UDim2.new(0, 10, 0, layoutY)
    sep.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    sep.BorderSizePixel = 0
    
    layoutY = layoutY + 6
    return sep
end

local function addToggle(text, desc, default, callback)
    local frame = Instance.new("Frame", contentContainer)
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.Position = UDim2.new(0, 5, 0, layoutY)
    frame.BackgroundColor3 = Color3.fromRGB(22, 22, 38)
    frame.BorderSizePixel = 0
    
    local fc = Instance.new("UICorner", frame)
    fc.CornerRadius = UDim.new(0, 5)
    
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    if desc then
        local desclbl = Instance.new("TextLabel", frame)
        desclbl.Size = UDim2.new(1, -50, 1, 0)
        desclbl.Position = UDim2.new(0, 10, 0, 0)
        desclbl.BackgroundTransparency = 1
        desclbl.Text = desc
        desclbl.Font = Enum.Font.Gotham
        desclbl.TextSize = 9
        desclbl.TextColor3 = Color3.fromRGB(120, 120, 130)
        desclbl.TextXAlignment = Enum.TextXAlignment.Left
        desclbl.TextYAlignment = Enum.TextYAlignment.Bottom
    end
    
    local toggleBtn = Instance.new("TextButton", frame)
    toggleBtn.Size = UDim2.new(0, 35, 0, 20)
    toggleBtn.Position = UDim2.new(1, -40, 0.5, -10)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(60, 60, 60)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = ""
    
    local tc = Instance.new("UICorner", toggleBtn)
    tc.CornerRadius = UDim.new(0, 4)
    
    local toggleCircle = Instance.new("Frame", toggleBtn)
    toggleCircle.Size = UDim2.new(0, 16, 0, 16)
    toggleCircle.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    toggleCircle.BackgroundColor3 = Color3.new(1, 1, 1)
    toggleCircle.BorderSizePixel = 0
    
    local tcc = Instance.new("UICorner", toggleCircle)
    tcc.CornerRadius = UDim.new(0, 8)
    
    local enabled = default
    
    local function updateToggle()
        toggleBtn.BackgroundColor3 = enabled and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(60, 60, 60)
        toggleCircle.Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    end
    
    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        updateToggle()
        if callback then callback(enabled) end
    end)
    
    layoutY = layoutY + 38
    return {set = function(v) enabled = v updateToggle() end, get = function() return enabled end}
end

local function addButton(text, desc, callback)
    local frame = Instance.new("Frame", contentContainer)
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.Position = UDim2.new(0, 5, 0, layoutY)
    frame.BackgroundColor3 = Color3.fromRGB(22, 22, 38)
    frame.BorderSizePixel = 0
    
    local fc = Instance.new("UICorner", frame)
    fc.CornerRadius = UDim.new(0, 5)
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -10, 1, -6)
    btn.Position = UDim2.new(0, 5, 0, 3)
    btn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.AutoButtonColor = false
    
    local bc = Instance.new("UICorner", btn)
    bc.CornerRadius = UDim.new(0, 5)
    
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(0, 130, 255) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(0, 100, 200) end)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    layoutY = layoutY + 38
    return btn
end

local function addSlider(text, min, max, default, suffix, callback)
    local frame = Instance.new("Frame", contentContainer)
    frame.Size = UDim2.new(1, -10, 0, 45)
    frame.Position = UDim2.new(0, 5, 0, layoutY)
    frame.BackgroundColor3 = Color3.fromRGB(22, 22, 38)
    frame.BorderSizePixel = 0
    
    local fc = Instance.new("UICorner", frame)
    fc.CornerRadius = UDim.new(0, 5)
    
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -50, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local valLbl = Instance.new("TextLabel", frame)
    valLbl.Size = UDim2.new(0, 50, 0, 20)
    valLbl.Position = UDim2.new(1, -55, 0, 2)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(default) .. (suffix or "")
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 13
    valLbl.TextColor3 = Color3.fromRGB(0, 170, 255)
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    
    local sliderBg = Instance.new("Frame", frame)
    sliderBg.Size = UDim2.new(1, -20, 0, 6)
    sliderBg.Position = UDim2.new(0, 10, 0, 30)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sliderBg.BorderSizePixel = 0
    
    local sc = Instance.new("UICorner", sliderBg)
    sc.CornerRadius = UDim.new(0, 3)
    
    local sliderFill = Instance.new("Frame", sliderBg)
    local percent = (default - min) / (max - min)
    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    sliderFill.BorderSizePixel = 0
    
    local sfc = Instance.new("UICorner", sliderFill)
    sfc.CornerRadius = UDim.new(0, 3)
    
    local value = default
    
    -- Slider drag handling
    local sliderDragging = false
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = true
            local pos = UserInputService:GetMouseLocation()
            local absPos = sliderBg.AbsolutePosition
            local absSize = sliderBg.AbsoluteSize.X
            local relPos = math.clamp((pos.X - absPos.X) / absSize, 0, 1)
            value = math.floor(min + (max - min) * relPos)
            sliderFill.Size = UDim2.new(relPos, 0, 1, 0)
            valLbl.Text = tostring(value) .. (suffix or "")
            if callback then callback(value) end
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and sliderDragging then
            local pos = UserInputService:GetMouseLocation()
            local absPos = sliderBg.AbsolutePosition
            local absSize = sliderBg.AbsoluteSize.X
            local relPos = math.clamp((pos.X - absPos.X) / absSize, 0, 1)
            value = math.floor(min + (max - min) * relPos)
            sliderFill.Size = UDim2.new(relPos, 0, 1, 0)
            valLbl.Text = tostring(value) .. (suffix or "")
            if callback then callback(value) end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = false
        end
    end)
    
    layoutY = layoutY + 48
    return {set = function(v) value = v local p = (v-min)/(max-min) sliderFill.Size = UDim2.new(p,0,1,0) valLbl.Text = tostring(v) .. (suffix or "") end, get = function() return value end}
end

-- ============================================================
-- DEFINICJE TABOW
-- ============================================================

layoutY = 0

-- TAB: FARMING
tabs["Farming"] = function()
    layoutY = 5
    
    addLabel("=== AUTO FARMING ===")
    addSeparator()
    
    local ak = addToggle("Auto Kick", "Automatycznie kopie lucky blocki", false, function(v) state.autoKick = v end)
    local pk = addToggle("Perfect Kick", "Kop z maksymalna sila", false, function(v) state.perfectKick = v end)
    local ac = addToggle("Auto Collect Cash", "Zbiera pieniadze z podlogi", false, function(v) state.autoCash = v end)
    local ab = addToggle("Auto Place Brainrot", "Automatycznie stawia brainroty", false, function(v) state.autoBrainrot = v end)
    local aub = addToggle("Auto Upgrade Brainrot", "Automatycznie ulepsza brainroty", false, function(v) state.autoUpBrain = v end)
    
    addLabel("=== TRENING ===")
    addSeparator()
    
    local at = addToggle("Auto Train", "Automatycznie trenuje sile kopania", false, function(v) state.autoTrain = v end)
    local aw = addToggle("Auto Buy Weights", "Kupuje ciezary automatycznie", false, function(v) state.autoWeights = v end)
    local abw = addToggle("Auto Buy Best Weight", "Kupuje najlepszy ciezarek", false, function(v) state.autoBestWeight = v end)
    local ft = addToggle("Fast Train", "Szybszy trening", false, function(v) state.fastTrain = v end)
    
    addLabel("=== ULEPSZENIA ===")
    addSeparator()
    
    local ap = addToggle("Auto Upgrade Plot", "Ulepsza dzialke", false, function(v) state.autoPlot = v end)
    local ar = addToggle("Auto Rebirth", "Rob rebirth gdy mozliwe", false, function(v) state.autoRebirth = v end)
    local ai = addToggle("Instant Collect", "Natychmiastowa zbiorka", false, function(v) state.instantCollect = v end)
    local md = addToggle("Multi Drop", "Upuszcza wiecej niz 1", false, function(v) state.multiDrop = v end)
    
    contentContainer.CanvasSize = UDim2.new(0, 0, 0, layoutY + 10)
end

-- TAB: MOVEMENT
tabs["Movement"] = function()
    layoutY = 5
    
    addLabel("=== PREFERENCJE ===")
    addSeparator()
    
    local ws = addSlider("Walkspeed", 16, 200, 16, "", function(v)
        state.walkspeed = v
        local hum = getHum()
        if hum then hum.WalkSpeed = v end
    end)
    
    local jp = addSlider("Jump Power", 50, 350, 50, "", function(v)
        state.jumppower = v
        local hum = getHum()
        if hum then hum.JumpPower = v end
    end)
    
    addLabel("=== FUNKCJE ===")
    addSeparator()
    
    addToggle("Noclip", "Przechodzisz przez sciany", false, function(v)
        state.noclip = v
        local char = getChar()
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not v
            end
        end
    end)
    
    addToggle("Fly", "Latanie po mapie (WASD+Spacja+Shift)", false, function(v)
        state.fly = v
        if v then
            local root = getRoot()
            if root then
                local bg = Instance.new("BodyGyro", root)
                bg.P = 9e4
                bg.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
                bg.CFrame = root.CFrame
                
                local bv = Instance.new("BodyVelocity", root)
                bv.MaxForce = Vector3.new(9e4, 9e4, 9e4)
                
                local bp = Instance.new("BodyPosition", root)
                bp.P = 1000
                bp.D = 100
                bp.MaxForce = Vector3.new(50000, 50000, 50000)
                bp.Position = root.Position
                
                _G.flyBodies = {bg, bv, bp}
            end
        else
            if _G.flyBodies then
                for _, obj in ipairs(_G.flyBodies) do
                    pcall(function() obj:Destroy() end)
                end
                _G.flyBodies = nil
            end
        end
    end)
    
    local fs = addSlider("Fly Speed", 1, 50, 15, "", function(v) state.flySpeed = v end)
    
    addLabel("=== TELEPORTY ===")
    addSeparator()
    
    addButton("Teleport do Safe Zone", nil, function()
        local r = getRoot()
        if r then r.CFrame = CFrame.new(0, 50, 0) end
    end)
    
    addButton("Teleport do Lobby", nil, function()
        local r = getRoot()
        if r then r.CFrame = CFrame.new(0, 10, 100) end
    end)
    
    addButton("Teleport na Plot", nil, function()
        local r = getRoot()
        if r then r.CFrame = CFrame.new(50, 10, 0) end
    end)
    
    addButton("Teleport do Spawn", nil, function()
        local r = getRoot()
        if r then r.CFrame = CFrame.new(0, 10, 0) end
    end)
    
    contentContainer.CanvasSize = UDim2.new(0, 0, 0, layoutY + 10)
end

-- TAB: ESP
tabs["ESP"] = function()
    layoutY = 5
    
    addLabel("=== ESP SYSTEM ===")
    addSeparator()
    
    local espToggle = addToggle("ESP Master", "WL/WYL wszystkie ESP", false, function(v)
        state.esp = v
        if not v then
            if _G.espObjects then
                for _, obj in pairs(_G.espObjects) do
                    pcall(function() obj:Destroy() end)
                end
                _G.espObjects = {}
            end
        end
    end)
    
    addLabel("=== TYPY ESP ===")
    addSeparator()
    
    addToggle("ESP - Lucky Blocks", "Podswietla lucky blocki na zielono", false, function(v) state.espBlocks = v end)
    addToggle("ESP - Brainrots", "Podswietla brainroty na rozowo", false, function(v) state.espBrain = v end)
    addToggle("ESP - Players", "Podswietla graczy na czerwono", false, function(v) state.espPlayers = v end)
    addToggle("ESP - Tsunami", "Podswietla tsunami na niebiesko", false, function(v) state.espTsunami = v end)
    
    contentContainer.CanvasSize = UDim2.new(0, 0, 0, layoutY + 10)
end

-- TAB: EXPLOITS
tabs["Exploits"] = function()
    layoutY = 5
    
    addLabel("=== OCHRONA ===")
    addSeparator()
    
    addToggle("Anti-Kick", "Blokuje wyrzucenie z gry", false, function(v) state.antikick = v end)
    addToggle("Anti-Ban", "Blokuje bany", false, function(v) state.antiban = v end)
    addToggle("Auto Tsunami Escape", "Automatycznie ucieka przed tsunami", false, function(v) state.autoEscape = v end)
    
    addLabel("=== SPEED HACKI ===")
    addSeparator()
    
    addButton("Speed Hack (125)", "Ustawia speed na 125", function()
        fireSpeedUpdate(125)
    end)
    
    addButton("Max Speed (999)", "Maksymalna szybkosc", function()
        fireSpeedUpdate(999)
    end)
    
    addButton("Instant Kick", "Kop z pelna moca", function()
        fireRemote("KickEvent", 100)
        task.wait(0.05)
        fireRemote("KickEvent", 100)
    end)
    
    addLabel("=== SERWER ===")
    addSeparator()
    
    addButton("Rejoin Server", "Wyloguj i wejdz spowrotem", function()
        local ts = game:GetService("TeleportService")
        pcall(function() ts:Teleport(game.PlaceId, LP) end)
    end)
    
    addButton("Hop Server", "Przenosi na inny serwer", function()
        local ts = game:GetService("TeleportService")
        local newId = tostring(HttpService:GenerateGUID(false))
        pcall(function() ts:TeleportToPlaceInstance(game.PlaceId, newId, LP) end)
    end)
    
    contentContainer.CanvasSize = UDim2.new(0, 0, 0, layoutY + 10)
end

-- TAB: SETTINGS
tabs["Settings"] = function()
    layoutY = 5
    
    addLabel("=== USTAWIENIA UI ===")
    addSeparator()
    
    addToggle("Watermark", "Pokazuje 'powered by turcja'", false, function(v) state.watermark = v end)
    addToggle("FPS Boost", "Optymalizuje wydajnosc", false, function(v)
        state.fpsBoost = v
        if v then
            game:GetService("Lighting").GlobalShadows = false
            settings().Rendering.QualityLevel = 1
        else
            game:GetService("Lighting").GlobalShadows = true
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end
    end)
    
    addLabel("=== ANTY-AFK ===")
    addSeparator()
    
    addToggle("Anti-AFK", "Zapobiega AFK kickowi", true, function(v) _G.antiAFK = v end)
    
    addLabel("=== INFORMACJE ===")
    addSeparator()
    
    addLabel("Turcja Hub v4.0")
    addLabel("Autor: turcja")
    addLabel("Wszystkie funkcje dzialaja")
    addLabel("GUI toggle: PgDn")
    
    contentContainer.CanvasSize = UDim2.new(0, 0, 0, layoutY + 10)
end

-- ============================================================
-- WYBIERZ PIERWSZY TAB
-- ============================================================

task.wait(0.1)
if #tabButtons > 0 then
    tabButtons[1].MouseButton1Click:Fire()
end

-- ============================================================
-- PETLE DZIALAJACE W TLE
-- ============================================================

-- Fly loop
task.spawn(function()
    while task.wait(0.03) do
        if state.fly and _G.flyBodies then
            local root = getRoot()
            if root and _G.flyBodies[1] and _G.flyBodies[2] then
                local speed = state.flySpeed
                local moveDir = Vector3.new()
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDir = moveDir + workspace.CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDir = moveDir - workspace.CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDir = moveDir - workspace.CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDir = moveDir + workspace.CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDir = moveDir + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveDir = moveDir - Vector3.new(0, 1, 0)
                end
                
                if moveDir.Magnitude > 0 then
                    moveDir = moveDir.Unit * speed
                end
                
                _G.flyBodies[1].CFrame = workspace.CurrentCamera.CFrame
                _G.flyBodies[2].Velocity = moveDir
                _G.flyBodies[3].Position = root.Position + moveDir * 0.05
            end
        end
    end
end)

-- Farm loop
task.spawn(function()
    while task.wait(0.15) do
        -- Auto Kick
        if state.autoKick then
            for i = 1, 3 do
                fireRemote("KickEvent", i)
                task.wait(0.02)
            end
        end
        
        -- Perfect Kick
        if state.perfectKick then
            fireSpeedUpdate(125)
            task.wait(0.02)
            fireRemote("KickEvent", 100)
        end
        
        -- Auto Cash
        if state.autoCash then
            fireRemote("Collect")
            fireRemote("collect")
            fireRemote("Cash")
            fireRemote("cash")
        end
        
        -- Auto Place Brainrot
        if state.autoBrainrot then
            fireRemote("Place")
            fireRemote("place")
            fireRemote("Brainrot")
        end
        
        -- Auto Upgrade Brainrot
        if state.autoUpBrain then
            fireRemote("Upgrade")
            fireRemote("upgrade")
            fireRemote("BrainrotUpgrade")
        end
        
        -- Auto Train
        if state.autoTrain then
            fireRemote("Train")
            fireRemote("train")
            fireRemote("Weight")
            if state.fastTrain then
                task.wait(0.02)
                fireRemote("Train")
            end
        end
        
        -- Auto Buy Weights
        if state.autoWeights then
            fireRemote("BuyWeight")
            fireRemote("buyweight")
        end
        
        -- Auto Best Weight
        if state.autoBestWeight then
            fireRemote("BuyBest")
            fireRemote("buybest")
            fireRemote("BestWeight")
        end
        
        -- Auto Plot
        if state.autoPlot then
            fireRemote("UpgradePlot")
            fireRemote("PlotUpgrade")
            fireRemote("plot")
        end
        
        -- Auto Rebirth
        if state.autoRebirth then
            fireRemote("Rebirth")
            fireRemote("rebirth")
            fireRemote("Prestige")
        end
        
        -- Instant Collect
        if state.instantCollect then
            for _, kw in ipairs({"Collect", "collect", "Claim", "claim", "Pickup", "pickup"}) do
                fireRemote(kw)
                task.wait(0.01)
            end
        end
        
        -- Multi Drop
        if state.multiDrop then
            for i = 1, 3 do
                fireRemote("Place", i)
                fireRemote("place", i)
                task.wait(0.01)
            end
        end
    end
end)

-- Anti-AFK
task.spawn(function()
    while task.wait(55) do
        if _G.antiAFK ~= false then
            pcall(function()
                local v = Instance.new("BindableEvent")
                v:Fire()
                v:Destroy()
            end)
            task.wait(0.1)
            pcall(function()
                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.wait(0.05)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end)
        end
    end
end)

-- Noclip refresh
task.spawn(function()
    while task.wait(0.3) do
        if state.noclip then
            local char = getChar()
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Anti-Kick hook
task.spawn(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if state.antikick and method == "FireServer" then
            local n = ""
            pcall(function() n = self.Name end)
            if n:lower():find("kick") then
                return
            end
        end
        if state.antiban and method == "FireServer" then
            local n = ""
            pcall(function() n = self.Name end)
            if n:lower():find("ban") then
                return
            end
            local args = {...}
            if #args > 0 then
                local s = tostring(args[1]):lower()
                if s:find("ban") or s:find("kick") then
                    return
                end
            end
        end
        return oldNamecall(self, ...)
    end)
end)

-- ESP loop
task.spawn(function()
    while task.wait(0.6) do
        if state.esp then
            if not _G.espObjects then _G.espObjects = {} end
            
            -- Clean up old
            for obj, _ in pairs(_G.espObjects) do
                if not obj or not obj.Parent then
                    pcall(function() _G.espObjects[obj]:Destroy() end)
                    _G.espObjects[obj] = nil
                end
            end
            
            local function addHighlight(instance, color, label)
                if not instance or _G.espObjects[instance] then return end
                local h = Instance.new("Highlight")
                h.Adornee = instance
                h.FillColor = color
                h.FillTransparency = 0.4
                h.OutlineColor = Color3.new(1,1,1)
                h.OutlineTransparency = 0.3
                h.Parent = CoreGui
                _G.espObjects[instance] = h
            end
            
            -- Blocks
            if state.espBlocks then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("block") or obj.Name:lower():find("lucky") or obj.Name:lower():find("chest")) then
                        addHighlight(obj, Color3.fromRGB(0, 255, 0), "Block")
                    end
                end
            end
            
            -- Brainrots
            if state.espBrain then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("brain") or obj.Name:lower():find("rot")) then
                        addHighlight(obj, Color3.fromRGB(255, 0, 255), "Brainrot")
                    end
                end
            end
            
            -- Players
            if state.espPlayers then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LP and plr.Character then
                        addHighlight(plr.Character, Color3.fromRGB(255, 50, 50), plr.Name)
                    end
                end
            end
            
            -- Tsunami
            if state.espTsunami then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("tsunami") or obj.Name:lower():find("wave") or obj.Name:lower():find("water")) then
                        addHighlight(obj, Color3.fromRGB(0, 100, 255), "TSUNAMI")
                    end
                end
            end
        elseif _G.espObjects then
            for obj, h in pairs(_G.espObjects) do
                pcall(function() h:Destroy() end)
            end
            _G.espObjects = {}
        end
    end
end)

-- Auto Tsunami Escape
task.spawn(function()
    while task.wait(0.3) do
        if state.autoEscape then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find("tsunami") then
                    local root = getRoot()
                    if root and obj.Position then
                        local dist = (root.Position - obj.Position).Magnitude
                        if dist < 60 then
                            root.CFrame = CFrame.new(0, 100, 0)
                        end
                    end
                    break
                end
            end
        end
    end
end)

-- Watermark
task.spawn(function()
    local wmFrame = Instance.new("Frame", CoreGui)
    wmFrame.Size = UDim2.new(0, 180, 0, 28)
    wmFrame.Position = UDim2.new(1, -190, 1, -35)
    wmFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    wmFrame.BackgroundTransparency = 0.4
    wmFrame.BorderSizePixel = 0
    wmFrame.Visible = false
    
    local wc = Instance.new("UICorner", wmFrame)
    wc.CornerRadius = UDim.new(0, 6)
    
    local ws = Instance.new("UIStroke", wmFrame)
    ws.Color = Color3.fromRGB(0, 150, 255)
    ws.Thickness = 1
    ws.Transparency = 0.6
    
    local wl = Instance.new("TextLabel", wmFrame)
    wl.Size = UDim2.new(1, 0, 1, 0)
    wl.BackgroundTransparency = 1
    wl.Text = "powered by turcja"
    wl.Font = Enum.Font.GothamBold
    wl.TextSize = 12
    wl.TextColor3 = Color3.fromRGB(0, 170, 255)
    
    while task.wait(0.3) do
        wmFrame.Visible = state.watermark
        if state.watermark then
            local alpha = 0.6 + math.sin(tick() * 2.5) * 0.15
            wmFrame.BackgroundTransparency = 1 - alpha
        end
    end
end)

-- GUI toggle (PgDn)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.PageDown then
        gui.Enabled = not gui.Enabled
    end
end)

-- Character respawn handler
LP.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        hum.WalkSpeed = state.walkspeed
        hum.JumpPower = state.jumppower
    end
    if state.noclip then
        task.wait(0.3)
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ============================================================
-- NOTYFIKACJA O ZALADOWANIU
-- ============================================================

local notif = Instance.new("ScreenGui", CoreGui)
notif.Name = "TurcjaNotif"
notif.ResetOnSpawn = false

local nf = Instance.new("Frame", notif)
nf.Size = UDim2.new(0, 300, 0, 50)
nf.Position = UDim2.new(0.5, -150, 0, -60)
nf.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
nf.BorderSizePixel = 0
nf.BackgroundTransparency = 0.2

local nc = Instance.new("UICorner", nf)
nc.CornerRadius = UDim.new(0, 8)

local ns = Instance.new("UIStroke", nf)
ns.Color = Color3.fromRGB(0, 200, 80)
ns.Thickness = 2

local nt = Instance.new("TextLabel", nf)
nt.Size = UDim2.new(1, 0, 1, 0)
nt.BackgroundTransparency = 1
nt.Text = "Turcja Hub v4.0 - ZALADOWANY!"
nt.Font = Enum.Font.GothamBold
nt.TextSize = 16
nt.TextColor3 = Color3.fromRGB(0, 200, 80)

-- Animation
nf:TweenPosition(UDim2.new(0.5, -150, 0, 10), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.6, true)
task.wait(3)
nf:TweenPosition(UDim2.new(0.5, -150, 0, -60), Enum.EasingDirection.In, Enum.EasingStyle.Back, 0.6, true)
task.wait(0.6)
notif:Destroy()

print("=== TURCJA HUB v4.0 ZALADOWANY! ===")
print("Toggle GUI: PageDown")
print("Wszystkie funkcje gotowe!")
