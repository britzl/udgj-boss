local sequence = require "sequence"

local M = {}


function M.float(url, delay)
	local pos = go.get_position(url)
	go.animate(url, "position.y", go.PLAYBACK_LOOP_PINGPONG, pos.y + 3, go.EASING_INOUTQUAD, 1, delay)
end


function M.blink(url, count, duration)
	local delay = duration / count / 2
	sequence.run_once(function()
		for i=1,count do
			msg.post(url, "disable")
			sequence.delay(delay)
			msg.post(url, "enable")
			sequence.delay(delay)
		end
	end)
end

return M