# breakout-9: Progression Update

Add Levels to the game and fix bug: game over screen not showing

## `main.lua` changes

```Lua
function love.load()
    -- ...
    states = {
        ["start"] = function() return StartState() end,
        ["play"] = function() return PlayState() end,
        ["serve"] = function() return ServeState() end,
        ["game-over"] = function() return GameOverState() end,
        ["victory"] = function() return VictoryState() end,
    }
    gStateMachine = StateMachine(states)
    gStateMachine:change("start")
    -- ...
end
```

## `Dependencies.lua` changes

```Lua
-- ...
require "src/states/VictoryState"
require "src/states/GameOverState"
```

## `PlayState.lua` changes

```Lua
function PlayState:enter(enterParams)
    self.paused = false
    self.paddle = enterParams["paddle"]
    self.bricks = enterParams["bricks"]
    self.lives = enterParams["lives"]
    self.score = enterParams["score"]
    self.level = enterParams["level"]
    self.ball = enterParams["ball"]
    -- Give ball random velocity
    self.ball:randomVelocity()
end

function PlayState:update(dt)
    -- ...
    if not self.paused then
        self.paddle:update(dt)
        self.ball:update(dt)
        self:checkPaddleCollision(dt)
        self:checkBricksCollision(dt)
        self:checkVictory()
        self:updateLives()
        for key, brick in pairs(self.bricks) do
            brick:update(dt)
        end
    end
end

function PlayState:checkVictory()
    for key, brick in pairs(self.bricks) do
        if brick:isCurrentlyActive() then
            return
        end
    end
    -- All bricks are cleared
    gSounds["victory"]:stop()
    gSounds["victory"]:play()
    local victoryStateParams = {
        ["paddle"] = self.paddle,
        ["ball"] = self.ball,
        ["lives"] = self.lives,
        ["score"] = self.score,
        ["level"] = self.level,
    }
    gStateMachine:change("victory", victoryStateParams)
end

function PlayState:updateLives()
    if self.ball.y >= VIRTUAL_HEIGHT then
        gSounds["hurt"]:play()
        self.lives = self.lives - 1
        -- Check for game over
        if self.lives == 0 then
            gStateMachine:change("game-over", {
                ["score"] = self.score,
            })
        else
            self:resetBall()
            local serveStateParams = {
                ["paused"] = self.paused,
                ["paddle"] = self.paddle,
                ["bricks"] = self.bricks,
                ["lives"] = self.lives,
                ["score"] = self.score,
                ["level"] = self.level,
            }
            gStateMachine:change("serve", serveStateParams)
        end
    end
end
```

## `ServeState.lua` changes

```Lua
function ServeState:enter(param)
    -- ...
    self.lives = param["lives"]
    self.level = param["level"]
end

function ServeState:update(dt)
    -- ...
    if love.keyboard.wasPressed("enter") or love.keyboard.wasPressed("return") then
        gStateMachine:change("play", {
            ["paddle"] = self.paddle,
            ["ball"] = self.ball,
            ["bricks"] = self.bricks,
            ["score"] = self.score,
            ["lives"] = self.lives,
            ["level"] = self.level,
        })
    elseif love.keyboard.wasPressed("escape") then
        love.event.quit()
    end
end

function ServeState:render()
    -- ...
    -- Display instructions to serve ball
    love.graphics.setFont(gFonts["large"])
    love.graphics.printf("Level " .. tostring(self.level), 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, "center")
    love.graphics.printf("Press \"Enter\" to serve!", 0, VIRTUAL_HEIGHT / 3 + 50, VIRTUAL_WIDTH, "center")
end
```

## `StartState.lua` changes

```Lua
function StartState:update(dt)
    -- ...
    elseif love.keyboard.wasPressed("enter") or love.keyboard.wasPressed("return") then
        gSounds["confirm"]:play()
        if selectedOption == 1 then
            -- Start game
            gStateMachine:change("serve", {
                ["paddle"] = Paddle(1),
                ["bricks"] = LevelMaker.createMap(1),
                ["ball"] = Ball(1),
                ["lives"] = MAX_LIVES,
                ["score"] = 0,
                ["level"] = 1,
            })
        end
    elseif love.keyboard.wasPressed("escape") then
        love.event.quit()
    end
end
```

## `VictoryState.lua`

```Lua
VictoryState = Class{__includes = BaseState}

function VictoryState:enter(params)
    self.paddle = params["paddle"]
    self.ball = params["ball"]
    self.lives = params["lives"]
    self.score = params["score"]
    self.level = params["level"]
end

function VictoryState:update(dt)
    self.paddle:update(dt)
    self.ball.x = self.paddle.x + (self.paddle.width / 2) - (self.ball.width / 2)
    self.ball.y = self.paddle.y - self.ball.height

    if love.keyboard.wasPressed("enter") or love.keyboard.wasPressed("return") then
        gStateMachine:change("serve", {
            ["paddle"] = self.paddle,
            ["bricks"] = LevelMaker.createMap(self.level + 1),
            ["lives"] = self.lives,
            ["score"] = self.score,
            ["level"] = self.level + 1,
        })
    end
end

function VictoryState:render()
    self.paddle:render()
    self.ball:render()
    drawPlayerLives(self.lives)
    drawPlayerScore(self.score)

    love.graphics.setFont(gFonts["large"])
    love.graphics.printf("Level " .. tostring(self.level) .. " complete!", 0, VIRTUAL_HEIGHT / 4, VIRTUAL_WIDTH, "center")

    love.graphics.setFont(gFonts["medium"])
    love.graphics.printf("Press \"Enter\" to continue...", 0, VIRTUAL_HEIGHT / 4 + 50, VIRTUAL_WIDTH, "center")
end
```
