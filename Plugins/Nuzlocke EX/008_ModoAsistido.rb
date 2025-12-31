class PokemonGlobalMetadata
    attr_accessor :revive_item_count
    alias init_revive_item_count initialize
    def initialize
        init_revive_item_count
        @revive_item_count ||= 0
    end
end

module ChallengeModes
    def self.grant_revives_if_needed
      return unless running? && on?(:MODOASISTIDO)
      revive_item = RULES[:MODOASISTIDO][:revive_item]
      return unless revive_item
      return unless GameData::Item.exists?(revive_item)
      revive_count = $PokemonGlobal.revive_item_count || 0
      return unless revive_count > 0
      pbReceiveItem(revive_item, revive_count)
    end  
end