local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEBHOOK
-----------------------------------------------------------------------------------------------------------------------------------------
local webhookadmin = ""
local webhookfac = ""
local webhookcds = ""
local webhookblacklistarmas = ""

function SendWebhookMessage(webhook,message)
	if webhook ~= nil and webhook ~= "" then
		PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- VROUPAS
-----------------------------------------------------------------------------------------------------------------------------------------
local player_customs = {}
RegisterCommand('vroupas',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    local custom = vRPclient.getCustomization(source)
    if vRP.hasPermission(user_id,"admin.perm") then
        if player_customs[source] then
            player_customs[source] = nil
            vRPclient._removeDiv(source,"customization")
        else 
            local content = ""
            for k,v in pairs(custom) do
                content = content..k.." => "..json.encode(v).."<br/>" 
            end

            player_customs[source] = true
            vRPclient._setDiv(source,"customization",".div_customization{ margin: auto; padding: 4px; width: 250px; margin-top: 200px; margin-right: 50px; background: rgba(15,15,15,0.7); color: #ffff; font-weight: bold; }",content)
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- LIMPAR AREA
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('limpararea',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    local x,y,z = vRPclient.getPosition(source)
    if vRP.hasPermission(user_id,"admin.perm") then
        TriggerClientEvent("syncarea",-1,x,y,z)
        TriggerClientEvent("Notify",source,"sucesso","Área limpada.")
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RENOMEAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('renomear',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id,"admin.perm") then
        local idjogador = vRP.prompt(source,"Qual id do jogador?","")
        local nome = vRP.prompt(source,"Novo nome","")
        local firstname = vRP.prompt(source,"Novo sobrenome","")
		local idade = vRP.prompt(source,"Nova idade","")
		local identity = vRP.getUserIdentity(parseInt(idjogador))
        vRP.execute("vRP/update_user_identity",{
			user_id = idjogador,
            firstname = firstname,
            name = nome,
            age = idade,
			registration = identity.registration,
			phone = identity.phone
        })
        TriggerClientEvent("Notify",source,"sucesso","Identidade alterada.")
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FIX
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('fix',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	local vehicle = vRPclient.getNearestVehicle(source,11)
	if vehicle then
		TriggerClientEvent('reparar',source)
		TriggerClientEvent("Notify",source,"sucesso","Veículo reparado.")
		SendWebhookMessage(webhookadmin,"```prolog\n[ID]: "..user_id.." "..identity.name.." "..identity.firstname.." \n[REPAROU UM VEÍCULO] "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DV
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('dv',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
        local vehicle = vRPclient.getNearestVehicle(source,7)
        if vehicle then
            TriggerClientEvent('deletarveiculo',source,vehicle)
        end
    end)
RegisterNetEvent('deletarveiculo')
AddEventHandler('deletarveiculo',function(vehicle)
    TriggerServerEvent("vrp_garages:admDelete",VehToNet(vehicle))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GOD
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('god',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    local identity = vRP.getUserIdentity(user_id)
    if vRP.hasPermission(user_id,"admin.perm") then
        if args[1] then
            local nplayer = vRP.getUserSource(parseInt(args[1]))
            if nplayer then
                vRPclient.killGod(nplayer)
                vRPclient.setHealth(nplayer,400)
                TriggerClientEvent("Notify",source,"sucesso","ID: <b>"..args[1].."</b> revivido.")
            end
        else
            vRPclient.killGod(source)
            vRPclient.setHealth(source,400)
            TriggerClientEvent("Notify",source,"sucesso","Você se reviveu.")
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GOD ALL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('godall',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id,"admin.perm") then
    	local users = vRP.getUsers()
        for k,v in pairs(users) do
            local id = vRP.getUserSource(parseInt(k))
            if id then
            	vRPclient.killGod(id)
				vRPclient.setHealth(id,400)
				TriggerClientEvent("Notify",source,"sucesso","Todo mundo foi revivido.")
				print(id)
            end
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('colete',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id,"admin.perm") or vRP.hasPermission(user_id,"policia.perm") then
        if args[1] then
            local nplayer = vRP.getUserSource(parseInt(args[1]))
            if nplayer then
                vRPclient.setArmour(nplayer,100)
                TriggerClientEvent("Notify",source,"sucesso","ID: <b>"..args[1].."</b> adicionado colete.")
            end
        else
            vRPclient.setArmour(source,100)
            TriggerClientEvent("Notify",source,"sucesso","Você se adicionou colete.")
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- KILL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('kill',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    local identity = vRP.getUserIdentity(user_id)
    if vRP.hasPermission(user_id,"admin.perm") then
        if args[1] then
            local nplayer = vRP.getUserSource(parseInt(args[1]))
            if nplayer then
                vRPclient.setHealth(nplayer,0)
                TriggerClientEvent("Notify",source,"sucesso","ID: <b>"..args[1].."</b> foi morto.")
            end
        else
            vRPclient.setHealth(source,0)
            TriggerClientEvent("Notify",source,"sucesso","Você se matou.")
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- WL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('wl',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    local identity = vRP.getUserIdentity(user_id)
    if vRP.hasPermission(user_id,"admin.perm") or vRP.hasPermission(user_id,"mod.perm") or vRP.hasPermission(user_id,"suporte.perm") then
        if args[1] then
            vRP.setWhitelisted(parseInt(args[1]),true)
            TriggerClientEvent("Notify",source,"sucesso","ID: <b>"..args[1].."</b> adicionado na whitelist.")
            SendWebhookMessage(webhookadmin,"```[ID]: "..user_id.." "..identity.name.." "..identity.firstname.." \n[APROVOU WL]: "..args[1].." "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UNWL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('unwl',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	if vRP.hasPermission(user_id,"admin.perm") or vRP.hasPermission(user_id,"mod.perm") or vRP.hasPermission(user_id,"suporte.perm")  then
		if args[1] then
			vRP.setWhitelisted(parseInt(args[1]),false)
			TriggerClientEvent("Notify",source,"sucesso","ID: <b>"..args[1].."</b> removido da whitelist.")
			SendWebhookMessage(webhookadmin,"```[ID]: "..user_id.." "..identity.name.." "..identity.firstname.." \n[RETIROU WL]: "..args[1].." "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- KICK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('kick',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	if vRP.hasPermission(user_id,"admin.perm") or vRP.hasPermission(user_id,"mod.perm") or vRP.hasPermission(user_id,"suporte.perm") then
		if args[1] then
			local id = vRP.getUserSource(parseInt(args[1]))
			if id then
				vRP.kick(id,"Você foi expulso da cidade.")
				TriggerClientEvent("Notify",source,"sucesso","ID: <b>"..args[1].."</b> foi expulso.")
				SendWebhookMessage(webhookadmin,"```[ID]: "..user_id.." "..identity.name.." "..identity.firstname.." \n[KICKOU]: "..args[1].." "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- KICK ALL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('kickall',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id,"admin.perm") then
        local users = vRP.getUsers()
        for k,v in pairs(users) do
            local id = vRP.getUserSource(parseInt(k))
            if id then
                vRP.kick(id,"Você foi vitima do terremoto.")
                TriggerClientEvent("Notify",source,"sucesso","Todo mundo foi expulso.")
            end
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BAN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('ban',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	if vRP.hasPermission(user_id,"admin.perm") or vRP.hasPermission(user_id,"mod.perm") then
		if args[1] then
			vRP.setBanned(parseInt(args[1]),true)
			TriggerClientEvent("Notify",source,"sucesso","ID: <b>"..args[1].."</b> banido.")
			SendWebhookMessage(webhookadmin,"```[ID]: "..user_id.." "..identity.name.." "..identity.firstname.." \n[BANIU]: "..args[1].." "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UNBAN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('unban',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	if vRP.hasPermission(user_id,"admin.perm") then
		if args[1] then
			vRP.setBanned(parseInt(args[1]),false)
			TriggerClientEvent("Notify",source,"sucesso","ID: <b>"..args[1].."</b> desbanido.")
			SendWebhookMessage(webhookadmin,"```[ID]: "..user_id.." "..identity.name.." "..identity.firstname.." \n[DESBANIU]: "..args[1].." "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NC
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('nc',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.perm") or vRP.hasPermission(user_id,"mod.perm") or vRP.hasPermission(user_id,"suporte.perm") then
		vRPclient.toggleNoclip(source)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TPCDS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('tpcds',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.perm") then
		local fcoords = vRP.prompt(source,"Cordenadas:","")
		if fcoords == "" then
			return
		end
		local coords = {}
		for coord in string.gmatch(fcoords or "0,0,0","[^,]+") do
			table.insert(coords,parseInt(coord))
		end
		vRPclient.teleport(source,coords[1] or 0,coords[2] or 0,coords[3] or 0)
		TriggerClientEvent("Notify",source,"sucesso","Teleportado para as coordenadas: <b>"..coords[1]..","..coords[2]..","..coords[3].."</b>.")
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CDS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('cds',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.perm") then
		local x,y,z = vRPclient.getPosition(source)
		vRP.prompt(source,"Cordenadas:",x..","..y..","..z)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GROUP
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('group',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	if vRP.hasPermission(user_id,"admin.perm") or vRP.hasPermission(user_id,"mod.perm") then
		if args[1] and args[2] then
			vRP.addUserGroup(parseInt(args[1]),args[2])
			TriggerClientEvent("Notify",source,"sucesso","Grupo: <b>"..args[2].."</b> adicionado no ID: <b>"..args[1].."</b>.")
			SendWebhookMessage(webhookadmin,"```[ID]: "..user_id.." "..identity.name.." "..identity.firstname.." \n[SETOU]: "..args[1].." \n[GRUPO]: "..args[2].." "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UNGROUP
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('ungroup',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	if vRP.hasPermission(user_id,"admin.perm") then
		if args[1] and args[2] then
			vRP.removeUserGroup(parseInt(args[1]),args[2])
			TriggerClientEvent("Notify",source,"sucesso","Grupo: <b>"..args[2].."</b> removido do ID: <b>"..args[1].."</b>.")
			SendWebhookMessage(webhookadmin,"```[ID]: "..user_id.." "..identity.name.." "..identity.firstname.." \n[REMOVEU]: "..args[1].." \n[GRUPO]: "..args[2].." "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TPTOME
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('tptome',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.perm") or vRP.hasPermission(user_id,"mod.perm") then
		if args[1] then
			local tplayer = vRP.getUserSource(parseInt(args[1]))
			local x,y,z = vRPclient.getPosition(source)
			if tplayer then
				vRPclient.teleport(tplayer,x,y,z)
				TriggerClientEvent("Notify",source,"sucesso","ID: <b>"..args[1].."</b> puxado até você.")
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- 	TPTO
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('tpto',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.perm") or vRP.hasPermission(user_id,"mod.perm") or vRP.hasPermission(user_id,"suporte.perm") then
		if args[1] then
			local tplayer = vRP.getUserSource(parseInt(args[1]))
			if tplayer then
				vRPclient.teleport(source,vRPclient.getPosition(tplayer))
				TriggerClientEvent("Notify",source,"sucesso","Teleportado para o ID: <b>"..args[1].."</b>.")
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TPWAY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('tpway',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.perm") or vRP.hasPermission(user_id,"policia.perm") then
		TriggerClientEvent('tptoway',source)
		TriggerClientEvent("Notify",source,"sucesso","Teleportado para a localização marcada!")
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('car',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	if vRP.hasPermission(user_id,"admin.perm") or vRP.hasPermission(user_id,"policia.perm") then
		if args[1] then
			TriggerClientEvent('spawnarveiculo',source,args[1])
			TriggerClientEvent("Notify",source,"sucesso","Veículo spawnado: <b>"..args[1].."</b>.")
			SendWebhookMessage(webhookadmin,"```[ID]: "..user_id.." "..identity.name.." "..identity.firstname.." \n[SPAWNOU]: "..(args[1]).." "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DEL NPCS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('delnpcs',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.perm") then
		TriggerClientEvent('delnpcs',source)
		TriggerClientEvent("Notify",source,"sucesso","Todos os NPCS mortos foram removidos.")
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- AVISO
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('aviso',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	if vRP.hasPermission(user_id,"admin.perm") or vRP.hasPermission(user_id,"mod.perm") then
		local mensagem = vRP.prompt(source,"Mensagem:","")
		if mensagem == "" then
			return
		end
		TriggerClientEvent("Notify",source,"sucesso","Aviso enviado.")
		SendWebhookMessage(webhookadmin,"```[ID]: "..user_id.." "..identity.name.." "..identity.firstname.." \n[AVISOU]: "..mensagem.." "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
		vRPclient.setDiv(-1,"anuncio",".div_anuncio { background: rgba(255,50,50,0.8); font-size: 11px; font-family: arial; color: #fff; padding: 20px; bottom: 10%; right: 5%; max-width: 500px; position: absolute; -webkit-border-radius: 5px; } bold { font-size: 16px; }","<bold>"..mensagem.."</bold><br><br>O administrador: "..identity.name.." "..identity.firstname.." enviou um aviso.")
		SetTimeout(60000,function()
			vRPclient.removeDiv(-1,"anuncio")
		end)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MSG ADMIN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('msgadmin',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	if vRP.hasPermission(user_id,"admin.perm") or vRP.hasPermission(user_id,"mod.perm") then
		local mensagem = vRP.prompt(source,"Mensagem:","")
		if mensagem == "" then
			return
		end
		SendWebhookMessage(webhookadmin,"```[ID]: "..user_id.." "..identity.name.." "..identity.firstname.." \n[MENSAGEM]: "..mensagem.." "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
		vRPclient.setDiv(-1,"anuncio",".div_anuncio { background: rgba(153,0,255,0.8); font-size: 11px; font-family: arial; color: #fff; padding: 20px; bottom: 10%; right: 5%; max-width: 500px; position: absolute; -webkit-border-radius: 5px; } bold { font-size: 16px; }","<bold>"..mensagem.."</bold><br><br>O administrador: "..identity.name.." "..identity.firstname.." enviou uma mensagem.")
		SetTimeout(60000,function()
			vRPclient.removeDiv(-1,"anuncio")
		end)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('players',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id,"admin.perm") or vRP.hasPermission(user_id,"mod.perm") then
        local users = vRP.getUsers()
        local players = ""
        local quantidade = 0
        for k,v in pairs(users) do
            if k ~= #users then
                players = players..", "
            end
            players = players..k
            quantidade = quantidade + 1
        end
        TriggerClientEvent('chatMessage',source,"TOTAL ONLINE",{255,0,0},quantidade)
        TriggerClientEvent('chatMessage',source,"IDS ONLINE",{255,0,0},players)
    end
end)
------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DEBUG
------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('debug',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if user_id ~= nil then
		local player = vRP.getUserSource(user_id)
		if vRP.hasPermission(user_id,"admin.perm") then
			TriggerClientEvent("ToggleDebug",player)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BLACKLIST ARMAS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("adminLogs:Armamentos")
AddEventHandler("adminLogs:Armamentos",function(weapon)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
    	SendWebhookMessage(webhookblacklistarmas,"```[BLACKLIST ARMAS]: "..user_id.." " .. "\n[ARMA]: " .. weapon ..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```<@&641048265856647169>")  
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRYDELETEVEH
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("trydeleteveh")
AddEventHandler("trydeleteveh",function(index)
	TriggerClientEvent("syncdeleteveh",-1,index)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRYDELETEOBJ
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("trydeleteobj")
AddEventHandler("trydeleteobj",function(index)
    TriggerClientEvent("syncdeleteobj",-1,index)
end)