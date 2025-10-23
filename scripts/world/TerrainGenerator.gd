# ============================================================================
# TerrainGenerator.gd - Generador de Terreno Procedural
# ============================================================================
# Genera terreno usando Perlin Noise (FastNoiseLite)
# ============================================================================

extends Node
class_name TerrainGenerator

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Generador de ruido Perlin
var noise: FastNoiseLite = null

## Semilla del mundo (para generar siempre el mismo mundo)
@export var world_seed: int = 12345

## Frecuencia del ruido (cuanto más bajo, más suave el terreno)
@export var noise_frequency: float = 0.05

## Altura mínima del terreno
@export var min_terrain_height: int = 5

## Altura máxima del terreno
@export var max_terrain_height: int = 15

## Profundidad de piedra bajo la superficie
@export var stone_depth: int = 3

## Probabilidad de generar un árbol (0.0 - 1.0)
@export var tree_spawn_chance: float = 0.02

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	# Configurar generador de ruido
	noise = FastNoiseLite.new()
	noise.seed = world_seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = noise_frequency

	# Inicializar sistema de biomas
	BiomeSystem.initialize(world_seed)

	print("🌄 TerrainGenerator inicializado (seed: ", world_seed, ")")


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PÚBLICOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Genera el terreno para un chunk específico
func generate_chunk_terrain(chunk: Chunk) -> void:
	var chunk_world_pos = Utils.chunk_to_world_position(chunk.chunk_position)

	# Iterar por cada columna XZ del chunk
	for local_x in range(Constants.CHUNK_SIZE):
		for local_z in range(Constants.CHUNK_SIZE):
			# Calcular posición global del bloque
			var world_x = int(chunk_world_pos.x) + local_x
			var world_z = int(chunk_world_pos.z) + local_z

			# Obtener bioma y altura del terreno
			var biome = BiomeSystem.get_biome_at(world_x, world_z)
			var terrain_height = _get_terrain_height(world_x, world_z)

			# Generar columna de bloques
			_generate_terrain_column(chunk, Vector3i(local_x, 0, local_z), terrain_height)

			# Intentar generar árbol según probabilidad del bioma
			var biome_tree_chance = BiomeSystem.get_tree_chance(biome)
			if Utils.random_chance(biome_tree_chance):
				_try_spawn_tree(chunk, Vector3i(local_x, terrain_height + 1, local_z))

	# Intentar generar estructuras especiales
	StructureGenerator.try_generate_random_structures(chunk, chunk.chunk_position)


## Cambia la semilla del mundo
func set_seed(new_seed: int) -> void:
	world_seed = new_seed
	if noise:
		noise.seed = new_seed
	print("🌱 Nueva semilla de mundo: ", new_seed)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PRIVADOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Obtiene la altura del terreno en una posición XZ usando Perlin Noise y bioma
func _get_terrain_height(world_x: int, world_z: int) -> int:
	# Obtener bioma para esta posición
	var biome = BiomeSystem.get_biome_at(world_x, world_z)
	var height_range = BiomeSystem.get_height_range(biome)

	# Usar ruido para variar dentro del rango del bioma
	var noise_value = noise.get_noise_2d(float(world_x), float(world_z))
	var normalized = (noise_value + 1.0) / 2.0

	# Mapear a rango de altura del bioma
	var height = int(lerp(float(height_range.x), float(height_range.y), normalized))

	return clampi(height, 0, Constants.MAX_WORLD_HEIGHT - 1)


## Genera una columna vertical de bloques según el bioma
func _generate_terrain_column(chunk: Chunk, local_pos: Vector3i, terrain_height: int) -> void:
	# Calcular posición mundial para determinar bioma
	var chunk_world_pos = Utils.chunk_to_world_position(chunk.chunk_position)
	var world_x = int(chunk_world_pos.x) + local_pos.x
	var world_z = int(chunk_world_pos.z) + local_pos.z

	# Obtener bioma
	var biome = BiomeSystem.get_biome_at(world_x, world_z)
	var biome_data = BiomeSystem.get_biome_data(biome)

	# Llenar desde Y=0 hasta la altura del terreno
	for y in range(terrain_height + 1):
		var block_pos = Vector3i(local_pos.x, y, local_pos.z)
		var block_type = _get_block_type_for_biome(y, terrain_height, biome_data)

		chunk.set_block(block_pos, block_type)


## Determina el tipo de bloque según la altura y bioma
func _get_block_type_for_biome(current_y: int, terrain_height: int, biome_data: Dictionary) -> Enums.BlockType:
	# Superficie: Usar bloque de superficie del bioma (césped, nieve, arena, etc.)
	if current_y == terrain_height:
		return biome_data.surface_block

	# Capa subsuperficial (2-3 bloques bajo superficie)
	elif current_y >= terrain_height - 3:
		return biome_data.underground_block

	# Profundo: Usar bloque profundo del bioma
	else:
		return biome_data.deep_block


## Determina el tipo de bloque según la altura en la columna (legacy, mantener por compatibilidad)
func _get_block_type_for_height(current_y: int, terrain_height: int) -> Enums.BlockType:
	# Superficie: Tierra
	if current_y == terrain_height:
		return Enums.BlockType.TIERRA

	# Capa de piedra bajo la superficie
	elif current_y >= terrain_height - stone_depth:
		return Enums.BlockType.PIEDRA

	# Profundo: Piedra
	else:
		return Enums.BlockType.PIEDRA


## Intenta generar un árbol moderno con hojas verdes
func _try_spawn_tree(chunk: Chunk, local_pos: Vector3i) -> void:
	# Verificar que esté dentro del chunk (con espacio para el árbol)
	if local_pos.x < 2 or local_pos.x >= Constants.CHUNK_SIZE - 2:
		return
	if local_pos.z < 2 or local_pos.z >= Constants.CHUNK_SIZE - 2:
		return
	if local_pos.y + 6 >= Constants.MAX_WORLD_HEIGHT:
		return

	# Árbol moderno: 4-5 bloques de madera + copa de hojas 3x3x3
	var trunk_height = 4 + (randi() % 2)  # 4 o 5 bloques

	# Tronco de madera
	for i in range(trunk_height):
		var trunk_pos = Vector3i(local_pos.x, local_pos.y + i, local_pos.z)
		chunk.set_block(trunk_pos, Enums.BlockType.MADERA)

	# Copa de hojas (3x3 en las dos capas superiores)
	var leaves_start_y = local_pos.y + trunk_height - 1

	# Capa media de hojas (3x3)
	for x in range(-1, 2):
		for z in range(-1, 2):
			var leaf_pos = Vector3i(local_pos.x + x, leaves_start_y, local_pos.z + z)
			chunk.set_block(leaf_pos, Enums.BlockType.HOJAS)

	# Capa superior de hojas (cruz + centro)
	var top_y = leaves_start_y + 1
	chunk.set_block(Vector3i(local_pos.x, top_y, local_pos.z), Enums.BlockType.HOJAS)
	chunk.set_block(Vector3i(local_pos.x + 1, top_y, local_pos.z), Enums.BlockType.HOJAS)
	chunk.set_block(Vector3i(local_pos.x - 1, top_y, local_pos.z), Enums.BlockType.HOJAS)
	chunk.set_block(Vector3i(local_pos.x, top_y, local_pos.z + 1), Enums.BlockType.HOJAS)
	chunk.set_block(Vector3i(local_pos.x, top_y, local_pos.z - 1), Enums.BlockType.HOJAS)

	# Punta del árbol
	chunk.set_block(Vector3i(local_pos.x, top_y + 1, local_pos.z), Enums.BlockType.HOJAS)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# GENERACIÓN ADICIONAL (FUTURO)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Genera cuevas (TODO: implementar con noise 3D)
func _generate_caves(_chunk: Chunk) -> void:
	pass  # Futuro: usar noise 3D para crear cuevas


## Genera minerales/cristales (TODO)
func _generate_ores(_chunk: Chunk) -> void:
	pass  # Futuro: generar vetas de cristales/metal
