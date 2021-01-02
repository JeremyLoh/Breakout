GameOverState = Class{__includes = BaseState}

function GameOverState:enter(params)
    self.score = params["score"]
end

function GameOverState:update(dt)
    if love.keyboard.wasPressed("enter") or love.keyboard.wasPressed("return") then
        gStateMachine:change("start")
    elseif love.keyboard.wasPressed("escape") then
        love.event.quit()
    end
end

function GameOverState:render()
    local y = VIRTUAL_HEIGHT / 5
    love.graphics.setFont(gFonts["large"])
    love.graphics.printf("GAME OVER", 0, y, VIRTUAL_WIDTH, "center")
    love.graphics.printf("Score: " .. tostring(self.score), 0, y + 50, VIRTUAL_WIDTH, "center")
    love.graphics.printf("Press \"Enter\" to restart", 0, y + 100, VIRTUAL_WIDTH, "center")
end