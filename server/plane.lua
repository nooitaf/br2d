plane = {}
tween = require 'lib/tween'

function plane.load()
  plane.img = love.graphics.newImage("assets/plane.png")
  plane.img:setFilter("nearest","nearest")
  plane.x = 100
  plane.y = 100
  plane.targetX = 400
  plane.targetY = 400
  plane.speed = 2
  plane.angle = 0
  plane.animation = nil
  plane.jumpTimer = 10
  plane.isCarrier = false
  plane.active = false
  plane.items = {}
  plane.startCarrier()
end

function plane.draw()
  if plane.active then
    love.graphics.setColor(255,255,255)
    local angle = angleFromPoint(plane.x,plane.y,plane.targetX,plane.targetY)
    local rad = radiansWithDegrees(angle)
    love.graphics.draw(plane.img,plane.x,plane.y,-rad,0.5,0.5,32,32)
    -- love.graphics.rectangle("fill",plane.x-2,plane.y-2,4,4)
  end
end


function plane.update(dt)
  if plane.animation then

    plane.jumpTimer = plane.jumpTimer - dt
    if plane.jumpTimer <= 0 then

      if plane.type == 'support' then

        local item = table.remove(plane.items)
        if item then
          dropSupportBox(plane.x,plane.y,10,item)
        end


      elseif plane.type == 'carrier' then
        for u,c in pairs( players ) do
          if c.inPlane then
            c.inPlane = false
          end
        end
      end
    end

    local complete = plane.animation:update(dt)
    if complete then
      plane.animation = nil
      plane.active = false
      if plane.type == 'carrier' then
        zone.start()
      elseif plane.type == 'support' then

      end
    end

  end
end




function plane.startCarrier()
  plane.createFlight()
  plane.type = 'carrier'
  plane.animation = tween.new(plane.speed,plane,{x=plane.targetX, y=plane.targetY},'linear')
  plane.jumpTimer = plane.speed - 1
  plane.active = true
end


function plane.startSupport()
  plane.createFlight()
  plane.type = 'support'
  table.insert(plane.items,"gun")
  plane.animation = tween.new(plane.speed,plane,{x=plane.targetX, y=plane.targetY},'linear')
  plane.jumpTimer = math.random()*plane.speed/8*7
  plane.active = true
end



function plane.createFlight()
  local dir = math.random(0,3)
  if dir == 0 then
    plane_start = { x=math.random(100,400), y=500 }
    plane_end = { x=math.random(100,400), y=0 }
  elseif dir == 1 then
    plane_start = { y=math.random(100,400), x=500 }
    plane_end = { y=math.random(100,400), x=0 }
  elseif dir == 2 then
    plane_start = { x=math.random(100,400), y=0 }
    plane_end = { x=math.random(100,400), y=500 }
  elseif dir == 3 then
    plane_start = { y=math.random(100,400), x=0 }
    plane_end = { y=math.random(100,400), x=500 }
  end
  plane.x = plane_start.x
  plane.y = plane_start.y
  plane.targetX = plane_end.x
  plane.targetY = plane_end.y
  plane.angle = angleFromPoint(plane.x,plane.y,plane.targetX,plane.targetY)
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
