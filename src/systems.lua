local g = love.graphics
local epsilon = 0.0001

local components = require "src.components"
local prefabs = require "src.prefabs"
local systems = {}

local collides = function(entA, entB)
	return math.sqrt(math.pow(entA.position.y - entB.position.y, 2) + math.pow(entA.position.x - entB.position.x, 2)) < entA.damageCircle + entB.damageCircle
end

systems.systems = {
	-- mouselook
	function(e)
		if e.mouseLook and e.position and e.rotation then
			local mX, mY = love.mouse.getPosition()
			e.rotation = math.atan2(mY - e.position.y, mX - e.position.x)
		end
	end,
	-- keyboard movement
	function(e)
		if e.keyboardControl and e.movementDirection then
			local k = love.keyboard
			e.movementDirection.x = 0
			e.movementDirection.y = 0
			if k.isDown("w") then e.movementDirection.y = e.movementDirection.y - 1 end
			if k.isDown("s") then e.movementDirection.y = e.movementDirection.y + 1 end
			if k.isDown("a") then e.movementDirection.x = e.movementDirection.x - 1 end
			if k.isDown("d") then e.movementDirection.x = e.movementDirection.x + 1 end
		end
	end,
	-- player casting
	function(e, dt, entities)
		if e.playerCast then
			local m = love.mouse
			local mX, mY = m.getPosition()
			local angle = math.atan2(mY - e.position.y, mX - e.position.x)
			
			for i, j in pairs(e.playerCast) do
				j.cd.cur = j.cd.cur - dt
				if j.fireFunc() and j.cd.cur <= 0 then
					if j.castFunc() == 1 then -- can't define these in component because of cyclic dependancy
						local rand = math.random(-1, 1)*math.random()*.1
						entities[#entities + 1] = prefabs.bloodBullet(
						e.position.x + math.cos(angle + rand) * e.damageCircle, 
						e.position.y + math.sin(angle + rand) * e.damageCircle)
						entities[#entities].movementDirection.x = math.cos(angle + rand)
						entities[#entities].movementDirection.y = math.sin(angle + rand)
					elseif j.castFunc() == 2 then
						local dist = math.min(200, math.sqrt(math.pow(mY - e.position.y, 2) + math.pow(mX - e.position.x, 2)))
						entities[#entities + 1] = prefabs.bloodSuck(
							e.position.x + math.cos(angle) * dist,
							e.position.y + math.sin(angle) * dist)
					elseif j.castFunc() == 3 then
						entities[#entities + 1] = prefabs.conversionCircle(entities[1].position.x, entities[1].position.y)
					end
					e.health.cur = e.health.cur - j.cost
					j.cd.cur = j.cd.max
				end
			end		
		end
	end,
	-- AI
	function(e, dt, entities)
		local pX, pY = entities[1].position.x, entities[1].position.y	
		local angleToPlayer = math.atan2(pY - e.position.y, pX - e.position.x)
		
		if e.shootFireAI then
			e.shootFireAI.cd.cur = e.shootFireAI.cd.cur - dt
			if e.shootFireAI.cd.cur <= 0 then
				e.shootFireAI.cd.cur = e.shootFireAI.cd.max
				for i = 1, 3, 1 do
					local angle = math.atan2(entities[1].position.y - e.position.y, entities[1].position.x - e.position.x)
					angle = angle + (i - 2)*.25
					entities[#entities + 1] = prefabs.fire(
					e.position.x + math.cos(angle) * e.damageCircle, 
					e.position.y + math.sin(angle) * e.damageCircle)
					entities[#entities].movementDirection.x = math.cos(angle)
					entities[#entities].movementDirection.y = math.sin(angle)
				end
			end
		end

		if e.enterArenaAI and e.movementDirection then
			local wWidth, wHeight = love.window.getMode()
			if e.position.x - e.dimensions.w/2 - epsilon < 0 or
				e.position.x + e.dimensions.w/2 + epsilon > wWidth or
				e.position.y - e.dimensions.h/2 - epsilon < 0 or 
				e.position.y + e.dimensions.h/2 + epsilon > wHeight then
				local angle = math.atan2(wHeight/2 - e.position.y, wWidth/2 - e.position.x)
				e.movementDirection.x = math.cos(angle)
				e.movementDirection.y = math.sin(angle)
				e.speed.cur = 25	
			else
				e.enterArenaAI = false
				e.speed.cur = e.speed.max
				e.movementDirection.x = 0
				e.movementDirection.y = 0
				components.collideWithRoom(e)
			end
		elseif e.wandererAI and e.movementDirection then
			while e.movementDirection.y == 0 and e.movementDirection.x == 0 do
				e.movementDirection.x = math.random(-100, 100)
				e.movementDirection.y = math.random(-100, 100)
			end
		elseif e.chargeAI and not e.chargeAI.charging and e.movementDirection then
			e.movementDirection.x = math.cos(angleToPlayer)
			e.movementDirection.y = math.sin(angleToPlayer)
			e.chargeAI.charging = true
			components.hurtPlayerOnTouch(e, 10)
		elseif e.playerFollowAI then
			e.movementDirection.x = math.cos(angleToPlayer)
			e.movementDirection.y = math.sin(angleToPlayer)
		end
	end,
	-- movement
	function(e, dt)
		if e.position and e.movementDirection and e.speed then
			if e.movementDirection.x ~= 0 or e.movementDirection.y ~= 0 then
				local angle = math.atan2(e.movementDirection.y, e.movementDirection.x)
				e.position.x = e.position.x + math.cos(angle) * e.speed.cur * dt
				e.position.y = e.position.y + math.sin(angle) * e.speed.cur * dt
			end
		end
		if e.stopMovementAfter then
			e.stopMovementAfter = e.stopMovementAfter - dt
			if e.stopMovementAfter <= 0 then
				e.stopMovementAfter = false
				e.movementDirection.x = 0
				e.movementDirection.y = 0
			end
		end
	end,
	-- collision with room
	function(e)
		if e.collideWithRoom and e.position and e.movementDirection then
			local xCol = false
			local yCol = false
			local wWidth, wHeight = love.window.getMode()
			if (e.position.x - e.dimensions.w/2) < 0 then
				e.position.x = e.dimensions.w/2 + epsilon
				xCol = true
			elseif (e.position.x + e.dimensions.w/2) > wWidth then
				e.position.x = wWidth - e.dimensions.w/2 - epsilon
				xCol = true
			end

			if (e.position.y - e.dimensions.h/2) < 0 then
				e.position.y = e.dimensions.h/2 + epsilon
				yCol = true
			elseif (e.position.y + e.dimensions.h/2) > wHeight then
				e.position.y = wHeight - e.dimensions.h/2 - epsilon
				yCol = true
			end

			if xCol then
				if e.wandererAI then 
					e.movementDirection.x = -e.movementDirection.x
				elseif e.chargeAI then
					e.movementDirection.x = 0
					e.movementDirection.y = 0
					e.chargeAI.charging = false
					e.hurtPlayerOnTouch = false
				else
					e.movementDirection.x = 0
				end
			elseif yCol then
				if e.wandererAI then
					e.movementDirection.y = -e.movementDirection.y
				elseif e.chargeAI then
					e.movementDirection.x = 0
					e.movementDirection.y = 0
					e.chargeAI.charging = false
				else
					e.movementDirection.y = 0
				end
			end
		end
	end,
	-- calculate damage
	function(e, dt, entities)
		if e.hurtEnemyOnTouch then
			for i, j in ipairs(entities) do
				if j.enemy and collides(e, j) then
					damage = e.hurtEnemyOnTouch
					if not e.dieOnCollision then 
						damage = damage * dt 
					else
						components.dead(e)
					end
					if e.giveHealthOnTouch then
						local health = e.giveHealthOnTouch
						if not e.dieOnCollision then
							health = health * dt
						end
						--hack
						entities[1].health.cur = math.min(entities[1].health.cur + health, entities[1].health.max)
					end
					j.health.cur = j.health.cur - damage
				end
			end
		end

		if e.hurtPlayerOnTouch then
			for i, j in ipairs(entities) do
				if j.player and collides(j, e) then
					damage = e.hurtPlayerOnTouch
					if not e.dieOnCollision then
						damage = damage * dt
					else
						components.dead(e)
					end
					j.health.cur = j.health.cur - damage
				end
			end
		end

		if e.takeConstantDamage then
			e.health.cur = e.health.cur - e.takeConstantDamage * dt
		end
	end,
	-- dying
	function(e, dt, entities)
		if e.health and e.health.cur <= 0 then
			local converted = false
			if e.enemy then
				for i, j in ipairs(entities) do 
					if j.convertOnDeath and collides(j, e) then
						e.health.cur = e.health.max
						e.enemy = false
						components.player(e)
						e.playerFollowAI = false
						e.chargeAI = false
						components.wandererAI(e)
						components.hurtEnemyOnTouch(e, e.health.max/10)
						e.hurtPlayerOnTouch = false
						e.showHealth = false
						e.showBigHealth = false
						components.takeConstantDamage(e, e.health.max/50)
						converted = true
						e.shootFireAI = false
						break
					end
				end
			end
			if not converted then
				components.dead(e)
			end
		end

		if e.killIfOutsideOfRoom then
			local wWidth, wHeight = love.window.getMode()
			if e.position.x + e.damageCircle < 0 or 
				e.position.x - e.damageCircle > wWidth or
				e.position.y + e.damageCircle < 0 or
				e.position.y + e.damageCircle > wHeight then
				components.dead(e)
			end
		end

		if e.killAfterDelay then
			e.killAfterDelay = e.killAfterDelay - dt
			if e.killAfterDelay <= 0 then
				components.dead(e)
			end
		end
	end
}

systems.drawSystems = {
	function(e)
		if e.drawable and e.position then
			local r = e.rotation or 0
			if not e.mouselook and e.rotation and e.movementDirection then 
				e.rotation = math.atan2(e.movementDirection.y, e.movementDirection.x) 
			end
			local w = 0
			local h = 0
			if e.dimensions then w = e.dimensions.w; h = e.dimensions.h end
			if e.enemy == false then -- converted mob
				g.setColor(255, 255, 255, 50)
			else
				g.setColor(255, 255, 255)
			end
			g.draw(e.drawable, e.position.x, e.position.y, r, 1, 1, w/2, h/2)
		end

		--[[if e.damageCircle then
			g.setColor(100, 100, 100)
			g.circle("line", e.position.x, e.position.y, e.damageCircle)
			g.setColor(255, 255, 255)
		end]]--
	end
}

systems.uiSystems = {
	function(e)
		if e.health and e.showHealth and e.position and e.dimensions then
			g.setColor(200, 0, 0)
			g.rectangle("fill", e.position.x - e.dimensions.w/2, e.position.y - e.dimensions.h/2, e.dimensions.w, 5)
			g.setColor(0, 200, 0)
			g.rectangle("fill", e.position.x - e.dimensions.w/2, e.position.y - e.dimensions.h/2, e.dimensions.w*(e.health.cur/e.health.max), 5)
		end

		if e.showBigHealth then
			local wWidth, wHeight = love.window.getMode()
			local x = 0
			local y = 0
			if e.showBigHealth.pos == 1 then
				y = wHeight - 14
			end
			g.setColor(200, 0, 0)
			g.rectangle("fill", x, y, wWidth, 14)
			g.setColor(0, 200, 0)
			g.rectangle("fill", x, y, wWidth*(e.health.cur/e.health.max), 14)
			g.setColor(0, 0, 0)
			g.print(e.showBigHealth.name, wWidth/2, y)
		end
	end
}

return systems
