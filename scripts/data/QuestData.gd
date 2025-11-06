extends Resource
class_name QuestData
## Datos de una misión/quest

enum QuestType {
	MAIN,           # Misión principal
	SIDE,           # Misión secundaria
	DAILY,          # Misión diaria
	TUTORIAL,       # Misión de tutorial
	REPEATABLE      # Misión repetible
}

enum QuestStatus {
	LOCKED,         # No disponible aún
	AVAILABLE,      # Disponible para aceptar
	ACTIVE,         # Activa/en progreso
	COMPLETED,      # Completada
	FAILED          # Fallada
}

enum ObjectiveType {
	COLLECT,        # Recolectar items
	KILL,           # Matar enemigos
	CRAFT,          # Craftear items
	BUILD,          # Construir estructuras
	TALK,           # Hablar con NPC
	EXPLORE,        # Explorar ubicación
	SURVIVE,        # Sobrevivir X tiempo
	DELIVER         # Entregar items
}

## Identificación
@export var quest_id: String = ""
@export var quest_name: String = ""
@export var description: String = ""
@export var quest_type: QuestType = QuestType.SIDE
@export var level_required: int = 1

## Objetivos
@export var objectives: Array[Dictionary] = []  # {type, target, current, required, description}

## Recompensas
@export var reward_exp: int = 0
@export var reward_money: int = 0
@export var reward_items: Dictionary = {}  # {item_id: cantidad}

## Condiciones
@export var prerequisite_quests: Array[String] = []  # IDs de quests requeridas
@export var time_limit: float = 0.0  # 0 = sin límite de tiempo (en segundos)

## Estado
var status: QuestStatus = QuestStatus.LOCKED
var time_remaining: float = 0.0
var accepted_time: float = 0.0

## Obtener progreso de un objetivo específico
func get_objective_progress(index: int) -> Dictionary:
	if index < 0 or index >= objectives.size():
		return {}
	return objectives[index]

## Verificar si todos los objetivos están completos
func all_objectives_complete() -> bool:
	for obj in objectives:
		if obj.current < obj.required:
			return false
	return true

## Incrementar progreso de un objetivo
func increment_objective(index: int, amount: int = 1) -> void:
	if index < 0 or index >= objectives.size():
		return

	objectives[index].current = min(
		objectives[index].current + amount,
		objectives[index].required
	)

## Obtener porcentaje de completado (0.0 a 1.0)
func get_completion_percentage() -> float:
	if objectives.size() == 0:
		return 1.0

	var total = 0.0
	var completed = 0.0

	for obj in objectives:
		total += obj.required
		completed += obj.current

	return completed / total if total > 0 else 0.0

## Crear objetivo
static func create_objective(type: ObjectiveType, target: String, required: int, desc: String) -> Dictionary:
	return {
		"type": type,
		"target": target,
		"current": 0,
		"required": required,
		"description": desc
	}
