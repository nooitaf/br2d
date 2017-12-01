local class = require 'lib/middleclass'
local anim8 = require 'lib/anim8'
local Vehicle = class('Vehicle')

local sprites_vehicles, sprites_vehicles_scale, vg, animation_vehicle

function Vehicle:initialize()
  self.x = 0
  self.y = 0
  self.rotation = 0
  self.size = 10
  self.speed = 0
  self.maxSpeedForward = 50
  self.maxSpeedReverse = -10
  self.maxRotationLeft = -45
  self.maxRotationRight = 45
  self.wheels = 4
  self.seats = 4
  self.doors = 4
  self.player = nil

  sprites_vehicles = love.graphics.newImage('assets/sprites_player.png')
  sprites_vehicles_scale = 0.03
  sprites_vehicles:setFilter("nearest","nearest")
  local vg = anim8.newGrid(24, 12, sprites_vehicles:getWidth(), sprites_vehicles:getHeight())
  animation_vehicle = anim8.newAnimation(vg(1,4), 0.1)
end

function Vehicle:checkKeyboard(key)
  if key and key == 'f' then
    self:leave(game.player)
    return
  end
  if key and key == 'down' or key == 's' then
    self:accelerate(-3)
    return
  end
  if love.keyboard.isDown('up') or love.keyboard.isDown('w') then
    if self.speed >= 0 then
      self:accelerate(3)
    elseif self.speed < 0 then
      self:brake()
    end
  end
  if love.keyboard.isDown('left')  or love.keyboard.isDown('a') then
    self:steer(-3)
  end
  if love.keyboard.isDown('down') or love.keyboard.isDown('s') then
    if self.speed > 0 then
      self:brake()
    elseif self.speed < 0 then
      self:accelerate(-3)
    end
  end
  if love.keyboard.isDown('right') or love.keyboard.isDown('d') then
    self:steer(3)
  end
end

function Vehicle:steer(direction)
  self.rotation = self.rotation - direction*(self.speed/20)
  -- if self.rotation > self.maxRotationRight then self.rotation = self.maxRotationRight end
  -- if self.rotation < self.maxRotationLeft  then self.rotation = self.maxRotationLeft end
  print('set rotation:',rotation)
end

function Vehicle:accelerate(direction)
  self.speed = self.speed + direction
  if self.speed > self.maxSpeedForward then self.speed = self.maxSpeedForward end
  if self.speed < self.maxSpeedReverse then self.speed = self.maxSpeedReverse end
end

function Vehicle:brake()
  if self.speed > 0 then self.speed = self.speed - 5 end
  if self.speed < 0 then self.speed = self.speed + 5 end
  if self.speed < 5 and self.speed > -5 then self.speed = 0 end 
end

function Vehicle:inRangeOf(player)
  local c = player
  local inRange = false
  local rangeAcceptance = 0.2
  local x = self.x
  local y = self.y
  if c.x <= (x + rangeAcceptance) and c.x >= (x - rangeAcceptance) and c.y <= (y + rangeAcceptance) and c.y >= (y - rangeAcceptance) then
    inRange = true
  end
  print(c.x,c.y,inRange,self.speed,x + rangeAcceptance)
  return inRange
end

function Vehicle:enter(player)
  player.inVehicle = true
  player.vehicle = self
  self.player = player
  print("entered vehicle")
end

function Vehicle:leave(player)
  player.inVehicle = false
  player.vehicle = nil
  self.player = nil
  print("left vehicle")
end

function Vehicle:setPosition(x,y)
  self.x = x
  self.y = y
end

function Vehicle:setRotation(rotation)
  self.rotation = rotation
end

function Vehicle:setSpeed(speed)
  self.speed = speed
end

function Vehicle:update(dt)
  if self.rotation < 0 then self.rotation = self.rotation + 360000 end
  if not self.player and self.speed > 0 then self.speed = self.speed - .05 end
  if self.speed > 0 or self.speed < 0 then
    -- print("vehicle",self.x, self.y,self.speed,self.rotation)
    local x,y = distantPointWithAngleAndLength(self.rotation+90,self.speed*dt/10)
    self.x = self.x + x
    self.y = self.y + y
  end
end

function Vehicle:draw()
  love.graphics.setColor( 230, 30, 30, 40 )
  love.graphics.circle("fill",self.x,self.y, 1, 30)
  if self:inRangeOf(game.player) or game.player.vehicle == self then
    love.graphics.setColor(255,50,50,255)
  else
    love.graphics.setColor(255,255,255,255)
  end
  animation_vehicle:draw(sprites_vehicles, self.x, self.y,-math.rad(self.rotation),sprites_vehicles_scale, sprites_vehicles_scale, 6, 6)
end

return Vehicle
