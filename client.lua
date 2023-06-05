local Target = exports.ox_target

local in_work = false
local fin_work = false

local spawn_boss = false
local spawn_cont = false


local function workloc_blip()
    local workblip = AddBlipForCoord(
        Config.wblip.loc.x, 
        Config.wblip.loc.y,
        Config.wblip.loc.z)
    SetBlipSprite(workblip, Config.wblip.sprite)
    SetBlipColour(workblip, Config.wblip.color)
    SetBlipScale(workblip, Config.wblip.scale)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.wblip.name)
    EndTextCommandSetBlipName(workblip)
end

local function vehicle_ped()
    if lib.requestModel(Config.vehicle_ped.model, 1000) then
        local npc = CreatePed(1, 
            Config.vehicle_ped.model, 
            Config.vehicle_ped.loc.x, 
            Config.vehicle_ped.loc.y, 
            Config.vehicle_ped.loc.z-1, 
            Config.vehicle_ped.loc.w, 
            false, false)
        TaskStartScenarioInPlace(npc, 'WORLD_HUMAN_CLIPBOARD_FACILITY', 0, true)
        FreezeEntityPosition(npc, true)
        SetEntityInvincible(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)

        local options = {
            {
                name = 'spawn_vehicle',
                label = 'Spawn EMS Scout',
                icon = 'fa-solid fa-car',
                event = 'spawn_vehicle',
                onSelect = function()
                    TriggerServerEvent('sp_vehicle', 'ulsaems')
                end,
                canInteract = function(_, distance)
                    return distance < 2.0
                end
            },
            {
                name = 'spawn_vehicle',
                label = 'Spawn EMS Speedo',
                icon = 'fa-solid fa-car',
                event = 'spawn_vehicle',
                onSelect = function()
                    TriggerServerEvent('sp_vehicle', 'ulsaems3')
                end,
                canInteract = function(_, distance)
                    return distance < 2.0
                end
            },
            {
                name = 'spawn_vehicle',
                label = 'Spawn Ambulance',
                icon = 'fa-solid fa-car',
                event = 'spawn_vehicle',
                onSelect = function()
                    TriggerServerEvent('sp_vehicle', 'ulsaems2')
                end,
                canInteract = function(_, distance)
                    return distance < 2.0
                end
            },
            
        }
        
        exports.ox_target:addLocalEntity(npc, options)
        spawn_boss = true

    end
end

local function boss_ped()
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
                name = 'clock_in',
                label = 'Clock in',
                icon = 'fa-solid fa-check',
                event = 'clock_in',
                onSelect = function()
                    TriggerServerEvent('service_enter')
                    print('checked in')
                end,
                canInteract = function(_, distance)
                    return distance < 2.0
                end
            },
            {
                name = 'clock_out',
                label = 'Clock out',
                icon = 'fa-solid fa-xmark',
                event = 'clock_out',
                onSelect = function()
                    TriggerServerEvent('service_exit')
                    print('checked out')
                end,
                canInteract = function(_, distance)
                    return distance < 2.0
                end
            },

            {
                name = 'spawn_vehicle',
                label = 'Job Option 1',
                icon = 'fa-solid fa-user',
                event = 'spawn_vehicle',
                onSelect = function()
                    --TriggerServerEvent('sp_vehicle', 'ulsaems')
                end,
                canInteract = function(_, distance)
                    return distance < 2.0
                end
            },
            {
                name = 'spawn_vehicle',
                label = 'Job Option 2',
                icon = 'fa-solid fa-car',
                event = 'spawn_vehicle',
                onSelect = function()
                    --TriggerServerEvent('sp_vehicle', 'ulsaems')
                end,
                canInteract = function(_, distance)
                    return distance < 2.0
                end
            },
            
        }
        
        exports.ox_target:addLocalEntity(npc, options)
        spawn_boss = true

    end
end

local function zone_vehicle()
    local vehicle_zone = lib.zones.box({
        coords = Config.vehicle.loc,
        size = vec3(4, 4, 2),
        rotation = Config.vehicle.head,
        debug = Config.debug,
        inside = inside,
        onEnter = function()
            lib.registerContext({
                id = 'vehicle_menu',
                title = 'Vehicle Menu',
                menu = 'veh_menu',
                options = {
                    {
                        title = 'Return vehicle',
                        description = 'Return vehicle to garage',
                        icon = 'car',
                        onSelect = function()
                            lib.callback('dl_vehicle')
                        end,
                    },
                }
              })
             
              lib.showContext('vehicle_menu')
        end,
        onExit = function()
            lib.hideContext('vehicle_menu')
        end
    })
end

RegisterNetEvent('miwt:c:start_job1', function()

end)

Citizen.CreateThread(function()
    while spawn_boss == false do
        workloc_blip()
        vehicle_ped()
        boss_ped()
        zone_vehicle()
        Citizen.Wait(1000)
    end
end)