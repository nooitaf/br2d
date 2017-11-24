game = {}
DEBUG = false


function game.load()
  local w = love.graphics.getWidth()
  local h = love.graphics.getHeight()
  game.clock = 0
end

function game.draw()
  local w = love.graphics.getWidth()
  local h = love.graphics.getHeight()
  love.graphics.clear()
  love.graphics.setColor(0,0,0)
  love.graphics.rectangle("fill",0,0 ,w,h)
end

function game.dist(x1,y1,x2,y2)
  return math.sqrt( (x1 - x2)^2 + (y1 - y2)^2 )
end

function game.update(dt)
  game.clock = game.clock + dt
end

function game.keypressed(key)
end

function love.wheelmoved(x, y)
  if y > 0 then
    mapZoomScale = mapZoomScale + .1 * mapZoomScale
  elseif y < 0 then
    mapZoomScale = mapZoomScale - .1 * mapZoomScale
  end
end
if DEBUG then
  function Net.event.client.connect( ip, port) --Called when client connects to a server with net:connect() ip is ip of server and port is port of server
    print("net event connect: ",ip, port)
  end
  function Net.event.client.receive( table, dt, cmd, param ) --Called when client receives a packet table is the table client sent, dt deltatime of net:update(), cmd is the command from client, param is parameters from the client
    print("net event receive: ", table.Command)
  end
  function Net.event.client.disconnect() --Called when client disconnects from server with net:disconnect()
    print("net event disconnect")
  end
  function Net.event.client.cmdRegistered( cmd, functionS ) --Called when a command is registered, cmd is the cmd and function is the function called by the cmd
    print("net event cmdRegistered: ", cmd)
  end
  function Net.event.client.send( table, cmd, param ) --Called when a packet is sent to the server, table is the table being sent, cmd is the cmd, param is parameters
    print("net event send: ",cmd)
  end
  function Net.event.client.kickedFromServer( reason ) --Called when we( the client ) is kicked from the server, reason is the reason for the kick
    print("net event kickedFromServer: ",reason)
  end
end
