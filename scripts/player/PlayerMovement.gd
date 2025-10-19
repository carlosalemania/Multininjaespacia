# ============================================================================
# PlayerMovement.gd - Movimiento del Jugador (WASD + Jump)
# ============================================================================
# Componente que maneja movimiento horizontal, salto y gravedad
# ============================================================================

extends Node

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Referencia al CharacterBody3D padre
@onready var player: CharacterBody3D = get_parent()

## Velocidad de movimiento
var speed: float = Constants.PLAYER_SPEED

## Fuerza de salto
var jump_force: float = Constants.JUMP_FORCE

## Gravedad
var gravity: float = Constants.GRAVITY

## Velocidad vertical actual
var vertical_velocity: float = 0.0

## ¿Está en el suelo?
var is_grounded: bool = false

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	print("🏃 PlayerMovement inicializado")


func _physics_process(delta: float) -> void:
	# No mover si está pausado o deshabilitado
	if not player.can_move or GameManager.is_paused:
		return

	# Actualizar estado de suelo
	is_grounded = player.is_on_floor()

	# Manejar movimiento horizontal
	_handle_horizontal_movement(delta)

	# Manejar salto y gravedad
	_handle_vertical_movement(delta)

	# Aplicar velocidad al CharacterBody3D
	player.velocity = Vector3(
		player.velocity.x,
		vertical_velocity,
		player.velocity.z
	)

	# Mover y deslizar
	player.move_and_slide()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PRIVADOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Maneja el movimiento horizontal (WASD)
func _handle_horizontal_movement(delta: float) -> void:
	# Obtener input del jugador
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	# Obtener la dirección de la cámara (solo en plano XZ)
	var camera_forward = player.get_look_direction()
	camera_forward.y = 0
	camera_forward = camera_forward.normalized()

	var camera_right = camera_forward.cross(Vector3.UP).normalized()

	# Calcular dirección de movimiento relativa a la cámara
	var move_direction = (camera_forward * -input_dir.y + camera_right * input_dir.x).normalized()

	# Aplicar velocidad horizontal
	if move_direction.length() > 0:
		player.velocity.x = move_direction.x * speed
		player.velocity.z = move_direction.z * speed
	else:
		# Fricción (frenar gradualmente)
		player.velocity.x = lerp(player.velocity.x, 0.0, 10.0 * delta)
		player.velocity.z = lerp(player.velocity.z, 0.0, 10.0 * delta)


## Maneja el salto y la gravedad
func _handle_vertical_movement(delta: float) -> void:
	# Aplicar gravedad
	if not is_grounded:
		vertical_velocity -= gravity * delta
	else:
		# En el suelo, resetear velocidad vertical
		vertical_velocity = -0.1  # Pequeño valor para mantenerlo pegado al suelo

		# Manejar salto
		if Input.is_action_just_pressed("jump"):
			vertical_velocity = jump_force
			AudioManager.play_sfx(Enums.SoundType.BUTTON_CLICK)  # Placeholder sound

	# Limitar velocidad de caída
	vertical_velocity = max(vertical_velocity, -50.0)
