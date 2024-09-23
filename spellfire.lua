fire = {}

-- Load support for MT game translation.
local S = minetest.get_translator("fire")

local spell_fire_node = {
	drawtype = "firelike",
	tiles = {{
		name = "fire_basic_flame_animated.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 1
		}}
	},
	inventory_image = "fire_basic_flame.png",
	paramtype = "light",
	light_source = 13,
	walkable = false,
	buildable_to = true,
	sunlight_propagates = true,
	floodable = true,
	damage_per_second = 4,
	groups = {igniter = 2, dig_immediate = 3, fire = 1},
	drop = "",
	on_flood = flood_flame
}

-- Basic flame node
local flame_fire_node = table.copy(spell_fire_node)
flame_fire_node.description = S("Fire")
flame_fire_node.groups.not_in_creative_inventory = 1
flame_fire_node.on_timer = function(pos)
	if not minetest.find_node_near(pos, 1, {"group:flammable"}) then
		minetest.remove_node(pos)
		return
  else
    minetest.set_node(pos, { name = 'fire:basic_flame' })
	end
	-- Restart timer
	return true
end
flame_fire_node.on_construct = function(pos)
	minetest.get_node_timer(pos):start(math.random(1, 2))
end

minetest.register_node("devmagic:spell_flame", flame_fire_node)