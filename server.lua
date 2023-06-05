

-- spawn vehicle
RegisterServerEvent('sp_vehicle', function(vehicle)
    local player = Ox.GetPlayer(source)
    print(json.encode(player, { indent = true }))

    local vehicle = Ox.CreateVehicle({
        model = vehicle,
        group = Config.jobname,
        owner = player.charid,
    }, Config.vehicle.loc, Config.vehicle.head)
    print(json.encode(vehicle, { indent = true }))
end)

-- despawn & de-own vehicle
RegisterServerEvent('dl_vehicle', function()
    local player = Ox.GetPlayer(source)
    local vehicle = Ox.GetVehicle({
        owner = player.charid,
        group = Config.jobname,
    })
    print(json.encode(vehicle, { indent = true }))
    if vehicle then
        vehicle.delete(vehicle)
    end
end)
