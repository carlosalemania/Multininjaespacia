# ============================================================================
# WeatherSystem.gd - Sistema de Clima Dinámico
# ============================================================================
# Gestiona el clima del mundo con transiciones automáticas
# Integra con PresetTransitionManager para efectos visuales
# Soporta múltiples tipos de clima y transiciones aleatorias
# ============================================================================

extends Node
class_name WeatherSystem

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SIGNALS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Emitido cuando cambia el clima
signal weather_changed(old_weather: Weather, new_weather: Weather)

## Emitido cuando comienza una tormenta
signal storm_started()

## Emitido cuando termina una tormenta
signal storm_ended()

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENUMERACIONES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Tipos de clima disponibles
enum Weather {
	CLEAR,          ## Día despejado
	CLOUDY,         ## Nublado
	RAINY,          ## Lluvia (fog + partículas)
	STORMY,         ## Tormenta (fog denso + rayos)
	SNOWY,          ## Nieve
	BLIZZARD,       ## Ventisca (nieve intensa)
	FOGGY,          ## Niebla densa
	SANDSTORM       ## Tormenta de arena (bioma desierto)
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONFIGURACIÓN
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Activar cambios automáticos de clima
@export var enable_dynamic_weather: bool = true

## Duración mínima de cada clima (segundos)
@export var min_weather_duration: float = 60.0

## Duración máxima de cada clima (segundos)
@export var max_weather_duration: float = 300.0

## Duración de transiciones entre climas (segundos)
@export var transition_duration: float = 5.0

## PresetTransitionManager (auto-detect si null)
@export var transition_manager: PresetTransitionManager = null

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MAPEO CLIMA → PRESET
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Mapeo de tipo de clima a preset de shader
const WEATHER_TO_PRESET: Dictionary = {
	Weather.CLEAR: ShaderPresets.Preset.CLEAR_DAY,
	Weather.CLOUDY: ShaderPresets.Preset.CLOUDY_DAY,
	Weather.RAINY: ShaderPresets.Preset.FOGGY,       # Fog medio + lluvia
	Weather.STORMY: ShaderPresets.Preset.FOGGY,      # Fog denso + rayos
	Weather.SNOWY: ShaderPresets.Preset.SNOW_STORM,
	Weather.BLIZZARD: ShaderPresets.Preset.SNOW_STORM,
	Weather.FOGGY: ShaderPresets.Preset.FOGGY,
	Weather.SANDSTORM: ShaderPresets.Preset.DESERT_DAY  # Custom fog amarillo
}

## Probabilidades de transición entre climas
## [clima_actual][clima_siguiente] = probabilidad
const WEATHER_TRANSITIONS: Dictionary = {
	Weather.CLEAR: {
		Weather.CLEAR: 0.7,
		Weather.CLOUDY: 0.2,
		Weather.RAINY: 0.05,
		Weather.FOGGY: 0.05
	},
	Weather.CLOUDY: {
		Weather.CLEAR: 0.3,
		Weather.CLOUDY: 0.3,
		Weather.RAINY: 0.3,
		Weather.STORMY: 0.1
	},
	Weather.RAINY: {
		Weather.CLOUDY: 0.4,
		Weather.RAINY: 0.3,
		Weather.STORMY: 0.2,
		Weather.CLEAR: 0.1
	},
	Weather.STORMY: {
		Weather.RAINY: 0.5,
		Weather.CLOUDY: 0.3,
		Weather.CLEAR: 0.2
	},
	Weather.SNOWY: {
		Weather.SNOWY: 0.6,
		Weather.BLIZZARD: 0.2,
		Weather.CLOUDY: 0.2
	},
	Weather.BLIZZARD: {
		Weather.SNOWY: 0.6,
		Weather.CLOUDY: 0.4
	},
	Weather.FOGGY: {
		Weather.FOGGY: 0.4,
		Weather.CLOUDY: 0.4,
		Weather.CLEAR: 0.2
	}
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Clima actual
var current_weather: Weather = Weather.CLEAR

## Timer para próximo cambio de clima
var weather_timer: float = 0.0

## Duración del clima actual
var current_weather_duration: float = 120.0

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	# Auto-detect PresetTransitionManager
	if not transition_manager:
		transition_manager = _find_transition_manager()

	if not transition_manager:
		push_warning("⚠️ WeatherSystem: No se encontró PresetTransitionManager")
		enable_dynamic_weather = false
		return

	# Inicializar clima
	randomize()
	current_weather_duration = randf_range(min_weather_duration, max_weather_duration)

	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("  🌤️ WEATHER SYSTEM ACTIVADO")
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("Clima inicial: %s" % Weather.keys()[current_weather])
	print("Próximo cambio en: %.0fs" % current_weather_duration)
	print("Dynamic weather: %s" % enable_dynamic_weather)
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")


func _process(delta: float) -> void:
	if not enable_dynamic_weather:
		return

	weather_timer += delta

	# Verificar si es hora de cambiar clima
	if weather_timer >= current_weather_duration:
		_trigger_weather_change()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# API PÚBLICA
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Cambia el clima manualmente
## @param new_weather Nuevo clima
## @param instant Si true, cambio instantáneo. Si false, transición suave
func set_weather(new_weather: Weather, instant: bool = false) -> void:
	if new_weather == current_weather:
		return

	var old_weather = current_weather
	current_weather = new_weather

	# Aplicar preset correspondiente
	var preset = WEATHER_TO_PRESET.get(new_weather, ShaderPresets.Preset.CLEAR_DAY)

	if instant:
		transition_manager.snap_to(preset)
	else:
		transition_manager.transition_to(preset, transition_duration, PresetTransitionManager.TransitionType.EASE_IN_OUT)

	# Resetear timer
	weather_timer = 0.0
	current_weather_duration = randf_range(min_weather_duration, max_weather_duration)

	# Emitir señales
	weather_changed.emit(old_weather, new_weather)

	if _is_storm_weather(new_weather) and not _is_storm_weather(old_weather):
		storm_started.emit()
	elif not _is_storm_weather(new_weather) and _is_storm_weather(old_weather):
		storm_ended.emit()

	print("🌦️ WeatherSystem: %s → %s (%s)" % [
		Weather.keys()[old_weather],
		Weather.keys()[new_weather],
		"Instant" if instant else "Transición %.0fs" % transition_duration
	])


## Obtiene el clima actual
func get_current_weather() -> Weather:
	return current_weather


## Obtiene el nombre del clima actual
func get_current_weather_name() -> String:
	return Weather.keys()[current_weather]


## Verifica si hay tormenta activa
func is_stormy() -> bool:
	return _is_storm_weather(current_weather)


## Fuerza un clima despejado
func force_clear_weather() -> void:
	set_weather(Weather.CLEAR, false)


## Fuerza una tormenta
func force_storm() -> void:
	set_weather(Weather.STORMY, false)


## Obtiene tiempo restante hasta próximo cambio de clima
func get_time_until_next_change() -> float:
	return current_weather_duration - weather_timer


## Activa/desactiva sistema dinámico
func set_dynamic_enabled(enabled: bool) -> void:
	enable_dynamic_weather = enabled
	print("🌤️ WeatherSystem: Dynamic weather %s" % ("enabled" if enabled else "disabled"))

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PRIVADOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Busca PresetTransitionManager en la escena
func _find_transition_manager() -> PresetTransitionManager:
	# Buscar en padre
	var parent = get_parent()
	if parent:
		for child in parent.get_children():
			if child is PresetTransitionManager:
				return child

	# Buscar en root
	var root = get_tree().root
	for child in root.get_children():
		var mgr = child.find_child("*", true, false)
		if mgr is PresetTransitionManager:
			return mgr

	return null


## Trigger de cambio automático de clima
func _trigger_weather_change() -> void:
	var new_weather = _get_next_weather()
	set_weather(new_weather, false)


## Obtiene el próximo clima basado en probabilidades
func _get_next_weather() -> Weather:
	var transitions = WEATHER_TRANSITIONS.get(current_weather, {})

	if transitions.is_empty():
		# Fallback: elegir aleatoriamente
		return Weather.values()[randi() % Weather.size()]

	# Selección basada en probabilidades
	var rand_value = randf()
	var cumulative = 0.0

	for weather in transitions.keys():
		cumulative += transitions[weather]
		if rand_value <= cumulative:
			return weather

	# Fallback
	return current_weather


## Verifica si un clima es "tormentoso"
func _is_storm_weather(weather: Weather) -> bool:
	return weather in [Weather.STORMY, Weather.BLIZZARD, Weather.SANDSTORM]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# UTILIDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Imprime estado del sistema
func print_status() -> void:
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("  🌤️ WEATHER SYSTEM - STATUS")
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("Current weather: %s" % get_current_weather_name())
	print("Is stormy: %s" % is_stormy())
	print("Dynamic weather: %s" % enable_dynamic_weather)
	if enable_dynamic_weather:
		print("Time until next change: %.0fs" % get_time_until_next_change())
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
