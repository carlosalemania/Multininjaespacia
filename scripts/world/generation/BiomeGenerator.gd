# ============================================================================
# BiomeGenerator.gd - Generador de Biomas (Lógica Pura)
# ============================================================================
# Componente que calcula biomas usando noise. NO es autoload.
# Puede ser instanciado y testeado independientemente.
# ============================================================================

class_name BiomeGenerator

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TIPOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum BiomeType {
	BOSQUE,    ## Bioma por defecto
	DESIERTO,  ## Zonas áridas
	MONTAÑA,   ## Alturas elevadas
	PLAYA,     ## Cerca del nivel del mar
	CRISTAL    ## Zonas raras con cristales
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONFIGURACIÓN (Inmutable después de initialize)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Datos de configuración de cada bioma
const BIOME_DATA: Dictionary = {
	BiomeType.BOSQUE: {
		"name": "Bosque",
		"color": Color(0.2, 0.6, 0.2),
		"surface_block": Enums.BlockType.TIERRA,
		"underground_block": Enums.BlockType.PIEDRA,
		"deep_block": Enums.BlockType.PIEDRA,
		"min_height": 8,
		"max_height": 12,
		"tree_chance": 0.03
	},
	BiomeType.DESIERTO: {
		"name": "Desierto",
		"color": Color(0.9, 0.8, 0.5),
		"surface_block": Enums.BlockType.ARENA,
		"underground_block": Enums.BlockType.ARENA,
		"deep_block": Enums.BlockType.PIEDRA,
		"min_height": 6,
		"max_height": 9,
		"tree_chance": 0.001
	},
	BiomeType.MONTAÑA: {
		"name": "Montaña",
		"color": Color(0.5, 0.5, 0.5),
		"surface_block": Enums.BlockType.PIEDRA,
		"underground_block": Enums.BlockType.PIEDRA,
		"deep_block": Enums.BlockType.PIEDRA,
		"min_height": 12,
		"max_height": 20,
		"tree_chance": 0.01
	},
	BiomeType.PLAYA: {
		"name": "Playa",
		"color": Color(0.9, 0.9, 0.7),
		"surface_block": Enums.BlockType.ARENA,
		"underground_block": Enums.BlockType.ARENA,
		"deep_block": Enums.BlockType.PIEDRA,
		"min_height": 4,
		"max_height": 6,
		"tree_chance": 0.005
	},
	BiomeType.CRISTAL: {
		"name": "Campo de Cristal",
		"color": Color(0.7, 0.3, 0.9),
		"surface_block": Enums.BlockType.CRISTAL,
		"underground_block": Enums.BlockType.PIEDRA,
		"deep_block": Enums.BlockType.PIEDRA,
		"min_height": 10,
		"max_height": 14,
		"tree_chance": 0.0
	}
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ESTADO INTERNO
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var _noise: FastNoiseLite = null
var _seed: int = 0
var _is_initialized: bool = false

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PÚBLICOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Inicializa el generador con una semilla
func initialize(world_seed: int) -> void:
	assert(world_seed >= 0, "World seed must be non-negative")

	_seed = world_seed
	_noise = FastNoiseLite.new()
	_noise.seed = world_seed + 1000  # Seed diferente al terreno
	_noise.frequency = 0.02  # Biomas grandes (menor frecuencia = zonas más grandes)
	_noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	_is_initialized = true

	print("🌍 BiomeGenerator inicializado (seed: ", world_seed, ")")


## Calcula el bioma en una posición mundial XZ (lógica pura)
func calculate_biome(world_x: int, world_z: int) -> BiomeType:
	assert(_is_initialized, "BiomeGenerator must be initialized before use")

	var noise_value := _noise.get_noise_2d(float(world_x), float(world_z))

	# Mapear noise (-1.0 a 1.0) a tipos de bioma
	if noise_value < -0.6:
		return BiomeType.DESIERTO
	elif noise_value < -0.2:
		return BiomeType.PLAYA
	elif noise_value < 0.3:
		return BiomeType.BOSQUE
	elif noise_value < 0.7:
		return BiomeType.MONTAÑA
	else:
		return BiomeType.CRISTAL  # Bioma raro


## Obtiene los datos de configuración de un bioma (acceso inmutable)
func get_biome_config(biome: BiomeType) -> Dictionary:
	return BIOME_DATA.get(biome, BIOME_DATA[BiomeType.BOSQUE])


## Obtiene el bloque de superficie para un bioma
func get_surface_block(biome: BiomeType) -> Enums.BlockType:
	return get_biome_config(biome).surface_block


## Obtiene el bloque subterráneo para un bioma
func get_underground_block(biome: BiomeType) -> Enums.BlockType:
	return get_biome_config(biome).underground_block


## Obtiene el bloque profundo para un bioma
func get_deep_block(biome: BiomeType) -> Enums.BlockType:
	return get_biome_config(biome).deep_block


## Obtiene el rango de altura [min, max] para un bioma
func get_height_range(biome: BiomeType) -> Vector2i:
	var config := get_biome_config(biome)
	return Vector2i(config.min_height, config.max_height)


## Obtiene la probabilidad de árbol para un bioma
func get_tree_chance(biome: BiomeType) -> float:
	return get_biome_config(biome).tree_chance


## Obtiene el nombre legible del bioma
func get_biome_name(biome: BiomeType) -> String:
	return get_biome_config(biome).name


## Obtiene el color representativo del bioma (para debug/UI)
func get_biome_color(biome: BiomeType) -> Color:
	return get_biome_config(biome).color


## Verifica si el generador está listo para usar
func is_ready() -> bool:
	return _is_initialized


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS DE DEBUG
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Genera un mapa de biomas para debug (útil para visualización)
func generate_debug_map(size: int) -> Array[BiomeType]:
	assert(_is_initialized, "Generator must be initialized")

	var biome_map: Array[BiomeType] = []
	biome_map.resize(size * size)

	for x in range(size):
		for z in range(size):
			var idx := x * size + z
			biome_map[idx] = calculate_biome(x, z)

	return biome_map
