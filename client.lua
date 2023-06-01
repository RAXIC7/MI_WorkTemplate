local Target = exports.ox_target

local in_work = false
local fin_work = false

local spawn_boss = false
local spawn_cont = false



local function load_npc()
    if lib.requestModel(Config.boss_ped.model, 1000) then
        local npc = CreatePed(1, 
            Config.boss_ped.model, 
            Config.boss_ped.loc.x, 
            Config.boss_ped.loc.y, 
            Config.boss_ped.loc.z-1, 
            Config.boss_ped.loc.w, 
            false, false)
        TaskStartScenarioInPlace(npc, 'PROP_HUMAN_STAND_IMPATIENT', 0, true)
        FreezeEntityPosition(npc, true)
        SetEntityInvincible(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)

        local options = {
            {
                name = 'spawn_vehicle',
                label = 'Spawn New Vehicle',
                icon = 'fa-solid fa-car',
                event = 'spawn_vehicle',
                canInteract = function(_, distance)
                    return distance < 2.0
                end
            },
            {
                name = 'open_garage',
                label = 'Open Garage',
                icon = 'fa-solid fa-car',
                event = 'open_garage',
                canInteract = function(_, distance)
                    return distance < 2.0
                end
            }
        }
        
        exports.ox_target:addLocalEntity(npc, options)
        spawn_boss = true

    end
end

RegisterNetEvent('spawn_vehicle', function() 
    TriggerServerEvent('sp_vehicle')
end)

RegisterNetEvent('open_garage', function() 
    TriggerServerEvent('op_garage')
end)

Citizen.CreateThread(function()
    while spawn_boss == false do
        load_npc()
        Citizen.Wait(1000)
    end
end)