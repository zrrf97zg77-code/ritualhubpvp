-- ============================================================
-- RITUAL HUB V12.5 | BLACK & GOLD | FOV AIMBOT
-- ============================================================
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)

-- Clear old UI
for _, v in pairs(playerGui:GetChildren()) do
    if v.Name:match("RitualHub") then v:Destroy() end
end

-- ============================================================
-- POPUP (Black & Gold, no PC warning)
-- ============================================================
local continueEvent = Instance.new("BindableEvent")
local launcherGui = Instance.new("ScreenGui")
launcherGui.Name = "RitualHubLauncher"
launcherGui.ResetOnSpawn = false
launcherGui.Parent = playerGui

local popFrame = Instance.new("Frame", launcherGui)
popFrame.Size = UDim2.new(0, 300, 0, 200)
popFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
popFrame.AnchorPoint = Vector2.new(0.5, 0.5)
popFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
popFrame.BackgroundTransparency = 0
popFrame.Active = true
popFrame.Draggable = true
Instance.new("UICorner", popFrame).CornerRadius = UDim.new(0,12)
local popStroke = Instance.new("UIStroke", popFrame)
popStroke.Color = Color3.fromRGB(255,215,0)
popStroke.Thickness = 2

local title = Instance.new("TextLabel", popFrame)
title.Size = UDim2.new(1,0,0,30)
title.Position = UDim2.new(0,0,0,12)
title.BackgroundTransparency = 1
title.Text = "✨ Ritual Hub 12.5"
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255,215,0)
title.TextXAlignment = Enum.TextXAlignment.Center

local content = Instance.new("TextLabel", popFrame)
content.Size = UDim2.new(1,-30,0,50)
content.Position = UDim2.new(0,15,0,50)
content.BackgroundTransparency = 1
content.Text = "FOV Aimbot • ESP • Movement • Glitches\nSoru Engine • Macro • Save/Load Config"
content.Font = Enum.Font.GothamBold
content.TextSize = 11
content.TextColor3 = Color3.fromRGB(200,200,200)
content.TextXAlignment = Enum.TextXAlignment.Center
content.TextYAlignment = Enum.TextYAlignment.Top
content.TextWrapped = true

local startBtn = Instance.new("TextButton", popFrame)
startBtn.Size = UDim2.new(0,120,0,32)
startBtn.Position = UDim2.new(0.5,-60,1,-48)
startBtn.BackgroundColor3 = Color3.fromRGB(255,215,0)
startBtn.Text = "Get Started"
startBtn.Font = Enum.Font.GothamBlack
startBtn.TextSize = 12
startBtn.TextColor3 = Color3.fromRGB(0,0,0)
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,8)

startBtn.MouseButton1Click:Connect(function()
    launcherGui:Destroy()
    continueEvent:Fire()
end)

continueEvent.Event:Wait()
continueEvent:Destroy()

-- ============================================================
-- MAIN SCRIPT
-- ============================================================
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

-- ============================================================
-- CONFIG PERSISTENCE
-- ============================================================
local configFileName = "RitualHub_Config.json"
local bountyFileName = "RitualHub_Bounty.json"
local macroFileName = "RitualHub_Macro.json"

function SaveConfig(data)
    pcall(function()
        if writefile then
            writefile(configFileName, HttpService:JSONEncode(data))
        end
    end)
end

function LoadConfig()
    local data = {}
    pcall(function()
        if isfile and isfile(configFileName) then
            data = HttpService:JSONDecode(readfile(configFileName))
        end
    end)
    return data or {}
end

-- ============================================================
-- STATE VARIABLES (defaults)
-- ============================================================
local state = {
    -- ESP
    ESPEnabled = false,
    ESPName = true,
    ESPLevel = true,
    ESPBounty = true,
    ESPFruit = true,
    ESPDist = true,
    ESPHP = true,
    ESPHighlight = false,
    ESPTextSize = 12,
    
    -- Combat
    FastAttack = false,
    WalkSpeed = false,
    WalkSpeedVal = 16,
    Dash = false,
    DashDist = 1,
    Noclip = false,
    WalkOnWater = false,
    
    -- Glitches
    SuperJump = false,
    SuperJumpPower = 500,
    NoAnim = false,
    AntiLava = false,
    FFlags = false,
    Macro = false,
    MacroMode = "Soru",
    MacroSlot1 = 1, MacroKey1 = "Z", MacroDelay1 = 0.3,
    MacroSlot2 = 2, MacroKey2 = "X", MacroDelay2 = 0.3,
    MacroSlot3 = 3, MacroKey3 = "C", MacroDelay3 = 0.3,
    MacroSlot4 = 4, MacroKey4 = "V", MacroDelay4 = 0.3,
    MacroSlot5 = 1, MacroKey5 = "OFF", MacroDelay5 = 0.3,
    MacroSlot6 = 1, MacroKey6 = "OFF", MacroDelay6 = 0.3,
    
    -- Soru
    InfSoru = false,
    SoruAimbot = false,
    PortalSoru = false,
    PortalSanguineC = false,
    PortalSanguineCTrigger = "PortalF",
    
    -- Aimbot
    SkillAimbot = false,
    ShowFOV = false,
    FOVRadius = 150,
    ShowLine = false,
    TargetPlayers = false,
    TargetMobs = false,
    TeamCheck = false,
    IgnoreSafe = true,
    IgnorePvPOff = true,
    RainbowBody = false,
    AimbotMaxDist = 2500,
    SelectedTarget = "",
    
    -- Misc
    FPSOverlay = false,
    Language = "EN",
}

-- Load saved config
local saved = LoadConfig()
for k,v in pairs(saved) do
    if state[k] ~= nil then state[k] = v end
end

-- Save function wrapper
function SaveAll()
    SaveConfig(state)
end

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================
local function isEnemy(p)
    if p == player then return false end
    if state.TeamCheck then
        if player.Team and p.Team and player.Team.Name == p.Team.Name then
            return false
        end
    end
    return true
end

local function isPvPOn(p)
    if state.IgnorePvPOff then
        local attr = p:GetAttribute("PvpDisabled")
        if attr == true then return false end
        -- Check GUI PvP button
        local main = p.PlayerGui:FindFirstChild("Main")
        if main then
            local dis = main:FindFirstChild("PvpDisabled")
            if dis and dis.Visible then return false end
        end
    end
    return true
end

local function inSafeZone(char)
    if not state.IgnoreSafe then return false end
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local wo = workspace:FindFirstChild("_WorldOrigin")
    if not wo then return false end
    for _, zone in pairs(wo:FindFirstChild("SafeZones") or {}) do
        local mesh = zone:FindFirstChild("Mesh")
        if mesh and mesh:IsA("SpecialMesh") then
            local radius = zone.Size.X * mesh.Scale.X / 2
            if (hrp.Position - zone.Position).Magnitude <= radius then return true end
        end
    end
    return false
end

local function getTargets()
    local targets = {}
    local myChar = player.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return targets end
    local myPos = myHRP.Position
    
    if state.TargetPlayers then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and hrp and isEnemy(p) and isPvPOn(p) and not inSafeZone(p.Character) then
                    local dist = (hrp.Position - myPos).Magnitude
                    if dist <= state.AimbotMaxDist then
                        table.insert(targets, {char = p.Character, part = hrp, dist = dist, player = p})
                    end
                end
            end
        end
    end
    if state.TargetMobs then
        local enemies = workspace:FindFirstChild("Enemies")
        if enemies then
            for _, npc in pairs(enemies:GetChildren()) do
                local hum = npc:FindFirstChildOfClass("Humanoid")
                local hrp = npc:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and hrp then
                    local dist = (hrp.Position - myPos).Magnitude
                    if dist <= state.AimbotMaxDist then
                        table.insert(targets, {char = npc, part = hrp, dist = dist, player = nil})
                    end
                end
            end
        end
    end
    return targets
end

-- ============================================================
-- FOV & TARGET LINE (using Drawing)
-- ============================================================
local FOVCircle = nil
local TargetLine = nil
pcall(function()
    if Drawing and Drawing.new then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Visible = false
        FOVCircle.Color = Color3.fromRGB(255,215,0)
        FOVCircle.Thickness = 2
        FOVCircle.Filled = false
        FOVCircle.Radius = state.FOVRadius

        TargetLine = Drawing.new("Line")
        TargetLine.Visible = false
        TargetLine.Color = Color3.fromRGB(255,215,0)
        TargetLine.Thickness = 1.5
        TargetLine.Transparency = 0.7
    end
end)

local currentTargetPart = nil

-- Convert world to screen and check FOV
local function getTargetInFOV()
    local cam = workspace.CurrentCamera
    local screenCenter = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    local targets = getTargets()
    local bestPart = nil
    local bestDist = math.huge
    for _, t in ipairs(targets) do
        local part = t.part
        if part then
            local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
            if onScreen then
                local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                local dist = (screenVec - screenCenter).Magnitude
                if dist <= state.FOVRadius and dist < bestDist then
                    bestDist = dist
                    bestPart = part
                end
            end
        end
    end
    return bestPart
end

-- Update line and circle
RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local screenCenter = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    
    -- FOV Circle
    if FOVCircle then
        FOVCircle.Visible = state.ShowFOV and state.SkillAimbot
        FOVCircle.Radius = state.FOVRadius
        FOVCircle.Position = screenCenter
    end
    
    -- Update target
    if state.SkillAimbot then
        currentTargetPart = getTargetInFOV()
    else
        currentTargetPart = nil
    end
    
    -- Target Line
    if TargetLine then
        if currentTargetPart and state.ShowLine then
            local screenPos, onScreen = cam:WorldToViewportPoint(currentTargetPart.Position)
            if onScreen then
                TargetLine.From = screenCenter
                TargetLine.To = Vector2.new(screenPos.X, screenPos.Y)
                TargetLine.Visible = true
            else
                TargetLine.Visible = false
            end
        else
            TargetLine.Visible = false
        end
    end
end)

-- ============================================================
-- METAMETHODS HOOKS (Silent Aim)
-- ============================================================
local oldIndex, oldNamecall
if hookmetamethod then
    pcall(function()
        oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
            if not checkcaller() and self == mouse and (key == "Hit" or key == "Target") then
                if state.SkillAimbot and currentTargetPart then
                    if key == "Hit" then return CFrame.new(currentTargetPart.Position) end
                    if key == "Target" then return currentTargetPart end
                end
                if state.SoruAimbot then
                    -- Soru Aimbot (teleport to target) – kept simple
                    local targetName = SelectedSoruTarget or "Nearest"
                    local targetChar
                    if targetName == "Nearest" then
                        targetChar = getTargets()[1] and getTargets()[1].char
                    else
                        local p = Players:FindFirstChild(targetName)
                        if p then targetChar = p.Character end
                    end
                    if targetChar then
                        local hrp = targetChar:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            if key == "Hit" then return CFrame.new(hrp.Position) end
                            if key == "Target" then return hrp end
                        end
                    end
                end
            end
            return oldIndex(self, key)
        end))
    end)
    pcall(function()
        oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
                if state.SkillAimbot and currentTargetPart then
                    -- Override position arguments
                    for i,arg in ipairs(args) do
                        if typeof(arg) == "Vector3" then
                            args[i] = currentTargetPart.Position
                        elseif typeof(arg) == "CFrame" then
                            args[i] = CFrame.new(currentTargetPart.Position)
                        end
                    end
                    -- Special handling for RegisterHit
                    if self.Name:find("RegisterHit") then
                        local parent = currentTargetPart.Parent
                        if parent then
                            local head = parent:FindFirstChild("Head") or currentTargetPart
                            args[1] = head
                            args[2] = { {parent, head} }
                        end
                    end
                    if self.Name:find("ShootGunEvent") then
                        args[1] = currentTargetPart.Position
                        if currentTargetPart.Parent then
                            args[2] = {currentTargetPart.Parent}
                        end
                    end
                    return oldNamecall(self, unpack(args))
                end
            end
            return oldNamecall(self, ...)
        end))
    end)
else
    -- Fallback for executors without hookmetamethod
    pcall(function()
        local mt = getrawmetatable(game)
        if mt then
            oldIndex = mt.__index
            oldNamecall = mt.__namecall
            setreadonly(mt, false)
            mt.__index = newcclosure(function(self, key)
                if not checkcaller() and self == mouse and (key == "Hit" or key == "Target") then
                    if state.SkillAimbot and currentTargetPart then
                        if key == "Hit" then return CFrame.new(currentTargetPart.Position) end
                        if key == "Target" then return currentTargetPart end
                    end
                end
                return oldIndex(self, key)
            end)
            mt.__namecall = newcclosure(function(self, ...)
                local args = {...}
                local method = getnamecallmethod()
                if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
                    if state.SkillAimbot and currentTargetPart then
                        for i,arg in ipairs(args) do
                            if typeof(arg) == "Vector3" then args[i] = currentTargetPart.Position end
                            if typeof(arg) == "CFrame" then args[i] = CFrame.new(currentTargetPart.Position) end
                        end
                        if self.Name:find("RegisterHit") then
                            local parent = currentTargetPart.Parent
                            if parent then
                                local head = parent:FindFirstChild("Head") or currentTargetPart
                                args[1] = head
                                args[2] = { {parent, head} }
                            end
                        end
                        return oldNamecall(self, unpack(args))
                    end
                end
                return oldNamecall(self, ...)
            end)
            setreadonly(mt, true)
        end
    end)
end

-- ============================================================
-- ESP SYSTEM (Gold Highlight)
-- ============================================================
local espObjects = {}
local espRunning = false

function updateESP()
    if not state.ESPEnabled then
        for _, obj in pairs(espObjects) do
            pcall(function() obj.gui:Destroy() end)
            pcall(function() obj.highlight:Destroy() end)
        end
        espObjects = {}
        return
    end
    local myChar = player.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local char = p.Character
            local head = char:FindFirstChild("Head")
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if head and root and hum and hum.Health > 0 then
                local obj = espObjects[p]
                if not obj then
                    local gui = Instance.new("BillboardGui")
                    gui.Adornee = head
                    gui.Size = UDim2.new(0,200,0,70)
                    gui.StudsOffset = Vector3.new(0,3,0)
                    gui.AlwaysOnTop = true
                    gui.Parent = head
                    local label = Instance.new("TextLabel", gui)
                    label.Size = UDim2.new(1,0,1,0)
                    label.BackgroundTransparency = 1
                    label.TextScaled = false
                    label.TextSize = state.ESPTextSize
                    label.Font = Enum.Font.SourceSansBold
                    label.RichText = true
                    label.TextStrokeTransparency = 0
                    label.TextColor3 = Color3.fromRGB(255,255,255)
                    
                    local hl
                    if state.ESPHighlight then
                        hl = Instance.new("Highlight")
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.FillColor = Color3.fromRGB(255,215,0)
                        hl.FillTransparency = 0.5
                        hl.OutlineColor = Color3.fromRGB(255,215,0)
                        hl.OutlineTransparency = 0
                        hl.Parent = char
                    end
                    espObjects[p] = {gui = gui, label = label, highlight = hl}
                    obj = espObjects[p]
                end
                -- Update text
                local dist = math.floor((root.Position - myRoot.Position).Magnitude)
                local parts = {}
                if state.ESPName then
                    local team = p.Team and p.Team.Name or "Unknown"
                    parts[#parts+1] = "["..team.."] <font color='rgb(255,255,0)'>"..p.Name.."</font>"
                end
                if state.ESPLevel then
                    local level = p.Data and p.Data.Level and p.Data.Level.Value or "?"
                    parts[#parts+1] = " [Lv."..level.."]"
                end
                if state.ESPBounty then
                    local bounty = 0
                    pcall(function() bounty = p.leaderstats["Bounty/Honor"].Value end)
                    local bM = math.floor(bounty/1000000)
                    parts[#parts+1] = "\nBounty: "..bM.."M"
                end
                if state.ESPFruit then
                    local fruit = "None"
                    pcall(function() fruit = p.Data.DevilFruit.Value end)
                    parts[#parts+1] = " | Fruit: "..tostring(fruit)
                end
                if state.ESPDist then
                    parts[#parts+1] = " | "..dist.."m"
                end
                if state.ESPHP then
                    local hp = math.floor((hum.Health/hum.MaxHealth)*100)
                    parts[#parts+1] = " | HP "..hp.."%"
                end
                obj.label.Text = table.concat(parts)
                obj.label.TextSize = state.ESPTextSize
                if obj.highlight then
                    obj.highlight.Visible = state.ESPHighlight
                end
            else
                local obj = espObjects[p]
                if obj then
                    pcall(function() obj.gui:Destroy() end)
                    pcall(function() obj.highlight:Destroy() end)
                    espObjects[p] = nil
                end
            end
        end
    end
end

-- ESP loop
task.spawn(function()
    while true do
        task.wait(0.2)
        pcall(updateESP)
    end
end)

-- ============================================================
-- FAST ATTACK
-- ============================================================
local RegisterHit, RegisterAttack
task.spawn(function()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            if v.Name == "RE/RegisterHit" then RegisterHit = v end
            if v.Name == "RE/RegisterAttack" then RegisterAttack = v end
        end
    end
end)

local fastAttackRunning = false
function startFastAttack()
    if fastAttackRunning then return end
    fastAttackRunning = true
    task.spawn(function()
        while state.FastAttack do
            RunService.Stepped:Wait()
            local myChar = player.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myHRP then
                local targets = {}
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and not inSafeZone(p.Character) then
                        local hum = p.Character:FindFirstChildOfClass("Humanoid")
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if hum and hrp and hum.Health > 0 and (hrp.Position - myHRP.Position).Magnitude <= 2500 then
                            table.insert(targets, p.Character)
                        end
                    end
                end
                local enemies = workspace:FindFirstChild("Enemies")
                if enemies then
                    for _, npc in pairs(enemies:GetChildren()) do
                        local hum = npc:FindFirstChildOfClass("Humanoid")
                        local hrp = npc:FindFirstChild("HumanoidRootPart")
                        if hum and hrp and hum.Health > 0 and (hrp.Position - myHRP.Position).Magnitude <= 2500 then
                            table.insert(targets, npc)
                        end
                    end
                end
                if #targets > 0 and RegisterHit and RegisterAttack then
                    local heads = {}
                    for _, char in pairs(targets) do
                        local head = char:FindFirstChild("Head")
                        if head then table.insert(heads, {char, head}) end
                    end
                    if #heads > 0 then
                        RegisterAttack:FireServer(0)
                        RegisterHit:FireServer(heads[1][2], heads)
                    end
                end
            end
        end
        fastAttackRunning = false
    end)
end

-- ============================================================
-- WALK SPEED, DASH, NOCLIP, WALK ON WATER
-- ============================================================
task.spawn(function()
    while true do
        task.wait(0.15)
        if state.WalkSpeed then
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = state.WalkSpeedVal end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if state.Dash then
            local char = player.Character
            if char then
                if char:GetAttribute("DashLength") ~= state.DashDist then
                    char:SetAttribute("DashLength", state.DashDist)
                    char:SetAttribute("DashLengthAir", state.DashDist)
                end
            end
        end
    end
end)

local noclipConn
function setNoclip(v)
    state.Noclip = v
    if v then
        noclipConn = RunService.Stepped:Connect(function()
            if player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end

task.spawn(function()
    local water = nil
    while true do
        task.wait(0.15)
        if state.WalkOnWater then
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and hrp.Position.Y >= 9.5 then
                if not water then
                    water = Instance.new("Part")
                    water.Size = Vector3.new(200,1,200)
                    water.Transparency = 1
                    water.Anchored = true
                    water.CanCollide = false
                    water.Name = "RitualWater"
                    water.Parent = workspace
                end
                water.Position = Vector3.new(hrp.Position.X, 9.2, hrp.Position.Z)
                water.CanCollide = true
            else
                if water then water.CanCollide = false end
            end
        else
            if water then water:Destroy(); water = nil end
        end
    end
end)

-- ============================================================
-- SUPER JUMP
-- ============================================================
function doSuperJump()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hrp and hum then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, state.SuperJumpPower, hrp.AssemblyLinearVelocity.Z)
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

-- ============================================================
-- NO ANIMATIONS
-- ============================================================
local noAnimConn
function setNoAnim(v)
    state.NoAnim = v
    if v then
        noAnimConn = RunService.Stepped:Connect(function()
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    local animator = hum:FindFirstChild("Animator")
                    if animator then
                        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                            if not track.Name:lower():match("attack") then
                                track:Stop(0)
                            end
                        end
                    end
                end
            end
        end)
    else
        if noAnimConn then noAnimConn:Disconnect(); noAnimConn = nil end
    end
end

-- ============================================================
-- ANTI LAVA
-- ============================================================
local antiLavaConn
function setAntiLava(v)
    state.AntiLava = v
    if v then
        antiLavaConn = RunService.Stepped:Connect(function()
            local char = player.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanTouch = false
                    end
                end
            end
        end)
    else
        if antiLavaConn then antiLavaConn:Disconnect(); antiLavaConn = nil end
    end
end

-- ============================================================
-- FFLAGS1 (external load)
-- ============================================================
local fflagsThread
function toggleFFlags(v)
    state.FFlags = v
    if v then
        fflagsThread = task.spawn(function()
            local url = string.char(104,116,116,112,115,58,47,47,112,97,115,116,101,98,105,110,46,99,111,109,47,114,97,119,47,78,77,122,55,82,120,113,68)
            loadstring(game:HttpGet(url))()
        end)
    else
        if fflagsThread then task.cancel(fflagsThread); fflagsThread = nil end
    end
end

-- ============================================================
-- INFINITE SORU
-- ============================================================
function setInfSoru(v)
    state.InfSoru = v
    if v and player.Character then
        player.Character:SetAttribute("FlashstepCooldown", 1)
    end
end

player.CharacterAdded:Connect(function(char)
    if state.InfSoru then
        char:SetAttribute("FlashstepCooldown", 1)
    end
end)

-- ============================================================
-- PORTAL COMBOS (simplified)
-- ============================================================
function equipTool(namePattern)
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local tool = char:FindFirstChild(namePattern) or player.Backpack:FindFirstChild(namePattern)
    if not tool then
        for _, t in pairs(player.Backpack:GetChildren()) do
            if t.Name:lower():find(string.lower(namePattern)) then
                tool = t; break
            end
        end
    end
    if tool and tool.Parent ~= char then
        hum:EquipTool(tool)
        task.wait(0.1)
    end
    return tool
end

function doPortalCombo()
    equipTool("Portal")
    task.wait(0.08)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.X, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.X, false, game)
    task.wait(0.15)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Z, false, game)
end

function doPortalSanguineC()
    task.wait(0.25)
    equipTool("Sanguine")
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.C, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, game)
end

-- Detect flashstep and trigger
local function onAnimationPlayed(track)
    if not player.Character then return end
    local isFlash = track.Name:lower():find("flash") or track.Name:lower():find("soru")
    if isFlash then
        if state.PortalSoru then
            task.spawn(doPortalCombo)
        end
        if state.PortalSanguineC then
            if state.PortalSanguineCTrigger == "Soru" then
                task.spawn(doPortalSanguineC)
            end
        end
    end
    -- Also detect Portal F animation
    if track.Name:lower():find("portal") or track.Name:lower():find("teleport") then
        if state.PortalSanguineC and state.PortalSanguineCTrigger == "PortalF" then
            task.spawn(doPortalSanguineC)
        end
    end
end

player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        hum.AnimationPlayed:Connect(onAnimationPlayed)
    end
end)
if player.Character then
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.AnimationPlayed:Connect(onAnimationPlayed) end
end

-- ============================================================
-- MACRO BETA (simplified)
-- ============================================================
local macroRunning = false
local macroComboSlots = {
    {slot = 1, key = "Z", delay = 0.3},
    {slot = 2, key = "X", delay = 0.3},
    {slot = 3, key = "C", delay = 0.3},
    {slot = 4, key = "V", delay = 0.3},
    {slot = 1, key = "OFF", delay = 0.3},
    {slot = 1, key = "OFF", delay = 0.3},
}
-- Override from state
macroComboSlots[1] = {slot = state.MacroSlot1, key = state.MacroKey1, delay = state.MacroDelay1}
macroComboSlots[2] = {slot = state.MacroSlot2, key = state.MacroKey2, delay = state.MacroDelay2}
macroComboSlots[3] = {slot = state.MacroSlot3, key = state.MacroKey3, delay = state.MacroDelay3}
macroComboSlots[4] = {slot = state.MacroSlot4, key = state.MacroKey4, delay = state.MacroDelay4}
macroComboSlots[5] = {slot = state.MacroSlot5, key = state.MacroKey5, delay = state.MacroDelay5}
macroComboSlots[6] = {slot = state.MacroSlot6, key = state.MacroKey6, delay = state.MacroDelay6}

function executeMacro()
    if not state.Macro or macroRunning then return end
    macroRunning = true
    local function pressKey(k)
        if k == "OFF" then return end
        local key = Enum.KeyCode[k]
        if key then
            VirtualInputManager:SendKeyEvent(true, key, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, key, false, game)
        end
    end
    local function equipSlot(slotNum)
        local key = Enum.KeyCode["One"..slotNum] or Enum.KeyCode["Key"..slotNum]
        if key then
            VirtualInputManager:SendKeyEvent(true, key, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, key, false, game)
            task.wait(0.1)
        end
    end
    local prevSlot = nil
    for _, item in ipairs(macroComboSlots) do
        if item.key ~= "OFF" then
            if item.slot ~= prevSlot then equipSlot(item.slot) end
            pressKey(item.key)
            prevSlot = item.slot
            task.wait(item.delay or 0.3)
        end
    end
    macroRunning = false
end

-- Trigger macro on flashstep if in Soru mode
local function onMacroTrigger(track)
    if state.Macro and state.MacroMode == "Soru" then
        if track.Name:lower():find("flash") or track.Name:lower():find("soru") then
            task.spawn(executeMacro)
        end
    end
end

-- Hook into animation for macro
local originalOnAnim = onAnimationPlayed
onAnimationPlayed = function(track)
    originalOnAnim(track)
    onMacroTrigger(track)
end

-- ============================================================
-- UI SYSTEM (Black & Gold)
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RitualHubUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 310)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -155)
mainFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
mainFrame.BackgroundTransparency = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0,16)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(255,215,0)
mainStroke.Thickness = 2

-- Title
local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(0,200,0,24)
titleLabel.Position = UDim2.new(0.5,-100,0,8)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "RITUAL HUB"
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 16
titleLabel.TextColor3 = Color3.fromRGB(255,215,0)
titleLabel.TextXAlignment = Enum.TextXAlignment.Center

local subTitle = Instance.new("TextLabel", mainFrame)
subTitle.Size = UDim2.new(0,150,0,14)
subTitle.Position = UDim2.new(0.5,-75,0,32)
subTitle.BackgroundTransparency = 1
subTitle.Text = "by: ritualz999"
subTitle.Font = Enum.Font.GothamBold
subTitle.TextSize = 9
subTitle.TextColor3 = Color3.fromRGB(255,215,0)
subTitle.TextXAlignment = Enum.TextXAlignment.Center

-- Close button
local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0,24,0,24)
closeBtn.Position = UDim2.new(1,-32,0,4)
closeBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
closeBtn.BackgroundTransparency = 0
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.TextSize = 14
closeBtn.TextColor3 = Color3.fromRGB(255,80,80)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)
local closeStroke = Instance.new("UIStroke", closeBtn)
closeStroke.Color = Color3.fromRGB(255,215,0)
closeStroke.Thickness = 1
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    -- Clean up ESP objects
    for _, obj in pairs(espObjects) do
        pcall(function() obj.gui:Destroy() end)
        pcall(function() obj.highlight:Destroy() end)
    end
    espObjects = {}
end)

-- Sidebar tabs
local tabs = {"Stats", "Combat", "Glitches", "ESP", "Soru", "Misc"}
local tabBtns = {}
local pages = {}

local sidebar = Instance.new("Frame", mainFrame)
sidebar.Size = UDim2.new(0,90,1,-50)
sidebar.Position = UDim2.new(0,10,0,50)
sidebar.BackgroundColor3 = Color3.fromRGB(0,0,0)
sidebar.BackgroundTransparency = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0,8)
local sideStroke = Instance.new("UIStroke", sidebar)
sideStroke.Color = Color3.fromRGB(255,215,0)
sideStroke.Thickness = 1

local pageContainer = Instance.new("Frame", mainFrame)
pageContainer.Size = UDim2.new(1,-110,1,-55)
pageContainer.Position = UDim2.new(0,100,0,45)
pageContainer.BackgroundTransparency = 1

-- Create pages
for i, name in ipairs(tabs) do
    local page = Instance.new("ScrollingFrame", pageContainer)
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.Visible = (i == 1)
    page.CanvasSize = UDim2.new(0,0,0,0)
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0,6)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 20)
    end)
    pages[name] = page
end

-- Tab buttons
for i, name in ipairs(tabs) do
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1,-4,0,24)
    btn.Position = UDim2.new(0,2,0,8 + (i-1)*28)
    btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
    btn.BackgroundTransparency = 0
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.TextColor3 = (i==1) and Color3.fromRGB(255,215,0) or Color3.fromRGB(200,200,200)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)
    local bStroke = Instance.new("UIStroke", btn)
    bStroke.Color = Color3.fromRGB(255,215,0)
    bStroke.Thickness = (i==1) and 1.5 or 0.5
    tabBtns[name] = btn
    btn.MouseButton1Click:Connect(function()
        for _, b in pairs(tabBtns) do
            b.TextColor3 = Color3.fromRGB(200,200,200)
            b.Stroke.Thickness = 0.5
        end
        btn.TextColor3 = Color3.fromRGB(255,215,0)
        btn.Stroke.Thickness = 1.5
        for _, p in pairs(pages) do p.Visible = false end
        pages[name].Visible = true
    end)
end

-- ============================================================
-- UI HELPERS
-- ============================================================
function createCard(parent, title, height)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1,-8,0,height)
    card.BackgroundColor3 = Color3.fromRGB(0,0,0)
    card.BackgroundTransparency = 0
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0,10)
    local cStroke = Instance.new("UIStroke", card)
    cStroke.Color = Color3.fromRGB(255,215,0)
    cStroke.Thickness = 1
    cStroke.Transparency = 0.3
    local label = Instance.new("TextLabel", card)
    label.Size = UDim2.new(1,0,0,20)
    label.Position = UDim2.new(0,0,0,4)
    label.BackgroundTransparency = 1
    label.Text = title
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 10
    label.TextColor3 = Color3.fromRGB(255,215,0)
    label.TextXAlignment = Enum.TextXAlignment.Center
    return card, label
end

function addToggle(card, labelText, stateKey, yPos)
    local frame = Instance.new("Frame", card)
    frame.Size = UDim2.new(1,-12,0,20)
    frame.Position = UDim2.new(0,6,0,yPos)
    frame.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.65,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 8.5
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0,36,0,16)
    btn.Position = UDim2.new(1,-38,0.5,-8)
    btn.BackgroundColor3 = state[stateKey] and Color3.fromRGB(255,215,0) or Color3.fromRGB(30,30,35)
    btn.BackgroundTransparency = state[stateKey] and 0.2 or 0.5
    btn.Text = state[stateKey] and "ON" or "OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 7.5
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)
    local bStroke = Instance.new("UIStroke", btn)
    bStroke.Color = Color3.fromRGB(255,215,0)
    bStroke.Thickness = 1
    
    btn.MouseButton1Click:Connect(function()
        state[stateKey] = not state[stateKey]
        btn.BackgroundColor3 = state[stateKey] and Color3.fromRGB(255,215,0) or Color3.fromRGB(30,30,35)
        btn.BackgroundTransparency = state[stateKey] and 0.2 or 0.5
        btn.Text = state[stateKey] and "ON" or "OFF"
        -- Special actions
        if stateKey == "FastAttack" then
            if state.FastAttack then startFastAttack() end
        elseif stateKey == "Noclip" then
            setNoclip(state.Noclip)
        elseif stateKey == "NoAnim" then
            setNoAnim(state.NoAnim)
        elseif stateKey == "AntiLava" then
            setAntiLava(state.AntiLava)
        elseif stateKey == "FFlags" then
            toggleFFlags(state.FFlags)
        elseif stateKey == "InfSoru" then
            setInfSoru(state.InfSoru)
        elseif stateKey == "SkillAimbot" then
            -- toggle FOV visuals
            if FOVCircle then FOVCircle.Visible = state.ShowFOV and state.SkillAimbot end
            if TargetLine then TargetLine.Visible = state.ShowLine and state.SkillAimbot end
        end
        SaveAll()
    end)
    return btn
end

function addStepper(card, labelText, stateKey, min, max, step, yPos, suffix)
    suffix = suffix or ""
    local frame = Instance.new("Frame", card)
    frame.Size = UDim2.new(1,-12,0,22)
    frame.Position = UDim2.new(0,6,0,yPos)
    frame.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.6,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 8.5
    lbl.TextColor3 = Color3.fromRGB(200,200,200)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local valLabel = Instance.new("TextLabel", frame)
    valLabel.Size = UDim2.new(0,45,0,18)
    valLabel.Position = UDim2.new(1,-90,0.5,-9)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(state[stateKey])..suffix
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 8.5
    valLabel.TextColor3 = Color3.fromRGB(255,255,255)
    valLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    local minus = Instance.new("TextButton", frame)
    minus.Size = UDim2.new(0,18,0,18)
    minus.Position = UDim2.new(1,-45,0.5,-9)
    minus.BackgroundColor3 = Color3.fromRGB(0,0,0)
    minus.BackgroundTransparency = 0
    minus.Text = "-"
    minus.Font = Enum.Font.GothamBold
    minus.TextSize = 11
    minus.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", minus).CornerRadius = UDim.new(0,4)
    local mStroke = Instance.new("UIStroke", minus)
    mStroke.Color = Color3.fromRGB(255,215,0)
    mStroke.Thickness = 1
    
    local plus = Instance.new("TextButton", frame)
    plus.Size = UDim2.new(0,18,0,18)
    plus.Position = UDim2.new(1,-22,0.5,-9)
    plus.BackgroundColor3 = Color3.fromRGB(0,0,0)
    plus.BackgroundTransparency = 0
    plus.Text = "+"
    plus.Font = Enum.Font.GothamBold
    plus.TextSize = 11
    plus.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", plus).CornerRadius = UDim.new(0,4)
    local pStroke = Instance.new("UIStroke", plus)
    pStroke.Color = Color3.fromRGB(255,215,0)
    pStroke.Thickness = 1
    
    local function update(v)
        local raw = math.floor((v / step) + 0.5) * step
        raw = math.max(min, math.min(max, raw))
        state[stateKey] = raw
        valLabel.Text = tostring(raw)..suffix
        SaveAll()
        -- Special updates for FOV
        if stateKey == "FOVRadius" and FOVCircle then
            FOVCircle.Radius = raw
        end
    end
    
    minus.MouseButton1Click:Connect(function()
        update(state[stateKey] - step)
    end)
    plus.MouseButton1Click:Connect(function()
        update(state[stateKey] + step)
    end)
    return valLabel
end

-- ============================================================
-- BUILD UI PAGES
-- ============================================================

-- STATS PAGE
local statsCard, _ = createCard(pages["Stats"], "Player Profile", 170)
local nameLabel = Instance.new("TextLabel", statsCard)
nameLabel.Size = UDim2.new(1,0,0,18)
nameLabel.Position = UDim2.new(0,0,0,30)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = player.Name
nameLabel.Font = Enum.Font.GothamBlack
nameLabel.TextSize = 14
nameLabel.TextColor3 = Color3.fromRGB(255,215,0)
nameLabel.TextXAlignment = Enum.TextXAlignment.Center

local levelLabel = Instance.new("TextLabel", statsCard)
levelLabel.Size = UDim2.new(1,0,0,16)
levelLabel.Position = UDim2.new(0,0,0,52)
levelLabel.BackgroundTransparency = 1
levelLabel.Text = "Level: Loading..."
levelLabel.Font = Enum.Font.GothamBold
levelLabel.TextSize = 10
levelLabel.TextColor3 = Color3.fromRGB(200,200,200)
levelLabel.TextXAlignment = Enum.TextXAlignment.Center

local bountyLabel = Instance.new("TextLabel", statsCard)
bountyLabel.Size = UDim2.new(1,0,0,16)
bountyLabel.Position = UDim2.new(0,0,0,70)
bountyLabel.BackgroundTransparency = 1
bountyLabel.Text = "Bounty: Loading..."
bountyLabel.Font = Enum.Font.GothamBold
bountyLabel.TextSize = 10
bountyLabel.TextColor3 = Color3.fromRGB(200,200,200)
bountyLabel.TextXAlignment = Enum.TextXAlignment.Center

local timeLabel = Instance.new("TextLabel", statsCard)
timeLabel.Size = UDim2.new(1,0,0,16)
timeLabel.Position = UDim2.new(0,0,0,100)
timeLabel.BackgroundTransparency = 1
timeLabel.Text = "Time: 00:00:00"
timeLabel.Font = Enum.Font.GothamBold
timeLabel.TextSize = 10
timeLabel.TextColor3 = Color3.fromRGB(200,200,200)
timeLabel.TextXAlignment = Enum.TextXAlignment.Center

local execLabel = Instance.new("TextLabel", statsCard)
execLabel.Size = UDim2.new(1,0,0,16)
execLabel.Position = UDim2.new(0,0,0,118)
execLabel.BackgroundTransparency = 1
execLabel.Text = "Executions: 0"
execLabel.Font = Enum.Font.GothamBold
execLabel.TextSize = 10
execLabel.TextColor3 = Color3.fromRGB(200,200,200)
execLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Update stats loop
scriptStartTime = os.time()
totalExecutions = 0
task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            local lv = "?"
            local bn = "0"
            if player.Data and player.Data.Level then lv = tostring(player.Data.Level.Value) end
            if player.leaderstats and player.leaderstats["Bounty/Honor"] then
                bn = tostring(player.leaderstats["Bounty/Honor"].Value)
            end
            levelLabel.Text = "Level: "..lv
            bountyLabel.Text = "Bounty: "..bn
            
            local elapsed = os.time() - scriptStartTime
            local h = math.floor(elapsed/3600)
            local m = math.floor((elapsed%3600)/60)
            local s = elapsed%60
            timeLabel.Text = string.format("Time: %02d:%02d:%02d", h,m,s)
            execLabel.Text = "Executions: "..tostring(totalExecutions)
        end)
    end
end)

-- COMBAT PAGE
local cCard, _ = createCard(pages["Combat"], "Aimbot Modules", 300)
local yOff = 24
addToggle(cCard, "Aimbot Skills", "SkillAimbot", yOff); yOff = yOff + 24
addToggle(cCard, "Show FOV Circle", "ShowFOV", yOff); yOff = yOff + 24
addStepper(cCard, "FOV Radius:", "FOVRadius", 20, 500, 10, yOff); yOff = yOff + 28
addToggle(cCard, "Show Targeting Line", "ShowLine", yOff); yOff = yOff + 24
addToggle(cCard, "Aimbot M1 (Dragon Gun) ⚠️ BAN RISK", "DragonGun", yOff); yOff = yOff + 24
addToggle(cCard, "Target Players", "TargetPlayers", yOff); yOff = yOff + 24
addToggle(cCard, "Target NPCs", "TargetMobs", yOff); yOff = yOff + 24
addToggle(cCard, "Team Check", "TeamCheck", yOff); yOff = yOff + 24
addToggle(cCard, "Ignore Safe Zone", "IgnoreSafe", yOff); yOff = yOff + 24
addToggle(cCard, "Ignore PvP OFF", "IgnorePvPOff", yOff); yOff = yOff + 24
addToggle(cCard, "Rainbow Body ESP", "RainbowBody", yOff); yOff = yOff + 24
addStepper(cCard, "Max Dist:", "AimbotMaxDist", 100, 5000, 100, yOff); yOff = yOff + 28

local cCard2, _ = createCard(pages["Combat"], "Fast Attack & Combat", 80)
yOff = 24
addToggle(cCard2, "Fast Attack", "FastAttack", yOff); yOff = yOff + 24
addToggle(cCard2, "Walk Speed", "WalkSpeed", yOff); yOff = yOff + 24
addStepper(cCard2, "Speed:", "WalkSpeedVal", 16, 500, 10, yOff); yOff = yOff + 28
addToggle(cCard2, "Dash Distance", "Dash", yOff); yOff = yOff + 24
addStepper(cCard2, "Distance:", "DashDist", 1, 300, 5, yOff); yOff = yOff + 28
addToggle(cCard2, "Noclip", "Noclip", yOff); yOff = yOff + 24
addToggle(cCard2, "Walk on Water", "WalkOnWater", yOff); yOff = yOff + 24

-- GLITCHES PAGE
local gCard, _ = createCard(pages["Glitches"], "Glitches", 220)
yOff = 24
addToggle(gCard, "Super Jump", "SuperJump", yOff); yOff = yOff + 24
addStepper(gCard, "Jump Power:", "SuperJumpPower", 100, 1500, 50, yOff); yOff = yOff + 28
addToggle(gCard, "No Animations", "NoAnim", yOff); yOff = yOff + 24
addToggle(gCard, "Anti Lava", "AntiLava", yOff); yOff = yOff + 24
addToggle(gCard, "FFlags 1", "FFlags", yOff); yOff = yOff + 24
addToggle(gCard, "Macro Beta", "Macro", yOff); yOff = yOff + 24

-- ESP PAGE
local eCard, _ = createCard(pages["ESP"], "ESP & Visuals", 280)
yOff = 24
addToggle(eCard, "General ESP", "ESPEnabled", yOff); yOff = yOff + 24
addToggle(eCard, "Show Name", "ESPName", yOff); yOff = yOff + 24
addToggle(eCard, "Show Level", "ESPLevel", yOff); yOff = yOff + 24
addToggle(eCard, "Show Bounty", "ESPBounty", yOff); yOff = yOff + 24
addToggle(eCard, "Show Fruit", "ESPFruit", yOff); yOff = yOff + 24
addToggle(eCard, "Show Distance", "ESPDist", yOff); yOff = yOff + 24
addToggle(eCard, "Show HP %", "ESPHP", yOff); yOff = yOff + 24
addToggle(eCard, "Highlight Players (Gold)", "ESPHighlight", yOff); yOff = yOff + 24
addStepper(eCard, "Text Size:", "ESPTextSize", 8, 30, 1, yOff); yOff = yOff + 28

-- SORU PAGE
local sCard, _ = createCard(pages["Soru"], "Soru & Bypass", 220)
yOff = 24
addToggle(sCard, "Infinite Soru", "InfSoru", yOff); yOff = yOff + 24
addToggle(sCard, "Soru Aimbot (TP)", "SoruAimbot", yOff); yOff = yOff + 24
addToggle(sCard, "Portal Soru Combo", "PortalSoru", yOff); yOff = yOff + 24
addToggle(sCard, "Portal Sanguine C Combo", "PortalSanguineC", yOff); yOff = yOff + 24
-- Trigger selector (simple toggle between PortalF and Soru)
local triggerBtn = Instance.new("TextButton", sCard)
triggerBtn.Size = UDim2.new(1,-12,0,20)
triggerBtn.Position = UDim2.new(0,6,0,yOff)
triggerBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
triggerBtn.BackgroundTransparency = 0
triggerBtn.Text = "Trigger: " .. (state.PortalSanguineCTrigger == "PortalF" and "Portal F" or "Soru")
triggerBtn.Font = Enum.Font.GothamBold
triggerBtn.TextSize = 8.5
triggerBtn.TextColor3 = Color3.fromRGB(255,215,0)
Instance.new("UICorner", triggerBtn).CornerRadius = UDim.new(0,4)
local trigStroke = Instance.new("UIStroke", triggerBtn)
trigStroke.Color = Color3.fromRGB(255,215,0)
trigStroke.Thickness = 1
triggerBtn.MouseButton1Click:Connect(function()
    state.PortalSanguineCTrigger = (state.PortalSanguineCTrigger == "PortalF") and "Soru" or "PortalF"
    triggerBtn.Text = "Trigger: " .. (state.PortalSanguineCTrigger == "PortalF" and "Portal F" or "Soru")
    SaveAll()
end)
yOff = yOff + 28

-- MISC PAGE
local mCard, _ = createCard(pages["Misc"], "Config", 140)
yOff = 24
local langBtn = Instance.new("TextButton", mCard)
langBtn.Size = UDim2.new(1,-12,0,24)
langBtn.Position = UDim2.new(0,6,0,yOff)
langBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
langBtn.BackgroundTransparency = 0
langBtn.Text = "🌐 Language: " .. (state.Language == "EN" and "English" or "Español")
langBtn.Font = Enum.Font.GothamBold
langBtn.TextSize = 9
langBtn.TextColor3 = Color3.fromRGB(255,215,0)
Instance.new("UICorner", langBtn).CornerRadius = UDim.new(0,4)
local langStroke = Instance.new("UIStroke", langBtn)
langStroke.Color = Color3.fromRGB(255,215,0)
langStroke.Thickness = 1
langBtn.MouseButton1Click:Connect(function()
    state.Language = (state.Language == "EN") and "ES" or "EN"
    langBtn.Text = "🌐 Language: " .. (state.Language == "EN" and "English" or "Español")
    SaveAll()
end)
yOff = yOff + 28

local saveBtn = Instance.new("TextButton", mCard)
saveBtn.Size = UDim2.new(1,-12,0,24)
saveBtn.Position = UDim2.new(0,6,0,yOff)
saveBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
saveBtn.BackgroundTransparency = 0
saveBtn.Text = "💾 Save Config"
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 9
saveBtn.TextColor3 = Color3.fromRGB(255,215,0)
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0,4)
local saveStroke = Instance.new("UIStroke", saveBtn)
saveStroke.Color = Color3.fromRGB(255,215,0)
saveStroke.Thickness = 1
saveBtn.MouseButton1Click:Connect(function()
    SaveAll()
    saveBtn.Text = "✅ Saved!"
    task.delay(1.5, function()
        saveBtn.Text = "💾 Save Config"
    end)
end)
yOff = yOff + 28

local resetBtn = Instance.new("TextButton", mCard)
resetBtn.Size = UDim2.new(1,-12,0,24)
resetBtn.Position = UDim2.new(0,6,0,yOff)
resetBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
resetBtn.BackgroundTransparency = 0
resetBtn.Text = "🔄 Reset Config"
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = 9
resetBtn.TextColor3 = Color3.fromRGB(255,215,0)
Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0,4)
local resetStroke = Instance.new("UIStroke", resetBtn)
resetStroke.Color = Color3.fromRGB(255,215,0)
resetStroke.Thickness = 1
resetBtn.MouseButton1Click:Connect(function()
    -- Reset all to defaults
    for k,v in pairs(state) do
        if type(v) ~= "table" then
            if k == "ESPEnabled" then state[k] = false
            elseif k == "ESPName" then state[k] = true
            elseif k == "ESPLevel" then state[k] = true
            elseif k == "ESPBounty" then state[k] = true
            elseif k == "ESPFruit" then state[k] = true
            elseif k == "ESPDist" then state[k] = true
            elseif k == "ESPHP" then state[k] = true
            elseif k == "ESPHighlight" then state[k] = false
            elseif k == "ESPTextSize" then state[k] = 12
            elseif k == "FastAttack" then state[k] = false
            elseif k == "WalkSpeed" then state[k] = false
            elseif k == "WalkSpeedVal" then state[k] = 16
            elseif k == "Dash" then state[k] = false
            elseif k == "DashDist" then state[k] = 1
            elseif k == "Noclip" then state[k] = false
            elseif k == "WalkOnWater" then state[k] = false
            elseif k == "SuperJump" then state[k] = false
            elseif k == "SuperJumpPower" then state[k] = 500
            elseif k == "NoAnim" then state[k] = false
            elseif k == "AntiLava" then state[k] = false
            elseif k == "FFlags" then state[k] = false
            elseif k == "Macro" then state[k] = false
            elseif k == "InfSoru" then state[k] = false
            elseif k == "SoruAimbot" then state[k] = false
            elseif k == "PortalSoru" then state[k] = false
            elseif k == "PortalSanguineC" then state[k] = false
            elseif k == "PortalSanguineCTrigger" then state[k] = "PortalF"
            elseif k == "SkillAimbot" then state[k] = false
            elseif k == "ShowFOV" then state[k] = false
            elseif k == "FOVRadius" then state[k] = 150
            elseif k == "ShowLine" then state[k] = false
            elseif k == "TargetPlayers" then state[k] = false
            elseif k == "TargetMobs" then state[k] = false
            elseif k == "TeamCheck" then state[k] = false
            elseif k == "IgnoreSafe" then state[k] = true
            elseif k == "IgnorePvPOff" then state[k] = true
            elseif k == "RainbowBody" then state[k] = false
            elseif k == "AimbotMaxDist" then state[k] = 2500
            elseif k == "FPSOverlay" then state[k] = false
            elseif k == "Language" then state[k] = "EN"
            end
        end
    end
    -- Clear file
    pcall(function() if isfile and isfile(configFileName) then delfile(configFileName) end end)
    SaveAll()
    resetBtn.Text = "✅ Reset Done!"
    task.delay(1.5, function()
        resetBtn.Text = "🔄 Reset Config"
    end)
    -- Reload UI by destroying and recreating? For simplicity, just restart the script.
    screenGui:Destroy()
    -- Re-run the script? We'll just print a message and let user re-run.
    print("Config reset. Re-execute the script to reload UI.")
end)

-- ============================================================
-- FPS OVERLAY
-- ============================================================
local fpsGui = Instance.new("ScreenGui")
fpsGui.Name = "RitualFPS"
fpsGui.ResetOnSpawn = false
fpsGui.Parent = playerGui

local fpsFrame = Instance.new("Frame", fpsGui)
fpsFrame.Size = UDim2.new(0,140,0,20)
fpsFrame.Position = UDim2.new(0.5,-70,0,5)
fpsFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
fpsFrame.BackgroundTransparency = 0.3
fpsFrame.Visible = false
Instance.new("UICorner", fpsFrame).CornerRadius = UDim.new(0,6)
local fpsStroke = Instance.new("UIStroke", fpsFrame)
fpsStroke.Color = Color3.fromRGB(255,215,0)
fpsStroke.Thickness = 1

local fpsLabel = Instance.new("TextLabel", fpsFrame)
fpsLabel.Size = UDim2.new(1,0,1,0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: 0 | Ping: 0ms"
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 9
fpsLabel.TextColor3 = Color3.fromRGB(255,255,255)
fpsLabel.TextXAlignment = Enum.TextXAlignment.Center

local frameCount = 0
local lastTime = tick()
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
end)
task.spawn(function()
    while true do
        task.wait(1)
        local now = tick()
        local elapsed = now - lastTime
        local fps = math.floor(frameCount / elapsed)
        frameCount = 0
        lastTime = now
        local ping = math.floor(player:GetNetworkPing() * 1000)
        fpsLabel.Text = "FPS: "..fps.." | Ping: "..ping.."ms"
    end
end)

-- Toggle FPS overlay via keybind? We'll add a toggle in Misc later.
-- For now, we just keep it hidden; we'll add a toggle in the UI if needed.
-- Actually we can add a toggle in Misc.

local fpsToggle = Instance.new("TextButton", mCard)
fpsToggle.Size = UDim2.new(1,-12,0,24)
fpsToggle.Position = UDim2.new(0,6,0,yOff)
fpsToggle.BackgroundColor3 = Color3.fromRGB(0,0,0)
fpsToggle.BackgroundTransparency = 0
fpsToggle.Text = "📊 FPS Overlay: OFF"
fpsToggle.Font = Enum.Font.GothamBold
fpsToggle.TextSize = 9
fpsToggle.TextColor3 = Color3.fromRGB(255,215,0)
Instance.new("UICorner", fpsToggle).CornerRadius = UDim.new(0,4)
local fpsToggleStroke = Instance.new("UIStroke", fpsToggle)
fpsToggleStroke.Color = Color3.fromRGB(255,215,0)
fpsToggleStroke.Thickness = 1
yOff = yOff + 28

fpsToggle.MouseButton1Click:Connect(function()
    state.FPSOverlay = not state.FPSOverlay
    fpsFrame.Visible = state.FPSOverlay
    fpsToggle.Text = "📊 FPS Overlay: " .. (state.FPSOverlay and "ON" or "OFF")
    SaveAll()
end)

-- ============================================================
-- FINAL SETUP
-- ============================================================
print("✅ Ritual Hub loaded. Press F4 to toggle UI (if visible).")
-- Keybind to toggle UI
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.F4 then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- Auto-save on close? Not needed, saved on toggle changes.

-- Ensure settings applied on load
setNoclip(state.Noclip)
setNoAnim(state.NoAnim)
setAntiLava(state.AntiLava)
setInfSoru(state.InfSoru)
if state.FastAttack then startFastAttack() end
if state.FFlags then toggleFFlags(true) end
if state.SkillAimbot then
    if FOVCircle then FOVCircle.Visible = state.ShowFOV end
    if TargetLine then TargetLine.Visible = state.ShowLine end
end

-- Load macro settings from state
macroComboSlots[1] = {slot = state.MacroSlot1, key = state.MacroKey1, delay = state.MacroDelay1}
macroComboSlots[2] = {slot = state.MacroSlot2, key = state.MacroKey2, delay = state.MacroDelay2}
macroComboSlots[3] = {slot = state.MacroSlot3, key = state.MacroKey3, delay = state.MacroDelay3}
macroComboSlots[4] = {slot = state.MacroSlot4, key = state.MacroKey4, delay = state.MacroDelay4}
macroComboSlots[5] = {slot = state.MacroSlot5, key = state.MacroKey5, delay = state.MacroDelay5}
macroComboSlots[6] = {slot = state.MacroSlot6, key = state.MacroKey6, delay = state.MacroDelay6}

-- Start ESP update loop
task.spawn(function()
    while true do
        task.wait(0.3)
        pcall(updateESP)
    end
end)
