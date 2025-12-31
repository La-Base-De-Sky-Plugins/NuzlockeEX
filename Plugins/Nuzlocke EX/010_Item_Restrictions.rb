#===============================================================================
# Item Restrictions Rule for Challenge Modes
# Bans X-Items and limits Revive/Full Restore usage per battle
#===============================================================================
module GameData
  class Item
    def is_x_item?;        return has_flag?("XItem");   end if !method_defined?(:is_x_item?)
    def is_healing_item?;  return has_flag?("Healing"); end if !method_defined?(:is_healing_item?)
    def is_vitamin?;       return has_flag?("Vitamin"); end if !method_defined?(:is_vitamin?)
  end
end


module ChallengeModes
  # Initialize item usage counter
  @battle_item_usage ||= {}
  
  # Check if Item Restrictions rule is active
  def self.item_restrictions?
    return on?(:ITEM_RESTRICTIONS)
  end
  
  # Reset item usage counter (called at battle start)
  def self.reset_battle_items
    @battle_item_usage = {}
  end
  
  # Get item usage count for current battle
  def self.get_item_usage(item_id)
    @battle_item_usage ||= {}
    return @battle_item_usage[item_id] || 0
  end
  
  # Increment item usage count
  def self.increment_item_usage(item_id)
    @battle_item_usage ||= {}
    @battle_item_usage[item_id] ||= 0
    @battle_item_usage[item_id] += 1
  end
  
  # Check if item is allowed
  def self.can_use_item?(item_id)
    return true if !item_restrictions?
    
    item_data = GameData::Item.get(item_id)
    item_symbol = item_data.id
    
    # Check if X-Item and banned
    return false if ITEM_RESTRICTIONS_CONFIG[:x_items_banned] && item_data.is_x_item?

    # Check if item is banned
    return false if ITEM_RESTRICTIONS_CONFIG[:banned_items].include?(item_symbol)
    
    # Check if item is limited
    if ITEM_RESTRICTIONS_CONFIG[:limited_items].include?(item_symbol)
      limit = ITEM_RESTRICTIONS_CONFIG[:item_limits][item_symbol] || 3
      usage = get_item_usage(item_symbol)
      return usage < limit
    end
    
    return true
  end
  
  # Get remaining uses for limited item
  def self.remaining_uses(item_id)
    return -1 if !item_restrictions?
    
    item_data = GameData::Item.get(item_id)
    item_symbol = item_data.id
    
    return -1 if !ITEM_RESTRICTIONS_CONFIG[:limited_items].include?(item_symbol)
    
    limit = ITEM_RESTRICTIONS_CONFIG[:item_limits][item_symbol] || 3
    usage = get_item_usage(item_symbol)
    return limit - usage
  end
end

#===============================================================================
# Hook into battle item usage
#===============================================================================
class Battle
  alias __challengemodes_itemrestrict__pbUseItemOnPokemon pbUseItemOnPokemon unless method_defined?(:__challengemodes_itemrestrict__pbUseItemOnPokemon)
  
  def pbUseItemOnPokemon(item, battler, scene)
    # Check if Item Restrictions rule is active
    if ChallengeModes.item_restrictions?
      item_data = GameData::Item.get(item)
      item_symbol = item_data.id
      
      # Check if item is allowed
      if !ChallengeModes.can_use_item?(item_symbol)
        # Check if banned
        if ChallengeModes::ITEM_RESTRICTIONS_CONFIG[:banned_items].include?(item_symbol)
          scene.pbDisplay(_INTL("¡Está prohibido usar {1} en el modo desafío!", item_data.name))
          return false
        end

        if ChallengeModes::ITEM_RESTRICTIONS_CONFIG[:x_items_banned] && item_data.is_x_item?
          scene.pbDisplay(_INTL("¡Está prohibido usar {1} en el modo desafío!", item_data.name))
          return false
        end
        
        # Check if limit reached
        if ChallengeModes::ITEM_RESTRICTIONS_CONFIG[:limited_items].include?(item_symbol)
          limit = ChallengeModes::ITEM_RESTRICTIONS_CONFIG[:item_limits][item_symbol] || 3
          scene.pbDisplay(_INTL("¡Ya has usado {1} en este combate!", item_data.name))
          scene.pbDisplay(_INTL("Límite: {1} por combate", limit))
          return false
        end
      end
      
      # Track usage for limited items
      if ChallengeModes::ITEM_RESTRICTIONS_CONFIG[:limited_items].include?(item_symbol)
        ChallengeModes.increment_item_usage(item_symbol)
        
        # Show remaining uses
        remaining = ChallengeModes.remaining_uses(item_symbol)
        if remaining == 0
          scene.pbDisplay(_INTL("(Ese fue tu último {1} para este combate)", item_data.name))
        elsif remaining > 0
          scene.pbDisplay(_INTL("({1} {2} restantes para este combate)", remaining, item_data.name))
        end
      end
    end
    
    # Normal item usage
    return __challengemodes_itemrestrict__pbUseItemOnPokemon(item, battler, scene)
  end
  
  # Reset item counter at battle start
  alias __challengemodes_itemrestrict__pbStartBattle pbStartBattle unless method_defined?(:__challengemodes_itemrestrict__pbStartBattle)
  
  def pbStartBattle
    ChallengeModes.reset_battle_items if ChallengeModes.item_restrictions?
    return __challengemodes_itemrestrict__pbStartBattle
  end
end

#===============================================================================
# Block banned items in ItemHandlers
#===============================================================================
ItemHandlers::CanUseInBattle.add(:battle_items,
  proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
    next true if !ChallengeModes.item_restrictions?
    
    item_data = GameData::Item.get(item)
    item_symbol = item_data.id
    
    # Check if item is banned
    if ChallengeModes::ITEM_RESTRICTIONS_CONFIG[:banned_items].include?(item_symbol)
      scene.pbDisplay(_INTL("¡Está prohibido usar {1} en el modo desafío!", item_data.name)) if showMessages
      next false
    end
    
    # Check if X-Item and banned
    if ChallengeModes::ITEM_RESTRICTIONS_CONFIG[:x_items_banned] && item_data.is_x_item?
      scene.pbDisplay(_INTL("¡Está prohibido usar {1} en el modo desafío!", item_data.name)) if showMessages
      next false
    end
    
    # Check if item limit reached
    if ChallengeModes::ITEM_RESTRICTIONS_CONFIG[:limited_items].include?(item_symbol)
      if !ChallengeModes.can_use_item?(item_symbol)
        limit = ChallengeModes::ITEM_RESTRICTIONS_CONFIG[:item_limits][item_symbol] || 3
        scene.pbDisplay(_INTL("¡Ya has usado {1} {2} en este combate!", limit, item_data.name)) if showMessages
        next false
      end
    end
    
    next true
  }
)

#===============================================================================
# Block X-Items specifically (Battle stat boosters)
#===============================================================================
# X Attack variants
ItemHandlers::CanUseInBattle.copy(:battle_items, :XATTACK)
ItemHandlers::CanUseInBattle.copy(:battle_items, :XATTACK2)
ItemHandlers::CanUseInBattle.copy(:battle_items, :XATTACK3)
ItemHandlers::CanUseInBattle.copy(:battle_items, :XATTACK6)
# X Defense variants
ItemHandlers::CanUseInBattle.copy(:battle_items, :XDEFENSE)
ItemHandlers::CanUseInBattle.copy(:battle_items, :XDEFENSE2)
ItemHandlers::CanUseInBattle.copy(:battle_items, :XDEFENSE3)
ItemHandlers::CanUseInBattle.copy(:battle_items, :XDEFENSE6)
# X Sp. Atk variants
ItemHandlers::CanUseInBattle.copy(:battle_items, :XSPATK)
ItemHandlers::CanUseInBattle.copy(:battle_items, :XSPATK2)
ItemHandlers::CanUseInBattle.copy(:battle_items, :XSPATK3)
ItemHandlers::CanUseInBattle.copy(:battle_items, :XSPATK6)
# X Sp. Def variants
ItemHandlers::CanUseInBattle.copy(:battle_items, :XSPDEF)
ItemHandlers::CanUseInBattle.copy(:battle_items, :XSPDEF2)
ItemHandlers::CanUseInBattle.copy(:battle_items, :XSPDEF3)
ItemHandlers::CanUseInBattle.copy(:battle_items, :XSPDEF6)
# X Speed variants
ItemHandlers::CanUseInBattle.copy(:battle_items, :XSPEED)
ItemHandlers::CanUseInBattle.copy(:battle_items, :XSPEED2)
ItemHandlers::CanUseInBattle.copy(:battle_items, :XSPEED3)
ItemHandlers::CanUseInBattle.copy(:battle_items, :XSPEED6)
# X Accuracy variants
ItemHandlers::CanUseInBattle.copy(:battle_items, :XACCURACY)
ItemHandlers::CanUseInBattle.copy(:battle_items, :XACCURACY2)
ItemHandlers::CanUseInBattle.copy(:battle_items, :XACCURACY3)
ItemHandlers::CanUseInBattle.copy(:battle_items, :XACCURACY6)
# Max Mushrooms
ItemHandlers::CanUseInBattle.copy(:battle_items, :MAXMUSHROOMS)
# Dire Hit variants
ItemHandlers::CanUseInBattle.copy(:battle_items, :DIREHIT)
ItemHandlers::CanUseInBattle.copy(:battle_items, :DIREHIT2)
ItemHandlers::CanUseInBattle.copy(:battle_items, :DIREHIT3)
# Guard Spec
ItemHandlers::CanUseInBattle.copy(:battle_items, :GUARDSPEC)

# Revives and Full Restores
ItemHandlers::CanUseInBattle.copy(:battle_items, :REVIVE)
ItemHandlers::CanUseInBattle.copy(:battle_items, :MAXREVIVE)
ItemHandlers::CanUseInBattle.copy(:battle_items, :FULLRESTORE)

#===============================================================================
# Script command to check item usage
#===============================================================================
def pbCheckItemUsage
  if !ChallengeModes.item_restrictions?
    pbMessage(_INTL("No hay restricciones de objetos activas."))
    return
  end
  
  text = "Uso de objetos en combate:\\n"
  used_any = false
  
  ChallengeModes::ITEM_RESTRICTIONS_CONFIG[:limited_items].each do |item_symbol|
    usage = ChallengeModes.get_item_usage(item_symbol)
    if usage > 0
      item_name = GameData::Item.get(item_symbol).name
      limit = ChallengeModes::ITEM_RESTRICTIONS_CONFIG[:item_limits][item_symbol] || 3
      text += "#{item_name}: #{usage}/#{limit}\\n"
      used_any = true
    end
  end
  
  if !used_any
    text += "No se han usado objetos limitados aún."
  end
  
  pbMessage(_INTL(text))
end

#===============================================================================
# Console logging for debugging
#===============================================================================
if ChallengeModes.running?
  puts "Modos Desafío: Regla de Restricciones de Objetos cargada"
  puts "  - Prohibir Objetos X: #{ChallengeModes::ITEM_RESTRICTIONS_CONFIG[:x_items_banned] ? 'Sí' : 'No'}"
  puts "  - Objetos prohibidos: #{ChallengeModes::ITEM_RESTRICTIONS_CONFIG[:banned_items]&.join(', ')}"
  puts "  - Objetos limitados: #{ChallengeModes::ITEM_RESTRICTIONS_CONFIG[:limited_items]&.join(', ')}"

  puts "  - Rastrea el uso por combate"
end
