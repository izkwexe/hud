local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPS = Tunnel.getInterface("vRP")

vSERVER = Tunnel.getInterface("hype")

local data = {}
data.hunger = 100
data.thirst = 100
data.hud = true
local stress = 0
blockHud = false

Citizen.CreateThread(function()
    --MumbleSetServerAddress('131.196.197.199', 64738)
    DisplayRadar(false)
end)


RegisterNetEvent("statusHunger")
AddEventHandler("statusHunger", function(number)
    data.hunger = tonumber(number)
end)

RegisterNetEvent("statusThirst")
AddEventHandler("statusThirst", function(number)
    data.thirst = tonumber(number)
end)

RegisterNetEvent("hud:Stress")
AddEventHandler("hud:Stress", function(number)
    stress = tonumber(number)
end)

RegisterCommand('hud', function(source, args, rawCommand)
    blockHud = not blockHud
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        data.talking = MumbleIsPlayerTalking(PlayerId())
        data.menu = IsPauseMenuActive()

        local x, y, z = table.unpack(GetEntityCoords(ped))
        data.street = GetStreetNameFromHashKey(GetStreetNameAtCoord(x, y, z))
        data.date = {
            hour = GetClockHours(),
            minute = GetClockMinutes()
        }
        data.stamina = stress
        data.armor = GetPedArmour(ped)
        data.health = GetEntityHealth(PlayerPedId()) - 100
        data.hud = data.health > 1 and not blockHud

        data.oxygen = ((GetPlayerUnderwaterTimeRemaining(PlayerId()) / 10) * 100)

        SendNUIMessage({ type = 'info', data = data })

        Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local health = GetEntityHealth(ped)

        if health > 101 then
            if data.hunger then
                if data.hunger <= 5 then
                    SetFlash(0, 0, 500, 1000, 500)
                    StartScreenEffect("MinigameTransitionIn", 0, true)
                elseif data.hunger >= 5 then
                    StopScreenEffect("MinigameTransitionIn")
                end
            end
            if data.thirst then
                if data.thirst >= 10 and data.thirst <= 20 then
                    SetFlash(0, 0, 500, 1000, 500)
                elseif data.thirst <= 9 then
                    SetFlash(0, 0, 500, 2000, 500)
                end
            end
        end

        Citizen.Wait(5000)
    end
end)

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        if GetEntityHealth(ped) > 101 then
            updateFoods = GetGameTimer() + 60000
            data.thirst = data.thirst - 1
            data.hunger = data.hunger - 1
            vRPS.clientFoods()
        end

        Citizen.Wait(60000)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA CLIMÁTICO
-----------------------------------------------------------------------------------------------------------------------------------------
local Hours = 12
local Minutes = 0
local data = {}
Citizen.CreateThread(function()
    while true do
        NetworkOverrideClockTime(GlobalState.time[1] or Hours, GlobalState.time[2] or Minutes, 0)

        SendNUIMessage({ type = 'weather', data = { Weather = "CLEAR", Hours = GlobalState.time[1], Minutes = GlobalState.time[2] } })

        SetWeatherTypeNowPersist("weather")
        Wait(1000)
    end
end)
--------------------------------------------------------------------------------------------------------------------------------------
----- MINIMAP OVAL
--------------------------------------------------------------------------------------------------------------------------------------


--posX = 0.01
--posY = 0.0 -- 0.0152
--width = 0.183
--height = 0.32 --0.354
--
--Citizen.CreateThread(function()
--    RequestStreamedTextureDict("circlemap", false)
--    while not HasStreamedTextureDictLoaded("circlemap") do
--        Wait(100)
--    end
--    AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "circlemap", "radarmasksm")
--
--    SetMinimapClipType(1)
--    SendNUIMessage({ type = 'weather', data = data })
--    SetMinimapComponentPosition('minimap', 'L', 'B', posX, posY, width, height)
--    SetMinimapComponentPosition('minimap_mask', 'L', 'B', posX, posY, width, height)
--    SetMinimapComponentPosition('minimap_blur', 'L', 'B', 0.012, 0.022, 0.256, 0.337)
--
--    local minimap = RequestScaleformMovie("minimap")
--    SetRadarBigmapEnabled(true, false)
--    Wait(0)
--    SetRadarBigmapEnabled(false, false)
--
--    while true do
--        Wait(0)
--        BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
--        ScaleformMovieMethodAddParamInt(3)
--        EndScaleformMovieMethod()
--    end
--end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- ARMAS
-----------------------------------------------------------------------------------------------------------------------------------------

local weapon_name = ""

RegisterNetEvent('weapon_arms')
AddEventHandler('weapon_arms', function(index)
    local ped = PlayerPedId()
    weapon_name = index
end)

function updateAmmoInfo(ped)
    local ped = ped
    if (GetPedParachuteState(ped) == -1 or GetPedParachuteState(ped) == 0) and not IsPedInParachuteFreeFall(ped) and not IsPedSwimming(ped) then
        if GetSelectedPedWeapon(ped) ~= GetHashKey("WEAPON_UNARMED") then
            local weapon = GetSelectedPedWeapon(ped)
            local ammoTotal = GetAmmoInPedWeapon(ped, weapon)
            local bool, ammoClip = GetAmmoInClip(ped, weapon)
            local ammoRemaining = math.floor(ammoTotal - ammoClip)

            local arms = {}
            arms.gunname = weapon_name:upper()
            arms.maxAmmo = ammoRemaining or 0
            arms.ammo = ammoClip or 0
            arms.openWeapon = true

            SendNUIMessage({ type = 'weapon', data = arms })
        else
            local arms = {}
            arms.openWeapon = false

            SendNUIMessage({ type = 'weapon', data = arms })
        end
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADTIMERS
-----------------------------------------------------------------------------------------------------------------------------------------
exports("setMinimapActive", function(status)
	inFarm = status 
end)