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

-- exp_hud_frame
-- exp_hud_xp
-- ^ global tables

local data = ...



local xp_hud_frame = {
	hud_elem_type = "image",
	position = {x = 0.5, y = 0.9},
	offset = {x = 0, y = 0},
	text = "bar_frame.png^[transformR90",
	scale = {x = 5, y = 5},
	alignment = {x = 0, y = 0},
}

local xp_hud_xp = {
	hud_elem_type = "image",
	position = {x = 0.5, y = 0.9},
	offset = {x = 0, y = 0},
	text = "bar_xp.png^[transformR90",
	scale = {x = 5, y = 5},
	alignment = {x = 0, y = 0},
}



function mobs_exp.set_hud_xp(player, xp) -- handles the changes in xp and applies them to the HUD
	if type(player) == "string" then
		player = minetest.get_player_by_name(player)
	end

	assert(player, "set_hud_xp needs a provided online player")

	local name = player:get_player_name()

	xp = xp or data.get(name)
	player:hud_change(exp_hud_xp[name], "text", "bar_xp.png^[lowpart:" ..mobs_exp.normalize_range(xp)*100 ..":bar_frame.png^[transformR90")
end



minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	exp_hud_frame[name] = player:hud_add(xp_hud_frame)
	exp_hud_xp[name] = player:hud_add(xp_hud_xp)
	mobs_exp.set_hud_xp(player)
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	exp_hud_frame[name] = nil
	exp_hud_xp[name] = nil
end)

data.add_callback(function(name, oldval, newval)
	mobs_exp.set_hud_xp(name, newval)
end)
