local boss = require "game.bosses.boss"

local M = {}



local function rotate(amount, playback, easing)
	return { amount = amount or 360, playback = playback or go.PLAYBACK_ONCE_FORWARD, easing = easing or go.EASING_INOUTQUAD }
end

local function strafe(amount, playback, easing)
	return { amount = amount or 360, playback = playback or go.PLAYBACK_ONCE_FORWARD, easing = easing or go.EASING_INOUTQUAD }
end

local function move(amount, playback, easing)
	return { amount = amount or 100, playback = playback or go.PLAYBACK_ONCE_FORWARD, easing = easing or go.EASING_INOUTQUAD }
end



local function boss1()
	assert(coroutine.running(), "You must run this from within a coroutine")

	boss.float(".", 0)

	local shield_wave1 = boss.create_wave("#shieldfactory", "shield1", 3, 40, 0, function(wave)
		boss.animate_wave(wave, { strafe = strafe(360) }, 2)
	end)

	while true do
		boss.update_wave(shield_wave1)
		coroutine.yield()
	end

	boss.destroy_wave(shield_wave1)
end


local function boss2()
	assert(coroutine.running(), "You must run this from within a coroutine")

	boss.float(".", 0)

	local shield_wave1 = boss.create_wave("#shieldfactory", "shield1", 4, 50, 0, function(wave)
		boss.animate_wave(wave, { strafe = strafe(360) }, 2)
	end)
	local enemy_wave1 = boss.create_wave("#enemyfactory", "tiny_skull", 12, 100, 0, function(wave)
		boss.animate_wave(wave, { strafe = strafe(360) }, 4)
		boss.animate_wave(wave, { move = move(100) }, 1)
		boss.animate_wave(wave, { strafe = strafe(360) }, 8)
		boss.animate_wave(wave, { move = move(100) }, 1)
		boss.animate_wave(wave, { strafe = strafe(360) }, 8)
		boss.animate_wave(wave, { move = move(-100) }, 1)
		boss.animate_wave(wave, { strafe = strafe(360) }, 4)
		boss.animate_wave(wave, { move = move(-100) }, 1)
	end)
	
	while true do
		boss.update_wave(shield_wave1)
		boss.update_wave(enemy_wave1)
		coroutine.yield()
	end

	boss.destroy_wave(shield_wave1)
	boss.destroy_wave(enemy_wave1)
end

local function boss3()
	assert(coroutine.running(), "You must run this from within a coroutine")

	boss.float(".", 0)

	local shield_wave1 = boss.create_wave("#shieldfactory", "shield1", 4, 40, 0, function(wave)
		boss.animate_wave(wave, { strafe = strafe(360) }, 2)
	end)
	local enemy_wave1 = boss.create_wave("#bulletfactory", "shuriken1", 6, 90, 0, function(wave)
		boss.animate_wave(wave, { strafe = strafe(-360), rotate = rotate(360 * 12) }, 2)
		boss.animate_wave(wave, { move = move(90), rotate = rotate(360 * 6) }, 1)
		boss.animate_wave(wave, { strafe = strafe(-360), rotate = rotate(360 * 12) }, 2)
		boss.animate_wave(wave, { move = move(-90), rotate = rotate(360 * 6) }, 1)
	end)
	local enemy_wave2 = boss.create_wave("#bulletfactory", "shuriken1", 12, 150, 30, function(wave)
		boss.animate_wave(wave, { strafe = strafe(360), rotate = rotate(360 * 12) }, 2)
		boss.animate_wave(wave, { move = move(-60), rotate = rotate(360 * 6) }, 1)
		boss.animate_wave(wave, { strafe = strafe(360), rotate = rotate(360 * 12) }, 2)
		boss.animate_wave(wave, { move = move(60), rotate = rotate(360 * 6) }, 1)
	end)

	local spawner = boss.create_spawner(2, "#enemyfactory", "tiny_skull", 12, 0, 0, function(wave)
		boss.animate_wave(wave, { strafe = strafe(90), move = move(400) }, 16)
	end)
	
	while true do
		boss.update_spawner(spawner)
		boss.update_wave(shield_wave1)
		boss.update_wave(enemy_wave1)
		boss.update_wave(enemy_wave2)
		coroutine.yield()
	end

	boss.destroy_spawner(spawner)
	boss.destroy_wave(shield_wave1)
	boss.destroy_wave(enemy_wave1)
	boss.destroy_wave(enemy_wave2)
end


function M.get(level)
	if level == 1 then
		return boss1
	elseif level == 2 then
		return boss2
	else
		return boss3
	end
end


return M