# ============================================================================
# PauseMenu.gd - Menú de Pausa
# ============================================================================
# Control que se muestra cuando el juego está pausado
# ============================================================================

extends Control

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# NODOS UI
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var save_button: Button = $Panel/VBoxContainer/SaveButton
@onready var options_button: Button = $Panel/VBoxContainer/OptionsButton
@onready var main_menu_button: Button = $Panel/VBoxContainer/MainMenuButton

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	# Configurar process mode (funciona incluso cuando el juego está pausado)
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Conectar botones
	resume_button.pressed.connect(_on_resume_pressed)
	save_button.pressed.connect(_on_save_pressed)
	options_button.pressed.connect(_on_options_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

	# Conectar señales de GameManager
	GameManager.game_paused.connect(_on_game_paused)
	GameManager.game_resumed.connect(_on_game_resumed)

	# Ocultar inicialmente
	hide()

	print("⏸️ PauseMenu inicializado")


func _input(event: InputEvent) -> void:
	# Cerrar menú con ESC
	if visible and event.is_action_pressed("ui_cancel"):
		_on_resume_pressed()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SEÑALES DE BOTONES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _on_resume_pressed() -> void:
	AudioManager.play_sfx(Enums.SoundType.MENU_CLOSE)
	GameManager.resume_game()


func _on_save_pressed() -> void:
	AudioManager.play_sfx(Enums.SoundType.BUTTON_CLICK)
	print("💾 Guardando partida...")

	if SaveSystem.save_game():
		# TODO: Mostrar notificación "Partida guardada"
		print("✅ Partida guardada exitosamente")
	else:
		# TODO: Mostrar error
		print("❌ Error al guardar partida")


func _on_options_pressed() -> void:
	AudioManager.play_sfx(Enums.SoundType.BUTTON_CLICK)
	print("⚙️ Abriendo opciones")

	# TODO: Abrir panel de opciones
	pass


func _on_main_menu_pressed() -> void:
	AudioManager.play_sfx(Enums.SoundType.BUTTON_CLICK)
	print("🏠 Volviendo al menú principal")

	# Guardar antes de salir
	SaveSystem.save_game()

	# Reanudar para permitir cambio de escena
	GameManager.resume_game()

	# Volver al menú
	GameManager.go_to_main_menu()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SEÑALES DE GAMEMANAGER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _on_game_paused() -> void:
	show()
	AudioManager.play_sfx(Enums.SoundType.MENU_OPEN)


func _on_game_resumed() -> void:
	hide()
