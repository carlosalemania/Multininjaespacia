# ============================================================================
# NPC.gd - Non-Player Character
# ============================================================================
# Aldeano interactivo con diálogos y misiones
# ============================================================================

extends CharacterBody3D
class_name NPC

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SEÑALES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Emitida cuando el jugador interactúa con el NPC
signal npc_interacted(npc: NPC)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES EXPORTADAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Tipo de NPC
@export var npc_type: NPCData.NPCType = NPCData.NPCType.VILLAGER_BASIC

## ¿El NPC se mueve?
@export var can_wander: bool = false

## Radio de movimiento (si puede moverse)
@export var wander_radius: float = 5.0

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# NODOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var visual_mesh: MeshInstance3D = $VisualMesh
@onready var interaction_area: Area3D = $InteractionArea
@onready var name_label_3d: Label3D = $NameLabel3D
@onready var quest_indicator: MeshInstance3D = $QuestIndicator

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Datos del NPC (desde NPCData)
var npc_data: Dictionary = {}

## Nombre del NPC
var npc_name: String = ""

## ¿El jugador está cerca?
var player_in_range: bool = false

## Posición inicial (para wander)
var spawn_position: Vector3 = Vector3.ZERO

## Timer para cambio de dirección (wander)
var wander_timer: float = 0.0

## Dirección actual de movimiento
var wander_direction: Vector3 = Vector3.ZERO

## Tiempo de espera entre movimientos
const WANDER_INTERVAL: float = 3.0

## Velocidad de movimiento
const MOVE_SPEED: float = 1.5

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	# Obtener datos del NPC
	npc_data = NPCData.get_npc_data(npc_type)
	npc_name = NPCData.get_npc_name(npc_type)

	# Configurar visual
	_setup_visual()

	# Configurar área de interacción
	_setup_interaction_area()

	# Guardar posición inicial
	spawn_position = global_position

	print("🧍 NPC creado: ", npc_name, " en ", global_position)


func _physics_process(delta: float) -> void:
	# Movimiento de vagabundeo
	if can_wander and not player_in_range:
		_handle_wander(delta)

	# Aplicar gravedad
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	move_and_slide()

	# Actualizar indicador de misión
	_update_quest_indicator()

	# Hacer que el label mire siempre a la cámara
	if name_label_3d and GameManager.player:
		var camera_pos = GameManager.player.get_camera_position()
		name_label_3d.look_at(camera_pos, Vector3.UP)


func _input(event: InputEvent) -> void:
	# Interactuar con E cuando el jugador está cerca
	if event.is_action_pressed("interact") and player_in_range:
		interact()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PÚBLICOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Interactuar con el NPC
func interact() -> void:
	print("💬 Interactuando con: ", npc_name)
	npc_interacted.emit(self)
	AudioManager.play_sfx(Enums.SoundType.UI_CLICK)


## Obtiene el saludo del NPC
func get_greeting() -> String:
	return NPCData.get_greeting(npc_type)


## Obtiene un diálogo aleatorio
func get_dialogue() -> String:
	return NPCData.get_random_dialogue(npc_type)


## Obtiene las misiones del NPC
func get_quests() -> Array:
	return NPCData.get_npc_quests(npc_type)


## Verifica si el NPC tiene misiones disponibles
func has_available_quests() -> bool:
	var quests = get_quests()
	for quest_id in quests:
		if not QuestSystem.is_quest_completed(quest_id):
			return true
	return false


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PRIVADOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Configura el visual del NPC
func _setup_visual() -> void:
	if not visual_mesh:
		return

	# Crear material con color del NPC
	var material = StandardMaterial3D.new()
	material.albedo_color = NPCData.get_npc_color(npc_type)
	material.emission_enabled = true
	material.emission = material.albedo_color * 0.3
	visual_mesh.material_override = material

	# Configurar label con nombre
	if name_label_3d:
		name_label_3d.text = npc_name
		name_label_3d.modulate = Color.WHITE
		name_label_3d.outline_modulate = Color.BLACK
		name_label_3d.outline_size = 4


## Configura el área de interacción
func _setup_interaction_area() -> void:
	if not interaction_area:
		return

	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)


## Maneja el movimiento de vagabundeo
func _handle_wander(delta: float) -> void:
	wander_timer += delta

	# Cambiar dirección cada X segundos
	if wander_timer >= WANDER_INTERVAL:
		wander_timer = 0.0
		_choose_new_wander_direction()

	# Mover en la dirección actual
	if wander_direction != Vector3.ZERO:
		velocity.x = wander_direction.x * MOVE_SPEED
		velocity.z = wander_direction.z * MOVE_SPEED

		# Rotar hacia la dirección de movimiento
		var look_direction = Vector3(wander_direction.x, 0, wander_direction.z)
		if look_direction.length() > 0.1:
			look_at(global_position + look_direction, Vector3.UP)


## Elige una nueva dirección de vagabundeo
func _choose_new_wander_direction() -> void:
	# Verificar si está muy lejos del spawn
	var distance_from_spawn = global_position.distance_to(spawn_position)

	if distance_from_spawn > wander_radius:
		# Volver hacia el spawn
		wander_direction = (spawn_position - global_position).normalized()
	else:
		# Dirección aleatoria o quedarse quieto
		if randf() < 0.3:
			wander_direction = Vector3.ZERO  # Quedarse quieto
		else:
			var angle = randf() * TAU
			wander_direction = Vector3(cos(angle), 0, sin(angle)).normalized()


## Actualiza el indicador de misión (! sobre la cabeza)
func _update_quest_indicator() -> void:
	if not quest_indicator:
		return

	# Mostrar si tiene misiones disponibles
	quest_indicator.visible = has_available_quests()

	# Hacer que mire siempre a la cámara
	if quest_indicator.visible and GameManager.player:
		var camera_pos = GameManager.player.get_camera_position()
		quest_indicator.look_at(camera_pos, Vector3.UP)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SEÑALES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		print("👋 Jugador cerca de ", npc_name)


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		print("👋 Jugador lejos de ", npc_name)
