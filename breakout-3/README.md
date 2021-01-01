# breakout-3: Brick update

1. Add brick quads
1. Add Brick class
1. Add a Level maker (creates a table of starting bricks for a level)

### Add brick quads

`main.lua` changes

```Lua
function love.load()
    -- ...
    gGraphics = {
        ["background"] = love.graphics.newImage("graphics/background.png"),
        ["main"] = love.graphics.newImage("graphics/breakout.png"),
        ["arrows"] = love.graphics.newImage("graphics/arrows.png"),
        ["hearts"] = love.graphics.newImage("graphics/hearts.png"),
        ["particle"] = love.graphics.newImage("graphics/particle.png"),
    }
    -- Quads generated from our textures
    gQuadsTable = {
        ["paddles"] = GenerateQuadPaddles(gGraphics["main"]),
        ["balls"] = GenerateQuadBalls(gGraphics["main"]),
        ["bricks"] = GenerateQuadBricks(gGraphics["main"]),
    }
    -- ...
end
```

`Util.lua` changes

```Lua
--[[
    Generate quad bricks based on "breakout.png"
    There are a total of 4 rows of bricks.
    There are 6 bricks for row of the first 3 rows.
    The 4th row has 3 bricks.
    Each brick is 32px x 16px (width x height).
]]
function GenerateQuadBricks(atlas)
    local tileWidth = 32
    local tileHeight = 16
    local allQuads = generateQuads(atlas, tileWidth, tileHeight)

    return table.slice(allQuads, 1, 21, 1)
end
```

### Add Brick class

`Brick.lua` Class:

```Lua
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
```

### Add a Level maker (creates a table of starting bricks for a level)

```Lua
--[[
    LevelMaker Class

    Used to create randomized levels by returning a table of bricks that the
    game should render.
]]

LevelMaker = Class{}

function LevelMaker.createMap()
    local brickWidth = 32
    local brickHeight = 16
    local bricks = {}
    local index = 1
    -- Randomly generate rows and columns
    local maxColumns = (VIRTUAL_WIDTH / brickWidth) - 1
    local rows = math.random(3, 6)
    local columns = math.random(5, maxColumns)

    local startMargin = ((VIRTUAL_WIDTH - (maxColumns * brickWidth)) / 2) +
        ((maxColumns - columns) * brickWidth) / 2-- account for lesser columns situation
    local brickColor = 0

    for y = 1, rows do
        for x = 1, columns do
            bricks[index] = Brick(
                (x - 1) * brickWidth +  -- tables are 1 indexed
                startMargin, -- x-coord
                y * brickHeight, -- y-coord, has top padding of brick height
                brickColor + 1)
            index = index + 1
        end
        brickColor = (brickColor + 1) % TOTAL_BRICK_COLORS
    end

    return bricks
end
```
