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

	# Conectar señales de PlayerData
	PlayerData.luz_changed.connect(_on_luz_changed)
	PlayerData.inventory_changed.connect(_on_inventory_changed)

	# Actualizar UI inicial
	_update_luz_bar()
	_update_hotbar()

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
