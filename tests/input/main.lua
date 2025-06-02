local component = require 'badr'
local inputHandler = require 'components.input'
local input = inputHandler.input

local menu = component { column = true, gap = 10 }
        + input {
            emptyText = "I'm empty!",
            onSubmit = function(self)
                print(self.text)
                self.text = ""
            end,
            width = 200
        }
        + input { text = "Initial text", width = 200 }

function love.load()
    love.graphics.setBackgroundColor({ 1, 1, 1 })
    local clicks = 0
end

function love.draw()
    menu:draw()
end

function love.keypressed(key, scancode, isrepeat)
    inputHandler:keypressed(key, scancode, isrepeat)
end

function love.textinput(text)
    inputHandler:textinput(text)
end

function love.update()
    menu:update()
end
