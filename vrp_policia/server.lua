local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
local Tools = module("vrp","lib/Tools")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
local idgens = Tools.newIDGenerator()
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEBHOOK
-----------------------------------------------------------------------------------------------------------------------------------------
local webhookmultas = "https://discordapp.com/api/webhooks/690989855005736971/dU3PxVZU87q9V3xvOIqSZqzL2SSudsDWTyaXL_433rrnacu-tCxowi-9evgiQuOwjO7A"
local webhookdetido = "https://discordapp.com/api/webhooks/690990314328031349/G6LAu-CZSTFpjizWPOMMk_v29of8Ad5q3e-6HiKc1s-9ru5-2a6o50IHjzBEWA6Mgelr"

local webhookarsenal = "https://discordapp.com/api/webhooks/678286363644264530/wqSRxX_e9S5y2vf5coeism9czmuU7vQhZLHJB8Hq68XNhXd_eHh6MB42wtYczixBpo-r"
local webhookprender = "https://discordapp.com/api/webhooks/678286776288149554/kMBRcq5l2NfI4vJ04v9lwl0u_u2XzneMOMNu0aqDSA2hIPNrsQcFY_ndp0ZjbSRMHM1m"
local webhookocorrencias = "https://discordapp.com/api/webhooks/678286993356226580/x4yH11gmfYP_x0lM7fjEB0AdkvpkxfytBAWiWwzIIQKIYUdouUj2WBORXf7veGAn2p2G"
local webhookservico = "https://discordapp.com/api/webhooks/678287471750152221/_i6n40DPjLw3xlDdPzUhFQQQLR1juAShBQNszChHHLciGWjwjEr0mdFv1tHEGRxVL4M5"
local webhookreanimar = "https://discordapp.com/api/webhooks/678287739090763796/sXcFG36zteJnVKAxaL6Vwdh4CjNgNHd8YcZvBwUgkfBhCzxyBhUp_w1x1X30_65gRFnF"
local webhookpoliciaapreendidos = "https://discordapp.com/api/webhooks/678287908851023882/F6_g29ESX0I4kbT49Ef-IERpeLIh5sg_KVIVYel7nw15JxNYbq1Pi4ahhZLyBplz0N2k"

function SendWebhookMessage(webhook,message)
	if webhook ~= nil and webhook ~= "" then
		PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BVIDA
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('bvida',function(source,rawCommand)
	local user_id = vRP.getUserId(source)		
		vRPclient._setCustomization(source,vRPclient.getCustomization(source))
		vRP.removeCloak(source)			
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PTR
 ----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('on', function(source,args,rawCommand)
 	local user_id = vRP.getUserId(source)
 	local player = vRP.getUserSource(user_id)
 	local oficiais = vRP.getUsersByPermission("policia.perm")
 	local paramedicos = 0
 	local oficiais_nomes = ""
 		for k,v in ipairs(oficiais) do
 			local identity = vRP.getUserIdentity(parseInt(v))
 			oficiais_nomes = oficiais_nomes .. "<b>" .. v .. "</b>: " .. identity.name .. " " .. identity.firstname .. "<br>"
 			paramedicos = paramedicos + 1
 		end
 		TriggerClientEvent("Notify",source,"importante", "Atualmente <b>"..paramedicos.." Player</b> Jogando.")
 		if parseInt(paramedicos) > 0 then
 			TriggerClientEvent("Notify",source,"importante", oficiais_nomes)
 		end
 	end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- P
-----------------------------------------------------------------------------------------------------------------------------------------
local policia = {}
RegisterCommand('p',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	local uplayer = vRP.getUserSource(user_id)
	local identity = vRP.getUserIdentity(user_id)
	local x,y,z = vRPclient.getPosition(source)
	if vRPclient.getHealth(source) > 100 then
		if vRP.hasPermission(user_id,"policia.perm") then
			local soldado = vRP.getUsersByPermission("policia.perm")
			for l,w in pairs(soldado) do
				local player = vRP.getUserSource(parseInt(w))
				if player and player ~= uplayer then
					async(function()
						local id = idgens:gen()
						policia[id] = vRPclient.addBlip(player,x,y,z,153,84,"Localização de "..identity.name.." "..identity.firstname,0.5,false)
						TriggerClientEvent("Notify",player,"importante","Localização recebida de <b>"..identity.name.." "..identity.firstname.."</b>.")
						vRPclient._playSound(player,"Out_Of_Bounds_Timer","DLC_HEISTS_GENERAL_FRONTEND_SOUNDS")
						SetTimeout(60000,function() vRPclient.removeBlip(player,policia[id]) idgens:free(id) end)
					end)
				end
			end
			TriggerClientEvent("Notify",source,"sucesso","Localização enviada com sucesso.")
			vRPclient.playSound(source,"Event_Message_Purple","GTAO_FM_Events_Soundset")
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REANIMAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('rnpc',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.perm") or vRP.hasPermission(user_id,"paramedico.perm") then
		TriggerClientEvent('reanimar',source)
	end
end)

RegisterServerEvent("reanimar:pagamento018301983190838131")
AddEventHandler("reanimar:pagamento018301983190838131",function()
	local user_id = vRP.getUserId(source)
	if user_id then
		pagamento = math.random(50,80)
		vRP.giveMoney(user_id,pagamento)
		TriggerClientEvent("Notify",source,"sucesso","Recebeu <b>$"..pagamento.." dólares</b> de gorjeta do americano.")
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RG
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('id',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.perm") or vRP.hasPermission(user_id,"mod.perm") or vRP.hasPermission(user_id,"suporte.perm")  then
		if args[1] then
			local nplayer = vRP.getUserSource(parseInt(args[1]))
			if nplayer == nil then
				TriggerClientEvent("Notify",source,"aviso","Passaporte <b>"..vRP.format(args[1]).."</b> indisponível no momento.")
				return
			end
			nuser_id = vRP.getUserId(nplayer)
			if nuser_id then
				local value = vRP.getUData(nuser_id,"vRP:multas")
				local valormultas = json.decode(value) or 0
				local identity = vRP.getUserIdentity(nuser_id)
				local carteira = vRP.getMoney(nuser_id)
				local banco = vRP.getBankMoney(nuser_id)
				vRPclient.setDiv(source,"completerg",".div_completerg { background-color: rgba(0,0,0,0.60); font-size: 13px; font-family: arial; color: #fff; width: 420px; padding: 20px 20px 5px; bottom: 8%; right: 2.5%; position: absolute; border: 1px solid rgba(255,255,255,0.2); letter-spacing: 0.5px; } .local { width: 220px; padding-bottom: 15px; float: left; } .local2 { width: 200px; padding-bottom: 15px; float: left; } .local b, .local2 b { color: #9900ff; }","<div class=\"local\"><b>Nome:</b> "..identity.name.." "..identity.firstname.." ( "..vRP.format(identity.user_id).." )</div><div class=\"local2\"><b>Identidade:</b> "..identity.registration.."</div><div class=\"local\"><b>Idade:</b> "..identity.age.." Anos</div><div class=\"local2\"><b>Telefone:</b> "..identity.phone.."</div><div class=\"local\"><b>Multas pendentes:</b> "..vRP.format(parseInt(valormultas)).."</div><div class=\"local2\"><b>Carteira:</b> "..vRP.format(parseInt(carteira)).."</div>")
				vRP.request(source,"Você deseja fechar o registro geral?",1000)
				vRPclient.removeDiv(source,"completerg")
			end
		else
			local nplayer = vRPclient.getNearestPlayer(source,2)
			local nuser_id = vRP.getUserId(nplayer)
			if nuser_id then
				local value = vRP.getUData(nuser_id,"vRP:multas")
				local valormultas = json.decode(value) or 0
				local identityv = vRP.getUserIdentity(user_id)
				local identity = vRP.getUserIdentity(nuser_id)
				local carteira = vRP.getMoney(nuser_id)
				local banco = vRP.getBankMoney(nuser_id)
				TriggerClientEvent("Notify",nplayer,"importante","Seu documento está sendo verificado por <b>"..identityv.name.." "..identityv.firstname.."</b>.")
				vRPclient.setDiv(source,"completerg",".div_completerg { background-color: rgba(0,0,0,0.60); font-size: 13px; font-family: arial; color: #fff; width: 420px; padding: 20px 20px 5px; bottom: 8%; right: 2.5%; position: absolute; border: 1px solid rgba(255,255,255,0.2); letter-spacing: 0.5px; } .local { width: 220px; padding-bottom: 15px; float: left; } .local2 { width: 200px; padding-bottom: 15px; float: left; } .local b, .local2 b { color: #9900ff; }","<div class=\"local\"><b>Nome:</b> "..identity.name.." "..identity.firstname.." ( "..vRP.format(identity.user_id).." )</div><div class=\"local2\"><b>Identidade:</b> "..identity.registration.."</div><div class=\"local\"><b>Idade:</b> "..identity.age.." Anos</div><div class=\"local2\"><b>Telefone:</b> "..identity.phone.."</div><div class=\"local\"><b>Multas pendentes:</b> "..vRP.format(parseInt(valormultas)).."</div><div class=\"local2\"><b>Carteira:</b> "..vRP.format(parseInt(carteira)).."</div>")
				vRP.request(source,"Você deseja fechar o registro geral?",1000)
				vRPclient.removeDiv(source,"completerg")
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REANIMAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('reanimar',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"paramedico.perm") then
		local nplayer = vRPclient.getNearestPlayer(source,2)
		if nplayer then
			if vRPclient.isInComa(nplayer) then
				local identity_user = vRP.getUserIdentity(user_id)
				local nuser_id = vRP.getUserId(nplayer)
				local identity_coma = vRP.getUserIdentity(nuser_id)
				local set_user = "Policia"
				if vRP.hasPermission(user_id,"paramedico.perm") then
					set_user = "Paramedico"
				end
				TriggerClientEvent('cancelando',source,true)
				vRPclient._playAnim(source,false,{{"amb@medic@standing@tendtodead@base","base"},{"mini@cpr@char_a@cpr_str","cpr_pumpchest"}},true)
				TriggerClientEvent("progress",source,30000,"reanimando")
				SetTimeout(30000,function()
					SendWebhookMessage(webhookreanimar,"```[ID]: "..user_id.." "..identity_user.name.." "..identity_user.firstname.." \n[REVIVEU]: "..nuser_id.." "..identity_coma.name.." "..identity_coma.firstname .. "\n[SET]: "..set_user..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
					vRPclient.killGod(nplayer)
					vRPclient._stopAnim(source,false)
					vRP.giveMoney(user_id,200)
					TriggerClientEvent("resetBleeding",nplayer)
					TriggerClientEvent('cancelando',source,false)
				end)
			else
				TriggerClientEvent("Notify",source,"importante","A pessoa precisa estar em coma para prosseguir.")
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ARSENAL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('arsenal',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"policia.perm") then
		TriggerClientEvent('arsenal',source)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ANUNCIO
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('anuncio',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.perm") or vRP.hasPermission(user_id,"policia.perm") then
		local identity = vRP.getUserIdentity(user_id)
		local mensagem = vRP.prompt(source,"Mensagem:","")
		if mensagem == "" then
			return
		end
		vRPclient.setDiv(-1,"anuncio",".div_anuncio { background: rgba(0,128,192,0.8); font-size: 11px; font-family: arial; color: #fff; padding: 20px; bottom: 7%; right: 5%; max-width: 500px; position: absolute; -webkit-border-radius: 5px; } bold { font-size: 15px; }","<bold>"..mensagem.."</bold><br><br>Mensagem enviada por: "..identity.name.." "..identity.firstname)
		SetTimeout(30000,function()
			vRPclient.removeDiv(-1,"anuncio")
		end)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ARMAS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('armas',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	if user_id then
    	SendWebhookMessage(webhookarsenal,"```[ID]: "..user_id.." "..identity.name.." "..identity.firstname.." \n[RETIROU]: "..("armas").." "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
		vRPclient.giveWeapons(source,{["WEAPON_STUNGUN"] = { ammo = 0 }})
		--vRPclient.giveWeapons(source,{["WEAPON_FIREWORK"] = { ammo = 10 }})
		vRPclient.giveWeapons(source,{["WEAPON_NIGHTSTICK"] = { ammo = 0 }})
		vRPclient.giveWeapons(source,{["WEAPON_FLASHLIGHT"] = { ammo = 0 }})
		vRPclient.giveWeapons(source,{["WEAPON_FIREEXTINGUISHER"] = { ammo = 0 }})
		vRPclient.giveWeapons(source,{["WEAPON_PISTOL"] = { ammo = 100 }})
		vRPclient.giveWeapons(source,{["WEAPON_COMBATPISTOL"] = { ammo = 100 }})
		vRPclient.giveWeapons(source,{["WEAPON_REVOLVER_MK2"] = { ammo = 50 }})
		vRPclient.giveWeapons(source,{["WEAPON_SMG"] = { ammo = 200 }})
		vRPclient.giveWeapons(source,{["WEAPON_COMBATPDW"] = { ammo = 200 }})
		vRPclient.giveWeapons(source,{["WEAPON_PUMPSHOTGUN_MK2"] = { ammo = 30 }})
		vRPclient.giveWeapons(source,{["WEAPON_CARBINERIFLE"] = { ammo = 200 }})
		vRPclient.giveWeapons(source,{["WEAPON_HEAVYSNIPER_MK2"] = { ammo = 50 }})
		vRPclient.giveWeapons(source,{["WEAPON_BZGAS"] = { ammo = 1 }})
		vRPclient.giveWeapons(source,{["WEAPON_APPISTOL"] = { ammo = 200 }})
		vRPclient.giveWeapons(source,{["WEAPON_MICROSMG"] = { ammo = 300 }})
		vRPclient.giveWeapons(source,{["WEAPON_PISTOL50"] = { ammo = 300 }})
		vRPclient.giveWeapons(source,{["WEAPON_SNSPISTOL"] = { ammo = 300 }})
		vRPclient.giveWeapons(source,{["WEAPON_SPECIALCARBINE"] = { ammo = 300 }})
		vRPclient.giveWeapons(source,{["WEAPON_HEAVYPISTOL"] = { ammo = 300 }})
		vRPclient.giveWeapons(source,{["WEAPON_VINTAGEPISTOL"] = { ammo = 300 }})
		vRPclient.giveWeapons(source,{["WEAPON_SNOWBALL"] = { ammo = 300 }})
		vRPclient.giveWeapons(source,{["WEAPON_GUSENBERG"] = { ammo = 300 }})
		vRPclient.giveWeapons(source,{["WEAPON_MACHINEPISTOL"] = { ammo = 300 }})
		vRPclient.giveWeapons(source,{["WEAPON_COMPACTRIFLE"] = { ammo = 300 }})
		vRPclient.giveWeapons(source,{["WEAPON_FLASHLIGHT"] = { ammo = 300 }})
		vRPclient.giveWeapons(source,{["WEAPON_MINISMG"] = { ammo = 200 }})
		vRPclient.giveWeapons(source,{["WEAPON_BULLPUPSHOTGUN"] = { ammo = 200 }})
		vRPclient.giveWeapons(source,{["WEAPON_ASSAULTSHOTGUN"] = { ammo = 300 }})
		vRPclient.giveWeapons(source,{["WEAPON_ASSAULTRIFLE"] = { ammo = 300 }})
		vRPclient.giveWeapons(source,{["WEAPON_ASSAULTSMG"] = { ammo = 300 }})
		vRPclient.giveWeapons(source,{["WEAPON_KNIFE"] = { ammo = 0 }})
		vRPclient.giveWeapons(source,{["weapon_navyrevolver"] = { ammo = 300 }})
		vRPclient.giveWeapons(source,{["weapon_heavyshotgun"] = { ammo = 300 }})
		vRPclient.giveWeapons(source,{["weapon_sawnoffshotgun"] = { ammo = 300 }})
		vRPclient.giveWeapons(source,{["weapon_carbinerifle_mk2"] = { ammo = 300 }})
		vRPclient.giveWeapons(source,{["weapon_bullpuprifle_mk2"] = { ammo = 300 }})
		vRPclient.giveWeapons(source,{["weapon_combatmg_mk2"] = { ammo = 300 }})
		vRPclient.giveWeapons(source,{["weapon_combatmg"] = { ammo = 300 }})
		vRPclient.giveWeapons(source,{["weapon_mg"] = { ammo = 300 }})
		vRPclient.giveWeapons(source,{["weapon_heavysniper"] = { ammo = 300 }})	
		vRPclient.giveWeapons(source,{["weapon_marksmanrifle"] = { ammo = 300 }})
		vRPclient.giveWeapons(source,{["WEAPON_HATCHET"] = { ammo = 300 }})		

				
		vRPclient.setArmour(source,100)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- LIMPAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('limpar',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	if user_id then
		TriggerClientEvent("Notify",source,"sucesso","Você limpou seus armamentos.")
		vRPclient.giveWeapons(source,{},true)
		vRPclient.setArmour(source,0)
	end
end)