# breakout-11: Paddle Select Update

Add ability for users to select a paddle before starting the game

## `main.lua` changes

```Lua
function love.load()
    -- ...
    -- Quads generated from our textures
    gQuadsTable = {
        ["paddles"] = GenerateQuadPaddles(gGraphics["main"]),
        ["balls"] = GenerateQuadBalls(gGraphics["main"]),
        ["bricks"] = GenerateQuadBricks(gGraphics["main"]),
        ["hearts"] = generateQuads(gGraphics["hearts"], 16, 16),
        ["arrows"] = generateQuads(gGraphics["arrows"], 16, 16),
    }

    states = {
        ["start"] = function() return StartState() end,
        ["highscores"] = function() return HighscoreState() end,
        ["play"] = function() return PlayState() end,
        ["serve"] = function() return ServeState() end,
        ["game-over"] = function() return GameOverState() end,
        ["victory"] = function() return VictoryState() end,
        ["enter-highscores"] = function() return EnterHighscoreState() end,
        ["paddle-select"] = function() return PaddleSelectState() end,
    }
end
```

## `constants.lua` changes

```Lua
HIGHEST_PADDLE_SKIN = 4
HIGHEST_PADDLE_SIZE = 4
LOWEST_PADDLE_SKIN = 1
LOWEST_PADDLE_SIZE = 1

PADDLE_SIZES = {
    -- small (size 1)
    [1] = {
        ["width"] = 32,
        ["height"] = 16,
    },
    -- medium (size 2)
    [2] = {
        ["width"] = 64,
        ["height"] = 16,
    },
    -- large (size 3)
    [3] = {
        ["width"] = 96,
        ["height"] = 16,
    },
    -- extra-large (size 4)
    [4] = {
        ["width"] = 128,
        ["height"] = 16,
    },
}
```

## `Dependencies.lua` changes

```Lua
require "src/states/PaddleSelectState"
```

## `Paddle.lua` changes

```Lua
function Paddle:init(skin, size)
    -- Color of paddle (skin), used to offset gPaddleSkins
    self.skin = skin
    -- Paddle size (small (1), medium (2), large (3), extra-large (4))
    self.size = size
    -- Paddle dimensions
    self.width = PADDLE_SIZES[self.size]["width"]
    self.height = PADDLE_SIZES[self.size]["height"]
    self.x = (VIRTUAL_WIDTH / 2) - (self.width / 2)
    self.y = VIRTUAL_HEIGHT - 30
    -- Keep track of paddle velocity
    self.dx = 0
end
```

## `PaddleSelectState.lua`

```Lua
PaddleSelectState = Class{__includes = BaseState}

function PaddleSelectState:init()
    -- Color of paddle
    self.skin = 1
    -- Paddle size (small (1), medium (2), large (3), extra-large (4))
    self.size = 1
end

function PaddleSelectState:update(dt)
    if love.keyboard.wasPressed("enter") or love.keyboard.wasPressed("return") then
        gStateMachine:change("serve", {
            ["paddle"] = Paddle(self.skin, self.size),
            ["bricks"] = LevelMaker.createMap(1),
            ["ball"] = Ball(1),
            ["lives"] = MAX_LIVES,
            ["score"] = 0,
            ["level"] = 1,
        })
    elseif love.keyboard.wasPressed("escape") then
        gStateMachine:change("start")
    elseif love.keyboard.wasPressed("left") then
        if self.skin == LOWEST_PADDLE_SKIN and self.size == LOWEST_PADDLE_SIZE then
            gSounds["no-select"]:play()
        else
            gSounds["select"]:play()
            self.size = self.size - 1
            if self.size < 1 then
                self.skin = self.skin - 1
                self.size = HIGHEST_PADDLE_SIZE
            end
        end
    elseif love.keyboard.wasPressed("right") then
        if self.skin == HIGHEST_PADDLE_SKIN and self.size == HIGHEST_PADDLE_SIZE then
            gSounds["no-select"]:play()
        else
            gSounds["select"]:play()
            self.size = self.size + 1
            if self.size > 4 then
                self.size = LOWEST_PADDLE_SIZE
                self.skin = self.skin + 1
            end
        end
    end
end

function PaddleSelectState:render()
    love.graphics.setFont(gFonts["medium"])
    love.graphics.printf("Select your paddle with the left and right arrow keys", 0, 20, VIRTUAL_WIDTH, "center")
    love.graphics.setFont(gFonts["small"])
    love.graphics.printf("Press \"Enter\" to continue", 0, 40, VIRTUAL_WIDTH, "center")

    local arrowHeight = gGraphics["arrows"]:getHeight()
    local arrowWidth = gGraphics["arrows"]:getWidth()
    local arrowX = (VIRTUAL_WIDTH / 3) - (arrowWidth / 2)
    local arrowY = (VIRTUAL_HEIGHT / 2) - (arrowHeight / 2)
    local rightArrowOffset = (VIRTUAL_WIDTH / 2 - arrowX) - arrowWidth / 2

    -- Left select arrow
    if self.skin == LOWEST_PADDLE_SKIN and self.size == LOWEST_PADDLE_SIZE then
        -- Give grey tint to indicate no further selection possible
        love.graphics.setColor(40/255, 40/255, 40/255, 128/255)
    else
        -- Reset drawing color to full white for proper rendering
        love.graphics.setColor(1, 1, 1, 1)
    end
    love.graphics.draw(gGraphics["arrows"], gQuadsTable["arrows"][1], arrowX, arrowY)

    -- Right select arrow
    if self.skin == HIGHEST_PADDLE_SKIN and self.size == HIGHEST_PADDLE_SIZE then
        -- Give grey tint to indicate no further selection possible
        love.graphics.setColor(40/255, 40/255, 40/255, 128/255)
    else
        -- Reset drawing color to full white for proper rendering
        love.graphics.setColor(1, 1, 1, 1)
    end
    love.graphics.draw(gGraphics["arrows"], gQuadsTable["arrows"][2],
        (VIRTUAL_WIDTH / 2) + rightArrowOffset, arrowY)

    -- Reset drawing color to full white for proper rendering
    love.graphics.setColor(1, 1, 1, 1)
    -- Draw paddle
    local paddleWidth = PADDLE_SIZES[self.size]["width"]
    local paddleHeight = PADDLE_SIZES[self.size]["height"]
    love.graphics.draw(gGraphics["main"],
        gQuadsTable["paddles"][(self.skin - 1) * 4 + self.size],
        VIRTUAL_WIDTH / 2 - paddleWidth / 2,
        VIRTUAL_HEIGHT / 2 - paddleHeight / 2)
end
```

## `StartState.lua` changes

```Lua
function StartState:update(dt)
    if love.keyboard.wasPressed("up") or love.keyboard.wasPressed("down") then
        selectedOption = selectedOption == 1 and 2 or 1
        gSounds["paddle-hit"]:play()
    elseif love.keyboard.wasPressed("enter") or love.keyboard.wasPressed("return") then
        gSounds["confirm"]:play()
        if selectedOption == 1 then
            -- Start game, select paddle
            gStateMachine:change("paddle-select")
        elseif selectedOption == 2 then
            -- Highscores
            gStateMachine:change("highscores", {
                ["highscores"] = highscores
            })
        end
    elseif love.keyboard.wasPressed("escape") then
        love.event.quit()
    end
end
```
