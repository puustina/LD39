local prefabs = require "src.prefabs"
local systems = require "src.systems"

local entities = {}

function love.load()
	math.randomseed(os.time())
	
	local wWidth, wHeight = love.window.getMode()

	-- make player
	entities[1] = prefabs.player(wWidth/2, wHeight/2)

	local spawnOutsideScreen = function(fun)
		local angle = math.random(100*-math.pi, 100*math.pi)
		local dist = math.sqrt(math.pow(wWidth/2, 2) + math.pow(wHeight/2, 2))
		entities[#entities + 1] = fun(wWidth/2 + math.cos(angle)*dist, wHeight/2 + math.sin(angle)*dist)
	end

	-- make enemies
	for i = 1, 3, 1 do
		spawnOutsideScreen(prefabs.peasant)
	end
	spawnOutsideScreen(prefabs.knight)
	spawnOutsideScreen(prefabs.boss)
end

function love.update(dt)
	for i, j in ipairs(entities) do
		for k, sys in ipairs(systems.systems) do
			sys(j, dt, entities)
		end
	end

	-- death (removal from entity-list)
	for i = #entities, 1, -1 do
		if entities[i].dead then
			table.remove(entities, i)
		end
	end
end

function love.draw()
	love.graphics.setBackgroundColor(255, 255, 255)
	love.graphics.setColor(255, 255, 255)
	for i, j in ipairs(entities) do
		for k, sys in ipairs(systems.drawSystems) do
			sys(j)
		end
	end

	-- UI
	for i, j in ipairs(entities) do
		for k, sys in ipairs(systems.uiSystems) do
			sys(j)
		end
	end
end
