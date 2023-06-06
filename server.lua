local pefcl = exports.pefcl
local s_in_service = false
local paycheckInterval = 15
local paychecks = {
    ['job1'] = { 100, 200, 300 },
}

local jobstash = {
    id = Config.jobstash_id,
    label = Config.jobstash_label,
    slots = Config.jobstash_slots,
    weight = Config.jobstash_weight,
    owner = 'char1:license'
}

AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == 'ox_inventory' or resourceName == GetCurrentResourceName() then
        exports.ox_inventory:RegisterStash(
            jobstash.id, 
            jobstash.label, 
            jobstash.slots, 
            jobstash.weight, 
            jobstash.owner, 
            jobstash.jobs)
    end
end)

-- Credit and thanks to FlakeSkillz for creating this method of paycheck intervals
---@diagnostic disable: missing-parameter, param-type-mismatch
CreateThread(function()
    while s_in_service == true do
        Wait(paycheckInterval * 60000)
        for _, player in pairs(Ox.GetPlayers()) do
            local group = Config.jobname
            local grade = player.getGroup(group)
            local paycheck = paychecks?[group]?[grade]

            if paycheck > 0 and pefcl:getTotalBankBalanceByIdentifier(player.source, group) then
                pefcl:removeBankBalanceByIdentifier(player.source, { 
                    identifier = group, 
                    amount = paycheck, 
                    message = 'Work: Direct Deposit'  })
                pefcl:addBankBalance(player.source, { 
                    amount = paycheck, 
                    message = 'Work: Direct Deposit' })
            end
        end
    end
end)

-- simple player service checker (server side)
lib.callback.register('checkin', function(source)
    if s_in_service == false then
        s_in_service = true
    else
        s_in_service = false
    end
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
RegisterServerEvent('dl_vehicle', function(source)
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

-- job payout
lib.callback.register('payout', function(source)
    exports.pefcl:addBankBalance(source, { 
        amount = Config.job1.payment, 
        message = 'Job: Task c/w'})
end)
