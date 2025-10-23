# ============================================================================
# PlayerData.gd - Datos del Jugador
# ============================================================================
# Singleton que almacena el inventario, recursos, posición y Luz del jugador
# ============================================================================

extends Node

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SEÑALES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Emitida cuando cambia el inventario
signal inventory_changed

## Emitida cuando se recolecta un recurso
signal resource_collected(resource_type: Enums.ResourceType, amount: int)

## Emitida cuando cambia la Luz Interior
signal luz_changed(new_luz: int)

## Emitida cuando cambia la posición del jugador
signal player_position_changed(new_position: Vector3)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Inventario del jugador (Dictionary: BlockType → cantidad)
var inventory: Dictionary = {}

## Recursos recolectados (Dictionary: ResourceType → cantidad)
var resources: Dictionary = {}

## Luz Interior acumulada
var luz_interior: int = Constants.STARTING_LUZ

## Posición actual del jugador
var player_position: Vector3 = Vector3.ZERO

## Slot activo del inventario (0-8)
var active_slot: int = 0

## Modo creativo (bloques infinitos)
var creative_mode: bool = true  # true para testing

## Contador de bloques construidos seguidos (para Luz)
var consecutive_blocks_built: int = 0

## Contador de recursos recolectados desde última recompensa
var resources_collected_since_reward: int = 0

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	print("💾 PlayerData inicializado")
	reset()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# INVENTARIO
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Añade bloques al inventario
func add_item(block_type: Enums.BlockType, amount: int = 1) -> void:
	if not inventory.has(block_type):
		inventory[block_type] = 0

	# Aplicar límite de stack
	var new_amount = min(inventory[block_type] + amount, Constants.MAX_STACK_SIZE)
	inventory[block_type] = new_amount

	inventory_changed.emit()
	print("➕ Añadido al inventario: ", Enums.BLOCK_NAMES[block_type], " x", amount)


## Remueve bloques del inventario
func remove_item(block_type: Enums.BlockType, amount: int = 1) -> bool:
	# Modo creativo: bloques infinitos, nunca se gastan
	if creative_mode:
		return true

	if not has_item(block_type, amount):
		return false

	inventory[block_type] -= amount

	# Eliminar entrada si llega a 0
	if inventory[block_type] <= 0:
		inventory.erase(block_type)

	inventory_changed.emit()
	return true


## Verifica si el jugador tiene suficientes bloques
func has_item(block_type: Enums.BlockType, amount: int = 1) -> bool:
	return inventory.has(block_type) and inventory[block_type] >= amount


## Obtiene la cantidad de un bloque en el inventario
func get_item_count(block_type: Enums.BlockType) -> int:
	return inventory.get(block_type, 0)


## Obtiene el bloque del slot activo (o NONE si vacío)
func get_active_block() -> Enums.BlockType:
	# Convertir slot (0-8) a BlockType (0-4)
	# Slots 0-4 = Tierra, Piedra, Madera, Cristal, Oro
	# Slots 5-8 = Sin asignar por ahora
	if active_slot >= 5:
		return Enums.BlockType.NONE

	var block_type = active_slot as Enums.BlockType

	# Modo creativo: siempre tener todos los bloques disponibles
	if creative_mode:
		return block_type

	# Verificar si tiene al menos 1 en inventario
	if has_item(block_type, 1):
		return block_type

	return Enums.BlockType.NONE


## Cambia el slot activo (con números 1-9 del teclado)
func set_active_slot(slot: int) -> void:
	active_slot = clamp(slot, 0, Constants.INVENTORY_SIZE - 1)
	inventory_changed.emit()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RECURSOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Añade recursos recolectados
func add_resource(resource_type: Enums.ResourceType, amount: int = 1) -> void:
	if not resources.has(resource_type):
		resources[resource_type] = 0

	resources[resource_type] += amount
	resources_collected_since_reward += amount

	resource_collected.emit(resource_type, amount)
	print("💎 Recurso recolectado: ", Enums.RESOURCE_NAMES[resource_type], " x", amount)

	# Verificar si se ganó Luz por recolección
	_check_resource_luz_reward()


## Obtiene la cantidad de un recurso
func get_resource_count(resource_type: Enums.ResourceType) -> int:
	return resources.get(resource_type, 0)


## Verifica si se debe dar recompensa de Luz por recolección
func _check_resource_luz_reward() -> void:
	if resources_collected_since_reward >= 20:
		VirtueSystem.add_luz(Enums.LuzAction.RECOLECCION)
		resources_collected_since_reward = 0


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# LUZ INTERIOR
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Añade Luz Interior (llamado desde VirtueSystem)
func add_luz(amount: int) -> void:
	luz_interior = min(luz_interior + amount, Constants.MAX_LUZ)
	luz_changed.emit(luz_interior)
	print("✨ Luz Interior ganada: +", amount, " (Total: ", luz_interior, ")")


## Obtiene la Luz Interior actual
func get_luz() -> int:
	return luz_interior


## Obtiene el porcentaje de Luz (0.0 - 1.0)
func get_luz_percentage() -> float:
	return float(luz_interior) / float(Constants.MAX_LUZ)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONSTRUCCIÓN (PARA LUZ)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Notifica que se colocó un bloque (para contador de Luz)
func on_block_placed() -> void:
	consecutive_blocks_built += 1

	# Verificar si se ganó Luz por construcción (10 bloques seguidos)
	if consecutive_blocks_built >= 10:
		VirtueSystem.add_luz(Enums.LuzAction.CONSTRUCCION)
		consecutive_blocks_built = 0


## Resetea el contador de bloques seguidos (si el jugador deja de construir)
func reset_construction_counter() -> void:
	consecutive_blocks_built = 0


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# POSICIÓN
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Actualiza la posición del jugador
func update_position(new_position: Vector3) -> void:
	player_position = new_position
	player_position_changed.emit(new_position)


## Obtiene la posición del jugador
func get_position() -> Vector3:
	return player_position


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RESET
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Resetea todos los datos del jugador (nueva partida)
func reset() -> void:
	print("🔄 Reseteando datos del jugador...")

	# Limpiar inventario
	inventory.clear()

	# Dar bloques iniciales para empezar (cantidad generosa para testing)
	add_item(Enums.BlockType.TIERRA, 99)
	add_item(Enums.BlockType.PIEDRA, 99)
	add_item(Enums.BlockType.MADERA, 99)
	add_item(Enums.BlockType.CRISTAL, 99)
	add_item(Enums.BlockType.ORO, 99)

	# Resetear recursos
	resources.clear()

	# Resetear Luz
	luz_interior = Constants.STARTING_LUZ

	# Posición inicial (spawn en el aire, caerá al suelo)
	player_position = Vector3(0, Constants.PLAYER_SPAWN_HEIGHT, 0)

	# Resetear contadores
	active_slot = 0
	consecutive_blocks_built = 0
	resources_collected_since_reward = 0

	# Emitir señales
	inventory_changed.emit()
	luz_changed.emit(luz_interior)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SERIALIZACIÓN (PARA GUARDADO)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Convierte los datos del jugador a Dictionary (para guardar)
func to_dict() -> Dictionary:
	return {
		"inventory": inventory,
		"resources": resources,
		"luz_interior": luz_interior,
		"player_position": {
			"x": player_position.x,
			"y": player_position.y,
			"z": player_position.z
		},
		"active_slot": active_slot
	}


## Carga datos desde Dictionary (al cargar partida)
func from_dict(data: Dictionary) -> void:
	inventory = data.get("inventory", {})
	resources = data.get("resources", {})
	luz_interior = data.get("luz_interior", Constants.STARTING_LUZ)

	var pos_data = data.get("player_position", {"x": 0, "y": Constants.PLAYER_SPAWN_HEIGHT, "z": 0})
	player_position = Vector3(pos_data.x, pos_data.y, pos_data.z)

	active_slot = data.get("active_slot", 0)

	# Emitir señales
	inventory_changed.emit()
	luz_changed.emit(luz_interior)

	print("✅ Datos del jugador cargados")
