--- Puts l2 on to the end of l1
--- ```lua
--- local l1 = { 1, 2, 3 }
--- local l2 = { 4, 5, 6 }
---
--- concatenate_lists(l1, l2)
---
--- print(unpack(l1)) -- prints "1 2 3 4 5 6"
--- ```
---@param l1 any[]
---@param l2 any[]
local function append(l1, l2)
    table.move(l2, 1, #l2, #l1 + 1, l1)
end

--- The last config takes precedance
---@param ... badr.component.config
local function merge(...)
    ---@type badr.component.config
    local new = {}

    for _, cfg in ipairs { ... } do
        for k, v in pairs(cfg) do
            new[k] = v
        end
    end

    -- Set them to new tables as to not accidentally modify the configs contents
    new.onUpdates = {}
    new.onDraws = {}
    for _, cfg in ipairs { ... } do
        if cfg.onUpdate then
            new.onUpdates[#new.onUpdates + 1] = cfg.onUpdate
        end
        append(new.onUpdates, cfg.onUpdates or {})
        if cfg.onDraw then
            new.onDraws[#new.onDraws + 1] = cfg.onDraw
        end
        append(new.onDraws, cfg.onDraws or {})
    end

    return new
end

return merge
