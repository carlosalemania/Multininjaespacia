# ============================================================================
# ToolHUD.gd - HUD para Mostrar Herramienta Equipada
# ============================================================================
# Muestra la herramienta actualmente equipada con nombre, icono y durabilidad
# ============================================================================

extends Control
class_name ToolHUD

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# NODOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@onready var tool_panel: PanelContainer = $ToolPanel
@onready var tool_name_label: Label = $ToolPanel/VBoxContainer/ToolName
@onready var tool_icon_label: Label = $ToolPanel/VBoxContainer/ToolIcon
@onready var durability_bar: ProgressBar = $ToolPanel/VBoxContainer/DurabilityBar
@onready var durability_label: Label = $ToolPanel/VBoxContainer/DurabilityLabel

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Tiempo de fade out en segundos
@export var fade_out_time: float = 0.5

## Tiempo para ocultar automáticamente
@export var auto_hide_delay: float = 3.0

## Timer para auto-ocultar
var hide_timer: float = 0.0

## Herramienta actualmente mostrada
var current_tool: Variant = null

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	# Ocultar inicialmente
	tool_panel.modulate.a = 0.0
	hide_timer = 0.0

	# Configurar estilo del panel
	_setup_panel_style()

	print("🎨 ToolHUD inicializado")


func _process(delta: float) -> void:
	# Actualizar desde PlayerData
	var equipped_tool = PlayerData.get_equipped_tool()

	if equipped_tool != current_tool:
		_update_display(equipped_tool)
		current_tool = equipped_tool

	# Auto-ocultar después del delay
	if equipped_tool == null:
		_fade_out(delta)
	else:
		_fade_in(delta)
		hide_timer += delta
		if hide_timer >= auto_hide_delay:
			# No ocultar, solo reducir opacidad levemente
			tool_panel.modulate.a = lerpf(tool_panel.modulate.a, 0.7, delta * 2.0)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PRIVADOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Configura el estilo visual del panel
func _setup_panel_style() -> void:
	# El estilo se define en la escena .tscn
	# Aquí solo ajustamos propiedades dinámicas
	tool_panel.self_modulate = Color(0.1, 0.1, 0.15, 0.9)


## Actualiza la información mostrada
func _update_display(tool_type: Variant) -> void:
	hide_timer = 0.0  # Resetear timer al cambiar

	if tool_type == null:
		# Mostrar "Manos"
		tool_name_label.text = "🤚 Manos"
		tool_icon_label.text = "👋"
		durability_bar.visible = false
		durability_label.visible = false
	else:
		# Obtener datos de herramienta
		var tool_data = MagicTool.get_tool_data(tool_type)
		tool_name_label.text = tool_data.get("name", "Desconocida")

		# Icono según tier
		var tier = tool_data.get("tier", "common")
		tool_icon_label.text = _get_tier_icon(tier)

		# Mostrar durabilidad
		var current_dur = PlayerData.get_tool_durability(tool_type)
		var max_dur = tool_data.get("durability", 100)

		durability_bar.visible = true
		durability_label.visible = true
		durability_bar.max_value = max_dur
		durability_bar.value = current_dur
		durability_label.text = "%d / %d" % [current_dur, max_dur]

		# Color de la barra según durabilidad
		var durability_percent = float(current_dur) / float(max_dur)
		if durability_percent > 0.5:
			durability_bar.modulate = Color.GREEN
		elif durability_percent > 0.25:
			durability_bar.modulate = Color.YELLOW
		else:
			durability_bar.modulate = Color.RED


## Obtiene el icono visual según el tier
func _get_tier_icon(tier: String) -> String:
	match tier:
		"common": return "⚪"
		"uncommon": return "🟢"
		"rare": return "🔵"
		"epic": return "🟣"
		"legendary": return "🟡"
		"divine": return "🌟"
		_: return "❓"


## Fade in suave
func _fade_in(delta: float) -> void:
	if tool_panel.modulate.a < 1.0:
		tool_panel.modulate.a = min(1.0, tool_panel.modulate.a + delta / fade_out_time)


## Fade out suave
func _fade_out(delta: float) -> void:
	if tool_panel.modulate.a > 0.0:
		tool_panel.modulate.a = max(0.0, tool_panel.modulate.a - delta / fade_out_time)
