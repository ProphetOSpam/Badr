--
-- Badr
--
-- Copyright (c) 2024 Nabeel20
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.

---@class badr.root
---@field x integer
---@field y integer
---@field visible boolean

---@class badr.component.config
---@field x integer?
---@field y integer?
---@field height integer?
---@field width integer?
---@field id string?
---@field visible integer?
---@field gap integer? Defaults to 0
---@field column boolean? Display children stacked vertically
---@field row boolean? Display children stacked horizontally
---@field onUpdates fun(self: badr.component)[]? Used internally, set onUpdates instead
---@field onUpdate fun(self: badr.component)?
---@field onDraws fun(self: badr.component)[]? Used internally, set onDraws instead
---@field onDraw fun(self: badr.component)?

--- To append a child component to a parent component, you can use the following
--- syntax: `parent = parent + child`.
---
--- To remove a child component from its parent, you can use the following
--- syntax: parent = parent - child. To hide a component you can use
--- component.visible = false
---
--- To update a child component, you can directly modify its value using:
--- `child.foo = newFoo`. For continuous updates, use :onUpdate(), and ensure to
--- call component update method.
---
--- To retrieve a child component by its id (string), you can use the following
--- syntax: `parent % id`. This will return the targeted child component
---
---@class badr.component : badr.root
---@field height integer
---@field width integer
---@field parent badr.component | badr.root Use the operator metamethods instead of setting this directly
---@field id string
---@field children badr.component[] Use the operator metamethods instead of setting this directly
---@field gap integer? Defaults to 0
---@field column boolean? Display children stacked vertically
---@field row boolean? Display children stacked horizontally
--- This allows greater OOPage for components, that way new functionality won't override previous
---@field onUpdates fun(self: badr.component)[] Called every `:update()`
---@field onDraws fun(self: badr.component)[] Called every `:draw()`
---@operator add(badr.component):badr.component
---@operator sub(badr.component):badr.component
---@operator mod(string):badr.component
local component = {}
component.__index = component

---@param t badr.component.config
function component:new(t)
    t = t or {}
    local _default = {
        x = 0,
        y = 0,
        height = 0,
        width = 0,
        parent = { x = 0, y = 0, visible = true },
        id = tostring(love.timer.getTime()),
        visible = true,
        children = {},
        onUpdates = {},
        onDraws = {},
    }
    for key, value in pairs(t) do
        _default[key] = value
    end
    return setmetatable(_default, component)
end

function component.__add(self, other)
    if type(other) ~= "table" or other == nil then return end

    other.parent = self
    other.x = self.x + other.x
    other.y = self.y + other.y

    local childrenSize = { width = 0, hight = 0 }
    for _, child in ipairs(self.children) do
        childrenSize.width = childrenSize.width + child.width;
        childrenSize.hight = childrenSize.hight + child.height
    end

    local gap = self.gap or 0
    local lastChild = self.children[#self.children] or {}

    if self.column then
        other.y = (lastChild.height or 0) + (lastChild.y or self.y)
        if #self.children > 0 then
            other.y = other.y + gap
        end
        self.height = math.max(self.height, childrenSize.hight + other.height + gap * #self.children)
        self.width = math.max(self.width, other.width)
    end
    if self.row then
        other.x = (lastChild.width or 0) + (lastChild.x or self.x)
        if #self.children > 0 then
            other.x = other.x + gap
        end
        self.width = math.max(self.width, childrenSize.width + other.width + gap * #self.children)
        self.height = math.max(self.height, other.height)
    end

    if #other.children > 0 then
        for _, child in ipairs(other.children) do
            child:updatePosition(other.x, other.y)
        end
    end
    table.insert(self.children, other)
    return self
end

-- Remove child
function component.__sub(self, other)
    if self % other.id then
        for index, child in ipairs(self.children) do
            if child.id == other.id then
                table.remove(self.children, index)
            end
        end
    end
    return self
end

-- Returns child with specific id
function component.__mod(self, id)
    assert(type(id) == "string", 'Badar; Provided id must be a string.')
    for _, child in ipairs(self.children) do
        if child.id == id then
            return child
        end
    end
end

--- To check if the mouse is within a component, you can use `:isMouseInside()`.
--- Badr uses `love.mouse.isDown()` to check for mouse clicks
function component:isMouseInside()
    local mouseX, mouseY = love.mouse.getPosition()
    return mouseX >= self.x and mouseX <= self.x + self.width and
        mouseY >= self.y and
        mouseY <= self.y + self.height
end

function component:draw()
    if not self.visible then return end;

    for _, onDraw in ipairs(self.onDraws) do
        onDraw(self)
    end

    if #self.children > 0 then
        for _, child in ipairs(self.children) do
            child:draw()
        end
    end
end

--- To update the position of a child component and all its children, you can
--- use the following syntax `:updatePosition(x,y)`.
---
---@param x integer
---@param y integer
function component:updatePosition(x, y)
    self.x = self.x + x
    self.y = self.y + y
    for _, child in ipairs(self.children) do
        child:updatePosition(x, y)
    end
end

--- To animate any component, you can use flux. If you want to animate a
--- component and all its children, you can use :animate().
--- ```lua
--- button {
---     text = 'Click for animation',
---     onClick = function(self)
---         -- Animate this component
---         self.opacity = 0
---         flux.to(self, 0.4, { opacity = 1 })
---         -- Animate the whole tree
---         self.parent:animate(function(s)
---             -- note that we pass the current position
---             flux.to(s, 2, { x = s.x + 250 })
---         end)
---     end,
--- }
--- ```
---
---@param f fun(self: badr.component)
function component:animate(f)
    f(self)
    for _, child in ipairs(self.children) do
        child:animate(f)
    end
end

function component:update()
    for _, onUpdate in ipairs(self.onUpdates) do
        onUpdate(self)
    end

    for _, child in ipairs(self.children) do
        child:update()
    end
end

---@param config badr.component.config
---@return badr.component
return function(config)
    return component:new(config)
end
