# ============================================================================
# NPC.gd - Personajes No Jugables
# ============================================================================
# NPCs que dan misiones, consejos y recompensas
# ============================================================================

extends CharacterBody3D
class_name NPC

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TIPOS DE NPC
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum NPCType {
	ALDEANO,    ## Da misiones simples
	SABIO,      ## Enseña construcciones
	COMERCIANTE ## Intercambia recursos (futuro)
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@export var npc_type: NPCType = NPCType.ALDEANO
@export var npc_name: String = "Aldeano"
@export var interaction_range: float = 3.0

## Colores por tipo de NPC
const NPC_COLORS: Dictionary = {
	NPCType.ALDEANO: Color(0.2, 0.6, 0.2),     # Verde
	NPCType.SABIO: Color(0.5, 0.3, 0.8),       # Púrpura
	NPCType.COMERCIANTE: Color(0.8, 0.6, 0.2)  # Dorado
}

## Diálogos por tipo
const NPC_DIALOGUES: Dictionary = {
	NPCType.ALDEANO: [
		"¡Hola, constructor! ¿Necesitas una misión?",
		"Construye 20 bloques y te daré una recompensa.",
		"¡Que la Luz Interior te guíe!"
	],
	NPCType.SABIO: [
		"Bienvenido, aprendiz. Observa y aprende.",
		"Las grandes construcciones empiezan con un solo bloque.",
		"La paciencia es la virtud del constructor sabio."
	]
}

## Misiones disponibles
var available_missions: Array[Dictionary] = []
var current_mission: Dictionary = {}

## ¿El jugador está en rango?
var player_in_range: bool = false
var player_ref: Node3D = null

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# COMPONENTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var interaction_area: Area3D = $InteractionArea

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	_setup_visuals()
	_setup_missions()

	# Conectar señales del área de interacción
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	# Mirar al jugador si está cerca
	if player_in_range and player_ref:
		var direction = (player_ref.global_position - global_position).normalized()
		if direction.length() > 0.1:
			look_at(global_position + Vector3(direction.x, 0, direction.z), Vector3.UP)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PÚBLICOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Interactuar con el NPC
func interact() -> void:
	if npc_type == NPCType.ALDEANO:
		_aldeano_interaction()
	elif npc_type == NPCType.SABIO:
		_sabio_interaction()

	print("💬 ", npc_name, ": ", _get_random_dialogue())


## Obtiene un diálogo aleatorio
func _get_random_dialogue() -> String:
	var dialogues = NPC_DIALOGUES.get(npc_type, ["..."])
	return dialogues[randi() % dialogues.size()]


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PRIVADOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Configura la apariencia del NPC
func _setup_visuals() -> void:
	# Crear mesh (cubo simple como cuerpo)
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.6, 1.8, 0.4)

	if mesh_instance:
		mesh_instance.mesh = box_mesh

		# Material con color del tipo de NPC
		var material = StandardMaterial3D.new()
		material.albedo_color = NPC_COLORS.get(npc_type, Color.WHITE)
		mesh_instance.set_surface_override_material(0, material)

	# Collision shape
	if collision_shape:
		var shape = BoxShape3D.new()
		shape.size = Vector3(0.6, 1.8, 0.4)
		collision_shape.shape = shape


## Configura las misiones del NPC
func _setup_missions() -> void:
	if npc_type == NPCType.ALDEANO:
		available_missions = [
			{
				"title": "Constructor Novato",
				"description": "Construye 20 bloques",
				"type": "build",
				"target": 20,
				"reward_luz": 25
			},
			{
				"title": "Recolector",
				"description": "Recolecta 30 bloques",
				"type": "collect",
				"target": 30,
				"reward_luz": 20
			}
		]
	elif npc_type == NPCType.SABIO:
		available_missions = [
			{
				"title": "Torre del Conocimiento",
				"description": "Construye una torre de 15 bloques de altura",
				"type": "build_height",
				"target": 15,
				"reward_luz": 50
			}
		]


## Interacción con aldeano
func _aldeano_interaction() -> void:
	if current_mission.is_empty() and available_missions.size() > 0:
		# Asignar misión aleatoria
		current_mission = available_missions[randi() % available_missions.size()]
		print("📜 Misión asignada: ", current_mission.title)
		print("   ", current_mission.description)
		print("   Recompensa: +", current_mission.reward_luz, " Luz")
	elif not current_mission.is_empty():
		print("📜 Misión activa: ", current_mission.title)


## Interacción con sabio
func _sabio_interaction() -> void:
	# El sabio da consejos de construcción
	var tips = [
		"Construye una base sólida antes de subir en altura.",
		"Los bloques de piedra son más resistentes.",
		"Una torre de 10 bloques te dará mejor vista.",
		"Practica construyendo en diferentes formas."
	]
	print("🧙 Consejo del Sabio: ", tips[randi() % tips.size()])


## Cuando un cuerpo entra al área de interacción
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		player_ref = body
		print("💡 Presiona E para hablar con ", npc_name)


## Cuando un cuerpo sale del área de interacción
func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		player_ref = null
