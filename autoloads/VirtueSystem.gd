# ============================================================================
# VirtueSystem.gd - Sistema de Luz Interior (Virtudes)
# ============================================================================
# Singleton que gestiona el sistema de Luz Interior y recompensas
# ============================================================================

extends Node

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SEÑALES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Emitida cuando se gana Luz Interior
signal luz_gained(amount: int, reason: String)

## Emitida cuando se alcanza un milestone de Luz
signal milestone_reached(luz_amount: int)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Timer para dar Luz por tiempo de juego
var _time_played_timer: float = 0.0

## Milestones de Luz (para mostrar notificaciones)
const MILESTONES: Array[int] = [50, 100, 200, 500, 1000]

## Último milestone alcanzado
var _last_milestone: int = 0

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	print("✨ VirtueSystem inicializado")


func _process(delta: float) -> void:
	# Solo contar tiempo si estamos jugando y no pausado
	if GameManager.current_state == Enums.GameState.PLAYING and not GameManager.is_paused:
		_time_played_timer += delta

		# Dar Luz cada minuto
		if _time_played_timer >= 60.0:
			add_luz(Enums.LuzAction.TIEMPO_JUEGO)
			_time_played_timer = 0.0


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PÚBLICOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Añade Luz Interior por una acción específica
func add_luz(action: Enums.LuzAction) -> void:
	var amount = Enums.LUZ_AMOUNTS[action]
	var reason = _get_action_reason(action)

	# Añadir Luz a PlayerData
	PlayerData.add_luz(amount)

	# Emitir señal
	luz_gained.emit(amount, reason)

	# Reproducir sonido
	AudioManager.play_sfx(Enums.SoundType.LUZ_GAIN)

	# Verificar milestones
	_check_milestones()

	print("✨ Luz ganada: +", amount, " (", reason, ")")


## Añade Luz de forma manual (para casos especiales)
func add_luz_manual(amount: int, reason: String) -> void:
	PlayerData.add_luz(amount)
	luz_gained.emit(amount, reason)
	AudioManager.play_sfx(Enums.SoundType.LUZ_GAIN)
	_check_milestones()


## Obtiene la Luz Interior actual
func get_luz() -> int:
	return PlayerData.get_luz()


## Obtiene el porcentaje de progreso hacia el siguiente milestone
func get_progress_to_next_milestone() -> float:
	var current_luz = get_luz()
	var next_milestone = _get_next_milestone()

	if next_milestone == -1:
		return 1.0  # Ya alcanzó todos los milestones

	return float(current_luz) / float(next_milestone)


## Obtiene el siguiente milestone
func get_next_milestone() -> int:
	return _get_next_milestone()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PRIVADOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Convierte una acción a texto legible
func _get_action_reason(action: Enums.LuzAction) -> String:
	match action:
		Enums.LuzAction.CONSTRUCCION:
			return "Construir 10 bloques"
		Enums.LuzAction.RECOLECCION:
			return "Recolectar 20 recursos"
		Enums.LuzAction.TIEMPO_JUEGO:
			return "1 minuto de juego"
		_:
			return "Acción desconocida"


## Verifica si se alcanzó un nuevo milestone
func _check_milestones() -> void:
	var current_luz = get_luz()

	for milestone in MILESTONES:
		if current_luz >= milestone and _last_milestone < milestone:
			_last_milestone = milestone
			milestone_reached.emit(milestone)
			print("🎉 ¡Milestone alcanzado! Luz: ", milestone)


## Obtiene el siguiente milestone no alcanzado
func _get_next_milestone() -> int:
	var current_luz = get_luz()

	for milestone in MILESTONES:
		if current_luz < milestone:
			return milestone

	return -1  # Ya alcanzó todos


## Resetea el sistema (para nueva partida)
func reset() -> void:
	_time_played_timer = 0.0
	_last_milestone = 0
