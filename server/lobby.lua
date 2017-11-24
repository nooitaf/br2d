lobby = {}

function lobby.load()
  lobby.timer = 0
  lobby.timerStart = 0 -- timer between restarts default 3 sec
  lobby.active = false
  lobby.showOverlay = false
end

function lobby.draw()
  if lobby.showOverlay then
    love.graphics.setColor(0,0,0,100)
    love.graphics.rectangle("fill", 0,0,love.graphics.getWidth(),love.graphics.getHeight() )
    -- print(lobby.showOverlay)
    local i = 0
    for k,p in pairs( players ) do
      -- print(k)
      love.graphics.setColor(255,255,0)
      love.graphics.printf(k,5,i*12 + 20,love.graphics.getWidth(),"left")
      i = i + 1
    end
  end

  if lobby.active then
    love.graphics.setColor(255,255,0)
    love.graphics.printf(math.ceil(lobby.timer),0,12,love.graphics.getWidth(),"right")
  end
end

function lobby.update(dt)
  if lobby.active then
    lobby.timer = lobby.timer - dt
    if lobby.timer <= 0 and gameInfo.playercount >= START_GAME_PLAYER_MIN then
      lobby.active = false
      startGame()
    elseif lobby.timer <= 0 then
      lobby.start()
    end
  end
end

function lobby.start()
  plane.stopAndRemoveEverything()
  loot.reset()
  zone.reset()
  gameInfo.gameState = "lobby"
  lobby.timer = lobby.timerStart
  lobby.active = true
  for uid,v in pairs( players ) do
    if not players[uid].connected then
      Net:kickUser(uid, "you were disconnected at gamestart")
    end
    players[uid].health = 100
    players[uid].dead = false
    players[uid].inLobby = true
    players[uid].inPlane = true
    players[uid].inPlaneQueue = true
    Net:send({},"startLobby",nil,uid)
    local lootArray = {}
    local i = 1
    for j,l in pairs( loot.items ) do
      local d = {
        x = l.x,
        y = l.y,
        size = l.size,
        content = l.content
      }
      -- Net:send(d,"insertLoot",nil,uid)
      lootArray[i] = l.x..","..l.y..","..l.size..","..l.content
      i = i + 1
    end
    Net:send(lootArray,"insertLootBatch",nil,uid)
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
