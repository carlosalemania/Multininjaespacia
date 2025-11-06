extends Node3D
class_name Campfire
## Hoguera/Fogata para cocinar y calentarse

signal fire_started()
signal fire_extinguished()
signal item_cooked(item_id: String)

## Estado
var is_lit: bool = false
var fuel_remaining: float = 0.0
var max_fuel: float = 300.0  # 5 minutos
var fuel_consumption_rate: float = 1.0  # Puntos por segundo

## Cooking
var cooking_slots: Array[Dictionary] = []  # {item_id, cook_time, time_remaining}
const MAX_COOKING_SLOTS: int = 4
const COOK_TIME_MULTIPLIER: float = 1.0

## Componentes visuales
var fire_particles: GPUParticles3D
var light_source: OmniLight3D
var smoke_particles: GPUParticles3D
var heat_area: Area3D

## Modelo 3D
var model_root: Node3D

func _ready() -> void:
	_create_campfire_model()
	_setup_fire_effects()
	_setup_heat_area()

func _process(delta: float) -> void:
	if is_lit:
		# Consumir combustible
		fuel_remaining -= fuel_consumption_rate * delta

		if fuel_remaining <= 0:
			extinguish_fire()
		else:
			# Actualizar cocción
			_update_cooking(delta)

			# Actualizar efectos visuales
			_update_fire_effects()

## ============================================================================
## MODELO 3D
## ============================================================================

func _create_campfire_model() -> void:
	model_root = Node3D.new()
	model_root.name = "CampfireModel"
	add_child(model_root)

	# Base de piedras
	var stone_circle_count = 8
	var circle_radius = 0.6
	for i in range(stone_circle_count):
		var angle = (PI * 2.0 / stone_circle_count) * i
		var stone = _create_stone()
		stone.position = Vector3(
			cos(angle) * circle_radius,
			0.15,
			sin(angle) * circle_radius
		)
		stone.rotation.y = angle
		model_root.add_child(stone)

	# Troncos de madera (cuando no está encendida)
	var log1 = _create_log()
	log1.position = Vector3(0, 0.1, 0)
	log1.rotation.z = deg_to_rad(90)
	model_root.add_child(log1)

	var log2 = _create_log()
	log2.position = Vector3(0, 0.15, 0)
	log2.rotation.x = deg_to_rad(90)
	model_root.add_child(log2)

	# Parrilla de cocina (opcional, aparece al encender)
	var grill = _create_grill()
	grill.name = "Grill"
	grill.position = Vector3(0, 0.5, 0)
	grill.visible = false
	model_root.add_child(grill)

func _create_stone() -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(0.3, 0.25, 0.2)
	mesh_instance.mesh = box

	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.4, 0.4, 0.45)
	mat.roughness = 0.9
	mesh_instance.set_surface_override_material(0, mat)

	return mesh_instance

func _create_log() -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.height = 0.8
	cylinder.top_radius = 0.08
	cylinder.bottom_radius = 0.08
	mesh_instance.mesh = cylinder

	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.35, 0.25, 0.15)
	mat.roughness = 0.8
	mesh_instance.set_surface_override_material(0, mat)

	return mesh_instance

func _create_grill() -> Node3D:
	var grill_node = Node3D.new()

	# Barras de parrilla
	for i in range(5):
		var bar = MeshInstance3D.new()
		var cylinder = CylinderMesh.new()
		cylinder.height = 0.8
		cylinder.top_radius = 0.02
		cylinder.bottom_radius = 0.02
		bar.mesh = cylinder

		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.2, 0.2, 0.2)
		mat.metallic = 0.8
		bar.set_surface_override_material(0, mat)

		bar.rotation.z = deg_to_rad(90)
		bar.position.z = -0.3 + (i * 0.15)
		grill_node.add_child(bar)

	return grill_node

## ============================================================================
## EFECTOS DE FUEGO
## ============================================================================

func _setup_fire_effects() -> void:
	# Partículas de fuego
	fire_particles = GPUParticles3D.new()
	fire_particles.name = "FireParticles"
	fire_particles.emitting = false
	fire_particles.amount = 50
	fire_particles.lifetime = 1.0
	fire_particles.explosiveness = 0.1

	# Material de partículas
	var particle_mat = ParticleProcessMaterial.new()
	particle_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	particle_mat.emission_sphere_radius = 0.3
	particle_mat.direction = Vector3(0, 1, 0)
	particle_mat.spread = 25.0
	particle_mat.gravity = Vector3(0, 1, 0)  # Fuego sube
	particle_mat.initial_velocity_min = 0.5
	particle_mat.initial_velocity_max = 1.5
	particle_mat.scale_min = 0.1
	particle_mat.scale_max = 0.3

	# Color del fuego (naranja a rojo)
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1.0, 0.8, 0.2, 1.0))  # Amarillo
	gradient.add_point(0.5, Color(1.0, 0.3, 0.1, 0.8))  # Naranja
	gradient.add_point(1.0, Color(0.3, 0.1, 0.1, 0.0))  # Rojo oscuro (fade)

	particle_mat.color_ramp = gradient
	fire_particles.process_material = particle_mat

	add_child(fire_particles)

	# Luz del fuego
	light_source = OmniLight3D.new()
	light_source.name = "FireLight"
	light_source.light_color = Color(1.0, 0.6, 0.2)
	light_source.light_energy = 0.0
	light_source.omni_range = 8.0
	light_source.omni_attenuation = 2.0
	add_child(light_source)

	# Partículas de humo
	smoke_particles = GPUParticles3D.new()
	smoke_particles.name = "SmokeParticles"
	smoke_particles.emitting = false
	smoke_particles.amount = 30
	smoke_particles.lifetime = 3.0

	var smoke_mat = ParticleProcessMaterial.new()
	smoke_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	smoke_mat.emission_sphere_radius = 0.2
	smoke_mat.direction = Vector3(0, 1, 0)
	smoke_mat.spread = 15.0
	smoke_mat.gravity = Vector3(0, 0.5, 0)
	smoke_mat.initial_velocity_min = 0.3
	smoke_mat.initial_velocity_max = 0.8
	smoke_mat.scale_min = 0.2
	smoke_mat.scale_max = 0.6

	# Color del humo (gris)
	var smoke_gradient = Gradient.new()
	smoke_gradient.add_point(0.0, Color(0.3, 0.3, 0.3, 0.5))
	smoke_gradient.add_point(1.0, Color(0.2, 0.2, 0.2, 0.0))

	smoke_mat.color_ramp = smoke_gradient
	smoke_particles.process_material = smoke_mat

	add_child(smoke_particles)

func _setup_heat_area() -> void:
	# Área de calor que afecta al jugador
	heat_area = Area3D.new()
	heat_area.name = "HeatArea"

	var collision = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 3.0
	collision.shape = sphere

	heat_area.add_child(collision)
	add_child(heat_area)

	# Conectar señales
	heat_area.body_entered.connect(_on_body_entered_heat_area)
	heat_area.body_exited.connect(_on_body_exited_heat_area)

func _on_body_entered_heat_area(body: Node3D) -> void:
	if is_lit and body.has_method("get") and body.get("is_player"):
		if SurvivalSystem:
			SurvivalSystem.set_near_heat_source(true)

func _on_body_exited_heat_area(body: Node3D) -> void:
	if body.has_method("get") and body.get("is_player"):
		if SurvivalSystem:
			SurvivalSystem.set_near_heat_source(false)

func _update_fire_effects() -> void:
	# Flicker de la luz
	var flicker = randf_range(0.9, 1.1)
	light_source.light_energy = 2.0 * flicker * (fuel_remaining / max_fuel)

	# Intensidad de partículas según combustible
	var intensity = fuel_remaining / max_fuel
	fire_particles.amount_ratio = intensity

## ============================================================================
## CONTROL DE FUEGO
## ============================================================================

## Encender fuego
func light_fire(fuel_amount: float = 100.0) -> bool:
	if is_lit:
		# Ya está encendida, solo agregar combustible
		add_fuel(fuel_amount)
		return true

	# Verificar que haya combustible
	if fuel_amount <= 0:
		print("❌ No hay combustible para encender el fuego")
		return false

	is_lit = true
	fuel_remaining = fuel_amount

	# Activar efectos
	fire_particles.emitting = true
	smoke_particles.emitting = true
	light_source.light_energy = 2.0

	# Mostrar parrilla
	var grill = model_root.get_node_or_null("Grill")
	if grill:
		grill.visible = true

	fire_started.emit()
	print("🔥 Fuego encendido")

	# Notificar a QuestSystem
	if QuestSystem:
		QuestSystem.notify_built("campfire")

	return true

## Apagar fuego
func extinguish_fire() -> void:
	if not is_lit:
		return

	is_lit = false
	fuel_remaining = 0.0

	# Desactivar efectos
	fire_particles.emitting = false
	smoke_particles.emitting = true  # Humo continúa por un momento
	light_source.light_energy = 0.0

	# Ocultar parrilla
	var grill = model_root.get_node_or_null("Grill")
	if grill:
		grill.visible = false

	# Cancelar todas las cocciones
	cooking_slots.clear()

	fire_extinguished.emit()
	print("💨 Fuego apagado")

## Agregar combustible
func add_fuel(amount: float) -> void:
	fuel_remaining = min(max_fuel, fuel_remaining + amount)
	print("➕ Combustible agregado: ", amount, " (Total: ", fuel_remaining, ")")

## ============================================================================
## COCINA
## ============================================================================

## Cocinar item
func cook_item(item_id: String) -> bool:
	if not is_lit:
		print("❌ El fuego no está encendido")
		return false

	if cooking_slots.size() >= MAX_COOKING_SLOTS:
		print("❌ Todos los slots de cocción están ocupados")
		return false

	var recipe = _get_cooking_recipe(item_id)
	if not recipe:
		print("❌ No se puede cocinar: ", item_id)
		return false

	# Agregar a slot de cocción
	cooking_slots.append({
		"input_item": item_id,
		"output_item": recipe.output,
		"cook_time": recipe.cook_time * COOK_TIME_MULTIPLIER,
		"time_remaining": recipe.cook_time * COOK_TIME_MULTIPLIER
	})

	print("🍳 Cocinando: ", item_id, " → ", recipe.output)
	return true

func _update_cooking(delta: float) -> void:
	for i in range(cooking_slots.size() - 1, -1, -1):
		var slot = cooking_slots[i]
		slot.time_remaining -= delta

		if slot.time_remaining <= 0:
			# Cocción completada
			_finish_cooking(slot)
			cooking_slots.remove_at(i)

func _finish_cooking(slot: Dictionary) -> void:
	var output_item = slot.output_item
	print("✅ Cocción completada: ", output_item)

	# Agregar item al inventario
	if InventorySystem:
		InventorySystem.add_item(output_item, 1)

	# Notificar a QuestSystem
	if QuestSystem:
		QuestSystem.notify_item_crafted(output_item, 1)

	item_cooked.emit(output_item)

func _get_cooking_recipe(input_item: String) -> Dictionary:
	var recipes = {
		# Carnes
		"raw_meat": {"output": "cooked_meat", "cook_time": 10.0},
		"raw_chicken": {"output": "cooked_chicken", "cook_time": 8.0},
		"raw_fish": {"output": "cooked_fish", "cook_time": 6.0},

		# Vegetales
		"potato": {"output": "baked_potato", "cook_time": 5.0},
		"corn": {"output": "roasted_corn", "cook_time": 5.0},

		# Agua
		"dirty_water": {"output": "clean_water", "cook_time": 15.0}
	}

	return recipes.get(input_item, {})

## Obtener recetas disponibles
func get_available_recipes() -> Array:
	return [
		"raw_meat", "raw_chicken", "raw_fish",
		"potato", "corn", "dirty_water"
	]

## ============================================================================
## INTERACCIÓN
## ============================================================================

## Interactuar con la hoguera
func interact(_player: Node3D) -> void:
	if not is_lit:
		# Intentar encender
		# TODO: Verificar que el jugador tenga materiales (madera, etc.)
		light_fire(100.0)
	else:
		# Mostrar menú de cocina
		print("🔥 Hoguera encendida (", fuel_remaining, " combustible)")
		print("   Slots de cocción: ", cooking_slots.size(), "/", MAX_COOKING_SLOTS)
		# TODO: Abrir UI de cocina

## Obtener info de estado
func get_state_info() -> String:
	if is_lit:
		return "Encendida (%.0f%% combustible)" % ((fuel_remaining / max_fuel) * 100.0)
	else:
		return "Apagada"
