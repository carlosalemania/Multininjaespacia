# ============================================================================
# NPCData.gd - Datos de NPCs y Diálogos
# ============================================================================
# Define todos los NPCs, diálogos y misiones del juego
# ============================================================================

extends Node
class_name NPCData

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TIPOS DE NPCS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum NPCType {
	ELDER,           ## Anciano del pueblo - Da misiones principales
	BUILDER,         ## Constructor - Enseña sobre construcción
	MINER,           ## Minero - Enseña sobre minería
	MERCHANT,        ## Comerciante - Intercambia recursos
	EXPLORER,        ## Explorador - Habla sobre biomas
	VILLAGER_BASIC   ## Aldeano genérico
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DATOS DE NPCS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const NPC_DATABASE: Dictionary = {
	NPCType.ELDER: {
		"name": "Anciano Sabio",
		"greeting": "🧙 ¡Bienvenido, viajero! Soy el guardián de este lugar.",
		"color": Color(0.8, 0.7, 0.9),  # Púrpura claro
		"dialogues": [
			"La Luz Interior es la esencia de todo lo que existe.",
			"En tiempos antiguos, nuestro mundo brillaba con luz propia...",
			"Los Templos esconden secretos que pocos han descubierto.",
			"Tu viaje apenas comienza. Hay mucho por explorar."
		],
		"quests": ["main_quest_1", "main_quest_2"]
	},

	NPCType.BUILDER: {
		"name": "Constructor Tomás",
		"greeting": "🏗️ ¡Hola! ¿Vienes a aprender sobre construcción?",
		"color": Color(0.8, 0.5, 0.3),  # Marrón/Naranja
		"dialogues": [
			"La clave de una buena construcción es la planificación.",
			"¿Sabías que puedes usar diferentes bloques para crear estructuras únicas?",
			"He construido casas, torres, puentes... ¡de todo!",
			"Si quieres construir algo grande, necesitarás muchos recursos."
		],
		"quests": ["build_quest_1"]
	},

	NPCType.MINER: {
		"name": "Minera Elena",
		"greeting": "⛏️ ¿Buscas tesoros bajo tierra? ¡Estás en el lugar correcto!",
		"color": Color(0.6, 0.6, 0.7),  # Gris metálico
		"dialogues": [
			"Las profundidades guardan recursos valiosos.",
			"He encontrado oro, cristales y hasta diamantes.",
			"Ten cuidado al excavar. No querrás quedar atrapado.",
			"Las herramientas mejores hacen la minería más rápida."
		],
		"quests": ["mine_quest_1"]
	},

	NPCType.MERCHANT: {
		"name": "Comerciante Marcos",
		"greeting": "💰 ¡Tengo lo que necesitas! ¿Qué deseas intercambiar?",
		"color": Color(0.9, 0.7, 0.2),  # Dorado
		"dialogues": [
			"Intercambio recursos por Luz Interior.",
			"¿Tienes cristales? Pago bien por ellos.",
			"El comercio mantiene viva nuestra comunidad.",
			"Cada recurso tiene su valor único."
		],
		"quests": []
	},

	NPCType.EXPLORER: {
		"name": "Exploradora Ana",
		"greeting": "🗺️ ¡He viajado por todos los biomas! ¿Quieres escuchar mis historias?",
		"color": Color(0.3, 0.8, 0.5),  # Verde aventurero
		"dialogues": [
			"El desierto es ardiente, pero hermoso al atardecer.",
			"Las montañas nevadas son traicioneras pero valen la pena.",
			"Cada bioma tiene sus propios secretos y tesoros.",
			"¿Has visitado el bosque encantado? Es mágico."
		],
		"quests": ["explore_quest_1"]
	},

	NPCType.VILLAGER_BASIC: {
		"name": "Aldeano",
		"greeting": "👋 ¡Hola viajero! ¿Cómo estás?",
		"color": Color(0.7, 0.7, 0.7),  # Gris neutral
		"dialogues": [
			"El clima está agradable hoy.",
			"Me encanta vivir en este lugar.",
			"¿Has visto al Anciano? Él sabe muchas cosas.",
			"La vida aquí es tranquila y pacífica."
		],
		"quests": []
	}
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SISTEMA DE MISIONES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum QuestType {
	COLLECT,    ## Recolectar X items
	BUILD,      ## Construir X bloques
	EXPLORE,    ## Visitar X biomas
	MINE        ## Romper X bloques
}

const QUEST_DATABASE: Dictionary = {
	"main_quest_1": {
		"title": "🎯 Tus Primeros Pasos",
		"description": "El Anciano te pide que coloques 10 bloques para demostrar tus habilidades de construcción.",
		"type": QuestType.BUILD,
		"target": 10,
		"stat": "blocks_placed",
		"reward_luz": 50,
		"reward_text": "¡Bien hecho! Aquí tienes 50 Luz Interior."
	},

	"main_quest_2": {
		"title": "💎 El Poder de los Recursos",
		"description": "Recolecta 5 cristales para el Anciano.",
		"type": QuestType.COLLECT,
		"target": 5,
		"item": Enums.BlockType.CRISTAL,
		"reward_luz": 100,
		"reward_text": "¡Excelente! Los cristales brillan con Luz Interior."
	},

	"build_quest_1": {
		"title": "🏗️ Constructor Novato",
		"description": "Tomás quiere que construyas una pequeña casa (50 bloques).",
		"type": QuestType.BUILD,
		"target": 50,
		"stat": "blocks_placed",
		"reward_luz": 75,
		"reward_text": "¡Impresionante construcción!"
	},

	"mine_quest_1": {
		"title": "⛏️ Excavador Principiante",
		"description": "Elena te reta a romper 30 bloques.",
		"type": QuestType.MINE,
		"target": 30,
		"stat": "blocks_broken",
		"reward_luz": 60,
		"reward_text": "¡Buen trabajo minando!"
	},

	"explore_quest_1": {
		"title": "🗺️ Descubre el Mundo",
		"description": "Ana te pide que visites 2 biomas diferentes.",
		"type": QuestType.EXPLORE,
		"target": 2,
		"stat": "biomes_visited",
		"reward_luz": 80,
		"reward_text": "¡Eres un verdadero explorador!"
	}
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS ESTÁTICOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Obtiene datos de un NPC
static func get_npc_data(npc_type: NPCType) -> Dictionary:
	return NPC_DATABASE.get(npc_type, {})


## Obtiene nombre de un NPC
static func get_npc_name(npc_type: NPCType) -> String:
	var data = get_npc_data(npc_type)
	return data.get("name", "Desconocido")


## Obtiene color de un NPC
static func get_npc_color(npc_type: NPCType) -> Color:
	var data = get_npc_data(npc_type)
	return data.get("color", Color.WHITE)


## Obtiene saludo de un NPC
static func get_greeting(npc_type: NPCType) -> String:
	var data = get_npc_data(npc_type)
	return data.get("greeting", "...")


## Obtiene un diálogo aleatorio de un NPC
static func get_random_dialogue(npc_type: NPCType) -> String:
	var data = get_npc_data(npc_type)
	var dialogues = data.get("dialogues", ["..."])
	return dialogues[randi() % dialogues.size()]


## Obtiene misiones de un NPC
static func get_npc_quests(npc_type: NPCType) -> Array:
	var data = get_npc_data(npc_type)
	return data.get("quests", [])


## Obtiene datos de una misión
static func get_quest_data(quest_id: String) -> Dictionary:
	return QUEST_DATABASE.get(quest_id, {})


## Obtiene el progreso de una misión (0.0 - 1.0)
static func get_quest_progress(quest_id: String) -> float:
	var quest_data = get_quest_data(quest_id)
	if quest_data.is_empty():
		return 0.0

	var quest_type = quest_data.get("type", QuestType.COLLECT)
	var target = quest_data.get("target", 1)

	match quest_type:
		QuestType.BUILD, QuestType.MINE, QuestType.EXPLORE:
			var stat_name = quest_data.get("stat", "")
			var current = AchievementSystem.stats.get(stat_name, 0)
			return minf(float(current) / float(target), 1.0)

		QuestType.COLLECT:
			var item = quest_data.get("item", Enums.BlockType.NONE)
			var current = PlayerData.get_inventory_count(item)
			return minf(float(current) / float(target), 1.0)

	return 0.0


## Verifica si una misión está completada
static func is_quest_completed(quest_id: String) -> bool:
	return get_quest_progress(quest_id) >= 1.0
