local Blips = {}

local LoadedBlips = LoadResourceFile(GetCurrentResourceName(), "blips.json")
if LoadedBlips then
    Blips = json.decode(LoadedBlips)
end

CreateThread(function()
    Wait(1000)
    for blipid, blipdata in next, Blips do
        TriggerClientEvent("blip-editor:save", -1, blipdata)
        Wait(0)
    end
end)

RegisterServerEvent("blip-editor:save")
AddEventHandler("blip-editor:save", function(blip)
    if (not Config.ALLOW_CREATING) and (not Config.ALLOW_EDIT) then return end
    if Config.ACE_PERMISSIONS then if not IsPlayerAceAllowed(source, "blipeditor.save") then return end end
    if not blip.created then blip.created = os.time() end
    blip.last_edited = os.time()
    saveBlip(blip)
end)

RegisterServerEvent("blip-editor:delete")
AddEventHandler("blip-editor:delete", function(blipid)
    if not Config.ALLOW_DELETE then return end
    if Config.ACE_PERMISSIONS then if not IsPlayerAceAllowed(source, "blipeditor.delete") then return end end
    removeExistingBlip(blipid)
end)

RegisterServerEvent("blip-editor:requestServerBlips")
AddEventHandler("blip-editor:requestServerBlips", function()
    local source = source
    for blipid, blipdata in next, Blips do
        TriggerClientEvent("blip-editor:save", source, blipdata)
    end
end)

function updateJson()
    SaveResourceFile(GetCurrentResourceName(), "blips.json", json.encode(Blips), -1)
end

function saveBlip(blip)
    if not blip.id then
        blip.id = GenerateBlipHash(blip.pos[1], blip.pos[2], os.time())
    end
    Blips[blip.id] = blip
    TriggerClientEvent("blip-editor:save", -1, blip)

    updateJson()
end

function removeExistingBlip(blipid)
    if Blips[blipid] then
        TriggerClientEvent("blip-editor:delete", -1, blipid)
        Blips[blipid] = nil

        updateJson()
    end
end
