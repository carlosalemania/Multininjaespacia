# ============================================================================
# AchievementNotification.gd - Notificación Emergente de Logros
# ============================================================================
# Popup animado que aparece cuando se desbloquea un logro
# ============================================================================

extends Control
class_name AchievementNotification

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# NODOS (creados dinámicamente)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var panel: PanelContainer
var vbox: VBoxContainer
var title_label: Label
var icon_label: Label
var description_label: Label

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Duración de la notificación en pantalla
const DISPLAY_DURATION: float = 4.0

## Velocidad de animación
const ANIMATION_SPEED: float = 0.3

## Offset desde el borde superior
const TOP_OFFSET: float = 80.0

## Timer interno
var display_timer: float = 0.0

## Estado de la animación
enum AnimState { SLIDE_IN, DISPLAYING, SLIDE_OUT, FINISHED }
var current_state: AnimState = AnimState.SLIDE_IN

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	# Crear UI dinámicamente
	_create_ui()

	# Posicionar fuera de pantalla (arriba)
	position = Vector2(0, -200)


func _process(delta: float) -> void:
	match current_state:
		AnimState.SLIDE_IN:
			_animate_slide_in(delta)

		AnimState.DISPLAYING:
			display_timer += delta
			if display_timer >= DISPLAY_DURATION:
				current_state = AnimState.SLIDE_OUT

		AnimState.SLIDE_OUT:
			_animate_slide_out(delta)

		AnimState.FINISHED:
			queue_free()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PÚBLICOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Muestra una notificación de logro
func show_achievement(achievement_id: String, achievement_data: Dictionary) -> void:
	var icon = achievement_data.get("icon", "🏆")
	var title = achievement_data.get("name", "Logro Desbloqueado")
	var description = achievement_data.get("description", "")

	icon_label.text = icon
	title_label.text = title
	description_label.text = description

	# Reproducir sonido de desbloqueo
	AudioManager.play_sfx(Enums.SoundType.MAGIC_CAST)

	# Generar sonido procedural de logro
	var achievement_sound = ProceduralSounds.generate_achievement_sound()
	var player_sfx = AudioManager._get_free_sfx_player()
	player_sfx.stream = achievement_sound
	player_sfx.volume_db = -5.0
	player_sfx.play()

	print("🎉 LOGRO DESBLOQUEADO: ", title)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PRIVADOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Crea la UI dinámicamente
func _create_ui() -> void:
	# Panel contenedor
	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(400, 120)
	add_child(panel)

	# Estilo del panel
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.1, 0.1, 0.15, 0.95)
	style_box.border_width_left = 4
	style_box.border_width_top = 4
	style_box.border_width_right = 4
	style_box.border_width_bottom = 4
	style_box.border_color = Color(1.0, 0.84, 0.0)  # Dorado
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8

	var theme_override = Theme.new()
	theme_override.set_stylebox("panel", "PanelContainer", style_box)
	panel.theme = theme_override

	# VBox para organizar contenido
	vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	# Header con "LOGRO DESBLOQUEADO"
	var header = Label.new()
	header.text = "🎉 LOGRO DESBLOQUEADO"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	header.add_theme_font_size_override("font_size", 16)
	vbox.add_child(header)

	# HBox para icono + texto
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	vbox.add_child(hbox)

	# Icono del logro (emoji grande)
	icon_label = Label.new()
	icon_label.text = "🏆"
	icon_label.add_theme_font_size_override("font_size", 48)
	hbox.add_child(icon_label)

	# VBox para título + descripción
	var text_vbox = VBoxContainer.new()
	text_vbox.add_theme_constant_override("separation", 4)
	text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(text_vbox)

	# Título del logro
	title_label = Label.new()
	title_label.text = "Logro"
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	text_vbox.add_child(title_label)

	# Descripción
	description_label = Label.new()
	description_label.text = "Descripción del logro"
	description_label.add_theme_font_size_override("font_size", 14)
	description_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_vbox.add_child(description_label)

	# Centrar horizontalmente
	anchors_preset = Control.PRESET_TOP_WIDE
	offset_left = 0
	offset_right = 0
	offset_top = TOP_OFFSET
	grow_horizontal = Control.GROW_DIRECTION_BOTH


## Anima entrada desde arriba
func _animate_slide_in(delta: float) -> void:
	position.y = lerpf(position.y, TOP_OFFSET, delta / ANIMATION_SPEED)

	# Cuando llega a la posición final
	if abs(position.y - TOP_OFFSET) < 1.0:
		position.y = TOP_OFFSET
		current_state = AnimState.DISPLAYING
		display_timer = 0.0


## Anima salida hacia arriba
func _animate_slide_out(delta: float) -> void:
	position.y = lerpf(position.y, -200, delta / ANIMATION_SPEED)

	# Cuando sale de pantalla
	if position.y < -150:
		current_state = AnimState.FINISHED
