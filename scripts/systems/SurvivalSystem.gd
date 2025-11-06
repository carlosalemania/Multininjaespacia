extends Node
## Sistema de Supervivencia - Hambre, Sed, Temperatura

signal hunger_changed(value: float, max_value: float)
signal thirst_changed(value: float, max_value: float)
signal temperature_changed(value: float)
signal player_freezing(is_freezing: bool)
signal player_overheating(is_overheating: bool)
signal player_starving(is_starving: bool)
signal player_dehydrated(is_dehydrated: bool)

## Stats de supervivencia
var hunger: float = 100.0
var max_hunger: float = 100.0
var thirst: float = 100.0
var max_thirst: float = 100.0
var body_temperature: float = 37.0  # Temperatura corporal normal

## Rangos de temperatura
const TEMP_FREEZING: float = 0.0
const TEMP_COLD: float = 10.0
const TEMP_COMFORTABLE_MIN: float = 15.0
const TEMP_COMFORTABLE_MAX: float = 30.0
const TEMP_HOT: float = 40.0
const TEMP_BURNING: float = 50.0

## Rates de cambio
var hunger_drain_rate: float = 1.0  # Puntos por segundo
var thirst_drain_rate: float = 1.5  # Puntos por segundo
var temp_change_rate: float = 0.1   # Grados por segundo

## Estado
var is_enabled: bool = true
var current_biome_temp: float = 20.0  # Temperatura del bioma actual
var near_heat_source: bool = false
var in_shelter: bool = false

## Efectos
var damage_tick_timer: float = 0.0
const DAMAGE_TICK_INTERVAL: float = 2.0  # Daño cada 2 segundos

func _ready() -> void:
	print("🌡️ Sistema de Supervivencia inicializado")

func _process(delta: float) -> void:
	if not is_enabled:
		return

	# Actualizar hambre y sed
	_update_hunger(delta)
	_update_thirst(delta)
	_update_temperature(delta)

	# Aplicar efectos de estado
	_apply_survival_effects(delta)

## ============================================================================
## HAMBRE
## ============================================================================

func _update_hunger(delta: float) -> void:
	# Drenar hambre con el tiempo
	var drain = hunger_drain_rate * delta

	# Modificadores
	# TODO: Implementar cuando PlayerData tenga is_sprinting
	# if PlayerData and PlayerData.is_sprinting:
	#	drain *= 1.5  # Más hambre al correr

	hunger = max(0.0, hunger - drain)
	hunger_changed.emit(hunger, max_hunger)

	# Verificar estado de hambre
	var was_starving = hunger <= 20.0
	if was_starving != (hunger <= 20.0):
		player_starving.emit(hunger <= 20.0)

## Comer comida
func eat_food(food_id: String) -> bool:
	var food_data = _get_food_data(food_id)
	if not food_data:
		return false

	hunger = min(max_hunger, hunger + food_data.hunger_restore)

	# Efectos adicionales
	# TODO: Implementar cuando PlayerData tenga heal()
	if food_data.has("health_restore"):
		print("  💚 +%.1f HP" % food_data.health_restore)
		# PlayerData.heal(food_data.health_restore)

	if food_data.has("thirst_restore"):
		thirst = min(max_thirst, thirst + food_data.thirst_restore)

	hunger_changed.emit(hunger, max_hunger)
	print("🍖 Comido: ", food_id, " (+", food_data.hunger_restore, " hambre)")
	return true

func _get_food_data(food_id: String) -> Dictionary:
	# Base de datos de comidas
	var foods = {
		# Carne
		"raw_meat": {"hunger_restore": 10.0, "health_restore": 0},
		"cooked_meat": {"hunger_restore": 30.0, "health_restore": 5},
		"steak": {"hunger_restore": 40.0, "health_restore": 10},

		# Pescado
		"raw_fish": {"hunger_restore": 8.0},
		"cooked_fish": {"hunger_restore": 25.0, "health_restore": 5},

		# Vegetales
		"apple": {"hunger_restore": 15.0, "thirst_restore": 5.0},
		"bread": {"hunger_restore": 20.0},
		"carrot": {"hunger_restore": 12.0},
		"potato": {"hunger_restore": 10.0},
		"baked_potato": {"hunger_restore": 22.0},

		# Comidas elaboradas
		"stew": {"hunger_restore": 45.0, "health_restore": 15, "thirst_restore": 10.0},
		"soup": {"hunger_restore": 35.0, "thirst_restore": 20.0},
		"pie": {"hunger_restore": 40.0, "health_restore": 10},

		# Snacks
		"berries": {"hunger_restore": 8.0, "thirst_restore": 3.0},
		"mushroom": {"hunger_restore": 5.0}  # Puede ser venenoso
	}

	return foods.get(food_id, {})

## ============================================================================
## SED
## ============================================================================

func _update_thirst(delta: float) -> void:
	# Drenar sed con el tiempo
	var drain = thirst_drain_rate * delta

	# Modificadores
	if body_temperature > TEMP_HOT:
		drain *= 1.5  # Más sed con calor

	# TODO: Implementar cuando PlayerData tenga is_sprinting
	# if PlayerData and PlayerData.is_sprinting:
	#	drain *= 1.3

	thirst = max(0.0, thirst - drain)
	thirst_changed.emit(thirst, max_thirst)

	# Verificar estado de sed
	var was_dehydrated = thirst <= 20.0
	if was_dehydrated != (thirst <= 20.0):
		player_dehydrated.emit(thirst <= 20.0)

## Beber agua
func drink_water(amount: float = 30.0) -> void:
	thirst = min(max_thirst, thirst + amount)
	thirst_changed.emit(thirst, max_thirst)
	print("💧 Bebido agua (+", amount, " sed)")

## Beber de una botella
func drink_item(item_id: String) -> bool:
	var drink_data = _get_drink_data(item_id)
	if not drink_data:
		return false

	thirst = min(max_thirst, thirst + drink_data.thirst_restore)

	# Efectos adicionales
	# TODO: Implementar cuando PlayerData tenga heal()
	if drink_data.has("health_restore"):
		print("  💚 +%.1f HP" % drink_data.health_restore)
		# PlayerData.heal(drink_data.health_restore)

	if drink_data.has("hunger_restore"):
		hunger = min(max_hunger, hunger + drink_data.hunger_restore)

	thirst_changed.emit(thirst, max_thirst)
	print("🥤 Bebido: ", item_id, " (+", drink_data.thirst_restore, " sed)")
	return true

func _get_drink_data(drink_id: String) -> Dictionary:
	var drinks = {
		"water_bottle": {"thirst_restore": 30.0},
		"dirty_water": {"thirst_restore": 20.0},  # Puede causar enfermedad
		"clean_water": {"thirst_restore": 40.0},
		"milk": {"thirst_restore": 25.0, "hunger_restore": 10.0},
		"juice": {"thirst_restore": 35.0, "hunger_restore": 5.0},
		"tea": {"thirst_restore": 30.0, "health_restore": 5},
		"coffee": {"thirst_restore": 25.0}  # Podría dar buff de velocidad
	}

	return drinks.get(drink_id, {})

## ============================================================================
## TEMPERATURA
## ============================================================================

func _update_temperature(delta: float) -> void:
	var target_temp = _calculate_target_temperature()

	# Ajustar temperatura corporal gradualmente hacia la target
	if body_temperature < target_temp:
		body_temperature = min(target_temp, body_temperature + temp_change_rate * delta)
	elif body_temperature > target_temp:
		body_temperature = max(target_temp, body_temperature - temp_change_rate * delta)

	temperature_changed.emit(body_temperature)

	# Emitir señales de estado
	var is_freezing = body_temperature < TEMP_COLD
	var is_overheating = body_temperature > TEMP_HOT

	player_freezing.emit(is_freezing)
	player_overheating.emit(is_overheating)

func _calculate_target_temperature() -> float:
	var target = current_biome_temp

	# Modificadores
	if near_heat_source:
		target += 15.0

	if in_shelter:
		# En refugio, la temperatura se estabiliza
		target = lerp(target, 20.0, 0.5)

	# Ropa (TODO: Implementar sistema de armadura/ropa)
	# if wearing_warm_clothes:
	#     target += 5.0

	return clamp(target, -10.0, 50.0)

## Establecer temperatura del bioma
func set_biome_temperature(temp: float) -> void:
	current_biome_temp = temp

## Cerca de fuente de calor (hoguera, horno, etc.)
func set_near_heat_source(value: bool) -> void:
	near_heat_source = value

## Dentro de refugio
func set_in_shelter(value: bool) -> void:
	in_shelter = value

## ============================================================================
## EFECTOS DE SUPERVIVENCIA
## ============================================================================

func _apply_survival_effects(delta: float) -> void:
	damage_tick_timer += delta
	if damage_tick_timer < DAMAGE_TICK_INTERVAL:
		return

	damage_tick_timer = 0.0
	var damage = 0.0

	# Daño por hambre
	if hunger <= 0:
		damage += 5.0
		print("💀 Muriendo de hambre...")

	elif hunger <= 20.0:
		# TODO: Reducir regeneración de stamina cuando esté implementado
		# PlayerData.stamina_regen_rate *= 0.5
		pass

	# Daño por sed
	if thirst <= 0:
		damage += 5.0
		print("💀 Muriendo de sed...")

	elif thirst <= 20.0:
		# TODO: Reducir velocidad cuando esté implementado
		# PlayerData.move_speed_modifier = 0.8
		pass

	# Daño por frío
	if body_temperature < TEMP_FREEZING:
		damage += 10.0
		print("❄️ ¡Congelándote!")

	elif body_temperature < TEMP_COLD:
		damage += 3.0
		print("🥶 Mucho frío...")
		# TODO: Reducir velocidad cuando esté implementado
		# PlayerData.move_speed_modifier = 0.9

	# Daño por calor
	if body_temperature > TEMP_BURNING:
		damage += 10.0
		print("🔥 ¡Quemándote!")

	elif body_temperature > TEMP_HOT:
		damage += 3.0
		print("🥵 Demasiado calor...")
		# Sed drena más rápido (ya implementado arriba)

	# Aplicar daño
	# TODO: Implementar cuando PlayerData tenga take_damage()
	if damage > 0:
		print("⚠️ Daño de supervivencia: %.1f HP" % damage)
		# PlayerData.take_damage(damage)

## ============================================================================
## UTILIDADES
## ============================================================================

## Habilitar/deshabilitar sistema
func set_enabled(value: bool) -> void:
	is_enabled = value

## Resetear stats (para respawn o debug)
func reset_stats() -> void:
	hunger = max_hunger
	thirst = max_thirst
	body_temperature = 37.0
	hunger_changed.emit(hunger, max_hunger)
	thirst_changed.emit(thirst, max_thirst)
	temperature_changed.emit(body_temperature)

## Obtener estado de supervivencia
func get_survival_state() -> Dictionary:
	return {
		"hunger": hunger,
		"max_hunger": max_hunger,
		"hunger_percentage": (hunger / max_hunger) * 100.0,
		"thirst": thirst,
		"max_thirst": max_thirst,
		"thirst_percentage": (thirst / max_thirst) * 100.0,
		"temperature": body_temperature,
		"is_comfortable": body_temperature >= TEMP_COMFORTABLE_MIN and body_temperature <= TEMP_COMFORTABLE_MAX,
		"is_freezing": body_temperature < TEMP_COLD,
		"is_overheating": body_temperature > TEMP_HOT,
		"is_starving": hunger <= 20.0,
		"is_dehydrated": thirst <= 20.0
	}

## Aplicar buff de comida
func apply_food_buff(buff_type: String, duration: float) -> void:
	# TODO: Implementar buffs temporales
	print("🍴 Buff aplicado: ", buff_type, " por ", duration, "s")
