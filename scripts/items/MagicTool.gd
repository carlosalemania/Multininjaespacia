# ============================================================================
# MagicTool.gd - Herramientas Mágicas y Poderosas
# ============================================================================
# Sistema de herramientas con efectos visuales, partículas y poderes especiales
# ============================================================================

extends Node
class_name MagicTool

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TIPOS DE HERRAMIENTAS MÁGICAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum ToolType {
	# Picos mágicos
	WOODEN_PICKAXE,      ## Pico de madera básico
	STONE_PICKAXE,       ## Pico de piedra mejorado
	IRON_PICKAXE,        ## Pico de hierro brillante
	GOLDEN_PICKAXE,      ## Pico de oro resplandeciente
	DIAMOND_PICKAXE,     ## Pico de diamante legendario

	# Herramientas especiales
	MAGIC_WAND,          ## Varita mágica (convierte bloques)
	HAMMER_OF_THUNDER,   ## Martillo del trueno (rompe 3x3)
	STAFF_OF_LIGHT,      ## Bastón de luz (ilumina y purifica)
	INFINITY_GAUNTLET,   ## Guantelete infinito (poder supremo)

	# Hachas mágicas
	FIRE_AXE,            ## Hacha de fuego (quema árboles)
	ICE_AXE,             ## Hacha de hielo (congela)

	# Palas especiales
	EARTH_SHOVEL,        ## Pala de tierra (excava rápido)
	TELEPORT_SPADE       ## Pala de teletransporte
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DATOS DE HERRAMIENTAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const TOOL_DATA: Dictionary = {
	ToolType.WOODEN_PICKAXE: {
		"name": "🔨 Pico de Madera",
		"description": "Un pico básico pero confiable",
		"speed_multiplier": 2.0,
		"durability": 50,
		"glow_color": Color(0.6, 0.4, 0.2),  # Marrón claro
		"particle_color": Color(0.8, 0.6, 0.3),
		"special_ability": "",
		"tier": "common"
	},

	ToolType.STONE_PICKAXE: {
		"name": "⛏️ Pico de Piedra",
		"description": "Más duro y rápido",
		"speed_multiplier": 3.0,
		"durability": 100,
		"glow_color": Color(0.5, 0.5, 0.6),  # Gris azulado
		"particle_color": Color(0.7, 0.7, 0.8),
		"special_ability": "",
		"tier": "uncommon"
	},

	ToolType.IRON_PICKAXE: {
		"name": "⚒️ Pico de Hierro Brillante",
		"description": "Brilla con poder metálico",
		"speed_multiplier": 4.0,
		"durability": 200,
		"glow_color": Color(0.7, 0.7, 0.75),  # Plateado brillante
		"particle_color": Color(0.9, 0.9, 1.0),
		"special_ability": "glow",
		"tier": "rare"
	},

	ToolType.GOLDEN_PICKAXE: {
		"name": "💎 Pico de Oro Resplandeciente",
		"description": "Resplandece con luz dorada mágica",
		"speed_multiplier": 6.0,
		"durability": 500,
		"glow_color": Color(1.0, 0.84, 0.0),  # Dorado intenso
		"particle_color": Color(1.0, 1.0, 0.5),
		"special_ability": "golden_glow",
		"tier": "epic"
	},

	ToolType.DIAMOND_PICKAXE: {
		"name": "💠 Pico de Diamante Legendario",
		"description": "El pico definitivo, brilla como las estrellas",
		"speed_multiplier": 10.0,
		"durability": 1000,
		"glow_color": Color(0.3, 0.8, 1.0),  # Azul brillante
		"particle_color": Color(0.5, 1.0, 1.0),
		"special_ability": "rainbow_glow",
		"tier": "legendary"
	},

	ToolType.MAGIC_WAND: {
		"name": "🪄 Varita Mágica",
		"description": "Convierte bloques con magia",
		"speed_multiplier": 1.0,
		"durability": 999,
		"glow_color": Color(0.8, 0.3, 1.0),  # Púrpura mágico
		"particle_color": Color(1.0, 0.5, 1.0),
		"special_ability": "transmute",
		"tier": "epic"
	},

	ToolType.HAMMER_OF_THUNDER: {
		"name": "⚡ Martillo del Trueno",
		"description": "Rompe 3x3 bloques con el poder del rayo",
		"speed_multiplier": 5.0,
		"durability": 750,
		"glow_color": Color(1.0, 1.0, 0.3),  # Amarillo eléctrico
		"particle_color": Color(1.0, 1.0, 0.8),
		"special_ability": "area_break_3x3",
		"tier": "epic"
	},

	ToolType.STAFF_OF_LIGHT: {
		"name": "✨ Bastón de Luz",
		"description": "Ilumina y purifica todo a su paso",
		"speed_multiplier": 3.0,
		"durability": 999,
		"glow_color": Color(1.0, 1.0, 1.0),  # Blanco puro
		"particle_color": Color(1.0, 1.0, 0.9),
		"special_ability": "light_aura",
		"tier": "legendary"
	},

	ToolType.INFINITY_GAUNTLET: {
		"name": "♾️ Guantelete Infinito",
		"description": "Poder absoluto sobre la realidad",
		"speed_multiplier": 50.0,
		"durability": 9999,
		"glow_color": Color(0.5, 0.0, 1.0),  # Púrpura cósmico
		"particle_color": Color(1.0, 0.3, 1.0),
		"special_ability": "reality_warp",
		"tier": "divine"
	},

	ToolType.FIRE_AXE: {
		"name": "🔥 Hacha de Fuego",
		"description": "Quema árboles instantáneamente",
		"speed_multiplier": 5.0,
		"durability": 300,
		"glow_color": Color(1.0, 0.3, 0.0),  # Rojo fuego
		"particle_color": Color(1.0, 0.6, 0.0),
		"special_ability": "burn_trees",
		"tier": "rare"
	},

	ToolType.ICE_AXE: {
		"name": "❄️ Hacha de Hielo",
		"description": "Congela todo lo que toca",
		"speed_multiplier": 4.0,
		"durability": 300,
		"glow_color": Color(0.5, 0.8, 1.0),  # Azul hielo
		"particle_color": Color(0.7, 0.9, 1.0),
		"special_ability": "freeze",
		"tier": "rare"
	},

	ToolType.EARTH_SHOVEL: {
		"name": "🌍 Pala de Tierra",
		"description": "Excava tierra y arena a velocidad luz",
		"speed_multiplier": 8.0,
		"durability": 400,
		"glow_color": Color(0.4, 0.3, 0.2),  # Marrón tierra
		"particle_color": Color(0.6, 0.5, 0.3),
		"special_ability": "fast_dig",
		"tier": "epic"
	},

	ToolType.TELEPORT_SPADE: {
		"name": "🌀 Pala de Teletransporte",
		"description": "Teletransporta bloques a tu inventario",
		"speed_multiplier": 1.0,
		"durability": 200,
		"glow_color": Color(0.0, 1.0, 0.8),  # Turquesa
		"particle_color": Color(0.3, 1.0, 1.0),
		"special_ability": "teleport_blocks",
		"tier": "epic"
	}
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS ESTÁTICOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Obtiene datos de una herramienta
static func get_tool_data(tool_type: ToolType) -> Dictionary:
	return TOOL_DATA.get(tool_type, {})


## Obtiene el multiplicador de velocidad
static func get_speed_multiplier(tool_type: ToolType) -> float:
	var data = get_tool_data(tool_type)
	return data.get("speed_multiplier", 1.0)


## Obtiene el color de brillo
static func get_glow_color(tool_type: ToolType) -> Color:
	var data = get_tool_data(tool_type)
	return data.get("glow_color", Color.WHITE)


## Obtiene el color de partículas
static func get_particle_color(tool_type: ToolType) -> Color:
	var data = get_tool_data(tool_type)
	return data.get("particle_color", Color.WHITE)


## Verifica si tiene habilidad especial
static func has_special_ability(tool_type: ToolType, ability_name: String) -> bool:
	var data = get_tool_data(tool_type)
	return data.get("special_ability", "") == ability_name


## Aplica habilidad especial al romper bloque
static func apply_special_ability(tool_type: ToolType, world: Node3D, block_pos: Vector3i, player: Node3D) -> void:
	var data = get_tool_data(tool_type)
	var ability = data.get("special_ability", "")

	match ability:
		"area_break_3x3":
			_break_area_3x3(world, block_pos)
		"transmute":
			_transmute_block(world, block_pos)
		"light_aura":
			_create_light_aura(player)
		"reality_warp":
			_reality_warp(world, block_pos)
		"burn_trees":
			_burn_tree(world, block_pos)
		"freeze":
			_freeze_blocks(world, block_pos)
		"teleport_blocks":
			_teleport_block_to_inventory(world, block_pos)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HABILIDADES ESPECIALES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Rompe 3x3 bloques
static func _break_area_3x3(world: Node3D, center_pos: Vector3i) -> void:
	for x in range(-1, 2):
		for y in range(-1, 2):
			for z in range(-1, 2):
				var pos = center_pos + Vector3i(x, y, z)
				if world.has_method("remove_block"):
					world.remove_block(pos)

	# Explosión mágica amarilla (trueno)
	var world_pos = Vector3(center_pos) + Vector3(0.5, 0.5, 0.5)
	ParticleEffects.create_magic_explosion(world, world_pos, Color(1.0, 1.0, 0.3), 4.0)

	print("⚡ ¡MARTILLO DEL TRUENO! Área 3x3 destruida")
	AudioManager.play_sfx(Enums.SoundType.MAGIC_CAST)


## Transmuta bloque a oro
static func _transmute_block(world: Node3D, block_pos: Vector3i) -> void:
	if world.has_method("get_block") and world.has_method("place_block"):
		var current_block = world.get_block(block_pos)
		if current_block != Enums.BlockType.NONE and current_block != Enums.BlockType.ORO:
			world.place_block(block_pos, Enums.BlockType.ORO)

			# Partículas púrpuras mágicas de transmutación
			var world_pos = Vector3(block_pos) + Vector3(0.5, 0.5, 0.5)
			ParticleEffects.create_magic_explosion(world, world_pos, Color(0.8, 0.3, 1.0), 2.5)

			print("🪄 ¡TRANSMUTACIÓN! Bloque convertido a ORO")
			AudioManager.play_sfx(Enums.SoundType.MAGIC_CAST)


## Crea aura de luz
static func _create_light_aura(player: Node3D) -> void:
	# Crear aura mágica blanca alrededor del jugador
	ParticleEffects.create_magic_aura(player, Color(1.0, 1.0, 1.0), 2.0)

	# Añadir luz temporal
	var light = OmniLight3D.new()
	light.light_color = Color.WHITE
	light.light_energy = 2.0
	light.omni_range = 15.0
	player.add_child(light)

	# Eliminar la luz después de 5 segundos
	await player.get_tree().create_timer(5.0).timeout
	if is_instance_valid(light):
		light.queue_free()

	print("✨ ¡AURA DE LUZ ACTIVADA!")
	AudioManager.play_sfx(Enums.SoundType.MAGIC_CAST)


## Deformación de realidad - convierte bloques cercanos
static func _reality_warp(world: Node3D, block_pos: Vector3i) -> void:
	for x in range(-2, 3):
		for y in range(-2, 3):
			for z in range(-2, 3):
				var pos = block_pos + Vector3i(x, y, z)
				if world.has_method("place_block"):
					# Convertir aleatoriamente a bloques preciosos
					var random_block = [Enums.BlockType.ORO, Enums.BlockType.CRISTAL, Enums.BlockType.PLATA][randi() % 3]
					world.place_block(pos, random_block)

	# Gran explosión cósmica púrpura
	var world_pos = Vector3(block_pos) + Vector3(0.5, 0.5, 0.5)
	ParticleEffects.create_magic_explosion(world, world_pos, Color(0.5, 0.0, 1.0), 6.0)

	print("♾️ ¡DEFORMACIÓN DE REALIDAD! Bloques transformados")
	AudioManager.play_sfx(Enums.SoundType.MAGIC_CAST)


## Quema árbol completo
static func _burn_tree(world: Node3D, block_pos: Vector3i) -> void:
	# Explosión de fuego rojo-naranja
	var world_pos = Vector3(block_pos) + Vector3(0.5, 0.5, 0.5)
	ParticleEffects.create_magic_explosion(world, world_pos, Color(1.0, 0.3, 0.0), 3.0)

	# TODO: Detectar y quemar árbol completo
	print("🔥 ¡ÁRBOL QUEMADO!")
	AudioManager.play_sfx(Enums.SoundType.MAGIC_CAST)


## Congela bloques cercanos
static func _freeze_blocks(world: Node3D, block_pos: Vector3i) -> void:
	for x in range(-1, 2):
		for z in range(-1, 2):
			var pos = block_pos + Vector3i(x, 0, z)
			if world.has_method("place_block"):
				world.place_block(pos, Enums.BlockType.HIELO)

	# Explosión de hielo azul
	var world_pos = Vector3(block_pos) + Vector3(0.5, 0.5, 0.5)
	ParticleEffects.create_magic_explosion(world, world_pos, Color(0.5, 0.8, 1.0), 3.5)

	print("❄️ ¡CONGELACIÓN! Bloques convertidos a hielo")
	AudioManager.play_sfx(Enums.SoundType.MAGIC_CAST)


## Teletransporta bloque directamente al inventario
static func _teleport_block_to_inventory(world: Node3D, block_pos: Vector3i) -> void:
	if world.has_method("get_block") and world.has_method("remove_block"):
		var block_type = world.get_block(block_pos)
		if block_type != Enums.BlockType.NONE:
			world.remove_block(block_pos)

			# Efecto de teletransporte turquesa
			var world_pos = Vector3(block_pos) + Vector3(0.5, 0.5, 0.5)
			ParticleEffects.create_magic_explosion(world, world_pos, Color(0.0, 1.0, 0.8), 2.0)

			# Añadir al inventario directamente
			PlayerData.add_to_inventory(block_type, 1)
			print("🌀 ¡TELETRANSPORTADO! Bloque enviado al inventario")
			AudioManager.play_sfx(Enums.SoundType.MAGIC_CAST)
