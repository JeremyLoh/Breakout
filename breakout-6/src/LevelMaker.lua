--[[
    LevelMaker Class

    Used to create randomized levels by returning a table of bricks that the
    game should render.
]]

LevelMaker = Class{}

-- Global patterns (make map a certain shape)
NONE = 1
SINGLE_PYRAMID = 2
MULTI_PYRAMID = 3

-- Per Row Patterns
SOLID = 1       -- same colors for entire row
ALTERNATE = 2   -- alternate brick colors
SKIP = 3        -- skip every other brick
NONE = 4        -- no bricks on row

function LevelMaker.createMap(level)
    local brickWidth = 32
    local brickHeight = 16
    local bricks = {}
    local index = 1
    -- Randomly generate rows and columns
    local maxColumns = (VIRTUAL_WIDTH / brickWidth) - 1
    maxColumns = maxColumns % 2 == 0 and maxColumns - 1 or maxColumns
    local rows = math.random(3, 6)
    -- Columns need to be odd (for symmetry)
    local columns = math.random(7, maxColumns)
    columns = columns % 2 == 0 and (columns + 1) or columns
    -- Determine left margin before first brick
    local startMargin = (VIRTUAL_WIDTH - (maxColumns * brickWidth)) / 2 + 
        ((maxColumns - columns) * brickWidth) / 2 -- account for lesser columns situation
    
    -- Obtain max color and max variation of brick
    local maxVariation = math.min(4, math.floor(level / 5))
    local maxColor = math.min(5, level % 5 + 3)

    local index = 1

    for y = 1, rows do
        local rowAlternativeColorBrick = math.random(1, 2) == 1 and true or false
        local rowSkipBrickPattern = math.random(1, 2) == 1 and true or false

        -- Create alternative colors and variations
        local alternativeColor1 = math.random(1, maxColor)
        local alternativeColor2 = math.random(1, maxColor)
        local alternativeVariation1 = math.random(1, maxVariation)
        local alternativeVariation2 = math.random(1, maxVariation)
        -- Create solid color bricks
        local solidColor = math.random(1, maxColor)
        local solidVariation = math.random(1, maxVariation)

        -- Flag for skipping or alternative current brick
        local skipCurrentBrickFlag = math.random(1, 2) == 1 and true or false
        local alternateCurrentBrickFlag = math.random(1, 2) == 1 and true or false

        for x = 1, columns do
            if skipCurrentBrickFlag and rowSkipBrickPattern then
                skipCurrentBrickFlag = not skipCurrentBrickFlag
                goto continue
            else
                -- Maintain skip order for row iteration that skip is not used
                skipCurrentBrickFlag = not skipCurrentBrickFlag
            end

            local color = solidColor
            local variation = solidVariation

            if alternateCurrentBrickFlag and rowAlternativeColorBrick then
                color = alternativeColor1
                variation = alternativeVariation1
                alternateCurrentBrickFlag = not alternateCurrentBrickFlag
            else
                color = alternativeColor2
                variation = alternativeVariation2
                alternateCurrentBrickFlag = not alternateCurrentBrickFlag
            end

            local brick = Brick((x - 1) * brickWidth + startMargin, -- x coord 
                y * brickHeight, -- y coord
                color, 
                variation) 
            
            bricks[index] = brick
            index = index + 1
            -- Lua's version of the 'continue' statement
            ::continue::
        end
    end

    if #bricks == 0 then
        return self.createMap(level)
    end

    return bricks
end