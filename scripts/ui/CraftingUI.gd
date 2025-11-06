extends Control
class_name CraftingUI
## Interfaz de usuario para el sistema de crafteo

@onready var background: ColorRect
@onready var main_panel: PanelContainer
@onready var category_tabs: TabContainer
@onready var recipe_list: VBoxContainer
@onready var preview_panel: PanelContainer
@onready var craft_button: Button
@onready var close_button: Button

var selected_recipe_id: String = ""

func _ready() -> void:
	_create_ui()
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Conectar señales del sistema de crafteo
	if CraftingSystem:
		CraftingSystem.item_crafted.connect(_on_item_crafted)
		CraftingSystem.crafting_failed.connect(_on_crafting_failed)

func _input(event: InputEvent) -> void:
	# Abrir/cerrar con tecla C
	if event.is_action_pressed("toggle_crafting"):
		toggle_panel()

	# Cerrar con ESC
	if visible and event.is_action_pressed("ui_cancel"):
		hide_panel()
		get_viewport().set_input_as_handled()

## Crear interfaz dinámica
func _create_ui() -> void:
	# Fondo oscuro
	background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.8)
	background.anchors_preset = Control.PRESET_FULL_RECT
	add_child(background)

	# Panel principal
	main_panel = PanelContainer.new()
	main_panel.custom_minimum_size = Vector2(900, 600)
	main_panel.anchors_preset = Control.PRESET_CENTER
	main_panel.offset_left = -450
	main_panel.offset_right = 450
	main_panel.offset_top = -300
	main_panel.offset_bottom = 300
	add_child(main_panel)

	# Estilo del panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.12, 0.12, 0.18, 0.98)
	panel_style.border_width_left = 3
	panel_style.border_width_top = 3
	panel_style.border_width_right = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color(0.4, 0.6, 0.8)
	panel_style.corner_radius_top_left = 15
	panel_style.corner_radius_top_right = 15
	panel_style.corner_radius_bottom_left = 15
	panel_style.corner_radius_bottom_right = 15

	var panel_theme = Theme.new()
	panel_theme.set_stylebox("panel", "PanelContainer", panel_style)
	main_panel.theme = panel_theme

	# VBox principal
	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 15)
	main_panel.add_child(main_vbox)

	# Header
	var header_hbox = HBoxContainer.new()
	main_vbox.add_child(header_hbox)

	var title_label = Label.new()
	title_label.text = "🔨 MESA DE CRAFTEO"
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(title_label)

	close_button = Button.new()
	close_button.text = "✖"
	close_button.add_theme_font_size_override("font_size", 24)
	close_button.custom_minimum_size = Vector2(50, 50)
	close_button.pressed.connect(hide_panel)
	header_hbox.add_child(close_button)

	# Separador
	var separator1 = HSeparator.new()
	main_vbox.add_child(separator1)

	# HBox para lista de recetas + preview
	var content_hbox = HBoxContainer.new()
	content_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_theme_constant_override("separation", 20)
	main_vbox.add_child(content_hbox)

	# === LADO IZQUIERDO: CATEGORÍAS + LISTA ===
	var left_panel = VBoxContainer.new()
	left_panel.custom_minimum_size = Vector2(500, 0)
	left_panel.add_theme_constant_override("separation", 10)
	content_hbox.add_child(left_panel)

	# Tab Container para categorías
	category_tabs = TabContainer.new()
	category_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_panel.add_child(category_tabs)

	# Crear tabs por categoría
	_create_category_tabs()

	# === LADO DERECHO: PREVIEW + CRAFTEO ===
	preview_panel = PanelContainer.new()
	preview_panel.custom_minimum_size = Vector2(350, 0)
	content_hbox.add_child(preview_panel)

	var preview_style = StyleBoxFlat.new()
	preview_style.bg_color = Color(0.08, 0.08, 0.12, 0.9)
	preview_style.border_width_left = 2
	preview_style.border_width_top = 2
	preview_style.border_width_right = 2
	preview_style.border_width_bottom = 2
	preview_style.border_color = Color(0.3, 0.3, 0.4)
	preview_style.corner_radius_top_left = 10
	preview_style.corner_radius_top_right = 10
	preview_style.corner_radius_bottom_left = 10
	preview_style.corner_radius_bottom_right = 10

	var preview_theme = Theme.new()
	preview_theme.set_stylebox("panel", "PanelContainer", preview_style)
	preview_panel.theme = preview_theme

	var preview_vbox = VBoxContainer.new()
	preview_vbox.add_theme_constant_override("separation", 15)
	preview_panel.add_child(preview_vbox)

	var preview_title = Label.new()
	preview_title.text = "SELECCIONA UNA RECETA"
	preview_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_title.add_theme_font_size_override("font_size", 18)
	preview_title.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	preview_vbox.add_child(preview_title)

	# Botón de craftear
	craft_button = Button.new()
	craft_button.text = "⚒️ CRAFTEAR"
	craft_button.custom_minimum_size = Vector2(0, 60)
	craft_button.add_theme_font_size_override("font_size", 24)
	craft_button.disabled = true
	craft_button.pressed.connect(_on_craft_pressed)
	main_vbox.add_child(craft_button)

## Crear tabs de categorías
func _create_category_tabs() -> void:
	var categories = CraftingSystem.get_categories()

	for category in categories:
		var scroll = ScrollContainer.new()
		scroll.name = category.capitalize()
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED

		var recipe_vbox = VBoxContainer.new()
		recipe_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		recipe_vbox.add_theme_constant_override("separation", 8)
		scroll.add_child(recipe_vbox)

		# Llenar con recetas de esta categoría
		var recipes = CraftingSystem.get_recipes_by_category(category)
		for recipe_data in recipes:
			var recipe_button = _create_recipe_button(recipe_data["id"], recipe_data["data"])
			recipe_vbox.add_child(recipe_button)

		category_tabs.add_child(scroll)

## Crear botón de receta
func _create_recipe_button(recipe_id: String, recipe: Dictionary) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 80)

	# Estilo según si se puede craftear
	var can_craft = CraftingSystem.can_craft(recipe_id)
	var style = StyleBoxFlat.new()

	if can_craft:
		style.bg_color = Color(0.15, 0.2, 0.15, 0.7)
		style.border_color = Color(0.3, 0.7, 0.3)
	else:
		style.bg_color = Color(0.2, 0.15, 0.15, 0.5)
		style.border_color = Color(0.5, 0.3, 0.3)

	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8

	var panel_theme = Theme.new()
	panel_theme.set_stylebox("panel", "PanelContainer", style)
	panel.theme = panel_theme

	var button = Button.new()
	button.flat = true
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(func(): _on_recipe_selected(recipe_id, recipe))
	panel.add_child(button)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(hbox)

	# Icono
	var icon_label = Label.new()
	icon_label.text = recipe.get("icon", "📦")
	icon_label.add_theme_font_size_override("font_size", 48)
	hbox.add_child(icon_label)

	# Texto
	var text_vbox = VBoxContainer.new()
	text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(text_vbox)

	var name_label = Label.new()
	name_label.text = recipe.get("name", "Item")
	name_label.add_theme_font_size_override("font_size", 18)
	if can_craft:
		name_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
	else:
		name_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	text_vbox.add_child(name_label)

	var desc_label = Label.new()
	desc_label.text = recipe.get("description", "")
	desc_label.add_theme_font_size_override("font_size", 13)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_vbox.add_child(desc_label)

	# Requisitos
	var req_label = Label.new()
	var req_text = "Requiere: "
	var inputs = recipe.get("inputs", {})
	var req_parts = []
	for resource in inputs:
		var amount = inputs[resource]
		var has_amount = PlayerData.resources.get(resource, 0)
		var color = "[color=green]" if has_amount >= amount else "[color=red]"
		req_parts.append(color + str(amount) + "x " + resource.capitalize() + "[/color]")
	req_text += ", ".join(req_parts)

	req_label.text = req_text
	req_label.add_theme_font_size_override("font_size", 12)
	req_label.bbcode_enabled = true
	text_vbox.add_child(req_label)

	return panel

## Cuando se selecciona una receta
func _on_recipe_selected(recipe_id: String, recipe: Dictionary) -> void:
	selected_recipe_id = recipe_id
	craft_button.disabled = not CraftingSystem.can_craft(recipe_id)
	AudioManager.play_sfx(Enums.SoundType.BUTTON_CLICK)

	# TODO: Actualizar preview panel con detalles

## Cuando se presiona craftear
func _on_craft_pressed() -> void:
	if selected_recipe_id.is_empty():
		return

	if CraftingSystem.craft(selected_recipe_id):
		# Refrescar UI
		_refresh_recipes()

## Cuando se craftea exitosamente
func _on_item_crafted(item_name: String, quantity: int) -> void:
	print("✅ Crafteado: %dx %s" % [quantity, item_name])
	AudioManager.play_sfx(Enums.SoundType.MAGIC_CAST)

## Cuando falla el crafteo
func _on_crafting_failed(reason: String) -> void:
	print("❌ Crafteo falló: ", reason)
	AudioManager.play_sfx(Enums.SoundType.BUTTON_CLICK)

## Refrescar lista de recetas
func _refresh_recipes() -> void:
	# Limpiar tabs
	for child in category_tabs.get_children():
		child.queue_free()

	# Recrear
	_create_category_tabs()

## Mostrar panel
func show_panel() -> void:
	_refresh_recipes()
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true

## Ocultar panel
func hide_panel() -> void:
	visible = false
	if not GameManager.is_paused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_tree().paused = false

## Toggle panel
func toggle_panel() -> void:
	if visible:
		hide_panel()
	else:
		show_panel()
