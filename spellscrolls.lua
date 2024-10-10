local defaultscrolltable={
liquids_pointable = true,
inventory_image = 'devmagic_scroll.png',
wield_image = 'devmagic_scroll.png',
}


TroMagic.register_scroll= function(name,table,effect)
  local description=TroMagic.mergetables(TroMagic.mergetables(defaultscrolltable,table),{on_use = effect})
  TroMagic.Scrolls[name]=description
  minetest.register_craftitem(name,description)
end
  
  
TroMagic.register_scroll("devmagic:scroll_of_freeze",
  {description= "Scroll of Freeze(LV 1)\nSingle use scroll casts Freeze | 2MP",    
inventory_image = 'devmagic_scroll_dark_blue.png',
wield_image = 'devmagic_scroll_dark_blue.png',}
,function(itemstack, placer, pointed_thing) --effect function
  TroMagic.CastSpell(placer,"Freeze",pointed_thing,angle,inclination,1)
  end )

TroMagic.register_scroll("devmagic:scroll_of_blast",
  {description= "Scroll of Blast (LV 1)\nSingle use scroll casts Blast | 6MP",
    inventory_image = 'devmagic_scroll_red.png',
wield_image = 'devmagic_scroll_red.png',}
,function(itemstack, placer, pointed_thing) --effect function
  TroMagic.CastSpell(placer,"Blast",pointed_thing,angle,inclination,1)
end)

TroMagic.register_scroll("devmagic:scroll_of_treewall_1",
{description= "Scroll of Tree Wall (LV 1)\nSingle use scroll casts Tree Wall | 2MP",
  inventory_image = 'devmagic_scroll_green.png',
wield_image = 'devmagic_scroll_green.png'}
,function(itemstack, placer, pointed_thing) --effect function
  local angle=placer:get_look_horizontal()
  TroMagic.CastSpell(placer,"TreeWall",pointed_thing,angle,inclination,1)
  end )

TroMagic.register_scroll("devmagic:scroll_of_treewall_2",
{description= "Scroll of Tree Wall (LV 2)\nSingle use scroll casts Tree Wall | 5MP",
  inventory_image = 'devmagic_scroll_green.png',
wield_image = 'devmagic_scroll_green.png'}
,function(itemstack, placer, pointed_thing) --effect function
  local angle=placer:get_look_horizontal()
  TroMagic.CastSpell(placer,"TreeWall",pointed_thing,angle,inclination,2)
  --spells.treewall2(placer,pos,angle)
  end )

TroMagic.register_scroll("devmagic:scroll_of_healing",
{description= "Scroll of Healing (LV 1)\nSingle use scroll casts Heals for 5 HP | 10MP",
  inventory_image = 'devmagic_scroll_light.png',
wield_image = 'devmagic_scroll_light.png'}
,function(itemstack, placer, pointed_thing) --effect function
  TroMagic.CastSpell(placer,"Heal",pointed_thing,angle,inclination,1)
  end)

TroMagic.register_scroll("devmagic:scroll_of_extinguish",
{description= "Scroll of Extinguish (LV 1)\nSingle use scroll casts Extinguish | 5MP",
    inventory_image = 'devmagic_scroll_light_blue.png',
wield_image = 'devmagic_scroll_light_blue.png'}
,function(itemstack, placer, pointed_thing) --effect function
  local pos = pointed_thing.under
  TroMagic.CastSpell(placer,"Extinguish",pointed_thing,angle,inclination,1)
end)

TroMagic.register_scroll("devmagic:scroll_of_stonebridge",
{description= "Scroll of Stone Bridge(LV 1)\nSingle use scroll casts Stone Bridge | 5MP",
    inventory_image = 'devmagic_scroll_brown.png',
wield_image = 'devmagic_scroll_light_brown.png'}
,function(itemstack, placer, pointed_thing) --effect function
  TroMagic.CastSpell(placer,"StoneBridge",pointed_thing,angle,inclination,1)
end)

function create_spell_stone(pos)
  minetest.set_node(pos, { name = 'devmagic:spell_stone' })
  local timer = minetest.get_node_timer(pos)
  timer:start(3) -- in seconds
  end
