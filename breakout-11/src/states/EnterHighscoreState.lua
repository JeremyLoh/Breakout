EnterHighscoreState = Class{__includes = BaseState}

-- Store individual characters of string
-- ASCII value ranges from 65 (A) to 90 (Z)
local chars = {
    [1] = 65,
    [2] = 65,
    [3] = 65,
}
local highlightedChar = 1

function EnterHighscoreState:enter(params)
    self.score = params["score"]
    self.scoreIndex = params["score-index"]
end

function EnterHighscoreState:update(dt)
    if love.keyboard.wasPressed("enter") or love.keyboard.wasPressed("return") then
        local name = string.char(chars[1]) .. string.char(chars[2]) .. string.char(chars[3])
        -- Update score table
        -- Shift values down one position
        for i = 10, self.scoreIndex, -1 do
            highscores[i + 1] = highscores[i]
        end
        highscores[self.scoreIndex] = {
            ["name"] = name,
            ["score"] = self.score,
        }
        -- Write to file
        while true do
            local data = ""
            for i = 1, 10 do
                data = data .. highscores[i]["name"] .. "\n"
                    .. tostring(highscores[i]["score"]) .. "\n"
            end
            writeSuccess = love.filesystem.write("highscores.lst", data)
            if writeSuccess then
                break
            end
        end
        gStateMachine:change("start")
    elseif love.keyboard.wasPressed("left") and highlightedChar > 1 then
        highlightedChar = highlightedChar - 1
        gSounds["select"]:play()
    elseif love.keyboard.wasPressed("right") and highlightedChar < 3 then
        highlightedChar = highlightedChar + 1
        gSounds["select"]:play()
    elseif love.keyboard.wasPressed("up") then
        chars[highlightedChar] = 65 + ((chars[highlightedChar] - 65 + 1) % 26)
        gSounds["select"]:play()
    elseif love.keyboard.wasPressed("down") then
        chars[highlightedChar] = 65 + ((chars[highlightedChar] - 65 - 1) % 26)
        gSounds["select"]:play()
    end
end

local function printSelectedChar(char, x, y, charNumber)
    if highlightedChar == charNumber then
        love.graphics.setColor(103/255, 1, 1, 1)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end
    love.graphics.print(string.char(char), x, y)
end

function EnterHighscoreState:render()
    love.graphics.setFont(gFonts["large"])
    love.graphics.printf("You got a new highscore!", 0, 20, VIRTUAL_WIDTH, "center")
    love.graphics.printf("Your score: " .. tostring(self.score), 0, 60, VIRTUAL_WIDTH, "center")

    love.graphics.setFont(gFonts["large"])
    local offset = 30
    local x = VIRTUAL_WIDTH / 2 - offset
    local y = VIRTUAL_HEIGHT / 2 - offset
    
    printSelectedChar(chars[1], x, y, 1)
    printSelectedChar(chars[2], x + offset, y, 2)
    printSelectedChar(chars[3], x + (offset * 2), y, 3)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(gFonts["small"])
    love.graphics.printf("Press \"Enter\" to confirm...", 0, VIRTUAL_HEIGHT - 30, VIRTUAL_WIDTH, "center")
end