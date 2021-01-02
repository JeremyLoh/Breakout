--[[
    StartState Class

    Represents the state that the game is in when it is started
    Displays "Breakout" in large text and 2 possible selection options:
    1) Start Game
    2) Highscores
]]

StartState = Class{__includes = BaseState}

-- Whether we are selecting "Start Game" or "Highscores"
local selectedOption = 1

function setHighlightColour()
    love.graphics.setColor(144/255, 180/255, 236/255, 255/255)
end

function resetColour()
    love.graphics.setColor(1, 1, 1, 1)
end

function StartState:update(dt)
    if love.keyboard.wasPressed("up") or love.keyboard.wasPressed("down") then
        selectedOption = selectedOption == 1 and 2 or 1
        gSounds["paddle-hit"]:play()
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
            })
        end
    elseif love.keyboard.wasPressed("escape") then
        love.event.quit()
    end
end

function StartState:render()
    -- Display title
    love.graphics.setFont(gFonts["large"])
    love.graphics.printf("BREAKOUT", 0, VIRTUAL_HEIGHT / 6, VIRTUAL_WIDTH, "center")

    -- Display options
    love.graphics.setFont(gFonts["medium"])
    -- "Start Game" is highlighted
    if selectedOption == 1 then
        setHighlightColour()
    end
    love.graphics.printf("Start Game", 0, VIRTUAL_HEIGHT / 3 + 10, VIRTUAL_WIDTH, "center")
    resetColour()

    -- "Highscores" is highlighted
    if selectedOption == 2 then
        setHighlightColour()
    end
    love.graphics.printf("Highscores", 0, VIRTUAL_HEIGHT / 3 + 30, VIRTUAL_WIDTH, "center")
    resetColour()
end
