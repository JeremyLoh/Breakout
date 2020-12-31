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
    for (i = first or 1), (last or #tbl), (step or 1) do
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
    atlasDimensions = atlas:getDimensions()

    for i = 0, 3 do
        -- Small paddle
        paddles[index] = love.graphics.newQuad(x, y, 32, 16, atlasDimensions)
        index = index + 1

        -- Medium paddle
        paddles[index] = love.graphics.newQuad(x + 32, y, 64, 16, atlasDimensions)
        index = index + 1
        
        -- Large paddle
        paddles[index] = love.graphics.newQuad(x + 32 + 64, y, 96, 16, atlasDimensions)
        index = index + 1
        
        -- Extra large paddle (next row)
        x = 0
        paddles[index] = love.graphics.newQuad(x, y + 16, 128, 16, atlasDimensions)
        index = index + 1

        -- For next set of paddles
        x = 0
        y = y + 32
    end

    return paddles
end