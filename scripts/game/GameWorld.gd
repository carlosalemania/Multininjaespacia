# ============================================================================
# GameWorld.gd - Escena Principal del Mundo de Juego
# ============================================================================
# Node3D raíz que contiene el mundo, jugador y coordina todo
# ============================================================================

extends Node3D

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# COMPONENTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@onready var chunk_manager: ChunkManager = $ChunkManager
@onready var terrain_generator: TerrainGenerator = $TerrainGenerator
@onready var player: CharacterBody3D = $Player
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var directional_light: DirectionalLight3D = $DirectionalLight3D
@onready var day_night_cycle: DayNightCycle = null  # Se crea dinámicamente

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## ¿El mundo está cargado?
var is_loaded: bool = false

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	print("🌍 GameWorld inicializando...")

	# Configurar ciclo día/noche
	_setup_day_night_cycle()

	# Conectar player.world
	if player:
		player.world = self

	# Generar mundo
	_generate_world()

	# Esperar a que los chunks generen sus meshes y colisiones
	# Los chunks se actualizan gradualmente en _process() del ChunkManager
	print("⏳ Esperando generación de chunks...")

	# Esperar hasta que no haya chunks pendientes de actualizar
	var max_wait_time = 5.0  # Máximo 5 segundos
	var wait_time = 0.0
	while chunk_manager.chunks_to_update.size() > 0 and wait_time < max_wait_time:
		await get_tree().process_frame
		wait_time += get_process_delta_time()

	print("✅ Chunks generados (",chunk_manager.chunks.size(), " chunks con colisión)")

	# Posicionar jugador en el spawn
	_spawn_player()

	# Notificar a GameManager que el mundo está listo
	GameManager.on_world_loaded(self)

	# Cambiar música a gameplay
	AudioManager.play_gameplay_music()

	is_loaded = true
	print("✅ GameWorld cargado")


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PÚBLICOS (para Player)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Coloca un bloque en el mundo
func place_block(block_pos: Vector3i, block_type: Enums.BlockType) -> bool:
	if chunk_manager:
		return chunk_manager.place_block(block_pos, block_type)
	return false


## Remueve un bloque del mundo
func remove_block(block_pos: Vector3i) -> bool:
	if chunk_manager:
		return chunk_manager.remove_block(block_pos)
	return false


## Obtiene el tipo de bloque en una posición
func get_block(block_pos: Vector3i) -> Enums.BlockType:
	if chunk_manager:
		return chunk_manager.get_block(block_pos)
	return Enums.BlockType.NONE


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PRIVADOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Genera el mundo usando el ChunkManager
func _generate_world() -> void:
	if not chunk_manager or not terrain_generator:
		push_error("❌ ChunkManager o TerrainGenerator no encontrados")
		return

	# Generar mundo
	chunk_manager.generate_world(terrain_generator)


## Posiciona al jugador en el punto de spawn
func _spawn_player() -> void:
	if not player:
		push_error("❌ Player no encontrado")
		return

	# Obtener posición de spawn desde PlayerData (o usar default)
	var spawn_pos = PlayerData.get_position()

	# Si es posición inicial (0, altura spawn, 0), buscar superficie
	if spawn_pos.y == Constants.PLAYER_SPAWN_HEIGHT:
		spawn_pos = _find_safe_spawn_position(spawn_pos)

	# Posicionar jugador
	player.global_position = spawn_pos

	print("🎮 Jugador spawneado en: ", spawn_pos)


## Encuentra una posición segura de spawn (sobre el terreno)
func _find_safe_spawn_position(default_pos: Vector3) -> Vector3:
	var block_x = int(default_pos.x)
	var block_z = int(default_pos.z)

	# Buscar desde arriba hacia abajo el primer bloque sólido
	for y in range(Constants.MAX_WORLD_HEIGHT - 1, -1, -1):
		var block_type = get_block(Vector3i(block_x, y, block_z))

		if block_type != Enums.BlockType.NONE:
			# Encontró terreno, spawn 2 bloques arriba
			return Vector3(float(block_x) + 0.5, float(y + 2), float(block_z) + 0.5)

	# Si no encontró terreno, usar posición default
	return default_pos


## Configura el ciclo día/noche
func _setup_day_night_cycle() -> void:
	# Remover luz direccional estática si existe
	if directional_light:
		directional_light.queue_free()

	# Remover WorldEnvironment estático si existe
	if world_environment:
		world_environment.queue_free()

	# Crear sistema de día/noche
	day_night_cycle = DayNightCycle.new()
	day_night_cycle.name = "DayNightCycle"
	day_night_cycle.starting_hour = 7.0  # Empezar de día (7:00 AM)
	day_night_cycle.day_duration = 600.0  # 10 minutos por día completo
	day_night_cycle.time_scale = 1.0  # Velocidad normal
	day_night_cycle.cycle_enabled = true
	add_child(day_night_cycle)

	# Conectar señales
	day_night_cycle.time_period_changed.connect(_on_time_period_changed)

	print("🌅 Ciclo día/noche activado")


## Callback cuando cambia el periodo del día
func _on_time_period_changed(new_period: DayNightCycle.TimePeriod) -> void:
	var period_name = day_night_cycle.get_period_name() if day_night_cycle else "???"
	print("⏰ Cambio de periodo: ", period_name)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# GUARDADO/CARGA
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Serializa el estado del mundo (para guardado)
func to_dict() -> Dictionary:
	return {
		"chunk_data": chunk_manager.to_dict() if chunk_manager else {}
	}


## Carga el estado del mundo (desde guardado)
func from_dict(world_data: Dictionary) -> void:
	if world_data.has("chunk_data") and chunk_manager:
		chunk_manager.from_dict(world_data.chunk_data)
