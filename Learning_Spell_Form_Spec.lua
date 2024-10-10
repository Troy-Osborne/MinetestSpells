function TroMagic.Set_SpellBook= function (SetBook,CurrentSpell) 
local RequiredXP="None"
local CurrentXP="None"
return "formspec_version[6]" ..
"size[10.2,11]" ..
"box[0.2,2.3;6.1,1.8;#999999]" ..
"box[0,0;10.2,0.7;#888888]" ..
"label[0.2,0.3;Active Book (Spell Learning)]" ..
"list[context;SpellBook;4.4,1;1,1;0]" ..
"label[2.5,1.3;Spell Book]" ..
"label[6.5,1.3;Learned Spells]" ..
"list[current_player;main;0.2,6;8,4;0]" ..
"label[0.3,5.7;Inventory]" ..
"list[context;learned_spells;8.9,1;1,4;0]" ..
"label[0.3,2.6;Learning Spell]" ..
"label[2.8,2.6;"..CurrentSpell.Name.."]" ..
"label[0.3,3.2;Required XP]" ..
"label[2.8,3.2;"..RequiredXP.."]" ..
"label[0.3,3.8;Current XP]" ..
"label[2.8,3.8;"..CurrentXP.."]" ..
"button_exit[9.7,0.1;0.4,0.5;Close_Spellbook;x]"
end