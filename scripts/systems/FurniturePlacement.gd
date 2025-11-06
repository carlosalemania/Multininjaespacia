extends Node
class_name FurniturePlacement
## Sistema de colocación de muebles en el mundo

## Señales
signal furniture_placed(furniture: FurnitureEntity, position: Vector3i)
signal furniture_removed(furniture: FurnitureEntity)
signal placement_mode_changed(enabled: bool)

## Estado
var placement_mode_enabled: bool = false
var selected_furniture_id: String = ""
var preview_furniture: FurnitureEntity = null
var rotation_index: int = 0

## Referencias
var player: Node3D
var camera: Camera3D
var world: Node3D

## Configuración
var max_placement_distance: float = 5.0
var grid_size: float = 1.0
var valid_placement_color: Color = Color(0.0, 1.0, 0.0, 0.5)
var invalid_placement_color: Color = Color(1.0, 0.0, 0.0, 0.5)

## Muebles colocados
var placed_furniture: Array[FurnitureEntity] = []

func _ready() -> void:
	pass

## Inicializa el sistema con referencias
func initialize(player_node: Node3D, camera_node: Camera3D, world_node: Node3D) -> void:
	player = player_node
	camera = camera_node
	world = world_node

func _process(_delta: float) -> void:
	if not placement_mode_enabled:
		return

	# Actualizar posición del preview
	_update_preview_position()

	# Inputs
	if Input.is_action_just_pressed("rotate_furniture"):
		_rotate_preview()

	if Input.is_action_just_pressed("place_block"):
		_try_place_furniture()

	if Input.is_action_just_pressed("break_block"):
		_try_remove_furniture()

## Activa/desactiva el modo de colocación
func toggle_placement_mode() -> void:
	placement_mode_enabled = not placement_mode_enabled

	if placement_mode_enabled:
		_enter_placement_mode()
	else:
		_exit_placement_mode()

	placement_mode_changed.emit(placement_mode_enabled)

## Entra en modo de colocación
func _enter_placement_mode() -> void:
	if selected_furniture_id.is_empty():
		# Seleccionar el primer mueble por defecto
		var furniture_ids = FurnitureSystem.get_all_furniture_ids()
		if furniture_ids.size() > 0:
			select_furniture(furniture_ids[0])
	else:
		_create_preview()

## Sale del modo de colocación
func _exit_placement_mode() -> void:
	_destroy_preview()

## Selecciona un mueble para colocar
func select_furniture(furniture_id: String) -> void:
	if not FurnitureSystem.has_furniture(furniture_id):
		push_error("Mueble no encontrado: " + furniture_id)
		return

	selected_furniture_id = furniture_id
	rotation_index = 0

	# Recrear preview si está en modo de colocación
	if placement_mode_enabled:
		_destroy_preview()
		_create_preview()

## Crea el preview del mueble
func _create_preview() -> void:
	if selected_furniture_id.is_empty():
		return

	var furniture_data = FurnitureSystem.get_furniture(selected_furniture_id)
	if not furniture_data:
		return

	preview_furniture = FurnitureEntity.new()
	preview_furniture.initialize(furniture_data, true)
	preview_furniture.set_rotation_index(rotation_index)
	world.add_child(preview_furniture)

## Destruye el preview
func _destroy_preview() -> void:
	if preview_furniture:
		preview_furniture.queue_free()
		preview_furniture = null

## Actualiza la posición del preview según el raycast
func _update_preview_position() -> void:
	if not preview_furniture or not camera:
		return

	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * max_placement_distance

	var space_state = world.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var result = space_state.intersect_ray(query)

	if result:
		var hit_position = result.position
		var hit_normal = result.normal

		# Ajustar posición a la grilla
		var grid_pos = _snap_to_grid(hit_position)

		# Si es montado en pared, ajustar posición
		if preview_furniture.furniture_data.is_wall_mounted:
			grid_pos += Vector3(hit_normal) * 0.1
		else:
			# Colocar sobre la superficie
			grid_pos += Vector3(0, 0.01, 0)

		preview_furniture.position = grid_pos

		# Verificar si puede ser colocado
		var can_place = _can_place_at(grid_pos)
		_update_preview_material(can_place)
	else:
		# Colocar frente al jugador
		var forward_pos = player.global_position + player.global_transform.basis.z * -3.0
		var grid_pos = _snap_to_grid(forward_pos)
		preview_furniture.position = grid_pos
		_update_preview_material(false)

## Ajusta una posición a la grilla
func _snap_to_grid(position: Vector3) -> Vector3:
	return Vector3(
		floor(position.x / grid_size) * grid_size,
		floor(position.y / grid_size) * grid_size,
		floor(position.z / grid_size) * grid_size
	)

## Verifica si se puede colocar en una posición
func _can_place_at(position: Vector3) -> bool:
	if not preview_furniture:
		return false

	var furniture_data = preview_furniture.furniture_data
	var grid_pos = Vector3i(position)

	# Verificar distancia al jugador
	if player.global_position.distance_to(position) > max_placement_distance:
		return false

	# Verificar colisión con otros muebles
	for furniture in placed_furniture:
		if _check_overlap(grid_pos, furniture_data.size, furniture.grid_position, furniture.furniture_data.size):
			return false

	# TODO: Verificar si requiere piso y hay piso debajo
	# TODO: Verificar si es montado en pared y hay pared cerca

	# Verificar que el jugador tiene los recursos
	if not _has_required_resources(furniture_data):
		return false

	return true

## Verifica si dos muebles se solapan
func _check_overlap(pos1: Vector3i, size1: Vector3i, pos2: Vector3i, size2: Vector3i) -> bool:
	# AABB overlap check
	var max1 = pos1 + size1
	var max2 = pos2 + size2

	return not (
		pos1.x >= max2.x or max1.x <= pos2.x or
		pos1.y >= max2.y or max1.y <= pos2.y or
		pos1.z >= max2.z or max1.z <= pos2.z
	)

## Verifica si el jugador tiene los recursos necesarios
func _has_required_resources(_furniture_data: FurnitureData) -> bool:
	# TODO: Verificar recursos en inventario
	return true

## Actualiza el material del preview según validez
func _update_preview_material(is_valid: bool) -> void:
	if not preview_furniture or not preview_furniture.model_root:
		return

	var color = valid_placement_color if is_valid else invalid_placement_color

	for child in preview_furniture.model_root.get_children():
		if child is MeshInstance3D:
			var mat = child.get_active_material(0)
			if mat is StandardMaterial3D:
				mat = mat.duplicate()
				mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				mat.albedo_color = color
				child.set_surface_override_material(0, mat)

## Rota el preview
func _rotate_preview() -> void:
	if not preview_furniture:
		return

	rotation_index = (rotation_index + 1) % 4
	preview_furniture.set_rotation_index(rotation_index)

## Intenta colocar el mueble
func _try_place_furniture() -> void:
	if not preview_furniture:
		return

	var position = preview_furniture.position
	if not _can_place_at(position):
		_show_message("No se puede colocar aquí")
		if AudioManager:
			AudioManager.play_sound("error")
		return

	# Crear mueble real
	var furniture_data = FurnitureSystem.get_furniture(selected_furniture_id)
	var furniture = FurnitureEntity.new()
	furniture.initialize(furniture_data, false)
	furniture.place(position, Vector3i(position))
	furniture.set_rotation_index(rotation_index)
	world.add_child(furniture)

	# Conectar señales
	furniture.removed.connect(_on_furniture_removed)

	# Agregar a la lista
	placed_furniture.append(furniture)

	# Consumir recursos
	_consume_resources(furniture_data)

	# Emitir señal
	furniture_placed.emit(furniture, Vector3i(position))

	# Sonido
	if furniture_data.placement_sound:
		if AudioManager:
			AudioManager.play_sound(furniture_data.placement_sound)

	# Registrar en FurnitureSystem
	FurnitureSystem.place_furniture(selected_furniture_id, Vector3i(position))

	# Logro
	if AchievementSystem:
		AchievementSystem.increment_stat("furniture_placed", 1)

	_show_message("Colocado: " + furniture_data.furniture_name)

## Intenta remover un mueble
func _try_remove_furniture() -> void:
	if not camera:
		return

	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * max_placement_distance

	var space_state = world.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var result = space_state.intersect_ray(query)

	if result and result.collider:
		# Buscar si el collider pertenece a un mueble
		var node = result.collider
		while node:
			if node is FurnitureEntity:
				node.remove_furniture()
				return
			node = node.get_parent()

## Consume recursos para craftear el mueble
func _consume_resources(_furniture_data: FurnitureData) -> void:
	# TODO: Implementar consumo de recursos del inventario
	pass

## Callback cuando un mueble es removido
func _on_furniture_removed(furniture: FurnitureEntity) -> void:
	placed_furniture.erase(furniture)
	FurnitureSystem.remove_furniture(furniture.grid_position)
	furniture_removed.emit(furniture)

## Muestra un mensaje al jugador
func _show_message(message: String) -> void:
	print("[Furniture] " + message)
	# TODO: Mostrar en UI

## Obtiene el número de muebles colocados
func get_furniture_count() -> int:
	return placed_furniture.size()

## Obtiene muebles por categoría
func get_furniture_by_category(category: FurnitureData.FurnitureCategory) -> Array[FurnitureEntity]:
	var result: Array[FurnitureEntity] = []
	for furniture in placed_furniture:
		if furniture.furniture_data.category == category:
			result.append(furniture)
	return result

## Limpia todos los muebles (para debug/tests)
func clear_all_furniture() -> void:
	for furniture in placed_furniture.duplicate():
		furniture.remove_furniture()
	placed_furniture.clear()

## Guarda el estado de los muebles
func save_furniture_data() -> Array:
	var data = []
	for furniture in placed_furniture:
		data.append({
			"furniture_id": furniture.furniture_data.furniture_id,
			"position": furniture.grid_position,
			"rotation": furniture.rotation_index,
			"is_light_on": furniture.is_light_on
		})
	return data

## Carga el estado de los muebles
func load_furniture_data(data: Array) -> void:
	clear_all_furniture()

	for furniture_info in data:
		var furniture_data = FurnitureSystem.get_furniture(furniture_info.furniture_id)
		if not furniture_data:
			continue

		var furniture = FurnitureEntity.new()
		furniture.initialize(furniture_data, false)
		furniture.place(
			Vector3(furniture_info.position),
			furniture_info.position
		)
		furniture.set_rotation_index(furniture_info.rotation)
		furniture.is_light_on = furniture_info.is_light_on

		world.add_child(furniture)
		furniture.removed.connect(_on_furniture_removed)
		placed_furniture.append(furniture)
