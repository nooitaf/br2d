plane = {}
tween = require 'lib/tween'

function plane.load()
  plane.img = love.graphics.newImage("assets/plane.png")
  plane.img:setFilter("nearest","nearest")
  plane.sizeX = 32
  plane.sizeY = 32
  plane.smokeImage = love.graphics.newImage("assets/smoke.png")
  plane.smokeImage:setFilter("nearest","nearest")
  plane.ps = love.graphics.newParticleSystem(plane.smokeImage,64)
  plane.ps:setParticleLifetime(10*GAMESPEED,15*GAMESPEED)
  plane.ps:setEmissionRate(2/GAMESPEED)
  plane.ps:setSizeVariation(.1)
  plane.ps:setSpin(4,.1)
  plane.ps:setSizes(.2,.8,1,1,1,1)
  plane.ps:setLinearAcceleration(-.1,-.1,.1,.1)
  plane.ps:setColors(255,0,0,255,0,255,0,0)
  plane.x = -100
  plane.y = -100
  plane.targetX = 400
  plane.targetY = 400
  plane.angle = 0
  plane.animation = nil
  plane.active = false
  plane.items = {}
  -- plane.startCarrier()
end

function plane.draw()
  -- smoke
  if plane.ps:getCount() then
    love.graphics.setColor(255,255,255)
    love.graphics.draw(plane.ps,0,0)
  end
  -- plane
  if plane.active then
    love.graphics.setColor(255,255,255)
    local angle = gameInfo.planeAngle
    -- local rad = radiansWithDegrees(angle)
    local rad = math.rad(angle)

    -- draw plane on map
    love.graphics.draw(plane.img,plane.x,plane.y,-rad,0.2,0.2,plane.sizeX,plane.sizeY)
  end
end


function plane.update(dt)
  plane.ps:moveTo(plane.x,plane.y)
  plane.ps:update(dt)

  if plane.animation then
    local complete = plane.animation:update(dt)
    if complete then
      plane.ps:stop()
    end
  end
end


function plane.updatePosition()
  if gameInfo.planeActive then
    plane.active = true
    plane.animation = tween.new(1/400,plane,{x=gameInfo.planeX, y=gameInfo.planeY},'inCubic')
    plane.ps:start()
  else
    plane.active = false
    plane.ps:stop()
  end
end




function angleFromPoint(x,y,x2,y2)
  local dy = (y - y2)
  local dx = (x - x2)
  local theta = math.atan2(dy,dx)
  local angle = (90 - ((theta * 180) / math.pi)) % 360
  return angle
end

function radiansWithDegrees(deg)
  return deg * math.pi / 180
end
