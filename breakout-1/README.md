# breakout-1: Quad update

- Add basic play state to the game
- Allow users to pause the game by pressing "spacebar" in the play state
- Implement movement of paddles
- Divide and retrieve paddle based on skin and size in `Paddle.lua` class

## Sprite Sheet

Place all sprites in one single image. Divide and select regions of rectangles (quads) from this sprite sheet when drawing sprites.

The purpose of a Quad is to use a fraction of a texture to draw objects, as opposed to drawing the entire texture.

### Functions used

- `love.graphics.newQuad(x, y, width, height, sw, sh)`

  Specify rectangle boundaries of our Quad and pass in the dimensions (returned via `image:getDimensions` on whatever texture we want to make a Quad for)

  `sw` and `sh` can be passed via `image:getDimensions`

  - `x`: Top left position in the Texture along the x-axis

  - `y`: Top left position in the Texture along the y-axis

  - `width`: Width of the Quad in the Texture (must be greater than 0)

  - `height`: Height of the Quad in the Texture (must be greater than 0)

  - `sw`: Reference width, the width of the Texture (must be greater than 0)

  - `sh`: Reference height, the height of the Texture (must be greater than 0)

- `love.graphics.draw(texture, quad, x, y)`

  Variant of `love.graphics.draw`. We can pass in a Quad to draw just the specific part of the texture, not the entire texture.
