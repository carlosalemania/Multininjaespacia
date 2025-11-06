# ============================================================================
# test_biome_system.gd - Test Manual del Sistema de Biomas Refactorizado
# ============================================================================
# Prueba la nueva arquitectura BiomeGenerator + BiomeManager
# Para ejecutar: Agregar como escena temporal y correr en Godot
# ============================================================================

extends Node

func _ready() -> void:
	var separator := ""
	for i in range(80):
		separator += "="
	print("\n" + separator)
	print("🧪 INICIANDO TESTS DEL SISTEMA DE BIOMAS REFACTORIZADO")
	print(separator + "\n")

	var all_passed := true

	# Test 1: Inicialización
	all_passed = test_initialization() and all_passed

	# Test 2: Consistencia de biomas
	all_passed = test_biome_consistency() and all_passed

	# Test 3: Diversidad de biomas
	all_passed = test_biome_diversity() and all_passed

	# Test 4: Configuración de bloques
	all_passed = test_block_configuration() and all_passed

	# Test 5: Caché del manager
	all_passed = test_cache_system() and all_passed

	# Test 6: Rangos de altura
	all_passed = test_height_ranges() and all_passed

	# Test 7: Integración con TerrainGenerator
	all_passed = test_terrain_integration() and all_passed

	print("\n" + separator)
	if all_passed:
		print("✅ TODOS LOS TESTS PASARON")
	else:
		print("❌ ALGUNOS TESTS FALLARON")
	print(separator + "\n")

	# Auto-cerrar después de 2 segundos
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TESTS INDIVIDUALES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func test_initialization() -> bool:
	print("📋 Test 1: Inicialización del Sistema")
	print("   ├─ Verificando que BiomeManager es autoload...")

	if not BiomeManager:
		print("   ❌ BiomeManager no está disponible como autoload")
		return false

	print("   ├─ Inicializando con seed 12345...")
	BiomeManager.initialize(12345)

	if not BiomeManager.is_ready():
		print("   ❌ BiomeManager no está listo después de initialize()")
		return false

	print("   ✅ Sistema inicializado correctamente\n")
	return true


func test_biome_consistency() -> bool:
	print("📋 Test 2: Consistencia de Biomas")
	print("   ├─ Verificando que misma posición = mismo bioma...")

	var test_positions := [
		Vector2i(0, 0),
		Vector2i(100, 200),
		Vector2i(-50, 75),
		Vector2i(999, -999)
	]

	for pos in test_positions:
		var biome1 = BiomeManager.get_biome_at(pos.x, pos.y)
		var biome2 = BiomeManager.get_biome_at(pos.x, pos.y)

		if biome1 != biome2:
			print("   ❌ Inconsistencia en posición ", pos)
			return false

	print("   ✅ Biomas consistentes en todas las posiciones\n")
	return true


func test_biome_diversity() -> bool:
	print("📋 Test 3: Diversidad de Biomas")
	print("   ├─ Verificando que existen múltiples biomas...")

	var biomes_found := {}
	var sample_size := 100

	for x in range(sample_size):
		for z in range(sample_size):
			var biome = BiomeManager.get_biome_at(x, z)
			biomes_found[biome] = biomes_found.get(biome, 0) + 1

	print("   ├─ Biomas encontrados en ", sample_size, "x", sample_size, " área:")
	for biome in biomes_found.keys():
		var biome_name = BiomeManager.get_biome_name(biome)
		var count = biomes_found[biome]
		var percentage = (float(count) / (sample_size * sample_size)) * 100.0
		print("   │  • ", biome_name, ": ", count, " bloques (", "%.1f" % percentage, "%)")

	if biomes_found.size() < 2:
		print("   ❌ Solo se encontró 1 tipo de bioma")
		return false

	print("   ✅ Se encontraron ", biomes_found.size(), " tipos de biomas diferentes\n")
	return true


func test_block_configuration() -> bool:
	print("📋 Test 4: Configuración de Bloques por Bioma")
	print("   ├─ Verificando que todos los biomas tienen bloques definidos...")

	var biome_types := [
		BiomeManager.BiomeType.BOSQUE,
		BiomeManager.BiomeType.DESIERTO,
		BiomeManager.BiomeType.MONTAÑA,
		BiomeManager.BiomeType.PLAYA,
		BiomeManager.BiomeType.CRISTAL
	]

	for biome in biome_types:
		var biome_name = BiomeManager.get_biome_name(biome)
		var surface = BiomeManager.get_surface_block(biome)
		var underground = BiomeManager.get_underground_block(biome)
		var deep = BiomeManager.get_deep_block(biome)

		print("   │  ", biome_name, ":")
		print("   │    • Superficie: ", Enums.BLOCK_NAMES.get(surface, "???"))
		print("   │    • Subterráneo: ", Enums.BLOCK_NAMES.get(underground, "???"))
		print("   │    • Profundo: ", Enums.BLOCK_NAMES.get(deep, "???"))

		if surface == Enums.BlockType.NONE:
			print("   ❌ Bioma ", biome_name, " no tiene bloque de superficie")
			return false

		if underground == Enums.BlockType.NONE:
			print("   ❌ Bioma ", biome_name, " no tiene bloque subterráneo")
			return false

		if deep == Enums.BlockType.NONE:
			print("   ❌ Bioma ", biome_name, " no tiene bloque profundo")
			return false

	print("   ✅ Todos los biomas tienen bloques correctamente configurados\n")
	return true


func test_cache_system() -> bool:
	print("📋 Test 5: Sistema de Caché")
	print("   ├─ Limpiando caché...")

	BiomeManager.clear_cache()
	var stats_before = BiomeManager.get_cache_stats()

	if stats_before.size != 0:
		print("   ❌ Caché no se limpió correctamente")
		return false

	print("   ├─ Realizando 50 consultas...")
	for i in range(50):
		BiomeManager.get_biome_at(i, i)

	var stats_after = BiomeManager.get_cache_stats()
	print("   │  • Entradas en caché: ", stats_after.size)
	print("   │  • Uso: ", "%.1f" % stats_after.usage_percent, "%")

	if stats_after.size != 50:
		print("   ❌ Caché no almacenó las consultas correctamente")
		return false

	print("   ✅ Sistema de caché funciona correctamente\n")
	return true


func test_height_ranges() -> bool:
	print("📋 Test 6: Rangos de Altura por Bioma")
	print("   ├─ Verificando rangos válidos...")

	var biome_types := [
		BiomeManager.BiomeType.BOSQUE,
		BiomeManager.BiomeType.DESIERTO,
		BiomeManager.BiomeType.MONTAÑA,
		BiomeManager.BiomeType.PLAYA,
		BiomeManager.BiomeType.CRISTAL
	]

	for biome in biome_types:
		var biome_name = BiomeManager.get_biome_name(biome)
		var height_range = BiomeManager.get_height_range(biome)
		var tree_chance = BiomeManager.get_tree_chance(biome)

		print("   │  ", biome_name, ":")
		print("   │    • Altura: ", height_range.x, " - ", height_range.y)
		print("   │    • Árboles: ", "%.1f" % (tree_chance * 100.0), "%")

		if height_range.x >= height_range.y:
			print("   ❌ Rango de altura inválido para ", biome_name)
			return false

		if height_range.x < 0 or height_range.y > 50:
			print("   ❌ Rango de altura fuera de límites para ", biome_name)
			return false

	print("   ✅ Todos los rangos de altura son válidos\n")
	return true


func test_terrain_integration() -> bool:
	print("📋 Test 7: Integración con TerrainGenerator")
	print("   ├─ Verificando que BiomeManager puede ser usado por TerrainGenerator...")

	# Simular lo que hace TerrainGenerator
	var test_x := 50
	var test_z := 100

	var biome = BiomeManager.get_biome_at(test_x, test_z)
	var biome_data = BiomeManager.get_biome_data(biome)

	print("   │  Posición (", test_x, ", ", test_z, "):")
	print("   │    • Bioma: ", BiomeManager.get_biome_name(biome))
	print("   │    • Datos disponibles: ", biome_data.keys())

	# Verificar que biome_data tiene todas las claves necesarias
	var required_keys := ["name", "surface_block", "underground_block", "deep_block", "min_height", "max_height", "tree_chance"]

	for key in required_keys:
		if not biome_data.has(key):
			print("   ❌ Falta clave requerida: ", key)
			return false

	print("   ✅ BiomeManager proporciona todos los datos necesarios\n")
	return true
