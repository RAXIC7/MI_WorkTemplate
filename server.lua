RegisterServerEvent('sp_vehicle', function(car)

    local player = Ox.GetPlayer(source)
    print(json.encode(player, { indent = true }))

    local vehicle = Ox.CreateVehicle({
        model = 'ulsaems2',
        owner = player.charid,
    }, Config.vehicle.loc, Config.vehicle.head)
    print(json.encode(vehicle, { indent = true }))

end)

RegisterServerEvent('op_garage', function(car)

    local player = Ox.GetPlayer(source)
    print(json.encode(player, { indent = true }))

    local vehicleId = MySQL.scalar.await('SELECT id FROM vehicles WHERE owner = ? LIMIT 1', { player.charid })

    if vehicleId then
        local vehicle = Ox.CreateVehicle(vehicleId, Config.vehicle.loc, Config.vehicle.head)

        if vehicle then
            print(json.encode(vehicle, { indent = true }))
        end
    end

end)