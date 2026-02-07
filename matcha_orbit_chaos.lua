--[[
  Orbit script for Matcha LuaVM.
  When _G.OrbitChaos is set (e.g. by matcha_orbit_loader), uses OrbitChaos.getOffset(dt, t) for camera.
]]

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

local SPACE_POS = Vector3.new(123456789012, 123456789012, 123456789012)
local BASE_RADIUS = 12
local RADIUS_CHAOS = 2.5
local THETA_SPEED = 1.7
local PHI_SPEED = 0.93
local PHASE_NOISE_SCALE = 0.4
local RADIAL_NOISE_SCALE = 0.08

local orbitTarget = nil
local orbitToggles = {}
local chaosTime = 0
local inSpace = true

local function hash1(x)
    local t = math.sin(x * 12.9898) * 43758.5453
    return t - math.floor(t)
end
local function hash2(x, y)
    return hash1(x + y * 78.233)
end
local function getChaosOffset(t)
    local theta = t * THETA_SPEED + hash1(t * 0.7) * PHASE_NOISE_SCALE * math.pi * 2
        + math.sin(t * 2.3) * 0.15 + math.sin(t * 5.1) * 0.08
    local phi = t * PHI_SPEED + hash1(t * 0.3 + 1) * PHASE_NOISE_SCALE * math.pi
        + math.sin(t * 1.9) * 0.12
    local r = BASE_RADIUS + (hash2(t, t * 0.5) - 0.5) * 2 * RADIUS_CHAOS
        + math.sin(t * 3.1) * RADIAL_NOISE_SCALE * BASE_RADIUS
    local x = r * math.cos(phi) * math.cos(theta)
    local y = r * math.sin(phi)
    local z = r * math.cos(phi) * math.sin(theta)
    return Vector3.new(x, y, z)
end

local function teleportToSpace(character)
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if hrp then
        hrp.CFrame = CFrame.new(SPACE_POS)
        hrp.Velocity = Vector3.zero
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.Anchored = true
    end
    if humanoid then
        humanoid.PlatformStand = true
    end
    inSpace = true
end

local function freeze(character)
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if hrp then
        hrp.Anchored = true
        hrp.Velocity = Vector3.zero
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    if humanoid then
        humanoid.PlatformStand = true
    end
end

local function unfreeze(character)
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if hrp then hrp.Anchored = false end
    if humanoid then humanoid.PlatformStand = false end
end

local function setOrbitTarget(player)
    if orbitTarget == player then return end
    if orbitTarget and orbitToggles[orbitTarget.UserId] then
        orbitToggles[orbitTarget.UserId]:Set(false)
    end
    orbitTarget = player
    if player and orbitToggles[player.UserId] then
        orbitToggles[player.UserId]:Set(true)
    end
end

-- Load p UI library (it sets global UILib, does not return it)
loadstring(game:HttpGet("https://raw.githubusercontent.com/catowice/p/refs/heads/main/library.lua"))()
local UILib = _G.UILib
if not UILib then
    error("[Orbit] p library failed to load: UILib not found")
end
UILib:SetMenuTitle("Orbit")
UILib._menu_key = "f1"

local orbitTab = UILib:Tab("Orbit")
local playersSection = orbitTab:Section("Players")

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then
        local name = player.Name
        local uid = player.UserId
        local toggle = playersSection:Toggle("Orbit: " .. name, false, function(on)
            if on then
                setOrbitTarget(player)
            else
                if orbitTarget == player then
                    setOrbitTarget(nil)
                end
            end
        end)
        orbitToggles[uid] = toggle
    end
end

local lp = Players.LocalPlayer

if lp.Character then
    teleportToSpace(lp.Character)
else
    lp.CharacterAdded:Connect(function(char)
        teleportToSpace(char)
    end)
end

-- Heartbeat: keep in space when no orbit; on target death -> space
RunService.Heartbeat:Connect(function()
    local char = lp.Character
    if orbitTarget then
        local targetChar = orbitTarget.Character
        local humanoid = targetChar and targetChar:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            setOrbitTarget(nil)
            if char then teleportToSpace(char) end
        end
    else
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and (hrp.Position - SPACE_POS).Magnitude > 10 then
                teleportToSpace(char)
            end
            freeze(char)
        end
    end
end)

-- RenderStepped: chaotic orbit camera + UI step
RunService.RenderStepped:Connect(function(dt)
    chaosTime = chaosTime + dt
    if orbitTarget then
        local targetChar = orbitTarget.Character
        local root = targetChar and targetChar:FindFirstChild("HumanoidRootPart") or targetChar and targetChar:FindFirstChild("Torso")
        if root and Camera then
            local targetPos = root.Position
            local offset
            if _G.OrbitChaos and _G.OrbitChaos.getOffset then
                offset = _G.OrbitChaos.getOffset(dt, chaosTime)
            else
                offset = getChaosOffset(chaosTime)
            end
            local camPos = targetPos + offset
            Camera.CFrame = CFrame.lookAt(camPos, targetPos)
            Camera.CameraType = Enum.CameraType.Scriptable
        end
    else
        if Camera then
            Camera.CameraType = Enum.CameraType.Custom
        end
    end
    pcall(function()
        UILib:Step()
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if orbitTarget == player then
        setOrbitTarget(nil)
        if lp.Character then teleportToSpace(lp.Character) end
    end
    orbitToggles[player.UserId] = nil
end)

Players.PlayerAdded:Connect(function(player)
    if player == Players.LocalPlayer then return end
    if playersSection and orbitToggles then
        local name = player.Name
        local uid = player.UserId
        local toggle = playersSection:Toggle("Orbit: " .. name, false, function(on)
            if on then setOrbitTarget(player)
            elseif orbitTarget == player then setOrbitTarget(nil) end
        end)
        orbitToggles[uid] = toggle
    end
end)

print("[Orbit] Loaded. F1 = toggle GUI. Select a player to orbit.")
