loot = {}


function loot.load()
  loot.items = {}
  loot.map = love.image.newImageData( 'assets/loot.png' )
  loot.possibleItems = {'gun','medkit','ammo'}
  loot.timer = 0
  loot.timerTrigger = 2
  loot.reset()
end


function loot.reset()
  loot.items = {}
  loot.timer = 0
  loot.generateLoot()
end
function loot.draw()
  if #loot.items > 0 then
    for _,item in ipairs( loot.items ) do
      love.graphics.setColor( 225, 80, 50, 255 )
      love.graphics.rectangle("fill",item.x-item.size/2,item.y-item.size/2, item.size, item.size)
    end
  end
end

function loot.update(dt)
  loot.timer = loot.timer + dt
  if loot.timer > loot.timerTrigger then
    if zone.scale > zone.min_scale then
      -- plane.startSupport()
    end
    loot.timer = 0
  end
end


function randomLootItem()
  return loot.possibleItems[math.random(1,#loot.possibleItems)]
end

function createLootAtPosition(x,y,item)
  -- print(#loot.possibleItems,x,y,item)
  local lootItem = {
    x = x,
    y = y,
    size = 1,
    content = item
  }
  table.insert(loot.items,lootItem)
end

function loot.dropSupportBox(x,y,s, item)
  print(x,y,s, item)
  local l = {
    x = x,
    y = y,
    size = s,
    content = item
  }
  table.insert(loot.items,l)
end

function loot.generateLoot()
  for row = 1, 1000 do
    for col = 1, 1000 do
      local r,g,b,a = loot.map:getPixel( row-1, col-1 )
      if r > 100 and math.random(0,1) == 1 then
        local item = randomLootItem()
        createLootAtPosition(row/2,col/2,item)
      end
    end
  end
end
