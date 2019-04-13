local boss = require "game.boss.boss"

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
	boss.float(".", 0)

	local b = boss.create(5)
	boss.create_wave(b, "#shieldfactory", "shield1", 3, 40, 0, function(wave)
		boss.animate_wave(wave, { strafe = strafe(360) }, 2)
	end)
	return b
end


local function boss2()
	boss.float(".", 0)

	local b = boss.create(5)
	boss.create_wave(b, "#shieldfactory", "shield1", 4, 50, 0, function(wave)
		boss.animate_wave(wave, { strafe = strafe(360) }, 2)
	end)
	boss.create_wave(b, "#enemyfactory", "tiny_skull", 12, 100, 0, function(wave)
		boss.animate_wave(wave, { strafe = strafe(360) }, 4)
		boss.animate_wave(wave, { move = move(100) }, 1)
		boss.animate_wave(wave, { strafe = strafe(360) }, 8)
		boss.animate_wave(wave, { move = move(100) }, 1)
		boss.animate_wave(wave, { strafe = strafe(360) }, 8)
		boss.animate_wave(wave, { move = move(-100) }, 1)
		boss.animate_wave(wave, { strafe = strafe(360) }, 4)
		boss.animate_wave(wave, { move = move(-100) }, 1)
	end)

	return b
end


local function boss3()
	boss.float(".", 0)

	local b = boss.create(6)
	boss.create_wave(b, "#shieldfactory", "shield1", 4, 40, 0, function(wave)
		boss.animate_wave(wave, { strafe = strafe(360) }, 2)
	end)
	boss.create_wave(b, "#bulletfactory", "shuriken1", 6, 90, 0, function(wave)
		boss.animate_wave(wave, { strafe = strafe(-360), rotate = rotate(360 * 12) }, 2)
		boss.animate_wave(wave, { move = move(90), rotate = rotate(360 * 6) }, 1)
		boss.animate_wave(wave, { strafe = strafe(-360), rotate = rotate(360 * 12) }, 2)
		boss.animate_wave(wave, { move = move(-90), rotate = rotate(360 * 6) }, 1)
	end)
	boss.create_wave(b, "#bulletfactory", "shuriken1", 12, 150, 30, function(wave)
		boss.animate_wave(wave, { strafe = strafe(360), rotate = rotate(360 * 12) }, 2)
		boss.animate_wave(wave, { move = move(-60), rotate = rotate(360 * 6) }, 1)
		boss.animate_wave(wave, { strafe = strafe(360), rotate = rotate(360 * 12) }, 2)
		boss.animate_wave(wave, { move = move(60), rotate = rotate(360 * 6) }, 1)
	end)

	boss.create_spawner(b, 2, "#enemyfactory", "tiny_skull", 12, 0, 0, function(wave)
		boss.animate_wave(wave, { strafe = strafe(90), move = move(400) }, 16)
	end)
	return b
end

local function boss4()
	boss.float(".", 0)

	local b = boss.create(5)
	boss.create_wave(b, "#shieldfactory", "shield1", 4, 50, 0, function(wave)
		boss.animate_wave(wave, { strafe = strafe(360) }, 2)
	end)
	boss.create_wave(b, "#shieldfactory", "shield1", 10, 180, 45, function(wave)
		boss.animate_wave(wave, { strafe = strafe(360) }, 8)
	end)
	boss.create_wave(b, "#enemyfactory", "tiny_skull", 12, 100, 0, function(wave)
		boss.animate_wave(wave, { strafe = strafe(360) }, 4)
		boss.animate_wave(wave, { move = move(100) }, 1)
		boss.animate_wave(wave, { strafe = strafe(360) }, 8)
		boss.animate_wave(wave, { move = move(100) }, 1)
		boss.animate_wave(wave, { strafe = strafe(360) }, 8)
		boss.animate_wave(wave, { move = move(-100) }, 1)
		boss.animate_wave(wave, { strafe = strafe(360) }, 4)
		boss.animate_wave(wave, { move = move(-100) }, 1)
	end)
	boss.create_wave(b, "#enemyfactory", "tiny_skull", 12, 150, 0, function(wave)
		boss.animate_wave(wave, { strafe = strafe(360) }, 4)
		boss.animate_wave(wave, { move = move(100) }, 1)
		boss.animate_wave(wave, { strafe = strafe(360) }, 8)
		boss.animate_wave(wave, { move = move(-100) }, 1)
	end)

	return b
end

local function random()
	boss.float(".", 0)
	local b = boss.create(6)

	boss.create_wave(b, "#shieldfactory", "shield1", math.random(4,10), 25, 0, function(wave)
		boss.animate_wave(wave, { strafe = strafe(360) }, math.random(10, 50) / 10 )
	end)
	if math.random(1, 10) > 5 then
		boss.create_spawner(b, 2, "#enemyfactory", "tiny_skull", 12, 0, 0, function(wave)
			boss.animate_wave(wave, { strafe = strafe(90), move = move(400) }, 16)
		end)
	end
	for i=1,15 do
		local r = math.random(1,10)
		if r == 1 then
			boss.create_wave(b, "#shieldfactory", "shield1", math.random(i+3,i+10), 25 + i * 50, 0, function(wave)
				boss.animate_wave(wave, { strafe = strafe(360) }, math.random(10, 50) / 10 )
			end)
		elseif r == 2 then
			boss.create_wave(b, "#enemyfactory", "tiny_skull", math.random(i+3,i+10), 25 + i * 30, 0, function(wave)
				boss.animate_wave(wave, { strafe = strafe(360) }, math.random(1,i) + 4)
				boss.animate_wave(wave, { move = move(100) }, math.random(1,i) + 1)
				boss.animate_wave(wave, { strafe = strafe(360) }, math.random(1,i) + 8)
				boss.animate_wave(wave, { move = move(-100) }, math.random(1,i) + 1)
			end)
		elseif r == 3 then
			boss.create_wave(b, "#bulletfactory", "shuriken1", math.random(i+3,i+10), 25 + i * 30, 0, function(wave)
				boss.animate_wave(wave, { strafe = strafe(360) }, math.random(1,i)+4)
				boss.animate_wave(wave, { move = move(100) }, math.random(1,i)+1)
				boss.animate_wave(wave, { strafe = strafe(360) }, math.random(1,i)+8)
				boss.animate_wave(wave, { move = move(-100) }, math.random(1,i)+1)
			end)
		end
	end
	
	return b
end

M.BOSS1 = hash("BOSS1")
M.BOSS2 = hash("BOSS2")
M.BOSS3 = hash("BOSS3")
M.BOSS4 = hash("BOSS4")
M.RANDOM = hash("RANDOM")

local BOSSES = {
	[M.BOSS1] = boss1,
	[M.BOSS2] = boss2,
	[M.BOSS3] = boss3,
	[M.BOSS4] = boss4,
	[M.RANDOM] = random,
}

function M.create(boss_id)
	local boss_fn = BOSSES[boss_id] or random
	return boss_fn()
end


return M