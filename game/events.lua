local signal = require "ludobits.m.signal"

local M = {}

M.BOSS_HIT = signal.create("BOSS_HIT")
M.BOSS_DEAD = signal.create("BOSS_DEAD")
M.SHIELD_HIT = signal.create("SHIELD_HIT")
M.OBJECT_DESTROYED = signal.create("OBJECT_DESTROYED")

return M