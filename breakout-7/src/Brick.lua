Brick = Class{}

function Brick:init(x, y, color, variation)
    -- Keep track of brick color and the variation of that color
    self.variation = variation
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
    local lastColor = 5
    local lastVariation = 1
    local highestVariation = 4
    if self.color == lastColor and self.variation == lastVariation then
        self.isActive = false
        gSounds["brick-hit-2"]:play()
        return
    end
    
    if self.variation == lastVariation then
        -- Move to next color
        self.color = self.color + 1
        self.variation = highestVariation
        gSounds["brick-hit-2"]:play()
    else
        self.variation = self.variation - 1
    end
end

function Brick:isCurrentlyActive()
    return self.isActive
end

function Brick:render()
    if self.isActive then
        local texture = gGraphics["main"]
        local quad = gQuadsTable["bricks"][((self.color - 1) * 4) + self.variation]
        love.graphics.draw(texture, quad, self.x, self.y)
    end
end