# ============================================================================
# AchievementPanel.gd - Panel de Logros Completo (Tecla L)
# ============================================================================
# Panel que muestra todos los logros con progreso y estado de desbloqueo
# ============================================================================

extends Control
class_name AchievementPanel

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# NODOS (creados dinámicamente)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var background: ColorRect
var panel: PanelContainer
var scroll_container: ScrollContainer
var achievement_list: VBoxContainer
var header_label: Label
var stats_label: Label
var close_button: Button

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	# Crear UI
	_create_ui()

	# Ocultar inicialmente
	visible = false

	# Liberar el mouse cuando se abre
	visibility_changed.connect(_on_visibility_changed)

	print("📋 AchievementPanel inicializado")


func _input(event: InputEvent) -> void:
	# Toggle con tecla L
	if event.is_action_pressed("toggle_achievements"):
		toggle_panel()

	# Cerrar con ESC cuando está abierto
	if visible and event.is_action_pressed("ui_cancel"):
		hide_panel()
		get_viewport().set_input_as_handled()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PÚBLICOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Muestra el panel
func show_panel() -> void:
	_refresh_achievements()
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	AudioManager.play_sfx(Enums.SoundType.BUTTON_CLICK)


## Oculta el panel
func hide_panel() -> void:
	visible = false
	if not GameManager.is_paused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	AudioManager.play_sfx(Enums.SoundType.BUTTON_CLICK)


## Toggle del panel
func toggle_panel() -> void:
	if visible:
		hide_panel()
	else:
		show_panel()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PRIVADOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Crea la UI completa
func _create_ui() -> void:
	# Fondo oscuro semi-transparente
	background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.7)
	background.anchors_preset = Control.PRESET_FULL_RECT
	add_child(background)

	# Panel principal centrado
	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(700, 500)
	panel.anchors_preset = Control.PRESET_CENTER
	panel.offset_left = -350
	panel.offset_right = 350
	panel.offset_top = -250
	panel.offset_bottom = 250
	add_child(panel)

	# Estilo del panel
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.15, 0.15, 0.2, 0.95)
	style_box.border_width_left = 2
	style_box.border_width_top = 2
	style_box.border_width_right = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.3, 0.3, 0.4)
	style_box.corner_radius_top_left = 12
	style_box.corner_radius_top_right = 12
	style_box.corner_radius_bottom_left = 12
	style_box.corner_radius_bottom_right = 12

	var theme_override = Theme.new()
	theme_override.set_stylebox("panel", "PanelContainer", style_box)
	panel.theme = theme_override

	# VBox principal
	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 12)
	panel.add_child(main_vbox)

	# Header
	var header_hbox = HBoxContainer.new()
	main_vbox.add_child(header_hbox)

	header_label = Label.new()
	header_label.text = "🏆 LOGROS"
	header_label.add_theme_font_size_override("font_size", 28)
	header_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	header_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(header_label)

	# Botón cerrar
	close_button = Button.new()
	close_button.text = "✖"
	close_button.add_theme_font_size_override("font_size", 20)
	close_button.custom_minimum_size = Vector2(40, 40)
	close_button.pressed.connect(hide_panel)
	header_hbox.add_child(close_button)

	# Stats (X/Y logros desbloqueados)
	stats_label = Label.new()
	stats_label.text = "0 / 0 Logros Desbloqueados"
	stats_label.add_theme_font_size_override("font_size", 16)
	stats_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	main_vbox.add_child(stats_label)

	# Separador
	var separator = HSeparator.new()
	main_vbox.add_child(separator)

	# ScrollContainer para logros
	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_vbox.add_child(scroll_container)

	# Lista de logros
	achievement_list = VBoxContainer.new()
	achievement_list.add_theme_constant_override("separation", 8)
	achievement_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.add_child(achievement_list)


## Refresca la lista de logros
func _refresh_achievements() -> void:
	# Limpiar lista
	for child in achievement_list.get_children():
		child.queue_free()

	# Obtener todos los logros
	var all_achievements = AchievementSystem.ACHIEVEMENTS
	var unlocked_count = 0
	var total_count = all_achievements.size()

	# Crear entrada para cada logro
	for achievement_id in all_achievements.keys():
		var achievement_data = all_achievements[achievement_id]
		var is_unlocked = AchievementSystem.is_achievement_unlocked(achievement_id)

		if is_unlocked:
			unlocked_count += 1

		var achievement_entry = _create_achievement_entry(achievement_id, achievement_data, is_unlocked)
		achievement_list.add_child(achievement_entry)

	# Actualizar stats
	stats_label.text = "%d / %d Logros Desbloqueados (%.1f%%)" % [
		unlocked_count,
		total_count,
		(float(unlocked_count) / float(total_count)) * 100.0
	]


## Crea una entrada de logro con barra de progreso
func _create_achievement_entry(_achievement_id: String, achievement_data: Dictionary, is_unlocked: bool) -> PanelContainer:
	var entry = PanelContainer.new()
	entry.custom_minimum_size = Vector2(0, 80)

	# Estilo diferente si está desbloqueado
	var style = StyleBoxFlat.new()
	if is_unlocked:
		style.bg_color = Color(0.2, 0.3, 0.2, 0.5)  # Verde oscuro
		style.border_color = Color(0.3, 0.8, 0.3)
	else:
		style.bg_color = Color(0.2, 0.2, 0.25, 0.3)  # Gris oscuro
		style.border_color = Color(0.3, 0.3, 0.35)

	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6

	var entry_theme = Theme.new()
	entry_theme.set_stylebox("panel", "PanelContainer", style)
	entry.theme = entry_theme

	# HBox principal
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	entry.add_child(hbox)

	# Icono del logro
	var icon_label = Label.new()
	icon_label.text = achievement_data.get("icon", "🏆")
	icon_label.add_theme_font_size_override("font_size", 40)
	if not is_unlocked:
		icon_label.modulate = Color(0.4, 0.4, 0.4)  # Gris si no desbloqueado
	hbox.add_child(icon_label)

	# VBox para texto + progreso
	var text_vbox = VBoxContainer.new()
	text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_vbox.add_theme_constant_override("separation", 4)
	hbox.add_child(text_vbox)

	# Título
	var title_label = Label.new()
	title_label.text = achievement_data.get("name", "Logro")
	title_label.add_theme_font_size_override("font_size", 18)
	if is_unlocked:
		title_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
	else:
		title_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	text_vbox.add_child(title_label)

	# Descripción
	var desc_label = Label.new()
	desc_label.text = achievement_data.get("description", "")
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_vbox.add_child(desc_label)

	# Barra de progreso (si no está desbloqueado)
	if not is_unlocked:
		var progress_bar = ProgressBar.new()
		progress_bar.custom_minimum_size = Vector2(0, 20)

		# Obtener progreso actual
		var stat_name = achievement_data.get("stat", "")
		var required_value = achievement_data.get("value", 1)
		var current_value = AchievementSystem.stats.get(stat_name, 0)

		progress_bar.max_value = required_value
		progress_bar.value = current_value

		# Color de la barra
		var progress_percent = float(current_value) / float(required_value)
		if progress_percent > 0.75:
			progress_bar.modulate = Color(0.3, 1.0, 0.3)
		elif progress_percent > 0.5:
			progress_bar.modulate = Color(1.0, 1.0, 0.3)
		else:
			progress_bar.modulate = Color(0.8, 0.8, 0.8)

		text_vbox.add_child(progress_bar)

		# Label de progreso
		var progress_label = Label.new()
		progress_label.text = "%d / %d" % [current_value, required_value]
		progress_label.add_theme_font_size_override("font_size", 12)
		progress_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		text_vbox.add_child(progress_label)
	else:
		# Si está desbloqueado, mostrar "DESBLOQUEADO"
		var unlocked_label = Label.new()
		unlocked_label.text = "✓ DESBLOQUEADO"
		unlocked_label.add_theme_font_size_override("font_size", 14)
		unlocked_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
		text_vbox.add_child(unlocked_label)

	return entry


## Callback cuando cambia visibilidad
func _on_visibility_changed() -> void:
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		if not GameManager.is_paused:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
