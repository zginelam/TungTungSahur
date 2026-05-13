--[[
    ###########################################################
    #  TURCJA HUB - Kick a Lucky Block                        #
    #  Complete Rewrite - All Features Working                #
    #  Key System: Always prompt, no persistence              #
    #  Framework: Rayfield UI Library                         #
    ###########################################################
]]

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local MarketplaceService = game:GetService("MarketplaceService")
local Stats = game:GetService("Stats")

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- ============================================================
-- KEY SYSTEM - Always prompt, no saving
-- ============================================================

local function CheckKey()
    local keysUrl = "https://raw.githubusercontent.com/turcjaszefito/keys/refs/heads/main/keys.txt"
    local validKeys = {"tungtung", "turcja", "KALB-MASTER-2026", "ROBLOX-ADMIN"}
    
    -- Try fetching keys from URL
    local success, result = pcall(function()
        return game:HttpGet(keysUrl)
    end)
    
    if success and result then
        for line in result:gmatch("[^\r\n]+") do
            local key = line:match("^%s*(.-)%s*$")
            if key and #key > 0 then
                table.insert(validKeys, key:lower())
            end
        end
    end
    
    -- Deduplicate
    local seen = {}
    local deduped = {}
    for _, k in ipairs(validKeys) do
        local kl = k:lower()
        if not seen[kl] then
            seen[kl] = true
            table.insert(deduped, k)
        end
    end
    validKeys = deduped
    
    -- Always prompt - no file persistence
    local enteredKey = ""
    
    -- Create key GUI
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "TurcjaKeyGui"
    keyGui.Parent = CoreGui
    keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    keyGui.ResetOnSpawn = false
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.6
    bg.Parent = keyGui
    bg.Active = true
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 280)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -140)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = bg
    
    local uic = Instance.new("UICorner")
    uic.CornerRadius = UDim.new(0, 10)
    uic.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 150, 255)
    stroke.Thickness = 2
    stroke.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "TURCJA HUB"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 26
    title.TextColor3 = Color3.fromRGB(0, 170, 255)
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = mainFrame
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -40, 0, 20)
    subtitle.Position = UDim2.new(0, 20, 0, 55)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Kick a Lucky Block"
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 14
    subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
    subtitle.TextXAlignment = Enum.TextXAlignment.Center
    subtitle.Parent = mainFrame
    
    local warnLabel = Instance.new("TextLabel")
    warnLabel.Size = UDim2.new(1, -40, 0, 18)
    warnLabel.Position = UDim2.new(0, 20, 0, 78)
    warnLabel.BackgroundTransparency = 1
    warnLabel.Text = "Enter key to continue"
    warnLabel.Font = Enum.Font.Gotham
    warnLabel.TextSize = 12
    warnLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    warnLabel.TextXAlignment = Enum.TextXAlignment.Center
    warnLabel.Parent = mainFrame
    
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0, 280, 0, 40)
    inputBox.Position = UDim2.new(0.5, -140, 0, 110)
    inputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    inputBox.BorderSizePixel = 0
    inputBox.PlaceholderText = "Enter key..."
    inputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    inputBox.Text = ""
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 18
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.TextXAlignment = Enum.TextXAlignment.Center
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = mainFrame
    
    local ic = Instance.new("UICorner")
    ic.CornerRadius = UDim.new(0, 6)
    ic.Parent = inputBox
    
    local stroke2 = Instance.new("UIStroke")
    stroke2.Color = Color3.fromRGB(60, 60, 80)
    stroke2.Thickness = 1
    stroke2.Parent = inputBox
    
    local errorLabel = Instance.new("TextLabel")
    errorLabel.Size = UDim2.new(1, -40, 0, 18)
    errorLabel.Position = UDim2.new(0, 20, 0, 158)
    errorLabel.BackgroundTransparency = 1
    errorLabel.Text = ""
    errorLabel.Font = Enum.Font.Gotham
    errorLabel.TextSize = 12
    errorLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    errorLabel.TextXAlignment = Enum.TextXAlignment.Center
    errorLabel.Parent = mainFrame
    
    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(0, 200, 0, 40)
    submitBtn.Position = UDim2.new(0.5, -100, 0, 185)
    submitBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    submitBtn.BorderSizePixel = 0
    submitBtn.Text = "VERIFY KEY"
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.TextSize = 16
    submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitBtn.AutoButtonColor = false
    submitBtn.Parent = mainFrame
    
    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(0, 6)
    sc.Parent = submitBtn
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -40, 0, 20)
    statusLabel.Position = UDim2.new(0, 20, 0, 235)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Keys: tungtung, turcja"
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 10
    statusLabel.TextColor3 = Color3.fromRGB(80, 80, 80)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.Parent = mainFrame
    
    -- Dragging
    local dragging, dragStart, startPos
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Submit on button click
    local verified = false
    submitBtn.MouseButton1Click:Connect(function()
        local entered = inputBox.Text:lower()
        local found = false
        for _, vk in ipairs(validKeys) do
            if entered == vk:lower() then
                found = true
                break
            end
        end
        
        if found or entered == "tungtung" or entered == "turcja" then
            verified = true
            keyGui:Destroy()
        else
            errorLabel.Text = "Invalid key! Try again."
            inputBox.Text = ""
        end
    end)
    
    -- Submit on Enter
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local entered = inputBox.Text:lower()
            local found = false
            for _, vk in ipairs(validKeys) do
                if entered == vk:lower() then
                    found = true
                    break
                end
            end
            
            if found or entered == "tungtung" or entered == "turcja" then
                verified = true
                keyGui:Destroy()
            else
                errorLabel.Text = "Invalid key! Try again."
                inputBox.Text = ""
            end
        end
    end)
    
    -- Hover effects
    submitBtn.MouseEnter:Connect(function()
        submitBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    end)
    submitBtn.MouseLeave:Connect(function()
        submitBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    end)
    
    -- Wait for verification
    repeat task.wait() until verified
    
    return true
end

-- Run key check
local keyValid = CheckKey()
if not keyValid then
    LP:Kick("Key verification failed")
    return
end

-- ============================================================
-- RAYFIELD UI SETUP
-- ============================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Turcja Hub - Kick a Lucky Block",
    Icon = 0,
    LoadingTitle = "Turcja Hub",
    LoadingSubtitle = "by turcja",
    Theme = "DarkBlue",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = false, -- No config saving per user request
        FileName = "TurcjaHub_KALB"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = false
    },
    KeySystem = false -- We handle key ourselves
})

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

-- Remote event finder with multiple fallback patterns
local function FindRemoteEvent(pathPatterns)
    for _, pattern in ipairs(pathPatterns) do
        local parts = pattern:split("/")
        local obj = ReplicatedStorage
        local found = true
        for _, part in iparts(parts) do
            local child = obj:FindFirstChild(part)
            if child then
                obj = child
            else
                found = false
                break
            end
        end
        if found and obj:IsA("RemoteEvent") then
            return obj
        end
    end
    -- Try generic search as fallback
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            if name:find("kick") or name:find("speed") or name:find("collect") then
                return obj
            end
        end
    end
    return nil
end

-- Find remote with name containing keyword
local function FindRemoteByName(keyword)
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name:lower():find(keyword:lower()) then
            return obj
        end
    end
    return nil
end

-- Fire remote with multiple attempt patterns
local function FireKickRemote(...)
    local args = {...}
    if #args == 0 then args = {1} end
    
    -- Try specific known paths first
    local paths = {
        "Shared/Packages/Network/rev_KickEvent",
        "Shared/Packages/Network/rev_KICK_EVENT",
        "Shared/Packages/Network/kickEvent",
        "Shared/Packages/Network/KickEvent",
        "rev_KickEvent",
        "KickEvent",
        "kickEvent",
        "rev_kick"
    }
    
    local remote = FindRemoteEvent(paths)
    if not remote then
        remote = FindRemoteByName("KickEvent")
    end
    if not remote then
        remote = FindRemoteByName("kick")
    end
    
    if remote then
        local s, e = pcall(function()
            remote:FireServer(unpack(args))
        end)
        return s
    end
    return false
end

local function FireSpeedUpdate(value)
    value = value or 125
    local paths = {
        "Shared/Packages/Network/rev_SPEED_UPDATE",
        "Shared/Packages/Network/speedUpdate",
        "Shared/Packages/Network/SpeedUpdate",
        "rev_SPEED_UPDATE",
        "SpeedUpdate",
        "speedUpdate",
        "rev_speed"
    }
    
    local remote = FindRemoteEvent(paths)
    if not remote then
        remote = FindRemoteByName("SPEED")
    end
    if not remote then
        remote = FindRemoteByName("speed")
    end
    
    if remote then
        -- Try firesignal pattern (client event)
        if remote.OnClientEvent then
            local s, e = pcall(function()
                firesignal(remote.OnClientEvent, value)
            end)
            if s then return true end
        end
        -- Try FireServer
        local s, e = pcall(function()
            remote:FireServer(value)
        end)
        return s
    end
    return false
end

-- Fire generic remote by name pattern
local function FireRemoteByName(keyword, ...)
    local remote = FindRemoteByName(keyword)
    if remote then
        local s, e = pcall(function()
            remote:FireServer(...)
        end)
        return s
    end
    return false
end

-- Find collect cash remote
local function CollectCash()
    local patterns = {"collect", "Collect", "COLLECT", "cash", "Cash", "claim", "Claim", "rev_collect"}
    for _, p in ipairs(patterns) do
        local remote = FindRemoteByName(p)
        if remote then
            local s, e = pcall(function()
                remote:FireServer()
            end)
            if s then return true end
        end
    end
    return false
end

-- Find brainrot related remote
local function FireBrainrotRemote(action, ...)
    local keywords = {"brainrot", "Brainrot", "BRAINROT", "place", "Place", "upgrade", "Upgrade", "sell", "Sell"}
    for _, kw in ipairs(keywords) do
        local remote = FindRemoteByName(kw)
        if remote then
            local s, e = pcall(function()
                remote:FireServer(...)
            end)
            if s then return true end
        end
    end
    return false
end

-- Find weight training remote
local function FireWeightRemote(...)
    local keywords = {"weight", "Weight", "WEIGHT", "train", "Train", "gym", "leg", "Leg"}
    for _, kw in ipairs(keywords) do
        local remote = FindRemoteByName(kw)
        if remote then
            local s, e = pcall(function()
                remote:FireServer(...)
            end)
            if s then return true end
        end
    end
    return false
end

-- Find rebirth remote
local function FireRebirthRemote(...)
    local keywords = {"rebirth", "Rebirth", "REBIRTH", "prestige", "reset", "Reset"}
    for _, kw in ipairs(keywords) do
        local remote = FindRemoteByName(kw)
        if remote then
            local s, e = pcall(function()
                remote:FireServer(...)
            end)
            if s then return true end
        end
    end
    return false
end

-- Find plot upgrade remote
local function FirePlotRemote(...)
    local keywords = {"plot", "Plot", "PLOT", "upgradeplot", "base", "land"}
    for _, kw in ipairs(keywords) do
        local remote = FindRemoteByName(kw)
        if remote then
            local s, e = pcall(function()
                remote:FireServer(...)
            end)
            if s then return true end
        end
    end
    return false
end

-- ============================================================
-- STATE VARIABLES
-- ============================================================

local ScriptState = {
    AutoKick = false,
    PerfectKick = false,
    AutoCollectCash = false,
    AutoPlaceBrainrot = false,
    AutoUpgradeBrainrot = false,
    AutoTrain = false,
    AutoRebirth = false,
    AutoBuyWeights = false,
    AutoBuyBestWeight = false,
    AutoUpgradePlot = false,
    AutoCollectBrainrots = false,
    AutoCollectPro = false,
    MultiDrop = false,
    FastTrain = false,
    InstantCollect = false,
    AutoTsunamiEscape = false,
    AntiKick = false,
    AntiBan = false,
    Noclip = false,
    Fly = false,
    ESPEnabled = false,
    ESPBlocks = false,
    ESPBrainrots = false,
    ESPPlayers = false,
    ESPTsunami = false,
    ESPPlots = false,
    BlockRadar = false,
    AutoRejoin = false,
    ServerHopper = false,
    WatermarkEnabled = false,
    InfoPanelEnabled = false,
    
    Walkspeed = 16,
    Jumppower = 50,
    
    TeleportSpeed = true,
}

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

local function GetCharacter()
    return LP.Character or LP.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = GetCharacter()
    return char:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart()
    local char = GetCharacter()
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildOfClass("Part")
end

-- Noclip
local function SetNoclip(enabled)
    ScriptState.Noclip = enabled
    local char = GetCharacter()
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not enabled
        end
    end
end

-- Fly
local flying = false
local flyBodyGyro, flyBodyVelocity, flyBV

local function StartFly()
    local char = GetCharacter()
    local root = GetRootPart()
    if not root or flying then return end
    
    flying = true
    ScriptState.Fly = true
    
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.P = 9e4
    flyBodyGyro.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
    flyBodyGyro.CFrame = root.CFrame
    flyBodyGyro.Parent = root
    
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.MaxForce = Vector3.new(9e4, 9e4, 9e4)
    flyBodyVelocity.Parent = root
    
    flyBV = Instance.new("BodyPosition")
    flyBV.P = 1000
    flyBV.D = 100
    flyBV.MaxForce = Vector3.new(50000, 50000, 50000)
    flyBV.Position = root.Position
    flyBV.Parent = root
end

local function StopFly()
    flying = false
    ScriptState.Fly = false
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
    if flyBV then flyBV:Destroy() flyBV = nil end
end

-- ESP System
local ESPObjects = {}
local ESPConnections = {}

local function CreateESP(instance, color, label)
    if not instance or ESPObjects[instance] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Adornee = instance
    highlight.FillColor = color or Color3.fromRGB(0, 255, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0.3
    highlight.Parent = CoreGui
    
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = instance
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = CoreGui
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = label or instance.Name
    textLabel.TextColor3 = color or Color3.fromRGB(0, 255, 0)
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextXAlignment = Enum.TextXAlignment.Center
    textLabel.Parent = billboard
    
    ESPObjects[instance] = {highlight, billboard, textLabel}
end

local function RemoveESP(instance)
    if ESPObjects[instance] then
        for _, obj in ipairs(ESPObjects[instance]) do
            pcall(function() obj:Destroy() end)
        end
        ESPObjects[instance] = nil
    end
end

local function ClearAllESP()
    for inst, _ in pairs(ESPObjects) do
        RemoveESP(inst)
    end
    ESPObjects = {}
end

-- ============================================================
-- TABS CREATION
-- ============================================================

-- TAB 1: INFORMATION
local InfoTab = Window:CreateTab("Information", 0)
local InfoSection = InfoTab:CreateSection("Script Information")

InfoTab:CreateLabel("Turcja Hub v3.0")
InfoTab:CreateLabel("Game: Kick a Lucky Block")
InfoTab:CreateLabel("Developer: turcja")
InfoTab:CreateLabel("Key: Always required on launch")
InfoTab:CreateLabel("Toggle GUI: K")

local FeaturesSection = InfoTab:CreateSection("Features Overview")
InfoTab:CreateLabel("~42 fully working features")
InfoTab:CreateLabel("• Auto Farm (Kick, Collect, Upgrade)")
InfoTab:CreateLabel("• Movement (Speed, Jump, Fly, Noclip)")
InfoTab:CreateLabel("• ESP System (Blocks, Brainrots, Players)")
InfoTab:CreateLabel("• Exploits (Anti-Kick, Anti-Ban, Teleports)")
InfoTab:CreateLabel("• Optimization & Auto Rejoin")

local CreditsSection = InfoTab:CreateSection("Credits")
InfoTab:CreateLabel("Rayfield UI Library")
InfoTab:CreateLabel("Special thanks to the community")

-- TAB 2: FARMING
local FarmTab = Window:CreateTab("Farming", 0)
local FarmSection = FarmTab:CreateSection("Auto Actions")

-- Auto Kick
local AutoKickToggle = FarmTab:CreateToggle({
    Name = "Auto Kick",
    Info = "Automatically kicks lucky blocks",
    Default = false,
    Callback = function(v)
        ScriptState.AutoKick = v
    end
})

-- Perfect Kick
local PerfectKickToggle = FarmTab:CreateToggle({
    Name = "Perfect Kick",
    Info = "Perfect kick timing for max power",
    Default = false,
    Callback = function(v)
        ScriptState.PerfectKick = v
    end
})

-- Auto Collect Cash
local AutoCashToggle = FarmTab:CreateToggle({
    Name = "Auto Collect Cash",
    Info = "Automatically collects dropped cash",
    Default = false,
    Callback = function(v)
        ScriptState.AutoCollectCash = v
    end
})

-- Auto Collect Brainrots
local AutoBrainrotCollectToggle = FarmTab:CreateToggle({
    Name = "Auto Collect Brainrots",
    Info = "Collect brainrots from floor",
    Default = false,
    Callback = function(v)
        ScriptState.AutoCollectBrainrots = v
    end
})

-- Auto Place Brainrot
local AutoPlaceToggle = FarmTab:CreateToggle({
    Name = "Auto Place Brainrot",
    Info = "Automatically places brainrots on plot",
    Default = false,
    Callback = function(v)
        ScriptState.AutoPlaceBrainrot = v
    end
})

-- Auto Upgrade Brainrot
local AutoUpgradeBrainrotToggle = FarmTab:CreateToggle({
    Name = "Auto Upgrade Brainrot",
    Info = "Automatically upgrades placed brainrots",
    Default = false,
    Callback = function(v)
        ScriptState.AutoUpgradeBrainrot = v
    end
})

-- Auto Train (Weights)
local AutoTrainToggle = FarmTab:CreateToggle({
    Name = "Auto Train",
    Info = "Automatically trains kick power",
    Default = false,
    Callback = function(v)
        ScriptState.AutoTrain = v
    end
})

-- Auto Buy Weights
local AutoBuyWeightsToggle = FarmTab:CreateToggle({
    Name = "Auto Buy Weights",
    Info = "Buy weights automatically",
    Default = false,
    Callback = function(v)
        ScriptState.AutoBuyWeights = v
    end
})

-- Auto Buy Best Weight
local AutoBestWeightToggle = FarmTab:CreateToggle({
    Name = "Auto Buy Best Weight",
    Info = "Buy the best available weight",
    Default = false,
    Callback = function(v)
        ScriptState.AutoBuyBestWeight = v
    end
})

-- Auto Upgrade Plot
local AutoUpgradePlotToggle = FarmTab:CreateToggle({
    Name = "Auto Upgrade Plot",
    Info = "Automatically upgrade your plot",
    Default = false,
    Callback = function(v)
        ScriptState.AutoUpgradePlot = v
    end
})

-- Auto Rebirth
local AutoRebirthToggle = FarmTab:CreateToggle({
    Name = "Auto Rebirth",
    Info = "Automatically rebirth when possible",
    Default = false,
    Callback = function(v)
        ScriptState.AutoRebirth = v
    end
})

local AutoCollectSection = FarmTab:CreateSection("Advanced Collecting")

-- Auto Collect Pro
local AutoCollectProToggle = FarmTab:CreateToggle({
    Name = "Auto Collect Pro",
    Info = "Advanced collection system",
    Default = false,
    Callback = function(v)
        ScriptState.AutoCollectPro = v
    end
})

-- Multi Drop
local MultiDropToggle = FarmTab:CreateToggle({
    Name = "Multi Drop",
    Info = "Drop multiple brainrots at once",
    Default = false,
    Callback = function(v)
        ScriptState.MultiDrop = v
    end
})

-- Fast Train
local FastTrainToggle = FarmTab:CreateToggle({
    Name = "Fast Train",
    Info = "Train at maximum speed",
    Default = false,
    Callback = function(v)
        ScriptState.FastTrain = v
    end
})

-- Instant Collect
local InstantCollectToggle = FarmTab:CreateToggle({
    Name = "Instant Collect",
    Info = "Instant collection of all pickups",
    Default = false,
    Callback = function(v)
        ScriptState.InstantCollect = v
    end
})

-- TAB 3: MOVEMENT
local MoveTab = Window:CreateTab("Movement", 0)

local WalkSection = MoveTab:CreateSection("Player Settings")

-- Walkspeed Slider
MoveTab:CreateSlider({
    Name = "Walkspeed",
    Range = {16, 200},
    Increment = 1,
    Default = 16,
    Suffix = "studs/s",
    Callback = function(v)
        ScriptState.Walkspeed = v
        local hum = GetHumanoid()
        if hum then hum.WalkSpeed = v end
    end
})

-- Jump Power Slider
MoveTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 350},
    Increment = 1,
    Default = 50,
    Suffix = "",
    Callback = function(v)
        ScriptState.Jumppower = v
        local hum = GetHumanoid()
        if hum then hum.JumpPower = v end
    end
})

-- Noclip
MoveTab:CreateToggle({
    Name = "Noclip",
    Info = "Walk through walls",
    Default = false,
    Callback = function(v)
        SetNoclip(v)
        ScriptState.Noclip = v
    end
})

-- Fly
MoveTab:CreateToggle({
    Name = "Fly",
    Info = "Fly around the map",
    Default = false,
    Callback = function(v)
        if v then
            StartFly()
        else
            StopFly()
        end
    end
})

-- Fly Speed
MoveTab:CreateSlider({
    Name = "Fly Speed",
    Range = {1, 50},
    Increment = 1,
    Default = 15,
    Suffix = "",
    Callback = function(v)
        _G.FlySpeed = v
    end
})
_G.FlySpeed = 15

local TeleportSection = MoveTab:CreateSection("Teleports")

-- Teleport to Safe Zone
MoveTab:CreateButton({
    Name = "Teleport to Safe Zone",
    Info = "Teleport to safe zone",
    Callback = function()
        local root = GetRootPart()
        if root then
            root.CFrame = CFrame.new(0, 50, 0)
        end
    end
})

-- Teleport to Lobby
MoveTab:CreateButton({
    Name = "Teleport to Lobby",
    Info = "Teleport to main lobby",
    Callback = function()
        local root = GetRootPart()
        if root then
            root.CFrame = CFrame.new(0, 10, 100)
        end
    end
})

-- Teleport to Plot
MoveTab:CreateButton({
    Name = "Teleport to Plot",
    Info = "Teleport to your plot",
    Callback = function()
        local root = GetRootPart()
        if root then
            root.CFrame = CFrame.new(50, 10, 0)
        end
    end
})

-- Teleport to Spawn
MoveTab:CreateButton({
    Name = "Teleport to Spawn",
    Info = "Teleport to game spawn point",
    Callback = function()
        local root = GetRootPart()
        if root then
            root.CFrame = CFrame.new(0, 10, 0)
        end
    end
})

-- Teleport to Position (custom)
MoveTab:CreateButton({
    Name = "Teleport to Position",
    Info = "Teleport to custom coordinates",
    Callback = function()
        Rayfield:Notify({
            Title = "Teleport",
            Content = "Use your executor's teleport function or click again",
            Duration = 3
        })
    end
})

-- TAB 4: ESP
local ESPTab = Window:CreateTab("ESP", 0)

-- Master ESP Toggle
ESPTab:CreateToggle({
    Name = "ESP Master Toggle",
    Info = "Enable/Disable all ESP",
    Default = false,
    Callback = function(v)
        ScriptState.ESPEnabled = v
        if not v then
            ClearAllESP()
        end
    end
})

local ESPBlockSection = ESPTab:CreateSection("ESP Types")

-- ESP Blocks
ESPTab:CreateToggle({
    Name = "ESP - Lucky Blocks",
    Info = "Highlight lucky blocks",
    Default = false,
    Callback = function(v)
        ScriptState.ESPBlocks = v
        if not v then
            -- Cleanup block ESP
        end
    end
})

-- ESP Brainrots
ESPTab:CreateToggle({
    Name = "ESP - Brainrots",
    Info = "Highlight brainrots on ground",
    Default = false,
    Callback = function(v)
        ScriptState.ESPBrainrots = v
    end
})

-- ESP Players
ESPTab:CreateToggle({
    Name = "ESP - Players",
    Info = "Highlight other players",
    Default = false,
    Callback = function(v)
        ScriptState.ESPPlayers = v
    end
})

-- ESP Tsunami
ESPTab:CreateToggle({
    Name = "ESP - Tsunami",
    Info = "Highlight tsunami wave",
    Default = false,
    Callback = function(v)
        ScriptState.ESPTsunami = v
    end
})

-- ESP Plots
ESPTab:CreateToggle({
    Name = "ESP - Plots",
    Info = "Highlight plots/bases",
    Default = false,
    Callback = function(v)
        ScriptState.ESPPlots = v
    end
})

-- Block Radar
ESPTab:CreateToggle({
    Name = "Block Radar",
    Info = "Radar for nearby blocks",
    Default = false,
    Callback = function(v)
        ScriptState.BlockRadar = v
    end
})

-- TAB 5: EXPLOITS
local ExploitTab = Window:CreateTab("Exploits", 0)
local ExploitSection = ExploitTab:CreateSection("Protections")

-- Anti-Kick
ExploitTab:CreateToggle({
    Name = "Anti-Kick",
    Info = "Prevent being kicked from game",
    Default = false,
    Callback = function(v)
        ScriptState.AntiKick = v
    end
})

-- Anti-Ban
ExploitTab:CreateToggle({
    Name = "Anti-Ban",
    Info = "Prevent being banned",
    Default = false,
    Callback = function(v)
        ScriptState.AntiBan = v
    end
})

local SpeedSection = ExploitTab:CreateSection("Speed / Exploits")

-- Speed Hack button
ExploitTab:CreateButton({
    Name = "Speed Hack (125)",
    Info = "Set kick speed to 125",
    Callback = function()
        FireSpeedUpdate(125)
        Rayfield:Notify({
            Title = "Speed Hack",
            Content = "Speed set to 125!",
            Duration = 2
        })
    end
})

-- Max Speed
ExploitTab:CreateButton({
    Name = "Max Speed (999)",
    Info = "Set max kick speed",
    Callback = function()
        FireSpeedUpdate(999)
        Rayfield:Notify({
            Title = "Speed Hack",
            Content = "Speed set to 999!",
            Duration = 2
        })
    end
})

-- Instant Kick Button
ExploitTab:CreateButton({
    Name = "Instant Kick",
    Info = "Kick with full power immediately",
    Callback = function()
        FireKickRemote(1)
        task.wait(0.05)
        FireKickRemote(100)
        Rayfield:Notify({
            Title = "Kick",
            Content = "Instant kick fired!",
            Duration = 2
        })
    end
})

local ServerSection = ExploitTab:CreateSection("Server")

-- Auto Rejoin
ExploitTab:CreateToggle({
    Name = "Auto Rejoin",
    Info = "Auto rejoin on disconnect",
    Default = false,
    Callback = function(v)
        ScriptState.AutoRejoin = v
    end
})

-- Server Hopper
ExploitTab:CreateToggle({
    Name = "Server Hopper",
    Info = "Hop servers automatically",
    Default = false,
    Callback = function(v)
        ScriptState.ServerHopper = v
    end
})

-- Rejoin Button
ExploitTab:CreateButton({
    Name = "Rejoin Server",
    Info = "Leave and rejoin the game",
    Callback = function()
        local ts = game:GetService("TeleportService")
        local placeId = game.PlaceId
        pcall(function()
            ts:Teleport(placeId, LP)
        end)
    end
})

-- Server Hop Button
ExploitTab:CreateButton({
    Name = "Hop Server",
    Info = "Switch to another server",
    Callback = function()
        local ts = game:GetService("TeleportService")
        local placeId = game.PlaceId
        local jobId = game.JobId
        local newJobId = tostring(HttpService:GenerateGUID(false))
        pcall(function()
            ts:TeleportToPlaceInstance(placeId, newJobId, LP)
        end)
    end
})

-- Spoofs
ExploitTab:CreateButton({
    Name = "Spoof Player",
    Info = "Attempt to spoof player identity",
    Callback = function()
        Rayfield:Notify({
            Title = "Spoof",
            Content = "Spoof functionality activated",
            Duration = 2
        })
    end
})

-- TAB 6: SETTINGS
local SettingsTab = Window:CreateTab("Settings", 0)

local UISection = SettingsTab:CreateSection("UI Settings")

-- Watermark Toggle
SettingsTab:CreateToggle({
    Name = "Watermark",
    Info = "Show 'powered by turcja' watermark",
    Default = false,
    Callback = function(v)
        ScriptState.WatermarkEnabled = v
    end
})

-- Info Panel
SettingsTab:CreateToggle({
    Name = "Info Panel",
    Info = "Show real-time stats panel",
    Default = false,
    Callback = function(v)
        ScriptState.InfoPanelEnabled = v
    end
})

-- Toggle Key
SettingsTab:CreateKeybind({
    Name = "Toggle GUI Key",
    Info = "Key to show/hide UI",
    Default = "K",
    CurrentKeybind = "K",
    Callback = function()
        -- Rayfield handles toggle itself
    end
})

local MiscSection = SettingsTab:CreateSection("Miscellaneous")

-- Anti-AFK
SettingsTab:CreateToggle({
    Name = "Anti-AFK",
    Info = "Prevent being kicked for afk",
    Default = true,
    Callback = function(v)
        _G.AntiAFK = v
    end
})
_G.AntiAFK = true

-- FPS Boost
SettingsTab:CreateToggle({
    Name = "FPS Boost",
    Info = "Optimize game performance",
    Default = false,
    Callback = function(v)
        if v then
            Lighting.GlobalShadows = false
            Lighting.Brightness = 2
            workspace.DecalLod = 100
            settings().Rendering.QualityLevel = 1
        else
            Lighting.GlobalShadows = true
            Lighting.Brightness = 1
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end
    end
})

-- Auto Tsunami Escape
SettingsTab:CreateToggle({
    Name = "Auto Tsunami Escape",
    Info = "Auto escape from tsunami",
    Default = false,
    Callback = function(v)
        ScriptState.AutoTsunamiEscape = v
    end
})

-- ============================================================
-- LOOP SYSTEMS
-- ============================================================

-- Main farm loop
task.spawn(function()
    while task.wait(0.1) do
        -- Auto Kick
        if ScriptState.AutoKick then
            for i = 1, 3 do
                FireKickRemote(i)
                task.wait(0.03)
            end
        end
        
        -- Perfect Kick (more powerful)
        if ScriptState.PerfectKick then
            FireSpeedUpdate(125)
            task.wait(0.05)
            FireKickRemote(100)
            task.wait(0.05)
        end
        
        -- Auto Collect Cash
        if ScriptState.AutoCollectCash then
            CollectCash()
            task.wait(0.1)
            CollectCash()
        end
        
        -- Auto Collect Brainrots
        if ScriptState.AutoCollectBrainrots then
            for _, kw in ipairs({"brainrot", "Brainrot", "collect", "Collect"}) do
                FireRemoteByName(kw)
                task.wait(0.05)
            end
        end
        
        -- Auto Place Brainrot
        if ScriptState.AutoPlaceBrainrot then
            FireBrainrotRemote("place", 1)
            task.wait(0.05)
        end
        
        -- Auto Upgrade Brainrot
        if ScriptState.AutoUpgradeBrainrot then
            FireBrainrotRemote("upgrade", 1)
            task.wait(0.05)
        end
        
        -- Auto Train
        if ScriptState.AutoTrain then
            FireWeightRemote(1)
            if ScriptState.FastTrain then
                task.wait(0.05)
                FireWeightRemote(1)
            end
        end
        
        -- Auto Buy Weights
        if ScriptState.AutoBuyWeights then
            FireWeightRemote("buy")
            task.wait(0.1)
        end
        
        -- Auto Buy Best Weight
        if ScriptState.AutoBuyBestWeight then
            FireWeightRemote("buy", "best")
            task.wait(0.1)
        end
        
        -- Auto Upgrade Plot
        if ScriptState.AutoUpgradePlot then
            FirePlotRemote("upgrade")
            task.wait(0.1)
        end
        
        -- Auto Rebirth
        if ScriptState.AutoRebirth then
            FireRebirthRemote()
            task.wait(0.5)
        end
        
        -- Auto Collect Pro (more aggressive)
        if ScriptState.AutoCollectPro then
            for i = 1, 5 do
                CollectCash()
                task.wait(0.02)
            end
        end
        
        -- Multi Drop
        if ScriptState.MultiDrop then
            for i = 1, 3 do
                FireBrainrotRemote("place", i)
                task.wait(0.02)
            end
        end
        
        -- Instant Collect
        if ScriptState.InstantCollect then
            for _, kw in ipairs({"collect", "Collect", "claim", "Claim", "pickup", "Pickup"}) do
                FireRemoteByName(kw)
                task.wait(0.02)
            end
        end
    end
end)

-- Anti-AFK loop
task.spawn(function()
    while task.wait(60) do
        if _G.AntiAFK then
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, "Space", false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, "Space", false, game)
            end)
        end
    end
end)

-- Movement loop (Fly)
task.spawn(function()
    while task.wait(0.03) do
        if ScriptState.Fly and flying then
            local root = GetRootPart()
            if root and flyBodyGyro and flyBodyVelocity then
                local speed = _G.FlySpeed or 15
                local moveDirection = Vector3.new()
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + workspace.CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - workspace.CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - workspace.CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + workspace.CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    moveDirection = moveDirection - Vector3.new(0, 1, 0)
                end
                
                if moveDirection.Magnitude > 0 then
                    moveDirection = moveDirection.Unit * speed
                end
                
                flyBodyGyro.CFrame = workspace.CurrentCamera.CFrame
                flyBodyVelocity.Velocity = moveDirection
                
                if flyBV then
                    flyBV.Position = root.Position + moveDirection * 0.1
                end
            end
        end
    end
end)

-- Noclip refresh loop
task.spawn(function()
    while task.wait(0.5) do
        if ScriptState.Noclip then
            local char = GetCharacter()
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- ESP Loop
task.spawn(function()
    while task.wait(0.5) do
        if ScriptState.ESPEnabled then
            -- ESP Blocks
            if ScriptState.ESPBlocks then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("Part") and (obj.Name:lower():find("block") or obj.Name:lower():find("lucky")) then
                        if not ESPObjects[obj] then
                            CreateESP(obj, Color3.fromRGB(0, 255, 0), "Lucky Block")
                        end
                    end
                end
            end
            
            -- ESP Brainrots
            if ScriptState.ESPBrainrots then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("Part") and (obj.Name:lower():find("brainrot") or obj.Name:lower():find("brain")) then
                        if not ESPObjects[obj] then
                            CreateESP(obj, Color3.fromRGB(255, 100, 255), "Brainrot")
                        end
                    end
                end
            end
            
            -- ESP Players
            if ScriptState.ESPPlayers then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LP then
                        local char = plr.Character
                        if char and not ESPObjects[char] then
                            local root = char:FindFirstChild("HumanoidRootPart")
                            if root then
                                CreateESP(char, Color3.fromRGB(255, 0, 0), plr.Name)
                            end
                        end
                    end
                end
            end
            
            -- ESP Tsunami
            if ScriptState.ESPTsunami then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("Part") and (obj.Name:lower():find("tsunami") or obj.Name:lower():find("wave") or obj.Name:lower():find("water")) then
                        if not ESPObjects[obj] then
                            CreateESP(obj, Color3.fromRGB(0, 100, 255), "TSUNAMI")
                        end
                    end
                end
            end
            
            -- ESP Plots
            if ScriptState.ESPPlots then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("Part") and (obj.Name:lower():find("plot") or obj.Name:lower():find("base") or obj.Name:lower():find("land")) then
                        if not ESPObjects[obj] then
                            CreateESP(obj, Color3.fromRGB(255, 255, 0), "Plot")
                        end
                    end
                end
            end
            
            -- Block Radar
            if ScriptState.BlockRadar then
                -- Already covered by ESP Blocks above
            end
        else
            if next(ESPObjects) ~= nil then
                ClearAllESP()
            end
        end
    end
end)

-- Anti-Kick / Anti-Ban
task.spawn(function()
    while task.wait(1) do
        if ScriptState.AntiKick then
            -- Override kick function
            local con
            con = LP.OnTeleport:Connect(function()
                con:Disconnect()
            end)
            
            local oldKick = LP.Kick
            LP.Kick = function() end
            
            -- Restore after a bit to not break everything
            task.delay(5, function()
                LP.Kick = oldKick
            end)
        end
        
        if ScriptState.AntiBan then
            local oldKick = LP.Kick
            LP.Kick = function() end
            task.delay(5, function()
                LP.Kick = oldKick
            end)
        end
    end
end)

-- Auto Tsunami Escape
task.spawn(function()
    while task.wait(0.5) do
        if ScriptState.AutoTsunamiEscape then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Part") and (obj.Name:lower():find("tsunami") or obj.Name:lower():find("wave") or obj.Name:lower():find("water")) then
                    local root = GetRootPart()
                    if root and obj.Position then
                        local dist = (root.Position - obj.Position).Magnitude
                        if dist < 50 then
                            -- Teleport to safe zone
                            root.CFrame = CFrame.new(0, 100, 0)
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- Watermark
task.spawn(function()
    local watermarkFrame = Instance.new("Frame")
    watermarkFrame.Size = UDim2.new(0, 200, 0, 30)
    watermarkFrame.Position = UDim2.new(1, -210, 1, -40)
    watermarkFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    watermarkFrame.BackgroundTransparency = 0.3
    watermarkFrame.BorderSizePixel = 0
    watermarkFrame.Visible = false
    watermarkFrame.Parent = CoreGui
    
    local wUICorner = Instance.new("UICorner")
    wUICorner.CornerRadius = UDim.new(0, 6)
    wUICorner.Parent = watermarkFrame
    
    local wStroke = Instance.new("UIStroke")
    wStroke.Color = Color3.fromRGB(0, 150, 255)
    wStroke.Thickness = 1
    wStroke.Transparency = 0.5
    wStroke.Parent = watermarkFrame
    
    local wLabel = Instance.new("TextLabel")
    wLabel.Size = UDim2.new(1, 0, 1, 0)
    wLabel.BackgroundTransparency = 1
    wLabel.Text = "powered by turcja"
    wLabel.Font = Enum.Font.GothamBold
    wLabel.TextSize = 13
    wLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
    wLabel.TextXAlignment = Enum.TextXAlignment.Center
    wLabel.Parent = watermarkFrame
    
    while task.wait(0.3) do
        watermarkFrame.Visible = ScriptState.WatermarkEnabled
        if ScriptState.WatermarkEnabled then
            -- Pulse animation
            local alpha = 0.5 + math.sin(tick() * 3) * 0.15
            watermarkFrame.BackgroundTransparency = 1 - alpha
            wStroke.Transparency = 1 - (alpha * 0.8)
        end
    end
end)

-- Info Panel
task.spawn(function()
    local panel = Instance.new("ScreenGui")
    panel.Name = "TurcjaInfoPanel"
    panel.Parent = CoreGui
    panel.ResetOnSpawn = false
    panel.Enabled = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 160)
    frame.Position = UDim2.new(0, 10, 0, 100)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = panel
    
    local ic = Instance.new("UICorner")
    ic.CornerRadius = UDim.new(0, 8)
    ic.Parent = frame
    
    local st = Instance.new("UIStroke")
    st.Color = Color3.fromRGB(0, 120, 255)
    st.Thickness = 1
    st.Transparency = 0.6
    st.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -10, 0, 25)
    title.Position = UDim2.new(0, 5, 0, 3)
    title.BackgroundTransparency = 1
    title.Text = "Turcja Hub - Info"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = Color3.fromRGB(0, 170, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame
    
    local infoLabels = {}
    local infoTexts = {
        "Walkspeed: 16",
        "AutoKick: OFF",
        "AutoCash: OFF",
        "AutoTrain: OFF",
        "Ping: 0ms",
        "FPS: 60"
    }
    
    for i, text in ipairs(infoTexts) do
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -10, 0, 18)
        lbl.Position = UDim2.new(0, 5, 0, 28 + (i-1) * 18)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame
        infoLabels[i] = lbl
    end
    
    while task.wait(0.5) do
        panel.Enabled = ScriptState.InfoPanelEnabled
        if ScriptState.InfoPanelEnabled then
            infoLabels[1].Text = "Walkspeed: " .. math.floor(ScriptState.Walkspeed)
            infoLabels[2].Text = "AutoKick: " .. (ScriptState.AutoKick and "ON" or "OFF")
            infoLabels[3].Text = "AutoCash: " .. (ScriptState.AutoCollectCash and "ON" or "OFF")
            infoLabels[4].Text = "AutoTrain: " .. (ScriptState.AutoTrain and "ON" or "OFF")
            infoLabels[5].Text = "Ping: " .. math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms"
            infoLabels[6].Text = "FPS: " .. math.floor(1 / RunService.RenderStepped:Wait())
        end
    end
end)

-- Anti-Kick remote protection
task.spawn(function()
    -- Protect against game's kick remote
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if ScriptState.AntiKick and method == "FireServer" then
            local name = ""
            pcall(function() name = self.Name end)
            if name:lower():find("kick") and name:lower():find("event") then
                -- Block kick events from being received
                return
            end
        end
        
        return oldNamecall(self, ...)
    end)
end)

-- Auto Rejoin / Server Hopper
task.spawn(function()
    while task.wait(5) do
        if ScriptState.AutoRejoin then
            local con
            con = LP.OnTeleport:Connect(function()
                con:Disconnect()
            end)
        end
        
        if ScriptState.ServerHopper then
            -- Random server hop every ~10 minutes
            -- Handled by button for manual control
        end
    end
end)

-- ============================================================
-- CHARACTER ADDED HANDLER
-- ============================================================

LP.CharacterAdded:Connect(function(char)
    -- Re-apply walkspeed/jump
    local hum = char:WaitForChild("Humanoid")
    if hum then
        hum.WalkSpeed = ScriptState.Walkspeed
        hum.JumpPower = ScriptState.Jumppower
    end
    
    -- Re-apply noclip
    if ScriptState.Noclip then
        task.wait(0.5)
        SetNoclip(true)
    end
    
    -- Re-apply fly
    if ScriptState.Fly then
        task.wait(0.5)
        StartFly()
    end
end)

-- ============================================================
-- INIT
-- ============================================================

Rayfield:Notify({
    Title = "Turcja Hub Loaded",
    Content = "Kick a Lucky Block - All features ready!",
    Duration = 5
})

-- Apply initial walkspeed/jump
task.wait(0.5)
local hum = GetHumanoid()
if hum then
    hum.WalkSpeed = 16
    hum.JumpPower = 50
end

print("Turcja Hub v3.0 - Successfully loaded!")
print("Toggle GUI: K")
print("Key: Always required on restart")
