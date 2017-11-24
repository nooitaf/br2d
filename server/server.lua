server = {}
gameInfo = {}
players = {}

Net = require("lib/net")

function server.load()
  server.clock = 0
  server.visibleToUpdateTime = .1
  viewDistance = 10
  coltime = 0

  gameInfo.playercount = 0
  gameInfo.playercount_alive = 0
  gameInfo.dead = false
  gameInfo.health = 0

  gameInfoNetUpdateRate = 1/30
  gameInfoNetUpdateCounter = 0

  restartWaitCounter = 0
  restartWaitCounterMax = 2

  Net:init( "Server" )
  Net:connect( nil, 25045 )
  Net:setMaxPing( 200 )
  Net:registerCMD( "tik", function( data, param, id, deltatime )
    Net:send({time=data.time},"tok",nil,id)
	end )
  Net:registerCMD( "updateClientMeta", function( meta, param, id, deltatime )
    -- print('client data ----------------------',#client_data)
		if not meta.name then return end
		if not meta.r then return end
		if not meta.g then return end
    if not meta.b then return end
    -- if not meta.inPlane then return end
    if players and players[id] then
      players[id].name = meta.name
      players[id].r = meta.r
      players[id].g = meta.g
      players[id].b = meta.b
      if players[id].inPlane and not meta.inPlane then
        players[id].inPlane = false
        players[id].inPlaneQueue = false
        gameInfo.gameState = "activated"
      end
    end
	end )
  Net:registerCMD( "updateClientInfo", function( client_data, param, id, deltatime )
    -- print('client data ----------------------',#client_data)
		if not client_data.name then return end
		if not client_data.r then return end
		if not client_data.g then return end
    if not client_data.b then return end
    if not client_data.x then return end
    if not client_data.y then return end
    if not client_data.aimX then return end
    if not client_data.aimY then return end
    -- if not client_data.inPlane then return end
    if players and players[id] then
      players[id].name = client_data.name
      players[id].r = client_data.r
      players[id].g = client_data.g
      players[id].b = client_data.b
      players[id].aimX = client_data.aimX
      players[id].aimY = client_data.aimY
      if players[id].inPlane and not client_data.inPlane then
        players[id].inPlane = false
        players[id].inPlaneQueue = false
        gameInfo.gameState = "activated"
      end
      players[id].x = client_data.x
      players[id].y = client_data.y
      -- if not Net.users[id].health then Net.users[id].health = 100 end
    end
	end )
  Net:registerCMD( "updateClientPosition", function( data, param, id, deltatime )
    -- print('client position data ----------------------',#data)
    if not data.x then return end
    if not data.y then return end
    if not data.d then return end
    if players and players[id] then
      players[id].x = data.x
      players[id].y = data.y
      players[id].viewDirection = data.d
    end
	end )
end







function server.draw()
  -- love.graphics.setColor(0,0,255)
  -- love.graphics.rectangle("fill",0,0 ,love.graphics.getWidth(),love.graphics.getHeight()/8)

  for k,c in pairs( players ) do
    -- draw circles visible range
    if c.r and c.g and c.b and c.x and c.y then
      -- love.graphics.setBlendMode("alpha","premultiplied")
      love.graphics.setColor( 30, 30, 30, 100 )
      love.graphics.circle("fill",c.x,c.y, viewDistance)
    end
    -- draw circles hitarea
    if c.r and c.g and c.b and c.x and c.y and (#c.enemies > 0) then
      love.graphics.setColor( 60, 60, 60, 100 )
      love.graphics.circle("fill",c.x,c.y, viewDistance)
    end
    -- draw connections
    if c.r and c.g and c.b and c.x and c.y and (#c.enemies > 0) then
      for k2,c2 in pairs( c.enemies ) do
        love.graphics.setColor( 255,255,255,20 )
        love.graphics.line(c.x,c.y,c2.x,c2.y)
      end
    end
    -- draw loot
    -- draw players
    if c.r and c.g and c.b and c.x and c.y then
      if c.dead then
        -- player
        love.graphics.setColor( 130,130,130,255 )
        love.graphics.rectangle("fill", c.x - 1, c.y - 1, 2, 2 )
      else
        -- player
        love.graphics.setColor( c.r, c.g, c.b )
        love.graphics.rectangle("fill", c.x - 1, c.y - 1, 2, 2 )
        -- health bar
        if c.health then
          -- background
          love.graphics.setColor( 30, 30, 30, 255 )
          love.graphics.rectangle("fill", c.x - 5, c.y - 5, 10, 2 )
          -- color
          local health = c.health or 0
          if health < 20 then
            love.graphics.setColor( 230, 30, 30, 255 )
          elseif health >= 20 and health < 70 then
            love.graphics.setColor( 230, 230, 30, 255 )
          elseif health >= 70 and health < 100 then
            love.graphics.setColor( 130, 230, 30, 255 )
          else
            love.graphics.setColor( 30, 230, 30, 255 )
          end
          -- foreground
          love.graphics.rectangle("fill", c.x - 5, c.y - 5, 10/100*c.health, 2 )
        end
      end
    end
  end

  -- draw clock
  love.graphics.setColor(0,255,0)
  local s = math.floor(server.clock)
  local m = math.floor(s / 60)
  local h = math.floor(m / 60)
  love.graphics.printf(string.format('%.2i:%.2i:%.2i',h,m,s),0,0,love.graphics.getWidth(),"center")

  -- draw playercount
  love.graphics.setColor(0,255,0)
  love.graphics.printf("Players "..gameInfo.playercount_alive.."/"..gameInfo.playercount,5,5,love.graphics.getWidth(),"left")

  -- draw fps
  love.graphics.setColor(255,255,0)
  love.graphics.printf(love.timer.getFPS() or "",5,75,love.graphics.getWidth(),"left")
end









function server.update(dt)
  server.clock = server.clock + dt
  Net:update( dt )

  if players then

    for k,c in pairs( players ) do
      -- plane check
      if c.inPlane then
        c.x = plane.x
        c.y = plane.y
      end
      -- dead check
      if c.health and c.health <= 0 and not c.dead then
        c.dead = true
      end
      -- calc player hitareas
      c.enemies = {}
      c.enemiesPacked = ""
      local visibleTo = {}
      if c.x and c.y and not c.inPlane then
        for k2,c2 in pairs( players ) do
          if c2.x and c2.y and k2 ~= k and not c2.inPlane then
            square_dist = (c.x - c2.x)^2 + (c.y - c2.y)^2
            if square_dist < viewDistance^2 then
              local e = {}
              -- enemy = Net.users[e]
              table.insert(c.enemies,players[k2])
              -- print(k," <-> ",k2,square_dist)
            end
          end
        end
      end

      -- fix users
      if not c.health then
        c.health = 0
      end
      if not c.dead then
        c.dead = false
      end
      if not c.rank then
        c.rank = 100
      end
    end


    gameInfo.serverClock = server.clock

    -- game info update
    gameInfo.playercount = tablelength(players)
    gameInfo.playercount_alive = alivecount(players)
    gameInfo.playercount_plane = planecount(players)
    gameInfo.restartWaitCounter = restartWaitCounter

    -- if no enough players or just one alive
    if gameInfo.playercount_alive <= 1 and gameInfo.gameState == "activated" then
      restartWaitCounter = 0
      for id,p in pairs( players ) do
        if p.health > 0 then
          gameInfo.winnerName = p.name.." "..p.id
          p.health = 0
          p.rank = 1
        end
      end
      gameInfo.gameState = "restartWait"
    end
    if gameInfo.gameState == "restartWait" then
      restartWaitCounter = restartWaitCounter + dt
      if restartWaitCounter > restartWaitCounterMax then
        lobby.start()
      end
    end

    sendGameInfo(dt)

  end
end









function sendGameInfo(dt)
  gameInfoNetUpdateCounter = gameInfoNetUpdateCounter + dt
  if gameInfoNetUpdateCounter >= gameInfoNetUpdateRate then
    gi = gameInfo
    -- update general
    gi.gameInfoNetUpdateRate = gameInfoNetUpdateRate
    gi.planeActive = plane.active
    gi.planeX = plane.x
    gi.planeY = plane.y
    gi.planeAngle = plane.angle
    gi.planeFlightCounter = plane.flightCounter
    -- update player
    for pid,player in pairs( players ) do
      gi.health = player.health
      gi.dead = player.dead
      local enemies = {}
      -- gi.enemies = table.concat(gi.enemies,",")
      gi.enemiesPacked = ""
      for uid,p in pairs( player.enemies ) do
        if p.id then
          gi.enemiesPacked = gi.enemiesPacked..";"..p.id..","..p.x..","..p.y
        end
      end
      -- print("ep:"..gi.enemiesPacked)
      -- gameInfo.isPlane = user.isPlane or true
      if not player.dead then
        gi.rank = gi.playercount_alive
        player.rank = gi.rank
      else
        gi.rank = player.rank
      end
      gi.inPlane = player.inPlane
      -- gi.inPlaneQueue = player.inPlaneQueue
      Net:send(gi,"updateGameInfo",nil,pid)
    end
    -- reset timer
    gameInfoNetUpdateCounter = 0
  end
end





function generateGameInfoForPlayer()
end





function server.keypressed(key)
  if key == 'r' then
    lobby.start()
    -- startGame()
  end

  -- local data = {}
  -- data.text = "blaaaa"
  -- for CLIENTSID,table in pairs( Net.users ) do
  --   love.graphics.setColor(0,0,0)
  --   love.graphics.print(CLIENTSID)
  --   print(CLIENTSID)
  --   Net:send(data,"updateConsole",nil,CLIENTSID)
  -- end

end








function Net.event.server.userConnected(id)
  print("CONNECTED: "..id)
  local found = false
  for uid,player in pairs( players ) do
    -- print(uid,id)
    if (uid == id) then
      print('RE: '..id)
      gameInfo.health = player.health
      gameInfo.dead = player.dead
      -- gameInfo.isPlane = user.isPlane or true
      if not player.dead then
        gameInfo.rank = gameInfo.playercount_alive
        player.rank = gameInfo.rank
      else
        gameInfo.rank = player.rank
      end
      found = true
      player.connected = true
      -- Net:send(gameInfo,"updateGameInfo",nil,uid)
    end
  end
  if not found then
    players[id] = {}
    players[id].id = id
    players[id].connected = true
    players[id].dead = false
    players[id].inPlane = true
    players[id].inPlaneQueue = true
    players[id].health = 100
  end
end



function Net.event.server.userDisconnected(id)
  print("DISCONNECTED: "..id)
  players[id].connected = false
  players[id] = nil
end











function startGame()
  gameInfo.gameState = "running"
  for uid,v in pairs( players ) do
    players[uid].health = 100
    players[uid].dead = false
    players[uid].inPlane = true
    players[uid].inPlaneQueue = true
    players[uid].inLobby = false
    players[uid].enemies = {}
    players[uid].enemiesPacked = ""
    players[uid].x = 250
    players[uid].y = 250
    Net:send({},"startGame",nil,uid)
  end
  plane.startCarrier()
end






function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function alivecount(T)
  local count = 0
  for _,u in pairs(T) do
    if not u.dead then
      count = count + 1
    end
  end
  return count
end
function planecount(T)
  local count = 0
  for _,u in pairs(T) do
    if u.inPlane then
      count = count + 1
    end
  end
  return count
end
