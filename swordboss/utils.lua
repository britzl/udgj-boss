local M = {}

function M.udgj_label(url, text)
	local upper = true
	label.set_text(url, text)
	timer.delay(0.3, true, function()
		upper = not upper
		if upper then
			text = string.upper(text)
		else
			text = string.lower(text)
		end
		label.set_text(url, text)
	end)
end


function M.udgj_text(node, text)
	local upper = true
	gui.set_text(node, text)
	timer.delay(0.3, true, function()
		upper = not upper
		if upper then
			text = string.upper(text)
		else
			text = string.lower(text)
		end
		gui.set_text(node, text)
	end)
end

return M