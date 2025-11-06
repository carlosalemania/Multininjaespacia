extends Node
class_name FurnitureModelGenerator
## Generador de modelos 3D procedurales para muebles y artefactos

## Generar modelo según ID de mueble
static func generate_furniture_model(furniture_data: FurnitureData) -> Node3D:
	match furniture_data.furniture_id:
		# Muebles básicos
		"bed_simple":
			return _generate_bed(furniture_data)
		"table_wood":
			return _generate_table(furniture_data)
		"chair_wood":
			return _generate_chair(furniture_data)
		"sofa":
			return _generate_sofa(furniture_data)
		"desk":
			return _generate_desk(furniture_data)

		# Almacenamiento
		"chest_wood":
			return _generate_chest(furniture_data)
		"bookshelf":
			return _generate_bookshelf(furniture_data)
		"wardrobe":
			return _generate_wardrobe(furniture_data)

		# Iluminación
		"lamp_floor":
			return _generate_floor_lamp(furniture_data)
		"lamp_table":
			return _generate_table_lamp(furniture_data)
		"torch_wall":
			return _generate_wall_torch(furniture_data)

		# Decoración
		"potted_plant":
			return _generate_potted_plant(furniture_data)
		"painting":
			return _generate_painting(furniture_data)
		"rug":
			return _generate_rug(furniture_data)
		"vase":
			return _generate_vase(furniture_data)

		# Cocina
		"stove":
			return _generate_stove(furniture_data)
		"fridge":
			return _generate_fridge(furniture_data)
		"kitchen_table":
			return _generate_kitchen_table(furniture_data)

		# Educación
		"library":
			return _generate_library(furniture_data)
		"lectern":
			return _generate_lectern(furniture_data)

		_:
			return _generate_placeholder(furniture_data)

## ============================================================
## MUEBLES BÁSICOS
## ============================================================

## Generar cama
static func _generate_bed(furniture_data: FurnitureData) -> Node3D:
	var root = Node3D.new()
	root.name = "Bed"

	# Marco de cama (madera)
	var frame = MeshInstance3D.new()
	var frame_box = BoxMesh.new()
	frame_box.size = Vector3(2.0, 0.3, 1.0)

	var frame_material = StandardMaterial3D.new()
	frame_material.albedo_color = furniture_data.primary_color
	frame_material.roughness = 0.9
	frame_box.material = frame_material

	frame.mesh = frame_box
	frame.position = Vector3(0, 0.15, 0)
	root.add_child(frame)

	# Colchón (tela)
	var mattress = MeshInstance3D.new()
	var mattress_box = BoxMesh.new()
	mattress_box.size = Vector3(1.9, 0.4, 0.9)

	var mattress_material = StandardMaterial3D.new()
	mattress_material.albedo_color = furniture_data.secondary_color
	mattress_material.roughness = 0.95
	mattress_box.material = mattress_material

	mattress.mesh = mattress_box
	mattress.position = Vector3(0, 0.5, 0)
	root.add_child(mattress)

	# Almohada
	var pillow = MeshInstance3D.new()
	var pillow_box = BoxMesh.new()
	pillow_box.size = Vector3(0.5, 0.2, 0.3)

	var pillow_material = StandardMaterial3D.new()
	pillow_material.albedo_color = Color(0.95, 0.95, 0.95)
	pillow_material.roughness = 0.9
	pillow_box.material = pillow_material

	pillow.mesh = pillow_box
	pillow.position = Vector3(-0.6, 0.8, 0)
	root.add_child(pillow)

	return root

## Generar mesa
static func _generate_table(furniture_data: FurnitureData) -> Node3D:
	var root = Node3D.new()
	root.name = "Table"

	var wood_material = _create_wood_material(furniture_data.primary_color)

	# Superficie
	var top = MeshInstance3D.new()
	var top_box = BoxMesh.new()
	top_box.size = Vector3(2.0, 0.1, 1.0)
	top_box.material = wood_material

	top.mesh = top_box
	top.position = Vector3(0, 0.75, 0)
	root.add_child(top)

	# 4 patas
	var leg_positions = [
		Vector3(-0.8, 0.35, -0.4),
		Vector3(0.8, 0.35, -0.4),
		Vector3(-0.8, 0.35, 0.4),
		Vector3(0.8, 0.35, 0.4)
	]

	for leg_pos in leg_positions:
		var leg = MeshInstance3D.new()
		var leg_cylinder = CylinderMesh.new()
		leg_cylinder.top_radius = 0.05
		leg_cylinder.bottom_radius = 0.05
		leg_cylinder.height = 0.7
		leg_cylinder.material = wood_material

		leg.mesh = leg_cylinder
		leg.position = leg_pos
		root.add_child(leg)

	return root

## Generar silla
static func _generate_chair(furniture_data: FurnitureData) -> Node3D:
	var root = Node3D.new()
	root.name = "Chair"

	var wood_material = _create_wood_material(furniture_data.primary_color)

	# Asiento
	var seat = MeshInstance3D.new()
	var seat_box = BoxMesh.new()
	seat_box.size = Vector3(0.5, 0.1, 0.5)
	seat_box.material = wood_material

	seat.mesh = seat_box
	seat.position = Vector3(0, 0.5, 0)
	root.add_child(seat)

	# Respaldo
	var backrest = MeshInstance3D.new()
	var backrest_box = BoxMesh.new()
	backrest_box.size = Vector3(0.5, 0.6, 0.1)
	backrest_box.material = wood_material

	backrest.mesh = backrest_box
	backrest.position = Vector3(0, 0.85, -0.2)
	root.add_child(backrest)

	# 4 patas
	var leg_positions = [
		Vector3(-0.2, 0.2, -0.2),
		Vector3(0.2, 0.2, -0.2),
		Vector3(-0.2, 0.2, 0.2),
		Vector3(0.2, 0.2, 0.2)
	]

	for leg_pos in leg_positions:
		var leg = MeshInstance3D.new()
		var leg_cylinder = CylinderMesh.new()
		leg_cylinder.top_radius = 0.04
		leg_cylinder.bottom_radius = 0.04
		leg_cylinder.height = 0.4
		leg_cylinder.material = wood_material

		leg.mesh = leg_cylinder
		leg.position = leg_pos
		root.add_child(leg)

	return root

## Generar sofá
static func _generate_sofa(furniture_data: FurnitureData) -> Node3D:
	var root = Node3D.new()
	root.name = "Sofa"

	# Base del sofá
	var base = MeshInstance3D.new()
	var base_box = BoxMesh.new()
	base_box.size = Vector3(3.0, 0.5, 1.0)

	var fabric_material = StandardMaterial3D.new()
	fabric_material.albedo_color = furniture_data.primary_color
	fabric_material.roughness = 0.9
	base_box.material = fabric_material

	base.mesh = base_box
	base.position = Vector3(0, 0.3, 0)
	root.add_child(base)

	# Respaldo
	var backrest = MeshInstance3D.new()
	var backrest_box = BoxMesh.new()
	backrest_box.size = Vector3(3.0, 0.6, 0.2)
	backrest_box.material = fabric_material

	backrest.mesh = backrest_box
	backrest.position = Vector3(0, 0.8, -0.4)
	root.add_child(backrest)

	# Reposabrazos izquierdo
	var armrest_left = MeshInstance3D.new()
	var armrest_box = BoxMesh.new()
	armrest_box.size = Vector3(0.2, 0.5, 1.0)
	armrest_box.material = fabric_material

	armrest_left.mesh = armrest_box
	armrest_left.position = Vector3(-1.4, 0.6, 0)
	root.add_child(armrest_left)

	# Reposabrazos derecho
	var armrest_right = armrest_left.duplicate()
	armrest_right.position = Vector3(1.4, 0.6, 0)
	root.add_child(armrest_right)

	# Patas de madera
	var wood_material = _create_wood_material(furniture_data.secondary_color)

	var leg_positions = [
		Vector3(-1.3, 0.1, -0.4),
		Vector3(1.3, 0.1, -0.4),
		Vector3(-1.3, 0.1, 0.4),
		Vector3(1.3, 0.1, 0.4)
	]

	for leg_pos in leg_positions:
		var leg = MeshInstance3D.new()
		var leg_cylinder = CylinderMesh.new()
		leg_cylinder.top_radius = 0.06
		leg_cylinder.bottom_radius = 0.06
		leg_cylinder.height = 0.2
		leg_cylinder.material = wood_material

		leg.mesh = leg_cylinder
		leg.position = leg_pos
		root.add_child(leg)

	return root

## Generar escritorio
static func _generate_desk(furniture_data: FurnitureData) -> Node3D:
	var root = Node3D.new()
	root.name = "Desk"

	var wood_material = _create_wood_material(furniture_data.primary_color)

	# Superficie
	var top = MeshInstance3D.new()
	var top_box = BoxMesh.new()
	top_box.size = Vector3(2.0, 0.1, 0.8)
	top_box.material = wood_material

	top.mesh = top_box
	top.position = Vector3(0, 0.75, 0)
	root.add_child(top)

	# Patas (solo 2 laterales para espacio de piernas)
	var left_leg = MeshInstance3D.new()
	var leg_box = BoxMesh.new()
	leg_box.size = Vector3(0.1, 0.7, 0.7)
	leg_box.material = wood_material

	left_leg.mesh = leg_box
	left_leg.position = Vector3(-0.9, 0.35, 0)
	root.add_child(left_leg)

	var right_leg = left_leg.duplicate()
	right_leg.position = Vector3(0.9, 0.35, 0)
	root.add_child(right_leg)

	# Cajón
	var drawer = MeshInstance3D.new()
	var drawer_box = BoxMesh.new()
	drawer_box.size = Vector3(0.8, 0.15, 0.6)

	var drawer_material = _create_wood_material(furniture_data.primary_color.darkened(0.2))
	drawer_box.material = drawer_material

	drawer.mesh = drawer_box
	drawer.position = Vector3(-0.5, 0.5, 0)
	root.add_child(drawer)

	return root

## ============================================================
## ALMACENAMIENTO
## ============================================================

## Generar cofre
static func _generate_chest(furniture_data: FurnitureData) -> Node3D:
	var root = Node3D.new()
	root.name = "Chest"

	var wood_material = _create_wood_material(furniture_data.primary_color)

	# Base del cofre
	var base = MeshInstance3D.new()
	var base_box = BoxMesh.new()
	base_box.size = Vector3(1.0, 0.6, 0.6)
	base_box.material = wood_material

	base.mesh = base_box
	base.position = Vector3(0, 0.3, 0)
	root.add_child(base)

	# Tapa del cofre
	var lid = MeshInstance3D.new()
	var lid_box = BoxMesh.new()
	lid_box.size = Vector3(1.0, 0.3, 0.6)

	var lid_material = _create_wood_material(furniture_data.primary_color.lightened(0.1))
	lid_box.material = lid_material

	lid.mesh = lid_box
	lid.position = Vector3(0, 0.75, 0)
	root.add_child(lid)

	# Cerradura (metal)
	var lock = MeshInstance3D.new()
	var lock_box = BoxMesh.new()
	lock_box.size = Vector3(0.15, 0.15, 0.05)

	var metal_material = StandardMaterial3D.new()
	metal_material.albedo_color = Color(0.7, 0.7, 0.2)
	metal_material.metallic = 0.8
	metal_material.roughness = 0.3
	lock_box.material = metal_material

	lock.mesh = lock_box
	lock.position = Vector3(0, 0.4, 0.33)
	root.add_child(lock)

	return root

## Generar estantería
static func _generate_bookshelf(furniture_data: FurnitureData) -> Node3D:
	var root = Node3D.new()
	root.name = "Bookshelf"

	var wood_material = _create_wood_material(furniture_data.primary_color)

	# Marco
	var frame = MeshInstance3D.new()
	var frame_box = BoxMesh.new()
	frame_box.size = Vector3(2.0, 2.0, 0.3)
	frame_box.material = wood_material

	frame.mesh = frame_box
	frame.position = Vector3(0, 1.0, 0)
	root.add_child(frame)

	# 3 estantes internos
	for i in range(4):
		var shelf = MeshInstance3D.new()
		var shelf_box = BoxMesh.new()
		shelf_box.size = Vector3(1.9, 0.05, 0.25)
		shelf_box.material = wood_material

		shelf.mesh = shelf_box
		shelf.position = Vector3(0, 0.1 + i * 0.6, 0)
		root.add_child(shelf)

	# Libros (decorativos)
	for shelf_idx in range(3):
		for book_idx in range(5):
			var book = _create_book(
				Vector3(-0.8 + book_idx * 0.4, 0.35 + shelf_idx * 0.6, 0.08),
				Color(randf(), randf(), randf())
			)
			root.add_child(book)

	return root

## Generar armario
static func _generate_wardrobe(furniture_data: FurnitureData) -> Node3D:
	var root = Node3D.new()
	root.name = "Wardrobe"

	var wood_material = _create_wood_material(furniture_data.primary_color)

	# Cuerpo principal
	var body = MeshInstance3D.new()
	var body_box = BoxMesh.new()
	body_box.size = Vector3(2.0, 3.0, 0.8)
	body_box.material = wood_material

	body.mesh = body_box
	body.position = Vector3(0, 1.5, 0)
	root.add_child(body)

	# Puertas (2)
	var door_material = _create_wood_material(furniture_data.primary_color.lightened(0.1))

	var left_door = MeshInstance3D.new()
	var door_box = BoxMesh.new()
	door_box.size = Vector3(0.95, 2.8, 0.1)
	door_box.material = door_material

	left_door.mesh = door_box
	left_door.position = Vector3(-0.5, 1.5, 0.45)
	root.add_child(left_door)

	var right_door = left_door.duplicate()
	right_door.position = Vector3(0.5, 1.5, 0.45)
	root.add_child(right_door)

	# Manijas
	var handle_material = StandardMaterial3D.new()
	handle_material.albedo_color = Color(0.8, 0.8, 0.8)
	handle_material.metallic = 0.7

	var left_handle = MeshInstance3D.new()
	var handle_sphere = SphereMesh.new()
	handle_sphere.radius = 0.05
	handle_sphere.material = handle_material

	left_handle.mesh = handle_sphere
	left_handle.position = Vector3(-0.2, 1.5, 0.55)
	root.add_child(left_handle)

	var right_handle = left_handle.duplicate()
	right_handle.position = Vector3(0.2, 1.5, 0.55)
	root.add_child(right_handle)

	return root

## ============================================================
## ILUMINACIÓN
## ============================================================

## Generar lámpara de pie
static func _generate_floor_lamp(furniture_data: FurnitureData) -> Node3D:
	var root = Node3D.new()
	root.name = "FloorLamp"

	# Poste
	var pole = MeshInstance3D.new()
	var pole_cylinder = CylinderMesh.new()
	pole_cylinder.top_radius = 0.03
	pole_cylinder.bottom_radius = 0.05
	pole_cylinder.height = 1.8

	var pole_material = StandardMaterial3D.new()
	pole_material.albedo_color = furniture_data.primary_color
	pole_material.metallic = 0.5
	pole_material.roughness = 0.4
	pole_cylinder.material = pole_material

	pole.mesh = pole_cylinder
	pole.position = Vector3(0, 0.9, 0)
	root.add_child(pole)

	# Pantalla
	var shade = MeshInstance3D.new()
	var shade_cylinder = CylinderMesh.new()
	shade_cylinder.top_radius = 0.3
	shade_cylinder.bottom_radius = 0.4
	shade_cylinder.height = 0.4

	var shade_material = StandardMaterial3D.new()
	shade_material.albedo_color = Color(0.95, 0.9, 0.8)
	shade_material.roughness = 0.8
	shade_cylinder.material = shade_material

	shade.mesh = shade_cylinder
	shade.position = Vector3(0, 1.9, 0)
	root.add_child(shade)

	# Luz
	if furniture_data.emits_light:
		var light = OmniLight3D.new()
		light.light_color = furniture_data.light_color
		light.light_energy = furniture_data.light_energy
		light.omni_range = furniture_data.light_range
		light.position = Vector3(0, 1.9, 0)
		root.add_child(light)

	return root

## Generar lámpara de mesa
static func _generate_table_lamp(furniture_data: FurnitureData) -> Node3D:
	var root = Node3D.new()
	root.name = "TableLamp"

	# Base
	var base = MeshInstance3D.new()
	var base_cylinder = CylinderMesh.new()
	base_cylinder.top_radius = 0.15
	base_cylinder.bottom_radius = 0.2
	base_cylinder.height = 0.1

	var base_material = StandardMaterial3D.new()
	base_material.albedo_color = furniture_data.primary_color
	base_material.roughness = 0.6
	base_cylinder.material = base_material

	base.mesh = base_cylinder
	base.position = Vector3(0, 0.05, 0)
	root.add_child(base)

	# Poste
	var pole = MeshInstance3D.new()
	var pole_cylinder = CylinderMesh.new()
	pole_cylinder.top_radius = 0.03
	pole_cylinder.bottom_radius = 0.03
	pole_cylinder.height = 0.4
	pole_cylinder.material = base_material

	pole.mesh = pole_cylinder
	pole.position = Vector3(0, 0.3, 0)
	root.add_child(pole)

	# Pantalla
	var shade = MeshInstance3D.new()
	var shade_cylinder = CylinderMesh.new()
	shade_cylinder.top_radius = 0.15
	shade_cylinder.bottom_radius = 0.2
	shade_cylinder.height = 0.25

	var shade_material = StandardMaterial3D.new()
	shade_material.albedo_color = Color(0.95, 0.9, 0.8)
	shade_material.roughness = 0.8
	shade_cylinder.material = shade_material

	shade.mesh = shade_cylinder
	shade.position = Vector3(0, 0.625, 0)
	root.add_child(shade)

	# Luz
	if furniture_data.emits_light:
		var light = OmniLight3D.new()
		light.light_color = furniture_data.light_color
		light.light_energy = furniture_data.light_energy
		light.omni_range = furniture_data.light_range
		light.position = Vector3(0, 0.7, 0)
		root.add_child(light)

	return root

## Generar antorcha de pared
static func _generate_wall_torch(furniture_data: FurnitureData) -> Node3D:
	var root = Node3D.new()
	root.name = "WallTorch"

	# Soporte
	var holder = MeshInstance3D.new()
	var holder_box = BoxMesh.new()
	holder_box.size = Vector3(0.15, 0.1, 0.3)

	var metal_material = StandardMaterial3D.new()
	metal_material.albedo_color = Color(0.3, 0.3, 0.3)
	metal_material.metallic = 0.7
	metal_material.roughness = 0.5
	holder_box.material = metal_material

	holder.mesh = holder_box
	holder.position = Vector3(0, 0, 0)
	root.add_child(holder)

	# Palo de antorcha
	var stick = MeshInstance3D.new()
	var stick_cylinder = CylinderMesh.new()
	stick_cylinder.top_radius = 0.03
	stick_cylinder.bottom_radius = 0.03
	stick_cylinder.height = 0.5

	var wood_material = _create_wood_material(furniture_data.primary_color)
	stick_cylinder.material = wood_material

	stick.mesh = stick_cylinder
	stick.rotation_degrees = Vector3(0, 0, -45)
	stick.position = Vector3(0, 0.25, 0.15)
	root.add_child(stick)

	# Llama
	var flame = MeshInstance3D.new()
	var flame_sphere = SphereMesh.new()
	flame_sphere.radius = 0.12

	var flame_material = StandardMaterial3D.new()
	flame_material.albedo_color = Color(1.0, 0.5, 0.0)
	flame_material.emission_enabled = true
	flame_material.emission = Color(1.0, 0.5, 0.0)
	flame_material.emission_energy = 2.0
	flame_sphere.material = flame_material

	flame.mesh = flame_sphere
	flame.position = Vector3(0, 0.5, 0.3)
	root.add_child(flame)

	# Luz
	if furniture_data.emits_light:
		var light = OmniLight3D.new()
		light.light_color = furniture_data.light_color
		light.light_energy = furniture_data.light_energy
		light.omni_range = furniture_data.light_range
		light.position = Vector3(0, 0.5, 0.3)
		root.add_child(light)

	return root

## ============================================================
## DECORACIÓN
## ============================================================

## Generar maceta con planta
static func _generate_potted_plant(furniture_data: FurnitureData) -> Node3D:
	var root = Node3D.new()
	root.name = "PottedPlant"

	# Maceta
	var pot = MeshInstance3D.new()
	var pot_cylinder = CylinderMesh.new()
	pot_cylinder.top_radius = 0.2
	pot_cylinder.bottom_radius = 0.15
	pot_cylinder.height = 0.3

	var pot_material = StandardMaterial3D.new()
	pot_material.albedo_color = furniture_data.primary_color
	pot_material.roughness = 0.8
	pot_cylinder.material = pot_material

	pot.mesh = pot_cylinder
	pot.position = Vector3(0, 0.15, 0)
	root.add_child(pot)

	# Tierra
	var dirt = MeshInstance3D.new()
	var dirt_cylinder = CylinderMesh.new()
	dirt_cylinder.top_radius = 0.18
	dirt_cylinder.bottom_radius = 0.18
	dirt_cylinder.height = 0.05

	var dirt_material = StandardMaterial3D.new()
	dirt_material.albedo_color = Color(0.4, 0.3, 0.2)
	dirt_material.roughness = 1.0
	dirt_cylinder.material = dirt_material

	dirt.mesh = dirt_cylinder
	dirt.position = Vector3(0, 0.32, 0)
	root.add_child(dirt)

	# Planta (hojas)
	var plant_material = StandardMaterial3D.new()
	plant_material.albedo_color = furniture_data.secondary_color
	plant_material.roughness = 0.9

	for i in range(5):
		var leaf = MeshInstance3D.new()
		var leaf_sphere = SphereMesh.new()
		leaf_sphere.radius = 0.15
		leaf_sphere.material = plant_material

		leaf.mesh = leaf_sphere
		var angle = i * TAU / 5
		var offset_x = cos(angle) * 0.1
		var offset_z = sin(angle) * 0.1
		leaf.position = Vector3(offset_x, 0.5 + i * 0.1, offset_z)
		root.add_child(leaf)

	return root

## Generar cuadro
static func _generate_painting(furniture_data: FurnitureData) -> Node3D:
	var root = Node3D.new()
	root.name = "Painting"

	# Marco
	var frame = MeshInstance3D.new()
	var frame_box = BoxMesh.new()
	frame_box.size = Vector3(2.0, 1.5, 0.1)

	var frame_material = _create_wood_material(furniture_data.primary_color)
	frame_box.material = frame_material

	frame.mesh = frame_box
	frame.position = Vector3(0, 0.75, 0)
	root.add_child(frame)

	# Lienzo (arte abstracto simple)
	var canvas = MeshInstance3D.new()
	var canvas_box = BoxMesh.new()
	canvas_box.size = Vector3(1.8, 1.3, 0.05)

	var canvas_material = StandardMaterial3D.new()
	# Arte abstracto: gradiente aleatorio
	canvas_material.albedo_color = Color(randf(), randf(), randf())
	canvas_material.roughness = 0.6
	canvas_box.material = canvas_material

	canvas.mesh = canvas_box
	canvas.position = Vector3(0, 0.75, 0.08)
	root.add_child(canvas)

	return root

## Generar alfombra
static func _generate_rug(furniture_data: FurnitureData) -> Node3D:
	var root = Node3D.new()
	root.name = "Rug"

	var rug = MeshInstance3D.new()
	var rug_box = BoxMesh.new()
	rug_box.size = Vector3(2.0, 0.05, 2.0)

	var rug_material = StandardMaterial3D.new()
	rug_material.albedo_color = furniture_data.primary_color
	rug_material.roughness = 1.0
	rug_box.material = rug_material

	rug.mesh = rug_box
	rug.position = Vector3(0, 0.025, 0)
	root.add_child(rug)

	# Patrón decorativo (bordes)
	var border_material = StandardMaterial3D.new()
	border_material.albedo_color = furniture_data.primary_color.lightened(0.3)
	border_material.roughness = 1.0

	# Bordes horizontales
	for x in [-0.9, 0.9]:
		var border = MeshInstance3D.new()
		var border_box = BoxMesh.new()
		border_box.size = Vector3(0.1, 0.06, 2.0)
		border_box.material = border_material

		border.mesh = border_box
		border.position = Vector3(x, 0.03, 0)
		root.add_child(border)

	# Bordes verticales
	for z in [-0.9, 0.9]:
		var border = MeshInstance3D.new()
		var border_box = BoxMesh.new()
		border_box.size = Vector3(2.0, 0.06, 0.1)
		border_box.material = border_material

		border.mesh = border_box
		border.position = Vector3(0, 0.03, z)
		root.add_child(border)

	return root

## Generar florero
static func _generate_vase(furniture_data: FurnitureData) -> Node3D:
	var root = Node3D.new()
	root.name = "Vase"

	# Florero
	var vase = MeshInstance3D.new()
	var vase_cylinder = CylinderMesh.new()
	vase_cylinder.top_radius = 0.15
	vase_cylinder.bottom_radius = 0.1
	vase_cylinder.height = 0.5

	var vase_material = StandardMaterial3D.new()
	vase_material.albedo_color = furniture_data.primary_color
	vase_material.roughness = 0.3
	vase_material.metallic = 0.2
	vase_cylinder.material = vase_material

	vase.mesh = vase_cylinder
	vase.position = Vector3(0, 0.25, 0)
	root.add_child(vase)

	# Flores
	var flower_material = StandardMaterial3D.new()
	flower_material.albedo_color = furniture_data.secondary_color
	flower_material.roughness = 0.8

	for i in range(3):
		var flower = MeshInstance3D.new()
		var flower_sphere = SphereMesh.new()
		flower_sphere.radius = 0.08
		flower_sphere.material = flower_material

		flower.mesh = flower_sphere
		var angle = i * TAU / 3
		var offset_x = cos(angle) * 0.08
		var offset_z = sin(angle) * 0.08
		flower.position = Vector3(offset_x, 0.6, offset_z)
		root.add_child(flower)

	return root

## ============================================================
## COCINA
## ============================================================

## Generar estufa
static func _generate_stove(furniture_data: FurnitureData) -> Node3D:
	var root = Node3D.new()
	root.name = "Stove"

	# Cuerpo
	var body = MeshInstance3D.new()
	var body_box = BoxMesh.new()
	body_box.size = Vector3(1.0, 0.8, 0.6)

	var metal_material = StandardMaterial3D.new()
	metal_material.albedo_color = furniture_data.primary_color
	metal_material.metallic = 0.6
	metal_material.roughness = 0.4
	body_box.material = metal_material

	body.mesh = body_box
	body.position = Vector3(0, 0.4, 0)
	root.add_child(body)

	# Superficie de cocina
	var top = MeshInstance3D.new()
	var top_box = BoxMesh.new()
	top_box.size = Vector3(1.0, 0.05, 0.6)
	top_box.material = metal_material

	top.mesh = top_box
	top.position = Vector3(0, 0.825, 0)
	root.add_child(top)

	# 4 hornillas
	var burner_material = StandardMaterial3D.new()
	burner_material.albedo_color = Color(0.2, 0.2, 0.2)
	burner_material.metallic = 0.8
	burner_material.roughness = 0.3

	var burner_positions = [
		Vector3(-0.25, 0.85, -0.15),
		Vector3(0.25, 0.85, -0.15),
		Vector3(-0.25, 0.85, 0.15),
		Vector3(0.25, 0.85, 0.15)
	]

	for burner_pos in burner_positions:
		var burner = MeshInstance3D.new()
		var burner_cylinder = CylinderMesh.new()
		burner_cylinder.top_radius = 0.12
		burner_cylinder.bottom_radius = 0.12
		burner_cylinder.height = 0.02
		burner_cylinder.material = burner_material

		burner.mesh = burner_cylinder
		burner.position = burner_pos
		root.add_child(burner)

	# Puerta de horno
	var door = MeshInstance3D.new()
	var door_box = BoxMesh.new()
	door_box.size = Vector3(0.9, 0.4, 0.05)

	var door_material = StandardMaterial3D.new()
	door_material.albedo_color = Color(0.2, 0.2, 0.2)
	door_material.roughness = 0.5
	door_box.material = door_material

	door.mesh = door_box
	door.position = Vector3(0, 0.3, 0.32)
	root.add_child(door)

	# Luz de horno
	if furniture_data.emits_light:
		var light = OmniLight3D.new()
		light.light_color = furniture_data.light_color
		light.light_energy = furniture_data.light_energy
		light.omni_range = furniture_data.light_range
		light.position = Vector3(0, 0.5, 0)
		root.add_child(light)

	return root

## Generar refrigerador
static func _generate_fridge(furniture_data: FurnitureData) -> Node3D:
	var root = Node3D.new()
	root.name = "Fridge"

	# Cuerpo principal
	var body = MeshInstance3D.new()
	var body_box = BoxMesh.new()
	body_box.size = Vector3(1.0, 2.0, 0.6)

	var fridge_material = StandardMaterial3D.new()
	fridge_material.albedo_color = furniture_data.primary_color
	fridge_material.metallic = 0.3
	fridge_material.roughness = 0.2
	body_box.material = fridge_material

	body.mesh = body_box
	body.position = Vector3(0, 1.0, 0)
	root.add_child(body)

	# Puerta superior (congelador)
	var door_top = MeshInstance3D.new()
	var door_top_box = BoxMesh.new()
	door_top_box.size = Vector3(0.95, 0.7, 0.05)
	door_top_box.material = fridge_material

	door_top.mesh = door_top_box
	door_top.position = Vector3(0, 1.6, 0.32)
	root.add_child(door_top)

	# Puerta inferior
	var door_bottom = MeshInstance3D.new()
	var door_bottom_box = BoxMesh.new()
	door_bottom_box.size = Vector3(0.95, 1.2, 0.05)
	door_bottom_box.material = fridge_material

	door_bottom.mesh = door_bottom_box
	door_bottom.position = Vector3(0, 0.6, 0.32)
	root.add_child(door_bottom)

	# Manijas
	var handle_material = StandardMaterial3D.new()
	handle_material.albedo_color = Color(0.3, 0.3, 0.3)
	handle_material.metallic = 0.7

	var handle_top = MeshInstance3D.new()
	var handle_box = BoxMesh.new()
	handle_box.size = Vector3(0.1, 0.4, 0.05)
	handle_box.material = handle_material

	handle_top.mesh = handle_box
	handle_top.position = Vector3(0.4, 1.6, 0.35)
	root.add_child(handle_top)

	var handle_bottom = handle_top.duplicate()
	handle_bottom.position = Vector3(0.4, 0.6, 0.35)
	root.add_child(handle_bottom)

	return root

## Generar mesa de cocina
static func _generate_kitchen_table(furniture_data: FurnitureData) -> Node3D:
	var root = Node3D.new()
	root.name = "KitchenTable"

	# Similar a mesa normal pero más pequeña y con superficie diferente
	var surface_material = StandardMaterial3D.new()
	surface_material.albedo_color = furniture_data.primary_color
	surface_material.roughness = 0.3
	surface_material.metallic = 0.1

	# Superficie
	var top = MeshInstance3D.new()
	var top_box = BoxMesh.new()
	top_box.size = Vector3(1.0, 0.1, 0.6)
	top_box.material = surface_material

	top.mesh = top_box
	top.position = Vector3(0, 0.9, 0)
	root.add_child(top)

	# Patas de metal
	var leg_material = StandardMaterial3D.new()
	leg_material.albedo_color = Color(0.7, 0.7, 0.7)
	leg_material.metallic = 0.8
	leg_material.roughness = 0.3

	var leg_positions = [
		Vector3(-0.4, 0.45, -0.25),
		Vector3(0.4, 0.45, -0.25),
		Vector3(-0.4, 0.45, 0.25),
		Vector3(0.4, 0.45, 0.25)
	]

	for leg_pos in leg_positions:
		var leg = MeshInstance3D.new()
		var leg_cylinder = CylinderMesh.new()
		leg_cylinder.top_radius = 0.03
		leg_cylinder.bottom_radius = 0.03
		leg_cylinder.height = 0.9
		leg_cylinder.material = leg_material

		leg.mesh = leg_cylinder
		leg.position = leg_pos
		root.add_child(leg)

	return root

## ============================================================
## EDUCACIÓN
## ============================================================

## Generar biblioteca grande
static func _generate_library(furniture_data: FurnitureData) -> Node3D:
	var root = Node3D.new()
	root.name = "Library"

	var wood_material = _create_wood_material(furniture_data.primary_color)

	# Marco grande
	var frame = MeshInstance3D.new()
	var frame_box = BoxMesh.new()
	frame_box.size = Vector3(3.0, 3.0, 0.4)
	frame_box.material = wood_material

	frame.mesh = frame_box
	frame.position = Vector3(0, 1.5, 0)
	root.add_child(frame)

	# 5 estantes
	for i in range(6):
		var shelf = MeshInstance3D.new()
		var shelf_box = BoxMesh.new()
		shelf_box.size = Vector3(2.9, 0.05, 0.35)
		shelf_box.material = wood_material

		shelf.mesh = shelf_box
		shelf.position = Vector3(0, i * 0.6, 0)
		root.add_child(shelf)

	# Muchos libros
	for shelf_idx in range(5):
		for book_idx in range(8):
			var book = _create_book(
				Vector3(-1.2 + book_idx * 0.35, 0.3 + shelf_idx * 0.6, 0.08),
				Color(randf(), randf(), randf())
			)
			root.add_child(book)

	return root

## Generar atril
static func _generate_lectern(furniture_data: FurnitureData) -> Node3D:
	var root = Node3D.new()
	root.name = "Lectern"

	var wood_material = _create_wood_material(furniture_data.primary_color)

	# Poste
	var pole = MeshInstance3D.new()
	var pole_cylinder = CylinderMesh.new()
	pole_cylinder.top_radius = 0.05
	pole_cylinder.bottom_radius = 0.08
	pole_cylinder.height = 1.2
	pole_cylinder.material = wood_material

	pole.mesh = pole_cylinder
	pole.position = Vector3(0, 0.6, 0)
	root.add_child(pole)

	# Superficie inclinada
	var surface = MeshInstance3D.new()
	var surface_box = BoxMesh.new()
	surface_box.size = Vector3(0.5, 0.4, 0.05)
	surface_box.material = wood_material

	surface.mesh = surface_box
	surface.rotation_degrees = Vector3(30, 0, 0)
	surface.position = Vector3(0, 1.3, -0.15)
	root.add_child(surface)

	# Libro abierto
	var book = MeshInstance3D.new()
	var book_box = BoxMesh.new()
	book_box.size = Vector3(0.4, 0.05, 0.3)

	var book_material = StandardMaterial3D.new()
	book_material.albedo_color = Color(0.9, 0.85, 0.7)
	book_material.roughness = 0.9
	book_box.material = book_material

	book.mesh = book_box
	book.rotation_degrees = Vector3(30, 0, 0)
	book.position = Vector3(0, 1.35, -0.15)
	root.add_child(book)

	# Páginas (líneas)
	for i in range(5):
		var line = MeshInstance3D.new()
		var line_box = BoxMesh.new()
		line_box.size = Vector3(0.3, 0.002, 0.05)

		var line_material = StandardMaterial3D.new()
		line_material.albedo_color = Color(0.2, 0.2, 0.2)
		line_box.material = line_material

		line.mesh = line_box
		line.rotation_degrees = Vector3(30, 0, 0)
		line.position = Vector3(0, 1.38 + i * 0.03, -0.15 + i * 0.015)
		root.add_child(line)

	return root

## ============================================================
## UTILIDADES
## ============================================================

## Crear material de madera
static func _create_wood_material(color: Color) -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	material.metallic = 0.0
	return material

## Crear libro pequeño
static func _create_book(position: Vector3, color: Color) -> MeshInstance3D:
	var book = MeshInstance3D.new()
	var book_box = BoxMesh.new()
	book_box.size = Vector3(0.08, 0.3, 0.2)

	var book_material = StandardMaterial3D.new()
	book_material.albedo_color = color
	book_material.roughness = 0.8
	book_box.material = book_material

	book.mesh = book_box
	book.position = position
	return book

## Placeholder para muebles no implementados
static func _generate_placeholder(furniture_data: FurnitureData) -> Node3D:
	var root = Node3D.new()
	root.name = "Placeholder"

	var box = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(furniture_data.size.x * 0.9, furniture_data.size.y * 0.9, furniture_data.size.z * 0.9)

	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.8, 0.3, 0.8)
	material.roughness = 0.7
	box_mesh.material = material

	box.mesh = box_mesh
	root.add_child(box)

	return root
