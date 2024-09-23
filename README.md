A very early minetest spell library.
Only a day old at this point. Mostly just an excercise to brush up on Lua and learn the minetest engine

At the moment the mana is on persistant and spells are only called from scrolls.

Added Functions useful for implementing a variety of spells

Completed Spell Effects:
  **Freeze (Spherical AOE):**
    -Can be cast on water or ground
    -Turns water group into default:ice nodes
    -Turns soil group into default:dirt_with_snow nodes
    -Turns sand into default:silver_sand nodes
  
  **Blast (Spherical AOE):**
    -Turns air into devmagic:spell_flame nodes
    -Flames burn out in 1-2 seconds
    -Flames next to flamable tiles turn into 
  
  **Tree Wall:**
    -Creates a line of trees perpendicular to the player direction

To Do:
  -Make spells learnable
  -Make unrepairable staffs which cast spells without mana cosumption until they lose durability
  -Add Magic Level with the ability to learn or upgrade a spell each level
  -Make Mana/Max Mana, Spells, and Magic Level persistent 
  -Add Inventory Image and Wield images.
  -Add Casting Animations and Delays
  -Add Missle Animations
  -Add Cooldown
  -Add Water Spells
  -Add Summoning Spells
  -Add Wards/Auras
  -Add Trap Spells
