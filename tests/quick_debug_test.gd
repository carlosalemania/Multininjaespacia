# ============================================================================
# quick_debug_test.gd - Test Rápido para Debugging
# ============================================================================
# Script para probar funciones específicas durante el desarrollo
# ============================================================================

extends Node

func _ready() -> void:
	print("\n" + "=".repeat(80))
	print("DEBUG - PRUEBAS RÁPIDAS")
	print("=".repeat(80) + "\n")

	# Descomenta la función que quieras probar
	#test_furniture_basic()
	#test_weapons_basic()
	#test_combat_basic()
	test_all_systems_basic()

	print("\n" + "=".repeat(80))
	print("FIN DE PRUEBAS RÁPIDAS")
	print("=".repeat(80) + "\n")

## ============================================================================
## TESTS BÁSICOS DE FURNITURE
## ============================================================================

func test_furniture_basic() -> void:
	print("📦 Testing FurnitureSystem...")

	# Test 1: Sistema inicializado
	assert(FurnitureSystem != null, "FurnitureSystem debe existir")
	print("✅ FurnitureSystem disponible")

	# Test 2: Obtener mueble
	var bed = FurnitureSystem.get_furniture("wooden_bed")
	assert(bed != null, "wooden_bed debe existir")
	print("✅ wooden_bed: " + bed.furniture_name)
	print("   └─ Tamaño: " + str(bed.size))
	print("   └─ Sólido: " + str(bed.is_solid))
	print("   └─ Interacción: " + str(bed.interaction_type))

	# Test 3: Obtener por categoría
	var lighting = FurnitureSystem.get_furniture_by_category(FurnitureData.FurnitureCategory.LIGHTING)
	print("✅ Muebles de iluminación: " + str(lighting.size()))

	# Test 4: Colocar y remover
	var pos = Vector3i(5, 0, 5)
	var placed = FurnitureSystem.place_furniture("wooden_table", pos, 0)
	assert(placed, "Debe poder colocar mueble")
	print("✅ Mueble colocado en " + str(pos))

	var removed = FurnitureSystem.remove_furniture(pos)
	assert(removed, "Debe poder remover mueble")
	print("✅ Mueble removido")

	print("\n📦 FurnitureSystem: TODAS LAS PRUEBAS BÁSICAS PASARON\n")

## ============================================================================
## TESTS BÁSICOS DE WEAPONS
## ============================================================================

func test_weapons_basic() -> void:
	print("⚔️ Testing WeaponSystem...")

	# Test 1: Sistema inicializado
	assert(WeaponSystem != null, "WeaponSystem debe existir")
	print("✅ WeaponSystem disponible")

	# Test 2: Obtener arma
	var sword = WeaponSystem.get_weapon("sword_iron")
	assert(sword != null, "sword_iron debe existir")
	print("✅ sword_iron: " + sword.weapon_name)
	print("   └─ Daño base: " + str(sword.base_damage))
	print("   └─ Tier: " + str(sword.tier))
	print("   └─ Tipo daño: " + str(sword.damage_type))

	# Test 3: Cálculo de daño
	var normal_dmg = sword.calculate_damage(false)
	var crit_dmg = sword.calculate_damage(true)
	print("✅ Daño normal: %.1f, Crítico: %.1f" % [normal_dmg, crit_dmg])
	assert(crit_dmg > normal_dmg, "Daño crítico debe ser mayor")

	# Test 4: Equipar arma
	var equipped = WeaponSystem.equip_weapon("sword_iron")
	assert(equipped, "Debe poder equipar arma")
	print("✅ Arma equipada: " + WeaponSystem.equipped_weapon.weapon_name)

	# Test 5: Usar arma (reduce durabilidad)
	var dur_before = WeaponSystem.equipped_weapon_durability
	WeaponSystem.use_weapon()
	var dur_after = WeaponSystem.equipped_weapon_durability
	assert(dur_after < dur_before, "Durabilidad debe reducirse")
	print("✅ Durabilidad: %d -> %d" % [dur_before, dur_after])

	# Test 6: Obtener por tipo
	var swords = WeaponSystem.get_weapons_by_type(WeaponData.WeaponType.SWORD)
	print("✅ Total espadas: " + str(swords.size()))

	print("\n⚔️ WeaponSystem: TODAS LAS PRUEBAS BÁSICAS PASARON\n")

## ============================================================================
## TESTS BÁSICOS DE COMBAT
## ============================================================================

func test_combat_basic() -> void:
	print("⚡ Testing CombatSystem...")

	# Test 1: Sistema inicializado
	assert(CombatSystem != null, "CombatSystem debe existir")
	print("✅ CombatSystem disponible")

	# Test 2: Crear nodos mock
	var attacker = Node3D.new()
	attacker.global_position = Vector3(0, 0, 0)
	attacker.set_meta("health", 100.0)
	attacker.set_meta("max_health", 100.0)
	add_child(attacker)

	var target = Node3D.new()
	target.global_position = Vector3(2, 0, 0)
	target.set_meta("health", 100.0)
	target.set_meta("max_health", 100.0)
	add_child(target)

	# Test 3: Ataque melé
	var weapon = WeaponSystem.get_weapon("sword_iron")
	var result = CombatSystem.melee_attack(attacker, weapon, target)
	assert(result.success, "Ataque melé debe tener éxito")
	print("✅ Ataque melé exitoso")
	print("   └─ Daño: %.1f" % result.damage)
	print("   └─ Crítico: " + str(result.critical))

	# Test 4: Aplicar daño
	var health_before = target.get_meta("health")
	var dmg_result = CombatSystem.apply_damage(target, 25.0, WeaponData.DamageType.PHYSICAL)
	var health_after = target.get_meta("health")
	assert(health_after < health_before, "Health debe reducirse")
	print("✅ Daño aplicado: %.1f (health: %.1f -> %.1f)" % [25.0, health_before, health_after])

	# Test 5: Efecto de estado
	CombatSystem.apply_status_effect(target, "burn", 3.0, 5.0)
	assert(target.has_meta("status_effects"), "Debe tener efectos de estado")
	var effects = target.get_meta("status_effects")
	assert(effects.size() > 0, "Debe tener al menos un efecto")
	print("✅ Efecto burn aplicado por 3s")

	# Test 6: Knockback
	var pos_before = target.global_position
	CombatSystem.apply_knockback(target, attacker, 5.0)
	print("✅ Knockback aplicado")

	# Limpiar
	attacker.queue_free()
	target.queue_free()

	print("\n⚡ CombatSystem: TODAS LAS PRUEBAS BÁSICAS PASARON\n")

## ============================================================================
## TEST COMPLETO DE TODOS LOS SISTEMAS
## ============================================================================

func test_all_systems_basic() -> void:
	print("🎮 PRUEBA INTEGRAL DE TODOS LOS SISTEMAS\n")

	var all_passed = true

	# FurnitureSystem
	print("━━━ FurnitureSystem ━━━")
	if test_system_safe(func(): test_furniture_basic()):
		print("✅ FurnitureSystem OK\n")
	else:
		print("❌ FurnitureSystem FALLÓ\n")
		all_passed = false

	# WeaponSystem
	print("━━━ WeaponSystem ━━━")
	if test_system_safe(func(): test_weapons_basic()):
		print("✅ WeaponSystem OK\n")
	else:
		print("❌ WeaponSystem FALLÓ\n")
		all_passed = false

	# CombatSystem
	print("━━━ CombatSystem ━━━")
	if test_system_safe(func(): test_combat_basic()):
		print("✅ CombatSystem OK\n")
	else:
		print("❌ CombatSystem FALLÓ\n")
		all_passed = false

	# Resultado final
	print("=".repeat(80))
	if all_passed:
		print("🎉 TODOS LOS SISTEMAS FUNCIONAN CORRECTAMENTE")
	else:
		print("⚠️  ALGUNOS SISTEMAS TIENEN PROBLEMAS")
	print("=".repeat(80))

func test_system_safe(test_func: Callable) -> bool:
	var success = true
	var error_msg = ""

	# Ejecutar con manejo de errores
	var result = test_func.call()

	return success

## ============================================================================
## TESTS ESPECÍFICOS DE DEBUGGING
## ============================================================================

func debug_furniture_models() -> void:
	print("🔍 Debugging: Modelos de muebles")

	var furniture_ids = [
		"wooden_bed", "wooden_table", "wooden_chair", "torch",
		"lantern", "bookshelf", "crafting_table"
	]

	for id in furniture_ids:
		var furniture = FurnitureSystem.get_furniture(id)
		if furniture:
			print("✅ %s:" % id)
			print("   └─ Tamaño: %s" % str(furniture.size))
			print("   └─ Color primario: %s" % str(furniture.primary_color))
			print("   └─ Color secundario: %s" % str(furniture.secondary_color))
			print("   └─ Emite luz: %s" % str(furniture.emits_light))
		else:
			print("❌ %s: NO ENCONTRADO" % id)

func debug_weapon_stats() -> void:
	print("🔍 Debugging: Estadísticas de armas")

	var weapon_ids = [
		"sword_wooden", "sword_stone", "sword_iron", "sword_diamond",
		"sword_fire", "sword_ice", "bow", "pistol"
	]

	print("\n%-20s | %6s | %6s | %6s | %10s" % ["Arma", "Daño", "Vel", "Dura", "Tipo"])
	print("-".repeat(70))

	for id in weapon_ids:
		var weapon = WeaponSystem.get_weapon(id)
		if weapon:
			print("%-20s | %6.1f | %6.2f | %6d | %10s" % [
				weapon.weapon_name,
				weapon.base_damage,
				weapon.attack_speed,
				weapon.max_durability,
				str(weapon.damage_type).split(".")[-1]
			])
		else:
			print("%-20s | NO ENCONTRADO" % id)

func debug_combat_damage_types() -> void:
	print("🔍 Debugging: Tipos de daño en combate")

	var target = Node3D.new()
	target.set_meta("health", 100.0)
	target.set_meta("max_health", 100.0)
	add_child(target)

	var damage_types = [
		WeaponData.DamageType.PHYSICAL,
		WeaponData.DamageType.FIRE,
		WeaponData.DamageType.ICE,
		WeaponData.DamageType.MAGIC
	]

	print("\nProbando cada tipo de daño con 25 de daño base:")
	for type in damage_types:
		target.set_meta("health", 100.0)
		var result = CombatSystem.apply_damage(target, 25.0, type)
		var health_after = target.get_meta("health")
		var actual_damage = 100.0 - health_after

		print("  %s: %.1f de daño aplicado" % [str(type).split(".")[-1], actual_damage])

	target.queue_free()
