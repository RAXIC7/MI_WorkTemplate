local ox_inventory = exports.ox_inventory
local res_start = false

local job_blip = nil
local cur_task = nil
local in_work = false
local c_in_service = false

local taskped = {
    spawned = false,
    ped = nil
}

local taskobj = {
    spawned = false,
    obj = nil
}

---------- Work Location ----------
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
                groups = Config.jobname,
                event = 'spawn_vehicle',
                onSelect = function()
                    TriggerServerEvent('sp_vehicle', 'ulsaems')
                end,
                canInteract = function(_, distance)
                    return distance < 2.0 and c_in_service == true
                end
            },
            {
                name = 'spawn_vehicle',
                label = 'Spawn EMS Speedo',
                icon = 'fa-solid fa-truck',
                groups = Config.jobname,
                event = 'spawn_vehicle',
                onSelect = function()
                    TriggerServerEvent('sp_vehicle', 'ulsaems3')
                end,
                canInteract = function(_, distance)
                    return distance < 2.0 and c_in_service == true
                end
            },
            {
                name = 'spawn_vehicle',
                label = 'Spawn Ambulance',
                icon = 'fa-solid fa-ambulance',
                groups = Config.jobname,
                event = 'spawn_vehicle',
                onSelect = function()
                    TriggerServerEvent('sp_vehicle', 'ulsaems2')
                end,
                canInteract = function(_, distance)
                    return distance < 2.0 and c_in_service == true
                end
            },
            
        }
    
        exports.ox_target:addLocalEntity(npc, options)
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
                groups = Config.jobname,
                event = 'clock_in',
                onSelect = function()
                    c_in_service = true
                    lib.callback('checkin')
                    lib.notify({
                        title = 'In Service',
                        description = 'You have checked in to work',
                        type = 'inform'
                    })
                end,
                canInteract = function(_, distance)
                    return distance < 2.0 and c_in_service == false
                end
            },
            {
                name = 'clock_out',
                label = 'Clock out',
                icon = 'fa-solid fa-xmark',
                groups = Config.jobname,
                event = 'clock_out',
                onSelect = function()
                    c_in_service = false
                    lib.notify({
                        title = 'Out of Service',
                        description = 'You have checked out of work',
                        type = 'inform'
                    })
                end,
                canInteract = function(_, distance)
                    return distance < 2.0 and c_in_service == true
                end
            },

            {
                name = 'start_job1',
                label = 'Job Option 1',
                icon = 'fa-solid fa-user',
                groups = Config.jobname,
                event = 'start_job1',
                onSelect = function()
                    TriggerEvent('miwt:c:start_job1')
                end,
                canInteract = function(_, distance)
                    return distance < 2.0 and c_in_service == true
                end
            },
            {
                name = 'start_job1',
                label = 'Job Option 2',
                icon = 'fa-solid fa-user',
                groups = Config.jobname,
                event = 'start_job1',
                onSelect = function()
                    TriggerEvent('miwt:c:start_job2')
                end,
                canInteract = function(_, distance)
                    return distance < 2.0 and c_in_service == true
                end
            },
            
        }
        
        exports.ox_target:addLocalEntity(npc, options)
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
                            RegisterServerEvent('dl_vehicle')
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

local function zone_stash()
    exports.ox_target:addBoxZone({
        coords = Config.jobstash.loc,
        size = vec3(1.5, 0.9, 1),
        rotation = Config.jobstash.head,
        debug = Config.debug,
        options = {
            {
                name = 'job_stash',
                event = 'ox_target:debug',
                icon = 'fa-solid fa-archive',
                label = 'Work Lockers',
                onSelect = function()
                    ox_inventory:openInventory('stash', {id = 'job1', owner = false})
                end

            }
        }
    })
end

---------- Job Functions ----------
local function sp_jblip()
    if job_blip ~= nil then
        RemoveBlip(job_blip)
        job_blip = nil
    end
    local job_blip = AddBlipForCoord(
        cur_task.loc.x, 
        cur_task.loc.y,
        cur_task.loc.z)
        SetBlipSprite(job_blip, 1)
        SetBlipColour(job_blip, 68)
        SetBlipRoute(job_blip, true)
        SetBlipRouteColour(job_blip, 68)
        SetBlipScale(job_blip, 0.8)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('Task 1')
        EndTextCommandSetBlipName(job_blip)
end

local function sp_taskped()
    if taskped.spawned then return end
    local model = lib.requestmodel(joaat(cur_task.model))
    while not HasModelLoaded(joaat(cur_task.model)) do
        Wait(100)
    end
    local ped = CreatePed(4, 
        cur_task.model, 
        cur_task.loc.x, 
        cur_task.loc.y, 
        cur_task.loc.z-1, 
        cur_task.loc.h, 
        false, true)
    taskped.ped = ped
    TaskStartScenarioInPlace(ped, 'PROP_HUMAN_STAND_IMPATIENT', 0, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    local ped_options = {
        {
            name = 'miwt:c:dojob1',
            label = 'Do the job',
            icon = 'fa-solid fa-box',
            event = 'miwt:c:finish_job1',
            canInteract = function(_, distance)
                return distance < 2.0 and in_work
            end
        }
    }

    exports.ox_target:addLocalEntity(taskped.ped, ped_options)

    taskped.spawned = true
end

local function dl_taskped()
    if not taskped.spawned then return end
    exports.ox_target:removeLocalEntity(taskped.ped, { 'miwt:c:dojob1' })
    DeleteEntity(taskped.ped)
    taskped.spawned = false
    taskped.ped = nil
end

local function sp_taskobj()
    if taskobj.spawned then return end
    local model = lib.requestModel(joaat(cur_task.object))
    while not HasModelLoaded(cur_task.object) do
        Wait(100)
    end

    local object = CreateObject(
        cur_task.object, 
        cur_task.loc.x, 
        cur_task.loc.y, 
        cur_task.loc.z, 
        true, true, true)
    taskobj.obj = object

    SetModelAsNoLongerNeeded(model)
    PlaceObjectOnGroundProperly(object)
    FreezeEntityPosition(object, true)
    SetEntityCollision(object, true, true)

    local obj_options = {
        {
            name = 'miwt:c:dojob2',
            label = 'Do the job',
            icon = 'fa-solid fa-box',
            event = 'miwt:c:finish_job2',
            canInteract = function(_, distance)
                return distance < 2.0 and in_work
            end
        }
    }

    exports.ox_target:addLocalEntity(taskobj.obj, obj_options)
    taskobj.spawned = true
end

local function dl_taskobj()
    if not taskobj.spawned then return end
    exports.ox_target:removeLocalEntity(taskobj.obj, { 'miwt:c:dojob2' })
    DeleteEntity(taskobj.obj)
    taskobj.spawned = false
    taskobj.obj = nil
end

---------- Job Events ----------
RegisterNetEvent('miwt:c:start_job1', function()
    if in_work and in_service == true then return end
    local task1 = Config.job1[math.random(1, #Config.job1)]
    cur_task = task1
    in_work = true
    lib.notify({
        title = 'Task active',
        description = 'Do the job',
        type = 'inform'
    })
    sp_jblip()
    sp_taskped()
end)

RegisterNetEvent('miwt:c:finish_job1', function()
    exports.scully_emotemenu:PlayByCommand('notepad')
    if lib.progressBar({
        duration = 3000,
        label = 'Joing Job 1',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
        },
    }) then print('Do stuff when complete') else print('Do stuff when cancelled') end
    exports.scully_emotemenu:CancelAnimation()
    RemoveBlip(job_blip)
    lib.notify({
        title = 'Task Completed',
        description = 'Good job',
        type = 'success'
    })
    lib.callback('payout')
    dl_taskped()
    in_work = false
    cur_task = nil
    
end)

RegisterNetEvent('miwt:c:start_job2', function()
    if in_work and c_in_service == true then return end
    local task2 = Config.job2[math.random(1, #Config.job2)]
    cur_task = task2
    in_work = true
    lib.notify({
        title = 'Task active',
        description = 'Do the job',
        type = 'inform'
    })
    sp_jblip()
    sp_taskobj()
end)

RegisterNetEvent('miwt:c:finish_job2', function()
    exports.scully_emotemenu:PlayByCommand('mechanic4')
    local success = lib.skillCheck({'easy', 'easy', 'easy'}, {'w', 'a', 's', 'd'})
    if success == true then
        lib.notify({
            title = 'Task Completed',
            description = 'Good job',
            type = 'success'
        })
        RemoveBlip(job_blip)
        exports.scully_emotemenu:CancelAnimation()
        lib.callback('payout')
        dl_taskobj()
        in_work = false
        cur_task = nil
    else
        RemoveBlip(job_blip)
        lib.notify({
            title = 'Task Failed',
            description = 'Not good job',
            type = 'error'
        })
        exports.scully_emotemenu:CancelAnimation()
        dl_taskobj()
        in_work = false
        cur_task = nil
    end
end)

---------- Main Thread ----------
Citizen.CreateThread(function()
    while res_start == false do
        
        workloc_blip()
        vehicle_ped()
        boss_ped()
        zone_vehicle()
        zone_stash()

        res_start = true
        Citizen.Wait(1000)
    end
end)