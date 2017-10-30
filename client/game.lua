game = {}

function game.load()
  game.clock = 0
end

function game.draw()
  love.graphics.clear()
  love.graphics.setColor(0,0,0)
  love.graphics.rectangle("fill",0,0 ,love.graphics.getWidth(),love.graphics.getHeight())
end

function game.dist(x1,y1,x2,y2)
  return math.sqrt( (x1 - x2)^2 + (y1 - y2)^2 )
end

function game.update(dt)
  game.clock = game.clock + dt
end

function game.keypressed(key)
end
