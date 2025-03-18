-----------------------------------------------------------------------------------------------------------------------------------------
-- DIVINABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local divingMask = nil
local divingTank = nil
local clientOxigen = 100
local divingTimers = GetGameTimer()
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:OXIGEN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Oxigen")
AddEventHandler("hud:Oxigen",function(number)
	SendNUIMessage({ oxigen = number, oxigenShow = divingMask })
	clientOxigen = number
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RECHARGEOXIGEN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:rechargeOxigen")
AddEventHandler("hud:rechargeOxigen",function()
	TriggerEvent("Notify","verde","Reabastecimento concluído.",3000)
	SendNUIMessage({ oxigen = 100, oxigenShow = divingMask })
	vRPS.rechargeOxigen()
	clientOxigen = 100
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:REMOVESCUBA
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:RemoveScuba")
AddEventHandler("hud:RemoveScuba",function()
	local ped = PlayerPedId()
	if DoesEntityExist(divingMask) or DoesEntityExist(divingTank) then
		if DoesEntityExist(divingMask) then
			SendNUIMessage({ oxigen = clientOxigen, oxigenShow = nil })
			TriggerServerEvent("tryDeleteObject",ObjToNet(divingMask))
			divingMask = nil
		end

		if DoesEntityExist(divingTank) then
			TriggerServerEvent("tryDeleteObject",ObjToNet(divingTank))
			divingTank = nil
		end

		SetEnableScuba(ped,false)
		SetPedMaxTimeUnderwater(ped,10.0)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:DIVING
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Diving")
AddEventHandler("hud:Diving",function()
	local ped = PlayerPedId()

	if DoesEntityExist(divingMask) or DoesEntityExist(divingTank) then
		if DoesEntityExist(divingMask) then
			SendNUIMessage({ oxigen = clientOxigen, oxigenShow = nil })
			TriggerServerEvent("tryDeleteObject",ObjToNet(divingMask))
			divingMask = nil
		end

		if DoesEntityExist(divingTank) then
			TriggerServerEvent("tryDeleteObject",ObjToNet(divingTank))
			divingTank = nil
		end

		SetEnableScuba(ped,false)
		SetPedMaxTimeUnderwater(ped,10.0)
	else
		local coords = GetEntityCoords(ped)
		local myObject,objNet = vRPS.CreateObject("p_s_scuba_tank_s",coords["x"],coords["y"],coords["z"])
		if myObject then
			local spawnObjects = 0
			divingTank = NetworkGetEntityFromNetworkId(objNet)
			while not DoesEntityExist(divingTank) and spawnObjects <= 1000 do
				divingTank = NetworkGetEntityFromNetworkId(objNet)
				spawnObjects = spawnObjects + 1
				Citizen.Wait(1)
			end

			spawnObjects = 0
			local objectControl = NetworkRequestControlOfEntity(divingTank)
			while not objectControl and spawnObjects <= 1000 do
				objectControl = NetworkRequestControlOfEntity(divingTank)
				spawnObjects = spawnObjects + 1
				Citizen.Wait(1)
			end

			AttachEntityToEntity(divingTank,ped,GetPedBoneIndex(ped,24818),-0.28,-0.24,0.0,180.0,90.0,0.0,1,1,0,0,2,1)
	
			SetEntityAsNoLongerNeeded(divingTank)
		end

		local myObject,objNet = vRPS.CreateObject("p_s_scuba_mask_s",coords["x"],coords["y"],coords["z"])
		if myObject then
			local spawnObjects = 0
			divingMask = NetworkGetEntityFromNetworkId(objNet)
			while not DoesEntityExist(divingMask) and spawnObjects <= 1000 do
				divingMask = NetworkGetEntityFromNetworkId(objNet)
				spawnObjects = spawnObjects + 1
				Citizen.Wait(1)
			end

			spawnObjects = 0
			local objectControl = NetworkRequestControlOfEntity(divingMask)
			while not objectControl and spawnObjects <= 1000 do
				objectControl = NetworkRequestControlOfEntity(divingMask)
				spawnObjects = spawnObjects + 1
				Citizen.Wait(1)
			end

			AttachEntityToEntity(divingMask,ped,GetPedBoneIndex(ped,12844),0.0,0.0,0.0,180.0,90.0,0.0,1,1,0,0,2,1)
	
			SetEntityAsNoLongerNeeded(divingMask)
		end

		SetEnableScuba(ped,true)
		SetPedMaxTimeUnderwater(ped,2000.0)
	end
end)