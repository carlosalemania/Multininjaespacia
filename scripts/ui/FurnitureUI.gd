extends Control
class_name FurnitureUI
## UI para seleccionar y colocar muebles

## Señales
signal furniture_selected(furniture_id: String)
signal placement_mode_toggled(enabled: bool)

## Referencias de nodos UI
@onready var main_panel: PanelContainer = $MainPanel
@onready var category_tabs: TabContainer = $MainPanel/VBox/CategoryTabs
@onready var furniture_grid: GridContainer = $MainPanel/VBox/CategoryTabs/Basico/ScrollContainer/FurnitureGrid
@onready var info_panel: PanelContainer = $MainPanel/VBox/InfoPanel
@onready var info_label: Label = $MainPanel/VBox/InfoPanel/InfoLabel
@onready var placement_button: Button = $MainPanel/VBox/BottomBar/PlacementButton
@onready var close_button: Button = $MainPanel/VBox/BottomBar/CloseButton

## Estado
var selected_furniture_id: String = ""
var is_visible: bool = false
var placement_mode: bool = false

## Categorías
var categories = {
	"Basico": FurnitureData.FurnitureCategory.BASIC_FURNITURE,
	"Almacenamiento": FurnitureData.FurnitureCategory.STORAGE,
	"Iluminacion": FurnitureData.FurnitureCategory.LIGHTING,
	"Decoracion": FurnitureData.FurnitureCategory.DECORATION,
	"Cocina": FurnitureData.FurnitureCategory.KITCHEN,
	"Educacion": FurnitureData.FurnitureCategory.EDUCATION,
	"Granja": FurnitureData.FurnitureCategory.FARM,
	"Entretenimiento": FurnitureData.FurnitureCategory.ENTERTAINMENT
}

func _ready() -> void:
	# Crear UI programáticamente si no existe en escena
	if not main_panel:
		_create_ui()

	_setup_ui()
	hide()

## Crea la UI programáticamente
func _create_ui() -> void:
	# Panel principal
	main_panel = PanelContainer.new()
	main_panel.name = "MainPanel"
	main_panel.set_anchors_preset(Control.PRESET_CENTER)
	main_panel.custom_minimum_size = Vector2(800, 600)
	add_child(main_panel)

	# Layout vertical
	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	main_panel.add_child(vbox)

	# Título
	var title = Label.new()
	title.text = "🪑 Muebles y Decoración"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)

	# Tabs de categorías
	category_tabs = TabContainer.new()
	category_tabs.name = "CategoryTabs"
	category_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(category_tabs)

	# Crear tabs para cada categoría
	for category_name in categories.keys():
		var tab = _create_category_tab(category_name)
		category_tabs.add_child(tab)

	# Panel de información
	info_panel = PanelContainer.new()
	info_panel.name = "InfoPanel"
	info_panel.custom_minimum_size = Vector2(0, 100)
	vbox.add_child(info_panel)

	info_label = Label.new()
	info_label.name = "InfoLabel"
	info_label.text = "Selecciona un mueble para ver su información"
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	info_panel.add_child(info_label)

	# Barra inferior con botones
	var bottom_bar = HBoxContainer.new()
	bottom_bar.name = "BottomBar"
	vbox.add_child(bottom_bar)

	placement_button = Button.new()
	placement_button.name = "PlacementButton"
	placement_button.text = "Modo Colocación (F)"
	placement_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	placement_button.pressed.connect(_on_placement_button_pressed)
	bottom_bar.add_child(placement_button)

	close_button = Button.new()
	close_button.name = "CloseButton"
	close_button.text = "Cerrar (ESC)"
	close_button.pressed.connect(_on_close_button_pressed)
	bottom_bar.add_child(close_button)

## Crea un tab de categoría
func _create_category_tab(category_name: String) -> Control:
	var tab = Control.new()
	tab.name = category_name

	var scroll = ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tab.add_child(scroll)

	var grid = GridContainer.new()
	grid.name = "FurnitureGrid"
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(grid)

	return tab

## Configura la UI
func _setup_ui() -> void:
	# Conectar señales
	if placement_button and not placement_button.pressed.is_connected(_on_placement_button_pressed):
		placement_button.pressed.connect(_on_placement_button_pressed)

	if close_button and not close_button.pressed.is_connected(_on_close_button_pressed):
		close_button.pressed.connect(_on_close_button_pressed)

	# Populate furniture
	_populate_furniture()

	# Estilo
	_apply_styles()

## Aplica estilos a la UI
func _apply_styles() -> void:
	if main_panel:
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
		style.border_color = Color(0.4, 0.4, 0.4)
		style.set_border_width_all(2)
		style.corner_radius_top_left = 10
		style.corner_radius_top_right = 10
		style.corner_radius_bottom_left = 10
		style.corner_radius_bottom_right = 10
		main_panel.add_theme_stylebox_override("panel", style)

	if info_panel:
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.15, 0.15, 0.15)
		style.border_color = Color(0.3, 0.3, 0.3)
		style.set_border_width_all(1)
		info_panel.add_theme_stylebox_override("panel", style)

## Puebla los muebles en la UI
func _populate_furniture() -> void:
	# Limpiar grids existentes
	for category_name in categories.keys():
		var tab = category_tabs.get_node_or_null(category_name)
		if not tab:
			continue

		var scroll = tab.get_child(0) as ScrollContainer
		if not scroll:
			continue

		var grid = scroll.get_child(0) as GridContainer
		if not grid:
			continue

		# Limpiar grid
		for child in grid.get_children():
			child.queue_free()

	# Obtener todos los muebles
	var all_furniture = FurnitureSystem.get_all_furniture()

	# Agrupar por categoría
	for furniture_id in all_furniture.keys():
		var furniture_data = all_furniture[furniture_id]
		var category = furniture_data.category

		# Encontrar el tab correspondiente
		var tab_name = _get_tab_name_for_category(category)
		if tab_name.is_empty():
			continue

		var tab = category_tabs.get_node_or_null(tab_name)
		if not tab:
			continue

		var scroll = tab.get_child(0) as ScrollContainer
		if not scroll:
			continue

		var grid = scroll.get_child(0) as GridContainer
		if not grid:
			continue

		# Crear botón de mueble
		var button = _create_furniture_button(furniture_data)
		grid.add_child(button)

## Obtiene el nombre del tab para una categoría
func _get_tab_name_for_category(category: FurnitureData.FurnitureCategory) -> String:
	for tab_name in categories.keys():
		if categories[tab_name] == category:
			return tab_name
	return ""

## Crea un botón de mueble
func _create_furniture_button(furniture_data: FurnitureData) -> Button:
	var button = Button.new()
	button.custom_minimum_size = Vector2(150, 150)
	button.text = furniture_data.icon + "\n" + furniture_data.furniture_name

	# Estilo
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.2, 0.2, 0.2)
	style_normal.border_color = Color(0.4, 0.4, 0.4)
	style_normal.set_border_width_all(2)
	button.add_theme_stylebox_override("normal", style_normal)

	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = Color(0.3, 0.3, 0.3)
	style_hover.border_color = Color(0.6, 0.6, 0.6)
	style_hover.set_border_width_all(2)
	button.add_theme_stylebox_override("hover", style_hover)

	var style_pressed = StyleBoxFlat.new()
	style_pressed.bg_color = Color(0.4, 0.6, 0.8)
	style_pressed.border_color = Color(0.6, 0.8, 1.0)
	style_pressed.set_border_width_all(3)
	button.add_theme_stylebox_override("pressed", style_pressed)

	# Conectar señal
	button.pressed.connect(_on_furniture_button_pressed.bind(furniture_data.furniture_id))

	# Tooltip con información
	button.tooltip_text = _get_furniture_tooltip(furniture_data)

	return button

## Obtiene el tooltip de un mueble
func _get_furniture_tooltip(furniture_data: FurnitureData) -> String:
	var tooltip = furniture_data.furniture_name + "\n\n"
	tooltip += furniture_data.description + "\n\n"

	tooltip += "Tamaño: %dx%dx%d bloques\n" % [furniture_data.size.x, furniture_data.size.y, furniture_data.size.z]

	if furniture_data.emits_light:
		tooltip += "💡 Emite luz\n"

	if furniture_data.storage_slots > 0:
		tooltip += "📦 Almacenamiento: " + str(furniture_data.storage_slots) + " espacios\n"

	if furniture_data.provides_buff:
		tooltip += "✨ " + furniture_data.buff_type + "\n"

	if furniture_data.craft_requirements.size() > 0:
		tooltip += "\nRecursos necesarios:\n"
		for resource in furniture_data.craft_requirements:
			tooltip += "  • " + resource + ": " + str(furniture_data.craft_requirements[resource]) + "\n"

	return tooltip

## Callback cuando se presiona un botón de mueble
func _on_furniture_button_pressed(furniture_id: String) -> void:
	selected_furniture_id = furniture_id
	_update_info_panel()
	furniture_selected.emit(furniture_id)

## Actualiza el panel de información
func _update_info_panel() -> void:
	if selected_furniture_id.is_empty():
		info_label.text = "Selecciona un mueble para ver su información"
		return

	var furniture_data = FurnitureSystem.get_furniture(selected_furniture_id)
	if not furniture_data:
		return

	var info = furniture_data.icon + " " + furniture_data.furniture_name + "\n\n"
	info += furniture_data.description + "\n\n"

	info += "📏 Tamaño: %dx%dx%d bloques\n" % [furniture_data.size.x, furniture_data.size.y, furniture_data.size.z]

	if furniture_data.emits_light:
		info += "💡 Emite luz (rango: " + str(furniture_data.light_range) + "m)\n"

	if furniture_data.storage_slots > 0:
		info += "📦 Almacenamiento: " + str(furniture_data.storage_slots) + " espacios\n"

	if furniture_data.provides_buff:
		info += "✨ Proporciona: " + furniture_data.buff_type + "\n"

	if furniture_data.interaction_type != FurnitureData.InteractionType.NONE:
		info += "🎯 Interacción: " + furniture_data.interaction_text + "\n"

	if furniture_data.craft_requirements.size() > 0:
		info += "\n🔨 Recursos necesarios:\n"
		for resource in furniture_data.craft_requirements:
			var amount = furniture_data.craft_requirements[resource]
			# TODO: Verificar si el jugador tiene suficientes recursos
			info += "  • " + resource + ": " + str(amount) + "\n"

	info_label.text = info

## Callback del botón de modo colocación
func _on_placement_button_pressed() -> void:
	if selected_furniture_id.is_empty():
		_show_message("Selecciona un mueble primero")
		return

	placement_mode = not placement_mode
	placement_mode_toggled.emit(placement_mode)

	if placement_mode:
		placement_button.text = "Salir Modo Colocación"
		hide()
	else:
		placement_button.text = "Modo Colocación (F)"

## Callback del botón cerrar
func _on_close_button_pressed() -> void:
	hide()

func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_cancel"):
		hide()
		get_viewport().set_input_as_handled()

## Muestra la UI
func show() -> void:
	super.show()
	is_visible = true
	get_tree().paused = true

## Oculta la UI
func hide() -> void:
	super.hide()
	is_visible = false
	get_tree().paused = false

## Toggle visibility
func toggle() -> void:
	if visible:
		hide()
	else:
		show()

## Muestra un mensaje temporal
func _show_message(message: String) -> void:
	print("[FurnitureUI] " + message)
	# TODO: Mostrar notificación en pantalla

## Obtiene el mueble seleccionado
func get_selected_furniture_id() -> String:
	return selected_furniture_id

## Limpia la selección
func clear_selection() -> void:
	selected_furniture_id = ""
	_update_info_panel()
