--[[
  Loader: подгружает chaos и main по ссылкам через loadstring.
  Запускай только этот скрипт в Matcha.
]]

local CHAOS_URL = "https://raw.githubusercontent.com/Oracle228/crazyorbitmtcha/refs/heads/main/matcha_orbit_chaos.lua"
local MAIN_URL = "https://raw.githubusercontent.com/Oracle228/crazyorbitmtcha/refs/heads/main/matcha_orbit_main.lua"

local function load(url)
    return game:HttpGet(url)
end

-- 1) Загружаем модуль chaos и кладём в _G, чтобы main мог его использовать
_G.OrbitChaos = loadstring(load(CHAOS_URL))()

-- 2) Загружаем и запускаем main (в main должен быть учёт _G.OrbitChaos для орбиты)
loadstring(load(MAIN_URL))()
