--------------------------------------------
-- VARIABLES
--------------------------------------------
local propList = {}

--------------------------------------------
-- FUNCTIONS
--------------------------------------------
AddEventHandler("onResourceStart", function(Resource)
    if (GetCurrentResourceName() == Resource) then
        for index, netId in pairs(propList) do
            if DoesEntityExist(NetworkGetEntityFromNetworkId(netId)) then
                DeleteEntity(NetworkGetEntityFromNetworkId(netId))
            end
            propList[index] = nil
        end
    end
end)

lib.callback.register(GetCurrentResourceName()..':server:createProp', function(source, prop, coords)
    if propList[source] then
        DeleteEntity(NetworkGetEntityFromNetworkId(propList[source]))
        propList[source] = nil
    end

    local Object = CreateObject(prop, coords.x, coords.y, coords.z,true,true,false)

    while not DoesEntityExist(Object) do
		Wait(10)
	end

    if DoesEntityExist(Object) then
        propList[source] = NetworkGetNetworkIdFromEntity(Object)
		return propList[source]
	end

	return false

end)

lib.callback.register(GetCurrentResourceName()..':server:deleteProp', function(source)
    if propList[source] then
        DeleteEntity(NetworkGetEntityFromNetworkId(propList[source]))
        propList[source] = nil
    end
end)