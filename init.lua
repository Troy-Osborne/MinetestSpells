-- MAGIC MOD
-- by Troy Osborne

-- Defines Mana a basic spell functions


TroMagic = {}
TroMagic.mod = {author = "Troy Osborne" }
TroMagic.modpath = minetest.get_modpath("devmagic")

dofile(TroMagic.modpath.."./spellfire.lua")
dofile(TroMagic.modpath.."./spellhud.lua")
dofile(TroMagic.modpath.."/itempotions.lua")
dofile(TroMagic.modpath.."/spellscrolls.lua")
--dofile(TroMagic.modpath.."/spells.lua")


tau=math.pi*2
halfpi=math.pi*0.5
----------MANA

--Wait until the player is established
--Then when a player joins load them in with the default mana.

--This will be chaged in future to write the player mana to the world so it can be loaded whenever they join
minetest.register_on_joinplayer(function(player)
    if player then
	 pmeta = player:get_meta()
      
      
 if pmeta:get_int("Logins")==nil then -- if player is logging in for the first time
    pmeta:set_int("Logins", 1) -- set logins to 1
    local defaultmana=100
    pmeta:set_int("MaxMana", defaultmana) --initalise maximum mana (can be altered by status effects)
    pmeta:set_int("Mana", defaultmana) -- and current mana
    
  else -- if player has logged in before
    --increase login count
    
    pmeta:set_int("Logins", pmeta:get_int("Logins")+1) 
    end

local MaxMana= pmeta:get_int("MaxMana")
 local Mana=pmeta:get_int("Mana")
 ManaDisplay = CreateManaBar(player,Mana,MaxMana)
 LoginDisplay = DisplayLogins(player,pmeta:get_int("Logins"))
 end
end)


  
  
  
---MANA CALCULATIONS

--SUBTRACT MANA IF POSSIBLE
SpendMana= function(player,manacost)
  local pmeta = player:get_meta()
  local oldmana=pmeta:get_int("Mana")
  local newmana=oldmana-manacost
  --Check if you have enough mana to spend
  if newmana>=0 then  --If you have enough mana Adust the Mana Refresh the display and return True for success
  pmeta:set_int("Mana", newmana)
  RefreshManaDisplay(player,ManaDisplay)
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
RefreshManaDisplay(player,ManaDisplay)
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
  for xo=-math.ceil(radius),math.ceil(radius),1 do --xoffset
  for yo=-math.ceil(radius),math.ceil(radius),1 do --yoffset
  for zo=-math.ceil(radius),math.ceil(radius),1 do --zoffset
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

function evaporate_flammable(pos)
    local currentnode=minetest.get_node(pos)
    if minetest.get_item_group(currentnode.name, "flammable") >= 1 then
    minetest.set_node(pos, { name = 'air' })
  end
end

function burn_air(pos)
    local currentnode=minetest.get_node(pos)
    if currentnode.name=='air'       
  then
    minetest.set_node(pos, { name = 'devmagic:spell_flame' })
  end
end

function removefire(pos)
    local currentnode=minetest.get_node(pos)
    if currentnode.name=='fire:basic_flame' or currentnode.name=='devmagic:spell_flame'      
  then
    minetest.set_node(pos, { name = 'air' })
  end
end

function spell_treewall1(player,pos,angle)
  local manacost=2
  local cooldown=0
    castspell(player,pos,"TreeWall",function (caster,castpos) blocksinline(castpos,2,3,angle,growtree("default:acacia_tree")) end, manacost,cooldown)
end

function spell_treewall2(player,pos,angle)
  local manacost=5
  local cooldown=0
    castspell(player,pos,"TreeWall",function (caster,castpos) blocksinline(castpos,6,4,angle,growtree("default:acacia_tree")) end, manacost,cooldown)
end


function spell_freeze(player,pos)
  local manacost=2
  local cooldown=0
    castspell(player,pos,"Freeze",function (caster,castpos) blocksinradius(castpos,3,freezewater) end, manacost,cooldown)
end

function spell_heal(player)
  local manacost=10
  local cooldown=0
    castspell(player,pos,"Heal",function (caster,castpos) caster:set_hp(caster:get_hp() + 5) end, manacost,cooldown)
end

function spell_waterbreathing(player)
  local manacost=20
  local duration=60
  local cooldown=0
    castspell(player,pos,"WaterBreathing",function (caster,castpos) statuseffect(caster,duration,"WaterBreathing") end, manacost,cooldown)
end

function spell_regen(player)
  local manacost=20
  local duration=30
  local cooldown=0
    castspell(player,pos,"Regen",function (caster,castpos) statuseffect(caster,duration,"Regen") end, manacost,cooldown)
end

function spell_extinguish(player,pos)
  local manacost=5
  local cooldown=0
    castspell(player,pos,"Extinguish",function (caster,castpos) blocksinradius(castpos,6,removefire) end, manacost,cooldown)
end

function spell_ignite(player,pos)
  local manacost=4
  local cooldown=0
    castspell(player,pos,"Ignite",function (caster,castpos) blocksinradius(castpos,1.7,burn_air) end, manacost,cooldown)
end

function spell_blast(player,pos)
  local manacost=10
  local cooldown=0
    castspell(player,pos,"Blast",function (caster,castpos) 
        blocksinradius(castpos,1.5,evaporate_flammable) 
        blocksinradius(castpos,3,burn_air)
        end, manacost,cooldown)
end

spell_table={
  blast=spell_blast,
  ignite=spell_ignite,
  extinguish=spell_extinguish,
  regen=spell_regen,
  treewall=spell_treewall1,
  treewall2=spell_treewall2,
  freeze=spell_freeze,
  heal=spell_heal,
  }

local merge = function(a, b)
    local c = {}
    for k,v in pairs(a) do c[k] = v end
    for k,v in pairs(b) do c[k] = v end
    return c
end


Register_Spell_Scrolls(spell_table,{merge=merge})

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



--potions
Register_Mana_Potions({GainMana = GainMana});
  
