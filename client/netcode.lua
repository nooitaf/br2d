Net:init( "Client" )
Net:connect( "127.0.0.1", 25045 )
Net:registerCMD( "tok", function( data, param, id, deltatime )
  local tok = math.floor((game.clock-data.time)*1000)
  game.player.ping = tok
  -- print("tok: "..tok)
end )


Net:registerCMD( "updateEnemies", function( data, param, id, deltatime )
  if not data then return end
  -- table.foreach(data,print)
  game.enemies[data.id] = data
end )
Net:registerCMD( "updategame.info", function( data, param, id, deltatime )
  if not data then return end
  game.info = data
  if data.enemiesPacked then
    for enms in string.gmatch(data.enemiesPacked, "[^;]+") do
      local i = 1
      local vals = {}
      for token in string.gmatch(enms, "[^,]+") do
        vals[i] = token
        i = i + 1
      end
      local item = {
        id = vals[1],
        x = vals[2],
        y = vals[3]
      }
      local id = item.id
      if not game.enemies then
        game.enemies = {}
      end
      if not game.enemies[id] then
        game.enemies[id] = {}
      end
      game.enemies[id].id = item.id
      game.enemies[id].x = item.x
      game.enemies[id].y = item.y
      game.enemies[id].lastSeen = 1
    end
  end
  -- print(data.enemiesPacked)
end )
Net:registerCMD( "updatePosition", function( data, param, id, deltatime )
  if not data then return end
  -- table.foreach(data,print)
  game.player:setPosition(data.x,data.y)
  -- client.data.inPlane = data.inPlane
end )
Net:registerCMD( "startGame", function( data, param, id, deltatime )
  game.player.inPlane = true
  game.player.inPlaneQueue = true
  game.info.inPlane = true
  game.info.inPlaneQueue = true
  print('start game')
end )
Net:registerCMD( "startLobby", function( data, param, id, deltatime )
  game.player.inPlane = true
  game.player.inPlaneQueue = true
  game.info.inPlane = true
  game.info.inPlaneQueue = true
  print('start lobby')
end )

if DEBUG then
  function Net.event.game.player.connect( ip, port) --Called when client connects to a server with net:connect() ip is ip of server and port is port of server
    print("net event connect: ",ip, port)
  end
  function Net.event.game.player.receive( table, dt, cmd, param ) --Called when client receives a packet table is the table client sent, dt deltatime of net:update(), cmd is the command from client, param is parameters from the client
    print("net event receive: ", table.Command)
  end
  function Net.event.game.player.disconnect() --Called when client disconnects from server with net:disconnect()
    print("net event disconnect")
  end
  function Net.event.game.player.cmdRegistered( cmd, functionS ) --Called when a command is registered, cmd is the cmd and function is the function called by the cmd
    print("net event cmdRegistered: ", cmd)
  end
  function Net.event.game.player.send( table, cmd, param ) --Called when a packet is sent to the server, table is the table being sent, cmd is the cmd, param is parameters
    print("net event send: ",cmd)
  end
  function Net.event.game.player.kickedFromServer( reason ) --Called when we( the client ) is kicked from the server, reason is the reason for the kick
    print("net event kickedFromServer: ",reason)
  end
end
