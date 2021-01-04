-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
--
-- https://github.com/Ulydev/push
push = require "lib/push"

-- the "Class" library allows us to represent anything in
-- our game as code, rather than keeping track of many
-- variables and methods
--
-- https://github.com/vrld/hump/blob/master/class.lua
Class = require "lib/class"

-- Import global constants
require "src/constants"

-- Utility function, mainly used for splitting sprite sheet (atlas) 
-- into various Quads of different sizes 
require "src/Util"

require "src/Paddle"
require "src/Ball"
require "src/Brick"
require "src/LevelMaker"

require "src/StateMachine"
require "src/states/BaseState"
require "src/states/StartState"
require "src/states/PlayState"
require "src/states/ServeState"
require "src/states/VictoryState"
require "src/states/GameOverState"
require "src/states/HighscoreState"