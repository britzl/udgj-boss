local events = require "game.events"

local M = {}


local function update_spawner(spawner)
end

local function update_wave(wave)
	local ok, err = coroutine.resume(wave.co)
	if not ok then
		print(err)
	end
end

local function destroy_wave(boss, wave)
	for i,w in pairs(boss.waves or {}) do
		if wave == w then
			boss.waves[i] = nil
			break
		end
	end
	events.OBJECT_DESTROYED.remove(wave.on_object_destroyed)
	go.cancel_animations(wave.rotation, "property")
	go.cancel_animations(wave.strafe, "property")
	go.cancel_animations(wave.distance, "property")
	go.delete(wave.rotation)
	go.delete(wave.strafe)
	go.delete(wave.distance)

	for object_id,_ in pairs(wave.objects) do
		msg.post(msg.url(nil, object_id, "sprite"), "disable")
		particlefx.play(msg.url(nil, object_id, "destroy"), function(self, id, emitter, state)
			if state == particlefx.EMITTER_STATE_SLEEPING then
				go.delete(object_id)
			end
		end)
	end
end

local function destroy_spawner(boss, spawner)
	for i,s in pairs(boss.spawners) do
		if spawner == s then
			boss.spawners[i] = nil
			break
		end
	end
	timer.cancel(spawner.timer_handle)
end

function M.create(health)
	local boss = {
		waves = {},
		spawners = {},
		health = health,
		max_health = health,
	}
	return boss
end


function M.run(boss)
	boss.co = coroutine.create(function()
		while boss.health > 0 do
			for _,wave in ipairs(boss.waves) do
				update_wave(wave)
			end
			for _,spawner in ipairs(boss.spawners) do
				update_spawner(spawner)
			end
			coroutine.yield()
		end
	end)
end

function M.update(boss)
	local status = coroutine.status(boss.co)
	if status == "suspended" then
		local ok, err = coroutine.resume(boss.co)
		if not ok then
			print(err)
		end
	end
end

function M.destroy(boss)
	while #boss.waves > 0 do
		destroy_wave(boss, boss.waves[#boss.waves])
	end
	while #boss.spawners > 0 do
		destroy_spawner(boss, boss.spawners[#boss.spawners])
	end
end

function M.float(url, delay)
	local pos = go.get_position(url)
	go.animate(url, "position.y", go.PLAYBACK_LOOP_PINGPONG, pos.y + 3, go.EASING_INOUTQUAD, 1, delay)
end


local function position(id, angle, distance)
	local pos = go.get_position(id)
	pos.x = distance * math.cos(angle)
	pos.y = distance * math.sin(angle)
	go.set_position(pos, id)
end


local function spawn(factory_url, anim, count, distance, offset)
	local instances = {}
	for i=1,count do
		local angle = offset + math.rad(i * 360 / count)
		local pos = vmath.vector3(math.cos(angle) * distance, math.sin(angle) * distance, 0)
		local id = factory.create(factory_url, pos)
		if anim then
			sprite.play_flipbook(msg.url(nil, id, "sprite"), anim)
		end
		go.set_parent(id, go.get_id())
		instances[id] = { id = id, angle = angle, distance = distance }
	end
	return instances
end


local function create_property()
	local id = factory.create("#propertyfactory")
	return msg.url(nil, id, "script")
end


function M.create_wave(boss, factory_url, anim, count, distance, offset, fn)
	local wave = {
		objects = spawn(factory_url, anim, count, distance, offset),
		rotation = create_property(),
		strafe = create_property(),
		distance = create_property(),
	}
	function wave.on_object_destroyed(id)
		wave.objects[id] = nil
	end
	events.OBJECT_DESTROYED.add(wave.on_object_destroyed)
	wave.co = coroutine.create(function()
		while true do
			fn(wave)
		end
	end)
	boss.waves[#boss.waves + 1] = wave
	return wave
end


function M.create_spawner(boss, interval, factory_url, anim, count, distance, offset, fn)
	local spawner = {}
	spawner.timer_handle = timer.delay(interval, true, function(self, handle, time_elapsed)
		local wave = M.create_wave(boss, factory_url, anim, count, distance, offset, function(wave)
			fn(wave)
			destroy_wave(wave)
		end)
	end)
	boss.spawners[#boss.spawners + 1] = spawner
	return spawner
end


function M.animate_wave(wave, config, duration, delay)
	assert(coroutine.running(), "You must run this from within a coroutine")
	config.strafe = config.strafe or {}
	config.rotate = config.rotate or {}
	config.move = config.move or {}
	local strafe_amount = config.strafe.amount or 0
	local strafe_easing = config.strafe.easing or go.EASING_LINEAR
	local strafe_playback = config.strafe.playback or go.PLAYBACK_ONCE_FORWARD
	local rotate_amount = config.rotate.amount or 0
	local rotate_easing = config.rotate.easing or go.EASING_LINEAR
	local rotate_playback = config.rotate.playback or go.PLAYBACK_ONCE_FORWARD
	local move_amount = config.move.amount or 0
	local move_easing = config.move.easing or go.EASING_LINEAR
	local move_playback = config.move.playback or go.PLAYBACK_ONCE_FORWARD

	local done = false
	local strafe_to = go.get(wave.strafe, "property") + strafe_amount
	go.animate(wave.strafe, "property", strafe_playback, strafe_to, strafe_easing, duration, delay or 0, function()
		done = true
	end)
	local rotate_to = go.get(wave.rotation, "property") + rotate_amount
	go.animate(wave.rotation, "property", rotate_playback, rotate_to, rotate_easing, duration, delay or 0, function()
		done = true
	end)
	local move_to = go.get(wave.distance, "property") + move_amount
	go.animate(wave.distance, "property", move_playback, move_to, move_easing, duration, delay or 0, function()
		done = true
	end)
	while not done do
		local angle = math.rad(go.get(wave.strafe, "property"))
		local distance = go.get(wave.distance, "property")
		for id,object in pairs(wave.objects) do
			position(id, object.angle + angle, object.distance + distance)
			go.set(id, "euler.z", go.get(wave.rotation, "property"))
		end
		coroutine.yield()
	end
end

return M