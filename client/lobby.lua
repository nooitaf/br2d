lobby = {}

function lobby.load()
  lobby.timer = 0
  lobby.timerStart = 10
  lobby.active = false
  lobby.showOverlay = false
end

function lobby.draw()
  if lobby.showOverlay then
    love.graphics.setColor(0,0,0,100)
    love.graphics.rectangle("fill", 0,0,love.graphics.getWidth(),love.graphics.getHeight() )
    print(lobby.showOverlay)
    local i = 0
    for k,p in pairs( players ) do
      print(k)
      love.graphics.setColor(255,255,0)
      love.graphics.printf(k,5,i*12 + 20,love.graphics.getWidth(),"left")
      i = i + 1
    end
  end
  love.graphics.setColor(255,255,0)
  love.graphics.printf(math.floor(lobby.timer),0,12,love.graphics.getWidth(),"right")
end

function lobby.update(dt)
  if lobby.active then
    lobby.timer = lobby.timer - dt
    if lobby.timer <= 0 then
      lobby.active = false
      startGame()
    end
  end
end

function lobby.start()
  lobby.timer = lobby.timerStart
  lobby.active = true
  for uid,v in pairs( players ) do
    players[uid].health = 100
    players[uid].dead = false
    players[uid].inLobby = true
    players[uid].inPlane = false
    Net:send({},"startLobby",nil,uid)
  end
end

function lobby.keypressed(key)
  if key == "tab" then
    if lobby.showOverlay then
      lobby.showOverlay = false
    else
      lobby.showOverlay = true
    end
  end
end
