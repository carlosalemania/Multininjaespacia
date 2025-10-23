# ============================================================================
# DialogueUI.gd - UI de Diálogos con NPCs
# ============================================================================
# Muestra diálogos, nombre del NPC y opciones de misiones
# ============================================================================

extends Control
class_name DialogueUI

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# NODOS (creados dinámicamente)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var background: ColorRect
var dialogue_panel: PanelContainer
var vbox: VBoxContainer
var npc_name_label: Label
var dialogue_text_label: Label
var button_container: HBoxContainer
var continue_button: Button
var quest_list: VBoxContainer

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## NPC actual con el que se está hablando
var current_npc: NPC = null

## Índice del diálogo actual
var dialogue_index: int = 0

## Lista de diálogos del NPC
var dialogues: Array[String] = []

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	# Crear UI dinámicamente
	_create_ui()

	# Ocultar inicialmente
	visible = false

	visibility_changed.connect(_on_visibility_changed)

	print("💬 DialogueUI inicializado")


func _input(event: InputEvent) -> void:
	if not visible:
		return

	# Continuar con SPACE o E
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		_show_next_dialogue()
		get_viewport().set_input_as_handled()

	# Cerrar con ESC
	if event.is_action_pressed("ui_cancel"):
		close_dialogue()
		get_viewport().set_input_as_handled()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PÚBLICOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Muestra diálogo con un NPC
func show_dialogue(npc: NPC) -> void:
	current_npc = npc
	dialogue_index = 0

	# Obtener saludo + 2 diálogos aleatorios
	dialogues = [
		npc.get_greeting(),
		npc.get_dialogue(),
		npc.get_dialogue()
	]

	# Mostrar primer diálogo
	_display_dialogue()

	# Mostrar misiones disponibles
	_display_quests()

	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	AudioManager.play_sfx(Enums.SoundType.UI_CLICK)


## Cierra el diálogo
func close_dialogue() -> void:
	current_npc = null
	dialogues.clear()
	dialogue_index = 0
	visible = false

	if not GameManager.is_paused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	AudioManager.play_sfx(Enums.SoundType.UI_CLICK)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PRIVADOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Crea la UI dinámicamente
func _create_ui() -> void:
	# Fondo semi-transparente
	background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.5)
	background.anchors_preset = Control.PRESET_FULL_RECT
	add_child(background)

	# Panel de diálogo (parte inferior)
	dialogue_panel = PanelContainer.new()
	dialogue_panel.custom_minimum_size = Vector2(800, 250)
	dialogue_panel.anchors_preset = Control.PRESET_CENTER_BOTTOM
	dialogue_panel.offset_left = -400
	dialogue_panel.offset_right = 400
	dialogue_panel.offset_top = -270
	dialogue_panel.offset_bottom = -20
	add_child(dialogue_panel)

	# Estilo del panel
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.1, 0.1, 0.15, 0.95)
	style_box.border_width_left = 3
	style_box.border_width_top = 3
	style_box.border_width_right = 3
	style_box.border_width_bottom = 3
	style_box.border_color = Color(0.3, 0.5, 0.7)
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_top_right = 10
	style_box.corner_radius_bottom_left = 10
	style_box.corner_radius_bottom_right = 10

	var theme_override = Theme.new()
	theme_override.set_stylebox("panel", "PanelContainer", style_box)
	dialogue_panel.theme = theme_override

	# VBox principal
	vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	dialogue_panel.add_child(vbox)

	# Nombre del NPC
	npc_name_label = Label.new()
	npc_name_label.add_theme_font_size_override("font_size", 20)
	npc_name_label.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	vbox.add_child(npc_name_label)

	# Texto del diálogo
	dialogue_text_label = Label.new()
	dialogue_text_label.add_theme_font_size_override("font_size", 16)
	dialogue_text_label.add_theme_color_override("font_color", Color.WHITE)
	dialogue_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(dialogue_text_label)

	# Lista de misiones
	quest_list = VBoxContainer.new()
	quest_list.add_theme_constant_override("separation", 6)
	vbox.add_child(quest_list)

	# Separador
	var separator = HSeparator.new()
	vbox.add_child(separator)

	# Botones
	button_container = HBoxContainer.new()
	button_container.alignment = BoxContainer.ALIGNMENT_END
	button_container.add_theme_constant_override("separation", 10)
	vbox.add_child(button_container)

	# Botón continuar
	continue_button = Button.new()
	continue_button.text = "Continuar (E / Space)"
	continue_button.custom_minimum_size = Vector2(200, 40)
	continue_button.pressed.connect(_show_next_dialogue)
	button_container.add_child(continue_button)

	# Botón cerrar
	var close_button = Button.new()
	close_button.text = "Cerrar (ESC)"
	close_button.custom_minimum_size = Vector2(150, 40)
	close_button.pressed.connect(close_dialogue)
	button_container.add_child(close_button)


## Muestra el diálogo actual
func _display_dialogue() -> void:
	if current_npc == null or dialogue_index >= dialogues.size():
		return

	npc_name_label.text = current_npc.npc_name
	dialogue_text_label.text = dialogues[dialogue_index]


## Muestra el siguiente diálogo
func _show_next_dialogue() -> void:
	dialogue_index += 1

	if dialogue_index < dialogues.size():
		_display_dialogue()
	else:
		# No hay más diálogos, cerrar
		close_dialogue()


## Muestra las misiones disponibles
func _display_quests() -> void:
	# Limpiar lista
	for child in quest_list.get_children():
		child.queue_free()

	if current_npc == null:
		return

	var quests = current_npc.get_quests()

	for quest_id in quests:
		# Skip si ya está completada
		if QuestSystem.is_quest_completed(quest_id):
			continue

		var quest_data = NPCData.get_quest_data(quest_id)
		if quest_data.is_empty():
			continue

		# Crear botón de misión
		var quest_button = Button.new()
		quest_button.custom_minimum_size = Vector2(0, 35)

		var is_active = QuestSystem.is_quest_active(quest_id)

		if is_active:
			# Mostrar progreso
			var current = QuestSystem.get_quest_current_value(quest_id)
			var target = quest_data.get("target", 1)
			var progress_percent = (float(current) / float(target)) * 100.0
			quest_button.text = "📋 %s (%d / %d - %.0f%%)" % [
				quest_data.get("title", "???"),
				current,
				target,
				progress_percent
			]
			quest_button.disabled = true
			quest_button.modulate = Color(0.7, 0.7, 0.7)
		else:
			# Disponible para aceptar
			quest_button.text = "⭐ %s - Aceptar" % quest_data.get("title", "???")
			quest_button.pressed.connect(_on_quest_accepted.bind(quest_id))

		quest_list.add_child(quest_button)


## Callback cuando se acepta una misión
func _on_quest_accepted(quest_id: String) -> void:
	if QuestSystem.accept_quest(quest_id):
		_display_quests()  # Refrescar lista
		AudioManager.play_sfx(Enums.SoundType.ACHIEVEMENT)


## Callback cuando cambia visibilidad
func _on_visibility_changed() -> void:
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		if not GameManager.is_paused:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
