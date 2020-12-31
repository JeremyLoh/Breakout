# breakout-0: Day 0 update

In this update, the following has been added:

- Main title game screen has been created
- Background music
- Selection text for title screen (currently only used for navigation with up and down arrow keys, does not fully work yet)
- Initialization of global variables
- Basic state machine

## Project Organization

We have the following project directory structure:

- fonts/
- lib/
- sounds/
- src
  - states
    - BaseState.lua
    - StartState.lua
    - ...
  - constants.lua
  - Dependencies.lua
  - StateMachine.lua
- main.lua

Most of the global variables have been placed in `constants.lua`. The other relevant global variables have been initialized in the `love.load()` function and are named starting with a `g` (e.g. `gStateMachine` indicates a global state machine)
