local player = {}

local menu = {
    {label = "Lancer une partie", action = startGame},
    {label = "Paramètres", action = printSettings},
    {label = "Crédits", action = printCredits}
}

local selectedOption = 1
local showSettings = false
local gameStarted = false


function love.keypressed(key)
    if not gameStarted then
        handleMenuInput(key)
    else
        handleGameInput(key)
    end
end

function handleMenuInput(key)
    if not gameStarted then
        print("Menu controls")
        if key == "up" then
            selectedOption = selectedOption - 1
            if selectedOption < 1 then
                selectedOption = #menu
            end
        elseif key == "down" then
            selectedOption = selectedOption + 1
            if selectedOption > #menu then
                selectedOption = 1
            end
        elseif key == "return" then
            if menu[selectedOption] and menu[selectedOption].action then
                menu[selectedOption].action()
            end
        end
    end 
end

function love.resize(w, h)
     -- Mettre à jour les positions des joueurs
     player.posYRight = h / 2 - player.Handing / 2
     player.posYLeft = h / 2 - player.Handing / 2
 
     -- Remettre la balle au centre de l'écran après un redimensionnement
     resetBall()
end

function love.load()
    love.window.setTitle("Mon Super Jeu Pong")
    backgroundImage = love.graphics.newImage("a.png")
    initializeGame()
end

function love.update(dt)
    if gameStarted then
        -- Mouvement des joueurs
        if love.keyboard.isDown("up") and player.posYRight > 0 then
            player.posYRight = player.posYRight - player.speed * dt
        end

        if love.keyboard.isDown("down") and player.posYRight < love.graphics.getHeight() - player.Handing then
            player.posYRight = player.posYRight + player.speed * dt
        end

        if love.keyboard.isDown("z") and player.posYLeft > 0 then
            player.posYLeft = player.posYLeft - player.speed * dt
        end

        if love.keyboard.isDown("s") and player.posYLeft < love.graphics.getHeight() - player.Handing then
            player.posYLeft = player.posYLeft + player.speed * dt
        end

        -- Mouvement de la balle
        ball.posX = ball.posX + ball.speedX * dt
        ball.posY = ball.posY + ball.speedY * dt

        -- Gestion des collisions avec les bords
        if ball.posY <= 0 or ball.posY >= love.graphics.getHeight() then
            ball.speedY = -ball.speedY
        end

        -- Gestion des collisions avec les joueurs
        if ball.posX <= player.posXRight + player.sizeRight and
        ball.posY >= player.posYRight and
        ball.posY <= player.posYRight + player.Handing then
            ball.speedX = -ball.speedX
            accelerateBall()
        end

        if ball.posX >= player.posXLeft - ball.size and
        ball.posY >= player.posYLeft and
        ball.posY <= player.posYLeft + player.Handing then
            ball.speedX = -ball.speedX
            accelerateBall()
        end

        -- Gestion des collisions avec les bords gauche et droit
        if ball.posX <= 0 then
            -- La balle a touché le bord droit, le joueur de gauche marque un point
            scoreLeft = scoreLeft + 1
            resetBall()
        elseif ball.posX >= love.graphics.getWidth() then
            -- La balle a touché le bord gauche, le joueur de droite marque un point
            scoreRight = scoreRight + 1
            resetBall()
        end
    end
end


function drawMenu()
    local menuWidth = love.graphics.getWidth() / 3
    local menuHeight = love.graphics.getHeight() / 3
    local cornerRadius = 5

    for i, option in ipairs(menu) do
        local optionX = (love.graphics.getWidth() - menuWidth) / 2
        local optionY = menuHeight + i * 50

        love.graphics.rectangle("line", optionX - 10, optionY - 5, menuWidth + 20, 30, cornerRadius, cornerRadius)

        local textWidth = love.graphics.getFont():getWidth(option.label)
        local textX = optionX + (menuWidth - textWidth) / 2

        if i == selectedOption then
            love.graphics.setColor(0, 1, 0)  -- Option sélectionnée en vert
        else
            love.graphics.setColor(1, 1, 1)
        end

        love.graphics.print(option.label, textX, optionY)

        love.graphics.setColor(1, 1, 1)
    end
end

function love.draw()
    if not gameStarted then
        love.graphics.draw(backgroundImage, 0, 0, 0, love.graphics.getWidth() / backgroundImage:getWidth(), love.graphics.getHeight() / backgroundImage:getHeight())
        drawMenu()
    else

        -- Afficher le menu normal
       
    
            -- Afficher les paramètres
            local settingsRectX = love.graphics.getWidth() / 4
            local settingsRectY = love.graphics.getHeight() / 4
            local settingsRectWidth = love.graphics.getWidth() / 2
            local settingsRectHeight = love.graphics.getHeight() / 2

            love.graphics.rectangle("fill", settingsRectX, settingsRectY, settingsRectWidth, settingsRectHeight)

            -- Ajoutez vos boutons et éléments spécifiques pour les paramètres ici
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("Bouton 1", settingsRectX + 10, settingsRectY + 10)
            love.graphics.print("Bouton 2", settingsRectX + 10, settingsRectY + 40)
            -- ...

        end
        -- Dessine le reste du jeu
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(15))  -- Utilisez une police de taille 15

        love.graphics.rectangle("fill", player.posXRight, player.posYRight, player.sizeRight, player.Handing, cornerRadius, cornerRadius)
        love.graphics.rectangle("fill", player.posXLeft, player.posYLeft, player.sizeLeft, player.Handing, cornerRadius, cornerRadius)

        love.graphics.circle("fill", ball.posX, ball.posY, ball.size)

        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Score joueur droit: " .. scoreRight, 10, 10)
        love.graphics.print("Score joueur gauche: " .. scoreLeft, love.graphics.getWidth() - 250, 10)

        love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 40)

        local ramUsage = collectgarbage("count") / 1024
        local totalRam = collectgarbage("count", 0) / 1024
        local ramPercentage = (ramUsage / totalRam) * 100
        love.graphics.print(string.format("RAM: %.2f MB (%.2f%%)", ramUsage, ramPercentage), 10, 60)

        love.graphics.print("Resolution: " .. love.graphics.getWidth() .. "x" .. love.graphics.getHeight(), 10, 80)
    end




function resetBall()
    -- Remettre la balle au centre de l'écran
    ball.posX = love.graphics.getWidth() / 2
    ball.posY = love.graphics.getHeight() / 2

    -- Réinitialiser la vitesse de la balle
    ball.speedX = initialSpeedX
    ball.speedY = initialSpeedY
end

function accelerateBall()
    -- Augmenter la vitesse de la balle
    if math.abs(ball.speedX) < maxSpeedX then
        ball.speedX = ball.speedX * 1.1
    end

    if math.abs(ball.speedY) < maxSpeedY then
        ball.speedY = ball.speedY * 1.1
    end
end

function startGame()
    print("La partie est lancée !")
    gameStarted = true
    resetGame()
end

function printSettings()
    print("Ouverture des paramètres...")
end

function printCredits()
    print("Affichage des crédits...")
end


function initializeGame()
    player.Handing = love.graphics.getHeight() / 5
    player.speed = 200
    player.sizeRight = 20
    player.posXRight = 50
    player.posYRight = love.graphics.getHeight() / 2 - player.Handing / 2
    player.sizeLeft = 20
    player.posXLeft = love.graphics.getWidth() - 50 - player.sizeLeft
    player.posYLeft = love.graphics.getHeight() / 2 - player.Handing / 2

    ball = {
        posX = love.graphics.getWidth() / 2,
        posY = love.graphics.getHeight() / 2,
        size = 10,
        speedX = 150,
        speedY = 150
    }

    scoreRight = 0
    scoreLeft = 0
    maxSpeedX = 400
    maxSpeedY = 400
    initialSpeedX = 150
    initialSpeedY = 150
end


function drawMenu()
    local menuWidth = love.graphics.getWidth() / 3
    local menuHeight = love.graphics.getHeight() / 3
    local cornerRadius = 5

    for i, option in ipairs(menu) do
        local optionX = (love.graphics.getWidth() - menuWidth) / 2
        local optionY = menuHeight + i * 50

        love.graphics.rectangle("line", optionX - 10, optionY - 5, menuWidth + 20, 30, cornerRadius, cornerRadius)

        local textWidth = love.graphics.getFont():getWidth(option.label)
        local textX = optionX + (menuWidth - textWidth) / 2

        if i == selectedOption then
            love.graphics.setColor(0, 1, 0)  -- Option sélectionnée en vert
        else
            love.graphics.setColor(1, 1, 1)
        end

        love.graphics.print(option.label, textX, optionY)

        love.graphics.setColor(1, 1, 1)
    end
end