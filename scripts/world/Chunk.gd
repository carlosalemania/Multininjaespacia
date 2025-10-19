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
func generate_mesh() -> void:
	if not needs_mesh_update:
		return

	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

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

		# Crear material simple
		var material = StandardMaterial3D.new()
		material.vertex_color_use_as_albedo = true
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
func _generate_block_faces(surface_tool: SurfaceTool, local_pos: Vector3i, block_type: Enums.BlockType) -> void:
	var block_color = Utils.get_block_color(block_type)

	# Verificar cada cara del bloque
	for face in Enums.BlockFace.values():
		if _is_face_visible(local_pos, face):
			_add_face(surface_tool, local_pos, face, block_color)


## Verifica si una cara del bloque es visible (no está cubierta por otro bloque)
func _is_face_visible(local_pos: Vector3i, face: Enums.BlockFace) -> bool:
	var normal = Enums.FACE_NORMALS[face]
	var neighbor_pos = local_pos + Vector3i(roundi(normal.x), roundi(normal.y), roundi(normal.z))

	# Si el vecino está fuera del chunk, la cara es visible
	if not _is_valid_local_position(neighbor_pos):
		return true

	# Si el vecino es aire, la cara es visible
	var neighbor_block = get_block(neighbor_pos)
	return neighbor_block == Enums.BlockType.NONE


## Añade una cara de bloque al mesh
func _add_face(surface_tool: SurfaceTool, local_pos: Vector3i, face: Enums.BlockFace, color: Color) -> void:
	var offset = Vector3(local_pos) * BLOCK_SIZE
	var normal = Enums.FACE_NORMALS[face]

	# Definir vértices según la cara
	var vertices = _get_face_vertices(face)

	# Añadir triángulos (2 triángulos por cara = 6 vértices)
	var indices = [0, 1, 2, 0, 2, 3]  # Orden de vértices para formar triángulos

	for i in indices:
		var vertex = vertices[i] * BLOCK_SIZE + offset
		surface_tool.set_normal(normal)
		surface_tool.set_color(color)
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
				Vector3(0, 0, 1), Vector3(1, 0, 1),
				Vector3(1, 0, 0), Vector3(0, 0, 0)
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
