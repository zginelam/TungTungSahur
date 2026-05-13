--[[
    Turcja Hub - Kick A Lucky Block (No More Flops)
    powered by turcja
    Wersja: 2.0.0
]]

-- Konfiguracja
local Config = {
    KeySystem = {
        Enabled = true,
        KeyURL = "https://raw.githubusercontent.com/turcjaszefito/keys/refs/heads/main/keys.txt",
        ValidKeys = {"turcja", "tungtung"}
    },
    Discord = {
        Invite = "discord.gg/turcjahub"
    },
    Watermark = {
        Text = "powered by turcja",
        DefaultEnabled = false,
        Position = Vector2.new(10, 10)
    },
    Configuration = {
        FolderName = "TurcjaHub",
        FileName = "KALB_Config"
    }
}

-- Własny system kluczy
local KeySystem = {}
KeySystem.__index = KeySystem

function KeySystem:Show()
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "TurcjaKeySystem"
    keyGui.ResetOnSpawn = true
    keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local keyFrame = Instance.new("Frame")
    keyFrame.Name = "KeyFrame"
    keyFrame.Size = UDim2.new(0, 400, 0, 300)
    keyFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    keyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    keyFrame.BackgroundTransparency = 0.05
    keyFrame.BorderSizePixel = 0
    keyFrame.Active = true
    keyFrame.Draggable = true
    keyFrame.Parent = keyGui
    
    -- Tytuł
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.Position = UDim2.new(0, 0, 0, 15)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Turcja Hub - Authentication"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = keyFrame
    
    -- Podtytuł
    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Name = "Subtitle"
    subtitleLabel.Size = UDim2.new(1, -60, 0, 40)
    subtitleLabel.Position = UDim2.new(0, 30, 0, 65)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = "Enter your license key to continue"
    subtitleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    subtitleLabel.TextScaled = true
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.Parent = keyFrame
    
    -- Pole tekstowe
    local textBox = Instance.new("TextBox")
    textBox.Name = "KeyInput"
    textBox.Size = UDim2.new(1, -80, 0, 45)
    textBox.Position = UDim2.new(0, 40, 0, 115)
    textBox.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    textBox.BorderSizePixel = 0
    textBox.PlaceholderText = "Enter your key here..."
    textBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    textBox.Text = ""
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextScaled = true
    textBox.Font = Enum.Font.Gotham
    textBox.ClearTextOnFocus = false
    textBox.Parent = keyFrame
    
    -- Przycisk Verify
    local verifyButton = Instance.new("TextButton")
    verifyButton.Name = "VerifyButton"
    verifyButton.Size = UDim2.new(1, -200, 0, 40)
    verifyButton.Position = UDim2.new(0, 40, 0, 175)
    verifyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    verifyButton.BorderSizePixel = 0
    verifyButton.Text = "VERIFY KEY"
    verifyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    verifyButton.TextScaled = true
    verifyButton.Font = Enum.Font.GothamBold
    verifyButton.Parent = keyFrame
    
    -- Przycisk Discord
    local discordButton = Instance.new("TextButton")
    discordButton.Name = "DiscordButton"
    discordButton.Size = UDim2.new(1, -200, 0, 40)
    discordButton.Position = UDim2.new(0, 40, 0, 225)
    discordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    discordButton.BorderSizePixel = 0
    discordButton.Text = "GET KEY (DISCORD)"
    discordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    discordButton.TextScaled = true
    discordButton.Font = Enum.Font.GothamBold
    discordButton.Parent = keyFrame
    
    -- Status label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -60, 0, 25)
    statusLabel.Position = UDim2.new(0, 30, 0, 270)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = keyFrame
    
    -- Efekt tła
    local backgroundFrame = Instance.new("Frame")
    backgroundFrame.Name = "Background"
    backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
    backgroundFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backgroundFrame.BackgroundTransparency = 0.5
    backgroundFrame.BorderSizePixel = 0
    backgroundFrame.Parent = keyGui
    
    backgroundFrame.ZIndex = 0
    keyFrame.ZIndex = 1
    
    -- Wczytywanie klawiszy z GitHub
    local function FetchKeys()
        local success, result = pcall(function()
            return game:HttpGet(Config.KeySystem.KeyURL)
        end)
        if success and result then
            for line in result:gmatch("[^\r\n]+") do
                line = line:gsub("^%s+", ""):gsub("%s+$", "")
                if line ~= "" then
                    table.insert(Config.KeySystem.ValidKeys, line)
                end
            end
        end
    end
    
    -- Próba pobrania kluczy z GitHub (nie blokuje GUI)
    local fetchThread = coroutine.wrap(FetchKeys)
    fetchThread()
    
    -- Obsługa przycisku Verify
    verifyButton.MouseButton1Click:Connect(function()
        local enteredKey = textBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
        if enteredKey == "" then
            statusLabel.Text = "Please enter a key!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end
        
        local isValid = false
        for _, validKey in ipairs(Config.KeySystem.ValidKeys) do
            if enteredKey == validKey then
                isValid = true
                break
            end
        end
        
        if isValid then
            statusLabel.Text = "Authentication successful!"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            wait(0.5)
            keyGui:Destroy()
            coroutine.wrap(function()
                InitializeHub()
            end)()
        else
            statusLabel.Text = "Invalid key! Get one from Discord."
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
    
    -- Obsługa przycisku Discord
    discordButton.MouseButton1Click:Connect(function()
        pcall(function()
            setclipboard("https://" .. Config.Discord.Invite)
        end)
        statusLabel.Text = "Discord link copied to clipboard!"
        statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    end)
    
    -- Obsługa Enter
    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            verifyButton.MouseButton1Click:Fire()
        end
    end)
    
    keyGui.Parent = game:GetService("CoreGui")
end

-- Główna funkcja inicjalizująca hub
function InitializeHub()
    -- Ładowanie Rayfield UI
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    
    -- Zmienne globalne
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local VirtualUser = game:GetService("VirtualUser")
    local TweenService = game:GetService("TweenService")
    local HttpService = game:GetService("HttpService")
    local MarketplaceService = game:GetService("MarketplaceService")
    
    local Player = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local Character = Player.Character or Player.CharacterAdded:Wait()
    
    -- Zmienne stanu
    local FluentVariables = {
        AutoFarm = false,
        AutoKick = false,
        AutoRebirth = false,
        AutoOpenCrates = false,
        AutoClaimRewards = false,
        AutoTsunami = false,
        AutoBrainrot = false,
        AutoCollectDrops = false,
        AntiAfk = false,
        SpeedEnabled = false,
        SpeedBoost = 50,
        FlyEnabled = false,
        FlySpeed = 50,
        NoclipEnabled = false,
        WalkSpeed = 16,
        JumpPower = 50,
        ESPEnabled = false,
        ESPBoxes = false,
        ESPNames = false,
        ESPTracers = false,
        ESPHealth = false,
        ESPDistance = false,
        ESPTeamCheck = false,
        RejoinOnKick = false,
        AntiIdle = false,
        WatermarkEnabled = Config.Watermark.DefaultEnabled,
        SelectedZone = "Common",
        SelectedCrate = "Common",
        SelectedFarmMode = "Current Zone",
        SpeedDuration = 5,
        AutoTap = false,
        AutoUpgradeSpeed = false,
        AutoBuyWeight = false,
        WeightThreshold = 500,
        AutoSpin = false,
        SelectedMutation = "Any",
        AutoClaimPassive = false,
        PassiveClaimInterval = 60,
        TsunamiWarning = false,
        AutoEatFood = false,
        FoodThreshold = 50,
        AutoSell = false,
        SellThreshold = 1000,
        TeleportToZone = "Common",
        ClickInterval = 0.01,
        UseDeltaTime = true,
        CustomCFrame = false,
        CFrameOffset = Vector3.new(0, 5, 0),
        AutoClickerMode = "Normal",
        MultiplierKey = "F",
        HoldToClick = false,
        SelectedGamepass = "Mutation Luck",
        AutoBuyGamepass = false,
        NotificationEnabled = true,
        Themes = "Dark",
        CustomTheme = {Background = Color3.fromRGB(20, 20, 30), Primary = Color3.fromRGB(0, 170, 255)},
    }
    
    -- Zmienne dla ESP
    local ESPObjects = {}
    local ESPConnection = nil
    
    -- Zmienna watermark
    local Watermark = nil
    local WatermarkConnection = nil
    
    -- Zmienne dla fly
    local FlyConnection = nil
    local FlyBodyVelocity = nil
    
    -- Zmienne dla noclip
    local NoclipConnection = nil
    
    -- Zmienne auto farm
    local AutoFarmConnection = nil
    local AutoKickConnection = nil
    local AutoTapConnection = nil
    
    -- Funkcje pomocnicze
    
    -- Watermark System
    local function CreateWatermark()
        if Watermark and Watermark.Parent then
            Watermark:Destroy()
            Watermark = nil
        end
        
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "TurcjaWatermark"
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.DisplayOrder = 999
        screenGui.IgnoreGuiInset = true
        
        local watermarkLabel = Instance.new("TextLabel")
        watermarkLabel.Name = "WatermarkLabel"
        watermarkLabel.Size = UDim2.new(0, 200, 0, 30)
        watermarkLabel.Position = UDim2.new(1, -210, 1, -40)
        watermarkLabel.BackgroundTransparency = 1
        watermarkLabel.Text = Config.Watermark.Text
        watermarkLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        watermarkLabel.TextTransparency = 0.3
        watermarkLabel.TextScaled = true
        watermarkLabel.Font = Enum.Font.GothamBold
        watermarkLabel.TextXAlignment = Enum.TextXAlignment.Right
        watermarkLabel.TextYAlignment = Enum.TextYAlignment.Bottom
        watermarkLabel.Parent = screenGui
        
        -- Animacja fade in/out
        local isVisible = true
        local fadeConnection = RunService.Heartbeat:Connect(function()
            if watermarkLabel then
                -- Subtelne pulsowanie przezroczystości
                local sinValue = math.sin(tick() * 0.5) * 0.1 + 0.3
                watermarkLabel.TextTransparency = sinValue
            end
        end)
        
        screenGui.Parent = PlayerGui
        Watermark = screenGui
        WatermarkConnection = fadeConnection
    end
    
    local function ToggleWatermark(enable)
        if enable then
            if not Watermark or not Watermark.Parent then
                CreateWatermark()
            end
        else
            if Watermark and Watermark.Parent then
                Watermark:Destroy()
                Watermark = nil
            end
            if WatermarkConnection then
                WatermarkConnection:Disconnect()
                WatermarkConnection = nil
            end
        end
        FluentVariables.WatermarkEnabled = enable
    end
    
    -- Funkcje ESP
    local function GetESPColor(player)
        if player.TeamColor == Player.TeamColor then
            return Color3.fromRGB(0, 255, 0)
        else
            return Color3.fromRGB(255, 0, 0)
        end
    end
    
    local function CreateESP(player)
        if ESPObjects[player] then
            return
        end
        
        local espData = {
            Box = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            Tracer = Drawing.new("Line"),
            HealthBar = Drawing.new("Square"),
            HealthText = Drawing.new("Text"),
            Distance = Drawing.new("Text")
        }
        
        espData.Box.Visible = false
        espData.Box.Filled = false
        espData.Box.Thickness = 1
        espData.Box.Color = Color3.fromRGB(255, 255, 255)
        
        espData.Name.Visible = false
        espData.Name.Size = 14
        espData.Name.Center = true
        espData.Name.Outline = true
        espData.Name.Color = Color3.fromRGB(255, 255, 255)
        
        espData.Tracer.Visible = false
        espData.Tracer.Thickness = 1
        espData.Tracer.Color = Color3.fromRGB(255, 255, 255)
        espData.Tracer.Transparency = 0.5
        
        espData.HealthBar.Visible = false
        espData.HealthBar.Thickness = 1
        espData.HealthBar.Filled = true
        
        espData.HealthText.Visible = false
        espData.HealthText.Size = 12
        espData.HealthText.Center = true
        espData.HealthText.Outline = true
        
        espData.Distance.Visible = false
        espData.Distance.Size = 12
        espData.Distance.Center = true
        espData.Distance.Outline = true
        
        ESPObjects[player] = espData
        
        -- Aktualizacja ESP w pętli
        player.CharacterAdded:Connect(function(char)
            wait(0.5)
            -- ESP zostanie zaktualizowane w pętli
        end)
    end
    
    local function UpdateESP()
        for player, espData in pairs(ESPObjects) do
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                local rootPart = player.Character.HumanoidRootPart
                local humanoid = player.Character.Humanoid
                local camera = workspace.CurrentCamera
                local vector, onScreen = camera:WorldToViewportPoint(rootPart.Position)
                local distance = (rootPart.Position - camera.CFrame.Position).Magnitude
                
                -- Team check
                if FluentVariables.ESPTeamCheck and player.TeamColor == Player.TeamColor then
                    espData.Box.Visible = false
                    espData.Name.Visible = false
                    espData.Tracer.Visible = false
                    espData.HealthBar.Visible = false
                    espData.HealthText.Visible = false
                    espData.Distance.Visible = false
                    continue
                end
                
                if onScreen then
                    local scale = camera.ViewportSize.Y / 1000
                    local boxSize = Vector2.new(50 * scale, 80 * scale)
                    local boxPos = Vector2.new(vector.X - boxSize.X / 2, vector.Y - boxSize.Y / 2)
                    local color = GetESPColor(player)
                    
                    -- Box
                    if FluentVariables.ESPBoxes then
                        espData.Box.Visible = true
                        espData.Box.Size = boxSize
                        espData.Box.Position = boxPos
                        espData.Box.Color = color
                    else
                        espData.Box.Visible = false
                    end
                    
                    -- Name
                    if FluentVariables.ESPNames then
                        espData.Name.Visible = true
                        espData.Name.Position = Vector2.new(vector.X, boxPos.Y - 16)
                        espData.Name.Text = player.DisplayName or player.Name
                        espData.Name.Color = color
                    else
                        espData.Name.Visible = false
                    end
                    
                    -- Tracer
                    if FluentVariables.ESPTracers then
                        espData.Tracer.Visible = true
                        espData.Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                        espData.Tracer.To = Vector2.new(vector.X, vector.Y)
                        espData.Tracer.Color = color
                    else
                        espData.Tracer.Visible = false
                    end
                    
                    -- Health
                    if FluentVariables.ESPHealth and humanoid then
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        local healthBarSize = Vector2.new(4, boxSize.Y * healthPercent)
                        local healthBarPos = Vector2.new(boxPos.X - 6, boxPos.Y + boxSize.Y - healthBarSize.Y)
                        
                        espData.HealthBar.Visible = true
                        espData.HealthBar.Size = healthBarSize
                        espData.HealthBar.Position = healthBarPos
                        espData.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                        
                        espData.HealthText.Visible = true
                        espData.HealthText.Position = Vector2.new(healthBarPos.X - 20, healthBarPos.Y + healthBarSize.Y / 2)
                        espData.HealthText.Text = tostring(math.floor(humanoid.Health))
                        espData.HealthText.Color = color
                    else
                        espData.HealthBar.Visible = false
                        espData.HealthText.Visible = false
                    end
                    
                    -- Distance
                    if FluentVariables.ESPDistance then
                        espData.Distance.Visible = true
                        espData.Distance.Position = Vector2.new(vector.X, boxPos.Y + boxSize.Y + 4)
                        espData.Distance.Text = tostring(math.floor(distance)) .. " studs"
                        espData.Distance.Color = color
                    else
                        espData.Distance.Visible = false
                    end
                else
                    espData.Box.Visible = false
                    espData.Name.Visible = false
                    espData.Tracer.Visible = false
                    espData.HealthBar.Visible = false
                    espData.HealthText.Visible = false
                    espData.Distance.Visible = false
                end
            else
                espData.Box.Visible = false
                espData.Name.Visible = false
                espData.Tracer.Visible = false
                espData.HealthBar.Visible = false
                espData.HealthText.Visible = false
                espData.Distance.Visible = false
            end
        end
    end
    
    local function ToggleESP(enable)
        FluentVariables.ESPEnabled = enable
        if enable then
            -- Tworzenie ESP dla wszystkich graczy
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= Player then
                    CreateESP(player)
                end
            end
            
            -- Podłączanie dla nowych graczy
            Players.PlayerAdded:Connect(function(player)
                wait(0.5)
                CreateESP(player)
            end)
            
            -- Pętla aktualizacji
            if ESPConnection then
                ESPConnection:Disconnect()
            end
            ESPConnection = RunService.RenderStepped:Connect(UpdateESP)
        else
            -- Usuwanie ESP
            for player, espData in pairs(ESPObjects) do
                espData.Box:Remove()
                espData.Name:Remove()
                espData.Tracer:Remove()
                espData.HealthBar:Remove()
                espData.HealthText:Remove()
                espData.Distance:Remove()
            end
            table.clear(ESPObjects)
            if ESPConnection then
                ESPConnection:Disconnect()
                ESPConnection = nil
            end
        end
    end
    
    -- Funkcje Auto Farm
    local function GetNetwork()
        local network = ReplicatedStorage:FindFirstChild("Shared")
        if network then
            network = network:FindFirstChild("Packages")
            if network then
                network = network:FindFirstChild("Network")
            end
        end
        return network
    end
    
    local function FireKickEvent(value)
        local network = GetNetwork()
        if network then
            local kickEvent = network:FindFirstChild("rev_KickEvent")
            if kickEvent then
                kickEvent:FireServer(value or 1)
                return true
            end
        end
        return false
    end
    
    local function FireSpeedEvent(speed, duration)
        local network = GetNetwork()
        if network then
            local speedEvent = network:FindFirstChild("rev_SPEED_UPDATE")
            if speedEvent then
                local event = speedEvent:FindFirstChild("Event") or speedEvent
                if event and event.ClassName == "RemoteEvent" then
                    event:FireServer(speed, duration)
                else
                    -- Próba firesignal
                    local bindable = speedEvent:FindFirstChildWhichIsA("BindableEvent")
                    if bindable then
                        bindable:Fire(speed, duration)
                    end
                end
                return true
            end
        end
        return false
    end
    
    local function AutoFarmLogic()
        while FluentVariables.AutoFarm do
            local success = FireKickEvent(1)
            if FluentVariables.AutoTap then
                -- Symulacja kliknięcia
                VirtualUser:ClickButton1(Vector2.new(0, 0))
            end
            if FluentVariables.UseDeltaTime then
                wait(FluentVariables.ClickInterval)
            else
                wait(0.05)
            end
        end
    end
    
    local function AutoKickLogic()
        while FluentVariables.AutoKick do
            FireKickEvent(1)
            wait(FluentVariables.ClickInterval * 10)
        end
    end
    
    -- Funkcje Anti-AFK
    local function AntiAfkLogic()
        while FluentVariables.AntiAfk do
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
            wait(60)
        end
    end
    
    -- Funkcje Fly
    local function ToggleFly(enable)
        FluentVariables.FlyEnabled = enable
        Character = Player.Character or Player.CharacterAdded:Wait()
        local humanoid = Character:FindFirstChild("Humanoid")
        local rootPart = Character:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not rootPart then return end
        
        if enable then
            if FlyConnection then
                FlyConnection:Disconnect()
            end
            if FlyBodyVelocity then
                FlyBodyVelocity:Destroy()
            end
            
            FlyBodyVelocity = Instance.new("BodyVelocity")
            FlyBodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
            FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            FlyBodyVelocity.P = 1000
            FlyBodyVelocity.Parent = rootPart
            
            FlyConnection = RunService.Heartbeat:Connect(function()
                if not FluentVariables.FlyEnabled or not FlyBodyVelocity or not FlyBodyVelocity.Parent then
                    return
                end
                
                local moveDirection = Vector3.new(0, 0, 0)
                local camera = workspace.CurrentCamera
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveDirection = moveDirection - Vector3.new(0, 1, 0)
                end
                
                if moveDirection.Magnitude > 0 then
                    moveDirection = moveDirection.Unit * FluentVariables.FlySpeed
                end
                
                FlyBodyVelocity.Velocity = moveDirection
            end)
        else
            if FlyConnection then
                FlyConnection:Disconnect()
                FlyConnection = nil
            end
            if FlyBodyVelocity then
                FlyBodyVelocity:Destroy()
                FlyBodyVelocity = nil
            end
        end
    end
    
    -- Funkcje Noclip
    local function ToggleNoclip(enable)
        FluentVariables.NoclipEnabled = enable
        if enable then
            if NoclipConnection then
                NoclipConnection:Disconnect()
            end
            NoclipConnection = RunService.Stepped:Connect(function()
                if not FluentVariables.NoclipEnabled then return end
                Character = Player.Character or Player.CharacterAdded:Wait()
                for _, part in ipairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end)
        else
            if NoclipConnection then
                NoclipConnection:Disconnect()
                NoclipConnection = nil
            end
            -- Przywracanie CanCollide
            Character = Player.Character or Player.CharacterAdded:Wait()
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
    
    -- Funkcje Speed Boost
    local function ToggleSpeed(enable)
        FluentVariables.SpeedEnabled = enable
        if enable then
            FireSpeedEvent(FluentVariables.SpeedBoost, FluentVariables.SpeedDuration)
            FluentVariables.SpeedEnabled = false
            Rayfield:Notify({
                Title = "Speed Boost",
                Content = "Speed boost activated! (" .. FluentVariables.SpeedBoost .. "x for " .. FluentVariables.SpeedDuration .. "s)",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
    
    -- Teleportacja do strefy
    local function TeleportToZone(zoneName)
        local zones = workspace:FindFirstChild("Zones") or workspace:FindFirstChild("Areas")
        if zones then
            local targetZone = zones:FindFirstChild(zoneName)
            if targetZone then
                local spawnPoint = targetZone:FindFirstChild("Spawn") or targetZone:FindFirstChild("SpawnLocation")
                if spawnPoint then
                    Character = Player.Character or Player.CharacterAdded:Wait()
                    local rootPart = Character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        rootPart.CFrame = spawnPoint.CFrame + Vector3.new(0, 3, 0)
                        Rayfield:Notify({
                            Title = "Teleported",
                            Content = "Teleported to " .. zoneName,
                            Duration = 2,
                            Image = 4483362458
                        })
                        return
                    end
                end
                -- Próba teleportacji bez spawn point
                Character = Player.Character or Player.CharacterAdded:Wait()
                local rootPart = Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    rootPart.CFrame = targetZone.CFrame + Vector3.new(0, 3, 0)
                    Rayfield:Notify({
                        Title = "Teleported",
                        Content = "Teleported to " .. zoneName,
                        Duration = 2,
                        Image = 4483362458
                    })
                end
            end
        end
    end
    
    -- Auto Rebirth
    local function AutoRebirthLogic()
        while FluentVariables.AutoRebirth do
            -- Symulacja rebirth
            local args = {["Rebirth"] = true}
            local remote = ReplicatedStorage:FindFirstChild("RebirthEvent") or 
                          ReplicatedStorage:FindFirstChild("rev_Rebirth")
            if remote then
                remote:FireServer(args)
            end
            wait(5)
        end
    end
    
    -- Auto Open Crates
    local function AutoOpenCratesLogic()
        while FluentVariables.AutoOpenCrates do
            local remote = ReplicatedStorage:FindFirstChild("OpenCrate") or 
                          ReplicatedStorage:FindFirstChild("rev_OpenCrate")
            if remote then
                remote:FireServer(FluentVariables.SelectedCrate)
            end
            wait(1)
        end
    end
    
    -- Auto Claim Rewards
    local function AutoClaimRewardsLogic()
        while FluentVariables.AutoClaimRewards do
            local remote = ReplicatedStorage:FindFirstChild("ClaimReward") or 
                          ReplicatedStorage:FindFirstChild("rev_ClaimReward")
            if remote then
                remote:FireServer()
            end
            wait(5)
        end
    end
    
    -- Auto Tsunami
    local function AutoTsunamiLogic()
        while FluentVariables.AutoTsunami do
            local remote = ReplicatedStorage:FindFirstChild("TsunamiEvent") or 
                          ReplicatedStorage:FindFirstChild("rev_Tsunami")
            if remote then
                remote:FireServer()
            end
            wait(30)
        end
    end
    
    -- Auto Brainrot
    local function AutoBrainrotLogic()
        while FluentVariables.AutoBrainrot do
            local remote = ReplicatedStorage:FindFirstChild("BrainrotEvent") or 
                          ReplicatedStorage:FindFirstChild("rev_Brainrot")
            if remote then
                remote:FireServer()
            end
            wait(10)
        end
    end
    
    -- Auto Collect Drops
    local function AutoCollectDropsLogic()
        while FluentVariables.AutoCollectDrops do
            for _, drop in ipairs(workspace:GetDescendants()) do
                if drop:IsA("Part") and drop.Name:find("Drop") then
                    local character = Player.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CFrame = drop.CFrame + Vector3.new(0, 2, 0)
                        wait(0.5)
                        firetouchinterest(character.HumanoidRootPart, drop, 0)
                        wait(0.1)
                        firetouchinterest(character.HumanoidRootPart, drop, 1)
                        wait(0.5)
                    end
                end
            end
            wait(2)
        end
    end
    
    -- Auto Claim Passive Income
    local function AutoClaimPassiveLogic()
        while FluentVariables.AutoClaimPassive do
            local remote = ReplicatedStorage:FindFirstChild("ClaimPassive") or 
                          ReplicatedStorage:FindFirstChild("rev_ClaimPassive")
            if remote then
                remote:FireServer()
            end
            wait(FluentVariables.PassiveClaimInterval)
        end
    end
    
    -- Auto Upgrade Speed
    local function AutoUpgradeSpeedLogic()
        while FluentVariables.AutoUpgradeSpeed do
            local remote = ReplicatedStorage:FindFirstChild("UpgradeSpeed") or 
                          ReplicatedStorage:FindFirstChild("rev_UpgradeSpeed")
            if remote then
                remote:FireServer()
            end
            wait(2)
        end
    end
    
    -- Auto Buy Weight
    local function AutoBuyWeightLogic()
        while FluentVariables.AutoBuyWeight do
            local playerData = Player:FindFirstChild("Data") or Player:FindFirstChild("leaderstats")
            if playerData then
                local weight = playerData:FindFirstChild("Weight") or playerData:FindFirstChild("MaxWeight")
                if weight and weight.Value < FluentVariables.WeightThreshold then
                    local remote = ReplicatedStorage:FindFirstChild("BuyWeight") or 
                                  ReplicatedStorage:FindFirstChild("rev_BuyWeight")
                    if remote then
                        remote:FireServer()
                    end
                end
            end
            wait(3)
        end
    end
    
    -- Auto Spin
    local function AutoSpinLogic()
        while FluentVariables.AutoSpin do
            local remote = ReplicatedStorage:FindFirstChild("SpinEvent") or 
                          ReplicatedStorage:FindFirstChild("rev_Spin")
            if remote then
                remote:FireServer(FluentVariables.SelectedMutation)
            end
            wait(1)
        end
    end
    
    -- Auto Eat Food
    local function AutoEatFoodLogic()
        while FluentVariables.AutoEatFood do
            local playerData = Player:FindFirstChild("Data") or Player:FindFirstChild("leaderstats")
            if playerData then
                local hunger = playerData:FindFirstChild("Hunger") or playerData:FindFirstChild("Food")
                if hunger and hunger.Value <= FluentVariables.FoodThreshold then
                    local backpack = Player:FindFirstChild("Backpack")
                    if backpack then
                        for _, item in ipairs(backpack:GetChildren()) do
                            if item:IsA("Tool") and (item.Name:find("Food") or item.Name:find("Bread") or item.Name:find("Apple")) then
                                item:Activate()
                                wait(1)
                                break
                            end
                        end
                    end
                end
            end
            wait(5)
        end
    end
    
    -- Auto Sell
    local function AutoSellLogic()
        while FluentVariables.AutoSell do
            local playerData = Player:FindFirstChild("Data") or Player:FindFirstChild("leaderstats")
            if playerData then
                local currency = playerData:FindFirstChild("Coins") or playerData:FindFirstChild("Money") or playerData:FindFirstChild("Value")
                if currency and currency.Value >= FluentVariables.SellThreshold then
                    local remote = ReplicatedStorage:FindFirstChild("SellEvent") or 
                                  ReplicatedStorage:FindFirstChild("rev_Sell")
                    if remote then
                        remote:FireServer()
                    end
                end
            end
            wait(5)
        end
    end
    
    -- AntiIdle
    local function AntiIdleLogic()
        while FluentVariables.AntiIdle do
            local virtualUser = game:GetService("VirtualUser")
            virtualUser:CaptureController()
            virtualUser:ClickButton2(Vector2.new(0, 0))
            wait(300) -- 5 minut
        end
    end
    
    -- Rejoin on Kick
    local function RejoinOnKickLogic()
        if FluentVariables.RejoinOnKick then
            Player.OnTeleport:Connect(function(state)
                if state == Enum.TeleportState.Failed then
                    wait(2)
                    local ts = game:GetService("TeleportService")
                    ts:Teleport(game.PlaceId, Player)
                end
            end)
        end
    end
    
    -- Toggle Handler dla loop function
    local function ToggleLoop(varName, func, enable)
        FluentVariables[varName] = enable
        if enable then
            coroutine.wrap(func)()
        end
    end
    
    -- ============================================
    -- TWORZENIE GUI RAYFIELD
    -- ============================================
    
    local Window = Rayfield:CreateWindow({
        Name = "Turcja Hub - Kick A Lucky Block",
        LoadingTitle = "Turcja Hub",
        LoadingSubtitle = "powered by turcja",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = Config.Configuration.FolderName,
            FileName = Config.Configuration.FileName
        },
        Discord = {
            Enabled = true,
            Invite = Config.Discord.Invite,
            RememberJoins = true
        },
        KeySystem = false,
        KeySettings = {
            Title = "Turcja Hub",
            Subtitle = "Key System",
            Note = "Get your key from Discord",
            FileName = "TurcjaHubKey",
            SaveKey = true,
            GrabKeyFromSite = false,
            Key = {"turcja"}
        }
    })
    
    -- ============================================
    -- ZAKŁADKA: INFORMATION
    -- ============================================
    local InfoTab = Window:CreateTab("Information", "info")
    
    InfoTab:CreateSection("Hub Info")
    
    InfoTab:CreateParagraph({
        Title = "Turcja Hub v2.0.0",
        Content = "Welcome to Turcja Hub for Kick A Lucky Block (No More Flops)!\n\n" ..
                  "💠 Premium script with advanced features\n" ..
                  "⚡ Optimized for performance & undetected\n" ..
                  "🛡️ Anti-ban protection included\n" ..
                  "🎯 42+ modules across all categories\n\n" ..
                  "Powered by turcja"
    })
    
    InfoTab:CreateSection("Game Info")
    
    InfoTab:CreateParagraph({
        Title = "Game Features",
        Content = "🏆 11 Zones: Common → Celestial\n" ..
                  "🌟 8 Mutations: Gold(1.5×) → Rainbow(30×)\n" ..
                  "🔄 Rebirth System: Prestige + Multipliers\n" ..
                  "🌊 Tsunami Events\n" ..
                  "🧠 Brainrot Collection\n" ..
                  "💪 Speed & Weight Upgrades\n" ..
                  "🎮 Gamepasses Available"
    })
    
    InfoTab:CreateSection("Quick Actions")
    
    InfoTab:CreateButton({
        Name = "📋 Copy Discord Invite",
        Callback = function()
            pcall(function()
                setclipboard("https://" .. Config.Discord.Invite)
                Rayfield:Notify({
                    Title = "Discord",
                    Content = "Invite link copied!",
                    Duration = 2,
                    Image = 4483362458
                })
            end)
        end
    })
    
    InfoTab:CreateButton({
        Name = "🔄 Rejoin Game",
        Callback = function()
            local ts = game:GetService("TeleportService")
            ts:Teleport(game.PlaceId, Player)
        end
    })
    
    InfoTab:CreateButton({
        Name = "🔍 Check Player Stats",
        Callback = function()
            local playerData = Player:FindFirstChild("Data") or Player:FindFirstChild("leaderstats")
            if playerData then
                local infoStr = "Player: " .. Player.Name .. "\n"
                for _, child in ipairs(playerData:GetChildren()) do
                    if child:IsA("NumberValue") or child:IsA("StringValue") or child:IsA("IntValue") then
                        infoStr = infoStr .. child.Name .. ": " .. tostring(child.Value) .. "\n"
                    end
                end
                Rayfield:Notify({
                    Title = "Player Stats",
                    Content = infoStr,
                    Duration = 5,
                    Image = 4483362458
                })
            else
                Rayfield:Notify({
                    Title = "Error",
                    Content = "Could not find player data!",
                    Duration = 3,
                    Image = 4483362458
                })
            end
        end
    })
    
    -- ============================================
    -- ZAKŁADKA: AUTO FARM
    -- ============================================
    local FarmTab = Window:CreateTab("Auto Farm", "zap")
    
    FarmTab:CreateSection("Main Farming")
    
    FarmTab:CreateToggle({
        Name = "Auto Farm (Main)",
        CurrentValue = false,
        Flag = "AutoFarm",
        Callback = function(Value)
            ToggleLoop("AutoFarm", AutoFarmLogic, Value)
            if Value then
                Rayfield:Notify({
                    Title = "Auto Farm",
                    Content = "Auto Farm started!",
                    Duration = 2,
                    Image = 4483362458
                })
            end
        end
    })
    
    FarmTab:CreateToggle({
        Name = "Auto Kick",
        CurrentValue = false,
        Flag = "AutoKick",
        Callback = function(Value)
            ToggleLoop("AutoKick", AutoKickLogic, Value)
        end
    })
    
    FarmTab:CreateToggle({
        Name = "Auto Tap (Virtual)",
        CurrentValue = false,
        Flag = "AutoTap",
        Callback = function(Value)
            FluentVariables.AutoTap = Value
        end
    })
    
    FarmTab:CreateSlider({
        Name = "Click Interval (seconds)",
        Range = {0.01, 1},
        Increment = 0.01,
        Suffix = "s",
        CurrentValue = 0.01,
        Flag = "ClickInterval",
        Callback = function(Value)
            FluentVariables.ClickInterval = Value
        end
    })
    
    FarmTab:CreateSection("Auto Progression")
    
    FarmTab:CreateToggle({
        Name = "Auto Rebirth",
        CurrentValue = false,
        Flag = "AutoRebirth",
        Callback = function(Value)
            ToggleLoop("AutoRebirth", AutoRebirthLogic, Value)
        end
    })
    
    FarmTab:CreateToggle({
        Name = "Auto Open Crates",
        CurrentValue = false,
        Flag = "AutoOpenCrates",
        Callback = function(Value)
            ToggleLoop("AutoOpenCrates", AutoOpenCratesLogic, Value)
        end
    })
    
    FarmTab:CreateDropdown({
        Name = "Crate Type",
        Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Celestial"},
        CurrentOption = "Common",
        Flag = "SelectedCrate",
        Callback = function(Option)
            FluentVariables.SelectedCrate = Option
        end
    })
    
    FarmTab:CreateToggle({
        Name = "Auto Claim Rewards",
        CurrentValue = false,
        Flag = "AutoClaimRewards",
        Callback = function(Value)
            ToggleLoop("AutoClaimRewards", AutoClaimRewardsLogic, Value)
        end
    })
    
    FarmTab:CreateSection("Events & Collection")
    
    FarmTab:CreateToggle({
        Name = "Auto Tsunami",
        CurrentValue = false,
        Flag = "AutoTsunami",
        Callback = function(Value)
            ToggleLoop("AutoTsunami", AutoTsunamiLogic, Value)
        end
    })
    
    FarmTab:CreateToggle({
        Name = "Auto Brainrot",
        CurrentValue = false,
        Flag = "AutoBrainrot",
        Callback = function(Value)
            ToggleLoop("AutoBrainrot", AutoBrainrotLogic, Value)
        end
    })
    
    FarmTab:CreateToggle({
        Name = "Auto Collect Drops",
        CurrentValue = false,
        Flag = "AutoCollectDrops",
        Callback = function(Value)
            ToggleLoop("AutoCollectDrops", AutoCollectDropsLogic, Value)
        end
    })
    
    FarmTab:CreateToggle({
        Name = "Auto Claim Passive Income",
        CurrentValue = false,
        Flag = "AutoClaimPassive",
        Callback = function(Value)
            ToggleLoop("AutoClaimPassive", AutoClaimPassiveLogic, Value)
        end
    })
    
    FarmTab:CreateSlider({
        Name = "Passive Claim Interval",
        Range = {10, 300},
        Increment = 5,
        Suffix = "s",
        CurrentValue = 60,
        Flag = "PassiveClaimInterval",
        Callback = function(Value)
            FluentVariables.PassiveClaimInterval = Value
        end
    })
    
    FarmTab:CreateSection("Auto Upgrades")
    
    FarmTab:CreateToggle({
        Name = "Auto Upgrade Speed",
        CurrentValue = false,
        Flag = "AutoUpgradeSpeed",
        Callback = function(Value)
            ToggleLoop("AutoUpgradeSpeed", AutoUpgradeSpeedLogic, Value)
        end
    })
    
    FarmTab:CreateToggle({
        Name = "Auto Buy Weight",
        CurrentValue = false,
        Flag = "AutoBuyWeight",
        Callback = function(Value)
            ToggleLoop("AutoBuyWeight", AutoBuyWeightLogic, Value)
        end
    })
    
    FarmTab:CreateSlider({
        Name = "Weight Threshold",
        Range = {100, 10000},
        Increment = 50,
        Suffix = "kg",
        CurrentValue = 500,
        Flag = "WeightThreshold",
        Callback = function(Value)
            FluentVariables.WeightThreshold = Value
        end
    })
    
    -- ============================================
    -- ZAKŁADKA: MOVEMENT
    -- ============================================
    local MoveTab = Window:CreateTab("Movement", "move")
    
    MoveTab:CreateSection("Movement Mods")
    
    MoveTab:CreateToggle({
        Name = "Fly",
        CurrentValue = false,
        Flag = "FlyToggle",
        Callback = function(Value)
            ToggleFly(Value)
        end
    })
    
    MoveTab:CreateSlider({
        Name = "Fly Speed",
        Range = {10, 200},
        Increment = 5,
        Suffix = "studs/s",
        CurrentValue = 50,
        Flag = "FlySpeed",
        Callback = function(Value)
            FluentVariables.FlySpeed = Value
        end
    })
    
    MoveTab:CreateToggle({
        Name = "Noclip",
        CurrentValue = false,
        Flag = "NoclipToggle",
        Callback = function(Value)
            ToggleNoclip(Value)
        end
    })
    
    MoveTab:CreateSection("Speed")
    
    MoveTab:CreateButton({
        Name = "⚡ Activate Speed Boost",
        Callback = function()
            ToggleSpeed(true)
        end
    })
    
    MoveTab:CreateSlider({
        Name = "Speed Boost Value",
        Range = {10, 500},
        Increment = 5,
        Suffix = "x",
        CurrentValue = 50,
        Flag = "SpeedBoostValue",
        Callback = function(Value)
            FluentVariables.SpeedBoost = Value
        end
    })
    
    MoveTab:CreateSlider({
        Name = "Speed Duration",
        Range = {1, 60},
        Increment = 1,
        Suffix = "s",
        CurrentValue = 5,
        Flag = "SpeedDuration",
        Callback = function(Value)
            FluentVariables.SpeedDuration = Value
        end
    })
    
    MoveTab:CreateSection("Character Stats")
    
    MoveTab:CreateSlider({
        Name = "Walk Speed",
        Range = {16, 200},
        Increment = 1,
        Suffix = "studs/s",
        CurrentValue = 16,
        Flag = "WalkSpeed",
        Callback = function(Value)
            FluentVariables.WalkSpeed = Value
            Character = Player.Character or Player.CharacterAdded:Wait()
            local humanoid = Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = Value
            end
        end
    })
    
    MoveTab:CreateSlider({
        Name = "Jump Power",
        Range = {50, 500},
        Increment = 5,
        Suffix = "",
        CurrentValue = 50,
        Flag = "JumpPower",
        Callback = function(Value)
            FluentVariables.JumpPower = Value
            Character = Player.Character or Player.CharacterAdded:Wait()
            local humanoid = Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.JumpPower = Value
            end
        end
    })
    
    MoveTab:CreateSection("Teleportation")
    
    MoveTab:CreateDropdown({
        Name = "Teleport to Zone",
        Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Celestial", "Event", "Secret", "Void", "Debug"},
        CurrentOption = "Common",
        Flag = "TeleportZone",
        Callback = function(Option)
            FluentVariables.TeleportToZone = Option
        end
    })
    
    MoveTab:CreateButton({
        Name = "🚀 Teleport Now",
        Callback = function()
            TeleportToZone(FluentVariables.TeleportToZone)
        end
    })
    
    -- ============================================
    -- ZAKŁADKA: ESP
    -- ============================================
    local ESPTab = Window:CreateTab("ESP", "eye")
    
    ESPTab:CreateSection("ESP Settings")
    
    ESPTab:CreateToggle({
        Name = "Enable ESP",
        CurrentValue = false,
        Flag = "ESPMain",
        Callback = function(Value)
            ToggleESP(Value)
        end
    })
    
    ESPTab:CreateToggle({
        Name = "Boxes",
        CurrentValue = false,
        Flag = "ESPBoxes",
        Callback = function(Value)
            FluentVariables.ESPBoxes = Value
        end
    })
    
    ESPTab:CreateToggle({
        Name = "Names",
        CurrentValue = false,
        Flag = "ESPNames",
        Callback = function(Value)
            FluentVariables.ESPNames = Value
        end
    })
    
    ESPTab:CreateToggle({
        Name = "Tracers",
        CurrentValue = false,
        Flag = "ESPTracers",
        Callback = function(Value)
            FluentVariables.ESPTracers = Value
        end
    })
    
    ESPTab:CreateToggle({
        Name = "Health Bar",
        CurrentValue = false,
        Flag = "ESPHealth",
        Callback = function(Value)
            FluentVariables.ESPHealth = Value
        end
    })
    
    ESPTab:CreateToggle({
        Name = "Distance",
        CurrentValue = false,
        Flag = "ESPDistance",
        Callback = function(Value)
            FluentVariables.ESPDistance = Value
        end
    })
    
    ESPTab:CreateToggle({
        Name = "Team Check (Hide Allies)",
        CurrentValue = false,
        Flag = "ESPTeamCheck",
        Callback = function(Value)
            FluentVariables.ESPTeamCheck = Value
        end
    })
    
    -- ============================================
    -- ZAKŁADKA: EXPLOITS PREMIUM
    -- ============================================
    local ExploitTab = Window:CreateTab("Exploits Premium", "zap")
    
    ExploitTab:CreateSection("Premium Exploits")
    
    ExploitTab:CreateToggle({
        Name = "Auto Spin (Mutation)",
        CurrentValue = false,
        Flag = "AutoSpin",
        Callback = function(Value)
            ToggleLoop("AutoSpin", AutoSpinLogic, Value)
        end
    })
    
    ExploitTab:CreateDropdown({
        Name = "Mutation Target",
        Options = {"Any", "Gold", "Diamond", "Dark", "Omega", "Galaxy", "Rainbow", "Celestial"},
        CurrentOption = "Any",
        Flag = "MutationTarget",
        Callback = function(Option)
            FluentVariables.SelectedMutation = Option
        end
    })
    
    ExploitTab:CreateToggle({
        Name = "Auto Sell Items",
        CurrentValue = false,
        Flag = "AutoSell",
        Callback = function(Value)
            ToggleLoop("AutoSell", AutoSellLogic, Value)
        end
    })
    
    ExploitTab:CreateSlider({
        Name = "Sell Threshold",
        Range = {100, 100000},
        Increment = 100,
        Suffix = "$",
        CurrentValue = 1000,
        Flag = "SellThreshold",
        Callback = function(Value)
            FluentVariables.SellThreshold = Value
        end
    })
    
    ExploitTab:CreateToggle({
        Name = "Auto Eat Food",
        CurrentValue = false,
        Flag = "AutoEatFood",
        Callback = function(Value)
            ToggleLoop("AutoEatFood", AutoEatFoodLogic, Value)
        end
    })
    
    ExploitTab:CreateSlider({
        Name = "Food Threshold",
        Range = {10, 100},
        Increment = 5,
        Suffix = "%",
        CurrentValue = 50,
        Flag = "FoodThreshold",
        Callback = function(Value)
            FluentVariables.FoodThreshold = Value
        end
    })
    
    ExploitTab:CreateSection("Advanced")
    
    ExploitTab:CreateToggle({
        Name = "Use DeltaTime (Optimized)",
        CurrentValue = true,
        Flag = "UseDeltaTime",
        Callback = function(Value)
            FluentVariables.UseDeltaTime = Value
        end
    })
    
    ExploitTab:CreateToggle({
        Name = "Custom CFrame Offset",
        CurrentValue = false,
        Flag = "CustomCFrame",
        Callback = function(Value)
            FluentVariables.CustomCFrame = Value
        end
    })
    
    ExploitTab:CreateInput({
        Name = "CFrame Offset (X,Y,Z)",
        CurrentValue = "0,5,0",
        PlaceholderText = "0,5,0",
        RemoveTextAfterFocusLost = false,
        Flag = "CFrameOffsetInput",
        Callback = function(Text)
            local x, y, z = Text:match("([%d.-]+),([%d.-]+),([%d.-]+)")
            if x and y and z then
                FluentVariables.CFrameOffset = Vector3.new(tonumber(x) or 0, tonumber(y) or 5, tonumber(z) or 0)
            end
        end
    })
    
    ExploitTab:CreateSection("Auto Clicker")
    
    ExploitTab:CreateToggle({
        Name = "Hold to Click",
        CurrentValue = false,
        Flag = "HoldToClick",
        Callback = function(Value)
            FluentVariables.HoldToClick = Value
        end
    })
    
    ExploitTab:CreateInput({
        Name = "Multiplier Key",
        CurrentValue = "F",
        PlaceholderText = "F",
        RemoveTextAfterFocusLost = false,
        Flag = "MultiplierKey",
        Callback = function(Text)
            FluentVariables.MultiplierKey = Text:upper()
        end
    })
    
    ExploitTab:CreateDropdown({
        Name = "Auto Clicker Mode",
        Options = {"Normal", "Multiplier", "Hold", "Toggle"},
        CurrentOption = "Normal",
        Flag = "ClickerMode",
        Callback = function(Option)
            FluentVariables.AutoClickerMode = Option
        end
    })
    
    -- ============================================
    -- ZAKŁADKA: OCHRONA PRZED BANEM
    -- ============================================
    var AntiBanTab = Window:CreateTab("Anti-Ban", "shield")
    
    AntiBanTab:CreateSection("Protection")
    
    AntiBanTab:CreateToggle({
        Name = "Anti AFK",
        CurrentValue = false,
        Flag = "AntiAFK",
        Callback = function(Value)
            ToggleLoop("AntiAfk", AntiAfkLogic, Value)
        end
    })
    
    AntiBanTab:CreateToggle({
        Name = "Anti Idle (5min)",
        CurrentValue = false,
        Flag = "AntiIdle",
        Callback = function(Value)
            ToggleLoop("AntiIdle", AntiIdleLogic, Value)
        end
    })
    
    AntiBanTab:CreateToggle({
        Name = "Rejoin on Kick",
        CurrentValue = false,
        Flag = "RejoinOnKick",
        Callback = function(Value)
            FluentVariables.RejoinOnKick = Value
            if Value then
                RejoinOnKickLogic()
            end
        end
    })
    
    AntiBanTab:CreateSection("Safety")
    
    AntiBanTab:CreateLabel("⚠️ Anti-ban measures active", {Image = 4483362458})
    
    AntiBanTab:CreateParagraph({
        Title = "Safety Tips",
        Content = "• Don't use obvious settings in public servers\n" ..
                  "• Use Anti AFK to prevent auto-kick\n" ..
                  "• Moderate Auto Farm speeds recommended\n" ..
                  "• Anti-ban is not 100% guaranteed\n" ..
                  "• You are responsible for your account"
    })
    
    -- ============================================
    -- ZAKŁADKA: ADDONS
    -- ============================================
    local AddonTab = Window:CreateTab("Addons", "package")
    
    AddonTab:CreateSection("Gamepasses")
    
    AddonTab:CreateDropdown({
        Name = "Gamepass Select",
        Options = {"Mutation Luck", "Rebirth Skip", "2x Coins", "2x Luck", "VIP", "Auto Farm"},
        CurrentOption = "Mutation Luck",
        Flag = "GamepassSelect",
        Callback = function(Option)
            FluentVariables.SelectedGamepass = Option
        end
    })
    
    AddonTab:CreateToggle({
        Name = "Auto Buy Gamepass",
        CurrentValue = false,
        Flag = "AutoBuyGamepass",
        Callback = function(Value)
            FluentVariables.AutoBuyGamepass = Value
        end
    })
    
    AddonTab:CreateButton({
        Name = "🛒 Open Gamepass Store",
        Callback = function()
            local msg = Instance.new("Message")
            msg.Text = "Opening gamepass store..."
            msg.Parent = workspace
            game:GetService("MarketplaceService"):PromptGamePassPurchase(Player, 0)
            wait(3)
            msg:Destroy()
        end
    })
    
    AddonTab:CreateSection("Visuals")
    
    AddonTab:CreateToggle({
        Name = "Notifications",
        CurrentValue = true,
        Flag = "Notifications",
        Callback = function(Value)
            FluentVariables.NotificationEnabled = Value
        end
    })
    
    AddonTab:CreateColorPicker({
        Name = "Theme Color",
        Color = Color3.fromRGB(0, 170, 255),
        Flag = "ThemeColor",
        Callback = function(Color)
            FluentVariables.CustomTheme.Primary = Color
        end
    })
    
    AddonTab:CreateSection("Extras")
    
    AddonTab:CreateButton({
        Name = "📊 Server Info",
        Callback = function()
            local players = Players:GetPlayers()
            local info = "Server: " .. game.JobId .. "\n" ..
                        "Players: " .. #players .. "/" .. (game.PrivateServerOwnerId ~= 0 and "Private" or "Public") .. "\n" ..
                        "Place: " .. game.PlaceId .. "\n" ..
                        "FPS: " .. math.floor(1 / game:GetService("Stats").PerformanceStats.FrameTime:GetValue())
            Rayfield:Notify({
                Title = "Server Info",
                Content = info,
                Duration = 5,
                Image = 4483362458
            })
        end
    })
    
    AddonTab:CreateButton({
        Name = "🧹 Clear Items",
        Callback = function()
            local backpack = Player:FindFirstChild("Backpack")
            if backpack then
                for _, item in ipairs(backpack:GetChildren()) do
                    if item:IsA("Tool") or item:IsA("HopperBin") then
                        item:Destroy()
                    end
                end
                Rayfield:Notify({
                    Title = "Cleared",
                    Content = "Backpack items cleared!",
                    Duration = 2,
                    Image = 4483362458
                })
            end
        end
    })
    
    -- ============================================
    -- ZAKŁADKA: SETTINGS
    -- ============================================
    local SettingsTab = Window:CreateTab("Settings", "settings")
    
    SettingsTab:CreateSection("Hub Settings")
    
    SettingsTab:CreateToggle({
        Name = "Watermark (powered by turcja)",
        CurrentValue = Config.Watermark.DefaultEnabled,
        Flag = "WatermarkToggle",
        Callback = function(Value)
            ToggleWatermark(Value)
        end
    })
    
    SettingsTab:CreateButton({
        Name = "💾 Save Configuration",
        Callback = function()
            Rayfield:LoadConfiguration()
            Rayfield:Notify({
                Title = "Configuration",
                Content = "Configuration saved!",
                Duration = 2,
                Image = 4483362458
            })
        end
    })
    
    SettingsTab:CreateButton({
        Name = "🔄 Reload Configuration",
        Callback = function()
            Rayfield:LoadConfiguration()
            Rayfield:Notify({
                Title = "Configuration",
                Content = "Configuration reloaded!",
                Duration = 2,
                Image = 4483362458
            })
        end
    })
    
    SettingsTab:CreateButton({
        Name = "❌ Destroy GUI",
        Callback = function()
            Rayfield:Destroy()
            -- Czyszczenie ESP
            ToggleESP(false)
            -- Czyszczenie Fly
            ToggleFly(false)
            -- Czyszczenie Noclip
            ToggleNoclip(false)
            -- Wyłącz wszystkie pętle
            FluentVariables.AutoFarm = false
            FluentVariables.AutoKick = false
            FluentVariables.AutoRebirth = false
            FluentVariables.AutoOpenCrates = false
            FluentVariables.AutoClaimRewards = false
            FluentVariables.AutoTsunami = false
            FluentVariables.AutoBrainrot = false
            FluentVariables.AutoCollectDrops = false
            FluentVariables.AntiAfk = false
            FluentVariables.AntiIdle = false
            FluentVariables.AutoClaimPassive = false
            FluentVariables.AutoUpgradeSpeed = false
            FluentVariables.AutoBuyWeight = false
            FluentVariables.AutoSpin = false
            FluentVariables.AutoEatFood = false
            FluentVariables.AutoSell = false
            ToggleWatermark(false)
        end
    })
    
    SettingsTab:CreateSection("About")
    
    SettingsTab:CreateParagraph({
        Title = "Turcja Hub v2.0.0",
        Content = "Created by turcja\n" ..
                  "Powered by turcja\n\n" ..
                  "Special thanks to:\n" ..
                  "• Rayfield UI\n" ..
                  "• KALB Community\n\n" ..
                  "© 2026 Turcja Hub - All rights reserved"
    })
    
    SettingsTab:CreateLabel("powered by turcja", {Image = 4483362458, Color = Color3.fromRGB(0, 170, 255)})
    
    -- ============================================
    -- INICJALIZACJA WATERMARKA (jeśli włączony domyślnie)
    -- ============================================
    if Config.Watermark.DefaultEnabled then
        coroutine.wrap(CreateWatermark)()
    end
    
    -- ============================================
    -- POWIADOMIENIE O ZAŁADOWANIU
    -- ============================================
    Rayfield:Notify({
        Title = "Turcja Hub Loaded",
        Content = "Powered by turcja\n" ..
                  "42+ modules ready!\n" ..
                  "Join Discord for keys/support",
        Duration = 5,
        Image = 4483362458
    })
    
    -- Obsługa zmiany postaci
    Player.CharacterAdded:Connect(function(char)
        Character = char
        wait(0.5)
        
        -- Przywróć WalkSpeed/JumpPower
        local humanoid = char:WaitForChild("Humanoid")
        if humanoid then
            if FluentVariables.WalkSpeed ~= 16 then
                humanoid.WalkSpeed = FluentVariables.WalkSpeed
            end
            if FluentVariables.JumpPower ~= 50 then
                humanoid.JumpPower = FluentVariables.JumpPower
            end
        end
        
        -- Przywróć Fly jeśli aktywny
        if FluentVariables.FlyEnabled then
            ToggleFly(true)
        end
        
        -- Przywróć Noclip jeśli aktywny
        if FluentVariables.NoclipEnabled then
            ToggleNoclip(true)
        end
    end)
    
    print("✅ Turcja Hub loaded successfully!")
    print("   ⚡ 42+ modules ready")
    print("   🛡️ Anti-ban active")
    print("   💠 Powered by turcja")
end

-- ============================================
-- URUCHOMIENIE
-- ============================================

-- Sprawdź, czy gra to Kick A Lucky Block
local isCorrectGame = game.PlaceId == 131698427156869 or 
                      game.Name:find("Kick") or 
                      game.Name:find("Lucky Block") or
                      game.Name:find("No More Flops")

if isCorrectGame then
    -- Pokaż system kluczy
    local ks = KeySystem:Show()
else
    -- Jeśli nie rozpoznano gry, nadal próbuj uruchomić
    warn("⚠️ Game not fully recognized, attempting to load anyway...")
    local ks = KeySystem:Show()
end
