local Proxy = module("lib/Proxy")
local Tunnel = module("lib/Tunnel")

local config = module("cfg/base")

vRP = {}
Proxy.addInterface("vRP",vRP)

tvRP = {}
Tunnel.bindInterface("vRP",tvRP)
vRPclient = Tunnel.getInterface("vRP")

vRP.users = {}
vRP.rusers = {}
vRP.user_tables = {}
vRP.user_tmp_tables = {}
vRP.user_sources = {}

local db_drivers = {}
local db_driver
local cached_prepares = {}
local cached_queries = {}
local prepared_queries = {}
local db_initialized = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEBHOOK
-----------------------------------------------------------------------------------------------------------------------------------------
local webhookconnect = ""
local webhookdisconnect = ""
local webhookpolicia = ""
local webhookparamedico = ""
local webhookmecanico = ""

function SendWebhookMessage2(webhook,message)
	if webhook ~= nil and webhook ~= "" then
		PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BASE.LUA
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.registerDBDriver(name,on_init,on_prepare,on_query)
	if not db_drivers[name] then
		db_drivers[name] = { on_init,on_prepare,on_query }

		if name == config.db.driver then
			db_driver = db_drivers[name]

			local ok = on_init(config.db)
			if ok then
				db_initialized = true
				for _,prepare in pairs(cached_prepares) do
					on_prepare(table.unpack(prepare,1,table.maxn(prepare)))
				end

				for _,query in pairs(cached_queries) do
					query[2](on_query(table.unpack(query[1],1,table.maxn(query[1]))))
				end

				cached_prepares = nil
				cached_queries = nil
			end
		end
	end
end

function vRP.format(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

function vRP.prepare(name,query)
	prepared_queries[name] = true

	if db_initialized then
		db_driver[2](name,query)
	else
		table.insert(cached_prepares,{ name,query })
	end
end

function vRP.query(name,params,mode)
	if not mode then mode = "query" end

	if db_initialized then
		return db_driver[3](name,params or {},mode)
	else
		local r = async()
		table.insert(cached_queries,{{ name,params or {},mode },r })
		return r:wait()
	end
end

function vRP.execute(name,params)
	return vRP.query(name,params,"execute")
end

vRP.prepare("vRP/create_user","INSERT INTO vrp_users(whitelisted,banned) VALUES(true,false); SELECT LAST_INSERT_ID() AS id")
vRP.prepare("vRP/add_identifier","INSERT INTO vrp_user_ids(identifier,user_id) VALUES(@identifier,@user_id)")
vRP.prepare("vRP/userid_byidentifier","SELECT user_id FROM vrp_user_ids WHERE identifier = @identifier")
vRP.prepare("vRP/set_userdata","REPLACE INTO vrp_user_data(user_id,dkey,dvalue) VALUES(@user_id,@key,@value)")
vRP.prepare("vRP/get_userdata","SELECT dvalue FROM vrp_user_data WHERE user_id = @user_id AND dkey = @key")
vRP.prepare("vRP/set_srvdata","REPLACE INTO vrp_srv_data(dkey,dvalue) VALUES(@key,@value)")
vRP.prepare("vRP/get_srvdata","SELECT dvalue FROM vrp_srv_data WHERE dkey = @key")
vRP.prepare("vRP/get_banned","SELECT banned FROM vrp_users WHERE id = @user_id")
vRP.prepare("vRP/set_banned","UPDATE vrp_users SET banned = @banned WHERE id = @user_id")
vRP.prepare("vRP/get_whitelisted","SELECT whitelisted FROM vrp_users WHERE id = @user_id")
vRP.prepare("vRP/set_whitelisted","UPDATE vrp_users SET whitelisted = @whitelisted WHERE id = @user_id")
vRP.prepare("vRP/set_last_login","UPDATE vrp_users SET last_login = @last_login, ip = @ip WHERE id = @user_id")

function vRP.getUserIdByIdentifier(ids)
	local rows = vRP.query("vRP/userid_byidentifier",{ identifier = ids})
	if #rows > 0 then
		return rows[1].user_id
	else
		return -1
	end
end

function vRP.getUserIdByIdentifiers(ids)
	if ids and #ids then
		for i=1,#ids do
			if (string.find(ids[i],"ip:") == nil) then
				local rows = vRP.query("vRP/userid_byidentifier",{ identifier = ids[i] })
				if #rows > 0 then
					return rows[1].user_id
				end
			end
		end

		local rows,affected = vRP.query("vRP/create_user",{})

		if #rows > 0 then
			local user_id = rows[1].id
			for l,w in pairs(ids) do
				if (string.find(w,"ip:") == nil) then
					vRP.execute("vRP/add_identifier",{ user_id = user_id, identifier = w })
				end
			end
			return user_id
		end
	end
end

function vRP.getPlayerEndpoint(player)
	return GetPlayerEP(player) or "0.0.0.0"
end

function vRP.isBanned(user_id, cbr)
	local rows = vRP.query("vRP/get_banned",{ user_id = user_id })
	if #rows > 0 then
		return rows[1].banned
	else
		return false
	end
end

function vRP.setBanned(user_id,banned)
	vRP.execute("vRP/set_banned",{ user_id = user_id, banned = banned })
end

function vRP.isWhitelisted(user_id, cbr)
	local rows = vRP.query("vRP/get_whitelisted",{ user_id = user_id })
	if #rows > 0 then
		return rows[1].whitelisted
	else
		return false
	end
end

function vRP.setWhitelisted(user_id,whitelisted)
	vRP.execute("vRP/set_whitelisted",{ user_id = user_id, whitelisted = whitelisted })
end

function vRP.setUData(user_id,key,value)
	vRP.execute("vRP/set_userdata",{ user_id = user_id, key = key, value = value })
end

function vRP.getUData(user_id,key,cbr)
	local rows = vRP.query("vRP/get_userdata",{ user_id = user_id, key = key })
	if #rows > 0 then
		return rows[1].dvalue
	else
		return ""
	end
end

function vRP.setSData(key,value)
	vRP.execute("vRP/set_srvdata",{ key = key, value = value })
end

function vRP.getSData(key, cbr)
	local rows = vRP.query("vRP/get_srvdata",{ key = key })
	if #rows > 0 then
		return rows[1].dvalue
	else
		return ""
	end
end

function vRP.getUserDataTable(user_id)
	return vRP.user_tables[user_id]
end

function vRP.getUserTmpTable(user_id)
	return vRP.user_tmp_tables[user_id]
end

function vRP.getUserId(source)
	if source ~= nil then
		local ids = GetPlayerIdentifiers(source)
		if ids ~= nil and #ids > 0 then
			return vRP.users[ids[1]]
		end
	end
	return nil
end

function vRP.getUsers()
	local users = {}
	for k,v in pairs(vRP.user_sources) do
		users[k] = v
	end
	return users
end

function vRP.getUserSource(user_id)
	return vRP.user_sources[user_id]
end

function vRP.kick(source,reason)
	DropPlayer(source,reason)
end

function vRP.dropPlayer(source)
	local source = source
	local user_id = vRP.getUserId(source)
	vRPclient._removePlayer(-1,source)
	if user_id then
		if user_id and source then
			TriggerEvent("vRP:playerLeave",user_id,source)
			SendWebhookMessage2(webhookdisconnect,"```[ID]: "..user_id.." \n[IP]: "..GetPlayerEndpoint(source).." \n[=========SAIU DO SERVIDOR=========]"..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
			local identity = vRP.getUserIdentity(user_id)
			if vRP.hasGroup(user_id,"Taxista") then
				vRP.removeUserGroup(user_id,"Taxista")
			elseif vRP.hasGroup(user_id,"Policia") then
				vRP.addUserGroup(user_id,"PaisanaPolicia")
				SendWebhookMessage2(webhookpolicia,"```[POLICIAL]: "..user_id.." "..identity.name.." "..identity.firstname.." \n[===========SAIU DE SERVICO==========] "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
			elseif vRP.hasGroup(user_id,"Paramedico") then
				vRP.addUserGroup(user_id,"PaisanaParamedico")
				SendWebhookMessage2(webhookparamedico,"```[PARAMÉDICO]: "..user_id.." "..identity.name.." "..identity.firstname.." \n[===========SAIU DE SERVICO==========] "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")	
			elseif vRP.hasGroup(user_id,"Mecanico") then
				vRP.addUserGroup(user_id,"PaisanaMecanico")
				SendWebhookMessage2(webhookmecanico,"```[MECÂNICO]: "..user_id.." "..identity.name.." "..identity.firstname.." \n[===========SAIU DE SERVICO==========] "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
			end
		end
		vRP.setUData(user_id,"vRP:datatable",json.encode(vRP.getUserDataTable(user_id)))
		vRP.users[vRP.rusers[user_id]] = nil
		vRP.rusers[user_id] = nil
		vRP.user_tables[user_id] = nil
		vRP.user_tmp_tables[user_id] = nil
		vRP.user_sources[user_id] = nil
	end
end

function task_save_datatables()
	SetTimeout(60000,task_save_datatables)
	TriggerEvent("vRP:save")
	for k,v in pairs(vRP.user_tables) do
		vRP.setUData(k,"vRP:datatable",json.encode(v))
	end
end

async(function()
	task_save_datatables()
end)

AddEventHandler("queue:playerConnecting",function(source,ids,name,setKickReason,deferrals)
	deferrals.defer()
	local source = source
	local ids = ids

	if ids ~= nil and #ids > 0 then
		deferrals.update("[MSPVP] Checando identidades...")
		local user_id = vRP.getUserIdByIdentifiers(ids)
		if user_id then
			deferrals.update("[MSPVP] Checando banimentos...")
			if not vRP.isBanned(user_id) then
				deferrals.update("[MSPVP] Checando whitelist...")
				if vRP.isWhitelisted(user_id) then
					if vRP.rusers[user_id] == nil then
						deferrals.update("[MSPVP] Carregando banco de dados...")
						local sdata = vRP.getUData(user_id,"vRP:datatable")

						vRP.users[ids[1]] = user_id
						vRP.rusers[user_id] = ids[1]
						vRP.user_tables[user_id] = {}
						vRP.user_tmp_tables[user_id] = {}
						vRP.user_sources[user_id] = source

						local data = json.decode(sdata)
						if type(data) == "table" then vRP.user_tables[user_id] = data end

						local tmpdata = vRP.getUserTmpTable(user_id)
						tmpdata.spawns = 0

						vRP.execute("vRP/set_last_login",{ user_id = user_id, last_login = os.date("%d.%m.%Y"), ip = GetPlayerEndpoint(source) })

						TriggerEvent("vRP:playerJoin",user_id,source,name)
						SendWebhookMessage2(webhookconnect,"```[ID]: "..user_id.." \n[IP]: "..GetPlayerEndpoint(source).." \n[=========ENTROU NO SERVIDOR=========]: "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
						deferrals.done()
					else
						local tmpdata = vRP.getUserTmpTable(user_id)
						tmpdata.spawns = 0

						TriggerEvent("vRP:playerRejoin",user_id,source,name)
						deferrals.done()
					end
				else
					deferrals.done("Seu ID não está adicionado na Whitelist. Acesse nosso discord e envie seu ID para ser aprovado.\n\nSeu ID: "..user_id.."\nDiscord: https://discord.gg/Kxn3BT4")
					TriggerEvent("queue:playerConnectingRemoveQueues",ids)
				end
			else
				deferrals.done("Você foi banido do servidor. Para revogar seu banimento, acesse: https://discord.gg/nyyGTjF.")

				TriggerEvent("queue:playerConnectingRemoveQueues",ids)
			end
		else
			deferrals.done("Ocorreu um problema com sua identificação.")
			TriggerEvent("queue:playerConnectingRemoveQueues",ids)
		end
	else
		deferrals.done("Ocorreu um problema com sua identidade.")
		TriggerEvent("queue:playerConnectingRemoveQueues",ids)
	end
end)

AddEventHandler("playerDropped",function(reason)
	local source = source
	vRP.dropPlayer(source)
end)

RegisterServerEvent("vRPcli:playerSpawned")
AddEventHandler("vRPcli:playerSpawned",function()
	local user_id = vRP.getUserId(source)
	if user_id then
		vRP.user_sources[user_id] = source
		local tmp = vRP.getUserTmpTable(user_id)
		tmp.spawns = tmp.spawns+1
		local first_spawn = (tmp.spawns == 1)

		if first_spawn then
			for k,v in pairs(vRP.user_sources) do
				vRPclient._addPlayer(source,v)
			end
			vRPclient._addPlayer(-1,source)
			Tunnel.setDestDelay(source,0)
		end
		TriggerEvent("vRP:playerSpawn",user_id,source,first_spawn)
	end
end)

function vRP.getDayHours(seconds)
    local days = math.floor(seconds/86400)
    seconds = seconds - days * 86400
    local hours = math.floor(seconds/3600)

    if days > 0 then
        return string.format("<b>%d Dias</b> e <b>%d Horas</b>",days,hours)
    else
        return string.format("<b>%d Horas</b>",hours)
    end
end

function vRP.getMinSecs(seconds)
    local days = math.floor(seconds/86400)
    seconds = seconds - days * 86400
    local hours = math.floor(seconds/3600)
    seconds = seconds - hours * 3600
    local minutes = math.floor(seconds/60)
    seconds = seconds - minutes * 60

    if minutes > 0 then
        return string.format("<b>%d Minutos</b> e <b>%d Segundos</b>",minutes,seconds)
    else
        return string.format("<b>%d Segundos</b>",seconds)
    end
end