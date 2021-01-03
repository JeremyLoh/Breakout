# breakout-8: Particle System Update

Adds a particle system for when the ball collides with a brick. Particles will be emitted for a short duration during this collision and in the color of the collided brick (before the brick changes color). The particles emitted will also move downwards.

## Functions used

`love.graphics.newParticleSystem(texture, particles)`

1. Takes in a particle texture and maximum number of particles we can emit and creates a particle system we can emit from, update, and render

https://love2d.org/wiki/ParticleSystem

A ParticleSystem can be used to create particle effects like fire or smoke.

The particle system has to be created using `love.graphics.newParticleSystem`. Just like any other Drawable it can be drawn to the screen using `love.graphics.draw`. You also have to update it in the update callback to see any changes in the particles emitted.

The particle system won't create any particles unless you call `setParticleLifetime` and `setEmissionRate`.

## `Brick.lua` Changes

```Lua
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
    -- ...
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
    -- ...
end

function Brick:update(dt)
    self.particleSystem:update(dt)
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
```

## `PlayState.lua` Changes

```Lua
function PlayState:update(dt)
    -- ...
    if not self.paused then
        self.paddle:update(dt)
        self.ball:update(dt)
        self:checkPaddleCollision(dt)
        self:checkBricksCollision(dt)
        self:updateLives()
        for key, brick in pairs(self.bricks) do
            brick:update(dt)
        end
    end
end
function PlayState:render()
    -- ...
    for key, brick in pairs(self.bricks) do
        brick:render()
    end
    for key, brick in pairs(self.bricks) do
        brick:renderParticles()
    end
    -- ...
end
```
