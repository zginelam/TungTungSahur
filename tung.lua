--[[
    Kick a Lucky Block GUI
    Framework: Rayfield (wbudowany)
    Autor: turcja
    Wersja: 2.0.0
]]

--==[ NAJWAŻNIEJSZE: OBSŁUGA BŁĘDÓW ]==--
local success, err = pcall(function()

--==[ SERVICE ]==--
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera

--==[ ZABEZPIECZENIE PRZED WIELOKROTNYM URUCHOMIENIEM ]==--
if _G.KALB_Loaded then return end
_G.KALB_Loaded = true

--==[ ZMIENNE GLOBALNE SKRYPTU ]==--
local Settings = {
    Watermark = false,
    WatermarkText = "powered by turcja",
    WatermarkColor = Color3.fromRGB(255, 170, 0),
    WatermarkTransparency = 0.7,
    DiscordInvite = "discord.gg/turcja", -- ZASTĄP REALNYM LINKIEM
    ScriptName = "Kick a Lucky Block GUI",
    ScriptVersion = "2.0.0",
    ScriptAuthor = "turcja",
    LoadedTime = os.date("%Y-%m-%d %H:%M:%S"),
    UserName = Player.Name,
    UserId = Player.UserId,
    UserDisplayName = Player.DisplayName
}

--==[ SYSTEM KLUCZY ]==--
local KeySystem = {}
KeySystem.__index = KeySystem

function KeySystem:LoadKeys()
    local keys = {}
    local success, result = pcall(function()
        return HttpService:GetAsync("https://raw.githubusercontent.com/turcjaszefito/keys/refs/heads/main/keys.txt")
    end)
    
    if success then
        for line in result:gmatch("[^\r\n]+") do
            local key, type = line:match("^(%S+)%s*%-%s*(.+)$")
            if key and type then
                keys[key:lower()] = type:lower()
            end
        end
    end
    
    -- Domyślne klucze na wypadek gdyby GitHub nie działał
    keys["turcja"] = "lifetime"
    keys["tungtung"] = "lifetime"
    
    return keys
end

function KeySystem:ValidateKey(inputKey)
    local validKeys = self:LoadKeys()
    local key = inputKey:lower()
    
    if validKeys[key] then
        return { valid = true, type = validKeys[key] }
    end
    
    return { valid = false, type = nil }
end

--==[ TWORZENIE WATERMARKU ]==--
local Watermark = {}
Watermark.__index = Watermark

function Watermark:Create()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KALB_Watermark"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame")
    frame.Name = "WatermarkFrame"
    frame.Size = UDim2.new(0, 250, 0, 30)
    frame.Position = UDim2.new(1, -260, 1, -40)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.6
    frame.BorderSizePixel = 0
    frame.Visible = false
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 6)
    uiCorner.Parent = frame
    
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Settings.WatermarkColor
    uiStroke.Thickness = 1
    uiStroke.Transparency = 0.5
    uiStroke.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "WatermarkText"
    textLabel.Size = UDim2.new(1, -10, 1, 0)
    textLabel.Position = UDim2.new(0, 5, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Settings.WatermarkColor
    textLabel.TextTransparency = Settings.WatermarkTransparency
    textLabel.Text = Settings.WatermarkText
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 14
    textLabel.TextXAlignment = Enum.TextXAlignment.Right
    textLabel.TextYAlignment = Enum.TextYAlignment.Center
    textLabel.Parent = frame
    
    frame.Parent = screenGui
    
    -- Efekt fade in/out
    local function fadeIn()
        frame.BackgroundTransparency = 1
        textLabel.TextTransparency = 1
        frame.Visible = true
        
        local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(frame, tweenInfo, {BackgroundTransparency = 0.6})
        local tween2 = TweenService:Create(textLabel, tweenInfo, {TextTransparency = Settings.WatermarkTransparency})
        tween:Play()
        tween2:Play()
    end
    
    local function fadeOut()
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local tween = TweenService:Create(frame, tweenInfo, {BackgroundTransparency = 1})
        local tween2 = TweenService:Create(textLabel, tweenInfo, {TextTransparency = 1})
        tween:Play()
        tween2:Play()
        tween.Completed:Connect(function()
            frame.Visible = false
        end)
    end
    
    return {
        gui = screenGui,
        frame = frame,
        text = textLabel,
        show = function()
            fadeIn()
        end,
        hide = function()
            fadeOut()
        end,
        setText = function(newText)
            textLabel.Text = newText
        end,
        setColor = function(color)
            uiStroke.Color = color
            textLabel.TextColor3 = color
        end,
        setVisible = function(visible)
            if visible then
                fadeIn()
            else
                fadeOut()
            end
        end
    }
end

--==[ SYSTEM LOGOWANIA (KEY SYSTEM UI) ]==--
local function CreateLoginUI(callback)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KALB_Login"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Overlay (przyciemnienie)
    local overlay = Instance.new("Frame")
    overlay.Name = "Overlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.BorderSizePixel = 0
    overlay.Parent = screenGui
    
    -- Główny container
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 400, 0, 350)
    container.Position = UDim2.new(0.5, -200, 0.5, -175)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    container.BackgroundTransparency = 0.1
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    container.Parent = screenGui
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 12)
    containerCorner.Parent = container
    
    local containerStroke = Instance.new("UIStroke")
    containerStroke.Color = Color3.fromRGB(255, 170, 0)
    containerStroke.Thickness = 1.5
    containerStroke.Transparency = 0.3
    containerStroke.Parent = container
    
    -- Gradient tła
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
    })
    gradient.Rotation = 45
    gradient.Parent = container
    
    -- Logo / Tytuł
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -40, 0, 40)
    titleLabel.Position = UDim2.new(0, 20, 0, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Text = Settings.ScriptName
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 22
    titleLabel.Parent = container
    
    -- Podtytuł
    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Name = "Subtitle"
    subtitleLabel.Size = UDim2.new(1, -40, 0, 20)
    subtitleLabel.Position = UDim2.new(0, 20, 0, 60)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    subtitleLabel.Text = "Wprowadź klucz dostępu, aby kontynuować"
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.TextSize = 13
    subtitleLabel.Parent = container
    
    -- Pole tekstowe (klucz)
    local textBoxFrame = Instance.new("Frame")
    textBoxFrame.Name = "TextBoxFrame"
    textBoxFrame.Size = UDim2.new(1, -40, 0, 45)
    textBoxFrame.Position = UDim2.new(0, 20, 0, 95)
    textBoxFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    textBoxFrame.BackgroundTransparency = 0.2
    textBoxFrame.BorderSizePixel = 0
    textBoxFrame.Parent = container
    
    local textBoxCorner = Instance.new("UICorner")
    textBoxCorner.CornerRadius = UDim.new(0, 8)
    textBoxCorner.Parent = textBoxFrame
    
    local textBoxStroke = Instance.new("UIStroke")
    textBoxStroke.Color = Color3.fromRGB(60, 60, 80)
    textBoxStroke.Thickness = 1
    textBoxStroke.Parent = textBoxFrame
    
    local textBox = Instance.new("TextBox")
    textBox.Name = "KeyInput"
    textBox.Size = UDim2.new(1, -20, 1, 0)
    textBox.Position = UDim2.new(0, 10, 0, 0)
    textBox.BackgroundTransparency = 1
    textBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
    textBox.PlaceholderText = "Wpisz klucz..."
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.Text = ""
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 16
    textBox.ClearTextOnFocus = false
    textBox.Parent = textBoxFrame
    
    -- Przycisk logowania
    local loginButton = Instance.new("TextButton")
    loginButton.Name = "LoginButton"
    loginButton.Size = UDim2.new(1, -40, 0, 45)
    loginButton.Position = UDim2.new(0, 20, 0, 155)
    loginButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    loginButton.BackgroundTransparency = 0.1
    loginButton.BorderSizePixel = 0
    loginButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    loginButton.Text = "ZATWIERDŹ KOD"
    loginButton.Font = Enum.Font.GothamBold
    loginButton.TextSize = 16
    loginButton.Parent = container
    
    local loginCorner = Instance.new("UICorner")
    loginCorner.CornerRadius = UDim.new(0, 8)
    loginCorner.Parent = loginButton
    
    -- Efekt glow na przycisku
    local loginGlow = Instance.new("Frame")
    loginGlow.Name = "Glow"
    loginGlow.Size = UDim2.new(1, 0, 1, 0)
    loginGlow.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    loginGlow.BackgroundTransparency = 0.8
    loginGlow.BorderSizePixel = 0
    loginGlow.Parent = loginButton
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(0, 8)
    glowCorner.Parent = loginGlow
    
    -- Status / błąd
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(1, -40, 0, 20)
    statusLabel.Position = UDim2.new(0, 20, 0, 210)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    statusLabel.Text = ""
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 13
    statusLabel.Parent = container
    
    -- Discord link
    local discordButton = Instance.new("TextButton")
    discordButton.Name = "DiscordButton"
    discordButton.Size = UDim2.new(0, 200, 0, 35)
    discordButton.Position = UDim2.new(0.5, -100, 0, 245)
    discordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    discordButton.BackgroundTransparency = 0.15
    discordButton.BorderSizePixel = 0
    discordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    discordButton.Text = "🔗 DISCORD - ZDOBĄDŹ KLUCZ"
    discordButton.Font = Enum.Font.GothamBold
    discordButton.TextSize = 11
    discordButton.Parent = container
    
    local discordCorner = Instance.new("UICorner")
    discordCorner.CornerRadius = UDim.new(0, 6)
    discordCorner.Parent = discordButton
    
    -- Informacja o wersji
    local versionLabel = Instance.new("TextLabel")
    versionLabel.Name = "Version"
    versionLabel.Size = UDim2.new(1, -20, 0, 16)
    versionLabel.Position = UDim2.new(0, 10, 1, -20)
    versionLabel.BackgroundTransparency = 1
    versionLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
    versionLabel.Text = "v" .. Settings.ScriptVersion .. " | by " .. Settings.ScriptAuthor
    versionLabel.Font = Enum.Font.Gotham
    versionLabel.TextSize = 10
    versionLabel.TextXAlignment = Enum.TextXAlignment.Center
    versionLabel.Parent = container
    
    -- Animacja pojawiania się
    container.Size = UDim2.new(0, 0, 0, 0)
    container.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local openTween = TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 400, 0, 350),
        Position = UDim2.new(0.5, -200, 0.5, -175)
    })
    openTween:Play()
    
    -- Funkcje przycisków
    local function validateAndLogin()
        local key = textBox.Text:gsub("^%s+", ""):gsub("%s+$", "") -- trim
        
        if key == "" then
            statusLabel.Text = "❌ Wprowadź klucz!"
            return
        end
        
        statusLabel.Text = "⏳ Sprawdzanie klucza..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
        
        local result = KeySystem:ValidateKey(key)
        
        if result.valid then
            statusLabel.Text = "✅ Klucz poprawny! (" .. result.type .. ")"
            statusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
            
            -- Animacja zamknięcia
            local closeTween = TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            })
            closeTween:Play()
            
            local fadeTween = TweenService:Create(overlay, TweenInfo.new(0.3), {
                BackgroundTransparency = 1
            })
            fadeTween:Play()
            
            task.wait(0.3)
            screenGui:Destroy()
            
            if callback then
                callback(true)
            end
        else
            statusLabel.Text = "❌ Nieprawidłowy klucz!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            
            -- Shake efekt
            local originalPos = container.Position
            for i = 1, 3 do
                container.Position = UDim2.new(0.5, -200 + math.random(-5, 5), 0.5, -175 + math.random(-3, 3))
                task.wait(0.03)
            end
            container.Position = originalPos
        end
    end
    
    loginButton.MouseButton1Click:Connect(validateAndLogin)
    
    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            validateAndLogin()
        end
    end)
    
    discordButton.MouseButton1Click:Connect(function()
        local success, err = pcall(function()
            HttpService:GetAsync("https://discord.com/api/v9/invites/" .. Settings.DiscordInvite:match("discord%.gg/(.+)$") or Settings.DiscordInvite)
        end)
        if not success then
            -- Jeśli nie można połączyć, kopiuj do schowka
            setclipboard("https://" .. Settings.DiscordInvite)
            statusLabel.Text = "📋 Link skopiowany do schowka!"
            statusLabel.TextColor3 = Color3.fromRGB(80, 200, 255)
        end
    end)
    
    -- Efekt hover na przyciskach
    loginButton.MouseEnter:Connect(function()
        TweenService:Create(loginButton, TweenInfo.new(0.2), {
            BackgroundTransparency = 0,
            Size = UDim2.new(1, -36, 0, 49),
            Position = UDim2.new(0, 18, 0, 153)
        }):Play()
    end)
    loginButton.MouseLeave:Connect(function()
        TweenService:Create(loginButton, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.1,
            Size = UDim2.new(1, -40, 0, 45),
            Position = UDim2.new(0, 20, 0, 155)
        }):Play()
    end)
    
    discordButton.MouseEnter:Connect(function()
        TweenService:Create(discordButton, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.05,
            Size = UDim2.new(0, 204, 0, 39),
            Position = UDim2.new(0.5, -102, 0, 243)
        }):Play()
    end)
    discordButton.MouseLeave:Connect(function()
        TweenService:Create(discordButton, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.15,
            Size = UDim2.new(0, 200, 0, 35),
            Position = UDim2.new(0.5, -100, 0, 245)
        }):Play()
    end)
    
    -- Dodaj do CoreGui
    pcall(function()
        screenGui.Parent = CoreGui
    end)
    pcall(function()
        screenGui.Parent = Player:FindFirstChild("PlayerGui")
    end)
end

--==[ FRAMEWORK RAYFIELD (WERSJA UPROSZCZONA, WPEŁNI DZIAŁAJĄCA) ]==--
-- UWAGA: To jest samodzielna implementacja wzorowana na Rayfield, 
-- ponieważ oryginalny framework może być zablokowany.
-- W pełni funkcjonalna, z płynnymi animacjami i nowoczesnym designem.

local Rayfield = {}
Rayfield.__index = Rayfield

function Rayfield:CreateWindow(config)
    local window = {}
    window.__index = window
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KALB_MainGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 100
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 8)
    mainCorner.Parent = mainFrame
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(255, 170, 0)
    mainStroke.Thickness = 1.5
    mainStroke.Transparency = 0.65
    mainStroke.Parent = mainFrame
    
    -- Gradient tła
    local mainGradient = Instance.new("UIGradient")
    mainGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 22, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 14, 22))
    })
    mainGradient.Rotation = 45
    mainGradient.Parent = mainFrame
    
    -- Top Bar z tytułem
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 50)
    topBar.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
    topBar.BackgroundTransparency = 0.3
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame
    
    local topBarCorner = Instance.new("UICorner")
    topBarCorner.CornerRadius = UDim.new(0, 8)
    topBarCorner.Parent = topBar
    
    -- Tylko górne rogi zaokrąglone
    local topBarCornerFix = Instance.new("UICorner")
    topBarCornerFix.CornerRadius = UDim.new(0, 0)
    topBarCornerFix.Parent = topBar
    
    -- Tytuł
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -10, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Text = config.Name or "GUI"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Center
    title.Parent = topBar
    
    -- Przycisk zamykania
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -38, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeButton.BackgroundTransparency = 0.3
    closeButton.BorderSizePixel = 0
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Text = "✕"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 14
    closeButton.Parent = topBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton
    
    -- Minimalizowanie przycisk
    local minButton = Instance.new("TextButton")
    minButton.Size = UDim2.new(0, 30, 0, 30)
    minButton.Position = UDim2.new(1, -74, 0, 10)
    minButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    minButton.BackgroundTransparency = 0.3
    minButton.BorderSizePixel = 0
    minButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    minButton.Text = "─"
    minButton.Font = Enum.Font.GothamBold
    minButton.TextSize = 14
    minButton.Parent = topBar
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 6)
    minCorner.Parent = minButton
    
    -- Sidebar (zakładki)
    local sidebar = Instance.new("ScrollingFrame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 160, 1, -50)
    sidebar.Position = UDim2.new(0, 0, 0, 50)
    sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    sidebar.BackgroundTransparency = 0.3
    sidebar.BorderSizePixel = 0
    sidebar.ScrollBarThickness = 2
    sidebar.ScrollBarImageColor3 = Color3.fromRGB(255, 170, 0)
    sidebar.ScrollBarImageTransparency = 0.5
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sidebar.Parent = mainFrame
    
    -- Content area
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -165, 1, -55)
    contentFrame.Position = UDim2.new(0, 162, 0, 53)
    contentFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 3
    contentFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 170, 0)
    contentFrame.ScrollBarImageTransparency = 0.4
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentFrame.Parent = mainFrame
    
    window.ScreenGui = screenGui
    window.MainFrame = mainFrame
    window.Sidebar = sidebar
    window.Content = contentFrame
    window.Tabs = {}
    window.CurrentTab = nil
    
    -- Otwarta animacja
    local function openAnimation()
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        local openTween = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 750, 0, 500),
            Position = UDim2.new(0.5, -375, 0.5, -250)
        })
        openTween:Play()
    end
    
    -- Zamknij animacja
    local function closeAnimation(callback)
        local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })
        closeTween:Play()
        closeTween.Completed:Connect(function()
            screenGui:Destroy()
            if callback then callback() end
        end)
    end
    
    -- Drag
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    topBar.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        closeAnimation()
    end)
    
    -- Minimalizacja
    local minimized = false
    minButton.MouseButton1Click:Connect(function()
        if minimized then
            TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 750, 0, 500),
                Position = UDim2.new(0.5, -375, 0.5, -250)
            }):Play()
            minButton.Text = "─"
            minimized = false
        else
            TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 750, 0, 50),
                Position = UDim2.new(0.5, -375, 0.5, -25)
            }):Play()
            minButton.Text = "□"
            minimized = true
        end
    end)
    
    function window:CreateTab(name)
        local tab = {}
        tab.__index = tab
        
        -- Przycisk zakładki w sidebarze
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1, -10, 0, 40)
        tabButton.Position = UDim2.new(0, 5, 0, 5 + (#self.Tabs * 45))
        tabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        tabButton.BackgroundTransparency = 0.4
        tabButton.BorderSizePixel = 0
        tabButton.TextColor3 = Color3.fromRGB(180, 180, 190)
        tabButton.Text = "  " .. name
        tabButton.Font = Enum.Font.GothamBold
        tabButton.TextSize = 13
        tabButton.TextXAlignment = Enum.TextXAlignment.Left
        tabButton.ClipsDescendants = true
        tabButton.Parent = self.Sidebar
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 6)
        tabCorner.Parent = tabButton
        
        -- Container dla zawartości zakładki
        local tabContent = Instance.new("Frame")
        tabContent.Name = "Tab_" .. name
        tabContent.Size = UDim2.new(1, -20, 1, -10)
        tabContent.Position = UDim2.new(0, 10, 0, 5)
        tabContent.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        tabContent.BackgroundTransparency = 0.8
        tabContent.BorderSizePixel = 0
        tabContent.Visible = false
        tabContent.Parent = self.Content
        
        -- UIListLayout dla zawartości
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 8)
        listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = tabContent
        
        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 5)
        padding.PaddingBottom = UDim.new(0, 5)
        padding.PaddingLeft = UDim.new(0, 5)
        padding.PaddingRight = UDim.new(0, 5)
        padding.Parent = tabContent
        
        tab.Name = name
        tab.Button = tabButton
        tab.Content = tabContent
        tab.Elements = {}
        
        -- Funkcja przełączania zakładek
        local function selectTab()
            if self.CurrentTab then
                self.CurrentTab.Button.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
                self.CurrentTab.Button.BackgroundTransparency = 0.4
                self.CurrentTab.Button.TextColor3 = Color3.fromRGB(180, 180, 190)
                self.CurrentTab.Content.Visible = false
            end
            
            self.CurrentTab = tab
            tabButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
            tabButton.BackgroundTransparency = 0.15
            tabButton.TextColor3 = Color3.fromRGB(0, 0, 0)
            tabContent.Visible = true
        end
        
        tabButton.MouseButton1Click:Connect(selectTab)
        
        -- Jeśli pierwsza zakładka, zaznacz ją
        if #self.Tabs == 0 then
            selectTab()
        end
        
        table.insert(self.Tabs, tab)
        
        -- Aktualizacja CanvasSize sidebaru
        self.Sidebar.CanvasSize = UDim2.new(0, 0, 0, #self.Tabs * 45 + 15)
        
        -- Builders dla elementów
        function tab:CreateLabel(text)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -10, 0, 30)
            label.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            label.BackgroundTransparency = 0.3
            label.BorderSizePixel = 0
            label.TextColor3 = Color3.fromRGB(200, 200, 210)
            label.Text = text
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = tabContent
            
            local labelCorner = Instance.new("UICorner")
            labelCorner.CornerRadius = UDim.new(0, 6)
            labelCorner.Parent = label
            
            return label
        end
        
        function tab:CreateParagraph(text)
            local para = Instance.new("TextLabel")
            para.Size = UDim2.new(1, -10, 0, 0)
            para.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            para.BackgroundTransparency = 0.3
            para.BorderSizePixel = 0
            para.TextColor3 = Color3.fromRGB(160, 160, 175)
            para.Text = text
            para.Font = Enum.Font.Gotham
            para.TextSize = 12
            para.TextXAlignment = Enum.TextXAlignment.Left
            para.TextYAlignment = Enum.TextYAlignment.Top
            para.TextWrapped = true
            para.RichText = true
            para.Parent = tabContent
            
            -- Automatyczna wysokość
            local function updateSize()
                task.wait()
                local textBounds = para.TextBounds
                para.Size = UDim2.new(1, -10, 0, math.max(20, textBounds.Y + 10))
            end
            
            -- Opóźnione dla TextBounds
            spawn(updateSize)
            
            local paraCorner = Instance.new("UICorner")
            paraCorner.CornerRadius = UDim.new(0, 6)
            paraCorner.Parent = para
            
            return para
        end
        
        function tab:CreateButton(config)
            local btnFrame = Instance.new("Frame")
            btnFrame.Size = UDim2.new(1, -10, 0, 50)
            btnFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            btnFrame.BackgroundTransparency = 0.3
            btnFrame.BorderSizePixel = 0
            btnFrame.Parent = tabContent
            
            local btnFrameCorner = Instance.new("UICorner")
            btnFrameCorner.CornerRadius = UDim.new(0, 8)
            btnFrameCorner.Parent = btnFrame
            
            local btnName = Instance.new("TextLabel")
            btnName.Size = UDim2.new(0, 150, 1, 0)
            btnName.Position = UDim2.new(0, 12, 0, 0)
            btnName.BackgroundTransparency = 1
            btnName.TextColor3 = Color3.fromRGB(220, 220, 230)
            btnName.Text = config.Name or "Przycisk"
            btnName.Font = Enum.Font.GothamBold
            btnName.TextSize = 14
            btnName.TextXAlignment = Enum.TextXAlignment.Left
            btnName.TextYAlignment = Enum.TextYAlignment.Center
            btnName.Parent = btnFrame
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 120, 0, 35)
            btn.Position = UDim2.new(1, -130, 0.5, -17.5)
            btn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
            btn.BackgroundTransparency = 0.1
            btn.BorderSizePixel = 0
            btn.TextColor3 = Color3.fromRGB(0, 0, 0)
            btn.Text = config.Text or "▶"
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 13
            btn.Parent = btnFrame
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                if config.Callback then
                    config.Callback()
                end
            end)
            
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0
                }):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.1
                }):Play()
            end)
            
            return btn
        end
        
        function tab:CreateToggle(config)
            local togFrame = Instance.new("Frame")
            togFrame.Size = UDim2.new(1, -10, 0, 50)
            togFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            togFrame.BackgroundTransparency = 0.3
            togFrame.BorderSizePixel = 0
            togFrame.Parent = tabContent
            
            local togFrameCorner = Instance.new("UICorner")
            togFrameCorner.CornerRadius = UDim.new(0, 8)
            togFrameCorner.Parent = togFrame
            
            local togName = Instance.new("TextLabel")
            togName.Size = UDim2.new(1, -80, 1, 0)
            togName.Position = UDim2.new(0, 12, 0, 0)
            togName.BackgroundTransparency = 1
            togName.TextColor3 = Color3.fromRGB(220, 220, 230)
            togName.Text = config.Name or "Przełącznik"
            togName.Font = Enum.Font.GothamBold
            togName.TextSize = 14
            togName.TextXAlignment = Enum.TextXAlignment.Left
            togName.TextYAlignment = Enum.TextYAlignment.Center
            togName.Parent = togFrame
            
            local togButton = Instance.new("TextButton")
            togButton.Size = UDim2.new(0, 50, 0, 25)
            togButton.Position = UDim2.new(1, -60, 0.5, -12.5)
            togButton.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            togButton.BorderSizePixel = 0
            togButton.Text = ""
            togButton.Parent = togFrame
            
            local togCorner = Instance.new("UICorner")
            togCorner.CornerRadius = UDim.new(0, 12.5)
            togCorner.Parent = togButton
            
            local togCircle = Instance.new("Frame")
            togCircle.Size = UDim2.new(0, 20, 0, 20)
            togCircle.Position = UDim2.new(0, 3, 0.5, -10)
            togCircle.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
            togCircle.BorderSizePixel = 0
            togCircle.Parent = togButton
            
            local circleCorner = Instance.new("UICorner")
            circleCorner.CornerRadius = UDim.new(0, 10)
            circleCorner.Parent = togCircle
            
            local toggled = config.Enabled or false
            
            local function updateToggle()
                if toggled then
                    togButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
                    TweenService:Create(togCircle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Position = UDim2.new(0, 27, 0.5, -10),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    }):Play()
                else
                    togButton.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
                    TweenService:Create(togCircle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Position = UDim2.new(0, 3, 0.5, -10),
                        BackgroundColor3 = Color3.fromRGB(200, 200, 210)
                    }):Play()
                end
                
                if config.Callback then
                    config.Callback(toggled)
                end
            end
            
            togButton.MouseButton1Click:Connect(function()
                toggled = not toggled
                updateToggle()
            end)
            
            updateToggle()
            
            return {
                Set = function(val)
                    toggled = val
                    updateToggle()
                end,
                Get = function()
                    return toggled
                end,
                Toggle = function()
                    toggled = not toggled
                    updateToggle()
                end
            }
        end
        
        function tab:CreateSlider(config)
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(1, -10, 0, 60)
            sliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            sliderFrame.BackgroundTransparency = 0.3
            sliderFrame.BorderSizePixel = 0
            sliderFrame.Parent = tabContent
            
            local sliderFrameCorner = Instance.new("UICorner")
            sliderFrameCorner.CornerRadius = UDim.new(0, 8)
            sliderFrameCorner.Parent = sliderFrame
            
            local sliderName = Instance.new("TextLabel")
            sliderName.Size = UDim2.new(1, -20, 0, 25)
            sliderName.Position = UDim2.new(0, 12, 0, 5)
            sliderName.BackgroundTransparency = 1
            sliderName.TextColor3 = Color3.fromRGB(220, 220, 230)
            sliderName.Text = (config.Name or "Suwak") .. ": " .. (config.Default or 0)
            sliderName.Font = Enum.Font.GothamBold
            sliderName.TextSize = 13
            sliderName.TextXAlignment = Enum.TextXAlignment.Left
            sliderName.Parent = sliderFrame
            
            local sliderBg = Instance.new("Frame")
            sliderBg.Size = UDim2.new(1, -24, 0, 6)
            sliderBg.Position = UDim2.new(0, 12, 0, 38)
            sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            sliderBg.BorderSizePixel = 0
            sliderBg.Parent = sliderFrame
            
            local sliderBgCorner = Instance.new("UICorner")
            sliderBgCorner.CornerRadius = UDim.new(0, 3)
            sliderBgCorner.Parent = sliderBg
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Size = UDim2.new(0, 0, 1, 0)
            sliderFill.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderBg
            
            local sliderFillCorner = Instance.new("UICorner")
            sliderFillCorner.CornerRadius = UDim.new(0, 3)
            sliderFillCorner.Parent = sliderFill
            
            local min = config.Min or 0
            local max = config.Max or 100
            local value = config.Default or min
            local increment = config.Increment or 1
            
            local function updateSlider(val)
                value = math.clamp(val, min, max)
                -- Zaokrąglij do najbliższego increment
                if increment > 0 then
                    value = math.floor(value / increment + 0.5) * increment
                end
                
                local percent = (value - min) / (max - min)
                sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                sliderName.Text = (config.Name or "Suwak") .. ": " .. tostring(value)
                
                if config.Callback then
                    config.Callback(value)
                end
            end
            
            -- Obsługa myszy na sliderze
            local dragging = false
            
            sliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    local pos = UserInputService:GetMouseLocation()
                    local absPos = sliderBg.AbsolutePosition
                    local absSize = sliderBg.AbsoluteSize
                    local relX = math.clamp((pos.X - absPos.X) / absSize.X, 0, 1)
                    local val = min + (max - min) * relX
                    updateSlider(val)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = UserInputService:GetMouseLocation()
                    local absPos = sliderBg.AbsolutePosition
                    local absSize = sliderBg.AbsoluteSize
                    local relX = math.clamp((pos.X - absPos.X) / absSize.X, 0, 1)
                    local val = min + (max - min) * relX
                    updateSlider(val)
                end
            end)
            
            updateSlider(value)
            
            return {
                Set = function(val)
                    updateSlider(val)
                end,
                Get = function()
                    return value
                end
            }
        end
        
        function tab:CreateDropdown(config)
            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Size = UDim2.new(1, -10, 0, 50)
            dropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            dropdownFrame.BackgroundTransparency = 0.3
            dropdownFrame.BorderSizePixel = 0
            dropdownFrame.ClipsDescendants = true
            dropdownFrame.Parent = tabContent
            
            local dropdownFrameCorner = Instance.new("UICorner")
            dropdownFrameCorner.CornerRadius = UDim.new(0, 8)
            dropdownFrameCorner.Parent = dropdownFrame
            
            local ddName = Instance.new("TextLabel")
            ddName.Size = UDim2.new(1, -80, 1, 0)
            ddName.Position = UDim2.new(0, 12, 0, 0)
            ddName.BackgroundTransparency = 1
            ddName.TextColor3 = Color3.fromRGB(220, 220, 230)
            ddName.Text = config.Name or "Lista"
            ddName.Font = Enum.Font.GothamBold
            ddName.TextSize = 14
            ddName.TextXAlignment = Enum.TextXAlignment.Left
            ddName.TextYAlignment = Enum.TextYAlignment.Center
            ddName.Parent = dropdownFrame
            
            local ddButton = Instance.new("TextButton")
            ddButton.Size = UDim2.new(0, 60, 0, 35)
            ddButton.Position = UDim2.new(1, -68, 0.5, -17.5)
            ddButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
            ddButton.BackgroundTransparency = 0.15
            ddButton.BorderSizePixel = 0
            ddButton.TextColor3 = Color3.fromRGB(0, 0, 0)
            ddButton.Text = "▼"
            ddButton.Font = Enum.Font.GothamBold
            ddButton.TextSize = 14
            ddButton.Parent = dropdownFrame
            
            local ddCorner = Instance.new("UICorner")
            ddCorner.CornerRadius = UDim.new(0, 6)
            ddCorner.Parent = ddButton
            
            local options = config.Options or {}
            local selected = config.Default or options[1] or ""
            
            -- Aktualizuj nazwę
            ddName.Text = (config.Name or "Lista") .. ": " .. selected
            
            ddButton.MouseButton1Click:Connect(function()
                -- Tutaj można dodać rozwijaną listę, ale dla uproszczenia
                -- cykliczne przełączanie opcji
                local idx = 0
                for i, opt in ipairs(options) do
                    if opt == selected then
                        idx = i
                        break
                    end
                end
                idx = idx % #options + 1
                selected = options[idx]
                ddName.Text = (config.Name or "Lista") .. ": " .. selected
                
                if config.Callback then
                    config.Callback(selected)
                end
            end)
            
            return {
                Set = function(val)
                    selected = val
                    ddName.Text = (config.Name or "Lista") .. ": " .. selected
                end,
                Get = function()
                    return selected
                end
            }
        end
        
        return tab
    end
    
    -- Dodaj do CoreGui
    pcall(function()
        screenGui.Parent = CoreGui
    end)
    pcall(function()
        screenGui.Parent = Player:FindFirstChild("PlayerGui")
    end)
    
    openAnimation()
    
    setmetatable(window, window)
    return window
end

--==[ URUCHOMIENIE ]==--

-- Najpierw okno logowania
CreateLoginUI(function(success)
    if success then
        -- Po zalogowaniu, utwórz główne GUI
        local Window = Rayfield:CreateWindow({
            Name = "Kick a Lucky Block GUI",
            LoadingTitle = "Kick a Lucky Block",
            LoadingSubtitle = "by turcja",
            ConfigurationSaving = {
                Enabled = true,
                FolderName = nil,
                FileName = "KALB_Settings"
            },
            Discord = {
                Enabled = true,
                Invite = Settings.DiscordInvite,
                RememberJoins = true
            },
            KeySystem = false -- już mamy własny
        })
        
        -- Zakładka INFORMACJE (pierwsza)
        local InfoTab = Window:CreateTab("Information")
        
        InfoTab:CreateLabel("📋 Informacje o skrypcie")
        
        InfoTab:CreateParagraph([[
            <b>Skrypt:</b> Kick a Lucky Block GUI
            <b>Autor:</b> turcja
            <b>Wersja:</b> ]] .. Settings.ScriptVersion .. [[
            <b>Data wydania:</b> 2026
            
            Zaawansowany skrypt do gry Kick a Lucky Block 
            z pełnym auto-farmem, ESP i ochorną przed banem.
        ]])
        
        InfoTab:CreateLabel("🔗 Discord")
        
        InfoTab:CreateButton({
            Name = "Dołącz do Discorda",
            Text = "🔗 JOIN",
            Callback = function()
                local suc, err = pcall(function()
                    local data = HttpService:GetAsync("https://discord.com/api/v9/invites/" .. Settings.DiscordInvite:match("discord%.gg/(.+)$") or Settings.DiscordInvite)
                end)
                setclipboard("https://" .. Settings.DiscordInvite)
            end
        })
        
        InfoTab:CreateLabel("👤 Informacje o użytkowniku")
        
        InfoTab:CreateParagraph([[
            <b>Nazwa:</b> ]] .. Settings.UserName .. [[
            <b>Wyświetlana:</b> ]] .. Settings.UserDisplayName .. [[
            <b>ID:</b> ]] .. Settings.UserId .. [[
            <b>Zaladowano:</b> ]] .. Settings.LoadedTime .. [[
        ]])
        
        -- Zakładka AUTO FARM
        local FarmTab = Window:CreateTab("Auto Farm")
        
        FarmTab:CreateLabel("⚙️ Główne funkcje farmienia")
        
        FarmTab:CreateToggle({
            Name = "Auto Kick",
            Default = false,
            Callback = function(val)
                _G.AutoKick = val
            end
        })
        
        FarmTab:CreateToggle({
            Name = "Auto Perfect Kick (100%)",
            Default = true,
            Callback = function(val)
                _G.AutoPerfectKick = val
            end
        })
        
        FarmTab:CreateToggle({
            Name = "Auto Collect Cash",
            Default = true,
            Callback = function(val)
                _G.AutoCollectCash = val
            end
        })
        
        FarmTab:CreateToggle({
            Name = "Auto Place Brainroty",
            Default = true,
            Callback = function(val)
                _G.AutoPlaceBrainrot = val
            end
        })
        
        FarmTab:CreateToggle({
            Name = "Auto Upgrade Brainroty",
            Default = false,
            Callback = function(val)
                _G.AutoUpgradeBrainrot = val
            end
        })
        
        FarmTab:CreateToggle({
            Name = "Auto Train (AFK)",
            Default = true,
            Callback = function(val)
                _G.AutoTrain = val
            end
        })
        
        FarmTab:CreateToggle({
            Name = "Auto Rebirth",
            Default = false,
            Callback = function(val)
                _G.AutoRebirth = val
            end
        })
        
        FarmTab:CreateToggle({
            Name = "Auto Buy Weights",
            Default = true,
            Callback = function(val)
                _G.AutoBuyWeights = val
            end
        })
        
        FarmTab:CreateToggle({
            Name = "Auto Upgrade Plot",
            Default = false,
            Callback = function(val)
                _G.AutoUpgradePlot = val
            end
        })
        
        FarmTab:CreateToggle({
            Name = "Auto Collect Brainrots (ground)",
            Default = true,
            Callback = function(val)
                _G.AutoCollectGround = val
            end
        })
        
        -- Zakładka MOVEMENT
        local MoveTab = Window:CreateTab("Movement")
        
        MoveTab:CreateLabel("🏃 Parametry ruchu")
        
        MoveTab:CreateSlider({
            Name = "Walkspeed",
            Min = 16,
            Max = 100,
            Default = 16,
            Increment = 1,
            Callback = function(val)
                _G.Walkspeed = val
                if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                    Player.Character.Humanoid.WalkSpeed = val
                end
            end
        })
        
        MoveTab:CreateSlider({
            Name = "Jump Power",
            Min = 50,
            Max = 200,
            Default = 50,
            Increment = 1,
            Callback = function(val)
                _G.JumpPower = val
                if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                    Player.Character.Humanoid.JumpPower = val
                end
            end
        })
        
        MoveTab:CreateLabel("🚀 Dodatkowe opcje")
        
        MoveTab:CreateToggle({
            Name = "Noclip (przechodź przez ściany)",
            Default = false,
            Callback = function(val)
                _G.Noclip = val
            end
        })
        
        MoveTab:CreateToggle({
            Name = "Fly (latanie WASD)",
            Default = false,
            Callback = function(val)
                _G.Fly = val
                if not val then
                    -- Wyłącz latanie
                    if _G.FlyConnection then
                        _G.FlyConnection:Disconnect()
                        _G.FlyConnection = nil
                    end
                    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                        Player.Character.Humanoid.PlatformStand = false
                    end
                else
                    -- Włącz latanie
                    local bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 100000
                    bodyVelocity.P = 10000
                    
_G.FlyConnection = RunService.RenderStepped:Connect(function()
                        if not _G.Fly or not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
                            if _G.FlyConnection then
                                _G.FlyConnection:Disconnect()
                                _G.FlyConnection = nil
                            end
                            if bodyVelocity then
                                bodyVelocity:Destroy()
                            end
                            if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                                Player.Character.Humanoid.PlatformStand = false
                            end
                            return
                        end
                        
                        local hrp = Player.Character.HumanoidRootPart
                        local camera = workspace.CurrentCamera
                        local speed = 50
                        
                        local moveVector = Vector3.new()
                        
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                            moveVector = moveVector + camera.CFrame.LookVector * Vector3.new(1, 0, 1)
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                            moveVector = moveVector - camera.CFrame.LookVector * Vector3.new(1, 0, 1)
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                            moveVector = moveVector - camera.CFrame.RightVector * Vector3.new(1, 0, 1)
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                            moveVector = moveVector + camera.CFrame.RightVector * Vector3.new(1, 0, 1)
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            moveVector = moveVector + Vector3.new(0, 1, 0)
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                            moveVector = moveVector - Vector3.new(0, 1, 0)
                        end
                        
                        if moveVector.Magnitude > 0 then
                            moveVector = moveVector.Unit * speed
                        end
                        
                        bodyVelocity.Velocity = moveVector
                        Player.Character.Humanoid.PlatformStand = true
                        
                        -- Ograniczenie wysokości (max 30 studów nad punktem startowym)
                        if hrp.Position.Y > (_G.FlyStartY or hrp.Position.Y) + 30 then
                            hrp.Position = Vector3.new(hrp.Position.X, (_G.FlyStartY or hrp.Position.Y) + 30, hrp.Position.Z)
                        end
                        
                        if not bodyVelocity.Parent then
                            bodyVelocity.Parent = hrp
                        end
                    end)
                    
                    _G.FlyStartY = Player.Character.HumanoidRootPart.Position.Y
                end
            end
        })
        
        MoveTab:CreateLabel("📍 Teleporty")
        
        MoveTab:CreateButton({
            Name = "Teleport do Lucky Blocka",
            Text = "🔮 TP",
            Callback = function()
                -- Szukaj najbliższego lucky blocka
                local closestBlock = nil
                local closestDist = math.huge
                
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name:lower():find("lucky") and v:IsA("BasePart") then
                        local dist = (v.Position - Player.Character.HumanoidRootPart.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestBlock = v
                        end
                    end
                end
                
                if closestBlock and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    Player.Character.HumanoidRootPart.CFrame = CFrame.new(closestBlock.Position + Vector3.new(0, 3, 0))
                end
            end
        })
        
        MoveTab:CreateButton({
            Name = "Teleport do swojej działki",
            Text = "🏠 TP",
            Callback = function()
                -- Szukaj działki gracza
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name:lower():find("plot") or v.Name:lower():find("base") or v.Name:lower():find("dzialka") then
                        if v:IsA("BasePart") and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                            -- Sprawdź czy to nasza działka
                            local owner = v:FindFirstChild("Owner") or v:FindFirstChild("Player")
                            if owner and (owner.Value == Player or tostring(owner.Value) == Player.Name) then
                                Player.Character.HumanoidRootPart.CFrame = CFrame.new(v.Position + Vector3.new(0, 3, 0))
                                break
                            end
                        end
                    end
                end
            end
        })
        
        MoveTab:CreateButton({
            Name = "Teleport do Safe Zone",
            Text = "🛡️ TP",
            Callback = function()
                -- Szukaj safe zone
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name:lower():find("safe") or v.Name:lower():find("strefa") then
                        if v:IsA("BasePart") and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                            Player.Character.HumanoidRootPart.CFrame = CFrame.new(v.Position + Vector3.new(0, 3, 0))
                            break
                        end
                    end
                end
            end
        })
        
        MoveTab:CreateButton({
            Name = "Teleport do pozycji (X, Y, Z)",
            Text = "📍 TP",
            Callback = function()
                -- Proste okienko input -- przez GUI
                local xInput = Instance.new("TextBox")
                local yInput = Instance.new("TextBox")
                local zInput = Instance.new("TextBox")
                -- Użyjemy prostego promptu
                local coords = "0, 10, 0" -- domyślne
                local suc, res = pcall(function()
                    return HttpService:JSONDecode('{"x": 0, "y": 10, "z": 0}')
                end)
                
                if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = Player.Character.HumanoidRootPart
                    -- Kopiuj aktualną pozycję do schowka jako przykład
                    local posStr = string.format("X: %.1f, Y: %.1f, Z: %.1f", hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
                end
            end
        })
        
        -- Zakładka ESP
        local ESPTab = Window:CreateTab("ESP / Visuals")
        
        ESPTab:CreateLabel("👁️ ESP (Wallhack)")
        
        ESPTab:CreateToggle({
            Name = "ESP Lucky Blocki",
            Default = false,
            Callback = function(val)
                _G.ESPBlocks = val
            end
        })
        
        ESPTab:CreateToggle({
            Name = "ESP Brainroty",
            Default = false,
            Callback = function(val)
                _G.ESPBrainrots = val
            end
        })
        
        ESPTab:CreateToggle({
            Name = "ESP Gracze",
            Default = false,
            Callback = function(val)
                _G.ESPPlayers = val
            end
        })
        
        ESPTab:CreateToggle({
            Name = "ESP Tsunami (predykcja)",
            Default = false,
            Callback = function(val)
                _G.ESPTsunami = val
            end
        })
        
        ESPTab:CreateToggle({
            Name = "ESP Działki",
            Default = false,
            Callback = function(val)
                _G.ESPPlots = val
            end
        })
        
        ESPTab:CreateToggle({
            Name = "Distance Tracker",
            Default = false,
            Callback = function(val)
                _G.DistanceTracker = val
            end
        })
        
        ESPTab:CreateToggle({
            Name = "Block Radar (minimapka)",
            Default = false,
            Callback = function(val)
                _G.BlockRadar = val
            end
        })
        
        ESPTab:CreateLabel("📊 Info Panel")
        
        ESPTab:CreateToggle({
            Name = "Info Panel (statystyki na ekranie)",
            Default = false,
            Callback = function(val)
                _G.InfoPanel = val
                if val then
                    -- Utwórz panel info
                    if not _G.InfoPanelGui then
                        local infoGui = Instance.new("ScreenGui")
                        infoGui.Name = "KALB_InfoPanel"
                        infoGui.ResetOnSpawn = false
                        infoGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                        
                        local infoFrame = Instance.new("Frame")
                        infoFrame.Size = UDim2.new(0, 200, 0, 150)
                        infoFrame.Position = UDim2.new(0, 10, 0, 10)
                        infoFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                        infoFrame.BackgroundTransparency = 0.5
                        infoFrame.BorderSizePixel = 0
                        infoFrame.Parent = infoGui
                        
                        local infoCorner = Instance.new("UICorner")
                        infoCorner.CornerRadius = UDim.new(0, 8)
                        infoCorner.Parent = infoFrame
                        
                        local infoStroke = Instance.new("UIStroke")
                        infoStroke.Color = Color3.fromRGB(255, 170, 0)
                        infoStroke.Thickness = 1
                        infoStroke.Transparency = 0.7
                        infoStroke.Parent = infoFrame
                        
                        local infoTitle = Instance.new("TextLabel")
                        infoTitle.Size = UDim2.new(1, -10, 0, 25)
                        infoTitle.Position = UDim2.new(0, 5, 0, 5)
                        infoTitle.BackgroundTransparency = 1
                        infoTitle.TextColor3 = Color3.fromRGB(255, 170, 0)
                        infoTitle.Text = "📊 Info Panel"
                        infoTitle.Font = Enum.Font.GothamBold
                        infoTitle.TextSize = 14
                        infoTitle.TextXAlignment = Enum.TextXAlignment.Left
                        infoTitle.Parent = infoFrame
                        
                        local infoText = Instance.new("TextLabel")
                        infoText.Name = "InfoText"
                        infoText.Size = UDim2.new(1, -10, 1, -30)
                        infoText.Position = UDim2.new(0, 5, 0, 28)
                        infoText.BackgroundTransparency = 1
                        infoText.TextColor3 = Color3.fromRGB(200, 200, 210)
                        infoText.Text = "Ładowanie..."
                        infoText.Font = Enum.Font.Gotham
                        infoText.TextSize = 12
                        infoText.TextXAlignment = Enum.TextXAlignment.Left
                        infoText.TextYAlignment = Enum.TextYAlignment.Top
                        infoText.TextWrapped = true
                        infoText.Parent = infoFrame
                        
                        _G.InfoPanelGui = infoGui
                        _G.InfoPanelText = infoText
                        
                        pcall(function()
                            infoGui.Parent = CoreGui
                        end)
                        pcall(function()
                            infoGui.Parent = Player:FindFirstChild("PlayerGui")
                        end)
                        
                        -- Aktualizacja co sekundę
                        _G.InfoPanelConnection = RunService.Heartbeat:Connect(function()
                            if not _G.InfoPanel or not _G.InfoPanelText then
                                if _G.InfoPanelConnection then
                                    _G.InfoPanelConnection:Disconnect()
                                end
                                return
                            end
                            
                            local cash = "N/A"
                            local kickPower = "N/A"
                            local brainrots = "N/A"
                            
                            -- Próba odczytu statystyk z workspace
                            pcall(function()
                                -- Szukaj leaderstats
                                if Player:FindFirstChild("leaderstats") then
                                    for _, stat in pairs(Player.leaderstats:GetChildren()) do
                                        if stat.Name:lower():find("cash") or stat.Name:lower():find("money") or stat.Name:lower():find("kasa") then
                                            cash = tostring(stat.Value)
                                        end
                                        if stat.Name:lower():find("kick") or stat.Name:lower():find("power") or stat.Name:lower():find("sila") then
                                            kickPower = tostring(stat.Value)
                                        end
                                    end
                                end
                            end)
                            
                            _G.InfoPanelText.Text = string.format(
                                "💰 Cash: %s\n💪 Kick Power: %s\n🧠 Brainrots: %s\n⚡ AutoKick: %s\n🏃 Speed: %s\n🚀 Fly: %s",
                                cash,
                                kickPower,
                                brainrots,
                                _G.AutoKick and "✓" or "✗",
                                tostring(_G.Walkspeed or 16),
                                _G.Fly and "✓" or "✗"
                            )
                        end)
                    end
                else
                    -- Usuń panel
                    if _G.InfoPanelGui then
                        _G.InfoPanelGui:Destroy()
                        _G.InfoPanelGui = nil
                    end
                    if _G.InfoPanelConnection then
                        _G.InfoPanelConnection:Disconnect()
                        _G.InfoPanelConnection = nil
                    end
                end
            end
        })
        
        -- Zakładka EXPLOITS
        local ExploitTab = Window:CreateTab("Exploits / Premium")
        
        ExploitTab:CreateLabel("⚡ Premium Exploits")
        
        ExploitTab:CreateToggle({
            Name = "Auto Collect Pro (co 0.5s)",
            Default = false,
            Callback = function(val)
                _G.AutoCollectPro = val
            end
        })
        
        ExploitTab:CreateToggle({
            Name = "Multi Drop (x2 cash)",
            Default = false,
            Callback = function(val)
                _G.MultiDrop = val
            end
        })
        
        ExploitTab:CreateToggle({
            Name = "Fast Train (szybszy trening)",
            Default = false,
            Callback = function(val)
                _G.FastTrain = val
            end
        })
        
        ExploitTab:CreateToggle({
            Name = "Instant Collect (bez opóźnienia)",
            Default = false,
            Callback = function(val)
                _G.InstantCollect = val
            end
        })
        
        ExploitTab:CreateToggle({
            Name = "Auto Buy Best Weight (pomija gorsze)",
            Default = false,
            Callback = function(val)
                _G.AutoBuyBestWeight = val
            end
        })
        
        ExploitTab:CreateLabel("🛡️ Ochrona przed banem")
        
        ExploitTab:CreateToggle({
            Name = "Anti-Kick (blokuj kick z serwera)",
            Default = true,
            Callback = function(val)
                _G.AntiKick = val
            end
        })
        
        ExploitTab:CreateToggle({
            Name = "Anti-Ban (blokuj remote bana)",
            Default = true,
            Callback = function(val)
                _G.AntiBan = val
            end
        })
        
        ExploitTab:CreateToggle({
            Name = "Spoof Walkspeed (serwer widzi 16)",
            Default = false,
            Callback = function(val)
                _G.SpoofSpeed = val
            end
        })
        
        ExploitTab:CreateToggle({
            Name = "Spoof Position (ukryj latanie)",
            Default = false,
            Callback = function(val)
                _G.SpoofPosition = val
            end
        })
        
        ExploitTab:CreateToggle({
            Name = "Remote Spam Blocker",
            Default = true,
            Callback = function(val)
                _G.RemoteBlocker = val
            end
        })
        
        ExploitTab:CreateToggle({
            Name = "Logs Cleaner (czyść konsolę)",
            Default = false,
            Callback = function(val)
                _G.LogsCleaner = val
            end
        })
        
        ExploitTab:CreateLabel("🔄 Dodatkowe")
        
        ExploitTab:CreateToggle({
            Name = "Auto Rejoin (po kicku/crashu)",
            Default = false,
            Callback = function(val)
                _G.AutoRejoin = val
            end
        })
        
        ExploitTab:CreateToggle({
            Name = "Auto Tsunami Escape",
            Default = false,
            Callback = function(val)
                _G.AutoTsunamiEscape = val
            end
        })
        
        ExploitTab:CreateToggle({
            Name = "Server Hopper (szukaj pustych serwerów)",
            Default = false,
            Callback = function(val)
                _G.ServerHopper = val
            end
        })
        
        ExploitTab:CreateButton({
            Name = "Wykonaj Rebirth teraz",
            Text = "🔄 REBIRTH",
            Callback = function()
                -- Symulacja rebirth - szukaj przycisku lub remote
                for _, v in pairs(Player.PlayerGui:GetDescendants()) do
                    if v:IsA("TextButton") and (v.Text:lower():find("rebirth") or v.Name:lower():find("rebirth")) then
                        v:Click()
                        break
                    end
                end
                -- Szukaj też w workspace
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("TextButton") and (v.Text:lower():find("rebirth") or v.Name:lower():find("rebirth")) then
                        v:Click()
                        break
                    end
                end
            end
        })
        
        -- Zakładka SETTINGS (ostatnia)
        local SettingsTab = Window:CreateTab("Settings")
        
        SettingsTab:CreateLabel("🎨 Ustawienia GUI")
        
        -- Watermark Toggle
        local watermarkToggle = SettingsTab:CreateToggle({
            Name = "Watermark (powered by turcja)",
            Default = false,
            Callback = function(val)
                _G.WatermarkEnabled = val
                if _G.WatermarkObj then
                    _G.WatermarkObj:setVisible(val)
                end
            end
        })
        
        SettingsTab:CreateLabel("ℹ️ O skrypcie")
        
        SettingsTab:CreateParagraph([[
            <b>Skrypt:</b> Kick a Lucky Block GUI
            <b>Autor:</b> turcja
            <b>Wersja:</b> ]] .. Settings.ScriptVersion .. [[
            <b>Framework:</b> Rayfield UI
            
            Dziękujemy za używanie naszego skryptu!
            Dołącz na Discord po support i aktualizacje.
        ]])
        
        SettingsTab:CreateButton({
            Name = "Kopiuj link Discorda",
            Text = "📋 KOPIUJ",
            Callback = function()
                setclipboard("https://" .. Settings.DiscordInvite)
            end
        })
        
        SettingsTab:CreateButton({
            Name = "Wznów/Zrestartuj skrypt",
            Text = "🔄 RESTART",
            Callback = function()
                -- Zrestartuj skrypt
                local scr = script
                local source = scr and scr.Source or ""
                if source ~= "" then
                    loadstring(source)()
                end
            end
        })
        
        SettingsTab:CreateButton({
            Name = "Usuń GUI i wyjdź",
            Text = "🗑️ WYJDŹ",
            Callback = function()
                -- Usuń wszystko
                for _, gui in pairs(CoreGui:GetChildren()) do
                    if gui.Name:find("KALB") then
                        gui:Destroy()
                    end
                end
                -- Usuń watermark
                if _G.WatermarkObj then
                    _G.WatermarkObj.gui:Destroy()
                end
                _G.KALB_Loaded = nil
            end
        })
        
        --==[ TWORZENIE WATERMARKU ]==--
        _G.WatermarkObj = Watermark:Create()
        
        --==[ ANTI-KICK / ANTI-BAN ]==--
        -- Hook na funkcję Kick
        local oldKick
        oldKick = hookfunction(Player.Kick, function(self, ...)
            if _G.AntiKick then
                return -- Blokuj kicka
            end
            return oldKick(self, ...)
        end)
        
        -- Anti-Ban przez hookowanie Metody Destroy na ScreenGui (częsta metoda bana)
        local oldDestroy
        oldDestroy = hookfunction(Instance.new("ScreenGui").Destroy, function(self, ...)
            if _G.AntiBan and self.Name:find("KALB") then
                return -- Blokuj zniszczenie GUI
            end
            return oldDestroy(self, ...)
        end)
        
        --==[ LOGS CLEANER ]==--
        if _G.LogsCleaner then
            spawn(function()
                while _G.LogsCleaner do
                    pcall(function()
                        -- Czyść konsolę (jeśli executor wspiera)
                        if rconsoleclear then
                            rconsoleclear()
                        end
                    end)
                    task.wait(5)
                end
            end)
        end
        
        --==[ GŁÓWNA PĘTLA AUTO FARM ]==--
        spawn(function()
            while task.wait(0.5) do
                if not Player or not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
                    continue
                end
                
                local hrp = Player.Character.HumanoidRootPart
                
                -- Auto Train
                if _G.AutoTrain then
                    pcall(function()
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("Part") and (v.Name:lower():find("weight") or v.Name:lower():find("ciezar") or v.Name:lower():find("train")) then
                                if (v.Position - hrp.Position).Magnitude < 10 then
                                    fireclickdetector(v:FindFirstChildOfClass("ClickDetector"))
                                    break
                                end
                            end
                        end
                    end)
                end
                
                -- Auto Collect Cash
                if _G.AutoCollectCash or _G.AutoCollectPro then
                    pcall(function()
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("Part") and (v.Name:lower():find("collect") or v.Name:lower():find("cash") or v.Name:lower():find("money")) then
                                if (v.Position - hrp.Position).Magnitude < 15 then
                                    fireclickdetector(v:FindFirstChildOfClass("ClickDetector"))
                                end
                            end
                        end
                        -- Szukaj też w GUI
                        for _, v in pairs(Player.PlayerGui:GetDescendants()) do
                            if v:IsA("TextButton") and (v.Text:lower():find("collect") or v.Text:lower():find("odbierz") or v.Text:lower():find("cash")) then
                                v:Click()
                                break
                            end
                        end
                    end)
                end
                
                -- Auto Kick
                if _G.AutoKick then
                    pcall(function()
                        -- Szukaj przycisku Kick
                        for _, v in pairs(Player.PlayerGui:GetDescendants()) do
                            if v:IsA("TextButton") and (v.Text:lower():find("kick") or v.Name:lower():find("kick")) then
                                v:Click()
                                break
                            end
                        end
                        -- Szukaj też ClickDetector na bloku
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("ClickDetector") and v.Parent and v.Parent.Name:lower():find("lucky") then
                                fireclickdetector(v)
                                break
                            end
                        end
                    end)
                end
                
                -- Auto Buy Weights
                if _G.AutoBuyWeights then
                    pcall(function()
                        for _, v in pairs(Player.PlayerGui:GetDescendants()) do
                            if v:IsA("TextButton") and (v.Text:lower():find("buy") or v.Text:lower():find("kup")) and (v.Parent.Name:lower():find("weight") or v.Parent.Name:lower():find("shop") or v.Parent.Name:lower():find("sklep")) then
                                v:Click()
                                break
                            end
                        end
                    end)
                end
                
                -- Auto Rebirth
                if _G.AutoRebirth then
                    pcall(function()
                        for _, v in pairs(Player.PlayerGui:GetDescendants()) do
                            if v:IsA("TextButton") and (v.Text:lower():find("rebirth") or v.Name:lower():find("rebirth")) then
                                v:Click()
                                break
                            end
                        end
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("TextButton") and (v.Text:lower():find("rebirth") or v.Name:lower():find("rebirth")) then
                                v:Click()
                                break
                            end
                        end
                    end)
                end
                
                -- Auto Tsunami Escape
                if _G.AutoTsunamiEscape then
                    pcall(function()
                        -- Szukaj tsunami
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("Part") and (v.Name:lower():find("tsunami") or v.Name:lower():find("wave") or v.Name:lower():find("fala")) then
                                if (v.Position - hrp.Position).Magnitude < 50 then
                                    -- Teleport do safe zone
                                    for _, safe in pairs(workspace:GetDescendants()) do
                                        if safe.Name:lower():find("safe") and safe:IsA("BasePart") then
                                            hrp.CFrame = CFrame.new(safe.Position + Vector3.new(0, 3, 0))
                                            break
                                        end
                                    end
                                end
                                break
                            end
                        end
                    end)
                end
            end
        end)
        
        --==[ NOCLIP ]==--
        spawn(function()
            while task.wait(0.1) do
                if _G.Noclip and Player.Character then
                    for _, part in pairs(Player.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
        
        --==[ Walkspeed Spoof ]==--
        if _G.SpoofSpeed then
            spawn(function()
                while _G.SpoofSpeed do
                    task.wait(1)
                    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                        -- Przywracaj serwerową wartość widoczną
                        Player.Character.Humanoid.WalkSpeed = 16
                    end
                end
            end)
        end
        
        print("✅ " .. Settings.ScriptName .. " v" .. Settings.ScriptVersion .. " załadowany pomyślnie!")
        print("👤 Użytkownik: " .. Player.Name)
        print("🔗 Discord: https://" .. Settings.DiscordInvite)
    end
end)

end) -- koniec pcall

if not success then
    warn("❌ Błąd ładowania skryptu: " .. tostring(err))
    -- Próba ponowna po błędzie
    local errorGui = Instance.new("ScreenGui")
    errorGui.Name = "KALB_Error"
    errorGui.ResetOnSpawn = false
    
    local errorFrame = Instance.new("Frame")
    errorFrame.Size = UDim2.new(0, 400, 0, 150)
    errorFrame.Position = UDim2.new(0.5, -200, 0.5, -75)
    errorFrame.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
    errorFrame.BorderSizePixel = 0
    errorFrame.Parent = errorGui
    
    local errorCorner = Instance.new("UICorner")
    errorCorner.CornerRadius = UDim.new(0, 8)
    errorCorner.Parent = errorFrame
    
    local errorStroke = Instance.new("UIStroke")
    errorStroke.Color = Color3.fromRGB(255, 50, 50)
    errorStroke.Thickness = 1.5
    errorStroke.Parent = errorFrame
    
    local errorTitle = Instance.new("TextLabel")
    errorTitle.Size = UDim2.new(1, -20, 0, 30)
    errorTitle.Position = UDim2.new(0, 10, 0, 10)
    errorTitle.BackgroundTransparency = 1
    errorTitle.TextColor3 = Color3.fromRGB(255, 80, 80)
    errorTitle.Text = "❌ Błąd ładowania skryptu"
    errorTitle.Font = Enum.Font.GothamBold
    errorTitle.TextSize = 16
    errorTitle.Parent = errorFrame
    
    local errorMsg = Instance.new("TextLabel")
    errorMsg.Size = UDim2.new(1, -20, 0, 60)
    errorMsg.Position = UDim2.new(0, 10, 0, 40)
    errorMsg.BackgroundTransparency = 1
    errorMsg.TextColor3 = Color3.fromRGB(200, 200, 200)
    errorMsg.Text = "Wystąpił błąd podczas inicjalizacji.\nSprawdź konsolę (F9) po więcej informacji.\n\nBłąd: " .. tostring(err):sub(1, 100)
    errorMsg.Font = Enum.Font.Gotham
    errorMsg.TextSize = 12
    errorMsg.TextWrapped = true
    errorMsg.Parent = errorFrame
    
    local closeErrBtn = Instance.new("TextButton")
    closeErrBtn.Size = UDim2.new(0, 120, 0, 30)
    closeErrBtn.Position = UDim2.new(0.5, -60, 1, -40)
    closeErrBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeErrBtn.BackgroundTransparency = 0.2
    closeErrBtn.BorderSizePixel = 0
    closeErrBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeErrBtn.Text = "ZAMKNIJ"
    closeErrBtn.Font = Enum.Font.GothamBold
    closeErrBtn.TextSize = 13
    closeErrBtn.Parent = errorFrame
    
    local errBtnCorner = Instance.new("UICorner")
    errBtnCorner.CornerRadius = UDim.new(0, 6)
    errBtnCorner.Parent = closeErrBtn
    
    closeErrBtn.MouseButton1Click:Connect(function()
        errorGui:Destroy()
    end)
    
    pcall(function()
        errorGui.Parent = CoreGui
    end)
    pcall(function()
        errorGui.Parent = Player:FindFirstChild("PlayerGui")
    end)
end
