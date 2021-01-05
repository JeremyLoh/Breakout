-- Size of our actual window
WINDOW_WIDTH = 1280 
WINDOW_HEIGHT = 720

-- Size we want to emulate
VIRTUAL_WIDTH = 640
VIRTUAL_HEIGHT = 360

PADDLE_SPEED = 200
TOTAL_BRICK_COLORS = 5
MAX_LIVES = 3
TOTAL_BALL_VARIATIONS = 7
HIGHEST_PADDLE_SKIN = 4
HIGHEST_PADDLE_SIZE = 4
LOWEST_PADDLE_SKIN = 1
LOWEST_PADDLE_SIZE = 1

PADDLE_SIZES = {
    -- small (size 1)
    [1] = {
        ["width"] = 32,
        ["height"] = 16,
    },
    -- medium (size 2)
    [2] = {
        ["width"] = 64,
        ["height"] = 16,
    },
    -- large (size 3)
    [3] = {
        ["width"] = 96,
        ["height"] = 16,
    },
    -- extra-large (size 4)
    [4] = {
        ["width"] = 128,
        ["height"] = 16,
    },
}