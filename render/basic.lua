local lumiere = require "lumiere.lumiere"

local PRG = {}

function PRG.init(self)
	print("basic")
end

function PRG.update(self, dt)
	lumiere.clear(lumiere.BLACK)
	lumiere.use_world_projection()
	lumiere.draw_graphics2d()
	lumiere.use_screen_projection()
	lumiere.draw_gui()
end

return PRG