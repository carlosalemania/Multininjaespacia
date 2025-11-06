# ============================================================================
# GameHUD.gd - HUD del Juego (Interfaz en pantalla)
# ============================================================================
# Control que muestra crosshair, barra de Luz, inventario y debug info
# ============================================================================

extends Control

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# NODOS UI
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Crosshair (centro de la pantalla)
@onready var crosshair: Control = $Crosshair

## Barra de Luz Interior (arriba a la izquierda)
@onready var luz_bar: ProgressBar = $TopLeft/VBoxContainer/LuzBar
@onready var luz_label: Label = $TopLeft/VBoxContainer/LuzBar/LuzLabel

## Barras de supervivencia (se crean dinámicamente)
var hunger_bar: ProgressBar
var thirst_bar: ProgressBar
var temperature_label: Label

## Quest tracker (se crea dinámicamente)
var quest_tracker_panel: PanelContainer

## Hotbar de inventario (abajo centro)
@onready var hotbar: HBoxContainer = $Bottom/Hotbar

## Información de debug (arriba derecha)
@onready var debug_panel: VBoxContainer = $TopRight/DebugPanel

## Información del bloque apuntado (centro arriba)
@onready var block_info_label: Label = $TopCenter/BlockInfoLabel

## Progreso de rotura de bloque
@onready var break_progress: ProgressBar = $Center/BreakProgress

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## ¿Mostrar información de debug?
var show_debug: bool = false

## Slots del hotbar (9 paneles)
var hotbar_slots: Array[Panel] = []

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	# Inicializar hotbar
	_setup_hotbar()

	# Configurar barras de supervivencia
	_setup_survival_bars()

	# Configurar quest tracker
	_setup_quest_tracker()

	# Conectar señales de PlayerData
	PlayerData.luz_changed.connect(_on_luz_changed)
	PlayerData.inventory_changed.connect(_on_inventory_changed)

	# Conectar señales de SurvivalSystem
	if SurvivalSystem:
		SurvivalSystem.hunger_changed.connect(_on_hunger_changed)
		SurvivalSystem.thirst_changed.connect(_on_thirst_changed)
		SurvivalSystem.temperature_changed.connect(_on_temperature_changed)

	# Conectar señales de QuestSystem
	if QuestSystem:
		QuestSystem.quest_accepted.connect(_on_quest_changed)
		QuestSystem.quest_completed.connect(_on_quest_changed)
		QuestSystem.objective_updated.connect(_on_quest_changed)

	# Actualizar UI inicial
	_update_luz_bar()
	_update_hotbar()
	_update_survival_bars()
	_update_quest_tracker()

	# Ocultar debug por defecto
	if debug_panel:
		debug_panel.visible = show_debug

	# Ocultar progreso de rotura
	if break_progress:
		break_progress.visible = false

	print("🎨 GameHUD inicializado")


func _process(_delta: float) -> void:
	# Actualizar debug info si está visible
	if show_debug and debug_panel:
		_update_debug_info()

	# Actualizar progreso de rotura de bloque
	_update_break_progress()


func _input(event: InputEvent) -> void:
	# Toggle debug con F3
	if event.is_action_pressed("toggle_debug"):
		toggle_debug()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PÚBLICOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Muestra/oculta información de debug
func toggle_debug() -> void:
	show_debug = not show_debug
	if debug_panel:
		debug_panel.visible = show_debug


## Muestra información del bloque apuntado
func show_block_info(block_name: String) -> void:
	if block_info_label:
		block_info_label.text = block_name
		block_info_label.visible = true


## Oculta información del bloque
func hide_block_info() -> void:
	if block_info_label:
		block_info_label.visible = false


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PRIVADOS - SETUP
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Configura los 9 slots del hotbar
func _setup_hotbar() -> void:
	if not hotbar:
		return

	# Crear 9 slots
	for i in range(Constants.INVENTORY_SIZE):
		var slot = Panel.new()
		slot.custom_minimum_size = Vector2(60, 60)

		# Label para el número de slot
		var slot_number = Label.new()
		slot_number.text = str(i + 1)
		slot_number.add_theme_font_size_override("font_size", 12)
		slot.add_child(slot_number)

		# Label para la cantidad de items
		var item_count = Label.new()
		item_count.name = "ItemCount"
		item_count.text = ""
		item_count.add_theme_font_size_override("font_size", 16)
		item_count.position = Vector2(5, 30)
		slot.add_child(item_count)

		hotbar.add_child(slot)
		hotbar_slots.append(slot)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PRIVADOS - ACTUALIZACIÓN
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Actualiza la barra de Luz Interior
func _update_luz_bar() -> void:
	if not luz_bar:
		return

	var current_luz = PlayerData.get_luz()
	luz_bar.value = current_luz
	luz_bar.max_value = Constants.MAX_LUZ

	if luz_label:
		luz_label.text = "✨ Luz: %d / %d" % [current_luz, Constants.MAX_LUZ]


## Actualiza los slots del hotbar
func _update_hotbar() -> void:
	# Actualizar cada slot
	for i in range(hotbar_slots.size()):
		var slot = hotbar_slots[i]

		# Destacar slot activo
		if i == PlayerData.active_slot:
			slot.add_theme_stylebox_override("panel", _create_highlight_style())
		else:
			slot.remove_theme_stylebox_override("panel")

		# Actualizar cantidad de items
		var block_type = i as Enums.BlockType
		var count = PlayerData.get_item_count(block_type)

		var item_count_label = slot.get_node("ItemCount") as Label
		if item_count_label:
			if count > 0:
				item_count_label.text = str(count)
			else:
				item_count_label.text = ""


## Actualiza información de debug
func _update_debug_info() -> void:
	if not debug_panel or not GameManager.player:
		return

	var player_pos = GameManager.player.global_position
	var chunk_pos = Utils.world_to_chunk_position(player_pos)
	var block_pos = Utils.world_to_block_position(player_pos)

	var debug_text = ""
	debug_text += "FPS: %d\n" % Engine.get_frames_per_second()
	debug_text += "Posición: %.1f, %.1f, %.1f\n" % [player_pos.x, player_pos.y, player_pos.z]
	debug_text += "Chunk: %s\n" % Utils.vector3i_to_string(chunk_pos)
	debug_text += "Bloque: %s\n" % Utils.vector3i_to_string(block_pos)
	debug_text += "Tiempo: %s\n" % GameManager.get_play_time_formatted()
	debug_text += "Luz: %d / %d" % [PlayerData.get_luz(), Constants.MAX_LUZ]

	# Buscar o crear label
	var debug_label = debug_panel.get_node_or_null("DebugLabel") as Label
	if not debug_label:
		debug_label = Label.new()
		debug_label.name = "DebugLabel"
		debug_label.add_theme_font_size_override("font_size", 14)
		debug_panel.add_child(debug_label)

	debug_label.text = debug_text


## Actualiza la barra de progreso de rotura de bloque
func _update_break_progress() -> void:
	if not break_progress or not GameManager.player:
		return

	var interaction = GameManager.player.get_node_or_null("PlayerInteraction")
	if not interaction:
		return

	var progress = interaction.get_break_progress()

	if progress > 0.0:
		break_progress.visible = true
		break_progress.value = progress * 100.0
	else:
		break_progress.visible = false


## Crea un estilo de panel destacado (para slot activo)
func _create_highlight_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1.0, 1.0, 0.5, 0.3)  # Amarillo semi-transparente
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color.YELLOW
	return style


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SEÑALES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _on_luz_changed(_new_luz: int) -> void:
	_update_luz_bar()


func _on_inventory_changed() -> void:
	_update_hotbar()


func _on_hunger_changed(_value: float, _max_value: float) -> void:
	_update_survival_bars()


func _on_thirst_changed(_value: float, _max_value: float) -> void:
	_update_survival_bars()


func _on_temperature_changed(_value: float) -> void:
	_update_survival_bars()


func _on_quest_changed(_quest_id: String = "") -> void:
	_update_quest_tracker()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SISTEMA DE SUPERVIVENCIA
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Configura las barras de supervivencia
func _setup_survival_bars() -> void:
	if not $TopLeft/VBoxContainer:
		return

	var vbox = $TopLeft/VBoxContainer

	# Barra de hambre
	hunger_bar = ProgressBar.new()
	hunger_bar.custom_minimum_size = Vector2(200, 25)
	hunger_bar.max_value = 100.0
	hunger_bar.show_percentage = false

	var hunger_label = Label.new()
	hunger_label.name = "HungerLabel"
	hunger_label.text = "🍖 Hambre: 100%"
	hunger_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hunger_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hunger_label.anchors_preset = Control.PRESET_FULL_RECT
	hunger_bar.add_child(hunger_label)

	vbox.add_child(hunger_bar)

	# Barra de sed
	thirst_bar = ProgressBar.new()
	thirst_bar.custom_minimum_size = Vector2(200, 25)
	thirst_bar.max_value = 100.0
	thirst_bar.show_percentage = false

	var thirst_label = Label.new()
	thirst_label.name = "ThirstLabel"
	thirst_label.text = "💧 Sed: 100%"
	thirst_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	thirst_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	thirst_label.anchors_preset = Control.PRESET_FULL_RECT
	thirst_bar.add_child(thirst_label)

	vbox.add_child(thirst_bar)

	# Label de temperatura
	temperature_label = Label.new()
	temperature_label.text = "🌡️ Temperatura: 37.0°C"
	temperature_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(temperature_label)

	print("  ✅ Barras de supervivencia creadas")


## Actualiza las barras de supervivencia
func _update_survival_bars() -> void:
	if not SurvivalSystem:
		return

	# Actualizar hambre
	if hunger_bar:
		hunger_bar.value = SurvivalSystem.hunger
		var hunger_label = hunger_bar.get_node_or_null("HungerLabel") as Label
		if hunger_label:
			var percentage = int((SurvivalSystem.hunger / SurvivalSystem.max_hunger) * 100)
			hunger_label.text = "🍖 Hambre: %d%%" % percentage

			# Color según nivel
			if percentage < 20:
				hunger_label.add_theme_color_override("font_color", Color.RED)
			elif percentage < 50:
				hunger_label.add_theme_color_override("font_color", Color.ORANGE)
			else:
				hunger_label.add_theme_color_override("font_color", Color.WHITE)

	# Actualizar sed
	if thirst_bar:
		thirst_bar.value = SurvivalSystem.thirst
		var thirst_label = thirst_bar.get_node_or_null("ThirstLabel") as Label
		if thirst_label:
			var percentage = int((SurvivalSystem.thirst / SurvivalSystem.max_thirst) * 100)
			thirst_label.text = "💧 Sed: %d%%" % percentage

			# Color según nivel
			if percentage < 20:
				thirst_label.add_theme_color_override("font_color", Color.RED)
			elif percentage < 50:
				thirst_label.add_theme_color_override("font_color", Color.ORANGE)
			else:
				thirst_label.add_theme_color_override("font_color", Color.WHITE)

	# Actualizar temperatura
	if temperature_label:
		var temp = SurvivalSystem.body_temperature
		temperature_label.text = "🌡️ Temp: %.1f°C" % temp

		# Color según temperatura
		if temp < SurvivalSystem.TEMP_COLD:
			temperature_label.add_theme_color_override("font_color", Color.CYAN)
		elif temp > SurvivalSystem.TEMP_HOT:
			temperature_label.add_theme_color_override("font_color", Color.ORANGE_RED)
		else:
			temperature_label.add_theme_color_override("font_color", Color.WHITE)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# QUEST TRACKER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Configura el quest tracker
func _setup_quest_tracker() -> void:
	# Crear panel en la esquina superior derecha (debajo del debug)
	quest_tracker_panel = PanelContainer.new()
	quest_tracker_panel.name = "QuestTracker"

	# Posicionar en top-right
	quest_tracker_panel.position = Vector2(20, 220)
	quest_tracker_panel.custom_minimum_size = Vector2(300, 100)

	# VBox para las quests
	var vbox = VBoxContainer.new()
	vbox.name = "QuestList"
	quest_tracker_panel.add_child(vbox)

	# Título
	var title = Label.new()
	title.text = "📜 Misiones Activas"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color.YELLOW)
	vbox.add_child(title)

	add_child(quest_tracker_panel)
	print("  ✅ Quest tracker creado")


## Actualiza el quest tracker
func _update_quest_tracker() -> void:
	if not QuestSystem or not quest_tracker_panel:
		return

	var vbox = quest_tracker_panel.get_node_or_null("QuestList") as VBoxContainer
	if not vbox:
		return

	# Limpiar quests antiguas (excepto el título)
	for child in vbox.get_children():
		if child.name != "Label":  # No borrar el título
			if not child.text.begins_with("📜"):
				child.queue_free()

	# Agregar quests activas
	var active_quests = QuestSystem.get_active_quests()

	if active_quests.is_empty():
		quest_tracker_panel.visible = false
		return

	quest_tracker_panel.visible = true

	for quest in active_quests:
		# Nombre de la quest
		var quest_label = Label.new()
		quest_label.text = "▸ " + quest.quest_name
		quest_label.add_theme_font_size_override("font_size", 14)
		vbox.add_child(quest_label)

		# Objetivos
		for objective in quest.objectives:
			var obj_label = Label.new()
			var progress_text = "%d/%d" % [objective.current, objective.required]

			# Emoji según tipo
			var emoji = "•"
			match objective.type:
				QuestData.ObjectiveType.COLLECT:
					emoji = "📦"
				QuestData.ObjectiveType.KILL:
					emoji = "⚔️"
				QuestData.ObjectiveType.CRAFT:
					emoji = "🔨"
				QuestData.ObjectiveType.BUILD:
					emoji = "🏗️"

			obj_label.text = "  %s %s (%s)" % [emoji, objective.description, progress_text]
			obj_label.add_theme_font_size_override("font_size", 12)

			# Color según completitud
			if objective.current >= objective.required:
				obj_label.add_theme_color_override("font_color", Color.GREEN)
			else:
				obj_label.add_theme_color_override("font_color", Color.WHITE)

			vbox.add_child(obj_label)
