Brick = Class{}

-- Make colors according to atlas of bricks
paletteColors = {
    -- Blue
    [1] = {
        ["r"] = 99/255,
        ["g"] = 155/255,
        ["b"] = 255/255, 
    },
    -- Green
    [2] = {
        ["r"] = 106/255,
        ["g"] = 190/255,
        ["b"] = 47/255,
    },
    -- Red
    [3] = {
        ["r"] = 238/255,
        ["g"] = 59/255,
        ["b"] = 87/255,
    },
    -- Purple
    [4] = {
        ["r"] = 142/255,
        ["g"] = 40/255, 
        ["b"] = 161/255, 
    },
    -- Gold
    [5] = {
        ["r"] = 255/255,
        ["g"] = 207/255,
        ["b"] = 64/255,
    }
}

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
    -- Create particle system
    self.particleSystem = love.graphics.newParticleSystem(gGraphics["particle"], 64)
    self.particleSystem:setParticleLifetime(0.5, 1)
    self.particleSystem:setLinearAcceleration(-15, 0, 15, 60)
    self.particleSystem:setEmissionArea("normal", 10, 10)
end

function Brick:hit()
    -- Set particle system
    self.particleSystem:setColors(
        paletteColors[self.color]["r"],
        paletteColors[self.color]["g"],
        paletteColors[self.color]["b"],
        1,
        paletteColors[self.color]["r"],
        paletteColors[self.color]["g"],
        paletteColors[self.color]["b"],
        0
    )
    self.particleSystem:emit(64)

    gSounds["brick-hit-1"]:stop()
    gSounds["brick-hit-1"]:play()

    local lastColor = 5
    local lastVariation = 1
    local highestVariation = 4
    if self.color == lastColor and self.variation == lastVariation then
        self.isActive = false
        gSounds["brick-hit-2"]:stop()
        gSounds["brick-hit-2"]:play()
        return
    end
    
    if self.variation == lastVariation then
        -- Move to next color
        self.color = self.color + 1
        self.variation = highestVariation
        gSounds["brick-hit-2"]:stop()
        gSounds["brick-hit-2"]:play()
    else
        self.variation = self.variation - 1
    end
end

function Brick:isCurrentlyActive()
    return self.isActive
end

function Brick:update(dt)
    self.particleSystem:update(dt)
end

function Brick:render()
    if self.isActive then
        local texture = gGraphics["main"]
        local quad = gQuadsTable["bricks"][((self.color - 1) * 4) + self.variation]
        love.graphics.draw(texture, quad, self.x, self.y)
    end
end

--[[
    Separate render function for particles so that they can
    be called after all bricks are drawn
    Else, there will be overlap of bricks and particle systems
]]
function Brick:renderParticles()
    love.graphics.draw(self.particleSystem, self.x + (self.width / 2), 
        self.y + (self.height / 2))
end