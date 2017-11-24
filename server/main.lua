debug = false
math.randomseed(os.clock())

GAMESPEED = .3
START_GAME_PLAYER_MIN = 2
MAXFPS = 1/10000

require('server')
require('zone')
require('plane')
require('loot')
require('lobby')

function love.load()
  love.window.setMode(500, 500, {
    resizable=true,
    vsync=false,
    minwidth=500,
    minheight=500,
    x=0,
    y=0,
    display=2
  })

  bg_img = love.graphics.newImage("assets/map.png")
  bg_img:setFilter("nearest","nearest")

  font = love.graphics.newFont("assets/font.ttf",10)
  love.graphics.setFont(font)

  bgcolor = {r=10,g=10,b=10}
  fontcolor = {r=46,g=115,b=46}

  server.load()
  zone.load()
  plane.load()
  loot.load()
  lobby.load()
  lobby.start()
  -- startGame()
end

function love.draw()
  love.graphics.setColor(bgcolor.r,bgcolor.g,bgcolor.b)
  love.graphics.rectangle("fill",0,0 ,love.graphics.getWidth(),love.graphics.getHeight())
  love.graphics.setColor(100,100,100)
  love.graphics.draw(bg_img,0,0,0,0.5,0.5)
  server.draw()
  zone.draw()
  plane.draw()
  loot.draw()
  lobby.draw()
end

function love.update(dt)
  server.update(dt)
  zone.update(dt)
  plane.update(dt)
  loot.update(dt)
  lobby.update(dt)
end

function love.keypressed(key)
  server.keypressed(key)
  zone.keypressed(key)
  lobby.keypressed(key)
  if key == "`" then
    debug = not debug
  end
  if key == "q" then
    love.window.close()
    love.event.quit()
  end
end

function love.run()

	if love.math then
		love.math.setRandomSeed(os.time())
	end

	if love.load then love.load(arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0

	-- Main loop time.
	while true do
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
		end

		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

		if love.graphics and love.graphics.isActive() then
			love.graphics.clear(love.graphics.getBackgroundColor())
			love.graphics.origin()
			if love.draw then love.draw() end
			love.graphics.present()
		end

		if love.timer then love.timer.sleep(MAXFPS) end
	end

end
