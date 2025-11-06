# ============================================================================
# BiomeManager.gd - Manager de Biomas (Autoload/Singleton)
# ============================================================================
# Orquestador que gestiona el generador de biomas.
# Este ES un autoload. Proporciona interfaz simple al resto del sistema.
# ============================================================================

extends Node

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SEÑALES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Emitida cuando el sistema está listo para usar
signal biome_system_ready

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# COMPOSICIÓN (Dependency Injection)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var _generator: BiomeGenerator = null

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CACHÉ (Optimización opcional)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var _biome_cache: Dictionary = {}  # Vector2i → BiomeType
const MAX_CACHE_SIZE: int = 1000

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CICLO DE VIDA
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	print("🌍 BiomeManager cargado (esperando inicialización)")


## Inicializa el sistema con una semilla
## DEBE ser llamado antes de usar el sistema (típicamente desde GameWorld)
func initialize(world_seed: int) -> void:
	# Crear generador
	_generator = BiomeGenerator.new()
	_generator.initialize(world_seed)

	# Limpiar caché
	_biome_cache.clear()

	biome_system_ready.emit()
	print("✅ BiomeManager inicializado y listo")


## Libera recursos al salir
func _exit_tree() -> void:
	_biome_cache.clear()
	_generator = null


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# API PÚBLICA (Delega al generador)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Obtiene el bioma en una posición mundial XZ (con caché)
func get_biome_at(world_x: int, world_z: int) -> BiomeGenerator.BiomeType:
	assert(_generator != null, "BiomeManager not initialized! Call initialize() first")

	# Verificar caché
	var cache_key := Vector2i(world_x, world_z)
	if _biome_cache.has(cache_key):
		return _biome_cache[cache_key]

	# Calcular y cachear
	var biome := _generator.calculate_biome(world_x, world_z)

	# Limitar tamaño de caché (FIFO simple)
	if _biome_cache.size() >= MAX_CACHE_SIZE:
		var first_key = _biome_cache.keys()[0]
		_biome_cache.erase(first_key)

	_biome_cache[cache_key] = biome
	return biome


## Obtiene datos de configuración de un bioma
func get_biome_data(biome: BiomeGenerator.BiomeType) -> Dictionary:
	assert(_generator != null, "BiomeManager not initialized")
	return _generator.get_biome_config(biome)


## Obtiene el bloque de superficie para un bioma
func get_surface_block(biome: BiomeGenerator.BiomeType) -> Enums.BlockType:
	assert(_generator != null, "BiomeManager not initialized")
	return _generator.get_surface_block(biome)


## Obtiene el bloque subterráneo para un bioma
func get_underground_block(biome: BiomeGenerator.BiomeType) -> Enums.BlockType:
	assert(_generator != null, "BiomeManager not initialized")
	return _generator.get_underground_block(biome)


## Obtiene el bloque profundo para un bioma
func get_deep_block(biome: BiomeGenerator.BiomeType) -> Enums.BlockType:
	assert(_generator != null, "BiomeManager not initialized")
	return _generator.get_deep_block(biome)


## Obtiene el rango de altura para un bioma
func get_height_range(biome: BiomeGenerator.BiomeType) -> Vector2i:
	assert(_generator != null, "BiomeManager not initialized")
	return _generator.get_height_range(biome)


## Obtiene la probabilidad de árbol para un bioma
func get_tree_chance(biome: BiomeGenerator.BiomeType) -> float:
	assert(_generator != null, "BiomeManager not initialized")
	return _generator.get_tree_chance(biome)


## Obtiene el nombre del bioma
func get_biome_name(biome: BiomeGenerator.BiomeType) -> String:
	assert(_generator != null, "BiomeManager not initialized")
	return _generator.get_biome_name(biome)


## Obtiene el color del bioma (para UI/debug)
func get_biome_color(biome: BiomeGenerator.BiomeType) -> Color:
	assert(_generator != null, "BiomeManager not initialized")
	return _generator.get_biome_color(biome)


## Verifica si el sistema está listo
func is_ready() -> bool:
	return _generator != null and _generator.is_ready()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# UTILIDADES DE DEBUG
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Limpia la caché (útil si se cambia la semilla)
func clear_cache() -> void:
	_biome_cache.clear()
	print("🗑️ Caché de biomas limpiado")


## Obtiene estadísticas de la caché
func get_cache_stats() -> Dictionary:
	return {
		"size": _biome_cache.size(),
		"max_size": MAX_CACHE_SIZE,
		"usage_percent": (float(_biome_cache.size()) / MAX_CACHE_SIZE) * 100.0
	}


## Genera mapa de biomas para debug
func generate_debug_map(size: int) -> Array[BiomeGenerator.BiomeType]:
	assert(_generator != null, "BiomeManager not initialized")
	return _generator.generate_debug_map(size)


## Re-exponer el enum para facilitar acceso
## Esto permite: BiomeManager.BiomeType.BOSQUE
enum BiomeType {
	BOSQUE = BiomeGenerator.BiomeType.BOSQUE,
	DESIERTO = BiomeGenerator.BiomeType.DESIERTO,
	MONTAÑA = BiomeGenerator.BiomeType.MONTAÑA,
	PLAYA = BiomeGenerator.BiomeType.PLAYA,
	CRISTAL = BiomeGenerator.BiomeType.CRISTAL
}
