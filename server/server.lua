server = {}

gameInfo = {}

players = {}

loot = {}

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

  lootTimer = 0
  lootTimerTrigger = 10


  gameInfoNetUpdateRate = 1/30
  gameInfoNetUpdateCounter = 0

  Net:init( "Server" )
  Net:connect( nil, 25045 )


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
      players[id].inPlane = meta.inPlane
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
      players[id].inPlane = client_data.inPlane
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
  for _,item in pairs( loot ) do
    love.graphics.setColor( 225, 80, 50, 255 )
    love.graphics.rectangle("fill",item.x-item.size/2,item.y-item.size/2, item.size, item.size)
  end

  for k,c in pairs( players ) do
    -- draw circles visible range
    if c.r and c.g and c.b and c.x and c.y then
      -- love.graphics.setBlendMode("alpha","premultiplied")
      love.graphics.setColor( 30, 30, 30, 100 )
      love.graphics.circle("fill",c.x,c.y, viewDistance)
    end
    -- draw circles hitarea
    if c.r and c.g and c.b and c.x and c.y and (#c.visibleTo > 0) then
      love.graphics.setColor( 60, 60, 60, 100 )
      love.graphics.circle("fill",c.x,c.y, viewDistance)
    end
    -- draw connections
    if c.r and c.g and c.b and c.x and c.y and (#c.visibleTo > 0) then
      for k2,c2 in pairs( c.visibleTo ) do
        love.graphics.setColor( 255,255,255,20 )
        local u = {}
        u = players[c2]
        love.graphics.line(c.x,c.y,u.x,u.y)
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
      local visibleTo = {}
      if c.x and c.y and not c.inPlane then
        for k2,c2 in pairs( players ) do
          if c2.x and c2.y and k2 ~= k and not c2.inPlane then
            square_dist = (c.x - c2.x)^2 + (c.y - c2.y)^2
            if square_dist < viewDistance^2 then
              table.insert(visibleTo,k2)
              -- print(k," <-> ",k2,square_dist)
            end
          end
        end
      end
      c.visibleTo = visibleTo

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
      if c.inPlane then
        c.x = plane.x
        c.y = plane.y
      end
    end

    -- send collision info
    coltime = coltime + dt
    if coltime > server.visibleToUpdateTime and players then
      coltime = 0
      -- enemies = {}
      for k,u in pairs( players ) do
        if not u.visibleTo then break end
        for j,e in pairs( u.visibleTo ) do
          -- table.insert(enemies,Net.users[e])
          local enemy = {}
          -- enemy = Net.users[e]
          enemy.id = e
          enemy.name = players[e].name
          enemy.x = players[e].x
          enemy.y = players[e].y
          enemy.r = players[e].r
          enemy.g = players[e].g
          enemy.b = players[e].b
          enemy.aimX = players[e].aimX
          enemy.aimY = players[e].aimY
          enemy.lastSeen = 1
          if not enemy.inPlane then
            -- Net:send(enemy,"updateEnemies",nil,k)
          end
          -- print('updateEnemy',k)
        end
      end
    end

    gameInfo.serverClock = server.clock

    lootTimer = lootTimer + dt
    if lootTimer > lootTimerTrigger then
      if zone.scale > zone.min_scale then
        plane.startSupport()
      end
      lootTimer = 0
    end

    -- game info update
    sendGameInfo(dt)

  end
end

function sendGameInfo(dt)
  gameInfoNetUpdateCounter = gameInfoNetUpdateCounter + dt
  if gameInfoNetUpdateCounter >= gameInfoNetUpdateRate then
    gi = gameInfo
    -- update general
    gi.playercount = tablelength(players)
    gi.playercount_alive = alivecount(players)
    gi.planeX = plane.x
    gi.planeY = plane.y
    -- update player
    for id,player in pairs( players ) do
      gi.health = player.health
      gi.dead = player.dead
      -- gameInfo.isPlane = user.isPlane or true
      if not player.dead then
        gi.rank = gi.playercount_alive
        player.rank = gi.rank
      else
        gi.rank = player.rank
      end
      gi.inPlane = player.inPlane
      Net:send(gi,"updateGameInfo",nil,id)
    end
    -- reset timer
    gameInfoNetUpdateCounter = 0
  end
end

function generateGameInfoForPlayer()
end

function server.keypressed(key)
  if key == 'r' then
    startGame()
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
  print("connection from: "..id)
  local found = false
  for uid,player in pairs( players ) do
    print(uid,id)
    if (uid == id) then
      print(id..' reconnected. sending state')
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
      Net:send(gameInfo,"updateGameInfo",nil,uid)
    end
  end
  if not found then
    players[id] = {}
    players[id].connected = true
  end
end

function Net.event.server.userDisconnected(id)
  print("disconnection from: "..id)
  players[id].connected = false
end


function startGame()
  for uid,v in pairs( players ) do
    players[uid].health = 100
    players[uid].dead = false
    players[uid].inPlane = true
    Net:send({},"startGame",nil,uid)
  end
  loot = {}
  zone.reset()
  plane.startCarrier()
end

function dropSupportBox(x,y,s, item)
  print(x,y,s, item)
  local l = {
    x = x,
    y = y,
    size = s,
    content = item
  }
  table.insert(loot,l)
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
