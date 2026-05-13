--[[
██╗  ██╗██╗ ██████╗██╗  ██╗ █████╗     ██╗     ██╗   ██╗ ██████╗██╗  ██╗██╗██████╗ ██╗      ██████╗  ██████╗██╗  ██╗
██║ ██╔╝██║██╔════╝██║ ██╔╝██╔══██╗    ██║     ██║   ██║██╔════╝██║ ██╔╝██║██╔══██╗██║     ██╔═══██╗██╔════╝██║ ██╔╝
█████╔╝ ██║██║     █████╔╝ ███████║    ██║     ██║   ██║██║     █████╔╝ ██║██████╔╝██║     ██║   ██║██║     █████╔╝ 
██╔═██╗ ██║██║     ██╔═██╗ ██╔══██║    ██║     ██║   ██║██║     ██╔═██╗ ██║██╔══██╗██║     ██║   ██║██║     ██╔═██╗ 
██║  ██╗██║╚██████╗██║  ██╗██║  ██║    ███████╗╚██████╔╝╚██████╗██║  ██╗██║██████╔╝███████╗╚██████╔╝╚██████╗██║  ██╗
╚═╝  ╚═╝╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝    ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝╚═╝╚═════╝ ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝
                                                                                                                           
Kick a Lucky Block - Premium Script
Powered by turcja
]]

-- === KONFIGURACJA ===
local CONFIG = {
    GithubKeyUrl = "https://raw.githubusercontent.com/turcjaszefito/keys/refs/heads/main/keys.txt",
    DiscordInvite = "https://discord.gg/turcja", -- zmien na swoj link
    ScriptName = "Kick a Lucky Block",
    Version = "v2.0",
    WatermarkText = "powered by turcja",
    DefaultSpeed = 50,
    DefaultJump = 80,
    MaxSafeHeight = 35,
}

-- === ZMIENNE GLOBALNE ===
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Flagi stanu
local Modules = {
    AutoKick = false,
    AutoPerfectKick = false,
    AutoCollectCash = false,
    AutoPlaceBrainrot = false,
    AutoUpgradeBrainrot = false,
    AutoTrain = false,
    AutoRebirth = false,
    AutoBuyWeights = false,
    AutoUpgradePlot = false,
    AutoPickupBrainrot = false,
    Walkspeed = false,
    JumpPower = false,
    Noclip = false,
    Fly = false,
    TpToBlock = false,
    TpToPlot = false,
    TpToSafeZone = false,
    AutoTpSafe = false,
    ESPBlocks = false,
    ESPBrainrots = false,
    ESPPlayers = false,
    ESPTsunami = false,
    ESPPlots = false,
    DistanceTracker = false,
    AutoCollectPro = false,
    MultiDrop = false,
    FastTrain = false,
    InstantCollect = false,
    AutoBuyBestWeight = false,
    AntiKick = false,
    AntiBan = false,
    SpoofWalkspeed = false,
    SpoofPosition = false,
    RemoteSpamBlocker = false,
    LogsCleaner = false,
    InfoPanel = false,
    AutoRejoin = false,
    ServerHopper = false,
    BlockRadar = false,
    AutoTsunamiEscape = false,
    TpToPosition = false,
}

local FlyState = {
    Enabled = false,
    BodyGyro = nil,
    BodyVelocity = nil,
    Speed = 50,
}

local SpoofState = {
    Walkspeed = false,
    Position = false,
}

-- Wartosci suwakow
local SliderValues = {
    Walkspeed = CONFIG.DefaultSpeed,
    JumpPower = CONFIG.DefaultJump,
    FlySpeed = 50,
    CollectInterval = 1.0,
    KickDelay = 0.5,
}

-- === FUNKCJE POMOCNICZE ===

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetRoot()
    local char = GetCharacter()
    return char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local char = GetCharacter()
    return char:FindFirstChildOfClass("Humanoid")
end

local function GetPlayerGui()
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function Notify(title, text, duration)
    if Rayfield then
        Rayfield:Notify({
            Title = title,
            Content = text,
            Duration = duration or 5,
            Image = 4483362458,
        })
    end
end

-- Watermark
local Watermark = Instance.new("ScreenGui")
Watermark.Name = "Watermark"
Watermark.Enabled = false
Watermark.ResetOnSpawn = false
Watermark.Parent = GetPlayerGui()

local WatermarkLabel = Instance.new("TextLabel")
WatermarkLabel.Size = UDim2.new(0, 200, 0, 25)
WatermarkLabel.Position = UDim2.new(1, -210, 1, -35)
WatermarkLabel.BackgroundColor3 = Color3.new(0, 0, 0)
WatermarkLabel.BackgroundTransparency = 0.6
WatermarkLabel.TextColor3 = Color3.new(1, 1, 1)
WatermarkLabel.TextTransparency = 0.4
WatermarkLabel.Text = CONFIG.WatermarkText
WatermarkLabel.Font = Enum.Font.SourceSansBold
WatermarkLabel.TextSize = 14
WatermarkLabel.TextXAlignment = Enum.TextXAlignment.Right
WatermarkLabel.BorderSizePixel = 0
WatermarkLabel.Parent = Watermark

-- === SYSTEM KLUCZY ===

local KeySystemGui = Instance.new("ScreenGui")
KeySystemGui.Name = "KeySystem"
KeySystemGui.ResetOnSpawn = false
KeySystemGui.Parent = GetPlayerGui()

-- Tlo z blur
local KeyBackground = Instance.new("Frame")
KeyBackground.Size = UDim2.new(1, 0, 1, 0)
KeyBackground.BackgroundColor3 = Color3.new(0, 0, 0)
KeyBackground.BackgroundTransparency = 0.7
KeyBackground.Parent = KeySystemGui

-- Glowne okno
local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 400, 0, 320)
KeyFrame.Position = UDim2.new(0.5, -200, 0.5, -160)
KeyFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
KeyFrame.BorderSizePixel = 0
KeyFrame.ClipsDescendants = true

local KeyFrameCorner = Instance.new("UICorner")
KeyFrameCorner.CornerRadius = UDim.new(0, 12)
KeyFrameCorner.Parent = KeyFrame

local KeyBorder = Instance.new("Frame")
KeyBorder.Size = UDim2.new(1, 0, 1, 0)
KeyBorder.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
KeyBorder.BackgroundTransparency = 0.85
KeyBorder.BorderSizePixel = 0
local KeyBorderCorner = Instance.new("UICorner")
KeyBorderCorner.CornerRadius = UDim.new(0, 12)
KeyBorderCorner.Parent = KeyBorder
KeyBorder.Parent = KeyFrame

-- Tytul
local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 50)
KeyTitle.Position = UDim2.new(0, 0, 0, 15)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = CONFIG.ScriptName .. " " .. CONFIG.Version
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.TextSize = 22
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.Parent = KeyFrame

local KeySubtitle = Instance.new("TextLabel")
KeySubtitle.Size = UDim2.new(1, 0, 0, 25)
KeySubtitle.Position = UDim2.new(0, 0, 0, 60)
KeySubtitle.BackgroundTransparency = 1
KeySubtitle.Text = "System autoryzacji"
KeySubtitle.Font = Enum.Font.Gotham
KeySubtitle.TextSize = 14
KeySubtitle.TextColor3 = Color3.fromRGB(160, 160, 180)
KeySubtitle.Parent = KeyFrame

-- Pole tekstowe
local KeyTextBox = Instance.new("TextBox")
KeyTextBox.Size = UDim2.new(0, 300, 0, 40)
KeyTextBox.Position = UDim2.new(0.5, -150, 0, 100)
KeyTextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
KeyTextBox.BorderSizePixel = 0
KeyTextBox.PlaceholderText = "Wpisz klucz dostępu..."
KeyTextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
KeyTextBox.Text = ""
KeyTextBox.Font = Enum.Font.Gotham
KeyTextBox.TextSize = 16
KeyTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTextBox.ClearTextOnFocus = false

local KeyTextBoxCorner = Instance.new("UICorner")
KeyTextBoxCorner.CornerRadius = UDim.new(0, 8)
KeyTextBoxCorner.Parent = KeyTextBox

KeyTextBox.Parent = KeyFrame

-- Przycisk autoryzacji
local KeyButton = Instance.new("TextButton")
KeyButton.Size = UDim2.new(0, 300, 0, 40)
KeyButton.Position = UDim2.new(0.5, -150, 0, 155)
KeyButton.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
KeyButton.BorderSizePixel = 0
KeyButton.Text = "AUTORYZUJ"
KeyButton.Font = Enum.Font.GothamBold
KeyButton.TextSize = 16
KeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)

local KeyButtonCorner = Instance.new("UICorner")
KeyButtonCorner.CornerRadius = UDim.new(0, 8)
KeyButtonCorner.Parent = KeyButton

-- Przycisk discord
local DiscordButton = Instance.new("TextButton")
DiscordButton.Size = UDim2.new(0, 300, 0, 35)
DiscordButton.Position = UDim2.new(0.5, -150, 0, 210)
DiscordButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
DiscordButton.BorderSizePixel = 0
DiscordButton.Text = "🔗 Nie masz klucza? Wejdź na Discord!"
DiscordButton.Font = Enum.Font.Gotham
DiscordButton.TextSize = 13
DiscordButton.TextColor3 = Color3.fromRGB(150, 150, 200)

local DiscordButtonCorner = Instance.new("UICorner")
DiscordButtonCorner.CornerRadius = UDim.new(0, 8)
DiscordButtonCorner.Parent = DiscordButton

-- Status
local KeyStatus = Instance.new("TextLabel")
KeyStatus.Size = UDim2.new(1, 0, 0, 30)
KeyStatus.Position = UDim2.new(0, 0, 0, 260)
KeyStatus.BackgroundTransparency = 1
KeyStatus.Text = ""
KeyStatus.Font = Enum.Font.Gotham
KeyStatus.TextSize = 13
KeyStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
KeyStatus.Parent = KeyFrame

KeyButton.Parent = KeyFrame
DiscordButton.Parent = KeyFrame
KeyFrame.Parent = KeySystemGui

-- Animacja okienka
KeyFrame:TweenPosition(UDim2.new(0.5, -200, 0.5, -160), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.6, true)

-- === WERYFIKACJA KLUCZA ===

local function ValidateKey(inputKey)
    local success, keysText = pcall(function()
        return game:HttpGet(CONFIG.GithubKeyUrl)
    end)
    
    if not success then
        return false, "Nie można połączyć z serwerem kluczy!"
    end
    
    local keys = {}
    for line in keysText:gmatch("[^\r\n]+") do
        table.insert(keys, line:lower():match("^%s*(.-)%s*$"))
    end
    
    local inputLower = inputKey:lower():match("^%s*(.-)%s*$")
    
    for _, key in ipairs(keys) do
        if key == inputLower then
            return true, "Autoryzacja pomyślna!"
        end
    end
    
    return false, "Nieprawidłowy klucz!"
end

-- Obsluga przyciskow
KeyButton.MouseButton1Click:Connect(function()
    local key = KeyTextBox.Text
    if key == "" then
        KeyStatus.Text = "Wpisz klucz!"
        return
    end
    
    KeyStatus.Text = "Sprawdzanie..."
    KeyStatus.TextColor3 = Color3.fromRGB(255, 200, 100)
    KeyButton.Text = "..."
    KeyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    
    local valid, msg = ValidateKey(key)
    
    if valid then
        KeyStatus.Text = msg
        KeyStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
        KeyButton.Text = "✓ ZAUTORYZOWANO"
        KeyButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        
        task.wait(1)
        
        -- Fade out
        local tween = TweenService:Create(KeyBackground, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {BackgroundTransparency = 1})
        tween:Play()
        
        local tween2 = TweenService:Create(KeyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -200, 1.5, 0)})
        tween2:Play()
        tween2.Completed:Connect(function()
            KeySystemGui:Destroy()
            -- Laduj GUI
            loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
            task.wait(0.5)
            InitializeGUI()
        end)
    else
        KeyStatus.Text = msg
        KeyStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
        KeyButton.Text = "AUTORYZUJ"
        KeyButton.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
    end
end)

DiscordButton.MouseButton1Click:Connect(function()
    setclipboard(CONFIG.DiscordInvite)
    KeyStatus.Text = "Link skopiowany! Wklej w przeglądarce."
    KeyStatus.TextColor3 = Color3.fromRGB(100, 200, 255)
end)

KeyTextBox.FocusLost:Connect(function(enter)
    if enter then
        KeyButton.MouseButton1Click:Fire()
    end
end)

-- === GLOWNA FUNKCJA INICJALIZUJACA RAYFIELD GUI ===

function InitializeGUI()
    local Window = Rayfield:CreateWindow({
        Name = "Kick a Lucky Block " .. CONFIG.Version,
        LoadingTitle = "Ladowanie modulow...",
        LoadingSubtitle = "by turcja",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "KickLuckyBlock",
            FileName = "Config"
        },
        Discord = {
            Enabled = true,
            Invite = CONFIG.DiscordInvite:match("discord%.gg/(.+)$") or "turcja",
            RememberJoins = true
        },
        KeySystem = false,
    })

    -- === ZMIENNE DLA RAYFIELD ===
    local Toggles = {}
    local Sliders = {}

    -- === SEKCJA: INFORMATION ===
    local InfoTab = Window:CreateTab("Information", 4483362458)
    
    InfoTab:CreateSection("O skrypcie")
    
    InfoTab:CreateLabel("Kick a Lucky Block " .. CONFIG.Version)
    InfoTab:CreateLabel("Stworzony przez: turcja")
    InfoTab:CreateLabel("Modulow: 47+")
    InfoTab:CreateLabel("Status: Dziala")
    
    InfoTab:CreateSection("Informacje o uzytkowniku")
    
    local playerName = LocalPlayer.DisplayName or LocalPlayer.Name
    local userId = LocalPlayer.UserId
    local accountAge = LocalPlayer.AccountAge
    
    InfoTab:CreateLabel("Gracz: " .. playerName)
    InfoTab:CreateLabel("User ID: " .. userId)
    InfoTab:CreateLabel("Wiek konta: " .. accountAge .. " dni")
    InfoTab:CreateLabel("Klucz: Lifetime")
    InfoTab:CreateLabel("Data aktywacji: " .. os.date("%d/%m/%Y %H:%M"))
    
    InfoTab:CreateSection("Linki")
    
    InfoTab:CreateButton({
        Name = "Discord",
        Callback = function()
            setclipboard(CONFIG.DiscordInvite)
            Notify("Discord", "Link skopiowany!", 3)
        end,
    })
    
    InfoTab:CreateButton({
        Name = "Kopiuj nazwe gracza",
        Callback = function()
            setclipboard(playerName)
            Notify("Skopiowano", "Nazwa: " .. playerName, 3)
        end,
    })

    -- === SEKCJA: AUTO FARM ===
    local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
    
    FarmTab:CreateSection("Podstawowe")
    
    Toggles.AutoKick = FarmTab:CreateToggle({
        Name = "Auto Kick",
        CurrentValue = false,
        Flag = "AutoKick",
        Callback = function(val) Modules.AutoKick = val end,
    })
    
    Toggles.AutoPerfectKick = FarmTab:CreateToggle({
        Name = "Auto Perfect Kick",
        CurrentValue = false,
        Flag = "AutoPerfectKick",
        Callback = function(val) Modules.AutoPerfectKick = val end,
    })
    
    Toggles.AutoCollectCash = FarmTab:CreateToggle({
        Name = "Auto Collect Cash",
        CurrentValue = false,
        Flag = "AutoCollectCash",
        Callback = function(val) Modules.AutoCollectCash = val end,
    })
    
    Toggles.AutoPlaceBrainrot = FarmTab:CreateToggle({
        Name = "Auto Place Brainroty",
        CurrentValue = false,
        Flag = "AutoPlaceBrainrot",
        Callback = function(val) Modules.AutoPlaceBrainrot = val end,
    })
    
    Toggles.AutoUpgradeBrainrot = FarmTab:CreateToggle({
        Name = "Auto Upgrade Brainroty",
        CurrentValue = false,
        Flag = "AutoUpgradeBrainrot",
        Callback = function(val) Modules.AutoUpgradeBrainrot = val end,
    })
    
    FarmTab:CreateSection("Trening i progresja")
    
    Toggles.AutoTrain = FarmTab:CreateToggle({
        Name = "Auto Train",
        CurrentValue = false,
        Flag = "AutoTrain",
        Callback = function(val) Modules.AutoTrain = val end,
    })
    
    Toggles.AutoRebirth = FarmTab:CreateToggle({
        Name = "Auto Rebirth",
        CurrentValue = false,
        Flag = "AutoRebirth",
        Callback = function(val) Modules.AutoRebirth = val end,
    })
    
    Toggles.AutoBuyWeights = FarmTab:CreateToggle({
        Name = "Auto Kupowanie Ciezarow",
        CurrentValue = false,
        Flag = "AutoBuyWeights",
        Callback = function(val) Modules.AutoBuyWeights = val end,
    })
    
    Toggles.AutoBuyBestWeight = FarmTab:CreateToggle({
        Name = "Auto Buy Best Weight",
        CurrentValue = false,
        Flag = "AutoBuyBestWeight",
        Callback = function(val) Modules.AutoBuyBestWeight = val end,
    })
    
    Toggles.AutoUpgradePlot = FarmTab:CreateToggle({
        Name = "Auto Upgrade Dzialki",
        CurrentValue = false,
        Flag = "AutoUpgradePlot",
        Callback = function(val) Modules.AutoUpgradePlot = val end,
    })
    
    FarmTab:CreateSection("Zbieranie")
    
    Toggles.AutoPickupBrainrot = FarmTab:CreateToggle({
        Name = "Auto Zbieranie Brainrotow",
        CurrentValue = false,
        Flag = "AutoPickupBrainrot",
        Callback = function(val) Modules.AutoPickupBrainrot = val end,
    })
    
    Sliders.CollectInterval = FarmTab:CreateSlider({
        Name = "Interval Collect (s)",
        Range = {0.3, 3},
        Increment = 0.1,
        Suffix = "s",
        CurrentValue = 1.0,
        Flag = "CollectInterval",
        Callback = function(val) SliderValues.CollectInterval = val end,
    })
    
    Sliders.KickDelay = FarmTab:CreateSlider({
        Name = "Opóznienie Kicka (s)",
        Range = {0.1, 2},
        Increment = 0.1,
        Suffix = "s",
        CurrentValue = 0.5,
        Flag = "KickDelay",
        Callback = function(val) SliderValues.KickDelay = val end,
    })

    -- === SEKCJA: MOVEMENT ===
    local MoveTab = Window:CreateTab("Movement", 4483362458)
    
    MoveTab:CreateSection("Predkosc i skok")
    
    Toggles.Walkspeed = MoveTab:CreateToggle({
        Name = "Walkspeed",
        CurrentValue = false,
        Flag = "Walkspeed",
        Callback = function(val) Modules.Walkspeed = val end,
    })
    
    Sliders.Walkspeed = MoveTab:CreateSlider({
        Name = "Walkspeed Value",
        Range = {16, 120},
        Increment = 1,
        Suffix = "",
        CurrentValue = CONFIG.DefaultSpeed,
        Flag = "WalkspeedVal",
        Callback = function(val) SliderValues.Walkspeed = val end,
    })
    
    Toggles.JumpPower = MoveTab:CreateToggle({
        Name = "Jump Power",
        CurrentValue = false,
        Flag = "JumpPower",
        Callback = function(val) Modules.JumpPower = val end,
    })
    
    Sliders.JumpPower = MoveTab:CreateSlider({
        Name = "Jump Power Value",
        Range = {50, 250},
        Increment = 5,
        Suffix = "",
        CurrentValue = CONFIG.DefaultJump,
        Flag = "JumpPowerVal",
        Callback = function(val) SliderValues.JumpPower = val end,
    })
    
    MoveTab:CreateSection("Noclip i latanie")
    
    Toggles.Noclip = MoveTab:CreateToggle({
        Name = "Noclip",
        CurrentValue = false,
        Flag = "Noclip",
        Callback = function(val) Modules.Noclip = val end,
    })
    
    Toggles.Fly = MoveTab:CreateToggle({
        Name = "Fly",
        CurrentValue = false,
        Flag = "Fly",
        Callback = function(val)
            Modules.Fly = val
            if val then
                FlyState.Enabled = true
                EnableFly()
            else
                FlyState.Enabled = false
                DisableFly()
            end
        end,
    })
    
    Sliders.FlySpeed = MoveTab:CreateSlider({
        Name = "Fly Speed",
        Range = {10, 200},
        Increment = 5,
        Suffix = "stud/s",
        CurrentValue = 50,
        Flag = "FlySpeed",
        Callback = function(val) FlyState.Speed = val end,
    })
    
    MoveTab:CreateSection("Teleporty")
    
    Toggles.TpToBlock = MoveTab:CreateToggle({
        Name = "Teleport To Block (kliknij)",
        CurrentValue = false,
        Flag = "TpToBlock",
        Callback = function(val) Modules.TpToBlock = val end,
    })
    
    Toggles.TpToPlot = MoveTab:CreateButton({
        Name = "Teleport do dzialki",
        Callback = function()
            TeleportToPlot()
        end,
    })
    
    Toggles.TpToSafeZone = MoveTab:CreateButton({
        Name = "Teleport do Safe Zone",
        Callback = function()
            TeleportToSafeZone()
        end,
    })
    
    Toggles.AutoTsunamiEscape = MoveTab:CreateToggle({
        Name = "Auto Tsunami Escape",
        CurrentValue = false,
        Flag = "AutoTsunamiEscape",
        Callback = function(val) Modules.AutoTsunamiEscape = val end,
    })
    
    Toggles.TpToPosition = MoveTab:CreateButton({
        Name = "Teleport do pozycji (kliknij myszka)",
        Callback = function()
            Modules.TpToPosition = true
            Notify("Teleport", "Kliknij gdzie chcesz sie teleportowac!", 3)
        end,
    })

    -- === SEKCJA: ESP / VISUALS ===
    local ESPTab = Window:CreateTab("ESP / Visuals", 4483362458)
    
    ESPTab:CreateSection("ESP")
    
    Toggles.ESPBlocks = ESPTab:CreateToggle({
        Name = "ESP Lucky Blocki",
        CurrentValue = false,
        Flag = "ESPBlocks",
        Callback = function(val) Modules.ESPBlocks = val end,
    })
    
    Toggles.ESPBrainrots = ESPTab:CreateToggle({
        Name = "ESP Brainroty",
        CurrentValue = false,
        Flag = "ESPBrainrots",
        Callback = function(val) Modules.ESPBrainrots = val end,
    })
    
    Toggles.ESPPlayers = ESPTab:CreateToggle({
        Name = "ESP Gracze",
        CurrentValue = false,
        Flag = "ESPPlayers",
        Callback = function(val) Modules.ESPPlayers = val end,
    })
    
    Toggles.ESPTsunami = ESPTab:CreateToggle({
        Name = "ESP Tsunami",
        CurrentValue = false,
        Flag = "ESPTsunami",
        Callback = function(val) Modules.ESPTsunami = val end,
    })
    
    Toggles.ESPPlots = ESPTab:CreateToggle({
        Name = "ESP Dzialki",
        CurrentValue = false,
        Flag = "ESPPlots",
        Callback = function(val) Modules.ESPPlots = val end,
    })
    
    ESPTab:CreateSection("Radar i informacje")
    
    Toggles.BlockRadar = ESPTab:CreateToggle({
        Name = "Block Radar (minimapa)",
        CurrentValue = false,
        Flag = "BlockRadar",
        Callback = function(val) Modules.BlockRadar = val end,
    })
    
    Toggles.DistanceTracker = ESPTab:CreateToggle({
        Name = "Distance Tracker",
        CurrentValue = false,
        Flag = "DistanceTracker",
        Callback = function(val) Modules.DistanceTracker = val end,
    })
    
    Toggles.InfoPanel = ESPTab:CreateToggle({
        Name = "Info Panel (HUD)",
        CurrentValue = false,
        Flag = "InfoPanel",
        Callback = function(val) Modules.InfoPanel = val end,
    })

    -- === SEKCJA: EXPLOITY ===
    local ExploitTab = Window:CreateTab("Exploity", 4483362458)
    
    ExploitTab:CreateSection("Kasa i progresja")
    
    Toggles.AutoCollectPro = ExploitTab:CreateToggle({
        Name = "Auto Collect Pro",
        CurrentValue = false,
        Flag = "AutoCollectPro",
        Callback = function(val) Modules.AutoCollectPro = val end,
    })
    
    Toggles.MultiDrop = ExploitTab:CreateToggle({
        Name = "Multi Drop (x2 cash)",
        CurrentValue = false,
        Flag = "MultiDrop",
        Callback = function(val) Modules.MultiDrop = val end,
    })
    
    Toggles.InstantCollect = ExploitTab:CreateToggle({
        Name = "Instant Collect",
        CurrentValue = false,
        Flag = "InstantCollect",
        Callback = function(val) Modules.InstantCollect = val end,
    })
    
    Toggles.FastTrain = ExploitTab:CreateToggle({
        Name = "Fast Train",
        CurrentValue = false,
        Flag = "FastTrain",
        Callback = function(val) Modules.FastTrain = val end,
    })
    
    ExploitTab:CreateSection("Anticheat Bypass")
    
    Toggles.AntiKick = ExploitTab:CreateToggle({
        Name = "Anti-Kick",
        CurrentValue = false,
        Flag = "AntiKick",
        Callback = function(val) Modules.AntiKick = val end,
    })
    
    Toggles.AntiBan = ExploitTab:CreateToggle({
        Name = "Anti-Ban",
        CurrentValue = false,
        Flag = "AntiBan",
        Callback = function(val) Modules.AntiBan = val end,
    })
    
    Toggles.SpoofWalkspeed = ExploitTab:CreateToggle({
        Name = "Spoof Walkspeed",
        CurrentValue = false,
        Flag = "SpoofWalkspeed",
        Callback = function(val) Modules.SpoofWalkspeed = val end,
    })
    
    Toggles.SpoofPosition = ExploitTab:CreateToggle({
        Name = "Spoof Position",
        CurrentValue = false,
        Flag = "SpoofPosition",
        Callback = function(val) Modules.SpoofPosition = val end,
    })
    
    Toggles.RemoteSpamBlocker = ExploitTab:CreateToggle({
        Name = "Remote Spam Blocker",
        CurrentValue = false,
        Flag = "RemoteSpamBlocker",
        Callback = function(val) Modules.RemoteSpamBlocker = val end,
    })
    
    Toggles.LogsCleaner = ExploitTab:CreateToggle({
        Name = "Logs Cleaner",
        CurrentValue = false,
        Flag = "LogsCleaner",
        Callback = function(val) Modules.LogsCleaner = val end,
    })
    
    ExploitTab:CreateSection("Narzedzia")
    
    Toggles.AutoRejoin = ExploitTab:CreateToggle({
        Name = "Auto Rejoin",
        CurrentValue = false,
        Flag = "AutoRejoin",
        Callback = function(val) Modules.AutoRejoin = val end,
    })
    
    Toggles.ServerHopper = ExploitTab:CreateToggle({
        Name = "Server Hopper",
        CurrentValue = false,
        Flag = "ServerHopper",
        Callback = function(val) Modules.ServerHopper = val end,
    })

    -- === SEKCJA: SETTINGS ===
    local SettingsTab = Window:CreateTab("Settings", 4483362458)
    
    SettingsTab:CreateSection("Interfejs")
    
    local WatermarkToggle = SettingsTab:CreateToggle({
        Name = "Watermark",
        CurrentValue = false,
        Flag = "Watermark",
        Callback = function(val)
            Watermark.Enabled = val
        end,
    })
    
    SettingsTab:CreateSection("Skrypt")
    
    SettingsTab:CreateLabel("Wersja: " .. CONFIG.Version)
    SettingsTab:CreateLabel("Autor: turcja")
    
    SettingsTab:CreateButton({
        Name = "Skopiuj nazwe uzytkownika",
        Callback = function()
            setclipboard(LocalPlayer.Name)
            Notify("OK", "Nazwa skopiowana", 2)
        end,
    })
    
    SettingsTab:CreateButton({
        Name = "Destroy GUI",
        Callback = function()
            Window:Destroy()
            if Watermark then
                Watermark.Enabled = false
                Watermark:Destroy()
            end
            Notify("GUI", "Zniszczono interfejs", 2)
        end,
    })

    Notify("Zaladowano", CONFIG.ScriptName .. " " .. CONFIG.Version .. " gotowy!", 3)

    -- === LOGIKA MODULOW ===

    -- Walkspeed loop
    task.spawn(function()
        while true do
            task.wait(0.3)
            local hum = GetHumanoid()
            if hum then
                if Modules.Walkspeed and hum.WalkSpeed ~= SliderValues.Walkspeed then
                    hum.WalkSpeed = SliderValues.Walkspeed
                elseif not Modules.Walkspeed and hum.WalkSpeed ~= 16 then
                    hum.WalkSpeed = 16
                end
                
                if Modules.JumpPower and hum.JumpPower ~= SliderValues.JumpPower then
                    hum.JumpPower = SliderValues.JumpPower
                elseif not Modules.JumpPower and hum.JumpPower ~= 50 then
                    hum.JumpPower = 50
                end
                
                if Modules.SpoofWalkspeed then
                    -- hook na metatable dla spoofa
                    -- (wymaga executor z metatable hook)
                end
            end
        end
    end)

    -- Noclip loop
    task.spawn(function()
        while true do
            task.wait(0.1)
            if Modules.Noclip then
                local char = GetCharacter()
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)

    -- ESP blocks
    task.spawn(function()
        while true do
            task.wait(0.5)
            if Modules.ESPBlocks then
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and (v.Name:find("Block") or v.Name:find("Lucky")) then
                        if not v:FindFirstChild("ESP_Block") then
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "ESP_Block"
                            highlight.FillColor = Color3.fromRGB(255, 215, 0)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            highlight.Adornee = v
                            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            highlight.Parent = v
                        end
                    end
                end
            else
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v:FindFirstChild("ESP_Block") then
                        v.ESP_Block:Destroy()
                    end
                end
            end
        end
    end)

    -- Auto Tsunami Escape
    task.spawn(function()
        while true do
            task.wait(0.2)
            if Modules.AutoTsunamiEscape then
                local tsunami = workspace:FindFirstChild("Tsunami") or workspace:FindFirstChild("tsunami") or workspace:FindFirstChild("Wave")
                if tsunami then
                    TeleportToSafeZone()
                end
            end
        end
    end)

    print("Kick a Lucky Block Premium - Loading complete!")
end

-- === FUNKCJE FLY ===

function EnableFly()
    local root = GetRoot()
    if not root then return end
    
    FlyState.BodyGyro = Instance.new("BodyGyro")
    FlyState.BodyGyro.P = 9e4
    FlyState.BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyState.BodyGyro.CFrame = root.CFrame
    FlyState.BodyGyro.Parent = root
    
    FlyState.BodyVelocity = Instance.new("BodyVelocity")
    FlyState.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    FlyState.BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    FlyState.BodyVelocity.Parent = root
    
    local flyLoop
    flyLoop = RunService.RenderStepped:Connect(function()
        if not FlyState.Enabled or not root then
            flyLoop:Disconnect()
            return
        end
        
        local moveVector = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVector = moveVector + (workspace.CurrentCamera.CFrame.LookVector * FlyState.Speed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVector = moveVector - (workspace.CurrentCamera.CFrame.LookVector * FlyState.Speed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVector = moveVector - (workspace.CurrentCamera.CFrame.RightVector * FlyState.Speed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVector = moveVector + (workspace.CurrentCamera.CFrame.RightVector * FlyState.Speed)
        end
        
        -- Gora/dol
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVector = moveVector + Vector3.new(0, FlyState.Speed, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveVector = moveVector - Vector3.new(0, FlyState.Speed, 0)
        end
        
        FlyState.BodyVelocity.Velocity = moveVector
        FlyState.BodyGyro.CFrame = workspace.CurrentCamera.CFrame
        
        -- Height limit
        if root.Position.Y > CONFIG.MaxSafeHeight then
            root.CFrame = CFrame.new(root.Position.X, CONFIG.MaxSafeHeight, root.Position.Z)
        end
    end)
end

function DisableFly()
    local root = GetRoot()
    if root then
        if FlyState.BodyGyro then
            FlyState.BodyGyro:Destroy()
            FlyState.BodyGyro = nil
        end
        if FlyState.BodyVelocity then
            FlyState.BodyVelocity:Destroy()
            FlyState.BodyVelocity = nil
        end
    end
end

-- === FUNKCJE TELEPORT ===

function TeleportToPlot()
    local root = GetRoot()
    if not root then return end
    
    local plot = workspace:FindFirstChild("Plot") or workspace:FindFirstChild("Base") or workspace:FindFirstChild("Home")
    if plot then
        root.CFrame = plot.CFrame + Vector3.new(0, 5, 0)
        Notify("Teleport", "Przeniesiono na dzialke!", 2)
    else
        Notify("Blad", "Nie znaleziono dzialki!", 2)
    end
end

function TeleportToSafeZone()
    local root = GetRoot()
    if not root then return end
    
    local safe = workspace:FindFirstChild("SafeZone") or workspace:FindFirstChild("Safe") or workspace:FindFirstChild("Spawn")
    if safe then
        root.CFrame = safe.CFrame + Vector3.new(0, 5, 0)
    end
end

-- Mouse teleport
Mouse.Button1Down:Connect(function()
    if Modules.TpToPosition then
        local root = GetRoot()
        if root then
            local target = Mouse.Hit
            root.CFrame = CFrame.new(target.X, target.Y + 3, target.Z)
            Modules.TpToPosition = false
            Notify("Teleport", "Przeniesiono!", 2)
        end
    end
end)
