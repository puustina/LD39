local components = require "src.components"
local prefabs = {}

local g = love.graphics
local wImage = g.newImage("assets/wizard.png")
local pImage = g.newImage("assets/peasant.png")
local kImage = g.newImage("assets/knight.png")
local bImage = g.newImage("assets/dragon.png")

prefabs.player = function(x, y)
	local p = {}
	components.position(p, x, y)
	components.movementDirection(p, 0, 0)
	components.dimensions(p, 64, 64)
	components.rotation(p, 0)
	components.speed(p, 175)
	components.drawable(p, wImage)
	components.mouseLook(p)
	components.keyboardControl(p)
	components.health(p, 100)
	components.showBigHealth(p, 0, "Player")
	components.playerCast(p)
	components.damageCircle(p, 16)
	components.collideWithRoom(p)
	components.player(p)
	return p
end

prefabs.peasant = function(x, y)
	local p = {}
	components.position(p, x, y)
	components.movementDirection(p, 0, 0)
	components.dimensions(p, 64, 64)
	components.rotation(p, 0)
	components.drawable(p, pImage)
	components.wandererAI(p)
	components.enterArenaAI(p)
	components.speed(p, 50)
	components.health(p, 10)
	components.showHealth(p)
	components.damageCircle(p, 32)
	components.enemy(p)
	return p
end

prefabs.knight = function(x, y)
	local k = {}
	components.position(k, x, y)
	components.movementDirection(k, 0, 0)
	components.dimensions(k, 64, 64)
	components.rotation(k, 0)
	components.drawable(k, kImage)
	components.chargeAI(k)
	components.enterArenaAI(k)
	components.speed(k, 300)
	components.health(k, 20)
	components.showHealth(k)
	components.damageCircle(k, 32)
	components.enemy(k)
	return k
end

prefabs.boss = function(x, y)
	local b = {}
	components.position(b, x, y)
	components.movementDirection(b, 0, 0)
	components.dimensions(b, 128, 128)
	components.rotation(b, 0)
	components.drawable(b, bImage)
	--components.bossAI(b)
	components.enterArenaAI(b)
	components.speed(b, 10)
	components.health(b, 1000)
	components.showBigHealth(b, 1, "Dragon")
	components.damageCircle(b, 64)
	components.enemy(b)
	return b
end

prefabs.bloodBullet = function(x, y)
	local bb = {}
	components.position(bb, x, y)
	components.movementDirection(bb, 0, 0)
	--components.dimensions(bb, 16, 16)
	components.drawable(bb, nil)
	components.speed(bb, 400)
	components.damageCircle(bb, 16)
	components.hurtEnemyOnTouch(bb, 5)
	components.dieOnCollision(bb)
	components.killIfOutsideOfRoom(bb)
	return bb
end

prefabs.bloodSuck = function(x, y)
	local bs = {}
	components.position(bs, x, y)
	components.drawable(bs, nil)
	components.damageCircle(bs, 64)
	components.hurtEnemyOnTouch(bs, 10)
	components.giveHealthOnTouch(bs, 10)
	components.killAfterDelay(bs, 0.5)
	return bs
end

return prefabs