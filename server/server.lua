server = {}

gameInfo = {}


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

  Net:init( "Server" )
  Net:connect( nil, 25045 )


  Net:registerCMD( "updateClientMeta", function( meta, param, id, deltatime )
    -- print('client data ----------------------',#client_data)
		if not meta.name then return end
		if not meta.r then return end
		if not meta.g then return end
    if not meta.b then return end
    -- if not meta.inPlane then return end
    if Net.users and Net.users[id] then
      Net.users[id].name = meta.name
      Net.users[id].r = meta.r
      Net.users[id].g = meta.g
      Net.users[id].b = meta.b
      Net.users[id].inPlane = meta.inPlane
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
    if Net.users and Net.users[id] then
      Net.users[id].name = client_data.name
      Net.users[id].r = client_data.r
      Net.users[id].g = client_data.g
      Net.users[id].b = client_data.b
      Net.users[id].aimX = client_data.aimX
      Net.users[id].aimY = client_data.aimY
      Net.users[id].inPlane = client_data.inPlane
      Net.users[id].x = client_data.x
      Net.users[id].y = client_data.y
      -- if not Net.users[id].health then Net.users[id].health = 100 end
    end
	end )

  Net:registerCMD( "updateClientPosition", function( data, param, id, deltatime )
    -- print('client position data ----------------------',#data)
    if not data.x then return end
    if not data.y then return end
    if not data.d then return end
    if Net.users and Net.users[id] then
      Net.users[id].x = data.x
      Net.users[id].y = data.y
      Net.users[id].viewDirection = data.d
    end
	end )
end

function server.draw()
  -- love.graphics.setColor(0,0,255)
  -- love.graphics.rectangle("fill",0,0 ,love.graphics.getWidth(),love.graphics.getHeight()/8)

  -- draw circles visible range
  for k,c in pairs( Net.users ) do
    if c.r and c.g and c.b and c.x and c.y then
      -- love.graphics.setBlendMode("alpha","premultiplied")
      love.graphics.setColor( 30, 30, 30, 100 )
      love.graphics.circle("fill",c.x,c.y, viewDistance)
    end
  end

  -- draw circles hitarea
  for k,c in pairs( Net.users ) do
    if c.r and c.g and c.b and c.x and c.y and (#c.visibleTo > 0) then
      love.graphics.setColor( 60, 60, 60, 100 )
      love.graphics.circle("fill",c.x,c.y, viewDistance)
    end
  end

  -- draw connections
  for k,c in pairs( Net.users ) do
    if c.r and c.g and c.b and c.x and c.y and (#c.visibleTo > 0) then
      for k2,c2 in pairs( c.visibleTo ) do
        love.graphics.setColor( 255,255,255,20 )
        local u = {}
        u = Net.users[c2]
        love.graphics.line(c.x,c.y,u.x,u.y)
      end
    end
  end

  -- draw players
  for k,c in pairs( Net.users ) do
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

  if Net.users then
    -- dead check
    for k,c in pairs( Net.users ) do
      if c.health and c.health <= 0 and not c.dead then
        c.dead = true
      end
    end

    -- calc player hitareas
    for k,c in pairs( Net.users ) do
      local visibleTo = {}
      if c.x and c.y and not c.inPlane then
        for k2,c2 in pairs( Net.users ) do
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
    end

    -- send collision info
    coltime = coltime + dt
    if coltime > server.visibleToUpdateTime and Net.users then
      coltime = 0
      -- enemies = {}
      for k,u in pairs( Net.users ) do
        if not u.visibleTo then break end
        for j,e in pairs( u.visibleTo ) do
          -- table.insert(enemies,Net.users[e])
          local enemy = {}
          -- enemy = Net.users[e]
          enemy.id = e
          enemy.name = Net.users[e].name
          enemy.x = Net.users[e].x
          enemy.y = Net.users[e].y
          enemy.r = Net.users[e].r
          enemy.g = Net.users[e].g
          enemy.b = Net.users[e].b
          enemy.aimX = Net.users[e].aimX
          enemy.aimY = Net.users[e].aimY
          enemy.lastSeen = 1
          if not enemy.inPlane then
            Net:send(enemy,"updateEnemies",nil,k)
          end
          -- print('updateEnemy',k)
        end
      end
    end

    gameInfo.serverClock = server.clock

    -- fix users
    for id,user in pairs( Net.users ) do
      if not user.health then
        Net.users[id].health = 0
      end
      if not user.dead then
        Net.users[id].dead = false
      end
      if not user.rank then
        Net.users[id].rank = 100
      end
      if user.inPlane then
        user.x = plane.x
        user.y = plane.y
      end
    end

    -- game info update
    sendGameInfo(dt)

  end
end

function sendGameInfo(dt)
  gameInfoNetUpdateCounter = gameInfoNetUpdateCounter + dt
  if gameInfoNetUpdateCounter >= gameInfoNetUpdateRate then
    -- update general
    gameInfo.playercount = tablelength(Net.users)
    gameInfo.playercount_alive = alivecount(Net.users)
    gameInfo.planeX = plane.x
    gameInfo.planeY = plane.y
    -- update player
    for id,user in pairs( Net.users ) do
      gameInfo.health = user.health
      gameInfo.dead = user.dead
      -- gameInfo.isPlane = user.isPlane or true
      if not user.dead then
        gameInfo.rank = gameInfo.playercount_alive
        user.rank = gameInfo.rank
      else
        gameInfo.rank = user.rank
      end
      Net:send(gameInfo,"updateGameInfo",nil,id)
    end
    -- reset timer
    gameInfoNetUpdateCounter = 0
  end
end

function server.keypressed(key)
  local data = {}
  data.text = "blaaaa"
  for CLIENTSID,table in pairs( Net.users ) do
    love.graphics.setColor(0,0,0)
    love.graphics.print(CLIENTSID)
    print(CLIENTSID)
    Net:send(data,"updateConsole",nil,CLIENTSID)
  end
  if key == 'r' then
    startGame()
  end

end

function Net.event.server.userConnected(id)
  love.graphics.setColor(255,255,255)
  love.graphics.print("userConnected: "..id,50,50)
  for uid,user in pairs( Net.users ) do
    print(uid,id)
    if (uid == id) then
      print('refresh data send/...')
      gameInfo.health = user.health
      gameInfo.dead = user.dead
      -- gameInfo.isPlane = user.isPlane or true
      if not user.dead then
        gameInfo.rank = gameInfo.playercount_alive
        user.rank = gameInfo.rank
      else
        gameInfo.rank = user.rank
      end
      Net:send(gameInfo,"updateGameInfo",nil,uid)
    end
  end
  print("userConnected: "..id)
end


function startGame()
  for uid,v in pairs( Net.users ) do
    Net.users[uid].health = 100
    Net.users[uid].dead = false
    Net.users[uid].inPlane = true
    Net:send({},"startGame",nil,uid)
  end
  zone.restart()
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
