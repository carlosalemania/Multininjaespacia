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
	var neighbor_block = chunk_manager.get_block(neighbor_global_pos)
	return neighbor_block == Enums.BlockType.NONE


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
		# ❌ REMOVIDO: surface_tool.set_color(color)  # Ya no usamos vertex colors
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


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SISTEMA DE MATERIALES CON TEXTURAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Crea un material con el texture atlas para renderizar bloques
## @return StandardMaterial3D configurado para voxels
func _create_textured_material() -> StandardMaterial3D:
	var material = StandardMaterial3D.new()

	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# TEXTURA ALBEDO (color base)
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	var texture = load("res://assets/textures/block_atlas.png")
	if texture:
		material.albedo_texture = texture
	else:
		push_warning("⚠️ Chunk: No se pudo cargar block_atlas.png, usando color fallback")
		material.albedo_color = Color.WHITE

	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# FILTRO DE TEXTURA: NEAREST (pixel-perfect para voxels)
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# NEAREST = Sin interpolación, mantiene pixels nítidos
	# Perfecto para estética retro/pixel art
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST

	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# CULLING: BACK (no renderizar caras traseras)
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# Optimización estándar: caras internas son invisibles
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	material.cull_mode = BaseMaterial3D.CULL_BACK

	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# DESACTIVAR VERTEX COLORS (ahora usamos texturas)
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	material.vertex_color_use_as_albedo = false

	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# SHADING: UNSHADED (sin iluminación por ahora)
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# Mantiene colores vibrantes sin sombras
	# TODO futuro: Cambiar a shading_mode = SHADING_MODE_PER_PIXEL con luces
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	return material
