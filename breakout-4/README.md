# breakout-4: Collision update

This updates adds the following:

1. Paddle Collision update
1. Brick Collision (Simple)

## Paddle Collision update

1. Take the difference between the ball's x and the paddle's center (diff = paddle.x + paddle.width / 2 - ball.x) and scale the ball's dx appropriately.
1. If the ball is on the left side of the paddle's center, the difference will be positive. For this case, we scale the ball's dx by `ball.dx = ball.dx * -diff * dt` if the paddle is moving to the left (paddle.dx < 0) and the ball is moving to the left (ball.dx < 0)
1. If the ball is on the right side of the paddle's center, the difference will be negative. For this case, we scale the ball's dx by `ball.dx = ball.dx * diff * dt` if the paddle is moving to the right (paddle.dx > 0) and the ball is moving to the right (ball.dx > 0)

`PlayState.lua` changes:

```Lua
function PlayState:checkPaddleCollision(dt)
    -- Check ball collision with paddle
    if self.ball:collides(self.paddle) then
        -- Update ball dx if the paddle is moving in same direction as ball
        -- during collision
        -- Find difference between paddle's center and the ball
        local paddleCenter = self.paddle.x + (self.paddle.width / 2)
        local difference = paddleCenter - self.ball.x
        local factor = 100
        local startDx = 50
        if difference > 0 and self.paddle.dx < 0 and self.ball.dx < 0 then
            -- left side collision, paddle moving left
            self.ball.dx = -(startDx + (dt * difference * factor))
        elseif difference < 0 and self.paddle.dx > 0 and self.ball.dx > 0 then
            -- right side collision, paddle moving right
            self.ball.dx = startDx + (dt * math.abs(difference) * factor)
        end

        -- Move ball out of paddle
        self.ball.y = self.paddle.y - self.ball.height
        -- Reverse Y direction
        self.ball.dy = -self.ball.dy
        gSounds["paddle-hit"]:play()
    end
end

function PlayState:update(dt)
    -- ...
    if not self.paused then
        self.paddle:update(dt)
        self.ball:update(dt)
        self:checkPaddleCollision(dt)
        self:checkBricksCollision(dt)
    end
    end
end
```

## Brick Collision (Simple)

Brick collision with the ball (top, left, right, down)

If the left edge of ball is outside the left edge of the brick and ball dx is positive (going right), we have a **left side collision**

If the right side of ball is outside the right edge of the brick and ball dx is negative (going left), we have a **right side collision**

If the top edge of the ball is outside the top edge of the brick and ball dy is positive, we have a **top side collision**

If the bottom edge of the ball is outside the bottom edge of the brick and ball dx is negative, we have a **bottom side collision**

Collision Alternative way (better)

1. https://github.com/noooway/love2d_arkanoid_tutorial

`PlayState.lua` changes:

```Lua
function PlayState:checkBricksCollision(dt)
    -- Check ball collision with bricks
    for key, brick in pairs(self.bricks) do
        if brick:isCurrentlyActive() and self.ball:collides(brick) then
            brick:hit()
            local ballMovingRight = self.ball.dx > 0
            local ballMovingLeft = self.ball.dx < 0
            local ballMovingDown = self.ball.dy > 0
            local ballMovingUp = self.ball.dy < 0
            -- Offset checked value to fix corner collision detection
            local offset = 2

            -- Check side of brick that collides with ball
            if self.ball.x + offset < brick.x and ballMovingRight then
                -- Left side collision
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x - self.ball.width
            elseif (self.ball.x + self.ball.width - offset) > (brick.x + brick.width)
                and ballMovingLeft then
                -- Right side collision
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x + brick.width
            elseif self.ball.y < brick.y and ballMovingDown then
                -- Top side collision
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y - self.ball.height
            elseif (self.ball.y + self.ball.height) > brick.y + brick.height
                and ballMovingUp then
                -- Bottom side collision
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y + brick.height
            end

            -- Slightly increase y velocity to speed up the game
            self.ball.dy = self.ball.dy * 1.02
        end
    end
end
```
