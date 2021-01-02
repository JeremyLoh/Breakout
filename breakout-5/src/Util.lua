--[[
    Given an atlas (texture with multiple sprites), width and height of
    the tiles, split the texture into Quads by dividing it evenly
]]

function generateQuads(atlas, tileWidth, tileHeight)
    -- Lua index starts from 1
    local quadIndex = 1
    local quadsheet = {}

    local cols = atlas:getWidth() / tileWidth
    local rows = atlas:getHeight() / tileHeight

    -- Generate quads row by row, left to right
    -- for init, max/min value, increment
    for y = 0, rows - 1, 1 do
        for x = 0, cols - 1, 1 do
            quadsheet[quadIndex] = love.graphics.newQuad(
                x * tileWidth, -- x
                y * tileHeight, -- y
                tileWidth, -- quad width
                tileHeight, -- quad height
                atlas:getDimensions())
            quadIndex = quadIndex + 1
        end
    end

    return quadsheet
end

--[[
    Create own slice operation for tables

    Takes in a table, first index, last index, step/increment
    Index are 1 based (start from 1)
]]
function table.slice(tbl, first, last, step)
    local output = {}
    -- #[TABLE_NAME] gives the size of the table
    for i = first or 1, last or #tbl, step or 1 do
        output[#output + 1] = tbl[i]
    end
    return output
end

--[[
    Function is specifically made to piece out the paddles in the spritesheet.
    For the atlas (spritesheet) stored in `blocks.png`,
    The paddles have 4 sizes (w x h) starting at (0, 64): 
    small (32 x 16), medium (64 x 16), large (96 x 16), extra-large (128 x 16)
    They start from (x, y) of (0, 64)
]]
function GenerateQuadPaddles(atlas)
    local x = 0
    local y = 64

    paddles = {}
    index = 1

    for i = 0, 3 do
        -- Small paddle
        paddles[index] = love.graphics.newQuad(x, y, 32, 16, atlas:getDimensions())
        index = index + 1

        -- Medium paddle
        paddles[index] = love.graphics.newQuad(x + 32, y, 64, 16, atlas:getDimensions())
        index = index + 1
        
        -- Large paddle
        paddles[index] = love.graphics.newQuad(x + 32 + 64, y, 96, 16, atlas:getDimensions())
        index = index + 1
        
        -- Extra large paddle (next row)
        x = 0
        paddles[index] = love.graphics.newQuad(x, y + 16, 128, 16, atlas:getDimensions())
        index = index + 1

        -- For next set of paddles
        x = 0
        y = y + 32
    end

    return paddles
end

--[[
    Function to obtain ball sprites from "breakout.png"
    Each ball is 8px by 8px
    The first row has 4 balls and the second row has 3 balls
]]
function GenerateQuadBalls(atlas)
    local x = 96
    local y = 48
    local ballWidth = 8
    local ballHeight = 8

    balls = {}
    index = 1

    -- Get balls on first row
    for i = 1, 4 do
        balls[index] = love.graphics.newQuad(x, y, ballWidth, ballHeight, atlas:getDimensions())
        index = index + 1
        x = x + 8
    end

    -- Get balls on second row
    x = 96
    y = 56
    for i = 1, 3 do
        balls[index] = love.graphics.newQuad(x, y, ballWidth, ballHeight, atlas:getDimensions())
        index = index + 1
    end

    return balls
end

--[[
    Generate quad bricks based on "breakout.png"
    There are a total of 4 rows of bricks.
    There are 6 bricks for row of the first 3 rows. 
    The 4th row has 3 bricks.
    Each brick is 32px x 16px (width x height).
]]
function GenerateQuadBricks(atlas)
    local tileWidth = 32
    local tileHeight = 16
    local allQuads = generateQuads(atlas, tileWidth, tileHeight)

    return table.slice(allQuads, 1, 21, 1)
end

--[[
    Function to draw player lives
]]
function drawPlayerLives(lives)
    local filledHeart = gQuadsTable["hearts"][1]
    local emptyHeart = gQuadsTable["hearts"][2]
    local texture = gGraphics["hearts"]
    local heartWidth = texture:getWidth() / 2
    local x = VIRTUAL_WIDTH - (MAX_LIVES * heartWidth)

    for i = 1, lives do
        love.graphics.draw(texture, filledHeart, x, 0)
        x = x + heartWidth
    end

    for i = 1, MAX_LIVES - lives do
        love.graphics.draw(texture, emptyHeart, x, 0)
        x = x + heartWidth
    end
end

--[[
    Function to draw player score
]]
function drawPlayerScore(score)
    local x = 16
    local y = VIRTUAL_HEIGHT - 20
    local limit = VIRTUAL_WIDTH / 10
    love.graphics.setFont(gFonts["medium"])
    love.graphics.printf(tostring(score), x, y, limit, "left")
end