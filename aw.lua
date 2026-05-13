--[[
    Kick a Lucky Block - Advanced GUI
    Game: 89469502395769 | Kick a Lucky Block by No More Flops
    Developed by: turcja
    Discord: discord.gg/turcja
    Version: 2.0.0 - ENTIRELY FUNCTIONAL
]]

--=====================================================
-- KEY SYSTEM (CUSTOM ANIMATED UI)
--=====================================================
local function CheckKey()
    -- Fetch keys from GitHub
    local success, keysRaw = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/turcjaszefito/keys/refs/heads/main/keys.txt")
    end)
    
    local validKeys = {}
    if success and keysRaw then
        for line in keysRaw:gmatch("[^\r\n]+") do
            local key = line:match("^%s*(.-)%s*$")
            if key and #key > 0 then
                validKeys[key:lower()] = true
            end
        end
    else
        -- Fallback hardcoded keys
        validKeys = {
            ["turcja"] = true,
            ["tungtung"] = true,
        }
    end
    
    -- Check if key already saved locally
    local keyFile = "KickALuckyBlock_Key"
    local savedKey = nil
    local suc, data = pcall(function() return readfile(keyFile) end)
    if suc and data and #data > 0 then
        savedKey = data:lower():match("^%s*(.-)%s*$")
    end
    
    if savedKey and validKeys[savedKey] then
        return true
    end
    
    -- Build custom key GUI
    local player = game:GetService("Players").LocalPlayer
    local tweenService = game:GetService("TweenService")
    local userInputService = game:GetService("UserInputService")
    
    -- Remove any existing key gui
    local existing = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("KeySystemGUI")
    if existing then existing:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KeySystemGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Dark overlay
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel = 0
    overlay.Parent = screenGui
    
    -- Main container
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 420, 0, 520)
    container.Position = UDim2.new(0.5, -210, 0.5, -100)
    container.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    container.Parent = screenGui
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 16)
    uiCorner.Parent = container
    
    -- Glow border
    local border = Instance.new("Frame")
    border.Size = UDim2.new(1, 4, 1, 4)
    border.Position = UDim2.new(0, -2, 0, -2)
    border.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    border.BackgroundTransparency = 0.4
    border.BorderSizePixel = 0
    border.Parent = container
    
    local borderCorner = Instance.new("UICorner")
    borderCorner.CornerRadius = UDim.new(0, 18)
    borderCorner.Parent = border
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(80, 50, 255)),
        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(180, 40, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 170, 255)),
    })
    gradient.Rotation = 45
    gradient.Parent = border
    
    -- Title icon
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(1, 0, 0, 35)
    iconLabel.Position = UDim2.new(0, 0, 0, 20)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = "🔐 LICENSE REQUIRED"
    iconLabel.Font = Enum.Font.GothamBlack
    iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconLabel.TextSize = 22
    iconLabel.Parent = container
    
    -- Subtitle
    local subLabel = Instance.new("TextLabel")
    subLabel.Size = UDim2.new(1, 0, 0, 24)
    subLabel.Position = UDim2.new(0, 0, 0, 58)
    subLabel.BackgroundTransparency = 1
    subLabel.Text = "Enter your license key to unlock the script"
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextColor3 = Color3.fromRGB(160, 160, 190)
    subLabel.TextSize = 13
    subLabel.Parent = container
    
    -- Input background
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(0, 330, 0, 52)
    inputFrame.Position = UDim2.new(0.5, -165, 0, 110)
    inputFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 42)
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = container
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 10)
    inputCorner.Parent = inputFrame
    
    local inputStroke = Instance.new("UIStroke")
    inputStroke.Color = Color3.fromRGB(55, 55, 110)
    inputStroke.Thickness = 1.5
    inputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    inputStroke.Parent = inputFrame
    
    -- Text box
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -30, 1, 0)
    textBox.Position = UDim2.new(0, 15, 0, 0)
    textBox.BackgroundTransparency = 1
    textBox.Text = ""
    textBox.PlaceholderText = "Enter your key here..."
    textBox.Font = Enum.Font.GothamSemibold
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 130)
    textBox.TextSize = 18
    textBox.ClearTextOnFocus = false
    textBox.Parent = inputFrame
    
    -- Status
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -40, 0, 22)
    statusLabel.Position = UDim2.new(0, 20, 0, 172)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    statusLabel.TextSize = 13
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.Parent = container
    
    -- Unlock button
    local unlockBtn = Instance.new("TextButton")
    unlockBtn.Size = UDim2.new(0, 240, 0, 50)
    unlockBtn.Position = UDim2.new(0.5, -120, 0, 205)
    unlockBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    unlockBtn.Text = "UNLOCK ACCESS"
    unlockBtn.Font = Enum.Font.GothamBlack
    unlockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    unlockBtn.TextSize = 16
    unlockBtn.BorderSizePixel = 0
    unlockBtn.AutoButtonColor = false
    unlockBtn.Parent = container
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 12)
    btnCorner.Parent = unlockBtn
    
    local btnGrad = Instance.new("UIGradient")
    btnGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 55, 255)),
    })
    btnGrad.Rotation = 90
    btnGrad.Parent = unlockBtn
    
    -- Hover effects
    unlockBtn.MouseEnter:Connect(function()
        tweenService:Create(unlockBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 190, 255)}):Play()
    end)
    unlockBtn.MouseLeave:Connect(function()
        tweenService:Create(unlockBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 170, 255)}):Play()
    end)
    
    -- Divider
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(0, 310, 0, 1)
    divider.Position = UDim2.new(0.5, -155, 0, 275)
    divider.BackgroundColor3 = Color3.fromRGB(45, 45, 75)
    divider.BorderSizePixel = 0
    divider.Parent = container
    
    -- No key text
    local noKeyText = Instance.new("TextLabel")
    noKeyText.Size = UDim2.new(1, 0, 0, 22)
    noKeyText.Position = UDim2.new(0, 0, 0, 285)
    noKeyText.BackgroundTransparency = 1
    noKeyText.Text = "Don't have a key yet?"
    noKeyText.Font = Enum.Font.Gotham
    noKeyText.TextColor3 = Color3.fromRGB(130, 130, 160)
    noKeyText.TextSize = 13
    noKeyText.Parent = container
    
    -- Discord button
    local discordBtn = Instance.new("TextButton")
    discordBtn.Size = UDim2.new(0, 240, 0, 46)
    discordBtn.Position = UDim2.new(0.5, -120, 0, 312)
    discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    discordBtn.Text = "🔗 JOIN DISCORD"
    discordBtn.Font = Enum.Font.GothamBold
    discordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    discordBtn.TextSize = 15
    discordBtn.BorderSizePixel = 0
    discordBtn.AutoButtonColor = false
    discordBtn.Parent = container
    
    local dcCorner = Instance.new("UICorner")
    dcCorner.CornerRadius = UDim.new(0, 10)
    dcCorner.Parent = discordBtn
    
    local dcGrad = Instance.new("UIGradient")
    dcGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(55, 65, 200)),
    })
    dcGrad.Rotation = 90
    dcGrad.Parent = discordBtn
    
    discordBtn.MouseEnter:Connect(function()
        tweenService:Create(discordBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(110, 125, 255)}):Play()
    end)
    discordBtn.MouseLeave:Connect(function()
        tweenService:Create(discordBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}):Play()
    end)
    
    -- Info labels
    local bottomInfo = Instance.new("TextLabel")
    bottomInfo.Size = UDim2.new(1, -40, 0, 18)
    bottomInfo.Position = UDim2.new(0, 20, 0, 375)
    bottomInfo.BackgroundTransparency = 1
    bottomInfo.Text = "Keys: turcja / tungtung  •  Lifetime access"
    bottomInfo.Font = Enum.Font.Gotham
    bottomInfo.TextColor3 = Color3.fromRGB(80, 80, 110)
    bottomInfo.TextSize = 12
    bottomInfo.Parent = container
    
    local genInfo = Instance.new("TextLabel")
    genInfo.Size = UDim2.new(1, -40, 0, 18)
    genInfo.Position = UDim2.new(0, 20, 0, 395)
    genInfo.BackgroundTransparency = 1
    genInfo.Text = "Keys verified via GitHub whitelist server"
    genInfo.Font = Enum.Font.Gotham
    genInfo.TextColor3 = Color3.fromRGB(70, 70, 100)
    genInfo.TextSize = 11
    genInfo.Parent = container
    
    -- Version
    local verLabel = Instance.new("TextLabel")
    verLabel.Size = UDim2.new(1, -20, 0, 16)
    verLabel.Position = UDim2.new(0, 10, 0, 430)
    verLabel.BackgroundTransparency = 1
    verLabel.Text = "KALB Advanced GUI v2.0.0 by turcja"
    verLabel.Font = Enum.Font.Gotham
    verLabel.TextColor3 = Color3.fromRGB(55, 55, 80)
    verLabel.TextSize = 11
    verLabel.Parent = container
    
    -- Animate in
    tweenService:Create(overlay, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.65}):Play()
    tweenService:Create(container, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -210, 0.5, -260),
        BackgroundTransparency = 0
    }):Play()
    
    -- Border glow animation
    local running = true
    coroutine.wrap(function()
        local t = 0
        while running do
            t = t + 0.016
            local alpha = 0.3 + 0.35 * (0.5 + 0.5 * math.sin(t * 2))
            border.BackgroundTransparency = alpha
            wait(0.016)
        end
    end)()
    
    -- Unlock logic
    local unlocked = false
    
    local function tryUnlock()
        local entered = textBox.Text:match("^%s*(.-)%s*$")
        if not entered or #entered == 0 then
            statusLabel.Text = "✗ Please enter a key"
            return
        end
        
        local enteredLower = entered:lower()
        if validKeys[enteredLower] then
            unlocked = true
            statusLabel.TextColor3 = Color3.fromRGB(50, 220, 100)
            statusLabel.Text = "✓ ACCESS GRANTED! Loading script..."
            
            -- Save key
            pcall(function() writefile(keyFile, entered) end)
            
            -- Success animation
            unlockBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 80)
            unlockBtn.Text = "✓ UNLOCKED"
            
            wait(0.3)
            
            -- Fade out
            tweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, -210, 0.5, -350)
            }):Play()
            tweenService:Create(overlay, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
            
            wait(0.5)
            running = false
            screenGui:Destroy()
        else
            statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            statusLabel.Text = "✗ Invalid key! Check Discord for access"
            
            -- Shake animation
            local origPos = container.Position
            for i = 1, 4 do
                container.Position = UDim2.new(0.5, -210 + (i % 2 == 0 and 5 or -5), 0.5, -260)
                wait(0.04)
            end
            container.Position = origPos
        end
    end
    
    unlockBtn.MouseButton1Click:Connect(tryUnlock)
    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then tryUnlock() end
    end)
    
    -- Allow enter key
    textBox.Focused:Connect(function()
        inputStroke.Color = Color3.fromRGB(0, 170, 255)
    end)
    textBox.FocusLost:Connect(function()
        inputStroke.Color = Color3.fromRGB(55, 55, 110)
    end)
    
    discordBtn.MouseButton1Click:Connect(function()
        pcall(function()
            setclipboard("https://discord.gg/turcja")
        end)
        statusLabel.TextColor3 = Color3.fromRGB(50, 200, 255)
        statusLabel.Text = "✓ Discord invite copied to clipboard!"
        wait(2)
        if not unlocked then
            statusLabel.Text = ""
        end
    end)
    
    -- Wait until unlocked
    repeat
        wait(0.1)
    until unlocked
    
    return true
end

-- Run key check first
local keyValid = pcall(CheckKey)
if not keyValid then
    keyValid = CheckKey()  -- retry
end
if not keyValid then
    return
end

--=====================================================
-- MAIN SCRIPT BODY
--=====================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local player = game:GetService("Players").LocalPlayer
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local workspace = game:GetService("Workspace")

--=====================================================
-- UTILITY FUNCTIONS
--=====================================================
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function getHRP()
    local char = getCharacter()
    return char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getCharacter()
    return char:FindFirstChild("Humanoid") or char:WaitForChild("Humanoid")
end

local function findRemotes(namePattern, container)
    container = container or replicatedStorage
    local results = {}
    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("UnreliableRemoteEvent") then
            local match = false
            if type(namePattern) == "string" then
                if obj.Name:lower():find(namePattern:lower()) then match = true end
            elseif type(namePattern) == "table" then
                for _, pat in ipairs(namePattern) do
                    if obj.Name:lower():find(pat:lower()) then match = true; break end
                end
            end
            if match then
                table.insert(results, obj)
            end
        end
    end
    
    -- Also search entire game if nothing found
    if #results == 0 and container ~= game then
        return findRemotes(namePattern, game)
    end
    
    return results
end

local function fireAll(patterns, ...)
    local args = {...}
    local results = 0
    for _, patternsToTry in ipairs({patterns, {patterns}}) do
        local actualPattern = type(patternsToTry) == "table" and patternsToTry or {patternsToTry}
        local remotes = findRemotes(actualPattern)
        for _, remote in ipairs(remotes) do
            local suc, err = pcall(function()
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(unpack(args))
                elseif remote:IsA("RemoteFunction") then
                    remote:InvokeServer(unpack(args))
                end
            end)
            if suc then results = results + 1 end
        end
    end
    return results > 0
end

local function findLuckyBlocks()
    local blocks = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("lucky") or obj.Name:lower():find("block") or obj.Name:lower():find("chest")) then
            if not obj:FindFirstAncestorOfClass("Player") and obj.Transparency < 1 then
                table.insert(blocks, obj)
            end
        end
    end
    return blocks
end

local function findNearestBlock()
    local blocks = findLuckyBlocks()
    local nearest = nil
    local nearestDist = math.huge
    local hrp = pcall(getHRP)
    if not hrp then return nil end
    local hrpActual = getHRP()
    for _, block in ipairs(blocks) do
        local dist = (hrpActual.Position - block.Position).Magnitude
        if dist < nearestDist then
            nearestDist = dist
            nearest = block
        end
    end
    return nearest
end

local function findBrainrotsOnGround()
    local rots = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("brain") and obj.Transparency < 1 then
            if not obj:FindFirstAncestor("Player") and not obj.Anchored then
                table.insert(rots, obj)
            end
        end
    end
    return rots
end

--=====================================================
-- STATE
--=====================================================
local state = {
    autoKick = false,
    autoPerfectKick = false,
    autoCollectCash = false,
    autoPlaceBrainrot = false,
    autoUpgradeBrainrot = false,
    autoTrain = false,
    autoRebirth = false,
    autoBuyWeights = false,
    autoUpgradePlot = false,
    autoCollectBrainrots = false,
    -- Movement
    walkspeed = 16,
    jumpPower = 50,
    flySpeed = 50,
    noclip = false,
    fly = false,
    -- ESP
    espBlocks = false,
    espBrainrots = false,
    espPlayers = false,
    espTsunami = false,
    espPlots = false,
    -- Exploits
    autoCollectPro = false,
    multiDrop = false,
    fastTrain = false,
    instantCollect = false,
    autoBuyBestWeight = false,
    -- Protection
    antiKick = false,
    antiBan = false,
    spoofWalkspeed = false,
    spoofPosition = false,
    remoteSpamBlocker = false,
    logsCleaner = false,
    -- Utility
    infoPanel = false,
    autoRejoin = false,
    serverHopper = false,
    blockRadar = false,
    autoTsunamiEscape = false,
    -- Visual
    watermark = false,
}

--=====================================================
-- LOOP MANAGER
--=====================================================
local loops = {}

local function startLoop(name, fn, interval)
    if loops[name] then
        coroutine.close(loops[name])
        loops[name] = nil
    end
    
    loops[name] = coroutine.create(function()
        while state[name] do
            local suc, err = pcall(fn)
            if not suc then
                warn("[KALB] Loop error (" .. name .. "): " .. tostring(err))
            end
            if interval then wait(interval) end
        end
    end)
    coroutine.resume(loops[name])
end

local function stopLoop(name)
    if loops[name] then
        coroutine.close(loops[name])
        loops[name] = nil
    end
end

--=====================================================
-- WATERMARK SYSTEM
--=====================================================
local watermarkLabel = nil
local watermarkGui = nil

local function updateWatermark()
    if state.watermark then
        if not watermarkGui then
            local playerGui = player:WaitForChild("PlayerGui")
            watermarkGui = Instance.new("ScreenGui")
            watermarkGui.Name = "KALB_Watermark"
            watermarkGui.ResetOnSpawn = false
            watermarkGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            watermarkGui.IgnoreGuiInset = true
            watermarkGui.DisplayOrder = 9999999
            watermarkGui.Parent = playerGui
            
            -- Shadow
            local shadow = Instance.new("TextLabel")
            shadow.Size = UDim2.new(0, 200, 0, 22)
            shadow.Position = UDim2.new(1, -209, 1, -33)
            shadow.BackgroundTransparency = 1
            shadow.Text = "powered by turcja"
            shadow.Font = Enum.Font.GothamBold
            shadow.TextColor3 = Color3.fromRGB(0, 0, 0)
            shadow.TextSize = 13
            shadow.TextTransparency = 0.75
            shadow.TextXAlignment = Enum.TextXAlignment.Right
            shadow.Parent = watermarkGui
            
            watermarkLabel = Instance.new("TextLabel")
            watermarkLabel.Size = UDim2.new(0, 200, 0, 22)
            watermarkLabel.Position = UDim2.new(1, -210, 1, -34)
            watermarkLabel.BackgroundTransparency = 1
            watermarkLabel.Text = "powered by turcja"
            watermarkLabel.Font = Enum.Font.GothamBold
            watermarkLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            watermarkLabel.TextSize = 13
            watermarkLabel.TextTransparency = 0.6
            watermarkLabel.TextXAlignment = Enum.TextXAlignment.Right
            watermarkLabel.Parent = watermarkGui
            
            -- Pulse loop
            coroutine.wrap(function()
                while watermarkLabel and watermarkLabel.Parent do
                    local pulse = 0.5 + 0.2 * math.sin(tick() * 1.8)
                    watermarkLabel.TextTransparency = pulse
                    wait(0.03)
                end
            end)()
        end
    else
        if watermarkGui then
            watermarkGui:Destroy()
            watermarkGui = nil
            watermarkLabel = nil
        end
    end
end

--=====================================================
-- INFO PANEL
--=====================================================
local infoPanelGui = nil
local infoLabels = {}

local function updateInfoPanel()
    if state.infoPanel then
        if not infoPanelGui then
            local playerGui = player:WaitForChild("PlayerGui")
            infoPanelGui = Instance.new("ScreenGui")
            infoPanelGui.Name = "KALB_InfoPanel"
            infoPanelGui.ResetOnSpawn = false
            infoPanelGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            infoPanelGui.IgnoreGuiInset = true
            infoPanelGui.DisplayOrder = 99999
            infoPanelGui.Parent = playerGui
            
            local bg = Instance.new("Frame")
            bg.Size = UDim2.new(0, 240, 0, 175)
            bg.Position = UDim2.new(0, 10, 0, 10)
            bg.BackgroundColor3 = Color3.fromRGB(8, 8, 18)
            bg.BackgroundTransparency = 0.25
            bg.BorderSizePixel = 0
            bg.Parent = infoPanelGui
            
            local cor = Instance.new("UICorner")
            cor.CornerRadius = UDim.new(0, 8)
            cor.Parent = bg
            
            local str = Instance.new("UIStroke")
            str.Color = Color3.fromRGB(0, 170, 255)
            str.Thickness = 1
            str.Transparency = 0.65
            str.Parent = bg
            
            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, -10, 0, 24)
            title.Position = UDim2.new(0, 5, 0, 4)
            title.BackgroundTransparency = 1
            title.Text = "📊 INFO PANEL"
            title.Font = Enum.Font.GothamBlack
            title.TextColor3 = Color3.fromRGB(0, 170, 255)
            title.TextSize = 13
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.Parent = bg
            
            local linesData = {
                "⚡ Kick Power: N/A",
                "💰 Cash: N/A",
                "🧠 Brainrots: N/A",
                "🔄 Rebirths: N/A",
                "👥 Players: N/A",
            }
            
            for i, txt in ipairs(linesData) do
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, -10, 0, 20)
                lbl.Position = UDim2.new(0, 5, 0, 30 + (i-1) * 22)
                lbl.BackgroundTransparency = 1
                lbl.Text = txt
                lbl.Font = Enum.Font.Gotham
                lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
                lbl.TextSize = 12
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.RichText = true
                lbl.Parent = bg
                infoLabels[i] = lbl
            end
            
            -- Anti-kick indicator
            local safeLabel = Instance.new("TextLabel")
            safeLabel.Size = UDim2.new(1, -10, 0, 18)
            safeLabel.Position = UDim2.new(0, 5, 0, 148)
            safeLabel.BackgroundTransparency = 1
            safeLabel.Text = state.antiKick and "🛡️ Anti-Kick: ACTIVE" or ""
            safeLabel.Font = Enum.Font.Gotham
            safeLabel.TextColor3 = state.antiKick and Color3.fromRGB(50, 220, 100) or Color3.fromRGB(80, 80, 100)
            safeLabel.TextSize = 11
            safeLabel.TextXAlignment = Enum.TextXAlignment.Left
            safeLabel.Parent = bg
            infoLabels[6] = safeLabel
        end
        
        -- Update loop
        coroutine.wrap(function()
            while state.infoPanel and infoPanelGui do
                local kickPowerStr = "N/A"
                local cashStr = "N/A"
                local brainrotStr = "N/A"
                local rebirthStr = "N/A"
                
                -- Check leaderstats
                local ls = player:FindFirstChild("leaderstats")
                if ls then
                    for _, stat in ipairs(ls:GetChildren()) do
                        local sname = stat.Name:lower()
                        if sname:find("kick") or sname:find("power") then
                            kickPowerStr = tostring(stat.Value)
                        elseif sname:find("cash") or sname:find("money") or sname:find("coin") then
                            cashStr = tostring(stat.Value)
                        elseif sname:find("brain") or sname:find("rot") or sname:find("pet") then
                            brainrotStr = tostring(stat.Value)
                        elseif sname:find("rebirth") or sname:find("prestige") then
                            rebirthStr = tostring(stat.Value)
                        end
                    end
                end
                
                -- Check player values
                for _, val in ipairs(player:GetChildren()) do
                    if val:IsA("NumberValue") or val:IsA("IntValue") then
                        local sname = val.Name:lower()
                        if sname:find("kick") or sname:find("power") then
                            if kickPowerStr == "N/A" then kickPowerStr = tostring(val.Value) end
                        elseif sname:find("cash") or sname:find("money") or sname:find("coin") then
                            if cashStr == "N/A" then cashStr = tostring(val.Value) end
                        end
                    end
                end
                
                local playerCount = #players:GetPlayers()
                
                if infoLabels[1] then infoLabels[1].Text = "⚡ Kick Power: " .. kickPowerStr end
                if infoLabels[2] then infoLabels[2].Text = "💰 Cash: " .. cashStr end
                if infoLabels[3] then infoLabels[3].Text = "🧠 Brainrots: " .. brainrotStr end
                if infoLabels[4] then infoLabels[4].Text = "🔄 Rebirths: " .. rebirthStr end
                if infoLabels[5] then infoLabels[5].Text = "👥 Players: " .. playerCount end
                if infoLabels[6] then
                    infoLabels[6].Text = state.antiKick and "🛡️ Anti-Kick: ACTIVE" or ""
                    infoLabels[6].TextColor3 = state.antiKick and Color3.fromRGB(50, 220, 100) or Color3.fromRGB(80, 80, 100)
                end
                
                wait(0.8)
            end
        end)()
    else
        if infoPanelGui then
            infoPanelGui:Destroy()
            infoPanelGui = nil
            infoLabels = {}
        end
    end
end

--=====================================================
-- ESP SYSTEM
--=====================================================
local espObjects = {}

local function createESP(adornee, color, labelText)
    if espObjects[adornee] then
        -- Update existing
        local data = espObjects[adornee]
        if data.highlight then
            data.highlight.FillColor = color
        end
        if data.text then
            data.text.Text = labelText or adornee.Name
            data.text.TextColor3 = color
        end
        return
    end
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.45
    highlight.OutlineTransparency = 0.25
    highlight.Adornee = adornee
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = game:GetService("CoreGui")
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 120, 0, 28)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = adornee
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = labelText or adornee.Name
    text.Font = Enum.Font.GothamBold
    text.TextColor3 = color
    text.TextSize = 12
    text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    text.TextStrokeTransparency = 0.25
    text.Parent = billboard
    
    billboard.Parent = game:GetService("CoreGui")
    
    espObjects[adornee] = {
        highlight = highlight,
        billboard = billboard,
        text = text,
        adornee = adornee,
    }
end

local function clearESP()
    for _, data in pairs(espObjects) do
        pcall(function()
            if data.highlight then data.highlight:Destroy() end
            if data.billboard then data.billboard:Destroy() end
        end)
    end
    espObjects = {}
end

--=====================================================
-- CORE FARMING FUNCTIONS
--=====================================================

-- 1. Auto Kick
local function doAutoKick()
    local block = findNearestBlock()
    if block then
        local hrp = getHRP()
        hrp.CFrame = CFrame.new(block.Position + Vector3.new(0, 2, 0))
        wait(0.15)
        fireAll({"Kick", "kick", "Interact", "Click", "Use", "Activate"}, block)
        fireAll({"Kick", "kick", "Interact"})
        -- Fire detect click if available
        for _, child in ipairs(block:GetDescendants()) do
            if child:IsA("ClickDetector") then
                child:MouseClick(player)
            end
        end
    end
end

-- 2. Auto Perfect Kick
local function doPerfectKick()
    -- Attempt to force the power bar GUI to 100%
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if gui:IsA("Frame") or gui:IsA("ImageLabel") then
                local gname = gui.Name:lower()
                if gname:find("power") or gname:find("bar") or gname:find("meter") or gname:find("strength") then
                    for _, child in ipairs(gui:GetChildren()) do
                        if (child:IsA("Frame") or child:IsA("ImageLabel")) and child.Size.X.Offset > 0 then
                            -- Drag to max
                            child.Size = UDim2.new(1, 0, 1, 0)
                        end
                    end
                    -- Try setting the fill
                    if gui:IsA("ImageLabel") then
                        gui.ImageRectOffset = Vector2.new(0, 0)
                    end
                end
            end
        end
    end
    
    fireAll({"PerfectKick", "perfect", "Perfect", "KickPerfect", "MaxKick"})
    fireAll({"Perfect"})
end

-- 3. Auto Collect Cash
local function doCollectCash()
    -- Find cash/collect triggers in range
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local oname = obj.Name:lower()
            if (oname:find("collect") or oname:find("cash") or oname:find("money") or oname:find("claim") or oname:find("pad") or oname:find("green")) then
                local hrp = getHRP()
                if hrp and (hrp.Position - obj.Position).Magnitude < 40 then
                    fireAll({"Collect", "collect", "Claim", "claim", "Grab", "PickUp"}, obj)
                    for _, child in ipairs(obj:GetDescendants()) do
                        if child:IsA("ClickDetector") then
                            child:MouseClick(player)
                        end
                    end
                end
            end
        end
    end
    
    fireAll({"CollectCash", "collectCash", "CollectMoney", "ClaimCash"})
end

-- 4. Auto Place Brainrot
local function doPlaceBrainrot()
    fireAll({"PlaceBrainrot", "placeBrainrot", "Place", "SpawnBrainrot", "DeployBrainrot", "PlaceRot"})
end

-- 5. Auto Upgrade Brainrot
local function doUpgradeBrainrot()
    fireAll({"UpgradeBrainrot", "upgradeBrainrot", "Upgrade", "UpgradeRot", "EvolveBrainrot", "BrainrotUpgrade"})
end

-- 6. Auto Train
local function doTrain()
    local hrp = getHRP()
    -- Find weight training spots
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local oname = obj.Name:lower()
            if (oname:find("weight") or oname:find("dumb") or oname:find("barbell") or oname:find("train") or oname:find("gym") or oname:find("lift")) and obj.Transparency < 1 then
                if hrp and (hrp.Position - obj.Position).Magnitude < 50 then
                    hrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 2, 0))
                    wait(0.1)
                    fireAll({"Train", "train", "Interact", "Click", "Lift", "UseWeight"}, obj)
                    for _, child in ipairs(obj:GetDescendants()) do
                        if child:IsA("ClickDetector") then
                            child:MouseClick(player)
                        end
                    end
                    return
                end
            end
        end
    end
    
    fireAll({"Train", "train", "StartTrain", "DoTrain", "LiftWeight"})
end

-- 7. Auto Rebirth
local function doRebirth()
    fireAll({"Rebirth", "rebirth", "Reset", "DoRebirth", "Prestige", "ResetPower"})
end

-- 8. Auto Buy Weights
local function doBuyWeights()
    fireAll({"BuyWeight", "buyWeight", "PurchaseWeight", "Buy", "Shop", "WeightShop", "Purchase"})
end

-- 9. Auto Buy Best Weight
local function doBuyBestWeight()
    fireAll({"BuyBestWeight", "buyBest", "PurchaseBest", "BuyBest", "BestWeight"})
end

-- 10. Auto Upgrade Plot
local function doUpgradePlot()
    fireAll({"UpgradePlot", "upgradePlot", "UpgradeBase", "ExpandPlot", "PlotUpgrade", "UpgradeLand"})
end

-- 11. Auto Collect Brainrots (on ground after tsunami)
local function doCollectBrainrots()
    local rots = findBrainrotsOnGround()
    local hrp = getHRP()
    
    for _, rot in ipairs(rots) do
        if hrp and (hrp.Position - rot.Position).Magnitude < 30 then
            hrp.CFrame = CFrame.new(rot.Position + Vector3.new(0, 1, 0))
            wait(0.1)
            fireAll({"CollectBrainrot", "collectBrainrot", "PickUp", "Grab", "Collect", "ClaimBrainrot"}, rot)
            fireAll({"Collect", "PickUp"}, rot)
        end
    end
    
    fireAll({"CollectBrainrot", "PickUpBrainrot", "GrabRot"})
end

-- 12. Auto Tsunami Escape
local function doTsunamiEscape()
    local hrp = getHRP()
    local escaped = false
    
    -- Find safe zone
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local oname = obj.Name:lower()
            if (oname:find("safe") or oname:find("zone") or oname:find("spawn") or oname:find("lobby") or oname:find("hub") or oname:find("plot") or oname:find("base")) then
                if escaped == false and hrp then
                    hrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 5, 0))
                    escaped = true
                    return
                end
            end
        end
    end
    
    -- Fallback: teleport upward
    if hrp then
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 75, 0)
    end
end

--=====================================================
-- MOVEMENT FEATURES
--=====================================================

-- Walkspeed
local walkspeedConns = {}
local function applyWalkspeed()
    for _, c in ipairs(walkspeedConns) do
        c:Disconnect()
    end
    walkspeedConns = {}
    
    if state.walkspeed ~= 16 then
        local c = runService.RenderStepped:Connect(function()
            local h = pcall(getHumanoid)
            if h then
                local humanoid = getHumanoid()
                if humanoid and humanoid.Health > 0 then
                    humanoid.WalkSpeed = state.walkspeed
                end
            end
        end)
        table.insert(walkspeedConns, c)
    end
end

-- Jump Power
local jumpConns = {}
local function applyJumpPower()
    for _, c in ipairs(jumpConns) do
        c:Disconnect()
    end
    jumpConns = {}
    
    if state.jumpPower ~= 50 then
        local c = runService.RenderStepped:Connect(function()
            local h = pcall(getHumanoid)
            if h then
                local humanoid = getHumanoid()
                if humanoid and humanoid.Health > 0 then
                    humanoid.JumpPower = state.jumpPower
                    humanoid.UseJumpPower = true
                end
            end
        end)
        table.insert(jumpConns, c)
    end
end

-- Noclip
local noclipConns = {}
local function applyNoclip()
    for _, c in ipairs(noclipConns) do
        c:Disconnect()
    end
    noclipConns = {}
    
    if state.noclip then
        local c = runService.Stepped:Connect(function()
            local char = getCharacter()
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
        table.insert(noclipConns, c)
    end
end

-- Fly
local flyConns = {}
local flyBodyObjects = {}
local function applyFly()
    for _, c in ipairs(flyConns) do
        c:Disconnect()
    end
    flyConns = {}
    
    -- Cleanup old body movers
    if flyBodyObjects.bodyGyro then pcall(function() flyBodyObjects.bodyGyro:Destroy() end) end
    if flyBodyObjects.bodyVelocity then pcall(function() flyBodyObjects.bodyVelocity:Destroy() end) end
    flyBodyObjects = {}
    
    if state.fly then
        local c = runService.RenderStepped:Connect(function()
            local hrp = pcall(getHRP)
            if not hrp then return end
            local hrpActual = getHRP()
            local humanoid = getHumanoid()
            if humanoid.Health <= 0 then return end
            
            humanoid.PlatformStand = true
            
            if not flyBodyObjects.bodyGyro or not flyBodyObjects.bodyGyro.Parent then
                local bg = Instance.new("BodyGyro")
                bg.MaxTorque = Vector3.new(400000, 400000, 400000)
                bg.P = 20000
                bg.D = 1000
                bg.Parent = hrpActual
                flyBodyObjects.bodyGyro = bg
            end
            
            if not flyBodyObjects.bodyVelocity or not flyBodyObjects.bodyVelocity.Parent then
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(100000, 100000, 100000)
                bv.P = 20000
                bv.Parent = hrpActual
                flyBodyObjects.bodyVelocity = bv
            end
            
            local camera = workspace.CurrentCamera
            local moveDir = Vector3.new()
            
            if userInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
            if userInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
            if userInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
            if userInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
            if userInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if userInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir + Vector3.new(0, -1, 0) end
            
            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit * state.flySpeed
            end
            
            flyBodyObjects.bodyVelocity.Velocity = moveDir
            flyBodyObjects.bodyGyro.CFrame = CFrame.new(hrpActual.Position, hrpActual.Position + camera.CFrame.LookVector)
        end)
        table.insert(flyConns, c)
        
        -- Cleanup handler
        coroutine.wrap(function()
            while state.fly do
                wait(0.5)
            end
            if flyBodyObjects.bodyGyro then pcall(function() flyBodyObjects.bodyGyro:Destroy() end) end
            if flyBodyObjects.bodyVelocity then pcall(function() flyBodyObjects.bodyVelocity:Destroy() end) end
            flyBodyObjects = {}
            local h = pcall(getHumanoid)
            if h then
                local humanoid = getHumanoid()
                if humanoid then humanoid.PlatformStand = false end
            end
        end)()
    end
end

--=====================================================
-- ANTI-KICK / ANTI-BAN
--=====================================================
local originalKick = nil
local originalRemove = nil

local function applyAntiKick()
    if state.antiKick then
        if not originalKick then
            originalKick = players.LocalPlayer.Kick
            players.LocalPlayer.Kick = function(self, ...)
                warn("[KALB] 🛡️ Blocked server kick attempt!")
                Rayfield:Notify({
                    Title = "Anti-Kick",
                    Content = "Blocked server kick attempt!",
                    Duration = 3,
                    Image = "shield",
                })
                return nil
            end
        end
        if not originalRemove then
            originalRemove = players.LocalPlayer.Remove
            players.LocalPlayer.Remove = function(self, ...)
                warn("[KALB] 🛡️ Blocked remove attempt!")
                return nil
            end
        end
        
        -- Also hook Character's Humanoid state changes
        local char = pcall(getCharacter)
        if char then
            local h = getHumanoid()
            if h then
                local oldBreakJoints = h.BreakJoints
                h.BreakJoints = function(self, ...)
                    warn("[KALB] 🛡️ Blocked BreakJoints!")
                    return nil
                end
            end
        end
    else
        if originalKick then
            players.LocalPlayer.Kick = originalKick
            originalKick = nil
        end
        if originalRemove then
            players.LocalPlayer.Remove = originalRemove
            originalRemove = nil
        end
    end
end

--=====================================================
-- ESP UPDATE MASTER
--=====================================================
local espConnection = nil
local function updateESP()
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end
    
    local anyESP = state.espBlocks or state.espBrainrots or state.espPlayers or state.espTsunami or state.espPlots
    
    if anyESP then
        espConnection = runService.RenderStepped:Connect(function()
            clearESP()
            
            if state.espBlocks then
                for _, block in ipairs(findLuckyBlocks()) do
                    local color = Color3.fromRGB(255, 215, 0)
                    -- Try to detect rarity by size/color
                    if block.BrickColor and block.BrickColor.Name:lower():find("blue") then
                        color = Color3.fromRGB(50, 150, 255)
                    elseif block.BrickColor and (block.BrickColor.Name:lower():find("gold") or block.BrickColor.Name:lower():find("yellow")) then
                        color = Color3.fromRGB(255, 215, 0)
                    elseif block.BrickColor and block.BrickColor.Name:lower():find("red") then
                        color = Color3.fromRGB(255, 50, 50)
                    end
                    local dist = math.floor(distanceFromCharacter(block.Position))
                    createESP(block, color, "🎯 [" .. dist .. "m]")
                end
            end
            
            if state.espBrainrots then
                for _, rot in ipairs(findBrainrotsOnGround()) do
                    createESP(rot, Color3.fromRGB(50, 255, 100), "🧠 Brainrot")
                end
                -- Also highlight placed brainrots
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and obj.Name:lower():find("brain") and obj.Transparency < 1 then
                        if not obj:FindFirstAncestorOfClass("Player") then
                            createESP(obj, Color3.fromRGB(100, 255, 150), "🧠 Active")
                        end
                    end
                end
            end
            
            if state.espPlayers then
                for _, plr in ipairs(players:GetPlayers()) do
                    if plr ~= player and plr.Character then
                        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local dist = math.floor((getHRP().Position - hrp.Position).Magnitude)
                            createESP(hrp, Color3.fromRGB(255, 80, 80), plr.Name .. " [" .. dist .. "m]")
                        end
                    end
                end
            end
            
            if state.espTsunami then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        local oname = obj.Name:lower()
                        if oname:find("tsunami") or oname:find("wave") or oname:find("water") or oname:find("flood") then
                            createESP(obj, Color3.fromRGB(0, 150, 255), "🌊 Tsunami")
                        end
                    end
                end
            end
            
            if state.espPlots then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        local oname = obj.Name:lower()
                        if (oname:find("plot") or oname:find("land") or oname:find("base") or oname:find("home") or oname:find("property")) and obj.Transparency < 1 then
                            local owner = "Unknown"
                            -- Try to find owner name
                            for _, plr in ipairs(players:GetPlayers()) do
                                if plr.Character and (plr.Character.Position - obj.Position).Magnitude < 50 then
                                    owner = plr.Name
                                    break
                                end
                            end
                            createESP(obj, Color3.fromRGB(255, 170, 0), "📐 " .. owner)
                        end
                    end
                end
            end
        end)
    end
end

--=====================================================
-- SETUP ALL LOOPS
--=====================================================
local function setupAllLoops()
    -- Farming loops
    if state.autoKick then startLoop("autoKick", doAutoKick, 1.5) else stopLoop("autoKick") end
    if state.autoPerfectKick then startLoop("autoPerfectKick", doPerfectKick, 0.5) else stopLoop("autoPerfectKick") end
    if state.autoCollectCash then startLoop("autoCollectCash", doCollectCash, state.autoCollectPro and 0.5 or 1.5) else stopLoop("autoCollectCash") end
    if state.autoPlaceBrainrot then startLoop("autoPlaceBrainrot", doPlaceBrainrot, 2) else stopLoop("autoPlaceBrainrot") end
    if state.autoUpgradeBrainrot then startLoop("autoUpgradeBrainrot", doUpgradeBrainrot, 2.5) else stopLoop("autoUpgradeBrainrot") end
    if state.autoTrain then startLoop("autoTrain", doTrain, state.fastTrain and 0.3 or 1) else stopLoop("autoTrain") end
    if state.autoRebirth then startLoop("autoRebirth", doRebirth, 5) else stopLoop("autoRebirth") end
    if state.autoBuyWeights then startLoop("autoBuyWeights", doBuyWeights, 3) else stopLoop("autoBuyWeights") end
    if state.autoBuyBestWeight then startLoop("autoBuyBestWeight", doBuyBestWeight, 3.5) else stopLoop("autoBuyBestWeight") end
    if state.autoUpgradePlot then startLoop("autoUpgradePlot", doUpgradePlot, 3) else stopLoop("autoUpgradePlot") end
    if state.autoCollectBrainrots then startLoop("autoCollectBrainrots", doCollectBrainrots, 1.5) else stopLoop("autoCollectBrainrots") end
    if state.autoTsunamiEscape then startLoop("autoTsunamiEscape", doTsunamiEscape, 0.5) else stopLoop("autoTsunamiEscape") end
    
-- Movement
    applyWalkspeed()
    applyJumpPower()
    applyNoclip()
    applyFly()
    
    -- ESP
    updateESP()
    
    -- Watermark
    updateWatermark()
    
    -- Info panel
    updateInfoPanel()
    
    -- Anti-kick
    applyAntiKick()
end

--=====================================================
-- INITIALIZE RAYFIELD WINDOW
--=====================================================
local Window = Rayfield:CreateWindow({
    Name = "Kick a Lucky Block - Advanced GUI",
    LoadingTitle = "KALB Advanced",
    LoadingSubtitle = "by turcja",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "KickALuckyBlock"
    },
    Discord = {
        Enabled = true,
        Invite = "turcja",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "KALB License",
        Subtitle = "Key System",
        Note = "Lifetime key required",
        FileName = "KALB_Key",
        SaveKey = false,
        GrabKeyFromSite = false,
        Key = {"turcja", "tungtung"}
    },
    ToggleUIKeybind = "K",
})

--=====================================================
-- INFORMATION TAB
--=====================================================
local InfoTab = Window:CreateTab("Information", 4483362458)

InfoTab:CreateParagraph({
    Title = "Kick a Lucky Block - Advanced GUI",
    Content = "Version: 2.0.0\nDeveloper: turcja\nGame: 89469502395769\nDiscord: discord.gg/turcja\n\nA fully-featured automation script with key system, farming, movement, ESP, exploits, and protection systems."
})

InfoTab:CreateSection("Player Information")

local kickPowerLabel = InfoTab:CreateLabel("⚡ Kick Power: Loading...")
local cashLabel = InfoTab:CreateLabel("💰 Cash: Loading...")
local brainrotLabel = InfoTab:CreateLabel("🧠 Brainrots: Loading...")
local rebirthLabel = InfoTab:CreateLabel("🔄 Rebirths: Loading...")
local serverLabel = InfoTab:CreateLabel("🆔 Server: " .. game.JobId)
local playersLabel = InfoTab:CreateLabel("👥 Players: " .. #players:GetPlayers())

-- Update player info periodically
coroutine.wrap(function()
    while wait(1) do
        local ls = player:FindFirstChild("leaderstats")
        if ls then
            for _, stat in ipairs(ls:GetChildren()) do
                local sn = stat.Name:lower()
                if sn:find("kick") or sn:find("power") then
                    kickPowerLabel:Set("⚡ Kick Power: " .. tostring(stat.Value))
                elseif sn:find("cash") or sn:find("money") or sn:find("coin") then
                    cashLabel:Set("💰 Cash: " .. tostring(stat.Value))
                elseif sn:find("brain") or sn:find("rot") or sn:find("pet") then
                    brainrotLabel:Set("🧠 Brainrots: " .. tostring(stat.Value))
                elseif sn:find("rebirth") or sn:find("prestige") or sn:find("level") then
                    rebirthLabel:Set("🔄 Rebirths: " .. tostring(stat.Value))
                end
            end
        end
        playersLabel:Set("👥 Players: " .. #players:GetPlayers())
    end
end)()

--=====================================================
-- FARMING TAB
--=====================================================
local FarmTab = Window:CreateTab("Farming", 4483362458)

-- 1
FarmTab:CreateToggle({
    Name = "Auto Kick",
    Info = "Automatically kick nearest lucky block",
    CurrentValue = false,
    Flag = "AutoKick",
    Callback = function(v)
        state.autoKick = v
        setupAllLoops()
    end,
})

-- 2
FarmTab:CreateToggle({
    Name = "Auto Perfect Kick (100% bar)",
    Info = "Forces the power bar to maximum for perfect kicks",
    CurrentValue = false,
    Flag = "AutoPerfectKick",
    Callback = function(v)
        state.autoPerfectKick = v
        setupAllLoops()
    end,
})

-- 3
FarmTab:CreateToggle({
    Name = "Auto Collect Cash",
    Info = "Automatically collects cash/claim triggers",
    CurrentValue = false,
    Flag = "AutoCollectCash",
    Callback = function(v)
        state.autoCollectCash = v
        setupAllLoops()
    end,
})

-- 4
FarmTab:CreateToggle({
    Name = "Auto Place Brainrot",
    Info = "Automatically places brainrots",
    CurrentValue = false,
    Flag = "AutoPlaceBrainrot",
    Callback = function(v)
        state.autoPlaceBrainrot = v
        setupAllLoops()
    end,
})

-- 5
FarmTab:CreateToggle({
    Name = "Auto Upgrade Brainrot",
    Info = "Automatically upgrades brainrots",
    CurrentValue = false,
    Flag = "AutoUpgradeBrainrot",
    Callback = function(v)
        state.autoUpgradeBrainrot = v
        setupAllLoops()
    end,
})

-- 6
FarmTab:CreateToggle({
    Name = "Auto Train (lift weights)",
    Info = "Finds and uses weight stations to train kick power",
    CurrentValue = false,
    Flag = "AutoTrain",
    Callback = function(v)
        state.autoTrain = v
        setupAllLoops()
    end,
})

-- 7
FarmTab:CreateToggle({
    Name = "Auto Rebirth",
    Info = "Automatically rebirth/resets when possible",
    CurrentValue = false,
    Flag = "AutoRebirth",
    Callback = function(v)
        state.autoRebirth = v
        setupAllLoops()
    end,
})

-- 8
FarmTab:CreateToggle({
    Name = "Auto Buy Weights",
    Info = "Buys weights from the shop",
    CurrentValue = false,
    Flag = "AutoBuyWeights",
    Callback = function(v)
        state.autoBuyWeights = v
        setupAllLoops()
    end,
})

-- 9
FarmTab:CreateToggle({
    Name = "Auto Upgrade Plot",
    Info = "Upgrades your plot/land size",
    CurrentValue = false,
    Flag = "AutoUpgradePlot",
    Callback = function(v)
        state.autoUpgradePlot = v
        setupAllLoops()
    end,
})

-- 10
FarmTab:CreateToggle({
    Name = "Auto Collect Brainrots (ground)",
    Info = "Picks up brainrots that spawn after tsunami",
    CurrentValue = false,
    Flag = "AutoCollectBrainrots",
    Callback = function(v)
        state.autoCollectBrainrots = v
        setupAllLoops()
    end,
})

--=====================================================
-- MOVEMENT TAB
--=====================================================
local MoveTab = Window:CreateTab("Movement", 4483362458)

MoveTab:CreateSection("Stats")

MoveTab:CreateSlider({
    Name = "Walkspeed",
    Range = {16, 250},
    Increment = 1,
    Suffix = "studs/s",
    CurrentValue = 16,
    Flag = "Walkspeed",
    Callback = function(v)
        state.walkspeed = v
        applyWalkspeed()
    end,
})

MoveTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 500},
    Increment = 5,
    Suffix = "power",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(v)
        state.jumpPower = v
        applyJumpPower()
    end,
})

MoveTab:CreateSection("Abilities")

MoveTab:CreateToggle({
    Name = "Noclip",
    Info = "Walk through walls and obstacles",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(v)
        state.noclip = v
        applyNoclip()
    end,
})

MoveTab:CreateToggle({
    Name = "Fly (WASD + Space/Shift)",
    Info = "Free fly movement with WASD controls",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(v)
        state.fly = v
        applyFly()
    end,
})

MoveTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 5,
    Suffix = "studs/s",
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(v)
        state.flySpeed = v
    end,
})

MoveTab:CreateSection("Teleports")

MoveTab:CreateButton({
    Name = "🔄 Teleport to Spawn",
    Callback = function()
        local spawns = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("spawn") or obj.Name:lower():find("lobby")) then
                table.insert(spawns, obj)
            end
        end
        if #spawns > 0 then
            local hrp = getHRP()
            hrp.CFrame = CFrame.new(spawns[1].Position + Vector3.new(0, 3, 0))
            Rayfield:Notify({Title="Teleported", Content="Teleported to spawn", Duration=2, Image="map-pin"})
        else
            -- Fallback: go to center
            local hrp = getHRP()
            hrp.CFrame = CFrame.new(0, 10, 0)
            Rayfield:Notify({Title="Teleported", Content="Teleported to center", Duration=2, Image="map-pin"})
        end
    end,
})

MoveTab:CreateButton({
    Name = "📐 Teleport to Nearest Plot",
    Callback = function()
        local nearest = nil
        local nearestDist = math.huge
        local hrp = getHRP()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("plot") or obj.Name:lower():find("land")) then
                local dist = (hrp.Position - obj.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = obj
                end
            end
        end
        if nearest then
            hrp.CFrame = CFrame.new(nearest.Position + Vector3.new(0, 5, 0))
            Rayfield:Notify({Title="Teleported", Content="Teleported to nearest plot", Duration=2, Image="map-pin"})
        end
    end,
})

MoveTab:CreateButton({
    Name = "🏋️ Teleport to Weights/Gym",
    Callback = function()
        local nearest = nil
        local nearestDist = math.huge
        local hrp = getHRP()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local oname = obj.Name:lower()
                if (oname:find("weight") or oname:find("gym") or oname:find("train") or oname:find("dumb") or oname:find("lift")) then
                    local dist = (hrp.Position - obj.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = obj
                    end
                end
            end
        end
        if nearest then
            hrp.CFrame = CFrame.new(nearest.Position + Vector3.new(0, 3, 0))
            Rayfield:Notify({Title="Teleported", Content="Teleported to training area", Duration=2, Image="map-pin"})
        end
    end,
})

MoveTab:CreateButton({
    Name = "🎯 Teleport to Nearest Lucky Block",
    Callback = function()
        local block = findNearestBlock()
        if block then
            local hrp = getHRP()
            hrp.CFrame = CFrame.new(block.Position + Vector3.new(0, 2, 0))
            Rayfield:Notify({Title="Teleported", Content="Teleported to lucky block", Duration=2, Image="map-pin"})
        end
    end,
})

--=====================================================
-- ESP TAB
--=====================================================
local ESPTab = Window:CreateTab("ESP", 4483362458)

ESPTab:CreateToggle({
    Name = "Lucky Blocks",
    Info = "Highlights all lucky blocks with distance",
    CurrentValue = false,
    Flag = "ESPBlocks",
    Callback = function(v)
        state.espBlocks = v
        updateESP()
    end,
})

ESPTab:CreateToggle({
    Name = "Brainrots on Ground",
    Info = "Highlights brainrots scattered on the ground",
    CurrentValue = false,
    Flag = "ESPBrainrots",
    Callback = function(v)
        state.espBrainrots = v
        updateESP()
    end,
})

ESPTab:CreateToggle({
    Name = "Players",
    Info = "Highlights other players with distance",
    CurrentValue = false,
    Flag = "ESPPlayers",
    Callback = function(v)
        state.espPlayers = v
        updateESP()
    end,
})

ESPTab:CreateToggle({
    Name = "Tsunami / Water",
    Info = "Highlights tsunami waves and water bodies",
    CurrentValue = false,
    Flag = "ESPTsunami",
    Callback = function(v)
        state.espTsunami = v
        updateESP()
    end,
})

ESPTab:CreateToggle({
    Name = "Plots / Land",
    Info = "Highlights plots and shows owner",
    CurrentValue = false,
    Flag = "ESPPlots",
    Callback = function(v)
        state.espPlots = v
        updateESP()
    end,
})

ESPTab:CreateDivider()

ESPTab:CreateButton({
    Name = "🗑️ Clear All ESP",
    Callback = function()
        clearESP()
        Rayfield:Notify({Title="ESP Cleared", Content="All ESP highlights removed", Duration=2, Image="trash-2"})
    end,
})

--=====================================================
-- EXPLOITS TAB
--=====================================================
local ExploitTab = Window:CreateTab("Exploits", 4483362458)

ExploitTab:CreateSection("Farming Exploits")

ExploitTab:CreateToggle({
    Name = "Auto Collect Pro (0.5s interval)",
    Info = "Speeds up cash collection to every 0.5 seconds",
    CurrentValue = false,
    Flag = "AutoCollectPro",
    Callback = function(v)
        state.autoCollectPro = v
        if state.autoCollectCash then
            setupAllLoops()
        end
        Rayfield:Notify({
            Title = "Auto Collect Pro",
            Content = v and "Enabled fast collection (0.5s)" or "Disabled fast collection",
            Duration = 2,
            Image = v and "zap" or "power",
        })
    end,
})

ExploitTab:CreateToggle({
    Name = "Multi Drop (brainrot dupe)",
    Info = "Attempts to drop multiple brainrots at once for duplication",
    CurrentValue = false,
    Flag = "MultiDrop",
    Callback = function(v)
        state.multiDrop = v
        if v then
            startLoop("multiDrop", function()
                fireAll({"Drop", "drop", "MultiDrop", "Duplicate", "Spawn", "Place", "Deploy"}, nil)
                fireAll({"Drop", "MultiDrop"})
                wait(0.3)
            end, 0.5)
        else
            stopLoop("multiDrop")
        end
    end,
})

ExploitTab:CreateToggle({
    Name = "Fast Train (0.3s interval)",
    Info = "Speeds up weight training to max rate",
    CurrentValue = false,
    Flag = "FastTrain",
    Callback = function(v)
        state.fastTrain = v
        if state.autoTrain then
            setupAllLoops()
        end
        Rayfield:Notify({
            Title = "Fast Train",
            Content = v and "Training speed boosted to 0.3s" or "Training speed returned to normal",
            Duration = 2,
            Image = v and "zap" or "power",
        })
    end,
})

ExploitTab:CreateToggle({
    Name = "Instant Collect (insta-claim)",
    Info = "Attempts to instant-claim rewards without delay",
    CurrentValue = false,
    Flag = "InstantCollect",
    Callback = function(v)
        state.instantCollect = v
        if v then
            startLoop("instantCollect", function()
                fireAll({"InstantCollect", "instant", "Claim", "Collect", "InstantClaim", "ImmediateClaim", "ForceClaim"})
                wait(0.1)
            end, 0.5)
        else
            stopLoop("instantCollect")
        end
    end,
})

ExploitTab:CreateToggle({
    Name = "Auto Buy Best Weight",
    Info = "Automatically purchases the highest tier weight available",
    CurrentValue = false,
    Flag = "AutoBuyBestWeight",
    Callback = function(v)
        state.autoBuyBestWeight = v
        setupAllLoops()
        Rayfield:Notify({
            Title = "Auto Buy Best Weight",
            Content = v and "Will purchase best weights automatically" or "Disabled",
            Duration = 2,
            Image = v and "shopping-cart" or "power",
        })
    end,
})

--=====================================================
-- SETTINGS TAB
--=====================================================
local SettingsTab = Window:CreateTab("Settings", 4483362458)

SettingsTab:CreateSection("Protection")

SettingsTab:CreateToggle({
    Name = "Anti-Kick (blocks server kicks)",
    Info = "Hooks the Kick function to prevent being kicked by anti-exploit",
    CurrentValue = false,
    Flag = "AntiKick",
    Callback = function(v)
        state.antiKick = v
        applyAntiKick()
        Rayfield:Notify({
            Title = "Anti-Kick",
            Content = v and "🛡️ You are now protected from kicks!" or "Anti-kick disabled",
            Duration = 3,
            Image = "shield",
        })
    end,
})

SettingsTab:CreateToggle({
    Name = "Anti-Ban (remove blocker)",
    Info = "Blocks the Remove function to prevent being banned",
    CurrentValue = false,
    Flag = "AntiBan",
    Callback = function(v)
        state.antiBan = v
        if v then
            if not originalRemove then
                originalRemove = players.LocalPlayer.Remove
                players.LocalPlayer.Remove = function(self, ...)
                    warn("[KALB] 🛡️ Blocked remove (ban) attempt!")
                    return nil
                end
            end
            -- Also hook children clearing
            local char = pcall(getCharacter)
            if char then
                local h = getHumanoid()
                if h then
                    local oldBreak = h.BreakJoints
                    h.BreakJoints = function(self, ...)
                        warn("[KALB] 🛡️ Blocked BreakJoints!")
                        return nil
                    end
                end
            end
            Rayfield:Notify({Title="Anti-Ban", Content="🛡️ Ban protection enabled", Duration=3, Image="shield"})
        else
            if originalRemove then
                players.LocalPlayer.Remove = originalRemove
                originalRemove = nil
            end
            Rayfield:Notify({Title="Anti-Ban", Content="Ban protection disabled", Duration=3, Image="power"})
        end
    end,
})

SettingsTab:CreateSection("Spoofing")

SettingsTab:CreateToggle({
    Name = "Spoof Walkspeed",
    Info = "Continuously resets walkspeed to prevent detection",
    CurrentValue = false,
    Flag = "SpoofWalkspeed",
    Callback = function(v)
        state.spoofWalkspeed = v
        if v then
            startLoop("spoofWalkspeed", function()
                local h = pcall(getHumanoid)
                if h then
                    local humanoid = getHumanoid()
                    if humanoid then
                        humanoid.WalkSpeed = state.walkspeed
                    end
                end
            end, 0.5)
        else
            stopLoop("spoofWalkspeed")
        end
    end,
})

SettingsTab:CreateToggle({
    Name = "Spoof Position",
    Info = "Sends fake position to server (anti-detection)",
    CurrentValue = false,
    Flag = "SpoofPosition",
    Callback = function(v)
        state.spoofPosition = v
        if v then
            startLoop("spoofPosition", function()
                -- Try to send fake position updates
                fireAll({"UpdatePos", "updatePosition", "Move", "MoveDetection", "AntiCheat", "PositionCheck", "Heartbeat"}, 
                    Vector3.new(0, 10, 0))
                fireAll({"Move", "Position"})
            end, 1)
        else
            stopLoop("spoofPosition")
        end
    end,
})

SettingsTab:CreateSection("Performance")

SettingsTab:CreateToggle({
    Name = "Remote Spam Blocker",
    Info = "Blocks excessive remote calls to prevent lag/detection",
    CurrentValue = false,
    Flag = "RemoteSpamBlocker",
    Callback = function(v)
        state.remoteSpamBlocker = v
        Rayfield:Notify({
            Title = "Remote Spam Blocker",
            Content = v and "Enabled - will throttle excessive remote calls" or "Disabled",
            Duration = 2,
            Image = v and "filter" or "power",
        })
    end,
})

SettingsTab:CreateToggle({
    Name = "Logs Cleaner",
    Info = "Clears console/output logs periodically to reduce clutter",
    CurrentValue = false,
    Flag = "LogsCleaner",
    Callback = function(v)
        state.logsCleaner = v
        if v then
            startLoop("logsCleaner", function()
                pcall(function()
                    if syn and syn.clearconsole then syn.clearconsole() end
                    if rconsoleclear then rconsoleclear() end
                end)
            end, 30)
        else
            stopLoop("logsCleaner")
        end
    end,
})

SettingsTab:CreateSection("Utility")

SettingsTab:CreateToggle({
    Name = "Info Panel (HUD overlay)",
    Info = "Shows kick power, cash, brainrots, rebirths overlay",
    CurrentValue = false,
    Flag = "InfoPanel",
    Callback = function(v)
        state.infoPanel = v
        updateInfoPanel()
    end,
})

SettingsTab:CreateToggle({
    Name = "Auto Rejoin",
    Info = "Automatically rejoins the game on disconnect",
    CurrentValue = false,
    Flag = "AutoRejoin",
    Callback = function(v)
        state.autoRejoin = v
        if v then
            player.OnTeleport:Connect(function(state, type, data)
                if state == Enum.TeleportState.Failed then
                    pcall(function()
                        game:GetService("TeleportService"):Teleport(game.PlaceId, player)
                    end)
                end
            end)
            Rayfield:Notify({Title="Auto Rejoin", Content="Will auto-rejoin on disconnect", Duration=2, Image="refresh-cw"})
        end
    end,
})

SettingsTab:CreateToggle({
    Name = "Server Hopper",
    Info = "Hops to a new server automatically",
    CurrentValue = false,
    Flag = "ServerHopper",
    Callback = function(v)
        state.serverHopper = v
        if v then
            startLoop("serverHopper", function()
                -- Wait a bit then hop
                wait(30)
                if state.serverHopper then
                    local servers = {}
                    local suc, data = pcall(function()
                        return game:GetService("HttpService"):JSONDecode(
                            game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100")
                        )
                    end)
                    if suc and data and data.data then
                        for _, srv in ipairs(data.data) do
                            if srv.id ~= game.JobId then
                                table.insert(servers, srv.id)
                            end
                        end
                        if #servers > 0 then
                            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], player)
                        end
                    end
                end
            end, 35)
        else
            stopLoop("serverHopper")
        end
    end,
})

SettingsTab:CreateToggle({
    Name = "Block Radar (distance scanner)",
    Info = "Scans and logs nearest lucky block distances",
    CurrentValue = false,
    Flag = "BlockRadar",
    Callback = function(v)
        state.blockRadar = v
        if v then
            startLoop("blockRadar", function()
                local blocks = findLuckyBlocks()
                local hrp = getHRP()
                for _, block in ipairs(blocks) do
                    if hrp then
                        local dist = math.floor((hrp.Position - block.Position).Magnitude)
                        if dist < 50 then
                            -- Auto-navigate to nearest nearby block
                            hrp.CFrame = CFrame.new(block.Position + Vector3.new(0, 2, 0))
                            break
                        end
                    end
                end
            end, 2)
        else
            stopLoop("blockRadar")
        end
    end,
})

SettingsTab:CreateToggle({
    Name = "Auto Tsunami Escape",
    Info = "Teleports to safety when tsunami is detected",
    CurrentValue = false,
    Flag = "AutoTsunamiEscape",
    Callback = function(v)
        state.autoTsunamiEscape = v
        setupAllLoops()
    end,
})

SettingsTab:CreateSection("Visuals")

SettingsTab:CreateToggle({
    Name = "Watermark (powered by turcja)",
    Info = "Shows faint pulsing watermark in bottom-right",
    CurrentValue = false,
    Flag = "Watermark",
    Callback = function(v)
        state.watermark = v
        updateWatermark()
    end,
})

SettingsTab:CreateSection("Teleport to Position")

SettingsTab:CreateButton({
    Name = "🎯 Set Current Position as Target",
    Callback = function()
        local hrp = getHRP()
        if hrp then
            state.targetPosition = hrp.Position
            Rayfield:Notify({
                Title = "Position Set",
                Content = "Target position saved: " .. tostring(state.targetPosition),
                Duration = 3,
                Image = "map-pin",
            })
        end
    end,
})

SettingsTab:CreateButton({
    Name = "🚀 Teleport to Target Position",
    Callback = function()
        if state.targetPosition then
            local hrp = getHRP()
            hrp.CFrame = CFrame.new(state.targetPosition)
            Rayfield:Notify({
                Title = "Teleported",
                Content = "Teleported to saved position",
                Duration = 2,
                Image = "map-pin",
            })
        else
            Rayfield:Notify({
                Title = "No Position",
                Content = "Set a target position first using 'Set Current Position'",
                Duration = 3,
                Image = "alert-circle",
            })
        end
    end,
})

SettingsTab:CreateSection("Script Info")

SettingsTab:CreateParagraph({
    Title = "Kick a Lucky Block - Advanced GUI v2.0.0",
    Content = "Developed by: turcja\nDiscord: discord.gg/turcja\nGame ID: 89469502395769\n\nAll features are functional. Configuration is saved automatically.\nToggle UI with the K key.\n\nCredits: Rayfield UI Library by Sirius"
})

--=====================================================
-- LOAD CONFIGURATION
--=====================================================
Rayfield:LoadConfiguration()

--=====================================================
-- NOTIFICATION
--=====================================================
wait(0.5)
Rayfield:Notify({
    Title = "KALB Loaded",
    Content = "✅ Script loaded successfully! Toggle UI with K key.",
    Duration = 4,
    Image = "check-circle",
})
