# ============================================================================
# AchievementSystem.gd - Sistema de Logros
# ============================================================================
# Singleton que gestiona logros, notificaciones y recompensas
# ============================================================================

extends Node

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SEÑALES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Emitida cuando se desbloquea un logro
signal achievement_unlocked(achievement_id: String, achievement_data: Dictionary)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEFINICIÓN DE LOGROS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const ACHIEVEMENTS: Dictionary = {
	# Construcción
	"first_block": {
		"icon": "🎯",
		"name": "Primer Bloque",
		"description": "Coloca tu primer bloque",
		"value": 1,
		"stat": "blocks_placed",
		"reward_luz": 5,
		"tier": "bronze"
	},
	"builder": {
		"icon": "🏗️",
		"name": "Constructor",
		"description": "Coloca 50 bloques",
		"value": 50,
		"stat": "blocks_placed",
		"reward_luz": 25,
		"tier": "silver"
	},
	"architect": {
		"icon": "🏛️",
		"name": "Arquitecto",
		"description": "Coloca 200 bloques",
		"value": 200,
		"stat": "blocks_placed",
		"reward_luz": 75,
		"tier": "gold"
	},
	"master_builder": {
		"icon": "👑",
		"name": "Maestro Constructor",
		"description": "Coloca 1000 bloques",
		"value": 1000,
		"stat": "blocks_placed",
		"reward_luz": 200,
		"tier": "diamond"
	},

	# Minería
	"first_break": {
		"icon": "⛏️",
		"name": "Primera Excavación",
		"description": "Rompe tu primer bloque",
		"value": 1,
		"stat": "blocks_broken",
		"reward_luz": 5,
		"tier": "bronze"
	},
	"miner": {
		"icon": "⛏️",
		"name": "Minero",
		"description": "Rompe 100 bloques",
		"value": 100,
		"stat": "blocks_broken",
		"reward_luz": 30,
		"tier": "silver"
	},
	"excavator": {
		"icon": "💎",
		"name": "Excavador Experto",
		"description": "Rompe 500 bloques",
		"value": 500,
		"stat": "blocks_broken",
		"reward_luz": 100,
		"tier": "gold"
	},

	# Exploración
	"explorer": {
		"icon": "🗺️",
		"name": "Explorador",
		"description": "Visita los 4 biomas",
		"value": 4,
		"stat": "biomes_visited",
		"reward_luz": 50,
		"tier": "gold"
	},
	"traveler": {
		"icon": "🚶",
		"name": "Viajero",
		"description": "Camina 1000 metros",
		"value": 1000,
		"stat": "distance_walked",
		"reward_luz": 40,
		"tier": "silver"
	},
	"marathon": {
		"icon": "🏃",
		"name": "Maratonista",
		"description": "Camina 5000 metros",
		"value": 5000,
		"stat": "distance_walked",
		"reward_luz": 150,
		"tier": "diamond"
	},

	# Naturaleza
	"lumberjack": {
		"icon": "🪓",
		"name": "Leñador",
		"description": "Tala 20 árboles",
		"value": 20,
		"stat": "trees_cut",
		"reward_luz": 35,
		"tier": "silver"
	},

	# Luz Interior
	"enlightened": {
		"icon": "✨",
		"name": "Iluminado",
		"description": "Alcanza 1000 Luz Interior",
		"value": 1000,
		"stat": "luz_total",
		"reward_luz": 0,  # Ya llegó a 1000
		"tier": "diamond"
	},
	"beacon": {
		"icon": "🌟",
		"name": "Faro de Esperanza",
		"description": "Alcanza 500 Luz Interior",
		"value": 500,
		"stat": "luz_total",
		"reward_luz": 50,
		"tier": "gold"
	},

	# Crafteo
	"first_craft": {
		"icon": "🔨",
		"name": "Primer Crafteo",
		"description": "Craftea tu primer objeto",
		"value": 1,
		"stat": "items_crafted",
		"reward_luz": 10,
		"tier": "bronze"
	},
	"crafter": {
		"icon": "⚒️",
		"name": "Artesano",
		"description": "Craftea 50 objetos",
		"value": 50,
		"stat": "items_crafted",
		"reward_luz": 60,
		"tier": "gold"
	},

	# Estructuras
	"temple_visitor": {
		"icon": "⛪",
		"name": "Peregrino",
		"description": "Entra a un Templo",
		"value": 1,
		"stat": "temples_visited",
		"reward_luz": 25,
		"tier": "silver"
	}
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Logros desbloqueados
var unlocked_achievements: Array[String] = []

## Estadísticas del jugador
var stats: Dictionary = {
	"blocks_placed": 0,
	"blocks_broken": 0,
	"biomes_visited": 0,
	"distance_walked": 0.0,
	"trees_cut": 0,
	"luz_total": 0,
	"items_crafted": 0,
	"temples_visited": 0
}

## Biomas ya visitados
var visited_biomes: Array[int] = []

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	print("🏆 AchievementSystem inicializado")


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PÚBLICOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Incrementa una estadística y verifica logros
func increment_stat(stat_name: String, amount: float = 1.0) -> void:
	if not stats.has(stat_name):
		return

	stats[stat_name] += amount
	_check_achievements_for_stat(stat_name)


## Registra visita a un bioma
func visit_biome(biome_type: int) -> void:
	if biome_type not in visited_biomes:
		visited_biomes.append(biome_type)
		stats.biomes_visited = visited_biomes.size()
		_check_achievements_for_stat("biomes_visited")


## Verifica si un logro está desbloqueado
func is_unlocked(achievement_id: String) -> bool:
	return achievement_id in unlocked_achievements


## Alias para compatibilidad con UI
func is_achievement_unlocked(achievement_id: String) -> bool:
	return is_unlocked(achievement_id)


## Obtiene el progreso de un logro (0.0 - 1.0)
func get_progress(achievement_id: String) -> float:
	if is_unlocked(achievement_id):
		return 1.0

	var achievement = ACHIEVEMENTS.get(achievement_id)
	if not achievement:
		return 0.0

	var stat_value = stats.get(achievement.stat, 0)
	var required_value = achievement.get("value", achievement.get("requirement", 1))

	return minf(float(stat_value) / float(required_value), 1.0)


## Obtiene todos los logros desbloqueados
func get_unlocked_count() -> int:
	return unlocked_achievements.size()


## Obtiene el total de logros
func get_total_count() -> int:
	return ACHIEVEMENTS.size()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PRIVADOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Verifica logros relacionados con una estadística
func _check_achievements_for_stat(stat_name: String) -> void:
	for achievement_id in ACHIEVEMENTS:
		# Saltar si ya está desbloqueado
		if is_unlocked(achievement_id):
			continue

		var achievement = ACHIEVEMENTS[achievement_id]

		# Verificar si este logro usa esta estadística
		if achievement.stat != stat_name:
			continue

		# Verificar si se cumple el requisito
		var stat_value = stats.get(stat_name, 0)
		var required_value = achievement.get("value", achievement.get("requirement", 1))
		if stat_value >= required_value:
			_unlock_achievement(achievement_id, achievement)


## Desbloquea un logro
func _unlock_achievement(achievement_id: String, achievement_data: Dictionary) -> void:
	unlocked_achievements.append(achievement_id)

	# Dar recompensa de Luz
	if achievement_data.reward_luz > 0:
		PlayerData.add_luz(achievement_data.reward_luz)

	# Emitir señal
	achievement_unlocked.emit(achievement_id, achievement_data)

	# Notificación
	print("🏆 ¡LOGRO DESBLOQUEADO! ", achievement_data.name)
	print("   ", achievement_data.description)
	if achievement_data.reward_luz > 0:
		print("   Recompensa: +", achievement_data.reward_luz, " Luz")

	# Efecto de sonido
	AudioManager.play_sfx(Enums.SoundType.ACHIEVEMENT)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# GUARDADO/CARGA
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Serializa el estado de logros
func to_dict() -> Dictionary:
	return {
		"unlocked_achievements": unlocked_achievements,
		"stats": stats,
		"visited_biomes": visited_biomes
	}


## Carga el estado de logros
func from_dict(data: Dictionary) -> void:
	unlocked_achievements = data.get("unlocked_achievements", [])
	stats = data.get("stats", stats)
	visited_biomes = data.get("visited_biomes", [])
