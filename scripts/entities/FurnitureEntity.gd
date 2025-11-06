extends Node3D
class_name FurnitureEntity
## Entidad de un mueble colocado en el mundo

## Señales
signal interacted(furniture: FurnitureEntity)
signal removed(furniture: FurnitureEntity)
signal light_toggled(furniture: FurnitureEntity, is_on: bool)

## Datos del mueble
var furniture_data: FurnitureData
var grid_position: Vector3i  # Posición en la grilla del mundo
var rotation_index: int = 0  # 0-3 para rotaciones de 90°
var is_placed: bool = false
var is_preview: bool = false

## Almacenamiento (si aplica)
var storage_inventory: Array = []

## Estado
var is_light_on: bool = true
var current_durability: float = 100.0

## Referencias
var model_root: Node3D
var light_node: OmniLight3D
var collision_shape: CollisionShape3D
var interaction_area: Area3D

func _ready() -> void:
	if furniture_data and is_placed:
		_setup_interaction()

## Inicializa el mueble con sus datos
func initialize(data: FurnitureData, preview: bool = false) -> void:
	furniture_data = data
	is_preview = preview

	# Generar modelo 3D
	_generate_model()

	# Configurar luz si emite
	if furniture_data.emits_light:
		_setup_light()

	# Configurar colisión si no es preview
	if not is_preview:
		_setup_collision()

	# Material semi-transparente para preview
	if is_preview:
		_apply_preview_material()

## Genera el modelo 3D del mueble
func _generate_model() -> void:
	# Usar el generador de modelos
	model_root = FurnitureModelGenerator.generate_furniture_model(furniture_data)
	add_child(model_root)

	# Aplicar escala
	model_root.scale = furniture_data.model_scale

## Configura la iluminación
func _setup_light() -> void:
	if not furniture_data.emits_light:
		return

	# Buscar si el modelo ya tiene una luz
	for child in model_root.get_children():
		if child is OmniLight3D:
			light_node = child
			break

	# Si no tiene, crear una
	if not light_node:
		light_node = OmniLight3D.new()
		light_node.light_color = furniture_data.light_color
		light_node.light_energy = furniture_data.light_energy
		light_node.omni_range = furniture_data.light_range
		light_node.position = Vector3(0, 1, 0)
		model_root.add_child(light_node)

	light_node.visible = is_light_on

## Configura la colisión
func _setup_collision() -> void:
	if not furniture_data.is_solid:
		return

	var static_body = StaticBody3D.new()
	add_child(static_body)

	collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(furniture_data.size)
	collision_shape.shape = box_shape
	collision_shape.position = Vector3(furniture_data.size) / 2.0
	static_body.add_child(collision_shape)

## Configura el área de interacción
func _setup_interaction() -> void:
	if furniture_data.interaction_type == FurnitureData.InteractionType.NONE:
		return

	interaction_area = Area3D.new()
	add_child(interaction_area)

	var area_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 2.0
	area_shape.shape = sphere_shape
	area_shape.position = Vector3(furniture_data.size) / 2.0
	interaction_area.add_child(area_shape)

	interaction_area.collision_layer = 0
	interaction_area.collision_mask = 2  # Capa del jugador

## Aplica material de preview semi-transparente
func _apply_preview_material() -> void:
	for child in model_root.get_children():
		if child is MeshInstance3D:
			var mat = child.get_active_material(0)
			if mat is StandardMaterial3D:
				mat = mat.duplicate()
				mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				mat.albedo_color.a = 0.5
				child.set_surface_override_material(0, mat)

## Rota el mueble 90° en el eje Y
func rotate_furniture() -> void:
	if not furniture_data.can_rotate:
		return

	rotation_index = (rotation_index + 1) % 4
	rotation.y = deg_to_rad(rotation_index * 90)

## Establece la rotación directamente
func set_rotation_index(index: int) -> void:
	rotation_index = index % 4
	rotation.y = deg_to_rad(rotation_index * 90)

## Coloca el mueble en el mundo
func place(world_position: Vector3, grid_pos: Vector3i) -> void:
	position = world_position
	grid_position = grid_pos
	is_placed = true
	is_preview = false

	# Quitar material de preview
	_remove_preview_material()

	# Configurar colisión e interacción
	_setup_collision()
	_setup_interaction()

## Quita el material de preview
func _remove_preview_material() -> void:
	for child in model_root.get_children():
		if child is MeshInstance3D:
			child.set_surface_override_material(0, null)

## Interactúa con el mueble
func interact(player: Node3D) -> void:
	if not is_placed:
		return

	match furniture_data.interaction_type:
		FurnitureData.InteractionType.SIT:
			_handle_sit(player)
		FurnitureData.InteractionType.SLEEP:
			_handle_sleep(player)
		FurnitureData.InteractionType.OPEN_STORAGE:
			_handle_open_storage(player)
		FurnitureData.InteractionType.USE_WORKSTATION:
			_handle_use_workstation(player)
		FurnitureData.InteractionType.READ:
			_handle_read(player)
		FurnitureData.InteractionType.TURN_ON_OFF:
			_handle_toggle_light()

	# Emitir señal
	interacted.emit(self)

	# Sonido de interacción
	if furniture_data.interaction_sound:
		_play_sound(furniture_data.interaction_sound)

## Maneja sentarse
func _handle_sit(_player: Node3D) -> void:
	# TODO: Implementar animación de sentarse
	print("Sentándose en ", furniture_data.furniture_name)

	# Buff temporal de descanso
	if VirtueSystem:
		VirtueSystem.add_luz_manual(5, "Descansar en " + furniture_data.furniture_name)

## Maneja dormir
func _handle_sleep(_player: Node3D) -> void:
	# Avanzar tiempo a la mañana
	if has_node("/root/DayNightCycle"):
		get_node("/root/DayNightCycle").set_time(0.3)

	# Restaurar vida
	if PlayerData:
		PlayerData.health = PlayerData.max_health
		VirtueSystem.add_luz_manual(10, "Dormir una noche completa")

## Maneja abrir almacenamiento
func _handle_open_storage(_player: Node3D) -> void:
	# TODO: Abrir UI de almacenamiento
	print("Abriendo ", furniture_data.furniture_name, " con ", furniture_data.storage_slots, " espacios")

## Maneja usar estación de trabajo
func _handle_use_workstation(_player: Node3D) -> void:
	# Abrir crafteo
	if CraftingSystem:
		# TODO: Filtrar recetas por tipo de estación
		print("Usando estación de trabajo: ", furniture_data.furniture_name)

## Maneja leer
func _handle_read(_player: Node3D) -> void:
	# Buff de sabiduría temporal
	if VirtueSystem:
		VirtueSystem.add_luz_manual(3, "Leer en " + furniture_data.furniture_name)

	# TODO: Mostrar UI de lectura

## Maneja encender/apagar luz
func _handle_toggle_light() -> void:
	if not furniture_data.emits_light or not light_node:
		return

	is_light_on = not is_light_on
	light_node.visible = is_light_on

	light_toggled.emit(self, is_light_on)
	print(furniture_data.furniture_name, " - Luz: ", "Encendida" if is_light_on else "Apagada")

## Reproduce un sonido
func _play_sound(sound_name: String) -> void:
	if AudioManager:
		AudioManager.play_sound(sound_name)

## Remueve el mueble del mundo
func remove_furniture() -> void:
	if not is_placed:
		return

	# Reproducir sonido
	if furniture_data.placement_sound:
		_play_sound(furniture_data.placement_sound)

	# Emitir señal
	removed.emit(self)

	# Devolver recursos al inventario
	# TODO: Implementar devolución de recursos

	# Eliminar del mundo
	queue_free()

## Actualiza el color del mueble
func update_colors(primary: Color, secondary: Color) -> void:
	furniture_data.primary_color = primary
	furniture_data.secondary_color = secondary

	# Regenerar modelo
	if model_root:
		model_root.queue_free()
	_generate_model()

## Verifica si puede ser colocado en una posición
func can_place_at(_world_pos: Vector3i, _world_node: Node3D) -> bool:
	# TODO: Verificar colisiones con terreno y otros muebles
	# TODO: Verificar si es montado en pared y hay pared cerca
	# TODO: Verificar si requiere piso y hay piso debajo
	return true

## Obtiene información del mueble
func get_info() -> String:
	var info = furniture_data.furniture_name + "\n"
	info += furniture_data.description + "\n"

	if furniture_data.emits_light:
		info += "💡 Emite luz\n"

	if furniture_data.storage_slots > 0:
		info += "📦 Almacenamiento: " + str(furniture_data.storage_slots) + " espacios\n"

	if furniture_data.provides_buff:
		info += "✨ Proporciona: " + furniture_data.buff_type + "\n"

	return info
