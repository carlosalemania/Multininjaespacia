# ============================================================================
# DayNightCycle.gd - Ciclo de Día y Noche
# ============================================================================
# Sistema de tiempo con sol, luna, estrellas y transiciones de luz
# ============================================================================

extends Node3D
class_name DayNightCycle

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SEÑALES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Emitida cuando cambia el periodo del día
signal time_period_changed(new_period: TimePeriod)

## Emitida cada hora del juego
signal hour_changed(hour: int)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENUMS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum TimePeriod {
	DAWN,       ## Amanecer (5:00 - 7:00)
	DAY,        ## Día (7:00 - 17:00)
	DUSK,       ## Atardecer (17:00 - 19:00)
	NIGHT       ## Noche (19:00 - 5:00)
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONFIGURACIÓN
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Duración de un día completo en segundos (en tiempo real)
@export var day_duration: float = 600.0  # 10 minutos

## Velocidad del ciclo (1.0 = normal, 2.0 = doble velocidad)
@export var time_scale: float = 1.0

## Activar/desactivar el ciclo
@export var cycle_enabled: bool = true

## Hora inicial (0-24)
@export var starting_hour: float = 7.0

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# NODOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Sol (DirectionalLight3D)
@onready var sun: DirectionalLight3D = null

## Luna (DirectionalLight3D)
@onready var moon: DirectionalLight3D = null

## Luz ambiental (WorldEnvironment)
@onready var world_environment: WorldEnvironment = null

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Hora actual del día (0-24)
var current_hour: float = 7.0

## Periodo actual del día
var current_period: TimePeriod = TimePeriod.DAY

## Ángulo del sol (0-360 grados)
var sun_angle: float = 0.0

# Colores según periodo
var sky_colors: Dictionary = {
	TimePeriod.DAWN: Color(1.0, 0.6, 0.4),      # Naranja suave
	TimePeriod.DAY: Color(0.53, 0.81, 0.92),    # Azul cielo
	TimePeriod.DUSK: Color(1.0, 0.4, 0.2),      # Naranja rojizo
	TimePeriod.NIGHT: Color(0.05, 0.05, 0.15)   # Azul muy oscuro
}

var sun_colors: Dictionary = {
	TimePeriod.DAWN: Color(1.0, 0.7, 0.5),
	TimePeriod.DAY: Color(1.0, 0.95, 0.9),
	TimePeriod.DUSK: Color(1.0, 0.5, 0.3),
	TimePeriod.NIGHT: Color(0.3, 0.3, 0.4)
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	current_hour = starting_hour
	_setup_lights()
	_update_time_period()
	print("🌅 Ciclo Día/Noche inicializado (hora: %.1f)" % current_hour)


func _process(delta: float) -> void:
	if not cycle_enabled:
		return

	# Avanzar el tiempo
	var previous_hour = int(current_hour)
	var hour_increment = (24.0 / day_duration) * delta * time_scale
	current_hour += hour_increment

	# Emitir señal si cambió la hora
	var new_hour = int(current_hour)
	if new_hour != previous_hour:
		hour_changed.emit(new_hour)

	# Wrap around (0-24)
	if current_hour >= 24.0:
		current_hour -= 24.0
		print("🌍 ¡Nuevo día!")

	# Actualizar sol/luna
	_update_sun_position()
	_update_lighting()
	_update_time_period()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONFIGURACIÓN INICIAL
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Configura luces (sol y luna)
func _setup_lights() -> void:
	# Crear sol si no existe
	if not sun:
		sun = DirectionalLight3D.new()
		sun.name = "Sun"
		sun.light_energy = 1.0
		sun.shadow_enabled = true
		add_child(sun)

	# Crear luna si no existe
	if not moon:
		moon = DirectionalLight3D.new()
		moon.name = "Moon"
		moon.light_energy = 0.3
		moon.light_color = Color(0.7, 0.7, 1.0)  # Azul lunar
		moon.shadow_enabled = false
		add_child(moon)

	# Crear WorldEnvironment si no existe
	if not world_environment:
		world_environment = WorldEnvironment.new()
		world_environment.name = "WorldEnvironment"

		var env = Environment.new()
		env.background_mode = Environment.BG_SKY
		env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
		env.ambient_light_energy = 1.0

		# Crear cielo
		var sky = Sky.new()
		var sky_material = ProceduralSkyMaterial.new()
		sky_material.sky_top_color = Color(0.53, 0.81, 0.92)
		sky_material.sky_horizon_color = Color(0.8, 0.9, 1.0)
		sky_material.ground_bottom_color = Color(0.2, 0.3, 0.4)
		sky_material.ground_horizon_color = Color(0.4, 0.5, 0.6)
		sky.sky_material = sky_material

		env.sky = sky
		world_environment.environment = env
		add_child(world_environment)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ACTUALIZACIÓN DEL CICLO
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Actualiza la posición del sol y la luna
func _update_sun_position() -> void:
	# Convertir hora (0-24) a ángulo (0-360)
	sun_angle = (current_hour / 24.0) * 360.0

	# Rotar sol
	if sun:
		# Rotar directamente en grados
		sun.rotation_degrees = Vector3(-sun_angle + 90.0, 0, 0)

	# Rotar luna (opuesta al sol)
	if moon:
		var moon_angle = sun_angle + 180.0
		moon.rotation_degrees = Vector3(-moon_angle + 90.0, 0, 0)


## Actualiza la iluminación según la hora
func _update_lighting() -> void:
	# Transiciones suaves entre periodos
	var sun_energy = _calculate_sun_energy()
	var moon_energy = _calculate_moon_energy()

	if sun:
		sun.light_energy = sun_energy
		sun.light_color = _get_interpolated_sun_color()

	if moon:
		moon.light_energy = moon_energy

	# Actualizar color del cielo
	if world_environment and world_environment.environment and world_environment.environment.sky:
		var sky_material = world_environment.environment.sky.sky_material as ProceduralSkyMaterial
		if sky_material:
			sky_material.sky_top_color = _get_interpolated_sky_color()


## Calcula la energía del sol según la hora
func _calculate_sun_energy() -> float:
	# Sol sale a las 5:00, máximo al mediodía (12:00), se oculta a las 19:00

	if current_hour >= 5.0 and current_hour < 7.0:
		# Amanecer (5-7): 0.0 → 1.0
		return remap(current_hour, 5.0, 7.0, 0.0, 1.0)
	elif current_hour >= 7.0 and current_hour < 17.0:
		# Día (7-17): 1.0
		return 1.0
	elif current_hour >= 17.0 and current_hour < 19.0:
		# Atardecer (17-19): 1.0 → 0.0
		return remap(current_hour, 17.0, 19.0, 1.0, 0.0)
	else:
		# Noche: 0.0
		return 0.0


## Calcula la energía de la luna según la hora
func _calculate_moon_energy() -> float:
	# Luna sale a las 19:00, máximo a medianoche (0:00), se oculta a las 5:00

	if current_hour >= 19.0 or current_hour < 5.0:
		# Noche completa
		return 0.3
	elif current_hour >= 5.0 and current_hour < 7.0:
		# Transición amanecer
		return remap(current_hour, 5.0, 7.0, 0.3, 0.0)
	elif current_hour >= 17.0 and current_hour < 19.0:
		# Transición atardecer
		return remap(current_hour, 17.0, 19.0, 0.0, 0.3)
	else:
		return 0.0


## Obtiene el color interpolado del cielo
func _get_interpolated_sky_color() -> Color:
	var period = _get_time_period()

	if period == TimePeriod.DAWN:
		# Transición noche → amanecer → día
		var t = remap(current_hour, 5.0, 7.0, 0.0, 1.0)
		return sky_colors[TimePeriod.NIGHT].lerp(sky_colors[TimePeriod.DAY], t)
	elif period == TimePeriod.DUSK:
		# Transición día → atardecer → noche
		var t = remap(current_hour, 17.0, 19.0, 0.0, 1.0)
		return sky_colors[TimePeriod.DAY].lerp(sky_colors[TimePeriod.NIGHT], t)
	else:
		return sky_colors.get(period, Color.WHITE)


## Obtiene el color interpolado del sol
func _get_interpolated_sun_color() -> Color:
	var period = _get_time_period()

	if period == TimePeriod.DAWN:
		var t = remap(current_hour, 5.0, 7.0, 0.0, 1.0)
		return sun_colors[TimePeriod.DAWN].lerp(sun_colors[TimePeriod.DAY], t)
	elif period == TimePeriod.DUSK:
		var t = remap(current_hour, 17.0, 19.0, 0.0, 1.0)
		return sun_colors[TimePeriod.DAY].lerp(sun_colors[TimePeriod.DUSK], t)
	else:
		return sun_colors.get(period, Color.WHITE)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS DE PERIODO
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Obtiene el periodo actual según la hora
func _get_time_period() -> TimePeriod:
	if current_hour >= 5.0 and current_hour < 7.0:
		return TimePeriod.DAWN
	elif current_hour >= 7.0 and current_hour < 17.0:
		return TimePeriod.DAY
	elif current_hour >= 17.0 and current_hour < 19.0:
		return TimePeriod.DUSK
	else:
		return TimePeriod.NIGHT


## Actualiza el periodo y emite señal si cambió
func _update_time_period() -> void:
	var new_period = _get_time_period()

	if new_period != current_period:
		current_period = new_period
		time_period_changed.emit(new_period)

		match new_period:
			TimePeriod.DAWN:
				print("🌅 ¡Amanecer!")
			TimePeriod.DAY:
				print("☀️ ¡Es de día!")
			TimePeriod.DUSK:
				print("🌇 ¡Atardecer!")
			TimePeriod.NIGHT:
				print("🌙 ¡Es de noche!")


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PÚBLICOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Establece la hora
func set_time(hour: float) -> void:
	current_hour = clampf(hour, 0.0, 24.0)
	_update_sun_position()
	_update_lighting()
	_update_time_period()


## Obtiene la hora actual
func get_time() -> float:
	return current_hour


## Obtiene el periodo actual
func get_period() -> TimePeriod:
	return current_period


## Obtiene el nombre del periodo
func get_period_name() -> String:
	match current_period:
		TimePeriod.DAWN:
			return "Amanecer"
		TimePeriod.DAY:
			return "Día"
		TimePeriod.DUSK:
			return "Atardecer"
		TimePeriod.NIGHT:
			return "Noche"
		_:
			return "???"


## Activa/desactiva el ciclo
func set_cycle_enabled(enabled: bool) -> void:
	cycle_enabled = enabled
	print("⏰ Ciclo día/noche: ", "activado" if enabled else "pausado")


## Cambia la velocidad del tiempo
func set_time_scale(new_scale: float) -> void:
	time_scale = maxf(0.0, new_scale)
	print("⏱️ Velocidad del tiempo: %.1fx" % time_scale)


## Verifica si es de día
func is_day() -> bool:
	return current_period == TimePeriod.DAY


## Verifica si es de noche
func is_night() -> bool:
	return current_period == TimePeriod.NIGHT


## Obtiene el texto de hora formateado
func get_time_string() -> String:
	var hours = int(current_hour)
	var minutes = int((current_hour - hours) * 60)
	return "%02d:%02d" % [hours, minutes]


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# INTEGRACIÓN CON SHADER PRESETS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## PresetTransitionManager (opcional - si existe, se usan shaders)
var preset_transition_manager: PresetTransitionManager = null

## Último preset aplicado (para evitar transiciones redundantes)
var last_applied_preset: ShaderPresets.Preset = ShaderPresets.Preset.CLEAR_DAY


## Conecta con PresetTransitionManager para efectos visuales
## @param manager PresetTransitionManager a usar
func connect_preset_manager(manager: PresetTransitionManager) -> void:
	preset_transition_manager = manager
	print("🎨 DayNightCycle: Conectado con PresetTransitionManager")

	# Conectar señales para sincronización
	time_period_changed.connect(_on_time_period_changed_shader)

	# Aplicar preset inicial
	_update_shader_preset()


## Callback cuando cambia el periodo del día (para shaders)
func _on_time_period_changed_shader(_new_period: TimePeriod) -> void:
	if not preset_transition_manager:
		return

	_update_shader_preset()


## Actualiza el preset de shader según el periodo actual
func _update_shader_preset() -> void:
	if not preset_transition_manager:
		return

	var target_preset: ShaderPresets.Preset

	# Mapeo de periodo a preset
	match current_period:
		TimePeriod.DAWN:
			target_preset = ShaderPresets.Preset.SUNSET  # Tonos naranjas suaves
		TimePeriod.DAY:
			target_preset = ShaderPresets.Preset.CLEAR_DAY
		TimePeriod.DUSK:
			target_preset = ShaderPresets.Preset.SUNSET
		TimePeriod.NIGHT:
			target_preset = ShaderPresets.Preset.NIGHT
		_:
			target_preset = ShaderPresets.Preset.CLEAR_DAY

	# Evitar transiciones redundantes
	if target_preset == last_applied_preset:
		return

	# Aplicar transición
	preset_transition_manager.transition_to(
		target_preset,
		2.0,  # 2 segundos de transición
		PresetTransitionManager.TransitionType.EASE_IN_OUT
	)

	last_applied_preset = target_preset
