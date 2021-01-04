# breakout-10: High Scores Update

Add highscore listing for the game, saved in a local file (`highscores.lst`) using `love.filesystem`.

The highscores file (`highscore.lst`) contains the top 10 highscores and the file has the following format for each highscore entry:

- `name`
- `score`

https://love2d.org/wiki/love.filesystem

Add ability to save highscore locally after player receives a game over screen (if score is a highscore).

## Functions Used

`love.filesystem.setIdentity(identity)`

1. Sets the active subfolder in the default LOVE save directory for reading and writing files to

`love.filesystem.getInfo(path, filtertype)`

1. Gets information about the specified file or directory. Returns a table containing information about the specified path, or `nil` if nothing exists at the path

`love.filesystem.write(path, data)`

1. Writes `data`, as a string, to the file location at `path`

`love.filesystem.lines(path)`

1. Returns an iterator over the string lines in a file at `path`, located in our active identity path

## `HighscoreState.lua`

```Lua
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
        if string.upper(name) == "NIL" then
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
```

## `main.lua` changes

```Lua
function love.load()
    -- ...
    -- Load highscores
    highscores = getSavedHighscores()
end

function getSavedHighscores()
    local highscores = {}
    for i = 1, 10 do
        highscores[i] = {
            ["name"] = nil,
            ["score"] = nil,
        }
    end
    love.filesystem.setIdentity("breakout")
    local highscoreFileExists = love.filesystem.getInfo("highscores.lst", "file")
    if highscoreFileExists then
        local isName = true
        local index = 1
        for line in love.filesystem.lines("highscores.lst") do
            if isName then
                highscores[index]["name"] = string.sub(line, 1, 3)
            else
                highscores[index]["score"] = tonumber(line)
                index = index + 1
            end
            isName = not isName
        end
    else
        -- Create highscores file
        local values = ""
        for i = 1, 10 do
            local name = "NIL\n"
            local score = "0\n"
            values = values .. name .. score
        end
        love.filesystem.write("highscores.lst", values)
    end

    return highscores
end
```

## `StartState.lua` changes

```Lua
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
                ["level"] = 1,
            })
        elseif selectedOption == 2 then
            -- Highscores
            gStateMachine:change("highscores", {
                ["highscores"] = highscores
            })
        end
    elseif love.keyboard.wasPressed("escape") then
        love.event.quit()
    end
end
```

## `EnterHighscoreState.lua`

```Lua
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
```

## `GameOverState.lua` changes

```Lua
local INVALID_INDEX = -1

function GameOverState:update(dt)
    if love.keyboard.wasPressed("enter") or love.keyboard.wasPressed("return") then
        -- Check for highscore
        local index = INVALID_INDEX
        for i = 1, 10 do
            if highscores[i]["score"] <= self.score then
                index = i
                break
            end
        end

        if index ~= INVALID_INDEX then
            gSounds["highscore"]:play()
            gStateMachine:change("enter-highscores", {
                ["score"] = self.score,
                ["score-index"] = index,
            })
        else
            gStateMachine:change("start")
        end
    elseif love.keyboard.wasPressed("escape") then
        love.event.quit()
    end
end
```
