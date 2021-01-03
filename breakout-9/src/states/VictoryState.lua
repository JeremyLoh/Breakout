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