
local function sendUI(action, data)
    SendNUIMessage({ action = action, data = data })
end

local function setFocus(on, keepInput)
    SetNuiFocus(on, on)
    SetNuiFocusKeepInput(keepInput or false)
end

local function readKvpBool(key, default)
    local ok, val = pcall(GetResourceKvpInt, key)
    if not ok or val == nil then return default end
    return val ~= 0
end

local function writeKvpBool(key, value)
    SetResourceKvpInt(key, value and 1 or 0)
end

local widgetOn   = true
local interacting = false

CreateThread(function()
    widgetOn = readKvpBool('3g_votes_widget', true)

    sendUI('config',    { widgetMax = (Config.Widget and Config.Widget.MaxOptions) or 5 })
    sendUI('setWidget', { on = widgetOn })

    local active = lib.callback.await('3g-poll:getActive', false)
    sendUI('syncVotes', { data = active or {} })
end)

RegisterNetEvent('3g-poll:push', function(payload)
    if type(payload) ~= 'table' then return end
    if not lib.callback.await('3g-poll:validatePush', false, payload) then return end

    local kind = payload.kind

    if kind == 'state' and payload.vote then
        sendUI('syncVote', { data = payload.vote })
        if widgetOn then sendUI('setWidget', { on = true }) end

    elseif kind == 'announce' and payload.text then
        sendUI('announce', { text = payload.text, ts = payload.ts })

    elseif kind == 'ended' then
        interacting = false
        setFocus(false, false)
        sendUI('setInteract', { on = false })
        sendUI('hideWidget', {})

    elseif kind == 'visibility' then
        widgetOn = payload.on and true or false
        writeKvpBool('3g_votes_widget', widgetOn)
        sendUI('setWidget', { on = widgetOn })

    elseif kind == 'openCreate' then
        setFocus(true, false)
        sendUI('openCreate', {})

    elseif kind == 'interact' then
        if not lib.callback.await('3g-poll:canInteract', false) then return end
        interacting = not interacting
        if interacting then
            setFocus(true, true)
            sendUI('setInteract', { on = true })
        else
            setFocus(false, false)
            sendUI('setInteract', { on = false })
        end

    elseif kind == 'toggle' then
        widgetOn = not widgetOn
        writeKvpBool('3g_votes_widget', widgetOn)
        sendUI('setWidget', { on = widgetOn })
    end
end)

RegisterNUICallback('submitVote', function(data, cb)
    if type(data) ~= 'table' or not data.id or not data.option then cb({}) return end
    lib.callback.await('3g-poll:submit', false, data)
    cb({})
end)

RegisterNUICallback('createVote', function(data, cb)
    if type(data) ~= 'table' or type(data.options) ~= 'table' or #data.options < 2 then cb({}) return end
    lib.callback.await('3g-poll:create', false, data)
    setFocus(false, false)
    sendUI('closeAll', {})
    cb({})
end)

RegisterNUICallback('close', function(_, cb)
    setFocus(false, false)
    sendUI('closeAll', {})
    cb({})
end)

RegisterNUICallback('hoverOn',  function(_, cb) cb({}) end)
RegisterNUICallback('hoverOff', function(_, cb) cb({}) end)