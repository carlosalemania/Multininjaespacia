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
		"name": "🎯 Primer Bloque",
		"description": "Coloca tu primer bloque",
		"requirement": 1,
		"stat": "blocks_placed",
		"reward_luz": 5,
		"tier": "bronze"
	},
	"builder": {
		"name": "🏗️ Constructor",
		"description": "Coloca 50 bloques",
		"requirement": 50,
		"stat": "blocks_placed",
		"reward_luz": 25,
		"tier": "silver"
	},
	"architect": {
		"name": "🏛️ Arquitecto",
		"description": "Coloca 200 bloques",
		"requirement": 200,
		"stat": "blocks_placed",
		"reward_luz": 75,
		"tier": "gold"
	},
	"master_builder": {
		"name": "👑 Maestro Constructor",
		"description": "Coloca 1000 bloques",
		"requirement": 1000,
		"stat": "blocks_placed",
		"reward_luz": 200,
		"tier": "diamond"
	},

	# Minería
	"first_break": {
		"name": "⛏️ Primera Excavación",
		"description": "Rompe tu primer bloque",
		"requirement": 1,
		"stat": "blocks_broken",
		"reward_luz": 5,
		"tier": "bronze"
	},
	"miner": {
		"name": "⛏️ Minero",
		"description": "Rompe 100 bloques",
		"requirement": 100,
		"stat": "blocks_broken",
		"reward_luz": 30,
		"tier": "silver"
	},
	"excavator": {
		"name": "💎 Excavador Experto",
		"description": "Rompe 500 bloques",
		"requirement": 500,
		"stat": "blocks_broken",
		"reward_luz": 100,
		"tier": "gold"
	},

	# Exploración
	"explorer": {
		"name": "🗺️ Explorador",
		"description": "Visita los 4 biomas",
		"requirement": 4,
		"stat": "biomes_visited",
		"reward_luz": 50,
		"tier": "gold"
	},
	"traveler": {
		"name": "🚶 Viajero",
		"description": "Camina 1000 metros",
		"requirement": 1000,
		"stat": "distance_walked",
		"reward_luz": 40,
		"tier": "silver"
	},
	"marathon": {
		"name": "🏃 Maratonista",
		"description": "Camina 5000 metros",
		"requirement": 5000,
		"stat": "distance_walked",
		"reward_luz": 150,
		"tier": "diamond"
	},

	# Naturaleza
	"lumberjack": {
		"name": "🪓 Leñador",
		"description": "Tala 20 árboles",
		"requirement": 20,
		"stat": "trees_cut",
		"reward_luz": 35,
		"tier": "silver"
	},

	# Luz Interior
	"enlightened": {
		"name": "✨ Iluminado",
		"description": "Alcanza 1000 Luz Interior",
		"requirement": 1000,
		"stat": "luz_total",
		"reward_luz": 0,  # Ya llegó a 1000
		"tier": "diamond"
	},
	"beacon": {
		"name": "🌟 Faro de Esperanza",
		"description": "Alcanza 500 Luz Interior",
		"requirement": 500,
		"stat": "luz_total",
		"reward_luz": 50,
		"tier": "gold"
	},

	# Crafteo
	"first_craft": {
		"name": "🔨 Primer Crafteo",
		"description": "Craftea tu primer objeto",
		"requirement": 1,
		"stat": "items_crafted",
		"reward_luz": 10,
		"tier": "bronze"
	},
	"crafter": {
		"name": "⚒️ Artesano",
		"description": "Craftea 50 objetos",
		"requirement": 50,
		"stat": "items_crafted",
		"reward_luz": 60,
		"tier": "gold"
	},

	# Estructuras
	"temple_visitor": {
		"name": "⛪ Peregrino",
		"description": "Entra a un Templo",
		"requirement": 1,
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


## Obtiene el progreso de un logro (0.0 - 1.0)
func get_progress(achievement_id: String) -> float:
	if is_unlocked(achievement_id):
		return 1.0

	var achievement = ACHIEVEMENTS.get(achievement_id)
	if not achievement:
		return 0.0

	var stat_value = stats.get(achievement.stat, 0)
	var requirement = achievement.requirement

	return minf(float(stat_value) / float(requirement), 1.0)


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
		if stat_value >= achievement.requirement:
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
