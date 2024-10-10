--items


function Register_Mana_Potions(TopLevel)
  minetest.register_craftitem("devmagic:light_mana_potion",{
description= "Single use Mana Potion Restores 25MP",
inventory_image = 'devmagic_light_mana_potion.png',
wield_image = 'devmagic_light_mana_potion.png',
on_use = function(itemstack, user, pointed_thing) 
  local hpchange=0
  local replacement=nil
  TopLevel.GainMana(user,25)
  return minetest.do_item_eat(hpchange,replacement,itemstack, user, pointed_thing) end 

})

minetest.register_craftitem("devmagic:mana_potion",{
description= "Single use Mana Potion Restores 75MP",
inventory_image = 'devmagic_mana_potion.png',
wield_image = 'devmagic_mana_potion.png',
on_use = function(itemstack, user, pointed_thing)
  
  local hpchange=0
  local replacement=nil
  TopLevel.GainMana(user,75)
  return minetest.do_item_eat(hpchange,replacement,itemstack, user, pointed_thing) end 
})

  
  end