local data = ...

minetest.register_on_dieplayer(function(player)
	local pname = player:get_player_name()
	local loss = math.floor(data:get_int(pname) * 0.2)
	local prev_lvl = mobs_exp.exp_to_level(data:get_int(pname))
	local next_lvl = mobs_exp.exp_to_level(data:get_int(pname) - loss)

	data:set_int(pname, data:get_int(pname) - loss)

	minetest.chat_send_player(pname, "You died! You lost "..loss.." EXP!")

	if next_lvl < prev_lvl then
		minetest.chat_send_player(pname, "Level down! You are now level: "..next_lvl)
	end
end)



function mobs_exp.exp_to_level(e)
	return 1 + math.floor((math.sqrt(.4 * e + 1) - 1) / 2)
end

function mobs_exp.level_to_exp(l)
	return 10 * l * (l + 1)
end

function mobs_exp.exp_per_level(l)
	return 20 * l
end

function mobs_exp.exp_for_level(l) -- Used to get exp for getting to a certain level. Primarily for the HUD
	local x = 0 
	local i = 1
	while (i <= l) do
		x = x + mobs_exp.exp_per_level(i)
		i = i + 1
	end
	return x
end

function mobs_exp.exp_to_next_level(e)
	return mobs_exp.exp_for_level(mobs_exp.exp_to_level(e)) - e
end

function mobs_exp.normalize_range(e)
	return mobs_exp.exp_to_next_level(e)/mobs_exp.exp_per_level(mobs_exp.exp_to_level(e))
end



minetest.register_entity("mobs_exp:orb", {
	initial_properties = {
		physical = true,
		collide_with_objects = false,
		collisionbox = {-0.125, -0.125, -0.125, 0.125, 0.125, 0.125},
		pointable = false,
		visual = "sprite",
		visual_size = {x = 0.125, y = 0.125},
		textures = {"mobs_exp_orb.png"},
		glow = -1,
		static_save = false,
	},

	on_step = function(self)
		local objs = minetest.get_objects_inside_radius(self.object:get_pos(), 1.5)
		local players = {}

		for _, obj in ipairs(objs) do
			if obj:is_player() then
				table.insert(players, obj:get_player_name())
			end
		end

		if #players > 0 then
			local exp = self.exp or 0
			local player = players[math.random(#players)]
			local prev_lvl = mobs_exp.exp_to_level(data:get_int(player))
			local next_lvl = mobs_exp.exp_to_level(data:get_int(player) + exp)

			data:set_int(player, data:get_int(player) + exp)

			minetest.chat_send_player(player, "You gained "..exp.." EXP!")

			if next_lvl > prev_lvl then
				minetest.chat_send_player(player, "Level up! You are now level: "..next_lvl)
			end

			self.object:remove()
		end
	end,
})



minetest.register_on_mods_loaded(function()
	for name, def in pairs(minetest.registered_entities) do
		if def.mod_origin == "mobs_monster" then
			local old_on_die = def.on_die

			rawset(def, "on_die", function(self, pos)
				local ref = minetest.add_entity(pos, "mobs_exp:orb")

				if ref then
					local armor = self.armor > 0 and self.armor or 1
					ref:get_luaentity().exp = math.ceil(((self.hp_min + self.hp_max) / 2 + self.damage) * (100 / self.armor))
				end

				if old_on_die then
					old_on_die(self, pos)
				end
			end)
		end
	end
end)
