-- Declare all of the components
local components = {}

components.position = function(entity, x, y)
	entity.position = { x = x, y = y }
end

components.movementDirection = function(entity, x, y)
	entity.movementDirection = { x = x, y = y }
end

components.dimensions = function(entity, w, h)
	entity.dimensions = { w = w, h = h }
end

components.rotation = function(entity, r)
	entity.rotation = r
end

components.speed = function(entity, speed)
	entity.speed = {
		cur = speed,
		max = speed
	}
end

components.health = function(entity, health)
	entity.health = { cur = health, max = health }
end

components.dead = function(entity)
	entity.dead = true
end

components.showHealth = function(entity)
	entity.showHealth = true
end

components.showBigHealth = function(entity, pos, name)
	entity.showBigHealth = {
		pos = pos,
		name = name
	}
end

components.drawable = function(entity, image)
	entity.drawable = image
end

components.keyboardControl = function(entity)
	entity.keyboardControl = true
end

components.wandererAI = function(entity)
	entity.wandererAI = true
end

components.mouseLook = function(entity)
	entity.mouseLook = true
end

components.playerFollowAI = function(entity)
	entity.playerFollowAI = true
end

components.chargeAI = function(entity)
	entity.chargeAI = {
		charging = false
	}
end

components.enterArenaAI = function(entity)
	entity.enterArenaAI = true
end

components.shootFireAI = function(entity, cd)
	entity.shootFireAI = {
		cd = {
			cur = 0,
			max = cd
		}
	}
end

components.playerCast = function(entity)
	entity.playerCast = {
		bloodBullet = {
			cd = {
				cur = 0.0,
				max = 0.1
			},
			cost = 1,
			fireFunc = function()
				return love.mouse.isDown(1)
			end,
			castFunc = function()
				return 1
			end
		},
		bloodSuck = {
			cd = {
				cur = 0.0,
				max = 0.5
			},
			cost = 0,
			fireFunc = function()
				return love.mouse.isDown(2)
			end,
			castFunc = function()
				return 2
			end
		},
		convert = {
			cd = {
				cur = 0,
				max = 10
			},
			cost = 50,
			fireFunc = function()
				return love.keyboard.isDown("space")
			end,
			castFunc = function()
				return 3
			end
		}
	}
end

components.hurtPlayerOnTouch = function(entity, value)
	entity.hurtPlayerOnTouch = value
end

components.hurtEnemyOnTouch = function(entity, value)
	entity.hurtEnemyOnTouch = value
end

components.dieOnCollision = function(entity)
	entity.dieOnCollision = true
end

components.giveHealthOnTouch = function(entity, value)
	entity.giveHealthOnTouch = value
end

components.damageCircle = function(entity, r)
	entity.damageCircle = r
end

components.collideWithRoom = function(entity)
	entity.collideWithRoom = true
end

components.killIfOutsideOfRoom = function(entity)
	entity.killIfOutsideOfRoom = true
end

components.killAfterDelay = function(entity, delay)
	entity.killAfterDelay = delay
end

components.player = function(entity)
	entity.player = true
end

components.enemy = function(entity)
	entity.enemy = true
end

components.convertOnDeath = function(entity)
	entity.convertOnDeath = true
end

components.takeConstantDamage = function(entity, value)
	entity.takeConstantDamage = value
end

components.stopMovementAfter = function(entity, delay)
	entity.stopMovementAfter = delay
end

return components
