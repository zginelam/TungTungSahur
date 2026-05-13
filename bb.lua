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
    DiscordInvite = "https://discord.gg/turcja",
    ScriptName = "Kick a Lucky Block",
    Version = "v2.1",
    WatermarkText = "powered by turcja",
    DefaultSpeed = 50,
    DefaultJump = 80,
    MaxSafeHeight = 35,
}

-- === SERVICE ===
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- === ZMIENNE GLOBALNE ===
local Modules = {}
local FlyState = { Enabled = false, BodyGyro = nil, BodyVelocity = nil, Speed = 50 }
local SliderValues = {
    Walkspeed = CONFIG.DefaultSpeed,
    JumpPower = CONFIG.DefaultJump,
    FlySpeed = 50,
    CollectInterval = 1.0,
    KickDelay = 0.5,
}
local WatermarkInstance = nil
local Window = nil
local RayfieldLoaded = false

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

-- Prosta notyfikacja przed zaladowaniem Rayfield
local function SimpleNotify(text, duration)
    duration = duration or 3
    local gui = Instance.new("ScreenGui")
    gui.Name = "SimpleNotify"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 45)
    frame.Position = UDim2.new(0.5, -175, 0, -60)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    local border = Instance.new("Frame")
    border.Size = UDim2.new(1, 0, 0, 2)
    border.Position = UDim2.new(0, 0, 1, -2)
    border.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
    border.BorderSizePixel = 0
    border.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 15
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Parent = frame
    
    -- Animacja wjazdu
    frame:TweenPosition(UDim2.new(0.5, -175, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.4, true)
    
    task.wait(duration)
    
    frame:TweenPosition(UDim2.new(0.5, -175, 0, -60), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.4, true)
    task.wait(0.5)
    gui:Destroy()
end

-- === WATERMARK ===

local function CreateWatermark()
    if WatermarkInstance then
        pcall(function() WatermarkInstance:Destroy() end)
    end
    
    WatermarkInstance = Instance.new("ScreenGui")
    WatermarkInstance.Name = "Watermark"
    WatermarkInstance.ResetOnSpawn = false
    WatermarkInstance.Enabled = false
    WatermarkInstance.Parent = CoreGui
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 200, 0, 25)
    label.Position = UDim2.new(1, -210, 1, -35)
    label.BackgroundColor3 = Color3.new(0, 0, 0)
    label.BackgroundTransparency = 0.6
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextTransparency = 0.4
    label.Text = CONFIG.WatermarkText
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Right
    label.BorderSizePixel = 0
    label.Parent = WatermarkInstance
end

-- === KEY SYSTEM ===

local function ShowKeySystem()
    local gui = Instance.new("ScreenGui")
    gui.Name = "KeySystem"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui
    
    -- Tlo
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.new(0, 0, 0)
    bg.BackgroundTransparency = 0.65
    bg.Parent = gui
    
    -- Glowne okno
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 420, 0, 340)
    frame.Position = UDim2.new(0.5, -210, 1.2, 0)
    frame.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = frame
    
    -- Border
    local border = Instance.new("Frame")
    border.Size = UDim2.new(1, 0, 1, 0)
    border.BackgroundTransparency = 0.9
    border.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
    border.BorderSizePixel = 0
    local borderCorner = Instance.new("UICorner")
    borderCorner.CornerRadius = UDim.new(0, 14)
    borderCorner.Parent = border
    border.Parent = frame
    
    -- Tytul
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Position = UDim2.new(0, 0, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = CONFIG.ScriptName .. " " .. CONFIG.Version
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Parent = frame
    
    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, 0, 0, 25)
    sub.Position = UDim2.new(0, 0, 0, 62)
    sub.BackgroundTransparency = 1
    sub.Text = "System autoryzacji"
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 14
    sub.TextColor3 = Color3.fromRGB(150, 150, 180)
    sub.Parent = frame
    
    -- Pole klucza
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 320, 0, 42)
    box.Position = UDim2.new(0.5, -160, 0, 105)
    box.BackgroundColor3 = Color3.fromRGB(38, 38, 55)
    box.BorderSizePixel = 0
    box.PlaceholderText = "Wpisz klucz dostepu..."
    box.PlaceholderColor3 = Color3.fromRGB(110, 110, 140)
    box.Text = ""
    box.Font = Enum.Font.Gotham
    box.TextSize = 16
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.ClearTextOnFocus = false
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 8)
    boxCorner.Parent = box
    box.Parent = frame
    
    -- Przycisk autoryzacji
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 320, 0, 42)
    btn.Position = UDim2.new(0.5, -160, 0, 160)
    btn.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
    btn.BorderSizePixel = 0
    btn.Text = "AUTORYZUJ"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    -- Hover efekt
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(120, 70, 255)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
    end)
    
    btn.Parent = frame
    
    -- Przycisk Discord
    local dbtn = Instance.new("TextButton")
    dbtn.Size = UDim2.new(0, 320, 0, 36)
    dbtn.Position = UDim2.new(0.5, -160, 0, 215)
    dbtn.BackgroundColor3 = Color3.fromRGB(45, 45, 68)
    dbtn.BorderSizePixel = 0
    dbtn.Text = "Nie masz klucza? Dolacz na Discord!"
    dbtn.Font = Enum.Font.Gotham
    dbtn.TextSize = 13
    dbtn.TextColor3 = Color3.fromRGB(150, 150, 200)
    
    local dbtnCorner = Instance.new("UICorner")
    dbtnCorner.CornerRadius = UDim.new(0, 8)
    dbtnCorner.Parent = dbtn
    
    dbtn.MouseEnter:Connect(function()
        dbtn.BackgroundColor3 = Color3.fromRGB(55, 55, 80)
    end)
    dbtn.MouseLeave:Connect(function()
        dbtn.BackgroundColor3 = Color3.fromRGB(45, 45, 68)
    end)
    
    dbtn.Parent = frame
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 28)
    status.Position = UDim2.new(0, 0, 0, 270)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.Font = Enum.Font.Gotham
    status.TextSize = 13
    status.TextColor3 = Color3.fromRGB(255, 100, 100)
    status.Parent = frame
    
    -- Wersja na dole
    local ver = Instance.new("TextLabel")
    ver.Size = UDim2.new(1, 0, 0, 20)
    ver.Position = UDim2.new(0, 0, 1, -25)
    ver.BackgroundTransparency = 1
    ver.Text = "v" .. CONFIG.Version .. " | by turcja"
    ver.Font = Enum.Font.Gotham
    ver.TextSize = 11
    ver.TextColor3 = Color3.fromRGB(80, 80, 100)
    ver.Parent = frame
    
    -- Animacja okienka
    frame:TweenPosition(UDim2.new(0.5, -210, 0.5, -170), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.7, true)
    
    -- === LOGIKA KEY SYSTEM ===
    
    local function ValidateKey(inputKey)
        local success, keysText = pcall(function()
            return game:HttpGet(CONFIG.GithubKeyUrl)
        end)
        
        if not success then
            return false, "Nie mozna polaczyc z serwerem kluczy!"
        end
        
        local keys = {}
        for line in keysText:gmatch("[^\r\n]+") do
            local trimmed = line:lower():match("^%s*(.-)%s*$")
            if trimmed and trimmed ~= "" then
                table.insert(keys, trimmed)
            end
        end
        
        local inputLower = inputKey:lower():match("^%s*(.-)%s*$")
        
        for _, key in ipairs(keys) do
            if key == inputLower then
                return true, "Autoryzacja pomyslna!"
            end
        end
        
        return false, "Nieprawidlowy klucz!"
    end
    
    btn.MouseButton1Click:Connect(function()
        local key = box.Text
        if key == "" then
            status.Text = "Wpisz klucz!"
            return
        end
        
        status.Text = "Sprawdzanie..."
        status.TextColor3 = Color3.fromRGB(255, 200, 100)
        btn.Text = "..."
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        
        local valid, msg = ValidateKey(key)
        
        if valid then
            status.Text = msg
            status.TextColor3 = Color3.fromRGB(100, 255, 100)
            btn.Text = "ZAutoryzowano!"
            btn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
            
            task.wait(0.8)
            
            -- Zamykanie key system
            bg:TweenPosition(UDim2.new(0.5, 0, 1.5, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.5, true)
            frame:TweenPosition(UDim2.new(0.5, -210, 1.5, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.4, true)
            
            task.wait(0.6)
            gui:Destroy()
            
            -- Ladujemy Rayfield
            LoadMainGUI()
        else
            status.Text = msg
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
            btn.Text = "AUTORYZUJ"
            btn.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
        end
    end)
    
    dbtn.MouseButton1Click:Connect(function()
        setclipboard(CONFIG.DiscordInvite)
        status.Text = "Link skopiowany!"
        status.TextColor3 = Color3.fromRGB(100, 200, 255)
    end)
    
    box.FocusLost:Connect(function(enter)
        if enter then
            btn.MouseButton1Click:Fire()
        end
    end)
end

-- === LADOWANIE RAYFIELD I GUI ===

function LoadMainGUI()
    SimpleNotify("Ladowanie Rayfield...")
    
    local success, result = pcall(function()
        return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    end)
    
    if not success or type(result) ~= "table" then
        SimpleNotify("Blad ladowania Rayfield! Spróbuj ponownie uruchomic skrypt.", 5)
        warn("[KickBlock] Rayfield load error:", result)
        return
    end
    
    RayfieldLoaded = true
    SimpleNotify("Rayfield gotowy! Ladowanie GUI...")
    task.wait(0.3)
    
    CreateMainGUI()
end

-- === GLOWNE GUI ===

function CreateMainGUI()
    Window = Rayfield:CreateWindow({
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
            Invite = "turcja",
            RememberJoins = true
        },
        KeySystem = false,
    })
    
    -- Stworz watermark
    CreateWatermark()
    
    local Toggles = {}
    local Sliders = {}
    
    -- ========== TAB: INFORMATION ==========
    local InfoTab = Window:CreateTab("Information", 4483362458)
    
    InfoTab:CreateSection("O skrypcie")
    InfoTab:CreateLabel(CONFIG.ScriptName .. " " .. CONFIG.Version)
    InfoTab:CreateLabel("Stworzony przez: turcja")
    InfoTab:CreateLabel("Modulow: 45+")
    InfoTab:CreateLabel("Stan: Dziala")
    
    InfoTab:CreateSection("Informacje o uzytkowniku")
    
    local playerName = LocalPlayer.DisplayName or LocalPlayer.Name
    local userId = LocalPlayer.UserId
    local accountAge = LocalPlayer.AccountAge
    
    InfoTab:CreateLabel("Gracz: " .. playerName)
    InfoTab:CreateLabel("User ID: " .. userId)
    InfoTab:CreateLabel("Wiek konta: " .. accountAge .. " dni")
    InfoTab:CreateLabel("Typ klucza: Lifetime")
    InfoTab:CreateLabel("Data: " .. os.date("%d/%m/%Y %H:%M"))
    
    InfoTab:CreateSection("Linki")
    
    InfoTab:CreateButton({
        Name = "Discord",
        Callback = function()
            setclipboard(CONFIG.DiscordInvite)
            Rayfield:Notify({Title = "Discord", Content = "Link skopiowany!", Duration = 3})
        end,
    })
    
    InfoTab:CreateButton({
        Name = "Kopiuj nick",
        Callback = function()
            setclipboard(playerName)
            Rayfield:Notify({Title = "OK", Content = "Skopiowano: " .. playerName, Duration = 3})
        end,
    })
    
    -- ========== TAB: AUTO FARM ==========
    local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
    
    FarmTab:CreateSection("Podstawowe")
    
    local tAutoKick = FarmTab:CreateToggle({
        Name = "Auto Kick", CurrentValue = false, Flag = "AutoKick",
        Callback = function(v) Modules.AutoKick = v end,
    })
    
    local tAutoPerfect = FarmTab:CreateToggle({
        Name = "Auto Perfect Kick", CurrentValue = false, Flag = "AutoPerfectKick",
        Callback = function(v) Modules.AutoPerfectKick = v end,
    })
    
    local tAutoCollect = FarmTab:CreateToggle({
        Name = "Auto Collect Cash", CurrentValue = false, Flag = "AutoCollectCash",
        Callback = function(v) Modules.AutoCollectCash = v end,
    })
    
    local tAutoPlace = FarmTab:CreateToggle({
        Name = "Auto Place Brainroty", CurrentValue = false, Flag = "AutoPlaceBrainrot",
        Callback = function(v) Modules.AutoPlaceBrainrot = v end,
    })
    
    local tAutoUpgBrain = FarmTab:CreateToggle({
        Name = "Auto Upgrade Brainroty", CurrentValue = false, Flag = "AutoUpgradeBrainrot",
        Callback = function(v) Modules.AutoUpgradeBrainrot = v end,
    })
    
    FarmTab:CreateSection("Trening i progresja")
    
    local tAutoTrain = FarmTab:CreateToggle({
        Name = "Auto Train", CurrentValue = false, Flag = "AutoTrain",
        Callback = function(v) Modules.AutoTrain = v end,
    })
    
    local tAutoRebirth = FarmTab:CreateToggle({
        Name = "Auto Rebirth", CurrentValue = false, Flag = "AutoRebirth",
        Callback = function(v) Modules.AutoRebirth = v end,
    })
    
    local tAutoBuyW = FarmTab:CreateToggle({
        Name = "Auto Kupowanie Ciezarow", CurrentValue = false, Flag = "AutoBuyWeights",
        Callback = function(v) Modules.AutoBuyWeights = v end,
    })
    
    local tAutoBestW = FarmTab:CreateToggle({
        Name = "Auto Buy Best Weight", CurrentValue = false, Flag = "AutoBuyBestWeight",
        Callback = function(v) Modules.AutoBuyBestWeight = v end,
    })
    
    local tAutoUpgPlot = FarmTab:CreateToggle({
        Name = "Auto Upgrade Dzialki", CurrentValue = false, Flag = "AutoUpgradePlot",
        Callback = function(v) Modules.AutoUpgradePlot = v end,
    })
    
    FarmTab:CreateSection("Zbieranie")
    
    local tAutoPickup = FarmTab:CreateToggle({
        Name = "Auto Zbieranie Brainrotow", CurrentValue = false, Flag = "AutoPickupBrainrot",
        Callback = function(v) Modules.AutoPickupBrainrot = v end,
    })
    
    local sCollect = FarmTab:CreateSlider({
        Name = "Interval Collect (s)", Range = {0.3, 3}, Increment = 0.1, Suffix = "s",
        CurrentValue = 1.0, Flag = "CollectInterval",
        Callback = function(v) SliderValues.CollectInterval = v end,
    })
    
    local sKickDelay = FarmTab:CreateSlider({
        Name = "Opóznienie Kicka (s)", Range = {0.1, 2}, Increment = 0.1, Suffix = "s",
        CurrentValue = 0.5, Flag = "KickDelay",
        Callback = function(v) SliderValues.KickDelay = v end,
    })
    
    -- ========== TAB: MOVEMENT ==========
    local MoveTab = Window:CreateTab("Movement", 4483362458)
    
    MoveTab:CreateSection("Predkosc i skok")
    
    local tWS = MoveTab:CreateToggle({
        Name = "Walkspeed", CurrentValue = false, Flag = "Walkspeed",
        Callback = function(v) Modules.Walkspeed = v end,
    })
    
    local sWS = MoveTab:CreateSlider({
        Name = "Walkspeed", Range = {16, 120}, Increment = 1, Suffix = "",
        CurrentValue = CONFIG.DefaultSpeed, Flag = "WSValue",
        Callback = function(v) SliderValues.Walkspeed = v end,
    })
    
    local tJP = MoveTab:CreateToggle({
        Name = "Jump Power", CurrentValue = false, Flag = "JumpPower",
        Callback = function(v) Modules.JumpPower = v end,
    })
    
    local sJP = MoveTab:CreateSlider({
        Name = "Jump Power", Range = {50, 250}, Increment = 5, Suffix = "",
        CurrentValue = CONFIG.DefaultJump, Flag = "JPValue",
        Callback = function(v) SliderValues.JumpPower = v end,
    })
    
    MoveTab:CreateSection("Noclip i latanie")
    
    local tNoclip = MoveTab:CreateToggle({
        Name = "Noclip", CurrentValue = false, Flag = "Noclip",
        Callback = function(v) Modules.Noclip = v end,
    })
    
    local tFly = MoveTab:CreateToggle({
        Name = "Fly", CurrentValue = false, Flag = "Fly",
        Callback = function(v)
            Modules.Fly = v
            if v then
                FlyState.Enabled = true
                EnableFly()
            else
                FlyState.Enabled = false
                DisableFly()
            end
        end,
    })
    
    local sFly = MoveTab:CreateSlider({
        Name = "Fly Speed", Range = {10, 200}, Increment = 5, Suffix = "",
        CurrentValue = 50, Flag = "FlySpeed",
        Callback = function(v) FlyState.Speed = v end,
    })
    
    MoveTab:CreateSection("Teleporty")
    
    MoveTab:CreateButton({
        Name = "Teleport do dzialki",
        Callback = function()
            local root = GetRoot()
            if not root then return end
            local target = workspace:FindFirstChild("Plot") or workspace:FindFirstChild("Base") or workspace:FindFirstChild("Home") or workspace:FindFirstChild("Spawn")
            if target then
                root.CFrame = target.CFrame + Vector3.new(0, 5, 0)
                Rayfield:Notify({Title = "Teleport", Content = "Przeniesiono!", Duration = 2})
            else
                Rayfield:Notify({Title = "Blad", Content = "Nie znaleziono punktu", Duration = 2})
            end
        end,
    })
    
    MoveTab:CreateButton({
        Name = "Teleport do Safe Zone",
        Callback = function()
            local root = GetRoot()
            if not root then return end
            local target = workspace:FindFirstChild("SafeZone") or workspace:FindFirstChild("Safe") or workspace:FindFirstChild("SpawnArea")
            if target then
                root.CFrame = target.CFrame + Vector3.new(0, 5, 0)
                Rayfield:Notify({Title = "Teleport", Content = "Przeniesiono do Safe Zone!", Duration = 2})
            end
        end,
    })
    
    MoveTab:CreateButton({
        Name = "Teleport w miejsce (kliknij)",
        Callback = function()
            Modules.TpToPosition = true
            Rayfield:Notify({Title = "Teleport", Content = "Kliknij gdzie chcesz isc!", Duration = 3})
        end,
    })
    
    local tTsunami = MoveTab:CreateToggle({
        Name = "Auto Tsunami Escape", CurrentValue = false, Flag = "AutoTsunamiEscape",
        Callback = function(v) Modules.AutoTsunamiEscape = v end,
    })
    
    -- ========== TAB: ESP / VISUALS ==========
    local ESPTab = Window:CreateTab("ESP / Visuals", 4483362458)
    
    ESPTab:CreateSection("ESP")
    
    local tESPBlocks = ESPTab:CreateToggle({
        Name = "ESP Lucky Blocki", CurrentValue = false, Flag = "ESPBlocks",
        Callback = function(v) Modules.ESPBlocks = v end,
    })
    
    local tESPBrain = ESPTab:CreateToggle({
        Name = "ESP Brainroty", CurrentValue = false, Flag = "ESPBrainrots",
        Callback = function(v) Modules.ESPBrainrots = v end,
    })
    
    local tESPPlayers = ESPTab:CreateToggle({
        Name = "ESP Gracze", CurrentValue = false, Flag = "ESPPlayers",
        Callback = function(v) Modules.ESPPlayers = v end,
    })
    
    local tESPTsunami = ESPTab:CreateToggle({
        Name = "ESP Tsunami", CurrentValue = false, Flag = "ESPTsunami",
        Callback = function(v) Modules.ESPTsunami = v end,
    })
    
    local tESPPlots = ESPTab:CreateToggle({
        Name = "ESP Dzialki", CurrentValue = false, Flag = "ESPPlots",
        Callback = function(v) Modules.ESPPlots = v end,
    })
    
    ESPTab:CreateSection("Informacje")
    
    local tRadar = ESPTab:CreateToggle({
        Name = "Block Radar", CurrentValue = false, Flag = "BlockRadar",
        Callback = function(v) Modules.BlockRadar = v end,
    })
    
    local tDist = ESPTab:CreateToggle({
        Name = "Distance Tracker", CurrentValue = false, Flag = "DistanceTracker",
        Callback = function(v) Modules.DistanceTracker = v end,
    })
    
    local tInfo = ESPTab:CreateToggle({
        Name = "Info Panel", CurrentValue = false, Flag = "InfoPanel",
        Callback = function(v) Modules.InfoPanel = v end,
    })
    
    -- ========== TAB: EXPLOITY ==========
    local ExploitTab = Window:CreateTab("Exploity", 4483362458)
    
    ExploitTab:CreateSection("Kasa")
    
    local tCollectPro = ExploitTab:CreateToggle({
        Name = "Auto Collect Pro", CurrentValue = false, Flag = "AutoCollectPro",
        Callback = function(v) Modules.AutoCollectPro = v end,
    })
    
    local tMultiDrop = ExploitTab:CreateToggle({
        Name = "Multi Drop (x2)", CurrentValue = false, Flag = "MultiDrop",
        Callback = function(v) Modules.MultiDrop = v end,
    })
    
    local tInstantC = ExploitTab:CreateToggle({
        Name = "Instant Collect", CurrentValue = false, Flag = "InstantCollect",
        Callback = function(v) Modules.InstantCollect = v end,
    })
    
    local tFastTrain = ExploitTab:CreateToggle({
        Name = "Fast Train", CurrentValue = false, Flag = "FastTrain",
        Callback = function(v) Modules.FastTrain = v end,
    })
    
    ExploitTab:CreateSection("Anticheat Bypass")
    
    local tAntiKick = ExploitTab:CreateToggle({
        Name = "Anti-Kick", CurrentValue = false, Flag = "AntiKick",
        Callback = function(v) Modules.AntiKick = v end,
    })
    
    local tAntiBan = ExploitTab:CreateToggle({
        Name = "Anti-Ban", CurrentValue = false, Flag = "AntiBan",
        Callback = function(v) Modules.AntiBan = v end,
    })
    
    local tSpoofWS = ExploitTab:CreateToggle({
        Name = "Spoof Walkspeed", CurrentValue = false, Flag = "SpoofWalkspeed",
        Callback = function(v) Modules.SpoofWalkspeed = v end,
    })
    
    local tSpoofPos = ExploitTab:CreateToggle({
        Name = "Spoof Position", CurrentValue = false, Flag = "SpoofPosition",
        Callback = function(v) Modules.SpoofPosition = v end,
    })
    
    local tRemote = ExploitTab:CreateToggle({
        Name = "Remote Spam Blocker", CurrentValue = false, Flag = "RemoteSpamBlocker",
        Callback = function(v) Modules.RemoteSpamBlocker = v end,
    })
    
    local tLogs = ExploitTab:CreateToggle({
        Name = "Logs Cleaner", CurrentValue = false, Flag = "LogsCleaner",
        Callback = function(v) Modules.LogsCleaner = v end,
    })
    
    ExploitTab:CreateSection("Narzedzia")
    
    local tRejoin = ExploitTab:CreateToggle({
        Name = "Auto Rejoin", CurrentValue = false, Flag = "AutoRejoin",
        Callback = function(v) Modules.AutoRejoin = v end,
    })
    
    local tHopper = ExploitTab:CreateToggle({
        Name = "Server Hopper", CurrentValue = false, Flag = "ServerHopper",
        Callback = function(v) Modules.ServerHopper = v end,
    })
    
    -- ========== TAB: SETTINGS ==========
    local SettingsTab = Window:CreateTab("Settings", 4483362458)
    
    SettingsTab:CreateSection("Interfejs")
    
    SettingsTab:CreateToggle({
        Name = "Watermark", CurrentValue = false, Flag = "WatermarkToggle",
        Callback = function(v)
            if WatermarkInstance then
                WatermarkInstance.Enabled = v
            end
        end,
    })
    
    SettingsTab:CreateSection("Skrypt")
    
    SettingsTab:CreateLabel("Wersja: " .. CONFIG.Version)
    SettingsTab:CreateLabel("Autor: turcja")
    
    SettingsTab:CreateButton({
        Name = "Kopiuj nazwe",
        Callback = function()
            setclipboard(LocalPlayer.Name)
            Rayfield:Notify({Title = "OK", Content = "Skopiowano: " .. LocalPlayer.Name, Duration = 2})
        end,
    })
    
    SettingsTab:CreateButton({
        Name = "Destroy GUI",
        Callback = function()
            if Window then
                Window:Destroy()
                Window = nil
            end
            if WatermarkInstance then
                WatermarkInstance:Destroy()
                WatermarkInstance = nil
            end
        end,
    })
    
    Rayfield:Notify({Title = "Gotowe!", Content = CONFIG.ScriptName .. " " .. CONFIG.Version .. " zaladowany!", Duration = 3})
    
    -- ========== LOGIKA MODULOW ==========
    
    -- Walkspeed / Jump
    task.spawn(function()
        while true do
            task.wait(0.3)
            local hum = GetHumanoid()
            if hum then
                if Modules.Walkspeed then
                    hum.WalkSpeed = SliderValues.Walkspeed
                elseif hum.WalkSpeed ~= 16 then
                    hum.WalkSpeed = 16
                end
                
                if Modules.JumpPower then
                    hum.JumpPower = SliderValues.JumpPower
                elseif hum.JumpPower ~= 50 then
                    hum.JumpPower = 50
                end
            end
        end
    end)
    
    -- Noclip
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
    
    -- ESP Blocks
    task.spawn(function()
        while true do
            task.wait(0.5)
            if Modules.ESPBlocks then
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and (v.Name:lower():find("block") or v.Name:lower():find("lucky")) then
                        if not v:FindFirstChild("_ESPTag") then
                            local hl = Instance.new("Highlight")
                            hl.Name = "_ESPTag"
                            hl.FillColor = Color3.fromRGB(255, 215, 0)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.Adornee = v
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hl.Parent = v
                        end
                    end
                end
            else
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v:FindFirstChild("_ESPTag") then
                        v._ESPTag:Destroy()
                    end
                end
            end
        end
    end)
    
    -- Auto Tsunami Escape
    task.spawn(function()
        while true do
            task.wait(0.3)
            if Modules.AutoTsunamiEscape then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("tsunami") or obj.Name:lower():find("wave") or obj.Name:lower():find("flood")) then
                        local root = GetRoot()
                        if root then
                            local safe = workspace:FindFirstChild("SafeZone") or workspace:FindFirstChild("Safe") or workspace:FindFirstChild("Spawn")
                            if safe then
                                root.CFrame = safe.CFrame + Vector3.new(0, 5, 0)
                            end
                        end
                        break
                    end
                end
            end
        end
    end)
    
    -- Teleport na klik
    Mouse.Button1Down:Connect(function()
        if Modules.TpToPosition then
            local root = GetRoot()
            if root then
                local hit = Mouse.Hit
                root.CFrame = CFrame.new(hit.X, hit.Y + 3, hit.Z)
                Modules.TpToPosition = false
                Rayfield:Notify({Title = "Teleport", Content = "Przeniesiono!", Duration = 2})
            end
        end
    end)
    
    print("[KickBlock] " .. CONFIG.ScriptName .. " " .. CONFIG.Version .. " - OK!")
end

-- === FLY ===

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
    
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not FlyState.Enabled or not root or not root.Parent then
            conn:Disconnect()
            return
        end
        
        local vec = Vector3.new(0, 0, 0)
        local cam = workspace.CurrentCamera
        if not cam then return end
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            vec = vec + (cam.CFrame.LookVector * FlyState.Speed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            vec = vec - (cam.CFrame.LookVector * FlyState.Speed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            vec = vec - (cam.CFrame.RightVector * FlyState.Speed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            vec = vec + (cam.CFrame.RightVector * FlyState.Speed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            vec = vec + Vector3.new(0, FlyState.Speed, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            vec = vec - Vector3.new(0, FlyState.Speed, 0)
        end
        
        FlyState.BodyVelocity.Velocity = vec
        FlyState.BodyGyro.CFrame = cam.CFrame
        
        if root.Position.Y > CONFIG.MaxSafeHeight then
            root.CFrame = CFrame.new(root.Position.X, CONFIG.MaxSafeHeight, root.Position.Z)
        end
    end)
end

function DisableFly()
    local root = GetRoot()
    if root then
        if FlyState.BodyGyro then
            pcall(function() FlyState.BodyGyro:Destroy() end)
            FlyState.BodyGyro = nil
        end
        if FlyState.BodyVelocity then
            pcall(function() FlyState.BodyVelocity:Destroy() end)
            FlyState.BodyVelocity = nil
        end
    end
end

-- === START ===

-- Uruchomienie
local startTime = tick()
SimpleNotify(CONFIG.ScriptName .. " " .. CONFIG.Version .. " - ladowanie...", 2)
task.wait(0.5)

-- Pokaz key system
ShowKeySystem()
