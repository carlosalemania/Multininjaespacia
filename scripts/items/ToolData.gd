extends Resource
class_name ToolData
## Definición de datos de herramienta

enum ToolType {
	NONE,
	HAND,           # Mano (sin herramienta)
	WOODEN_PICKAXE, # Pico de madera
	STONE_PICKAXE,  # Pico de piedra
	GOLD_PICKAXE,   # Pico de oro
	DIAMOND_PICKAXE,# Pico de diamante
	WOODEN_AXE,     # Hacha de madera
	STONE_AXE,      # Hacha de piedra
	WOODEN_SHOVEL,  # Pala de madera
	STONE_SHOVEL    # Pala de piedra
}

@export var tool_id: String = ""
@export var tool_name: String = ""
@export var tool_type: ToolType = ToolType.NONE
@export var description: String = ""
@export var icon: String = "🔨"

## Multiplicador de velocidad (1.0 = normal, 2.0 = doble velocidad)
@export var speed_multiplier: float = 1.0

## Durabilidad máxima (usos antes de romperse, 0 = infinito)
@export var max_durability: int = 0

## Durabilidad actual
@export var current_durability: int = 0

## Bloques eficientes (tipos de bloque que rompe más rápido)
@export var efficient_blocks: Array = []

## Requisitos de crafteo
@export var craft_requirements: Dictionary = {}

## Modelo 3D procedul (se genera dinámicamente)
var mesh_instance: MeshInstance3D = null

func _init() -> void:
	current_durability = max_durability

## Usar herramienta (reduce durabilidad)
func use() -> bool:
	if max_durability == 0:
		return true # Infinito

	current_durability -= 1
	if current_durability <= 0:
		return false # Rota
	return true

## Reparar herramienta
func repair(amount: int = -1) -> void:
	if amount < 0:
		current_durability = max_durability
	else:
		current_durability = mini(current_durability + amount, max_durability)

## Obtener porcentaje de durabilidad
func get_durability_percent() -> float:
	if max_durability == 0:
		return 1.0
	return float(current_durability) / float(max_durability)

## Verificar si es eficiente contra un bloque
func is_efficient_for(block_type: Enums.BlockType) -> bool:
	return block_type in efficient_blocks
