local hasFocus, locations, fading, current = false, false, {};
local QBCore = exports['qb-core']:GetCoreObject()

function BuildSelector(data)
    locations, playerData, hasFocus = BuildLocations(data), data, true;
    BuildCamera(1);
    SetNuiFocus(true, true);
    SendNUIMessage({
        event = "show",
    })
end


RegisterNetEvent("nv:selector:show", function(data)
    if data then
        BuildSelector(data);
    else
        TriggerServerEvent("nv:selector:show")
    end
end)


PlayerJob = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

function BuildCamera(index)
    current = index and locations[index];
    if current then
        current.index, fading, ped = index, true, PlayerPedId()
        DoScreenFadeOut(0);
        RequestCollisionAtCoord(current.spawn.x, current.spawn.y, current.spawn.z);
        RequestCollisionAtCoord(current.coords.x, current.coords.y, current.coords.z);
        SetEntityVisible(ped, false)
        SetEntityCoords(ped, current.spawn.x, current.spawn.y, current.spawn.z);
        SetEntityHeading(ped, current.spawn.w);
        FreezeEntityPosition(ped, true);
        SetEntityCollision(ped, false, false);

        if current.camera then
            SetCamActive(current.camera, false)
        end

        current.camera = CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA", current.coords.x, current.coords.y, current.coords.z, current.rot.x, current.rot.y, current.rot.z, 60.00, false, 0);
        SetCamActive(current.camera, true);
        RenderScriptCams(true, false, 1, true, true);

        SendNUIMessage({
            event = "update",
            name = current.name,
            label = current.label
        })
        local timeout = 500;
        while not HasCollisionLoadedAroundEntity(ped) and timeout ~= 0 do
            timeout = timeout - 1
            Wait(10)
        end

        Wait(500)

        DoScreenFadeIn(1000);
        fading = false;
    end
end

function Spawn()
    SetGameplayCamRelativeRotation(0.0, 0.0, 0.0);
    local ped, coord = PlayerPedId(), GetGameplayCamCoord();
    SetCamActive(current.camera, false)

    if current.name == "prison" and playerData.jail then
        TriggerEvent("prison:client:Enter", playerData.jail);
        RenderScriptCams(false, false, 0, true, true);
    else
        RenderScriptCams(false, true, 1000, true, true);
        Wait(200)
    end

    SetEntityVisible(ped, true);
    FreezeEntityPosition(ped, false);
    SetEntityCollision(ped, true, true);
    SendNUIMessage({ event = "hide" });
    SetNuiFocus(false, false);
    Wait(800);
    DestroyCam(current.camera, true);
    locations, playerData, hasFocus, current = nil;
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    -- TriggerServerEvent("clothing:checkIfNew")
end

function spawnplayer()
    local PlayerData = QBCore.Functions.GetPlayerData()
    local ped = PlayerPedId()
    SetCamActive(current.camera, false)

    if current.name == "prison" and playerData.jail then
        TriggerEvent("prison:client:Enter", playerData.jail);
        RenderScriptCams(false, false, 0, true, true);
    else
        DoScreenFadeOut(250)
        Citizen.Wait(500)
        RenderScriptCams(false, true, 2000, true, true);
        SetEntityVisible(ped, true)
        SetEntityCollision(ped, true, true)
        SendNUIMessage({ event = "hide" })
        SetNuiFocus(false, false)
        DestroyCam(current.camera, true)
        Citizen.Wait(5000)
        DoScreenFadeIn(1000)
        TriggerScreenblurFadeIn(1000)
        SetEntityCoords(PlayerPedId(), PlayerData.position.x, PlayerData.position.y, PlayerData.position.z - 0.9, 0, 0, 0, false)
        SetCamParams(Cam, PlayerData.position.x, PlayerData.position.y, PlayerData.position.z + 300, -85.0, 0.00, 0.00, 100.0, 7200, 0, 0, 2)
        SetCamParams(Cam, PlayerData.position.x, PlayerData.position.y, PlayerData.position.z + 10, -40.0, 0.00, 0.00, 100.0, 5000, 0, 0, 2)
        FreezeEntityPosition(ped, false)
        TriggerEvent('QBCore:Client:OnPlayerLoaded')
        Wait(700)
        TriggerScreenblurFadeOut(1000.0)
        print('spawned')
    end
end

RegisterNUICallback("spawn", Spawn);
RegisterNUICallback("lastloc", spawnplayer);

function BuildLocations(data)
    local results = {};

    if data then
        if data.position and not data.jail then
            local coords, rot = BuildCameraProperties(vector3(data.position.x, data.position.y, data.position.z));
            results[1] = { name = "last", label = "Last Location", coords = coords, rot = rot, spawn = vector4(data.position.x, data.position.y, data.position.z, 100) };
        end


        for i=1, #Settings.Locations do
            local location = Settings.Locations[i];
            if (location.name == "prison" and data.jail) or (not location.job or location.job == PlayerJob.name) and not data.jail then
                results[#results+1] = location;
            end
        end
    end

    return results;
end

function BuildCameraProperties(vector)
    return vector-vector3(-26.334, -4.58, -17.80), vector3(-32.76, 4.26, 100.72)
end

RegisterNUICallback("forward", function(data)
    if not fading then
        BuildCamera(locations[current.index+1] ~= nil and current.index+1 or 1);
    end
end)

RegisterNUICallback("backward", function(data)
    if not fading then
        BuildCamera(current.index-1 > 0 and current.index-1 or #locations);
    end
end)

RegisterNetEvent("qb-spawnselector:set")
AddEventHandler("qb-spawnselector:set" , function()
    BuildSelector('');
end)

-- command
RegisterCommand('ad', function()  BuildSelector('');end)
