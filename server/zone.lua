zone = {}

idleTimeDefault = 2

function zone.load()
  zone.animation = nil
  zone.damage = 25
  zone.x = 0
  zone.y = 0
  zone.scale = 0
  zone.min_scale = 20
  zone.target_x = 0
  zone.target_y = 0
  zone.target_scale = 0
  zone.idleTime = 0
  zone.active = false
  zone.state = 'wait'
end

function zone.draw()
  if zone.active then
    -- draw death zone
    love.graphics.setColor( 255, 20, 20, 200 )
    love.graphics.circle("line",zone.x,zone.y,zone.scale)
    -- draw death zone target
    love.graphics.setColor( 20, 255, 20, 100 )
    love.graphics.circle("line",zone.target_x,zone.target_y,zone.target_scale)
  end

  -- draw zone state
  love.graphics.setColor(255,255,0)
  love.graphics.printf(zone.state,0,5,love.graphics.getWidth(),"right")
end

function zone.update(dt)

  -- update idle time
  if zone.idleTime > 0 then
    zone.idleTime = zone.idleTime - dt
    if zone.idleTime < 0 then
      zone.idleTime = 0
    end
  end

  -- death zone updates
  if zone.idleTime == 0 and zone.animation then
    local complete = zone.animation:update(dt)
    if complete then
      zone.animation = nil
      createTargetDeathZone()
      zone.startCyclus()
      zone.state = 'waiting'
    else
      zone.state = 'moving'
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
  if zone.active then
    for k,c in pairs( players ) do
      if c.x and c.y then
        square_dist = (c.x - zone.x)^2 + (c.y - zone.y)^2
        if square_dist > zone.scale^2 and not c.inPlane then
          local dmg = c.health - zone.damage * dt
          if dmg < 0 then dmg = 0 end
          c.health = dmg
          -- print(k," in zone ",c.x,c.y,zone.x,zone.y,square_dist)
        else
          -- print(k," not in zone ",c.x,c.y,zone.x,zone.y,square_dist)
        end
      end
    end
  end
end

function zone.keypressed(key)
end

function zone.startCyclus()
  zone.idleTime = idleTimeDefault
  zone.animation = tween.new(plane.speed*GAMESPEED*3,zone,{x=zone.target_x,y=zone.target_y,scale=zone.target_scale},'linear')
  plane.startSupport()
end

function zone.reset()
  if zone.animation then
    zone.animation:reset()
    zone.animation = nil
  end
  zone.state = 'off'
  server.clock = 0
  zone.x = 250
  zone.y = 250
  zone.scale = 350
  zone.active = false
  zone.idleTime = 0
end

function zone.start()
  server.clock = 0
  zone.x = 250
  zone.y = 250
  zone.scale = 350
  zone.active = true
  createTargetDeathZone()
  zone.startCyclus()
  zone.state = 'waiting'
end

function createTargetDeathZone()
  zone.target_scale = math.floor(math.random(zone.scale/3,zone.scale/4*3))
  zone.target_x = zone.x + math.floor(math.random(-zone.target_scale,zone.target_scale)/3)
  zone.target_y = zone.y + math.floor(math.random(-zone.target_scale,zone.target_scale)/3)
  if zone.target_scale < zone.min_scale then zone.min_scale = zone.target_scale end
end
