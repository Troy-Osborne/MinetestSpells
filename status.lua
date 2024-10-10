function MakeEffectsTable(PassiveSpells,ItemEffects,EquipmentEffects)
  return {spell_effects={},

function player_effect(name,definitions) --must have unique same for deactivating
    local effect={name=name,definitions={}}
    return effect
end


function apply_effect(player,effect,duration,removeondeath,removeonsleep,positive) 
  -- if duration is nil or zero it's indefinite until explictly disabled
  -- if remove
  
  
  
end

function remove_effect(player,effectname)
  
  end