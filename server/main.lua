debug = false

require('server')
require('zone')
require('plane')

function love.load()
  bg_img = love.graphics.newImage("assets/map.png")
  bg_img:setFilter("nearest","nearest")

  font = love.graphics.newFont("assets/font.ttf",14)
  love.graphics.setFont(font)

  bgcolor = {r=10,g=10,b=10}
  fontcolor = {r=46,g=115,b=46}

  server.load()
  zone.load()
  plane.load()
end

function love.draw()
  love.graphics.setColor(bgcolor.r,bgcolor.g,bgcolor.b)
  love.graphics.rectangle("fill",0,0 ,love.graphics.getWidth(),love.graphics.getHeight())
  love.graphics.setColor(100,100,100)
  love.graphics.draw(bg_img,0,0,0,0.5,0.5)
  server.draw()
  zone.draw()
  plane.draw()
end

function love.update(dt)
  server.update(dt)
  zone.update(dt)
  plane.update(dt)
end

function love.keypressed(key)
  server.keypressed(key)
  zone.keypressed(key)
  if key == "`" then
    debug = not debug
  end
  if key == "q" then
    love.window.close()
    love.event.quit()
  end
end
