extends Resource
class_name FurnitureData
## Datos de un artefacto/mueble decorativo o funcional

enum FurnitureCategory {
	BASIC_FURNITURE,    # Muebles básicos
	STORAGE,            # Almacenamiento
	LIGHTING,           # Iluminación
	DECORATION,         # Decoración
	KITCHEN,            # Cocina
	EDUCATION,          # Educación/Libros
	BATHROOM,           # Baño
	FARM,               # Granja
	ENTERTAINMENT,      # Entretenimiento
	RELIGIOUS,          # Religioso/Espiritual
	UTILITY             # Utilidad/Crafteo
}

enum InteractionType {
	NONE,               # No interactivo
	SIT,                # Sentarse
	SLEEP,              # Dormir
	OPEN_STORAGE,       # Abrir inventario
	USE_WORKSTATION,    # Usar estación de trabajo
	READ,               # Leer
	TURN_ON_OFF         # Encender/Apagar
}

@export var furniture_id: String = ""
@export var furniture_name: String = ""
@export var description: String = ""
@export var icon: String = "🪑"

## Categoría
@export var category: FurnitureCategory = FurnitureCategory.BASIC_FURNITURE

## Tamaño en bloques (ancho, alto, profundidad)
@export var size: Vector3i = Vector3i(1, 1, 1)

## Rotación
@export var can_rotate: bool = true
@export var rotation_steps: int = 4  # 4 = 90°, 8 = 45°, etc.

## Colocación
@export var is_wall_mounted: bool = false
@export var requires_floor: bool = true
@export var can_stack: bool = false

## Interacción
@export var interaction_type: InteractionType = InteractionType.NONE
@export var interaction_text: String = "Usar"

## Iluminación
@export var emits_light: bool = false
@export var light_color: Color = Color.WHITE
@export var light_energy: float = 1.0
@export var light_range: float = 5.0

## Almacenamiento (si aplica)
@export var storage_slots: int = 0

## Efectos/Buffs
@export var provides_buff: bool = false
@export var buff_type: String = ""
@export var buff_duration: float = 0.0

## Crafteo
@export var craft_requirements: Dictionary = {}
@export var unlock_requirement: String = ""  # Logro requerido

## Visual
@export var model_scale: Vector3 = Vector3.ONE
@export var primary_color: Color = Color.WHITE
@export var secondary_color: Color = Color.WHITE

## Sonido
@export var placement_sound: String = "place"
@export var interaction_sound: String = "use"

## Física
@export var is_solid: bool = true
@export var blocks_movement: bool = true
