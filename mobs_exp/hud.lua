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
-- exp_hud_level
-- ^ global tables

local data = ...

local hud_pos = {x = 0.5, y = 0.85}
local hud_scale = {x = 5, y = 5}
local hud_offset = {x = 45, y = 1.6}


local xp_hud_frame = {
	hud_elem_type = "image",
	position = hud_pos,
	offset = {x = 0, y = 0},
	text = "bar_frame.png^[transformR90",
	scale = hud_scale,
	alignment = {x = 0, y = 0},
}

local xp_hud_xp = {
	hud_elem_type = "image",
	position = hud_pos,
	offset = {x = 0, y = 0},
	text = "bar_xp.png^[transformR90",
	scale = hud_scale,
	alignment = {x = 0, y = 0},
}

local xp_hud_lv = {
	hud_elem_type = "image",
	position = hud_pos,
	offset = {x = 0, y = 0},
	text = "",
	scale = hud_scale,
	alignment = {x = 0, y = 0},
}



function mobs_exp.set_hud_level(player, l)
	local levelString = tostring(l)
	local name = player:get_player_name()
	local width = -20

	for h = 1, exp_hud_level[name].level_length, 1 do
		if not exp_hud_level[name][h] then break end
		player:hud_remove(exp_hud_level[name][h])
		exp_hud_level[name][h] = nil
	end

	for i = 1, #levelString, 1 do
		exp_hud_level[name][i] = player:hud_add(xp_hud_lv)
		player:hud_change(exp_hud_level[name][i], "text", levelString:sub(i, i) ..".png")
		player:hud_change(exp_hud_level[name][i], "offset", {x = -(hud_offset.x*hud_scale.x + ((i-1)*width)), y = -(hud_offset.y*hud_scale.y)})
	end

	exp_hud_level[name].level_length = #levelString
end

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
	exp_hud_level[name] = {}
	exp_hud_level[name].level_length = #tostring(mobs_exp.exp_to_level(data.get(name)))
	mobs_exp.set_hud_level(player, mobs_exp.exp_to_level(data.get(name)))
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	exp_hud_frame[name] = nil
	exp_hud_xp[name] = nil
	exp_hud_level[name] = nil
end)

data.add_callback(function(name, oldval, newval)
	mobs_exp.set_hud_xp(name, newval)
	mobs_exp.set_hud_level(minetest.get_player_by_name(name), mobs_exp.exp_to_level(newval))
end)
