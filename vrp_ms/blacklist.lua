-----------------------------------------------------------------------------------------------------------------------------------------
-- BLACKLIST VEHICLES
-----------------------------------------------------------------------------------------------------------------------------------------
blackVehicles = {
	"insurgent",
	"Rhino",
	"Buzzard"
	"Valkyrie",
	"Savage",
	"Khanjali"
	"Scarab",
	"LAZER"
}

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		checkCar(GetVehiclePedIsIn(PlayerPedId()))
		x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
		for k,v in pairs(blackVehicles) do
			checkCar(GetClosestVehicle(x,y,z,300.0,GetHashKey(v),70))
		end
	end
end)

function checkCar(vehicle)
	if vehicle then
		local model = GetEntityModel(vehicle)
		if isCarBlacklisted(model) then
			Citizen.InvokeNative(0xAE3CBE5BF394C9C9,Citizen.PointerValueIntInitialized(vehicle))
		end
	end
end

function isCarBlacklisted(model)
	for k,v in pairs(blackVehicles) do
		if model == GetHashKey(v) then
			return true
		end
	end
	return false
end
