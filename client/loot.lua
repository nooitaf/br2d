local loot = {}

function loot.load()
  loot.items = {}
  loot.possibleItems = {'gun','medkit','ammo'}
  Net:registerCMD( "insertLoot", function( data, param, id, deltatime )
		if not data then return end
    -- table.foreach(data,print)
    table.insert(loot.items,data)
	end )
  Net:registerCMD( "insertLootBatch", function( data, param, id, deltatime )
		if not data then return end
    loot.items = {}
    for i,v in pairs( data ) do
      -- print('pair',v)
      for token in string.gmatch(v, "[^,]+") do
        -- print(token)
        local item = {
          x = token[1],
          y = token[2],
          size = token[3],
          content = token[4]
        }
        table.insert(loot.items,item)
      end
      -- table.insert(loot.items,data)
      -- table.foreach(data,table.insert(loot.items))
    end

	end )
  loot.devDropLoot()
end

function loot.devDropLoot()

  table.insert(loot.items,{
    x = 201,
    y = 189,
    size = 1,
    content = 'bagpack'
  })
  table.insert(loot.items,{
    x = 202,
    y = 189,
    size = 1,
    content = 'helmet'
  })


end

function loot.draw()
  if #loot.items > 0 then
    for _,item in pairs( loot.items ) do
      if item.size then
        love.graphics.setColor( 225, 80, 50, 255 )
        if loot.isItemInRange(item) then
          love.graphics.setColor( 25, 250, 50, 255 )
        end
        love.graphics.rectangle("fill",item.x+item.size/6,item.y+item.size/6, item.size/6, item.size/6)
      end
    end
  end
end

function loot.update(dt)
  -- if loot in reach pick first one to pickup

end

function loot.isItemInRange(item)
  local c = game.player:getInfo()
  local inRange = false
  local rangeAcceptance = 0.5
  local x = item.x+item.size/6
  local y = item.y+item.size/6
  if c.x <= (x + rangeAcceptance) and c.x >= (x - rangeAcceptance) and c.y <= (y + rangeAcceptance) and c.y >= (y - rangeAcceptance) then
    inRange = true
  end
  return inRange
end

function loot.inRangeOfPlayer()
  local inRangeItems
  if #loot.items > 0 then
    for _,item in pairs( loot.items ) do
      if item.size then
        table.insert(inRangeItems,item)
      end
    end
  end
  return inRangeItems or false
end

return loot
