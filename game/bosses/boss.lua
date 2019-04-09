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


local function spawn(factory_url, count, distance, offset)
	local instances = {}
	for i=1,count do
		local angle = offset + math.rad(i * 360 / count)
		local pos = vmath.vector3(math.cos(angle) * distance, math.sin(angle) * distance, 0)
		local id = factory.create(factory_url, pos)
		go.set_parent(id, go.get_id())
		instances[id] = { id = id, angle = angle, distance = distance }
	end
	return instances
end


local function create_property()
	local id = factory.create("#propertyfactory")
	return msg.url(nil, id, "script")
end


function M.create_wave(factory_url, count, distance, offset, fn)
	local wave = {
		objects = spawn(factory_url, count, distance, offset),
		rotation = create_property(),
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


function M.animate_wave(wave, config, duration, delay)
	assert(coroutine.running(), "You must run this from within a coroutine")
	config.rotate = config.rotate or {}
	config.move = config.move or {}
	local rotate_amount = config.rotate.amount or 0
	local rotate_easing = config.rotate.easing or go.EASING_LINEAR
	local rotate_playback = config.rotate.playback or go.PLAYBACK_ONCE_FORWARD
	local move_amount = config.move.amount or 0
	local move_easing = config.move.easing or go.EASING_LINEAR
	local move_playback = config.move.playback or go.PLAYBACK_ONCE_FORWARD

	local done = false
	local rotate_to = go.get(wave.rotation, "property") + rotate_amount
	go.animate(wave.rotation, "property", rotate_playback, rotate_to, rotate_easing, duration, delay or 0, function()
		done = true
	end)
	local move_to = go.get(wave.distance, "property") + move_amount
	go.animate(wave.distance, "property", move_playback, move_to, move_easing, duration, delay or 0, function()
		done = true
	end)
	while not done do
		local angle = math.rad(go.get(wave.rotation, "property"))
		local distance = go.get(wave.distance, "property")
		for id,object in pairs(wave.objects) do
			position(id, object.angle + angle, object.distance + distance)
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