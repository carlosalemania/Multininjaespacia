extends Node
class_name AnimalModelGenerator
## Generador de modelos 3D procedurales para animales

## Crear modelo de oveja
static func create_sheep() -> Node3D:
	var root = Node3D.new()
	root.name = "SheepModel"

	# Cuerpo (esfera blanca lanuda)
	var body = MeshInstance3D.new()
	var body_sphere = SphereMesh.new()
	body_sphere.radius = 0.4
	body_sphere.height = 0.6

	var wool_material = StandardMaterial3D.new()
	wool_material.albedo_color = Color(0.95, 0.95, 0.95)  # Blanco lana
	wool_material.roughness = 1.0
	body_sphere.material = wool_material

	body.mesh = body_sphere
	body.position = Vector3(0, 0.4, 0)
	root.add_child(body)

	# Cabeza (esfera negra pequeña)
	var head = MeshInstance3D.new()
	var head_sphere = SphereMesh.new()
	head_sphere.radius = 0.2

	var face_material = StandardMaterial3D.new()
	face_material.albedo_color = Color(0.15, 0.15, 0.15)  # Negro
	face_material.roughness = 0.8
	head_sphere.material = face_material

	head.mesh = head_sphere
	head.name = "Head"
	head.position = Vector3(0, 0.4, 0.5)
	root.add_child(head)

	# Patas (4 cilindros negros)
	var leg_material = StandardMaterial3D.new()
	leg_material.albedo_color = Color(0.1, 0.1, 0.1)

	for i in range(4):
		var leg = MeshInstance3D.new()
		var leg_cylinder = CylinderMesh.new()
		leg_cylinder.top_radius = 0.08
		leg_cylinder.bottom_radius = 0.08
		leg_cylinder.height = 0.4
		leg_cylinder.material = leg_material

		leg.mesh = leg_cylinder

		var x_offset = -0.2 if i % 2 == 0 else 0.2
		var z_offset = 0.2 if i < 2 else -0.2
		leg.position = Vector3(x_offset, 0.0, z_offset)

		root.add_child(leg)

	return root

## Crear modelo de vaca
static func create_cow() -> Node3D:
	var root = Node3D.new()
	root.name = "CowModel"

	# Cuerpo (caja rectangular)
	var body = MeshInstance3D.new()
	var body_box = BoxMesh.new()
	body_box.size = Vector3(0.6, 0.5, 0.9)

	var cow_material = StandardMaterial3D.new()
	cow_material.albedo_color = Color(0.85, 0.82, 0.75)  # Beige/blanco
	cow_material.roughness = 0.9
	body_box.material = cow_material

	body.mesh = body_box
	body.position = Vector3(0, 0.5, 0)
	root.add_child(body)

	# Cabeza
	var head = MeshInstance3D.new()
	var head_box = BoxMesh.new()
	head_box.size = Vector3(0.3, 0.3, 0.4)
	head_box.material = cow_material

	head.mesh = head_box
	head.name = "Head"
	head.position = Vector3(0, 0.6, 0.6)
	root.add_child(head)

	# Cuernos
	for i in range(2):
		var horn = MeshInstance3D.new()
		var horn_cone = CylinderMesh.new()
		horn_cone.top_radius = 0.0  # Hacer cono
		horn_cone.bottom_radius = 0.04
		horn_cone.height = 0.15

		var horn_material = StandardMaterial3D.new()
		horn_material.albedo_color = Color(0.9, 0.85, 0.7)
		horn_cone.material = horn_material

		horn.mesh = horn_cone
		horn.rotation_degrees = Vector3(45 if i == 0 else -45, 0, 0)
		var x_offset = -0.1 if i == 0 else 0.1
		horn.position = Vector3(x_offset, 0.85, 0.6)
		root.add_child(horn)

	# Patas
	var leg_material = StandardMaterial3D.new()
	leg_material.albedo_color = Color(0.75, 0.72, 0.65)

	for i in range(4):
		var leg = MeshInstance3D.new()
		var leg_cylinder = CylinderMesh.new()
		leg_cylinder.top_radius = 0.09
		leg_cylinder.bottom_radius = 0.09
		leg_cylinder.height = 0.5
		leg_cylinder.material = leg_material

		leg.mesh = leg_cylinder

		var x_offset = -0.25 if i % 2 == 0 else 0.25
		var z_offset = 0.3 if i < 2 else -0.3
		leg.position = Vector3(x_offset, 0.0, z_offset)

		root.add_child(leg)

	# Cola
	var tail = MeshInstance3D.new()
	var tail_cylinder = CylinderMesh.new()
	tail_cylinder.top_radius = 0.03
	tail_cylinder.bottom_radius = 0.02
	tail_cylinder.height = 0.4
	tail_cylinder.material = leg_material

	tail.mesh = tail_cylinder
	tail.rotation_degrees = Vector3(45, 0, 0)
	tail.position = Vector3(0, 0.5, -0.5)
	root.add_child(tail)

	return root

## Crear modelo de gallina
static func create_chicken() -> Node3D:
	var root = Node3D.new()
	root.name = "ChickenModel"

	# Cuerpo (esfera pequeña)
	var body = MeshInstance3D.new()
	var body_sphere = SphereMesh.new()
	body_sphere.radius = 0.2
	body_sphere.height = 0.25

	var feather_material = StandardMaterial3D.new()
	feather_material.albedo_color = Color(0.95, 0.9, 0.85)  # Blanco plumas
	feather_material.roughness = 0.9
	body_sphere.material = feather_material

	body.mesh = body_sphere
	body.position = Vector3(0, 0.2, 0)
	root.add_child(body)

	# Cabeza
	var head = MeshInstance3D.new()
	var head_sphere = SphereMesh.new()
	head_sphere.radius = 0.1
	head_sphere.material = feather_material

	head.mesh = head_sphere
	head.name = "Head"
	head.position = Vector3(0, 0.35, 0.15)
	root.add_child(head)

	# Pico
	var beak = MeshInstance3D.new()
	var beak_cone = CylinderMesh.new()
	beak_cone.top_radius = 0.0  # Hacer cono
	beak_cone.bottom_radius = 0.04
	beak_cone.height = 0.08

	var beak_material = StandardMaterial3D.new()
	beak_material.albedo_color = Color(1.0, 0.7, 0.0)  # Naranja
	beak_cone.material = beak_material

	beak.mesh = beak_cone
	beak.rotation_degrees = Vector3(90, 0, 0)
	beak.position = Vector3(0, 0.35, 0.23)
	root.add_child(beak)

	# Cresta (roja)
	var crest = MeshInstance3D.new()
	var crest_box = BoxMesh.new()
	crest_box.size = Vector3(0.08, 0.1, 0.06)

	var crest_material = StandardMaterial3D.new()
	crest_material.albedo_color = Color(0.9, 0.1, 0.1)  # Rojo
	crest_box.material = crest_material

	crest.mesh = crest_box
	crest.position = Vector3(0, 0.45, 0.15)
	root.add_child(crest)

	# Patas (2 delgadas)
	var leg_material = StandardMaterial3D.new()
	leg_material.albedo_color = Color(1.0, 0.8, 0.0)  # Amarillo

	for i in range(2):
		var leg = MeshInstance3D.new()
		var leg_cylinder = CylinderMesh.new()
		leg_cylinder.top_radius = 0.02
		leg_cylinder.bottom_radius = 0.02
		leg_cylinder.height = 0.15
		leg_cylinder.material = leg_material

		leg.mesh = leg_cylinder

		var x_offset = -0.08 if i == 0 else 0.08
		leg.position = Vector3(x_offset, 0.0, 0)

		root.add_child(leg)

	return root

## Crear modelo de conejo
static func create_rabbit() -> Node3D:
	var root = Node3D.new()
	root.name = "RabbitModel"

	# Cuerpo (esfera pequeña)
	var body = MeshInstance3D.new()
	var body_sphere = SphereMesh.new()
	body_sphere.radius = 0.25
	body_sphere.height = 0.3

	var fur_material = StandardMaterial3D.new()
	fur_material.albedo_color = Color(0.7, 0.6, 0.5)  # Marrón claro
	fur_material.roughness = 1.0
	body_sphere.material = fur_material

	body.mesh = body_sphere
	body.position = Vector3(0, 0.2, 0)
	root.add_child(body)

	# Cabeza
	var head = MeshInstance3D.new()
	var head_sphere = SphereMesh.new()
	head_sphere.radius = 0.15
	head_sphere.material = fur_material

	head.mesh = head_sphere
	head.name = "Head"
	head.position = Vector3(0, 0.3, 0.25)
	root.add_child(head)

	# Orejas (2 largas)
	for i in range(2):
		var ear = MeshInstance3D.new()
		var ear_capsule = CapsuleMesh.new()
		ear_capsule.radius = 0.04
		ear_capsule.height = 0.25
		ear_capsule.material = fur_material

		ear.mesh = ear_capsule
		ear.rotation_degrees = Vector3(-30, 0, 15 if i == 0 else -15)

		var x_offset = -0.08 if i == 0 else 0.08
		ear.position = Vector3(x_offset, 0.5, 0.25)

		root.add_child(ear)

	# Patas traseras (más largas)
	var leg_material = StandardMaterial3D.new()
	leg_material.albedo_color = Color(0.65, 0.55, 0.45)

	for i in range(2):
		var leg = MeshInstance3D.new()
		var leg_capsule = CapsuleMesh.new()
		leg_capsule.radius = 0.06
		leg_capsule.height = 0.2
		leg_capsule.material = leg_material

		leg.mesh = leg_capsule

		var x_offset = -0.12 if i == 0 else 0.12
		leg.position = Vector3(x_offset, 0.0, -0.1)

		root.add_child(leg)

	# Cola pompón
	var tail = MeshInstance3D.new()
	var tail_sphere = SphereMesh.new()
	tail_sphere.radius = 0.08
	tail_sphere.material = fur_material

	tail.mesh = tail_sphere
	tail.position = Vector3(0, 0.2, -0.25)
	root.add_child(tail)

	return root

## Crear modelo de venado
static func create_deer() -> Node3D:
	var root = Node3D.new()
	root.name = "DeerModel"

	# Cuerpo (caja rectangular marrón)
	var body = MeshInstance3D.new()
	var body_box = BoxMesh.new()
	body_box.size = Vector3(0.4, 0.5, 0.8)

	var deer_material = StandardMaterial3D.new()
	deer_material.albedo_color = Color(0.6, 0.4, 0.3)  # Marrón
	deer_material.roughness = 0.9
	body_box.material = deer_material

	body.mesh = body_box
	body.position = Vector3(0, 0.6, 0)
	root.add_child(body)

	# Cuello (cilindro)
	var neck = MeshInstance3D.new()
	var neck_cylinder = CylinderMesh.new()
	neck_cylinder.top_radius = 0.12
	neck_cylinder.bottom_radius = 0.15
	neck_cylinder.height = 0.3
	neck_cylinder.material = deer_material

	neck.mesh = neck_cylinder
	neck.position = Vector3(0, 0.95, 0.3)
	root.add_child(neck)

	# Cabeza
	var head = MeshInstance3D.new()
	var head_box = BoxMesh.new()
	head_box.size = Vector3(0.2, 0.25, 0.3)
	head_box.material = deer_material

	head.mesh = head_box
	head.name = "Head"
	head.position = Vector3(0, 1.2, 0.35)
	root.add_child(head)

	# Astas (cornamentas)
	for i in range(2):
		var antler = MeshInstance3D.new()
		var antler_cylinder = CylinderMesh.new()
		antler_cylinder.top_radius = 0.02
		antler_cylinder.bottom_radius = 0.04
		antler_cylinder.height = 0.35

		var antler_material = StandardMaterial3D.new()
		antler_material.albedo_color = Color(0.8, 0.75, 0.65)
		antler_cylinder.material = antler_material

		antler.mesh = antler_cylinder
		antler.rotation_degrees = Vector3(-20, 0, 25 if i == 0 else -25)

		var x_offset = -0.12 if i == 0 else 0.12
		antler.position = Vector3(x_offset, 1.45, 0.35)

		root.add_child(antler)

	# Patas (4 largas)
	var leg_material = StandardMaterial3D.new()
	leg_material.albedo_color = Color(0.5, 0.35, 0.25)

	for i in range(4):
		var leg = MeshInstance3D.new()
		var leg_cylinder = CylinderMesh.new()
		leg_cylinder.top_radius = 0.08
		leg_cylinder.bottom_radius = 0.06
		leg_cylinder.height = 0.6
		leg_cylinder.material = leg_material

		leg.mesh = leg_cylinder

		var x_offset = -0.15 if i % 2 == 0 else 0.15
		var z_offset = 0.3 if i < 2 else -0.3
		leg.position = Vector3(x_offset, 0.0, z_offset)

		root.add_child(leg)

	return root

## Crear modelo de pájaro
static func create_bird() -> Node3D:
	var root = Node3D.new()
	root.name = "BirdModel"

	# Cuerpo (esfera pequeña)
	var body = MeshInstance3D.new()
	var body_sphere = SphereMesh.new()
	body_sphere.radius = 0.12
	body_sphere.height = 0.15

	var feather_material = StandardMaterial3D.new()
	feather_material.albedo_color = Color(0.3, 0.5, 0.8)  # Azul
	feather_material.roughness = 0.8
	body_sphere.material = feather_material

	body.mesh = body_sphere
	body.position = Vector3(0, 0.15, 0)
	root.add_child(body)

	# Cabeza
	var head = MeshInstance3D.new()
	var head_sphere = SphereMesh.new()
	head_sphere.radius = 0.08
	head_sphere.material = feather_material

	head.mesh = head_sphere
	head.name = "Head"
	head.position = Vector3(0, 0.22, 0.1)
	root.add_child(head)

	# Pico
	var beak = MeshInstance3D.new()
	var beak_cone = CylinderMesh.new()
	beak_cone.top_radius = 0.0  # Hacer cono
	beak_cone.bottom_radius = 0.03
	beak_cone.height = 0.08

	var beak_material = StandardMaterial3D.new()
	beak_material.albedo_color = Color(1.0, 0.6, 0.0)
	beak_cone.material = beak_material

	beak.mesh = beak_cone
	beak.rotation_degrees = Vector3(90, 0, 0)
	beak.position = Vector3(0, 0.22, 0.17)
	root.add_child(beak)

	# Alas (2 planas)
	for i in range(2):
		var wing = MeshInstance3D.new()
		var wing_box = BoxMesh.new()
		wing_box.size = Vector3(0.25, 0.02, 0.12)

		var wing_material = StandardMaterial3D.new()
		wing_material.albedo_color = Color(0.25, 0.45, 0.75)
		wing_box.material = wing_material

		wing.mesh = wing_box

		var x_offset = -0.18 if i == 0 else 0.18
		wing.position = Vector3(x_offset, 0.15, 0)

		root.add_child(wing)

	# Patas (2 muy pequeñas)
	var leg_material = StandardMaterial3D.new()
	leg_material.albedo_color = Color(0.8, 0.5, 0.0)

	for i in range(2):
		var leg = MeshInstance3D.new()
		var leg_cylinder = CylinderMesh.new()
		leg_cylinder.top_radius = 0.01
		leg_cylinder.bottom_radius = 0.01
		leg_cylinder.height = 0.08
		leg_cylinder.material = leg_material

		leg.mesh = leg_cylinder

		var x_offset = -0.04 if i == 0 else 0.04
		leg.position = Vector3(x_offset, 0.0, 0)

		root.add_child(leg)

	return root
