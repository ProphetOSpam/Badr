local component = require 'badr'
local label = require 'components.label'

local menu = component { column = true, gap = 10 }
        + label "I'm from a string!"
        + label { text = "I'm from a table!", width = 200 }
        + label {
            text = 'Loading',
            counter = 1,
            onUpdates = {
                function(self)
                    self.counter = self.counter + 1

                    -- Only do it every 20 frames
                    if self.counter % 20 == 0 then
                        self.text = self.text .. "."
                    end

                    if self.counter / 20 >= 4 then
                        self.text = "Loading"
                        self.counter = 1
                    end
                end
            }
        }

function love.load()
    love.graphics.setBackgroundColor({ 1, 1, 1 })
    local clicks = 0
end

function love.draw()
    menu:draw()
end

function love.update()
    menu:update()
end
