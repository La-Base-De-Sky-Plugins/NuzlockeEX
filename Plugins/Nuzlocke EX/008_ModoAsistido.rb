class PokemonGlobalMetadata
    attr_accessor :revive_item_count
    alias init_revive_item_count initialize
    def initialize
        init_revive_item_count
        @revive_item_count ||= 0
    end
end