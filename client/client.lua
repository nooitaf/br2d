client = {}
gameInfo = {}


local sprites = {}
sprites.rock = {}
sprites.water = {}
sprites.gras = {}
sprites.corn = {}

Net = require("lib/net")
tween = require("lib/tween")
local anim8 = require "lib/anim8"
local sprites_player, animation_head, animation_body, animation_legs

require "car"
local auto = Car:new(203,190,2)



function client.load()
  bg_image = love.image.newImageData( 'assets/map.png' )


  sprites_player = love.graphics.newImage('assets/sprites_player.png')
  sprites_player_scale = 0.03
  sprites_player:setFilter("nearest","nearest")
  local pg = anim8.newGrid(12, 12, sprites_player:getWidth(), sprites_player:getHeight())
  animation_legs = anim8.newAnimation(pg(1,1,'4-5',1), 0.1)
  animation_body = anim8.newAnimation(pg(1,2,'4-5',2), 0.1)
  animation_head = anim8.newAnimation(pg(1,3,'4-5',3), 0.1)


  sprites_grounds = love.graphics.newImage("assets/sprites_grounds.png")
  -- sprites_grounds:setFilter("nearest","nearest")

  sprites_grounds_size_width = 12
  sprites_grounds_size_height = 12
  sprites.rock[1]  = love.graphics.newQuad(sprites_grounds_size_width*0,sprites_grounds_size_height*0,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
  sprites.rock[2]  = love.graphics.newQuad(sprites_grounds_size_width*1,sprites_grounds_size_height*0,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
  sprites.rock[3]  = love.graphics.newQuad(sprites_grounds_size_width*2,sprites_grounds_size_height*0,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
  sprites.rock[4]  = love.graphics.newQuad(sprites_grounds_size_width*3,sprites_grounds_size_height*0,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
  sprites.gras[1]  = love.graphics.newQuad(sprites_grounds_size_width*0,sprites_grounds_size_height*1,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
  sprites.gras[2]  = love.graphics.newQuad(sprites_grounds_size_width*1,sprites_grounds_size_height*1,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
  sprites.gras[3]  = love.graphics.newQuad(sprites_grounds_size_width*2,sprites_grounds_size_height*1,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
  sprites.gras[4]  = love.graphics.newQuad(sprites_grounds_size_width*3,sprites_grounds_size_height*1,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
  sprites.water[1] = love.graphics.newQuad(sprites_grounds_size_width*0,sprites_grounds_size_height*2,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
  sprites.water[2] = love.graphics.newQuad(sprites_grounds_size_width*1,sprites_grounds_size_height*2,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
  sprites.water[3] = love.graphics.newQuad(sprites_grounds_size_width*2,sprites_grounds_size_height*2,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
  sprites.water[4] = love.graphics.newQuad(sprites_grounds_size_width*3,sprites_grounds_size_height*2,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
  sprites.corn[1]  = love.graphics.newQuad(sprites_grounds_size_width*0,sprites_grounds_size_height*3,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
  sprites.corn[2]  = love.graphics.newQuad(sprites_grounds_size_width*1,sprites_grounds_size_height*3,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
  sprites.corn[3]  = love.graphics.newQuad(sprites_grounds_size_width*2,sprites_grounds_size_height*3,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
  sprites.corn[4]  = love.graphics.newQuad(sprites_grounds_size_width*3,sprites_grounds_size_height*3,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())




  show_map = true

  gameInfo.health = 0
  gameInfo.playercount = 0
  gameInfo.playercount_alive = 0
  gameInfo.rank = 0
  gameInfo.inPlane = false

  ground_sound_water = love.audio.newSource( "assets/shoot.ogg" )
  ground_sound_water:setLooping(false)
  ground_timer = 0

  playerSize = 5
  mapZoomScale = 100
  runningLimit = 50
  runningLimitIncrease = .01

  client.clock = 0
  nettimer = 0
  nettimer_trigger = 1/5
  netpositiontimer = 0
  netpositiontimer_trigger = 1/30
  movementUpdateTimer = 0
  movementUpdateTimerRate = 1/30
  pingtimer = 0
  pingval = 0
  ground = "water"
  client.speed = 0.001
  client.speedWalking = 0.02 -- realistic 0.02
  client.speedRunning = 0.05 -- realistic 0.03
  client.data = {}
	client.data.name = "Nick"
	client.data.r = 255
	client.data.g = 100
  client.data.b = 0
  client.data.x = 201.2
  client.data.y = 189.5
  client.data.viewDirection = 0
  client.data.bodyDirection = 0
  client.data.bodyDirectionRate = 5
  local x, y = distantPointWithAngleAndLength(client.data.viewDirection, 100)
  client.data.aimX = x
  client.data.aimY = y
  client.data.isWalking = false
  client.data.isRunning = false
  client.data.running = runningLimit
  client.data.inPlane = true
  client.data.inPlaneQueue = true
  client.data.isShooting = false
  client.data.shootTimer = 0
  client.data.shootTimerTrigger = 1/10
  client.bullets = {}

  lastData = client.data
  console = {}
  console.log = {}
  enemies = {}

  Net:init( "Client" )
  Net:connect( "127.0.0.1", 25045 )
  Net:registerCMD( "tok", function( data, param, id, deltatime )
    local tok = math.floor((game.clock-data.time)*1000)
    client.ping = tok
    -- print("tok: "..tok)
  end )


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
    gameInfo = data
    if data.enemiesPacked then
      for enms in string.gmatch(data.enemiesPacked, "[^;]+") do
        local i = 1
        local vals = {}
        for token in string.gmatch(enms, "[^,]+") do
          vals[i] = token
          i = i + 1
        end
        local item = {
          id = vals[1],
          x = vals[2],
          y = vals[3]
        }
        local id = item.id
        if not enemies then
          enemies = {}
        end
        if not enemies[id] then
          enemies[id] = {}
        end
        enemies[id].id = item.id
        enemies[id].x = item.x
        enemies[id].y = item.y
        enemies[id].lastSeen = 1
      end
    end
    -- print(data.enemiesPacked)
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
    client.data.inPlaneQueue = true
    gameInfo.inPlane = true
    gameInfo.inPlaneQueue = true
    print('start game')
	end )
  Net:registerCMD( "startLobby", function( data, param, id, deltatime )
    client.data.inPlane = true
    client.data.inPlaneQueue = true
    gameInfo.inPlane = true
    gameInfo.inPlaneQueue = true
    print('start lobby')
	end )
end


function client.mousemoved(x,y,dx,dy,istouch)
  local w = love.graphics.getWidth()
  local h = love.graphics.getHeight()
  -- if show_map then
  --   client.data.viewDirection = angleFromPoint(w/2,h/2,x,y)
  -- else
  --   client.data.viewDirection = angleFromPoint(client.data.x,client.data.y,x,y)
  -- end
  client.data.viewDirection = client.data.viewDirection - dx/10
  local x, y = distantPointWithAngleAndLength(client.data.viewDirection, 10*mapZoomScale)
  -- print(client.data.viewDirection,mapZoomScale)
  -- print("mouse",dx,dy)
  client.data.aimX = x
  client.data.aimY = y
end




function client.draw()
  -- debug
  pingtimer = pingtimer + 1
  if Net.connected and pingtimer > 100 then
    pingval = math.floor(Net.currentPing)
    pingtimer = 0
  end

  -- draw background map
  love.graphics.setColor(255,255,255)
  love.graphics.draw(bg_img,0,0,0,0.5,0.5)



  -- draw sprites
  local w = love.graphics.getWidth()
  local h = love.graphics.getHeight()
  local scale = .0417

  for row = -5,5 do
    for col = -5,5 do
      local px = round(client.data.x) + row/2
      local py = round(client.data.y) + col/2
      local ground = client.getGround(px,py)
      love.graphics.setColor( 255, 255, 255, 150 )
      if ground == "gras" then
        for i = 1,4 do
          love.graphics.draw(sprites_grounds,sprites.gras[i],px,py,0,scale,scale)
        end
      end
      if ground == "water" then
        for i = 1,4 do
          love.graphics.draw(sprites_grounds,sprites.water[i],px,py,0,scale,scale)
        end
      end
      if ground == "sand" then
        for i = 1,4 do
          love.graphics.draw(sprites_grounds,sprites.rock[i],px,py,0,scale,scale)
        end
      end
      if ground == "wood" then
        for i = 1,4 do
          love.graphics.draw(sprites_grounds,sprites.corn[i],px,py,0,scale,scale)
        end
      end
    end
  end

  -- draw loot
  loot.draw()

  -- draw player
  local c = client.data
  if c.r and c.g and c.b and c.x and c.y and not c.inPlane then
    -- visual area
    love.graphics.setColor( 30, 30, 30, 40 )
    love.graphics.circle("fill",c.x,c.y, 2)
    -- draw body
    -- love.graphics.setColor( c.r, c.g, c.b )
    -- love.graphics.rectangle("fill", c.x - 1, c.y - 1, 2, 2 )
    -- draw head
    -- love.graphics.setColor( 100, 100, 100, 255 )
    -- love.graphics.rectangle("fill", c.x - .5, c.y - .5, 1, 1 )
    -- love.graphics.rotate(math.rad(c.viewDirection/.3))
    -- love.graphics.push()
    -- love.graphics.pop()

    -- body animations
    love.graphics.setColor(255,255,255,255)
    local player_scale = sprites_player_scale
    animation_legs:draw(sprites_player, c.x, c.y,-math.rad(c.bodyDirection),player_scale, player_scale, 6, 6)
    animation_body:draw(sprites_player, c.x, c.y,-math.rad(c.bodyDirection),player_scale, player_scale, 6, 6)
    animation_head:draw(sprites_player, c.x, c.y,-math.rad(c.viewDirection),player_scale, player_scale, 6, 6)

  end

  -- draw enemies
  for key,value in pairs(enemies) do
    if value.x and value.y and value.r and value.g and value.b then
      love.graphics.setColor( value.r, value.g, value.b, value.lastSeen * 255 )
      love.graphics.rectangle("fill", value.x - 1, value.y - 1, 2, 2 )
    end
  end

  -- draw car
  auto:draw()


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


  -- -- draw enemies
  -- for key,value in pairs(enemies) do
  --   if value.x and value.y and value.r and value.g and value.b and value.aimX and value.aimY then
  --     love.graphics.setColor( value.r, value.g, value.b, value.lastSeen * 255 )
  --     local x = value.x - client.data.x
  --     local y = value.y - client.data.y
  --     x = x*2*scale + w/2
  --     y = y*2*scale + h/2
  --
  --     love.graphics.rectangle("fill", x - playerSize, y - playerSize, playerSize*2, playerSize*2 )
  --     -- draw enemy aim
  --     love.graphics.setColor( 100, 100, 100, 100 )
  --     love.graphics.setLineStyle("smooth")
  --     love.graphics.line(x,y,x+value.aimX,y+value.aimY)
  --   end
  -- end

  -- -- draw aim
  -- love.graphics.setColor( 100, 100, 100, 100 )
  -- love.graphics.setLineStyle("smooth")
  -- love.graphics.line(w/2,h/2,w/2+c.aimX,h/2+c.aimY)

  -- draw visual area
  love.graphics.setColor( 30, 30, 30, 40 )
  -- love.graphics.circle("fill",love.graphics.getWidth()/2,love.graphics.getHeight()/2, 250)

  -- -- draw player
  -- local c = client.data
  -- love.graphics.setColor( c.r, c.g, c.b )
  -- local px = w/2 - playerSize*mapZoomScale/10
  -- local py = h/2 - playerSize*mapZoomScale/10
  -- local pw = playerSize*mapZoomScale/10*2
  -- local ph = playerSize*mapZoomScale/10*2
  -- if pw < 1 then pw = 1 end
  -- if ph < 1 then ph = 1 end
  -- love.graphics.rectangle("fill", px,py, pw, ph )
  -- -- love.graphics.circle("fill", love.graphics.getWidth()/2 - playerSize,love.graphics.getHeight()/2 - playerSize, playerSize*2 )


  -- -- draw death zone
  -- if gameInfo and gameInfo.zone_scale then
  --   local x = 0
  --   local y = 0
  --   if gameInfo.zone_x >= client.data.x then
  --     x = gameInfo.zone_x - client.data.x
  --   elseif gameInfo.zone_x < client.data.x then
  --     x = gameInfo.zone_x - client.data.x
  --   end
  --   if client.data.y >= gameInfo.zone_y then
  --      y = gameInfo.zone_y - client.data.y
  --   elseif client.data.y < gameInfo.zone_y then
  --     y = gameInfo.zone_y - client.data.y
  --   end
  --   x = x*2*scale + w/2
  --   y = y*2*scale + h/2
  --   love.graphics.setColor( 230, 130, 130, 100 )
  --   love.graphics.circle("line",x,y,gameInfo.zone_scale*2*scale)
  --
  --   if gameInfo.zone_target_x >= client.data.x then
  --     x = gameInfo.zone_target_x - client.data.x
  --   elseif gameInfo.zone_target_x < client.data.x then
  --     x = gameInfo.zone_target_x - client.data.x
  --   end
  --   if client.data.y >= gameInfo.zone_target_y then
  --      y = gameInfo.zone_target_y - client.data.y
  --   elseif client.data.y < gameInfo.zone_target_y then
  --     y = gameInfo.zone_target_y - client.data.y
  --   end
  --   x = x*2*scale + w/2
  --   y = y*2*scale + h/2
  --   love.graphics.setColor( 130, 130, 130, 100 )
  --   love.graphics.circle("line",x,y,gameInfo.zone_target_scale*2*scale)
  -- end
end

function client.drawOverlay()
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

  -- draw plane queue state
  if gameInfo.inPlaneQueue then
    love.graphics.setColor(255,255,0)
    love.graphics.printf("Plane Queue",5,55,love.graphics.getWidth(),"left")
  end


  -- draw game clock
  love.graphics.setColor(255,255,0)
  love.graphics.printf(game.clock,5,65,love.graphics.getWidth(),"left")

  -- draw client ping
  love.graphics.setColor(255,255,0)
  local ping = client.ping or ""
  love.graphics.printf("PING "..ping,5,75,love.graphics.getWidth(),"left")

  -- draw fps
  love.graphics.setColor(255,255,0)
  love.graphics.printf("FPS "..love.timer.getFPS() or "",5,85,love.graphics.getWidth(),"left")

  -- draw plane flight counter
  love.graphics.setColor(255,255,0)
  local planeFlightCounter = gameInfo.planeFlightCounter or ""
  love.graphics.printf("flight# "..planeFlightCounter,5,95,love.graphics.getWidth(),"left")

  -- draw game state
  love.graphics.setColor(0,255,0)
  local gameState = gameInfo.gameState or ""
  love.graphics.printf("gamestate "..gameState,5,105,love.graphics.getWidth(),"left")

  -- draw position
  love.graphics.setColor(0,255,0)
  local gameState = gameInfo.gameState or ""
  love.graphics.printf(round(client.data.x).." "..round(client.data.y),5,115,love.graphics.getWidth(),"left")

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

function client.movementUpdate(dt)
  movementUpdateTimer = movementUpdateTimer + dt
  if movementUpdateTimer >= movementUpdateTimerRate then
    movementUpdateTimer = 0
  else
    return
  end

  -- position update
  local target = {}
  target.x = client.data.x
  target.y = client.data.y
  local running = 0
  local x = 0
  local y = 0
  client.data.isWalking = false
  client.data.isRunning = false
  if love.keyboard.isDown('lshift') and client.data.running > 1 then
    running = .1
    client.data.running = client.data.running - running
    client.data.isRunning = true
    if client.data.running < 1 then
      client.data.running = 0
      client.data.isRunning = false
    end
  end
  local speed = client.speedWalking
  if client.data.isRunning then speed = client.speedRunning end
  if love.keyboard.isDown('up') or love.keyboard.isDown('w') then
    x, y = distantPointWithAngleAndLength(client.data.viewDirection, speed)
    target.x = target.x + x
    target.y = target.y + y
    client.data.isWalking = true
  end
  if love.keyboard.isDown('left')  or love.keyboard.isDown('a') then
    x, y = distantPointWithAngleAndLength(client.data.viewDirection+90, speed)
    target.x = target.x + x
    target.y = target.y + y
    client.data.isWalking = true
  end
  if love.keyboard.isDown('down') or love.keyboard.isDown('s') then
    x, y = distantPointWithAngleAndLength(client.data.viewDirection+180, speed)
    target.x = target.x + x
    target.y = target.y + y
    client.data.isWalking = true
  end
  if love.keyboard.isDown('right') or love.keyboard.isDown('d') then
    x, y = distantPointWithAngleAndLength(client.data.viewDirection+270, speed)
    target.x = target.x + x
    target.y = target.y + y
    client.data.isWalking = true
  end
  -- print(client.data.viewDirection,speed, x, y, target.x,target.y)

  -- adjust body rotation
  client.data.bodyDirection = client.data.bodyDirection - (client.data.bodyDirection - client.data.viewDirection)/client.data.bodyDirectionRate

  -- collision check
  -- if isBuilding(target.x,target.y) then
  --   client.data.x = client.data.x
  --   client.data.y = client.data.y
  -- else
  --   client.data.x = target.x
  --   client.data.y = target.y
  -- end

  -- plane check
  if gameInfo.inPlane and gameInfo.planeX then
    target.x = gameInfo.planeX
    target.y = gameInfo.planeY
  end

  client.data.x = target.x
  client.data.y = target.y


  -- ground check
  local r = 0
  if client.data.x >= 0 and client.data.x < 500 and client.data.y >= 0 and client.data.y < 500 then
    r = bg_image:getPixel( client.data.x*2, client.data.y*2 )
  end
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

  -- plane check
  client.data.inPlane = gameInfo.inPlane

  -- update shooting state
  if love.mouse.isDown(1) then
    client.data.isShooting = true
  else
    client.data.isShooting = false
  end

  -- shooting attempt
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
end

function client.update(dt)
  -- plane update
  plane.updatePosition()

  -- colisionchecks etc.
  client.movementUpdate(dt)

  -- animation updates
  local dt2 = dt
  if client.data.isWalking then
    animation_head:resume()
    animation_body:resume()
    animation_legs:resume()
    if client.data.isRunning then
      dt2 = dt2 * 2
    end
  else
    animation_head:pauseAtStart()
    animation_body:pauseAtStart()
    animation_legs:pauseAtStart()

  end
  animation_head:update(dt2)
  animation_body:update(dt2)
  animation_legs:update(dt2)



  -- send client info
  if not client.inPlane then
    client.sendDataToServer(dt)
    client.sendPositionToServer(dt)
  end

  -- always update
  Net:update(dt)
end


function client.getGround(x,y)
  local r = 0
  local ground = ""
  -- update ground
  if x >= 0 and x < 500 and y >= 0 and y < 500 then
    r = bg_image:getPixel( x*2, y*2 )
  end
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
  return ground
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
  Net:send({time=game.clock},"tik",nil)
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
    love.mouse.setRelativeMode( show_map )
  end

  if key == 'f' then
    client.data.inPlane = false
    client.sendMetaToServer()
  end

end
