--[[
  Loader: loads chaos and main via loadstring from URLs.
  Run only this script in Matcha.
]]

local CHAOS_URL = "https://raw.githubusercontent.com/Oracle228/crazyorbitmtcha/refs/heads/main/matcha_orbit_chaos.lua"
local MAIN_URL = "https://raw.githubusercontent.com/Oracle228/crazyorbitmtcha/refs/heads/main/matcha_orbit_main.lua"

local function load(url)
    return game:HttpGet(url)
end

-- 1) Load chaos module into _G so main can use it
_G.OrbitChaos = loadstring(load(CHAOS_URL))()

-- 2) Load and run main (main uses _G.OrbitChaos.getOffset when set)
loadstring(load(MAIN_URL))()
