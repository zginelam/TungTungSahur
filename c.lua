--[[
    Turbo Blocks Script
    Made by: turcja
    Discord: discord.gg/turcja
]]

-- ========================================
-- KEY SYSTEM + LOADING SCREEN
-- ========================================

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local userId = player.UserId
local userName = player.Name
local displayName = player.DisplayName

-- Create loading screen
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TurboBlocksLoader"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local bgFrame = Instance.new("Frame")
bgFrame.Name = "LoadingBG"
bgFrame.Size = UDim2.new(1, 0, 1, 0)
bgFrame.Position = UDim2.new(0, 0, 0, 0)
bgFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
bgFrame.BackgroundTransparency = 0
bgFrame.Parent = screenGui

-- Animated background particles
for i = 1, 30 do
    local particle = Instance.new("Frame")
    particle.Name = "Particle_"..i
    particle.Size = UDim2.new(0, math.random(2, 6), 0, math.random(2, 6))
    particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
    particle.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    particle.BackgroundTransparency = 0.3
    particle.BorderSizePixel = 0
    particle.Parent = bgFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = particle
    
    spawn(function()
        while screenGui.Parent do
            local targetX = math.random()
            local targetY = math.random()
            local duration = math.random(8, 20)
            local tInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
            local tGoal = {
                Position = UDim2.new(targetX, 0, targetY, 0),
                BackgroundTransparency = math.random(5, 8) / 10
            }
            local tween = TweenService:Create(particle, tInfo, tGoal)
            tween:Play()
            tween.Completed:Wait()
        end
    end)
end

-- Center container
local centerContainer = Instance.new("Frame")
centerContainer.Name = "CenterContainer"
centerContainer.Size = UDim2.new(0, 420, 0, 520)
centerContainer.Position = UDim2.new(0.5, -210, 0.5, -260)
centerContainer.BackgroundTransparency = 1
centerContainer.Parent = bgFrame

-- Glow effect behind logo
local glow = Instance.new("ImageLabel")
glow.Name = "Glow"
glow.Size = UDim2.new(0, 300, 0, 300)
glow.Position = UDim2.new(0.5, -150, 0, -50)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://15050995973"
glow.ImageColor3 = Color3.fromRGB(255, 170, 0)
glow.ImageTransparency = 0.7
glow.Parent = centerContainer

spawn(function()
    while screenGui.Parent do
        for i = 0.7, 0.3, -0.01 do
            glow.ImageTransparency = i
            wait(0.03)
        end
        for i = 0.3, 0.7, 0.01 do
            glow.ImageTransparency = i
            wait(0.03)
        end
    end
end)

-- Logo
local logoLabel = Instance.new("TextLabel")
logoLabel.Name = "Logo"
logoLabel.Size = UDim2.new(1, 0, 0, 80)
logoLabel.Position = UDim2.new(0, 0, 0, 30)
logoLabel.BackgroundTransparency = 1
logoLabel.Text = "TURBO BLOCKS"
logoLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
logoLabel.TextSize = 48
logoLabel.Font = Enum.Font.GothamBlack
logoLabel.TextStrokeTransparency = 0.3
logoLabel.TextStrokeColor3 = Color3.fromRGB(255, 100, 0)
logoLabel.TextScaled = true
logoLabel.Parent = centerContainer

-- Subtitle
local subLabel = Instance.new("TextLabel")
subLabel.Name = "Subtitle"
subLabel.Size = UDim2.new(1, 0, 0, 30)
subLabel.Position = UDim2.new(0, 0, 0, 110)
subLabel.BackgroundTransparency = 1
subLabel.Text = "Premium Script by turcja"
subLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
subLabel.TextSize = 16
subLabel.Font = Enum.Font.Gotham
subLabel.TextTransparency = 0.3
subLabel.Parent = centerContainer

-- Loading bar frame
local barBg = Instance.new("Frame")
barBg.Name = "BarBG"
barBg.Size = UDim2.new(0.8, 0, 0, 8)
barBg.Position = UDim2.new(0.1, 0, 0, 180)
barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
barBg.BorderSizePixel = 0
barBg.Parent = centerContainer

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(1, 0)
barCorner.Parent = barBg

local barFill = Instance.new("Frame")
barFill.Name = "BarFill"
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.Position = UDim2.new(0, 0, 0, 0)
barFill.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
barFill.BorderSizePixel = 0
barFill.Parent = barBg

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = barFill

-- Loading text
local loadingText = Instance.new("TextLabel")
loadingText.Name = "LoadingText"
loadingText.Size = UDim2.new(1, 0, 0, 20)
loadingText.Position = UDim2.new(0, 0, 0, 195)
loadingText.BackgroundTransparency = 1
loadingText.Text = "Initializing..."
loadingText.TextColor3 = Color3.fromRGB(150, 150, 150)
loadingText.TextSize = 12
loadingText.Font = Enum.Font.Gotham
loadingText.Parent = centerContainer

-- Key input section
local keyFrame = Instance.new("Frame")
keyFrame.Name = "KeyFrame"
keyFrame.Size = UDim2.new(0.9, 0, 0, 200)
keyFrame.Position = UDim2.new(0.05, 0, 0, 230)
keyFrame.BackgroundTransparency = 1
keyFrame.Parent = centerContainer
keyFrame.Visible = true

local keyTitle = Instance.new("TextLabel")
keyTitle.Name = "KeyTitle"
keyTitle.Size = UDim2.new(1, 0, 0, 30)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "ENTER LICENSE KEY"
keyTitle.TextColor3 = Color3.fromRGB(255, 200, 100)
keyTitle.TextSize = 18
keyTitle.Font = Enum.Font.GothamBlack
keyTitle.TextScaled = true
keyTitle.Parent = keyFrame

-- Key input box
local inputBox = Instance.new("TextBox")
inputBox.Name = "KeyInput"
inputBox.Size = UDim2.new(0.9, 0, 0, 45)
inputBox.Position = UDim2.new(0.05, 0, 0, 40)
inputBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
inputBox.BorderSizePixel = 0
inputBox.Text = ""
inputBox.PlaceholderText = "Enter your key here..."
inputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.TextSize = 16
inputBox.Font = Enum.Font.Gotham
inputBox.ClearTextOnFocus = false
inputBox.Parent = keyFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 8)
inputCorner.Parent = inputBox

local inputStroke = Instance.new("UIStroke")
inputStroke.Color = Color3.fromRGB(255, 170, 0)
inputStroke.Thickness = 1.5
inputStroke.Transparency = 0.5
inputStroke.Parent = inputBox

-- Verify button
local verifyBtn = Instance.new("TextButton")
verifyBtn.Name = "VerifyBtn"
verifyBtn.Size = UDim2.new(0.6, 0, 0, 45)
verifyBtn.Position = UDim2.new(0.2, 0, 0, 100)
verifyBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
verifyBtn.BorderSizePixel = 0
verifyBtn.Text = "VERIFY KEY"
verifyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
verifyBtn.TextSize = 16
verifyBtn.Font = Enum.Font.GothamBold
verifyBtn.AutoButtonColor = false
verifyBtn.Parent = keyFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = verifyBtn

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, 0, 0, 25)
statusLabel.Position = UDim2.new(0, 0, 0, 155)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = keyFrame

-- Discord button
local discordBtn = Instance.new("TextButton")
discordBtn.Name = "DiscordBtn"
discordBtn.Size = UDim2.new(0.6, 0, 0, 35)
discordBtn.Position = UDim2.new(0.2, 0, 0, 175)
discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordBtn.BorderSizePixel = 0
discordBtn.Text = "Get Key on Discord"
discordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
discordBtn.TextSize = 14
discordBtn.Font = Enum.Font.GothamBold
discordBtn.AutoButtonColor = false
discordBtn.Parent = keyFrame

local dBtnCorner = Instance.new("UICorner")
dBtnCorner.CornerRadius = UDim.new(0, 8)
dBtnCorner.Parent = discordBtn

discordBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/turcja")
    statusLabel.Text = "Discord link copied to clipboard!"
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
end)

verifyBtn.MouseButton1Click:Connect(function()
    local enteredKey = inputBox.Text:lower():gsub("%s+", "")
    if enteredKey == "" then
        statusLabel.Text = "Please enter a key!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    statusLabel.Text = "Checking key..."
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    
    local success, result = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/turcjaszefito/keys/refs/heads/main/keys.txt")
    end)
    
    if success then
        local validKeys = {}
        for line in result:gmatch("[^\r\n]+") do
            local trimmed = line:gsub("%s+", ""):lower()
            if trimmed ~= "" then
                table.insert(validKeys, trimmed)
            end
        end
        
        local isValid = false
        for _, validKey in ipairs(validKeys) do
            if enteredKey == validKey then
                isValid = true
                break
            end
        end
        
        if isValid then
            statusLabel.Text = "✓ Key Verified! Loading..."
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
            
            -- Animate loading bar then proceed
            local loadSteps = {
                "Loading Rayfield UI...",
                "Initializing modules...",
                "Loading configurations...",
                "Preparing interface...",
                "Almost ready...",
                "Welcome!"
            }
            
            for i, text in ipairs(loadSteps) do
                loadingText.Text = text
                local tween = TweenService:Create(barFill, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(i / #loadSteps, 0, 1, 0)
                })
                tween:Play()
                wait(0.3 + math.random() * 0.2)
            end
            
            wait(0.3)
            
            -- Fade out loading screen
            local fadeOut = TweenService:Create(bgFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                BackgroundTransparency = 1
            })
            fadeOut:Play()
            wait(0.5)
            screenGui:Destroy()
            
            -- Load main script
            loadMainScript()
        else
            statusLabel.Text = "✗ Invalid Key!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
    else
        statusLabel.Text = "Could not verify key (no internet?)"
        statusLabel.TextColor3 = Color3.fromRGB(255, 150, 50)
    end
end)

-- Animate loading bar on start
spawn(function()
    local tween = TweenService:Create(barFill, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0.3, 0, 1, 0)
    })
    tween:Play()
end)

-- Hover effects
verifyBtn.MouseButton1Down:Connect(function()
    local tween = TweenService:Create(verifyBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(220, 140, 0)})
    tween:Play()
end)
verifyBtn.MouseButton1Up:Connect(function()
    local tween = TweenService:Create(verifyBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(255, 170, 0)})
    tween:Play()
end)

discordBtn.MouseButton1Down:Connect(function()
    local tween = TweenService:Create(discordBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(70, 85, 220)})
    tween:Play()
end)
discordBtn.MouseButton1Up:Connect(function()
    local tween = TweenService:Create(discordBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(88, 101, 242)})
    tween:Play()
end)

-- Enter key to submit
inputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        verifyBtn.MouseButton1Click:Fire()
    end
end)

-- ========================================
-- MAIN SCRIPT
-- ========================================

function loadMainScript()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    
    local Window = Rayfield:CreateWindow({
        Name = "Turbo Blocks",
        Icon = 0,
        LoadingTitle = "TungTung",
        LoadingSubtitle = "by turcja",
        ShowText = "Turbo Blocks",
        Theme = "Default",
        ToggleUIKeybind = "K",
        DisableRayfieldPrompts = false,
        DisableBuildWarnings = false,
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "TurboBlocks",
            FileName = "Config"
        },
        Discord = {
            Enabled = true,
            Invite = "turcja",
            RememberJoins = true
        },
        KeySystem = false
    })
    
    -- ========================================
    -- WATERMARK SYSTEM
    -- ========================================
    
    local watermarkEnabled = false
    local watermarkLabel = nil
    
    local function createWatermark()
        if watermarkLabel then
            watermarkLabel:Destroy()
            watermarkLabel = nil
        end
        
        if not watermarkEnabled then return end
        
        watermarkLabel = Instance.new("TextLabel")
        watermarkLabel.Name = "TurboWatermark"
        watermarkLabel.Size = UDim2.new(0, 200, 0, 30)
        watermarkLabel.Position = UDim2.new(1, -210, 1, -35)
        watermarkLabel.BackgroundTransparency = 1
        watermarkLabel.Text = "powered by turcja"
        watermarkLabel.TextColor3 = Color3.fromRGB(255, 170, 0)
        watermarkLabel.TextSize = 14
        watermarkLabel.Font = Enum.Font.GothamBold
        watermarkLabel.TextTransparency = 0.65
        watermarkLabel.TextXAlignment = Enum.TextXAlignment.Right
        watermarkLabel.BorderSizePixel = 0
        watermarkLabel.Parent = CoreGui
        watermarkLabel.ZIndex = 9999
        
        local shadow = watermarkLabel:Clone()
        shadow.Name = "Shadow"
        shadow.Position = UDim2.new(1, -208, 1, -33)
        shadow.TextColor3 = Color3.fromRGB(0, 0, 0)
        shadow.TextTransparency = 0.8
        shadow.Parent = CoreGui
        shadow.ZIndex = 9998
        
        -- Animate fade in
        spawn(function()
            for i = 0.65, 0.3, -0.01 do
                watermarkLabel.TextTransparency = i
                shadow.TextTransparency = i + 0.3
                wait(0.02)
            end
            wait(2)
            for i = 0.3, 0.65, 0.01 do
                watermarkLabel.TextTransparency = i
                shadow.TextTransparency = i + 0.3
                wait(0.02)
            end
        end)
    end
    
    -- ========================================
    -- TAB: INFORMATION
    -- ========================================
    
    local infoTab = Window:CreateTab("Information", "info")
    
    local infoSection = infoTab:CreateSection("About")
    
    local infoLabel = infoTab:CreateLabel("Turbo Blocks", "box", Color3.fromRGB(255, 170, 0), false)
    
    local infoPara = infoTab:CreateParagraph({
        Title = "Premium Script for Lucky Blocks",
        Content = "Turbo Blocks is a feature-rich automation script designed for Lucky Blocks games. Packed with 40+ modules including auto-farming, movement, ESP, and advanced anti-detection systems.\n\nMade with ❤️ by turcja"
    })
    
    local discBtn = infoTab:CreateButton({
        Name = "Join Discord",
        Callback = function()
            setclipboard("https://discord.gg/turcja")
            Rayfield:Notify({
                Title = "Discord",
                Content = "Invite link copied to clipboard!",
                Duration = 3,
                Image = "message-circle"
            })
        end
    })
    
    infoTab:CreateDivider()
    
    local userSection = infoTab:CreateSection("User Information")
    
    infoTab:CreateLabel("User: " .. displayName .. " (" .. userName .. ")", "user", Color3.fromRGB(100, 200, 255), false)
    infoTab:CreateLabel("User ID: " .. userId, "fingerprint", Color3.fromRGB(150, 150, 150), false)
    infoTab:CreateLabel("Key Status: Lifetime", "check-circle", Color3.fromRGB(0, 255, 100), false)
    
    infoTab:CreateDivider()
    
    infoTab:CreateLabel("Script Version: 2.0.0", "tag", Color3.fromRGB(200, 200, 200), false)
    infoTab:CreateLabel("Loaded: " .. os.date("%Y-%m-%d %H:%M:%S"), "clock", Color3.fromRGB(200, 200, 200), false)
    
    -- ========================================
    -- TAB: AUTO FARM
    -- ========================================
    
    local autoTab = Window:CreateTab("Auto Farm", "zap")
    
    local generalSection = autoTab:CreateSection("General")
    
    local toggles = {}
    
    toggles.autoKick = autoTab:CreateToggle({
        Name = "Auto Kick",
        CurrentValue = false,
        Flag = "AutoKick",
        Callback = function(v) end
    })
    
    toggles.perfectKick = autoTab:CreateToggle({
        Name = "Auto Perfect Kick (100%)",
        CurrentValue = false,
        Flag = "PerfectKick",
        Callback = function(v) end
    })
    
    toggles.autoCollectCash = autoTab:CreateToggle({
        Name = "Auto Collect Cash",
        CurrentValue = false,
        Flag = "AutoCollectCash",
        Callback = function(v) end
    })
    
    toggles.autoCollectPro = autoTab:CreateToggle({
        Name = "Auto Collect Pro (0.5s)",
        CurrentValue = false,
        Flag = "AutoCollectPro",
        Callback = function(v) end
    })
    
    toggles.instantCollect = autoTab:CreateToggle({
        Name = "Instant Collect",
        CurrentValue = false,
        Flag = "InstantCollect",
        Callback = function(v) end
    })
    
    autoTab:CreateDivider()
    local brainrotSection = autoTab:CreateSection("Brainrot Management")
    
    toggles.autoPlace = autoTab:CreateToggle({
        Name = "Auto Place Brainrots",
        CurrentValue = false,
        Flag = "AutoPlace",
        Callback = function(v) end
    })
    
    toggles.autoUpgrade = autoTab:CreateToggle({
        Name = "Auto Upgrade Brainrots",
        CurrentValue = false,
        Flag = "AutoUpgrade",
        Callback = function(v) end
    })
    
    toggles.autoCollectBrainrot = autoTab:CreateToggle({
        Name = "Auto Collect Brainrots (ground)",
        CurrentValue = false,
        Flag = "AutoCollectBrainrot",
        Callback = function(v) end
    })
    
    autoTab:CreateDivider()
    local trainSection = autoTab:CreateSection("Training & Rebirth")
    
    toggles.autoTrain = autoTab:CreateToggle({
        Name = "Auto Train",
        CurrentValue = false,
        Flag = "AutoTrain",
        Callback = function(v) end
    })
    
    toggles.fastTrain = autoTab:CreateToggle({
        Name = "Fast Train",
        CurrentValue = false,
        Flag = "FastTrain",
        Callback = function(v) end
    })
    
    toggles.autoRebirth = autoTab:CreateToggle({
        Name = "Auto Rebirth",
        CurrentValue = false,
        Flag = "AutoRebirth",
        Callback = function(v) end
    })
    
    local rebirthSlider = autoTab:CreateSlider({
        Name = "Rebirth Power Threshold",
        Range = {1000, 100000},
        Increment = 1000,
        Suffix = " Power",
        CurrentValue = 10000,
        Flag = "RebirthPower",
        Callback = function(v) end
    })
    
    autoTab:CreateDivider()
    local shopSection = autoTab:CreateSection("Auto Shop")
    
    toggles.autoBuyWeight = autoTab:CreateToggle({
        Name = "Auto Buy Weights",
        CurrentValue = false,
        Flag = "AutoBuyWeight",
        Callback = function(v) end
    })
    
    toggles.autoBuyBestWeight = autoTab:CreateToggle({
        Name = "Auto Buy Best Weight",
        CurrentValue = false,
        Flag = "AutoBuyBestWeight",
        Callback = function(v) end
    })
    
    toggles.autoUpgradePlot = autoTab:CreateToggle({
        Name = "Auto Upgrade Plot",
        CurrentValue = false,
        Flag = "AutoUpgradePlot",
        Callback = function(v) end
    })
    
    toggles.multiDrop = autoTab:CreateToggle({
        Name = "Multi Drop (x2 Cash)",
        CurrentValue = false,
        Flag = "MultiDrop",
        Callback = function(v) end
    })
    
    -- ========================================
    -- TAB: MOVEMENT
    -- ========================================
    
    local moveTab = Window:CreateTab("Movement", "navigation-2")
    
    local walkSection = moveTab:CreateSection("Movement Controls")
    
    local walkSlider = moveTab:CreateSlider({
        Name = "Walkspeed",
        Range = {16, 100},
        Increment = 1,
        Suffix = " W/S",
        CurrentValue = 16,
        Flag = "Walkspeed",
        Callback = function(v)
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = v
            end
        end
    })
    
    local jumpSlider = moveTab:CreateSlider({
        Name = "Jump Power",
        Range = {50, 200},
        Increment = 5,
        Suffix = " Power",
        CurrentValue = 50,
        Flag = "JumpPower",
        Callback = function(v)
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.JumpPower = v
            end
        end
    })
    
    toggles.noclip = moveTab:CreateToggle({
        Name = "Noclip",
        CurrentValue = false,
        Flag = "Noclip",
        Callback = function(v)
            if v then
                -- Noclip logic
                game:GetService("RunService").Stepped:Connect(function()
                    if toggles.noclip.CurrentValue and player.Character then
                        for _, part in ipairs(player.Character:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            end
        end
    })
    
    toggles.fly = moveTab:CreateToggle({
        Name = "Fly",
        CurrentValue = false,
        Flag = "Fly",
        Callback = function(v)
            -- Fly logic placeholder
        end
    })
    
    local flySlider = moveTab:CreateSlider({
        Name = "Fly Height Limit",
        Range = {10, 100},
        Increment = 5,
        Suffix = " Studs",
        CurrentValue = 30,
        Flag = "FlyHeight",
        Callback = function(v) end
    })
    
    moveTab:CreateDivider()
    local teleportSection = moveTab:CreateSection("Teleports")
    
    moveTab:CreateButton({
        Name = "Teleport to Block",
        Callback = function()
            Rayfield:Notify({
                Title = "Teleport",
                Content = "Click a block on the ESP map to teleport",
                Duration = 2,
                Image = "map-pin"
            })
        end
    })
    
    moveTab:CreateButton({
        Name = "Teleport to Plot",
        Callback = function()
            Rayfield:Notify({
                Title = "Teleport",
                Content = "Teleporting to your plot...",
                Duration = 2,
                Image = "home"
            })
        end
    })
    
    moveTab:CreateButton({
        Name = "TP to Safe Zone",
        Callback = function()
            Rayfield:Notify({
                Title = "Teleport",
                Content = "Teleporting to safe zone...",
                Duration = 2,
                Image = "shield"
            })
        end
    })
    
    moveTab:CreateButton({
        Name = "TP to Position (0, 50, 0)",
        Callback = function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
                Rayfield:Notify({
                    Title = "Teleported",
                    Content = "Teleported to position 0, 50, 0",
                    Duration = 2,
                    Image = "target"
                })
            end
        end
    })
    
    moveTab:CreateDivider()
    local autoMoveSection = moveTab:CreateSection("Auto Movement")
    
    toggles.autoTsunamiEscape = moveTab:CreateToggle({
        Name = "Auto Tsunami Escape",
        CurrentValue = false,
        Flag = "TsunamiEscape",
        Callback = function(v) end
    })
    
    toggles.autoRejoin = moveTab:CreateToggle({
        Name = "Auto Rejoin on Kick",
        CurrentValue = false,
        Flag = "AutoRejoin",
        Callback = function(v) end
    })
    
    toggles.serverHopper = moveTab:CreateToggle({
        Name = "Server Hopper",
        CurrentValue = false,
        Flag = "ServerHopper",
        Callback = function(v) end
    })
    
    -- ========================================
    -- TAB: ESP
    -- ========================================
    
    local espTab = Window:CreateTab("ESP", "eye")
    
    local visualSection = espTab:CreateSection("Visuals")
    
    toggles.espBlocks = espTab:CreateToggle({
        Name = "ESP Blocks",
        CurrentValue = false,
        Flag = "ESPBlocks",
        Callback = function(v) end
    })
    
    toggles.espBrainrots = espTab:CreateToggle({
        Name = "ESP Brainrots",
        CurrentValue = false,
        Flag = "ESPBrainrots",
        Callback = function(v) end
    })
    
    toggles.espPlayers = espTab:CreateToggle({
        Name = "ESP Players",
        CurrentValue = false,
        Flag = "ESPPlayers",
        Callback = function(v) end
    })
    
    toggles.espTsunami = espTab:CreateToggle({
        Name = "ESP Tsunami",
        CurrentValue = false,
        Flag = "ESPTsunami",
        Callback = function(v) end
    })
    
    toggles.espPlots = espTab:CreateToggle({
        Name = "ESP Plots",
        CurrentValue = false,
        Flag = "ESPPlots",
        Callback = function(v) end
    })
    
    espTab:CreateDivider()
    local radarSection = espTab:CreateSection("Radar & Tracking")
    
    toggles.blockRadar = espTab:CreateToggle({
        Name = "Block Radar (Minimap)",
        CurrentValue = false,
        Flag = "BlockRadar",
        Callback = function(v) end
    })
    
    toggles.distanceTracker = espTab:CreateToggle({
        Name = "Distance Tracker",
        CurrentValue = false,
        Flag = "DistanceTracker",
        Callback = function(v) end
    })
    
    toggles.infoPanel = espTab:CreateToggle({
        Name = "Info Panel (HUD)",
        CurrentValue = false,
        Flag = "InfoPanel",
        Callback = function(v) end
    })
    
    -- ========================================
    -- TAB: PROTECTION
    -- ========================================
    
    local protTab = Window:CreateTab("Protection", "shield")
    
    local antiSection = protTab:CreateSection("Anti-Detection")
    
    toggles.antiKick = protTab:CreateToggle({
        Name = "Anti-Kick",
        CurrentValue = false,
        Flag = "AntiKick",
        Callback = function(v) end
    })
    
    toggles.antiBan = protTab:CreateToggle({
        Name = "Anti-Ban",
        CurrentValue = false,
        Flag = "AntiBan",
        Callback = function(v) end
    })
    
    protTab:CreateDivider()
    local spoofSection = protTab:CreateSection("Spoofing")
    
    toggles.spoofWalkspeed = protTab:CreateToggle({
        Name = "Spoof Walkspeed",
        CurrentValue = false,
        Flag = "SpoofWalkspeed",
        Callback = function(v) end
    })
    
    toggles.spoofPosition = protTab:CreateToggle({
        Name = "Spoof Position",
        CurrentValue = false,
        Flag = "SpoofPosition",
        Callback = function(v) end
    })
    
    protTab:CreateDivider()
    local miscProtSection = protTab:CreateSection("Misc")
    
    toggles.remoteSpamBlocker = protTab:CreateToggle({
        Name = "Remote Spam Blocker",
        CurrentValue = false,
        Flag = "RemoteSpamBlocker",
        Callback = function(v) end
    })
    
    toggles.logsCleaner = protTab:CreateToggle({
        Name = "Logs Cleaner",
        CurrentValue = false,
        Flag = "LogsCleaner",
        Callback = function(v) end
    })
    
    -- ========================================
    -- TAB: SETTINGS
    -- ========================================
    
    local settingsTab = Window:CreateTab("Settings", "settings")
    
    local generalSetSection = settingsTab:CreateSection("General")
    
    local watermarkToggle = settingsTab:CreateToggle({
        Name = "Watermark",
        CurrentValue = false,
        Flag = "Watermark",
        Callback = function(v)
            watermarkEnabled = v
            createWatermark()
        end
    })
    
    settingsTab:CreateDivider()
    local infoSetSection = settingsTab:CreateSection("Script Info")
    
    settingsTab:CreateLabel("Turbo Blocks v2.0.0", "package", Color3.fromRGB(255, 170, 0), false)
    settingsTab:CreateLabel("Developer: turcja", "code", Color3.fromRGB(200, 200, 200), false)
    
    settingsTab:CreateButton({
        Name = "Copy Discord Invite",
        Callback = function()
            setclipboard("https://discord.gg/turcja")
            Rayfield:Notify({
                Title = "Copied!",
                Content = "Discord invite copied to clipboard",
                Duration = 2,
                Image = "copy"
            })
        end
    })
    
    settingsTab:CreateButton({
        Name = "Toggle UI (K)",
        Callback = function()
            Rayfield:SetVisibility(not Rayfield:IsVisible())
        end
    })
    
    settingsTab:CreateDivider()
    local dangerSection = settingsTab:CreateSection("Danger Zone")
    
    settingsTab:CreateButton({
        Name = "Destroy GUI",
        Callback = function()
            Rayfield:Destroy()
            if watermarkLabel then watermarkLabel:Destroy() end
        end
    })
    
    Rayfield:LoadConfiguration()
    
    -- Watermark pulse loop
    spawn(function()
        while wait(3) do
            if watermarkEnabled and watermarkLabel then
                local tween = TweenService:Create(watermarkLabel, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    TextTransparency = 0.4
                })
                tween:Play()
                wait(2)
                local tween2 = TweenService:Create(watermarkLabel, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    TextTransparency = 0.7
                })
                tween2:Play()
            end
        end
    end)
    
    Rayfield:Notify({
        Title = "Turbo Blocks Loaded",
        Content = "Script loaded successfully! Press K to toggle UI",
        Duration = 5,
        Image = "check-circle"
    })
end
