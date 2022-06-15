Ball = Class{}

--Constructor function, aka init function
function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    --Kepp track of ball velocity on both X and Y axis
    self.dy = math.random(2) == 1 and -100 or 100
    self.dx = math.random(2) == 1 and math.random(-80, -100) or math.random(80, 100)
end

--resets the ball
function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    self.dy = math.random(2) == 1 and -100 or 100
    self.dx = math.random(-50, 50)
end

--Applies velocity to position, scaled by DeltaTime
function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end
--Check every frame if the ball collides with the paddles
function Ball:collides(paddle)
    --first check if left edge of either objects is farther to the right than the right edge of the other
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end
    --then check to see if the bottom edge of either objects is higher than the top edge of the other
    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end
    --if neither of these conditions are true, then the ball is colliding
    return true
end

--Renders the ball
function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end