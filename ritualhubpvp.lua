-- ============================================================
-- RITUAL HUB V1.0 | DELTA EXECUTOR | BLACK & GOLD THEME
-- MADE BY: RITUALZ999
-- ============================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local VirtualInputManager = nil
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)

local player = Players.LocalPlayer or Players:FindFirstChildOfClass("Player")
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
-- RITUAL HUB THEME | BLACK & GOLD
-- ============================================================
local GOLD = Color3.fromRGB(255, 215, 0)
local DARK_GOLD = Color3.fromRGB(184, 134, 11)
local BLACK = Color3.fromRGB(0, 0, 0)
local DARK_BG = Color3.fromRGB(8, 8, 8)
local PANEL_BG = Color3.fromRGB(10, 10, 10)
local TEXT_WHITE = Color3.fromRGB(255, 255, 255)
local TEXT_GOLD = GOLD
local RITUAL_RED = Color3.fromRGB(180, 20, 20)

-- Tracking Variables
scriptStartTime = os.time()
totalExecutions = 0
startBounty = 0
accumulatedBountyGained = 0

-- Cargar Bounty Local Guardado
pcall(function()
    if isfile and readfile and isfile("RitualHub_Bounty.json") then
        local bData = HttpService:JSONDecode(readfile("RitualHub_Bounty.json"))
        if bData and bData.Gained then accumulatedBountyGained = bData.Gained end
    end
end)

function SaveLocalBounty(gained)
    accumulatedBountyGained = gained
    pcall(function()
        if writefile then
            writefile("RitualHub_Bounty.json", HttpService:JSONEncode({Gained = gained}))
        end
    end)
end

-- Estado
SoruInfinitoEnabled = false
SoruAimbotEnabled = false
soruMaxDist = 1000
AimlockPlayerEnabled = false
AimlockNpcEnabled = false
SilentAimPlayersEnabled = false
SilentAimNPCsEnabled = false
PlayerWidgetActive = false
NpcWidgetActive = false
SelectedSoruTarget = "Nearest"
maxRange = 2500

-- Config Aimbot
_G.G_DragonGunM1 = false
_G.G_AttackMobs = true
_G.G_AttackPlayers = true

_G.G_SilentAimSkill = false
_G.G_SilentAimShowFOV = false
_G.G_SilentAimFOV = 150
_G.G_SilentAimPart = "HumanoidRootPart"
_G.G_SilentAimFOVThickness = 2
_G.G_SilentAimFOVTransparency = 1
_G.G_SilentAimTargetPlayers = false
_G.G_SilentAimTargetMobs = false
_G.G_TargetRainbowBodyESP = false
_G.G_SilentAimFOVMode = "Screen Center"
_G.G_SilentAimTeamCheck = false
_G.G_SilentAimSelectedPlayer = ""
_G.G_AimbotMelee = false
_G.G_AimbotFruit = false
_G.G_AimbotSword = false
_G.G_AimbotGun = false

-- Granular Exclusions
_G.G_Ex_Fruit_M1 = false; _G.G_Ex_Fruit_Z = false; _G.G_Ex_Fruit_X = false; _G.G_Ex_Fruit_C = false; _G.G_Ex_Fruit_V = false; _G.G_Ex_Fruit_F = false
_G.G_Ex_Melee_M1 = false; _G.G_Ex_Melee_Z = false; _G.G_Ex_Melee_X = false; _G.G_Ex_Melee_C = false; _G.G_Ex_Melee_V = false; _G.G_Ex_Melee_F = false
_G.G_Ex_Sword_M1 = false; _G.G_Ex_Sword_Z = false; _G.G_Ex_Sword_X = false; _G.G_Ex_Sword_C = false; _G.G_Ex_Sword_V = false; _G.G_Ex_Sword_F = false
_G.G_Ex_Gun_M1 = false;   _G.G_Ex_Gun_Z = false;   _G.G_Ex_Gun_X = false;   _G.G_Ex_Gun_C = false;   _G.G_Ex_Gun_V = false;   _G.G_Ex_Gun_F = false

-- Variables
SuperJumpEnabled = false 
SuperJumpPower = 500 
SanguineAutoEnabled = false
SanguineWidgetVisible = false 
SanguineAutoConnection = nil
SanguineAutoDropDuration = 2.0
SanguineAutoCooldown = false
SanguineNoCDEnabled = false
noCDCharConnection = nil
SoulGuitarJumpEnabled = false
SoulGuitarWidgetVisible = false
SoulGuitarDashLength = 121 
soulGuitarBusy = false
fflagsThread = nil

PortalSoruEnabled = false
PortalSoruWidgetVisible = false
BlacklistedPlayers = {}
FakeKorbloxEnabled = false
FakeHeadlessEnabled = false
ActiveAura = nil
AuraObjects = {}
FPSPingOverlayEnabled = false
currentFPS = 0
currentPing = 0
currentLang = "EN"

DashEnabled = false
DashLengthDist = 1
DashRunning = false
prevDashLength = 1 
prevDashEnabled = false 

-- ============================================================
-- FOV CIRCLE
-- ============================================================
local FOVCircle = nil
local FOVCircleVisible = false

pcall(function()
    if Drawing and Drawing.new then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Visible = false
        FOVCircle.Color = GOLD
        FOVCircle.Radius = _G.G_SilentAimFOV or 150
        FOVCircle.Thickness = 2
        FOVCircle.Filled = false
        FOVCircle.Transparency = 0.5
    end
end)

-- ============================================================
-- PERSISTENCIA TOTAL DE CONFIGURACIÓN
-- ============================================================
UI_Toggle_Refreshes = {}
ToggleRegistryMap = {}

function SaveConfig()
    local conf = {
        ESPMaster = _G.G_ESPEnabled,
        ESPName = _G.G_ESP_Name,
        ESPLevel = _G.G_ESP_Level,
        ESPBounty = _G.G_ESP_Bounty,
        ESPFruit = _G.G_ESP_Fruit,
        ESPDist = _G.G_ESP_Distance,
        ESPHealth = _G.G_ESP_HP,
        ESPHighlight = _G.G_ESP_Highlight,
        ESPTextSize = _G.G_ESP_TextSize,
        FastAttack = FastAttackEnabled,
        WalkSpeed = WalkSpeedEnabled,
        WSpeedVal = WalkSpeedValue,
        Dash = DashEnabled,
        DashDist = DashLengthDist,
        Noclip = NoclipEnabled,
        WalkOnWater = WalkOnWaterEnabled,
        SmartV4 = SmartAutoV4Enabled,
        SanguineManual = SanguineManualEnabled,
        SanguineAuto = SanguineAutoEnabled,
        SanguineDrop = SanguineAutoDropDuration,
        SanguineNoCD = SanguineNoCDEnabled,
        AntiStunHitbox = AntiStunHitboxEnabled,
        SuperJump = SuperJumpEnabled,
        SuperPower = SuperJumpPower,
        SoulGuitar = SoulGuitarJumpEnabled,
        SoulDash = SoulGuitarDashLength,
        NoAnim = NoAnimEnabled,
        AntiLava = antiLavaActive,
        DeleteShip = deleteShipActive,
        TargetPlayers = _G.G_SilentAimTargetPlayers,
        TargetMobs = _G.G_SilentAimTargetMobs,
        SkillAimbot = _G.G_SilentAimSkill,
        DragonM1 = _G.G_DragonGunM1,
        TeamCheck = _G.G_SilentAimTeamCheck,
        ShowFOV = _G.G_SilentAimShowFOV,
        ShowLine = _G.G_SilentAimShowLine,
        FOVRadius = _G.G_SilentAimFOV,
        AimbotMaxDist = maxRange,
        AimlockPlayers = AimlockPlayerEnabled,
        AimlockNPCs = AimlockNpcEnabled,
        PlayerWidgetActive = PlayerWidgetActive,
        NpcWidgetActive = NpcWidgetActive,
        SanguineWidgetVisible = SanguineWidgetVisible,
        SanguineManualWidgetVisible = SanguineManualWidgetVisible,
        SoulGuitarWidgetVisible = SoulGuitarWidgetVisible,
        PortalSoruWidgetVisible = PortalSoruWidgetVisible,
        SuperJumpWidgetVisible = SuperJumpWidgetVisible,
        InfSoru = SoruInfinitoEnabled,
        SoruAimbot = SoruAimbotEnabled,
        PortalSoru = PortalSoruEnabled,
        PortalSanguineC = PortalSanguineCEnabled,
        PortalSanguineCTriggerMode = PortalSanguineCTriggerMode,
        FakeKorblox = FakeKorbloxEnabled,
        FakeHeadless = FakeHeadlessEnabled,
        FPSPing = FPSPingOverlayEnabled,
        MacroBeta = MacroEnabled,
        MacroMode = MacroMode,
        MacroSlot1 = MacroSlot1,
        MacroKey1 = MacroKey1,
        MacroSlot2 = MacroSlot2,
        MacroKey2 = MacroKey2,
        MacroSlot3 = MacroSlot3,
        MacroKey3 = MacroKey3,
        MacroSlot4 = MacroSlot4,
        MacroKey4 = MacroKey4,
        MacroSlot5 = MacroSlot5,
        MacroKey5 = MacroKey5,
        MacroSlot6 = MacroSlot6,
        MacroKey6 = MacroKey6,
        MacroDelay1 = MacroDelay1,
        MacroDelay2 = MacroDelay2,
        MacroDelay3 = MacroDelay3,
        MacroDelay4 = MacroDelay4,
        MacroDelay5 = MacroDelay5,
        MacroDelay6 = MacroDelay6,
        AutoV4 = AutoV4Enabled,
        ThemeName = currentThemeName,
        Language = currentLang
    }
    pcall(function()
        if writefile then
            writefile("RitualHub_Config.json", HttpService:JSONEncode(conf))
            print("💾 Ritual Hub Config Saved Successfully!")
        end
    end)
end

function LoadConfig()
    pcall(function()
        if isfile and readfile and isfile("RitualHub_Config.json") then
            local str = readfile("RitualHub_Config.json")
            local conf = HttpService:JSONDecode(str)
            if not conf then return end

            for id, val in pairs(conf) do
                if val ~= nil and ToggleRegistryMap[id] ~= nil then
                    pcall(function() ToggleRegistryMap[id](val) end)
                end
            end

            if conf.ESPMaster ~= nil then 
                _G.G_ESPEnabled = conf.ESPMaster 
                if conf.ESPMaster then EnableESP() else DisableESP() end
            end
            if conf.ESPName ~= nil then _G.G_ESP_Name = conf.ESPName end
            if conf.ESPLevel ~= nil then _G.G_ESP_Level = conf.ESPLevel end
            if conf.ESPBounty ~= nil then _G.G_ESP_Bounty = conf.ESPBounty end
            if conf.ESPFruit ~= nil then _G.G_ESP_Fruit = conf.ESPFruit end
            if conf.ESPDist ~= nil then _G.G_ESP_Distance = conf.ESPDist end
            if conf.ESPHealth ~= nil then _G.G_ESP_HP = conf.ESPHealth end
            if conf.ESPHighlight ~= nil then _G.G_ESP_Highlight = conf.ESPHighlight end
            if conf.ESPTextSize ~= nil then _G.G_ESP_TextSize = conf.ESPTextSize end

            if conf.WSpeedVal ~= nil then WalkSpeedValue = conf.WSpeedVal end
            if conf.DashDist ~= nil then DashLengthDist = conf.DashDist end
            if conf.SuperPower ~= nil then SuperJumpPower = conf.SuperPower end
            if conf.SanguineDrop ~= nil then SanguineAutoDropDuration = conf.SanguineDrop end
            if conf.SanguineNoCD ~= nil then SanguineNoCDEnabled = conf.SanguineNoCD end
            if conf.AntiStunHitbox ~= nil then AntiStunHitboxEnabled = conf.AntiStunHitbox end
            if conf.SoulDash ~= nil then SoulGuitarDashLength = conf.SoulDash end
            if conf.FOVRadius ~= nil then 
                _G.G_SilentAimFOV = conf.FOVRadius 
                if FOVCircle then FOVCircle.Radius = conf.FOVRadius end
            end
            if conf.AimbotMaxDist ~= nil then maxRange = conf.AimbotMaxDist end

            if conf.SanguineManual ~= nil then SanguineManualEnabled = conf.SanguineManual end
            if conf.SanguineManualWidgetVisible ~= nil then SanguineManualWidgetVisible = conf.SanguineManualWidgetVisible end

            if conf.PlayerWidgetActive ~= nil then PlayerWidgetActive = conf.PlayerWidgetActive end
            if conf.NpcWidgetActive ~= nil then NpcWidgetActive = conf.NpcWidgetActive end
            if conf.SanguineWidgetVisible ~= nil then SanguineWidgetVisible = conf.SanguineWidgetVisible end
            if conf.SoulGuitarWidgetVisible ~= nil then SoulGuitarWidgetVisible = conf.SoulGuitarWidgetVisible end
            if conf.PortalSoruWidgetVisible ~= nil then PortalSoruWidgetVisible = conf.PortalSoruWidgetVisible end
            if conf.SuperJumpWidgetVisible ~= nil then SuperJumpWidgetVisible = conf.SuperJumpWidgetVisible end

            if FOVCircle then FOVCircle.Visible = (_G.G_SilentAimShowFOV == true) end
            if conf.ThemeName and applyNewTheme then applyNewTheme(conf.ThemeName) end
            if updateWidgetsVisuals then updateWidgetsVisuals() end

            if conf.MacroBeta ~= nil then MacroEnabled = conf.MacroBeta end
            if conf.MacroMode ~= nil then MacroMode = conf.MacroMode end
            if conf.MacroSlot1 ~= nil then MacroSlot1 = conf.MacroSlot1 end
            if conf.MacroKey1 ~= nil then MacroKey1 = conf.MacroKey1 end
            if conf.MacroSlot2 ~= nil then MacroSlot2 = conf.MacroSlot2 end
            if conf.MacroKey2 ~= nil then MacroKey2 = conf.MacroKey2 end
            if conf.MacroSlot3 ~= nil then MacroSlot3 = conf.MacroSlot3 end
            if conf.MacroKey3 ~= nil then MacroKey3 = conf.MacroKey3 end
            if conf.MacroSlot4 ~= nil then MacroSlot4 = conf.MacroSlot4 end
            if conf.MacroKey4 ~= nil then MacroKey4 = conf.MacroKey4 end
            if conf.MacroSlot5 ~= nil then MacroSlot5 = conf.MacroSlot5 end
            if conf.MacroKey5 ~= nil then MacroKey5 = conf.MacroKey5 end
            if conf.MacroSlot6 ~= nil then MacroSlot6 = conf.MacroSlot6 end
            if conf.MacroKey6 ~= nil then MacroKey6 = conf.MacroKey6 end
            if conf.MacroDelay1 ~= nil then MacroDelay1 = conf.MacroDelay1 end
            if conf.MacroDelay2 ~= nil then MacroDelay2 = conf.MacroDelay2 end
            if conf.MacroDelay3 ~= nil then MacroDelay3 = conf.MacroDelay3 end
            if conf.MacroDelay4 ~= nil then MacroDelay4 = conf.MacroDelay4 end
            if conf.MacroDelay5 ~= nil then MacroDelay5 = conf.MacroDelay5 end
            if conf.MacroDelay6 ~= nil then MacroDelay6 = conf.MacroDelay6 end
            if conf.AutoV4 ~= nil then 
                AutoV4Enabled = conf.AutoV4 
                if AutoV4Enabled then startAutoV4Loop() end
            end

            if conf.Language ~= nil then 
                currentLang = conf.Language 
                if updateLangBtnColors then updateLangBtnColors() end
                if updateLanguageUI then updateLanguageUI() end
            end

            print("✅ Ritual Hub Config Loaded & Applied Successfully!")
        end
    end)
end

pcall(function()
    local targetFolder = parentGui or playerGui
    if targetFolder then
        for _, old in ipairs(targetFolder:GetChildren()) do
            if old and old.Name and old.Name:match("RitualUI") then 
                pcall(function() old:Destroy() end) 
            end
        end
    end
end)

-- ============================================================
-- DRAGON GUN M1 FAST ATTACK (REMOVED - No Aimbot)
-- ============================================================
-- Dragon Gun M1 functionality has been removed as requested

function UpdateDragonButton()
    -- Removed
end

-- ============================================================
-- AUTO RACE V4 ENGINE
-- ============================================================
AutoV4Enabled = false
local autoV4Thread = nil

function startAutoV4Loop()
    if autoV4Thread then return end
    autoV4Thread = task.spawn(function()
        while AutoV4Enabled do
            task.wait(0.5)
            pcall(function()
                local char = player.Character
                if not char then return end
                local raceEnergy = char:GetAttribute("RaceEnergy")
                if raceEnergy and raceEnergy >= 100 then
                    local awk = player.Backpack:FindFirstChild("Awakening") or char:FindFirstChild("Awakening")
                    if awk and awk:FindFirstChild("RemoteFunction") then
                        awk.RemoteFunction:InvokeServer(true)
                    else
                        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                        if remotes and remotes:FindFirstChild("CommF_") then
                            remotes.CommF_:InvokeServer("Awakening", true)
                        end
                    end
                end
            end)
        end
        autoV4Thread = nil
    end)
end

function stopAutoV4Loop()
    AutoV4Enabled = false
    autoV4Thread = nil
end

AntiStunHitboxEnabled = false
antiStunHeartbeatConn = nil
antiStunInputConn = nil
antiStunCharConn = nil

function enableAntiStunHitbox()
    AntiStunHitboxEnabled = true
    
    if antiStunHeartbeatConn then antiStunHeartbeatConn:Disconnect() end
    antiStunHeartbeatConn = RunService.Heartbeat:Connect(function()
        if not AntiStunHitboxEnabled then return end
        pcall(function()
            local char = player.Character
            if not char then return end
            char:SetAttribute("AllCooldown", 0)
            char:SetAttribute("FlashstepCooldown", 1)
            char:SetAttribute("UsingSkill", false)
            char:SetAttribute("isUsingSkill", false)
            char:SetAttribute("Busy", false)
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if hum and hum.WalkSpeed < 16 then hum.WalkSpeed = 16 end
            if root then
                for _, v in ipairs(root:GetChildren()) do
                    if v:IsA("BodyVelocity") or v:IsA("BodyPosition") then
                        v:Destroy()
                    end
                end
            end
            local pgui = player:FindFirstChild("PlayerGui")
            if pgui and pgui:FindFirstChild("Main") then
                local skills = pgui.Main:FindFirstChild("Skills")
                if skills then
                    local dbSkills = skills:FindFirstChild("Dark Blade")
                    if dbSkills then
                        for _, skillFrame in ipairs(dbSkills:GetChildren()) do
                            local cd = skillFrame:FindFirstChild("Cooldown")
                            if cd and cd:IsA("Frame") then
                                cd.Size = UDim2.new(0, 0, 1, 0)
                                cd.Visible = false
                            end
                        end
                    end
                end
            end
        end)
    end)
    
    if antiStunInputConn then antiStunInputConn:Disconnect() end
    antiStunInputConn = UserInputService.InputBegan:Connect(function(input, gp)
        if not AntiStunHitboxEnabled or gp then return end
        local char = player.Character
        if not char then return end
        local darkBlade = char:FindFirstChild("Dark Blade")
        if not darkBlade or not darkBlade:FindFirstChild("RemoteEvent") then return end
        if input.KeyCode == Enum.KeyCode.Z then
            darkBlade.RemoteEvent:FireServer("Z")
        elseif input.KeyCode == Enum.KeyCode.X then
            darkBlade.RemoteEvent:FireServer("X")
        end
    end)
    
    if antiStunCharConn then antiStunCharConn:Disconnect() end
    antiStunCharConn = player.CharacterAdded:Connect(function(char)
        if AntiStunHitboxEnabled then
            task.wait(1)
            pcall(function()
                char:SetAttribute("AllCooldown", 0)
                char:SetAttribute("FlashstepCooldown", 1)
            end)
        end
    end)
end

function disableAntiStunHitbox()
    AntiStunHitboxEnabled = false
    if antiStunHeartbeatConn then antiStunHeartbeatConn:Disconnect(); antiStunHeartbeatConn = nil end
    if antiStunInputConn then antiStunInputConn:Disconnect(); antiStunInputConn = nil end
    if antiStunCharConn then antiStunCharConn:Disconnect(); antiStunCharConn = nil end
    pcall(function()
        local char = player.Character
        if char then
            char:SetAttribute("AllCooldown", nil)
            char:SetAttribute("FlashstepCooldown", nil)
            char:SetAttribute("UsingSkill", nil)
            char:SetAttribute("isUsingSkill", nil)
            char:SetAttribute("Busy", nil)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
            end
        end
    end)
end

RegisterHit, RegisterAttack = nil, nil
FastAttackEnabled = false
FastAttackRange = 2500
FastAttackRunning = false

spawn(function()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name == "RE/RegisterHit" then RegisterHit = v end
        if v:IsA("RemoteEvent") and v.Name == "RE/RegisterAttack" then RegisterAttack = v end
    end
end)

function AttackMultipleTargets(targets)
    if not RegisterHit or not RegisterAttack then return end
    pcall(function()
        if not targets or #targets == 0 then return end
        local allTargets = {}
        for _, char in pairs(targets) do
            local head = char:FindFirstChild("Head")
            if head then table.insert(allTargets, {char, head}) end
        end
        if #allTargets == 0 then return end
        RegisterAttack:FireServer(0)
        RegisterHit:FireServer(allTargets[1][2], allTargets)
    end)
end

function StartFastAttack()
    if FastAttackRunning then return end
    FastAttackRunning = true
    spawn(function()
        while FastAttackEnabled do
            RunService.Stepped:Wait()
            local myChar = player.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myHRP then
                local targets = {}
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and not BlacklistedPlayers[p.Name] then
                        local hum = p.Character:FindFirstChild("Humanoid")
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if hum and hrp and hum.Health > 0 and (hrp.Position - myHRP.Position).Magnitude <= FastAttackRange then
                            table.insert(targets, p.Character)
                        end
                    end
                end
                local enemies = workspace:FindFirstChild("Enemies")
                if enemies then
                    for _, npc in pairs(enemies:GetChildren()) do
                        local hum = npc:FindFirstChild("Humanoid")
                        local hrp = npc:FindFirstChild("HumanoidRootPart")
                        if hum and hrp and hum.Health > 0 and (hrp.Position - myHRP.Position).Magnitude <= FastAttackRange then
                            table.insert(targets, npc)
                        end
                    end
                end
                if #targets > 0 then AttackMultipleTargets(targets) end
            end
        end
        FastAttackRunning = false
    end)
end

-- ============================================================
-- WALK SPEED
-- ============================================================
WalkSpeedEnabled = false
WalkSpeedValue = 16

spawn(function()
    while true do
        wait(0.2)
        if WalkSpeedEnabled then
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed ~= WalkSpeedValue then hum.WalkSpeed = WalkSpeedValue end
        end
    end
end)

-- ============================================================
-- DASH DISTANCE
-- ============================================================
function startDashLoop()
    if DashRunning then return end
    DashRunning = true
    spawn(function()
        while DashEnabled do
            wait(0.1)
            pcall(function()
                local char = player.Character
                if char then
                    if char:GetAttribute("DashLength") ~= DashLengthDist then char:SetAttribute("DashLength", DashLengthDist) end
                    if char:GetAttribute("DashLengthAir") ~= DashLengthDist then char:SetAttribute("DashLengthAir", DashLengthDist) end
                end
            end)
        end
        DashRunning = false
    end)
end

function stopDashLoop()
    DashEnabled = false
    pcall(function()
        local char = player.Character
        if char then
            char:SetAttribute("DashLength", 1)
            char:SetAttribute("DashLengthAir", 1)
        end
    end)
end

function applyDashInstantly()
    pcall(function()
        local char = player.Character
        if char then
            char:SetAttribute("DashLength", DashLengthDist)
            char:SetAttribute("DashLengthAir", DashLengthDist)
        end
    end)
end

-- ============================================================
-- NOCLIP
-- ============================================================
NoclipEnabled = false
NoclipConn = nil

function SetNoclip(state)
    NoclipEnabled = state
    if state then
        NoclipConn = RunService.Stepped:Connect(function()
            local char = player.Character
            if char and NoclipEnabled then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if NoclipConn then NoclipConn:Disconnect(); NoclipConn = nil end
        local char = player.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end

player.CharacterAdded:Connect(function()
    if NoclipEnabled then wait(0.5); SetNoclip(true) end
end)

-- ============================================================
-- DETENER ANIMACIONES
-- ============================================================
ATTACK_KEYWORDS = {"attack", "slash", "punch", "m1", "combo", "hit", "tool", "ability", "skill", "kamehameha", "bullet", "gun", "sword", "melee", "fruit"}

function isAttackAnim(track)
    local name = string.lower(track.Name)
    for _, kw in ipairs(ATTACK_KEYWORDS) do
        if string.find(name, kw) then return true end
    end
    if track.Priority == Enum.AnimationPriority.Action then return true end
    return false
end

function StopPlayerAnimations()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChild("Animator")
    if not animator then return end
    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
        if not isAttackAnim(track) then
            track:Stop(0)
        end
    end
end

-- ============================================================
-- SUPER JUMP
-- ============================================================
function doSuperJump()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    
    StopPlayerAnimations()
    hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, SuperJumpPower, hrp.AssemblyLinearVelocity.Z)
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
    if SuperJumpWidget then
        SuperJumpWidget.Visible = true
    end
end

-- ============================================================
-- SOUL GUITAR GLITCH
-- ============================================================
function executeSoulGuitarJump()
    if soulGuitarBusy then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local tool = char:FindFirstChild("Skull Guitar") or player.Backpack:FindFirstChild("Skull Guitar")
    if not tool then return end

    soulGuitarBusy = true

    if tool.Parent == player.Backpack then
        hum:EquipTool(tool)
        task.wait(0.15)
    end

    pcall(function()
        local equipEvent = tool:FindFirstChild("EquipEvent")
        if equipEvent then equipEvent:FireServer(true) end

        local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
        if remotesFolder then
            local validator = remotesFolder:FindFirstChild("Validator2")
            if validator then validator:FireServer(15627583, 1) end
        end

        local remoteEvent = tool:FindFirstChild("RemoteEvent")
        if remoteEvent then
            remoteEvent:FireServer("TAP", mouse.Hit.Position)
        end
    end)

    StopPlayerAnimations()
    local lookVector = hrp.CFrame.LookVector
    local flatLook = Vector3.new(lookVector.X, 0, lookVector.Z)
    if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end
    
    local soulAtt = Instance.new("Attachment")
    soulAtt.Parent = hrp
    local soulLV = Instance.new("LinearVelocity")
    soulLV.MaxForce = math.huge
    soulLV.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    soulLV.VectorVelocity = Vector3.new(flatLook.X * 180, 80, flatLook.Z * 180)
    soulLV.Attachment0 = soulAtt
    soulLV.Parent = hrp
    
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
    
    task.delay(0.7, function()
        if soulLV and soulLV.Parent then soulLV:Destroy() end
        if soulAtt and soulAtt.Parent then soulAtt:Destroy() end
    end)

    local tempNoAnimConn
    tempNoAnimConn = RunService.Stepped:Connect(function()
        if not char or not char.Parent or not hum or not hum.Parent then
            if tempNoAnimConn then tempNoAnimConn:Disconnect() end
            return
        end
        hum.AutoRotate = true
        local animator = hum:FindFirstChild("Animator")
        if animator then
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                if not isAttackAnim(track) then
                    track:Stop(0)
                end
            end
        end
        if hum.FloorMaterial ~= Enum.Material.Air then
            if tempNoAnimConn then tempNoAnimConn:Disconnect() end
        end
    end)
    
    task.wait(0.6) 
    soulGuitarBusy = false
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and SoulGuitarJumpEnabled then
        executeSoulGuitarJump()
    end
end)

-- ============================================================
-- PORTAL COMBOS
-- ============================================================
PortalSanguineCEnabled = false
PortalSanguineCTriggerMode = "PortalF"

function isHoldingPortalFruit()
    local char = player.Character
    if not char then return false end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local tName = string.lower(tool.Name)
        if string.find(tName, "portal") or string.find(tName, "door") then return true end
    end
    return false
end

function equipSanguineArt()
    local char = player.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    
    local tool = char:FindFirstChild("Sanguine Art") or char:FindFirstChild("Sanguine")
    if not tool then
        local bp = player:FindFirstChild("Backpack")
        if bp then
            for _, t in ipairs(bp:GetChildren()) do
                local name = string.lower(t.Name)
                if string.find(name, "sanguine") then
                    hum:EquipTool(t)
                    tool = t
                    task.wait(0.1)
                    break
                end
            end
        end
    end
    return tool
end

function equipPortalFruit()
    local char = player.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    
    local tool = char:FindFirstChild("Portal-Portal") or char:FindFirstChild("Portal Fruit") or char:FindFirstChild("Portal") or char:FindFirstChild("Door")
    if not tool then
        local bp = player:FindFirstChild("Backpack")
        if bp then
            for _, t in ipairs(bp:GetChildren()) do
                local name = string.lower(t.Name)
                if string.find(name, "portal") or string.find(name, "door") then
                    hum:EquipTool(t)
                    tool = t
                    task.wait(0.1)
                    break
                end
            end
        end
    end
    return tool
end

function doPortalCombo()
    if not isHoldingPortalFruit() then
        equipPortalFruit()
        task.wait(0.08)
    end
    if not isHoldingPortalFruit() then return end

    local function pressKey(kc)
        VirtualInputManager:SendKeyEvent(true, kc, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, kc, false, game)
    end
    pressKey(Enum.KeyCode.X)
    task.wait(0.15)
    pressKey(Enum.KeyCode.Z)
end

function doPortalSanguineCCombo()
    task.wait(0.25)
    equipSanguineArt()
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.C, false, game)
    task.wait(0.15)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, game)
end

FLASH_NAMES = {"FlashStepRegular","FlashStepDraco","FlashStep","Flashstep","Soru"}
FLASH_IDS = {"17555632156","18461649274","616006778","616010882","5403485593","5403491911"}

function isFlashstep(track)
    for _,n in ipairs(FLASH_NAMES) do
        if string.find(string.lower(track.Name), string.lower(n)) then return true end
    end
    local id = track.Animation and track.Animation.AnimationId:match("%d+") or ""
    for _,fid in ipairs(FLASH_IDS) do
        if id == fid then return true end
    end
    return false
end

function monitorCharPortal(char)
    local h = char:WaitForChild("Humanoid", 5) 
    if not h then return end
    h.AnimationPlayed:Connect(function(track)
        local animName = string.lower(track.Name)
        local animId = tostring(track.Animation and track.Animation.AnimationId or "")
        
        local isPortalF = string.find(animName, "portal") or string.find(animName, "teleport") or string.find(animName, "warp") or string.find(animName, "door") or string.find(animName, "world")
        local isSoru = isFlashstep(track)

        if PortalSoruEnabled and isSoru then
            task.spawn(doPortalCombo)
        end
        
        if PortalSanguineCEnabled then
            if (PortalSanguineCTriggerMode == "PortalF" and isPortalF) or (PortalSanguineCTriggerMode == "Soru" and isSoru) then
                task.spawn(doPortalSanguineCCombo)
            end
        end
    end)
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        if PortalSanguineCEnabled and PortalSanguineCTriggerMode == "PortalF" then
            if isHoldingPortalFruit() then
                task.spawn(doPortalSanguineCCombo)
            end
        end
    end
end)

player.CharacterAdded:Connect(monitorCharPortal)
if player.Character then monitorCharPortal(player.Character) end

-- ============================================================
-- ANTI LAVA
-- ============================================================
antiLavaActive = false
antiLavaConnection = nil

function startAntiLava()
    if antiLavaConnection then antiLavaConnection:Disconnect() end
    local antiLavaTimer = 0
    antiLavaConnection = RunService.Stepped:Connect(function(_, dt)
        antiLavaTimer = antiLavaTimer + dt
        if antiLavaTimer < 0.2 then return end
        antiLavaTimer = 0
        local char = player.Character
        if not (char and antiLavaActive) then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart"
            and part.Name ~= "Torso" and part.Name ~= "UpperTorso"
            and part.Name ~= "LowerTorso" and part.Name ~= "Head" then
                part.CanTouch = false
            end
        end
    end)
end

function stopAntiLava()
    if antiLavaConnection then antiLavaConnection:Disconnect(); antiLavaConnection = nil end
end

-- ============================================================
-- DELETE GHOST SHIP
-- ============================================================
deleteShipActive = false
deleteShipRunning = false

function deleteShipStructure()
    if not deleteShipActive then return end
    task.spawn(function()
        local shipNames = {"CursedShip","Cursed Ship","Ship"}
        local exteriorNames = {"Wall","Floor","Ceiling","Base","Hull","Window","DoorFrame"}
        for _, obj in pairs(workspace:GetDescendants()) do
            for _, sName in pairs(shipNames) do
                if obj.Name:find(sName) and (obj:IsA("Model") or obj:IsA("Folder")) then
                    for _, child in pairs(obj:GetDescendants()) do
                        if child:IsA("BasePart") and not child.Parent:FindFirstChild("Humanoid") then
                            local isExterior = false
                            for _, ext in pairs(exteriorNames) do
                                if child.Name:find(ext) then isExterior = true; break end
                            end
                            if not isExterior then child:Destroy() end
                        end
                    end
                end
            end
        end
    end)
end

function startDeleteShipLoop()
    if deleteShipRunning then return end
    deleteShipRunning = true
    task.spawn(function()
        while deleteShipActive do
            deleteShipStructure()
            task.wait(3)
        end
        deleteShipRunning = false
    end)
end

-- ============================================================
-- WALK ON WATER
-- ============================================================
WalkOnWaterEnabled = false

spawn(function()
    local waterPart = nil
    local function getWaterPart()
        if not waterPart or not waterPart.Parent then
            waterPart = Instance.new("Part")
            waterPart.Size = Vector3.new(200, 1, 200)
            waterPart.Transparency = 1
            waterPart.Anchored = true
            waterPart.CanCollide = false
            waterPart.Name = "RitualWaterPlatform"
            waterPart.Parent = workspace
        end
        return waterPart
    end
    while true do
        wait(0.15)
        if WalkOnWaterEnabled then
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            local wp = getWaterPart()
            if hrp and hrp.Position.Y >= 9.5 then
                wp.Position = Vector3.new(hrp.Position.X, 9.2, hrp.Position.Z)
                wp.CanCollide = true
            else
                wp.CanCollide = false
            end
        elseif waterPart and waterPart.Parent then
            waterPart.CanCollide = false
        end
    end
end)

-- ============================================================
-- SMART AUTO V4
-- ============================================================
SmartAutoV4Enabled = false

spawn(function()
    while true do
        wait(1)
        if SmartAutoV4Enabled then
            pcall(function()
                local char = player.Character
                if char and char:GetAttribute("RaceEnergy") and char:GetAttribute("RaceEnergy") >= 100 then
                    local awakening = player.Backpack:FindFirstChild("Awakening")
                    if awakening and awakening:FindFirstChild("RemoteFunction") then
                        awakening.RemoteFunction:InvokeServer(true)
                    end
                end
            end)
        end
    end
end)

-- ============================================================
-- ESP DE ALTO RENDIMIENTO
-- ============================================================
_G.G_ESPEnabled       = false
_G.G_ESP_Name         = true
_G.G_ESP_Level        = true
_G.G_ESP_Bounty       = true
_G.G_ESP_Fruit        = true
_G.G_ESP_Distance     = true
_G.G_ESP_HP           = true
_G.G_ESP_TextSize     = 12
_G.G_ESP_Highlight    = false
_G.G_ESP_HighlightColor = "FFD700"

local ESPRunning = false
local espObjects = {}
local lastESPUpdate = 0
local ESP_UPDATE_INTERVAL = 0.1
local playerCache = {}

function getTeamInfo(targetP)
    if not targetP or not targetP.Team then
        return "Unknown", Color3.fromRGB(255,255,255)
    end
    if targetP.Team.Name == "Marines" then
        return "Marines", Color3.fromRGB(0,170,255)
    else
        return "Pirates", Color3.fromRGB(255,70,70)
    end
end

function hexToColor3(hex)
    local r = tonumber(hex:sub(1,2), 16) / 255 or 0
    local g = tonumber(hex:sub(3,4), 16) / 255 or 1
    local b = tonumber(hex:sub(5,6), 16) / 255 or 0
    return Color3.new(r, g, b)
end

function removeESP(targetP)
    if espObjects[targetP] then
        pcall(function()
            if espObjects[targetP].gui then espObjects[targetP].gui:Destroy() end
            if espObjects[targetP].highlight then espObjects[targetP].highlight:Destroy() end
        end)
        espObjects[targetP] = nil
    end
end

function createESP(targetP)
    if not targetP or targetP == player then return end
    local char = targetP.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    local team, color = getTeamInfo(targetP)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "RitualESP_Billboard"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 200, 0, 75)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextScaled = false
    text.TextSize = _G.G_ESP_TextSize or 12
    text.RichText = true
    text.Font = Enum.Font.SourceSansBold
    text.TextStrokeTransparency = 0
    text.TextColor3 = color
    text.Parent = billboard

    local highlight = nil
    if _G.G_ESP_Highlight then
        local hlColor = hexToColor3(_G.G_ESP_HighlightColor or "FFD700")
        highlight = Instance.new("Highlight")
        highlight.Name = "ESP_PlayerHighlight"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = hlColor
        highlight.FillTransparency = 0.3
        highlight.OutlineColor = hlColor
        highlight.OutlineTransparency = 0
        highlight.Parent = char
    end

    espObjects[targetP] = {
        gui = billboard,
        label = text,
        char = char,
        highlight = highlight
    }
end

function getPlayerData(targetP)
    if not playerCache[targetP] then
        playerCache[targetP] = {
            level = "?",
            fruit = "None",
            bounty = 0,
            team = "Unknown",
            color = Color3.fromRGB(255, 255, 255),
            lastUpdate = 0
        }
    end
    local data = playerCache[targetP]
    local now = tick()
    if now - data.lastUpdate > 5 then
        pcall(function() data.level = targetP.Data.Level.Value end)
        pcall(function() data.fruit = targetP.Data.DevilFruit.Value end)
        pcall(function() data.bounty = targetP.leaderstats["Bounty/Honor"].Value end)
        data.team, data.color = getTeamInfo(targetP)
        data.lastUpdate = now
    end
    return data
end

function updateESP()
    if not _G.G_ESPEnabled then
        DisableESP()
        return
    end
    local anySubActive = _G.G_ESP_Name or _G.G_ESP_Level or _G.G_ESP_Bounty or _G.G_ESP_Fruit or _G.G_ESP_Distance or _G.G_ESP_HP or _G.G_ESP_Highlight
    if not anySubActive then
        DisableESP()
        return
    end

    local now = tick()
    if now - lastESPUpdate < ESP_UPDATE_INTERVAL then return end
    lastESPUpdate = now

    local myChar = player.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local myPos = myRoot.Position

    for _, targetP in ipairs(Players:GetPlayers()) do
        if targetP ~= player then
            local char = targetP.Character
            local head = char and char:FindFirstChild("Head")
            local data = espObjects[targetP]
            if char and head then
                if not data or data.char ~= char or not data.gui.Parent then
                    removeESP(targetP)
                    createESP(targetP)
                    data = espObjects[targetP]
                end

                if data then
                    local hum = char:FindFirstChild("Humanoid")
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if hum and root then
                        local distance = math.floor((root.Position - myPos).Magnitude)
                        local hp = math.floor((hum.Health / math.max(hum.MaxHealth, 1)) * 100)
                        local pData = getPlayerData(targetP)
                        local level = pData.level
                        local fruit = pData.fruit
                        local bounty = pData.bounty
                        local team = pData.team
                        local color = pData.color

                        local warnTag = ""
                        if type(bounty) == "number" and bounty > 10000000 then
                            warnTag = "⚠ "
                        end
                        local pvpState = "PVP Enabled "
                        local pvpIcon = "🔴 "
                        local isPvpDisabled = false
                        if targetP:GetAttribute("PvpDisabled") == true then
                            pvpState = "PvP Disabled "
                            pvpIcon = "🟢 "
                            isPvpDisabled = true
                        end

                        data.label.TextColor3 = color
                        if data.label.TextSize ~= _G.G_ESP_TextSize then
                            data.label.TextSize = _G.G_ESP_TextSize or 12
                        end

                        local parts = {}
                        if _G.G_ESP_Name then parts[#parts+1] = warnTag .. "[" .. team .. "] <font color=\"rgb(255,215,0)\">" .. targetP.Name .. "</font>" end
                        if _G.G_ESP_Level then parts[#parts+1] = " [Lv." .. level .. "]" end
                        if _G.G_ESP_Bounty then 
                            local bM = type(bounty) == "number" and math.floor(bounty / 1000000) or 0
                            if isPvpDisabled then
                                parts[#parts+1] = "\n<font color=\"rgb(0,255,0)\">" .. pvpIcon .. pvpState .. "</font> | Bounty: " .. bM .. "M\n"
                            else
                                parts[#parts+1] = "\n" .. pvpIcon .. pvpState .. "| Bounty: " .. bM .. "M\n"
                            end
                        end
                        if _G.G_ESP_Fruit then parts[#parts+1] = "Fruit: " .. tostring(fruit) .. "\n" end
                        if _G.G_ESP_Distance then parts[#parts+1] = distance .. "m | " end
                        if _G.G_ESP_HP then parts[#parts+1] = "HP " .. hp .. "%" end
                        data.label.Text = table.concat(parts)

                        if _G.G_ESP_Highlight then
                            local hlColor = hexToColor3(_G.G_ESP_HighlightColor or "FFD700")
                            pcall(function()
                                for _, child in ipairs(char:GetChildren()) do
                                    if child:IsA("Highlight") and child.Name ~= "ESP_PlayerHighlight" then
                                        child.FillColor = hlColor
                                        child.OutlineColor = hlColor
                                        child.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    end
                                end
                            end)
                            if not data.highlight or not data.highlight.Parent then
                                local hl = Instance.new("Highlight")
                                hl.Name = "ESP_PlayerHighlight"
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                hl.FillColor = hlColor
                                hl.FillTransparency = 0.3
                                hl.OutlineColor = hlColor
                                hl.OutlineTransparency = 0
                                hl.Parent = char
                                data.highlight = hl
                            else
                                data.highlight.FillColor = hlColor
                                data.highlight.OutlineColor = hlColor
                                data.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            end
                        else
                            if data.highlight then
                                data.highlight:Destroy()
                                data.highlight = nil
                            end
                        end
                    end
                end
            else
                if data then removeESP(targetP) end
            end
        end
    end
end

function EnableESP()
    if ESPRunning then return end
    ESPRunning = true
    for _, targetP in ipairs(Players:GetPlayers()) do
        createESP(targetP)
    end
    task.spawn(function()
        while ESPRunning do
            pcall(updateESP)
            task.wait(ESP_UPDATE_INTERVAL)
        end
    end)
end

function DisableESP()
    ESPRunning = false
    for targetP, _ in pairs(espObjects) do
        removeESP(targetP)
    end
    espObjects = {}
end
ClearESP = DisableESP

if not _G.ESP_Initialized then
    _G.ESP_Initialized = true
    Players.PlayerRemoving:Connect(function(targetP)
        removeESP(targetP)
        playerCache[targetP] = nil
    end)
end

-- ============================================================
-- SORU INFINITO
-- ============================================================
function enforceSoru(char)
    if not char then return end
    if SoruInfinitoEnabled then char:SetAttribute("FlashstepCooldown", 1) end
    char.AttributeChanged:Connect(function(attr)
        if attr == "FlashstepCooldown" and SoruInfinitoEnabled and char:GetAttribute("FlashstepCooldown") ~= 1 then
            char:SetAttribute("FlashstepCooldown", 1)
        end
    end)
end

player.CharacterAdded:Connect(enforceSoru)
if player.Character then enforceSoru(player.Character) end

spawn(function()
    while true do
        wait(0.5)
        if SoruInfinitoEnabled and player.Character then
            pcall(function() player.Character:SetAttribute("FlashstepCooldown", 1) end)
        end
    end
end)

-- ============================================================
-- NO ANIMATIONS
-- ============================================================
NoAnimEnabled = false
NoAnimConnection = nil

function StartNoAnimLoop()
    if NoAnimConnection then NoAnimConnection:Disconnect() end
    NoAnimConnection = RunService.Stepped:Connect(function()
        if not NoAnimEnabled then return end
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum then return end
        hum.AutoRotate = true 
        local animator = hum:FindFirstChild("Animator")
        if not animator then return end
        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
            if not isAttackAnim(track) then
                track:Stop(0)
            end
        end
    end)
end

-- ============================================================
-- SANGUINE Z AUTO
-- ============================================================
sanguineLagBusy = false
function dropFPS(duration)
    if sanguineLagBusy then return end
    sanguineLagBusy = true
    local DROP_TO_FPS = 20
    local stop = tick() + duration
    local interval = 1 / DROP_TO_FPS
    local con
    con = RunService.RenderStepped:Connect(function()
        if tick() > stop then
            if con then con:Disconnect() end
            sanguineLagBusy = false
            return
        end
        local now = tick()
        while tick() - now < interval do end
    end)
end

function dropFPSManual()
    if sanguineLagBusy then return end
    sanguineLagBusy = true
    local DROP_TO_FPS = 20
    local LAG_DURATION = 0.43
    local stop = tick() + LAG_DURATION
    local interval = 1 / DROP_TO_FPS
    local con
    con = RunService.RenderStepped:Connect(function()
        if tick() > stop then
            if con then con:Disconnect() end
            return
        end
        local now = tick()
        while tick() - now < interval do end
    end)
    local char = player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local dir = camera.CFrame.LookVector
            local att = Instance.new("Attachment")
            att.Parent = hrp
            local lv = Instance.new("LinearVelocity")
            lv.MaxForce = math.huge
            lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
            lv.VectorVelocity = dir * 400
            lv.Attachment0 = att
            lv.Parent = hrp
            task.delay(0.9, function()
                if lv and lv.Parent then lv:Destroy() end
                if att and att.Parent then att:Destroy() end
            end)
        end
    end
    task.wait(0.10)
    sanguineLagBusy = false
end

function startSanguineAutoWatcher()
    if SanguineAutoConnection then SanguineAutoConnection:Disconnect() end
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end

    SanguineAutoConnection = hum.AnimationPlayed:Connect(function(animTrack)
        if not SanguineAutoEnabled or SanguineAutoCooldown then return end
        
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool or not (string.find(string.lower(tool.Name), "sanguine") or string.find(string.lower(tool.Name), "art")) then
            return
        end

        local animId = tostring(animTrack.Animation and animTrack.Animation.AnimationId or "")
        if animId:find("14586872029") or animId:find("14418367908") or animId:find("14418370048") then
            SanguineAutoCooldown = true
            dropFPS(SanguineAutoDropDuration)
            local char2 = player.Character
            if char2 then
                local hrp2 = char2:FindFirstChild("HumanoidRootPart")
                if hrp2 then
                    local dir2 = camera.CFrame.LookVector
                    local att2 = Instance.new("Attachment")
                    att2.Parent = hrp2
                    local lv2 = Instance.new("LinearVelocity")
                    lv2.MaxForce = math.huge
                    lv2.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
                    lv2.VectorVelocity = dir2 * 400
                    lv2.Attachment0 = att2
                    lv2.Parent = hrp2
                    task.delay(0.9, function()
                        if lv2 and lv2.Parent then lv2:Destroy() end
                        if att2 and att2.Parent then att2:Destroy() end
                    end)
                end
            end
            task.delay(SanguineAutoDropDuration + 0.5, function()
                SanguineAutoCooldown = false
            end)
        end
    end)
end

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if SanguineAutoEnabled then
        startSanguineAutoWatcher()
    end
end)

-- ============================================================
-- TARGET HELPERS
-- ============================================================
function getClosestPlayer(overrideMaxDist)
    local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end

    local searchDist = overrideMaxDist or soruMaxDist or 3500

    if AimlockTargetPlayer ~= "Nearest" and AimlockTargetPlayer ~= nil then
        local targetP = Players:FindFirstChild(AimlockTargetPlayer)
        if targetP and targetP.Character and targetP.Character:FindFirstChild("HumanoidRootPart") then
            local hum = targetP.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then return targetP.Character end
        end
    end

    local closest, closestDist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and not BlacklistedPlayers[p.Name] and p:GetAttribute("PvpDisabled") ~= true and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local dist = (p.Character.HumanoidRootPart.Position - myHrp.Position).Magnitude
                if dist < closestDist and dist <= searchDist then
                    closestDist = dist
                    closest = p.Character
                end
            end
        end
    end
    return closest
end

function getClosestNPC()
    local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end
    local container = workspace:FindFirstChild("Enemies") or workspace
    local closest, closestDist = nil, math.huge
    for _, npc in pairs(container:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(npc) then
            local hum = npc:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local dist = (npc.HumanoidRootPart.Position - myHrp.Position).Magnitude
                if dist < closestDist and dist < maxRange then
                    closestDist = dist
                    closest = npc
                end
            end
        end
    end
    return closest
end

-- ============================================================
-- AIMLOCK PLAYER & NPC
-- ============================================================
_G.lockedPlayerTarget = nil
_G.lockedNpcTarget = nil

RunService.RenderStepped:Connect(function()
    if PlayerWidgetActive and AimlockPlayerEnabled then
        if not _G.lockedPlayerTarget or not _G.lockedPlayerTarget:FindFirstChild("HumanoidRootPart") then
            _G.lockedPlayerTarget = getClosestPlayer()
        end
        local targetChar = _G.lockedPlayerTarget
        if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
            local hum = targetChar:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local targetPos = targetChar.HumanoidRootPart.Position + Vector3.new(0, 0.5, 0)
                camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, targetPos), 0.4)
            else
                _G.lockedPlayerTarget = nil
            end
        else
            _G.lockedPlayerTarget = nil
        end
    else
        _G.lockedPlayerTarget = nil
    end

    if NpcWidgetActive and AimlockNpcEnabled then
        if not _G.lockedNpcTarget or not _G.lockedNpcTarget:FindFirstChild("HumanoidRootPart") then
            _G.lockedNpcTarget = getClosestNPC()
        end
        local targetNPC = _G.lockedNpcTarget
        if targetNPC and targetNPC:FindFirstChild("HumanoidRootPart") then
            local hum = targetNPC:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local targetPos = targetNPC.HumanoidRootPart.Position + Vector3.new(0, 0.5, 0)
                camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, targetPos), 0.4)
            else
                _G.lockedNpcTarget = nil
            end
        else
            _G.lockedNpcTarget = nil
        end
    else
        _G.lockedNpcTarget = nil
    end
end)

-- ============================================================
-- VISUALS & EFFECTS
-- ============================================================
function applyFakeKorblox(char)
    if not char then return end
    pcall(function()
        local rUpper = char:FindFirstChild("RightUpperLeg")
        local rLower = char:FindFirstChild("RightLowerLeg")
        local rFoot = char:FindFirstChild("RightFoot")
        if rUpper and rUpper:IsA("BasePart") then rUpper.Transparency = 1 end
        if rLower and rLower:IsA("BasePart") then rLower.Transparency = 1 end
        if rFoot and rFoot:IsA("BasePart") then rFoot.Transparency = 1 end
    end)
end

function removeFakeKorblox(char)
    if not char then return end
    pcall(function()
        local rUpper = char:FindFirstChild("RightUpperLeg")
        local rLower = char:FindFirstChild("RightLowerLeg")
        local rFoot = char:FindFirstChild("RightFoot")
        if rUpper and rUpper:IsA("BasePart") then rUpper.Transparency = 0 end
        if rLower and rLower:IsA("BasePart") then rLower.Transparency = 0 end
        if rFoot and rFoot:IsA("BasePart") then rFoot.Transparency = 0 end
    end)
end

function applyFakeHeadless(char)
    if not char then return end
    pcall(function()
        local head = char:FindFirstChild("Head")
        if head then
            head.Transparency = 1
            for _, child in pairs(head:GetChildren()) do
                if child:IsA("Decal") or child:IsA("Texture") then child.Transparency = 1 end
            end
        end
        for _, acc in pairs(char:GetChildren()) do
            if acc:IsA("Accessory") then
                local handle = acc:FindFirstChild("Handle")
                if handle and handle:IsA("BasePart") then
                    local isHeadAcc = false
                    for _, child in pairs(handle:GetChildren()) do
                        if child:IsA("Attachment") then
                            local aName = string.lower(child.Name)
                            if string.find(aName, "hat") or string.find(aName, "hair") or string.find(aName, "face") or string.find(aName, "head") then
                                isHeadAcc = true
                                break
                            end
                        end
                    end
                    if not isHeadAcc then
                        for _, weld in pairs(handle:GetChildren()) do
                            if weld:IsA("Weld") or weld:IsA("Motor6D") or weld:IsA("WeldConstraint") then
                                if weld.Part0 == head or weld.Part1 == head then
                                    isHeadAcc = true
                                    break
                                end
                            end
                        end
                    end
                    if isHeadAcc or acc.AccessoryType == Enum.AccessoryType.Hat or acc.AccessoryType == Enum.AccessoryType.Hair or acc.AccessoryType == Enum.AccessoryType.Face or acc.AccessoryType == Enum.AccessoryType.Unknown then
                        handle.Transparency = 1
                        for _, sub in pairs(handle:GetDescendants()) do
                            if sub:IsA("BasePart") or sub:IsA("MeshPart") or sub:IsA("Decal") or sub:IsA("Texture") then
                                sub.Transparency = 1
                            end
                        end
                    end
                end
            end
        end
    end)
end

function removeFakeHeadless(char)
    if not char then return end
    pcall(function()
        local head = char:FindFirstChild("Head")
        if head then
            head.Transparency = 0
            for _, child in pairs(head:GetChildren()) do
                if child:IsA("Decal") or child:IsA("Texture") then child.Transparency = 0 end
            end
        end
        for _, acc in pairs(char:GetChildren()) do
            if acc:IsA("Accessory") then
                local handle = acc:FindFirstChild("Handle")
                if handle and handle:IsA("BasePart") then
                    handle.Transparency = 0
                    for _, sub in pairs(handle:GetDescendants()) do
                        if sub:IsA("BasePart") or sub:IsA("MeshPart") or sub:IsA("Decal") or sub:IsA("Texture") then
                            sub.Transparency = 0
                        end
                    end
                end
            end
        end
    end)
end

AURA_DEFS = {
    Inferno = {
        Color = ColorSequence.new(Color3.fromRGB(255, 80, 0), Color3.fromRGB(255, 0, 0)),
        LightColor = Color3.fromRGB(255, 80, 0),
        Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(0.5, 2.5), NumberSequenceKeypoint.new(1, 0)}),
        Rate = 80,
        Speed = NumberRange.new(3, 8),
        Lifetime = NumberRange.new(0.5, 1.2),
        SpreadAngle = Vector2.new(25, 25),
        LightEmission = 1,
        RotSpeed = NumberRange.new(-90, 90),
        Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1)}),
    },
    Electric = {
        Color = ColorSequence.new(Color3.fromRGB(0, 170, 255), Color3.fromRGB(100, 200, 255)),
        LightColor = Color3.fromRGB(0, 170, 255),
        Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(0.3, 1.8), NumberSequenceKeypoint.new(1, 0)}),
        Rate = 100,
        Speed = NumberRange.new(5, 15),
        Lifetime = NumberRange.new(0.2, 0.5),
        SpreadAngle = Vector2.new(180, 180),
        LightEmission = 1,
        RotSpeed = NumberRange.new(-360, 360),
        Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1)}),
    },
    DarkSpirit = {
        Color = ColorSequence.new(Color3.fromRGB(100, 0, 180), Color3.fromRGB(50, 0, 100)),
        LightColor = Color3.fromRGB(100, 0, 180),
        Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 3), NumberSequenceKeypoint.new(1, 0)}),
        Rate = 40,
        Speed = NumberRange.new(1, 3),
        Lifetime = NumberRange.new(1, 2.5),
        SpreadAngle = Vector2.new(40, 40),
        LightEmission = 0.6,
        RotSpeed = NumberRange.new(-45, 45),
        Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 1)}),
    },
    Toxic = {
        Color = ColorSequence.new(Color3.fromRGB(0, 255, 80), Color3.fromRGB(80, 255, 0)),
        LightColor = Color3.fromRGB(0, 255, 80),
        Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(0.5, 2), NumberSequenceKeypoint.new(1, 0)}),
        Rate = 60,
        Speed = NumberRange.new(2, 5),
        Lifetime = NumberRange.new(0.8, 1.5),
        SpreadAngle = Vector2.new(30, 30),
        LightEmission = 0.8,
        RotSpeed = NumberRange.new(-60, 60),
        Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1)}),
    },
    Frost = {
        Color = ColorSequence.new(Color3.fromRGB(200, 230, 255), Color3.fromRGB(150, 200, 255)),
        LightColor = Color3.fromRGB(180, 220, 255),
        Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(0.5, 1.5), NumberSequenceKeypoint.new(1, 0)}),
        Rate = 50,
        Speed = NumberRange.new(1, 3),
        Lifetime = NumberRange.new(1, 2),
        SpreadAngle = Vector2.new(50, 50),
        LightEmission = 0.7,
        RotSpeed = NumberRange.new(-30, 30),
        Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1)}),
    },
}

function ClearAura()
    for _, obj in pairs(AuraObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    AuraObjects = {}
end

function ApplyAura(auraName)
    ClearAura()
    if not auraName then ActiveAura = nil; return end
    local def = AURA_DEFS[auraName]
    if not def then ActiveAura = nil; return end
    ActiveAura = auraName
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    pcall(function()
        local emitter = Instance.new("ParticleEmitter")
        emitter.Name = "RitualAura"
        emitter.Texture = "rbxassetid://243098098"
        emitter.Color = def.Color
        emitter.Size = def.Size
        emitter.Rate = def.Rate
        emitter.Speed = def.Speed
        emitter.Lifetime = def.Lifetime
        emitter.SpreadAngle = def.SpreadAngle
        emitter.LightEmission = def.LightEmission
        emitter.RotSpeed = def.RotSpeed
        emitter.Transparency = def.Transparency
        emitter.Parent = hrp
        table.insert(AuraObjects, emitter)
        local light = Instance.new("PointLight")
        light.Name = "RitualAuraLight"
        light.Color = def.LightColor
        light.Brightness = 2
        light.Range = 15
        light.Parent = hrp
        table.insert(AuraObjects, light)
    end)
end

player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if FakeKorbloxEnabled then applyFakeKorblox(char) end
    if FakeHeadlessEnabled then applyFakeHeadless(char) end
    if ActiveAura then ApplyAura(ActiveAura) end
end)

-- ============================================================
-- FPS / PING MONITORING
-- ============================================================
spawn(function()
    local frameCount = 0
    local lastTime = tick()
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
    end)
    while true do
        wait(1)
        local now = tick()
        local elapsed = now - lastTime
        currentFPS = math.floor(frameCount / elapsed)
        frameCount = 0
        lastTime = now
        pcall(function()
            currentPing = math.floor(player:GetNetworkPing() * 1000)
        end)
    end
end)

function performExtendedSoru(targetPos)
    if not targetPos then return end
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local currentPos = hrp.Position
    local fullDist = (targetPos - currentPos).Magnitude

    if fullDist <= 950 then
        pcall(function()
            local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
            if commF then
                commF:InvokeServer("Flashstep", targetPos)
            else
                hrp.CFrame = CFrame.new(targetPos)
            end
        end)
    else
        local steps = math.ceil(fullDist / 900)
        local dir = (targetPos - currentPos).Unit
        for i = 1, steps do
            local nextDist = math.min(i * 900, fullDist)
            local nextPos = currentPos + (dir * nextDist)
            pcall(function()
                local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                if commF then
                    commF:InvokeServer("Flashstep", nextPos)
                else
                    hrp.CFrame = CFrame.new(nextPos)
                end
            end)
            task.wait(0.015)
        end
    end
end

-- ============================================================
-- SILENT AIM WITH FOV CIRCLE (SKILLS LOCK ON TO TARGETS IN FOV)
-- ============================================================
local oldIndex = nil
local oldNamecall = nil

local currentSilentAimTarget = nil

function IsSilentAimAlly(p)
    local main = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("Main")
    local frame = main and main:FindFirstChild("Allies")
        and main.Allies:FindFirstChild("Container")
        and main.Allies.Container:FindFirstChild("Allies")
        and main.Allies.Container.Allies:FindFirstChild("ScrollingFrame")
        and main.Allies.Container.Allies.ScrollingFrame:FindFirstChild("Frame")
    if not frame then return false end
    return frame:FindFirstChild(p.Name) ~= nil
end

function IsSilentAimEnemy(p)
    if not p or p == player then return false end
    if IsSilentAimAlly(p) then return false end
    local myTeam, targetTeam = player.Team, p.Team
    if myTeam and targetTeam and myTeam.Name == "Marines" and targetTeam.Name == "Marines" then
        return false
    end
    return true
end

function AX_ReadPvPState(target)
    local ok, on = pcall(function()
        local attr = target:GetAttribute("PvpDisabled")
        if attr ~= nil then return attr ~= true end
        local main = target.PlayerGui and target.PlayerGui:FindFirstChild("Main")
        if main then
            local dis = main:FindFirstChild("PvpDisabled")
            if dis then return not dis.Visible end
            local pvp = main:FindFirstChild("Pvp")
            if pvp then
                local frame = pvp:FindFirstChild("Frame")
                if frame then
                    local btn = frame:FindFirstChild("PvpButton") or frame:FindFirstChildOfClass("TextButton")
                    if btn and btn:IsA("TextButton") then
                        local txt = tostring(btn.Text or ""):upper()
                        if txt:find("OFF") then return false end
                        if txt:find("ON") then return true end
                    end
                end
            end
        end
        return true
    end)
    return not ok or on
end

function AX_InSafeZone(target)
    local ok, inZone = pcall(function()
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

        local spawns = wo:FindFirstChild("PlayerSpawns")
        if spawns then
            local folder = spawns:FindFirstChild(tostring(target.Team)) or spawns:FindFirstChild("Pirates")
            if folder then
                for _, sp in pairs(folder:GetChildren()) do
                    local part = sp:FindFirstChild("Part")
                    if part and (hrp.Position - part.Position).Magnitude <= 400 then
                        return true
                    end
                end
            end
        end
        return false
    end)
    return ok and inZone
end

_G.G_AimbotSafeZoneCheck = true
_G.G_AimbotPvPCheck = true

function GetClosestTargetInFOV()
    local myChar = player.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    local maxDist3D = maxRange or 3500
    local fovRadius = _G.G_SilentAimFOV or 150
    
    local cam = workspace.CurrentCamera
    local viewportSize = cam and cam.ViewportSize
    if not viewportSize then return nil end

    if _G.G_SilentAimSelectedPlayer and _G.G_SilentAimSelectedPlayer ~= "" and _G.G_SilentAimSelectedPlayer ~= "Nearest" then
        local targetP = Players:FindFirstChild(_G.G_SilentAimSelectedPlayer)
        if targetP and targetP ~= player and targetP.Character and not BlacklistedPlayers[targetP.Name] then
            if _G.G_AimbotPvPCheck and not AX_ReadPvPState(targetP) then return nil end
            if _G.G_AimbotSafeZoneCheck and AX_InSafeZone(targetP) then return nil end
            if not _G.G_SilentAimTeamCheck or IsSilentAimEnemy(targetP) then
                local hum = targetP.Character:FindFirstChildOfClass("Humanoid")
                local hrp = targetP.Character:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and hrp then
                    return targetP.Character:FindFirstChild(_G.G_SilentAimPart) or hrp
                end
            end
        end
        return nil
    end

    local closestPart = nil
    local shortestDist = maxDist3D
    local shortestScreenDist = math.huge

    local function checkTargetPart(character)
        if not character or character == myChar then return end

        local p = Players:GetPlayerFromCharacter(character)
        if p then
            if p == player or BlacklistedPlayers[p.Name] then return end
            if _G.G_AimbotPvPCheck and not AX_ReadPvPState(p) then return end
            if _G.G_AimbotSafeZoneCheck and AX_InSafeZone(p) then return end
            if _G.G_SilentAimTeamCheck and not IsSilentAimEnemy(p) then return end
        end

        local hum = character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local part = character:FindFirstChild(_G.G_SilentAimPart) or character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
        if not part then return end

        local worldDist = (part.Position - myHRP.Position).Magnitude
        if worldDist > shortestDist then return end

        -- Check if target is within FOV
        local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
        if not onScreen then return end
        
        local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        
        if screenDist <= fovRadius then
            if screenDist < shortestScreenDist then
                shortestScreenDist = screenDist
                shortestDist = worldDist
                closestPart = part
            end
        end
    end

    local wantPlayers = _G.G_SilentAimTargetPlayers
    local wantMobs = _G.G_SilentAimTargetMobs

    if wantPlayers then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                checkTargetPart(p.Character)
            end
        end
    end

    if wantMobs then
        local enemies = workspace:FindFirstChild("Enemies")
        if enemies then
            for _, enemy in ipairs(enemies:GetChildren()) do
                checkTargetPart(enemy)
            end
        end
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj ~= myChar and obj:FindFirstChildOfClass("Humanoid") then
                checkTargetPart(obj)
            end
        end
    end

    return closestPart
end

-- Update FOV Circle position and visibility
RunService.RenderStepped:Connect(function()
    pcall(function()
        if FOVCircle then
            local cam = workspace.CurrentCamera
            if cam then
                local viewportSize = cam.ViewportSize
                FOVCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
                FOVCircle.Radius = _G.G_SilentAimFOV or 150
                FOVCircle.Visible = _G.G_SilentAimShowFOV and _G.G_SilentAimSkill
            end
        end
        
        -- Update target
        if _G.G_SilentAimSkill then
            currentSilentAimTarget = GetClosestTargetInFOV()
        else
            currentSilentAimTarget = nil
        end
    end)
end)

-- Metamethod hooks for Silent Aim
if hookmetamethod then
    pcall(function()
        oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
            if not checkcaller() then
                if self == mouse and (key == "Hit" or key == "Target") then
                    if _G.G_SilentAimSkill and currentSilentAimTarget then
                        if key == "Hit" then return CFrame.new(currentSilentAimTarget.Position) end
                        if key == "Target" then return currentSilentAimTarget end
                    end
                end
            end
            return oldIndex(self, key)
        end))
    end)

    pcall(function()
        oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local args = {...}
            local ncm = getnamecallmethod and getnamecallmethod()
            local method = ncm and tostring(ncm):lower() or ""

            if not checkcaller() then
                if (method == "fireserver" or method == "invokeserver") then
                    if _G.G_SilentAimSkill and currentSilentAimTarget then
                        local activePos = currentSilentAimTarget.Position

                        if self.Name == "RE/RegisterHit" or self.Name == "RegisterHit" or self.Name:find("RegisterHit") then
                            local targetChar = currentSilentAimTarget.Parent
                            local targetHead = targetChar and (targetChar:FindFirstChild("Head") or targetChar:FindFirstChild("HumanoidRootPart")) or currentSilentAimTarget
                            if targetHead and targetChar then
                                args[1] = targetHead
                                args[2] = { { targetChar, targetHead } }
                                return oldNamecall(self, unpack(args))
                            end
                        end

                        if self.Name == "RE/ShootGunEvent" or self.Name == "ShootGunEvent" or self.Name:find("ShootGunEvent") then
                            args[1] = activePos
                            if currentSilentAimTarget.Parent then
                                args[2] = { currentSilentAimTarget.Parent }
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
                elseif (method == "raycast" or method == "findpartonray" or method == "findpartonraywithignorelist" or method == "findpartonraywithwhitelist") then
                    if _G.G_SilentAimSkill and currentSilentAimTarget then
                        if method == "raycast" then
                            return {
                                Instance = currentSilentAimTarget,
                                Position = currentSilentAimTarget.Position,
                                Hit = currentSilentAimTarget.Position,
                                Normal = Vector3.new(0, 1, 0),
                                Material = Enum.Material.SmoothPlastic
                            }
                        else
                            return currentSilentAimTarget, currentSilentAimTarget.Position, Vector3.new(0, 1, 0), Enum.Material.SmoothPlastic
                        end
                    end
                end
            end

            return oldNamecall(self, ...)
        end))
    end)
else
    pcall(function()
        local mt = getrawmetatable and getrawmetatable(game)
        if mt then
            oldIndex = mt.__index
            oldNamecall = mt.__namecall
            if setreadonly then pcall(setreadonly, mt, false) end

            mt.__index = newcclosure(function(self, key)
                if not checkcaller() and self == mouse and (key == "Hit" or key == "Target") then
                    if _G.G_SilentAimSkill and currentSilentAimTarget then
                        if key == "Hit" then return CFrame.new(currentSilentAimTarget.Position) end
                        if key == "Target" then return currentSilentAimTarget end
                    end
                end
                return oldIndex(self, key)
            end)

            mt.__namecall = newcclosure(function(self, ...)
                local args = {...}
                local ncm = getnamecallmethod and getnamecallmethod()
                local method = ncm and tostring(ncm):lower() or ""

                if not checkcaller() and (method == "fireserver" or method == "invokeserver") then
                    if _G.G_SilentAimSkill and currentSilentAimTarget then
                        local activePos = currentSilentAimTarget.Position

                        if self.Name == "RE/RegisterHit" or self.Name == "RegisterHit" or self.Name:find("RegisterHit") then
                            local targetChar = currentSilentAimTarget.Parent
                            local targetHead = targetChar and (targetChar:FindFirstChild("Head") or targetChar:FindFirstChild("HumanoidRootPart")) or currentSilentAimTarget
                            if targetHead and targetChar then
                                args[1] = targetHead
                                args[2] = { { targetChar, targetHead } }
                                return oldNamecall(self, unpack(args))
                            end
                        end

                        if self.Name == "RE/ShootGunEvent" or self.Name == "ShootGunEvent" or self.Name:find("ShootGunEvent") then
                            args[1] = activePos
                            if currentSilentAimTarget.Parent then
                                args[2] = { currentSilentAimTarget.Parent }
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
end

-- ============================================================
-- RITUAL HUB UI | BLACK & GOLD THEME
-- ============================================================
local THEMES = {
    ["Black & Gold"] = GOLD,
}
local currentThemeColor = GOLD
local COLORS = {
    Background = BLACK,
    PanelBG = DARK_BG,
    TextWhite = TEXT_WHITE,
    TextGray = Color3.fromRGB(200, 200, 210),
    ToggleOff = BLACK,
}

local themeStrokes, themeTexts, themeFrames = {}, {}, {}

local parentGui = nil
pcall(function() if gethui then parentGui = gethui() end end)
if not parentGui then
    pcall(function() parentGui = game:GetService("CoreGui") end)
end
if not parentGui and player then
    pcall(function() parentGui = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui", 3) end)
end

local function safeParent(gui)
    if not gui then return end
    local ok = pcall(function() gui.Parent = parentGui end)
    if (not ok or not gui.Parent) and player then
        pcall(function() gui.Parent = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui", 3) end)
    end
end

GuiStore = {
    screenGui = Instance.new("ScreenGui"),
    toggleIconGui = Instance.new("ScreenGui"),
    playerWidgetGui = Instance.new("ScreenGui"),
    npcWidgetGui = Instance.new("ScreenGui"),
    superJumpWidgetGui = Instance.new("ScreenGui"),
    sanguineManualWidgetGui = Instance.new("ScreenGui"),
    sanguineAutoWidgetGui = Instance.new("ScreenGui"),
    soulGuitarWidgetGui = Instance.new("ScreenGui"),
    portalSoruWidgetGui = Instance.new("ScreenGui"),
    grokAIWidgetGui = Instance.new("ScreenGui")
}

GuiStore.screenGui.Name = "RitualUI_UltimateUI"
GuiStore.screenGui.ResetOnSpawn = false
safeParent(GuiStore.screenGui)

GuiStore.toggleIconGui.Name = "RitualUI_ToggleIcon"
GuiStore.toggleIconGui.ResetOnSpawn = false
safeParent(GuiStore.toggleIconGui)

GuiStore.playerWidgetGui.Name = "RitualUI_PlayerWidget"
GuiStore.playerWidgetGui.ResetOnSpawn = false
GuiStore.playerWidgetGui.DisplayOrder = 99999
GuiStore.playerWidgetGui.IgnoreGuiInset = true
safeParent(GuiStore.playerWidgetGui)

GuiStore.npcWidgetGui.Name = "RitualUI_NpcWidget"
GuiStore.npcWidgetGui.ResetOnSpawn = false
GuiStore.npcWidgetGui.DisplayOrder = 99999
GuiStore.npcWidgetGui.IgnoreGuiInset = true
safeParent(GuiStore.npcWidgetGui)

GuiStore.superJumpWidgetGui.Name = "RitualUI_SuperJumpWidget"
GuiStore.superJumpWidgetGui.ResetOnSpawn = false
GuiStore.superJumpWidgetGui.DisplayOrder = 99999
GuiStore.superJumpWidgetGui.IgnoreGuiInset = true
safeParent(GuiStore.superJumpWidgetGui)

GuiStore.sanguineManualWidgetGui.Name = "RitualUI_SanguineManualWidget"
GuiStore.sanguineManualWidgetGui.ResetOnSpawn = false
GuiStore.sanguineManualWidgetGui.DisplayOrder = 99999
GuiStore.sanguineManualWidgetGui.IgnoreGuiInset = true
safeParent(GuiStore.sanguineManualWidgetGui)

GuiStore.sanguineAutoWidgetGui.Name = "RitualUI_SanguineAutoWidget"
GuiStore.sanguineAutoWidgetGui.ResetOnSpawn = false
GuiStore.sanguineAutoWidgetGui.DisplayOrder = 99999
GuiStore.sanguineAutoWidgetGui.IgnoreGuiInset = true
safeParent(GuiStore.sanguineAutoWidgetGui)

GuiStore.soulGuitarWidgetGui.Name = "RitualUI_SoulGuitarWidget"
GuiStore.soulGuitarWidgetGui.ResetOnSpawn = false
GuiStore.soulGuitarWidgetGui.DisplayOrder = 99999
GuiStore.soulGuitarWidgetGui.IgnoreGuiInset = true
safeParent(GuiStore.soulGuitarWidgetGui)

GuiStore.portalSoruWidgetGui.Name = "RitualUI_PortalSoruWidget"
GuiStore.portalSoruWidgetGui.ResetOnSpawn = false
GuiStore.portalSoruWidgetGui.DisplayOrder = 99999
GuiStore.portalSoruWidgetGui.IgnoreGuiInset = true
safeParent(GuiStore.portalSoruWidgetGui)

GuiStore.grokAIWidgetGui.Name = "RitualUI_GrokAIWidget"
GuiStore.grokAIWidgetGui.ResetOnSpawn = false
GuiStore.grokAIWidgetGui.DisplayOrder = 99999
GuiStore.grokAIWidgetGui.IgnoreGuiInset = true
safeParent(GuiStore.grokAIWidgetGui)

local screenGui = GuiStore.screenGui
local toggleIconGui = GuiStore.toggleIconGui
local playerWidgetGui = GuiStore.playerWidgetGui
local npcWidgetGui = GuiStore.npcWidgetGui
local superJumpWidgetGui = GuiStore.superJumpWidgetGui
local sanguineManualWidgetGui = GuiStore.sanguineManualWidgetGui
local sanguineAutoWidgetGui = GuiStore.sanguineAutoWidgetGui
local soulGuitarWidgetGui = GuiStore.soulGuitarWidgetGui
local portalSoruWidgetGui = GuiStore.portalSoruWidgetGui
local grokAIWidgetGui = GuiStore.grokAIWidgetGui

-- ============================================================
-- CREAR WIDGETS FLOTANTES
-- ============================================================
function updateWidgetsVisuals()
    local isLight = isColorLight(currentThemeColor)
    local darkTxt = Color3.fromRGB(15, 10, 20)
    local lightTxt = Color3.fromRGB(255, 255, 255)

    if PlayerWidgetBtn then
        PlayerWidgetBtn.Visible = PlayerWidgetActive
        PlayerWidgetBtn.BackgroundColor3 = AimlockPlayerEnabled and currentThemeColor or BLACK
        PlayerWidgetBtn.BackgroundTransparency = AimlockPlayerEnabled and 0 or 1
        PlayerWidgetBtn.TextColor3 = AimlockPlayerEnabled and (isLight and darkTxt or lightTxt) or lightTxt
        PlayerWidgetBtn.Text = AimlockPlayerEnabled and "🔒 PLAYER: ON" or "🔓 PLAYER: OFF"
    end
    if NpcWidgetBtn then
        NpcWidgetBtn.Visible = NpcWidgetActive
        NpcWidgetBtn.BackgroundColor3 = AimlockNpcEnabled and currentThemeColor or BLACK
        NpcWidgetBtn.BackgroundTransparency = AimlockNpcEnabled and 0 or 1
        NpcWidgetBtn.TextColor3 = AimlockNpcEnabled and (isLight and darkTxt or lightTxt) or lightTxt
        NpcWidgetBtn.Text = AimlockNpcEnabled and "🔒 NPC: ON" or "🔓 NPC: OFF"
    end
    if SuperJumpWidget then
        SuperJumpWidget.Visible = SuperJumpWidgetVisible
        SuperJumpWidget.BackgroundColor3 = currentThemeColor
        SuperJumpWidget.BackgroundTransparency = 0
        SuperJumpWidget.TextColor3 = isLight and darkTxt or lightTxt
        SuperJumpWidget.Text = "⬆ JUMP"
    end
    if SanguineManualWidget then
        SanguineManualWidget.Visible = SanguineManualWidgetVisible
        SanguineManualWidget.BackgroundColor3 = currentThemeColor
        SanguineManualWidget.BackgroundTransparency = 0
        SanguineManualWidget.TextColor3 = isLight and darkTxt or lightTxt
        SanguineManualWidget.Text = "🩸 SANGUINE Z"
    end
    if SanguineAutoWidget then
        SanguineAutoWidget.Visible = SanguineWidgetVisible
        SanguineAutoWidget.BackgroundColor3 = SanguineAutoEnabled and currentThemeColor or BLACK
        SanguineAutoWidget.BackgroundTransparency = SanguineAutoEnabled and 0 or 1
        SanguineAutoWidget.TextColor3 = SanguineAutoEnabled and (isLight and darkTxt or lightTxt) or lightTxt
        SanguineAutoWidget.Text = SanguineAutoEnabled and "🔴 Auto: ON" or "⚫ Auto: OFF"
    end
end

function makeFloatingWidget(parent, pos, title)
    pcall(function()
        parent.DisplayOrder = 99999
        parent.IgnoreGuiInset = true
        parent.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    end)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 130, 0, 36)
    btn.Position = pos
    btn.BackgroundColor3 = BLACK
    btn.BackgroundTransparency = 0.15
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = TEXT_WHITE
    btn.TextSize = 11.5
    btn.Visible = false
    btn.Active = true
    btn.Draggable = true
    btn.ZIndex = 1000
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local sk = Instance.new("UIStroke", btn)
    sk.Color = GOLD
    sk.Thickness = 1.5
    table.insert(themeStrokes, sk)
    return btn
end

SuperJumpWidget = makeFloatingWidget(superJumpWidgetGui, UDim2.new(0.68, 0, 0.25, 0), "SJUMP")
SuperJumpWidget.Text = "⬆ JUMP"
SuperJumpWidget.MouseButton1Click:Connect(function()
    if doSuperJump then doSuperJump() end
end)

SanguineManualWidget = makeFloatingWidget(sanguineManualWidgetGui, UDim2.new(0.68, 0, 0.33, 0), "SANGUINE MANUAL")
SanguineManualWidget.Text = "🩸 SANGUINE Z"
SanguineManualWidget.MouseButton1Click:Connect(function()
    dropFPSManual()
end)

SanguineAutoWidget = makeFloatingWidget(sanguineAutoWidgetGui, UDim2.new(0.68, 0, 0.41, 0), "SANGUINE AUTO")
SanguineAutoWidget.Text = "🔴 Auto: ON"
SanguineAutoWidget.MouseButton1Click:Connect(function()
    SanguineAutoEnabled = not SanguineAutoEnabled
    updateWidgetsVisuals()
end)

function makeWidget(parent, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 115, 0, 36)
    btn.Position = pos
    btn.BackgroundColor3 = BLACK
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = TEXT_WHITE
    btn.TextSize = 10
    btn.Visible = false
    btn.Active = true
    btn.Draggable = true
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local sk = Instance.new("UIStroke", btn)
    sk.Color = GOLD
    sk.Thickness = 1.5
    table.insert(themeStrokes, sk)
    return btn
end

PlayerWidgetBtn = makeWidget(playerWidgetGui, UDim2.new(0.82, 0, 0.20, 0))
PlayerWidgetBtn.Text = "🔓 PLAYER: OFF"
PlayerWidgetBtn.MouseButton1Click:Connect(function()
    if setPlayerLockState then setPlayerLockState(not AimlockPlayerEnabled) else AimlockPlayerEnabled = not AimlockPlayerEnabled; updateWidgetsVisuals() end
end)

NpcWidgetBtn = makeWidget(npcWidgetGui, UDim2.new(0.82, 0, 0.27, 0))
NpcWidgetBtn.Text = "🔓 NPC: OFF"
NpcWidgetBtn.MouseButton1Click:Connect(function()
    if setNpcLockState then setNpcLockState(not AimlockNpcEnabled) else AimlockNpcEnabled = not AimlockNpcEnabled; updateWidgetsVisuals() end
end)

-- ============================================================
-- INTERFAZ PRINCIPAL RITUAL HUB
-- ============================================================
local mainFrame = Instance.new("Frame")
mainFrame.Name = "RitualMainFrame"
mainFrame.Size = UDim2.new(0, 480, 0, 315)
mainFrame.Position = UDim2.new(0.5, -240, 0.5, -157)
mainFrame.BackgroundColor3 = BLACK
mainFrame.BackgroundTransparency = 0
mainFrame.Visible = true
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 24)

local mainFrameStroke = Instance.new("UIStroke", mainFrame)
mainFrameStroke.Color = GOLD
mainFrameStroke.Thickness = 2
table.insert(themeStrokes, mainFrameStroke)

-- RITUAL HUB HEADER
local headerFrame = Instance.new("Frame", mainFrame)
headerFrame.Size = UDim2.new(1, 0, 0, 45)
headerFrame.Position = UDim2.new(0, 0, 0, 0)
headerFrame.BackgroundColor3 = BLACK
headerFrame.BackgroundTransparency = 0
Instance.new("UICorner", headerFrame).CornerRadius = UDim.new(0, 24)

local headerStroke = Instance.new("UIStroke", headerFrame)
headerStroke.Color = GOLD
headerStroke.Thickness = 1.5

local ritualTitle = Instance.new("TextLabel", headerFrame)
ritualTitle.Size = UDim2.new(0.7, 0, 1, 0)
ritualTitle.Position = UDim2.new(0, 15, 0, 0)
ritualTitle.BackgroundTransparency = 1
ritualTitle.Text = "⚜️ RITUAL HUB"
ritualTitle.Font = Enum.Font.GothamBlack
ritualTitle.TextSize = 18
ritualTitle.TextColor3 = GOLD
ritualTitle.TextXAlignment = Enum.TextXAlignment.Left
table.insert(themeTexts, ritualTitle)

local ritualSubtitle = Instance.new("TextLabel", headerFrame)
ritualSubtitle.Size = UDim2.new(0.3, 0, 1, 0)
ritualSubtitle.Position = UDim2.new(0.7, 0, 0, 0)
ritualSubtitle.BackgroundTransparency = 1
ritualSubtitle.Text = "by: ritualz999"
ritualSubtitle.Font = Enum.Font.GothamBold
ritualSubtitle.TextSize = 10
ritualSubtitle.TextColor3 = DARK_GOLD
ritualSubtitle.TextXAlignment = Enum.TextXAlignment.Right
ritualSubtitle.TextYAlignment = Enum.TextYAlignment.Center
table.insert(themeTexts, ritualSubtitle)

-- Background decoration
local bgDecor = Instance.new("ImageLabel", mainFrame)
bgDecor.Name = "RitualBackground"
bgDecor.Size = UDim2.new(1, 0, 1, 0)
bgDecor.Position = UDim2.new(0, 0, 0, 0)
bgDecor.BackgroundTransparency = 1
bgDecor.ImageTransparency = 0.85
bgDecor.ScaleType = Enum.ScaleType.Crop
bgDecor.ZIndex = 0
bgDecor.Image = "rbxassetid://132404081379154"
Instance.new("UICorner", bgDecor).CornerRadius = UDim.new(0, 24)

local topLabel = Instance.new("TextLabel", mainFrame)
topLabel.Size = UDim2.new(0, 200, 0, 22)
topLabel.Position = UDim2.new(0.5, -100, 0, 52)
topLabel.BackgroundTransparency = 1
topLabel.Text = "🎵 Discord: ritualz999"
topLabel.Font = Enum.Font.GothamBold
topLabel.TextSize = 10
topLabel.TextColor3 = DARK_GOLD
topLabel.TextStrokeTransparency = 0
topLabel.TextStrokeColor3 = BLACK

local controlsContainer = Instance.new("Frame", mainFrame)
controlsContainer.Size = UDim2.new(0, 50, 0, 25)
controlsContainer.Position = UDim2.new(1, -60, 0, 52)
controlsContainer.BackgroundTransparency = 1

function createTopControl(text, xOff, color, cb)
    local btn = Instance.new("TextButton", controlsContainer)
    btn.Size = UDim2.new(0, 22, 0, 22)
    btn.Position = UDim2.new(0, xOff, 0, 0)
    btn.BackgroundColor3 = BLACK
    btn.BackgroundTransparency = 0
    btn.Text = text
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 14
    btn.TextColor3 = color
    btn.TextStrokeTransparency = 0
    btn.TextStrokeColor3 = BLACK
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local tcStroke = Instance.new("UIStroke", btn)
    tcStroke.Color = color
    tcStroke.Thickness = 1
    btn.MouseButton1Click:Connect(cb)
end

createTopControl("-", 0, GOLD, function()
    mainFrame.Visible = false
    openButton.Visible = true
end)
createTopControl("X", 26, RITUAL_RED, function()
    screenGui:Destroy(); toggleIconGui:Destroy()
    playerWidgetGui:Destroy(); npcWidgetGui:Destroy()
    superJumpWidgetGui:Destroy(); sanguineAutoWidgetGui:Destroy()
    soulGuitarWidgetGui:Destroy()
    portalSoruWidgetGui:Destroy()
    if fpsOverlayGui then fpsOverlayGui:Destroy() end
    ClearESP()
end)

local openButton = Instance.new("TextButton")
openButton.Size = UDim2.new(0, 42, 0, 42)
openButton.Position = UDim2.new(0, 15, 0, 15)
openButton.BackgroundColor3 = BLACK
openButton.BackgroundTransparency = 0
openButton.Text = ""
openButton.Visible = false
openButton.Active = true
openButton.Draggable = true
openButton.Parent = toggleIconGui

local toggleBG = Instance.new("ImageLabel")
toggleBG.Name = "ToggleBackground"
toggleBG.Image = "rbxassetid://132404081379154"
toggleBG.Size = UDim2.new(1, 0, 1, 0)
toggleBG.Position = UDim2.new(0, 0, 0, 0)
toggleBG.BackgroundTransparency = 1
toggleBG.ScaleType = Enum.ScaleType.Crop
toggleBG.ZIndex = 1 
toggleBG.Parent = openButton

Instance.new("UICorner", toggleBG).CornerRadius = UDim.new(0, 8)
Instance.new("UICorner", openButton).CornerRadius = UDim.new(0, 8)
local openStroke = Instance.new("UIStroke", openButton)
openStroke.Thickness = 2
openStroke.Transparency = 0
openStroke.Color = GOLD
table.insert(themeStrokes, openStroke)

openButton.MouseButton1Click:Connect(function()
    openButton.Visible = false
    centerAndMaximizeUI()
end)

local sidebar = Instance.new("Frame", mainFrame)
sidebar.Size = UDim2.new(0, 115, 1, 0)
sidebar.Position = UDim2.new(0, 10, 0, 0)
sidebar.BackgroundTransparency = 1

-- ============================================================
-- UI HELPERS
-- ============================================================
function isColorLight(c3)
    return (c3.R * 0.299 + c3.G * 0.587 + c3.B * 0.114) > 0.65
end

function centerAndMaximizeUI()
    mainFrame.Visible = true
    TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -230, 0.5, -155)
    }):Play()
end

uiCardsRegistry = {}
uiTogglesRegistry = {}
uiSteppersRegistry = {}

function createModuleCard(name, height, targetPage)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -8, 0, height)
    card.BackgroundColor3 = DARK_BG
    card.BackgroundTransparency = 0.65
    card.BorderSizePixel = 0
    card.Parent = targetPage
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)
    local cStroke = Instance.new("UIStroke", card)
    cStroke.Color = GOLD
    cStroke.Thickness = 1
    cStroke.Transparency = 0.4
    table.insert(themeStrokes, cStroke)
    
    local title = Instance.new("TextLabel", card)
    title.Text = "[ " .. string.upper(name) .. " ]"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 11
    title.TextColor3 = GOLD
    title.TextStrokeTransparency = 0
    title.TextStrokeColor3 = BLACK
    title.Size = UDim2.new(1, 0, 0, 22)
    title.Position = UDim2.new(0, 0, 0, 2)
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Center

    table.insert(uiCardsRegistry, { label = title, rawName = name })
    return card
end

function addToggleElement(parent, labelText, defaultState, yPos, callback, configKey)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -12, 0, 20)
    frame.Position = UDim2.new(0, 6, 0, yPos)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Text = labelText
    label.Font = Enum.Font.GothamBold
    label.TextSize = 9.5
    label.TextColor3 = TEXT_WHITE
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = BLACK
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left

    table.insert(uiTogglesRegistry, { label = label, rawName = labelText })

    local clickBtn = Instance.new("TextButton", frame)
    clickBtn.Size = UDim2.new(0, 36, 0, 16)
    clickBtn.Position = UDim2.new(1, -38, 0.5, -8)
    clickBtn.BackgroundColor3 = defaultState and GOLD or Color3.fromRGB(25, 25, 30)
    clickBtn.BackgroundTransparency = defaultState and 0.2 or 0.5
    clickBtn.Text = defaultState and "ON" or "OFF"
    clickBtn.Font = Enum.Font.GothamBold
    clickBtn.TextSize = 8.5
    clickBtn.TextColor3 = TEXT_WHITE
    clickBtn.TextStrokeTransparency = 0
    clickBtn.TextStrokeColor3 = BLACK
    Instance.new("UICorner", clickBtn).CornerRadius = UDim.new(0, 6)
    local tStroke = Instance.new("UIStroke", clickBtn)
    tStroke.Color = GOLD
    tStroke.Thickness = 1
    table.insert(themeStrokes, tStroke)

    local state = defaultState
    local function refresh()
        if state then
            clickBtn.BackgroundColor3 = GOLD
            clickBtn.BackgroundTransparency = 0.2
            clickBtn.Text = "ON"
            clickBtn.TextColor3 = BLACK
            clickBtn.TextStrokeTransparency = 0
            clickBtn.TextStrokeColor3 = BLACK
        else
            clickBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            clickBtn.BackgroundTransparency = 0.5
            clickBtn.Text = "OFF"
            clickBtn.TextColor3 = TEXT_WHITE
            clickBtn.TextStrokeTransparency = 0
            clickBtn.TextStrokeColor3 = BLACK
        end
    end

    local function setExternalState(newState)
        state = newState
        refresh()
        callback(state)
        updateWidgetsVisuals()
    end

    table.insert(UI_Toggle_Refreshes, setExternalState)
    ToggleRegistryMap[labelText] = setExternalState
    if configKey then ToggleRegistryMap[configKey] = setExternalState end

    clickBtn.MouseButton1Click:Connect(function()
        state = not state
        refresh()
        callback(state)
        updateWidgetsVisuals()
        if state then totalExecutions = totalExecutions + 1 end
    end)
    
    return setExternalState, clickBtn
end

local function formatStepperVal(v)
    if type(v) == "number" then
        v = math.floor(v * 100 + 0.5) / 100
        if v % 1 == 0 then
            return string.format("%d", v)
        else
            local s = string.format("%.2f", v)
            s = s:gsub("0+$", ""):gsub("%.$", "")
            return s
        end
    end
    return tostring(v)
end

function addStepper(parent, labelText, yPos, minVal, maxVal, step, getter, setter, suffix)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -12, 0, 22)
    frame.Position = UDim2.new(0, 6, 0, yPos)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Text = labelText
    label.Font = Enum.Font.GothamBold
    label.TextSize = 8.5
    label.TextColor3 = TEXT_WHITE
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = BLACK
    label.Size = UDim2.new(1, -95, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ClipsDescendants = true
    label.TextTruncate = Enum.TextTruncate.AtEnd

    table.insert(uiSteppersRegistry, { label = label, rawName = labelText })

    local minus = Instance.new("TextButton", frame)
    minus.Size = UDim2.new(0, 18, 0, 18)
    minus.Position = UDim2.new(1, -90, 0.5, -9)
    minus.Text = "-"
    minus.Font = Enum.Font.GothamBold
    minus.TextSize = 11
    minus.BackgroundColor3 = BLACK
    minus.BackgroundTransparency = 1
    minus.TextColor3 = TEXT_WHITE
    minus.TextStrokeTransparency = 0
    minus.TextStrokeColor3 = BLACK
    Instance.new("UICorner", minus).CornerRadius = UDim.new(0, 4)
    local mStroke = Instance.new("UIStroke", minus)
    mStroke.Color = GOLD
    mStroke.Thickness = 1.2
    table.insert(themeStrokes, mStroke)

    local valueLabel = Instance.new("TextLabel", frame)
    valueLabel.Size = UDim2.new(0, 44, 0, 18)
    valueLabel.Position = UDim2.new(1, -68, 0.5, -9)
    valueLabel.Text = formatStepperVal(getter()) .. (suffix or "")
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 8.5
    valueLabel.TextColor3 = GOLD
    valueLabel.TextStrokeTransparency = 0
    valueLabel.TextStrokeColor3 = BLACK
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center

    local plus = Instance.new("TextButton", frame)
    plus.Size = UDim2.new(0, 18, 0, 18)
    plus.Position = UDim2.new(1, -20, 0.5, -9)
    plus.Text = "+"
    plus.Font = Enum.Font.GothamBold
    plus.TextSize = 11
    plus.BackgroundColor3 = BLACK
    plus.BackgroundTransparency = 1
    plus.TextColor3 = TEXT_WHITE
    plus.TextStrokeTransparency = 0
    plus.TextStrokeColor3 = BLACK
    Instance.new("UICorner", plus).CornerRadius = UDim.new(0, 4)
    local pStroke = Instance.new("UIStroke", plus)
    pStroke.Color = GOLD
    pStroke.Thickness = 1.2
    table.insert(themeStrokes, pStroke)

    minus.MouseButton1Click:Connect(function()
        local raw = getter() - step
        raw = math.floor(raw * 100 + 0.5) / 100
        local v = math.max(raw, minVal)
        setter(v)
        valueLabel.Text = formatStepperVal(v) .. (suffix or "")
    end)
    plus.MouseButton1Click:Connect(function()
        local raw = getter() + step
        raw = math.floor(raw * 100 + 0.5) / 100
        local v = math.min(raw, maxVal)
        setter(v)
        valueLabel.Text = formatStepperVal(v) .. (suffix or "")
    end)

    return valueLabel
end

-- ============================================================
-- SIDEBAR & PAGES
-- ============================================================
local categories = {
    { key = "Stats", page = StatsPage, y = 54 },
    { key = "Combat", page = CombatPage, y = 84 },
    { key = "Glitches", page = GlitchesPage, y = 114 },
    { key = "ESP", page = CamLockPage, y = 144 },
    { key = "Soru", page = SoruPage, y = 174 },
    { key = "Appearance", page = AppearancePage, y = 204 },
    { key = "Songs", page = SongsPage, y = 234 },
    { key = "VFX", page = SacredVFXPage, y = 264 },
    { key = "Misc", page = MiscPage, y = 294 },
}

local sidebarScroll = Instance.new("ScrollingFrame", sidebar)
sidebarScroll.Size = UDim2.new(1, 0, 1, -55)
sidebarScroll.Position = UDim2.new(0, 0, 0, 48)
sidebarScroll.BackgroundTransparency = 1
sidebarScroll.BorderSizePixel = 0
sidebarScroll.ScrollBarThickness = 2
sidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local sidebarLayout = Instance.new("UIListLayout", sidebarScroll)
sidebarLayout.Padding = UDim.new(0, 4)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder

local sidebarPadding = Instance.new("UIPadding", sidebarScroll)
sidebarPadding.PaddingLeft = UDim.new(0, 10)

local activeTabBtn = nil
for _, cat in ipairs(categories) do
    local btn = Instance.new("TextButton", sidebarScroll)
    btn.Text = cat.key
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = (cat.page == StatsPage) and GOLD or TEXT_WHITE
    btn.Size = UDim2.new(1, -12, 0, 24)
    btn.BackgroundTransparency = 1
    btn.TextXAlignment = Enum.TextXAlignment.Left
    cat.btn = btn

    if cat.page == StatsPage then
        activeTabBtn = btn
        table.insert(themeTexts, btn)
    end

    btn.MouseButton1Click:Connect(function()
        if activeTabBtn then
            activeTabBtn.TextColor3 = TEXT_WHITE
            local idx = table.find(themeTexts, activeTabBtn)
            if idx then table.remove(themeTexts, idx) end
        end
        activeTabBtn = btn
        table.insert(themeTexts, btn)
        btn.TextColor3 = GOLD
        StatsPage.Visible = false; CombatPage.Visible = false; GlitchesPage.Visible = false
        CamLockPage.Visible = false; SoruPage.Visible = false
        AppearancePage.Visible = false; SongsPage.Visible = false; BlacklistPage.Visible = false
        SacredVFXPage.Visible = false; MiscPage.Visible = false
        cat.page.Visible = true
        if cat.key == "Soru" then
            RightPanel.Visible = true
            PagesContainer.Size = UDim2.new(0, 165, 1, -55)
        else
            RightPanel.Visible = false
            PagesContainer.Size = UDim2.new(0, 320, 1, -55)
        end
    end)
end

local PagesContainer = Instance.new("Frame", mainFrame)
PagesContainer.Size = UDim2.new(0, 320, 1, -55)
PagesContainer.Position = UDim2.new(0, 125, 0, 45)
PagesContainer.BackgroundTransparency = 1
PagesContainer.ClipsDescendants = false

function createScrollingPage()
    local sf = Instance.new("ScrollingFrame", PagesContainer)
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 4
    sf.CanvasSize = UDim2.new(0, 0, 0, 800)
    sf.Visible = false

    local pad = Instance.new("UIPadding", sf)
    pad.PaddingTop = UDim.new(0, 12)
    pad.PaddingBottom = UDim.new(0, 15)

    local layout = Instance.new("UIListLayout", sf)
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 45)
    end)
    return sf
end

local StatsPage = createScrollingPage()
local CombatPage = createScrollingPage()
local GlitchesPage = createScrollingPage()
local CamLockPage = createScrollingPage()
local SoruPage = createScrollingPage()
local AppearancePage = createScrollingPage()
local SongsPage = createScrollingPage()
local BlacklistPage = createScrollingPage()
local SacredVFXPage = createScrollingPage()
local MiscPage = createScrollingPage()
StatsPage.Visible = true

local RightPanel = Instance.new("Frame", mainFrame)
RightPanel.Size = UDim2.new(0, 160, 1, -55)
RightPanel.Position = UDim2.new(0, 295, 0, 45)
RightPanel.BackgroundColor3 = DARK_BG
RightPanel.BackgroundTransparency = 0.65
RightPanel.Visible = false
Instance.new("UICorner", RightPanel).CornerRadius = UDim.new(0, 8)
local rpStroke = Instance.new("UIStroke", RightPanel)
rpStroke.Color = GOLD
rpStroke.Thickness = 1
table.insert(themeStrokes, rpStroke)

local ListScroll = Instance.new("ScrollingFrame", RightPanel)
ListScroll.Size = UDim2.new(1, -10, 1, -30)
ListScroll.Position = UDim2.new(0, 5, 0, 24)
ListScroll.BackgroundTransparency = 1
ListScroll.BorderSizePixel = 0
ListScroll.ScrollBarThickness = 3
ListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", ListScroll).Padding = UDim.new(0, 4)

local DropLabel = Instance.new("TextButton", ListScroll)
DropLabel.Name = "DropLabel"
DropLabel.Size = UDim2.new(1, 0, 0, 24)
DropLabel.BackgroundColor3 = BLACK
DropLabel.BackgroundTransparency = 1
DropLabel.Text = "🎯 Selector: Nearest"
DropLabel.Font = Enum.Font.GothamBold
DropLabel.TextColor3 = GOLD
DropLabel.TextSize = 8.5
Instance.new("UICorner", DropLabel).CornerRadius = UDim.new(0, 4)
local dlStroke = Instance.new("UIStroke", DropLabel)
dlStroke.Color = GOLD
dlStroke.Thickness = 1
table.insert(themeStrokes, dlStroke)
table.insert(themeTexts, DropLabel)

-- ============================================================
-- POBLAR PESTAÑAS (COMBAT - CON AIMBOT Y FOV SLIDER)
-- ============================================================

-- COMBAT TAB - Aimbot Modules
local c1 = createModuleCard("Aimbot Modules", 350, CombatPage)

-- Aimbot Skills Toggle
addToggleElement(c1, "Aimbot Skills", _G.G_SilentAimSkill, 24, function(v) 
    _G.G_SilentAimSkill = v 
    if FOVCircle then FOVCircle.Visible = v and _G.G_SilentAimShowFOV end
end, "SkillAimbot")

-- Target Players
addToggleElement(c1, "Target Players", _G.G_SilentAimTargetPlayers, 48, function(v) 
    _G.G_SilentAimTargetPlayers = v 
end, "TargetPlayers")

-- Target NPCs
addToggleElement(c1, "Target NPCs", _G.G_SilentAimTargetMobs, 72, function(v) 
    _G.G_SilentAimTargetMobs = v 
end, "TargetMobs")

-- Show FOV Circle
addToggleElement(c1, "Show FOV Circle", _G.G_SilentAimShowFOV, 96, function(v) 
    _G.G_SilentAimShowFOV = v 
    if FOVCircle then 
        FOVCircle.Visible = v and _G.G_SilentAimSkill
    end
end, "ShowFOV")

-- FOV Slider (aparece debajo de Show FOV Circle)
local fovSliderLabel = Instance.new("TextLabel", c1)
fovSliderLabel.Size = UDim2.new(1, -12, 0, 18)
fovSliderLabel.Position = UDim2.new(0, 6, 0, 120)
fovSliderLabel.BackgroundTransparency = 1
fovSliderLabel.Text = "FOV Radius: " .. tostring(_G.G_SilentAimFOV)
fovSliderLabel.Font = Enum.Font.GothamBold
fovSliderLabel.TextSize = 9
fovSliderLabel.TextColor3 = GOLD
fovSliderLabel.TextStrokeTransparency = 0
fovSliderLabel.TextStrokeColor3 = BLACK

local fovSlider = Instance.new("Frame", c1)
fovSlider.Size = UDim2.new(1, -20, 0, 20)
fovSlider.Position = UDim2.new(0, 10, 0, 140)
fovSlider.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
fovSlider.BackgroundTransparency = 0
Instance.new("UICorner", fovSlider).CornerRadius = UDim.new(0, 4)
local fovSliderStroke = Instance.new("UIStroke", fovSlider)
fovSliderStroke.Color = GOLD
fovSliderStroke.Thickness = 1

local fovFill = Instance.new("Frame", fovSlider)
fovFill.Size = UDim2.new((_G.G_SilentAimFOV - 30) / 470, 0, 1, 0)
fovFill.BackgroundColor3 = GOLD
fovFill.BackgroundTransparency = 0.3
Instance.new("UICorner", fovFill).CornerRadius = UDim.new(0, 4)

local fovHandle = Instance.new("TextButton", fovSlider)
fovHandle.Size = UDim2.new(0, 14, 0, 14)
fovHandle.Position = UDim2.new((_G.G_SilentAimFOV - 30) / 470, -7, 0.5, -7)
fovHandle.BackgroundColor3 = GOLD
fovHandle.BackgroundTransparency = 0
fovHandle.Text = ""
Instance.new("UICorner", fovHandle).CornerRadius = UDim.new(1, 0)
local fovHandleStroke = Instance.new("UIStroke", fovHandle)
fovHandleStroke.Color = Color3.fromRGB(255, 255, 255)
fovHandleStroke.Thickness = 1

local fovDragging = false
fovHandle.MouseButton1Down:Connect(function()
    fovDragging = true
end)
fovHandle.MouseButton1Up:Connect(function()
    fovDragging = false
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and fovDragging then
        local absPos = fovSlider.AbsolutePosition
        local absSize = fovSlider.AbsoluteSize
        local mousePos = input.Position.X
        local relative = math.clamp((mousePos - absPos.X) / absSize.X, 0, 1)
        local newVal = math.floor(30 + relative * 470)
        newVal = math.clamp(newVal, 30, 500)
        _G.G_SilentAimFOV = newVal
        fovFill.Size = UDim2.new(relative, 0, 1, 0)
        fovHandle.Position = UDim2.new(relative, -7, 0.5, -7)
        fovSliderLabel.Text = "FOV Radius: " .. tostring(newVal)
        if FOVCircle then FOVCircle.Radius = newVal end
    end
end)

-- Team Check
addToggleElement(c1, "Team Check", _G.G_SilentAimTeamCheck, 166, function(v) 
    _G.G_SilentAimTeamCheck = v 
end, "TeamCheck")

-- Ignore Safe Zone
addToggleElement(c1, "Ignore Safe Zone", _G.G_AimbotSafeZoneCheck, 190, function(v) _G.G_AimbotSafeZoneCheck = v end, "AimbotSafeZone")

-- Ignore PvP OFF Players
addToggleElement(c1, "Ignore PvP OFF Players", _G.G_AimbotPvPCheck, 214, function(v) _G.G_AimbotPvPCheck = v end, "AimbotPvP")

-- Rainbow Body ESP
addToggleElement(c1, "Target Rainbow Body ESP", _G.G_TargetRainbowBodyESP, 238, function(v) _G.G_TargetRainbowBodyESP = v end, "RainbowBodyESP")

-- Aimbot Max Distance
addStepper(c1, "Aimbot Max Dist:", 262, 100, 5000, 250, function() return maxRange end, function(v) maxRange = v end, "st")

-- Combat: Anti Stun and Hitbox Attack
local antiStunCard = createModuleCard("Anti Stun and Hitbox Attack [Beta]", 50, CombatPage)
addToggleElement(antiStunCard, "Anti Stun and Hitbox Attack [Beta]", AntiStunHitboxEnabled, 24, function(v)
    if v then enableAntiStunHitbox() else disableAntiStunHitbox() end
end, "AntiStunHitbox")

-- Combat: Fast Attack
local c2 = createModuleCard("Fast Attack & Combat", 50, CombatPage)
addToggleElement(c2, "Fast Attack", FastAttackEnabled, 24, function(v) FastAttackEnabled = v; if v then StartFastAttack() end end, "FastAttack")

-- Combat: Movement
local c3 = createModuleCard("Movement", 220, CombatPage)
addToggleElement(c3, "Walk Speed", WalkSpeedEnabled, 24, function(v) WalkSpeedEnabled = v end, "WalkSpeed")
addStepper(c3, "Speed:", 48, 16, 500, 50, function() return WalkSpeedValue end, function(v) WalkSpeedValue = v end, "")

RunService.Stepped:Connect(function()
    if WalkSpeedEnabled and player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hum and hrp then
            hum.WalkSpeed = WalkSpeedValue
            if hum.MoveDirection.Magnitude > 0 and WalkSpeedValue > 20 then
                hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (WalkSpeedValue / 100))
            end
        end
    end
end)

local setDashToggleState = addToggleElement(c3, "Dash Distance", DashEnabled, 88, function(v) 
    DashEnabled = v 
    if v then startDashLoop() else stopDashLoop() end 
end, "Dash")
local dashDistLabel = addStepper(c3, "Distance:", 116, 1, 300, 10, function() return DashLengthDist end, function(v) 
    DashLengthDist = v
    if DashEnabled then applyDashInstantly() end
end, "")

addToggleElement(c3, "Noclip", NoclipEnabled, 152, function(v) SetNoclip(v) end, "Noclip")
addToggleElement(c3, "Walk on Water", WalkOnWaterEnabled, 176, function(v) WalkOnWaterEnabled = v end, "WalkOnWater")

-- Combat: Auto Race V4
local autoV4Card = createModuleCard("Auto Race V4", 50, CombatPage)
addToggleElement(autoV4Card, "Auto Race V4", AutoV4Enabled, 24, function(v)
    AutoV4Enabled = v
    if v then startAutoV4Loop() else stopAutoV4Loop() end
end, "AutoV4")

-- ============================================================
-- LOAD CONFIG AND START
-- ============================================================
pcall(LoadConfig)
pcall(LoadMacroConfig)
centerAndMaximizeUI()

print("⚜️ RITUAL HUB V1.0 LOADED | BLACK & GOLD THEME | by: ritualz999")
print("🎯 Aimbot with FOV Circle | Skills lock onto targets inside the FOV circle")
