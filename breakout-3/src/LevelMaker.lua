--[[
    LevelMaker Class

    Used to create randomized levels by returning a table of bricks that the
    game should render.
]]

LevelMaker = Class{}

function LevelMaker.createMap()
    local brickWidth = 32
    local brickHeight = 16
    local bricks = {}
    local index = 1
    -- Randomly generate rows and columns
    local maxColumns = (VIRTUAL_WIDTH / brickWidth) - 1
    local rows = math.random(3, 6)
    local columns = math.random(5, maxColumns)

    local startMargin = ((VIRTUAL_WIDTH - (maxColumns * brickWidth)) / 2) +
        ((maxColumns - columns) * brickWidth) / 2-- account for lesser columns situation
    local brickColor = 0

    for y = 1, rows do
        for x = 1, columns do
            bricks[index] = Brick(
                (x - 1) * brickWidth +  -- tables are 1 indexed
                startMargin, -- x-coord
                y * brickHeight, -- y-coord, has top padding of brick height 
                brickColor + 1)
            index = index + 1
        end
        brickColor = (brickColor + 1) % TOTAL_BRICK_COLORS
    end  
    
    return bricks
end