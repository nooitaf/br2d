local class = require 'lib/middleclass'
local anim8 = require 'lib/anim8'

Car = class('Car')

local sprites_vehicles, sprites_vehicles_scale, vg, animation_car

function Car:initialize(x, y, r)
  self.x = x
  self.y = y
  self.r = r
  self.speed = 0

  sprites_vehicles = love.graphics.newImage('assets/sprites_player.png')
  sprites_vehicles_scale = 0.03
  sprites_vehicles:setFilter("nearest","nearest")
  local vg = anim8.newGrid(24, 12, sprites_vehicles:getWidth(), sprites_vehicles:getHeight())
  animation_car = anim8.newAnimation(vg(1,4), 0.1)
end

function Car:moveForward()
  self.x,self.y = distantPointWithAngleAndLength(self.r,self.speed)
end

function Car:draw()
  love.graphics.setColor( 230, 30, 30, 40 )
  love.graphics.circle("fill",self.x,self.y, 2)
  love.graphics.setColor(255,255,255,255)
  animation_car:draw(sprites_vehicles, self.x, self.y,-math.rad(self.r),sprites_vehicles_scale, sprites_vehicles_scale, 6, 6)
end
