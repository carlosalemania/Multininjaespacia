# ============================================================================
# Player.gd - Controlador Principal del Jugador
# ============================================================================
# CharacterBody3D que integra movimiento, cámara e interacción con bloques
# ============================================================================

extends CharacterBody3D

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# COMPONENTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@onready var movement: Node = $PlayerMovement
@onready var camera_controller: Node = $CameraController
@onready var interaction: Node = $PlayerInteraction
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## ¿El jugador puede moverse?
var can_move: bool = true

## ¿La cámara puede rotar?
var can_look: bool = true

## Referencia al mundo actual
var world: Node = null

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	# Registrar jugador en GameManager
	GameManager.player = self

	# Configurar posición inicial desde PlayerData
	global_position = PlayerData.get_position()

	print("🎮 Player inicializado en posición: ", global_position)

	# Conectar señales de pausa
	GameManager.game_paused.connect(_on_game_paused)
	GameManager.game_resumed.connect(_on_game_resumed)


func _physics_process(_delta: float) -> void:
	# Guardar posición actual en PlayerData
	PlayerData.update_position(global_position)


func _input(event: InputEvent) -> void:
	# Manejar pausa
	if event.is_action_pressed("ui_cancel"):
		GameManager.toggle_pause()

	# Cambiar slots del inventario (1-9)
	for i in range(1, 10):
		if event.is_action_pressed("slot_" + str(i)):
			PlayerData.set_active_slot(i - 1)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PÚBLICOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Teletransporta al jugador a una posición
func teleport_to(new_position: Vector3) -> void:
	global_position = new_position
	PlayerData.update_position(new_position)
	print("🎯 Jugador teletransportado a: ", new_position)


## Obtiene la posición de la cámara
func get_camera_position() -> Vector3:
	if camera_controller and camera_controller.has_method("get_camera_position"):
		return camera_controller.get_camera_position()
	return global_position


## Obtiene la dirección hacia donde mira la cámara
func get_look_direction() -> Vector3:
	if camera_controller and camera_controller.has_method("get_look_direction"):
		return camera_controller.get_look_direction()
	return -global_transform.basis.z


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SEÑALES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _on_game_paused() -> void:
	can_move = false
	can_look = false

	# Liberar mouse
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_game_resumed() -> void:
	can_move = true
	can_look = true

	# Capturar mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
