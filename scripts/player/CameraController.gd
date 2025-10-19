# ============================================================================
# CameraController.gd - Control de Cámara First-Person
# ============================================================================
# Componente que maneja la rotación de la cámara con el mouse
# ============================================================================

extends Node3D

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Referencia al jugador
@onready var player: CharacterBody3D = get_parent()

## Cámara 3D
@onready var camera: Camera3D = $Camera3D

## Sensibilidad del mouse
@export var mouse_sensitivity: float = 0.002

## Límite de rotación vertical (radianes)
@export var pitch_limit: float = deg_to_rad(89.0)

## Rotación vertical actual (pitch)
var pitch: float = 0.0

## Rotación horizontal (yaw) - controlada por el padre (Player)
var yaw: float = 0.0

## FOV (Field of View) de la cámara
@export var fov: float = 75.0

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	# Capturar el mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Configurar FOV
	if camera:
		camera.fov = fov

	print("📷 CameraController inicializado")


func _input(event: InputEvent) -> void:
	# Solo rotar si puede mirar y el mouse está capturado
	if not player.can_look or GameManager.is_paused:
		return

	if event is InputEventMouseMotion:
		_handle_mouse_motion(event)


func _physics_process(_delta: float) -> void:
	# Aplicar rotación vertical a este nodo (pitch)
	rotation.x = pitch

	# La rotación horizontal (yaw) se aplica al jugador, no a la cámara


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PÚBLICOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Obtiene la posición de la cámara en el mundo
func get_camera_position() -> Vector3:
	if camera:
		return camera.global_position
	return global_position


## Obtiene la dirección hacia donde mira la cámara
func get_look_direction() -> Vector3:
	if camera:
		return -camera.global_transform.basis.z
	return -global_transform.basis.z


## Cambia la sensibilidad del mouse
func set_mouse_sensitivity(sensitivity: float) -> void:
	mouse_sensitivity = clamp(sensitivity, 0.0001, 0.01)


## Cambia el FOV de la cámara
func set_fov(new_fov: float) -> void:
	fov = clamp(new_fov, 60.0, 120.0)
	if camera:
		camera.fov = fov


## Resetea la rotación de la cámara
func reset_rotation() -> void:
	pitch = 0.0
	yaw = 0.0
	rotation = Vector3.ZERO
	player.rotation.y = 0.0


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PRIVADOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Maneja el movimiento del mouse para rotar la cámara
func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	# Rotación horizontal (yaw) - rotar el jugador en Y
	yaw -= event.relative.x * mouse_sensitivity
	player.rotation.y = yaw

	# Rotación vertical (pitch) - rotar este nodo en X
	pitch -= event.relative.y * mouse_sensitivity
	pitch = clamp(pitch, -pitch_limit, pitch_limit)
