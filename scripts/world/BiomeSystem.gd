# ============================================================================
# BiomeSystem.gd - Sistema de Biomas
# ============================================================================
# Determina el bioma de cada zona y modifica la generación de terreno
# ============================================================================

extends Node
class_name BiomeSystem

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TIPOS DE BIOMAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum BiomeType {
	BOSQUE,     ## Muchos árboles, tierra verde
	MONTANAS,   ## Alto, rocoso, piedra
	PLAYA,      ## Bajo, arena, cristales
	NIEVE       ## Blanco, frío, hielo
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONFIGURACIÓN DE BIOMAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Datos de cada bioma
const BIOME_DATA: Dictionary = {
	BiomeType.BOSQUE: {
		"name": "Bosque",
		"surface_block": Enums.BlockType.CESPED,  # Verde brillante
		"underground_block": Enums.BlockType.TIERRA,
		"deep_block": Enums.BlockType.PIEDRA,
		"min_height": 8,
		"max_height": 14,
		"tree_chance": 0.20,  # 20% de árboles (más denso)
		"special_block": Enums.BlockType.MADERA,
		"color_tint": Color(0.35, 0.75, 0.25)  # Verde vibrante
	},
	BiomeType.MONTANAS: {
		"name": "Montañas",
		"surface_block": Enums.BlockType.PIEDRA,
		"underground_block": Enums.BlockType.PIEDRA,
		"deep_block": Enums.BlockType.PIEDRA,
		"min_height": 12,
		"max_height": 24,  # Más altas
		"tree_chance": 0.02,  # 2% de árboles
		"special_block": Enums.BlockType.ORO,
		"color_tint": Color(0.42, 0.44, 0.46)  # Gris azulado
	},
	BiomeType.PLAYA: {
		"name": "Playa",
		"surface_block": Enums.BlockType.ARENA,
		"underground_block": Enums.BlockType.ARENA,
		"deep_block": Enums.BlockType.PIEDRA,
		"min_height": 4,
		"max_height": 7,
		"tree_chance": 0.03,  # 3% de palmeras
		"special_block": Enums.BlockType.CRISTAL,
		"color_tint": Color(0.93, 0.84, 0.62)  # Arena dorada
	},
	BiomeType.NIEVE: {
		"name": "Nieve",
		"surface_block": Enums.BlockType.NIEVE,
		"underground_block": Enums.BlockType.HIELO,
		"deep_block": Enums.BlockType.PIEDRA,
		"min_height": 10,
		"max_height": 18,
		"tree_chance": 0.08,  # 8% de pinos
		"special_block": Enums.BlockType.PLATA,
		"color_tint": Color(0.98, 0.98, 1.0)  # Blanco cristalino
	}
}

## Ruido para determinar biomas
static var biome_noise: FastNoiseLite = null

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PÚBLICOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Inicializa el sistema de biomas
static func initialize(seed: int) -> void:
	biome_noise = FastNoiseLite.new()
	biome_noise.seed = seed + 1000  # Seed diferente al terreno
	biome_noise.frequency = 0.02  # Biomas grandes
	biome_noise.noise_type = FastNoiseLite.TYPE_CELLULAR

	print("🌍 Sistema de Biomas inicializado")


## Obtiene el bioma en una posición mundial XZ
static func get_biome_at(world_x: int, world_z: int) -> BiomeType:
	if biome_noise == null:
		initialize(0)

	var noise_value = biome_noise.get_noise_2d(float(world_x), float(world_z))

	# Mapear ruido [-1, 1] a biomas
	if noise_value < -0.5:
		return BiomeType.NIEVE
	elif noise_value < 0.0:
		return BiomeType.MONTANAS
	elif noise_value < 0.5:
		return BiomeType.BOSQUE
	else:
		return BiomeType.PLAYA


## Obtiene los datos de un bioma
static func get_biome_data(biome: BiomeType) -> Dictionary:
	return BIOME_DATA.get(biome, BIOME_DATA[BiomeType.BOSQUE])


## Obtiene el bloque de superficie para un bioma
static func get_surface_block(biome: BiomeType) -> Enums.BlockType:
	return get_biome_data(biome).surface_block


## Obtiene el rango de altura para un bioma
static func get_height_range(biome: BiomeType) -> Vector2i:
	var data = get_biome_data(biome)
	return Vector2i(data.min_height, data.max_height)


## Obtiene la probabilidad de árbol para un bioma
static func get_tree_chance(biome: BiomeType) -> float:
	return get_biome_data(biome).tree_chance


## Obtiene el nombre del bioma
static func get_biome_name(biome: BiomeType) -> String:
	return get_biome_data(biome).name
