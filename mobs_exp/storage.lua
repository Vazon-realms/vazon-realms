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

local data = ...

local storage = mobs_exp.lua_log_file.new(minetest.get_worldpath().."/mobs_exp.txt", {})
storage:init()
storage.root = storage.root or {}
storage:rewrite()

for k, v in pairs(storage.root) do
	if type(k) == "string" and type(v) == "number" then
		data.set(k, v)
	else
		minetest.log("warning", "Cannot load key of type \""..type(k).."\" for value of type \""..type(v).."\"")
	end
end

data.add_callback(function(name, oldval, newval)
	storage:set_root(name, newval)
end)
