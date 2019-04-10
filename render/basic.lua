local render_helper = require "orthographic.render.helper"
local lumiere = require "lumiere.lumiere"

local PRG = {}

function PRG.init(self)
	print("basic")
	render_helper.init(self)
	
end

function PRG.update(self, dt)
	render_helper.update(self)

	lumiere.clear(lumiere.BLACK)
	lumiere.set_world_projection(render_helper.world_view(self), render_helper.world_projection(self))
	lumiere.draw_graphics2d()
	render.draw_debug3d()
	lumiere.set_screen_projection(render_helper.screen_view(self), render_helper.screen_projection(self))
	lumiere.draw_gui()
end

function PRG.on_message(self, message_id, message, sender)
	render_helper.on_message(self, message_id, message, sender)
end

return PRG