lib.locale(Config.lang)

--------------------------------------------
-- VARIABLES
--------------------------------------------
local isExercising = false

--------------------------------------------
-- LOCAL FUNCTIONS
--------------------------------------------

local function StartAnim(dict, clip, time)
    local inprogress = true
    local finishTime = GetGameTimer() + time
    TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, time, 0, 0)
    while inprogress do
        DisableControlAction(0, 21, true)
        DisableControlAction(0, 30, true)
        DisableControlAction(0, 31, true)
        DisableControlAction(0, 36, true)

        if not IsEntityPlayingAnim(cache.ped,dict,clip,3) then
            TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, time, 0, 0)
        end

        if GetGameTimer()>=finishTime or isExercising then
            inprogress = false
        end
        Wait(0)
    end
end

local function startExercise(exercise, coord)
    CreateThread(function ()
        isExercising = true

        if Config.Exercises[exercise].startDict then
            lib.requestAnimDict(Config.Exercises[exercise].startDict)
        end
        lib.requestAnimDict(Config.Exercises[exercise].actionDict)
        if Config.Exercises[exercise].exitDict then
            lib.requestAnimDict(Config.Exercises[exercise].exitDict)
        end

        SetEntityCoords(cache.ped, coord.xyz)
        SetEntityHeading(cache.ped,coord.w)

        if Config.Exercises[exercise].prop then
            local prop = Config.Exercises[exercise].prop
            lib.requestModel(prop.model)
            local objNetId = lib.callback.await(GetCurrentResourceName()..':server:createProp', false, prop.model, coord)

            if objNetId then
                local object = NetworkGetEntityFromNetworkId(objNetId)
                while not DoesEntityExist(object)  do
                    object = NetworkGetEntityFromNetworkId(objNetId)
                    Wait(1)
                end
                SetEntityCollision(object,false,false)
                AttachEntityToEntity(object, cache.ped, GetPedBoneIndex(cache.ped, prop.bone or 60309), prop.pos.x, prop.pos.y, prop.pos.z, prop.rot.x, prop.rot.y, prop.rot.z, true, true, false, true, prop.rotOrder or 0, true)
            end
            SetModelAsNoLongerNeeded(prop.model)
        end

        notify(locale("notificaton.startExercise", locale(exercise)))
        if Config.Exercises[exercise].startDict then
            StartAnim(Config.Exercises[exercise].startDict, Config.Exercises[exercise].startClip, Config.Exercises[exercise].starttime)
        end
        startExerciseSuccess(exercise, coord)
        
        CreateThread(function ()
            while isExercising do
            
                if not IsEntityPlayingAnim(cache.ped, Config.Exercises[exercise].actionDict, Config.Exercises[exercise].actionClip,3) then
                    TaskPlayAnim(cache.ped, Config.Exercises[exercise].actionDict, Config.Exercises[exercise].actionClip, 3.0, 1.0, -1, 1, 0)
                end    
                DisableControlAction(0, 21, true)
                DisableControlAction(0, 30, true)
                DisableControlAction(0, 31, true)
                DisableControlAction(0, 36, true)
                Wait(Config.Exercises[exercise].actionTime)
                stepExerciseSuccess(exercise, coord)
            end
            if Config.Exercises[exercise].exitDict then
                StartAnim(Config.Exercises[exercise].exitDict, Config.Exercises[exercise].exitClip, Config.Exercises[exercise].exitTime)
            end
            lib.callback.await(GetCurrentResourceName()..':server:deleteProp', false)
            ClearPedTasks(cache.ped)
            notify(locale("notificaton.finishExercise", locale(exercise)))
            finishExerciseSuccess(exercise, coord)
        end)

    end)
end

--------------------------------------------
-- FUNCTIONS
--------------------------------------------

CreateThread(function ()
    if Config.blips and #Config.blips > 0 then
        for _, v in pairs(Config.blips) do
            local blip = AddBlipForCoord(v.coords)
            SetBlipSprite(blip, v.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipAsShortRange(blip, true)
            SetBlipColour(blip, v.color)
            SetBlipScale(blip, v.scale)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.label)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

CreateThread(function ()
    if Config.locations and #Config.locations > 0 then
        for index, loc in pairs(Config.locations) do

            local point = lib.points.new({
                coords = loc.coords,
                distance = loc.distance,
                index = index,
            })

            function point:onEnter()
                lib.showTextUI('['..Config.locationsAction..'] - '..locale(loc.exercise), {
                    position = "right-center",
                    icon = 'fa-duotone fa-solid fa-dumbbell',
                    style = {
                        borderRadius = '10px',
                        backgroundColor = '#e88a1c',
                        color = 'white'
                    }
                })                
            end

            function point:onExit()
                lib.hideTextUI()
            end
        end     
    end
end)

CreateThread(function ()
    if Config.entities and #Config.entities > 0 then
        for index, ent in ipairs(Config.entities) do
            exports.ox_target:addModel(ent.entity,{
                name = ent.exercise..'_'..index,
                label = locale(ent.exercise),
                icon = 'fa-duotone fa-solid fa-dumbbell',
                distance = ent.distance,
                canInteract = function(entity, distance, coords, name, bone)
                    return not IsEntityDead(cache.ped) and not IsPedInAnyVehicle(cache.ped)
                end,
                onSelect = function(data)
                    local entCoords = GetOffsetFromEntityInWorldCoords(data.entity, ent.offset.xyz )
                    entCoords = vector4(entCoords.x, entCoords.y, entCoords.z, GetEntityHeading(data.entity)+ent.offset.w)
                    local spot = lib.getClosestPlayer(entCoords.xyz, 1.0, false)
                    if not spot then
                        startExercise(ent.exercise, entCoords)
                        lib.showTextUI(locale('toFinish', Config.stopExerciseKey), {
                            position = "right-center",
                            style = {
                                borderRadius = '10px',
                                backgroundColor = '#e88a1c',
                                color = 'white'
                            }
                        })
                    else
                        notify(locale("notificaton.spotOcupied"))
                    end
                end
            })
        end
        
    end
end)

if Config.locations and #Config.locations > 0 then
    lib.addKeybind({
        name = GetCurrentResourceName()..'_key',
        description = 'Pess to interact with gym',
        defaultKey = Config.locationsAction,
        onPressed = function(self)
            if isExercising then return end

            local coords = GetEntityCoords(cache.ped)
            for _, loc in pairs(Config.locations) do
                if #(coords - loc.coords.xyz) <= 1 then
                    if not lib.getClosestPlayer(loc.coords.xyz, 1.0, false) then
                        startExercise(loc.exercise, loc.coords)
                        lib.hideTextUI()
                        lib.showTextUI(locale('toFinish', Config.stopExerciseKey), {
                            position = "right-center",
                            style = {
                                borderRadius = '10px',
                                backgroundColor = '#e88a1c',
                                color = 'white'
                            }
                        })
                    else
                        notify(locale("notificaton.spotOcupied"))
                    end
                    
                    break
                end
            end
            --print(('pressed %s (%s)'):format(self.currentKey, self.name))
        end,
        onReleased = function(self)
            --print(('released %s (%s)'):format(self.currentKey, self.name))
        end
    })
end

lib.addKeybind({
    name = GetCurrentResourceName()..'_stop_key',
    description = 'Stop exercising',
    defaultKey = Config.stopExerciseKey,
    onPressed = function(self)
        if isExercising then
            isExercising = false
            lib.hideTextUI()
        end
    end,
    onReleased = function(self)
        --print(('released %s (%s)'):format(self.currentKey, self.name))
    end
})

