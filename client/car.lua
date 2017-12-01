local class = require 'lib/middleclass'
local Vehicle = require 'vehicle'

local Car = class('Car', Vehicle)

function Car:initialize(wheels, seats, doors)
  Vehicle.initialize(self)
  self.wheels = 4
  self.seats = 4
  self.doors = 4
end


return Car
