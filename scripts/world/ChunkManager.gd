# ============================================================================
# ChunkManager.gd - Gestor de Chunks del Mundo
# ============================================================================
# Nodo que gestiona la creación, actualización y destrucción de chunks
# ============================================================================

extends Node3D
class_name ChunkManager

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SEÑALES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Emitida cuando se coloca un bloque
signal block_placed(block_pos: Vector3i, block_type: Enums.BlockType)

## Emitida cuando se rompe un bloque
signal block_broken(block_pos: Vector3i, block_type: Enums.BlockType)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Dictionary de chunks activos: Vector3i (chunk_pos) → Chunk
var chunks: Dictionary = {}

## Generador de terreno
var terrain_generator: Node = null

## Tamaño del mundo en chunks (10x10 chunks = 100x100 bloques)
const WORLD_SIZE_CHUNKS: int = 10

## Chunks pendientes de generar mesh
var chunks_to_update: Array[Chunk] = []

## Máximo de chunks a actualizar por frame (para evitar lag)
const MAX_CHUNKS_PER_FRAME: int = 2

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	print("🌍 ChunkManager inicializado")


func _process(_delta: float) -> void:
	# Actualizar meshes de chunks pendientes
	_update_pending_chunks()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PÚBLICOS - GESTIÓN DE CHUNKS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Genera el mundo inicial (todos los chunks)
func generate_world(generator: Node) -> void:
	terrain_generator = generator

	print("🌍 Generando mundo (", WORLD_SIZE_CHUNKS, "x", WORLD_SIZE_CHUNKS, " chunks)...")

	var start_time = Time.get_ticks_msec()

	# Generar chunks en un área centrada
	var half_size := int(WORLD_SIZE_CHUNKS / 2.0)

	for x in range(-half_size, half_size):
		for z in range(-half_size, half_size):
			var chunk_pos = Vector3i(x, 0, z)
			_create_chunk(chunk_pos)

	# Marcar todos los chunks para actualizar mesh
	for chunk in chunks.values():
		chunks_to_update.append(chunk)

	var elapsed = Time.get_ticks_msec() - start_time
	print("✅ Mundo generado en ", elapsed, " ms (", chunks.size(), " chunks)")


## Coloca un bloque en una posición global
func place_block(block_pos: Vector3i, block_type: Enums.BlockType) -> bool:
	# Verificar límites
	if not Utils.is_valid_block_position(block_pos):
		return false

	# Obtener chunk y posición local
	var chunk_pos = Utils.get_chunk_from_block(block_pos)
	var local_pos = Utils.block_to_local_chunk_position(block_pos)

	# Obtener chunk (o crearlo si no existe)
	var chunk = _get_or_create_chunk(chunk_pos)

	# Verificar que no haya ya un bloque ahí
	if chunk.get_block(local_pos) != Enums.BlockType.NONE:
		return false

	# Colocar bloque
	chunk.set_block(local_pos, block_type)

	# Marcar para actualizar mesh
	if not chunks_to_update.has(chunk):
		chunks_to_update.append(chunk)

	# Emitir señal
	block_placed.emit(block_pos, block_type)

	return true


## Rompe un bloque en una posición global
func remove_block(block_pos: Vector3i) -> bool:
	# Obtener chunk y posición local
	var chunk_pos = Utils.get_chunk_from_block(block_pos)
	var local_pos = Utils.block_to_local_chunk_position(block_pos)

	# Verificar que el chunk exista
	if not chunks.has(chunk_pos):
		return false

	var chunk = chunks[chunk_pos]

	# Obtener tipo de bloque antes de romperlo
	var block_type = chunk.get_block(local_pos)

	if block_type == Enums.BlockType.NONE:
		return false

	# Remover bloque
	chunk.set_block(local_pos, Enums.BlockType.NONE)

	# Marcar para actualizar mesh
	if not chunks_to_update.has(chunk):
		chunks_to_update.append(chunk)

	# Emitir señal
	block_broken.emit(block_pos, block_type)

	return true


## Obtiene el tipo de bloque en una posición global
func get_block(block_pos: Vector3i) -> Enums.BlockType:
	var chunk_pos = Utils.get_chunk_from_block(block_pos)
	var local_pos = Utils.block_to_local_chunk_position(block_pos)

	if not chunks.has(chunk_pos):
		return Enums.BlockType.NONE

	return chunks[chunk_pos].get_block(local_pos)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PRIVADOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Crea un nuevo chunk y lo llena con terreno
func _create_chunk(chunk_pos: Vector3i) -> Chunk:
	# Crear instancia de Chunk
	var chunk_scene = preload("res://scenes/world/Chunk.tscn")
	var chunk: Chunk = chunk_scene.instantiate() if chunk_scene else Chunk.new()

	# Añadir al árbol PRIMERO
	add_child(chunk)

	# Luego inicializar (ahora está en el árbol)
	chunk.initialize(chunk_pos)

	# Llenar con terreno generado
	if terrain_generator and terrain_generator.has_method("generate_chunk_terrain"):
		terrain_generator.generate_chunk_terrain(chunk)

	# Guardar en diccionario
	chunks[chunk_pos] = chunk

	return chunk


## Obtiene un chunk o lo crea si no existe
func _get_or_create_chunk(chunk_pos: Vector3i) -> Chunk:
	if chunks.has(chunk_pos):
		return chunks[chunk_pos]
	else:
		return _create_chunk(chunk_pos)


## Actualiza meshes de chunks pendientes (gradualmente)
func _update_pending_chunks() -> void:
	var updated_count = 0

	while chunks_to_update.size() > 0 and updated_count < MAX_CHUNKS_PER_FRAME:
		var chunk = chunks_to_update.pop_front()
		chunk.generate_mesh()
		updated_count += 1

	# Debug: mostrar progreso
	if chunks_to_update.size() > 0:
		pass  # Opcional: actualizar UI de carga


## Limpia todos los chunks
func clear_world() -> void:
	for chunk in chunks.values():
		chunk.queue_free()

	chunks.clear()
	chunks_to_update.clear()

	print("🗑️ Mundo limpiado")


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SERIALIZACIÓN (PARA GUARDADO)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Convierte el mundo a Dictionary (para guardar)
func to_dict() -> Dictionary:
	var world_data = {
		"chunks": {}
	}

	# Guardar solo chunks modificados (que tengan bloques no predeterminados)
	for chunk_pos in chunks.keys():
		var chunk = chunks[chunk_pos]
		var chunk_key = "%d,%d" % [chunk_pos.x, chunk_pos.z]
		world_data.chunks[chunk_key] = _serialize_chunk(chunk)

	return world_data


## Carga el mundo desde Dictionary
func from_dict(world_data: Dictionary) -> void:
	clear_world()

	if not world_data.has("chunks"):
		return

	# Cargar chunks guardados
	for chunk_key in world_data.chunks.keys():
		var chunk_data = world_data.chunks[chunk_key]
		_deserialize_chunk(chunk_key, chunk_data)


## Serializa un chunk individual
func _serialize_chunk(chunk: Chunk) -> Dictionary:
	var chunk_data = {
		"blocks": []
	}

	# Solo guardar bloques no-aire (compresión)
	for x in range(Constants.CHUNK_SIZE):
		for y in range(Constants.MAX_WORLD_HEIGHT):
			for z in range(Constants.CHUNK_SIZE):
				var block_type = chunk.get_block(Vector3i(x, y, z))
				if block_type != Enums.BlockType.NONE:
					chunk_data.blocks.append({
						"x": x, "y": y, "z": z,
						"type": block_type
					})

	return chunk_data


## Deserializa un chunk individual
func _deserialize_chunk(chunk_key: String, chunk_data: Dictionary) -> void:
	# Parsear posición del chunk desde key "x,z"
	var parts = chunk_key.split(",")
	var chunk_pos = Vector3i(int(parts[0]), 0, int(parts[1]))

	# Crear chunk
	var chunk = _create_chunk(chunk_pos)

	# Cargar bloques
	for block_info in chunk_data.blocks:
		var local_pos = Vector3i(block_info.x, block_info.y, block_info.z)
		chunk.set_block(local_pos, block_info.type)

	# Marcar para actualizar mesh
	chunks_to_update.append(chunk)
