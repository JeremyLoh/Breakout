PaddleSelectState = Class{__includes = BaseState}

function PaddleSelectState:init()
    -- Color of paddle
    self.skin = 1
    -- Paddle size (small (1), medium (2), large (3), extra-large (4))
    self.size = 1
end

function PaddleSelectState:update(dt)
    if love.keyboard.wasPressed("enter") or love.keyboard.wasPressed("return") then
        gStateMachine:change("serve", {
            ["paddle"] = Paddle(self.skin, self.size),
            ["bricks"] = LevelMaker.createMap(1),
            ["ball"] = Ball(1),
            ["lives"] = MAX_LIVES,
            ["score"] = 0,
            ["level"] = 1,
        })
    elseif love.keyboard.wasPressed("escape") then
        gStateMachine:change("start")
    elseif love.keyboard.wasPressed("left") then
        if self.skin == LOWEST_PADDLE_SKIN and self.size == LOWEST_PADDLE_SIZE then
            gSounds["no-select"]:play()
        else
            gSounds["select"]:play()
            self.size = self.size - 1
            if self.size < 1 then
                self.skin = self.skin - 1
                self.size = HIGHEST_PADDLE_SIZE
            end
        end
    elseif love.keyboard.wasPressed("right") then
        if self.skin == HIGHEST_PADDLE_SKIN and self.size == HIGHEST_PADDLE_SIZE then
            gSounds["no-select"]:play()
        else
            gSounds["select"]:play()
            self.size = self.size + 1
            if self.size > 4 then
                self.size = LOWEST_PADDLE_SIZE
                self.skin = self.skin + 1
            end
        end
    end
end

function PaddleSelectState:render()
    love.graphics.setFont(gFonts["medium"])
    love.graphics.printf("Select your paddle with the left and right arrow keys", 0, 20, VIRTUAL_WIDTH, "center")
    love.graphics.setFont(gFonts["small"])
    love.graphics.printf("Press \"Enter\" to continue", 0, 40, VIRTUAL_WIDTH, "center")
    
    local arrowHeight = gGraphics["arrows"]:getHeight()
    local arrowWidth = gGraphics["arrows"]:getWidth()
    local arrowX = (VIRTUAL_WIDTH / 3) - (arrowWidth / 2)
    local arrowY = (VIRTUAL_HEIGHT / 2) - (arrowHeight / 2) 
    local rightArrowOffset = (VIRTUAL_WIDTH / 2 - arrowX) - arrowWidth / 2 

    -- Left select arrow
    if self.skin == LOWEST_PADDLE_SKIN and self.size == LOWEST_PADDLE_SIZE then
        -- Give grey tint to indicate no further selection possible
        love.graphics.setColor(40/255, 40/255, 40/255, 128/255)
    else
        -- Reset drawing color to full white for proper rendering
        love.graphics.setColor(1, 1, 1, 1)
    end
    love.graphics.draw(gGraphics["arrows"], gQuadsTable["arrows"][1], arrowX, arrowY)

    -- Right select arrow
    if self.skin == HIGHEST_PADDLE_SKIN and self.size == HIGHEST_PADDLE_SIZE then
        -- Give grey tint to indicate no further selection possible
        love.graphics.setColor(40/255, 40/255, 40/255, 128/255)
    else
        -- Reset drawing color to full white for proper rendering
        love.graphics.setColor(1, 1, 1, 1)
    end
    love.graphics.draw(gGraphics["arrows"], gQuadsTable["arrows"][2],
        (VIRTUAL_WIDTH / 2) + rightArrowOffset, arrowY)

    -- Reset drawing color to full white for proper rendering
    love.graphics.setColor(1, 1, 1, 1)
    -- Draw paddle
    local paddleWidth = PADDLE_SIZES[self.size]["width"]
    local paddleHeight = PADDLE_SIZES[self.size]["height"]
    love.graphics.draw(gGraphics["main"], 
        gQuadsTable["paddles"][(self.skin - 1) * 4 + self.size],
        VIRTUAL_WIDTH / 2 - paddleWidth / 2,
        VIRTUAL_HEIGHT / 2 - paddleHeight / 2)
end