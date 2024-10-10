-- MAGIC MOD
-- by Troy Osborne

-- Defines Mana a basic spell functions


TroMagic = {}
TroMagic.mod = {author = "Troy Osborne" }
TroMagic.modpath = minetest.get_modpath("devmagic")

dofile(TroMagic.modpath.."./spellhud.lua")



local tau=math.pi*2
local halfpi=math.pi*0.5
local pi=math.pi

TroMagic.Spells={}

TroMagic.Scrolls={}

TroMagic.HUDS={}

TroMagic.Register_Spell=function (VarName,Definitions)
  --Definitions 
      --SpellName, 
      --Description 
      --Levels, 
      --Experience, 
      --ManaCost, 
      --Cooldown, 
      --CastTime, 
      --TargetType (Self,Ray,Node,Entity,Stack)
  TroMagic.Spells[VarName]=Definitions
  
  if TroMagic.Spells[VarName].Condition==nil --If condition undefined
  then --then set condition which is always true
    TroMagic.Spells[VarName].Condition= function (player,pointed_thing) return true end --If no condition specified condition always satisfied
    end
  end

local hand_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level = 0,
		groupcaps = {
			crumbly = {times={[2]=3.00, [3]=0.70}, uses=0, maxlevel=1},
			snappy = {times={[3]=0.40}, uses=0, maxlevel=1},
			oddly_breakable_by_hand = {times={[1]=3.50,[2]=2.00,[3]=0.70}, uses=0}
		},
		damage_groups = {fleshy=1},
	}

----------MANA

--Wait until the player is established
--Then when a player joins load them in with the default mana.

--This will be chaged in future to write the player mana to the world so it can be loaded whenever they join
minetest.register_on_joinplayer(function(player)
    if player then
	 pmeta = player:get_meta()
  
      
 if pmeta:get_int("Logins")==nil or pmeta:get_int("Logins")<=1   then -- if player is logging in for the first time
    
    local defaultmana=100
    pmeta:set_int("MaxMana", defaultmana) --initalise maximum mana (can be altered by status effects)
    pmeta:set_int("Mana", defaultmana) -- and current mana
    pmeta:set_int("Logins", 1) -- set logins to 1
  else -- if player has logged in before
    --increase login count
    pmeta:set_int("Logins", pmeta:get_int("Logins")+1) 
    end

local MaxMana= pmeta:get_int("MaxMana")
 local Mana=pmeta:get_int("Mana")
 TroMagic.HUDS.ManaDisplay = CreateManaBar(player,Mana,MaxMana)
 TroMagic.HUDS.LoginDisplay = DisplayLogins(player,pmeta:get_int("Logins"))
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
  RefreshManaDisplay(player,TroMagic.HUDS.ManaDisplay)
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
RefreshManaDisplay(player,TroMagic.HUDS.ManaDisplay)
end

---MISC FUNCTIONS
local function is_water(pos)
	local nn = minetest.get_node(pos).name
	return minetest.get_item_group(nn, "water") ~= 0
end

------SPELLS

TroMagic.CastSpell=function(player,spell,pointed_thing,angle,inclination,level)
  local spellname=TroMagic.Spells[spell].SpellName
  if level==nil then --look up player level
  local level=1 --needs to be replaced soon
end
if angle==nil then --look up player level
  angle=player:get_look_horizontal()+math.pi/2 --needs to be replaced soon
end
if inclination==nil then
  inclination=player:get_look_vertical()+math.pi/2
  end

  local effectfunc=TroMagic.Spells[spell].Effect
  local manacost=TroMagic.Spells[spell].ManaCost[level]
  local cooldown=TroMagic.Spells[spell].Cooldown[level]
  local casttime=TroMagic.Spells[spell].CastTime[level]
  local targettype=TroMagic.Spells[spell].TargetType
  local condition=TroMagic.Spells[spell].Condition
  --check Target is valid
  local TargetValid=false --Set to target to invalid by default and switch back to valid if corresponding condition is satisfied
if targettype=="Node" then
    local castpos = pointed_thing.under
    if castpos~=nil then
      TargetValid=true
  end
end
if targettype=="Self" or targettype=='Ray' then
  TargetValid=true --Target is always valid if targettype is self
  end

local ConditionValid=condition(player,pointed_thing) 
if ConditionValid and TargetValid then --If Condition is satisfied
  --check spell is ready
  
  if SpendMana(player,manacost) then --try to spend the mana; will return false is not enough mana available.
    if targettype=="Node" then
        effectfunc(player,level,pointed_thing.under,angle,inclination)
      end
      
    if targettype=="Self" then
        effectfunc(player,level)
      end
      
    if targettype=="Ray" then
      effectfunc(player,level,angle,inclination)
      end
    --Set Cooldown Timer
    return true -- return success
  else
    return false --return failure
  end 
  end
end

local blocksinradius= function (origin,radius,nodefunc) --applies nodefunc to all blocks in a given radius
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


local blocksinline= function(origin,width,height,angle,nodefunc)--angle in radians
  halfwidth=width/2
  for displacement=-halfwidth,halfwidth,1 do
    for yo=-1,height,1 do
      local xo=math.cos(angle)*displacement
      local zo=math.sin(angle)*displacement
      
     nodefunc({x=math.floor(0.5+xo+origin.x), y= math.floor(0.5+origin.y+yo), z= math.floor(0.5+origin.z+zo)}) 
    end
  end
end

local blocksinbeam= function(origin,width,height,angle,inclination,nodefunc,condition)--angle in radians
  for displacement=1,width,1 do
    for h=-1,height-1,1 do
      local xo=math.cos(angle)*displacement*math.sin(inclination)
      local zo=math.sin(angle)*displacement*math.sin(inclination)
      local yo=math.cos(inclination)*displacement+h
      local temppos={x=math.floor(0.5+xo+origin.x), y= math.floor(0.5+origin.y+yo), z= math.floor(0.5+origin.z+zo)}
      
      local currentnode=minetest.get_node(temppos)
      if condition(currentnode) or condition==nil then     
      minetest.after(displacement/10, nodefunc, temppos)
      end
  --   nodefunc(temppos) 
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


function is_diggable(player,nodename)
  local groups = minetest.registered_nodes[nodename].groups
  return minetest.get_dig_params(groups, hand_capabilities).diggable --Check whether the deault hand capabilites could dig the block
  --Original Version (simple)
  --return minetest.get_item_group(nodename, "snappy") >= 1 or minetest.get_item_group(nodename, "crumbly") >= 1 or minetest.get_item_group(nodename, "oddly_breakable_by_hand") >=1
end
function evaporate_digable(pos,player)
    local currentnode=minetest.get_node(pos).name
    if is_diggable(player,currentnode) then
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

function melt_all(pos)
    local currentnode=minetest.get_node(pos)
    --Turn snow into flowing water
    --turn ice into water source
    if currentnode.name=='default:ice'
  then
    minetest.set_node(pos, { name = 'default:water_source' })
  end
  
  if currentnode.name=='default:snow'
  then
    minetest.set_node(pos, { name = 'default:water_flowing' })
  end
  
  if currentnode.name== "default:dirt_with_snow"
  then
    minetest.set_node(pos, { name = 'default:dirt' })
  end
  
  if currentnode.name=='default:silver_sand'
  then
    minetest.set_node(pos, { name = 'default:sand' })
end
end

function removefire(pos)
    local currentnode=minetest.get_node(pos)
    if currentnode.name=='fire:basic_flame' or currentnode.name=='devmagic:spell_flame'      
  then
    minetest.set_node(pos, { name = 'air' })
  end
end


function fireball(player,pos,angle,inclination)
  
  
end

TroMagic.Register_Spell('TreeWall',
  {
    SpellName="Tree Wall",
    Description="Grows a wall of trees centered above the targeted node, perpendicular to the angle the player is looking",
    Levels=3, 
    Experience={Learn=100 ,--100 Experience to learn treewall
                LevelUp={[1]=150, [2]= 400, [3]= 1000}}, 
    ManaCost={[1]=2 ,[2]=5 ,[3]=8 }, 
    Cooldown={[1]=0, [2]=0 ,[3]=0}, 
    CastTime={[1]=0, [2]=0, [3]=0}, 
    TargetType="Node", -- Must be targeting a node to cast
    XPGain=5,--Experience Gained Per Cast
    Condition=nil,--If condition is nil effect will occur as long as correct Target Type
    Effect=function (caster,level,castpos,angle,inclination)
        blocksinline(castpos,2+level*4,3+level,angle,growtree("default:acacia_tree"))
      end
    })
  
TroMagic.Register_Spell('Freeze',
  {
    SpellName="Freeze",
    Description="Freezes nodes in an area around a target",
    Levels=4, 
    Experience={Learn=100 ,--100 Experience to learn Freeze
                LevelUp={[1]=150, [2]= 300, [3]= 500, [4]= 1500}}, 
    ManaCost={[1]=2 ,[2]=4 ,[3]=8, [4]=10}, 
    Cooldown={[1]=0, [2]=0 ,[3]=0, [4]=0}, 
    CastTime={[1]=0, [2]=0, [3]=0, [4]=0}, 
    TargetType="Node", -- Must be targeting a node to cast
    XPGain=5,--Experience Gained Per Cast
    Condition=nil,--If condition is nil effect will occur as long as correct Target Type
    Effect=function (caster,level,castpos,angle,inclination)
        blocksinradius(castpos,1+level*2,freezewater)
      end
    })
  
TroMagic.Register_Spell('Heal',
  {
    SpellName="Heal Self",
    Description="Freezes nodes in an area around a target",
    Levels=8, 
    Experience={Learn=100 ,--100 Experience to learn Heal
                LevelUp={[1]=150, [2]= 300, [3]= 500, [4]= 750, [5] = 1000, [6]= 1500, [7]= 2000, [8] = 2500}}, 
    ManaCost={[1]=10 ,[2]=12 ,[3]=15, [4]=18, [5]=20,  [6]=25,  [7]=30,  [8]=30}, 
    Cooldown={[1]=0, [2]=0 ,[3]=0, [4]=0, [5]=0, [6]=0, [7]=0, [8]=0}, 
    CastTime={[1]=0, [2]=0, [3]=0, [4]=0, [5]=0, [6]=0, [7]=0, [8]=0}, 
    TargetType="Self", --Casts on seld regardless of where you're pointing
    XPGain=5,--Experience Gained Per Cast
    Condition=nil,--If condition is nil effect will occur as long as correct Target Type
    Effect=function (caster,level)
        caster:set_hp(caster:get_hp() + 5 + level*3)
      end
    })

TroMagic.Register_Spell('WaterBreathing',
  {
    SpellName="Water Breathing",
    Description="Allows you to breath underwater for a short time",
    Levels=5, 
    Experience={Learn=150 ,
                LevelUp={[1]=250, [2]= 500, [3]= 750, [4]= 1250, [5] = 2000}}, 
    ManaCost={[1]=10 ,[2]=12 ,[3]=15, [4]=18, [5]=20}, 
    Cooldown={[1]=0, [2]=0 ,[3]=0, [4]=0, [5]=0}, 
    CastTime={[1]=0, [2]=0, [3]=0, [4]=0, [5]=0}, 
    TargetType="Self", --Casts on seld regardless of where you're pointing
    XPGain=10,--Experience Gained Per Cast
    Condition=nil,--If condition is nil effect will occur as long as correct Target Type
    Effect=function (caster,level)
         statuseffect(caster, Level*10,"WaterBreathing")
      end
    })
  
TroMagic.Register_Spell('Regen',
  {
    SpellName="Regen Self",
    Description="Automatically Heals Self Intermittently",
    Levels=5, 
    Experience={Learn=150 ,
                LevelUp={[1]=250, [2]= 500, [3]= 750, [4]= 1250, [5] = 2000}}, 
    ManaCost={[1]=20 ,[2]=25 ,[3]=30, [4]=35, [5]=40}, 
    Cooldown={[1]=0, [2]=0 ,[3]=0, [4]=0, [5]=0}, 
    CastTime={[1]=0, [2]=0, [3]=0, [4]=0, [5]=0}, 
    TargetType="Self", --Casts on seld regardless of where you're pointing
    XPGain=10,--Experience Gained Per Cast
    Condition=nil,--If condition is nil effect will occur as long as correct Target Type
    Effect=function (caster,level)
         statuseffect(caster, 15+ Level*15,"Regen")
      end
    })
  
  

TroMagic.Register_Spell('Extinguish',
  {
    SpellName="Extinguish",
    Description="Removes all fire within a large area",
    Levels=4, 
    Experience={Learn=100 ,--100 Experience to learn Freeze
                LevelUp={[1]=150, [2]= 300, [3]= 500, [4]= 1500}}, 
    ManaCost={[1]=5 ,[2]=6 ,[3]=8, [4]=10}, 
    Cooldown={[1]=0, [2]=0 ,[3]=0, [4]=0}, 
    CastTime={[1]=0, [2]=0, [3]=0, [4]=0}, 
    TargetType="Node", -- Must be targeting a node to cast
    XPGain=5,--Experience Gained Per Cast
    Condition=nil,--If condition is nil effect will occur as long as correct Target Type
    Effect=function (caster,level,castpos,angle,inclination)
        blocksinradius(castpos,6+level,removefire)
      end
    })
  

TroMagic.Register_Spell('Ignite',
  {
    SpellName="Ignite",
    Description="Creates a fire which spreads to any flammable object and melts where possible",
    Levels=4, 
    Experience={Learn=100 ,--100 Experience to learn Freeze
                LevelUp={[1]=150, [2]= 300, [3]= 500, [4]= 1500}}, 
    ManaCost={[1]=4 ,[2]=6 ,[3]=8, [4]=10}, 
    Cooldown={[1]=0, [2]=0 ,[3]=0, [4]=0}, 
    CastTime={[1]=0, [2]=0, [3]=0, [4]=0}, 
    TargetType="Node", -- Must be targeting a node to cast
    XPGain=5,--Experience Gained Per Cast
    Condition=nil,--If condition is nil effect will occur as long as correct Target Type
    Effect=function (caster,level,castpos,angle,inclination)
        blocksinradius(castpos,1.2+0.5*level,burn_air)
        blocksinradius(castpos,1+level,melt_all)
      end
    })
  
TroMagic.Register_Spell('Blast',
  {
    SpellName="Blast",
    Description="Creates an explosion which evaporates any flammable objects burning and melting the surroundings where possible",
    Levels=5, 
    Experience={Learn=250 ,--100 Experience to learn Freeze
                LevelUp={[1]=150, [2]= 300, [3]= 500, [4]= 1250, [5]= 2500}}, 
    ManaCost={[1]=10 ,[2]=16 ,[3]=20, [4]=25, [5]=35}, 
    Cooldown={[1]=0, [2]=0 ,[3]=0, [4]=0 , [5]=0}, 
    CastTime={[1]=0, [2]=0, [3]=0, [4]=0, [5]=0}, 
    TargetType="Node", -- Must be targeting a node to cast
    XPGain=10,--Experience Gained Per Cast
    Condition=nil,--If condition is nil effect will occur as long as correct Target Type
    Effect=function (caster,level,castpos,angle,inclination)
        blocksinradius(castpos,0.5+level,evaporate_flammable) 
        blocksinradius(castpos,2+level,burn_air)
        blocksinradius(castpos,1.75+level*1.25,melt_all)
      end
    })
  
TroMagic.Register_Spell('StoneBridge',
  {
    SpellName="Stone Bridge",
    Description="Creates a temporary bridge of stones",
    Levels=4, 
    Experience={Learn=100 ,--100 Experience to learn Stone Wall
                LevelUp={[1]=250, [2]= 400, [3]= 750, [4]= 1000}}, 
    ManaCost={[1]=5 ,[2]=8 ,[3]=12, [4]=16}, 
    Cooldown={[1]=0, [2]=0 ,[3]=0, [4]=0}, 
    CastTime={[1]=0, [2]=0, [3]=0, [4]=0}, 
    TargetType="Ray", -- Must be targeting a node to cast
    XPGain=5,--Experience Gained Per Cast
    Condition=nil,--If condition is nil effect will occur as long as correct Target Type
    Effect=function (caster,level,angle,inclination)
        blocksinbeam(caster:getpos(),4+level*2,1,angle,inclination,create_spell_stone,function (curnode) return curnode.name=='air' end)
      end
    })
  

TroMagic.mergetables = function(a, b)
    local c = {}
    for k,v in pairs(a) do c[k] = v end
    for k,v in pairs(b) do c[k] = v end
    return c
end


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

--Spell Ideas

--Fire
  -- Fireball (projectile, casts ignite on impact)
  -- Fire Summon (To be decided when mobs designed)
  

--Earth
 --Pillar
    --Creates a pillar and raises the surface to the top of it.
 
 --Fissure
    --Creates a crevice in the earth 
    
 --Island
    --Creates an Island in the shallows (5 blocks deep at most)
    
 --Cavern
    --Creates a Room in a cliff
    
 -- Stone Bridge
    --Creates a Beam of stone along the raycast, stone turns into cobble in 2-3 seconds, cobble turns into gravel after 5 seconds, gravel collapses after 5 seconds
    
--Water
  --Flood Creates a grid of water sources for 2 seconds and then disappears


--potions






---------THROWABLES

local function blast(pos, radius)
	local pos1 = vector.subtract(pos, radius)
	local pos2 = vector.add(pos, radius)

	for _, p in ipairs(minetest.find_nodes_in_area(pos1, pos2, {"group:flora", "group:dig_immediate"})) do
		if vector.distance(pos, p) <= radius then
			local node = minetest.get_node(p).name

			if node ~= "air" then
				minetest.add_item(p, node)
			end

			minetest.remove_node(p)
		end
	end
end

grenades.register_grenade("devmagic:exposive_potion", {
	description = "Explosive Potion",
	image = "devmagic_exposive_potion.png",
  clock = 2,
	on_explode = function(pos, name)
		if not name or not pos then
			return
		end

		local player = minetest.get_player_by_name(name)

		local smokeradius = 1
    
    local blastsize=4

		minetest.add_particlespawner({
			amount = 20,
			time = 0.2,
			minpos = vector.subtract(pos, smokeradius),
			maxpos = vector.add(pos, smokeradius),
			minvel = {x = 0, y = 0, z = 0},
			maxvel = {x = 2, y = 2, z = 2},
			minacc = {x = 0, y = 1, z = 0},
			maxacc = {x = 0, y = 1, z = 0},
			minexptime = 0.3,
			maxexptime = 0.6,
			minsize = 2,
			maxsize = 4,
			collisiondetection = true,
			collision_removal = false,
			vertical = false,
			texture = "devmagic_smoke_particle.png",
		})

		minetest.add_particle({
			pos = pos,
			velocity = {x=0, y=0, z=0},
			acceleration = {x=0, y=0, z=0},
			expirationtime = 0.2,
			size = 20,
			collisiondetection = false,
			collision_removal = false,
			object_collision = false,
			vertical = false,
			texture = "devmagic_boom.png",
			glow = 10
		})

        blocksinradius(pos,blastsize/2,function (nodepos) evaporate_digable(nodepos,player)
          end) 
        --ALL BLOCKS DIGGABLE IN CREATIVE MODE 
        
	end,
})

grenades.register_grenade("devmagic:fire_bomb", {
	description = "Fire Bomb",
	image = "devmagic_fire_bomb.png",
  clock = 2,
	on_explode = function(pos, name)
		if not name or not pos then
			return
		end

		local player = minetest.get_player_by_name(name)

		local smokeradius = 1
    
    local blastsize =4

		minetest.add_particlespawner({
			amount = 20,
			time = 0.2,
			minpos = vector.subtract(pos, smokeradius),
			maxpos = vector.add(pos, smokeradius),
			minvel = {x = 0, y = 0, z = 0},
			maxvel = {x = 2, y = 2, z = 2},
			minacc = {x = 0, y = 1, z = 0},
			maxacc = {x = 0, y = 1, z = 0},
			minexptime = 0.3,
			maxexptime = 0.6,
			minsize = 2,
			maxsize = 4,
			collisiondetection = true,
			collision_removal = false,
			vertical = false,
			texture = "devmagic_smoke_particle.png",
		})

		minetest.add_particle({
			pos = pos,
			velocity = {x=0, y=0, z=0},
			acceleration = {x=0, y=0, z=0},
			expirationtime = 0.2,
			size = 20,
			collisiondetection = false,
			collision_removal = false,
			object_collision = false,
			vertical = false,
			texture = "devmagic_boom.png",
			glow = 10
		})

        blocksinradius(pos,blastsize/2,function (nodepos) burn_air(nodepos,player)
            melt_all(nodepos,player)
          end) 
        --ALL BLOCKS DIGGABLE IN CREATIVE MODE 
        
	end,
})


minetest.register_craft({
	type = "shaped",
	output = "devmagic:explosive_potion",
	recipe = {
		{"default:obsidian_shard", "default:steel_ingot", "default:obsidian_shard"},
		{"default:steel_ingot", "tnt:gunpowder", "default:steel_ingot"},
		{"default:obsidian_shard", "default:steel_ingot", "default:obsidian_shard"}
	},
})

----THROWABLES END
dofile(TroMagic.modpath.."./spellfire.lua")
dofile(TroMagic.modpath.."/spellstone.lua")
dofile(TroMagic.modpath.."/spellscrolls.lua")


dofile(TroMagic.modpath.."/itempotions.lua")
Register_Mana_Potions({GainMana = GainMana});