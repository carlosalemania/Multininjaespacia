# ============================================================================
# PlayerInteraction.gd - Interacción con Bloques (Colocar/Romper)
# ============================================================================
# Componente que maneja raycast, colocación y destrucción de bloques
# ============================================================================

extends Node

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SEÑALES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Emitida cuando se apunta a un bloque
signal block_targeted(block_pos: Vector3i, block_type: Enums.BlockType)

## Emitida cuando se deja de apuntar a un bloque
signal block_untargeted

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Referencia al jugador
@onready var player: CharacterBody3D = get_parent()

## Rango de interacción
var interaction_range: float = Constants.INTERACTION_RANGE

## Bloque actualmente apuntado (null si no apunta a ninguno)
var targeted_block: Vector3i = Vector3i.ZERO

## ¿Hay un bloque apuntado?
var is_targeting_block: bool = false

## Normal del bloque apuntado (para colocar bloques adyacentes)
var targeted_normal: Vector3 = Vector3.ZERO

## Timer para romper bloques (mantener click derecho)
var break_timer: float = 0.0

## Dureza del bloque actual (tiempo necesario para romperlo)
var current_block_hardness: float = 0.0

## ¿Está rompiendo un bloque?
var is_breaking: bool = false

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	print("🎯 PlayerInteraction inicializado")


func _process(delta: float) -> void:
	if GameManager.is_paused:
		return

	# Actualizar raycast
	_update_raycast()

	# Manejar inputs de interacción
	_handle_interaction_input(delta)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PRIVADOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Actualiza el raycast para detectar bloques
func _update_raycast() -> void:
	if not player.world:
		return

	# Obtener posición y dirección de la cámara
	var camera_pos = player.get_camera_position()
	var look_dir = player.get_look_direction()

	# Realizar raycast
	var result = Utils.raycast_block(camera_pos, look_dir, interaction_range, player.world)

	# Actualizar estado
	var was_targeting = is_targeting_block

	if result.hit:
		is_targeting_block = true
		targeted_block = result.block_pos
		targeted_normal = result.normal

		# Emitir señal solo si cambió el bloque apuntado
		if not was_targeting or targeted_block != result.block_pos:
			var block_type = _get_block_at(targeted_block)
			block_targeted.emit(targeted_block, block_type)
	else:
		if was_targeting:
			block_untargeted.emit()

		is_targeting_block = false
		targeted_block = Vector3i.ZERO
		targeted_normal = Vector3.ZERO


## Maneja los inputs de interacción (colocar/romper bloques)
func _handle_interaction_input(delta: float) -> void:
	# COLOCAR BLOQUE (Click Izquierdo)
	if Input.is_action_just_pressed("place_block"):
		_try_place_block()

	# ROMPER BLOQUE (Mantener Click Derecho)
	if Input.is_action_pressed("break_block"):
		if is_targeting_block:
			_handle_break_block(delta)
	else:
		# Resetear timer si suelta el click
		if is_breaking:
			is_breaking = false
			break_timer = 0.0


## Intenta colocar un bloque
func _try_place_block() -> void:
	if not is_targeting_block:
		return

	# Obtener bloque activo del inventario
	var active_block = PlayerData.get_active_block()

	if active_block == Enums.BlockType.NONE:
		print("⚠️ No hay bloque seleccionado")
		return

	# Calcular posición donde colocar (adyacente al bloque apuntado)
	var place_pos = Utils.get_adjacent_block_position(targeted_block, targeted_normal)

	# Verificar que no colisione con el jugador
	if _is_position_occupied_by_player(place_pos):
		print("⚠️ No puedes colocar un bloque donde estás parado")
		return

	# Intentar colocar bloque en el mundo
	if _place_block_at(place_pos, active_block):
		# Remover del inventario
		PlayerData.remove_item(active_block, 1)

		# Notificar construcción (para sistema de Luz)
		PlayerData.on_block_placed()

		# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		# INTEGRACIÓN CON SISTEMA DE LOGROS
		# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		# Incrementar estadística de bloques colocados
		# Esto disparará automáticamente los logros relacionados:
		# - "first_block" (1 bloque)
		# - "builder" (100 bloques)
		# - "architect" (500 bloques)
		# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		AchievementSystem.increment_stat("blocks_placed")

		# Reproducir sonido
		AudioManager.play_sfx(Enums.SoundType.BLOCK_PLACE, 0.1)

		print("✅ Bloque colocado: ", Enums.BLOCK_NAMES[active_block], " en ", place_pos)


## Maneja el proceso de romper un bloque (mantener botón)
func _handle_break_block(delta: float) -> void:
	# Obtener tipo de bloque apuntado
	var block_type = _get_block_at(targeted_block)

	if block_type == Enums.BlockType.NONE:
		return

	# Si es un nuevo bloque, resetear timer
	if not is_breaking:
		is_breaking = true
		break_timer = 0.0
		current_block_hardness = Enums.BLOCK_HARDNESS[block_type]

	# Obtener multiplicador de velocidad de herramienta equipada
	var speed_multiplier = PlayerData.get_tool_speed_multiplier()

	# Incrementar timer (más rápido con herramientas)
	break_timer += delta * speed_multiplier

	# Verificar si se completó la rotura
	if break_timer >= current_block_hardness:
		_break_block_at(targeted_block, block_type)
		is_breaking = false
		break_timer = 0.0


## Rompe un bloque en una posición
## Integrado con AchievementSystem para tracking de progreso
func _break_block_at(block_pos: Vector3i, block_type: Enums.BlockType) -> void:
	if not player.world:
		return

	# Llamar al ChunkManager para remover el bloque
	if player.world.has_method("remove_block"):
		player.world.remove_block(block_pos)

		# Añadir bloque al inventario (recolectar)
		PlayerData.add_item(block_type, 1)

		# Añadir recurso correspondiente (si aplica)
		_add_resource_from_block(block_type)

		# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		# INTEGRACIÓN CON SISTEMA DE LOGROS
		# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		# Incrementar estadística de bloques rotos
		# Disparará logros: "miner" (100), "excavator" (500)
		AchievementSystem.increment_stat("blocks_broken")

		# Incrementar distancia recorrida (se actualiza en movimiento)
		# Incrementar altura máxima si aplica
		var current_height = block_pos.y
		if current_height > AchievementSystem.stats.get("max_height", 0):
			AchievementSystem.stats["max_height"] = current_height
			AchievementSystem._check_achievements_for_stat("max_height")
		# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

		# Aplicar habilidad especial de herramienta (si tiene)
		var equipped_tool = PlayerData.get_equipped_tool()
		if equipped_tool != null:
			MagicTool.apply_special_ability(equipped_tool, player.world, block_pos, player)

		# Reproducir sonido
		AudioManager.play_sfx(Enums.SoundType.BLOCK_BREAK, 0.1)

		print("🔨 Bloque roto: ", Enums.BLOCK_NAMES[block_type], " en ", block_pos)


## Coloca un bloque en una posición
func _place_block_at(block_pos: Vector3i, block_type: Enums.BlockType) -> bool:
	if not player.world:
		return false

	# Verificar límites del mundo
	if not Utils.is_valid_block_position(block_pos):
		return false

	# Llamar al ChunkManager para colocar el bloque
	if player.world.has_method("place_block"):
		return player.world.place_block(block_pos, block_type)

	return false


## Obtiene el tipo de bloque en una posición
func _get_block_at(block_pos: Vector3i) -> Enums.BlockType:
	if not player.world:
		return Enums.BlockType.NONE

	if player.world.has_method("get_block"):
		return player.world.get_block(block_pos)

	return Enums.BlockType.NONE


## Verifica si una posición está ocupada por el jugador (AABB check)
func _is_position_occupied_by_player(block_pos: Vector3i) -> bool:
	var block_world_pos = Utils.block_to_world_position(block_pos)

	# AABB del bloque (1x1x1)
	var block_aabb = AABB(
		block_world_pos - Vector3.ONE * 0.5,
		Vector3.ONE
	)

	# AABB del jugador (aproximado: 0.6 ancho x 1.8 alto)
	var player_aabb = AABB(
		player.global_position - Vector3(0.3, 0.0, 0.3),
		Vector3(0.6, 1.8, 0.6)
	)

	# Verificar intersección
	return block_aabb.intersects(player_aabb)


## Añade recursos al inventario según el tipo de bloque roto
## Integrado con AchievementSystem para tracking de recursos específicos
func _add_resource_from_block(block_type: Enums.BlockType) -> void:
	match block_type:
		Enums.BlockType.MADERA:
			PlayerData.add_resource(Enums.ResourceType.MADERA, 1)
			# Logro: "lumberjack" (recolectar 50 madera)
			AchievementSystem.increment_stat("wood_collected")

		Enums.BlockType.PIEDRA:
			PlayerData.add_resource(Enums.ResourceType.PIEDRA, 1)
			# Logro: "geologist" (recolectar 100 piedra)
			AchievementSystem.increment_stat("stone_collected")

		Enums.BlockType.CRISTAL:
			PlayerData.add_resource(Enums.ResourceType.CRISTAL, 1)
			# Logro: "gem_hunter" (recolectar 10 cristales)
			AchievementSystem.increment_stat("crystals_collected")

		Enums.BlockType.ORO:
			# Logro: "treasure_hunter" (encontrar 5 oro)
			AchievementSystem.increment_stat("gold_found")

		Enums.BlockType.METAL:
			AchievementSystem.increment_stat("metal_collected")


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PÚBLICOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Obtiene el porcentaje de rotura del bloque actual (para UI)
func get_break_progress() -> float:
	if not is_breaking:
		return 0.0

	return clamp(break_timer / current_block_hardness, 0.0, 1.0)


## Obtiene información del bloque apuntado (para UI)
func get_targeted_block_info() -> Dictionary:
	if not is_targeting_block:
		return {"valid": false}

	var block_type = _get_block_at(targeted_block)

	return {
		"valid": true,
		"position": targeted_block,
		"type": block_type,
		"name": Enums.BLOCK_NAMES.get(block_type, "Desconocido"),
		"hardness": Enums.BLOCK_HARDNESS.get(block_type, 1.0)
	}
