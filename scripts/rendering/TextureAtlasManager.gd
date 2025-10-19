# ============================================================================
# TextureAtlasManager.gd - Gestor de Atlas de Texturas
# ============================================================================
# Administra el mapeo de coordenadas UV para el texture atlas de bloques
# ============================================================================
# ARQUITECTURA:
# - Patrón: Facade Pattern (simplifica acceso a UVs)
# - Optimización: Cache de UVs para evitar recalcular
# - Escalabilidad: Soporta texturas por cara (grass top/side)
# ============================================================================

extends Node
class_name TextureAtlasManager

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONSTANTES DEL ATLAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Tamaño total del atlas en pixels (256x256)
const ATLAS_SIZE: int = 256

## Tamaño de cada tile de bloque en pixels (16x16)
const TILE_SIZE: int = 16

## Número de tiles por fila/columna (256 / 16 = 16)
const TILES_PER_ROW: int = 16

## Pequeño padding para evitar bleeding de texturas vecinas
const UV_PADDING: float = 0.001

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MAPEO DE TEXTURAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Mapeo de BlockType a posición en el atlas (x, y en tiles)
## Estructura: { BlockType: { "default": Vector2i, "top": Vector2i, ... } }
const TEXTURE_MAP: Dictionary = {
	# Fila 0: Bloques básicos
	Enums.BlockType.TIERRA: {
		"default": Vector2i(0, 0)  # Marrón oscuro
	},
	Enums.BlockType.PIEDRA: {
		"default": Vector2i(1, 0)  # Gris
	},
	Enums.BlockType.MADERA: {
		"default": Vector2i(2, 0)  # Marrón claro
	},
	Enums.BlockType.ARENA: {
		"default": Vector2i(3, 0)  # Amarillo arena
	},

	# Fila 1: Bloques con caras especiales
	Enums.BlockType.CESPED: {
		"top": Vector2i(0, 1),      # Verde césped
		"side": Vector2i(1, 1),     # Tierra + césped en borde
		"bottom": Vector2i(0, 0)    # Tierra normal
	},
	Enums.BlockType.HOJAS: {
		"default": Vector2i(2, 1)   # Verde hojas
	},

	# Fila 2: Minerales
	Enums.BlockType.CRISTAL: {
		"default": Vector2i(0, 2)   # Cyan brillante
	},
	Enums.BlockType.ORO: {
		"default": Vector2i(1, 2)   # Dorado
	},
	Enums.BlockType.PLATA: {
		"default": Vector2i(2, 2)   # Plateado
	},
	Enums.BlockType.METAL: {
		"default": Vector2i(3, 2)   # Gris metálico
	},

	# Fila 3: Bloques especiales
	Enums.BlockType.NIEVE: {
		"default": Vector2i(0, 3)   # Blanco nieve
	},
	Enums.BlockType.HIELO: {
		"default": Vector2i(1, 3)   # Cyan hielo
	},
}

## Cache de UVs calculados para evitar recalcular
## Estructura: { "BlockType_Face" : [Vector2, Vector2, Vector2, Vector2] }
static var _uv_cache: Dictionary = {}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PÚBLICOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Obtiene las coordenadas UV para un bloque y cara específica
## @param block_type Tipo de bloque (Enums.BlockType)
## @param face Cara del bloque (Enums.BlockFace)
## @return Array[Vector2] con 4 UVs (top-left, top-right, bottom-right, bottom-left)
static func get_block_uvs(block_type: Enums.BlockType, face: Enums.BlockFace) -> Array[Vector2]:
	# Verificar cache primero (optimización O(1))
	var cache_key = "%d_%d" % [block_type, face]
	if _uv_cache.has(cache_key):
		return _uv_cache[cache_key]

	# Obtener posición en el atlas
	var atlas_pos = _get_atlas_position(block_type, face)

	# Calcular UVs normalizados [0.0, 1.0]
	var uvs = _calculate_uvs(atlas_pos)

	# Guardar en cache
	_uv_cache[cache_key] = uvs

	return uvs


## Obtiene la posición del tile en el atlas para un bloque y cara
## @param block_type Tipo de bloque
## @param face Cara del bloque
## @return Vector2i posición en tiles (x, y)
static func _get_atlas_position(block_type: Enums.BlockType, face: Enums.BlockFace) -> Vector2i:
	# Verificar que el bloque existe en el mapeo
	if not TEXTURE_MAP.has(block_type):
		push_warning("⚠️ TextureAtlasManager: Bloque %d no tiene textura definida, usando default" % block_type)
		return Vector2i(0, 0)  # Fallback a tierra

	var texture_data = TEXTURE_MAP[block_type]

	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# LÓGICA DE TEXTURAS POR CARA
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# Algunos bloques (como CESPED) tienen texturas diferentes por cara:
	# - TOP: Césped verde
	# - SIDE: Tierra con borde de césped
	# - BOTTOM: Tierra normal
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

	# Intentar obtener textura específica por cara
	match face:
		Enums.BlockFace.TOP:
			if texture_data.has("top"):
				return texture_data.top
		Enums.BlockFace.BOTTOM:
			if texture_data.has("bottom"):
				return texture_data.bottom
		Enums.BlockFace.NORTH, Enums.BlockFace.SOUTH, Enums.BlockFace.EAST, Enums.BlockFace.WEST:
			if texture_data.has("side"):
				return texture_data.side

	# Si no hay textura específica, usar default
	if texture_data.has("default"):
		return texture_data.default

	# Fallback final
	return Vector2i(0, 0)


## Calcula coordenadas UV normalizadas desde posición en tiles
## @param atlas_pos Posición en tiles (x, y)
## @return Array[Vector2] con 4 UVs para un quad
static func _calculate_uvs(atlas_pos: Vector2i) -> Array[Vector2]:
	# Convertir de posición en tiles a posición en pixels
	var pixel_x = atlas_pos.x * TILE_SIZE
	var pixel_y = atlas_pos.y * TILE_SIZE

	# Normalizar a rango [0.0, 1.0]
	var u0 = float(pixel_x) / float(ATLAS_SIZE) + UV_PADDING
	var v0 = float(pixel_y) / float(ATLAS_SIZE) + UV_PADDING
	var u1 = float(pixel_x + TILE_SIZE) / float(ATLAS_SIZE) - UV_PADDING
	var v1 = float(pixel_y + TILE_SIZE) / float(ATLAS_SIZE) - UV_PADDING

	# Retornar 4 vértices del quad en orden correcto
	# Orden: top-left, top-right, bottom-right, bottom-left
	var uvs: Array[Vector2] = [
		Vector2(u0, v0),  # Top-left
		Vector2(u1, v0),  # Top-right
		Vector2(u1, v1),  # Bottom-right
		Vector2(u0, v1)   # Bottom-left
	]

	return uvs


## Limpia el cache de UVs (útil si cambia el atlas en runtime)
static func clear_cache() -> void:
	_uv_cache.clear()
	print("🗑️ TextureAtlasManager: Cache de UVs limpiado")


## Obtiene información de debug del atlas
static func get_debug_info() -> Dictionary:
	return {
		"atlas_size": ATLAS_SIZE,
		"tile_size": TILE_SIZE,
		"tiles_per_row": TILES_PER_ROW,
		"total_tiles": TILES_PER_ROW * TILES_PER_ROW,
		"blocks_mapped": TEXTURE_MAP.size(),
		"cached_uvs": _uv_cache.size()
	}
