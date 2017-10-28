plane = {}
tween = require 'lib/tween'

function plane.load()
  plane.x = 100
  plane.y = 100
  plane.targetX = 400
  plane.targetY = 400
  plane.speed = 10
  plane.angle = 0
  plane.animation = nil
  plane.isCarrier = false
  plane.startCarrier()
end

function plane.draw()
  love.graphics.setColor(255,0,255,100)
  love.graphics.rectangle("fill",plane.x-10,plane.y-10,20,20)
end


function plane.update(dt)
  if plane.animation then
    local complete = plane.animation:update(dt)
    if complete then
      --  startGame()
    end
  end
end






function plane.startCarrier()
  plane.createFlight()
  plane.isCarrier = true
  plane.animation = tween.new(plane.speed,plane,{x=plane.targetX, y=plane.targetY},'linear')
end


function plane.createFlight()
  local dir = math.random(0,4)
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
