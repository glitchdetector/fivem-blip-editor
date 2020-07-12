local Blips = {}
local BlipsToTerminate = {}

local ActiveBlip = 0
local Blip = {}
local BlipIDs = {}
local BlipCache = {}

if not DisplayStartJobTooltipInMapMenu then
    if not N_0xf1a6c18b35bcade6 then
        DisplayStartJobTooltipInMapMenu = function(...) return Citizen.InvokeNative(0xF1A6C18B35BCADE6, ...) end
    else
        DisplayStartJobTooltipInMapMenu = N_0xf1a6c18b35bcade6
    end
end

local IsEditorOpen = false
function OpenEditor(blip)
    ActiveBlip = blip

    Blip = {}

    Blip.sprite = GetBlipSprite(blip)
    Blip.color = GetBlipColour(blip)
    Blip.alpha = GetBlipAlpha(blip)
    Blip.name = "Editor Blip"
    Blip.scale = 1.0
    Blip.pos = {table.unpack(GetBlipCoords(blip))}

    Blip.bHideLegend = false
    Blip.bAlwaysVisible = false
    Blip.bCheckmark = false
    Blip.bHeightIndicator = false
    Blip.bHeadingIndicator = false
    Blip.bShrink = false
    Blip.bOutline = false

    if Blips[blip] then
        for k, v in next, Blips[blip] do
            Blip[k] = v
        end
    else
        Blips[blip] = {}
    end


    for k, v in next, Blip do
        BlipCache[k] = v
    end
    local sentData = {}
    local function sendData(field, value)
        if value == nil then
            value = Blip[field]
        end
        SendNuiMessage(json.encode({
            method = field,
            data = value,
        }))
        sentData[field] = true
    end
    sendData("sprite")
    sendData("color")
    sendData("alpha")
    sendData("name")
    sendData("scale", math.floor(Blip.scale * 10))

    for field, value in next, Blip do
        if not sentData[field] then
            sendData(field, value)
        end
    end

    SetNuiFocus(true, true)
    IsEditorOpen = true
    SendNuiMessage(json.encode({
        method = "open",
    }))

    -- open pause menu to see blip being edited
    if GetCurrentFrontendMenuVersion() == -1 then
        ActivateFrontendMenu(-1171018317, false, 0)
    end
    SetPlayerBlipPositionThisFrame(Blip.pos[1], Blip.pos[2])
end

function CloseEditor()
    SetNuiFocus(false, false)
    IsEditorOpen = false
    SendNuiMessage(json.encode({
        method = "close",
    }))
end

function SetBlipName(blip, name)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)
end

function UpdateBlip(_blip, _blipdata)
    if _blip ~= 0 then
        print("updating", _blip, json.encode(_blipdata))
        SetBlipSprite(_blip, _blipdata.sprite)
        SetBlipColour(_blip, _blipdata.color)
        SetBlipAlpha(_blip, _blipdata.alpha)
        SetBlipScale(_blip, _blipdata.scale)
        SetBlipHiddenOnLegend(_blip, not not _blipdata.bHideLegend)
        SetBlipAsShortRange(_blip, not _blipdata.bAlwaysVisible)
        SetBlipChecked(_blip, not not _blipdata.bCheckmark)
        ShowHeightOnBlip(_blip, not not _blipdata.bHeightIndicator)
        SetBlipShowCone(_blip, not not _blipdata.bHeadingIndicator)
        SetBlipShrink(_blip, not not _blipdata.bShrink)
        ShowOutlineIndicatorOnBlip(_blip, not not _blipdata.bOutline)
        SetBlipName(_blip, _blipdata.name)
    end
end

RegisterNetEvent("blip-editor:save")
AddEventHandler("blip-editor:save", function(newdata)
    local blipid = newdata.id
    if not BlipIDs[blipid] then
        -- Check for existing blip (usually a newly placed one)
        local ok = false
        for blip, blipdata in next, Blips do
            if blipdata.id == nil then
                if blipdata.pos[1] == newdata.pos[1] and blipdata.pos[2] == newdata.pos[2] then
                    BlipIDs[blipid] = blip
                    Blips[blip] = newdata
                    UpdateBlip(blip, Blips[blip])
                    ok = true
                    break
                end
            end
        end
        if not ok then
            -- Create a new blip!
            local blip = AddBlipForCoord(newdata.pos[1], newdata.pos[2], newdata.pos[3])
            SetBlipAsMissionCreatorBlip(blip, true)
            BlipIDs[blipid] = blip
            Blips[blip] = newdata
            UpdateBlip(blip, Blips[blip])
        end
    else
        -- Update existing blip
        local blip = BlipIDs[blipid]
        Blips[blip] = newdata
        UpdateBlip(blip, Blips[blip])
    end
end)

RegisterNetEvent("blip-editor:delete")
AddEventHandler("blip-editor:delete", function(blipid)
    if BlipIDs[blipid] then
        local blip = BlipIDs[blipid]
        RemoveBlip(blip)
        Blips[blip] = nil
        BlipIDs[blipid] = nil
    end
end)

RegisterNUICallback("return", function(data)
    local field = data.type
    local value = data.data
    if field == "finish" then
        if value == "delete" then
            if Blips[ActiveBlip] and Blips[ActiveBlip].id then
                TriggerServerEvent("blip-editor:delete", Blips[ActiveBlip].id)
            elseif Blips[ActiveBlip] then
                -- was never saved in the first place
                RemoveBlip(ActiveBlip)
            end
            ActiveBlip = 0
        elseif value == "discard" then
            for k, v in next, BlipCache do
                Blip[k] = v
            end
        elseif value == "save" then
            for k, v in next, Blip do
                Blips[ActiveBlip][k] = v
            end
            TriggerServerEvent("blip-editor:save", Blips[ActiveBlip])
        end
        CloseEditor()
    elseif field == "sprite" then
        Blip.sprite = value
        Blip.name = GetLabelText("BLIP_" .. Blip.sprite)
        SendNuiMessage(json.encode({
            method = "name",
            data = Blip.name,
        }))
    elseif field == "color" then
        Blip.color = value
    elseif field == "alpha" then
        Blip.alpha = math.floor(tonumber(value))
    elseif field == "scale" then
        Blip.scale = tonumber(value) / 10
    elseif field == "name" then
        Blip.name = value
    else
        Blip[field] = value
    end
    UpdateBlip(ActiveBlip, Blip)
end)

--
if Config.ALLOW_EDIT then
    local current_blip = nil
    AddEventHandler("onHoverBlipStart", function(blip)
        if DoesBlipExist(blip) then
            if current_blip ~= blip then
                current_blip = blip
                if Blips[blip] then
                    ActiveBlip = blip
                    DisplayStartJobTooltipInMapMenu(true)
                else
                    ActiveBlip = 0
                    DisplayStartJobTooltipInMapMenu(false)
                end
            end
        end
    end)
    AddEventHandler("onHoverBlipEnd", function(blip)
        if current_blip == blip then
            current_blip = nil
            ActiveBlip = 0
            DisplayStartJobTooltipInMapMenu(false)
        end
    end)
end

RegisterCommand("makeblip", function()
    local pos = GetEntityCoords(PlayerPedId())
    CreateNewBlip(pos.x, pos.y, pos.z)
end)
RegisterCommand("makeblipr", function()
    local pos = vector3(math.random(-4000, 4000) * 1.0, math.random(-1000, 8000) * 1.0, 0.0)
    CreateNewBlip(pos.x, pos.y, pos.z)
end)
RegisterCommand("blips", function()
    local c = 1
    for blip, bd in next, Blips do
        print("#" .. c, blip, bd.name)
        c = c + 1
    end
end)
RegisterCommand("bedit", function(_, args)
    local blip = tonumber(args[1])
    if Blips[blip] then
        OpenEditor(blip)
    end
end)

function CreateNewBlip(x, y, z)
    CreateThread(function()
        local _blip = AddBlipForCoord(x, y, z)
        SetBlipAsMissionCreatorBlip(_blip, true)
        OpenEditor(_blip)
        local pos = GetBlipCoords(_blip)
        while IsEditorOpen do
            LockMinimapPosition(pos.x, pos.y)
            Wait(0)
        end
        UnlockMinimapPosition()
    end)
end

CreateThread(function()
    if Config.ALLOW_EDIT then AddTextEntry("IB_SRTMISS", "Edit Blip") end
    if Config.ALLOW_CREATING then AddTextEntry("IB_POI", "Create Blip") end
    Wait(750)
    CloseEditor()
    TriggerServerEvent("blip-editor:requestServerBlips")
    local current_blip = nil
    while true do
        if Config.ALLOW_CREATING then
            local blip = GetFirstBlipInfoId(162 --[[radar_poi]])
            while blip ~= 0 do
                local pos = GetBlipCoords(blip)
                if pos ~= vector3(0, 0, 0) then
                    if not BlipsToTerminate[blip] then
                        BlipsToTerminate[blip] = true
                        -- Hide POI blip and place it at NULL Island (can't delete them!!)
                        SetBlipCoords(blip, 0, 0, 0)
                        SetBlipAlpha(blip, 0)
                        local _blip = AddBlipForCoord(pos)
                        SetBlipAsMissionCreatorBlip(_blip, true)
                        OpenEditor(_blip)
                        local pos = GetBlipCoords(_blip)
                        while IsEditorOpen do
                            LockMinimapPosition(pos.x, pos.y)
                            Wait(0)
                        end
                        UnlockMinimapPosition()
                        BlipsToTerminate[blip] = false
                    end
                end
                blip = GetNextBlipInfoId(162 --[[radar_poi]])
            end
        end

        -- Hover over blip logic
        if Config.STANDALONE_MODE then
            if N_0x3bab9a4e4f2ff5c7() then
                local blip = DisableBlipNameForVar()
                if N_0x4167efe0527d706e() then
                    if DoesBlipExist(blip) then
                        if current_blip ~= blip then
                            current_blip = blip
                            TriggerEvent("onHoverBlipStart", current_blip)
                        end
                    end
                else
                    if current_blip then
                        TriggerEvent("onHoverBlipEnd", current_blip)
                        current_blip = nil
                    end
                end
            end
        end

        -- Edit Blip prompt check
        if Config.ALLOW_EDIT then
            if N_0x4167efe0527d706e() and ActiveBlip ~= 0 then
                if IsControlJustPressed(13, 203) then
                    local pos = GetBlipCoords(ActiveBlip)
                    OpenEditor(ActiveBlip)
                    while IsEditorOpen do
                        LockMinimapPosition(pos.x, pos.y)
                        Wait(0)
                    end
                    UnlockMinimapPosition()
                end
            end
        end
        Wait(0)
    end
end)
