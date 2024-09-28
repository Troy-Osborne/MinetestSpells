###SpellHUD

function CreateManaBar(player,CurrentMana,MaxMana)
local per=CurrentMana/MaxMana
HUD_MB_background= player:hud_add({
    hud_elem_type = "image",
    position  = {x = 0, y = 0},
    offset    = {x = 48, y = 32},
    text      = "mana_bar_empty.png",
    scale     = { x = 1.01, y = 1},
    alignment = { x = 1, y = 0.5 },
})

HUD_MB_foreground= player:hud_add({
    hud_elem_type = "image",
    position  = {x = 0, y = 0},
    offset    = {x = 48, y = 32},
    text      = "mana_bar_full.png",
    scale     = { x = per, y = 0.9},
    alignment = { x = 1, y = 0.5 },
      })

HUD_MB_leftlabel1=player:hud_add({ --Background Text (Drop shadow)
         --hud_elem_type = "text",
         type = "text",
        position  = {x = 0, y = 0},
        offset    = {x = 2, y = 34},
         text          = "Mana:",
         number    = 0x333333,
         alignment     = {x = 1, y = 0.5},  -- center aligned
         scale         = {x = 100, y = 100}, 
    })
  
HUD_MB_leftlabel2=player:hud_add({ ---Foreground Text
         --hud_elem_type = "text",
         type = "text",
        position  = {x = 0, y = 0},
        offset    = {x = 0, y = 32},
         text          = "Mana:",
         number    = 0xFFFFFF,
         alignment     = {x = 1, y = 0.5},  -- center aligned
         scale         = {x = 100, y = 100}, 
    })

HUD_MB_overlaylabel=player:hud_add({
         --hud_elem_type = "text",
         type = "text",
        position  = {x = 0, y = 0},
        offset    = {x = 176, y = 32},
         number    = 0xFFFFFF,
         text          = CurrentMana.."/"..MaxMana,
         alignment     = {x = 0, y = 0.5},  -- center aligned
         scale         = {x = 100, y = 100}, 
    })



return {background = HUD_MB_background, foreground=HUD_MB_foreground, leftlabel1=HUD_MB_leftlabel1, leftlabel2=HUD_MB_leftlabel2, overlaylabel=HUD_MB_overlaylabel}
end

RefreshManaDisplay= function(player,ManaDisplay)
local pmeta = player:get_meta()
local CurrentMana=pmeta:get_string("Mana")
local MaxMana=pmeta:get_string("MaxMana")
local per=CurrentMana/MaxMana
player:hud_change(ManaDisplay.overlaylabel, "text", "Mana:"..CurrentMana..'/'..MaxMana)  
player:hud_change(ManaDisplay.foreground, "scale", {x = per, y = 0.9})  
end

function DisplayLogins(player,LoginCount)
  player:hud_add({ --Background Text (Drop shadow)
         --hud_elem_type = "text",
         type = "text",
        position  = {x = 0, y = 0},
        offset    = {x = 2, y = 62},
         text          = "Logins:"..LoginCount,
         number    = 0x333333,
         alignment     = {x = 1, y = 0},  -- center aligned
         scale         = {x = 100, y = 100}, 
    })
  end
