local component = require 'badr'
local make_config = require 'make_config'

---@class badr.button.config : badr.component.config
---@field text string?
---@field icon love.Image?
---@field font love.Font?
--- Styles
---@field backgroundColor [integer, integer, integer, integer]?
---@field hoverColor [integer, integer, integer, integer]?
---@field textColor [integer, integer, integer, integer]?
---@field cornerRadius number?
---@field leftPadding number?
---@field rightPadding number?
---@field topPadding number?
---@field bottomPadding number?
---@field borderColor [integer, integer, integer, integer]?
---@field borderWidth number?
---@field border boolean?
---@field angle number?
---@field scale number?
--- Logic
---@field onUpdate fun(self: badr.button)?
---@field onUpdates fun(self: badr.button)[]?
---@field onDraw fun(self: badr.button)?
---@field onDraws fun(self: badr.button)[]?
---@field onClick fun(self: badr.button)?
---@field onHover fun(self: badr.button)?
---@field onMouseExit fun(self: badr.button)?
---@field disabled boolean?

---@class badr.button : badr.component
---@field text string
---@field icon love.Image?
---@field font love.Font
--- Styles
---@field backgroundColor [integer, integer, integer, integer]
---@field hoverColor [integer, integer, integer, integer]
---@field textColor [integer, integer, integer, integer]
---@field cornerRadius number
---@field leftPadding number
---@field rightPadding number
---@field topPadding number
---@field bottomPadding number
---@field borderColor [integer, integer, integer, integer]
---@field borderWidth number
---@field border boolean
---@field angle number
---@field scale number
--- Logic
---@field onUpdates fun(self: badr.button)[]
---@field onDraws fun(self: badr.button)[]
---@field onClick fun(self: badr.button)?
---@field onHover fun(self: badr.button)?
---@field onMouseExit fun(self: badr.button)?
---@field disabled boolean
---@field hoverCalled boolean
---@field hovered boolean
---@field mousePressed boolean

--- https://github.com/s-walrus/hex2color/blob/master/hex2color.lua
---@param hex string 
---@param value integer?
local function Hex(hex, value)
    return {
        tonumber(string.sub(hex, 2, 3), 16) / 256,
        tonumber(string.sub(hex, 4, 5), 16) / 256,
        tonumber(string.sub(hex, 6, 7), 16) / 256,
        value or 1 }
end

---@param config badr.button.config
---@return badr.button
return function(config)
    -- Decided here because other values depend on them; if they are specified in `config` the other defaults should take that into account
    local text = config.text or ""

    local font = config.font or love.graphics.getFont()

    local padding = {
        left = config.leftPadding or 12,
        right = config.rightPadding or 12,
        top = config.topPadding or 8,
        bottom = config.bottomPadding or 8
    }

    local width = font:getWidth(text) + padding.left + padding.right
    local height = font:getHeight() + padding.top + padding.bottom

    ---@type badr.button.config
    local default = {
        text = text,
        width = width,
        height = height,
        font = font,
        -- styles
        backgroundColor = Hex '#DBE2EF',
        hoverColor = Hex '#3F72AF',
        textColor = Hex '#112D4E',
        cornerRadius = 4,
        leftPadding = padding.left,
        rightPadding = padding.right,
        topPadding = padding.top,
        bottomPadding = padding.bottom,
        borderColor = Hex "#FFFFFF",
        borderWidth = 0,
        border = false,
        angle = 0,
        scale = 1,
        -- logic
        disabled = false,
        hoverCalled = false,
        mousePressed = false,
        onUpdate = function(self)
            if love.mouse.isDown(1) then
                if self.mousePressed == false and self:isMouseInside() and self.parent.visible then
                    self.mousePressed = true
                    if config.onClick then self:onClick() end
                end
            else
                self.mousePressed = false
            end
        end,
        --
        onDraw = function(self)
            if not self.visible then return love.mouse.setCursor() end
            love.graphics.push()
            love.graphics.rotate(self.angle)
            love.graphics.scale(self.scale, self.scale)
            love.graphics.setFont(font)
            -- border
            if self.border then
                love.graphics.setColor(self.borderColor)
                love.graphics.setLineWidth(self.borderWidth)
                love.graphics.rectangle('line', self.x, self.y, self.width, self.height, self.cornerRadius)
            end
            --
            love.graphics.setColor(self.backgroundColor)
            -- hover
            if self:isMouseInside() then
                if self.onHover and not self.hoverCalled then
                    self:onHover()
                    self.hoverCalled = true
                end
                love.mouse.setCursor(love.mouse.getSystemCursor('hand'))
                love.graphics.setColor(self.hoverColor)
                self.hovered = true
            elseif self.hovered then
                love.mouse.setCursor()
                if self.onMouseExit then
                    self:onMouseExit()
                end
                self.hovered = false
                self.hoverCalled = false
            end
            love.graphics.rectangle('fill', self.x, self.y, self.width, self.height, self.cornerRadius)
            love.graphics.setColor(self.textColor)
            love.graphics.printf(self.text, self.x + self.leftPadding, self.y + self.topPadding,
                self.width - (self.rightPadding + self.leftPadding), 'center')
            love.graphics.pop()
        end

    }

    ---@type badr.button
    return component(make_config(default, config))
end
