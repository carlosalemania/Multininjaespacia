extends Node
class_name ToolModelGenerator
## Generador procedural de modelos 3D de herramientas

## Genera modelo 3D para una herramienta
static func generate_tool_model(tool_type: ToolData.ToolType) -> MeshInstance3D:
	match tool_type:
		ToolData.ToolType.HAND:
			return _generate_hand_model()
		ToolData.ToolType.WOODEN_PICKAXE:
			return _generate_pickaxe_model(Color(0.52, 0.37, 0.26)) # Madera
		ToolData.ToolType.STONE_PICKAXE:
			return _generate_pickaxe_model(Color(0.5, 0.5, 0.5)) # Piedra
		ToolData.ToolType.GOLD_PICKAXE:
			return _generate_pickaxe_model(Color(1.0, 0.76, 0.03)) # Oro
		ToolData.ToolType.DIAMOND_PICKAXE:
			return _generate_pickaxe_model(Color(0.3, 0.8, 1.0)) # Diamante
		ToolData.ToolType.WOODEN_AXE:
			return _generate_axe_model(Color(0.52, 0.37, 0.26))
		ToolData.ToolType.STONE_AXE:
			return _generate_axe_model(Color(0.5, 0.5, 0.5))
		ToolData.ToolType.WOODEN_SHOVEL:
			return _generate_shovel_model(Color(0.52, 0.37, 0.26))
		ToolData.ToolType.STONE_SHOVEL:
			return _generate_shovel_model(Color(0.5, 0.5, 0.5))
		_:
			return _generate_hand_model()

## Modelo de mano (invisible o placeholder)
static func _generate_hand_model() -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	# Mano es invisible, no necesita mesh
	mesh_instance.visible = false
	return mesh_instance

## Modelo de pico
static func _generate_pickaxe_model(material_color: Color) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var multi_mesh = ArrayMesh.new()

	# MANGO (cilindro vertical marrón)
	var handle_mesh = CylinderMesh.new()
	handle_mesh.top_radius = 0.02
	handle_mesh.bottom_radius = 0.02
	handle_mesh.height = 0.5

	var handle_material = StandardMaterial3D.new()
	handle_material.albedo_color = Color(0.4, 0.25, 0.15) # Marrón mango
	handle_material.roughness = 0.8
	handle_mesh.material = handle_material

	# Añadir mango
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.append_from(handle_mesh, 0, Transform3D.IDENTITY)
	surface_tool.commit(multi_mesh)

	# CABEZA DEL PICO (prisma horizontal)
	var head_box = BoxMesh.new()
	head_box.size = Vector3(0.3, 0.05, 0.05) # Horizontal, delgado

	var head_material = StandardMaterial3D.new()
	head_material.albedo_color = material_color
	head_material.metallic = 0.6 if material_color.r > 0.7 else 0.2 # Metálico si es oro
	head_material.roughness = 0.4
	head_box.material = head_material

	# Posicionar cabeza en la parte superior del mango
	var head_transform = Transform3D.IDENTITY
	head_transform.origin = Vector3(0, 0.27, 0)

	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.append_from(head_box, 0, head_transform)
	surface_tool.commit(multi_mesh)

	# PUNTA IZQ (cono)
	var left_spike = CylinderMesh.new()
	left_spike.top_radius = 0.0  # Hacer cono
	left_spike.bottom_radius = 0.03
	left_spike.height = 0.12
	left_spike.material = head_material

	var left_transform = Transform3D.IDENTITY
	left_transform = left_transform.rotated(Vector3(0, 0, 1), -PI / 2) # Rotar horizontal izq
	left_transform.origin = Vector3(-0.18, 0.27, 0)

	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.append_from(left_spike, 0, left_transform)
	surface_tool.commit(multi_mesh)

	# PUNTA DER (cono)
	var right_transform = Transform3D.IDENTITY
	right_transform = right_transform.rotated(Vector3(0, 0, 1), PI / 2) # Rotar horizontal der
	right_transform.origin = Vector3(0.18, 0.27, 0)

	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.append_from(left_spike, 0, right_transform)
	surface_tool.commit(multi_mesh)

	mesh_instance.mesh = multi_mesh
	mesh_instance.position = Vector3(0.3, -0.2, -0.4) # Frente a la cámara
	mesh_instance.rotation_degrees = Vector3(0, 180, 10) # Ligeramente inclinado

	return mesh_instance

## Modelo de hacha
static func _generate_axe_model(material_color: Color) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var multi_mesh = ArrayMesh.new()

	# MANGO
	var handle_mesh = CylinderMesh.new()
	handle_mesh.top_radius = 0.02
	handle_mesh.bottom_radius = 0.025
	handle_mesh.height = 0.5

	var handle_material = StandardMaterial3D.new()
	handle_material.albedo_color = Color(0.4, 0.25, 0.15)
	handle_material.roughness = 0.8
	handle_mesh.material = handle_material

	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.append_from(handle_mesh, 0, Transform3D.IDENTITY)
	surface_tool.commit(multi_mesh)

	# HOJA (caja cuadrada aplanada)
	var blade = BoxMesh.new()
	blade.size = Vector3(0.25, 0.15, 0.03)

	var blade_material = StandardMaterial3D.new()
	blade_material.albedo_color = material_color
	blade_material.metallic = 0.3
	blade_material.roughness = 0.5
	blade.material = blade_material

	var blade_transform = Transform3D.IDENTITY
	blade_transform.origin = Vector3(-0.1, 0.27, 0)

	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.append_from(blade, 0, blade_transform)
	surface_tool.commit(multi_mesh)

	# FILO (triángulo en el borde)
	var edge = PrismMesh.new()
	edge.size = Vector3(0.08, 0.03, 0.15)
	edge.material = blade_material

	var edge_transform = Transform3D.IDENTITY
	edge_transform = edge_transform.rotated(Vector3(0, 0, 1), PI / 2)
	edge_transform = edge_transform.rotated(Vector3(1, 0, 0), PI / 2)
	edge_transform.origin = Vector3(-0.22, 0.27, 0)

	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.append_from(edge, 0, edge_transform)
	surface_tool.commit(multi_mesh)

	mesh_instance.mesh = multi_mesh
	mesh_instance.position = Vector3(0.3, -0.2, -0.4)
	mesh_instance.rotation_degrees = Vector3(0, 180, 15)

	return mesh_instance

## Modelo de pala
static func _generate_shovel_model(material_color: Color) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var multi_mesh = ArrayMesh.new()

	# MANGO
	var handle_mesh = CylinderMesh.new()
	handle_mesh.top_radius = 0.02
	handle_mesh.bottom_radius = 0.02
	handle_mesh.height = 0.5

	var handle_material = StandardMaterial3D.new()
	handle_material.albedo_color = Color(0.4, 0.25, 0.15)
	handle_material.roughness = 0.8
	handle_mesh.material = handle_material

	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.append_from(handle_mesh, 0, Transform3D.IDENTITY)
	surface_tool.commit(multi_mesh)

	# PALA (caja rectangular aplanada)
	var scoop = BoxMesh.new()
	scoop.size = Vector3(0.12, 0.18, 0.02)

	var scoop_material = StandardMaterial3D.new()
	scoop_material.albedo_color = material_color
	scoop_material.metallic = 0.2
	scoop_material.roughness = 0.6
	scoop.material = scoop_material

	var scoop_transform = Transform3D.IDENTITY
	scoop_transform = scoop_transform.rotated(Vector3(1, 0, 0), deg_to_rad(20)) # Inclinada
	scoop_transform.origin = Vector3(0, 0.32, 0.05)

	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.append_from(scoop, 0, scoop_transform)
	surface_tool.commit(multi_mesh)

	# PUNTA (pirámide pequeña)
	var tip = PrismMesh.new()
	tip.size = Vector3(0.12, 0.05, 0.06)
	tip.material = scoop_material

	var tip_transform = Transform3D.IDENTITY
	tip_transform = tip_transform.rotated(Vector3(1, 0, 0), deg_to_rad(110))
	tip_transform.origin = Vector3(0, 0.41, 0.08)

	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.append_from(tip, 0, tip_transform)
	surface_tool.commit(multi_mesh)

	mesh_instance.mesh = multi_mesh
	mesh_instance.position = Vector3(0.3, -0.2, -0.4)
	mesh_instance.rotation_degrees = Vector3(0, 180, 5)

	return mesh_instance
