# ============================================================================
# GameManager.gd - Gestor Global del Juego
# ============================================================================
# Singleton que gestiona el estado global, cambio de escenas y eventos
# ============================================================================

extends Node

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SEÑALES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Emitida cuando cambia el estado del juego
signal game_state_changed(new_state: Enums.GameState)

## Emitida cuando se pausa el juego
signal game_paused

## Emitida cuando se reanuda el juego
signal game_resumed

## Emitida cuando se cambia de escena
signal scene_changed(scene_path: String)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Estado actual del juego
var current_state: Enums.GameState = Enums.GameState.MENU

## Referencia a la escena del mundo actual (si está cargada)
var current_world: Node = null

## Referencia al jugador actual (si existe)
var player: CharacterBody3D = null

## Tiempo de juego actual (en segundos)
var play_time: float = 0.0

## ¿Está el juego pausado?
var is_paused: bool = false

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUTAS DE ESCENAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const SCENE_MAIN_MENU: String = "res://scenes/menus/MainMenu.tscn"
const SCENE_GAME_WORLD: String = "res://scenes/game/GameWorld.tscn"
const SCENE_OPTIONS: String = "res://scenes/menus/OptionsMenu.tscn"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	print("🎮 GameManager inicializado")

	# Configurar process mode para que funcione siempre (incluso pausado)
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Configurar FPS objetivo
	Engine.max_fps = Constants.TARGET_FPS


func _process(delta: float) -> void:
	# Actualizar tiempo de juego solo si estamos jugando y no pausado
	if current_state == Enums.GameState.PLAYING and not is_paused:
		play_time += delta


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CAMBIO DE ESCENAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Cambia a una escena específica
func change_scene(scene_path: String) -> void:
	print("📦 Cambiando a escena: ", scene_path)

	# Emitir señal
	scene_changed.emit(scene_path)

	# Cambiar escena (diferido para evitar problemas con _ready)
	get_tree().change_scene_to_file.call_deferred(scene_path)


## Ir al menú principal
func go_to_main_menu() -> void:
	_change_state(Enums.GameState.MENU)
	change_scene(SCENE_MAIN_MENU)


## Iniciar nueva partida
func start_new_game() -> void:
	print("🎮 Iniciando nueva partida...")

	# Resetear datos del jugador
	PlayerData.reset()

	# Cambiar estado
	_change_state(Enums.GameState.LOADING)

	# Cargar mundo
	change_scene(SCENE_GAME_WORLD)


## Cargar partida guardada
func load_game() -> void:
	print("📂 Cargando partida guardada...")

	# Cargar datos del jugador
	if SaveSystem.load_game():
		_change_state(Enums.GameState.LOADING)
		change_scene(SCENE_GAME_WORLD)
	else:
		print("⚠️ No hay partida guardada, iniciando nueva...")
		start_new_game()


## Notificar que el mundo terminó de cargar
func on_world_loaded(world_node: Node) -> void:
	current_world = world_node
	_change_state(Enums.GameState.PLAYING)
	print("✅ Mundo cargado, estado: PLAYING")


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PAUSA
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Pausar el juego
func pause_game() -> void:
	if is_paused:
		return

	is_paused = true
	get_tree().paused = true
	game_paused.emit()
	print("⏸️ Juego pausado")


## Reanudar el juego
func resume_game() -> void:
	if not is_paused:
		return

	is_paused = false
	get_tree().paused = false
	game_resumed.emit()
	print("▶️ Juego reanudado")


## Alternar pausa
func toggle_pause() -> void:
	if is_paused:
		resume_game()
	else:
		pause_game()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SALIR DEL JUEGO
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Salir del juego (web: volver al menú, desktop: cerrar)
func quit_game() -> void:
	# En web, solo podemos volver al menú
	if OS.has_feature("web"):
		print("🌐 Web: Volviendo al menú principal")
		go_to_main_menu()
	else:
		# En desktop, guardar y cerrar
		print("👋 Cerrando juego...")
		SaveSystem.save_game()
		get_tree().quit()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PRIVADOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Cambia el estado del juego y emite señal
func _change_state(new_state: Enums.GameState) -> void:
	if current_state == new_state:
		return

	var old_state = current_state
	current_state = new_state

	print("🔄 Estado: ", _state_to_string(old_state), " → ", _state_to_string(new_state))
	game_state_changed.emit(new_state)


## Convierte estado a string (para debug)
func _state_to_string(state: Enums.GameState) -> String:
	match state:
		Enums.GameState.MENU:
			return "MENU"
		Enums.GameState.LOADING:
			return "LOADING"
		Enums.GameState.PLAYING:
			return "PLAYING"
		Enums.GameState.PAUSED:
			return "PAUSED"
		Enums.GameState.GAME_OVER:
			return "GAME_OVER"
		_:
			return "UNKNOWN"


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# UTILIDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Obtiene el tiempo de juego formateado (HH:MM:SS)
func get_play_time_formatted() -> String:
	var hours = int(play_time) / 3600.0
	var minutes = (int(play_time) % 3600) / 60.0
	var seconds = int(play_time) % 60

	return "%02d:%02d:%02d" % [hours, minutes, seconds]


## Resetea el tiempo de juego
func reset_play_time() -> void:
	play_time = 0.0
