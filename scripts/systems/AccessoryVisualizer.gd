extends Node
class_name AccessoryVisualizer
## Sistema para visualizar armas, herramientas y accesorios equipados

## Puntos de anclaje en el modelo humanoide
enum AttachPoint {
	RIGHT_HAND,      # Mano derecha (arma principal)
	LEFT_HAND,       # Mano izquierda (escudo, antorcha)
	BACK,            # Espalda (arma guardada)
	WAIST_LEFT,      # Cintura izquierda
	WAIST_RIGHT,     # Cintura derecha
	HEAD             # Cabeza (sombrero, casco)
}

## Nodo raíz del modelo (jugador o NPC)
var model_root: Node3D

## Accesorios actualmente equipados
var equipped_accessories: Dictionary = {}  # {AttachPoint: Node3D}

## Inicializar con el modelo del personaje
func initialize(character_model: Node3D) -> void:
	model_root = character_model
	_create_attach_points()

## Crear puntos de anclaje en el modelo
func _create_attach_points() -> void:
	if not model_root:
		return

	# Crear nodos marcadores para cada punto de anclaje
	var attach_points = {
		AttachPoint.RIGHT_HAND: Vector3(0.35, 0.6, 0.2),
		AttachPoint.LEFT_HAND: Vector3(-0.35, 0.6, 0.2),
		AttachPoint.BACK: Vector3(0, 0.5, -0.2),
		AttachPoint.WAIST_LEFT: Vector3(-0.3, 0.2, 0),
		AttachPoint.WAIST_RIGHT: Vector3(0.3, 0.2, 0),
		AttachPoint.HEAD: Vector3(0, 1.2, 0)
	}

	for point in attach_points:
		var marker = Node3D.new()
		marker.name = "AttachPoint_" + AttachPoint.keys()[point]
		marker.position = attach_points[point]
		model_root.add_child(marker)

## ============================================================================
## EQUIPAR ACCESORIOS
## ============================================================================

## Equipar arma en la mano
func equip_weapon(weapon_id: String, attach_point: AttachPoint = AttachPoint.RIGHT_HAND) -> void:
	# Desequipar anterior
	unequip_accessory(attach_point)

	# Obtener datos del arma
	var weapon_data = WeaponSystem.get_weapon(weapon_id)
	if not weapon_data:
		push_warning("Arma no encontrada: " + weapon_id)
		return

	# Generar modelo 3D del arma
	var weapon_model = _generate_weapon_model(weapon_data)
	if not weapon_model:
		return

	# Anclar al punto de attach
	_attach_accessory(weapon_model, attach_point)

	print("⚔️ Arma equipada: ", weapon_data.weapon_name, " en ", AttachPoint.keys()[attach_point])

## Equipar herramienta
func equip_tool(tool_id: String, attach_point: AttachPoint = AttachPoint.RIGHT_HAND) -> void:
	unequip_accessory(attach_point)

	var tool_data = ToolSystem.get_tool(tool_id) if ToolSystem else null
	if not tool_data:
		push_warning("Herramienta no encontrada: " + tool_id)
		return

	var tool_model = _generate_tool_model(tool_data)
	if not tool_model:
		return

	_attach_accessory(tool_model, attach_point)

	print("🔨 Herramienta equipada: ", tool_data.get("name", tool_id))

## Equipar accesorio genérico (antorcha, escudo, etc.)
func equip_accessory(accessory_id: String, attach_point: AttachPoint) -> void:
	unequip_accessory(attach_point)

	var accessory_model = _generate_accessory_model(accessory_id)
	if not accessory_model:
		return

	_attach_accessory(accessory_model, attach_point)

	print("✨ Accesorio equipado: ", accessory_id)

## Anclar accesorio al modelo
func _attach_accessory(accessory: Node3D, attach_point: AttachPoint) -> void:
	var marker_name = "AttachPoint_" + AttachPoint.keys()[attach_point]
	var marker = model_root.get_node_or_null(marker_name)

	if not marker:
		push_warning("Punto de anclaje no encontrado: " + marker_name)
		# Crear en posición por defecto
		marker = Node3D.new()
		marker.name = marker_name
		model_root.add_child(marker)

	marker.add_child(accessory)
	equipped_accessories[attach_point] = accessory

## Desequipar accesorio
func unequip_accessory(attach_point: AttachPoint) -> void:
	if equipped_accessories.has(attach_point):
		var accessory = equipped_accessories[attach_point]
		accessory.queue_free()
		equipped_accessories.erase(attach_point)

## Desequipar todo
func unequip_all() -> void:
	for point in equipped_accessories.keys():
		unequip_accessory(point)

## ============================================================================
## GENERADORES DE MODELOS 3D
## ============================================================================

## Generar modelo 3D de arma
func _generate_weapon_model(weapon_data: WeaponData) -> Node3D:
	if not WeaponModelGenerator:
		push_warning("WeaponModelGenerator no disponible")
		return null

	# Usar el generador de modelos de armas
	var model: Node3D = null

	match weapon_data.weapon_type:
		WeaponData.WeaponType.SWORD:
			model = WeaponModelGenerator.generate_sword(weapon_data)
		WeaponData.WeaponType.AXE:
			model = WeaponModelGenerator.generate_axe(weapon_data)
		WeaponData.WeaponType.DAGGER:
			model = WeaponModelGenerator.generate_dagger(weapon_data)
		WeaponData.WeaponType.SPEAR:
			model = WeaponModelGenerator.generate_spear(weapon_data)
		WeaponData.WeaponType.BOW:
			model = WeaponModelGenerator.generate_bow(weapon_data)
		WeaponData.WeaponType.CROSSBOW:
			model = WeaponModelGenerator.generate_crossbow(weapon_data)
		WeaponData.WeaponType.GUN:
			model = WeaponModelGenerator.generate_gun(weapon_data)
		WeaponData.WeaponType.MAGIC_STAFF:
			model = WeaponModelGenerator.generate_staff(weapon_data)
		WeaponData.WeaponType.HAMMER:
			model = WeaponModelGenerator.generate_hammer(weapon_data)
		WeaponData.WeaponType.MACE:
			model = WeaponModelGenerator.generate_mace(weapon_data)
		_:
			model = _generate_default_weapon()

	if model:
		model.name = "Weapon_" + weapon_data.weapon_id
		# Escalar y rotar para que se vea bien en la mano
		model.scale = Vector3(0.8, 0.8, 0.8)
		model.rotation_degrees = Vector3(45, 0, 0)  # Apuntando hacia adelante

	return model

## Generar modelo 3D de herramienta
func _generate_tool_model(tool_data: Dictionary) -> Node3D:
	if not ToolModelGenerator:
		push_warning("ToolModelGenerator no disponible")
		return _generate_default_tool()

	var tool_type = tool_data.get("type", "pickaxe")
	var model: Node3D = null

	match tool_type:
		"pickaxe":
			model = ToolModelGenerator.create_pickaxe(tool_data.get("tier", "wood"))
		"axe":
			model = ToolModelGenerator.create_axe(tool_data.get("tier", "wood"))
		"shovel":
			model = ToolModelGenerator.create_shovel(tool_data.get("tier", "wood"))
		"hoe":
			model = ToolModelGenerator.create_hoe(tool_data.get("tier", "wood"))
		_:
			model = _generate_default_tool()

	if model:
		model.scale = Vector3(0.7, 0.7, 0.7)
		model.rotation_degrees = Vector3(45, 0, 0)

	return model

## Generar modelo de accesorio
func _generate_accessory_model(accessory_id: String) -> Node3D:
	var model = Node3D.new()
	model.name = "Accessory_" + accessory_id

	match accessory_id:
		"torch":
			model = _create_torch()
		"shield_wood":
			model = _create_shield(Color(0.52, 0.37, 0.26))
		"shield_iron":
			model = _create_shield(Color(0.6, 0.6, 0.7))
		"lantern":
			model = _create_lantern()
		"backpack":
			model = _create_backpack()
		_:
			# Accesorio genérico
			var mesh_instance = MeshInstance3D.new()
			var box = BoxMesh.new()
			box.size = Vector3(0.1, 0.1, 0.1)
			mesh_instance.mesh = box
			model.add_child(mesh_instance)

	return model

## ============================================================================
## MODELOS DE ACCESORIOS ESPECÍFICOS
## ============================================================================

## Crear antorcha
func _create_torch() -> Node3D:
	var torch = Node3D.new()

	# Mango
	var handle = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.height = 0.5
	cylinder.top_radius = 0.02
	cylinder.bottom_radius = 0.02

	var wood_mat = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.4, 0.3, 0.2)
	cylinder.material = wood_mat

	handle.mesh = cylinder
	handle.position = Vector3(0, -0.25, 0)
	torch.add_child(handle)

	# Llama (cono naranja)
	var flame = MeshInstance3D.new()
	var cone = CylinderMesh.new()
	cone.height = 0.2
	cone.top_radius = 0.0
	cone.bottom_radius = 0.06

	var flame_mat = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.5, 0.1)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.5, 0.1)
	flame_mat.emission_energy_multiplier = 2.0
	cone.material = flame_mat

	flame.mesh = cone
	flame.position = Vector3(0, 0.1, 0)
	torch.add_child(flame)

	# Luz
	var light = OmniLight3D.new()
	light.light_color = Color(1.0, 0.6, 0.2)
	light.light_energy = 1.5
	light.omni_range = 4.0
	light.position = Vector3(0, 0.1, 0)
	torch.add_child(light)

	return torch

## Crear escudo
func _create_shield(color: Color) -> Node3D:
	var shield = Node3D.new()

	# Base del escudo (cilindro aplastado)
	var base = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.height = 0.05
	cylinder.top_radius = 0.25
	cylinder.bottom_radius = 0.25

	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = 0.3
	mat.roughness = 0.7
	cylinder.material = mat

	base.mesh = cylinder
	base.rotation_degrees = Vector3(90, 0, 0)
	shield.add_child(base)

	# Borde metálico
	var rim = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = 0.22
	torus.outer_radius = 0.25

	var metal_mat = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.7, 0.7, 0.8)
	metal_mat.metallic = 0.9
	torus.material = metal_mat

	rim.mesh = torus
	shield.add_child(rim)

	return shield

## Crear linterna
func _create_lantern() -> Node3D:
	var lantern = Node3D.new()

	# Cuerpo (caja pequeña)
	var body = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(0.12, 0.18, 0.12)

	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 0.3, 0.3)
	mat.metallic = 0.7
	box.material = mat

	body.mesh = box
	lantern.add_child(body)

	# Luz
	var light = OmniLight3D.new()
	light.light_color = Color(1.0, 0.9, 0.7)
	light.light_energy = 2.0
	light.omni_range = 6.0
	lantern.add_child(light)

	return lantern

## Crear mochila
func _create_backpack() -> Node3D:
	var backpack = Node3D.new()

	# Cuerpo principal
	var body = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(0.3, 0.4, 0.15)

	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.4, 0.3, 0.2)
	mat.roughness = 0.9
	box.material = mat

	body.mesh = box
	body.position = Vector3(0, 0, -0.1)
	backpack.add_child(body)

	return backpack

## ============================================================================
## MODELOS POR DEFECTO
## ============================================================================

func _generate_default_weapon() -> Node3D:
	var weapon = Node3D.new()

	# Espada simple
	var blade = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(0.05, 0.6, 0.02)

	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.8, 0.9)
	mat.metallic = 0.8
	box.material = mat

	blade.mesh = box
	blade.position = Vector3(0, 0.3, 0)
	weapon.add_child(blade)

	# Empuñadura
	var handle = MeshInstance3D.new()
	var handle_box = BoxMesh.new()
	handle_box.size = Vector3(0.03, 0.15, 0.03)

	var handle_mat = StandardMaterial3D.new()
	handle_mat.albedo_color = Color(0.3, 0.2, 0.1)
	handle_box.material = handle_mat

	handle.mesh = handle_box
	handle.position = Vector3(0, -0.1, 0)
	weapon.add_child(handle)

	return weapon

func _generate_default_tool() -> Node3D:
	var tool = Node3D.new()

	# Mango
	var handle = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.height = 0.5
	cylinder.top_radius = 0.02
	cylinder.bottom_radius = 0.02

	var wood_mat = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.5, 0.35, 0.2)
	cylinder.material = wood_mat

	handle.mesh = cylinder
	tool.add_child(handle)

	# Cabeza de herramienta
	var head = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(0.15, 0.08, 0.08)

	var metal_mat = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.6, 0.6, 0.7)
	metal_mat.metallic = 0.7
	box.material = metal_mat

	head.mesh = box
	head.position = Vector3(0, 0.3, 0)
	tool.add_child(head)

	return tool

## ============================================================================
## UTILIDADES
## ============================================================================

## Obtener accesorio equipado en un punto
func get_equipped_accessory(attach_point: AttachPoint) -> Node3D:
	return equipped_accessories.get(attach_point, null)

## Verificar si hay algo equipado en un punto
func has_accessory_equipped(attach_point: AttachPoint) -> bool:
	return equipped_accessories.has(attach_point)

## Obtener todos los accesorios equipados
func get_all_equipped() -> Dictionary:
	return equipped_accessories.duplicate()
