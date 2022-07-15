-- Additional Librarires --
local anim8 = require 'lib.anim8'
local camera = require 'lib.CameraMgr'
local Talkies = require "lib.talkies"
local utils = require 'utils'
local collision = require "collisionSystem"
---------------------------


-- Love Engine Functions --
function love.load()
    -- Initialisation --
    WIDTH = 608
    HEIGHT = 608
    TITLE = "PUZZLE GAME"

    love.window.setTitle(TITLE)
    love.window.setMode(WIDTH, HEIGHT)
    
    -- Collision

    -- Map
    townMap = love.graphics.newImage("assets/townmap.png")
    map_colliders = {b1=collision.createCollider(152, 400, 56, 88),
                    b2=collision.createCollider(328, 401, 56, 88),
                    b3=collision.createCollider(151, 215, 56, 88),
                    b4=collision.createCollider(328, 218, 56, 88),
                    bb=collision.createCollider(218, 18, 104, 72),
                    boat=collision.createCollider(247, 543, 48, 64),
                    hole1=collision.createCollider(72, 224, 40, 48),
                    hole2=collision.createCollider(82, 442, 40, 48),
                    hole3=collision.createCollider(380, 335, 35, 35),
                    hole4=collision.createCollider(435, 218, 40, 56),
                    hole5=collision.createCollider(480, 418, 40, 56)}

    -- Player 
    player = {x = 300, y = 300, w=24, h=24, speed = 150, image = nil, animation = nil, collider = nil, active = true}
    player.collider = collision.createCollider(player.x, player.x, player.w, player.h)
    sheet_path = {down="assets/character_down.png", up="assets/character_up.png", right="assets/character_right.png", left="assets/character_left.png"}
    player = updateAnimation(sheet_path.up, player)
    player.animation:pause()
    animationUpdated = false

     -- Camera
    CM = camera.newManager()
    CM.setScale(1.0) -- Should be set before others (some calls depend on the scale)
    CM.setBounds(-300, -300, WIDTH, 0)
    CM.setDeadzone(-64,-64,64,64)
    CM.setLerp(0.1)
    CM.setOffset(0)
    CM.setCoords(player.x, player.y) -- initial position

    -- dialog
    Talkies.font = love.graphics.newFont("assets/Early GameBoy.ttf", 16)
    Talkies.talkSound = love.audio.newSource("assets/sfx/type.mp3", 'stream')
    Talkies.optionSwitchSound = love.audio.newSource("assets/sfx/switch.mp3", 'stream')
    answered = {q1=false, q2=false, q3=false, q4=false, qb=false}
    score = 0

    -- Sound effects
    correctSFX = love.audio.newSource('assets/sfx/correct.mp3', 'stream')
    wrongSFX = love.audio.newSource('assets/sfx/wrong.mp3', 'stream')
    victorySFX = love.audio.newSource('assets/sfx/Victory.mp3', 'stream')
    victorySFX:setVolume(0.8)
    theme = love.audio.newSource('assets/sfx/theme.mp3', 'stream')
    theme:play()
end

function love.update(dt)
    -- Update --
    if player.active then
        playerMove(dt)
        player.animation:update(dt)
        handleCollision()
    end
    handleQuiz()

    CM.setTarget(player.x, player.y)
    CM.update(dt)

    if not theme:isPlaying() and not victorySFX:isPlaying() then
        theme:play()
    end

    Talkies.update(dt)
end

function love.draw()
    -- Render to the screen -- 
    love.graphics.setBackgroundColor(103/255, 230/255, 210/255)

    CM.attach()
    -- Stuff that is affected by the camera
    love.graphics.draw(townMap, l, t)
    player.animation:draw(player.image, player.x, player.y)
    -- debugCollision() -- FOR DEBUGGING COLLISIONS
    CM.detach()

    Talkies.draw()

    love.graphics.setFont(love.graphics.newFont("assets/Early GameBoy.ttf", 24))
    love.graphics.print("Current Score:" .. tostring(score), 8, 8)
end

function love.keypressed(key)
    if player.active then 
        if key == "c" then Talkies.clearMessages()
        elseif key == "space" then Talkies.onAction()
        elseif key == "z" then Talkies.prevOption()
        elseif key == "s" then Talkies.nextOption()
        elseif key == "escape" then love.event.quit()
        end
    end
end

function love.keyreleased(k)
    animationUpdated = false
    player.animation:pause()
end
---------------------------


-- Additional Functions --
function playerMove(dt)
    local velocity = {x= 0, y= 0}
    if love.keyboard.isDown("left") then
        if player.x > 40 then
            if not animationUpdated then
                player = updateAnimation(sheet_path.left, player)
                animationUpdated = true
            end
            velocity.x = velocity.x - 1
        end
    end
    if love.keyboard.isDown("right") then
        if player.x < WIDTH - 60 then
            if not animationUpdated then
                player = updateAnimation(sheet_path.right, player)
                animationUpdated = true
            end
            velocity.x = velocity.x + 1
        end
    end
    if love.keyboard.isDown("up") then
        if player.y > 40 then
            if not animationUpdated then
                player = updateAnimation(sheet_path.up, player)
                animationUpdated = true
            end
            velocity.y = velocity.y - 1
        end
    end
    if love.keyboard.isDown("down") then
        if player.y < HEIGHT - 80 then
            if not animationUpdated then
                player = updateAnimation(sheet_path.down, player)
                animationUpdated = true
            end
            velocity.y = velocity.y + 1
        end
    end

    velocity = utils.normalize(velocity.x, velocity.y)

    player.x = player.x + velocity.x * player.speed * dt
    player.y = player.y + velocity.y * player.speed * dt
end

function updateAnimation(path, player) 
    player.image = love.graphics.newImage(path)
    local g = anim8.newGrid(24, 24, player.image:getWidth(), player.image:getHeight())
    player.animation  = anim8.newAnimation(g("1-4", 1), 0.1)
    return player
end

function handleCollision()
    player.collider = collision.createCollider(player.x, player.y, player.w, player.h)
    for key, collider in pairs(map_colliders) do
        if collision.AABBCollision(player.collider, collider) then
            result = collision.getCollisionDir(player.collider, collider) 
            if result == "right" then 
                player.x = player.x + 5
            elseif result == "left" then
                player.x = player.x - 5
            elseif result == "top" then
                player.y = player.y - 5
            elseif result == "bottom" then
                player.y = player.y + 5
            end
        end
    end
end

function processAnswer(state, id)
    if state then
        love.audio.play(correctSFX)
        score = score + 1
    else
        love.audio.play(wrongSFX)
        score = score - 1
    end
    if id == 1 then answered.q1 = state
    elseif id == 2 then answered.q2 = state
    elseif id == 3 then answered.q3 = state
    elseif id == 4 then answered.q4 = state
    elseif id == 5 then answered.qb = state
    end
    Talkies.clearMessages()
end

function handleQuiz()
    if love.keyboard.isDown("return") and collision.AABBCollision(player.collider, map_colliders.b1) and not answered.q1 then
        Talkies.say(
            "Entomology",
            "Entomology is the science that studies",
            {
                options={
                    {"A. Behavior of human beings", function() processAnswer(false, 1) end},
                    {"B. Insects", function() processAnswer(true, 1) end},
                    {"C. The origin and history of technical and scientific terms", function() processAnswer(false, 1) end},
                    {"B. The formation of rocks", function() processAnswer(false, 1) end},
                }
            }
        )
    end
    if love.keyboard.isDown("return") and collision.AABBCollision(player.collider, map_colliders.b2) and not answered.q2 then
        Talkies.say(
            "Nobel Prize",
            "For which of the following disciplines is Nobel Prize awarded?",
            {
                options={
                    {"A. Physics and Chemistry", function() processAnswer(false, 2) end},
                    {"B. Physiology or Medicine", function() processAnswer(false, 2) end},
                    {"C. Literature, Peace and Economics", function() processAnswer(false, 2) end},
                    {"D. All of the above", function() processAnswer(true, 2) end},
                }
            }
        )
    end
    if love.keyboard.isDown("return") and collision.AABBCollision(player.collider, map_colliders.b3) and not answered.q3 then
        Talkies.say(
            "Hitler party",
            "Hitler party which came into power in 1933 is known as",
            {
                options={
                    {"A. Labour Party", function() processAnswer(false, 3) end},
                    {"B. Nazi Party", function() processAnswer(true, 3) end},
                    {"C. Klu-Klux-Klan", function() processAnswer(false, 3) end},
                    {"D. Democratic Party", function() processAnswer(true, 3) end},
                }
            }
        )
    end
    if love.keyboard.isDown("return") and collision.AABBCollision(player.collider, map_colliders.b4) and not answered.q4 then
        Talkies.say(
            "Friction",
            "Friction can be reduced by changing from",
            {
                options={
                    {"A. sliding to rolling", function() processAnswer(true, 4) end},
                    {"B. rolling to sliding", function() processAnswer(false, 4) end},
                    {"C. potential energy to kinetic energy", function() processAnswer(false, 4) end},
                    {"D. dynamic to static", function() processAnswer(false, 4) end},
                }
            }
        )
    end 
    if love.keyboard.isDown("return") and collision.AABBCollision(player.collider, map_colliders.bb) and not answered.q5 then
        if answered.q1 and answered.q2 and answered.q3 and answered.q4 then
        Talkies.say(
            "Religion",
            "Fire temple is the place of worship of which of the following religion?",
            {
                options={
                    {"A. Taoism", function() processAnswer(false, 5) end},
                    {"B. Judaism", function() processAnswer(false, 5) end},
                    {"C. Zoroastrianism (Parsi Religion)", function() processAnswer(true, 5) end},
                    {"D. Shintoism", function() processAnswer(false, 5) end},
                }
            }
        )
        else 
        Talkies.say(
            "BLOCKED",
            "You must answer the other questions in order to access this final one..."
        )
        end 
    end
    if love.keyboard.isDown("return") and collision.AABBCollision(player.collider, map_colliders.boat) then
        if answered.q1 and answered.q2 and answered.q3 and answered.q4 and answered.qb then
        Talkies.say(
            "VICTORY",
            "You managed to escape your score is: " .. tostring(score) .. "Points!"
        )
        player.active = false
        theme:stop()
        love.audio.play(victorySFX)
        else 
        Talkies.say(
            "BLOCKED",
            "In order to escape this island answer all the questions proposed by the houses."
        )
        end 
    end
end


function debugCollision()
    collision.drawCollider(player.collider)
    for key, collider in pairs(map_colliders) do
        collision.drawCollider(collider)
    end
end
---------------------------

