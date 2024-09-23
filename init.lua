-- MAGIC MOD
-- by Troy Osborne

-- Defines Mana a basic spell functions


TroMagic = {}
TroMagic.mod = {author = "Troy Osborne" }
TroMagic.modpath = minetest.get_modpath("devmagic")

dofile(TroMagic.modpath.."./spellfire.lua")
--dofile(TroMagic.modpath.."/mana.lua")
--dofile(TroMagic.modpath.."/spells.lua")


tau=math.pi*2
halfpi=math.pi*0.5
----------MANA

--Wait until the player is established
--Then when a player joins load them in with the default mana.

--This will be chaged in future to write the player mana to the world so it can be loaded whenever they join
minetest.register_on_joinplayer(function(player)
    if player then
        --local myplayer = minetest.get_player_by_name("singleplayer") --Load the Player

        local defaultmana=100

        local pmeta = player:get_meta()

        pmeta:set_int("Mana", defaultmana)
        pmeta:set_int("MaxMana", defaultmana)


        print(defaultmana)

        --Draw Mana To Screen
--INI MANA DISPLAY
 ManaDisplay = player:hud_add({
         --hud_elem_type = "text",
         type = "text",
         position      = {x = 0.1, y = 0.1},
         offset        = {x = 0,   y = 0},
         text          = "Mana:"..pmeta:get_string("Mana")..'/'..pmeta:get_string("MaxMana"),
         alignment     = {x = 0, y = 0},  -- center aligned
         scale         = {x = 100, y = 100}, -- covered later
    })
  

  

  end
end)


---REDRAWING MANA
RefreshManaDisplay= function(player)
local pmeta = player:get_meta()
player:hud_change(ManaDisplay, "text", "Mana:"..pmeta:get_string("Mana")..'/'..pmeta:get_string("MaxMana"))  
end
  
  
  
---MANA CALCULATIONS

--SUBTRACT MANA IF POSSIBLE
SpendMana= function(player,manacost)
  local pmeta = player:get_meta()
  local oldmana=pmeta:get_int("Mana")
  local newmana=oldmana-manacost
  --Check if you have enough mana to spend
  if newmana>=0 then  --If you have enough mana Adust the Mana Refresh the display and return True for success
  pmeta:set_int("Mana", newmana)
  RefreshManaDisplay(player)
  return true
else --otherwise don't adjust the mana and return false signalling the mana could not be spent
  return false
  end
end


--INCREASE MANA UP TO A MAXIMUM OF Player:Metadata:MaxMana
GainMana= function(player,managain)
  local pmeta = player:get_meta()
  local oldmana=pmeta:get_int("Mana")
  local maxmana=pmeta:get_int("MaxMana")
  local newmana=oldmana+managain
  --Check if you have enough mana to spend
  if newmana>maxmana then  --If you have enough mana Adust the Mana Refresh the display and return True for success
  pmeta:set_int("Mana", maxmana)
else --otherwise don't adjust the mana and return false signalling the mana could not be spent
  pmeta:set_int("Mana", newmana)
end
RefreshManaDisplay(player)
end






---MISC FUNCTIONS

local function is_water(pos)
	local nn = minetest.get_node(pos).name
	return minetest.get_item_group(nn, "water") ~= 0
end





------SPELLS



castspell=function(player,castpos,spellname,effectfunc,manacost,cooldown)
  --check spell is ready
  if SpendMana(player,manacost) then --try to spend the mana; will return false is not enough mana available.
    effectfunc(player,castpos)
    --Set Cooldown Timer
    return true -- return success
  else
    return false --return failure
  end 
  
end

blocksinradius= function (origin,radius,nodefunc) --applies nodefunc to all blocks in a given radius
  for xo=-radius,radius,1 do --xoffset
  for yo=-radius,radius,1 do --yoffset
for zo=-radius,radius,1 do --zoffset
  if math.sqrt(xo*xo+yo*yo+zo*zo)<=radius then
    nodefunc({x=xo+origin.x, y=origin.y+yo, z= origin.z+zo})
    end
end
end
end
end


blocksinline= function(origin,width,height,angle,nodefunc)--angle in radians
  halfwidth=width/2
  for displacement=-halfwidth,halfwidth,1 do
    for yo=-1,height,1 do
      xo=math.cos(angle)*displacement
      zo=math.sin(angle)*displacement
      
     nodefunc({x=math.floor(0.5+xo+origin.x), y= math.floor(0.5+origin.y+yo), z= math.floor(0.5+origin.z+zo)}) 
    end
  end
end

function growtree(treename) --returns a function which accepts a pos as an input. places a tree there if the 
    return function(pos) 
      local currentnode=minetest.get_node(pos)
      if currentnode.name=='air'       
      then
        minetest.set_node(pos, { name = treename })
      end
      
      end
    end


function freezewater(pos)
  local currentnode=minetest.get_node(pos)
    --if currentnode.name=='default:water_source' or currentnode.name=='default:water' or currentnode.name=='default:water_flowing' or currentnode.name=="default:river_water_flowing"  or currentnode.name=="default:river_water_source"        
    if minetest.get_item_group(currentnode.name, "water")>0
  then
    minetest.set_node(pos, { name = 'default:ice' })
  end
  
    if minetest.get_item_group(currentnode.name, "soil")>0
  then
    minetest.set_node(pos, { name = 'default:dirt_with_snow' })
  end
  
      if currentnode.name=='default:sand'
  then
    minetest.set_node(pos, { name = 'default:silver_sand' })
  end
end

function burnair(pos)
    local currentnode=minetest.get_node(pos)
    if currentnode.name=='air'       
  then
    minetest.set_node(pos, { name = 'devmagic:spell_flame' })
  end
end


function spell_treewall1(player,pos,angle)
  local manacost=2
  local cooldown=0
    castspell(player,pos,"TreeWall",function (caster,castpos) blocksinline(castpos,2,3,angle,growtree("default:acacia_tree")) end, manacost,cooldown)
end

function spell_treewall2(player,pos,angle)
  local manacost=2
  local cooldown=0
    castspell(player,pos,"TreeWall",function (caster,castpos) blocksinline(castpos,6,4,angle,growtree("default:acacia_tree")) end, manacost,cooldown)
end


function spell_freeze(player,pos)
  local manacost=2
  local cooldown=0
    castspell(player,pos,"Freeze",function (caster,castpos) blocksinradius(castpos,3,freezewater) end, manacost,cooldown)
end

--function spell_ignite(player,pos)
--  local manacost=5
--  local cooldown=0
--    castspell(player,pos,"Ignite",function (caster,castpos) blocksinradius(castpos,3,burnair) end, manacost,cooldown)
--end


function spell_blast(player,pos)
  local manacost=5
  local cooldown=0
    castspell(player,pos,"Blast",function (caster,castpos) blocksinradius(castpos,3,burnair) end, manacost,cooldown)
end


minetest.register_node("devmagic:scroll_of_freeze",{
description= "Single use scroll casts level 1 Freeze",
sunlight_propagates=true,
use_texture_alpha=true,
liquids_pointable = true,
on_place = function(itemstack, placer, pointed_thing)
  local pos = pointed_thing.above
  local underpos =  pointed_thing.under
  local topnode = minetest.get_node(pointed_thing.above).name
  local bottomnode = minetest.get_node(pointed_thing.under).name
  local name = placer:get_player_name()        
        spell_freeze(placer,pos)
        if  minetest.get_item_group(topnode, "water")>0 
        then
          minetest.set_node(pos, { name = "default:ice" })
       else 
        minetest.set_node(pos, { name = topnode })
        end
      end,
      
tiles = { 'scroll.png' },
inventory_image = 'scroll.png',
wield_image = 'scroll.png',
	paramtype = 'light',
	buildable_to = true,
})



minetest.register_node("devmagic:scroll_of_blast",{
description= "Single use scroll casts level 2 Fire",
sunlight_propagates=true,
use_texture_alpha=true,
liquids_pointable = true,
on_place = function(itemstack, placer, pointed_thing)
  local pos = pointed_thing.above
  local underpos =  pointed_thing.under
  local topnode = minetest.get_node(pointed_thing.above).name
  local bottomnode = minetest.get_node(pointed_thing.under).name
  local name = placer:get_player_name()        
        spell_blast(placer,pos)
        minetest.set_node(pos, { name = topnode })
        end,
      
tiles = { 'scroll.png' },
inventory_image = 'scroll.png',
wield_image = 'scroll.png',
	paramtype = 'light',
	buildable_to = true,
})


minetest.register_node("devmagic:scroll_of_treewall",{
description= "Single use scroll casts level 2 Tree Wall",
sunlight_propagates=true,
use_texture_alpha=true,
liquids_pointable = true,
on_place = function(itemstack, placer, pointed_thing)
  local pos = pointed_thing.above
  local underpos =  pointed_thing.under
  local topnode = minetest.get_node(pointed_thing.above).name
  local bottomnode = minetest.get_node(pointed_thing.under).name
  local name = placer:get_player_name()        
  local angle=placer:get_look_horizontal()
        spell_treewall2(placer,pos,angle)
        minetest.set_node(pos, { name = "default:acacia_tree" })
        end,
      
tiles = { 'scroll.png' },
inventory_image = 'scroll.png',
wield_image = 'scroll.png',
	paramtype = 'light',
	buildable_to = true,
})


---FIRST SPELL EFFECT TYPE

--- REPLACE BLOCKS IN RADIUS--

---SEARCH in an N by N by N cube
--if sqrt(xdif^2+ydif^2+zdif^2)<N and NodeAt(X,Y,Z)==ReplaceNode 
--Assign NodeAt(X,Y,Z) to ReplacementNode

--Examples 
----Make Water into ICE DONE
----Make Ice into Water
----Make Grass into Dry Grass
----Make Dry Grass into Fire
----Make All flammables into Fire
--Plantwall
----Make Dirt into Bamboo/Papyrus
