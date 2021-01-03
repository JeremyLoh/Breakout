# breakout-7: Tier update

Implement tier system for the bricks in the game

Goes from increasing colors from top to bottom of the atlas (blue -> green -> red -> purple -> yellow)

Within each color, goes from last pattern to first pattern (solid color)

`PlayState.lua` Changes

```Lua
function PlayState:checkBricksCollision(dt)
    -- Check ball collision with bricks
    for key, brick in pairs(self.bricks) do
        if brick:isCurrentlyActive() and self.ball:collides(brick) then
            self.score = self.score + (((brick.color - 1) * 15) + brick.variation * 100)
            brick:hit()
            -- ...
        end
        -- ...
    end
    -- ...
end
```

`Brick.lua` Changes

```Lua
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
```
