extends CharacterBody3D
class_name Animal
## Entidad de animal con IA básica y comportamiento

enum AnimalType {
	SHEEP,      # Oveja
	COW,        # Vaca
	CHICKEN,    # Gallina
	RABBIT,     # Conejo
	DEER,       # Venado
	BIRD        # Pájaro
}

enum BehaviorState {
	IDLE,       # Quieto
	WANDERING,  # Caminando aleatoriamente
	GRAZING,    # Comiendo
	FLEEING,    # Huyendo del jugador
	SLEEPING    # Durmiendo (noche)
}

@export var animal_type: AnimalType = AnimalType.SHEEP
@export var animal_name: String = "Animal"

## Comportamiento actual
var current_state: BehaviorState = BehaviorState.IDLE

## Velocidad de movimiento
var move_speed: float = 1.5

## Rango de detección del jugador
var detection_range: float = 8.0

## Si el animal huye del jugador
var is_scared: bool = false

## Tiempo acumulado para cambiar de estado
var state_timer: float = 0.0
var state_duration: float = 3.0

## Dirección de movimiento aleatorio
var wander_direction: Vector3 = Vector3.ZERO

## Punto de spawn (para no alejarse mucho)
var spawn_point: Vector3 = Vector3.ZERO

## Modelo 3D del animal
var model: Node3D

## Nodo de animación (para idle breathing, etc)
var animation_offset: float = 0.0

func _ready() -> void:
	spawn_point = global_position

	# Crear modelo según tipo
	_create_animal_model()

	# Configurar física
	_setup_physics()

	# Iniciar con estado aleatorio
	var states = [BehaviorState.IDLE, BehaviorState.WANDER, BehaviorState.GRAZE]
	_change_state(states[randi() % states.size()])

	print("🐑 Animal spawneado: ", animal_name, " (", AnimalType.keys()[animal_type], ")")

func _physics_process(delta: float) -> void:
	animation_offset += delta
	_update_behavior(delta)
	_update_animation()

	# Aplicar gravedad
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	move_and_slide()

## Actualizar comportamiento según estado
func _update_behavior(delta: float) -> void:
	state_timer += delta

	# Detectar jugador cercano
	var player_nearby = _check_player_nearby()

	# Si el animal es asustadizo y hay jugador cerca, huir
	if is_scared and player_nearby:
		if current_state != BehaviorState.FLEEING:
			_change_state(BehaviorState.FLEEING)

	# Cambiar de estado después de un tiempo
	if state_timer >= state_duration:
		_change_random_state()

	# Ejecutar lógica del estado actual
	match current_state:
		BehaviorState.IDLE:
			velocity.x = 0
			velocity.z = 0

		BehaviorState.WANDERING:
			_wander(delta)

		BehaviorState.GRAZING:
			_graze(delta)

		BehaviorState.FLEEING:
			_flee(delta, player_nearby)

		BehaviorState.SLEEPING:
			velocity.x = 0
			velocity.z = 0

## Cambiar a estado aleatorio
func _change_random_state() -> void:
	var states = [BehaviorState.IDLE, BehaviorState.WANDERING, BehaviorState.GRAZING]
	var new_state = states.pick_random()
	_change_state(new_state)

## Cambiar estado
func _change_state(new_state: BehaviorState) -> void:
	current_state = new_state
	state_timer = 0.0
	state_duration = randf_range(3.0, 8.0)

	match new_state:
		BehaviorState.WANDERING:
			_pick_random_wander_direction()

## Caminar aleatoriamente
func _wander(delta: float) -> void:
	# Caminar en dirección aleatoria
	velocity.x = wander_direction.x * move_speed
	velocity.z = wander_direction.z * move_speed

	# No alejarse mucho del punto de spawn
	var distance_from_spawn = global_position.distance_to(spawn_point)
	if distance_from_spawn > 15.0:
		# Regresar hacia el spawn
		var direction_to_spawn = (spawn_point - global_position).normalized()
		wander_direction = direction_to_spawn
		velocity.x = direction_to_spawn.x * move_speed
		velocity.z = direction_to_spawn.z * move_speed

	# Rotar hacia dirección de movimiento
	if wander_direction.length() > 0.1:
		var target_rotation = atan2(wander_direction.x, wander_direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, delta * 3.0)

## Pastar (comer)
func _graze(_delta: float) -> void:
	velocity.x = 0
	velocity.z = 0
	# Animación de comer (bajar/subir cabeza) se maneja en _update_animation

## Huir del jugador
func _flee(delta: float, player_pos: Variant) -> void:
	if player_pos == null:
		_change_state(BehaviorState.IDLE)
		return

	# Huir en dirección opuesta al jugador
	var flee_direction = (global_position - player_pos).normalized()
	velocity.x = flee_direction.x * move_speed * 2.0  # Más rápido al huir
	velocity.z = flee_direction.z * move_speed * 2.0

	# Rotar alejándose del jugador
	var target_rotation = atan2(flee_direction.x, flee_direction.z)
	rotation.y = lerp_angle(rotation.y, target_rotation, delta * 5.0)

	# Dejar de huir si el jugador está lejos
	if global_position.distance_to(player_pos) > detection_range * 1.5:
		_change_state(BehaviorState.IDLE)

## Elegir dirección aleatoria para caminar
func _pick_random_wander_direction() -> void:
	var angle = randf() * TAU  # Ángulo aleatorio
	wander_direction = Vector3(sin(angle), 0, cos(angle)).normalized()

## Verificar si el jugador está cerca
func _check_player_nearby() -> Variant:
	# Buscar nodo del jugador
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return null

	var distance = global_position.distance_to(player.global_position)
	if distance < detection_range:
		return player.global_position

	return null

## Actualizar animación (breathing idle, etc)
func _update_animation() -> void:
	if model == null:
		return

	# Respiración suave (idle breathing)
	var breath_offset = sin(animation_offset * 2.0) * 0.02
	model.scale.y = 1.0 + breath_offset

	# Si está comiendo, animar cabeza
	if current_state == BehaviorState.GRAZING:
		var graze_offset = abs(sin(animation_offset * 4.0)) * 0.1
		if model.has_node("Head"):
			model.get_node("Head").position.y = 0.4 - graze_offset

## Configurar física
func _setup_physics() -> void:
	# Collider
	var collision_shape = CollisionShape3D.new()
	var capsule = CapsuleShape3D.new()

	match animal_type:
		AnimalType.SHEEP, AnimalType.COW:
			capsule.radius = 0.4
			capsule.height = 0.8
			move_speed = 1.2
			is_scared = true

		AnimalType.CHICKEN:
			capsule.radius = 0.2
			capsule.height = 0.4
			move_speed = 2.0
			is_scared = true

		AnimalType.RABBIT:
			capsule.radius = 0.25
			capsule.height = 0.3
			move_speed = 3.0
			is_scared = true
			detection_range = 10.0

		AnimalType.DEER:
			capsule.radius = 0.5
			capsule.height = 1.2
			move_speed = 2.5
			is_scared = true
			detection_range = 12.0

		AnimalType.BIRD:
			capsule.radius = 0.15
			capsule.height = 0.3
			move_speed = 4.0
			is_scared = true

	collision_shape.shape = capsule
	add_child(collision_shape)

## Crear modelo del animal
func _create_animal_model() -> void:
	match animal_type:
		AnimalType.SHEEP:
			model = AnimalModelGenerator.create_sheep()
		AnimalType.COW:
			model = AnimalModelGenerator.create_cow()
		AnimalType.CHICKEN:
			model = AnimalModelGenerator.create_chicken()
		AnimalType.RABBIT:
			model = AnimalModelGenerator.create_rabbit()
		AnimalType.DEER:
			model = AnimalModelGenerator.create_deer()
		AnimalType.BIRD:
			model = AnimalModelGenerator.create_bird()

	if model:
		add_child(model)

## Interactuar con el animal (acariciar, alimentar)
func interact() -> void:
	print("🐑 Interactuando con ", animal_name)

	# Efecto de corazones (partículas)
	_spawn_heart_particles()

	# Recompensa de Luz
	if VirtueSystem:
		VirtueSystem.add_luz_manual(3, "Interacción con animal")

## Spawear partículas de corazón
func _spawn_heart_particles() -> void:
	# TODO: Implementar partículas de corazón
	print("💚 Corazones!")
