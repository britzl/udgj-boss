local boss = require "game.bosses.boss"

local M = {}



local function rotate(amount, playback, easing)
	return { amount = amount or 360, playback = playback or go.PLAYBACK_ONCE_FORWARD, easing = easing or go.EASING_INOUTQUAD }
end

local function move(amount, playback, easing)
	return { amount = amount or 100, playback = playback or go.PLAYBACK_ONCE_FORWARD, easing = easing or go.EASING_INOUTQUAD }
end

function M.run()
	assert(coroutine.running(), "You must run this from within a coroutine")

	boss.float(".", 0)

	local shield_wave1 = boss.create_wave("#shieldfactory", 4, 40, 0, function(wave)
		boss.animate_wave(wave, { rotate = rotate(360) }, 2)
	end)
	local enemy_wave1 = boss.create_wave("#enemyfactory", 6, 90, 0, function(wave)
		boss.animate_wave(wave, { rotate = rotate(-360) }, 2)
		boss.animate_wave(wave, { move = move(90) }, 1)
		boss.animate_wave(wave, { rotate = rotate(-360) }, 2)
		boss.animate_wave(wave, { move = move(-90) }, 1)
	end)
	local enemy_wave2 = boss.create_wave("#enemyfactory", 12, 150, 30, function(wave)
		boss.animate_wave(wave, { rotate = rotate(360) }, 2)
		boss.animate_wave(wave, { move = move(-60) }, 1)
		boss.animate_wave(wave, { rotate = rotate(360) }, 2)
		boss.animate_wave(wave, { move = move(60) }, 1)
	end)
		
	while true do
		boss.update_wave(shield_wave1)
		boss.update_wave(enemy_wave1)
		boss.update_wave(enemy_wave2)
		coroutine.yield()
	end

	boss.destroy_wave(shield_wave1)
	boss.destroy_wave(enemy_wave1)
	boss.destroy_wave(enemy_wave2)
end


return M