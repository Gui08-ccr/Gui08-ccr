RegisterCommand("cor",function(source,args)
    local tinta = tonumber(args[1])
    local ped = PlayerPedId()
    local arma = GetSelectedPedWeapon(ped)
        if tinta >= 0 then
            SetPedWeaponTintIndex(ped,arma,tinta)
        end
end,false)