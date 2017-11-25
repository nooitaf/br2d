local Loot = require('loot')
local Plane = require('plane')
local Ground = require('ground')

game = {}
game.info = {}
game.map = {}
game.plane = Plane
game.loot = Loot
game.ground = Ground
game.enemies = {}
game.vehicles = {}

DEBUG = false


Net = require("lib/net")
tween = require("lib/tween")
local anim8 = require "lib/anim8"

local Vehicle = require "vehicle"
local Car = require "car"
local auto = Car:new(4,2,2)
auto:setPosition(203,189)
auto:setRotation(0)
table.insert(game.vehicles,auto)
auto = Car:new(4,2,2)
auto:setPosition(202,189)
auto:setRotation(15)
table.insert(game.vehicles,auto)

local Player = require "player"

local enemies

function game.load()
  -- clock
  game.clock = 0

  -- player
  game.player = Player:new()

  -- background map
  game.map.imageData = love.image.newImageData( 'assets/map.png' )
  game.map.image = love.graphics.newImage(game.map.imageData)
  game.map.image:setFilter("nearest","nearest")

  show_map = true

  game.info.health = 0
  game.info.playercount = 0
  game.info.playercount_alive = 0
  game.info.rank = 0
  game.info.inPlane = false

  game.map.zoom = 100
  pingtimer = 0
  pingval = 0

  game.loot.load()
  game.plane.load()
  game.ground.load()

  require('netcode')
end

function game.update(dt)
  game.clock = game.clock + dt

  -- plane update
  game.plane.updatePosition()

  -- player update
  game.player:update(dt)

  -- disappear enemies
  for k,e in pairs( game.enemies ) do
    e.lastSeen = e.lastSeen - dt
    if e.lastSeen < 0 then
      print('remove ',e.id)
      game.enemies[k] = nil
    end
  end

end

function game.draw()
  -- draw background map
  love.graphics.setColor(255,255,255)
  love.graphics.draw(game.map.image,0,0,0,0.5,0.5)

  -- debug
  pingtimer = pingtimer + 1
  if Net.connected and pingtimer > 100 then
    pingval = math.floor(Net.currentPing)
    pingtimer = 0
  end

  -- draw ground
  game.ground.draw()

  -- draw loot
  game.loot:draw()

  -- draw player
  game.player:draw()

  -- draw plane
  game.plane:draw()

  -- draw enemies
  for key,value in pairs(game.enemies) do
    if value.x and value.y and value.r and value.g and value.b then
      love.graphics.setColor( value.r, value.g, value.b, value.lastSeen * 255 )
      love.graphics.rectangle("fill", value.x - 1, value.y - 1, 2, 2 )
    end
  end

  -- draw vehicles
  for key,item in pairs(game.vehicles) do
    item:draw()
  end

  -- draw death zone
  if game.info and game.info.zone_scale then
    love.graphics.setColor( 230, 130, 130, 100 )
    love.graphics.circle("line",game.info.zone_x,game.info.zone_y,game.info.zone_scale)
    love.graphics.setColor( 130, 130, 130, 100 )
    love.graphics.circle("line",game.info.zone_target_x,game.info.zone_target_y,game.info.zone_target_scale)
  end

end


function game.keypressed(key)
  if key == 'm' then
    if show_map == true then
      show_map = false
    else
      show_map = true
    end
    love.mouse.setRelativeMode( show_map )
  end

  if key == 'f' then
    game.player.inPlane = false
    game.player:sendMetaToServer()
  end

  -- game.player.keypressed(key)
end




function game.mousemoved(x,y,dx,dy,istouch)
  game.player:mousemoved(x,y,dx,dy,istouch)
end


function game.drawOverlay()
  -- draw dead screen
  if game.info.dead then
    love.graphics.setColor(0,0,0,230)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight() )
    love.graphics.setColor(255,255,0)
    local rank = game.info.rank or 0
    love.graphics.printf("#"..rank.." of "..game.info.playercount,0,love.graphics.getHeight()/2-20,love.graphics.getWidth(),"center")
    if rank == 1 then
      love.graphics.printf("Winner winner chicken dinner!",0,love.graphics.getHeight()/2,love.graphics.getWidth(),"center")
    else
      love.graphics.printf("BETTER LUCK NEXT TIME",0,love.graphics.getHeight()/2,love.graphics.getWidth(),"center")
    end
  end

  -- draw health
  if game.info.health then
    love.graphics.setColor( 30, 30, 30, 255 )
    love.graphics.rectangle("fill", 5, 5, (love.graphics.getWidth()-10), 10 )
    local health = game.info.health
    if health < 20 then
      love.graphics.setColor( 230, 30, 30, 255 )
    elseif health >= 20 and health < 40 then
      love.graphics.setColor( 230, 130, 30, 255 )
    elseif health >= 40 and health < 70 then
      love.graphics.setColor( 230, 230, 30, 255 )
    else
      love.graphics.setColor( 230, 230, 230, 255 )
    end
    love.graphics.rectangle("fill", 5, 5, (love.graphics.getWidth()-10)/100*game.info.health, 10 )

    love.graphics.setColor(0,255,0)
    love.graphics.printf("Health "..health,5,25,love.graphics.getWidth(),"left")
  end

  -- draw ground info
  love.graphics.setColor(0,255,0)
  love.graphics.printf("Ground "..game.player.ground,5,15,love.graphics.getWidth(),"left")

  -- draw ping
  -- love.graphics.setColor(0,255,0)
  -- love.graphics.printf(pingval,5,10,love.graphics.getWidth(),"right")

  -- draw playercount
  love.graphics.setColor(0,255,0)
  love.graphics.printf("Players "..game.info.playercount_alive.."/"..game.info.playercount,5,35,love.graphics.getWidth(),"left")

  -- draw plane state
  love.graphics.setColor(0,255,0)
  love.graphics.printf(string.format("Plane %s",tostring(game.player.inPlane)),5,45,love.graphics.getWidth(),"left")

  -- draw plane queue state
  if game.info.inPlaneQueue then
    love.graphics.setColor(255,255,0)
    love.graphics.printf("Plane Queue",5,55,love.graphics.getWidth(),"left")
  end


  -- draw game clock
  love.graphics.setColor(255,255,0)
  love.graphics.printf(game.clock,5,65,love.graphics.getWidth(),"left")

  -- draw player ping
  love.graphics.setColor(255,255,0)
  local ping = game.player.ping or ""
  love.graphics.printf("PING "..ping,5,75,love.graphics.getWidth(),"left")

  -- draw fps
  love.graphics.setColor(255,255,0)
  love.graphics.printf("FPS "..love.timer.getFPS() or "",5,85,love.graphics.getWidth(),"left")

  -- draw plane flight counter
  love.graphics.setColor(255,255,0)
  local planeFlightCounter = game.info.planeFlightCounter or ""
  love.graphics.printf("flight# "..planeFlightCounter,5,95,love.graphics.getWidth(),"left")

  -- draw game state
  love.graphics.setColor(0,255,0)
  local gameState = game.info.gameState or ""
  love.graphics.printf("gamestate "..gameState,5,105,love.graphics.getWidth(),"left")

  -- draw position
  love.graphics.setColor(0,255,0)
  local gameState = game.info.gameState or ""
  love.graphics.printf(round(game.player.x).." "..round(game.player.y),5,115,love.graphics.getWidth(),"left")

end





function love.wheelmoved(x, y)
  if y > 0 then
    game.map.zoom = game.map.zoom + .1 * game.map.zoom
  elseif y < 0 then
    game.map.zoom = game.map.zoom - .1 * game.map.zoom
  end
end
