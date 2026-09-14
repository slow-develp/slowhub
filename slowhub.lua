local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ========== PARENT GUI SEGURO ==========
local parentGui = CoreGui
pcall(function()
    if type(gethui) == "function" then
        local ok, res = pcall(gethui)
        if ok and res then parentGui = res end
    end
end)

if not parentGui or typeof(parentGui) ~= "Instance" then
    parentGui = CoreGui
end

local testOK = pcall(function()
    local t = Instance.new("Folder")
    t.Parent = parentGui
    t:Destroy()
end)
if not testOK then
    parentGui = CoreGui
end

pcall(function()
    if parentGui and parentGui.FindFirstChild then
        local old = parentGui:FindFirstChild("SlowHub")
        if old then old:Destroy() end
        local old2 = parentGui:FindFirstChild("SlowHubKey")
        if old2 then old2:Destroy() end
    end
end)

-- ========== CORES ==========
local BG = Color3.fromRGB(16, 16, 20)
local PANEL = Color3.fromRGB(28, 28, 34)
local CARD = Color3.fromRGB(38, 38, 46)
local ACCENT = Color3.fromRGB(150, 90, 240)
local TEXT = Color3.fromRGB(240, 240, 250)
local TEXTDIM = Color3.fromRGB(150, 150, 165)
local SUCCESS = Color3.fromRGB(70, 200, 120)
local DANGER = Color3.fromRGB(230, 80, 90)
local STROKE = Color3.fromRGB(90, 90, 100)
local PURPLE_BORDER = Color3.fromRGB(130, 70, 220)

-- ========== CONSTANTES ==========
local KEY = "SlowHubVIP"
local DISCORD_LINK = "https://discord.com/users/tav.x"
local SCRIPT_URL = "https://raw.githubusercontent.com/slow-develp/slowhub/main/Slow-Hub-Universal.lua"

local ICONS = {
    Home = "rbxassetid://111637692403997",
    Person = "rbxassetid://118410078119588",
    Eye = "rbxassetid://7546367582",
    Box = "rbxassetid://87246322401825",
    Door = "rbxassetid://138668025068101",
    Lightning = "rbxassetid://4177217854",
    Info = "rbxassetid://11780939099",
    Star = "rbxassetid://89172331085803",
    Config = "rbxassetid://103052477976081",
    Aimbot = "rbxassetid://87867532553953",
}

local rowCache = {}
local originalLighting = {}
local welcomeShown = false

-- ========== CONFIG ==========
local Config = {
    ESP = {Enabled=false, Color=Color3.fromRGB(150,90,240), ShowName=false, ShowDistance=false, ShowHealth=false, ShowHighlight=false, TeamCheck=false},
    Aimbot = {Enabled=false, FOVEnabled=false, FOVColor=Color3.fromRGB(150,90,240), FOVSize=150, Target="Head", TeamCheck=false, Smoothness=0.15, AutoShot=false},
    Hitbox = {Enabled=false, Size=3, Color=Color3.fromRGB(150,90,240), ShowBox=false},
    Noclip = {Enabled=false},
    Speed = {Enabled=false, Value=32},
    InfiniteJump = {Enabled=false},
    Fly = {Enabled=false, Speed=60, VerticalSpeed=40},
    Fullbright = {Enabled=false},
    FOVChanger = {Enabled=false, Value=70},
    AntiFling = {Enabled=false},
    AntiAFK = {Enabled=false}
}

-- ========== HELPERS ==========
local function safeChar(plr)
    if not plr or not plr.Parent then return nil, nil, nil end
    local char = plr.Character
    if not char then return nil, nil, nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return char, hum, hrp
end

local function sameTeam(plr)
    if not plr or not LocalPlayer then return false end
    if plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then return true end
    if plr.TeamColor and LocalPlayer.TeamColor and plr.TeamColor == LocalPlayer.TeamColor then return true end
    return false
end

local function isValidTarget(plr, teamcheck)
    if not plr or plr == LocalPlayer then return false end
    if not plr.Parent then return false end
    local char = plr.Character
    if not char then return false end
    if char:FindFirstChildOfClass("ForceField") then return false end
    if teamcheck and sameTeam(plr) then return false end
    return true
end

-- ========== ESP ==========
local espFolder = Instance.new("Folder")
espFolder.Name = "SlowHub_ESP"
espFolder.Parent = parentGui

local espData = {}
local highlightAvailable = pcall(function()
    local h = Instance.new("Highlight")
    h:Destroy()
end)

local function destroyESP(plr)
    local d = espData[plr]
    if not d then return end
    for _, obj in pairs(d) do
        if typeof(obj) == "Instance" and obj.Parent then obj:Destroy() end
    end
    espData[plr] = nil
end

local function createESP(plr)
    if espData[plr] then return end
    local d = {}

    local box = Instance.new("Frame")
    box.Name = "Box"
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Visible = false
    box.ZIndex = 5
    box.Parent = espFolder
    local stroke = Instance.new("UIStroke", box)
    stroke.Color = Config.ESP.Color
    stroke.Thickness = 1.2
    stroke.Transparency = 0.15

    local nameLbl = Instance.new("TextLabel")
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = plr.Name
    nameLbl.TextColor3 = Config.ESP.Color
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 12
    nameLbl.TextStrokeTransparency = 0.3
    nameLbl.Visible = false
    nameLbl.ZIndex = 6
    nameLbl.Parent = espFolder

    local distLbl = Instance.new("TextLabel")
    distLbl.BackgroundTransparency = 1
    distLbl.Text = "0m"
    distLbl.TextColor3 = Config.ESP.Color
    distLbl.Font = Enum.Font.Gotham
    distLbl.TextSize = 10
    distLbl.TextStrokeTransparency = 0.3
    distLbl.Visible = false
    distLbl.ZIndex = 6
    distLbl.Parent = espFolder

    local hpBg = Instance.new("Frame")
    hpBg.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    hpBg.BorderSizePixel = 0
    hpBg.Visible = false
    hpBg.ZIndex = 6
    hpBg.Parent = espFolder
    Instance.new("UICorner", hpBg).CornerRadius = UDim.new(1, 0)
    local hpBar = Instance.new("Frame")
    hpBar.BackgroundColor3 = SUCCESS
    hpBar.BorderSizePixel = 0
    hpBar.Size = UDim2.new(1, 0, 1, 0)
    hpBar.ZIndex = 7
    hpBar.Parent = hpBg
    Instance.new("UICorner", hpBar).CornerRadius = UDim.new(1, 0)

    local hl = nil
    if highlightAvailable then
        pcall(function()
            hl = Instance.new("Highlight")
            hl.Name = "HL"
            hl.FillColor = Config.ESP.Color
            hl.FillTransparency = 0.7
            hl.OutlineColor = Config.ESP.Color
            hl.OutlineTransparency = 0
            hl.Adornee = nil
            hl.Enabled = false
            hl.Parent = espFolder
        end)
    end

    d.Box = box
    d.Stroke = stroke
    d.Name = nameLbl
    d.Dist = distLbl
    d.HpBg = hpBg
    d.HpBar = hpBar
    d.HL = hl

    espData[plr] = d
end

local function hideESP(d)
    if d.Box then d.Box.Visible = false end
    if d.Name then d.Name.Visible = false end
    if d.Dist then d.Dist.Visible = false end
    if d.HpBg then d.HpBg.Visible = false end
    if d.HL then d.HL.Enabled = false end
end

local function updateESP()
    if not Config.ESP.Enabled then
        for _, d in pairs(espData) do
            hideESP(d)
        end
        return
    end

    local localChar = LocalPlayer.Character
    local localHrp = localChar and localChar:FindFirstChild("HumanoidRootPart")

    for plr, d in pairs(espData) do
        if isValidTarget(plr, Config.ESP.TeamCheck) then
            local char, hum, hrp = safeChar(plr)
            if (char and hum and hrp) and hum.Health > 0 then
                local head = char:FindFirstChild("Head")
                if head then
                    local headPos, headOn = Camera:WorldToViewportPoint(head.Position)
                    local footPos, footOn = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

                    if headOn and footOn then
                        local h = math.abs(footPos.Y - headPos.Y)
                        local w = h * 0.6
                        local x = headPos.X - w / 2
                        local y = headPos.Y

                        d.Box.Visible = true
                        d.Box.Position = UDim2.new(0, x, 0, y)
                        d.Box.Size = UDim2.new(0, w, 0, h)
                        d.Stroke.Color = Config.ESP.Color

                        if Config.ESP.ShowName then
                            d.Name.Visible = true
                            d.Name.Text = plr.Name
                            d.Name.Position = UDim2.new(0, x, 0, y - 16)
                            d.Name.Size = UDim2.new(0, w, 0, 14)
                        else
                            d.Name.Visible = false
                        end

                        if Config.ESP.ShowDistance then
                            d.Dist.Visible = true
                            local dist = localHrp and (localHrp.Position - hrp.Position).Magnitude or 0
                            d.Dist.Text = string.format("%dm", math.floor(dist))
                            d.Dist.Position = UDim2.new(0, x, 0, y + h + 2)
                            d.Dist.Size = UDim2.new(0, w, 0, 12)
                        else
                            d.Dist.Visible = false
                        end

                        if Config.ESP.ShowHealth then
                            d.HpBg.Visible = true
                            d.HpBg.Position = UDim2.new(0, x - 6, 0, y)
                            d.HpBg.Size = UDim2.new(0, 3, 0, h)
                            local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                            d.HpBar.Size = UDim2.new(1, 0, pct, 0)
                            d.HpBar.Position = UDim2.new(0, 0, 1 - pct, 0)
                            d.HpBar.BackgroundColor3 = Color3.fromRGB(
                                math.floor(255 * (1 - pct)),
                                math.floor(255 * pct),
                                60
                            )
                        else
                            d.HpBg.Visible = false
                        end

                        if d.HL then
                            d.HL.Enabled = Config.ESP.ShowHighlight
                            d.HL.Adornee = char
                            d.HL.FillColor = Config.ESP.Color
                            d.HL.OutlineColor = Config.ESP.Color
                        end
                    else
                        hideESP(d)
                    end
                else
                    hideESP(d)
                end
            else
                hideESP(d)
            end
        else
            hideESP(d)
        end
    end
end

-- ========== FOV / AIMBOT ==========
local fovFrame = Instance.new("Frame")
fovFrame.Name = "Aimbot_FOV"
fovFrame.BackgroundTransparency = 1
fovFrame.BorderSizePixel = 0
fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fovFrame.Visible = false
fovFrame.ZIndex = 4
fovFrame.Parent = parentGui
local fovStroke = Instance.new("UIStroke", fovFrame)
fovStroke.Color = Config.Aimbot.FOVColor
fovStroke.Thickness = 1.5
fovStroke.Transparency = 0.2
Instance.new("UICorner", fovFrame).CornerRadius = UDim.new(1, 0)

local function updateFOV()
    if not (Config.Aimbot.Enabled and Config.Aimbot.FOVEnabled) then
        fovFrame.Visible = false
        return
    end
    fovFrame.Visible = true
    fovFrame.Size = UDim2.new(0, Config.Aimbot.FOVSize * 2, 0, Config.Aimbot.FOVSize * 2)
    local vp = Camera.ViewportSize
    fovFrame.Position = UDim2.new(0, vp.X / 2, 0, vp.Y / 2)
    fovStroke.Color = Config.Aimbot.FOVColor
end

local function getClosest()
    local closest, closestDist = nil, math.huge
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    for _, plr in ipairs(Players:GetPlayers()) do
        if isValidTarget(plr, Config.Aimbot.TeamCheck) then
            local char, hum, hrp = safeChar(plr)
            if (char and hum and hrp) and hum.Health > 0 then
                local part = (Config.Aimbot.Target == "Head") and char:FindFirstChild("Head") or hrp
                if part then
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local screenPos = Vector2.new(pos.X, pos.Y)
                        local dist = (screenPos - center).Magnitude
                        if dist <= Config.Aimbot.FOVSize and dist < closestDist then
                            closest, closestDist = part, dist
                        end
                    end
                end
            end
        end
    end
    return closest
end

local aimbotActive = false
local function startAimbot()
    if aimbotActive then return end
    aimbotActive = true
    task.spawn(function()
        while Config.Aimbot.Enabled do
            local target = getClosest()
            if target then
                local goal = CFrame.new(Camera.CFrame.Position, target.Position)
                Camera.CFrame = Camera.CFrame:Lerp(goal, Config.Aimbot.Smoothness)
                if Config.Aimbot.AutoShot then
                    local char = LocalPlayer.Character
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    if tool then pcall(function() tool:Activate() end) end
                end
            end
            RunService.RenderStepped:Wait()
        end
        aimbotActive = false
    end)
end

-- ========== HITBOX (só quadro visual) ==========
local hitboxFolder = Instance.new("Folder")
hitboxFolder.Name = "SlowHub_Hitbox"
hitboxFolder.Parent = parentGui
local hitboxData = {}

local function createHitbox(plr)
    if hitboxData[plr] then return end
    local frame = Instance.new("Frame")
    frame.Name = "HB_" .. plr.Name
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.ZIndex = 4
    frame.Parent = hitboxFolder
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Config.Hitbox.Color
    stroke.Thickness = 1.5
    stroke.Transparency = 0.1
    hitboxData[plr] = {Frame = frame, Stroke = stroke}
end

local function updateHitboxes()
    if not (Config.Hitbox.Enabled and Config.Hitbox.ShowBox) then
        for _, d in pairs(hitboxData) do
            if d.Frame then d.Frame.Visible = false end
        end
        return
    end
    for plr, d in pairs(hitboxData) do
        if isValidTarget(plr, false) then
            local char, hum, hrp = safeChar(plr)
            if (char and hum and hrp) and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local size = Config.Hitbox.Size * 10
                    d.Frame.Visible = true
                    d.Frame.Position = UDim2.new(0, pos.X - size / 2, 0, pos.Y - size / 2)
                    d.Frame.Size = UDim2.new(0, size, 0, size)
                    d.Stroke.Color = Config.Hitbox.Color
                else
                    if d.Frame then d.Frame.Visible = false end
                end
            else
                if d.Frame then d.Frame.Visible = false end
            end
        else
            if d.Frame then d.Frame.Visible = false end
        end
    end
end

local function trackPlayer(plr)
    if plr == LocalPlayer then return end
    createESP(plr)
    createHitbox(plr)
end

for _, plr in ipairs(Players:GetPlayers()) do
    trackPlayer(plr)
end

Players.PlayerAdded:Connect(trackPlayer)
Players.PlayerRemoving:Connect(function(plr)
    destroyESP(plr)
    hitboxData[plr] = nil
end)

-- ========== MOVIMENTO ==========
local noclipConn
local function setNoclip(state)
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    if not state then return end
    noclipConn = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
end

local speedConn
local function setSpeed(state)
    if speedConn then speedConn:Disconnect() speedConn = nil end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if state then
        hum.WalkSpeed = Config.Speed.Value
        speedConn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if Config.Speed.Enabled and hum.WalkSpeed ~= Config.Speed.Value then
                hum.WalkSpeed = Config.Speed.Value
            end
        end)
    else
        hum.WalkSpeed = 16
    end
end

local flyConn
local flyBodyVel, flyBodyGyro
local flyKeys = {W=false, A=false, S=false, D=false, Space=false, Shift=false}
local flyInputConn
local flyInputEndConn

local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyInputConn then flyInputConn:Disconnect() flyInputConn = nil end
    if flyInputEndConn then flyInputEndConn:Disconnect() flyInputEndConn = nil end
    if flyBodyVel and flyBodyVel.Parent then flyBodyVel:Destroy() end
    if flyBodyGyro and flyBodyGyro.Parent then flyBodyGyro:Destroy() end
    flyBodyVel, flyBodyGyro = nil, nil
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
end

local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return end

    hum.PlatformStand = true

    flyBodyVel = Instance.new("BodyVelocity")
    flyBodyVel.Name = "SlowHub_FlyVel"
    flyBodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBodyVel.Velocity = Vector3.zero
    flyBodyVel.Parent = hrp

    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.Name = "SlowHub_FlyGyro"
    flyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyBodyGyro.P = 1000
    flyBodyGyro.D = 50
    flyBodyGyro.CFrame = hrp.CFrame
    flyBodyGyro.Parent = hrp

    flyInputConn = UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.W then flyKeys.W = true
        elseif input.KeyCode == Enum.KeyCode.A then flyKeys.A = true
        elseif input.KeyCode == Enum.KeyCode.S then flyKeys.S = true
        elseif input.KeyCode == Enum.KeyCode.D then flyKeys.D = true
        elseif input.KeyCode == Enum.KeyCode.Space then flyKeys.Space = true
        elseif input.KeyCode == Enum.KeyCode.LeftShift then flyKeys.Shift = true
        end
    end)
    flyInputEndConn = UIS.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.W then flyKeys.W = false
        elseif input.KeyCode == Enum.KeyCode.A then flyKeys.A = false
        elseif input.KeyCode == Enum.KeyCode.S then flyKeys.S = false
        elseif input.KeyCode == Enum.KeyCode.D then flyKeys.D = false
        elseif input.KeyCode == Enum.KeyCode.Space then flyKeys.Space = false
        elseif input.KeyCode == Enum.KeyCode.LeftShift then flyKeys.Shift = false
        end
    end)

    flyConn = RunService.RenderStepped:Connect(function()
        if not Config.Fly.Enabled then return end
        if not (hrp and hrp.Parent) then return end
        local cam = Camera.CFrame
        local move = Vector3.zero

        if flyKeys.W then move += cam.LookVector end
        if flyKeys.S then move -= cam.LookVector end
        if flyKeys.A then move -= cam.RightVector end
        if flyKeys.D then move += cam.RightVector end
        if flyKeys.Space then move += Vector3.new(0, 1, 0) end
        if flyKeys.Shift then move -= Vector3.new(0, 1, 0) end

        if move.Magnitude > 0 then
            move = move.Unit * Config.Fly.Speed
        end

        flyBodyVel.Velocity = move
        flyBodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.LookVector)
    end)
end

local function setFly(state)
    if state then startFly() else stopFly() end
end

local infJumpConn
local function setInfJump(state)
    if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
    if not state then return end
    infJumpConn = UIS.JumpRequest:Connect(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end

local function setFullbright(state)
    if state then
        if not originalLighting.Ambient then
            originalLighting.Ambient = Lighting.Ambient
            originalLighting.OutdoorAmbient = Lighting.OutdoorAmbient
            originalLighting.Brightness = Lighting.Brightness
            originalLighting.ClockTime = Lighting.ClockTime
            originalLighting.FogEnd = Lighting.FogEnd
            originalLighting.GlobalShadows = Lighting.GlobalShadows
        end
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1e6
        Lighting.GlobalShadows = false
    else
        if originalLighting.Ambient then
            Lighting.Ambient = originalLighting.Ambient
            Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
            Lighting.Brightness = originalLighting.Brightness
            Lighting.ClockTime = originalLighting.ClockTime
            Lighting.FogEnd = originalLighting.FogEnd
            Lighting.GlobalShadows = originalLighting.GlobalShadows
        end
    end
end

local function setFOVChanger(state)
    if state then
        Camera.FieldOfView = Config.FOVChanger.Value
    else
        Camera.FieldOfView = 70
    end
end

local antiFlingConn
local function setAntiFling(state)
    if antiFlingConn then antiFlingConn:Disconnect() antiFlingConn = nil end
    if not state then return end
    antiFlingConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local vel = hrp.AssemblyLinearVelocity
        if vel.Magnitude > 200 then
            hrp.AssemblyLinearVelocity = vel.Unit * 50
        end
    end)
end

local antiAfkConn
local function setAntiAFK(state)
    if antiAfkConn then antiAfkConn:Disconnect() antiAfkConn = nil end
    if not state then return end
    if LocalPlayer and LocalPlayer.Idled then
        antiAfkConn = LocalPlayer.Idled:Connect(function()
            pcall(function()
                local vu = game:GetService("VirtualUser")
                if vu then
                    vu:CaptureController()
                    vu:ClickButton2(Vector2.new())
                end
            end)
        end)
    end
end

local savedPositions = {}

local function savePosition(slot)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    savedPositions[slot] = hrp.CFrame
    return true
end

local function gotoPosition(slot)
    local cf = savedPositions[slot]
    if not cf then return false end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    hrp.CFrame = cf
    return true
end

local function gotoPlayer(plr)
    if not plr then return false end
    local _, _, targetHrp = safeChar(plr)
    if not targetHrp then return false end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    hrp.CFrame = targetHrp.CFrame + Vector3.new(0, 0, 3)
    return true
end

-- ========== AUTO-REJOIN (roda o script no próximo servidor) ==========
local function queueScriptOnTeleport()
    local code = 'loadstring(game:HttpGet("' .. SCRIPT_URL .. '"))()'
    local queued = false
    pcall(function()
        if queue_on_teleport then
            queue_on_teleport(code)
            queued = true
        elseif queueonteleport then
            queueonteleport(code)
            queued = true
        end
    end)
    return queued
end

local function rejoin()
    queueScriptOnTeleport()
    task.wait(0.3)
    pcall(function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end

local function serverHop()
    queueScriptOnTeleport()
    task.spawn(function()
        task.wait(0.3)
        local ok, servers = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if not ok or not servers or not servers.data then return end
        local currentJob = game.JobId
        for _, s in ipairs(servers.data) do
            if s.id ~= currentJob and s.playing < s.maxPlayers then
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                end)
                return
            end
        end
    end)
end

-- ========== LOOP PRINCIPAL ==========
RunService.RenderStepped:Connect(function()
    if type(updateESP) == "function" then pcall(updateESP) end
    if type(updateFOV) == "function" then pcall(updateFOV) end
    if type(updateHitboxes) == "function" then pcall(updateHitboxes) end
    if Config and Config.FOVChanger and Config.FOVChanger.Enabled then
        Camera.FieldOfView = Config.FOVChanger.Value
    end
end)

-- ========== DISCORD ==========
local function openDiscord()
    pcall(function()
        if setclipboard then
            setclipboard(DISCORD_LINK)
        elseif toclipboard then
            toclipboard(DISCORD_LINK)
        end
    end)
end

-- ========== GUI PRINCIPAL ==========
local gui = Instance.new("ScreenGui")
gui.Name = "SlowHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 9999
gui.Parent = parentGui

local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
local maxW = math.min(900, viewport.X * 0.95)
local maxH = math.min(540, viewport.Y * 0.85)
local NORMAL_SIZE = UDim2.new(0, 500, 0, 340)
local MAXIMIZED_SIZE = UDim2.new(0, maxW, 0, maxH)

-- ========== CÁPSULA ==========
local capsuleGlow = Instance.new("Frame")
capsuleGlow.Name = "CapsuleGlow"
capsuleGlow.Size = UDim2.new(0, 232, 0, 48)
capsuleGlow.Position = UDim2.new(0.5, -116, 0, 6)
capsuleGlow.BackgroundColor3 = PURPLE_BORDER
capsuleGlow.BackgroundTransparency = 0.75
capsuleGlow.BorderSizePixel = 0
capsuleGlow.ZIndex = 1
capsuleGlow.Visible = false
capsuleGlow.Parent = gui
Instance.new("UICorner", capsuleGlow).CornerRadius = UDim.new(1, 0)

local capsule = Instance.new("TextButton")
capsule.Name = "Capsule"
capsule.Size = UDim2.new(0, 220, 0, 36)
capsule.Position = UDim2.new(0.5, -110, 0, 12)
capsule.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
capsule.BackgroundTransparency = 0
capsule.Text = ""
capsule.AutoButtonColor = false
capsule.Active = true
capsule.Visible = false
capsule.ZIndex = 5
capsule.Parent = gui
Instance.new("UICorner", capsule).CornerRadius = UDim.new(1, 0)

local capsuleGradient = Instance.new("UIGradient", capsule)
capsuleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 20, 60)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 12, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 20, 60)),
})
capsuleGradient.Rotation = 0

local capsuleStroke = Instance.new("UIStroke", capsule)
capsuleStroke.Color = PURPLE_BORDER
capsuleStroke.Thickness = 2
capsuleStroke.Transparency = 0.1

local dragIcon = Instance.new("ImageLabel")
dragIcon.Name = "DragIcon"
dragIcon.Size = UDim2.new(0, 22, 0, 22)
dragIcon.Position = UDim2.new(0, 8, 0.5, -11)
dragIcon.BackgroundTransparency = 1
dragIcon.Image = "rbxassetid://79111374854903"
dragIcon.ImageColor3 = Color3.fromRGB(200, 200, 210)
dragIcon.ZIndex = 6
dragIcon.Parent = capsule

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 8, 0, 8)
statusDot.Position = UDim2.new(1, -16, 0.5, -4)
statusDot.BackgroundColor3 = SUCCESS
statusDot.BorderSizePixel = 0
statusDot.ZIndex = 6
statusDot.Parent = capsule
Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

local capsuleText = Instance.new("TextLabel")
capsuleText.Size = UDim2.new(1, -70, 1, 0)
capsuleText.Position = UDim2.new(0, 38, 0, 0)
capsuleText.BackgroundTransparency = 1
capsuleText.Text = "Slow Hub"
capsuleText.TextColor3 = TEXT
capsuleText.Font = Enum.Font.GothamBlack
capsuleText.TextSize = 14
capsuleText.TextXAlignment = Enum.TextXAlignment.Center
capsuleText.TextStrokeTransparency = 0.5
capsuleText.TextStrokeColor3 = PURPLE_BORDER
capsuleText.ZIndex = 6
capsuleText.Parent = capsule

-- ========== KEY GUI ==========
local keyGui = Instance.new("ScreenGui")
keyGui.Name = "SlowHubKey"
keyGui.ResetOnSpawn = false
keyGui.IgnoreGuiInset = true
keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
keyGui.DisplayOrder = 10000
keyGui.Parent = parentGui

local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(0, 400, 0, 300)
keyFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
keyFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
keyFrame.BackgroundTransparency = 0.1
keyFrame.BorderSizePixel = 0
keyFrame.Active = true
keyFrame.Parent = keyGui
Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 24)

local keyStroke = Instance.new("UIStroke", keyFrame)
keyStroke.Color = PURPLE_BORDER
keyStroke.Thickness = 1.5
keyStroke.Transparency = 0.2

local keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1, -32, 0, 30)
keyTitle.Position = UDim2.new(0, 16, 0, 22)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "Slow Hub"
keyTitle.TextColor3 = TEXT
keyTitle.Font = Enum.Font.GothamBold
keyTitle.TextSize = 20
keyTitle.TextXAlignment = Enum.TextXAlignment.Left
keyTitle.Parent = keyFrame

local keySub = Instance.new("TextLabel")
keySub.Size = UDim2.new(1, -32, 0, 20)
keySub.Position = UDim2.new(0, 16, 0, 54)
keySub.BackgroundTransparency = 1
keySub.Text = "Key Authentication System"
keySub.TextColor3 = TEXTDIM
keySub.Font = Enum.Font.Gotham
keySub.TextSize = 12
keySub.TextXAlignment = Enum.TextXAlignment.Left
keySub.Parent = keyFrame

local keyLine = Instance.new("Frame")
keyLine.Size = UDim2.new(1, -32, 0, 1)
keyLine.Position = UDim2.new(0, 16, 0, 84)
keyLine.BackgroundColor3 = STROKE
keyLine.BorderSizePixel = 0
keyLine.Parent = keyFrame

local keyInfo = Instance.new("TextLabel")
keyInfo.Size = UDim2.new(1, -32, 0, 40)
keyInfo.Position = UDim2.new(0, 16, 0, 96)
keyInfo.BackgroundTransparency = 1
keyInfo.Text = "Insira sua key para continuar."
keyInfo.TextColor3 = TEXTDIM
keyInfo.Font = Enum.Font.Gotham
keyInfo.TextSize = 12
keyInfo.TextXAlignment = Enum.TextXAlignment.Left
keyInfo.TextYAlignment = Enum.TextYAlignment.Top
keyInfo.TextWrapped = true
keyInfo.Parent = keyFrame

local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(1, -32, 0, 40)
keyInput.Position = UDim2.new(0, 16, 0, 138)
keyInput.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
keyInput.BorderSizePixel = 0
keyInput.Text = ""
keyInput.PlaceholderText = "Digite sua key..."
keyInput.PlaceholderColor3 = TEXTDIM
keyInput.TextColor3 = TEXT
keyInput.Font = Enum.Font.Gotham
keyInput.TextSize = 13
keyInput.ClearTextOnFocus = false
keyInput.Parent = keyFrame
Instance.new("UICorner", keyInput).CornerRadius = UDim.new(0, 8)

local discordBtn = Instance.new("TextButton")
discordBtn.Size = UDim2.new(1, -32, 0, 36)
discordBtn.Position = UDim2.new(0, 16, 0, 188)
discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordBtn.Text = "Adquirir a Key"
discordBtn.TextColor3 = Color3.new(1, 1, 1)
discordBtn.Font = Enum.Font.GothamBold
discordBtn.TextSize = 12
discordBtn.AutoButtonColor = false
discordBtn.Parent = keyFrame
Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0, 8)

local submitBtn = Instance.new("TextButton")
submitBtn.Size = UDim2.new(1, -32, 0, 38)
submitBtn.Position = UDim2.new(0, 16, 1, -56)
submitBtn.BackgroundColor3 = ACCENT
submitBtn.Text = "VALIDAR KEY"
submitBtn.TextColor3 = Color3.new(1, 1, 1)
submitBtn.Font = Enum.Font.GothamBold
submitBtn.TextSize = 13
submitBtn.AutoButtonColor = false
submitBtn.Parent = keyFrame
Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0, 8)

local keyStatus = Instance.new("TextLabel")
keyStatus.Size = UDim2.new(1, -32, 0, 16)
keyStatus.Position = UDim2.new(0, 16, 1, -74)
keyStatus.BackgroundTransparency = 1
keyStatus.Text = ""
keyStatus.TextColor3 = DANGER
keyStatus.Font = Enum.Font.Gotham
keyStatus.TextSize = 11
keyStatus.TextXAlignment = Enum.TextXAlignment.Left
keyStatus.Parent = keyFrame

discordBtn.MouseButton1Click:Connect(openDiscord)

-- ========== PAINEL PRINCIPAL ==========
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = NORMAL_SIZE
main.Position = UDim2.new(0.5, -250, 0.5, -170)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
main.BackgroundTransparency = 0.15
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true
main.Visible = false
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 24)

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = PURPLE_BORDER
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.2

local starContainer = Instance.new("Frame")
starContainer.Size = UDim2.new(1, 0, 1, 0)
starContainer.BackgroundColor3 = Color3.fromRGB(6, 4, 15)
starContainer.BackgroundTransparency = 0.15
starContainer.BorderSizePixel = 0
starContainer.ClipsDescendants = true
starContainer.ZIndex = 1
starContainer.Parent = main
Instance.new("UICorner", starContainer).CornerRadius = UDim.new(0, 24)

local stars = {}
for i = 1, 60 do
    local size = math.random(1, 3)
    local star = Instance.new("Frame")
    star.Size = UDim2.new(0, size, 0, size)
    star.Position = UDim2.new(math.random(), 0, math.random(), 0)
    star.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    star.BackgroundTransparency = math.random(10, 70) / 100
    star.BorderSizePixel = 0
    star.ZIndex = 2
    star.Parent = starContainer
    Instance.new("UICorner", star).CornerRadius = UDim.new(1, 0)
    stars[i] = {frame = star, speed = math.random(30, 90) / 100000}
end

local starOverlay = Instance.new("Frame")
starOverlay.Size = UDim2.new(1, 0, 1, 0)
starOverlay.BackgroundColor3 = Color3.fromRGB(10, 8, 18)
starOverlay.BackgroundTransparency = 0.6
starOverlay.BorderSizePixel = 0
starOverlay.ZIndex = 3
starOverlay.Parent = starContainer
Instance.new("UICorner", starOverlay).CornerRadius = UDim.new(0, 24)

RunService.RenderStepped:Connect(function(dt)
    if not stars then return end
    for i, s in ipairs(stars) do
        if s and s.frame and s.frame.Parent then
            local pos = s.frame.Position
            local newY = pos.Y.Scale + s.speed * dt * 100
            if newY > 1 then
                newY = -0.05
                s.frame.Position = UDim2.new(math.random(), 0, newY, 0)
            else
                s.frame.Position = UDim2.new(pos.X.Scale, 0, newY, 0)
            end
        end
    end
end)

-- ========== HEADER / FOOTER / SIDEBAR ==========
local HEADER_H = 36
local SIDEBAR_W = 140
local FOOTER_H = 42

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, HEADER_H)
header.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
header.BackgroundTransparency = 0.1
header.BorderSizePixel = 0
header.Active = true
header.ZIndex = 10
header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 24)

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 20)
headerFix.Position = UDim2.new(0, 0, 1, -20)
headerFix.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
headerFix.BackgroundTransparency = 0.1
headerFix.BorderSizePixel = 0
headerFix.ZIndex = 10
headerFix.Parent = header

local headerStroke = Instance.new("UIStroke", header)
headerStroke.Color = PURPLE_BORDER
headerStroke.Thickness = 1
headerStroke.Transparency = 0.2

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -180, 1, 0)
titleLbl.Position = UDim2.new(0, 80, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "Slow Hub"
titleLbl.TextColor3 = TEXT
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.TextSize = 14
titleLbl.TextXAlignment = Enum.TextXAlignment.Center
titleLbl.ZIndex = 11
titleLbl.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 26, 0, 26)
minBtn.Position = UDim2.new(1, -88, 0.5, -13)
minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
minBtn.Text = ""
minBtn.AutoButtonColor = false
minBtn.ZIndex = 11
minBtn.Parent = header
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

local minIcon = Instance.new("ImageLabel")
minIcon.Size = UDim2.new(0, 16, 0, 16)
minIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
minIcon.BackgroundTransparency = 1
minIcon.Image = "rbxassetid://6031091004"
minIcon.ImageColor3 = TEXT
minIcon.ZIndex = 12
minIcon.Parent = minBtn

local maxBtn = Instance.new("TextButton")
maxBtn.Size = UDim2.new(0, 26, 0, 26)
maxBtn.Position = UDim2.new(1, -58, 0.5, -13)
maxBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
maxBtn.Text = ""
maxBtn.AutoButtonColor = false
maxBtn.ZIndex = 11
maxBtn.Parent = header
Instance.new("UICorner", maxBtn).CornerRadius = UDim.new(0, 6)

local maxIcon = Instance.new("ImageLabel")
maxIcon.Size = UDim2.new(0, 16, 0, 16)
maxIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
maxIcon.BackgroundTransparency = 1
maxIcon.Image = "rbxassetid://116037492872893"
maxIcon.ImageColor3 = TEXT
maxIcon.ZIndex = 12
maxIcon.Parent = maxBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -28, 0.5, -13)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
closeBtn.Text = ""
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 11
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

local closeIcon = Instance.new("ImageLabel")
closeIcon.Size = UDim2.new(0, 16, 0, 16)
closeIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
closeIcon.BackgroundTransparency = 1
closeIcon.Image = "rbxassetid://14219436180"
closeIcon.ImageColor3 = TEXT
closeIcon.ZIndex = 12
closeIcon.Parent = closeBtn

-- ========== FOOTER ==========
local footer = Instance.new("Frame")
footer.Size = UDim2.new(1, 0, 0, FOOTER_H)
footer.Position = UDim2.new(0, 0, 1, -FOOTER_H)
footer.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
footer.BackgroundTransparency = 0.15
footer.BorderSizePixel = 0
footer.ZIndex = 50
footer.Parent = main
Instance.new("UICorner", footer).CornerRadius = UDim.new(0, 24)

local footerFix = Instance.new("Frame")
footerFix.Size = UDim2.new(1, 0, 0, 20)
footerFix.Position = UDim2.new(0, 0, 0, 0)
footerFix.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
footerFix.BackgroundTransparency = 0.15
footerFix.BorderSizePixel = 0
footerFix.ZIndex = 51
footerFix.Parent = footer

local footerAvatar = Instance.new("ImageLabel")
footerAvatar.Size = UDim2.new(0, 26, 0, 26)
footerAvatar.Position = UDim2.new(0, 10, 0.5, -13)
footerAvatar.BackgroundColor3 = CARD
footerAvatar.BorderSizePixel = 0
footerAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=100&h=100"
footerAvatar.ZIndex = 51
footerAvatar.Parent = footer
Instance.new("UICorner", footerAvatar).CornerRadius = UDim.new(1, 0)

local footerName = Instance.new("TextLabel")
footerName.Size = UDim2.new(1, -60, 0, 14)
footerName.Position = UDim2.new(0, 44, 0, 6)
footerName.BackgroundTransparency = 1
footerName.Text = LocalPlayer.DisplayName or LocalPlayer.Name
footerName.TextColor3 = TEXT
footerName.Font = Enum.Font.GothamBold
footerName.TextSize = 10
footerName.TextXAlignment = Enum.TextXAlignment.Left
footerName.ZIndex = 51
footerName.Parent = footer

local footerUser = Instance.new("TextLabel")
footerUser.Size = UDim2.new(1, -60, 0, 12)
footerUser.Position = UDim2.new(0, 44, 0, 21)
footerUser.BackgroundTransparency = 1
footerUser.Text = "@" .. LocalPlayer.Name
footerUser.TextColor3 = TEXTDIM
footerUser.Font = Enum.Font.Gotham
footerUser.TextSize = 9
footerUser.TextXAlignment = Enum.TextXAlignment.Left
footerUser.ZIndex = 51
footerUser.Parent = footer

-- ========== SIDEBAR ==========
local sidebarHolder = Instance.new("Frame")
sidebarHolder.Size = UDim2.new(0, SIDEBAR_W, 1, -(HEADER_H + FOOTER_H + 24))
sidebarHolder.Position = UDim2.new(0, 0, 0, HEADER_H)
sidebarHolder.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
sidebarHolder.BackgroundTransparency = 0.5
sidebarHolder.BorderSizePixel = 0
sidebarHolder.ZIndex = 10
sidebarHolder.Parent = main

local sidebarScroll = Instance.new("ScrollingFrame")
sidebarScroll.Size = UDim2.new(1, 0, 1, 0)
sidebarScroll.BackgroundTransparency = 1
sidebarScroll.BorderSizePixel = 0
sidebarScroll.ScrollBarThickness = 3
sidebarScroll.ScrollBarImageColor3 = ACCENT
sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
sidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
sidebarScroll.ZIndex = 10
sidebarScroll.Parent = sidebarHolder

local sidebarLayout = Instance.new("UIListLayout", sidebarScroll)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Padding = UDim.new(0, 2)

local sidebarPad = Instance.new("UIPadding", sidebarScroll)
sidebarPad.PaddingTop = UDim.new(0, 6)
sidebarPad.PaddingBottom = UDim.new(0, 6)
sidebarPad.PaddingLeft = UDim.new(0, 6)
sidebarPad.PaddingRight = UDim.new(0, 6)

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -SIDEBAR_W, 1, -(HEADER_H + FOOTER_H))
content.Position = UDim2.new(0, SIDEBAR_W, 0, HEADER_H)
content.BackgroundTransparency = 1
content.ZIndex = 10
content.Parent = main

local pages = {}
local buttons = {}

local function setPage(name)
    for n, page in pairs(pages) do
        page.Visible = (n == name)
    end
    for n, btn in pairs(buttons) do
        if n == name then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
            local img = btn:FindFirstChildOfClass("ImageLabel")
            if img then img.ImageColor3 = Color3.new(1, 1, 1) end
            local lbl = btn:FindFirstChild("TabLabel")
            if lbl then lbl.TextColor3 = Color3.new(1, 1, 1) end
        else
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 48)}):Play()
            local img = btn:FindFirstChildOfClass("ImageLabel")
            if img then img.ImageColor3 = TEXTDIM end
            local lbl = btn:FindFirstChild("TabLabel")
            if lbl then lbl.TextColor3 = TEXTDIM end
        end
    end
end

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = ACCENT
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.ZIndex = 11
    page.Parent = content
    pages[name] = page
    return page
end

local function createTabButton(name, iconId)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    btn.BackgroundTransparency = 0.35
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 11
    btn.Parent = sidebarScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0, 14, 0, 14)
    img.Position = UDim2.new(0, 8, 0.5, -7)
    img.BackgroundTransparency = 1
    img.Image = iconId
    img.ImageColor3 = TEXTDIM
    img.ZIndex = 12
    img.Parent = btn
    local lbl = Instance.new("TextLabel")
    lbl.Name = "TabLabel"
    lbl.Size = UDim2.new(1, -30, 1, 0)
    lbl.Position = UDim2.new(0, 26, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = TEXTDIM
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 12
    lbl.Parent = btn
    btn.MouseButton1Click:Connect(function()
        setPage(name)
    end)
    buttons[name] = btn
end

local function addPageTitle(page, text, subtext)
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -24, 0, 22)
    title.Position = UDim2.new(0, 12, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = text
    title.TextColor3 = TEXT
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 12
    title.Parent = page
    if subtext then
        local sub = Instance.new("TextLabel")
        sub.Size = UDim2.new(1, -24, 0, 14)
        sub.Position = UDim2.new(0, 12, 0, 30)
        sub.BackgroundTransparency = 1
        sub.Text = subtext
        sub.TextColor3 = TEXTDIM
        sub.Font = Enum.Font.Gotham
        sub.TextSize = 10
        sub.TextXAlignment = Enum.TextXAlignment.Left
        sub.ZIndex = 12
        sub.Parent = page
    end
end

-- ========== HELPERS UI ==========
local function makeCard(parent, y, h)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -24, 0, h or 32)
    card.Position = UDim2.new(0, 12, 0, y)
    card.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    card.BackgroundTransparency = 0.7
    card.BorderSizePixel = 0
    card.ZIndex = 12
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
    return card
end

local function makeLabel(card, text, x, width)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, width or 200, 1, 0)
    lbl.Position = UDim2.new(0, x or 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = TEXT
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 13
    lbl.Parent = card
    return lbl
end

local function makeToggle(card, defaultState, callback)
    local state = defaultState or false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 20)
    btn.Position = UDim2.new(1, -50, 0.5, -10)
    btn.BackgroundColor3 = state and ACCENT or CARD
    btn.Text = state and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.AutoButtonColor = false
    btn.ZIndex = 13
    btn.Parent = card
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and ACCENT or CARD
        btn.Text = state and "ON" or "OFF"
        if callback then callback(state) end
    end)
    return btn
end

local function makeButton(parent, text, y, w, h, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, w or 120, 0, h or 26)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = color or Color3.fromRGB(35, 35, 42)
    btn.Text = text
    btn.TextColor3 = TEXT
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.AutoButtonColor = false
    btn.ZIndex = 13
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(55, 55, 65)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = color or Color3.fromRGB(35, 35, 42)}):Play()
    end)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function makeInput(parent, y, placeholder, w, callback)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, w or 100, 0, 24)
    box.Position = UDim2.new(0, 10, 0, y)
    box.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    box.BorderSizePixel = 0
    box.Text = ""
    box.PlaceholderText = placeholder
    box.PlaceholderColor3 = TEXTDIM
    box.TextColor3 = TEXT
    box.Font = Enum.Font.Gotham
    box.TextSize = 10
    box.ClearTextOnFocus = false
    box.ZIndex = 13
    box.Parent = parent
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    if callback then
        box.FocusLost:Connect(function() callback(box.Text) end)
    end
    return box
end

-- ========== NOTIFICAÇÕES ==========
local function addNotif(title, desc, duration)
    duration = duration or 4
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 300, 0, 60)
    notif.Position = UDim2.new(1, 20, 1, -70)
    notif.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    notif.BackgroundTransparency = 0.05
    notif.BorderSizePixel = 0
    notif.ZIndex = 100
    notif.Parent = gui
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", notif)
    stroke.Color = PURPLE_BORDER
    stroke.Thickness = 1.2
    stroke.Transparency = 0.3

    local nIcon = Instance.new("ImageLabel")
    nIcon.Size = UDim2.new(0, 28, 0, 28)
    nIcon.Position = UDim2.new(0, 8, 0, 16)
    nIcon.BackgroundTransparency = 1
    nIcon.Image = ICONS.Star
    nIcon.ImageColor3 = PURPLE_BORDER
    nIcon.ZIndex = 102
    nIcon.Parent = notif

    local nTitle = Instance.new("TextLabel")
    nTitle.Size = UDim2.new(1, -60, 0, 18)
    nTitle.Position = UDim2.new(0, 44, 0, 8)
    nTitle.BackgroundTransparency = 1
    nTitle.Text = title or "Slow Hub"
    nTitle.TextColor3 = TEXT
    nTitle.Font = Enum.Font.GothamBold
    nTitle.TextSize = 12
    nTitle.TextXAlignment = Enum.TextXAlignment.Left
    nTitle.ZIndex = 102
    nTitle.Parent = notif

    local nDesc = Instance.new("TextLabel")
    nDesc.Size = UDim2.new(1, -60, 0, 24)
    nDesc.Position = UDim2.new(0, 44, 0, 26)
    nDesc.BackgroundTransparency = 1
    nDesc.Text = desc or ""
    nDesc.TextColor3 = TEXTDIM
    nDesc.Font = Enum.Font.Gotham
    nDesc.TextSize = 10
    nDesc.TextXAlignment = Enum.TextXAlignment.Left
    nDesc.TextWrapped = true
    nDesc.ZIndex = 102
    nDesc.Parent = notif

    local closeNotif = Instance.new("TextButton")
    closeNotif.Size = UDim2.new(0, 20, 0, 20)
    closeNotif.Position = UDim2.new(1, -26, 0, 6)
    closeNotif.BackgroundTransparency = 1
    closeNotif.Text = ""
    closeNotif.ZIndex = 103
    closeNotif.Parent = notif

    local closeNotifIcon = Instance.new("ImageLabel")
    closeNotifIcon.Size = UDim2.new(0, 12, 0, 12)
    closeNotifIcon.Position = UDim2.new(0.5, -6, 0.5, -6)
    closeNotifIcon.BackgroundTransparency = 1
    closeNotifIcon.Image = "rbxassetid://14219436180"
    closeNotifIcon.ImageColor3 = TEXTDIM
    closeNotifIcon.ZIndex = 104
    closeNotifIcon.Parent = closeNotif

    local dismissed = false
    local function dismiss()
        if dismissed then return end
        dismissed = true
        if notif and notif.Parent then
            TweenService:Create(notif, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                Position = UDim2.new(1, 20, notif.Position.Y.Scale, notif.Position.Y.Offset)
            }):Play()
            task.wait(0.3)
            if notif then notif:Destroy() end
        end
    end

    closeNotif.MouseButton1Click:Connect(dismiss)

    TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -320, 1, -70)
    }):Play()

    task.delay(duration, dismiss)
end

-- ========== HOME ==========
local homePage = createPage("Home")
addPageTitle(homePage, "Home", "Bem-vindo ao Slow Hub")

local welcomeCard = makeCard(homePage, 56, 70)
local welcomeLbl = Instance.new("TextLabel")
welcomeLbl.Size = UDim2.new(1, -20, 0, 24)
welcomeLbl.Position = UDim2.new(0, 10, 0, 10)
welcomeLbl.BackgroundTransparency = 1
welcomeLbl.Text = "Olá, " .. (LocalPlayer.DisplayName or LocalPlayer.Name) .. " ✌️"
welcomeLbl.TextColor3 = TEXT
welcomeLbl.Font = Enum.Font.GothamBold
welcomeLbl.TextSize = 14
welcomeLbl.TextXAlignment = Enum.TextXAlignment.Left
welcomeLbl.ZIndex = 13
welcomeLbl.Parent = welcomeCard

local creditLbl = Instance.new("TextLabel")
creditLbl.Size = UDim2.new(1, -20, 0, 16)
creditLbl.Position = UDim2.new(0, 10, 0, 36)
creditLbl.BackgroundTransparency = 1
creditLbl.Text = "Criado por Spzinx • Discord: tav.x"
creditLbl.TextColor3 = TEXTDIM
creditLbl.Font = Enum.Font.Gotham
creditLbl.TextSize = 10
creditLbl.TextXAlignment = Enum.TextXAlignment.Left
creditLbl.ZIndex = 13
creditLbl.Parent = welcomeCard

local infoCard = makeCard(homePage, 136, 32)
makeLabel(infoCard, "Use o menu lateral para acessar as funções.", 10, 380)

-- ========== JOGADORES ==========
local playersPage = createPage("Jogadores")
addPageTitle(playersPage, "Jogadores", "Lista de jogadores no servidor")

local searchBar = Instance.new("Frame")
searchBar.Size = UDim2.new(1, -24, 0, 30)
searchBar.Position = UDim2.new(0, 12, 0, 50)
searchBar.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
searchBar.BackgroundTransparency = 0.4
searchBar.BorderSizePixel = 0
searchBar.ZIndex = 12
searchBar.Parent = playersPage
Instance.new("UICorner", searchBar).CornerRadius = UDim.new(0, 8)

local searchIcon = Instance.new("ImageLabel")
searchIcon.Size = UDim2.new(0, 14, 0, 14)
searchIcon.Position = UDim2.new(0, 8, 0.5, -7)
searchIcon.BackgroundTransparency = 1
searchIcon.Image = ICONS.Person
searchIcon.ImageColor3 = TEXTDIM
searchIcon.ZIndex = 13
searchIcon.Parent = searchBar

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -30, 1, 0)
searchBox.Position = UDim2.new(0, 28, 0, 0)
searchBox.BackgroundTransparency = 1
searchBox.Text = ""
searchBox.PlaceholderText = "Buscar jogador..."
searchBox.PlaceholderColor3 = TEXTDIM
searchBox.TextColor3 = TEXT
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 11
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false
searchBox.ZIndex = 13
searchBox.Parent = searchBar

local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1, -24, 1, -90)
playerScroll.Position = UDim2.new(0, 12, 0, 86)
playerScroll.BackgroundTransparency = 1
playerScroll.BorderSizePixel = 0
playerScroll.ScrollBarThickness = 3
playerScroll.ScrollBarImageColor3 = ACCENT
playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
playerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerScroll.ZIndex = 12
playerScroll.Parent = playersPage

local playerLayout = Instance.new("UIListLayout", playerScroll)
playerLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerLayout.Padding = UDim.new(0, 4)

local playerPad = Instance.new("UIPadding", playerScroll)
playerPad.PaddingTop = UDim.new(0, 2)
playerPad.PaddingBottom = UDim.new(0, 6)
playerPad.PaddingLeft = UDim.new(0, 2)
playerPad.PaddingRight = UDim.new(0, 2)

local playerCards = {}

local function createPlayerCard(plr, order)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -4, 0, 40)
    card.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    card.BackgroundTransparency = 0.3
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.ZIndex = 13
    card.Parent = playerScroll
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0, 28, 0, 28)
    avatar.Position = UDim2.new(0, 8, 0.5, -14)
    avatar.BackgroundColor3 = CARD
    avatar.BorderSizePixel = 0
    avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. plr.UserId .. "&w=100&h=100"
    avatar.ZIndex = 14
    avatar.Parent = card
    Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -140, 0, 14)
    nameLbl.Position = UDim2.new(0, 44, 0, 5)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = plr.DisplayName or plr.Name
    nameLbl.TextColor3 = TEXT
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 11
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex = 14
    nameLbl.Parent = card

    local userLbl = Instance.new("TextLabel")
    userLbl.Size = UDim2.new(1, -140, 0, 12)
    userLbl.Position = UDim2.new(0, 44, 0, 20)
    userLbl.BackgroundTransparency = 1
    userLbl.Text = "@" .. plr.Name
    userLbl.TextColor3 = TEXTDIM
    userLbl.Font = Enum.Font.Gotham
    userLbl.TextSize = 9
    userLbl.TextXAlignment = Enum.TextXAlignment.Left
    userLbl.ZIndex = 14
    userLbl.Parent = card

    local gotoBtn = Instance.new("TextButton")
    gotoBtn.Size = UDim2.new(0, 60, 0, 24)
    gotoBtn.Position = UDim2.new(1, -68, 0.5, -12)
    gotoBtn.BackgroundColor3 = ACCENT
    gotoBtn.Text = "Goto"
    gotoBtn.TextColor3 = Color3.new(1, 1, 1)
    gotoBtn.Font = Enum.Font.GothamBold
    gotoBtn.TextSize = 10
    gotoBtn.AutoButtonColor = false
    gotoBtn.ZIndex = 14
    gotoBtn.Parent = card
    Instance.new("UICorner", gotoBtn).CornerRadius = UDim.new(0, 6)

    gotoBtn.MouseButton1Click:Connect(function()
        local ok = gotoPlayer(plr)
        if ok then
            addNotif("Goto", "Teleportado para " .. plr.Name)
        else
            addNotif("Erro", "Não foi possível teleportar.")
        end
    end)

    playerCards[plr.UserId] = {
        frame = card,
        name = string.lower(plr.DisplayName or plr.Name),
        username = string.lower(plr.Name)
    }
end

local function refreshPlayers()
    for _, data in pairs(playerCards) do
        if data.frame then data.frame:Destroy() end
    end
    playerCards = {}
    local order = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            order += 1
            createPlayerCard(plr, order)
        end
    end
end

refreshPlayers()

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = string.lower(searchBox.Text or "")
    for _, data in pairs(playerCards) do
        if data.frame and data.frame.Parent then
            local match = q == ""
                or string.find(data.name, q, 1, true)
                or string.find(data.username, q, 1, true)
            data.frame.Visible = match
        end
    end
end)

Players.PlayerAdded:Connect(function()
    task.wait(1)
    refreshPlayers()
end)

Players.PlayerRemoving:Connect(function(plr)
    local data = playerCards[plr.UserId]
    if data and data.frame then data.frame:Destroy() end
    playerCards[plr.UserId] = nil
end)

-- ========== MOVIMENTO ==========
local movementPage = createPage("Movimento")
addPageTitle(movementPage, "Movimento", "Noclip, Speed, Fly, Inf Jump")

local noclipCard = makeCard(movementPage, 56, 32)
makeLabel(noclipCard, "Noclip", 10, 200)
makeToggle(noclipCard, false, function(s)
    Config.Noclip.Enabled = s
    setNoclip(s)
end)

local speedCard = makeCard(movementPage, 94, 32)
makeLabel(speedCard, "Speed", 10, 150)
local speedInput = makeInput(speedCard, 6, tostring(Config.Speed.Value), 50, function(txt)
    local n = tonumber(txt)
    if n then Config.Speed.Value = math.clamp(n, 16, 200) end
end)
speedInput.Position = UDim2.new(1, -110, 0.5, -12)
makeToggle(speedCard, false, function(s)
    Config.Speed.Enabled = s
    setSpeed(s)
end)

local flyCard = makeCard(movementPage, 132, 32)
makeLabel(flyCard, "Fly ⚠ Pode não funcionar em alguns jogos", 10, 260)
makeToggle(flyCard, false, function(s)
    Config.Fly.Enabled = s
    setFly(s)
end)

local jumpCard = makeCard(movementPage, 170, 32)
makeLabel(jumpCard, "Infinite Jump", 10, 200)
makeToggle(jumpCard, false, function(s)
    Config.InfiniteJump.Enabled = s
    setInfJump(s)
end)

-- ========== TELEPORTE ==========
local tpPage = createPage("Teleporte")
addPageTitle(tpPage, "Teleporte", "Salvar / Ir para posição")

local savedList = Instance.new("ScrollingFrame")
savedList.Size = UDim2.new(1, -24, 1, -120)
savedList.Position = UDim2.new(0, 12, 0, 50)
savedList.BackgroundTransparency = 1
savedList.BorderSizePixel = 0
savedList.ScrollBarThickness = 3
savedList.ScrollBarImageColor3 = ACCENT
savedList.CanvasSize = UDim2.new(0, 0, 0, 0)
savedList.AutomaticCanvasSize = Enum.AutomaticSize.Y
savedList.ZIndex = 12
savedList.Parent = tpPage

local savedLayout = Instance.new("UIListLayout", savedList)
savedLayout.SortOrder = Enum.SortOrder.LayoutOrder
savedLayout.Padding = UDim.new(0, 4)

local savedSlots = {}

local function refreshSavedSlots()
    for _, obj in ipairs(savedList:GetChildren()) do
        if obj:IsA("Frame") then obj:Destroy() end
    end
    local order = 0
    for i, cf in pairs(savedSlots) do
        order += 1
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -4, 0, 32)
        card.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
        card.BackgroundTransparency = 0.3
        card.BorderSizePixel = 0
        card.LayoutOrder = order
        card.ZIndex = 13
        card.Parent = savedList
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -130, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = "Slot " .. i
        lbl.TextColor3 = TEXT
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 14
        lbl.Parent = card

        local goBtn = Instance.new("TextButton")
        goBtn.Size = UDim2.new(0, 44, 0, 22)
        goBtn.Position = UDim2.new(1, -100, 0.5, -11)
        goBtn.BackgroundColor3 = ACCENT
        goBtn.Text = "Ir"
        goBtn.TextColor3 = Color3.new(1, 1, 1)
        goBtn.Font = Enum.Font.GothamBold
        goBtn.TextSize = 9
        goBtn.AutoButtonColor = false
        goBtn.ZIndex = 14
        goBtn.Parent = card
        Instance.new("UICorner", goBtn).CornerRadius = UDim.new(0, 6)
        goBtn.MouseButton1Click:Connect(function()
            if gotoPosition(i) then
                addNotif("Teleporte", "Foi para o slot " .. i)
            end
        end)

        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0, 44, 0, 22)
        delBtn.Position = UDim2.new(1, -52, 0.5, -11)
        delBtn.BackgroundColor3 = DANGER
        delBtn.Text = "X"
        delBtn.TextColor3 = Color3.new(1, 1, 1)
        delBtn.Font = Enum.Font.GothamBold
        delBtn.TextSize = 9
        delBtn.AutoButtonColor = false
        delBtn.ZIndex = 14
        delBtn.Parent = card
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 6)
        delBtn.MouseButton1Click:Connect(function()
            savedSlots[i] = nil
            refreshSavedSlots()
        end)
    end
end

local saveBtn = makeButton(tpPage, "💾 Salvar Posição Atual", 0, 180, 28, Color3.fromRGB(35, 35, 42), function()
    local nextSlot = 1
    while savedSlots[nextSlot] do nextSlot += 1 end
    if savePosition(nextSlot) then
        savedSlots[nextSlot] = true
        refreshSavedSlots()
        addNotif("Teleporte", "Posição salva no slot " .. nextSlot)
    end
end)
saveBtn.Position = UDim2.new(0, 12, 1, -50)

-- ========== VISUAL ==========
local visualPage = createPage("Visual")
addPageTitle(visualPage, "Visual", "ESP, Fullbright")

local espCard = makeCard(visualPage, 56, 32)
makeLabel(espCard, "ESP", 10, 200)
makeToggle(espCard, false, function(s) Config.ESP.Enabled = s end)

local espNameCard = makeCard(visualPage, 94, 32)
makeLabel(espNameCard, "ESP • Mostrar Nome", 10, 200)
makeToggle(espNameCard, false, function(s) Config.ESP.ShowName = s end)

local espDistCard = makeCard(visualPage, 132, 32)
makeLabel(espDistCard, "ESP • Mostrar Distância", 10, 200)
makeToggle(espDistCard, false, function(s) Config.ESP.ShowDistance = s end)

local espHealthCard = makeCard(visualPage, 170, 32)
makeLabel(espHealthCard, "ESP • Mostrar Vida", 10, 200)
makeToggle(espHealthCard, false, function(s) Config.ESP.ShowHealth = s end)

local espHLCard = makeCard(visualPage, 208, 32)
makeLabel(espHLCard, "ESP • Highlight", 10, 200)
makeToggle(espHLCard, false, function(s) Config.ESP.ShowHighlight = s end)

local espTMCard = makeCard(visualPage, 246, 32)
makeLabel(espTMCard, "ESP • TeamCheck", 10, 200)
makeToggle(espTMCard, false, function(s) Config.ESP.TeamCheck = s end)

local fbCard = makeCard(visualPage, 284, 32)
makeLabel(fbCard, "Fullbright", 10, 200)
makeToggle(fbCard, false, function(s)
    Config.Fullbright.Enabled = s
    setFullbright(s)
end)

-- ========== HITBOX ==========
local hitboxPage = createPage("Hitbox")
addPageTitle(hitboxPage, "Hitbox", "Tamanho, cor e quadro visual")

local hbCard = makeCard(hitboxPage, 56, 32)
makeLabel(hbCard, "Hitbox Expander", 10, 200)
makeToggle(hbCard, false, function(s)
    Config.Hitbox.Enabled = s
end)

local hbSizeCard = makeCard(hitboxPage, 94, 32)
makeLabel(hbSizeCard, "Tamanho", 10, 150)
local hbSizeInput = makeInput(hbSizeCard, 6, tostring(Config.Hitbox.Size), 50, function(txt)
    local n = tonumber(txt)
    if n then Config.Hitbox.Size = math.clamp(n, 1, 20) end
end)
hbSizeInput.Position = UDim2.new(1, -70, 0.5, -12)

local hbShowCard = makeCard(hitboxPage, 132, 32)
makeLabel(hbShowCard, "Mostrar Quadro Visual", 10, 200)
makeToggle(hbShowCard, false, function(s)
    Config.Hitbox.ShowBox = s
end)

-- ========== MIRA ==========
local miraPage = createPage("Mira")
addPageTitle(miraPage, "Mira", "Aimbot, FOV")

local aimCard = makeCard(miraPage, 56, 32)
makeLabel(aimCard, "Aimbot", 10, 200)
makeToggle(aimCard, false, function(s)
    Config.Aimbot.Enabled = s
    if s then startAimbot() end
end)

local aimShotCard = makeCard(miraPage, 94, 32)
makeLabel(aimShotCard, "Aimbot • Auto Shot", 10, 200)
makeToggle(aimShotCard, false, function(s) Config.Aimbot.AutoShot = s end)

local aimTMCard = makeCard(miraPage, 132, 32)
makeLabel(aimTMCard, "Aimbot • TeamCheck", 10, 200)
makeToggle(aimTMCard, false, function(s) Config.Aimbot.TeamCheck = s end)

local aimTargetCard = makeCard(miraPage, 170, 32)
makeLabel(aimTargetCard, "Alvo (Head / Torso)", 10, 150)
local targetInput = makeInput(aimTargetCard, 6, Config.Aimbot.Target, 70, function(txt)
    if txt == "Head" or txt == "Torso" then Config.Aimbot.Target = txt end
end)
targetInput.Position = UDim2.new(1, -90, 0.5, -12)

local aimSmoothCard = makeCard(miraPage, 208, 32)
makeLabel(aimSmoothCard, "Suavidade (0.05 - 1)", 10, 150)
local smoothInput = makeInput(aimSmoothCard, 6, tostring(Config.Aimbot.Smoothness), 60, function(txt)
    local n = tonumber(txt)
    if n then Config.Aimbot.Smoothness = math.clamp(n, 0.05, 1) end
end)
smoothInput.Position = UDim2.new(1, -80, 0.5, -12)

local fovCard = makeCard(miraPage, 246, 32)
makeLabel(fovCard, "FOV Circle", 10, 200)
makeToggle(fovCard, false, function(s) Config.Aimbot.FOVEnabled = s end)

local fovSizeCard = makeCard(miraPage, 284, 32)
makeLabel(fovSizeCard, "Tamanho FOV", 10, 150)
local fovSizeInput = makeInput(fovSizeCard, 6, tostring(Config.Aimbot.FOVSize), 50, function(txt)
    local n = tonumber(txt)
    if n then Config.Aimbot.FOVSize = math.clamp(n, 20, 500) end
end)
fovSizeInput.Position = UDim2.new(1, -70, 0.5, -12)

local fovChangeCard = makeCard(miraPage, 322, 32)
makeLabel(fovChangeCard, "FOV Changer", 10, 200)
makeToggle(fovChangeCard, false, function(s)
    Config.FOVChanger.Enabled = s
    setFOVChanger(s)
end)

-- ========== ANTI ==========
local antiPage = createPage("Anti")
addPageTitle(antiPage, "Anti", "Anti-Fling, Anti-AFK")

local afCard = makeCard(antiPage, 56, 32)
makeLabel(afCard, "Anti-Fling", 10, 200)
makeToggle(afCard, false, function(s)
    Config.AntiFling.Enabled = s
    setAntiFling(s)
end)

local afkCard = makeCard(antiPage, 94, 32)
makeLabel(afkCard, "Anti-AFK", 10, 200)
makeToggle(afkCard, false, function(s)
    Config.AntiAFK.Enabled = s
    setAntiAFK(s)
end)

-- ========== SERVIDOR ==========
local serverPage = createPage("Servidor")
addPageTitle(serverPage, "Servidor", "Server Hop, Rejoin")

local rejoinCard = makeCard(serverPage, 56, 40)
makeLabel(rejoinCard, "Rejoin (entrar de novo)", 10, 200)
local rejoinBtn = makeButton(rejoinCard, "Rejoin", 7, 80, 26, ACCENT, function()
    addNotif("Servidor", "Rejoinando... Script vai reabrir!")
    rejoin()
end)
rejoinBtn.Position = UDim2.new(1, -90, 0.5, -13)

local hopCard = makeCard(serverPage, 102, 40)
makeLabel(hopCard, "Server Hop", 10, 200)
local hopBtn = makeButton(hopCard, "Hop", 7, 80, 26, ACCENT, function()
    addNotif("Servidor", "Procurando servidor... Script vai reabrir!")
    serverHop()
end)
hopBtn.Position = UDim2.new(1, -90, 0.5, -13)

-- ========== SOBRE ==========
local aboutPage = createPage("Sobre")
addPageTitle(aboutPage, "Sobre", "Informações")

local aboutCard = makeCard(aboutPage, 56, 120)
local aboutLbl = Instance.new("TextLabel")
aboutLbl.Size = UDim2.new(1, -20, 1, -20)
aboutLbl.Position = UDim2.new(0, 10, 0, 10)
aboutLbl.BackgroundTransparency = 1
aboutLbl.Text = "Slow Hub\n\nCriador: Spzinx\nDiscord: tav.x\nKey: SlowHubVIP\n\nGitHub: github.com/slow-develp/slowhub"
aboutLbl.TextColor3 = TEXT
aboutLbl.Font = Enum.Font.Gotham
aboutLbl.TextSize = 11
aboutLbl.TextXAlignment = Enum.TextXAlignment.Left
aboutLbl.TextYAlignment = Enum.TextYAlignment.Top
aboutLbl.TextWrapped = true
aboutLbl.ZIndex = 13
aboutLbl.Parent = aboutCard

-- ========== CRIA ABAS ==========
createTabButton("Home", ICONS.Home)
createTabButton("Jogadores", ICONS.Person)
createTabButton("Movimento", ICONS.Lightning)
createTabButton("Teleporte", ICONS.Door)
createTabButton("Visual", ICONS.Eye)
createTabButton("Hitbox", ICONS.Box)
createTabButton("Mira", ICONS.Aimbot)
createTabButton("Anti", ICONS.Info)
createTabButton("Servidor", ICONS.Star)
createTabButton("Sobre", ICONS.Config)

setPage("Home")

-- ========== MODAL CLOSE ==========
local closeModal = Instance.new("Frame")
closeModal.Name = "CloseModal"
closeModal.Size = UDim2.new(1, 0, 1, 0)
closeModal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
closeModal.BackgroundTransparency = 0.5
closeModal.BorderSizePixel = 0
closeModal.Visible = false
closeModal.ZIndex = 200
closeModal.Parent = gui

local modalBox = Instance.new("Frame")
modalBox.Size = UDim2.new(0, 320, 0, 160)
modalBox.Position = UDim2.new(0.5, -160, 0.5, -80)
modalBox.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
modalBox.BorderSizePixel = 0
modalBox.ZIndex = 201
modalBox.Parent = closeModal
Instance.new("UICorner", modalBox).CornerRadius = UDim.new(0, 16)

local modalStroke = Instance.new("UIStroke", modalBox)
modalStroke.Color = PURPLE_BORDER
modalStroke.Thickness = 1.5
modalStroke.Transparency = 0.2

local modalTitle = Instance.new("TextLabel")
modalTitle.Size = UDim2.new(1, -32, 0, 24)
modalTitle.Position = UDim2.new(0, 16, 0, 20)
modalTitle.BackgroundTransparency = 1
modalTitle.Text = "Close Window"
modalTitle.TextColor3 = TEXT
modalTitle.Font = Enum.Font.GothamBold
modalTitle.TextSize = 16
modalTitle.TextXAlignment = Enum.TextXAlignment.Left
modalTitle.ZIndex = 202
modalTitle.Parent = modalBox

local modalDesc = Instance.new("TextLabel")
modalDesc.Size = UDim2.new(1, -32, 0, 40)
modalDesc.Position = UDim2.new(0, 16, 0, 48)
modalDesc.BackgroundTransparency = 1
modalDesc.Text = "Are you sure you want to close the panel?"
modalDesc.TextColor3 = TEXTDIM
modalDesc.Font = Enum.Font.Gotham
modalDesc.TextSize = 12
modalDesc.TextXAlignment = Enum.TextXAlignment.Left
modalDesc.TextWrapped = true
modalDesc.ZIndex = 202
modalDesc.Parent = modalBox

local cancelBtn = Instance.new("TextButton")
cancelBtn.Size = UDim2.new(0, 130, 0, 32)
cancelBtn.Position = UDim2.new(0, 16, 1, -48)
cancelBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
cancelBtn.Text = "Cancel"
cancelBtn.TextColor3 = TEXT
cancelBtn.Font = Enum.Font.GothamBold
cancelBtn.TextSize = 12
cancelBtn.AutoButtonColor = false
cancelBtn.ZIndex = 202
cancelBtn.Parent = modalBox
Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 8)

local confirmCloseBtn = Instance.new("TextButton")
confirmCloseBtn.Size = UDim2.new(0, 130, 0, 32)
confirmCloseBtn.Position = UDim2.new(1, -146, 1, -48)
confirmCloseBtn.BackgroundColor3 = ACCENT
confirmCloseBtn.Text = "Close Window"
confirmCloseBtn.TextColor3 = Color3.new(1, 1, 1)
confirmCloseBtn.Font = Enum.Font.GothamBold
confirmCloseBtn.TextSize = 12
confirmCloseBtn.AutoButtonColor = false
confirmCloseBtn.ZIndex = 202
confirmCloseBtn.Parent = modalBox
Instance.new("UICorner", confirmCloseBtn).CornerRadius = UDim.new(0, 8)

cancelBtn.MouseEnter:Connect(function()
    TweenService:Create(cancelBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
end)
cancelBtn.MouseLeave:Connect(function()
    TweenService:Create(cancelBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 48)}):Play()
end)

confirmCloseBtn.MouseEnter:Connect(function()
    TweenService:Create(confirmCloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(180, 120, 255)}):Play()
end)
confirmCloseBtn.MouseLeave:Connect(function()
    TweenService:Create(confirmCloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = ACCENT}):Play()
end)

local function openCloseModal()
    closeModal.Visible = true
    closeModal.BackgroundTransparency = 1
    modalBox.Size = UDim2.new(0, 260, 0, 130)
    modalBox.Position = UDim2.new(0.5, -130, 0.5, -65)
    TweenService:Create(closeModal, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
    TweenService:Create(modalBox, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 320, 0, 160),
        Position = UDim2.new(0.5, -160, 0.5, -80)
    }):Play()
end

local function closeCloseModal()
    TweenService:Create(closeModal, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    TweenService:Create(modalBox, TweenInfo.new(0.2), {
        Size = UDim2.new(0, 260, 0, 130),
        Position = UDim2.new(0.5, -130, 0.5, -65)
    }):Play()
    task.wait(0.22)
    closeModal.Visible = false
end

cancelBtn.MouseButton1Click:Connect(closeCloseModal)

confirmCloseBtn.MouseButton1Click:Connect(function()
    closeModal.Visible = false
    main.Visible = false
    capsule.Visible = true
    capsuleGlow.Visible = true
end)

-- ========== GLOW PULSANTE ==========
local glowPulse = 0
local glowDir = 1
local glowAccum = 0

RunService.RenderStepped:Connect(function(dt)
    if not capsule or not capsuleGlow then return end
    if not capsule.Visible or not capsuleGlow.Visible then return end
    glowAccum += dt
    if glowAccum < 0.05 then return end
    glowAccum = 0

    glowPulse += glowDir * 0.05
    if glowPulse >= 1 then glowPulse = 1 glowDir = -1 end
    if glowPulse <= 0 then glowPulse = 0 glowDir = 1 end

    local extra = 8 * glowPulse
    capsuleGlow.BackgroundTransparency = 0.55 + (0.25 * glowPulse)
    capsuleGlow.Size = UDim2.new(0, 232 + extra, 0, 48 + extra)
    capsuleGlow.Position = UDim2.new(
        capsule.Position.X.Scale,
        capsule.Position.X.Offset - 6 - (extra / 2),
        capsule.Position.Y.Scale,
        capsule.Position.Y.Offset - 6 - (extra / 2)
    )
end)

-- ========== DRAG CÁPSULA ==========
local capsuleDragActive = false
local capsuleDragStart = nil
local capsuleStartPos = nil
local capsuleMoved = false

local function isOnDragIcon(inputPos)
    local abs = dragIcon.AbsolutePosition
    local sz = dragIcon.AbsoluteSize
    return inputPos.X >= abs.X and inputPos.X <= abs.X + sz.X
       and inputPos.Y >= abs.Y and inputPos.Y <= abs.Y + sz.Y
end

capsule.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        if isOnDragIcon(input.Position) then
            capsuleDragActive = true
            capsuleMoved = false
            capsuleDragStart = input.Position
            capsuleStartPos = capsule.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    capsuleDragActive = false
                end
            end)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if capsuleDragActive and capsuleDragStart then
        local delta = UIS:GetMouseLocation() - capsuleDragStart
        if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then
            capsuleMoved = true
        end
        local newX = capsuleStartPos.X.Offset + delta.X
        local newY = capsuleStartPos.Y.Offset + delta.Y
        capsule.Position = UDim2.new(capsuleStartPos.X.Scale, newX, capsuleStartPos.Y.Scale, newY)
    end
end)

-- ========== DRAG MAIN ==========
local mainDragging = false
local mainDragStart = nil
local mainStartPos = nil

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        mainDragging = true
        mainDragStart = input.Position
        mainStartPos = main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                mainDragging = false
            end
        end)
    end
end)

RunService.RenderStepped:Connect(function()
    if mainDragging and mainDragStart then
        local delta = UIS:GetMouseLocation() - mainDragStart
        main.Position = UDim2.new(
            mainStartPos.X.Scale, mainStartPos.X.Offset + delta.X,
            mainStartPos.Y.Scale, mainStartPos.Y.Offset + delta.Y
        )
    end
end)

-- ========== BOTÕES HEADER ==========
local isMaximized = false

minBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    capsule.Visible = true
    capsuleGlow.Visible = true
end)

maxBtn.MouseButton1Click:Connect(function()
    isMaximized = not isMaximized
    TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = isMaximized and MAXIMIZED_SIZE or NORMAL_SIZE
    }):Play()
end)

closeBtn.MouseButton1Click:Connect(function()
    openCloseModal()
end)

capsule.MouseButton1Click:Connect(function()
    if capsuleMoved then
        capsuleMoved = false
        return
    end
    capsule.Visible = false
    capsuleGlow.Visible = false
    main.Visible = true
end)

-- ========== VALIDAÇÃO DE KEY ==========
local function tryValidateKey()
    local typed = keyInput.Text or ""
    if typed == KEY then
        keyStatus.TextColor3 = SUCCESS
        keyStatus.Text = "Key validada com sucesso!"
        task.wait(0.6)
        keyFrame.Visible = false
        keyGui.Enabled = false
        gui.Enabled = true
        capsule.Visible = true
        capsuleGlow.Visible = true
        main.Visible = false
        if not welcomeShown then
            welcomeShown = true
            task.wait(0.4)
            addNotif("Welcome", "Bem-vindo ao Slow Hub, " .. (LocalPlayer.DisplayName or LocalPlayer.Name) .. "!", 6)
        end
    else
        keyStatus.TextColor3 = DANGER
        keyStatus.Text = "Key inválida. Tente novamente."
    end
end

submitBtn.MouseButton1Click:Connect(tryValidateKey)

keyInput.FocusLost:Connect(function(enter)
    if enter then tryValidateKey() end
end)

-- ========== DRAG KEY ==========
local keyDragging = false
local keyDragStart = nil
local keyStartPos = nil

keyFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        keyDragging = true
        keyDragStart = input.Position
        keyStartPos = keyFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                keyDragging = false
            end
        end)
    end
end)

RunService.RenderStepped:Connect(function()
    if keyDragging and keyDragStart then
        local delta = UIS:GetMouseLocation() - keyDragStart
        keyFrame.Position = UDim2.new(
            keyStartPos.X.Scale, keyStartPos.X.Offset + delta.X,
            keyStartPos.Y.Scale, keyStartPos.Y.Offset + delta.Y
        )
    end
end)

-- ========== BOOT FINAL ==========
gui.Enabled = false
keyGui.Enabled = true
keyFrame.Visible = true
capsule.Visible = false
capsuleGlow.Visible = false
main.Visible = false
