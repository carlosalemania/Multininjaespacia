extends Node
## Sistema de Herramientas - Gestiona herramientas disponibles y crafteo

signal tool_crafted(tool_type: ToolData.ToolType)
signal tool_broken(tool_type: ToolData.ToolType)

## Biblioteca de herramientas disponibles
var tools_library: Dictionary = {}

## Herramienta actualmente equipada
var equipped_tool: ToolData = null

func _ready() -> void:
	_initialize_tools()
	print("🔨 Sistema de Herramientas inicializado")

## Inicializar todas las herramientas disponibles
func _initialize_tools() -> void:
	# MANO (por defecto)
	var hand = ToolData.new()
	hand.tool_id = "hand"
	hand.tool_name = "Mano"
	hand.tool_type = ToolData.ToolType.HAND
	hand.description = "Tus manos, lentas pero efectivas"
	hand.icon = "✋"
	hand.speed_multiplier = 1.0
	hand.max_durability = 0 # Infinito
	tools_library[ToolData.ToolType.HAND] = hand

	# PICO DE MADERA
	var wooden_pickaxe = ToolData.new()
	wooden_pickaxe.tool_id = "wooden_pickaxe"
	wooden_pickaxe.tool_name = "Pico de Madera"
	wooden_pickaxe.tool_type = ToolData.ToolType.WOODEN_PICKAXE
	wooden_pickaxe.description = "Pico básico. Rompe piedra más rápido"
	wooden_pickaxe.icon = "⛏️"
	wooden_pickaxe.speed_multiplier = 2.0
	wooden_pickaxe.max_durability = 60
	wooden_pickaxe.current_durability = 60
	wooden_pickaxe.efficient_blocks = [Enums.BlockType.PIEDRA, Enums.BlockType.ORO, Enums.BlockType.PLATA]
	wooden_pickaxe.craft_requirements = {
		"wood": 3
	}
	tools_library[ToolData.ToolType.WOODEN_PICKAXE] = wooden_pickaxe

	# PICO DE PIEDRA
	var stone_pickaxe = ToolData.new()
	stone_pickaxe.tool_id = "stone_pickaxe"
	stone_pickaxe.tool_name = "Pico de Piedra"
	stone_pickaxe.tool_type = ToolData.ToolType.STONE_PICKAXE
	stone_pickaxe.description = "Pico resistente. 3x más rápido"
	stone_pickaxe.icon = "⛏️"
	stone_pickaxe.speed_multiplier = 3.0
	stone_pickaxe.max_durability = 132
	stone_pickaxe.current_durability = 132
	stone_pickaxe.efficient_blocks = [Enums.BlockType.PIEDRA, Enums.BlockType.ORO, Enums.BlockType.PLATA, Enums.BlockType.CRISTAL]
	stone_pickaxe.craft_requirements = {
		"stone": 3,
		"wood": 2
	}
	tools_library[ToolData.ToolType.STONE_PICKAXE] = stone_pickaxe

	# PICO DE ORO
	var gold_pickaxe = ToolData.new()
	gold_pickaxe.tool_id = "gold_pickaxe"
	gold_pickaxe.tool_name = "Pico de Oro"
	gold_pickaxe.tool_type = ToolData.ToolType.GOLD_PICKAXE
	gold_pickaxe.description = "Pico veloz. 5x más rápido"
	gold_pickaxe.icon = "⛏️"
	gold_pickaxe.speed_multiplier = 5.0
	gold_pickaxe.max_durability = 33
	gold_pickaxe.current_durability = 33
	gold_pickaxe.efficient_blocks = [Enums.BlockType.PIEDRA, Enums.BlockType.ORO, Enums.BlockType.PLATA, Enums.BlockType.CRISTAL]
	gold_pickaxe.craft_requirements = {
		"gold": 3,
		"wood": 2
	}
	tools_library[ToolData.ToolType.GOLD_PICKAXE] = gold_pickaxe

	# PICO DE DIAMANTE
	var diamond_pickaxe = ToolData.new()
	diamond_pickaxe.tool_id = "diamond_pickaxe"
	diamond_pickaxe.tool_name = "Pico de Diamante"
	diamond_pickaxe.tool_type = ToolData.ToolType.DIAMOND_PICKAXE
	diamond_pickaxe.description = "Pico supremo. 7x más rápido, ultra resistente"
	diamond_pickaxe.icon = "⛏️"
	diamond_pickaxe.speed_multiplier = 7.0
	diamond_pickaxe.max_durability = 1562
	diamond_pickaxe.current_durability = 1562
	diamond_pickaxe.efficient_blocks = [Enums.BlockType.PIEDRA, Enums.BlockType.ORO, Enums.BlockType.PLATA, Enums.BlockType.CRISTAL]
	diamond_pickaxe.craft_requirements = {
		"crystal": 3,
		"wood": 2
	}
	tools_library[ToolData.ToolType.DIAMOND_PICKAXE] = diamond_pickaxe

	# HACHA DE MADERA
	var wooden_axe = ToolData.new()
	wooden_axe.tool_id = "wooden_axe"
	wooden_axe.tool_name = "Hacha de Madera"
	wooden_axe.tool_type = ToolData.ToolType.WOODEN_AXE
	wooden_axe.description = "Hacha básica. Tala árboles más rápido"
	wooden_axe.icon = "🪓"
	wooden_axe.speed_multiplier = 2.5
	wooden_axe.max_durability = 60
	wooden_axe.current_durability = 60
	wooden_axe.efficient_blocks = [Enums.BlockType.MADERA, Enums.BlockType.HOJAS]
	wooden_axe.craft_requirements = {
		"wood": 3
	}
	tools_library[ToolData.ToolType.WOODEN_AXE] = wooden_axe

	# HACHA DE PIEDRA
	var stone_axe = ToolData.new()
	stone_axe.tool_id = "stone_axe"
	stone_axe.tool_name = "Hacha de Piedra"
	stone_axe.tool_type = ToolData.ToolType.STONE_AXE
	stone_axe.description = "Hacha resistente. 4x más rápido"
	stone_axe.icon = "🪓"
	stone_axe.speed_multiplier = 4.0
	stone_axe.max_durability = 132
	stone_axe.current_durability = 132
	stone_axe.efficient_blocks = [Enums.BlockType.MADERA, Enums.BlockType.HOJAS]
	stone_axe.craft_requirements = {
		"stone": 3,
		"wood": 2
	}
	tools_library[ToolData.ToolType.STONE_AXE] = stone_axe

	# PALA DE MADERA
	var wooden_shovel = ToolData.new()
	wooden_shovel.tool_id = "wooden_shovel"
	wooden_shovel.tool_name = "Pala de Madera"
	wooden_shovel.tool_type = ToolData.ToolType.WOODEN_SHOVEL
	wooden_shovel.description = "Pala básica. Excava tierra más rápido"
	wooden_shovel.icon = "🔨"
	wooden_shovel.speed_multiplier = 2.5
	wooden_shovel.max_durability = 60
	wooden_shovel.current_durability = 60
	wooden_shovel.efficient_blocks = [Enums.BlockType.TIERRA, Enums.BlockType.ARENA, Enums.BlockType.NIEVE, Enums.BlockType.CESPED]
	wooden_shovel.craft_requirements = {
		"wood": 2
	}
	tools_library[ToolData.ToolType.WOODEN_SHOVEL] = wooden_shovel

	# PALA DE PIEDRA
	var stone_shovel = ToolData.new()
	stone_shovel.tool_id = "stone_shovel"
	stone_shovel.tool_name = "Pala de Piedra"
	stone_shovel.tool_type = ToolData.ToolType.STONE_SHOVEL
	stone_shovel.description = "Pala resistente. 4x más rápido"
	stone_shovel.icon = "🔨"
	stone_shovel.speed_multiplier = 4.0
	stone_shovel.max_durability = 132
	stone_shovel.current_durability = 132
	stone_shovel.efficient_blocks = [Enums.BlockType.TIERRA, Enums.BlockType.ARENA, Enums.BlockType.NIEVE, Enums.BlockType.CESPED]
	stone_shovel.craft_requirements = {
		"stone": 2,
		"wood": 2
	}
	tools_library[ToolData.ToolType.STONE_SHOVEL] = stone_shovel

	# Equipar mano por defecto
	equipped_tool = hand

## Equipar herramienta
func equip_tool(tool_type: ToolData.ToolType) -> void:
	if tool_type in tools_library:
		equipped_tool = tools_library[tool_type]
		print("🔧 Equipada: ", equipped_tool.tool_name)
	else:
		push_error("Herramienta no encontrada: " + str(tool_type))

## Obtener herramienta equipada
func get_equipped_tool() -> ToolData:
	return equipped_tool

## Craftear herramienta
func craft_tool(tool_type: ToolData.ToolType) -> bool:
	if tool_type not in tools_library:
		print("❌ Herramienta no existe")
		return false

	var tool_template = tools_library[tool_type]

	# Verificar recursos
	var has_resources = true
	for resource_name in tool_template.craft_requirements:
		var required_amount = tool_template.craft_requirements[resource_name]
		var player_amount = PlayerData.resources.get(resource_name, 0)

		if player_amount < required_amount:
			print("❌ Faltan recursos: ", resource_name, " (tienes ", player_amount, ", necesitas ", required_amount, ")")
			has_resources = false
			break

	if not has_resources:
		return false

	# Consumir recursos
	for resource_name in tool_template.craft_requirements:
		var required_amount = tool_template.craft_requirements[resource_name]
		PlayerData.add_resource(resource_name, -required_amount)

	# Crear nueva instancia de herramienta (con durabilidad completa)
	var new_tool = tool_template.duplicate(true)
	new_tool.current_durability = new_tool.max_durability

	# Añadir al inventario del jugador (TODO: integrar con inventario)
	print("✅ Crafteada: ", new_tool.tool_name)

	tool_crafted.emit(tool_type)

	# Auto-equipar si no hay herramienta equipada
	if equipped_tool == null or equipped_tool.tool_type == ToolData.ToolType.HAND:
		equip_tool(tool_type)

	return true

## Usar herramienta actual (gastar durabilidad)
func use_equipped_tool() -> void:
	if equipped_tool == null:
		return

	if not equipped_tool.use():
		print("💥 ¡Herramienta rota! ", equipped_tool.tool_name)
		tool_broken.emit(equipped_tool.tool_type)
		# Volver a mano
		equip_tool(ToolData.ToolType.HAND)

## Calcular tiempo de rotura considerando herramienta
func calculate_break_time(block_type: Enums.BlockType, base_hardness: float) -> float:
	if equipped_tool == null:
		return base_hardness

	var break_time = base_hardness

	# Si la herramienta es eficiente, aplicar multiplicador
	if equipped_tool.is_efficient_for(block_type):
		break_time /= equipped_tool.speed_multiplier
	else:
		# Si no es eficiente, solo un pequeño beneficio
		break_time /= (equipped_tool.speed_multiplier * 0.3)

	return max(break_time, 0.1) # Mínimo 0.1 segundos

## Obtener todas las herramientas
func get_all_tools() -> Dictionary:
	return tools_library

## Verificar si se puede craftear
func can_craft(tool_type: ToolData.ToolType) -> bool:
	if tool_type not in tools_library:
		return false

	var tool_template = tools_library[tool_type]

	for resource_name in tool_template.craft_requirements:
		var required_amount = tool_template.craft_requirements[resource_name]
		var player_amount = PlayerData.resources.get(resource_name, 0)

		if player_amount < required_amount:
			return false

	return true
