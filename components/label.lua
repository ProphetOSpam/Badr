local component = require 'badr'
local merge = require 'badr_merge'

---@class badr.label.config : badr.component.config
---@field font love.Font?
---@field color [integer, integer, integer]?
---@field text string?
---@field opacity number?
---@field onUpdates fun(self: badr.label)[]?
---@field onDraws fun(self: badr.label)[]?

---@class badr.label : badr.component
---@field font love.Font
---@field color [integer, integer, integer, integer]
---@field text string
---@field opacity number
---@field onUpdates fun(self: badr.label)[]
---@field onDraws fun(self: badr.label)[]

---@param config badr.label.config | string
---@return badr.label
local function label(config)
    local text
    if type(config) == "string" then
        text = config
    else
        text = config.text or ""
    end

    local font = love.graphics.getFont()

    local width = font:getWidth(text)
    local height = font:getHeight()

    ---@type badr.label.config
    local default = {
        text = text,
        width = width,
        height = height,
        font = font,
        color = { 0, 0, 0, 1 },
        onDraws = {
            function(self)
                if not self.visible then return end
                love.graphics.setFont(self.font)
                love.graphics.setColor(self.color)
                love.graphics.print(self.text, self.x, self.y)
                love.graphics.setColor({ 1, 1, 1 })
            end,
        }
    }

    if type(config) == "string" then
        ---@type badr.label
        return component(default)
    else
        ---@type badr.label
        return component(merge(default, config))
    end
end

return label
