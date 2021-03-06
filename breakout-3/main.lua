--[[
    Author: Jeremy Loh
    https://github.com/JeremyLoh

    Originally developed by Atari in 1976. An effective evolution of
    Pong, Breakout ditched the two-player mechanic in favor of a single-
    player game where the player, still controlling a paddle, was tasked
    with eliminating a screen full of differently placed bricks of varying
    values by deflecting a ball back at them.

    Credit for music:
    http://freesound.org/people/joshuaempyre/sounds/251461/
    http://www.soundcloud.com/empyreanma
]]

require "src/Dependencies"

--[[
    Called once at the start of the game
    Used to setup game objects, variables etc.
]]
function love.load()
    -- Initialize our virtual resolution, this will be rendered within our 
    -- actual window regardless of its dimensions
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true,
    })

    love.window.setTitle("Breakout")
    love.graphics.setDefaultFilter("nearest", "nearest")
    math.randomseed(os.time())

    gFonts = {
        ["large"] = love.graphics.newFont("fonts/font.ttf", 32),
        ["medium"] = love.graphics.newFont("fonts/font.ttf", 16),
        ["small"] = love.graphics.newFont("fonts/font.ttf", 8),
    }

    gSounds = {
        ["brick-hit-1"] = love.audio.newSource("sounds/brick-hit-1.wav", "static"),
        ["brick-hit-2"] = love.audio.newSource("sounds/brick-hit-2.wav", "static"),
        ["confirm"] = love.audio.newSource("sounds/confirm.wav", "static"),
        ["highscore"] = love.audio.newSource("sounds/high_score.wav", "static"),
        ["hurt"] = love.audio.newSource("sounds/hurt.wav", "static"),
        ["no-select"] = love.audio.newSource("sounds/no-select.wav", "static"),
        ["paddle-hit"] = love.audio.newSource("sounds/paddle_hit.wav", "static"),
        ["pause"] = love.audio.newSource("sounds/pause.wav", "static"),
        ["recover"] = love.audio.newSource("sounds/recover.wav", "static"),
        ["score"] = love.audio.newSource("sounds/score.wav", "static"),
        ["select"] = love.audio.newSource("sounds/select.wav", "static"),
        ["victory"] = love.audio.newSource("sounds/victory.wav", "static"),
        ["wall-hit"] = love.audio.newSource("sounds/wall_hit.wav", "static"),

        ["music"] = love.audio.newSource("sounds/music.wav", "stream"),
    }

    -- Play game music
    local music = gSounds["music"]
    music:setVolume(0.5)
    music:setLooping(true)
    music:play()

    gGraphics = {
        ["background"] = love.graphics.newImage("graphics/background.png"),
        ["main"] = love.graphics.newImage("graphics/breakout.png"),
        ["arrows"] = love.graphics.newImage("graphics/arrows.png"),
        ["hearts"] = love.graphics.newImage("graphics/hearts.png"),
        ["particle"] = love.graphics.newImage("graphics/particle.png"),
    }
    -- Quads generated from our textures
    gQuadsTable = {
        ["paddles"] = GenerateQuadPaddles(gGraphics["main"]),
        ["balls"] = GenerateQuadBalls(gGraphics["main"]),
        ["bricks"] = GenerateQuadBricks(gGraphics["main"]),
    }

    states = {
        ["start"] = function() return StartState() end,
        ["play"] = function() return PlayState() end,
    }
    gStateMachine = StateMachine(states)
    gStateMachine:change("start")

    -- Keep track of which keys have been pressed
    love.keyboard.keysPressed = {}
end

function love.resize(width, height)
    return push:resize(width, height)
end

function love.keypressed(key, scancode, isrepeat)
    love.keyboard.keysPressed[key] = true
end

--[[
    Custom function that lets us to test for individual keystrokes
    outside of the default `love.keypressed` callback.
]]
function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

--[[
    Called every frame, passing in `dt` (deltatime) since the last frame.
    `dt` is measured in seconds.
    Multiplying `dt` by any changes we wish to make in the game will allow our
    game to perform consistently across all hardware
]]
function love.update(dt)
    gStateMachine:update(dt)
    -- Reset keys pressed
    love.keyboard.keysPressed = {}
end

function love.draw()
    -- Draw in our defined virtual resolution
    push:start()
    local backgroundImage = gGraphics["background"]
    local backgroundWidth = backgroundImage:getWidth()
    local backgroundHeight = backgroundImage:getHeight()
    love.graphics.draw(backgroundImage, 
        0, -- x-axis position 
        0, -- y-axis position
        0, -- orientation (radians)
        VIRTUAL_WIDTH / (backgroundWidth - 1), -- Scale factor (x-axis)
        VIRTUAL_HEIGHT / (backgroundHeight - 1) -- Scale factor (y-axis)
    )
    gStateMachine:render()
    -- Display FPS for debugging; comment out for game release
    displayFPS()
    push:finish()
end

--[[
    Render the current FPS
]]
function displayFPS()
    love.graphics.setFont(gFonts["small"])
    love.graphics.setColor(0, 255/255, 0, 255/255)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 5, 5)
end