module ChallengeModes
  # Array of species that are to be ignored when checking for "One
  # Capture per Map" rule
  ONE_CAPTURE_WHITELIST = [
  ]

  # Hash where parent map IDs are linked to their child map IDs
  # When a Pokemon is caught in any child map, it marks the parent and vice versa
  SPLIT_MAPS_FOR_ENCOUNTERS = {
    # Example structure:
    # parent_map_id => [child_map_id1, child_map_id2, child_map_id3]
    # 1 => [2, 3, 4],  # If you catch in map 2, 3, or 4, it marks map 1 and vice versa
    10 => [107], # Ruta 3
    11 => [13], # Monte Moon
    19 => [69, 216], # Ciudad Carmín
    25 => [26], # Tunel Roca
    86 => [108], # Ruta 12
    112 => [113, 114, 115], # Zona Safari
    130 => [133, 134, 135, 136], # Islas Espuma
    110 => [111], # Camino de bicis
    119 => [120, 121, 122], # Mansión Quemada
    151 => [152, 153], # Volcan Canela
    155 => [156], # Ruta 24
    160 => [161, 162, 163, 164], # Monte Plateado
    168 => [169, 170], # Cueva Celeste
    194 => [195], # Ruta 29
    199 => [201], # Bosque Arcoiris
  }


  # Name and Description for all the rules that can be toggled in the challenge
  RULES = {

    :PERMAFAINT => { # EDITAR QUE SE ACTIVE CON CUALQUIER CLÁUSULA DEBAJO DE ESTA
      :name  => _INTL("Muerte Permanente"),
      :desc  => _INTL("Cuando un Pokémon se debilite no podrá ser revivido hasta pasarte la liga."),
      :order => 1
    },
    # Habrá que ir a los eventos de líderes y cambiar las recompensas en base a esto (modificaría los conditional branches
    # para que el switch que comprueban sea del tipo s:modo? y que así no haya que editar todos los eventos)
    :MODOASISTIDO => {
      :name  => _INTL("- Cláusula Revivir"),
      :display_name  => _INTL("Cláusula Revivir"),
      :desc  => _INTL("Al derrotar a Entrenadores importantes recibirás una resurrecciones para tus Pokémon. Puedes elegir si 1 o 3."),
      :desc_short  => _INTL("Al derrotar a Entrenadores importantes recibirás una resurrecciones para tus Pokémon."),
      :order => 2,
      :revive_item => :MAXREVIVE,
      :parent => :PERMAFAINT
    },
    :MODOVIDAS => {
      :name  => _INTL("- Cláusula Vidas"),
      :display_name  => _INTL("Cláusula Vidas"),
      :desc  => _INTL("Elige si quieres tener un número limitado de vidas, que será la cantidad de Pokémon que puedes perder."),
      :order => 3,
      :parent => :PERMAFAINT
    },
    :GAME_OVER_WHITEOUT => { # EDITAR QUE NO SE ACTIVE AUTOMÁTICAMENTE AL ELEGIR OTROS MODOS.
      :name  => _INTL("- Cláusula sin Piedad"),
      :display_name  => _INTL("Cláusula sin Piedad"),
      :desc  => _INTL("Si todos los Pokémon de tu equipo se debilitan en combate, perderás el desafío inmediatamente."),
      :order => 4,
      :parent => :PERMAFAINT
    },

    :HEALING_ITEMS_PURCHASE => {
      :name => _INTL("Compra de curas"),
      :display_name => _INTL("Compra de objetos curativos"),
      :desc => _INTL("Prohibir la compra de objetos de curación en las tiendas. (Ej: Pociones, Antídotos, Limonadas, etc.)"),
      :order => 5,
    },

    :BATTLE_ITEMS_PURCHASE => {
      :name => _INTL("Compra de obj. com."),
      :display_name => _INTL("Compra de objetos combate"),
      :desc => _INTL("Prohibir la compra de objetos de combate en las tiendas. (Ej: Ataques X, Defensas X, etc.)"),
      :order => 6,
    },

    :VITAMINS_PURCHASE => {
      :name => _INTL("Compra de vitaminas"),
      :display_name => _INTL("Compra de vitaminas"),
      :desc => _INTL("Prohibir la compra de vitaminas en las tiendas. (Ej: Proteínas, Zinc, etc.)"),
      :order => 7,
    },

    :ONE_CAPTURE => { # EDITAR QUE SE ACTIVE ESTA REGLA CON CUALQUIER CLÁUSULA DEBAJO DE ESTA.
      :name  => _INTL("Una captura por mapa"),
      :display_name  => _INTL("Cláusula Una captura por mapa"),
      :desc  => _INTL("Sólo podrás capturar un Pokémon en un mismo mapa."),
      :order => 8,
    },
    :FIRST_CAPTURE => {
      :name  => _INTL("- Cláusula Primer Pokémon"),
      :display_name  => _INTL("Cláusula Primer Pokémon"),
      :desc  => _INTL("Sólo podrás capturar el primer Pokémon salvaje con el que combatas en un mismo mapa."),
      :order => 9,
      :parent => :ONE_CAPTURE
    },
    :GIFT_CLAUSE => {
      :name  => _INTL("- Cláusula Regalos"),
      :display_name  => _INTL("Cláusula Regalos"),
      :desc  => _INTL("Los Pokémon o Huevos que te regalen no se tienen en cuenta como \"Una captura por mapa\"."),
      :order => 10,
      :parent => :ONE_CAPTURE
    },
    :SHINY_CLAUSE => {
      :name  => _INTL("- Cláusula Shiny"),
      :display_name  => _INTL("Cláusula Shiny"),
      :desc  => _INTL("Los Pokémon Shiny no se tienen en cuenta en la regla \"Una captura por mapa\"."),
      :order => 11,
      :parent => :ONE_CAPTURE
    },
    :DUPS_CLAUSE => {
      :name  => _INTL("- Cláusula Duplicados"),
      :display_name  => _INTL("Cláusula Duplicados"),
      :desc  => _INTL("Las evoluciones de tus Pokémon no se tienen en cuenta en la regla \"Una captura por mapa\"."),
      :order => 12,
      :parent => :ONE_CAPTURE
    },
    :LEGENDARY_CLAUSE => {
      :name  => _INTL("- Cláusula Legendarios"),
      :display_name  => _INTL("Cláusula Legendarios"),
      :desc  => _INTL("Puedes escapar de los Pokémon Legendarios, no se tienen en cuenta en la regla \"Una captura por mapa\"."),
      :order => 13,
      :parent => :ONE_CAPTURE
    },

    :FORCE_NICKNAME => {
      :name  => _INTL("Motes Obligatorios"),
      :display_name  => _INTL("Motes Obligatorios"),
      :desc  => _INTL("Cualquier Pokémon que sea capturado/obtenido debe tener un mote obligatoriamente."),
      :order => 14
    },
    :FORCE_SET_BATTLES => {
      :name  => _INTL("Modo de Combate Fijo"),
      :display_name  => _INTL("Modo de Combate Fijo"),
      :desc  => _INTL("Al derrotar al Pokémon de un Entrenador no se te preguntará si quieres cambiar de Pokémon."),
      :order => 15
    },
    :ITEM_RESTRICTIONS => {
      :name  => _INTL("Objetos Restringidos"),
      :desc  => _INTL("No se podrán usar Objetos X en combate. También limita el uso de curaciones y revivir por combate."),
      :order => 16
    },
    :NO_TRAINER_BATTLE_ITEMS => {
      :name  => _INTL("Bloqueo de Mochila"),
      :display_name  => _INTL("Bloqueo de Mochila"),
      :desc  => _INTL("El uso de objetos quedará deshabilitado en las Batallas contra Entrenadores."),
      :order => 17
    },
    :NO_CAPTURES => {
      :name  => _INTL("Sin Capturas"),
      :display_name  => _INTL("Sin Capturas"),
      :desc  => _INTL("Solo se podrán obtener Pokémon regalados, de intercambio, comprados o fósiles, pero no capturados."),
      :order => 18
    },
  }

 # Configuration for Item Restrictions
  ITEM_RESTRICTIONS_CONFIG = {
    :banned_items => [],                 # Items that are completely banned
    :x_items_banned => true,             # Ban X-Items (X Attack, X Defense, etc.)
    # :max_revives_per_battle => 2,      # Max Revives/Max Revives per battle
    # :max_full_restores_per_battle => 1 # Max Full Restores per battle
  }
end
