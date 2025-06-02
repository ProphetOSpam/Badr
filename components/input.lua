local component = require("badr")
local make_config = require("make_config")

---@class badr.input.handler
---@field focus badr.input?
local inputHandler = {}

---@class badr.input.config : badr.button.config
---@field emptyText string?
---@field focusColor [integer, integer, integer, integer]?
---@field onTextInput fun(self: badr.input, char: string)?
---@field onKeypress fun(self: badr.input, key: string, scancode: integer, isrepeat: boolean)?
---@field onSubmit fun(self: badr.input)?
---@field onUpdate fun(self: badr.input)?
---@field onUpdates fun(self: badr.input)[]?
---@field onDraw fun(self: badr.input)?
---@field onDraws fun(self: badr.input)[]?

---@class badr.input : badr.button
---@field emptyText string
---@field focusColor [integer, integer, integer, integer]
---@field onTextInput fun(self: badr.input, char: string)
---@field onKeypress fun(self: badr.input, key: string, scancode: integer, isrepeat: boolean)
---@field onSubmit fun(self: badr.input)?
---@field onUpdates fun(self: badr.input)[]
---@field onDraws fun(self: badr.input)[]

-- https://github.com/s-walrus/hex2color/blob/master/hex2color.lua
local function Hex(hex, value)
    return {
        tonumber(string.sub(hex, 2, 3), 16) / 256,
        tonumber(string.sub(hex, 4, 5), 16) / 256,
        tonumber(string.sub(hex, 6, 7), 16) / 256,
        value or 1,
    }
end

--- This is largely copied from Badar's button
---
---@param config badr.input.config
---@return badr.input
function inputHandler.input(config)
    -- Decided here because other values depend on them; if they are specified in `config` the other defaults should take that into account
    local text = config.text or ""

    local font = config.font or love.graphics.getFont()

    local padding = {
        left = config.leftPadding or 12,
        right = config.rightPadding or 12,
        top = config.topPadding or 8,
        bottom = config.bottomPadding or 8,
    }

    local width = font:getWidth(text) + padding.left + padding.right
    local height = font:getHeight() + padding.top + padding.bottom

    ---@type badr.input.config
    local default = {
        text = text,
        width = width,
        height = height,
        font = font,
        -- styles
        backgroundColor = Hex("#DBE2EF"),
        hoverColor = Hex("#3F72AF"),
        textColor = Hex("#112D4E"),
        focusColor = Hex("#666666"),
        cornerRadius = 4,
        leftPadding = padding.left,
        rightPadding = padding.right,
        topPadding = padding.top,
        bottomPadding = padding.bottom,
        borderColor = Hex("#FFFFFF"),
        borderWidth = 0,
        border = false,
        angle = 0,
        scale = 1,
        -- logic
        onClick = function(self)
            inputHandler.focus = self
        end,
        disabled = false,
        hoverCalled = false,
        mousePressed = false,
        onUpdate = function(self)
            if love.mouse.isDown(1) then
                if
                    self.mousePressed == false
                    and self:isMouseInside()
                    and self.parent.visible
                then
                    self.mousePressed = true
                    if self.onClick then
                        self:onClick()
                    end
                end
            else
                self.mousePressed = false
            end
        end,
        onKeypress = function(self, key, scancode, isrepeat)
            if key == "backspace" then
                self.text = self.text:sub(1, #self.text - 1)
            elseif key == "escape" then -- Maybe an onEnter function?
                inputHandler.focus = nil
            elseif key == "return" then
                if self.onSubmit then
                    self:onSubmit()
                end
            end
        end,
        onTextInput = function(self, char)
            self.text = self.text .. char
        end,
        --
        onDraw = function(self)
            if not self.visible then
                return love.mouse.setCursor()
            end
            love.graphics.push()
            love.graphics.rotate(self.angle)
            love.graphics.scale(self.scale, self.scale)
            love.graphics.setFont(font)
            -- border
            if self.border then
                love.graphics.setColor(self.borderColor)
                love.graphics.setLineWidth(self.borderWidth)
                love.graphics.rectangle(
                    "line",
                    self.x,
                    self.y,
                    self.width,
                    self.height,
                    self.cornerRadius
                )
            end
            --
            love.graphics.setColor(self.backgroundColor)
            -- hover
            if self:isMouseInside() then
                if self.onHover and not self.hoverCalled then
                    --*  onHover return a 'clean up' callback
                    self.onMouseExit = self.onHover(self)
                    self.hoverCalled = true
                end
                love.mouse.setCursor(love.mouse.getSystemCursor("ibeam"))
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
            if inputHandler.focus == self then
                love.graphics.setColor(self.focusColor)
            end
            love.graphics.rectangle(
                "fill",
                self.x,
                self.y,
                self.width,
                self.height,
                self.cornerRadius
            )
            love.graphics.setColor(self.textColor)
            love.graphics.printf(
                (#self.text ~= 0 or inputHandler.focus == self) and self.text
                    or self.emptyText,
                self.x + self.leftPadding,
                self.y + self.topPadding,
                self.width - (self.rightPadding + self.leftPadding),
                "center"
            )
            love.graphics.pop()
        end,
    }

    ---@type badr.input
    return component(make_config(default, config))
end

--- Place in `love.keypressed`
--- ```lua
--- function love.keypressed(key, scancode, isrepeat)
---     inputHandler:keypressed(key, scancode, isrepeat)
--- end
--- ```
function inputHandler:keypressed(key, scancode, isrepeat)
    if self.focus then
        self.focus:onKeypress(key, scancode, isrepeat)
    end
end

--- Place in `love.textinput`
--- ```lua
--- function love.textinput(text)
---     inputHandler:textinput(text)
--- end
--- ```
function inputHandler:textinput(text)
    if self.focus then
        self.focus:onTextInput(text)
    end
end

return inputHandler
