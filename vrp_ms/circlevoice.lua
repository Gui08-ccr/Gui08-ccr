local playerNamesDist = 3
local key_holding = false
Citizen.CreateThread(function()
    while true do
        for _, id in ipairs(GetActivePlayers()) do
    	local takeaway = 0.95
            if (GetPlayerPed(id) ~= PlayerPedId()) then
                ped = GetPlayerPed(id)
                x1,y1,z1 = table.unpack(GetEntityCoords(PlayerPedId(),true))
                x2,y2,z2 = table.unpack(GetEntityCoords(GetPlayerPed(id),true))
                distance = math.floor(GetDistanceBetweenCoords(x1,y1,z1,x2,y2,z2,true))
                if (distance < NetworkGetTalkerProximity(GetPlayerPed(id))) and GetPlayerPed(id) ~= PlayerPedId() then
                    if NetworkIsPlayerTalking(id) and IsEntityVisible(GetPlayerPed(id)) then
                      DrawMarker(25,x2,y2,z2-takeaway,0,0,0,0,0,0,1.0,1.0,10.3,255,0,0,100,0,0,2,0,0,0,0)
                    end
                end 
            end
            if NetworkIsPlayerTalking(PlayerId()) then
            	x1,y1,z1 = table.unpack(GetEntityCoords(PlayerPedId(),true))
				DrawMarker(25,x1,y1,z1-takeaway,0,0,0,0,0,0,1.0,1.0,10.3,255,0,0,100,0,0,2,0,0,0,0)
			end
        end
        Citizen.Wait(5)
    end
end)