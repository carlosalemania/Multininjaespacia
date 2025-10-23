# ============================================================================
# QuestSystem.gd - Sistema de Misiones
# ============================================================================
# Singleton que gestiona misiones activas y completadas
# ============================================================================

extends Node

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SEÑALES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Emitida cuando se acepta una misión
signal quest_accepted(quest_id: String)

## Emitida cuando se completa una misión
signal quest_completed(quest_id: String, quest_data: Dictionary)

## Emitida cuando progresa una misión
signal quest_progressed(quest_id: String, progress: float)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Misiones activas
var active_quests: Array[String] = []

## Misiones completadas
var completed_quests: Array[String] = []

## Progreso inicial de misiones activas (para tracking)
var quest_start_values: Dictionary = {}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	print("📋 QuestSystem inicializado")


func _process(_delta: float) -> void:
	# Verificar progreso de misiones activas
	_check_active_quests()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PÚBLICOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Acepta una misión
func accept_quest(quest_id: String) -> bool:
	# Verificar si ya está activa o completada
	if is_quest_active(quest_id) or is_quest_completed(quest_id):
		return false

	# Verificar que la misión existe
	var quest_data = NPCData.get_quest_data(quest_id)
	if quest_data.is_empty():
		return false

	# Agregar a misiones activas
	active_quests.append(quest_id)

	# Guardar valor inicial del stat
	_save_quest_start_value(quest_id, quest_data)

	quest_accepted.emit(quest_id)
	print("✅ Misión aceptada: ", quest_data.get("title", "???"))

	return true


## Completa una misión manualmente
func complete_quest(quest_id: String) -> void:
	if not is_quest_active(quest_id):
		return

	var quest_data = NPCData.get_quest_data(quest_id)
	if quest_data.is_empty():
		return

	# Remover de activas
	active_quests.erase(quest_id)

	# Agregar a completadas
	completed_quests.append(quest_id)

	# Dar recompensa
	var reward = quest_data.get("reward_luz", 0)
	if reward > 0:
		PlayerData.add_luz(reward)

	quest_completed.emit(quest_id, quest_data)

	print("🎉 ¡MISIÓN COMPLETADA! ", quest_data.get("title", "???"))
	print("   Recompensa: +", reward, " Luz Interior")

	# Reproducir sonido
	AudioManager.play_sfx(Enums.SoundType.ACHIEVEMENT)


## Verifica si una misión está activa
func is_quest_active(quest_id: String) -> bool:
	return quest_id in active_quests


## Verifica si una misión está completada
func is_quest_completed(quest_id: String) -> bool:
	return quest_id in completed_quests


## Obtiene el progreso de una misión (0.0 - 1.0)
func get_quest_progress(quest_id: String) -> float:
	if not is_quest_active(quest_id):
		if is_quest_completed(quest_id):
			return 1.0
		return 0.0

	var quest_data = NPCData.get_quest_data(quest_id)
	if quest_data.is_empty():
		return 0.0

	var quest_type = quest_data.get("type", NPCData.QuestType.COLLECT)
	var target = quest_data.get("target", 1)
	var start_value = quest_start_values.get(quest_id, 0)

	match quest_type:
		NPCData.QuestType.BUILD, NPCData.QuestType.MINE, NPCData.QuestType.EXPLORE:
			var stat_name = quest_data.get("stat", "")
			var current = AchievementSystem.stats.get(stat_name, 0)
			var progress_made = current - start_value
			return clampf(float(progress_made) / float(target), 0.0, 1.0)

		NPCData.QuestType.COLLECT:
			var item = quest_data.get("item", Enums.BlockType.NONE)
			var current = PlayerData.get_inventory_count(item)
			return clampf(float(current) / float(target), 0.0, 1.0)

	return 0.0


## Obtiene el valor actual de progreso
func get_quest_current_value(quest_id: String) -> int:
	if not is_quest_active(quest_id):
		return 0

	var quest_data = NPCData.get_quest_data(quest_id)
	if quest_data.is_empty():
		return 0

	var quest_type = quest_data.get("type", NPCData.QuestType.COLLECT)
	var start_value = quest_start_values.get(quest_id, 0)

	match quest_type:
		NPCData.QuestType.BUILD, NPCData.QuestType.MINE, NPCData.QuestType.EXPLORE:
			var stat_name = quest_data.get("stat", "")
			var current = AchievementSystem.stats.get(stat_name, 0)
			return max(0, current - start_value)

		NPCData.QuestType.COLLECT:
			var item = quest_data.get("item", Enums.BlockType.NONE)
			return PlayerData.get_inventory_count(item)

	return 0


## Obtiene todas las misiones activas
func get_active_quests() -> Array[String]:
	return active_quests.duplicate()


## Obtiene la cantidad de misiones activas
func get_active_quest_count() -> int:
	return active_quests.size()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PRIVADOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Guarda el valor inicial de un stat para tracking
func _save_quest_start_value(quest_id: String, quest_data: Dictionary) -> void:
	var quest_type = quest_data.get("type", NPCData.QuestType.COLLECT)

	match quest_type:
		NPCData.QuestType.BUILD, NPCData.QuestType.MINE, NPCData.QuestType.EXPLORE:
			var stat_name = quest_data.get("stat", "")
			var current = AchievementSystem.stats.get(stat_name, 0)
			quest_start_values[quest_id] = current

		NPCData.QuestType.COLLECT:
			# Para COLLECT no guardamos valor inicial (siempre desde 0)
			quest_start_values[quest_id] = 0


## Verifica progreso de misiones activas
func _check_active_quests() -> void:
	for quest_id in active_quests:
		var progress = get_quest_progress(quest_id)

		# Si está completa, completarla
		if progress >= 1.0:
			complete_quest(quest_id)
			return  # Salir para evitar modificar array mientras iteramos


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# GUARDADO/CARGA
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Serializa el estado de misiones
func to_dict() -> Dictionary:
	return {
		"active_quests": active_quests,
		"completed_quests": completed_quests,
		"quest_start_values": quest_start_values
	}


## Carga el estado de misiones
func from_dict(data: Dictionary) -> void:
	active_quests = data.get("active_quests", [])
	completed_quests = data.get("completed_quests", [])
	quest_start_values = data.get("quest_start_values", {})
