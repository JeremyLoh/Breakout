--[[
    Paddle Class

    Represents a paddle that can move left and right.
    Used to deflect the ball towards the bricks
]]

Paddle = Class{}

--[[
    The paddle will initialize to the same spot every time
]]
function Paddle:init()
    -- Default paddle dimensions
    self.width = 64
    self.height = 16
    self.x = (VIRTUAL_WIDTH / 2) - (self.width / 2)
    self.y = VIRTUAL_HEIGHT - 30
    -- Keep track of paddle velocity
    self.dx = 0
    -- Color of paddle (skin), used to offset gPaddleSkins
    self.skin = 1
    -- Paddle size (small (1), medium (2), large (3), extra-large (4))
    self.size = 2
end

function Paddle:update(dt)
    if love.keyboard.isDown("left") then
        self.dx = -PADDLE_SPEED
    elseif love.keyboard.isDown("right") then
        self.dx = PADDLE_SPEED
    else
        self.dx = 0
    end

    -- Limit paddle to left and right edge of screen
    self.x = math.max(0, self.x + (self.dx * dt))
    self.x = math.min(self.x, VIRTUAL_WIDTH - self.width)
end

function Paddle:render()
    local texture = gGraphics["main"]
    local quad = gQuadsTable["paddles"][((self.skin - 1) * 4) + self.size]
    love.graphics.draw(texture, quad, self.x, self.y)
end