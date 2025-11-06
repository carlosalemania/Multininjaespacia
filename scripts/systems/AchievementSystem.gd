extends Node
## Sistema de Logros para Multi Ninja Espacial
## Maneja el desbloqueo, tracking y notificación de logros

signal achievement_unlocked(achievement_id: String, achievement_data: Dictionary)

## Datos de todos los logros disponibles
var achievements: Dictionary = {
	"first_block": {
		"id": "first_block",
		"name": "¡Primer Bloque!",
		"description": "Coloca tu primer bloque",
		"icon": "🧱",
		"requirement": 1,
		"type": "blocks_placed",
		"luz_reward": 5,
		"unlocked": false
	},
	"constructor_novice": {
		"id": "constructor_novice",
		"name": "Constructor Novato",
		"description": "Coloca 50 bloques",
		"icon": "🏗️",
		"requirement": 50,
		"type": "blocks_placed",
		"luz_reward": 20,
		"unlocked": false
	},
	"architect": {
		"id": "architect",
		"name": "Arquitecto",
		"description": "Coloca 200 bloques",
		"icon": "🏛️",
		"requirement": 200,
		"type": "blocks_placed",
		"luz_reward": 50,
		"unlocked": false
	},
	"master_builder": {
		"id": "master_builder",
		"name": "Maestro Constructor",
		"description": "Coloca 1000 bloques",
		"icon": "👷",
		"requirement": 1000,
		"type": "blocks_placed",
		"luz_reward": 150,
		"unlocked": false
	},
	"first_break": {
		"id": "first_break",
		"name": "Primer Golpe",
		"description": "Rompe tu primer bloque",
		"icon": "⛏️",
		"requirement": 1,
		"type": "blocks_broken",
		"luz_reward": 5,
		"unlocked": false
	},
	"miner": {
		"id": "miner",
		"name": "Minero",
		"description": "Rompe 100 bloques",
		"icon": "⚒️",
		"requirement": 100,
		"type": "blocks_broken",
		"luz_reward": 30,
		"unlocked": false
	},
	"lumberjack": {
		"id": "lumberjack",
		"name": "Leñador",
		"description": "Rompe 20 bloques de madera",
		"icon": "🪓",
		"requirement": 20,
		"type": "wood_broken",
		"luz_reward": 25,
		"unlocked": false
	},
	"explorer": {
		"id": "explorer",
		"name": "Explorador",
		"description": "Visita los 4 biomas diferentes",
		"icon": "🗺️",
		"requirement": 4,
		"type": "biomes_visited",
		"luz_reward": 100,
		"unlocked": false
	},
	"traveler": {
		"id": "traveler",
		"name": "Viajero",
		"description": "Camina 1000 metros",
		"icon": "🚶",
		"requirement": 1000,
		"type": "distance_walked",
		"luz_reward": 40,
		"unlocked": false
	},
	"illuminated": {
		"id": "illuminated",
		"name": "Iluminado",
		"description": "Alcanza 1000 de Luz Interior",
		"icon": "✨",
		"requirement": 1000,
		"type": "luz_total",
		"luz_reward": 200,
		"unlocked": false
	},
	"high_jumper": {
		"id": "high_jumper",
		"name": "Saltador",
		"description": "Salta 100 veces",
		"icon": "🦘",
		"requirement": 100,
		"type": "jumps",
		"luz_reward": 15,
		"unlocked": false
	},
	"finder": {
		"id": "finder",
		"name": "Buscador de Tesoros",
		"description": "Encuentra una estructura especial",
		"icon": "🏰",
		"requirement": 1,
		"type": "structures_found",
		"luz_reward": 50,
		"unlocked": false
	},
	"temple_visitor": {
		"id": "temple_visitor",
		"name": "Peregrino",
		"description": "Visita un templo",
		"icon": "⛪",
		"requirement": 1,
		"type": "temples_visited",
		"luz_reward": 75,
		"unlocked": false
	},
	"tower_climber": {
		"id": "tower_climber",
		"name": "Escalador",
		"description": "Sube a la cima de una torre",
		"icon": "🗼",
		"requirement": 1,
		"type": "towers_climbed",
		"luz_reward": 60,
		"unlocked": false
	},
	"npc_helper": {
		"id": "npc_helper",
		"name": "Ayudante",
		"description": "Completa una misión de un NPC",
		"icon": "🤝",
		"requirement": 1,
		"type": "quests_completed",
		"luz_reward": 80,
		"unlocked": false
	}
}

## Estadísticas del jugador para tracking
var stats: Dictionary = {
	"blocks_placed": 0,
	"blocks_broken": 0,
	"wood_broken": 0,
	"biomes_visited": [],
	"distance_walked": 0.0,
	"luz_total": 0,
	"jumps": 0,
	"structures_found": [],
	"temples_visited": 0,
	"towers_climbed": 0,
	"quests_completed": 0
}

func _ready() -> void:
	print("🏆 Sistema de Logros inicializado")
	_load_achievements()

## Incrementar estadística y verificar logros
func increment_stat(stat_name: String, amount: float = 1.0) -> void:
	if stat_name in stats:
		if stats[stat_name] is Array:
			return # Arrays se manejan con add_to_array_stat
		stats[stat_name] += amount
		_check_achievements_for_stat(stat_name)

## Añadir elemento único a estadística de array
func add_to_array_stat(stat_name: String, value: String) -> void:
	if stat_name in stats and stats[stat_name] is Array:
		if value not in stats[stat_name]:
			stats[stat_name].append(value)
			_check_achievements_for_stat(stat_name)

## Verificar logros relacionados con una estadística
func _check_achievements_for_stat(stat_name: String) -> void:
	for achievement_id in achievements:
		var achievement = achievements[achievement_id]
		if achievement.unlocked:
			continue

		if achievement.type == stat_name:
			var current_value = stats[stat_name]
			if current_value is Array:
				current_value = current_value.size()

			if current_value >= achievement.requirement:
				_unlock_achievement(achievement_id)

## Desbloquear logro
func _unlock_achievement(achievement_id: String) -> void:
	if achievement_id not in achievements:
		return

	var achievement = achievements[achievement_id]
	if achievement.unlocked:
		return

	achievement.unlocked = true

	# Otorgar recompensa de Luz
	if VirtueSystem:
		VirtueSystem.add_luz_manual(achievement.luz_reward, "Logro: " + achievement.name)

	print("🏆 ¡Logro desbloqueado! " + achievement.icon + " " + achievement.name)

	# Emitir señal para UI
	achievement_unlocked.emit(achievement_id, achievement)

	# Guardar progreso
	_save_achievements()

## Obtener todos los logros
func get_all_achievements() -> Dictionary:
	return achievements

## Obtener logros desbloqueados
func get_unlocked_achievements() -> Array:
	var unlocked = []
	for achievement_id in achievements:
		if achievements[achievement_id].unlocked:
			unlocked.append(achievements[achievement_id])
	return unlocked

## Obtener progreso de un logro específico
func get_achievement_progress(achievement_id: String) -> float:
	if achievement_id not in achievements:
		return 0.0

	var achievement = achievements[achievement_id]
	if achievement.unlocked:
		return 1.0

	var stat_name = achievement.type
	var current_value = stats[stat_name]
	if current_value is Array:
		current_value = current_value.size()

	return clamp(float(current_value) / float(achievement.requirement), 0.0, 1.0)

## Obtener estadísticas del jugador
func get_stats() -> Dictionary:
	return stats

## Guardar logros
func _save_achievements() -> void:
	if SaveSystem:
		var save_data = {
			"achievements": achievements,
			"stats": stats
		}
		SaveSystem.save_data("achievements", save_data)

## Cargar logros
func _load_achievements() -> void:
	if SaveSystem:
		var save_data = SaveSystem.load_data("achievements")
		if save_data:
			if "achievements" in save_data:
				# Merge con datos por defecto para no perder nuevos logros
				for achievement_id in save_data.achievements:
					if achievement_id in achievements:
						achievements[achievement_id].unlocked = save_data.achievements[achievement_id].unlocked
			if "stats" in save_data:
				for stat_name in save_data.stats:
					if stat_name in stats:
						stats[stat_name] = save_data.stats[stat_name]
			print("📥 Logros cargados")
