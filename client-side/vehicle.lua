--[[ VEHICLE VELOCITY ]]
local plyInVeh = false
local beltSpeed = 0
local sended = false
local nitroFuel = 0
local nitroActive = false
local vehicle = {}

RegisterNetEvent("trigHud:vehicleLockStatus")
AddEventHandler("trigHud:vehicleLockStatus",function(status)
	vehicle.lockstatus = status
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- NITROENABLE
-----------------------------------------------------------------------------------------------------------------------------------------
function nitroEnable()
	if nitroActive then return end

	local ped = PlayerPedId()
	if IsPedInAnyVehicle(ped) then
		local vehicle = GetVehiclePedIsUsing(ped)
		if GetPedInVehicleSeat(vehicle,-1) == ped then
			local net = VehToNet(vehicle)
			local vehPlate = GetVehicleNumberPlateText(vehicle)
			nitroFuel = Entity(vehicle).state.Nitro or 0
		
			if nitroFuel >= 1 then
				TriggerEvent("sounds:source","nitro",1.0)
				nitroActive = true

				while nitroActive do
					if nitroFuel >= 1 then
						nitroFuel = nitroFuel -1
						
						if not GetScreenEffectIsActive("RaceTurbo") then
							StartScreenEffect("RaceTurbo",0,true)
						end

						SetVehicleCheatPowerIncrease(vehicle,5.0)
						ModifyVehicleTopSpeed(vehicle,20.0)
						fireExaust(vehicle)
					else
						SetVehicleCheatPowerIncrease(vehicle,0.0)
						--vSERVER.updateNitro(net,Entity(vehicle).state.Nitro)
						ModifyVehicleTopSpeed(vehicle,0.0)

						if GetScreenEffectIsActive("RaceTurbo") then
							StopScreenEffect("RaceTurbo")
						end

						nitroActive = false
					end

					Citizen.Wait(100)
				end
				Entity(vehicle).state:set('Nitro', nitroFuel, false)
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NITRODISABLE
-----------------------------------------------------------------------------------------------------------------------------------------
function nitroDisable()
	if nitroActive then
		nitroActive = false

		local ped = PlayerPedId()
		if IsPedInAnyVehicle(ped) then
			local vehicle = GetVehiclePedIsUsing(ped)
			local vehPlate = GetVehicleNumberPlateText(vehicle)

			SetVehicleCheatPowerIncrease(vehicle,0.0)
			vSERVER.updateNitro(VehToNet(vehicle),nitroFuel)
			ModifyVehicleTopSpeed(vehicle,0.0)

			if GetScreenEffectIsActive("RaceTurbo") then
				StopScreenEffect("RaceTurbo")
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXAUSTS
-----------------------------------------------------------------------------------------------------------------------------------------
local exausts = {
	"exhaust","exhaust_2","exhaust_3","exhaust_4","exhaust_5","exhaust_6","exhaust_7","exhaust_8",
	"exhaust_9","exhaust_10","exhaust_11","exhaust_12","exhaust_13","exhaust_14","exhaust_15","exhaust_16"
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- FIREEXAUST
-----------------------------------------------------------------------------------------------------------------------------------------
function fireExaust(vehicle)
	for k,v in ipairs(exausts) do
		local exaustNumber = GetEntityBoneIndexByName(vehicle,v)

		if exaustNumber > -1 then
			UseParticleFxAssetNextCall("core")
			StartNetworkedParticleFxNonLoopedOnEntityBone("veh_backfire",vehicle,0.0,0.0,0.0,0.0,0.0,0.0,exaustNumber,1.75,false,false,false)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ACTIVENITRO
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("+activeNitro",nitroEnable)
RegisterCommand("-activeNitro",nitroDisable)
RegisterKeyMapping("+activeNitro","Ativação do nitro.","keyboard","LMENU")

Citizen.CreateThread(function()
    while true do 
        local sleep = 1000
		local ped = PlayerPedId()
		local vehicle = vehicle
        if IsPedInAnyVehicle(ped) then
			if blockHud then
				DisplayRadar(false)
			else
				DisplayRadar(true)
			end
            sleep = 50
            if not sended then
                SendNUIMessage({ type = 'open', open = true})
                sended = true
            end
            vehicle.entity = GetVehiclePedIsIn(ped)
            vehicle.maxSpeed = math.ceil(GetVehicleModelEstimatedMaxSpeed(GetEntityModel(vehicle.entity)) * 3.605936) or 200

            vehicle.speed = math.ceil(GetEntitySpeed(vehicle.entity) * 3.605936)
			vehicle.motor = GetVehicleEngineHealth(vehicle.entity)
			local nitroShow = 0
			if nitroActive then
				nitroShow = nitroFuel
			else
				nitroShow = Entity(vehicle.entity).state.Nitro or 0
			end
		
			nitroShow = ((nitroShow*100)/200)
			vehicle.nitro = nitroShow
			local vehPlate = GetVehicleNumberPlateText(vehicle.entity)
            local percentage = (vehicle.speed*100)/vehicle.maxSpeed

			if GetVehicleDoorLockStatus(vehicle.entity) <= 1 then
				vehicle.lockstatus = false
			else
				vehicle.lockstatus = true
			end
            
			vehicle.vehicleVelocityPercentage = percentage
			
            SendNuiMessage(json.encode({ type = 'inVehicle', data = vehicle}))
        elseif sended then
			DisplayRadar(false)
            SendNUIMessage({ type = 'open', open = false})
            sended = false
			vehicle = {}
        end
        Wait(50)
    end   
end)

Citizen.CreateThread(function()
    local ped = PlayerPedId()
	local veh = GetVehiclePedIsUsing(ped)
    while true do 
        Citizen.Wait(1000)
        if vehicle.entity then
            vehicle.status = (parseInt(GetVehicleEngineHealth(vehicle.entity)/10))
            vehicle.power = GetIsVehicleEngineRunning(vehicle.entity)
            vehicle.gasolina = GetVehicleFuelLevel(vehicle.entity)
			vehicle.level = GetVehicleCurrentGear(vehicle.entity)
        end
    end
end)

Citizen.CreateThread(function()
	while true do
		local ped = PlayerPedId()
		local timeDistance = 1000

		if IsPedInAnyVehicle(ped) then
			timeDistance = 4
			local veh = GetVehiclePedIsUsing(ped)
			local vehClass = GetVehicleClass(veh)
			if (vehClass >= 0 and vehClass <= 7) or (vehClass >= 9 and vehClass <= 12) or (vehClass >= 17 and vehClass <= 20) then
				if GetEntityHealth(ped)-100 >= 1 then
				else
					if not beltLock then
						vehicle.belt = true
						beltLock = true
						TriggerEvent("vrp_sound:source",'belt',0.5)
					end
				end
				
				local speed = GetEntitySpeed(veh) * 3.605936
				if speed ~= beltSpeed then
					if (beltSpeed - speed) >= 30 and not beltLock then
						local entCoords = GetOffsetFromEntityInWorldCoords(veh,0.0,7.0,0.0)
						SetEntityHealth(ped,GetEntityHealth(ped)-50)

						SetEntityCoords(ped,entCoords.x,entCoords.y,entCoords.z+1)
						SetEntityVelocity(ped,entVelocity.x,entVelocity.y,entVelocity.z)
						Citizen.Wait(1)
						SetPedToRagdoll(ped,5000,5000,0,0,0,0)
					end
					beltSpeed = speed
					entVelocity = GetEntityVelocity(veh)
				end

				if beltLock then
					DisableControlAction(1,75,true)
				end

				
			end
		else
			if beltSpeed ~= 0 then
				beltSpeed = 0
			end

			if beltLock then
				beltLock = false
			end
			vehicle = {}
		end

		Citizen.Wait(timeDistance)
	end
end)

RegisterKeyMapping("cintodesegunranca","Colocar e Retirar Cinto de Segurança.","keyboard","G")
RegisterCommand('cintodesegunranca',function(source,args,rawCommand)
	local ped = PlayerPedId()
	if IsPedInAnyVehicle(ped) then
		local veh = GetVehiclePedIsUsing(ped)
		local vehClass = GetVehicleClass(veh)
		if (vehClass >= 0 and vehClass <= 7) or (vehClass >= 9 and vehClass <= 12) or (vehClass >= 17 and vehClass <= 20) then
			beltLock = not beltLock
			if not beltLock then
				TriggerEvent("vrp_sound:source",'unbelt',0.5)
				vehicle.belt = false
			else
				TriggerEvent("vrp_sound:source",'belt',0.5)
				vehicle.belt = true
			end
		end
	end
end)

--[[ Citizen.CreateThread(function()
	local ped = PlayerPedId()
	while true do 
		local vehicle = GetVehiclePedIsIn(ped,false)
		if IsControlJustPressed(0,38) then 
			
--[[ 			SetVehicleFuelLevel(vehicle, 20.0)
			Wait(1000)
			SetVehicleFuelLevel(vehicle, 40.0)
			Wait(1000)
			SetVehicleFuelLevel(vehicle, 60.0)
			Wait(1000)
			SetVehicleFuelLevel(vehicle, 80.0)
			print(veh) ]]
--[[ 		end
	Wait(1)
	end
end)   ]] 

RegisterNetEvent('vrp_sound:source')
AddEventHandler('vrp_sound:source',function(sound,volume)
    TriggerEvent("sounds:source",sound,volume)
end)
