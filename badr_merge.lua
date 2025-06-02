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
local function concatenate_lists(l1, l2)
    table.move(l2, 1, #l2, #l1 + 1, l1)
end

--- `cfg2` takes precedance
---@param cfg1 badr.component.config
---@param cfg2 badr.component.config
local function merge(cfg1, cfg2)
    ---@type badr.component.config
    local new = {}

    for k, v in pairs(cfg1) do
        new[k] = v
    end

    for k, v in pairs(cfg2) do
        new[k] = v
    end

    -- This way we don't accidentally modify `cfg2`'s onUpdates/onDraws
    new.onUpdates = {}
    concatenate_lists(new.onUpdates, cfg1.onUpdates or {})
    concatenate_lists(new.onUpdates, cfg2.onUpdates or {})
    new.onDraws = {}
    concatenate_lists(new.onDraws, cfg1.onDraws or {})
    concatenate_lists(new.onDraws, cfg2.onDraws or {})

    return new
end

return merge
