# ============================================================================
# ShaderDebugControls.gd - Controles de Debug para Shaders
# ============================================================================
# Script para ajustar parámetros de shader en tiempo real durante desarrollo
# Añadir como hijo de GameWorld o cualquier nodo de la escena principal
# ============================================================================

extends Node
class_name ShaderDebugControls

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONFIGURACIÓN
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Activar/desactivar controles de debug
@export var enabled: bool = true

## ChunkManager al que aplicar cambios (auto-detect si null)
@export var chunk_manager: Node = null

## Mostrar UI con parámetros actuales
@export var show_ui: bool = true

## Índice del preset actual
var current_preset_index: int = 0

## Parámetros actuales (para UI)
var current_params: Dictionary = {}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	if not enabled:
		return

	# Auto-detect ChunkManager
	if not chunk_manager:
		chunk_manager = _find_chunk_manager()

	if not chunk_manager:
		push_warning("⚠️ ShaderDebugControls: No se encontró ChunkManager")
		return

	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("  🎨 SHADER DEBUG CONTROLS ACTIVADOS")
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("")
	print("CONTROLES DE PRESETS:")
	print("  [1-9]       → Cambiar preset (1=Día, 2=Nublado, 3=Atardecer, etc.)")
	print("  [P]         → Ciclar entre presets")
	print("")
	print("CONTROLES DE AO:")
	print("  [Page Up]   → Aumentar AO strength (+0.1)")
	print("  [Page Down] → Disminuir AO strength (-0.1)")
	print("  [O]         → Toggle AO on/off")
	print("")
	print("CONTROLES DE FOG:")
	print("  [Home]      → Aumentar fog_start (+5)")
	print("  [End]       → Disminuir fog_start (-5)")
	print("  [Insert]    → Aumentar fog_end (+10)")
	print("  [Delete]    → Disminuir fog_end (-10)")
	print("  [F]         → Toggle Fog on/off")
	print("")
	print("CONTROLES DE LUZ:")
	print("  [+]         → Aumentar ambient_light (+0.1)")
	print("  [-]         → Disminuir ambient_light (-0.1)")
	print("  [*]         → Aumentar sun_intensity (+0.2)")
	print("  [/]         → Disminuir sun_intensity (-0.2)")
	print("")
	print("OTROS:")
	print("  [I]         → Imprimir parámetros actuales")
	print("  [L]         → Listar todos los presets")
	print("  [H]         → Mostrar esta ayuda")
	print("")
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

	# Leer parámetros iniciales
	_update_current_params()


func _input(event: InputEvent) -> void:
	if not enabled or not chunk_manager:
		return

	if not event is InputEventKey or not event.pressed:
		return

	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# PRESETS (1-9, P)
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	if event.keycode == KEY_1:
		_apply_preset(ShaderPresets.Preset.CLEAR_DAY)
	elif event.keycode == KEY_2:
		_apply_preset(ShaderPresets.Preset.CLOUDY_DAY)
	elif event.keycode == KEY_3:
		_apply_preset(ShaderPresets.Preset.SUNSET)
	elif event.keycode == KEY_4:
		_apply_preset(ShaderPresets.Preset.NIGHT)
	elif event.keycode == KEY_5:
		_apply_preset(ShaderPresets.Preset.CAVE)
	elif event.keycode == KEY_6:
		_apply_preset(ShaderPresets.Preset.FOGGY)
	elif event.keycode == KEY_7:
		_apply_preset(ShaderPresets.Preset.DESERT_DAY)
	elif event.keycode == KEY_8:
		_apply_preset(ShaderPresets.Preset.SNOW_STORM)
	elif event.keycode == KEY_9:
		_apply_preset(ShaderPresets.Preset.UNDERWATER)
	elif event.keycode == KEY_P:
		_cycle_preset()

	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# AO CONTROLS
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	elif event.keycode == KEY_PAGEUP:
		_adjust_parameter("ao_strength", 0.1)
	elif event.keycode == KEY_PAGEDOWN:
		_adjust_parameter("ao_strength", -0.1)
	elif event.keycode == KEY_O:
		_toggle_parameter("enable_ao")

	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# FOG CONTROLS
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	elif event.keycode == KEY_HOME:
		_adjust_parameter("fog_start", 5.0)
	elif event.keycode == KEY_END:
		_adjust_parameter("fog_start", -5.0)
	elif event.keycode == KEY_INSERT:
		_adjust_parameter("fog_end", 10.0)
	elif event.keycode == KEY_DELETE:
		_adjust_parameter("fog_end", -10.0)
	elif event.keycode == KEY_F:
		_toggle_parameter("enable_fog")

	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# LIGHTING CONTROLS
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	elif event.keycode == KEY_EQUAL or event.keycode == KEY_PLUS:  # +
		_adjust_parameter("ambient_light", 0.1)
	elif event.keycode == KEY_MINUS:  # -
		_adjust_parameter("ambient_light", -0.1)
	elif event.keycode == KEY_ASTERISK or event.keycode == KEY_KP_MULTIPLY:  # *
		_adjust_parameter("sun_intensity", 0.2)
	elif event.keycode == KEY_SLASH or event.keycode == KEY_KP_DIVIDE:  # /
		_adjust_parameter("sun_intensity", -0.2)

	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# INFO CONTROLS
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	elif event.keycode == KEY_I:
		_print_current_params()
	elif event.keycode == KEY_L:
		ShaderPresets.print_all_presets()
	elif event.keycode == KEY_H:
		_print_help()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PRIVADOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Busca el ChunkManager en la escena
func _find_chunk_manager() -> Node:
	# Buscar en padre
	var parent = get_parent()
	if parent:
		var chunk_mgr = parent.get_node_or_null("ChunkManager")
		if chunk_mgr:
			return chunk_mgr

	# Buscar en root
	var root = get_tree().root
	for child in root.get_children():
		var chunk_mgr = child.find_child("ChunkManager", true, false)
		if chunk_mgr:
			return chunk_mgr

	return null


## Aplica un preset a todos los chunks
func _apply_preset(preset: ShaderPresets.Preset) -> void:
	ShaderPresets.apply_preset_to_all_chunks(chunk_manager, preset)
	current_preset_index = preset
	_update_current_params()


## Cicla al siguiente preset
func _cycle_preset() -> void:
	var presets = ShaderPresets.Preset.values()
	# Excluir CUSTOM
	presets = presets.filter(func(p): return p != ShaderPresets.Preset.CUSTOM)

	var current_index_in_array = presets.find(current_preset_index)
	var next_index = (current_index_in_array + 1) % presets.size()
	var next_preset = presets[next_index]

	_apply_preset(next_preset)


## Ajusta un parámetro en todos los chunks
func _adjust_parameter(param_name: String, delta: float) -> void:
	for child in chunk_manager.get_children():
		if child is Chunk:
			var chunk: Chunk = child
			if chunk.mesh_instance:
				var material = chunk.mesh_instance.get_surface_override_material(0)
				if material is ShaderMaterial:
					var current_value = material.get_shader_parameter(param_name)
					if current_value is float:
						var new_value = clampf(current_value + delta, 0.0, 10.0)
						material.set_shader_parameter(param_name, new_value)

	_update_current_params()
	print("🎨 %s: %.2f" % [param_name, current_params.get(param_name, 0.0)])


## Toggle un parámetro boolean
func _toggle_parameter(param_name: String) -> void:
	for child in chunk_manager.get_children():
		if child is Chunk:
			var chunk: Chunk = child
			if chunk.mesh_instance:
				var material = chunk.mesh_instance.get_surface_override_material(0)
				if material is ShaderMaterial:
					var current_value = material.get_shader_parameter(param_name)
					if current_value is bool:
						var new_value = not current_value
						material.set_shader_parameter(param_name, new_value)

	_update_current_params()
	print("🎨 %s: %s" % [param_name, current_params.get(param_name, false)])


## Actualiza current_params desde el primer chunk
func _update_current_params() -> void:
	var first_chunk = chunk_manager.get_child(0) if chunk_manager.get_child_count() > 0 else null
	if not first_chunk or not first_chunk is Chunk:
		return

	var chunk: Chunk = first_chunk
	if not chunk.mesh_instance:
		return

	var material = chunk.mesh_instance.get_surface_override_material(0)
	if not material is ShaderMaterial:
		return

	current_params = {
		"enable_ao": material.get_shader_parameter("enable_ao"),
		"ao_strength": material.get_shader_parameter("ao_strength"),
		"enable_fog": material.get_shader_parameter("enable_fog"),
		"fog_color": material.get_shader_parameter("fog_color"),
		"fog_start": material.get_shader_parameter("fog_start"),
		"fog_end": material.get_shader_parameter("fog_end"),
		"ambient_light": material.get_shader_parameter("ambient_light"),
		"sun_intensity": material.get_shader_parameter("sun_intensity")
	}


## Imprime parámetros actuales
func _print_current_params() -> void:
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("  PARÁMETROS ACTUALES DE SHADER")
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("")
	print("AMBIENT OCCLUSION:")
	print("  enable_ao: %s" % current_params.get("enable_ao", false))
	print("  ao_strength: %.2f" % current_params.get("ao_strength", 0.0))
	print("")
	print("FOG:")
	print("  enable_fog: %s" % current_params.get("enable_fog", false))
	print("  fog_color: %s" % current_params.get("fog_color", Color.WHITE))
	print("  fog_start: %.1f" % current_params.get("fog_start", 0.0))
	print("  fog_end: %.1f" % current_params.get("fog_end", 0.0))
	print("")
	print("LIGHTING:")
	print("  ambient_light: %.2f" % current_params.get("ambient_light", 0.0))
	print("  sun_intensity: %.2f" % current_params.get("sun_intensity", 0.0))
	print("")
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")


## Imprime ayuda de controles
func _print_help() -> void:
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("  🎨 SHADER DEBUG CONTROLS - AYUDA")
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("")
	print("CONTROLES DE PRESETS:")
	print("  [1] Día Claro      [2] Día Nublado    [3] Atardecer")
	print("  [4] Noche          [5] Cueva          [6] Niebla Densa")
	print("  [7] Desierto       [8] Tormenta Nieve [9] Submarino")
	print("  [P] Ciclar presets")
	print("")
	print("CONTROLES DE AO:")
	print("  [Page Up/Down] Ajustar ao_strength")
	print("  [O] Toggle AO on/off")
	print("")
	print("CONTROLES DE FOG:")
	print("  [Home/End] Ajustar fog_start")
	print("  [Insert/Delete] Ajustar fog_end")
	print("  [F] Toggle Fog on/off")
	print("")
	print("CONTROLES DE LUZ:")
	print("  [+/-] Ajustar ambient_light")
	print("  [*//] Ajustar sun_intensity")
	print("")
	print("INFO:")
	print("  [I] Imprimir parámetros")
	print("  [L] Listar presets")
	print("  [H] Mostrar ayuda")
	print("")
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
