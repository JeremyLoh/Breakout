--[[
    PlayState Class

    Represents the gameplay. 
    The player can control a paddle that can be moved left or right
    using the left and right arrow keys
]]

PlayState = Class{__includes = BaseState}

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
        self:checkVictory()
        self:updateLives()
        for key, brick in pairs(self.bricks) do
            brick:update(dt)
        end
    end
end

function PlayState:render()
    self.paddle:render()
    self.ball:render()
    for key, brick in pairs(self.bricks) do
        brick:render()
    end
    for key, brick in pairs(self.bricks) do
        brick:renderParticles()
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

function PlayState:resetBall()
    self.ball:reset()
    self.ball:randomVelocity()
end

function PlayState:checkPaddleCollision(dt)
    -- Check ball collision with paddle
    if self.ball:collides(self.paddle) then
        -- Update ball dx if the paddle is moving in same direction as ball
        -- during collision
        -- Find difference between paddle's center and the ball
        local paddleCenter = self.paddle.x + (self.paddle.width / 2)
        local difference = paddleCenter - self.ball.x
        local factor = 200
        local startDx = 60
        if difference > 0 and self.paddle.dx < 0 then
            -- left side collision, paddle moving left
            self.ball.dx = -(startDx + (dt * difference * factor))
        elseif difference < 0 and self.paddle.dx > 0 then
            -- right side collision, paddle moving right
            self.ball.dx = startDx + (dt * math.abs(difference) * factor)
        end

        -- Move ball out of paddle
        self.ball.y = self.paddle.y - self.ball.height
        -- Reverse Y direction
        self.ball.dy = -self.ball.dy
        gSounds["paddle-hit"]:play()
    end
end

function PlayState:checkBricksCollision(dt)
    -- Check ball collision with bricks
    for key, brick in pairs(self.bricks) do
        if brick:isCurrentlyActive() and self.ball:collides(brick) then
            self.score = self.score + (((brick.color - 1) * 15) + brick.variation * 100)
            brick:hit()
            local ballMovingRight = self.ball.dx > 0
            local ballMovingLeft = self.ball.dx < 0
            local ballMovingDown = self.ball.dy > 0
            local ballMovingUp = self.ball.dy < 0
            -- Offset checked value to fix corner collision detection
            local offset = 2

            -- Check side of brick that collides with ball
            if self.ball.x + offset < brick.x and ballMovingRight then
                -- Left side collision
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x - self.ball.width
            elseif (self.ball.x + self.ball.width - offset) > (brick.x + brick.width)
                and ballMovingLeft then
                -- Right side collision
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x + brick.width
            elseif self.ball.y < brick.y and ballMovingDown then
                -- Top side collision
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y - self.ball.height
            elseif (self.ball.y + self.ball.height) > brick.y + brick.height 
                and ballMovingUp then
                -- Bottom side collision
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y + brick.height
            end

            -- Slightly increase y velocity to speed up the game
            self.ball.dy = self.ball.dy * 1.02
        end
    end
end