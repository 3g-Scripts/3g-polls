local Vote = require 'server.classes.vote'

---@class VoteManager
---@field active table<string, Vote>
local VM = { active = {} }

---@param v number
---@param lo number
---@param hi number
---@return number
local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

---@return boolean
function VM:hasActive()
    for _ in pairs(self.active) do return true end
    return false
end

---@return table
function VM:list()
    local out, i = {}, 0
    for _, v in pairs(self.active) do
        i = i + 1
        out[i] = v:toClient()
    end
    return out
end

---@param title string
---@param opts string[]
---@param duration integer
---@param src number
---@return boolean, Vote|nil
function VM:create(title, opts, duration, src)
    if self:hasActive() then return false end
    if type(opts) ~= 'table' or #opts < 2 then return false end

    duration = clamp(duration or 0, Config.Durations.Min, Config.Durations.Max)

    local id = ('vote_%d_%d'):format(os.time(), math.random(1000, 9999))
    local options, k = {}, 0
    local lim = math.min(#opts, Config.MaxOptions)
    for i = 1, lim do
        local label = tostring(opts[i] or ''):sub(1, 60)
        if label ~= '' then
            k = k + 1
            options[k] = { id = k, label = label, count = 0 }
        end
    end
    if k < 2 then return false end

    local v = Vote:new(id, tostring(title or ''):sub(1, 80), options, duration, src)
    self.active[id] = v

    SetTimeout(duration * 1000, function()
        local vv = self.active[id]
        if not vv then return end
        self.active[id] = nil

        local winner
        for _, o in ipairs(vv.options) do
            if not winner or (o.count or 0) > (winner.count or 0) then
                winner = o
            end
        end

        local msg = winner
            and (('Vote ended — Winner: %s (%d)'):format(winner.label or 'Unknown', winner.count or 0))
            or 'Vote ended — no votes'

        TriggerClientEvent('3g-poll:push', -1, { kind = 'announce', text = msg })
        TriggerClientEvent('3g-poll:push', -1, { kind = 'ended', vote = vv:toClient(), winner = winner })
        TriggerClientEvent('3g-poll:push', -1, { kind = 'visibility', on = false })
    end)

    TriggerClientEvent('3g-poll:push', -1, { kind = 'state', vote = v:toClient() })
    TriggerClientEvent('3g-poll:push', -1, { kind = 'announce', text = ('New vote: "%s" — type /vote to participate'):format(v.title) })
    return true, v
end

---@param id string
---@param src number
---@param opt integer
---@param ident string
---@return boolean
function VM:submit(id, src, opt, ident)
    local v = self.active[id]
    if not v then return false end
    local ok = v:submit(src, opt, ident)
    if ok then
        TriggerClientEvent('3g-poll:push', -1, { kind = 'state', vote = v:toClient() })
    end
    return ok
end

return VM
