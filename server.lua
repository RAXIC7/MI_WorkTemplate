local ox_inventory = exports.ox_inventory
-- ox_inventory:AddItem(source, 'money', math.random(10000, 300000))
local players = {}
local table = lib.table

CreateThread(function()
    for _, player in pairs(Ox.GetPlayers(true, { groups = Config.jobname })) do
        local inService = player.get('inService')
        if inService and table.contains(Config.jobname, inService) then
            players[player.source] = player
        end
    end
end)

-- register service
RegisterNetEvent('service_enter', function(group)
    local player = Ox.GetPlayer(source)
    if player then
        if group and table.contains(Config.jobname, group) and player.hasGroup(Config.jobname) then
            players[source] = player
            return player.set('inService', group, true)
        end
        player.set('inService', false, true)
    end
    players[source] = nil
    print(source)
end)

RegisterNetEvent('service_exit', function(group)
    local player = Ox.GetPlayer(source)
    if player then
        if group and table.contains(Config.jobname, group) and player.hasGroup(Config.jobname) then
            players[source] = player
            return player.set('inService', group, false)
        end
        player.set('inService', false, true)
    end
    players[source] = nil
    print(source)
end)

lib.callback.register('ox:isPlayerInService', function(source, target)
    return players[target or source]
end)

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
lib.callback.register('dl_vehicle', function(source)
    local player = GetPlayerPed(source)
    local entity = GetVehiclePedIsIn(player)
    if entity == 0 then return end
    local vehicle = Ox.GetVehicle(entity)
    if vehicle then
        vehicle.delete()
    else
        DeleteEntity(entity)
    end
    return true
end)