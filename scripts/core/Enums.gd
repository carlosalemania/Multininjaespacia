# ============================================================================
# Enums.gd - Enumeraciones del Juego
# ============================================================================
# Define todos los enums usados en Multi Ninja Espacial
# ============================================================================

extends Node
class_name Enums

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TIPOS DE BLOQUES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum BlockType {
	NONE = -1,      ## Sin bloque (aire)
	TIERRA = 0,     ## Bloque de tierra (color café, común)
	PIEDRA = 1,     ## Bloque de piedra (color gris, resistente)
	MADERA = 2,     ## Bloque de madera (color marrón, del árbol)
	CRISTAL = 3,    ## Bloque de cristal (color azul, transparente)
	METAL = 4,      ## Bloque de metal (color plateado, para construcción)
	ORO = 5,        ## Bloque de oro (color dorado, valioso)
	PLATA = 6,      ## Bloque de plata (color plateado claro)
	ARENA = 7,      ## Bloque de arena (color amarillo, playas)
	NIEVE = 8,      ## Bloque de nieve (color blanco)
	HIELO = 9,      ## Bloque de hielo (color azul claro)
	CESPED = 10,    ## Bloque de césped (verde brillante, superficie)
	HOJAS = 11      ## Bloque de hojas (verde oscuro, árboles)
}

## Nombres legibles de bloques (para UI)
const BLOCK_NAMES: Dictionary = {
	BlockType.TIERRA: "Tierra",
	BlockType.PIEDRA: "Piedra",
	BlockType.MADERA: "Madera",
	BlockType.CRISTAL: "Cristal",
	BlockType.METAL: "Metal",
	BlockType.ORO: "Oro",
	BlockType.PLATA: "Plata",
	BlockType.ARENA: "Arena",
	BlockType.NIEVE: "Nieve",
	BlockType.HIELO: "Hielo",
	BlockType.CESPED: "Césped",
	BlockType.HOJAS: "Hojas"
}

## Dureza de bloques (tiempo para romper, en segundos)
const BLOCK_HARDNESS: Dictionary = {
	BlockType.TIERRA: 0.5,
	BlockType.PIEDRA: 2.0,
	BlockType.MADERA: 1.0,
	BlockType.CRISTAL: 1.5,
	BlockType.METAL: 3.0,
	BlockType.ORO: 4.0,
	BlockType.PLATA: 3.5,
	BlockType.ARENA: 0.3,
	BlockType.NIEVE: 0.2,
	BlockType.HIELO: 1.5,
	BlockType.CESPED: 0.4,
	BlockType.HOJAS: 0.1
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ESTADOS DEL JUEGO
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum GameState {
	MENU,           ## En el menú principal
	LOADING,        ## Cargando mundo
	PLAYING,        ## Jugando
	PAUSED,         ## Juego pausado
	GAME_OVER       ## Fin del juego (futuro)
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TIPOS DE RECURSOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum ResourceType {
	MADERA = 0,     ## Madera (se obtiene de árboles)
	PIEDRA = 1,     ## Piedra (se obtiene de bloques de piedra)
	CRISTAL = 2     ## Cristal (se obtiene de bloques de cristal)
}

## Nombres legibles de recursos
const RESOURCE_NAMES: Dictionary = {
	ResourceType.MADERA: "Madera",
	ResourceType.PIEDRA: "Piedra",
	ResourceType.CRISTAL: "Cristal"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ACCIONES QUE DAN LUZ INTERIOR
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum LuzAction {
	CONSTRUCCION,   ## Construir 10 bloques seguidos
	RECOLECCION,    ## Recolectar 20 recursos
	TIEMPO_JUEGO    ## Jugar sin trampa (por minuto)
}

## Cantidad de Luz por acción
const LUZ_AMOUNTS: Dictionary = {
	LuzAction.CONSTRUCCION: 5,
	LuzAction.RECOLECCION: 3,
	LuzAction.TIEMPO_JUEGO: 2
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CARAS DE BLOQUES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum BlockFace {
	TOP,            ## Cara superior (+Y)
	BOTTOM,         ## Cara inferior (-Y)
	NORTH,          ## Cara norte (+Z)
	SOUTH,          ## Cara sur (-Z)
	EAST,           ## Cara este (+X)
	WEST            ## Cara oeste (-X)
}

## Normales de cada cara (para mesh generation)
const FACE_NORMALS: Dictionary = {
	BlockFace.TOP:    Vector3.UP,
	BlockFace.BOTTOM: Vector3.DOWN,
	BlockFace.NORTH:  Vector3.FORWARD,
	BlockFace.SOUTH:  Vector3.BACK,
	BlockFace.EAST:   Vector3.RIGHT,
	BlockFace.WEST:   Vector3.LEFT
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TIPOS DE SONIDO
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum SoundType {
	BLOCK_PLACE,    ## Sonido de colocar bloque
	BLOCK_BREAK,    ## Sonido de romper bloque
	COLLECT,        ## Sonido de recolectar recurso
	LUZ_GAIN,       ## Sonido de ganar Luz Interior
	BUTTON_CLICK,   ## Sonido de clic en botón UI
	MENU_OPEN,      ## Sonido de abrir menú
	MENU_CLOSE,     ## Sonido de cerrar menú
	ACHIEVEMENT,    ## Sonido de logro desbloqueado
	MAGIC_CAST,     ## Sonido de magia/poder
	TOOL_USE        ## Sonido de usar herramienta épica
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TIPOS DE MENSAJES DE TUTORIAL
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum TutorialStep {
	BIENVENIDA,     ## Mensaje de bienvenida
	MOVIMIENTO,     ## Cómo moverse (WASD)
	CAMARA,         ## Cómo mover la cámara (mouse)
	COLOCAR_BLOQUE, ## Cómo colocar bloques (click izquierdo)
	ROMPER_BLOQUE,  ## Cómo romper bloques (click derecho)
	LUZ_INTERIOR,   ## Explicación del sistema de Luz
	INVENTARIO      ## Cómo usar el inventario
}
