# ============================================================================
# Chunk.gd - Fragmento de Mundo (10x10x30 bloques)
# ============================================================================
# Nodo que contiene un chunk de bloques y genera su mesh
# ============================================================================

extends Node3D
class_name Chunk

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Posición del chunk (en coordenadas de chunk, no bloques)
var chunk_position: Vector3i = Vector3i.ZERO

## Array 3D de bloques [x][y][z] → BlockType
var blocks: Array = []

## MeshInstance3D para renderizar los bloques
var mesh_instance: MeshInstance3D = null

## StaticBody3D para colisiones
var collision_body: StaticBody3D = null

## CollisionShape3D para la colisión
var collision_shape: CollisionShape3D = null

## ¿El chunk está generado?
var is_generated: bool = false

## ¿El mesh necesita actualizarse?
var needs_mesh_update: bool = false

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONSTANTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const CHUNK_SIZE: int = Constants.CHUNK_SIZE
const MAX_HEIGHT: int = Constants.MAX_WORLD_HEIGHT
const BLOCK_SIZE: float = Constants.BLOCK_SIZE

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	# Inicializar array 3D de bloques
	_initialize_blocks_array()

	# Crear MeshInstance3D
	mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)

	# Crear StaticBody3D para colisiones
	collision_body = StaticBody3D.new()
	add_child(collision_body)

	collision_shape = CollisionShape3D.new()
	collision_body.add_child(collision_shape)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PÚBLICOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Inicializa el chunk con una posición
func initialize(pos: Vector3i) -> void:
	chunk_position = pos
	global_position = Utils.chunk_to_world_position(pos)
	name = "Chunk_%d_%d" % [pos.x, pos.z]


## Establece un bloque en una posición local del chunk
func set_block(local_pos: Vector3i, block_type: Enums.BlockType) -> void:
	if not _is_valid_local_position(local_pos):
		return

	blocks[local_pos.x][local_pos.y][local_pos.z] = block_type
	needs_mesh_update = true


## Obtiene el tipo de bloque en una posición local
func get_block(local_pos: Vector3i) -> Enums.BlockType:
	if not _is_valid_local_position(local_pos):
		return Enums.BlockType.NONE

	return blocks[local_pos.x][local_pos.y][local_pos.z]


## Genera el mesh del chunk (llamar después de llenar bloques)
## ACTUALIZADO: Ahora usa texturas en lugar de vertex colors
func generate_mesh() -> void:
	if not needs_mesh_update:
		return

	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# SISTEMA DE TEXTURAS HABILITADO
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# Las UVs se añaden en _add_face() usando TextureAtlasManager
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

	# Iterar por todos los bloques
	for x in range(CHUNK_SIZE):
		for y in range(MAX_HEIGHT):
			for z in range(CHUNK_SIZE):
				var block_type = blocks[x][y][z]

				if block_type == Enums.BlockType.NONE:
					continue

				# Generar caras visibles del bloque
				_generate_block_faces(surface_tool, Vector3i(x, y, z), block_type)

	# Crear mesh
	var array_mesh = surface_tool.commit()

	if array_mesh.get_surface_count() > 0:
		mesh_instance.mesh = array_mesh

		# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		# MATERIAL CON TEXTURA (reemplaza vertex colors)
		# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		var material = _create_textured_material()
		mesh_instance.set_surface_override_material(0, material)

		# Generar colisión
		_generate_collision(array_mesh)

	needs_mesh_update = false


## Limpia el chunk (resetea bloques)
func clear() -> void:
	_initialize_blocks_array()
	needs_mesh_update = true


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PRIVADOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Inicializa el array 3D de bloques (todos NONE)
func _initialize_blocks_array() -> void:
	blocks = []
	for x in range(CHUNK_SIZE):
		blocks.append([])
		for y in range(MAX_HEIGHT):
			blocks[x].append([])
			for z in range(CHUNK_SIZE):
				blocks[x][y].append(Enums.BlockType.NONE)


## Verifica si una posición local es válida
func _is_valid_local_position(local_pos: Vector3i) -> bool:
	return Utils.is_valid_local_position(local_pos)


## Genera las caras visibles de un bloque
## ACTUALIZADO: Ya no necesita obtener color, usa texturas
func _generate_block_faces(surface_tool: SurfaceTool, local_pos: Vector3i, block_type: Enums.BlockType) -> void:
	# Verificar cada cara del bloque
	for face in Enums.BlockFace.values():
		if _is_face_visible(local_pos, face):
			_add_face(surface_tool, local_pos, face, block_type)


## Verifica si una cara del bloque es visible (no está cubierta por otro bloque)
## OPTIMIZACIÓN: Verifica bloques vecinos incluso en chunks adyacentes
## Esto previene "seams" (costuras visuales) en los bordes de chunks
func _is_face_visible(local_pos: Vector3i, face: Enums.BlockFace) -> bool:
	var normal = Enums.FACE_NORMALS[face]
	var neighbor_pos = local_pos + Vector3i(roundi(normal.x), roundi(normal.y), roundi(normal.z))

	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# CASO 1: Vecino dentro del mismo chunk
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	if _is_valid_local_position(neighbor_pos):
		var neighbor_block = get_block(neighbor_pos)
		return neighbor_block == Enums.BlockType.NONE

	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# CASO 2: Vecino en chunk adyacente (PREVIENE SEAMS)
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# Convertir posición local a global
	var global_block_pos = Utils.local_to_global_block_position(chunk_position, local_pos)
	var neighbor_global_pos = global_block_pos + Vector3i(roundi(normal.x), roundi(normal.y), roundi(normal.z))

	# Obtener ChunkManager del padre
	var chunk_manager = get_parent()
	if chunk_manager == null or not chunk_manager.has_method("get_block"):
		# No hay ChunkManager, asumir que la cara es visible
		return true

	# Verificar bloque en chunk adyacente
	var adjacent_block = chunk_manager.get_block(neighbor_global_pos)
	return adjacent_block == Enums.BlockType.NONE


## Añade una cara de bloque al mesh
## ACTUALIZADO: Ahora usa UVs del texture atlas en lugar de vertex colors
func _add_face(surface_tool: SurfaceTool, local_pos: Vector3i, face: Enums.BlockFace, block_type: Enums.BlockType) -> void:
	var offset = Vector3(local_pos) * BLOCK_SIZE
	var normal = Enums.FACE_NORMALS[face]

	# Definir vértices según la cara
	var vertices = _get_face_vertices(face)

	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# OBTENER UVs DEL TEXTURE ATLAS
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# TextureAtlasManager devuelve las coordenadas UV correctas
	# teniendo en cuenta texturas especiales por cara (ej: cesped top/side)
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	var uvs = TextureAtlasManager.get_block_uvs(block_type, face)

	# Añadir triángulos (2 triángulos por cara = 6 vértices)
	var indices = [0, 1, 2, 0, 2, 3]  # Orden de vértices para formar triángulos

	for i in indices:
		var vertex = vertices[i] * BLOCK_SIZE + offset
		surface_tool.set_normal(normal)
		surface_tool.set_uv(uvs[i])  # ✅ NUEVO: Añadir coordenadas UV

		# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		# AMBIENT OCCLUSION PER-VERTEX
		# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		# Calculamos cuántos bloques vecinos tiene cada vértice
		# Más bloques vecinos = más oscuro (AO)
		# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		var ao_value = _calculate_vertex_ao(local_pos, face, i)
		var ao_color = Color(ao_value, ao_value, ao_value, 1.0)
		surface_tool.set_color(ao_color)  # ✅ NUEVO: AO en vertex colors

		surface_tool.add_vertex(vertex)


## Obtiene los vértices de una cara específica
func _get_face_vertices(face: Enums.BlockFace) -> Array:
	match face:
		Enums.BlockFace.TOP:
			return [
				Vector3(0, 1, 0), Vector3(1, 1, 0),
				Vector3(1, 1, 1), Vector3(0, 1, 1)
			]
		Enums.BlockFace.BOTTOM:
			return [
				Vector3(0, 0, 0), Vector3(1, 0, 0),
				Vector3(1, 0, 1), Vector3(0, 0, 1)
			]
		Enums.BlockFace.NORTH:
			return [
				Vector3(0, 0, 1), Vector3(0, 1, 1),
				Vector3(1, 1, 1), Vector3(1, 0, 1)
			]
		Enums.BlockFace.SOUTH:
			return [
				Vector3(1, 0, 0), Vector3(1, 1, 0),
				Vector3(0, 1, 0), Vector3(0, 0, 0)
			]
		Enums.BlockFace.EAST:
			return [
				Vector3(1, 0, 1), Vector3(1, 1, 1),
				Vector3(1, 1, 0), Vector3(1, 0, 0)
			]
		Enums.BlockFace.WEST:
			return [
				Vector3(0, 0, 0), Vector3(0, 1, 0),
				Vector3(0, 1, 1), Vector3(0, 0, 1)
			]
		_:
			return []


## Genera la colisión del chunk desde el mesh
func _generate_collision(mesh: ArrayMesh) -> void:
	if mesh.get_surface_count() == 0:
		return

	# Crear shape de colisión desde el mesh
	var shape = mesh.create_trimesh_shape()
	if shape:
		collision_shape.shape = shape


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SISTEMA DE MATERIALES CON TEXTURAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Crea un material con shader custom para renderizar bloques
## @return ShaderMaterial con AO y Fog
func _create_textured_material() -> ShaderMaterial:
	var material = ShaderMaterial.new()

	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# CARGAR SHADER CUSTOM
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	var shader = load("res://shaders/block_voxel.gdshader")
	if shader:
		material.shader = shader
	else:
		push_error("❌ Chunk: No se pudo cargar block_voxel.gdshader")
		# Fallback a material simple
		var fallback = StandardMaterial3D.new()
		fallback.albedo_color = Color.WHITE
		return fallback

	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# CONFIGURAR PARÁMETROS DEL SHADER
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

	# Textura atlas
	var texture = load("res://assets/textures/block_atlas.png")
	if texture:
		material.set_shader_parameter("albedo_texture", texture)

	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# AMBIENT OCCLUSION
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	material.set_shader_parameter("enable_ao", true)
	material.set_shader_parameter("ao_strength", 0.4)  # 40% de oscurecimiento

	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# FOG ATMOSFÉRICO
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	material.set_shader_parameter("enable_fog", true)
	material.set_shader_parameter("fog_color", Color(0.6, 0.7, 0.8, 1.0))  # Azul cielo
	material.set_shader_parameter("fog_density", 0.015)
	material.set_shader_parameter("fog_start", 10.0)  # Empieza a 10 metros
	material.set_shader_parameter("fog_end", 80.0)    # Totalmente opaco a 80 metros

	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# ILUMINACIÓN
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	material.set_shader_parameter("ambient_light", 0.6)   # 60% luz ambiente
	material.set_shader_parameter("sun_intensity", 1.2)   # Sol 20% más intenso

	return material


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SISTEMA DE AMBIENT OCCLUSION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Calcula el valor de AO para un vértice específico
## @param local_pos Posición del bloque
## @param face Cara del bloque
## @param vertex_index Índice del vértice (0-3)
## @return float Valor de AO [0.0=oscuro, 1.0=brillante]
func _calculate_vertex_ao(local_pos: Vector3i, face: Enums.BlockFace, vertex_index: int) -> float:
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# ALGORITMO DE AO PER-VERTEX
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# Para cada vértice, verificamos 3 bloques vecinos:
	# - 2 en los lados (side1, side2)
	# - 1 en la esquina diagonal (corner)
	#
	# AO = función de cuántos están llenos
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

	# Obtener los offsets de los 3 vecinos según la cara y vértice
	var neighbors = _get_ao_neighbors(face, vertex_index)

	# Contar cuántos vecinos están llenos (no son NONE)
	var filled_count = 0
	for neighbor_offset in neighbors:
		var neighbor_pos = local_pos + neighbor_offset
		if _is_block_solid(neighbor_pos):
			filled_count += 1

	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# MAPEAR FILLED_COUNT A AO VALUE
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# 0 vecinos = 1.0 (totalmente brillante)
	# 1 vecino  = 0.8
	# 2 vecinos = 0.5
	# 3 vecinos = 0.3 (totalmente oscuro)
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

	match filled_count:
		0: return 1.0
		1: return 0.8
		2: return 0.5
		3: return 0.3
		_: return 1.0


## Obtiene los offsets de los 3 vecinos para calcular AO
## @param face Cara del bloque
## @param vertex_index Índice del vértice (0-5 después de indices)
## @return Array[Vector3i] Offsets de los 3 vecinos (side1, side2, corner)
func _get_ao_neighbors(face: Enums.BlockFace, vertex_index: int) -> Array[Vector3i]:
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# MAPEO COMPLETO DE VECINOS POR CARA Y VÉRTICE
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# Para cada vértice de cada cara, definimos 3 bloques vecinos:
	# - side1: Primer lado adyacente
	# - side2: Segundo lado adyacente
	# - corner: Bloque en la esquina diagonal
	#
	# Algoritmo de AO correcto:
	# if (side1 && side2) → AO = 0.0 (muy oscuro)
	# else → AO = 3 - (side1 + side2 + corner)
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

	var neighbors: Array[Vector3i] = []

	# El vertex_index viene del array de índices [0,1,2,0,2,3]
	# Necesitamos mapearlo al vértice real de la cara (0-3)
	var real_vertex_index = vertex_index
	if vertex_index == 3:
		real_vertex_index = 0  # Primer triángulo repite vértice 0
	elif vertex_index == 4:
		real_vertex_index = 2  # Segundo triángulo repite vértice 2

	match face:
		# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		# CARA TOP (Y+)
		# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		# Vértices: [0,0,1], [1,0,1], [1,0,0], [0,0,0]
		# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		Enums.BlockFace.TOP:
			match real_vertex_index:
				0:  # (0, 1, 0) - esquina noreste
					neighbors = [Vector3i(0, 1, 1), Vector3i(-1, 1, 0), Vector3i(-1, 1, 1)]
				1:  # (1, 1, 0) - esquina sureste
					neighbors = [Vector3i(1, 1, 0), Vector3i(0, 1, -1), Vector3i(1, 1, -1)]
				2:  # (1, 1, 1) - esquina suroeste
					neighbors = [Vector3i(1, 1, 0), Vector3i(0, 1, 1), Vector3i(1, 1, 1)]
				3:  # (0, 1, 1) - esquina noroeste
					neighbors = [Vector3i(-1, 1, 0), Vector3i(0, 1, 1), Vector3i(-1, 1, 1)]

		# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		# CARA BOTTOM (Y-)
		# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		Enums.BlockFace.BOTTOM:
			match real_vertex_index:
				0:  # (0, 0, 0) - Nuevo orden
					neighbors = [Vector3i(-1, -1, 0), Vector3i(0, -1, -1), Vector3i(-1, -1, -1)]
				1:  # (1, 0, 0)
					neighbors = [Vector3i(1, -1, 0), Vector3i(0, -1, -1), Vector3i(1, -1, -1)]
				2:  # (1, 0, 1)
					neighbors = [Vector3i(1, -1, 0), Vector3i(0, -1, 1), Vector3i(1, -1, 1)]
				3:  # (0, 0, 1)
					neighbors = [Vector3i(-1, -1, 0), Vector3i(0, -1, 1), Vector3i(-1, -1, 1)]

		# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		# CARA NORTH (Z+)
		# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		Enums.BlockFace.NORTH:
			match real_vertex_index:
				0:  # (0, 0, 1)
					neighbors = [Vector3i(-1, 0, 1), Vector3i(0, -1, 1), Vector3i(-1, -1, 1)]
				1:  # (0, 1, 1)
					neighbors = [Vector3i(-1, 0, 1), Vector3i(0, 1, 1), Vector3i(-1, 1, 1)]
				2:  # (1, 1, 1)
					neighbors = [Vector3i(1, 0, 1), Vector3i(0, 1, 1), Vector3i(1, 1, 1)]
				3:  # (1, 0, 1)
					neighbors = [Vector3i(1, 0, 1), Vector3i(0, -1, 1), Vector3i(1, -1, 1)]

		# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		# CARA SOUTH (Z-)
		# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		Enums.BlockFace.SOUTH:
			match real_vertex_index:
				0:  # (1, 0, 0)
					neighbors = [Vector3i(1, 0, -1), Vector3i(0, -1, -1), Vector3i(1, -1, -1)]
				1:  # (1, 1, 0)
					neighbors = [Vector3i(1, 0, -1), Vector3i(0, 1, -1), Vector3i(1, 1, -1)]
				2:  # (0, 1, 0)
					neighbors = [Vector3i(-1, 0, -1), Vector3i(0, 1, -1), Vector3i(-1, 1, -1)]
				3:  # (0, 0, 0)
					neighbors = [Vector3i(-1, 0, -1), Vector3i(0, -1, -1), Vector3i(-1, -1, -1)]

		# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		# CARA EAST (X+)
		# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		Enums.BlockFace.EAST:
			match real_vertex_index:
				0:  # (1, 0, 1)
					neighbors = [Vector3i(1, 0, 1), Vector3i(1, -1, 0), Vector3i(1, -1, 1)]
				1:  # (1, 1, 1)
					neighbors = [Vector3i(1, 0, 1), Vector3i(1, 1, 0), Vector3i(1, 1, 1)]
				2:  # (1, 1, 0)
					neighbors = [Vector3i(1, 0, -1), Vector3i(1, 1, 0), Vector3i(1, 1, -1)]
				3:  # (1, 0, 0)
					neighbors = [Vector3i(1, 0, -1), Vector3i(1, -1, 0), Vector3i(1, -1, -1)]

		# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		# CARA WEST (X-)
		# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		Enums.BlockFace.WEST:
			match real_vertex_index:
				0:  # (0, 0, 0)
					neighbors = [Vector3i(-1, 0, -1), Vector3i(-1, -1, 0), Vector3i(-1, -1, -1)]
				1:  # (0, 1, 0)
					neighbors = [Vector3i(-1, 0, -1), Vector3i(-1, 1, 0), Vector3i(-1, 1, -1)]
				2:  # (0, 1, 1)
					neighbors = [Vector3i(-1, 0, 1), Vector3i(-1, 1, 0), Vector3i(-1, 1, 1)]
				3:  # (0, 0, 1)
					neighbors = [Vector3i(-1, 0, 1), Vector3i(-1, -1, 0), Vector3i(-1, -1, 1)]

	return neighbors


## Verifica si un bloque en una posición es sólido (para AO)
## @param local_pos Posición local en el chunk
## @return bool True si el bloque es sólido
func _is_block_solid(local_pos: Vector3i) -> bool:
	# Verificar si está dentro del chunk
	if _is_valid_local_position(local_pos):
		return get_block(local_pos) != Enums.BlockType.NONE

	# Si está fuera del chunk, verificar en chunk vecino
	var chunk_manager = get_parent()
	if chunk_manager and chunk_manager.has_method("get_block"):
		var global_pos = Utils.local_to_global_block_position(chunk_position, local_pos)
		return chunk_manager.get_block(global_pos) != Enums.BlockType.NONE

	return false
