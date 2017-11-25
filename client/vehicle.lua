local class = require 'lib/middleclass'
local anim8 = require 'lib/anim8'
local Vehicle = class('Vehicle')

local sprites_vehicles, sprites_vehicles_scale, vg, animation_vehicle

function Vehicle:initialize()
  self.x = 0
  self.y = 0
  self.r = 0
  self.speed = 0

  sprites_vehicles = love.graphics.newImage('assets/sprites_player.png')
  sprites_vehicles_scale = 0.03
  sprites_vehicles:setFilter("nearest","nearest")
  local vg = anim8.newGrid(24, 12, sprites_vehicles:getWidth(), sprites_vehicles:getHeight())
  animation_vehicle = anim8.newAnimation(vg(1,4), 0.1)
end

function Vehicle:setPosition(x,y)
  self.x = x
  self.y = y
end

function Vehicle:setRotation(r)
  self.r = r
end

function Vehicle:moveForward()
  self.x,self.y = distantPointWithAngleAndLength(self.r,self.speed)
end

function Vehicle:draw()
  love.graphics.setColor( 230, 30, 30, 40 )
  love.graphics.circle("fill",self.x,self.y, 1, 30)
  love.graphics.setColor(255,255,255,255)
  animation_vehicle:draw(sprites_vehicles, self.x, self.y,-math.rad(self.r),sprites_vehicles_scale, sprites_vehicles_scale, 6, 6)
end

return Vehicle
