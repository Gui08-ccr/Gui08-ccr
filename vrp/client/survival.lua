-----------------------------------------------------------------------------------------------------------------------------------------
-- GETHEALTH
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.getHealth()
	return GetEntityHealth(PlayerPedId())
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETHEALTH
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.setHealth(health)
	SetEntityHealth(PlayerPedId(),parseInt(health))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETFRIENDLYFIRE
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.setFriendlyFire(flag)
	NetworkSetFriendlyFireOption(flag)
	SetCanAttackFriendly(PlayerPedId(),flag,flag)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NOCAUTEVAR
-----------------------------------------------------------------------------------------------------------------------------------------
local nocauteado = false
local deathtimer = 1
-----------------------------------------------------------------------------------------------------------------------------------------
-- NOCAUTEADO
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local ms = 1000
		local ped = PlayerPedId()
		if GetEntityHealth(ped) <= 101 and deathtimer >= 0 then
			ms = 1
			if not nocauteado then
				local x,y,z = table.unpack(GetEntityCoords(ped))
				NetworkResurrectLocalPlayer(x,y,z,true,true,false)
				deathtimer = 1
				nocauteado = true
				vRPserver._updateHealth(101)
				SetEntityHealth(ped,101)
				SetEntityInvincible(ped,true)
				if IsPedInAnyVehicle(ped) then
					TaskLeaveVehicle(ped,GetVehiclePedIsIn(ped),4160)
				end
				TriggerEvent("radio:outServers")
			else
				if deathtimer > 0 then
					drawTxt("FALTA  ~r~"..deathtimer.." ~w~ PARA VOLTA A VIDA",4,0.5,0.93,0.50,255,255,255,255)
				else
					drawTxt("PRESSIONE  ~r~[E]~w~  PARA VOLTA A VIDA",4,0.5,0.93,0.50,255,255,255,255)
				end
				SetPedToRagdoll(ped,1000,1000,0,0,0,0)
				SetEntityHealth(ped,101)
				BlockWeaponWheelThisFrame()
				DisableControlAction(0,21,true)
				DisableControlAction(0,22,true)
				DisableControlAction(0,23,true)
				DisableControlAction(0,24,true)
				DisableControlAction(0,25,true)
				DisableControlAction(0,29,true)
				DisableControlAction(0,32,true)
				DisableControlAction(0,33,true)
				DisableControlAction(0,34,true)
				DisableControlAction(0,35,true)
				DisableControlAction(0,47,true)
				DisableControlAction(0,56,true)
				DisableControlAction(0,58,true)
				DisableControlAction(0,73,true)
				DisableControlAction(0,75,true)
				DisableControlAction(0,137,true)
				DisableControlAction(0,140,true)
				DisableControlAction(0,141,true)
				DisableControlAction(0,142,true)
				DisableControlAction(0,143,true)
				DisableControlAction(0,166,true)
				DisableControlAction(0,167,true)
				DisableControlAction(0,168,true)
				DisableControlAction(0,169,true)
				DisableControlAction(0,170,true)
				DisableControlAction(0,177,true)
				DisableControlAction(0,182,true)
				DisableControlAction(0,187,true)
				DisableControlAction(0,188,true)
				DisableControlAction(0,189,true)
				DisableControlAction(0,190,true)
				DisableControlAction(0,243,true)
				--DisableControlAction(0,245,true)
				DisableControlAction(0,257,true)
				DisableControlAction(0,263,true)
				DisableControlAction(0,264,true)
				DisableControlAction(0,268,true)
				DisableControlAction(0,269,true)
				DisableControlAction(0,270,true)
				DisableControlAction(0,271,true)
				DisableControlAction(0,288,true)
				DisableControlAction(0,289,true)
				DisableControlAction(0,311,true)
				DisableControlAction(0,344,true)
				--[[if not IsEntityPlayingAnim(ped,"missarmenian2","corpse_search_exit_ped",3) then
					tvRP.playAnim(false,{{"missarmenian2","corpse_search_exit_ped"}},true)
				end]]
			end
		end
		Citizen.Wait(ms)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUTTONTIMER
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        local ms = 1000
        local ped = PlayerPedId()
        if GetEntityHealth(ped) <= 101 and deathtimer <= 0 then
        	ms = 1
            if IsControlJustPressed(0,38) then
                deathtimer = 1
                nocauteado = false
                ClearPedBloodDamage(ped)
                SetEntityInvincible(ped,false)
                --DoScreenFadeOut(1000)
                SetEntityHealth(ped,400)
                --SetPedArmour(ped,0)
				TriggerEvent("jabgjiabgjkabgjkab10329y4910490204820348",0)
                Citizen.Wait(1000)
               -- SetEntityCoords(PlayerPedId(),-1038.68+0.0001,-2738.62+0.0001,13.82+0.0001,1,0,0,1)
                FreezeEntityPosition(ped,true)
                SetTimeout(1000,function()
                    FreezeEntityPosition(ped,false)
                    Citizen.Wait(1000)
                    DoScreenFadeIn(1000)
                end)
            end
        end
        Wait(ms)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HEALTHRECHARGE
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100)
		SetPlayerHealthRechargeMultiplier(PlayerId(),0)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DEATHTIMER
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		if nocauteado and deathtimer > 0 then
			deathtimer = deathtimer - 1
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DRAWTXT
-----------------------------------------------------------------------------------------------------------------------------------------
function drawTxt(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ISINCOMA
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.isInComa()
	return nocauteado
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NETWORKRESSURECTION
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.killGod()
	nocauteado = false
	local ped = PlayerPedId()
	local x,y,z = table.unpack(GetEntityCoords(ped))
	NetworkResurrectLocalPlayer(x,y,z,true,true,false)
	ClearPedBloodDamage(ped)
	SetEntityInvincible(ped,false)
	SetEntityHealth(ped,201)
	ClearPedTasks(ped)
	ClearPedSecondaryTask(ped)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NETWORKPRISON
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.PrisionGod()
	local ped = PlayerPedId()
	if GetEntityHealth(ped) <= 101 then
		nocauteado = false
		ClearPedBloodDamage(ped)
		SetEntityInvincible(ped,false)
		SetEntityHealth(ped,201)
		ClearPedTasks(ped)
		ClearPedSecondaryTask(ped)
	end
end