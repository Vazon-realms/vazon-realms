--[[
Mobs Redo EXP System
Copyright (C) 2021 Noodlemire, Apelta

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
--]]

mobs_exp = {}
exp_hud_frame = {}
exp_hud_xp = {}
exp_hud_level = {}

local path = minetest.get_modpath(minetest.get_current_modname())


local data = assert(loadfile(path .. "/data.lua"))()

assert(loadfile(path .. "/modlib_persistence.lua"))()
assert(loadfile(path .. "/storage.lua"))(data)
assert(loadfile(path .. "/core.lua"))(data)
assert(loadfile(path .. "/hud.lua"))(data)
