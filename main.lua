local prefabs = require "src.prefabs"
local systems = require "src.systems"

local entities = {}

local bg = love.graphics.newImage("assets/bg.png")
local timer = 0
local whatToSpawn = {
-- time | wavenumber | enemies
	{0, {10,0,0}},
	{10, {0,5,0}},
	{20, {20,0,0}},
	{30, {0,0,1}},
	{40, {0,5,0}},
	{50, {10,0,0}}
}
local spawnOutsideScreen = function(fun)
	local wWidth, wHeight = love.window.getMode()
	local angle = math.random(100*-math.pi, 100*math.pi)
	local dist = math.sqrt(math.pow(wWidth/2, 2) + math.pow(wHeight/2, 2))
	entities[#entities + 1] = fun(wWidth/2 + math.cos(angle)*dist, wHeight/2 + math.sin(angle)*dist)
end

function love.load()
	math.randomseed(os.time())
	
	local wWidth, wHeight = love.window.getMode()

	-- make player
	entities[1] = prefabs.player(wWidth/2, wHeight/2)
end

function love.update(dt)
	timer = timer + dt

	for i = #whatToSpawn, 1, -1 do
		if whatToSpawn[i][1] < timer and whatToSpawn[i][2] then
			for enemyIndex, count in ipairs(whatToSpawn[i][2]) do
				for k = 1, count, 1 do
					local fun = nil
					if enemyIndex == 1 then
						fun = prefabs.peasant
					elseif enemyIndex == 2 then
						fun = prefabs.knight
					elseif enemyIndex == 3 then
						fun = prefabs.boss
					end
					spawnOutsideScreen(fun)
				end
			end
			whatToSpawn[i][2] = nil
		end
	end

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
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(bg, 0, 0)
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
