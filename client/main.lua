debug = false

require('client')
require('game')

function love.load()
  bg_img = love.graphics.newImage("assets/map.png")
  bg_img:setFilter("nearest","nearest")

  font = love.graphics.newFont("assets/font.ttf",14)
  love.graphics.setFont(font)

  bgcolor = {r=148,g=191,b=19}
  fontcolor = {r=46,g=115,b=46}

  client.load()
  game.load()
end

function love.draw()
  love.graphics.clear()
  love.graphics.setColor(bgcolor.r,bgcolor.g,bgcolor.b)
  love.graphics.rectangle("fill",0,0 ,love.graphics.getWidth(),love.graphics.getHeight())
  love.graphics.setColor(255,255,255)
  game.draw()
  client.draw()
end

function love.update(dt)
  game.update(dt)
  client.update(dt)
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
