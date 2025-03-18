-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:VOIP
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Voip")
AddEventHandler("hud:Voip",function(number)
	local Number = tonumber(number)
    SendNUIMessage({ type = 'voip', mic = Number-1 })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:RADIO
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Radio")
AddEventHandler("hud:Radio",function(number)
	if number <= 0 then
        SendNUIMessage({ type = 'radio', frequence = "" })
	else
        SendNUIMessage({ type = 'radio', frequence = parseInt(number) })
	end
end)



Citizen.CreateThread(function()
	while true do
		local idle = 1000
		if MumbleIsConnected() then
			if MumbleIsPlayerTalking(PlayerId()) then
				SendNUIMessage({ type = 'Falando', escrita = "iconVoice2" })
			else
				SendNUIMessage({ type = 'Falando', escrita = "iconVoice" })
			end
		end
		Citizen.Wait(idle)
	end
end)