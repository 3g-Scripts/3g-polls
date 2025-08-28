---@param action string
---@param data table|nil
local function SendReactMessage(action, data)
    SendNUIMessage({ action = action, data = data })
end

local widgetOn, widgetActive = true, false

local function kvpExists(key)
    local h = StartFindKvp(key)
    if not h or h == -1 then return false end
    local found = false
    local k = FindKvp(h)
    while k do
        if k == key then found = true break end
        k = FindKvp(h)
    end
    EndFindKvp(h)
    return found
end

CreateThread(function()
    local key = '3g_votes_widget'
    if kvpExists(key) then
        widgetOn = (GetResourceKvpInt(key) ~= 0)
    else
        widgetOn = true
    end

    SendReactMessage('config', { widgetMax = (Config.Widget and Config.Widget.MaxOptions) or 5 })
    SendReactMessage('setWidget', { on = widgetOn })

    local vs = lib.callback.await('3g-poll:getActive', false)
    SendReactMessage('syncVotes', { data = vs or {} })
end)

RegisterNetEvent('3g-poll:push', function(payload)
    if type(payload) ~= 'table' then return end
    local ok = lib.callback.await('3g-poll:validatePush', false, payload)
    if not ok then return end

    local k = payload.kind

    if k == 'state' and payload.vote then
        SendReactMessage('syncVote', { data = payload.vote })
        if widgetOn then SendReactMessage('setWidget', { on = true }) end

    elseif k == 'announce' and payload.text then
        SendReactMessage('announce', { text = payload.text })

    elseif k == 'ended' then
        widgetActive = false
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        SendReactMessage('setInteract', { on = false })
        SendReactMessage('hideWidget', {})

    elseif k == 'visibility' then
        widgetOn = payload.on and true or false
        SetResourceKvpInt('3g_votes_widget', widgetOn and 1 or 0)
        SendReactMessage('setWidget', { on = widgetOn })

    elseif k == 'openCreate' then
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(false)
        SendReactMessage('openCreate', {})

    elseif k == 'interact' then
        local can = lib.callback.await('3g-poll:canInteract', false)
        if not can then return end
        widgetActive = not widgetActive
        if widgetActive then
            SetNuiFocus(true, true)
            SetNuiFocusKeepInput(true)
            SendReactMessage('setInteract', { on = true })
        else
            SetNuiFocus(false, false)
            SetNuiFocusKeepInput(false)
            SendReactMessage('setInteract', { on = false })
        end

    elseif k == 'toggle' then
        widgetOn = not widgetOn
        SetResourceKvpInt('3g_votes_widget', widgetOn and 1 or 0)
        SendReactMessage('setWidget', { on = widgetOn })
    end
end)

---@param data { id: string, option: number }
---@param cb fun(resp: table)
RegisterNUICallback('submitVote', function(data, cb)
    if type(data) ~= 'table' or not data.id or not data.option then cb({}) return end
    lib.callback.await('3g-poll:submit', false, data)
    cb({})
end)

---@param data { title: string, duration: number, options: string[] }
---@param cb fun(resp: table)
RegisterNUICallback('createVote', function(data, cb)
    if type(data) ~= 'table' or type(data.options) ~= 'table' or #data.options < 2 then cb({}) return end
    lib.callback.await('3g-poll:create', false, data)
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendReactMessage('closeAll', {})
    cb({})
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendReactMessage('closeAll', {})
    cb({})
end)

RegisterNUICallback('hoverOn',  function(_, cb) cb({}) end)
RegisterNUICallback('hoverOff', function(_, cb) cb({}) end)
