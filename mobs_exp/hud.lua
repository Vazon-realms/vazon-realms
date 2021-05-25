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



function mobs_exp.set_hud_xp(player) -- handles the changes in xp and applies them to the HUD
	if not player then return end
	local name = player:get_player_name()
	local xp = data:get_int(name)
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