debug = false
GAMESPEED = .3

math.randomseed(os.clock())

require('lib/common')
require('client')
require('game')
require('loot')
require('plane')
require('car')
local gamera = require("lib/gamera")
local camera = gamera.new(0,0,500,500)

function love.load()
  camera:setWorld(-500,-500,1000,1000)
  camera:setWindow(0,0,love.graphics.getWidth(),love.graphics.getHeight())

  local x = 500+math.random(0,200)
  local y = math.random(0,200)
  love.window.setMode(250, 250, {
    resizable=true,
    vsync=false,
    minwidth=250,
    minheight=250,
    x=x,
    y=y,
    display=2
  })

  bg_img = love.graphics.newImage("assets/map.png")
  bg_img:setFilter("nearest","nearest")

  font = love.graphics.newFont("assets/font.ttf",14)
  love.graphics.setFont(font)

  bgcolor = {r=148,g=191,b=19}
  fontcolor = {r=46,g=115,b=46}

  client.load()
  game.load()
  loot.load()
  plane.load()
end

function love.resize(w,h)
  camera:setWindow(0,0,love.graphics.getWidth(),love.graphics.getHeight())
end

function love.draw()
  love.graphics.clear()
  love.graphics.setColor(bgcolor.r,bgcolor.g,bgcolor.b)
  love.graphics.rectangle("fill",0,0 ,love.graphics.getWidth(),love.graphics.getHeight())
  love.graphics.setColor(255,255,255)
  game.draw()
  if show_map then
    camera:setScale(mapZoomScale)
    if gameInfo.inPlane then
      camera:setPosition(plane.x, plane.y)
    else
      camera:setPosition(client.data.x, client.data.y)
    end
    camera:setAngle(math.rad(-client.data.viewDirection))
  else
    camera:setPosition(250,250)
    camera:setScale(1)
    camera:setAngle(0)
  end
  camera:draw(function(l,t,w,h)
    client.draw()
    -- loot.draw()
    plane.draw()
  end)
  client.drawOverlay()
end

function love.update(dt)
  game.update(dt)
  client.update(dt)
  plane.update(dt)
end

function love.keypressed(key)
  client.keypressed(key)
  game.keypressed(key)
  if key == "`" then
    debug = not debug
  end
  if key == "q" then
    love.window.close()
    love.event.quit()
  end
end

function love.mousemoved(x,y,dx,dy,istouch)
  client.mousemoved(x,y,dx,dy,istouch)
end
