extends Node
## Sistema de Muebles y Artefactos Decorativos

signal furniture_placed(furniture_id: String, position: Vector3)
signal furniture_removed(furniture_id: String, position: Vector3)
signal furniture_interacted(furniture_id: String)

## Biblioteca de todos los muebles disponibles
var furniture_library: Dictionary = {}

## Muebles colocados en el mundo (posición → furniture_data)
var placed_furniture: Dictionary = {}

func _ready() -> void:
	_initialize_furniture_library()
	print("🪑 Sistema de Muebles inicializado - ", furniture_library.size(), " items disponibles")

## Inicializar todos los muebles
func _initialize_furniture_library() -> void:
	# ============================================================
	# MUEBLES BÁSICOS
	# ============================================================

	_add_furniture({
		"id": "bed_simple",
		"name": "Cama Simple",
		"description": "Una cama cómoda para dormir y restaurar energía",
		"icon": "🛏️",
		"category": FurnitureData.FurnitureCategory.BASIC_FURNITURE,
		"size": Vector3i(2, 1, 1),
		"interaction_type": FurnitureData.InteractionType.SLEEP,
		"interaction_text": "Dormir",
		"provides_buff": true,
		"buff_type": "sleep_heal",
		"buff_duration": 8.0,
		"craft": {"wood": 6, "wool": 3},
		"primary_color": Color(0.52, 0.37, 0.26),
		"secondary_color": Color(0.9, 0.2, 0.2)
	})

	_add_furniture({
		"id": "table_wood",
		"name": "Mesa de Madera",
		"description": "Mesa sólida para comer o trabajar",
		"icon": "🪵",
		"category": FurnitureData.FurnitureCategory.BASIC_FURNITURE,
		"size": Vector3i(2, 1, 1),
		"interaction_type": FurnitureData.InteractionType.NONE,
		"craft": {"wood": 4},
		"primary_color": Color(0.52, 0.37, 0.26)
	})

	_add_furniture({
		"id": "chair_wood",
		"name": "Silla de Madera",
		"description": "Silla cómoda para sentarse",
		"icon": "🪑",
		"category": FurnitureData.FurnitureCategory.BASIC_FURNITURE,
		"size": Vector3i(1, 2, 1),
		"interaction_type": FurnitureData.InteractionType.SIT,
		"interaction_text": "Sentarse",
		"craft": {"wood": 3},
		"primary_color": Color(0.52, 0.37, 0.26)
	})

	_add_furniture({
		"id": "sofa",
		"name": "Sofá",
		"description": "Sofá cómodo para 2 personas",
		"icon": "🛋️",
		"category": FurnitureData.FurnitureCategory.BASIC_FURNITURE,
		"size": Vector3i(3, 1, 1),
		"interaction_type": FurnitureData.InteractionType.SIT,
		"interaction_text": "Sentarse",
		"craft": {"wood": 6, "wool": 4},
		"primary_color": Color(0.3, 0.5, 0.7),
		"secondary_color": Color(0.52, 0.37, 0.26)
	})

	_add_furniture({
		"id": "desk",
		"name": "Escritorio",
		"description": "Escritorio para trabajar y estudiar",
		"icon": "🗄️",
		"category": FurnitureData.FurnitureCategory.BASIC_FURNITURE,
		"size": Vector3i(2, 1, 1),
		"interaction_type": FurnitureData.InteractionType.USE_WORKSTATION,
		"interaction_text": "Usar",
		"craft": {"wood": 5},
		"primary_color": Color(0.45, 0.32, 0.22)
	})

	# ============================================================
	# ALMACENAMIENTO
	# ============================================================

	_add_furniture({
		"id": "chest_wood",
		"name": "Cofre de Madera",
		"description": "Almacena hasta 18 items",
		"icon": "📦",
		"category": FurnitureData.FurnitureCategory.STORAGE,
		"size": Vector3i(1, 1, 1),
		"interaction_type": FurnitureData.InteractionType.OPEN_STORAGE,
		"interaction_text": "Abrir",
		"storage_slots": 18,
		"craft": {"wood": 8},
		"primary_color": Color(0.52, 0.37, 0.26)
	})

	_add_furniture({
		"id": "bookshelf",
		"name": "Estantería",
		"description": "Estante para libros y decoración",
		"icon": "📚",
		"category": FurnitureData.FurnitureCategory.STORAGE,
		"size": Vector3i(2, 2, 1),
		"is_wall_mounted": true,
		"interaction_type": FurnitureData.InteractionType.OPEN_STORAGE,
		"interaction_text": "Ver libros",
		"storage_slots": 9,
		"craft": {"wood": 6},
		"primary_color": Color(0.45, 0.32, 0.22)
	})

	_add_furniture({
		"id": "wardrobe",
		"name": "Armario",
		"description": "Guarda ropa y pertenencias",
		"icon": "🚪",
		"category": FurnitureData.FurnitureCategory.STORAGE,
		"size": Vector3i(2, 3, 1),
		"interaction_type": FurnitureData.InteractionType.OPEN_STORAGE,
		"interaction_text": "Abrir",
		"storage_slots": 27,
		"craft": {"wood": 12},
		"primary_color": Color(0.4, 0.28, 0.18)
	})

	# ============================================================
	# ILUMINACIÓN
	# ============================================================

	_add_furniture({
		"id": "lamp_floor",
		"name": "Lámpara de Pie",
		"description": "Ilumina tu hogar con estilo",
		"icon": "💡",
		"category": FurnitureData.FurnitureCategory.LIGHTING,
		"size": Vector3i(1, 2, 1),
		"interaction_type": FurnitureData.InteractionType.TURN_ON_OFF,
		"interaction_text": "Encender/Apagar",
		"emits_light": true,
		"light_color": Color(1.0, 0.9, 0.7),
		"light_energy": 2.0,
		"light_range": 8.0,
		"craft": {"wood": 2, "crystal": 1},
		"primary_color": Color(0.8, 0.8, 0.8)
	})

	_add_furniture({
		"id": "lamp_table",
		"name": "Lámpara de Mesa",
		"description": "Pequeña lámpara decorativa",
		"icon": "🕯️",
		"category": FurnitureData.FurnitureCategory.LIGHTING,
		"size": Vector3i(1, 1, 1),
		"interaction_type": FurnitureData.InteractionType.TURN_ON_OFF,
		"emits_light": true,
		"light_color": Color(1.0, 0.85, 0.6),
		"light_energy": 1.5,
		"light_range": 5.0,
		"craft": {"wood": 1, "crystal": 1},
		"primary_color": Color(0.9, 0.7, 0.3)
	})

	_add_furniture({
		"id": "torch_wall",
		"name": "Antorcha de Pared",
		"description": "Antorcha clásica para iluminar",
		"icon": "🔥",
		"category": FurnitureData.FurnitureCategory.LIGHTING,
		"size": Vector3i(1, 1, 1),
		"is_wall_mounted": true,
		"requires_floor": false,
		"emits_light": true,
		"light_color": Color(1.0, 0.6, 0.2),
		"light_energy": 2.5,
		"light_range": 6.0,
		"craft": {"wood": 1, "crystal": 1},
		"primary_color": Color(0.6, 0.3, 0.1)
	})

	# ============================================================
	# DECORACIÓN
	# ============================================================

	_add_furniture({
		"id": "potted_plant",
		"name": "Maceta con Planta",
		"description": "Planta decorativa que alegra el hogar",
		"icon": "🪴",
		"category": FurnitureData.FurnitureCategory.DECORATION,
		"size": Vector3i(1, 1, 1),
		"craft": {"stone": 2},
		"primary_color": Color(0.6, 0.4, 0.3),
		"secondary_color": Color(0.2, 0.6, 0.2)
	})

	_add_furniture({
		"id": "painting",
		"name": "Cuadro",
		"description": "Pintura decorativa para la pared",
		"icon": "🖼️",
		"category": FurnitureData.FurnitureCategory.DECORATION,
		"size": Vector3i(2, 2, 1),
		"is_wall_mounted": true,
		"requires_floor": false,
		"craft": {"wood": 4},
		"primary_color": Color(0.3, 0.2, 0.1)
	})

	_add_furniture({
		"id": "rug",
		"name": "Alfombra",
		"description": "Alfombra suave y decorativa",
		"icon": "🟥",
		"category": FurnitureData.FurnitureCategory.DECORATION,
		"size": Vector3i(2, 0, 2),
		"blocks_movement": false,
		"craft": {"wool": 6},
		"primary_color": Color(0.7, 0.2, 0.2)
	})

	_add_furniture({
		"id": "vase",
		"name": "Florero",
		"description": "Florero elegante con flores",
		"icon": "🏺",
		"category": FurnitureData.FurnitureCategory.DECORATION,
		"size": Vector3i(1, 1, 1),
		"craft": {"stone": 3},
		"primary_color": Color(0.9, 0.9, 0.9),
		"secondary_color": Color(1.0, 0.5, 0.8)
	})

	# ============================================================
	# COCINA
	# ============================================================

	_add_furniture({
		"id": "stove",
		"name": "Estufa",
		"description": "Cocina alimentos más rápido",
		"icon": "🍳",
		"category": FurnitureData.FurnitureCategory.KITCHEN,
		"size": Vector3i(1, 1, 1),
		"interaction_type": FurnitureData.InteractionType.USE_WORKSTATION,
		"interaction_text": "Cocinar",
		"emits_light": true,
		"light_color": Color(1.0, 0.5, 0.0),
		"light_energy": 1.0,
		"light_range": 3.0,
		"craft": {"stone": 8, "metal": 4},
		"primary_color": Color(0.3, 0.3, 0.3)
	})

	_add_furniture({
		"id": "fridge",
		"name": "Refrigerador",
		"description": "Preserva comida por más tiempo",
		"icon": "❄️",
		"category": FurnitureData.FurnitureCategory.KITCHEN,
		"size": Vector3i(1, 2, 1),
		"interaction_type": FurnitureData.InteractionType.OPEN_STORAGE,
		"interaction_text": "Abrir",
		"storage_slots": 18,
		"craft": {"metal": 10, "crystal": 2},
		"primary_color": Color(0.9, 0.9, 0.9)
	})

	_add_furniture({
		"id": "kitchen_table",
		"name": "Mesa de Cocina",
		"description": "Mesa pequeña para preparar comida",
		"icon": "🍽️",
		"category": FurnitureData.FurnitureCategory.KITCHEN,
		"size": Vector3i(1, 1, 1),
		"interaction_type": FurnitureData.InteractionType.USE_WORKSTATION,
		"interaction_text": "Preparar comida",
		"craft": {"wood": 4},
		"primary_color": Color(0.95, 0.95, 0.95)
	})

	# ============================================================
	# EDUCACIÓN
	# ============================================================

	_add_furniture({
		"id": "library",
		"name": "Biblioteca Grande",
		"description": "Almacena muchos libros y sabiduría",
		"icon": "📚",
		"category": FurnitureData.FurnitureCategory.EDUCATION,
		"size": Vector3i(3, 3, 1),
		"is_wall_mounted": true,
		"interaction_type": FurnitureData.InteractionType.READ,
		"interaction_text": "Leer",
		"provides_buff": true,
		"buff_type": "wisdom",
		"buff_duration": 60.0,
		"craft": {"wood": 15},
		"primary_color": Color(0.4, 0.3, 0.2)
	})

	_add_furniture({
		"id": "lectern",
		"name": "Atril con Libro",
		"description": "Libro abierto para leer",
		"icon": "📖",
		"category": FurnitureData.FurnitureCategory.EDUCATION,
		"size": Vector3i(1, 2, 1),
		"interaction_type": FurnitureData.InteractionType.READ,
		"interaction_text": "Leer",
		"craft": {"wood": 3},
		"primary_color": Color(0.5, 0.35, 0.25)
	})

## Añadir mueble a la biblioteca
func _add_furniture(data: Dictionary) -> void:
	var furniture = FurnitureData.new()

	furniture.furniture_id = data.get("id", "")
	furniture.furniture_name = data.get("name", "")
	furniture.description = data.get("description", "")
	furniture.icon = data.get("icon", "🪑")
	furniture.category = data.get("category", FurnitureData.FurnitureCategory.BASIC_FURNITURE)
	furniture.size = data.get("size", Vector3i(1, 1, 1))
	furniture.can_rotate = data.get("can_rotate", true)
	furniture.is_wall_mounted = data.get("is_wall_mounted", false)
	furniture.requires_floor = data.get("requires_floor", true)
	furniture.interaction_type = data.get("interaction_type", FurnitureData.InteractionType.NONE)
	furniture.interaction_text = data.get("interaction_text", "Usar")
	furniture.emits_light = data.get("emits_light", false)
	furniture.light_color = data.get("light_color", Color.WHITE)
	furniture.light_energy = data.get("light_energy", 1.0)
	furniture.light_range = data.get("light_range", 5.0)
	furniture.storage_slots = data.get("storage_slots", 0)
	furniture.provides_buff = data.get("provides_buff", false)
	furniture.buff_type = data.get("buff_type", "")
	furniture.buff_duration = data.get("buff_duration", 0.0)
	furniture.craft_requirements = data.get("craft", {})
	furniture.primary_color = data.get("primary_color", Color.WHITE)
	furniture.secondary_color = data.get("secondary_color", Color.WHITE)
	furniture.blocks_movement = data.get("blocks_movement", true)

	furniture_library[furniture.furniture_id] = furniture

## Obtener datos de un mueble
func get_furniture(furniture_id: String) -> FurnitureData:
	return furniture_library.get(furniture_id, null)

## Obtener todos los muebles
func get_all_furniture() -> Dictionary:
	return furniture_library

## Obtener muebles por categoría
func get_furniture_by_category(category: FurnitureData.FurnitureCategory) -> Array:
	var result = []
	for furniture_id in furniture_library:
		var furniture = furniture_library[furniture_id]
		if furniture.category == category:
			result.append(furniture)
	return result

## Verificar si se puede craftear
func can_craft(furniture_id: String) -> bool:
	var furniture = get_furniture(furniture_id)
	if furniture == null:
		return false

	for resource_name in furniture.craft_requirements:
		var required = furniture.craft_requirements[resource_name]
		var available = PlayerData.resources.get(resource_name, 0)
		if available < required:
			return false

	return true

## Craftear mueble
func craft_furniture(furniture_id: String) -> bool:
	if not can_craft(furniture_id):
		return false

	var furniture = get_furniture(furniture_id)

	# Consumir recursos
	for resource_name in furniture.craft_requirements:
		var required = furniture.craft_requirements[resource_name]
		PlayerData.add_resource(resource_name, -required)

	print("✅ Crafteado: ", furniture.furniture_name)

	# Logro
	if AchievementSystem:
		AchievementSystem.increment_stat("furniture_crafted", 1)

	return true

## Colocar mueble en el mundo
func place_furniture(furniture_id: String, world_position: Vector3, rotation: int = 0) -> bool:
	var furniture = get_furniture(furniture_id)
	if furniture == null:
		return false

	# Verificar colisión (simplificado por ahora)
	var pos_key = _vector_to_key(world_position)
	if pos_key in placed_furniture:
		print("❌ Ya hay un mueble en esta posición")
		return false

	placed_furniture[pos_key] = {
		"furniture_id": furniture_id,
		"rotation": rotation,
		"is_on": true  # Para lámparas
	}

	furniture_placed.emit(furniture_id, world_position)

	print("🪑 Mueble colocado: ", furniture.furniture_name)
	return true

## Remover mueble
func remove_furniture(world_position: Vector3) -> bool:
	var pos_key = _vector_to_key(world_position)
	if pos_key not in placed_furniture:
		return false

	var data = placed_furniture[pos_key]
	placed_furniture.erase(pos_key)

	furniture_removed.emit(data["furniture_id"], world_position)
	return true

## Interactuar con mueble
func interact_with_furniture(world_position: Vector3) -> void:
	var pos_key = _vector_to_key(world_position)
	if pos_key not in placed_furniture:
		return

	var data = placed_furniture[pos_key]
	var furniture = get_furniture(data["furniture_id"])

	if furniture == null:
		return

	match furniture.interaction_type:
		FurnitureData.InteractionType.SLEEP:
			_handle_sleep(furniture)
		FurnitureData.InteractionType.SIT:
			_handle_sit(furniture)
		FurnitureData.InteractionType.OPEN_STORAGE:
			_handle_storage(furniture, world_position)
		FurnitureData.InteractionType.READ:
			_handle_read(furniture)
		FurnitureData.InteractionType.TURN_ON_OFF:
			_handle_toggle_light(furniture, world_position)

	furniture_interacted.emit(data["furniture_id"])

## Manejar dormir
func _handle_sleep(_furniture: FurnitureData) -> void:
	print("💤 Durmiendo...")
	# Avanzar tiempo a mañana
	if has_node("/root/DayNightCycle"):
		get_node("/root/DayNightCycle").set_time(0.3)  # Mañana

	# Restaurar salud
	if PlayerData:
		PlayerData.health = PlayerData.max_health

	# Buff
	print("✅ ¡Descansaste bien! Salud restaurada")

## Manejar sentarse
func _handle_sit(furniture: FurnitureData) -> void:
	print("🪑 Sentándose en ", furniture.furniture_name)
	# TODO: Animación de sentarse

## Manejar almacenamiento
func _handle_storage(furniture: FurnitureData, _position: Vector3) -> void:
	print("📦 Abriendo ", furniture.furniture_name, " (", furniture.storage_slots, " slots)")
	# TODO: Abrir UI de inventario

## Manejar lectura
func _handle_read(furniture: FurnitureData) -> void:
	print("📖 Leyendo libro...")
	# Buff de sabiduría
	if furniture.provides_buff:
		print("✨ +", furniture.buff_type, " por ", furniture.buff_duration, "s")
		if VirtueSystem:
			VirtueSystem.add_luz_manual(5, "Leer libro")

## Manejar encender/apagar luz
func _handle_toggle_light(_furniture: FurnitureData, position: Vector3) -> void:
	var pos_key = _vector_to_key(position)
	var data = placed_furniture[pos_key]
	data["is_on"] = not data["is_on"]

	print("💡 Lámpara ", "encendida" if data["is_on"] else "apagada")

## Convertir vector a key de diccionario
func _vector_to_key(vec: Vector3) -> String:
	return "%d,%d,%d" % [int(vec.x), int(vec.y), int(vec.z)]
