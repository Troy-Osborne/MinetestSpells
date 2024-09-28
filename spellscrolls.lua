local defaultscrolltable={
liquids_pointable = true,
tiles = { 'scroll.png' },
inventory_image = 'scroll.png',
wield_image = 'scroll.png',
}

function Register_Spell_Scrolls(spells,TopLevel)  
function register_scroll(name,table,effect)
  minetest.register_craftitem(name,TopLevel.merge(TopLevel.merge(defaultscrolltable,table),{on_use = effect}))
end
  
  
register_scroll("devmagic:scroll_of_freeze",
  {description= "Scroll of Freeze\nSingle use scroll casts Freeze | 2MP"}
,function(itemstack, placer, pointed_thing) --effect function
  local pos = pointed_thing.under
  if pos~=nil then
  spells.freeze(placer,pos)
  end end)

register_scroll("devmagic:scroll_of_blast",
  {description= "Scroll of Blast\nSingle use scroll casts Blast | 6MP",}
,function(itemstack, placer, pointed_thing) --effect function
  local pos = pointed_thing.under
  if pos~=nil then
  spells.blast(placer,pos)
end end)

register_scroll("devmagic:scroll_of_treewall",
{description= "Scroll of Tree Wall (LV 2)\nSingle use scroll casts Tree Wall | 5MP"}
,function(itemstack, placer, pointed_thing) --effect function
  local pos = pointed_thing.under
  if pos~=nil then
  local angle=placer:get_look_horizontal()
  spells.treewall2(placer,pos,angle)
  end end)

register_scroll("devmagic:scroll_of_healing",
{description= "Scroll of Healing\nSingle use scroll casts Heals for 5 HP | 10MP"}
,function(itemstack, placer, pointed_thing) --effect function
  local pos = pointed_thing.under
  spells.heal(placer,pos,angle)
  end)

register_scroll("devmagic:scroll_of_extinguish",
{description= "Scroll of Extinguish\nSingle use scroll casts Extinguish | 5MP"}
,function(itemstack, placer, pointed_thing) --effect function
  local pos = pointed_thing.under
  if pos~=nil then
  spells.extinguish(placer,pos,angle)
end
end)

end