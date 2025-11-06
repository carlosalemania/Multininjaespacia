extends Node
## Sistema Global de Misiones y Objetivos

signal quest_accepted(quest_id: String)
signal quest_completed(quest_id: String)
signal quest_failed(quest_id: String)
signal objective_updated(quest_id: String, objective_index: int)
signal quest_tracker_updated()

## Biblioteca de todas las quests disponibles
var quest_library: Dictionary = {}

## Quests activas del jugador
var active_quests: Array[QuestData] = []

## Quests completadas
var completed_quests: Array[String] = []

## Quest actualmente trackeada en el HUD
var tracked_quest: QuestData = null

func _ready() -> void:
	_initialize_quest_library()
	print("📜 Sistema de Misiones inicializado - ", quest_library.size(), " quests disponibles")

func _process(delta: float) -> void:
	# Actualizar temporizadores de quests con límite de tiempo
	for quest in active_quests:
		if quest.time_limit > 0:
			quest.time_remaining -= delta
			if quest.time_remaining <= 0:
				fail_quest(quest.quest_id, "Tiempo agotado")

## ============================================================================
## BIBLIOTECA DE QUESTS
## ============================================================================

func _initialize_quest_library() -> void:
	# ========================================
	# TUTORIAL QUESTS
	# ========================================

	_add_quest({
		"id": "tutorial_welcome",
		"name": "Bienvenido al Mundo",
		"description": "Aprende los controles básicos y explora tu entorno",
		"type": QuestData.QuestType.TUTORIAL,
		"objectives": [
			QuestData.create_objective(QuestData.ObjectiveType.EXPLORE, "spawn_area", 1, "Muévete con WASD"),
			QuestData.create_objective(QuestData.ObjectiveType.COLLECT, "wood", 5, "Recolecta 5 madera"),
			QuestData.create_objective(QuestData.ObjectiveType.CRAFT, "wooden_pickaxe", 1, "Craftea un pico de madera")
		],
		"reward_exp": 50,
		"reward_money": 10,
		"reward_items": {"torch": 3}
	})

	_add_quest({
		"id": "tutorial_survival",
		"name": "Sobrevive la Primera Noche",
		"description": "Construye un refugio y prepara comida antes del anochecer",
		"type": QuestData.QuestType.TUTORIAL,
		"prerequisites": ["tutorial_welcome"],
		"objectives": [
			QuestData.create_objective(QuestData.ObjectiveType.BUILD, "shelter", 1, "Construye un refugio básico"),
			QuestData.create_objective(QuestData.ObjectiveType.CRAFT, "campfire", 1, "Crea una hoguera"),
			QuestData.create_objective(QuestData.ObjectiveType.COLLECT, "food", 3, "Consigue comida (cazar o recolectar)")
		],
		"reward_exp": 100,
		"reward_money": 25,
		"reward_items": {"bed_simple": 1, "torch": 5}
	})

	# ========================================
	# MAIN QUESTS
	# ========================================

	_add_quest({
		"id": "main_01_explorer",
		"name": "El Gran Explorador",
		"description": "Explora los biomas principales del mundo",
		"type": QuestData.QuestType.MAIN,
		"level_required": 3,
		"prerequisites": ["tutorial_survival"],
		"objectives": [
			QuestData.create_objective(QuestData.ObjectiveType.EXPLORE, "forest", 1, "Explora el Bosque"),
			QuestData.create_objective(QuestData.ObjectiveType.EXPLORE, "desert", 1, "Explora el Desierto"),
			QuestData.create_objective(QuestData.ObjectiveType.EXPLORE, "mountains", 1, "Explora las Montañas")
		],
		"reward_exp": 250,
		"reward_money": 100,
		"reward_items": {"map": 1, "compass": 1}
	})

	_add_quest({
		"id": "main_02_hunter",
		"name": "El Cazador",
		"description": "Domina el arte de la caza",
		"type": QuestData.QuestType.MAIN,
		"level_required": 5,
		"objectives": [
			QuestData.create_objective(QuestData.ObjectiveType.KILL, "sheep", 5, "Caza 5 ovejas"),
			QuestData.create_objective(QuestData.ObjectiveType.KILL, "cow", 3, "Caza 3 vacas"),
			QuestData.create_objective(QuestData.ObjectiveType.CRAFT, "bow", 1, "Craftea un arco")
		],
		"reward_exp": 300,
		"reward_money": 150,
		"reward_items": {"arrow": 50, "cooked_meat": 10}
	})

	# ========================================
	# SIDE QUESTS
	# ========================================

	_add_quest({
		"id": "side_01_gatherer",
		"name": "Recolector Experto",
		"description": "Recolecta recursos básicos",
		"type": QuestData.QuestType.SIDE,
		"objectives": [
			QuestData.create_objective(QuestData.ObjectiveType.COLLECT, "wood", 50, "Recolecta 50 madera"),
			QuestData.create_objective(QuestData.ObjectiveType.COLLECT, "stone", 30, "Recolecta 30 piedra"),
			QuestData.create_objective(QuestData.ObjectiveType.COLLECT, "iron_ore", 10, "Recolecta 10 mineral de hierro")
		],
		"reward_exp": 150,
		"reward_money": 75
	})

	_add_quest({
		"id": "side_02_chef",
		"name": "Chef en Formación",
		"description": "Aprende a cocinar diferentes alimentos",
		"type": QuestData.QuestType.SIDE,
		"objectives": [
			QuestData.create_objective(QuestData.ObjectiveType.CRAFT, "cooked_meat", 5, "Cocina 5 carnes"),
			QuestData.create_objective(QuestData.ObjectiveType.CRAFT, "bread", 3, "Hornea 3 panes"),
			QuestData.create_objective(QuestData.ObjectiveType.CRAFT, "stew", 2, "Prepara 2 guisos")
		],
		"reward_exp": 200,
		"reward_money": 100,
		"reward_items": {"furnace": 1}
	})

	_add_quest({
		"id": "side_03_builder",
		"name": "Constructor Maestro",
		"description": "Construye una base completa",
		"type": QuestData.QuestType.SIDE,
		"level_required": 5,
		"objectives": [
			QuestData.create_objective(QuestData.ObjectiveType.BUILD, "walls", 20, "Construye 20 paredes"),
			QuestData.create_objective(QuestData.ObjectiveType.BUILD, "furniture", 10, "Coloca 10 muebles"),
			QuestData.create_objective(QuestData.ObjectiveType.BUILD, "lights", 5, "Instala 5 luces")
		],
		"reward_exp": 350,
		"reward_money": 200,
		"reward_items": {"chest_wood": 2}
	})

	# ========================================
	# DAILY QUESTS
	# ========================================

	_add_quest({
		"id": "daily_gathering",
		"name": "Recolección Diaria",
		"description": "Recolecta recursos para el día",
		"type": QuestData.QuestType.DAILY,
		"objectives": [
			QuestData.create_objective(QuestData.ObjectiveType.COLLECT, "wood", 20, "Recolecta 20 madera"),
			QuestData.create_objective(QuestData.ObjectiveType.COLLECT, "stone", 15, "Recolecta 15 piedra")
		],
		"reward_exp": 50,
		"reward_money": 25,
		"time_limit": 86400  # 24 horas
	})

	_add_quest({
		"id": "daily_hunting",
		"name": "Cacería Diaria",
		"description": "Caza animales para obtener comida",
		"type": QuestData.QuestType.DAILY,
		"objectives": [
			QuestData.create_objective(QuestData.ObjectiveType.KILL, "any_animal", 10, "Caza 10 animales")
		],
		"reward_exp": 75,
		"reward_money": 50,
		"reward_items": {"cooked_meat": 5},
		"time_limit": 86400
	})

func _add_quest(data: Dictionary) -> void:
	var quest = QuestData.new()
	quest.quest_id = data.get("id", "")
	quest.quest_name = data.get("name", "")
	quest.description = data.get("description", "")
	quest.quest_type = data.get("type", QuestData.QuestType.SIDE)
	quest.level_required = data.get("level_required", 1)

	# Convertir objectives a Array tipado
	var objectives_array: Array[Dictionary] = []
	for obj in data.get("objectives", []):
		objectives_array.append(obj)
	quest.objectives = objectives_array

	quest.reward_exp = data.get("reward_exp", 0)
	quest.reward_money = data.get("reward_money", 0)
	quest.reward_items = data.get("reward_items", {})

	# Convertir prerequisite_quests a Array tipado
	var prereq_array: Array[String] = []
	for prereq in data.get("prerequisites", []):
		prereq_array.append(prereq)
	quest.prerequisite_quests = prereq_array

	quest.time_limit = data.get("time_limit", 0.0)

	# Determinar estado inicial
	if quest.prerequisite_quests.size() > 0:
		quest.status = QuestData.QuestStatus.LOCKED
	else:
		quest.status = QuestData.QuestStatus.AVAILABLE

	quest_library[quest.quest_id] = quest

## ============================================================================
## GESTIÓN DE QUESTS
## ============================================================================

## Obtener quest por ID
func get_quest(quest_id: String) -> QuestData:
	return quest_library.get(quest_id, null)

## Verificar si una quest está completada
func is_quest_completed(quest_id: String) -> bool:
	return completed_quests.has(quest_id)

## Verificar si una quest está activa
func is_quest_active(quest_id: String) -> bool:
	for quest in active_quests:
		if quest.quest_id == quest_id:
			return true
	return false

## Verificar si una quest está disponible
func is_quest_available(quest_id: String) -> bool:
	var quest = get_quest(quest_id)
	if not quest:
		return false
	return quest.status == QuestData.QuestStatus.AVAILABLE and _check_prerequisites(quest)

## Obtener todas las quests disponibles para aceptar
func get_available_quests() -> Array[QuestData]:
	var available: Array[QuestData] = []
	for quest_id in quest_library:
		var quest = quest_library[quest_id]
		if quest.status == QuestData.QuestStatus.AVAILABLE:
			if _check_prerequisites(quest):
				available.append(quest)
	return available

## Verificar prerequisitos
func _check_prerequisites(quest: QuestData) -> bool:
	for prereq_id in quest.prerequisite_quests:
		if not completed_quests.has(prereq_id):
			return false
	return true

## Aceptar una quest
func accept_quest(quest_id: String) -> bool:
	var quest = get_quest(quest_id)
	if not quest:
		push_warning("Quest no encontrada: " + quest_id)
		return false

	if quest.status != QuestData.QuestStatus.AVAILABLE:
		push_warning("Quest no disponible: " + quest_id)
		return false

	if not _check_prerequisites(quest):
		push_warning("No cumples los prerequisitos para: " + quest_id)
		return false

	quest.status = QuestData.QuestStatus.ACTIVE
	quest.accepted_time = Time.get_unix_time_from_system()

	if quest.time_limit > 0:
		quest.time_remaining = quest.time_limit

	active_quests.append(quest)

	# Trackear automáticamente si no hay ninguna trackeada
	if tracked_quest == null:
		track_quest(quest_id)

	quest_accepted.emit(quest_id)
	print("📜 Quest aceptada: ", quest.quest_name)
	return true

## Completar una quest
func complete_quest(quest_id: String) -> bool:
	var quest = get_quest(quest_id)
	if not quest or quest.status != QuestData.QuestStatus.ACTIVE:
		return false

	if not quest.all_objectives_complete():
		push_warning("Objetivos incompletos para: " + quest_id)
		return false

	quest.status = QuestData.QuestStatus.COMPLETED
	active_quests.erase(quest)
	completed_quests.append(quest_id)

	# Dar recompensas
	_give_rewards(quest)

	# Desbloquear quests que dependen de esta
	_unlock_dependent_quests(quest_id)

	# Si era la quest trackeada, limpiar tracker
	if tracked_quest == quest:
		tracked_quest = null
		quest_tracker_updated.emit()

	quest_completed.emit(quest_id)
	print("✅ Quest completada: ", quest.quest_name)
	return true

## Fallar una quest
func fail_quest(quest_id: String, reason: String = "") -> void:
	var quest = get_quest(quest_id)
	if not quest or quest.status != QuestData.QuestStatus.ACTIVE:
		return

	quest.status = QuestData.QuestStatus.FAILED
	active_quests.erase(quest)

	if tracked_quest == quest:
		tracked_quest = null
		quest_tracker_updated.emit()

	quest_failed.emit(quest_id)
	print("❌ Quest fallida: ", quest.quest_name, " - ", reason)

## Dar recompensas
func _give_rewards(quest: QuestData) -> void:
	# Experiencia
	if quest.reward_exp > 0:
		if PlayerData:
			PlayerData.add_experience(quest.reward_exp)
		print("  + %d EXP" % quest.reward_exp)

	# Dinero
	if quest.reward_money > 0:
		if PlayerData:
			PlayerData.money += quest.reward_money
		print("  + %d monedas" % quest.reward_money)

	# Items
	for item_id in quest.reward_items:
		var amount = quest.reward_items[item_id]
		# TODO: Agregar al inventario cuando InventorySystem esté implementado
		# if InventorySystem:
		#	InventorySystem.add_item(item_id, amount)
		print("  + %d x %s" % [amount, item_id])

## Desbloquear quests dependientes
func _unlock_dependent_quests(completed_quest_id: String) -> void:
	for quest_id in quest_library:
		var quest = quest_library[quest_id]
		if quest.status == QuestData.QuestStatus.LOCKED:
			if quest.prerequisite_quests.has(completed_quest_id):
				if _check_prerequisites(quest):
					quest.status = QuestData.QuestStatus.AVAILABLE
					print("🔓 Quest desbloqueada: ", quest.quest_name)

## ============================================================================
## PROGRESO DE OBJETIVOS
## ============================================================================

## Actualizar progreso de objetivo
func update_objective(quest_id: String, objective_type: QuestData.ObjectiveType, target: String, amount: int = 1) -> void:
	var quest = get_quest(quest_id)
	if not quest or quest.status != QuestData.QuestStatus.ACTIVE:
		return

	var updated = false
	for i in range(quest.objectives.size()):
		var obj = quest.objectives[i]
		if obj.type == objective_type and (obj.target == target or obj.target == "any_" + target.split("_")[0]):
			quest.increment_objective(i, amount)
			objective_updated.emit(quest_id, i)
			updated = true

			# Mostrar progreso
			print("📊 %s: %d/%d %s" % [quest.quest_name, obj.current, obj.required, obj.description])

	# Verificar si se completó
	if updated and quest.all_objectives_complete():
		print("✨ ¡Todos los objetivos completados! Regresa para entregar la quest")

	if tracked_quest == quest:
		quest_tracker_updated.emit()

## Notificar recolección de item
func notify_item_collected(item_id: String, amount: int = 1) -> void:
	for quest in active_quests:
		update_objective(quest.quest_id, QuestData.ObjectiveType.COLLECT, item_id, amount)

## Notificar enemigo muerto
func notify_enemy_killed(enemy_type: String) -> void:
	for quest in active_quests:
		update_objective(quest.quest_id, QuestData.ObjectiveType.KILL, enemy_type, 1)

## Notificar item crafteado
func notify_item_crafted(item_id: String, amount: int = 1) -> void:
	for quest in active_quests:
		update_objective(quest.quest_id, QuestData.ObjectiveType.CRAFT, item_id, amount)

## Notificar construcción
func notify_built(structure_type: String) -> void:
	for quest in active_quests:
		update_objective(quest.quest_id, QuestData.ObjectiveType.BUILD, structure_type, 1)

## Notificar área explorada
func notify_area_explored(area_id: String) -> void:
	for quest in active_quests:
		update_objective(quest.quest_id, QuestData.ObjectiveType.EXPLORE, area_id, 1)

## ============================================================================
## QUEST TRACKER
## ============================================================================

## Trackear una quest en el HUD
func track_quest(quest_id: String) -> void:
	var quest = get_quest(quest_id)
	if quest and quest.status == QuestData.QuestStatus.ACTIVE:
		tracked_quest = quest
		quest_tracker_updated.emit()
		print("📌 Trackeando: ", quest.quest_name)

## Dejar de trackear
func untrack_quest() -> void:
	tracked_quest = null
	quest_tracker_updated.emit()

## Obtener quest trackeada
func get_tracked_quest() -> QuestData:
	return tracked_quest

## ============================================================================
## UTILIDADES
## ============================================================================

## Abandonar quest
func abandon_quest(quest_id: String) -> bool:
	var quest = get_quest(quest_id)
	if not quest or quest.status != QuestData.QuestStatus.ACTIVE:
		return false

	# No se pueden abandonar quests de tutorial o principales
	if quest.quest_type == QuestData.QuestType.TUTORIAL or quest.quest_type == QuestData.QuestType.MAIN:
		push_warning("No puedes abandonar esta quest")
		return false

	quest.status = QuestData.QuestStatus.AVAILABLE
	active_quests.erase(quest)

	# Resetear progreso
	for obj in quest.objectives:
		obj.current = 0

	if tracked_quest == quest:
		tracked_quest = null
		quest_tracker_updated.emit()

	print("🚫 Quest abandonada: ", quest.quest_name)
	return true

## Obtener información de debug
func get_debug_info() -> Dictionary:
	return {
		"total_quests": quest_library.size(),
		"active_quests": active_quests.size(),
		"completed_quests": completed_quests.size(),
		"tracked_quest": tracked_quest.quest_name if tracked_quest else "None"
	}
