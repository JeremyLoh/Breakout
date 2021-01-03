ServeState = Class{__includes = BaseState}

function ServeState:enter(param)
    self.paddle= param["paddle"]
    self.bricks = param["bricks"]
    self.score = param["score"]
    self.lives = param["lives"]
    self.level = param["level"]
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
            ["level"] = self.level,
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
    love.graphics.printf("Level " .. tostring(self.level), 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, "center")
    love.graphics.printf("Press \"Enter\" to serve!", 0, VIRTUAL_HEIGHT / 3 + 50, VIRTUAL_WIDTH, "center")
end