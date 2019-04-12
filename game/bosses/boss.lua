local signal = require "ludobits.m.signal"

local M = {}

M.OBJECT_HIT = signal.create("OBJECT_HIT")
M.OBJECT_DESTROYED = signal.create("OBJECT_DESTROYED")


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


function M.create_wave(factory_url, anim, count, distance, offset, fn)
	local wave = {
		objects = spawn(factory_url, anim, count, distance, offset),
		rotation = create_property(),
		strafe = create_property(),
		distance = create_property(),
	}
	function wave.on_object_destroyed(id)
		wave.objects[id] = nil
	end
	M.OBJECT_DESTROYED.add(wave.on_object_destroyed)
	wave.co = coroutine.create(function()
		while true do
			local ok, err = pcall(fn, wave)
			if not ok then
				print("Error running wave function", err)
				break
			end
		end
	end)
	return wave
end


function M.create_spawner(interval, factory_url, anim, count, distance, offset, fn)
	local spawner = {
		waves = {},
	}
	spawner.timer_handle = timer.delay(interval, true, function(self, handle, time_elapsed)
		local wave = M.create_wave(factory_url, anim, count, distance, offset, function(wave)
			fn(wave)
			M.destroy_wave(wave)
			spawner.waves[wave] = nil
		end)
		spawner.waves[wave] = true
	end)
	
	return spawner
end

function M.update_spawner(spawner)
	for wave,_ in pairs(spawner.waves) do
		M.update_wave(wave)
	end
end

function M.destroy_spawner(spawner)
	for wave,_ in pairs(spawner.waves) do
		M.destroy_wave(wave)
	end
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

function M.update_wave(wave)
	local ok, err = coroutine.resume(wave.co)
	if not ok then
		print(err)
	end
end



function M.destroy_wave(wave)
	M.OBJECT_DESTROYED.remove(wave.on_object_destroyed)
	for id,_ in pairs(wave.objects) do go.delete(id) end
	go.delete(wave.rotation)
	go.delete(wave.distance)
end


return M