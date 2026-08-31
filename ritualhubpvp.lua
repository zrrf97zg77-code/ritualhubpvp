-- ============================================================
-- RITUAL HUB V3.2 | MOBILE OPTIMIZED | BLACK & GOLD THEME
-- MADE BY: RITUALZ999
-- ============================================================
-- FIXES:
-- ✅ Aimbot WORKS (Silent Aim with FOV)
-- ✅ All sliders work properly (mobile touch fixed)
-- ✅ Crown button (pinky tip size)
-- ✅ Discord tags: ritualz999 & rayo06996
-- ✅ Mobile optimized (touch-friendly)
-- ============================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = nil
pcall(function() mouse = player and player:GetMouse() end)

local playerGui = nil
pcall(function() 
    if player then
        playerGui = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui", 5)
    end
end)

-- ============================================================
-- THEME COLORS
-- ============================================================
local GOLD = Color3.fromRGB(255, 215, 0)
local DARK_GOLD = Color3.fromRGB(184, 134, 11)
local BLACK = Color3.fromRGB(0, 0, 0)
local TEXT_WHITE = Color3.fromRGB(255, 255, 255)
local RITUAL_RED = Color3.fromRGB(180, 20, 20)

-- ============================================================
-- FOV CIRCLE (Drawing)
-- ============================================================
local FOVCircle = nil
pcall(function()
    if Drawing and Drawing.new then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Visible = false
        FOVCircle.Color = GOLD
        FOVCircle.Radius = 150
        FOVCircle.Thickness = 2
        FOVCircle.Filled = false
        FOVCircle.Transparency = 0.4
    end
end)

-- ============================================================
-- SILENT AIM VARIABLES
-- ============================================================
local SilentAimEnabled = false
local SilentAimPlayers = false
local SilentAimNPCs = false
local ShowFOVCircle = false
local FOVRadius = 150
local MaxRange = 2500
local SilentAimPart = "HumanoidRootPart"
local HeadshotOnly = false
local WallCheck = false
local Prediction = false
local LockOn = false
local TeamCheck = false
local IgnoreSafeZone = true
local IgnorePvPOff = true
local currentTarget = nil
local targetPosition = nil
local lockedTarget = nil

-- ============================================================
-- TARGET HELPERS
-- ============================================================
function IsAlly(target)
    local main = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("Main")
    if not main then return false end
    local allies = main:FindFirstChild("Allies")
    if not allies then return false end
    local container = allies:FindFirstChild("Container")
    if not container then return false end
    local allyFrame = container:FindFirstChild("Allies")
    if not allyFrame then return false end
    local scroll = allyFrame:FindFirstChild("ScrollingFrame")
    if not scroll then return false end
    local frame = scroll:FindFirstChild("Frame")
    if not frame then return false end
    return frame:FindFirstChild(target.Name) ~= nil
end

function IsEnemy(target)
    if not target or target == player then return false end
    if IsAlly(target) then return false end
    local myTeam, targetTeam = player.Team, target.Team
    if myTeam and targetTeam then
        if myTeam.Name == "Marines" and targetTeam.Name == "Marines" then return false end
    end
    return true
end

function IsPvPOff(target)
    pcall(function()
        local attr = target:GetAttribute("PvpDisabled")
        if attr ~= nil then return attr == true end
    end)
    local main = target.PlayerGui and target.PlayerGui:FindFirstChild("Main")
    if main then
        local dis = main:FindFirstChild("PvpDisabled")
        if dis then return dis.Visible == true end
    end
    return false
end

function InSafeZone(target)
    local char = target.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local wo = workspace:FindFirstChild("_WorldOrigin")
    if not wo then return false end

    local safeZones = wo:FindFirstChild("SafeZones")
    if safeZones then
        for _, zone in pairs(safeZones:GetChildren()) do
            local mesh = zone:FindFirstChild("Mesh")
            if mesh and mesh:IsA("SpecialMesh") then
                local realDiameter = zone.Size.X * mesh.Scale.X
                local radius = realDiameter / 2
                if radius and radius > 0 then
                    local dist = (zone.Position - hrp.Position).Magnitude
                    if dist <= radius then return true end
                end
            end
        end
    end
    return false
end

function IsTargetVisible(targetPart)
    if not WallCheck then return true end
    local myChar = player.Character
    if not myChar then return true end
    local root = myChar:FindFirstChild("HumanoidRootPart")
    if not root then return true end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {myChar}
    
    local direction = (targetPart.Position - root.Position).Unit
    local ray = workspace:Raycast(root.Position, direction * 500, raycastParams)
    if ray then
        local hit = ray.Instance
        if hit and hit:IsA("BasePart") and hit.Parent ~= targetPart.Parent then
            return false
        end
    end
    return true
end

-- ============================================================
-- GET TARGET IN FOV
-- ============================================================
function GetTargetInFOV()
    local myChar = player.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    local maxDist3D = MaxRange or 2500
    local fovRadius = FOVRadius or 150
    
    local cam = workspace.CurrentCamera
    local viewportSize = cam and cam.ViewportSize
    if not viewportSize then return nil end

    if LockOn and lockedTarget and lockedTarget.Parent then
        local hum = lockedTarget.Parent:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            local screenPos, onScreen = cam:WorldToViewportPoint(lockedTarget.Position)
            if onScreen then
                local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
                local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                if screenDist <= fovRadius then
                    return lockedTarget
                end
            end
        end
        lockedTarget = nil
    end

    local closestPart = nil
    local shortestDist = maxDist3D
    local shortestScreenDist = math.huge

    local function checkTarget(character)
        if not character or character == myChar then return end

        local p = Players:GetPlayerFromCharacter(character)
        if p then
            if p == player then return end
            if TeamCheck and not IsEnemy(p) then return end
            if IgnorePvPOff and IsPvPOff(p) then return end
            if IgnoreSafeZone and InSafeZone(p) then return end
        end

        local hum = character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        
        local targetPart = nil
        if HeadshotOnly then
            targetPart = character:FindFirstChild("Head")
        end
        if not targetPart then
            targetPart = character:FindFirstChild(SilentAimPart) or character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
        end
        if not targetPart then return end

        if not IsTargetVisible(targetPart) then return end

        local worldDist = (targetPart.Position - myHRP.Position).Magnitude
        if worldDist > shortestDist then return end

        local screenPos, onScreen = cam:WorldToViewportPoint(targetPart.Position)
        if not onScreen then return end
        
        local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        
        if screenDist <= fovRadius then
            if Prediction then
                local velocity = hum:GetVelocity()
                if velocity and velocity.Magnitude > 5 then
                    local predictedPos = targetPart.Position + (velocity * 0.12)
                    local predScreenPos, predOnScreen = cam:WorldToViewportPoint(predictedPos)
                    if predOnScreen then
                        local predScreenDist = (Vector2.new(predScreenPos.X, predScreenPos.Y) - screenCenter).Magnitude
                        if predScreenDist <= fovRadius and predScreenDist < shortestScreenDist then
                            shortestScreenDist = predScreenDist
                            shortestDist = worldDist
                            closestPart = targetPart
                            targetPosition = predictedPos
                            return
                        end
                    end
                end
            end
            
            if screenDist < shortestScreenDist then
                shortestScreenDist = screenDist
                shortestDist = worldDist
                closestPart = targetPart
                targetPosition = targetPart.Position
            end
        end
    end

    if SilentAimPlayers then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                checkTarget(p.Character)
            end
        end
    end

    if SilentAimNPCs then
        local enemies = workspace:FindFirstChild("Enemies")
        if enemies then
            for _, enemy in pairs(enemies:GetChildren()) do
                checkTarget(enemy)
            end
        end
    end

    if closestPart then
        lockedTarget = closestPart
    end
    return closestPart
end

-- ============================================================
-- METAMETHOD HOOKS FOR SILENT AIM
-- ============================================================
local oldIndex = nil
local oldNamecall = nil

pcall(function()
    local mt = getrawmetatable(game)
    if mt then
        oldIndex = mt.__index
        oldNamecall = mt.__namecall
        if setreadonly then pcall(setreadonly, mt, false) end

        mt.__index = newcclosure(function(self, key)
            if not checkcaller() and self == mouse and (key == "Hit" or key == "Target") then
                if SilentAimEnabled and currentTarget then
                    if key == "Hit" then 
                        local pos = targetPosition or currentTarget.Position
                        return CFrame.new(pos) 
                    end
                    if key == "Target" then return currentTarget end
                end
            end
            return oldIndex(self, key)
        end)

        mt.__namecall = newcclosure(function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            local methodStr = method and tostring(method):lower() or ""

            if not checkcaller() and (methodStr == "fireserver" or methodStr == "invokeserver") then
                if SilentAimEnabled and currentTarget then
                    local activePos = targetPosition or currentTarget.Position

                    if self.Name and (self.Name == "RE/RegisterHit" or self.Name == "RegisterHit" or string.find(self.Name, "RegisterHit")) then
                        local targetChar = currentTarget.Parent
                        local targetHead = targetChar and (targetChar:FindFirstChild("Head") or targetChar:FindFirstChild("HumanoidRootPart")) or currentTarget
                        if targetHead and targetChar then
                            args[1] = targetHead
                            args[2] = { { targetChar, targetHead } }
                            return oldNamecall(self, unpack(args))
                        end
                    end

                    if self.Name and (self.Name == "RE/ShootGunEvent" or self.Name == "ShootGunEvent" or string.find(self.Name, "ShootGunEvent")) then
                        args[1] = activePos
                        if currentTarget.Parent then
                            args[2] = { currentTarget.Parent }
                        end
                        return oldNamecall(self, unpack(args))
                    end

                    for i, arg in ipairs(args) do
                        if typeof(arg) == "Vector3" then 
                            args[i] = activePos
                        elseif typeof(arg) == "CFrame" then 
                            args[i] = CFrame.new(activePos)
                        end
                    end
                    return oldNamecall(self, unpack(args))
                end
            end

            return oldNamecall(self, ...)
        end)
        if setreadonly then pcall(setreadonly, mt, true) end
    end
end)

-- ============================================================
-- UPDATE TARGET LOOP
-- ============================================================
RunService.RenderStepped:Connect(function()
    pcall(function()
        if FOVCircle then
            local cam = workspace.CurrentCamera
            if cam then
                local viewportSize = cam.ViewportSize
                FOVCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
                FOVCircle.Radius = FOVRadius
                FOVCircle.Visible = SilentAimEnabled and ShowFOVCircle
            end
        end
        
        if SilentAimEnabled then
            currentTarget = GetTargetInFOV()
        else
            currentTarget = nil
            targetPosition = nil
            lockedTarget = nil
        end
    end)
end)

-- ============================================================
-- CROWN TOGGLE BUTTON (Mobile Optimized)
-- ============================================================
local crownToggleGui = Instance.new("ScreenGui")
crownToggleGui.Name = "RitualCrownToggle"
crownToggleGui.ResetOnSpawn = false
crownToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
crownToggleGui.Parent = playerGui or CoreGui

local crownButton = Instance.new("TextButton")
crownButton.Size = UDim2.new(0, 40, 0, 40)
crownButton.Position = UDim2.new(0.02, 0, 0.5, -20)
crownButton.BackgroundColor3 = BLACK
crownButton.BackgroundTransparency = 0.2
crownButton.Text = "👑"
crownButton.Font = Enum.Font.GothamBold
crownButton.TextSize = 20
crownButton.TextColor3 = GOLD
crownButton.Active = true
crownButton.Draggable = true
crownButton.Visible = true
crownButton.ZIndex = 1000
crownButton.Parent = crownToggleGui

Instance.new("UICorner", crownButton).CornerRadius = UDim.new(1, 0)
local crownStroke = Instance.new("UIStroke", crownButton)
crownStroke.Color = GOLD
crownStroke.Thickness = 2

local mainFrame = nil
local screenGui = nil
local isUIOpen = false

crownButton.MouseButton1Click:Connect(function()
    if mainFrame then
        isUIOpen = not isUIOpen
        mainFrame.Visible = isUIOpen
        crownButton.Visible = not isUIOpen
    end
end)

-- ============================================================
-- CREATE MAIN UI (Mobile Optimized)
-- ============================================================
screenGui = Instance.new("ScreenGui")
screenGui.Name = "RitualUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui or CoreGui

mainFrame = Instance.new("Frame")
mainFrame.Name = "RitualMainFrame"
mainFrame.Size = UDim2.new(0, 380, 0, 500)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -250)
mainFrame.BackgroundColor3 = BLACK
mainFrame.BackgroundTransparency = 0
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 24)

local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = GOLD
mainStroke.Thickness = 2

-- HEADER
local header = Instance.new("Frame", mainFrame)
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = BLACK
header.BackgroundTransparency = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 24)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0.7, 0, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "⚜️ RITUAL HUB"
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.TextColor3 = GOLD
title.TextXAlignment = Enum.TextXAlignment.Left

-- Close Buttons
local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -36, 0.5, -15)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = RITUAL_RED
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    isUIOpen = false
    crownButton.Visible = true
end)

local minBtn = Instance.new("TextButton", header)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -66, 0.5, -15)
minBtn.BackgroundTransparency = 1
minBtn.Text = "─"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
minBtn.TextColor3 = GOLD
minBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    isUIOpen = false
    crownButton.Visible = true
end)

-- DISCORD TAGS
local discordFrame = Instance.new("Frame", mainFrame)
discordFrame.Size = UDim2.new(1, 0, 0, 34)
discordFrame.Position = UDim2.new(0, 0, 0, 54)
discordFrame.BackgroundTransparency = 1

local d1 = Instance.new("TextLabel", discordFrame)
d1.Size = UDim2.new(0.5, 0, 1, 0)
d1.Position = UDim2.new(0, 0, 0, 0)
d1.BackgroundTransparency = 1
d1.Text = "discord: ritualz999"
d1.Font = Enum.Font.GothamBold
d1.TextSize = 10
d1.TextColor3 = DARK_GOLD
d1.TextXAlignment = Enum.TextXAlignment.Right

local d2 = Instance.new("TextLabel", discordFrame)
d2.Size = UDim2.new(0.5, 0, 1, 0)
d2.Position = UDim2.new(0.5, 0, 0, 0)
d2.BackgroundTransparency = 1
d2.Text = "discord: rayo06996"
d2.Font = Enum.Font.GothamBold
d2.TextSize = 10
d2.TextColor3 = DARK_GOLD
d2.TextXAlignment = Enum.TextXAlignment.Left

-- CONTENT FRAME
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, 0, 1, -88)
contentFrame.Position = UDim2.new(0, 0, 0, 88)
contentFrame.BackgroundTransparency = 1
contentFrame.ClipsDescendants = true

local contentScroll = Instance.new("ScrollingFrame", contentFrame)
contentScroll.Size = UDim2.new(1, -8, 1, 0)
contentScroll.Position = UDim2.new(0, 4, 0, 0)
contentScroll.BackgroundTransparency = 1
contentScroll.BorderSizePixel = 0
contentScroll.ScrollBarThickness = 4
contentScroll.CanvasSize = UDim2.new(0, 0, 0, 800)

local contentLayout = Instance.new("UIListLayout", contentScroll)
contentLayout.Padding = UDim.new(0, 8)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ============================================================
-- UI HELPERS (Mobile Touch Optimized)
-- ============================================================
local function createSection(title)
    local lbl = Instance.new("TextLabel", contentScroll)
    lbl.Size = UDim2.new(1, 0, 0, 28)
    lbl.BackgroundTransparency = 1
    lbl.Text = "⚜️ " .. title
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextSize = 14
    lbl.TextColor3 = GOLD
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    return lbl
end

local function createToggle(label, default, callback)
    local frame = Instance.new("Frame", contentScroll)
    frame.Size = UDim2.new(1, -4, 0, 30)
    frame.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.65, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextColor3 = TEXT_WHITE
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 50, 0, 24)
    btn.Position = UDim2.new(1, -54, 0.5, -12)
    btn.BackgroundColor3 = default and GOLD or Color3.fromRGB(30, 30, 40)
    btn.BackgroundTransparency = default and 0.2 or 0.5
    btn.Text = default and "ON" or "OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.TextColor3 = default and BLACK or TEXT_WHITE
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = GOLD
    stroke.Thickness = 1
    
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and GOLD or Color3.fromRGB(30, 30, 40)
        btn.BackgroundTransparency = state and 0.2 or 0.5
        btn.Text = state and "ON" or "OFF"
        btn.TextColor3 = state and BLACK or TEXT_WHITE
        if callback then callback(state) end
    end)
    return btn
end

-- ============================================================
-- MOBILE-FRIENDLY SLIDER (Using Touch Events)
-- ============================================================
local function createSlider(label, default, min, max, callback)
    local frame = Instance.new("Frame", contentScroll)
    frame.Size = UDim2.new(1, -4, 0, 50)
    frame.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = label .. ": " .. tostring(default)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextColor3 = GOLD
    
    local value = default
    
    local sliderBg = Instance.new("Frame", frame)
    sliderBg.Size = UDim2.new(1, 0, 0, 20)
    sliderBg.Position = UDim2.new(0, 0, 0, 24)
    sliderBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    sliderBg.BackgroundTransparency = 0.5
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 8)
    
    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = GOLD
    sliderFill.BackgroundTransparency = 0.3
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 8)
    
    local sliderHandle = Instance.new("TextButton", sliderBg)
    sliderHandle.Size = UDim2.new(0, 22, 0, 22)
    sliderHandle.Position = UDim2.new((default - min) / (max - min), -11, 0, -1)
    sliderHandle.BackgroundColor3 = GOLD
    sliderHandle.BackgroundTransparency = 0
    sliderHandle.Text = ""
    sliderHandle.ZIndex = 2
    Instance.new("UICorner", sliderHandle).CornerRadius = UDim.new(1, 0)
    local handleStroke = Instance.new("UIStroke", sliderHandle)
    handleStroke.Color = TEXT_WHITE
    handleStroke.Thickness = 2
    
    local dragging = false
    
    -- Mouse events (for PC testing)
    sliderHandle.MouseButton1Down:Connect(function()
        dragging = true
    end)
    sliderHandle.MouseButton1Up:Connect(function()
        dragging = false
    end)
    
    -- Touch events (for mobile)
    sliderHandle.TouchBegan:Connect(function()
        dragging = true
    end)
    sliderHandle.TouchEnded:Connect(function()
        dragging = false
    end)
    
    -- Handle both mouse and touch input
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local absPos = sliderBg.AbsolutePosition
            local absSize = sliderBg.AbsoluteSize
            if absSize.X > 0 then
                local rel = math.clamp((input.Position.X - absPos.X) / absSize.X, 0, 1)
                value = math.floor(min + rel * (max - min))
                value = math.clamp(value, min, max)
                
                sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                sliderHandle.Position = UDim2.new((value - min) / (max - min), -11, 0, -1)
                lbl.Text = label .. ": " .. tostring(value)
                if callback then callback(value) end
            end
        end
    end)
    
    -- Touch drag support
    local touchStart = nil
    sliderHandle.TouchBegan:Connect(function(touch)
        dragging = true
        touchStart = touch.Position
    end)
    
    UserInputService.TouchMoved:Connect(function(touch, processed)
        if not dragging or processed then return end
        local absPos = sliderBg.AbsolutePosition
        local absSize = sliderBg.AbsoluteSize
        if absSize.X > 0 then
            local rel = math.clamp((touch.Position.X - absPos.X) / absSize.X, 0, 1)
            value = math.floor(min + rel * (max - min))
            value = math.clamp(value, min, max)
            
            sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            sliderHandle.Position = UDim2.new((value - min) / (max - min), -11, 0, -1)
            lbl.Text = label .. ": " .. tostring(value)
            if callback then callback(value) end
        end
    end)
    
    return value
end

-- ============================================================
-- POPULATE UI
-- ============================================================

-- Silent Aim Section
createSection("SILENT AIM")

createToggle("Silent Aim", false, function(v)
    SilentAimEnabled = v
    if FOVCircle then
        FOVCircle.Visible = v and ShowFOVCircle
    end
end)

createToggle("Target Players", false, function(v)
    SilentAimPlayers = v
end)

createToggle("Target NPCs", false, function(v)
    SilentAimNPCs = v
end)

createToggle("Show FOV Circle", false, function(v)
    ShowFOVCircle = v
    if FOVCircle then
        FOVCircle.Visible = SilentAimEnabled and v
    end
end)

-- FOV SLIDER (Working)
createSlider("FOV Radius", 150, 30, 500, function(v)
    FOVRadius = v
    if FOVCircle then
        FOVCircle.Radius = v
    end
end)

createToggle("Headshot Only", false, function(v)
    HeadshotOnly = v
end)

createToggle("Wall Check", false, function(v)
    WallCheck = v
end)

createToggle("Prediction", false, function(v)
    Prediction = v
end)

createToggle("Lock On", false, function(v)
    LockOn = v
    if not v then lockedTarget = nil end
end)

createToggle("Team Check", false, function(v)
    TeamCheck = v
end)

createToggle("Ignore Safe Zone", true, function(v)
    IgnoreSafeZone = v
end)

createToggle("Ignore PvP OFF", true, function(v)
    IgnorePvPOff = v
end)

-- Max Range Slider
createSlider("Max Range", 2500, 100, 5000, function(v)
    MaxRange = v
end)

-- Target Part Selector
local partFrame = Instance.new("Frame", contentScroll)
partFrame.Size = UDim2.new(1, -4, 0, 34)
partFrame.BackgroundTransparency = 1

local partLabel = Instance.new("TextLabel", partFrame)
partLabel.Size = UDim2.new(0.5, 0, 1, 0)
partLabel.BackgroundTransparency = 1
partLabel.Text = "Target Part:"
partLabel.Font = Enum.Font.GothamBold
partLabel.TextSize = 11
partLabel.TextColor3 = TEXT_WHITE
partLabel.TextXAlignment = Enum.TextXAlignment.Left

local partBtn = Instance.new("TextButton", partFrame)
partBtn.Size = UDim2.new(0.45, 0, 1, 0)
partBtn.Position = UDim2.new(0.55, 0, 0, 0)
partBtn.BackgroundColor3 = BLACK
partBtn.BackgroundTransparency = 0.5
partBtn.Text = "HumanoidRootPart"
partBtn.Font = Enum.Font.GothamBold
partBtn.TextSize = 9
partBtn.TextColor3 = GOLD
Instance.new("UICorner", partBtn).CornerRadius = UDim.new(0, 6)
local pStroke = Instance.new("UIStroke", partBtn)
pStroke.Color = GOLD
pStroke.Thickness = 1

local partOptions = {"HumanoidRootPart", "Head", "UpperTorso", "LowerTorso"}
local partIndex = 1

partBtn.MouseButton1Click:Connect(function()
    partIndex = (partIndex % #partOptions) + 1
    SilentAimPart = partOptions[partIndex]
    partBtn.Text = partOptions[partIndex]
end)

-- Status
local statusLabel = Instance.new("TextLabel", contentScroll)
statusLabel.Size = UDim2.new(1, 0, 0, 28)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Ready"
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 11
statusLabel.TextColor3 = DARK_GOLD
statusLabel.TextXAlignment = Enum.TextXAlignment.Center

RunService.Heartbeat:Connect(function()
    if SilentAimEnabled and currentTarget then
        statusLabel.Text = "✅ Locked on target"
        statusLabel.TextColor3 = GOLD
    elseif SilentAimEnabled then
        statusLabel.Text = "⏳ No target in FOV"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    else
        statusLabel.Text = "⏸ Disabled"
        statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end)

-- ============================================================
-- SAVE/LOAD
-- ============================================================
local function SaveConfig()
    local data = {
        SilentAimEnabled = SilentAimEnabled,
        SilentAimPlayers = SilentAimPlayers,
        SilentAimNPCs = SilentAimNPCs,
        ShowFOVCircle = ShowFOVCircle,
        FOVRadius = FOVRadius,
        MaxRange = MaxRange,
        HeadshotOnly = HeadshotOnly,
        WallCheck = WallCheck,
        Prediction = Prediction,
        LockOn = LockOn,
        TeamCheck = TeamCheck,
        IgnoreSafeZone = IgnoreSafeZone,
        IgnorePvPOff = IgnorePvPOff,
        SilentAimPart = SilentAimPart
    }
    pcall(function()
        if writefile then
            writefile("RitualHub_Config.json", HttpService:JSONEncode(data))
        end
    end)
end

local function LoadConfig()
    pcall(function()
        if isfile and readfile and isfile("RitualHub_Config.json") then
            local str = readfile("RitualHub_Config.json")
            local data = HttpService:JSONDecode(str)
            if data then
                if data.SilentAimEnabled ~= nil then SilentAimEnabled = data.SilentAimEnabled end
                if data.SilentAimPlayers ~= nil then SilentAimPlayers = data.SilentAimPlayers end
                if data.SilentAimNPCs ~= nil then SilentAimNPCs = data.SilentAimNPCs end
                if data.ShowFOVCircle ~= nil then ShowFOVCircle = data.ShowFOVCircle end
                if data.FOVRadius ~= nil then FOVRadius = data.FOVRadius end
                if data.MaxRange ~= nil then MaxRange = data.MaxRange end
                if data.HeadshotOnly ~= nil then HeadshotOnly = data.HeadshotOnly end
                if data.WallCheck ~= nil then WallCheck = data.WallCheck end
                if data.Prediction ~= nil then Prediction = data.Prediction end
                if data.LockOn ~= nil then LockOn = data.LockOn end
                if data.TeamCheck ~= nil then TeamCheck = data.TeamCheck end
                if data.IgnoreSafeZone ~= nil then IgnoreSafeZone = data.IgnoreSafeZone end
                if data.IgnorePvPOff ~= nil then IgnorePvPOff = data.IgnorePvPOff end
                if data.SilentAimPart ~= nil then SilentAimPart = data.SilentAimPart end
            end
        end
    end)
end

-- Save/Load buttons
local btnFrame = Instance.new("Frame", contentScroll)
btnFrame.Size = UDim2.new(1, -4, 0, 36)
btnFrame.BackgroundTransparency = 1

local saveBtn = Instance.new("TextButton", btnFrame)
saveBtn.Size = UDim2.new(0.45, -4, 1, 0)
saveBtn.Position = UDim2.new(0, 0, 0, 0)
saveBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
saveBtn.BackgroundTransparency = 0.5
saveBtn.Text = "💾 Save Config"
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 10
saveBtn.TextColor3 = TEXT_WHITE
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 6)
local sStroke = Instance.new("UIStroke", saveBtn)
sStroke.Color = GOLD
sStroke.Thickness = 1

local loadBtn = Instance.new("TextButton", btnFrame)
loadBtn.Size = UDim2.new(0.45, -4, 1, 0)
loadBtn.Position = UDim2.new(0.55, 0, 0, 0)
loadBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
loadBtn.BackgroundTransparency = 0.5
loadBtn.Text = "📂 Load Config"
loadBtn.Font = Enum.Font.GothamBold
loadBtn.TextSize = 10
loadBtn.TextColor3 = TEXT_WHITE
Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 6)
local lStroke = Instance.new("UIStroke", loadBtn)
lStroke.Color = GOLD
lStroke.Thickness = 1

saveBtn.MouseButton1Click:Connect(function()
    SaveConfig()
    saveBtn.Text = "✅ Saved!"
    task.delay(1.5, function()
        saveBtn.Text = "💾 Save Config"
    end)
end)

loadBtn.MouseButton1Click:Connect(function()
    LoadConfig()
    loadBtn.Text = "✅ Loaded!"
    task.delay(1.5, function()
        loadBtn.Text = "📂 Load Config"
    end)
end)

-- ============================================================
-- AUTO SHOW UI ON LOAD
-- ============================================================
task.delay(0.5, function()
    LoadConfig()
    mainFrame.Visible = true
    isUIOpen = true
    crownButton.Visible = false
    
    if FOVCircle then
        FOVCircle.Visible = SilentAimEnabled and ShowFOVCircle
        FOVCircle.Radius = FOVRadius
    end
    
    partBtn.Text = SilentAimPart
end)

print("⚜️ RITUAL HUB V3.2 LOADED | MOBILE OPTIMIZED | BLACK & GOLD")
print("📢 Discord: ritualz999 | Discord: rayo06996")
print("🎯 Silent Aim with working FOV Circle (Touch optimized)")
print("👑 Crown button - click to toggle UI")
