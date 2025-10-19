# ============================================================================
# Main.gd - Escena Principal de Inicialización
# ============================================================================
# Nodo raíz que inicializa el juego y carga el menú principal
# ============================================================================

extends Node

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	print("============================================================")
	print("Multi Ninja Espacial - Iniciando...")
	print("============================================================")

	# Configurar proyecto
	_setup_project()

	# Ir al menú principal
	GameManager.go_to_main_menu()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PRIVADOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Configura opciones globales del proyecto
func _setup_project() -> void:
	# Configurar ventana
	_setup_window()

	# Configurar audio buses
	_setup_audio_buses()

	print("Proyecto configurado")


## Configura la ventana del juego
func _setup_window() -> void:
	# Título de la ventana
	DisplayServer.window_set_title("Multi Ninja Espacial")

	# Modo de ventana (centrada)
	if not OS.has_feature("web"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

		# Tamaño de ventana (1280x720)
		var window_size = Vector2i(1280, 720)
		DisplayServer.window_set_size(window_size)

		# Centrar ventana
		var screen_size = DisplayServer.screen_get_size()
		var window_pos = (screen_size - window_size) / 2
		DisplayServer.window_set_position(window_pos)


## Configura los buses de audio
func _setup_audio_buses() -> void:
	# Crear bus "Music" si no existe
	var music_bus_index = AudioServer.get_bus_index("Music")
	if music_bus_index == -1:
		AudioServer.add_bus()
		var new_bus_index = AudioServer.bus_count - 1
		AudioServer.set_bus_name(new_bus_index, "Music")
		AudioServer.set_bus_send(new_bus_index, "Master")

	# Crear bus "SFX" si no existe
	var sfx_bus_index = AudioServer.get_bus_index("SFX")
	if sfx_bus_index == -1:
		AudioServer.add_bus()
		var new_bus_index = AudioServer.bus_count - 1
		AudioServer.set_bus_name(new_bus_index, "SFX")
		AudioServer.set_bus_send(new_bus_index, "Master")

	print("Buses de audio configurados")
