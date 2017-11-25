local ground = {}

local sprites = {}
sprites.rock = {}
sprites.water = {}
sprites.gras = {}
sprites.corn = {}

function ground.load()
    sprites_grounds = love.graphics.newImage("assets/sprites_grounds.png")
    sprites_grounds:setFilter("nearest","nearest")
    sprites_grounds_size_width = 12
    sprites_grounds_size_height = 12
    sprites.rock[1]  = love.graphics.newQuad(sprites_grounds_size_width*0,sprites_grounds_size_height*0,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
    sprites.rock[2]  = love.graphics.newQuad(sprites_grounds_size_width*1,sprites_grounds_size_height*0,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
    sprites.rock[3]  = love.graphics.newQuad(sprites_grounds_size_width*2,sprites_grounds_size_height*0,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
    sprites.rock[4]  = love.graphics.newQuad(sprites_grounds_size_width*3,sprites_grounds_size_height*0,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
    sprites.gras[1]  = love.graphics.newQuad(sprites_grounds_size_width*0,sprites_grounds_size_height*1,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
    sprites.gras[2]  = love.graphics.newQuad(sprites_grounds_size_width*1,sprites_grounds_size_height*1,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
    sprites.gras[3]  = love.graphics.newQuad(sprites_grounds_size_width*2,sprites_grounds_size_height*1,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
    sprites.gras[4]  = love.graphics.newQuad(sprites_grounds_size_width*3,sprites_grounds_size_height*1,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
    sprites.water[1] = love.graphics.newQuad(sprites_grounds_size_width*0,sprites_grounds_size_height*2,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
    sprites.water[2] = love.graphics.newQuad(sprites_grounds_size_width*1,sprites_grounds_size_height*2,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
    sprites.water[3] = love.graphics.newQuad(sprites_grounds_size_width*2,sprites_grounds_size_height*2,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
    sprites.water[4] = love.graphics.newQuad(sprites_grounds_size_width*3,sprites_grounds_size_height*2,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
    sprites.corn[1]  = love.graphics.newQuad(sprites_grounds_size_width*0,sprites_grounds_size_height*3,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
    sprites.corn[2]  = love.graphics.newQuad(sprites_grounds_size_width*1,sprites_grounds_size_height*3,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
    sprites.corn[3]  = love.graphics.newQuad(sprites_grounds_size_width*2,sprites_grounds_size_height*3,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
    sprites.corn[4]  = love.graphics.newQuad(sprites_grounds_size_width*3,sprites_grounds_size_height*3,sprites_grounds_size_width,sprites_grounds_size_height,sprites_grounds:getDimensions())
end

function ground.draw()
  -- draw sprites
  local w = love.graphics.getWidth()
  local h = love.graphics.getHeight()
  local scale = .0417

  for row = -5,5 do
    for col = -5,5 do
      local px = round(game.player.x) + row/2
      local py = round(game.player.y) + col/2
      local g = ground.getGround(px,py)
      love.graphics.setColor( 255, 255, 255, 150 )
      if g == "gras" then
        for i = 1,4 do
          love.graphics.draw(sprites_grounds,sprites.gras[i],px,py,0,scale,scale)
        end
      end
      if g == "water" then
        for i = 1,4 do
          love.graphics.draw(sprites_grounds,sprites.water[i],px,py,0,scale,scale)
        end
      end
      if g == "sand" then
        for i = 1,4 do
          love.graphics.draw(sprites_grounds,sprites.rock[i],px,py,0,scale,scale)
        end
      end
      if g == "wood" then
        for i = 1,4 do
          love.graphics.draw(sprites_grounds,sprites.corn[i],px,py,0,scale,scale)
        end
      end
    end
  end
end

function ground.getGround(x,y)
  local r = 0
  local g = ""
  -- update ground
  if x >= 0 and x < 500 and y >= 0 and y < 500 then
    r = game.map.imageData:getPixel( x*2, y*2 )
  end
  if r >= 250 then
    g = "house"
  elseif r < 150 and r >= 110 then
    g = "snow"
  elseif r < 110 and r >= 70 then
    g = "stone"
  elseif r < 70 and r >= 50 then
    g = "wood"
  elseif r < 50 and r >= 20 then
    g = "gras"
  elseif r < 20 and r >= 10 then
    g = "sand"
  elseif r < 10 and r >= 0 then
    g = "water"
  end
  return g
end


return ground
