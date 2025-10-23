# ============================================================================
# StructureGenerator.gd - Generador de Estructuras Especiales
# ============================================================================
# Genera casas, templos, torres y otras estructuras en el mundo
# ============================================================================

extends Node
# NOTA: No usar class_name porque está registrado como autoload en project.godot
# Acceder via: StructureGenerator.generate(...) desde cualquier script

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TIPOS DE ESTRUCTURAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum StructureType {
	CASA,      ## Casa simple (4x4x3)
	TEMPLO,    ## Templo de luz (6x6x5)
	TORRE,     ## Torre alta (3x3x15)
	ALTAR      ## Altar pequeño (2x2x2)
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PÚBLICOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Genera una estructura en una posición específica
static func generate_structure(chunk: Chunk, structure_type: StructureType, base_pos: Vector3i) -> void:
	match structure_type:
		StructureType.CASA:
			_generate_casa(chunk, base_pos)
		StructureType.TEMPLO:
			_generate_templo(chunk, base_pos)
		StructureType.TORRE:
			_generate_torre(chunk, base_pos)
		StructureType.ALTAR:
			_generate_altar(chunk, base_pos)


## Intenta generar estructuras aleatorias en un chunk
static func try_generate_random_structures(chunk: Chunk, world_pos: Vector3i) -> void:
	# Solo generar estructuras ocasionalmente (10% de probabilidad)
	if randf() > 0.1:
		return

	# Buscar una posición válida en el chunk
	var chunk_size = Constants.CHUNK_SIZE
	var test_x = randi() % chunk_size
	var test_z = randi() % chunk_size

	# Buscar superficie desde arriba
	for y in range(Constants.MAX_WORLD_HEIGHT - 1, 0, -1):
		var local_pos = Vector3i(test_x, y, test_z)
		var block = chunk.get_block(local_pos)

		if block == Enums.BlockType.TIERRA or block == Enums.BlockType.PIEDRA:
			# Encontró superficie, generar estructura aleatoria
			var structure_types = [
				StructureType.CASA,
				StructureType.ALTAR,
				StructureType.TORRE
			]

			# Templo solo si está en zona central
			if abs(world_pos.x) < 2 and abs(world_pos.z) < 2:
				structure_types.append(StructureType.TEMPLO)

			var random_structure = structure_types[randi() % structure_types.size()]
			generate_structure(chunk, random_structure, Vector3i(test_x, y + 1, test_z))
			print("🏛️ Estructura generada: ", StructureType.keys()[random_structure], " en chunk ", world_pos)
			break


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# GENERADORES DE ESTRUCTURAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Genera una casa simple (4x4x3 bloques)
static func _generate_casa(chunk: Chunk, base_pos: Vector3i) -> void:
	var width = 4
	var depth = 4
	var height = 3

	# Piso
	for x in range(width):
		for z in range(depth):
			chunk.set_block(base_pos + Vector3i(x, 0, z), Enums.BlockType.MADERA)

	# Paredes
	for y in range(1, height):
		for x in range(width):
			for z in range(depth):
				# Solo bordes (no llenar el interior)
				if x == 0 or x == width - 1 or z == 0 or z == depth - 1:
					# Dejar puerta en un lado
					if not (x == 1 and z == 0 and y == 1):
						chunk.set_block(base_pos + Vector3i(x, y, z), Enums.BlockType.MADERA)

	# Techo
	for x in range(width):
		for z in range(depth):
			chunk.set_block(base_pos + Vector3i(x, height, z), Enums.BlockType.MADERA)


## Genera un templo de luz (6x6x5 bloques)
static func _generate_templo(chunk: Chunk, base_pos: Vector3i) -> void:
	var width = 6
	var depth = 6
	var height = 5

	# Plataforma base elevada
	for x in range(-1, width + 1):
		for z in range(-1, depth + 1):
			chunk.set_block(base_pos + Vector3i(x, -1, z), Enums.BlockType.PIEDRA)

	# Piso del templo
	for x in range(width):
		for z in range(depth):
			chunk.set_block(base_pos + Vector3i(x, 0, z), Enums.BlockType.ORO)

	# Columnas en las esquinas
	for y in range(1, height):
		chunk.set_block(base_pos + Vector3i(0, y, 0), Enums.BlockType.PIEDRA)
		chunk.set_block(base_pos + Vector3i(width - 1, y, 0), Enums.BlockType.PIEDRA)
		chunk.set_block(base_pos + Vector3i(0, y, depth - 1), Enums.BlockType.PIEDRA)
		chunk.set_block(base_pos + Vector3i(width - 1, y, depth - 1), Enums.BlockType.PIEDRA)

	# Altar central
	var center = Vector3i(width // 2, 1, depth // 2)  # División entera explícita
	chunk.set_block(base_pos + center, Enums.BlockType.ORO)
	chunk.set_block(base_pos + center + Vector3i(0, 1, 0), Enums.BlockType.CRISTAL)

	# Techo
	for x in range(width):
		for z in range(depth):
			chunk.set_block(base_pos + Vector3i(x, height, z), Enums.BlockType.ORO)


## Genera una torre alta (3x3x15 bloques)
static func _generate_torre(chunk: Chunk, base_pos: Vector3i) -> void:
	var width = 3
	var depth = 3
	var height = 15

	# Base reforzada
	for x in range(width):
		for z in range(depth):
			chunk.set_block(base_pos + Vector3i(x, 0, z), Enums.BlockType.PIEDRA)

	# Torre hueca
	for y in range(1, height):
		for x in range(width):
			for z in range(depth):
				# Solo bordes
				if x == 0 or x == width - 1 or z == 0 or z == depth - 1:
					chunk.set_block(base_pos + Vector3i(x, y, z), Enums.BlockType.PIEDRA)

	# Plataforma superior
	for x in range(width):
		for z in range(depth):
			chunk.set_block(base_pos + Vector3i(x, height, z), Enums.BlockType.ORO)

	# Antorcha en la cima
	chunk.set_block(base_pos + Vector3i(1, height + 1, 1), Enums.BlockType.CRISTAL)


## Genera un altar pequeño (2x2x2 bloques)
static func _generate_altar(chunk: Chunk, base_pos: Vector3i) -> void:
	# Base
	chunk.set_block(base_pos + Vector3i(0, 0, 0), Enums.BlockType.PIEDRA)
	chunk.set_block(base_pos + Vector3i(1, 0, 0), Enums.BlockType.PIEDRA)
	chunk.set_block(base_pos + Vector3i(0, 0, 1), Enums.BlockType.PIEDRA)
	chunk.set_block(base_pos + Vector3i(1, 0, 1), Enums.BlockType.PIEDRA)

	# Cristal central
	chunk.set_block(base_pos + Vector3i(0, 1, 0), Enums.BlockType.CRISTAL)
