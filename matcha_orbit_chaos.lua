--[[
  Chaotic orbit offset for camera.
  Returns offset from target: not a clean circle; desynced phases, small random deviations.
  Use: getOffset(dt, totalTime) -> offset Vector3 in world space (multiply by radius, add to target).
]]

local BASE_RADIUS = 12
local RADIUS_CHAOS = 2.5
local THETA_SPEED = 1.7
local PHI_SPEED = 0.93
local PHASE_NOISE_SCALE = 0.4
local RADIAL_NOISE_SCALE = 0.08

local function hash1(x)
    local t = math.sin(x * 12.9898) * 43758.5453
    return t - math.floor(t)
end

local function hash2(x, y)
    return hash1(x + y * 78.233)
end

-- Returns spherical offset with chaotic radius and angles (desynced, non-repeating).
-- dt = delta time, t = total time (e.g. os.clock() or tick())
local function getOffset(dt, t)
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

return {
    getOffset = getOffset,
    BASE_RADIUS = BASE_RADIUS,
}
