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

local data = {}
local callbacks = {}
local interface = {}

function interface.get(name)
	assert(type(name) == "string", "Name has to be a string, got: "..type(name))

	if type(data[name]) == "number" then
		return data[name]
	else
		return 0
	end
end

function interface.set(name, n)
	assert(type(name) == "string", "Name has to be a string, got: "..type(name))
	assert(type(n) == "number", "EXP has to be a number, got: "..type(n))

	for _, callback in ipairs(callbacks) do
		n = callback(name, data[name], n) or n

		assert(type(n) == "number", "Callback has to return a number or nil, got: "..type(n))
	end

	data[name] = math.max(n, 0)
end

function interface.add(name, n)
	interface.set(name, interface.get(name) + n)
end

function interface.add_callback(func)
	assert(type(func) == "function", "Callback has to be a function, got: "..type(func))
	table.insert(callbacks, func)
end

return setmetatable({}, {
	__index = interface,

	__newindex = function()
		error("ERROR: You are not allowed to directly manipulate mob_exp's data. Please use one of the provided functions instead.")
	end,

	__metatable = false
})
