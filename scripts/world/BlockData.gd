# ============================================================================
# BlockData.gd - Definición de Datos de Bloques (Resource)
# ============================================================================
# Resource que define las propiedades de cada tipo de bloque
# ============================================================================

extends Resource
class_name BlockData

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES EXPORTADAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Tipo de bloque
@export var block_type: Enums.BlockType = Enums.BlockType.TIERRA

## Nombre legible del bloque
@export var block_name: String = "Tierra"

## Color del bloque (para mesh generation)
@export var color: Color = Color(0.55, 0.35, 0.20)

## Dureza del bloque (tiempo para romper en segundos)
@export var hardness: float = 0.5

## ¿Es transparente? (como cristal)
@export var is_transparent: bool = false

## ¿Es sólido? (tiene colisión)
@export var is_solid: bool = true

## Textura del bloque (opcional, para futuro)
@export var texture: Texture2D = null

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS ESTÁTICOS (FACTORY)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Crea un BlockData desde un BlockType
static func create_from_type(type: Enums.BlockType) -> BlockData:
	var data = BlockData.new()
	data.block_type = type
	data.block_name = Enums.BLOCK_NAMES.get(type, "Desconocido")
	data.hardness = Enums.BLOCK_HARDNESS.get(type, 1.0)
	data.color = Utils.get_block_color(type)

	# Configurar transparencia
	if type == Enums.BlockType.CRISTAL:
		data.is_transparent = true

	return data


## Obtiene todas las definiciones de bloques
static func get_all_block_definitions() -> Dictionary:
	var definitions: Dictionary = {}

	for block_type in Enums.BlockType.values():
		if block_type == Enums.BlockType.NONE:
			continue
		definitions[block_type] = create_from_type(block_type)

	return definitions
