# ============================================================================
# Utils.gd - Funciones de Utilidad
# ============================================================================
# Funciones auxiliares para conversiones, matemáticas y helpers
# ============================================================================

extends Node
class_name Utils

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONVERSIONES DE COORDENADAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Convierte posición del mundo a coordenadas de bloque
static func world_to_block_position(world_pos: Vector3) -> Vector3i:
	return Vector3i(
		floori(world_pos.x),
		floori(world_pos.y),
		floori(world_pos.z)
	)


## Convierte coordenadas de bloque a posición del mundo (centro del bloque)
static func block_to_world_position(block_pos: Vector3i) -> Vector3:
	return Vector3(
		float(block_pos.x) + 0.5,
		float(block_pos.y) + 0.5,
		float(block_pos.z) + 0.5
	) * Constants.BLOCK_SIZE


## Convierte posición del mundo a coordenadas de chunk
static func world_to_chunk_position(world_pos: Vector3) -> Vector3i:
	return Vector3i(
		floori(world_pos.x / Constants.CHUNK_SIZE),
		0,  # Los chunks solo están en Y=0
		floori(world_pos.z / Constants.CHUNK_SIZE)
	)


## Convierte coordenadas de chunk a posición del mundo (origen del chunk)
static func chunk_to_world_position(chunk_pos: Vector3i) -> Vector3:
	return Vector3(
		float(chunk_pos.x * Constants.CHUNK_SIZE),
		0.0,
		float(chunk_pos.z * Constants.CHUNK_SIZE)
	)


## Convierte coordenadas de bloque global a coordenadas locales dentro de un chunk
static func block_to_local_chunk_position(block_pos: Vector3i) -> Vector3i:
	return Vector3i(
		posmod(block_pos.x, Constants.CHUNK_SIZE),
		block_pos.y,
		posmod(block_pos.z, Constants.CHUNK_SIZE)
	)


## Obtiene el chunk al que pertenece un bloque
static func get_chunk_from_block(block_pos: Vector3i) -> Vector3i:
	return Vector3i(
		floori(float(block_pos.x) / float(Constants.CHUNK_SIZE)),
		0,
		floori(float(block_pos.z) / float(Constants.CHUNK_SIZE))
	)


## Convierte coordenadas locales de chunk a posición global de bloque
## @param chunk_pos Posición del chunk en coordenadas de chunk
## @param local_pos Posición local del bloque dentro del chunk [0, CHUNK_SIZE-1]
## @return Posición global del bloque en coordenadas de mundo
static func local_to_global_block_position(chunk_pos: Vector3i, local_pos: Vector3i) -> Vector3i:
	return Vector3i(
		chunk_pos.x * Constants.CHUNK_SIZE + local_pos.x,
		local_pos.y,
		chunk_pos.z * Constants.CHUNK_SIZE + local_pos.z
	)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RAYCAST HELPERS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Realiza un raycast para detectar bloques
## Retorna: { "hit": bool, "block_pos": Vector3i, "normal": Vector3, "distance": float }
static func raycast_block(from: Vector3, direction: Vector3, max_distance: float, world: Node) -> Dictionary:
	var result = {
		"hit": false,
		"block_pos": Vector3i.ZERO,
		"normal": Vector3.ZERO,
		"distance": 0.0
	}

	# Crear PhysicsRayQueryParameters3D
	var space_state = world.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, from + direction * max_distance)
	query.collide_with_areas = false
	query.collide_with_bodies = true

	# Realizar raycast
	var collision = space_state.intersect_ray(query)

	if collision.is_empty():
		return result

	# Extraer información
	result.hit = true
	result.distance = from.distance_to(collision.position)
	result.normal = collision.normal

	# Calcular posición del bloque (retroceder un poco desde el punto de impacto)
	var hit_point = collision.position - collision.normal * 0.01
	result.block_pos = world_to_block_position(hit_point)

	return result


## Obtiene la posición del bloque adyacente en la dirección de la normal
static func get_adjacent_block_position(block_pos: Vector3i, normal: Vector3) -> Vector3i:
	var offset = Vector3i(
		roundi(normal.x),
		roundi(normal.y),
		roundi(normal.z)
	)
	return block_pos + offset


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VALIDACIONES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Verifica si una posición de bloque está dentro de los límites del mundo
static func is_valid_block_position(block_pos: Vector3i) -> bool:
	return (
		block_pos.y >= 0 and
		block_pos.y < Constants.MAX_WORLD_HEIGHT
	)


## Verifica si una posición local está dentro de un chunk
static func is_valid_local_position(local_pos: Vector3i) -> bool:
	return (
		local_pos.x >= 0 and local_pos.x < Constants.CHUNK_SIZE and
		local_pos.y >= 0 and local_pos.y < Constants.MAX_WORLD_HEIGHT and
		local_pos.z >= 0 and local_pos.z < Constants.CHUNK_SIZE
	)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MATEMÁTICAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Módulo positivo (siempre retorna valores positivos)
static func posmod(a: int, b: int) -> int:
	var result = a % b
	if result < 0:
		result += b
	return result


## Interpola suavemente entre dos valores (smoothstep)
static func smooth_lerp(from: float, to: float, weight: float) -> float:
	var t = clamp(weight, 0.0, 1.0)
	t = t * t * (3.0 - 2.0 * t)
	return lerp(from, to, t)


## Clampea un Vector3i dentro de límites
static func clamp_vector3i(vec: Vector3i, min_val: Vector3i, max_val: Vector3i) -> Vector3i:
	return Vector3i(
		clampi(vec.x, min_val.x, max_val.x),
		clampi(vec.y, min_val.y, max_val.y),
		clampi(vec.z, min_val.z, max_val.z)
	)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# GENERACIÓN PROCEDURAL
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Genera ruido Perlin 2D (usando FastNoiseLite)
static func get_perlin_noise(x: float, z: float, noise: FastNoiseLite) -> float:
	return noise.get_noise_2d(x, z)


## Obtiene la altura del terreno en una posición XZ
static func get_terrain_height(x: int, z: int, noise: FastNoiseLite) -> int:
	var noise_value = get_perlin_noise(float(x), float(z), noise)

	# Normalizar de [-1, 1] a [0, 1]
	var normalized = (noise_value + 1.0) / 2.0

	# Mapear a rango de altura (ej: 5 a 15 bloques)
	var min_height = 5
	var max_height = 15
	var height = int(lerp(float(min_height), float(max_height), normalized))

	return clampi(height, 0, Constants.MAX_WORLD_HEIGHT - 1)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STRING FORMATTING
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Formatea un número grande con separadores (ej: 1000 → "1,000")
static func format_number(value: int) -> String:
	var str_value = str(value)
	var result = ""
	var count = 0

	for i in range(str_value.length() - 1, -1, -1):
		if count == 3:
			result = "," + result
			count = 0
		result = str_value[i] + result
		count += 1

	return result


## Formatea tiempo en segundos a formato MM:SS
static func format_time(seconds: float) -> String:
	var minutes = int(int(seconds) / 60)
	var secs = int(seconds) % 60
	return "%02d:%02d" % [minutes, secs]


## Formatea Vector3i como string legible
static func vector3i_to_string(vec: Vector3i) -> String:
	return "(%d, %d, %d)" % [vec.x, vec.y, vec.z]


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# COLORES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Colores predefinidos para bloques (para mesh generation)
static func get_block_color(block_type: Enums.BlockType) -> Color:
	match block_type:
		Enums.BlockType.TIERRA:
			return Color(0.45, 0.28, 0.18)  # Tierra rica y oscura
		Enums.BlockType.PIEDRA:
			return Color(0.42, 0.44, 0.46)  # Gris piedra con tono azul
		Enums.BlockType.MADERA:
			return Color(0.52, 0.37, 0.26)  # Madera cálida roble
		Enums.BlockType.CRISTAL:
			return Color(0.3, 0.8, 1.0, 0.5)  # Cristal aqua brillante
		Enums.BlockType.METAL:
			return Color(0.65, 0.67, 0.69)  # Metal bruñido
		Enums.BlockType.ORO:
			return Color(1.0, 0.76, 0.03)  # Oro brillante intenso
		Enums.BlockType.PLATA:
			return Color(0.85, 0.87, 0.91)  # Plata lunar
		Enums.BlockType.ARENA:
			return Color(0.93, 0.84, 0.62)  # Arena dorada playa
		Enums.BlockType.NIEVE:
			return Color(0.98, 0.98, 1.0)  # Nieve pura cristalina
		Enums.BlockType.HIELO:
			return Color(0.6, 0.85, 0.95, 0.6)  # Hielo glacial transparente
		Enums.BlockType.CESPED:
			return Color(0.35, 0.75, 0.25)  # Verde césped vibrante
		Enums.BlockType.HOJAS:
			return Color(0.2, 0.55, 0.15, 0.9)  # Verde hojas bosque
		_:
			return Color.WHITE


## Interpola entre dos colores
static func lerp_color(from: Color, to: Color, weight: float) -> Color:
	return from.lerp(to, clamp(weight, 0.0, 1.0))


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ALEATORIOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Genera un entero aleatorio en un rango (inclusivo)
static func random_int_range(min_val: int, max_val: int) -> int:
	return randi() % (max_val - min_val + 1) + min_val


## Retorna true con una probabilidad dada (0.0 - 1.0)
static func random_chance(probability: float) -> bool:
	return randf() < probability


## Selecciona un elemento aleatorio de un array
static func random_element(array: Array) -> Variant:
	if array.is_empty():
		return null
	return array[randi() % array.size()]


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEBUG
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Imprime un mensaje de debug con formato
static func debug_log(message: String, category: String = "DEBUG") -> void:
	print("[", category, "] ", message)


## Imprime un Vector3i con etiqueta
static func debug_vector3i(vec: Vector3i, label: String = "") -> void:
	if label.is_empty():
		print(vector3i_to_string(vec))
	else:
		print(label, ": ", vector3i_to_string(vec))


## Mide el tiempo de ejecución de una función
static func measure_time(callable: Callable, label: String = "Execution") -> Variant:
	var start_time = Time.get_ticks_usec()
	var result = callable.call()
	var end_time = Time.get_ticks_usec()
	var elapsed_ms = (end_time - start_time) / 1000.0

	print("⏱️ ", label, " tomó: ", elapsed_ms, " ms")

	return result
