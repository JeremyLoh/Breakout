--[[
    PlayState Class

    Represents the gameplay. 
    The player can control a paddle that can be moved left or right
    using the left and right arrow keys
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.paused = false
    self.paddle = Paddle()
    self.ball = Ball(1)
    -- Give ball random velocity
    self.ball.dx = math.random(-200, 200)
    self.ball.dy = math.random(-70, -60)
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
        -- Check ball collision with paddle
        if self.ball:collides(self.paddle) then
            -- Move ball out of paddle
            self.ball.y = self.ball.y - (self.ball.height / 2)
            -- Reverse Y direction
            self.ball.dy = -self.ball.dy
            gSounds["paddle-hit"]:play()
        end
    end
end

function PlayState:render()
    self.paddle:render()
    self.ball:render()

    if self.paused then
        love.graphics.setFont(gFonts["large"])
        love.graphics.printf("PAUSED", 0, 20, VIRTUAL_WIDTH, "center")
        love.graphics.setFont(gFonts["medium"])
        love.graphics.printf("Press \"Spacebar\" to resume...", 0, 50, VIRTUAL_WIDTH, "center")
    end
end