
function round(x)
  return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

function isBuilding(x,y)
  -- update ground
  if x >= 0 and x < 250 and y >= 0 and y < 250 then
    local r = game.map.imageData:getPixel( x*2, y*2 )
    return r == 255
  end
end

function dist(x1,y1,x2,y2)
  return math.sqrt( (x1 - x2)^2 + (y1 - y2)^2 )
end

function isBuildingWithScale(x,y,s)
  print(client.data.inPlane)
  if not client.data.inPlane then
    -- update ground
    local r1 = game.map.imageData:getPixel( x*2-s/2, y*2 )
    local r2 = game.map.imageData:getPixel( x*2+s/2, y*2 )
    local r3 = game.map.imageData:getPixel( x*2, y*2-s/2 )
    local r4 = game.map.imageData:getPixel( x*2, y*2+s/2 )
    -- print(r1,r2,r3,r4)
    return r1 == 255 or r2 == 255 or r3 == 255 or r4 == 255
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

function distantPointWithAngleAndLength(angle,length)

  print("angle/length",angle,length)
  -- if angle < 0 then angle = angle + 360000 end
  local dir = 0
  if angle > 270 then
    angle = 90 - (angle - 270)
    dir = 0
  elseif angle > 180 and angle < 270 then
    angle = angle - 180
    dir = 1
  elseif angle > 90 and angle < 180 then
    angle = 90 - (angle - 90)
    dir = 2
  elseif angle < 90 and angle > 0 then
    angle = angle
    dir = 3
  elseif angle == 0 then
    return 0,-length
  elseif angle == 90 then
    return -length,0
  elseif angle == 180 then
    return 0,length
  elseif angle == 270 then
    return length,0
  end

  local c = length
  local A = math.rad(angle)
  local C = math.rad(90)
  local B = A - C
  local b = c/math.sin(C) * math.sin(B)
  local a = b/math.sin(B) * math.sin(A)

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
