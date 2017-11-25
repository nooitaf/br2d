local class = require 'lib/middleclass'
local Vehicle = require 'vehicle'

local Car = class('Car', Vehicle)

function Car:initialize(wheels, seats, doors)
  Vehicle.initialize(self)
  self.wheels = wheels
  self.seats = seats
  self.doors = doors
end

return Car
