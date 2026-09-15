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

local parentGui = CoreGui
pcall(function()
    if type(gethui) == "function" then
        local ok, res = pcall(gethui)
        if ok and res then parentGui = res end
    end
end)
if not parentGui or typeof(parentGui) ~= "Instance" then parentGui = CoreGui end
local testOK = pcall(function()
    local t = Instance.new("Folder")
    t.Parent = parentGui
    t:Destroy()
end)
if not testOK then parentGui = CoreGui end

pcall(function()
    if parentGui and parentGui.FindFirstChild then
        local old = parentGui:FindFirstChild("SlowHub")
        if old then old:Destroy() end
        local old2 = parentGui:FindFirstChild("SlowHubKey")
        if old2 then old2:Destroy() end
    end
end)

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

local KEY = "SlowHubVIP"
local DISCORD_LINK = "https://discord.com/users/tav.x"
local SCRIPT_URL = "https://raw.githubusercontent.com/slow-develp/slowhub/main/slowhub.lua"

ICONS = {
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

rowCache = {}
originalLighting = {}
welcomeShown = false

Config = {
    ESP = {Enabled=false, Color=Color3.fromRGB(150,90,240), ShowName=false, ShowDistance=false, ShowHealth=false, ShowHighlight=false, TeamCheck=false},
    Aimbot = {Enabled=false, FOVEnabled=false, FOVColor=Color3.fromRGB(150,90,240), FOVSize=250, Target="Head", TeamCheck=false, Smoothness=0.25, AutoShot=false, WallCheck=false},
    Hitbox = {Enabled=false, Size=3, Color=Color3.fromRGB(150,90,240), ShowBox=false},
    Noclip = {Enabled=false},
    Speed = {Enabled=false, Value=32},
    InfiniteJump = {Enabled=false},
    Fly = {Enabled=false, Speed=80},
    Fullbright = {Enabled=false},
    FOVChanger = {Enabled=false, Value=70},
    AntiFling = {Enabled=true},
    AntiAFK = {Enabled=false},
    Fling = {Enabled=false}
}
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

espFolder = Instance.new("Folder")
espFolder.Name = "SlowHub_ESP"
espFolder.Parent = parentGui

espData = {}
highlightAvailable = pcall(function()
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
        for _, d in pairs(espData) do hideESP(d) end
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

fovFrame = Instance.new("Frame")
fovFrame.Name = "Aimbot_FOV"
fovFrame.BackgroundTransparency = 1
fovFrame.BorderSizePixel = 0
fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fovFrame.Visible = false
fovFrame.ZIndex = 500
fovFrame.Parent = parentGui
fovStroke = Instance.new("UIStroke", fovFrame)
fovStroke.Color = Config.Aimbot.FOVColor
fovStroke.Thickness = 2.5
fovStroke.Transparency = 0
Instance.new("UICorner", fovFrame).CornerRadius = UDim.new(1, 0)

local function updateFOV()
    if not (Config.Aimbot.Enabled and Config.Aimbot.FOVEnabled) then
        fovFrame.Visible = false
        return
    end
    fovFrame.Visible = true
    fovFrame.Size = UDim2.new(0, Config.Aimbot.FOVSize * 2, 0, Config.Aimbot.FOVSize * 2)
    local vp = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
    fovFrame.Position = UDim2.new(0, vp.X / 2, 0, vp.Y / 2)
    fovStroke.Color = Config.Aimbot.FOVColor
end

local function hasLineOfSight(char)
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local origin = Camera.CFrame.Position
    local target = hrp.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, char}
    params.IgnoreWater = true
    local result = workspace:Raycast(origin, target - origin, params)
    return result == nil
end

local function getClosest()
    local closest, closestDist = nil, math.huge
    local vp = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    for _, plr in ipairs(Players:GetPlayers()) do
        if isValidTarget(plr, Config.Aimbot.TeamCheck) then
            local char, hum, hrp = safeChar(plr)
            if (char and hum and hrp) and hum.Health > 0 then
                local passWallCheck = true
                if Config.Aimbot.WallCheck then
                    passWallCheck = hasLineOfSight(char)
                end
                if passWallCheck then
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
    end
    return closest
end

aimbotActive = false
local function startAimbot()
    if aimbotActive then return end
    aimbotActive = true
    task.spawn(function()
        while Config.Aimbot.Enabled do
            local target = getClosest()
            if target and target.Parent then
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

hitboxFolder = Instance.new("Folder")
hitboxFolder.Name = "SlowHub_Hitbox"
hitboxFolder.Parent = parentGui
hitboxData = {}

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
    if not Config.Hitbox.Enabled then
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
noclipConn = nil
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

speedConn = nil
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

-- FLY
flyConn = nil
flyBodyVel = nil
flyBodyGyro = nil
flyKeys = {W=false, A=false, S=false, D=false, Space=false, Shift=false}
flyInputConn = nil
flyInputEndConn = nil

local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyInputConn then flyInputConn:Disconnect() flyInputConn = nil end
    if flyInputEndConn then flyInputEndConn:Disconnect() flyInputEndConn = nil end
    if flyBodyVel and flyBodyVel.Parent then flyBodyVel:Destroy() end
    if flyBodyGyro and flyBodyGyro.Parent then flyBodyGyro:Destroy() end
    flyBodyVel, flyBodyGyro = nil, nil
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return end

    hum.PlatformStand = true
    pcall(function()
        hum:ChangeState(Enum.HumanoidStateType.Physics)
    end)

    flyBodyVel = Instance.new("BodyVelocity")
    flyBodyVel.Name = "SlowHub_FlyVel"
    flyBodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBodyVel.P = 12500
    flyBodyVel.Velocity = Vector3.zero
    flyBodyVel.Parent = hrp

    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.Name = "SlowHub_FlyGyro"
    flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBodyGyro.P = 3000
    flyBodyGyro.D = 500
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

        if hum and hum.PlatformStand == false then
            hum.PlatformStand = true
        end

        if not flyBodyVel or not flyBodyVel.Parent then
            flyBodyVel = Instance.new("BodyVelocity")
            flyBodyVel.Name = "SlowHub_FlyVel"
            flyBodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            flyBodyVel.P = 12500
            flyBodyVel.Velocity = Vector3.zero
            flyBodyVel.Parent = hrp
        end
        if not flyBodyGyro or not flyBodyGyro.Parent then
            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.Name = "SlowHub_FlyGyro"
            flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            flyBodyGyro.P = 3000
            flyBodyGyro.D = 500
            flyBodyGyro.Parent = hrp
        end

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
    if state then
        startFly()
        addNotif("Fly", "Ativado. W/A/S/D + Space/Shift.", 4)
    else
        stopFly()
        addNotif("Fly", "Desativado.", 3)
    end
end

infJumpConn = nil
local function setInfJump(state)
    if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
    if not state then return end
    infJumpConn = UIS.JumpRequest:Connect(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end

-- FLING
flingConn = nil
flingCooldown = {}

local function setFling(state)
    if flingConn then flingConn:Disconnect() flingConn = nil end
    flingCooldown = {}
    if not state then return end

    flingConn = RunService.Heartbeat:Connect(function()
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myHrp = myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local targetChar = plr.Character
                if targetChar then
                    local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
                    local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
                    if targetHrp and targetHum and targetHum.Health > 0 then
                        local dist = (myHrp.Position - targetHrp.Position).Magnitude
                        if dist < 4 then
                            local now = tick()
                            if not flingCooldown[plr] or now - flingCooldown[plr] >= 0.15 then
                                flingCooldown[plr] = now
                                local randomDir = Vector3.new(
                                    math.random(-100, 100) / 100,
                                    math.random(60, 100) / 100,
                                    math.random(-100, 100) / 100
                                ).Unit
                                targetHrp.AssemblyLinearVelocity = randomDir * 900
                                pcall(function()
                                    targetHum.PlatformStand = true
                                end)
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- ANTI-FLING
antiFlingConn = nil
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

antiAfkConn = nil
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

savedPositions = {}

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
            if not game.HttpGet then return nil end
            local raw = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
            if not raw then return nil end
            return HttpService:JSONDecode(raw)
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

RunService.RenderStepped:Connect(function()
    if type(updateESP) == "function" then pcall(updateESP) end
    if type(updateFOV) == "function" then pcall(updateFOV) end
    if type(updateHitboxes) == "function" then pcall(updateHitboxes) end
    if Config and Config.FOVChanger and Config.FOVChanger.Enabled then
        Camera.FieldOfView = Config.FOVChanger.Value
    end
end)

local function openDiscord()
    pcall(function()
        if setclipboard then
            setclipboard(DISCORD_LINK)
        elseif toclipboard then
            toclipboard(DISCORD_LINK)
        end
    end)
end

task.spawn(function()
    task.wait(1)
    if Config.AntiFling.Enabled then
        pcall(setAntiFling, true)
    end
end)
gui = Instance.new("ScreenGui")
gui.Name = "SlowHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 9999
gui.Parent = parentGui

pcall(function()
    if espFolder then espFolder.Parent = gui end
    if hitboxFolder then hitboxFolder.Parent = gui end
    if fovFrame then fovFrame.Parent = gui end
end)

local vpSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
local maxW = math.min(900, vpSize.X * 0.85)
local maxH = math.min(600, vpSize.Y * 0.80)
NORMAL_SIZE = UDim2.new(0, 500, 0, 340)
MAXIMIZED_SIZE = UDim2.new(0, maxW, 0, maxH)

capsule = Instance.new("Frame")
capsule.Name = "Capsule"
capsule.Size = UDim2.new(0, 220, 0, 44)
capsule.Position = UDim2.new(0.5, -110, 0, 12)
capsule.BackgroundColor3 = Color3.fromRGB(12, 10, 18)
capsule.BorderSizePixel = 0
capsule.Active = true
capsule.Visible = false
capsule.ZIndex = 5
capsule.Parent = gui
Instance.new("UICorner", capsule).CornerRadius = UDim.new(1, 0)

local capsuleGradient = Instance.new("UIGradient", capsule)
capsuleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 15, 30)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 8, 15)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 15, 30)),
})

dragZone = Instance.new("TextButton")
dragZone.Name = "DragZone"
dragZone.Size = UDim2.new(0, 44, 1, 0)
dragZone.BackgroundTransparency = 1
dragZone.Text = ""
dragZone.AutoButtonColor = false
dragZone.Active = true
dragZone.ZIndex = 8
dragZone.Parent = capsule
Instance.new("UICorner", dragZone).CornerRadius = UDim.new(1, 0)

dragIcon = Instance.new("ImageLabel")
dragIcon.Size = UDim2.new(0, 24, 0, 24)
dragIcon.Position = UDim2.new(0.5, -12, 0.5, -12)
dragIcon.BackgroundTransparency = 1
dragIcon.Image = "rbxassetid://79111374854903"
dragIcon.ImageColor3 = Color3.fromRGB(210, 210, 220)
dragIcon.ZIndex = 9
dragIcon.Parent = dragZone

local divider = Instance.new("Frame")
divider.Size = UDim2.new(0, 1, 0, 24)
divider.Position = UDim2.new(0, 44, 0.5, -12)
divider.BackgroundColor3 = Color3.fromRGB(70, 65, 90)
divider.BackgroundTransparency = 0.2
divider.BorderSizePixel = 0
divider.ZIndex = 6
divider.Parent = capsule

capsuleText = Instance.new("TextButton")
capsuleText.Size = UDim2.new(1, -54, 1, 0)
capsuleText.Position = UDim2.new(0, 44, 0, 0)
capsuleText.BackgroundTransparency = 1
capsuleText.Text = "Slow Hub"
capsuleText.TextColor3 = Color3.new(1, 1, 1)
capsuleText.Font = Enum.Font.GothamBold
capsuleText.TextSize = 16
capsuleText.TextXAlignment = Enum.TextXAlignment.Center
capsuleText.AutoButtonColor = false
capsuleText.ZIndex = 6
capsuleText.Parent = capsule

capsuleGlow = Instance.new("Frame")
capsuleGlow.Name = "CapsuleGlow"
capsuleGlow.Size = UDim2.new(0, 220, 0, 44)
capsuleGlow.Position = UDim2.new(0.5, -110, 0, 12)
capsuleGlow.BackgroundTransparency = 1
capsuleGlow.BorderSizePixel = 0
capsuleGlow.ZIndex = 7
capsuleGlow.Visible = false
capsuleGlow.Parent = gui
Instance.new("UICorner", capsuleGlow).CornerRadius = UDim.new(1, 0)

glowStroke = Instance.new("UIStroke", capsuleGlow)
glowStroke.Color = Color3.fromRGB(255, 0, 0)
glowStroke.Thickness = 1.5
glowStroke.Transparency = 0
glowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- KEY GUI
keyGui = Instance.new("ScreenGui")
keyGui.Name = "SlowHubKey"
keyGui.ResetOnSpawn = false
keyGui.IgnoreGuiInset = true
keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
keyGui.DisplayOrder = 10000
keyGui.Parent = parentGui

keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(0, 400, 0, 300)
keyFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
keyFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
keyFrame.BackgroundTransparency = 0.1
keyFrame.BorderSizePixel = 0
keyFrame.Active = true
keyFrame.Parent = keyGui
Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 24)

keyStroke = Instance.new("UIStroke", keyFrame)
keyStroke.Color = PURPLE_BORDER
keyStroke.Thickness = 1.5
keyStroke.Transparency = 0.2

keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1, -32, 0, 30)
keyTitle.Position = UDim2.new(0, 16, 0, 22)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "Slow Hub"
keyTitle.TextColor3 = TEXT
keyTitle.Font = Enum.Font.GothamBold
keyTitle.TextSize = 20
keyTitle.TextXAlignment = Enum.TextXAlignment.Left
keyTitle.Parent = keyFrame

keySub = Instance.new("TextLabel")
keySub.Size = UDim2.new(1, -32, 0, 20)
keySub.Position = UDim2.new(0, 16, 0, 54)
keySub.BackgroundTransparency = 1
keySub.Text = "Key Authentication System"
keySub.TextColor3 = TEXTDIM
keySub.Font = Enum.Font.Gotham
keySub.TextSize = 12
keySub.TextXAlignment = Enum.TextXAlignment.Left
keySub.Parent = keyFrame

keyLine = Instance.new("Frame")
keyLine.Size = UDim2.new(1, -32, 0, 1)
keyLine.Position = UDim2.new(0, 16, 0, 84)
keyLine.BackgroundColor3 = STROKE
keyLine.BorderSizePixel = 0
keyLine.Parent = keyFrame

keyInfo = Instance.new("TextLabel")
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

keyInput = Instance.new("TextBox")
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

discordBtn = Instance.new("TextButton")
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

submitBtn = Instance.new("TextButton")
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

keyStatus = Instance.new("TextLabel")
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

-- MAIN PANEL
main = Instance.new("Frame")
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

mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = PURPLE_BORDER
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.2

starContainer = Instance.new("Frame")
starContainer.Size = UDim2.new(1, 0, 1, 0)
starContainer.BackgroundColor3 = Color3.fromRGB(6, 4, 15)
starContainer.BackgroundTransparency = 0.15
starContainer.BorderSizePixel = 0
starContainer.ClipsDescendants = true
starContainer.ZIndex = 1
starContainer.Parent = main
Instance.new("UICorner", starContainer).CornerRadius = UDim.new(0, 24)

stars = {}
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

starOverlay = Instance.new("Frame")
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

HEADER_H = 36
SIDEBAR_W = 140
FOOTER_H = 42

header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, HEADER_H)
header.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
header.BackgroundTransparency = 0.1
header.BorderSizePixel = 0
header.Active = true
header.ZIndex = 10
header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 24)

headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 20)
headerFix.Position = UDim2.new(0, 0, 1, -20)
headerFix.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
headerFix.BackgroundTransparency = 0.1
headerFix.BorderSizePixel = 0
headerFix.ZIndex = 10
headerFix.Parent = header

headerStroke = Instance.new("UIStroke", header)
headerStroke.Color = PURPLE_BORDER
headerStroke.Thickness = 1
headerStroke.Transparency = 0.2

titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -240, 1, 0)
titleLbl.Position = UDim2.new(0, 80, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "Slow Hub"
titleLbl.TextColor3 = TEXT
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.TextSize = 14
titleLbl.TextXAlignment = Enum.TextXAlignment.Center
titleLbl.ZIndex = 11
titleLbl.Parent = header

minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 26, 0, 26)
minBtn.Position = UDim2.new(1, -120, 0.5, -13)
minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
minBtn.Text = ""
minBtn.AutoButtonColor = false
minBtn.ZIndex = 11
minBtn.Parent = header
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

minIcon = Instance.new("ImageLabel")
minIcon.Size = UDim2.new(0, 16, 0, 16)
minIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
minIcon.BackgroundTransparency = 1
minIcon.Image = "rbxassetid://6031091004"
minIcon.ImageColor3 = TEXT
minIcon.ZIndex = 12
minIcon.Parent = minBtn

maxBtn = Instance.new("TextButton")
maxBtn.Size = UDim2.new(0, 26, 0, 26)
maxBtn.Position = UDim2.new(1, -88, 0.5, -13)
maxBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
maxBtn.Text = ""
maxBtn.AutoButtonColor = false
maxBtn.ZIndex = 11
maxBtn.Parent = header
Instance.new("UICorner", maxBtn).CornerRadius = UDim.new(0, 6)

maxIcon = Instance.new("ImageLabel")
maxIcon.Size = UDim2.new(0, 16, 0, 16)
maxIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
maxIcon.BackgroundTransparency = 1
maxIcon.Image = "rbxassetid://116037492872893"
maxIcon.ImageColor3 = TEXT
maxIcon.ZIndex = 12
maxIcon.Parent = maxBtn

closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -56, 0.5, -13)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
closeBtn.Text = ""
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 11
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

closeIcon = Instance.new("ImageLabel")
closeIcon.Size = UDim2.new(0, 16, 0, 16)
closeIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
closeIcon.BackgroundTransparency = 1
closeIcon.Image = "rbxassetid://14219436180"
closeIcon.ImageColor3 = TEXT
closeIcon.ZIndex = 12
closeIcon.Parent = closeBtn

footer = Instance.new("Frame")
footer.Size = UDim2.new(1, 0, 0, FOOTER_H)
footer.Position = UDim2.new(0, 0, 1, -FOOTER_H)
footer.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
footer.BackgroundTransparency = 0.15
footer.BorderSizePixel = 0
footer.ZIndex = 50
footer.Parent = main
Instance.new("UICorner", footer).CornerRadius = UDim.new(0, 24)

footerFix = Instance.new("Frame")
footerFix.Size = UDim2.new(1, 0, 0, 20)
footerFix.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
footerFix.BackgroundTransparency = 0.15
footerFix.BorderSizePixel = 0
footerFix.ZIndex = 51
footerFix.Parent = footer

footerAvatar = Instance.new("ImageLabel")
footerAvatar.Size = UDim2.new(0, 26, 0, 26)
footerAvatar.Position = UDim2.new(0, 10, 0.5, -13)
footerAvatar.BackgroundColor3 = CARD
footerAvatar.BorderSizePixel = 0
footerAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=100&h=100"
footerAvatar.ZIndex = 51
footerAvatar.Parent = footer
Instance.new("UICorner", footerAvatar).CornerRadius = UDim.new(1, 0)

footerName = Instance.new("TextLabel")
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

footerUser = Instance.new("TextLabel")
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

sidebarHolder = Instance.new("Frame")
sidebarHolder.Size = UDim2.new(0, SIDEBAR_W, 1, -(HEADER_H + FOOTER_H + 24))
sidebarHolder.Position = UDim2.new(0, 0, 0, HEADER_H)
sidebarHolder.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
sidebarHolder.BackgroundTransparency = 0.5
sidebarHolder.BorderSizePixel = 0
sidebarHolder.ZIndex = 10
sidebarHolder.Parent = main

sidebarScroll = Instance.new("ScrollingFrame")
sidebarScroll.Size = UDim2.new(1, 0, 1, 0)
sidebarScroll.BackgroundTransparency = 1
sidebarScroll.BorderSizePixel = 0
sidebarScroll.ScrollBarThickness = 3
sidebarScroll.ScrollBarImageColor3 = ACCENT
sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
sidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
sidebarScroll.ZIndex = 10
sidebarScroll.Parent = sidebarHolder

sidebarLayout = Instance.new("UIListLayout", sidebarScroll)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Padding = UDim.new(0, 2)

sidebarPad = Instance.new("UIPadding", sidebarScroll)
sidebarPad.PaddingTop = UDim.new(0, 6)
sidebarPad.PaddingBottom = UDim.new(0, 6)
sidebarPad.PaddingLeft = UDim.new(0, 6)
sidebarPad.PaddingRight = UDim.new(0, 6)

content = Instance.new("Frame")
content.Size = UDim2.new(1, -SIDEBAR_W, 1, -(HEADER_H + FOOTER_H))
content.Position = UDim2.new(0, SIDEBAR_W, 0, HEADER_H)
content.BackgroundTransparency = 1
content.ZIndex = 100
content.Parent = main

pages = {}
buttons = {}

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
    page.ZIndex = 110
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
    title.ZIndex = 130
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
        sub.ZIndex = 130
        sub.Parent = page
    end
end

local function makeCard(parent, y, h)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -24, 0, h or 32)
    card.Position = UDim2.new(0, 12, 0, y)
    card.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    card.BackgroundTransparency = 0.7
    card.BorderSizePixel = 0
    card.ZIndex = 120
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
    lbl.ZIndex = 130
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
    btn.ZIndex = 130
    btn.Parent = card
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    btn:SetAttribute("ToggleState", state)
    btn.MouseButton1Click:Connect(function()
        local newState = not btn:GetAttribute("ToggleState")
        btn:SetAttribute("ToggleState", newState)
        btn.BackgroundColor3 = newState and ACCENT or CARD
        btn.Text = newState and "ON" or "OFF"
        if callback then callback(newState) end
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
    btn.ZIndex = 130
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
    box.ZIndex = 130
    box.Parent = parent
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    if callback then
        box.FocusLost:Connect(function() callback(box.Text) end)
    end
    return box
end

local function addNotif(title, desc, duration)
    duration = duration or 4
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 300, 0, 60)
    notif.Position = UDim2.new(1, 20, 1, -70)
    notif.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    notif.BackgroundTransparency = 0.05
    notif.BorderSizePixel = 0
    notif.ZIndex = 200
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
    nIcon.ZIndex = 202
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
    nTitle.ZIndex = 202
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
    nDesc.ZIndex = 202
    nDesc.Parent = notif

    local closeNotif = Instance.new("TextButton")
    closeNotif.Size = UDim2.new(0, 20, 0, 20)
    closeNotif.Position = UDim2.new(1, -26, 0, 6)
    closeNotif.BackgroundTransparency = 1
    closeNotif.Text = ""
    closeNotif.ZIndex = 203
    closeNotif.Parent = notif

    local closeNotifIcon = Instance.new("ImageLabel")
    closeNotifIcon.Size = UDim2.new(0, 12, 0, 12)
    closeNotifIcon.Position = UDim2.new(0.5, -6, 0.5, -6)
    closeNotifIcon.BackgroundTransparency = 1
    closeNotifIcon.Image = "rbxassetid://14219436180"
    closeNotifIcon.ImageColor3 = TEXTDIM
    closeNotifIcon.ZIndex = 204
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
-- PÁGINA HOME
homePage = createPage("Home")
addPageTitle(homePage, "Home", "Bem-vindo ao Slow Hub")

welcomeCard = makeCard(homePage, 56, 70)
welcomeLbl = Instance.new("TextLabel")
welcomeLbl.Size = UDim2.new(1, -20, 0, 24)
welcomeLbl.Position = UDim2.new(0, 10, 0, 10)
welcomeLbl.BackgroundTransparency = 1
welcomeLbl.Text = "Olá, " .. (LocalPlayer.DisplayName or LocalPlayer.Name) .. " ✌️"
welcomeLbl.TextColor3 = TEXT
welcomeLbl.Font = Enum.Font.GothamBold
welcomeLbl.TextSize = 14
welcomeLbl.TextXAlignment = Enum.TextXAlignment.Left
welcomeLbl.ZIndex = 130
welcomeLbl.Parent = welcomeCard

creditLbl = Instance.new("TextLabel")
creditLbl.Size = UDim2.new(1, -20, 0, 16)
creditLbl.Position = UDim2.new(0, 10, 0, 36)
creditLbl.BackgroundTransparency = 1
creditLbl.Text = "Criado por Spzinx • Discord: tav.x"
creditLbl.TextColor3 = TEXTDIM
creditLbl.Font = Enum.Font.Gotham
creditLbl.TextSize = 10
creditLbl.TextXAlignment = Enum.TextXAlignment.Left
creditLbl.ZIndex = 130
creditLbl.Parent = welcomeCard

infoCard = makeCard(homePage, 136, 32)
makeLabel(infoCard, "Use o menu lateral para acessar as funções.", 10, 380)

-- PÁGINA JOGADORES
playersPage = createPage("Jogadores")
addPageTitle(playersPage, "Jogadores", "Lista de jogadores no servidor")

searchBar = Instance.new("Frame")
searchBar.Size = UDim2.new(1, -24, 0, 30)
searchBar.Position = UDim2.new(0, 12, 0, 50)
searchBar.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
searchBar.BackgroundTransparency = 0.4
searchBar.BorderSizePixel = 0
searchBar.ZIndex = 120
searchBar.Parent = playersPage
Instance.new("UICorner", searchBar).CornerRadius = UDim.new(0, 8)

searchIcon = Instance.new("ImageLabel")
searchIcon.Size = UDim2.new(0, 14, 0, 14)
searchIcon.Position = UDim2.new(0, 8, 0.5, -7)
searchIcon.BackgroundTransparency = 1
searchIcon.Image = ICONS.Person
searchIcon.ImageColor3 = TEXTDIM
searchIcon.ZIndex = 130
searchIcon.Parent = searchBar

searchBox = Instance.new("TextBox")
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
searchBox.ZIndex = 130
searchBox.Parent = searchBar

playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1, -24, 1, -90)
playerScroll.Position = UDim2.new(0, 12, 0, 86)
playerScroll.BackgroundTransparency = 1
playerScroll.BorderSizePixel = 0
playerScroll.ScrollBarThickness = 3
playerScroll.ScrollBarImageColor3 = ACCENT
playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
playerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerScroll.ZIndex = 120
playerScroll.Parent = playersPage

playerLayout = Instance.new("UIListLayout", playerScroll)
playerLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerLayout.Padding = UDim.new(0, 4)

playerPad = Instance.new("UIPadding", playerScroll)
playerPad.PaddingTop = UDim.new(0, 2)
playerPad.PaddingBottom = UDim.new(0, 6)
playerPad.PaddingLeft = UDim.new(0, 2)
playerPad.PaddingRight = UDim.new(0, 2)

playerCards = {}

local function createPlayerCard(plr, order)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -4, 0, 40)
    card.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    card.BackgroundTransparency = 0.3
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.ZIndex = 130
    card.Parent = playerScroll
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0, 28, 0, 28)
    avatar.Position = UDim2.new(0, 8, 0.5, -14)
    avatar.BackgroundColor3 = CARD
    avatar.BorderSizePixel = 0
    avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. plr.UserId .. "&w=100&h=100"
    avatar.ZIndex = 140
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
    nameLbl.ZIndex = 140
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
    userLbl.ZIndex = 140
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
    gotoBtn.ZIndex = 140
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

-- PÁGINA MOVIMENTO
movementPage = createPage("Movimento")
addPageTitle(movementPage, "Movimento", "Noclip, Speed, Fly, Inf Jump")

noclipCard = makeCard(movementPage, 56, 32)
makeLabel(noclipCard, "Noclip", 10, 200)
makeToggle(noclipCard, false, function(s)
    Config.Noclip.Enabled = s
    setNoclip(s)
end)

speedCard = makeCard(movementPage, 94, 32)
makeLabel(speedCard, "Speed", 10, 150)
speedInput = makeInput(speedCard, 6, tostring(Config.Speed.Value), 50, function(txt)
    local n = tonumber(txt)
    if n then Config.Speed.Value = math.clamp(n, 16, 200) end
end)
speedInput.Position = UDim2.new(1, -110, 0.5, -12)
makeToggle(speedCard, false, function(s)
    Config.Speed.Enabled = s
    setSpeed(s)
end)

flyCard = makeCard(movementPage, 132, 32)
makeLabel(flyCard, "Fly (W/A/S/D + Space/Shift)", 10, 240)
makeToggle(flyCard, false, function(s)
    Config.Fly.Enabled = s
    setFly(s)
end)

jumpCard = makeCard(movementPage, 170, 32)
makeLabel(jumpCard, "Infinite Jump", 10, 200)
makeToggle(jumpCard, false, function(s)
    Config.InfiniteJump.Enabled = s
    setInfJump(s)
end)

-- PÁGINA TELEPORTE
tpPage = createPage("Teleporte")
addPageTitle(tpPage, "Teleporte", "Salvar / Ir / Resetar / Remover")

savedList = Instance.new("ScrollingFrame")
savedList.Size = UDim2.new(1, -24, 1, -170)
savedList.Position = UDim2.new(0, 12, 0, 50)
savedList.BackgroundTransparency = 1
savedList.BorderSizePixel = 0
savedList.ScrollBarThickness = 3
savedList.ScrollBarImageColor3 = ACCENT
savedList.CanvasSize = UDim2.new(0, 0, 0, 0)
savedList.AutomaticCanvasSize = Enum.AutomaticSize.Y
savedList.ZIndex = 120
savedList.Parent = tpPage

savedLayout = Instance.new("UIListLayout", savedList)
savedLayout.SortOrder = Enum.SortOrder.LayoutOrder
savedLayout.Padding = UDim.new(0, 4)

savedSlots = {}

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
        card.ZIndex = 130
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
        lbl.ZIndex = 140
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
        goBtn.ZIndex = 140
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
        delBtn.ZIndex = 140
        delBtn.Parent = card
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 6)
        delBtn.MouseButton1Click:Connect(function()
            savedSlots[i] = nil
            savedPositions[i] = nil
            refreshSavedSlots()
            addNotif("Teleporte", "Slot " .. i .. " removido.")
        end)
    end
end

saveBtn = makeButton(tpPage, "Salvar Posição", 0, 155, 26, Color3.fromRGB(35, 35, 42), function()
    local nextSlot = 1
    while savedSlots[nextSlot] do nextSlot += 1 end
    if savePosition(nextSlot) then
        savedSlots[nextSlot] = true
        refreshSavedSlots()
        addNotif("Teleporte", "Posição salva no slot " .. nextSlot)
    end
end)
saveBtn.Position = UDim2.new(0, 12, 1, -108)

resetBtn = makeButton(tpPage, "Resetar Todos", 0, 155, 26, Color3.fromRGB(35, 35, 42), function()
    savedSlots = {}
    savedPositions = {}
    refreshSavedSlots()
    addNotif("Teleporte", "Todos os slots foram resetados.")
end)
resetBtn.Position = UDim2.new(0, 12, 1, -76)

removeHint = makeButton(tpPage, "Remover Slot (X)", 0, 155, 26, Color3.fromRGB(60, 25, 30), function()
    addNotif("Remover Slot", "Clique no X vermelho ao lado do slot.")
end)
removeHint.Position = UDim2.new(0, 12, 1, -44)

-- PÁGINA VISUAL
visualPage = createPage("Visual")
addPageTitle(visualPage, "Visual", "ESP, Fullbright")

espCard = makeCard(visualPage, 56, 32)
makeLabel(espCard, "ESP", 10, 200)
makeToggle(espCard, false, function(s) Config.ESP.Enabled = s end)

espNameCard = makeCard(visualPage, 94, 32)
makeLabel(espNameCard, "ESP • Mostrar Nome", 10, 200)
makeToggle(espNameCard, false, function(s) Config.ESP.ShowName = s end)

espDistCard = makeCard(visualPage, 132, 32)
makeLabel(espDistCard, "ESP • Mostrar Distância", 10, 200)
makeToggle(espDistCard, false, function(s) Config.ESP.ShowDistance = s end)

espHealthCard = makeCard(visualPage, 170, 32)
makeLabel(espHealthCard, "ESP • Mostrar Vida", 10, 200)
makeToggle(espHealthCard, false, function(s) Config.ESP.ShowHealth = s end)

espHLCard = makeCard(visualPage, 208, 32)
makeLabel(espHLCard, "ESP • Highlight", 10, 200)
makeToggle(espHLCard, false, function(s) Config.ESP.ShowHighlight = s end)

espTMCard = makeCard(visualPage, 246, 32)
makeLabel(espTMCard, "ESP • TeamCheck", 10, 200)
makeToggle(espTMCard, false, function(s) Config.ESP.TeamCheck = s end)

fbCard = makeCard(visualPage, 284, 32)
makeLabel(fbCard, "Fullbright", 10, 200)
makeToggle(fbCard, false, function(s)
    Config.Fullbright.Enabled = s
    setFullbright(s)
end)

-- PÁGINA HITBOX
hitboxPage = createPage("Hitbox")
addPageTitle(hitboxPage, "Hitbox", "Tamanho, cor e quadro visual")

hbCard = makeCard(hitboxPage, 56, 32)
makeLabel(hbCard, "Hitbox Expander", 10, 200)
makeToggle(hbCard, false, function(s)
    Config.Hitbox.Enabled = s
    Config.Hitbox.ShowBox = s
end)

hbSizeCard = makeCard(hitboxPage, 94, 32)
makeLabel(hbSizeCard, "Tamanho", 10, 150)
hbSizeInput = makeInput(hbSizeCard, 6, tostring(Config.Hitbox.Size), 50, function(txt)
    local n = tonumber(txt)
    if n then Config.Hitbox.Size = math.clamp(n, 1, 20) end
end)
hbSizeInput.Position = UDim2.new(1, -70, 0.5, -12)

hbShowCard = makeCard(hitboxPage, 132, 32)
makeLabel(hbShowCard, "Mostrar Quadro Visual", 10, 200)
makeToggle(hbShowCard, false, function(s)
    Config.Hitbox.ShowBox = s
end)

-- PÁGINA MIRA
miraPage = createPage("Mira")
addPageTitle(miraPage, "Mira", "Aimbot, FOV, WallCheck")

aimCard = makeCard(miraPage, 56, 32)
makeLabel(aimCard, "Aimbot", 10, 200)
makeToggle(aimCard, false, function(s)
    Config.Aimbot.Enabled = s
    if s then startAimbot() end
end)

aimShotCard = makeCard(miraPage, 94, 32)
makeLabel(aimShotCard, "Aimbot • Auto Shot", 10, 200)
makeToggle(aimShotCard, false, function(s) Config.Aimbot.AutoShot = s end)

aimTMCard = makeCard(miraPage, 132, 32)
makeLabel(aimTMCard, "Aimbot • TeamCheck", 10, 200)
makeToggle(aimTMCard, false, function(s) Config.Aimbot.TeamCheck = s end)

aimWCCard = makeCard(miraPage, 170, 32)
makeLabel(aimWCCard, "Aimbot • WallCheck (só visível)", 10, 240)
makeToggle(aimWCCard, false, function(s) Config.Aimbot.WallCheck = s end)

aimTargetCard = makeCard(miraPage, 208, 32)
makeLabel(aimTargetCard, "Alvo (Head / Torso)", 10, 150)
targetInput = makeInput(aimTargetCard, 6, Config.Aimbot.Target, 70, function(txt)
    if txt == "Head" or txt == "Torso" then Config.Aimbot.Target = txt end
end)
targetInput.Position = UDim2.new(1, -90, 0.5, -12)

aimSmoothCard = makeCard(miraPage, 246, 32)
makeLabel(aimSmoothCard, "Suavidade (0.05 - 1)", 10, 150)
smoothInput = makeInput(aimSmoothCard, 6, tostring(Config.Aimbot.Smoothness), 60, function(txt)
    local n = tonumber(txt)
    if n then Config.Aimbot.Smoothness = math.clamp(n, 0.05, 1) end
end)
smoothInput.Position = UDim2.new(1, -80, 0.5, -12)

fovCard = makeCard(miraPage, 284, 32)
makeLabel(fovCard, "FOV Circle", 10, 200)
makeToggle(fovCard, false, function(s) Config.Aimbot.FOVEnabled = s end)

fovSizeCard = makeCard(miraPage, 322, 32)
makeLabel(fovSizeCard, "Tamanho FOV", 10, 150)
fovSizeInput = makeInput(fovSizeCard, 6, tostring(Config.Aimbot.FOVSize), 50, function(txt)
    local n = tonumber(txt)
    if n then Config.Aimbot.FOVSize = math.clamp(n, 20, 500) end
end)
fovSizeInput.Position = UDim2.new(1, -70, 0.5, -12)

fovChangeCard = makeCard(miraPage, 360, 32)
makeLabel(fovChangeCard, "FOV Changer", 10, 200)
makeToggle(fovChangeCard, false, function(s)
    Config.FOVChanger.Enabled = s
    setFOVChanger(s)
end)

-- PÁGINA ANTI
antiPage = createPage("Anti")
addPageTitle(antiPage, "Anti", "Anti-Fling, Anti-AFK, Fling")

antiFlingToggle = nil
flingToggle = nil

afCard = makeCard(antiPage, 56, 32)
makeLabel(afCard, "Anti-Fling", 10, 200)
antiFlingToggle = makeToggle(afCard, true, function(s)
    Config.AntiFling.Enabled = s
    setAntiFling(s)
end)

afkCard = makeCard(antiPage, 94, 32)
makeLabel(afkCard, "Anti-AFK", 10, 200)
makeToggle(afkCard, false, function(s)
    Config.AntiAFK.Enabled = s
    setAntiAFK(s)
end)

flingCard = makeCard(antiPage, 132, 32)
makeLabel(flingCard, "Fling (arremessa players)", 10, 200)
flingToggle = makeToggle(flingCard, false, function(s)
    Config.Fling.Enabled = s
    setFling(s)

    if s then
        Config.AntiFling.Enabled = false
        setAntiFling(false)
        if antiFlingToggle then
            antiFlingToggle:SetAttribute("ToggleState", false)
            antiFlingToggle.BackgroundColor3 = CARD
            antiFlingToggle.Text = "OFF"
        end
        addNotif("Fling", "Anti-Fling desativado automaticamente.", 4)
    else
        Config.AntiFling.Enabled = true
        setAntiFling(true)
        if antiFlingToggle then
            antiFlingToggle:SetAttribute("ToggleState", true)
            antiFlingToggle.BackgroundColor3 = ACCENT
            antiFlingToggle.Text = "ON"
        end
        addNotif("Fling", "Anti-Fling reativado automaticamente.", 4)
    end
end)

-- PÁGINA SERVIDOR
serverPage = createPage("Servidor")
addPageTitle(serverPage, "Servidor", "Server Hop, Rejoin")

rejoinCard = makeCard(serverPage, 56, 40)
makeLabel(rejoinCard, "Rejoin (entrar de novo)", 10, 200)
rejoinBtn = makeButton(rejoinCard, "Rejoin", 7, 80, 26, ACCENT, function()
    addNotif("Servidor", "Rejoinando... Script vai reabrir!")
    rejoin()
end)
rejoinBtn.Position = UDim2.new(1, -90, 0.5, -13)

hopCard = makeCard(serverPage, 102, 40)
makeLabel(hopCard, "Server Hop", 10, 200)
hopBtn = makeButton(hopCard, "Hop", 7, 80, 26, ACCENT, function()
    addNotif("Servidor", "Procurando servidor... Script vai reabrir!")
    serverHop()
end)
hopBtn.Position = UDim2.new(1, -90, 0.5, -13)

-- PÁGINA SOBRE
aboutPage = createPage("Sobre")
addPageTitle(aboutPage, "Sobre", "Informações")

aboutCard = makeCard(aboutPage, 56, 120)
aboutLbl = Instance.new("TextLabel")
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
aboutLbl.ZIndex = 130
aboutLbl.Parent = aboutCard

-- BOTÕES LATERAIS
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

-- BOTÕES DO HEADER
minBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    capsule.Visible = true
    capsuleGlow.Visible = true
end)

isMaximized = false
maxBtn.MouseButton1Click:Connect(function()
    isMaximized = not isMaximized
    if isMaximized then
        main.Size = MAXIMIZED_SIZE
        main.Position = UDim2.new(0.5, -maxW/2, 0.5, -maxH/2)
    else
        main.Size = NORMAL_SIZE
        main.Position = UDim2.new(0.5, -250, 0.5, -170)
    end
end)

-- CÁPSULA
capsuleText.MouseButton1Click:Connect(function()
    if capsule.Visible then
        capsule.Visible = false
        capsuleGlow.Visible = false
        main.Visible = true
    end
end)

local capsuleDragging = false
local capsuleDragStart = nil
local capsuleStartPos = nil

dragZone.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        capsuleDragging = true
        capsuleDragStart = UIS:GetMouseLocation()
        capsuleStartPos = capsule.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if not capsuleDragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement
    and input.UserInputType ~= Enum.UserInputType.Touch then return end

    local pos = UIS:GetMouseLocation()
    local dx = pos.X - capsuleDragStart.X
    local dy = pos.Y - capsuleDragStart.Y

    capsule.Position = UDim2.new(
        capsuleStartPos.X.Scale, capsuleStartPos.X.Offset + dx,
        capsuleStartPos.Y.Scale, capsuleStartPos.Y.Offset + dy
    )
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        capsuleDragging = false
    end
end)

-- ═══════════ GLOW RGB DA CÁPSULA ═══════════
local glowHue = 0
RunService.RenderStepped:Connect(function(dt)
    if not capsuleGlow then return end
    capsuleGlow.Visible = capsule.Visible
    capsuleGlow.Position = UDim2.new(
        capsule.Position.X.Scale, capsule.Position.X.Offset,
        capsule.Position.Y.Scale, capsule.Position.Y.Offset
    )
    capsuleGlow.Size = capsule.Size
    glowHue = (glowHue + dt * 0.15) % 1
    local color = Color3.fromHSV(glowHue, 1, 1)
    if glowStroke then glowStroke.Color = color end
end)

-- ═══════════ DRAG DO PAINEL PELO HEADER ═══════════
local mainDragging = false
local mainDragStart = nil
local mainStartPos = nil

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        mainDragging = true
        mainDragStart = UIS:GetMouseLocation()
        mainStartPos = main.Position
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        mainDragging = false
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
closeModal = Instance.new("Frame")
closeModal.Name = "CloseModal"
closeModal.Size = UDim2.new(1, 0, 1, 0)
closeModal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
closeModal.BackgroundTransparency = 0.5
closeModal.BorderSizePixel = 0
closeModal.Visible = false
closeModal.ZIndex = 300
closeModal.Parent = gui

modalBox = Instance.new("Frame")
modalBox.Size = UDim2.new(0, 320, 0, 160)
modalBox.Position = UDim2.new(0.5, -160, 0.5, -80)
modalBox.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
modalBox.BorderSizePixel = 0
modalBox.ZIndex = 301
modalBox.Parent = closeModal
Instance.new("UICorner", modalBox).CornerRadius = UDim.new(0, 16)

modalStroke = Instance.new("UIStroke", modalBox)
modalStroke.Color = PURPLE_BORDER
modalStroke.Thickness = 1.5
modalStroke.Transparency = 0.2

modalTitle = Instance.new("TextLabel")
modalTitle.Size = UDim2.new(1, -32, 0, 24)
modalTitle.Position = UDim2.new(0, 16, 0, 20)
modalTitle.BackgroundTransparency = 1
modalTitle.Text = "Are you sure?"
modalTitle.TextColor3 = TEXT
modalTitle.Font = Enum.Font.GothamBold
modalTitle.TextSize = 16
modalTitle.TextXAlignment = Enum.TextXAlignment.Left
modalTitle.ZIndex = 302
modalTitle.Parent = modalBox

modalDesc = Instance.new("TextLabel")
modalDesc.Size = UDim2.new(1, -32, 0, 40)
modalDesc.Position = UDim2.new(0, 16, 0, 48)
modalDesc.BackgroundTransparency = 1
modalDesc.Text = "This will close the script and disable all features."
modalDesc.TextColor3 = TEXTDIM
modalDesc.Font = Enum.Font.Gotham
modalDesc.TextSize = 12
modalDesc.TextXAlignment = Enum.TextXAlignment.Left
modalDesc.TextWrapped = true
modalDesc.ZIndex = 302
modalDesc.Parent = modalBox

cancelBtn = Instance.new("TextButton")
cancelBtn.Size = UDim2.new(0, 130, 0, 32)
cancelBtn.Position = UDim2.new(0, 16, 1, -48)
cancelBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
cancelBtn.Text = "Cancel"
cancelBtn.TextColor3 = TEXT
cancelBtn.Font = Enum.Font.GothamBold
cancelBtn.TextSize = 12
cancelBtn.AutoButtonColor = false
cancelBtn.ZIndex = 302
cancelBtn.Parent = modalBox
Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 8)

confirmCloseBtn = Instance.new("TextButton")
confirmCloseBtn.Size = UDim2.new(0, 130, 0, 32)
confirmCloseBtn.Position = UDim2.new(1, -146, 1, -48)
confirmCloseBtn.BackgroundColor3 = ACCENT
confirmCloseBtn.Text = "Close Window"
confirmCloseBtn.TextColor3 = Color3.new(1, 1, 1)
confirmCloseBtn.Font = Enum.Font.GothamBold
confirmCloseBtn.TextSize = 12
confirmCloseBtn.AutoButtonColor = false
confirmCloseBtn.ZIndex = 302
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

local function resetEverything()
    for section, data in pairs(Config) do
        if type(data) == "table" and data.Enabled ~= nil then
            data.Enabled = false
        end
    end
    if espData then
        for _, d in pairs(espData) do
            if d.Box then d.Box.Visible = false end
            if d.Name then d.Name.Visible = false end
            if d.Dist then d.Dist.Visible = false end
            if d.HpBg then d.HpBg.Visible = false end
            if d.HL then d.HL.Enabled = false end
        end
    end
    if hitboxData then
        for _, d in pairs(hitboxData) do
            if d.Frame then d.Frame.Visible = false end
        end
    end
    if noclipConn then pcall(function() noclipConn:Disconnect() end) noclipConn = nil end
    if speedConn then pcall(function() speedConn:Disconnect() end) speedConn = nil end
    if flingConn then pcall(function() flingConn:Disconnect() end) flingConn = nil end
    if flyConn then pcall(function() flyConn:Disconnect() end) flyConn = nil end
    if flyInputConn then pcall(function() flyInputConn:Disconnect() end) flyInputConn = nil end
    if flyInputEndConn then pcall(function() flyInputEndConn:Disconnect() end) flyInputEndConn = nil end
    if flyBodyVel and flyBodyVel.Parent then flyBodyVel:Destroy() end
    if flyBodyGyro and flyBodyGyro.Parent then flyBodyGyro:Destroy() end
    flyBodyVel, flyBodyGyro = nil, nil
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then 
        hum.WalkSpeed = 16 
        hum.PlatformStand = false
    end
    if infJumpConn then pcall(function() infJumpConn:Disconnect() end) infJumpConn = nil end
    if originalLighting and originalLighting.Ambient then
        pcall(function()
            Lighting.Ambient = originalLighting.Ambient
            Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
            Lighting.Brightness = originalLighting.Brightness
            Lighting.ClockTime = originalLighting.ClockTime
            Lighting.FogEnd = originalLighting.FogEnd
            Lighting.GlobalShadows = originalLighting.GlobalShadows
        end)
    end
    pcall(function()
        if Camera then Camera.FieldOfView = 70 end
    end)
    if antiFlingConn then pcall(function() antiFlingConn:Disconnect() end) antiFlingConn = nil end
    if antiAfkConn then pcall(function() antiAfkConn:Disconnect() end) antiAfkConn = nil end
    if fovFrame then fovFrame.Visible = false end
    aimbotActive = false
end

confirmCloseBtn.MouseButton1Click:Connect(function()
    addNotif("Slow Hub", "Todas as funções foram desativadas.", 3)
    resetEverything()
    closeCloseModal()
    capsule.Visible = false
    capsuleGlow.Visible = false
    main.Visible = false
    task.wait(0.8)
    pcall(function()
        if gui then gui:Destroy() end
        if keyGui then keyGui:Destroy() end
    end)
    pcall(function()
        if espFolder and espFolder.Parent then espFolder:Destroy() end
        if hitboxFolder and hitboxFolder.Parent then hitboxFolder:Destroy() end
        if fovFrame and fovFrame.Parent then fovFrame:Destroy() end
    end)
    pcall(function()
        if noclipConn then noclipConn:Disconnect() end
        if speedConn then speedConn:Disconnect() end
        if flingConn then flingConn:Disconnect() end
        if flyConn then flyConn:Disconnect() end
        if flyInputConn then flyInputConn:Disconnect() end
        if flyInputEndConn then flyInputEndConn:Disconnect() end
        if infJumpConn then infJumpConn:Disconnect() end
        if antiFlingConn then antiFlingConn:Disconnect() end
        if antiAfkConn then antiAfkConn:Disconnect() end
    end)
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            hum.PlatformStand = false
        end
    end)
    pcall(function()
        if Camera then Camera.FieldOfView = 70 end
    end)
end)

closeBtn.MouseButton1Click:Connect(function()
    openCloseModal()
end)

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

local keyDragging = false
local keyDragStart = nil
local keyStartPos = nil

keyFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        keyDragging = true
        keyDragStart = UIS:GetMouseLocation()
        keyStartPos = keyFrame.Position
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        keyDragging = false
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

gui.Enabled = false
keyGui.Enabled = true
keyFrame.Visible = true
capsule.Visible = false
capsuleGlow.Visible = false
main.Visible = false
            
 
