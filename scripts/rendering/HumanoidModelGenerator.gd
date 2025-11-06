extends Node
class_name HumanoidModelGenerator
## Generador de modelos 3D humanoides procedurales con apariencia más realista

## Paleta de colores para piel
const SKIN_TONES = [
	Color(1.0, 0.87, 0.77),    # Piel clara
	Color(0.96, 0.80, 0.69),   # Piel media-clara
	Color(0.85, 0.65, 0.53),   # Piel media
	Color(0.71, 0.55, 0.42),   # Piel morena
	Color(0.55, 0.42, 0.33),   # Piel oscura
]

## Paleta de colores para ropa
const CLOTHING_COLORS = [
	Color(0.2, 0.6, 0.2),      # Verde (aldeano)
	Color(0.5, 0.3, 0.8),      # Púrpura (sabio)
	Color(0.8, 0.4, 0.2),      # Naranja
	Color(0.3, 0.5, 0.8),      # Azul
	Color(0.7, 0.2, 0.2),      # Rojo
	Color(0.9, 0.8, 0.3),      # Amarillo
]

## Paleta de colores para cabello
const HAIR_COLORS = [
	Color(0.1, 0.05, 0.02),    # Negro
	Color(0.3, 0.2, 0.1),      # Castaño oscuro
	Color(0.5, 0.35, 0.2),     # Castaño
	Color(0.8, 0.6, 0.3),      # Rubio
	Color(0.9, 0.4, 0.2),      # Pelirrojo
	Color(0.7, 0.7, 0.7),      # Gris (anciano)
]

## Generar modelo humanoide completo
static func generate_humanoid(npc_type: String = "villager", randomize_colors: bool = true) -> Node3D:
	var root = Node3D.new()
	root.name = "HumanoidModel"

	# Colores aleatorios o predefinidos
	var skin_color = SKIN_TONES.pick_random() if randomize_colors else SKIN_TONES[1]
	var clothing_color = _get_clothing_color_for_type(npc_type) if not randomize_colors else CLOTHING_COLORS.pick_random()
	var hair_color = HAIR_COLORS.pick_random() if randomize_colors else HAIR_COLORS[2]

	# Construir cuerpo
	var torso = _create_torso(clothing_color)
	root.add_child(torso)

	var head = _create_head(skin_color)
	head.position = Vector3(0, 0.9, 0)
	root.add_child(head)

	var hair = _create_hair(hair_color)
	hair.position = Vector3(0, 1.15, 0)
	root.add_child(hair)

	# Brazos
	var left_arm = _create_arm(skin_color, clothing_color)
	left_arm.position = Vector3(-0.35, 0.6, 0)
	root.add_child(left_arm)

	var right_arm = _create_arm(skin_color, clothing_color)
	right_arm.position = Vector3(0.35, 0.6, 0)
	root.add_child(right_arm)

	# Piernas
	var left_leg = _create_leg(clothing_color)
	left_leg.position = Vector3(-0.15, 0, 0)
	root.add_child(left_leg)

	var right_leg = _create_leg(clothing_color)
	right_leg.position = Vector3(0.15, 0, 0)
	root.add_child(right_leg)

	# Accesorio según tipo
	if npc_type == "sage":
		var staff = _create_staff()
		staff.position = Vector3(0.5, 0.5, 0)
		root.add_child(staff)

	return root

## Crear torso (cuerpo)
static func _create_torso(clothing_color: Color) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "Torso"

	var box = BoxMesh.new()
	box.size = Vector3(0.5, 0.7, 0.3)

	var material = StandardMaterial3D.new()
	material.albedo_color = clothing_color
	material.roughness = 0.8
	material.metallic = 0.0
	box.material = material

	mesh_instance.mesh = box
	mesh_instance.position = Vector3(0, 0.5, 0)

	return mesh_instance

## Crear cabeza
static func _create_head(skin_color: Color) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "Head"

	# Cabeza ligeramente ovalada
	var sphere = SphereMesh.new()
	sphere.radius = 0.2
	sphere.height = 0.4
	sphere.radial_segments = 16
	sphere.rings = 12

	var material = StandardMaterial3D.new()
	material.albedo_color = skin_color
	material.roughness = 0.7
	material.metallic = 0.0
	sphere.material = material

	mesh_instance.mesh = sphere

	# Añadir ojos
	var eyes_container = Node3D.new()
	eyes_container.name = "Eyes"
	mesh_instance.add_child(eyes_container)

	var left_eye = _create_eye()
	left_eye.position = Vector3(-0.08, 0.05, 0.18)
	eyes_container.add_child(left_eye)

	var right_eye = _create_eye()
	right_eye.position = Vector3(0.08, 0.05, 0.18)
	eyes_container.add_child(right_eye)

	return mesh_instance

## Crear ojo
static func _create_eye() -> MeshInstance3D:
	var eye = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.03
	sphere.height = 0.03

	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.1, 0.1, 0.1)  # Pupila negra
	material.roughness = 0.1
	material.metallic = 0.1
	sphere.material = material

	eye.mesh = sphere
	return eye

## Crear cabello
static func _create_hair(hair_color: Color) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "Hair"

	# Cabello como semi-esfera superior
	var sphere = SphereMesh.new()
	sphere.radius = 0.22
	sphere.height = 0.2
	sphere.radial_segments = 12
	sphere.rings = 8

	var material = StandardMaterial3D.new()
	material.albedo_color = hair_color
	material.roughness = 0.9
	material.metallic = 0.0
	sphere.material = material

	mesh_instance.mesh = sphere
	return mesh_instance

## Crear brazo
static func _create_arm(skin_color: Color, sleeve_color: Color) -> Node3D:
	var arm_node = Node3D.new()

	# Hombro/manga
	var shoulder = MeshInstance3D.new()
	var shoulder_box = BoxMesh.new()
	shoulder_box.size = Vector3(0.15, 0.25, 0.15)

	var sleeve_material = StandardMaterial3D.new()
	sleeve_material.albedo_color = sleeve_color
	sleeve_material.roughness = 0.8
	shoulder_box.material = sleeve_material

	shoulder.mesh = shoulder_box
	shoulder.position = Vector3(0, 0, 0)
	arm_node.add_child(shoulder)

	# Antebrazo (piel)
	var forearm = MeshInstance3D.new()
	var forearm_cylinder = CylinderMesh.new()
	forearm_cylinder.top_radius = 0.06
	forearm_cylinder.bottom_radius = 0.05
	forearm_cylinder.height = 0.3

	var skin_material = StandardMaterial3D.new()
	skin_material.albedo_color = skin_color
	skin_material.roughness = 0.7
	forearm_cylinder.material = skin_material

	forearm.mesh = forearm_cylinder
	forearm.position = Vector3(0, -0.4, 0)
	arm_node.add_child(forearm)

	# Mano
	var hand = MeshInstance3D.new()
	var hand_sphere = SphereMesh.new()
	hand_sphere.radius = 0.06
	hand_sphere.height = 0.12
	hand_sphere.material = skin_material

	hand.mesh = hand_sphere
	hand.position = Vector3(0, -0.6, 0)
	arm_node.add_child(hand)

	return arm_node

## Crear pierna
static func _create_leg(pants_color: Color) -> Node3D:
	var leg_node = Node3D.new()

	# Muslo
	var thigh = MeshInstance3D.new()
	var thigh_cylinder = CylinderMesh.new()
	thigh_cylinder.top_radius = 0.1
	thigh_cylinder.bottom_radius = 0.08
	thigh_cylinder.height = 0.4

	var pants_material = StandardMaterial3D.new()
	pants_material.albedo_color = pants_color.darkened(0.2)  # Pantalones más oscuros
	pants_material.roughness = 0.9
	thigh_cylinder.material = pants_material

	thigh.mesh = thigh_cylinder
	thigh.position = Vector3(0, -0.2, 0)
	leg_node.add_child(thigh)

	# Pantorrilla
	var calf = MeshInstance3D.new()
	var calf_cylinder = CylinderMesh.new()
	calf_cylinder.top_radius = 0.08
	calf_cylinder.bottom_radius = 0.07
	calf_cylinder.height = 0.35
	calf_cylinder.material = pants_material

	calf.mesh = calf_cylinder
	calf.position = Vector3(0, -0.55, 0)
	leg_node.add_child(calf)

	# Pie (zapato)
	var foot = MeshInstance3D.new()
	var foot_box = BoxMesh.new()
	foot_box.size = Vector3(0.12, 0.08, 0.2)

	var shoe_material = StandardMaterial3D.new()
	shoe_material.albedo_color = Color(0.2, 0.15, 0.1)  # Marrón zapato
	shoe_material.roughness = 0.9
	foot_box.material = shoe_material

	foot.mesh = foot_box
	foot.position = Vector3(0, -0.78, 0.05)
	leg_node.add_child(foot)

	return leg_node

## Crear bastón (para sabio)
static func _create_staff() -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "Staff"

	var cylinder = CylinderMesh.new()
	cylinder.top_radius = 0.02
	cylinder.bottom_radius = 0.02
	cylinder.height = 1.2

	var wood_material = StandardMaterial3D.new()
	wood_material.albedo_color = Color(0.4, 0.25, 0.15)  # Madera
	wood_material.roughness = 0.9
	cylinder.material = wood_material

	mesh_instance.mesh = cylinder
	mesh_instance.position = Vector3(0, 0, 0)

	# Cristal en la punta
	var crystal = MeshInstance3D.new()
	var crystal_sphere = SphereMesh.new()
	crystal_sphere.radius = 0.08

	var crystal_material = StandardMaterial3D.new()
	crystal_material.albedo_color = Color(0.5, 0.3, 1.0)  # Púrpura brillante
	crystal_material.metallic = 0.3
	crystal_material.roughness = 0.2
	crystal_material.emission_enabled = true
	crystal_material.emission = Color(0.5, 0.3, 1.0)
	crystal_material.emission_energy = 0.5
	crystal_sphere.material = crystal_material

	crystal.mesh = crystal_sphere
	crystal.position = Vector3(0, 0.7, 0)
	mesh_instance.add_child(crystal)

	return mesh_instance

## Obtener color de ropa según tipo de NPC
static func _get_clothing_color_for_type(npc_type: String) -> Color:
	match npc_type:
		"villager", "aldeano":
			return Color(0.2, 0.6, 0.2)  # Verde
		"sage", "sabio":
			return Color(0.5, 0.3, 0.8)  # Púrpura
		"merchant":
			return Color(0.8, 0.6, 0.2)  # Dorado
		"guard":
			return Color(0.3, 0.3, 0.6)  # Azul oscuro
		_:
			return CLOTHING_COLORS.pick_random()
