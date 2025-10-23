# ============================================================================
# PresetTransitionManager.gd - Gestor de Transiciones entre Presets
# ============================================================================
# Maneja transiciones suaves y automáticas entre presets de shaders
# Soporta múltiples tipos de transición (linear, smooth, bounce)
# ============================================================================

extends Node
class_name PresetTransitionManager

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SIGNALS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Emitido cuando comienza una transición
signal transition_started(from_preset: ShaderPresets.Preset, to_preset: ShaderPresets.Preset)

## Emitido cuando termina una transición
signal transition_finished(preset: ShaderPresets.Preset)

## Emitido cada frame durante transición (progress 0.0-1.0)
signal transition_progress(progress: float)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENUMERACIONES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Tipos de curva de transición
enum TransitionType {
	LINEAR,         ## Transición lineal constante
	EASE_IN,        ## Acelera al inicio
	EASE_OUT,       ## Desacelera al final
	EASE_IN_OUT,    ## Acelera y desacelera (smooth)
	BOUNCE,         ## Rebote al final
	ELASTIC         ## Elástico (overshoot)
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## ChunkManager objetivo (auto-detect si null)
@export var chunk_manager: Node = null

## Duración por defecto de transiciones (segundos)
@export var default_duration: float = 3.0

## Tipo de transición por defecto
@export var default_transition_type: TransitionType = TransitionType.EASE_IN_OUT

## ¿Está activa una transición?
var is_transitioning: bool = false

## Preset origen
var from_preset: ShaderPresets.Preset = ShaderPresets.Preset.CLEAR_DAY

## Preset destino
var to_preset: ShaderPresets.Preset = ShaderPresets.Preset.CLEAR_DAY

## Timer de transición actual
var transition_timer: float = 0.0

## Duración de transición actual
var transition_duration: float = 3.0

## Tipo de transición actual
var transition_type: TransitionType = TransitionType.LINEAR

## Materiales de chunks (cache)
var chunk_materials: Array[ShaderMaterial] = []

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	# Auto-detect ChunkManager
	if not chunk_manager:
		chunk_manager = _find_chunk_manager()

	if not chunk_manager:
		push_warning("⚠️ PresetTransitionManager: No se encontró ChunkManager")
		return

	# Cachear materiales de chunks
	_cache_chunk_materials()

	print("✅ PresetTransitionManager: Inicializado con %d chunks" % chunk_materials.size())


func _process(delta: float) -> void:
	if not is_transitioning:
		return

	# Avanzar transición
	transition_timer += delta
	var raw_progress = clampf(transition_timer / transition_duration, 0.0, 1.0)

	# Aplicar curva de transición
	var eased_progress = _apply_easing(raw_progress, transition_type)

	# Interpolar presets
	_apply_transition(eased_progress)

	# Emitir señal de progreso
	transition_progress.emit(eased_progress)

	# Verificar si terminó
	if raw_progress >= 1.0:
		_finish_transition()

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# API PÚBLICA
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Inicia una transición a un nuevo preset
## @param target_preset Preset destino
## @param duration Duración en segundos (usa default si -1)
## @param type Tipo de transición (usa default si null)
func transition_to(
	target_preset: ShaderPresets.Preset,
	duration: float = -1.0,
	type: TransitionType = TransitionType.LINEAR
) -> void:
	# Validaciones
	if not chunk_manager or chunk_materials.is_empty():
		push_error("❌ PresetTransitionManager: No hay chunks disponibles")
		return

	# Detectar preset actual como origen
	if chunk_materials.size() > 0:
		from_preset = ShaderPresets.detect_current_preset(chunk_materials[0])

	# Si ya estamos en el preset destino, no hacer nada
	if from_preset == target_preset and not is_transitioning:
		print("ℹ️ PresetTransitionManager: Ya en preset '%s'" % ShaderPresets.get_preset_name(target_preset))
		return

	# Configurar transición
	to_preset = target_preset
	transition_duration = duration if duration > 0.0 else default_duration
	transition_type = type if type != TransitionType.LINEAR else default_transition_type
	transition_timer = 0.0
	is_transitioning = true

	# Emitir señal de inicio
	transition_started.emit(from_preset, to_preset)

	print("🎬 PresetTransitionManager: '%s' → '%s' (%ds, %s)" % [
		ShaderPresets.get_preset_name(from_preset),
		ShaderPresets.get_preset_name(to_preset),
		transition_duration,
		TransitionType.keys()[transition_type]
	])


## Cancela la transición actual y aplica preset inmediatamente
## @param preset Preset a aplicar
func snap_to(preset: ShaderPresets.Preset) -> void:
	is_transitioning = false
	ShaderPresets.apply_preset_to_all_chunks(chunk_manager, preset)
	from_preset = preset
	to_preset = preset
	print("⏭️ PresetTransitionManager: Snap a '%s'" % ShaderPresets.get_preset_name(preset))


## Pausa la transición actual
func pause_transition() -> void:
	if is_transitioning:
		set_process(false)
		print("⏸️ PresetTransitionManager: Transición pausada")


## Resume la transición pausada
func resume_transition() -> void:
	if is_transitioning:
		set_process(true)
		print("▶️ PresetTransitionManager: Transición resumida")


## Obtiene el progreso actual de transición (0.0-1.0)
func get_progress() -> float:
	if not is_transitioning:
		return 1.0
	return clampf(transition_timer / transition_duration, 0.0, 1.0)


## Verifica si hay una transición activa
func is_active() -> bool:
	return is_transitioning


## Recachea los materiales de chunks (útil si se generan nuevos chunks)
func refresh_materials() -> void:
	_cache_chunk_materials()
	print("🔄 PresetTransitionManager: Materiales actualizados (%d chunks)" % chunk_materials.size())

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


## Cachea los materiales de todos los chunks
func _cache_chunk_materials() -> void:
	chunk_materials.clear()

	if not chunk_manager:
		return

	for child in chunk_manager.get_children():
		if child is Chunk:
			var chunk: Chunk = child
			if chunk.mesh_instance:
				var material = chunk.mesh_instance.get_surface_override_material(0)
				if material is ShaderMaterial:
					chunk_materials.append(material)


## Aplica la transición con progreso dado
func _apply_transition(progress: float) -> void:
	for material in chunk_materials:
		ShaderPresets.lerp_presets(material, from_preset, to_preset, progress)


## Finaliza la transición
func _finish_transition() -> void:
	is_transitioning = false

	# Asegurar que se aplique el preset final exacto
	ShaderPresets.apply_preset_to_all_chunks(chunk_manager, to_preset)

	# Emitir señal de finalización
	transition_finished.emit(to_preset)

	print("✅ PresetTransitionManager: Transición completada → '%s'" % ShaderPresets.get_preset_name(to_preset))


## Aplica curva de easing según tipo
func _apply_easing(t: float, type: TransitionType) -> float:
	match type:
		TransitionType.LINEAR:
			return t

		TransitionType.EASE_IN:
			# Cuadrática: t^2
			return t * t

		TransitionType.EASE_OUT:
			# Inversa cuadrática: 1 - (1-t)^2
			return 1.0 - (1.0 - t) * (1.0 - t)

		TransitionType.EASE_IN_OUT:
			# Smoothstep: 3t^2 - 2t^3
			return t * t * (3.0 - 2.0 * t)

		TransitionType.BOUNCE:
			# Bounce al final
			if t < 0.8:
				return _ease_out_cubic(t / 0.8)
			else:
				var bounce_t = (t - 0.8) / 0.2
				return 1.0 + (sin(bounce_t * PI * 2.0) * 0.1 * (1.0 - bounce_t))

		TransitionType.ELASTIC:
			# Elastic overshoot
			if t < 0.5:
				return _ease_in_out_cubic(t * 2.0) * 0.5
			else:
				var elastic_t = (t - 0.5) / 0.5
				return 0.5 + (_ease_out_cubic(elastic_t) + sin(elastic_t * PI * 3.0) * 0.05) * 0.5

		_:
			return t


## Ease out cubic
func _ease_out_cubic(t: float) -> float:
	var f = t - 1.0
	return f * f * f + 1.0


## Ease in out cubic
func _ease_in_out_cubic(t: float) -> float:
	if t < 0.5:
		return 4.0 * t * t * t
	else:
		var f = (2.0 * t) - 2.0
		return 0.5 * f * f * f + 1.0

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# UTILIDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Imprime estado actual del manager
func print_status() -> void:
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("  PRESET TRANSITION MANAGER - STATUS")
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("Transitioning: %s" % is_transitioning)
	if is_transitioning:
		print("From: %s" % ShaderPresets.get_preset_name(from_preset))
		print("To: %s" % ShaderPresets.get_preset_name(to_preset))
		print("Progress: %.1f%%" % (get_progress() * 100.0))
		print("Duration: %.1fs" % transition_duration)
		print("Type: %s" % TransitionType.keys()[transition_type])
	else:
		print("Current: %s" % ShaderPresets.get_preset_name(from_preset))
	print("Chunks: %d" % chunk_materials.size())
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
