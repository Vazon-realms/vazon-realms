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

local REQ = 20 --Base EXP requirement for a level

minetest.register_on_dieplayer(function(player)
	local pname = player:get_player_name()
	local loss = math.floor(data.get(pname) * 0.2)
	local prev_lvl = mobs_exp.exp_to_level(data.get(pname))
	local next_lvl = mobs_exp.exp_to_level(data.get(pname) - loss)

	data.add(pname, -loss)

	minetest.chat_send_player(pname, "Upon death, you lost "..loss.." EXP!")

	if next_lvl < prev_lvl then
		minetest.chat_send_player(pname, "Tier down! You are now Tier-"..mobs_exp.roman(next_lvl))
	end
end)



function mobs_exp.exp_to_level(e)
	return 1 + math.floor((math.sqrt(8 / REQ * e + 1) - 1) / 2)
end

function mobs_exp.level_to_exp(l)
	return REQ * l * (l + 1) / 2
end

function mobs_exp.exp_per_level(l)
	return REQ * l
end

function mobs_exp.exp_to_next_level(e)
	return mobs_exp.level_to_exp(mobs_exp.exp_to_level(e)) - e
end

function mobs_exp.normalize_range(e)
	return mobs_exp.exp_to_next_level(e)/mobs_exp.exp_per_level(mobs_exp.exp_to_level(e))
end

function mobs_exp.roman(n)
	local r = ""

	while n >= 100 do
		r = r.."C"
		n = n - 100
	end
	if n >= 90 then
		r = r.."XC"
		n = n - 90
	end
	if n >= 50 then
		r = r.."L"
		n = n - 50
	end
	if n >= 40 then
		r = r.."XL"
		n = n - 40
	end
	while n >= 10 do
		r = r.."X"
		n = n - 10
	end
	if n >= 9 then
		r = r.."IX"
		n = n - 9
	end
	if n >= 5 then
		r = r.."V"
		n = n - 5
	end
	if n >= 4 then
		r = r.."IV"
		n = n - 4
	end
	while n >= 1 do
		r = r.."I"
		n = n - 1
	end

	return r
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
			local prev_lvl = mobs_exp.exp_to_level(data.get(player))
			local next_lvl = mobs_exp.exp_to_level(data.get(player) + exp)

			data.add(player, exp)

			minetest.chat_send_player(player, "You gained "..exp.." EXP!")

			if next_lvl > prev_lvl then
				minetest.chat_send_player(player, "Tier up! You are now Tier-"..mobs_exp.roman(next_lvl))
			end

			self.object:remove()
		end
	end,
})



minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	if hitter:is_player() and player:get_hp() > 0 and player:get_hp() - damage <= 0 then
		local exp = mobs_exp.exp_to_level(data:get_int(player:get_player_name())) * 5
		local p = player:get_pos()
		local ref = minetest.add_entity({x=p.x, y=p.y+1, z=p.z}, "mobs_exp:orb")

		if ref then
			ref:get_luaentity().exp = exp
		end
	end
end)

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
