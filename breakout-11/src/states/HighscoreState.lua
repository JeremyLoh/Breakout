HighscoreState = Class{__includes = BaseState}

function HighscoreState:enter(params)
    self.highscores = params["highscores"]
end

function HighscoreState:update(dt)
    if love.keyboard.wasPressed("escape") then
        gStateMachine:change("start")
    end
end

function HighscoreState:render()
    love.graphics.setFont(gFonts["large"])
    love.graphics.printf("HIGHSCORES", 0, VIRTUAL_HEIGHT / 30, VIRTUAL_WIDTH, "center")

    love.graphics.setFont(gFonts["medium"])
    local x = VIRTUAL_WIDTH / 3 + 10
    local y = VIRTUAL_HEIGHT / 30 + 25
    local yIncrement = 25
    for i = 1, 10 do
        local name = self.highscores[i]["name"]
        local score = self.highscores[i]["score"]
        if name == nil or string.upper(name) == "NIL" then
            name = "---"
            score = "---"
        end
        -- Entry number
        love.graphics.printf(tostring(i) .. ":", x, y + (i * yIncrement), 50, "left")
        -- Name
        love.graphics.printf(string.upper(name), x + 50, y + (i * yIncrement), 50, "right")
        -- Score
        love.graphics.printf(tostring(score), x + 160, y + (i * yIncrement), VIRTUAL_WIDTH - x - 160, "left")
    end

    love.graphics.setFont(gFonts["medium"])
    love.graphics.printf("Press \"Escape\" to return to the Main Menu...", 0, VIRTUAL_HEIGHT - 20, VIRTUAL_WIDTH, "center")
end