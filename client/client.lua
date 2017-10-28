client = {}
gameInfo = {}

Net = require("lib/net")
tween = require("lib/tween")

function client.load()
  bg_image = love.image.newImageData( 'assets/map.png' )

  show_map = true

  gameInfo.health = 0
  gameInfo.playercount = 0
  gameInfo.playercount_alive = 0
  gameInfo.rank = 0

  ground_sound_water = love.audio.newSource( "assets/shoot.ogg" )
  ground_sound_water:setLooping(false)
  ground_timer = 0

  playerSize = 5
  mapZoomScale = 10
  runningLimit = 50
  runningLimitIncrease = .01

  client.clock = 0
  nettimer = 0
  nettimer_trigger = .3
  netpositiontimer = 0
  netpositiontimer_trigger = .1
  pingtimer = 0
  pingval = 0
  ground = "water"
  client.data = {}
	client.data.name = "Nick"
	client.data.r = 255
	client.data.g = 100
  client.data.b = 0
  client.data.x = 200
  client.data.y = 200
  client.data.viewDirection = 12
  local x, y = distantPointWithAngleAndLength(client.data.viewDirection, 100)
  client.data.aimX = x
  client.data.aimY = y
  client.data.running = runningLimit
  client.data.inPlane = true
  client.data.isShooting = false
  client.data.shootTimer = 0
  client.data.shootTimerTrigger = .1
  client.bullets = {}


  lastData = client.data
  console = {}
  console.log = {}
  enemies = {}
  speedAdjust = .01

  Net:init( "Client" )
  Net:connect( "127.0.0.1", 25045 )
  Net:registerCMD( "updateConsole", function( data, param, id, deltatime )
		if not data.text then return end
    -- print(data.text)
    love.graphics.setColor(255,120,155)
    love.graphics.print("cons:"..data.text,0,30)
    table.insert(console.log,data.text)
	end )
  Net:registerCMD( "updateEnemies", function( data, param, id, deltatime )
		if not data then return end
    -- table.foreach(data,print)
    enemies[data.id] = data
	end )
  Net:registerCMD( "updateGameInfo", function( data, param, id, deltatime )
		if not data then return end
    -- table.foreach(data,print)
    gameInfo = data
	end )
  Net:registerCMD( "updatePosition", function( data, param, id, deltatime )
		if not data then return end
    -- table.foreach(data,print)
    client.data.x = data.x
    client.data.y = data.y
    -- client.data.inPlane = data.inPlane
	end )
  Net:registerCMD( "startGame", function( data, param, id, deltatime )
    client.data.inPlane = true
    print('start game')
	end )

end

function round(x)
  return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

function isBuilding(x,y)
  -- update ground
  if client.data.x >= 0 and client.data.x < 250 and client.data.y >= 0 and client.data.y < 250 then
    local r = bg_image:getPixel( x*2, y*2 )
    return r == 255
  end
end

function isBuildingWithScale(x,y,s)
  print(client.data.inPlane)
  if not client.data.inPlane then
    -- update ground
    local r1 = bg_image:getPixel( x*2-s/2, y*2 )
    local r2 = bg_image:getPixel( x*2+s/2, y*2 )
    local r3 = bg_image:getPixel( x*2, y*2-s/2 )
    local r4 = bg_image:getPixel( x*2, y*2+s/2 )
    -- print(r1,r2,r3,r4)
    return r1 == 255 or r2 == 255 or r3 == 255 or r4 == 255
  end
end

function angleFromPoint(x,y,x2,y2)
  local dy = (y - y2)
  local dx = (x - x2)
  local theta = math.atan2(dy,dx)
  local angle = (90 - ((theta * 180) / math.pi)) % 360
  return angle
end

function distantPointWithAngleAndLength(angle,length)
  -- print(angle)
  local dir = 0
  if angle >= 270 then
    angle = 90 - (angle - 270)
    dir = 0
  elseif angle >= 180 and angle < 270 then
    angle = angle - 180
    dir = 1
  elseif angle >= 90 and angle < 180 then
    angle = 90 - (angle - 90)
    dir = 2
  elseif angle < 90 and angle >= 0 then
    angle = angle
    dir = 3
  end
  local c = length
  local A = math.rad(angle)
  local C = math.rad(90)
  local B = A - C
  local b = c/math.sin(C) * math.sin(B)
  local a = b/math.sin(B) * math.sin(A)
  -- print(angle,a,b,dir)
  if dir == 0 then
    a = a
    b = b
  elseif dir == 1 then
    a = a
    b = -b
  elseif dir == 2 then
    a = -a
    b = -b
  elseif dir == 3 then
    a = -a
    b = b
  end
  return a,b
end

function client.mousemoved(x,y,dx,dy,istouch)
  if show_map then
    client.data.viewDirection = angleFromPoint(250,250,x,y)
  else
    client.data.viewDirection = angleFromPoint(client.data.x,client.data.y,x,y)
  end
  local x, y = distantPointWithAngleAndLength(client.data.viewDirection, 100)
  client.data.aimX = x
  client.data.aimY = y
end



function client.draw()

  -- movement
  local target = {}
  target.x = client.data.x
  target.y = client.data.y
  local running = 0
  if love.keyboard.isDown('lshift') and client.data.running > 1 then
    running = .1
    client.data.running = client.data.running - running
    if client.data.running < 1 then client.data.running = 0 end
  end
  if love.keyboard.isDown('up') or love.keyboard.isDown('w') then
    target.y = client.data.y - (client.speed*speedAdjust+running)
  end
  if love.keyboard.isDown('right') or love.keyboard.isDown('d') then
    target.x = client.data.x + (client.speed*speedAdjust+running)
  end
  if love.keyboard.isDown('down') or love.keyboard.isDown('s') then
    target.y = client.data.y + (client.speed*speedAdjust+running)
  end
  if love.keyboard.isDown('left')  or love.keyboard.isDown('a') then
    target.x = client.data.x - (client.speed*speedAdjust+running)
  end

  target.x = target.x
  target.y = target.y

  if isBuilding(target.x,target.y) then
    client.data.x = client.data.x
    client.data.y = client.data.y
  else
    client.data.x = target.x
    client.data.y = target.y
  end

  if client.data.inPlane and gameInfo.planeX then
    target.x = gameInfo.planeX
    target.y = gameInfo.planeY
  end

  client.data.x = target.x
  client.data.y = target.y
  -- print(client.data.x,client.data.y)

  -- debug
  pingtimer = pingtimer + 1
  if Net.connected and pingtimer > 100 then
    pingval = math.floor(Net.currentPing)
    pingtimer = 0
  end

  -- draw player
  local c = client.data
  if c.r and c.g and c.b and c.x and c.y then
    -- visual area
    love.graphics.setColor( 30, 30, 30, 40 )
    love.graphics.circle("fill",c.x,c.y, 20)
    -- draw aim
    love.graphics.setColor( 100, 100, 100, 100 )
    love.graphics.setLineStyle("smooth")
    love.graphics.line(c.x,c.y,c.x+c.aimX/mapZoomScale,c.y+c.aimY/mapZoomScale)
    -- draw player
    love.graphics.setColor( c.r, c.g, c.b )
    love.graphics.rectangle("fill", c.x - 1, c.y - 1, 2, 2 )
  end

  -- draw enemies
  for key,value in pairs(enemies) do
    if value.x and value.y and value.r and value.g and value.b then
      love.graphics.setColor( value.r, value.g, value.b, value.lastSeen * 255 )
      love.graphics.rectangle("fill", value.x - 1, value.y - 1, 2, 2 )
    end
  end

  -- draw death zone
  if gameInfo and gameInfo.zone_scale then
    love.graphics.setColor( 230, 130, 130, 100 )
    love.graphics.circle("line",gameInfo.zone_x,gameInfo.zone_y,gameInfo.zone_scale)
    love.graphics.setColor( 130, 130, 130, 100 )
    love.graphics.circle("line",gameInfo.zone_target_x,gameInfo.zone_target_y,gameInfo.zone_target_scale)
  end

  -- play sound
  ground_timer = ground_timer + client.speed
  if ground_timer > 10
    and (
      love.keyboard.isDown('up')
      or love.keyboard.isDown('down')
      or love.keyboard.isDown('left')
      or love.keyboard.isDown('right')
    ) then
    -- love.audio.play(ground_sound_water)
    ground_timer = 0
  end


  -- zoom view
  if show_map then
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    -- draw background
    love.graphics.setColor( 255,255,255,255 )
    local scale = mapZoomScale
    local x = client.data.x*2-(250/scale)
    local y = client.data.y*2-(250/scale)
    love.graphics.draw(bg_img,0,0,0,scale,scale,x,y)

    -- draw enemies
    for key,value in pairs(enemies) do
      if value.x and value.y and value.r and value.g and value.b and value.aimX and value.aimY then
        love.graphics.setColor( value.r, value.g, value.b, value.lastSeen * 255 )
        local x = 0
        local y = 0
        if value.x >= client.data.x then
          x = value.x - client.data.x
        elseif value.x < client.data.x then
          x = value.x - client.data.x
        end
        if client.data.y >= value.y then
           y = value.y - client.data.y
        elseif client.data.y < value.y then
          y = value.y - client.data.y
        end
        x = x*2*scale + 250
        y = y*2*scale + 250

        love.graphics.rectangle("fill", x - playerSize, y - playerSize, playerSize*2, playerSize*2 )
        -- draw enemy aim
        love.graphics.setColor( 100, 100, 100, 100 )
        love.graphics.setLineStyle("smooth")
        love.graphics.line(x,y,x+value.aimX,y+value.aimY)
      end
    end

    -- draw aim
    love.graphics.setColor( 100, 100, 100, 100 )
    love.graphics.setLineStyle("smooth")
    love.graphics.line(w/2,h/2,w/2+c.aimX,h/2+c.aimY)

    -- draw visual area
    love.graphics.setColor( 30, 30, 30, 40 )
    -- love.graphics.circle("fill",love.graphics.getWidth()/2,love.graphics.getHeight()/2, 250)

    -- draw player
    local c = client.data
    love.graphics.setColor( c.r, c.g, c.b )
    love.graphics.rectangle("fill", w/2 - playerSize,h/2 - playerSize, playerSize*2, playerSize*2 )
    -- love.graphics.circle("fill", love.graphics.getWidth()/2 - playerSize,love.graphics.getHeight()/2 - playerSize, playerSize*2 )


    -- draw death zone
    if gameInfo and gameInfo.zone_scale then
      local x = 0
      local y = 0
      if gameInfo.zone_x >= client.data.x then
        x = gameInfo.zone_x - client.data.x
      elseif gameInfo.zone_x < client.data.x then
        x = gameInfo.zone_x - client.data.x
      end
      if client.data.y >= gameInfo.zone_y then
         y = gameInfo.zone_y - client.data.y
      elseif client.data.y < gameInfo.zone_y then
        y = gameInfo.zone_y - client.data.y
      end
      x = x*2*scale + 250
      y = y*2*scale + 250
      love.graphics.setColor( 230, 130, 130, 100 )
      love.graphics.circle("line",x,y,gameInfo.zone_scale*2*scale)

      if gameInfo.zone_target_x >= client.data.x then
        x = gameInfo.zone_target_x - client.data.x
      elseif gameInfo.zone_target_x < client.data.x then
        x = gameInfo.zone_target_x - client.data.x
      end
      if client.data.y >= gameInfo.zone_target_y then
         y = gameInfo.zone_target_y - client.data.y
      elseif client.data.y < gameInfo.zone_target_y then
        y = gameInfo.zone_target_y - client.data.y
      end
      x = x*2*scale + 250
      y = y*2*scale + 250
      love.graphics.setColor( 130, 130, 130, 100 )
      love.graphics.circle("line",x,y,gameInfo.zone_target_scale*2*scale)
    end

  end


  -- draw dead screen
  if gameInfo.dead then
    love.graphics.setColor(0,0,0,230)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight() )
    love.graphics.setColor(255,255,0)
    local rank = gameInfo.rank or 0
    love.graphics.printf("#"..rank.." of "..gameInfo.playercount,0,love.graphics.getHeight()/2-20,love.graphics.getWidth(),"center")
    if rank == 1 then
      love.graphics.printf("Winner winner chicken dinner!",0,love.graphics.getHeight()/2,love.graphics.getWidth(),"center")
    else
      love.graphics.printf("BETTER LUCK NEXT TIME",0,love.graphics.getHeight()/2,love.graphics.getWidth(),"center")
    end
  end

  -- draw health
  if gameInfo.health then
    love.graphics.setColor( 30, 30, 30, 255 )
    love.graphics.rectangle("fill", 5, 5, (love.graphics.getWidth()-10), 10 )
    local health = gameInfo.health
    if health < 20 then
      love.graphics.setColor( 230, 30, 30, 255 )
    elseif health >= 20 and health < 40 then
      love.graphics.setColor( 230, 130, 30, 255 )
    elseif health >= 40 and health < 70 then
      love.graphics.setColor( 230, 230, 30, 255 )
    else
      love.graphics.setColor( 230, 230, 230, 255 )
    end
    love.graphics.rectangle("fill", 5, 5, (love.graphics.getWidth()-10)/100*gameInfo.health, 10 )

    love.graphics.setColor(0,255,0)
    love.graphics.printf("Health "..health,5,25,love.graphics.getWidth(),"left")
  end

  -- draw ground info
  love.graphics.setColor(0,255,0)
  love.graphics.printf("Ground "..ground,5,15,love.graphics.getWidth(),"left")

  -- draw ping
  -- love.graphics.setColor(0,255,0)
  -- love.graphics.printf(pingval,5,10,love.graphics.getWidth(),"right")

  -- draw playercount
  love.graphics.setColor(0,255,0)
  love.graphics.printf("Players "..gameInfo.playercount_alive.."/"..gameInfo.playercount,5,35,love.graphics.getWidth(),"left")

  -- draw plane state
  love.graphics.setColor(0,255,0)
  love.graphics.printf(string.format("Plane %s",tostring(client.data.inPlane)),5,45,love.graphics.getWidth(),"left")

  -- -- draw console
  -- if console and console.log then
  --   if table.maxn(console.log) > 0 then
  --     love.graphics.setColor(255,255,0)
  --     for msg,v in pairs( console.log ) do
  --       love.graphics.printf(msg,0,love.graphics.getHeight()/2,love.graphics.getWidth(),"right")
  --     end
  --   end
  --   if table.maxn(console.log) > 5 then
  --     table.remove(console.log,table.maxn(console.log))
  --     print("removed "..table.maxn(console.log))
  --   end
  -- end


  -- love.graphics.setColor(0,0,255)
  -- love.graphics.rectangle("fill",0,0 ,love.graphics.getWidth(),love.graphics.getHeight()/8)
  -- if Net.connected then
  --   love.graphics.setColor(0,120,155)
  --
  --   love.graphics.print("Connected")
  -- else
  --   love.graphics.print("NOT Connected")
  -- end
end


function client.update(dt)
  -- always update
  Net:update(dt)

  -- update shooting state
  if love.mouse.isDown(1) then
    client.data.isShooting = true
  else
    client.data.isShooting = false
  end

  if client.data.isShooting then
    client.data.shootTimer = client.data.shootTimer + dt
    if client.data.shootTimer > client.data.shootTimerTrigger then
      local bullet = {
        x = client.data.x,
        y = client.data.y,
        tx = client.data.aimX,
        ty = client.data.aimY,
        animation = nil,
        dmg = 20
      }
      table.insert(client.bullets,bullet)
      bullet.animation = tween.new(3,bullet,{x=client.data.aimX,y=client.data.aimY},'linear')
      client.data.shootTimer = 0
      print("shooting")
    end
    if client.bullets then
      for _,b in pairs(client.bullets) do
        if b.animation and not b.animation == true then
          b.animation:update(dt)
        end
      end
    end
  end

  -- print(client.data.x,client.data.y)
  local r = 0
  -- update ground
  if client.data.x >= 0 and client.data.x < 500 and client.data.y >= 0 and client.data.y < 500 then
    r = bg_image:getPixel( client.data.x*2, client.data.y*2 )
  end
  -- print(r)
  if r >= 250 then
    ground = "house"
  elseif r < 150 and r >= 110 then
    ground = "snow"
  elseif r < 110 and r >= 70 then
    ground = "stone"
  elseif r < 70 and r >= 50 then
    ground = "wood"
  elseif r < 50 and r >= 20 then
    ground = "gras"
  elseif r < 20 and r >= 10 then
    ground = "sand"
  elseif r < 10 and r >= 0 then
    ground = "water"
  end

  -- update walking speed
  if ground == "water" then
    client.speed = 2
  elseif ground == "sand" then
    client.speed = 4
  elseif ground == "gras" then
    client.speed = 5
  elseif ground == "wood" then
    client.speed = 6
  elseif ground == "stone" then
    client.speed = 8
  elseif ground == "snow" then
    client.speed = 10
  elseif ground == "house" then
    client.speed = 1
  end

  -- update running
  if client.data.running < runningLimit then
    client.data.running = client.data.running + runningLimitIncrease
  end

  -- disappear enemies
  for k,e in pairs( enemies ) do
    e.lastSeen = e.lastSeen - dt
    if e.lastSeen < 0 then
      print('remove ',e.id)
      enemies[k] = nil
    end
  end

  -- send client info
  client.sendDataToServer(dt)
  client.sendPositionToServer(dt)
end

function client.sendDataToServer(dt)
  nettimer = nettimer + dt
  if (nettimer > nettimer_trigger) then
    nettimer = 0
    Net:send( client.data, "updateClientInfo", nil )
    client.sendMetaToServer()
  end
end

function client.sendMetaToServer()
  local meta = {
    name = client.data.name,
    inPlane = client.data.inPlane,
    r = client.data.r,
    g = client.data.g,
    b = client.data.b
  }
  Net:send( meta, "updateClientMeta", nil )
end

function client.sendPositionToServer(dt)
  netpositiontimer = netpositiontimer + dt
  if (netpositiontimer > netpositiontimer_trigger) and not client.data.inPlane then
    netpositiontimer = 0
    local data = {
      x = client.data.x,
      y = client.data.y,
      d = client.data.viewDirection
    }
    Net:send( data, "updateClientPosition", nil )
  end
end

function client.keypressed(key)
  if key == 'm' then
    if show_map == true then
      show_map = false
    else
      show_map = true
    end
  end

  if key == 'f' then
    client.data.inPlane = false
    client.sendMetaToServer()
  end

end
