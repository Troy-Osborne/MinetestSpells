function create_spell_stone(spawnpos)
  minetest.set_node(spawnpos, { name = 'devmagic:spell_stone' })
  local timer = minetest.get_node_timer(spawnpos)
  timer:start(3) -- in seconds
  end

minetest.register_node("devmagic:spell_stone", {
    tiles={'default_stone.png'},
    on_timer = function(pos)
        minetest.set_node(pos, { name = "devmagic:spell_cobble" })
        local timer = minetest.get_node_timer(pos)
        timer:start(5) -- in seconds
        return false
    end
})

minetest.register_node("devmagic:spell_cobble", {
    tiles={'default_cobble.png'},
    on_timer = function(pos)
        minetest.set_node(pos, { name = "devmagic:spell_gravel" })
        local timer = minetest.get_node_timer(pos)
        timer:start(2) -- in seconds
        return false
    end
})

minetest.register_node("devmagic:spell_gravel", {
    tiles={'default_gravel.png'},
    on_timer = function(pos)
        minetest.set_node(pos, { name = "air" })
        return false
    end
})