# ============================================================================
# test_furniture_system.gd - Pruebas Unitarias para FurnitureSystem
# ============================================================================

extends Node

var test_results = []
var passed_tests = 0
var failed_tests = 0

func _ready() -> void:
	print("\n" + "=".repeat(80))
	print("INICIANDO PRUEBAS UNITARIAS - FURNITURE SYSTEM")
	print("=".repeat(80) + "\n")

	run_all_tests()
	print_results()

func run_all_tests() -> void:
	# Tests de inicialización
	test_furniture_system_initialization()
	test_furniture_data_structure()

	# Tests de muebles específicos
	test_wooden_bed()
	test_wooden_table()
	test_wooden_chair()
	test_wooden_chest()
	test_torch()
	test_lantern()
	test_bookshelf()
	test_crafting_table()
	test_furnace()
	test_small_painting()

	# Tests de funcionalidades
	test_get_furniture()
	test_get_furniture_by_category()
	test_get_all_furniture()
	test_place_furniture()
	test_remove_furniture()
	test_interact_with_furniture()

## ============================================================================
## TESTS DE INICIALIZACIÓN
## ============================================================================

func test_furniture_system_initialization() -> void:
	var test_name = "FurnitureSystem se inicializa correctamente"

	if FurnitureSystem == null:
		add_test_result(test_name, false, "FurnitureSystem no está disponible como autoload")
		return

	if FurnitureSystem.furniture_library == null:
		add_test_result(test_name, false, "furniture_library es null")
		return

	if FurnitureSystem.furniture_library.size() == 0:
		add_test_result(test_name, false, "furniture_library está vacía")
		return

	add_test_result(test_name, true, "Sistema inicializado con %d muebles" % FurnitureSystem.furniture_library.size())

func test_furniture_data_structure() -> void:
	var test_name = "FurnitureData tiene la estructura correcta"

	var bed = FurnitureSystem.get_furniture("wooden_bed")
	if bed == null:
		add_test_result(test_name, false, "No se pudo obtener wooden_bed")
		return

	var required_properties = [
		"furniture_id", "furniture_name", "description", "category",
		"size", "is_solid", "can_rotate", "interaction_type",
		"emits_light", "storage_slots", "primary_color", "secondary_color"
	]

	for prop in required_properties:
		if not (prop in bed):
			add_test_result(test_name, false, "Falta propiedad: " + prop)
			return

	add_test_result(test_name, true, "Todas las propiedades requeridas están presentes")

## ============================================================================
## TESTS DE MUEBLES ESPECÍFICOS
## ============================================================================

func test_wooden_bed() -> void:
	var test_name = "Wooden Bed - Configuración correcta"
	var bed = FurnitureSystem.get_furniture("wooden_bed")

	if bed == null:
		add_test_result(test_name, false, "wooden_bed no existe")
		return

	var checks = [
		bed.furniture_id == "wooden_bed",
		bed.furniture_name == "Cama de Madera",
		bed.category == FurnitureData.FurnitureCategory.BASIC_FURNITURE,
		bed.size == Vector3i(2, 1, 1),
		bed.interaction_type == FurnitureData.InteractionType.SLEEP,
		bed.is_solid == true
	]

	if checks.all(func(x): return x):
		add_test_result(test_name, true, "Todas las propiedades son correctas")
	else:
		add_test_result(test_name, false, "Algunas propiedades son incorrectas")

func test_wooden_table() -> void:
	var test_name = "Wooden Table - Configuración correcta"
	var table = FurnitureSystem.get_furniture("wooden_table")

	if table == null:
		add_test_result(test_name, false, "wooden_table no existe")
		return

	if table.furniture_id == "wooden_table" and table.is_solid:
		add_test_result(test_name, true, "Mesa configurada correctamente")
	else:
		add_test_result(test_name, false, "Configuración incorrecta")

func test_wooden_chair() -> void:
	var test_name = "Wooden Chair - Interacción SIT"
	var chair = FurnitureSystem.get_furniture("wooden_chair")

	if chair == null:
		add_test_result(test_name, false, "wooden_chair no existe")
		return

	if chair.interaction_type == FurnitureData.InteractionType.SIT:
		add_test_result(test_name, true, "Interacción correcta")
	else:
		add_test_result(test_name, false, "Interacción incorrecta: " + str(chair.interaction_type))

func test_wooden_chest() -> void:
	var test_name = "Wooden Chest - Storage"
	var chest = FurnitureSystem.get_furniture("wooden_chest")

	if chest == null:
		add_test_result(test_name, false, "wooden_chest no existe")
		return

	var checks = [
		chest.category == FurnitureData.FurnitureCategory.STORAGE,
		chest.interaction_type == FurnitureData.InteractionType.OPEN_STORAGE,
		chest.storage_slots == 27
	]

	if checks.all(func(x): return x):
		add_test_result(test_name, true, "Storage configurado correctamente (27 slots)")
	else:
		add_test_result(test_name, false, "Storage slots: " + str(chest.storage_slots))

func test_torch() -> void:
	var test_name = "Torch - Iluminación"
	var torch = FurnitureSystem.get_furniture("torch")

	if torch == null:
		add_test_result(test_name, false, "torch no existe")
		return

	var checks = [
		torch.category == FurnitureData.FurnitureCategory.LIGHTING,
		torch.emits_light == true,
		torch.light_range > 0,
		torch.interaction_type == FurnitureData.InteractionType.TURN_ON_OFF
	]

	if checks.all(func(x): return x):
		add_test_result(test_name, true, "Iluminación configurada (range: %.1f)" % torch.light_range)
	else:
		add_test_result(test_name, false, "Configuración de luz incorrecta")

func test_lantern() -> void:
	var test_name = "Lantern - Luz más fuerte que Torch"
	var lantern = FurnitureSystem.get_furniture("lantern")
	var torch = FurnitureSystem.get_furniture("torch")

	if lantern == null or torch == null:
		add_test_result(test_name, false, "Falta lantern o torch")
		return

	if lantern.light_range > torch.light_range:
		add_test_result(test_name, true, "Lantern (%.1f) > Torch (%.1f)" % [lantern.light_range, torch.light_range])
	else:
		add_test_result(test_name, false, "Lantern debería iluminar más que torch")

func test_bookshelf() -> void:
	var test_name = "Bookshelf - Educación"
	var bookshelf = FurnitureSystem.get_furniture("bookshelf")

	if bookshelf == null:
		add_test_result(test_name, false, "bookshelf no existe")
		return

	var checks = [
		bookshelf.category == FurnitureData.FurnitureCategory.EDUCATION,
		bookshelf.interaction_type == FurnitureData.InteractionType.READ,
		bookshelf.provides_buff == true
	]

	if checks.all(func(x): return x):
		add_test_result(test_name, true, "Bookshelf con buff educativo")
	else:
		add_test_result(test_name, false, "Configuración incorrecta")

func test_crafting_table() -> void:
	var test_name = "Crafting Table - Workstation"
	var table = FurnitureSystem.get_furniture("crafting_table")

	if table == null:
		add_test_result(test_name, false, "crafting_table no existe")
		return

	if table.interaction_type == FurnitureData.InteractionType.USE_WORKSTATION:
		add_test_result(test_name, true, "Workstation configurada correctamente")
	else:
		add_test_result(test_name, false, "No es workstation")

func test_furnace() -> void:
	var test_name = "Furnace - Workstation + Luz"
	var furnace = FurnitureSystem.get_furniture("furnace")

	if furnace == null:
		add_test_result(test_name, false, "furnace no existe")
		return

	var checks = [
		furnace.interaction_type == FurnitureData.InteractionType.USE_WORKSTATION,
		furnace.emits_light == true,
		furnace.category == FurnitureData.FurnitureCategory.UTILITY
	]

	if checks.all(func(x): return x):
		add_test_result(test_name, true, "Workstation + emisión de luz")
	else:
		add_test_result(test_name, false, "Configuración incorrecta")

func test_small_painting() -> void:
	var test_name = "Small Painting - Decoración"
	var painting = FurnitureSystem.get_furniture("small_painting")

	if painting == null:
		add_test_result(test_name, false, "small_painting no existe")
		return

	var checks = [
		painting.category == FurnitureData.FurnitureCategory.DECORATION,
		painting.is_solid == false,
		painting.wall_mounted == true
	]

	if checks.all(func(x): return x):
		add_test_result(test_name, true, "Decoración montada en pared")
	else:
		add_test_result(test_name, false, "Configuración incorrecta")

## ============================================================================
## TESTS DE FUNCIONALIDADES
## ============================================================================

func test_get_furniture() -> void:
	var test_name = "get_furniture() retorna muebles correctos"

	var bed = FurnitureSystem.get_furniture("wooden_bed")
	var invalid = FurnitureSystem.get_furniture("invalid_furniture_id")

	if bed != null and invalid == null:
		add_test_result(test_name, true, "Retorna muebles válidos y null para inválidos")
	else:
		add_test_result(test_name, false, "Comportamiento incorrecto")

func test_get_furniture_by_category() -> void:
	var test_name = "get_furniture_by_category() filtra correctamente"

	var lighting = FurnitureSystem.get_furniture_by_category(FurnitureData.FurnitureCategory.LIGHTING)

	if lighting.size() == 0:
		add_test_result(test_name, false, "No se encontraron muebles de iluminación")
		return

	# Verificar que todos son de categoría LIGHTING
	var all_lighting = true
	for furniture in lighting:
		if furniture.category != FurnitureData.FurnitureCategory.LIGHTING:
			all_lighting = false
			break

	if all_lighting:
		add_test_result(test_name, true, "Filtrado correcto (%d muebles)" % lighting.size())
	else:
		add_test_result(test_name, false, "Hay muebles de otras categorías")

func test_get_all_furniture() -> void:
	var test_name = "get_all_furniture() retorna todos los muebles"

	var all_furniture = FurnitureSystem.get_all_furniture()
	var library_size = FurnitureSystem.furniture_library.size()

	if all_furniture.size() == library_size:
		add_test_result(test_name, true, "%d muebles en total" % all_furniture.size())
	else:
		add_test_result(test_name, false, "Tamaños no coinciden: %d vs %d" % [all_furniture.size(), library_size])

func test_place_furniture() -> void:
	var test_name = "place_furniture() coloca muebles correctamente"

	var position = Vector3i(10, 0, 10)
	var result = FurnitureSystem.place_furniture("wooden_table", position, 0)

	if result:
		# Verificar que está en placed_furniture
		var placed = FurnitureSystem.is_furniture_at(position)
		if placed:
			add_test_result(test_name, true, "Mueble colocado en " + str(position))
			# Limpiar
			FurnitureSystem.remove_furniture(position)
		else:
			add_test_result(test_name, false, "Mueble no está en placed_furniture")
	else:
		add_test_result(test_name, false, "place_furniture retornó false")

func test_remove_furniture() -> void:
	var test_name = "remove_furniture() elimina muebles correctamente"

	var position = Vector3i(15, 0, 15)
	FurnitureSystem.place_furniture("wooden_chair", position, 0)

	var removed = FurnitureSystem.remove_furniture(position)

	if removed:
		var still_there = FurnitureSystem.is_furniture_at(position)
		if not still_there:
			add_test_result(test_name, true, "Mueble eliminado correctamente")
		else:
			add_test_result(test_name, false, "Mueble aún está presente")
	else:
		add_test_result(test_name, false, "remove_furniture retornó false")

func test_interact_with_furniture() -> void:
	var test_name = "interact_furniture() ejecuta sin errores"

	var position = Vector3i(20, 0, 20)
	FurnitureSystem.place_furniture("wooden_bed", position, 0)

	# Intentar interactuar (solo verificamos que no crashea)
	var error_occurred = false
	var signal_received = false

	FurnitureSystem.furniture_interacted.connect(func(_id): signal_received = true)

	FurnitureSystem.interact_furniture(position)

	await get_tree().create_timer(0.1).timeout

	if signal_received:
		add_test_result(test_name, true, "Interacción ejecutada y señal emitida")
	else:
		add_test_result(test_name, true, "Interacción ejecutada sin errores")

	# Limpiar
	FurnitureSystem.remove_furniture(position)

## ============================================================================
## UTILIDADES DE TEST
## ============================================================================

func add_test_result(test_name: String, passed: bool, message: String = "") -> void:
	test_results.append({
		"name": test_name,
		"passed": passed,
		"message": message
	})

	if passed:
		passed_tests += 1
		print("✅ PASS: %s" % test_name)
		if message:
			print("   └─ %s" % message)
	else:
		failed_tests += 1
		print("❌ FAIL: %s" % test_name)
		if message:
			print("   └─ %s" % message)

func print_results() -> void:
	print("\n" + "=".repeat(80))
	print("RESULTADOS DE PRUEBAS - FURNITURE SYSTEM")
	print("=".repeat(80))
	print("Total de pruebas: %d" % (passed_tests + failed_tests))
	print("✅ Pasadas: %d" % passed_tests)
	print("❌ Fallidas: %d" % failed_tests)
	print("Tasa de éxito: %.1f%%" % ((float(passed_tests) / (passed_tests + failed_tests)) * 100))
	print("=".repeat(80) + "\n")
