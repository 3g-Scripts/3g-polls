---@class Vote
---@field id string
---@field title string
---@field options table
---@field endsAt number
---@field creator number
---@field ballots table<string, number>
local Vote = {}
Vote.__index = Vote

---@param id string
---@param title string
---@param options table
---@param duration number
---@param creator number
---@return Vote
function Vote:new(id, title, options, duration, creator)
    return setmetatable({
        id = id,
        title = title,
        options = options,
        endsAt = os.time() + duration,
        creator = creator,
        ballots = {}
    }, self)
end

---@return table
function Vote:toClient()
    local list = {}
    for i = 1, #self.options do
        local o = self.options[i]
        list[i] = { id = o.id, label = o.label, count = o.count or 0 }
    end
    return {
        id = self.id,
        title = self.title,
        options = list,
        endsAt = self.endsAt,
        creator = self.creator
    }
end

---@param src number
---@param optionId number
---@param ident string
---@return boolean
function Vote:submit(src, optionId, ident)
    if os.time() > self.endsAt then return false end
    local prev = self.ballots[ident]
    if prev then
        local p = self.options[prev]
        if p then p.count = math.max(0, (p.count or 0) - 1) end
    end
    local n = self.options[optionId]
    if not n then return false end
    self.ballots[ident] = optionId
    n.count = (n.count or 0) + 1
    return true
end

return Vote