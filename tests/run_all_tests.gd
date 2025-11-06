# ============================================================================
# run_all_tests.gd - Test Runner Principal
# ============================================================================
# Ejecuta todas las suites de pruebas y genera un reporte completo
# ============================================================================

extends Node

var all_results = {}
var start_time = 0
var end_time = 0

func _ready() -> void:
	print("\n" + "=".repeat(80))
	print("  MULTI NINJA ESPACIAL - SUITE COMPLETA DE PRUEBAS UNITARIAS")
	print("=".repeat(80) + "\n")

	start_time = Time.get_ticks_msec()

	await run_all_test_suites()

	end_time = Time.get_ticks_msec()

	generate_final_report()

	# Salir después de completar
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()

func run_all_test_suites() -> void:
	print("🚀 Iniciando ejecución de tests...\n")

	# Test Furniture System
	print("📦 Ejecutando: FurnitureSystem Tests...")
	var furniture_test = load("res://tests/test_furniture_system.gd").new()
	add_child(furniture_test)
	await get_tree().create_timer(0.5).timeout
	all_results["FurnitureSystem"] = {
		"passed": furniture_test.passed_tests,
		"failed": furniture_test.failed_tests,
		"total": furniture_test.passed_tests + furniture_test.failed_tests
	}
	furniture_test.queue_free()

	print("\n")

	# Test Weapon System
	print("⚔️ Ejecutando: WeaponSystem Tests...")
	var weapon_test = load("res://tests/test_weapon_system.gd").new()
	add_child(weapon_test)
	await get_tree().create_timer(0.5).timeout
	all_results["WeaponSystem"] = {
		"passed": weapon_test.passed_tests,
		"failed": weapon_test.failed_tests,
		"total": weapon_test.passed_tests + weapon_test.failed_tests
	}
	weapon_test.queue_free()

	print("\n")

	# Test Combat System
	print("⚡ Ejecutando: CombatSystem Tests...")
	var combat_test = load("res://tests/test_combat_system.gd").new()
	add_child(combat_test)
	await get_tree().create_timer(0.5).timeout
	all_results["CombatSystem"] = {
		"passed": combat_test.passed_tests,
		"failed": combat_test.failed_tests,
		"total": combat_test.passed_tests + combat_test.failed_tests
	}
	combat_test.queue_free()

func generate_final_report() -> void:
	var total_passed = 0
	var total_failed = 0
	var total_tests = 0

	print("\n\n")
	print("=".repeat(80))
	print("  REPORTE FINAL DE PRUEBAS")
	print("=".repeat(80))
	print("")

	# Calcular totales
	for system_name in all_results:
		var results = all_results[system_name]
		total_passed += results.passed
		total_failed += results.failed
		total_tests += results.total

	# Resultados por sistema
	print("SISTEMA                      | TOTAL  | PASADAS | FALLIDAS | TASA")
	print("-".repeat(75))

	for system_name in all_results:
		var results = all_results[system_name]
		var rate = 0.0 if results.total == 0 else (float(results.passed) / results.total) * 100
		var status_icon = "✅" if results.failed == 0 else "⚠️"

		print("%s %-24s | %6d | %7d | %8d | %4.1f%%" % [
			status_icon,
			system_name,
			results.total,
			results.passed,
			results.failed,
			rate
		])

	print("-".repeat(75))

	# Totales
	var total_rate = 0.0 if total_tests == 0 else (float(total_passed) / total_tests) * 100

	print("📊 TOTALES                   | %6d | %7d | %8d | %4.1f%%" % [
		total_tests,
		total_passed,
		total_failed,
		total_rate
	])

	print("")

	# Estadísticas adicionales
	var elapsed_time = (end_time - start_time) / 1000.0
	print("⏱️  Tiempo de ejecución: %.2f segundos" % elapsed_time)
	print("📈 Cobertura: %d sistemas probados" % all_results.size())
	print("")

	# Estado final
	print("=".repeat(80))
	if total_failed == 0:
		print("🎉 ¡TODOS LOS TESTS PASARON EXITOSAMENTE! 🎉")
		print("✅ Sistema listo para producción")
	elif total_rate >= 90:
		print("👍 La mayoría de tests pasaron (%.1f%%)" % total_rate)
		print("⚠️  Revisar %d fallas pendientes" % total_failed)
	elif total_rate >= 70:
		print("⚠️  Hay problemas que requieren atención (%.1f%%)" % total_rate)
		print("🔧 Corregir %d fallas antes de continuar" % total_failed)
	else:
		print("❌ SISTEMA CON PROBLEMAS CRÍTICOS (%.1f%%)" % total_rate)
		print("🚨 Requiere correcciones inmediatas: %d fallas" % total_failed)
	print("=".repeat(80))

	print("")

	# Guardar reporte en archivo
	save_report_to_file(total_tests, total_passed, total_failed, total_rate, elapsed_time)

func save_report_to_file(total: int, passed: int, failed: int, rate: float, time: float) -> void:
	var timestamp = Time.get_datetime_string_from_system()
	var file_path = "res://tests/REPORTE_TESTS_%s.txt" % timestamp.replace(":", "-")

	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_line("=".repeat(80))
		file.store_line("MULTI NINJA ESPACIAL - REPORTE DE PRUEBAS UNITARIAS")
		file.store_line("=".repeat(80))
		file.store_line("Fecha: " + timestamp)
		file.store_line("Tiempo de ejecución: %.2f segundos" % time)
		file.store_line("")

		file.store_line("RESULTADOS POR SISTEMA:")
		file.store_line("-".repeat(80))

		for system_name in all_results:
			var results = all_results[system_name]
			var sys_rate = 0.0 if results.total == 0 else (float(results.passed) / results.total) * 100
			file.store_line("%s: %d/%d tests (%.1f%%)" % [
				system_name,
				results.passed,
				results.total,
				sys_rate
			])

		file.store_line("")
		file.store_line("RESUMEN GENERAL:")
		file.store_line("-".repeat(80))
		file.store_line("Total de pruebas: %d" % total)
		file.store_line("Pruebas exitosas: %d" % passed)
		file.store_line("Pruebas fallidas: %d" % failed)
		file.store_line("Tasa de éxito: %.1f%%" % rate)

		file.store_line("")
		file.store_line("ESTADO: %s" % ("APROBADO" if failed == 0 else "REQUIERE ATENCIÓN"))
		file.store_line("=".repeat(80))

		file.close()
		print("💾 Reporte guardado en: %s\n" % file_path)
	else:
		print("⚠️  No se pudo guardar el reporte en archivo\n")
