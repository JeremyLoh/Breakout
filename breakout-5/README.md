# breakout-5: Hearts update

This update adds the following:

1. Add player lives (hearts) to the game
1. Add serve state
1. Add game over screen

## Add player lives (hearts) to the game

`PlayState.lua` changes:

```Lua
function PlayState:update(dt)
    if love.keyboard.wasPressed("escape") then
        love.event.quit()
    end

    if love.keyboard.wasPressed("space") then
        gSounds["pause"]:play()
        self.paused = not self.paused and true or false
    end

    if not self.paused then
        self.paddle:update(dt)
        self.ball:update(dt)
        self:checkPaddleCollision(dt)
        self:checkBricksCollision(dt)
        self:updateLives()
    end
end

function PlayState:render()
    self.paddle:render()
    self.ball:render()
    for key, brick in pairs(self.bricks) do
        brick:render()
    end
    drawPlayerLives(self.lives)
    drawPlayerScore(self.score)

    if self.paused then
        love.graphics.setFont(gFonts["large"])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 40, VIRTUAL_WIDTH, "center")
        love.graphics.setFont(gFonts["medium"])
        love.graphics.printf("Press \"Spacebar\" to resume...", 0, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, "center")
    end
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
        end

        self:resetBall()
        local serveStateParams = {
            ["paused"] = self.paused,
            ["paddle"] = self.paddle,
            ["bricks"] = self.bricks,
            ["lives"] = self.lives,
            ["score"] = self.score,
        }
        gStateMachine:change("serve", serveStateParams)
    end
end
```

## Add serve state

`ServeState.lua`:

```Lua
ServeState = Class{__includes = BaseState}

function ServeState:enter(param)
    self.paddle= param["paddle"]
    self.bricks = param["bricks"]
    self.score = param["score"]
    self.lives = param["lives"]
    -- Generate a new random ball variation
    self.ball = Ball(math.random(TOTAL_BALL_VARIATIONS))
end

function ServeState:update(dt)
    -- Update paddle movement
    self.paddle:update(dt)
    -- Make ball follow paddle's center
    self.ball.x = self.paddle.x + (self.paddle.width / 2) -
        (self.ball.width / 2)
    self.ball.y = self.paddle.y - self.ball.height

    if love.keyboard.wasPressed("enter") or love.keyboard.wasPressed("return") then
        gStateMachine:change("play", {
            ["paddle"] = self.paddle,
            ["ball"] = self.ball,
            ["bricks"] = self.bricks,
            ["score"] = self.score,
            ["lives"] = self.lives,
        })
    elseif love.keyboard.wasPressed("escape") then
        love.event.quit()
    end
end

function ServeState:render()
    for key, brick in pairs(self.bricks) do
        brick:render()
    end
    self.paddle:render()
    self.ball:render()
    drawPlayerLives(self.lives)
    drawPlayerScore(self.score)

    -- Display instructions to serve ball
    love.graphics.setFont(gFonts["large"])
    love.graphics.printf("Press \"Enter\" to serve!", 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, "center")
end
```

## Add game over screen

`GameOverState.lua`:

```Lua
GameOverState = Class{__includes = BaseState}

function GameOverState:enter(params)
    self.score = params["score"]
end

function GameOverState:update(dt)
    if love.keyboard.wasPressed("enter") or love.keyboard.wasPressed("return") then
        gStateMachine:change("serve", {
            ["paddle"] = Paddle(1),
            ["bricks"] = LevelMaker.createMap(),
            ["ball"] = Ball(1),
            ["lives"] = MAX_LIVES,
            ["score"] = 0,
        })
    elseif love.keyboard.wasPressed("escape") then
        love.event.quit()
    end
end

function GameOverState:render()
    local y = VIRTUAL_HEIGHT / 5
    love.graphics.setFont(gFonts["large"])
    love.graphics.printf("Game Over", 0, y, VIRTUAL_WIDTH, "center")
    love.graphics.printf("Score: " .. tostring(self.score), 0, y + 50, VIRTUAL_WIDTH, "center")
    love.graphics.printf("Press \"Enter\" to restart", 0, y + 100, VIRTUAL_WIDTH, "center")
end
```
