# ============================================================================
# MainMenu.gd - Menú Principal
# ============================================================================
# Control que muestra el menú principal del juego
# ============================================================================

extends Control

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# NODOS UI
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var new_game_button: Button = $VBoxContainer/NewGameButton
@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var options_button: Button = $VBoxContainer/OptionsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	# Conectar botones
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Verificar si hay partida guardada
	continue_button.disabled = not SaveSystem.has_save_data

	# Reproducir música del menú
	AudioManager.play_menu_music()

	# Mostrar cursor
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	print("🎮 MainMenu inicializado")


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SEÑALES DE BOTONES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _on_new_game_pressed() -> void:
	AudioManager.play_sfx(Enums.SoundType.BUTTON_CLICK)
	print("🎮 Nueva partida iniciada")

	# Si hay partida guardada, preguntar confirmación (opcional)
	if SaveSystem.has_save_data:
		# TODO: Mostrar diálogo de confirmación
		pass

	# Iniciar nueva partida
	GameManager.start_new_game()


func _on_continue_pressed() -> void:
	AudioManager.play_sfx(Enums.SoundType.BUTTON_CLICK)
	print("📂 Continuando partida guardada")

	# Cargar partida
	GameManager.load_game()


func _on_options_pressed() -> void:
	AudioManager.play_sfx(Enums.SoundType.BUTTON_CLICK)
	print("⚙️ Abriendo opciones")

	# TODO: Ir a menú de opciones
	# GameManager.change_scene(GameManager.SCENE_OPTIONS)


func _on_quit_pressed() -> void:
	AudioManager.play_sfx(Enums.SoundType.BUTTON_CLICK)
	print("👋 Saliendo del juego")

	GameManager.quit_game()
