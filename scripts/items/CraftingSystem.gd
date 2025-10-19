# ============================================================================
# CraftingSystem.gd - Sistema de Crafteo Mágico
# ============================================================================
# Crafteo épico con efectos visuales, partículas y recetas mágicas
# ============================================================================

extends Node
class_name CraftingSystem

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SEÑALES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Emitida cuando se craftea algo exitosamente
signal item_crafted(recipe_id: String, item_type)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RECETAS DE CRAFTEO
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const RECIPES: Dictionary = {
	# ═══════════════════════════════════════════════════════════════
	# HERRAMIENTAS BÁSICAS
	# ═══════════════════════════════════════════════════════════════

	"wooden_pickaxe": {
		"name": "🔨 Pico de Madera",
		"description": "Tu primera herramienta de minería",
		"result": MagicTool.ToolType.WOODEN_PICKAXE,
		"ingredients": {
			Enums.BlockType.MADERA: 3
		},
		"luz_cost": 0,
		"craft_time": 1.0,
		"tier": "common"
	},

	"stone_pickaxe": {
		"name": "⛏️ Pico de Piedra",
		"description": "Más duro y rápido",
		"result": MagicTool.ToolType.STONE_PICKAXE,
		"ingredients": {
			Enums.BlockType.PIEDRA: 3,
			Enums.BlockType.MADERA: 2
		},
		"luz_cost": 0,
		"craft_time": 1.5,
		"tier": "uncommon"
	},

	# ═══════════════════════════════════════════════════════════════
	# HERRAMIENTAS ÉPICAS (requieren Luz Interior)
	# ═══════════════════════════════════════════════════════════════

	"iron_pickaxe": {
		"name": "⚒️ Pico de Hierro Brillante",
		"description": "Brilla con poder metálico",
		"result": MagicTool.ToolType.IRON_PICKAXE,
		"ingredients": {
			Enums.BlockType.METAL: 3,
			Enums.BlockType.MADERA: 2
		},
		"luz_cost": 10,
		"craft_time": 2.0,
		"tier": "rare"
	},

	"golden_pickaxe": {
		"name": "💎 Pico de Oro Resplandeciente",
		"description": "Resplandece con luz dorada mágica",
		"result": MagicTool.ToolType.GOLDEN_PICKAXE,
		"ingredients": {
			Enums.BlockType.ORO: 3,
			Enums.BlockType.MADERA: 2,
			Enums.BlockType.CRISTAL: 1
		},
		"luz_cost": 50,
		"craft_time": 3.0,
		"tier": "epic"
	},

	"diamond_pickaxe": {
		"name": "💠 Pico de Diamante Legendario",
		"description": "El pico definitivo",
		"result": MagicTool.ToolType.DIAMOND_PICKAXE,
		"ingredients": {
			Enums.BlockType.CRISTAL: 5,
			Enums.BlockType.ORO: 3,
			Enums.BlockType.METAL: 2
		},
		"luz_cost": 100,
		"craft_time": 5.0,
		"tier": "legendary"
	},

	# ═══════════════════════════════════════════════════════════════
	# HERRAMIENTAS MÁGICAS
	# ═══════════════════════════════════════════════════════════════

	"magic_wand": {
		"name": "🪄 Varita Mágica",
		"description": "Convierte bloques con magia",
		"result": MagicTool.ToolType.MAGIC_WAND,
		"ingredients": {
			Enums.BlockType.MADERA: 1,
			Enums.BlockType.CRISTAL: 3,
			Enums.BlockType.ORO: 1
		},
		"luz_cost": 75,
		"craft_time": 4.0,
		"tier": "epic"
	},

	"hammer_of_thunder": {
		"name": "⚡ Martillo del Trueno",
		"description": "Rompe 3x3 bloques con el poder del rayo",
		"result": MagicTool.ToolType.HAMMER_OF_THUNDER,
		"ingredients": {
			Enums.BlockType.METAL: 5,
			Enums.BlockType.ORO: 3,
			Enums.BlockType.CRISTAL: 2
		},
		"luz_cost": 150,
		"craft_time": 6.0,
		"tier": "epic"
	},

	"staff_of_light": {
		"name": "✨ Bastón de Luz",
		"description": "Ilumina y purifica",
		"result": MagicTool.ToolType.STAFF_OF_LIGHT,
		"ingredients": {
			Enums.BlockType.MADERA: 3,
			Enums.BlockType.CRISTAL: 5,
			Enums.BlockType.ORO: 2
		},
		"luz_cost": 200,
		"craft_time": 7.0,
		"tier": "legendary"
	},

	"infinity_gauntlet": {
		"name": "♾️ Guantelete Infinito",
		"description": "Poder absoluto sobre la realidad",
		"result": MagicTool.ToolType.INFINITY_GAUNTLET,
		"ingredients": {
			Enums.BlockType.ORO: 5,
			Enums.BlockType.CRISTAL: 5,
			Enums.BlockType.PLATA: 3,
			Enums.BlockType.METAL: 3
		},
		"luz_cost": 500,
		"craft_time": 10.0,
		"tier": "divine"
	},

	# ═══════════════════════════════════════════════════════════════
	# HACHAS Y PALAS
	# ═══════════════════════════════════════════════════════════════

	"fire_axe": {
		"name": "🔥 Hacha de Fuego",
		"description": "Quema árboles instantáneamente",
		"result": MagicTool.ToolType.FIRE_AXE,
		"ingredients": {
			Enums.BlockType.METAL: 3,
			Enums.BlockType.MADERA: 2,
			Enums.BlockType.CRISTAL: 1
		},
		"luz_cost": 80,
		"craft_time": 3.0,
		"tier": "rare"
	},

	"ice_axe": {
		"name": "❄️ Hacha de Hielo",
		"description": "Congela todo lo que toca",
		"result": MagicTool.ToolType.ICE_AXE,
		"ingredients": {
			Enums.BlockType.METAL: 3,
			Enums.BlockType.MADERA: 2,
			Enums.BlockType.HIELO: 2
		},
		"luz_cost": 80,
		"craft_time": 3.0,
		"tier": "rare"
	},

	"earth_shovel": {
		"name": "🌍 Pala de Tierra",
		"description": "Excava tierra y arena a velocidad luz",
		"result": MagicTool.ToolType.EARTH_SHOVEL,
		"ingredients": {
			Enums.BlockType.METAL: 2,
			Enums.BlockType.MADERA: 2,
			Enums.BlockType.CRISTAL: 2
		},
		"luz_cost": 100,
		"craft_time": 4.0,
		"tier": "epic"
	},

	"teleport_spade": {
		"name": "🌀 Pala de Teletransporte",
		"description": "Teletransporta bloques a tu inventario",
		"result": MagicTool.ToolType.TELEPORT_SPADE,
		"ingredients": {
			Enums.BlockType.CRISTAL: 4,
			Enums.BlockType.ORO: 2,
			Enums.BlockType.PLATA: 2
		},
		"luz_cost": 120,
		"craft_time": 5.0,
		"tier": "epic"
	},

	# ═══════════════════════════════════════════════════════════════
	# CONVERSIONES DE BLOQUES
	# ═══════════════════════════════════════════════════════════════

	"wood_to_planks": {
		"name": "🪵 Tablas de Madera",
		"description": "Convierte madera en tablas",
		"result": Enums.BlockType.MADERA,
		"result_count": 4,
		"ingredients": {
			Enums.BlockType.MADERA: 1
		},
		"luz_cost": 0,
		"craft_time": 0.5,
		"tier": "common"
	},

	"stone_to_bricks": {
		"name": "🧱 Ladrillos de Piedra",
		"description": "Convierte piedra en ladrillos",
		"result": Enums.BlockType.PIEDRA,
		"result_count": 4,
		"ingredients": {
			Enums.BlockType.PIEDRA: 4
		},
		"luz_cost": 0,
		"craft_time": 1.0,
		"tier": "common"
	},

	"crystal_block": {
		"name": "💎 Bloque de Cristal Puro",
		"description": "Cristal refinado que brilla",
		"result": Enums.BlockType.CRISTAL,
		"result_count": 1,
		"ingredients": {
			Enums.BlockType.CRISTAL: 1,
			Enums.BlockType.ORO: 1
		},
		"luz_cost": 5,
		"craft_time": 2.0,
		"tier": "rare"
	}
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PÚBLICOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Verifica si una receta puede ser crafteada
static func can_craft(recipe_id: String) -> bool:
	var recipe = RECIPES.get(recipe_id)
	if not recipe:
		return false

	# Verificar ingredientes
	for block_type in recipe.ingredients:
		var required_amount = recipe.ingredients[block_type]
		var current_amount = PlayerData.inventory.get(block_type, 0)

		if current_amount < required_amount:
			return false

	# Verificar Luz Interior
	var luz_cost = recipe.get("luz_cost", 0)
	if PlayerData.luz_interior < luz_cost:
		return false

	return true


## Craftea un item si es posible
static func craft_item(recipe_id: String) -> bool:
	if not can_craft(recipe_id):
		print("❌ No puedes craftear esto aún")
		return false

	var recipe = RECIPES[recipe_id]

	# Consumir ingredientes
	for block_type in recipe.ingredients:
		var required_amount = recipe.ingredients[block_type]
		PlayerData.remove_from_inventory(block_type, required_amount)

	# Consumir Luz Interior
	var luz_cost = recipe.get("luz_cost", 0)
	if luz_cost > 0:
		PlayerData.add_luz(-luz_cost)

	# Dar resultado
	var result = recipe.result
	var result_count = recipe.get("result_count", 1)

	# Si es herramienta, añadirla al inventario de herramientas (futuro)
	# Por ahora, dar bloques si es BlockType
	if result is Enums.BlockType:
		PlayerData.add_to_inventory(result, result_count)

	# Efectos
	print("✨ ¡CRAFTEO EXITOSO! ", recipe.name)
	AudioManager.play_sfx(Enums.SoundType.MAGIC_CAST)

	# Logro
	AchievementSystem.increment_stat("items_crafted", 1)

	return true


## Obtiene información de una receta
static func get_recipe(recipe_id: String) -> Dictionary:
	return RECIPES.get(recipe_id, {})


## Obtiene todas las recetas desbloqueables (según tier)
static func get_available_recipes() -> Array[String]:
	var available: Array[String] = []

	for recipe_id in RECIPES:
		# Por ahora todas están disponibles
		# En el futuro podrías filtrar por nivel, logros, etc.
		available.append(recipe_id)

	return available


## Obtiene el color del tier
static func get_tier_color(tier: String) -> Color:
	match tier:
		"common":
			return Color(0.6, 0.6, 0.6)  # Gris
		"uncommon":
			return Color(0.3, 0.8, 0.3)  # Verde
		"rare":
			return Color(0.3, 0.6, 1.0)  # Azul
		"epic":
			return Color(0.7, 0.3, 1.0)  # Púrpura
		"legendary":
			return Color(1.0, 0.6, 0.0)  # Naranja
		"divine":
			return Color(1.0, 0.2, 0.2)  # Rojo brillante
		_:
			return Color.WHITE


## Obtiene la descripción de ingredientes
static func get_ingredients_text(recipe_id: String) -> String:
	var recipe = RECIPES.get(recipe_id)
	if not recipe:
		return ""

	var text = "Requiere:\n"

	for block_type in recipe.ingredients:
		var amount = recipe.ingredients[block_type]
		var block_name = Enums.BLOCK_NAMES.get(block_type, "???")
		var current = PlayerData.inventory.get(block_type, 0)

		var status = "✓" if current >= amount else "✗"
		text += "  %s %dx %s (%d/%d)\n" % [status, amount, block_name, current, amount]

	var luz_cost = recipe.get("luz_cost", 0)
	if luz_cost > 0:
		var status = "✓" if PlayerData.luz_interior >= luz_cost else "✗"
		text += "  %s %d Luz Interior (%d/%d)\n" % [status, luz_cost, PlayerData.luz_interior, luz_cost]

	return text


## Obtiene recetas por categoría
static func get_recipes_by_category() -> Dictionary:
	return {
		"Herramientas Básicas": [
			"wooden_pickaxe",
			"stone_pickaxe"
		],
		"Herramientas Épicas": [
			"iron_pickaxe",
			"golden_pickaxe",
			"diamond_pickaxe"
		],
		"Magia": [
			"magic_wand",
			"hammer_of_thunder",
			"staff_of_light",
			"infinity_gauntlet"
		],
		"Hachas y Palas": [
			"fire_axe",
			"ice_axe",
			"earth_shovel",
			"teleport_spade"
		],
		"Conversiones": [
			"wood_to_planks",
			"stone_to_bricks",
			"crystal_block"
		]
	}
