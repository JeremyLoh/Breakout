Brick = Class{}

function Brick:init(x, y, color)
    -- Keep track of brick color and the variation of that color
    self.variation = 3
    self.color = color
    self.x = x
    self.y = y
    self.width = 32
    self.height = 16
    -- Keep track of whether brick should be rendered
    self.isActive = true
end

function Brick:hit()
    gSounds["brick-hit-1"]:play()
    self.isActive = false
end

function Brick:render()
    if self.isActive then
        local texture = gGraphics["main"]
        local quad = gQuadsTable["bricks"][((self.color - 1) * 4) + self.variation]
        love.graphics.draw(texture, quad, self.x, self.y)
    end
end