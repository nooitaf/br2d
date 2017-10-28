zone = {}

function zone.load()
  zone.animation = nil
  zone.damage = 25
  zone.x = 0
  zone.y = 0
  zone.scale = 0
  zone.target_x = 0
  zone.target_y = 0
  zone.target_scale = 0
  zone.min_scale = 2
  zone.idleTime = 0
end

function zone.draw()
  -- draw death zone
  love.graphics.setColor( 130, 130, 230, 100 )
  love.graphics.circle("line",zone.x,zone.y,zone.scale)

  -- draw death zone target
  love.graphics.setColor( 230, 30, 30, 100 )
  love.graphics.circle("line",zone.target_x,zone.target_y,zone.target_scale)
end

function zone.update(dt)

  -- death zone updates
  if zone.idleTime == 0 and zone.animation then
    local complete = zone.animation:update(dt)
    if complete then
      zone.animation = nil
      createTargetDeathZone()
      zone.startCyclus()
    end
  end

  -- update idle time
  if zone.idleTime > 0 then
    zone.idleTime = zone.idleTime - dt
    if zone.idleTime < 0 then
      zone.idleTime = 0
    end
  end

  -- update game info
  gameInfo.zone_x = zone.x
  gameInfo.zone_y = zone.y
  gameInfo.zone_scale = zone.scale

  gameInfo.zone_target_x = zone.target_x
  gameInfo.zone_target_y = zone.target_y
  gameInfo.zone_target_scale = zone.target_scale

  -- calc player damage
  for k,c in pairs( Net.users ) do
    if c.x and c.y then
      square_dist = (c.x - zone.x)^2 + (c.y - zone.y)^2
      if square_dist > zone.scale^2 then
        local dmg = Net.users[k].health - zone.damage * dt
        if dmg < 0 then dmg = 0 end
        Net.users[k].health = dmg
        -- print(k," in zone ",c.x,c.y,zone.x,zone.y,square_dist)
      else
        -- print(k," not in zone ",c.x,c.y,zone.x,zone.y,square_dist)
      end
    end
  end
end

function zone.keypressed(key)
end

function zone.startCyclus()
  zone.idleTime = 2
  zone.animation = tween.new(10,zone,{x=zone.target_x,y=zone.target_y,scale=zone.target_scale},'linear')
end

function zone.restart()
  server.clock = 0
  zone.x = 250
  zone.y = 250
  zone.scale = 350
  createTargetDeathZone()
  zone.startCyclus()
end

function createTargetDeathZone()
  zone.target_scale = math.floor(math.random(zone.scale/3,zone.scale/4*3))
  zone.target_x = zone.x + math.floor(math.random(-zone.target_scale,zone.target_scale)/3)
  zone.target_y = zone.y + math.floor(math.random(-zone.target_scale,zone.target_scale)/3)
  if zone.target_scale < zone.min_scale then zone.min_scale = zone.target_scale end
end
