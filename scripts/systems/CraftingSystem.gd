extends Node
## Sistema de Crafteo - Maneja recetas y fabricación de items

signal item_crafted(item_name: String, quantity: int)
signal crafting_failed(reason: String)

## Recetas de crafteo disponibles
var recipes: Dictionary = {}

func _ready() -> void:
	_initialize_recipes()
	print("🔨 Sistema de Crafteo inicializado")

## Inicializar todas las recetas
func _initialize_recipes() -> void:
	# ============================================================
	# BLOQUES BÁSICOS
	# ============================================================

	recipes["planks"] = {
		"name": "Tablas de Madera",
		"output": {"block_type": Enums.BlockType.MADERA, "quantity": 4},
		"inputs": {
			"wood": 1
		},
		"icon": "🪵",
		"description": "Convierte madera en tablas útiles",
		"category": "blocks"
	}

	recipes["bricks"] = {
		"name": "Ladrillos",
		"output": {"item": "brick_block", "quantity": 1},
		"inputs": {
			"stone": 4
		},
		"icon": "🧱",
		"description": "Bloques de construcción resistentes",
		"category": "blocks"
	}

	recipes["glass_block"] = {
		"name": "Bloque de Cristal",
		"output": {"block_type": Enums.BlockType.CRISTAL, "quantity": 1},
		"inputs": {
			"sand": 2
		},
		"icon": "💎",
		"description": "Cristal transparente decorativo",
		"category": "blocks"
	}

	recipes["light_block"] = {
		"name": "Bloque Brillante",
		"output": {"item": "light_block", "quantity": 1},
		"inputs": {
			"gold": 1,
			"crystal": 1
		},
		"icon": "✨",
		"description": "Bloque que emite luz dorada",
		"category": "blocks"
	}

	# ============================================================
	# HERRAMIENTAS - PICOS
	# ============================================================

	recipes["wooden_pickaxe"] = {
		"name": "Pico de Madera",
		"output": {"tool": ToolData.ToolType.WOODEN_PICKAXE, "quantity": 1},
		"inputs": {
			"wood": 3
		},
		"icon": "⛏️",
		"description": "Pico básico, 2x velocidad en piedra",
		"category": "tools"
	}

	recipes["stone_pickaxe"] = {
		"name": "Pico de Piedra",
		"output": {"tool": ToolData.ToolType.STONE_PICKAXE, "quantity": 1},
		"inputs": {
			"stone": 3,
			"wood": 2
		},
		"icon": "⛏️",
		"description": "Pico resistente, 3x velocidad",
		"category": "tools"
	}

	recipes["gold_pickaxe"] = {
		"name": "Pico de Oro",
		"output": {"tool": ToolData.ToolType.GOLD_PICKAXE, "quantity": 1},
		"inputs": {
			"gold": 3,
			"wood": 2
		},
		"icon": "⛏️",
		"description": "Pico veloz, 5x velocidad",
		"category": "tools"
	}

	recipes["diamond_pickaxe"] = {
		"name": "Pico de Diamante",
		"output": {"tool": ToolData.ToolType.DIAMOND_PICKAXE, "quantity": 1},
		"inputs": {
			"crystal": 3,
			"wood": 2
		},
		"icon": "⛏️",
		"description": "Pico supremo, 7x velocidad",
		"category": "tools"
	}

	# ============================================================
	# HERRAMIENTAS - HACHAS
	# ============================================================

	recipes["wooden_axe"] = {
		"name": "Hacha de Madera",
		"output": {"tool": ToolData.ToolType.WOODEN_AXE, "quantity": 1},
		"inputs": {
			"wood": 3
		},
		"icon": "🪓",
		"description": "Hacha básica, 2.5x velocidad en madera",
		"category": "tools"
	}

	recipes["stone_axe"] = {
		"name": "Hacha de Piedra",
		"output": {"tool": ToolData.ToolType.STONE_AXE, "quantity": 1},
		"inputs": {
			"stone": 3,
			"wood": 2
		},
		"icon": "🪓",
		"description": "Hacha resistente, 4x velocidad",
		"category": "tools"
	}

	# ============================================================
	# HERRAMIENTAS - PALAS
	# ============================================================

	recipes["wooden_shovel"] = {
		"name": "Pala de Madera",
		"output": {"tool": ToolData.ToolType.WOODEN_SHOVEL, "quantity": 1},
		"inputs": {
			"wood": 2
		},
		"icon": "🔨",
		"description": "Pala básica, 2.5x velocidad en tierra",
		"category": "tools"
	}

	recipes["stone_shovel"] = {
		"name": "Pala de Piedra",
		"output": {"tool": ToolData.ToolType.STONE_SHOVEL, "quantity": 1},
		"inputs": {
			"stone": 2,
			"wood": 2
		},
		"icon": "🔨",
		"description": "Pala resistente, 4x velocidad",
		"category": "tools"
	}

	# ============================================================
	# DECORACIÓN
	# ============================================================

	recipes["torch"] = {
		"name": "Antorcha",
		"output": {"item": "torch", "quantity": 4},
		"inputs": {
			"wood": 1,
			"crystal": 1
		},
		"icon": "🔥",
		"description": "Fuente de luz portátil",
		"category": "decoration"
	}

	recipes["fence"] = {
		"name": "Valla",
		"output": {"item": "fence", "quantity": 3},
		"inputs": {
			"wood": 2
		},
		"icon": "🚧",
		"description": "Valla decorativa de madera",
		"category": "decoration"
	}

## Craftear un item
func craft(recipe_id: String) -> bool:
	if recipe_id not in recipes:
		crafting_failed.emit("Receta no encontrada")
		return false

	var recipe = recipes[recipe_id]

	# Verificar que el jugador tenga los recursos necesarios
	if not _has_required_resources(recipe):
		crafting_failed.emit("Recursos insuficientes")
		return false

	# Consumir recursos
	_consume_resources(recipe)

	# Crear item
	_create_output(recipe)

	var output_name = recipe.get("name", "Item")
	var output_qty = recipe.output.get("quantity", 1)

	print("✅ Crafteado: %dx %s" % [output_qty, output_name])
	item_crafted.emit(output_name, output_qty)

	# Logro de crafteo
	if AchievementSystem:
		AchievementSystem.increment_stat("items_crafted", 1)

	return true

## Verificar si el jugador tiene los recursos requeridos
func _has_required_resources(recipe: Dictionary) -> bool:
	var inputs = recipe.get("inputs", {})

	for resource_name in inputs:
		var required_amount = inputs[resource_name]
		var player_amount = PlayerData.resources.get(resource_name, 0)

		if player_amount < required_amount:
			return false

	return true

## Consumir recursos del jugador
func _consume_resources(recipe: Dictionary) -> void:
	var inputs = recipe.get("inputs", {})

	for resource_name in inputs:
		var required_amount = inputs[resource_name]
		PlayerData.add_resource(resource_name, -required_amount)

## Crear el output de la receta
func _create_output(recipe: Dictionary) -> void:
	var output = recipe.get("output", {})
	var quantity = output.get("quantity", 1)

	# Si es una herramienta
	if "tool" in output:
		var tool_type = output["tool"]
		if ToolSystem:
			ToolSystem.craft_tool(tool_type)

	# Si es un bloque
	elif "block_type" in output:
		var block_type = output["block_type"]
		# Añadir al inventario (TODO: integrar con sistema de inventario)
		print("  → Añadido al inventario: %dx bloque tipo %s" % [quantity, block_type])

	# Si es un item genérico
	elif "item" in output:
		var item_name = output["item"]
		print("  → Añadido al inventario: %dx %s" % [quantity, item_name])

## Obtener todas las recetas
func get_all_recipes() -> Dictionary:
	return recipes

## Obtener recetas por categoría
func get_recipes_by_category(category: String) -> Array:
	var filtered = []
	for recipe_id in recipes:
		var recipe = recipes[recipe_id]
		if recipe.get("category", "") == category:
			filtered.append({
				"id": recipe_id,
				"data": recipe
			})
	return filtered

## Verificar si se puede craftear
func can_craft(recipe_id: String) -> bool:
	if recipe_id not in recipes:
		return false

	return _has_required_resources(recipes[recipe_id])

## Obtener categorías disponibles
func get_categories() -> Array:
	var categories = []
	for recipe_id in recipes:
		var category = recipes[recipe_id].get("category", "misc")
		if category not in categories:
			categories.append(category)
	return categories
