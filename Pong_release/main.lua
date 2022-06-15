--Simple Pong game. Based on CS50's Introduction to Game development
--https://www.edx.org/course/cs50s-introduction-to-game-development
--By EMPDorna

--push library
-- https://github.com/Ulydev/push
push = require 'push'

--class library
--https://github.com/vrld/hump/blob/master/class.lua
Class = require 'class'

require 'Paddle'
require 'Ball'
--window size that will be rendering (720 is standard to most computers so higher values is not recomended)
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
--virtual size, if size is lower than window size will scale the screen
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243
--speed that the paddles will move
PADDLE_SPEED = 200
--function to initialize values before running the program. This function is called once
function love.load()
    --smotthness filter. Nearest is no filter, for pixelated games
    love.graphics.setDefaultFilter("nearest", "nearest")
    --gives math a seed for randomness. And os time is the current time of the system
    --Used like that because everytime the game starts, th os time will be different, so the seed will be always random
    math.randomseed(os.time())
    --Set window tittle
    love.window.setTitle('Pong')
    --this is the font configuration for the game
    smallFont = love.graphics.newFont('font.ttf', 8)
    --this is the font for the score system
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    --set the whole program's font as this
    love.graphics.setFont(smallFont)

    --initialize sounds as a table or array

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', "static"),
        ['score'] = love.audio.newSource('sounds/score.wav', "static"),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', "static")
    }

    --Initialize LOVE2D with virtual resolution. First 2 values are the game resolution, and last 2 are window resolution (If not fullscreen)
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,{
        fullscreen = false, --Windowed Mode if false. fullscreenif true
        resizable = true, --Cannot resize window if false
        vsync = true --Synchronize framerate to monitor refresh rate
    })

    servingPlayer = 1

    player1Score = 0
    player2Score = 0

    --Initialize player paddles, Make them global so they can be detected by other functions and modules
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
    --initialize ball in the center
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
    --Game state used to transition between different parts of the game
    gamestate = 'start'
end

--resizes the window
function love.resize(w, h)
    push:resize(w, h)    
end

--Update funcion for LOVE2D. Updates every frame. receives DeltaTime (dt) which is the lapse of time that passes between one frame and another, usually milliseconds
function love.update(dt)

    if gamestate == 'serve' then
        -- before switching to play, initialize ball's velocity based
        -- on player who last scored
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    elseif gamestate == 'play' then
            --If the ball detects collision, they movement will be reversed and slightly increases speed, to spice up the game :)
            if ball:collides(player1) then
                ball.dx = -ball.dx * 1.03
                ball.x = player1.x + 5
                if ball.dy < 0 then
                    ball.dy = -math.random(10, 150)
                else
                    ball.dy = math.random(10, 150)
                end
                --plays paddle hit sound
                sounds['paddle_hit']:play()
            end
            --same operation but with right paddle (Player 2)
            if ball:collides(player2) then
                ball.dx = -ball.dx * 1.03
                ball.x = player2.x - 4
                if ball.dy < 0 then
                    ball.dy = -math.random(10, 150)
                else
                    ball.dy = math.random(10, 150)
                end
                sounds['paddle_hit']:play()
            end
            --detect upper screen boundary and reverse the direction in the y axis
            if ball.y <= 0 then
                ball.y = 0
                ball.dy = -ball.dy
                --plays wall hit sound
                sounds['wall_hit']:play()
            end
    
            --detect lower screen boundary and reverse the direction in the y axis
            if ball.y >= VIRTUAL_HEIGHT - 4 then
                ball.y = VIRTUAL_HEIGHT - 4
                ball.dy = -ball.dy
                sounds['wall_hit']:play()
            end
    --if we reach either side of the screen, resets ball and update the score
        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            --plays score sound
            sounds['score']:play()
            --if reached score of 10, the game is over
            --set the game to done to show a victory message
            if player2Score == 10 then
                winningPlayer = 2
                gamestate = 'done'
            else
                gamestate = 'serve'
                ball:reset()
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()
            --same as above but with player 1
            if player1Score == 10 then
                winningPlayer = 1
                gamestate = 'done'
            else
                gamestate = 'serve'
                ball:reset()
            end
        end
    end

    --player 1 movement
    --Math max and min prevents the paddles to stranding out the screen
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end
    
    --player 2 movement
    if  love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end
    
    --if play state then move ball
    if gamestate == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end

--Generic function for key pressing. Receives the key that you pressed and calls the function every frame
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit() --This exits the game if ESC key is pressed
    --If press enter or return button, the game will either start or reset
    elseif key == 'enter' or key == 'return' then
        if gamestate == 'start' then
            gamestate = 'serve'
        elseif gamestate == 'serve' then
            gamestate = 'play'
        elseif gamestate == 'done' then
            --game simply restarts here
            --set the server phase to the opponent for fairness
            gamestate = 'serve'
            --resets the ball so there's no issues
            ball:reset()

            --resets scores to 0
            player1Score = 0
            player2Score = 0

            --decide who will serve
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end
--Main graphics function. Draws the GUI of the program
function love.draw()
    push:apply('start') --Begins rendering at virtual resolution
    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255) --Clears the screen with an specific color (Since Verison 11 and above values are 0 - 1 instead of 0 - 255)
    love.graphics.setFont(smallFont)
     --Set the next texts in that font
    if gamestate == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('hello pong! Press Enter to Start', 0, 10, VIRTUAL_WIDTH, "center")
    elseif gamestate == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s Serve!", 0 ,10, VIRTUAL_WIDTH, "center")
    elseif gamestate == 'play' then
       --No messages in play state 
    elseif gamestate == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!', 0, 10, VIRTUAL_WIDTH, "center")
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, "center")
    end
        
    displayScore()
    --left paddle
    player1:render()
    --righr paddle
    player2:render()
    --ball
    ball:render()
    displayFPS()
    push:apply('end') --End rendering at virtual resolution
end
--Prints the FPS in screen
function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function displayScore()
    --draw the player's score on left and right side of the screen
    --need to switch font before displaying it
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end