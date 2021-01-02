--[[
    Ball Class

    Represents a ball that will bounce back and forth between the
    top, left, right walls, the player's paddle and the bricks in the level

    Each ball can be created by providing a skin index, which will be used
    to access the balls quad created in `main.lua`
]]

Ball = Class{}

function Ball:init(skin)
    -- Balls have fixed width and height
    self.width = 8
    self.height = 8
    -- Set initial position to center of screen
    self.x = VIRTUAL_WIDTH / 2 - (self.width / 2)
    self.y = VIRTUAL_HEIGHT / 2 - (self.height / 2)
    -- Set initial velocity
    self.dx = 0
    self.dy = 0
    -- Set the skin index for the ball quad
    self.skin = skin
end

--[[
    Checks for collision of ball with a given object
]]
function Ball:collides(object)
    -- Use aabb collision detection
    if (self.x < object.x + object.width) and (self.x + self.width > object.x)
        and (self.y < object.y + object.height) and (self.y + self.height > object.y) then
        return true        
    end
    return false
end

--[[
    Reset ball to center of screen
]]
function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - (self.width / 2)
    self.y = VIRTUAL_HEIGHT / 2 - (self.height / 2)
    self.dx = 0
    self.dy = 0
end

function Ball:update(dt)
    self.x = self.x + (self.dx * dt)
    self.y = self.y + (self.dy * dt)

    if (self.x <= 0) then
        -- Left wall collision
        self.dx = -self.dx
        self.x = 0
        gSounds["wall-hit"]:play()
    elseif ((self.x + self.width) >= VIRTUAL_WIDTH) then
        -- Right wall collision
        self.dx = -self.dx
        self.x = VIRTUAL_WIDTH - self.width
        gSounds["wall-hit"]:play()
    elseif (self.y <= 0) then
        -- Top wall collision
        self.dy = -self.dy
        self.y = 0
        gSounds["wall-hit"]:play()
    end
end

function Ball:render()
    local texture = gGraphics["main"]
    local quad = gQuadsTable["balls"][self.skin]
    love.graphics.draw(texture, quad, self.x, self.y)
end

function Ball:randomVelocity()
    self.dx = math.random(-200, 200)
    self.dy = math.random(-100, -80)
end