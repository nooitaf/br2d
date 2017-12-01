local class = require 'lib/middleclass'
local anim8 = require 'lib/anim8'
local Player = class('Player')

local sprites_player, animation_head, animation_body, animation_legs

function Player:initialize()
  self.speed = 0.001
  self.speedWalking = 0.02 -- realistic 0.02
  self.speedRunning = 0.05 -- realistic 0.03
  self.name = "Nick"
  self.clock = 0
	self.r = 255
	self.g = 100
  self.b = 0
  self.x = 201.2
  self.y = 189.5
  self.viewDirection = 0
  self.bodyDirection = 0
  self.bodyDirectionRate = 5
  self.aimX = 0
  self.aimY = 0
  self.isWalking = false
  self.isRunning = false
  self.runningLimit = 50
  self.runningLimitIncrease = .01
  self.running = self.runningLimit
  self.inPlane = true
  self.inPlaneQueue = true
  self.inVehicle = false
  self.vehicle = nil
  self.isShooting = false
  self.shootTimer = 0
  self.shootTimerTrigger = 1/10
  self.bullets = {}

  self.nettimer = 0
  self.nettimer_trigger = 1/5
  self.netpositiontimer = 0
  self.netpositiontimer_trigger = 1/30
  self.movementUpdateTimer = 0
  self.movementUpdateTimerRate = 1/30
  self.ground = "water"

  sprites_player = love.graphics.newImage('assets/sprites_player.png')
  sprites_player_scale = 0.03
  sprites_player:setFilter("nearest","nearest")
  local pg = anim8.newGrid(12, 12, sprites_player:getWidth(), sprites_player:getHeight())
  animation_legs = anim8.newAnimation(pg(1,1,'4-5',1), 0.1)
  animation_body = anim8.newAnimation(pg(1,2,'4-5',2), 0.1)
  animation_head = anim8.newAnimation(pg(1,3,'4-5',3), 0.1)

end

function Player:setPosition(x,y)
  self.x = x
  self.y = y
end

function Player:mousemoved(x,y,dx,dy,istouch)
  self.viewDirection = self.viewDirection - dx/10
  local x, y = distantPointWithAngleAndLength(self.viewDirection, 10*game.map.zoom)
  -- print(self.viewDirection,game.map.zoom)
  -- print("mouse",dx,dy)
  self.aimX = x
  self.aimY = y
end

function Player:update(dt)
  -- update movement
  self:movementUpdate(dt)

  -- send client info
  if not self.inPlane then
    -- self:sendDataToServer(dt)
    self:sendPositionToServer(dt)
  end

end

function Player:movementUpdate(dt)
  self.movementUpdateTimer = self.movementUpdateTimer + dt
  if self.movementUpdateTimer >= self.movementUpdateTimerRate then
    self.movementUpdateTimer = 0
  else
    return
  end

  -- rotation fix
  if self.viewDirection < 0 then self.viewDirection = self.viewDirection + 360000 end
  -- position update
  local target = {}
  target.x = self.x
  target.y = self.y
  local running = 0
  local x = 0
  local y = 0
  self.isWalking = false
  self.isRunning = false
  if love.keyboard.isDown('lshift') and self.running > 1 then
    running = .1
    self.running = self.running - running
    self.isRunning = true
    if self.running < 1 then
      self.running = 0
      self.isRunning = false
    end
  end
  local speed = self.speedWalking
  if self.isRunning then speed = self.speedRunning end
  if love.keyboard.isDown('up') or love.keyboard.isDown('w') then
      x, y = distantPointWithAngleAndLength(self.viewDirection, speed)
      target.x = target.x + x
      target.y = target.y + y
      self.isWalking = true
    -- end
  end
  if love.keyboard.isDown('left')  or love.keyboard.isDown('a') then
    x, y = distantPointWithAngleAndLength(self.viewDirection+90, speed)
    target.x = target.x + x
    target.y = target.y + y
    self.isWalking = true
  end
  if love.keyboard.isDown('down') or love.keyboard.isDown('s') then
    x, y = distantPointWithAngleAndLength(self.viewDirection+180, speed)
    target.x = target.x + x
    target.y = target.y + y
    self.isWalking = true
  end
  if love.keyboard.isDown('right') or love.keyboard.isDown('d') then
    x, y = distantPointWithAngleAndLength(self.viewDirection+270, speed)
    target.x = target.x + x
    target.y = target.y + y
    self.isWalking = true
  end
  -- print(self.viewDirection,speed, x, y, target.x,target.y)



  -- adjust body rotation
  self.bodyDirection = self.bodyDirection - (self.bodyDirection - self.viewDirection)/self.bodyDirectionRate

  -- collision check
  -- if isBuilding(target.x,target.y) then
  --   self.x = self.x
  --   self.y = self.y
  -- else
  --   self.x = target.x
  --   self.y = target.y
  -- end

  -- plane check
  if game.info.inPlane and game.info.planeX then
    target.x = game.info.planeX
    target.y = game.info.planeY
  end

  if self.inVehicle then
    local v = self.vehicle

    v:checkKeyboard()
    self.isWalking = false
    target.x = v.x
    target.y = v.y
  end


  self.x = target.x
  self.y = target.y


  -- ground check
  local r = 0
  if self.x >= 0 and self.x < 500 and self.y >= 0 and self.y < 500 then
    r = game.map.imageData:getPixel( self.x*2, self.y*2 )
  end
  if r >= 250 then
    self.ground = "house"
  elseif r < 150 and r >= 110 then
    self.ground = "snow"
  elseif r < 110 and r >= 70 then
    self.ground = "stone"
  elseif r < 70 and r >= 50 then
    self.ground = "wood"
  elseif r < 50 and r >= 20 then
    self.ground = "gras"
  elseif r < 20 and r >= 10 then
    self.ground = "sand"
  elseif r < 10 and r >= 0 then
    self.ground = "water"
  end

  -- update walking speed
  if self.ground == "water" then
    self.speed = 2
  elseif self.ground == "sand" then
    self.speed = 4
  elseif self.ground == "gras" then
    self.speed = 5
  elseif self.ground == "wood" then
    self.speed = 6
  elseif self.ground == "stone" then
    self.speed = 8
  elseif self.ground == "snow" then
    self.speed = 10
  elseif self.ground == "house" then
    self.speed = 1
  end

  -- update running
  if self.running < self.runningLimit then
    self.running = self.running + self.runningLimitIncrease
  end


  -- plane check
  self.inPlane = game.info.inPlane

  -- update shooting state
  if love.mouse.isDown(1) then
    self.isShooting = true
  else
    self.isShooting = false
  end

  -- shooting attempt
  if self.isShooting then
    self.shootTimer = self.shootTimer + dt
    if self.shootTimer > self.shootTimerTrigger then
      local bullet = {
        x = self.x,
        y = self.y,
        tx = self.aimX,
        ty = self.aimY,
        animation = nil,
        dmg = 20
      }
      table.insert(self.bullets,bullet)
      bullet.animation = tween.new(3,bullet,{x=self.aimX,y=self.aimY},'linear')
      self.shootTimer = 0
      print("shooting")
    end
    if self.bullets then
      for _,b in pairs(self.bullets) do
        if b.animation and not b.animation == true then
          b.animation:update(dt)
        end
      end
    end
  end
  -- animation updates
  local dt2 = dt
  if self.isWalking then
    animation_head:resume()
    animation_body:resume()
    animation_legs:resume()
    if self.isRunning then
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

end

function Player:draw()
  -- draw player
  local c = self
  if c.r and c.g and c.b and c.x and c.y and not c.inPlane then
    -- visual area
    love.graphics.setColor( 30, 30, 30, 40 )
    love.graphics.circle("fill",c.x,c.y, 2)

    -- body animations
    love.graphics.setColor(255,255,255,255)
    local player_scale = sprites_player_scale
    animation_legs:draw(sprites_player, c.x, c.y,-math.rad(c.bodyDirection),player_scale, player_scale, 6, 6)
    animation_body:draw(sprites_player, c.x, c.y,-math.rad(c.bodyDirection),player_scale, player_scale, 6, 6)
    animation_head:draw(sprites_player, c.x, c.y,-math.rad(c.viewDirection),player_scale, player_scale, 6, 6)

  end
end


function Player:getInfo()
  local info = {
    speed = self.speed,
    speedWalking = self.speedWalking,
    speedRunning = self.speedRunning,
    name = self.name,
    clock = self.clock,
    r = self.r,
    g = self.g,
    b = self.b,
    x = self.x,
    y = self.y,
    viewDirection = self.viewDirection,
    bodyDirection = self.bodyDirection,
    aimX = self.aimX,
    aimY = self.aimY,
    isWalking = self.isWalking,
    isRunning = self.isRunning,
    running = self.running,
    inPLane = self.inPlane,
    inPlaneQueue = self.inPlaneQueue,
    isShooting = self.isShooting,
    shootTimer = self.shootTimer
  }
  return info
end


function Player:sendDataToServer(dt)
  self.nettimer = self.nettimer + dt
  if (self.nettimer > self.nettimer_trigger) then
    self.nettimer = 0
    local info = self:getInfo()
    Net:send( info, "updateClientInfo", nil )
    self.sendMetaToServer()
  end
end

function Player:sendMetaToServer()
  local meta = {
    name = self.name,
    inPlane = self.inPlane,
    r = self.r,
    g = self.g,
    b = self.b
  }
  Net:send( meta, "updateClientMeta", nil )
  Net:send({time=game.clock},"tik",nil)
end

function Player:sendPositionToServer(dt)
  self.netpositiontime = self.netpositiontimer + dt
  if (self.netpositiontimer > self.netpositiontimer_trigger) and not self.inPlane then
    self.netpositiontimer = 0
    local data = {
      x = self.x,
      y = self.y,
      d = self.viewDirection
    }
    Net:send( data, "updateClientPosition", nil )
  end
end



return Player
