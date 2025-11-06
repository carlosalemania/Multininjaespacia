# ============================================================================
# test_weapon_system.gd - Pruebas Unitarias para WeaponSystem
# ============================================================================

extends Node

var test_results = []
var passed_tests = 0
var failed_tests = 0

func _ready() -> void:
	print("\n" + "=".repeat(80))
	print("INICIANDO PRUEBAS UNITARIAS - WEAPON SYSTEM")
	print("=".repeat(80) + "\n")

	run_all_tests()
	print_results()

func run_all_tests() -> void:
	# Tests de inicialización
	test_weapon_system_initialization()
	test_weapon_data_structure()

	# Tests de armas específicas
	test_wooden_sword()
	test_diamond_sword()
	test_fire_sword()
	test_ice_sword()
	test_bow()
	test_pistol()
	test_magic_staff()

	# Tests de mecánicas
	test_weapon_damage_calculation()
	test_weapon_critical_chance()
	test_weapon_durability()
	test_weapon_tiers()
	test_damage_types()
	test_special_effects()

	# Tests de funcionalidades
	test_equip_weapon()
	test_use_weapon()
	test_get_weapon_by_type()

## ============================================================================
## TESTS DE INICIALIZACIÓN
## ============================================================================

func test_weapon_system_initialization() -> void:
	var test_name = "WeaponSystem se inicializa correctamente"

	if WeaponSystem == null:
		add_test_result(test_name, false, "WeaponSystem no está disponible")
		return

	if WeaponSystem.weapon_library.size() == 0:
		add_test_result(test_name, false, "weapon_library está vacía")
		return

	add_test_result(test_name, true, "Sistema inicializado con %d armas" % WeaponSystem.weapon_library.size())

func test_weapon_data_structure() -> void:
	var test_name = "WeaponData tiene la estructura correcta"

	var sword = WeaponSystem.get_weapon("sword_wooden")
	if sword == null:
		add_test_result(test_name, false, "No se pudo obtener sword_wooden")
		return

	var required_properties = [
		"weapon_id", "weapon_name", "weapon_type", "tier", "damage_type",
		"base_damage", "attack_speed", "attack_range", "critical_chance",
		"max_durability"
	]

	for prop in required_properties:
		if not (prop in sword):
			add_test_result(test_name, false, "Falta propiedad: " + prop)
			return

	add_test_result(test_name, true, "Todas las propiedades requeridas presentes")

## ============================================================================
## TESTS DE ARMAS ESPECÍFICAS
## ============================================================================

func test_wooden_sword() -> void:
	var test_name = "Wooden Sword - Tier BASIC"
	var sword = WeaponSystem.get_weapon("sword_wooden")

	if sword == null:
		add_test_result(test_name, false, "sword_wooden no existe")
		return

	var checks = [
		sword.weapon_type == WeaponData.WeaponType.SWORD,
		sword.tier == WeaponData.WeaponTier.BASIC,
		sword.base_damage > 0,
		sword.max_durability > 0
	]

	if checks.all(func(x): return x):
		add_test_result(test_name, true, "Daño: %.1f, Durabilidad: %d" % [sword.base_damage, sword.max_durability])
	else:
		add_test_result(test_name, false, "Configuración incorrecta")

func test_diamond_sword() -> void:
	var test_name = "Diamond Sword - Tier EPIC, más fuerte que madera"
	var diamond = WeaponSystem.get_weapon("sword_diamond")
	var wooden = WeaponSystem.get_weapon("sword_wooden")

	if diamond == null or wooden == null:
		add_test_result(test_name, false, "Falta alguna espada")
		return

	var checks = [
		diamond.tier == WeaponData.WeaponTier.EPIC,
		diamond.base_damage > wooden.base_damage,
		diamond.max_durability > wooden.max_durability
	]

	if checks.all(func(x): return x):
		add_test_result(test_name, true, "Diamante (%.1f) > Madera (%.1f)" % [diamond.base_damage, wooden.base_damage])
	else:
		add_test_result(test_name, false, "Estadísticas incorrectas")

func test_fire_sword() -> void:
	var test_name = "Fire Sword - Daño FIRE + Burn"
	var fire_sword = WeaponSystem.get_weapon("sword_fire")

	if fire_sword == null:
		add_test_result(test_name, false, "sword_fire no existe")
		return

	var checks = [
		fire_sword.damage_type == WeaponData.DamageType.FIRE,
		fire_sword.apply_burn == true,
		fire_sword.tier >= WeaponData.WeaponTier.RARE
	]

	if checks.all(func(x): return x):
		add_test_result(test_name, true, "Espada de fuego con efecto quemadura")
	else:
		add_test_result(test_name, false, "Efectos de fuego incorrectos")

func test_ice_sword() -> void:
	var test_name = "Ice Sword - Daño ICE + Freeze"
	var ice_sword = WeaponSystem.get_weapon("sword_ice")

	if ice_sword == null:
		add_test_result(test_name, false, "sword_ice no existe")
		return

	var checks = [
		ice_sword.damage_type == WeaponData.DamageType.ICE,
		ice_sword.apply_freeze == true,
		ice_sword.tier >= WeaponData.WeaponTier.RARE
	]

	if checks.all(func(x): return x):
		add_test_result(test_name, true, "Espada de hielo con efecto congelar")
	else:
		add_test_result(test_name, false, "Efectos de hielo incorrectos")

func test_bow() -> void:
	var test_name = "Bow - Arma a distancia"
	var bow = WeaponSystem.get_weapon("bow")

	if bow == null:
		add_test_result(test_name, false, "bow no existe")
		return

	var checks = [
		bow.weapon_type == WeaponData.WeaponType.BOW,
		bow.is_ranged == true,
		bow.attack_range > 10.0,
		bow.projectile_speed > 0
	]

	if checks.all(func(x): return x):
		add_test_result(test_name, true, "Arco con rango %.1f" % bow.attack_range)
	else:
		add_test_result(test_name, false, "Configuración de arco incorrecta")

func test_pistol() -> void:
	var test_name = "Pistol - Arma de fuego"
	var pistol = WeaponSystem.get_weapon("pistol")

	if pistol == null:
		add_test_result(test_name, false, "pistol no existe")
		return

	var checks = [
		pistol.weapon_type == WeaponData.WeaponType.GUN,
		pistol.is_ranged == true,
		pistol.requires_ammo == true,
		pistol.attack_speed > 0
	]

	if checks.all(func(x): return x):
		add_test_result(test_name, true, "Pistola requiere munición, velocidad: %.1f" % pistol.attack_speed)
	else:
		add_test_result(test_name, false, "Configuración incorrecta")

func test_magic_staff() -> void:
	var test_name = "Magic Staff - Daño MAGIC + Maná"
	var staff = WeaponSystem.get_weapon("magic_staff")

	if staff == null:
		add_test_result(test_name, false, "magic_staff no existe")
		return

	var checks = [
		staff.weapon_type == WeaponData.WeaponType.MAGIC_STAFF,
		staff.damage_type == WeaponData.DamageType.MAGIC,
		staff.requires_mana == true,
		staff.is_ranged == true
	]

	if checks.all(func(x): return x):
		add_test_result(test_name, true, "Bastón mágico requiere maná")
	else:
		add_test_result(test_name, false, "Configuración de magia incorrecta")

## ============================================================================
## TESTS DE MECÁNICAS
## ============================================================================

func test_weapon_damage_calculation() -> void:
	var test_name = "calculate_damage() retorna valores correctos"

	var sword = WeaponSystem.get_weapon("sword_iron")
	if sword == null:
		add_test_result(test_name, false, "sword_iron no existe")
		return

	var normal_damage = sword.calculate_damage(false)
	var critical_damage = sword.calculate_damage(true)

	if critical_damage > normal_damage and normal_damage == sword.base_damage:
		add_test_result(test_name, true, "Normal: %.1f, Crítico: %.1f" % [normal_damage, critical_damage])
	else:
		add_test_result(test_name, false, "Cálculo incorrecto")

func test_weapon_critical_chance() -> void:
	var test_name = "roll_critical() funciona con probabilidad"

	var sword = WeaponSystem.get_weapon("sword_wooden")
	if sword == null:
		add_test_result(test_name, false, "sword_wooden no existe")
		return

	# Probar 1000 veces y verificar que hay críticos
	var criticals = 0
	for i in range(1000):
		if sword.roll_critical():
			criticals += 1

	if criticals > 0 and criticals < 1000:
		var rate = (float(criticals) / 1000.0) * 100.0
		add_test_result(test_name, true, "Críticos: %d/1000 (%.1f%%)" % [criticals, rate])
	else:
		add_test_result(test_name, false, "Probabilidad anormal: %d críticos" % criticals)

func test_weapon_durability() -> void:
	var test_name = "Durabilidad se reduce con uso"

	var sword = WeaponSystem.get_weapon("sword_wooden")
	if sword == null:
		add_test_result(test_name, false, "sword_wooden no existe")
		return

	# Equipar arma
	WeaponSystem.equip_weapon("sword_wooden")
	var initial_durability = WeaponSystem.equipped_weapon_durability

	# Usar arma
	WeaponSystem.use_weapon()
	var after_use = WeaponSystem.equipped_weapon_durability

	if after_use < initial_durability:
		add_test_result(test_name, true, "Durabilidad: %d -> %d" % [initial_durability, after_use])
	else:
		add_test_result(test_name, false, "Durabilidad no se redujo")

func test_weapon_tiers() -> void:
	var test_name = "Tiers más altos tienen mejor daño"

	var basic = WeaponSystem.get_weapon("sword_wooden")  # BASIC
	var common = WeaponSystem.get_weapon("sword_stone")  # COMMON
	var epic = WeaponSystem.get_weapon("sword_diamond")  # EPIC

	if basic == null or common == null or epic == null:
		add_test_result(test_name, false, "Faltan armas para comparar")
		return

	if epic.base_damage > common.base_damage and common.base_damage > basic.base_damage:
		add_test_result(test_name, true, "Epic > Common > Basic")
	else:
		add_test_result(test_name, false, "Orden de daño incorrecto")

func test_damage_types() -> void:
	var test_name = "Diferentes tipos de daño existen"

	var physical = WeaponSystem.get_weapon("sword_wooden")
	var fire = WeaponSystem.get_weapon("sword_fire")
	var ice = WeaponSystem.get_weapon("sword_ice")
	var magic = WeaponSystem.get_weapon("magic_staff")

	if physical == null or fire == null or ice == null or magic == null:
		add_test_result(test_name, false, "Faltan armas")
		return

	var types = [
		physical.damage_type == WeaponData.DamageType.PHYSICAL,
		fire.damage_type == WeaponData.DamageType.FIRE,
		ice.damage_type == WeaponData.DamageType.ICE,
		magic.damage_type == WeaponData.DamageType.MAGIC
	]

	if types.all(func(x): return x):
		add_test_result(test_name, true, "4 tipos de daño diferentes verificados")
	else:
		add_test_result(test_name, false, "Tipos de daño incorrectos")

func test_special_effects() -> void:
	var test_name = "roll_special_effect() funciona"

	var sword = WeaponSystem.get_weapon("sword_crystal")
	if sword == null:
		add_test_result(test_name, false, "sword_crystal no existe")
		return

	# Probar 100 veces
	var specials = 0
	for i in range(100):
		if sword.roll_special_effect():
			specials += 1

	# Si tiene chance, debería activarse algunas veces
	if sword.special_effect_chance > 0:
		if specials > 0:
			add_test_result(test_name, true, "Efectos especiales: %d/100" % specials)
		else:
			add_test_result(test_name, false, "No se activó ningún efecto especial")
	else:
		add_test_result(test_name, true, "Arma sin efectos especiales")

## ============================================================================
## TESTS DE FUNCIONALIDADES
## ============================================================================

func test_equip_weapon() -> void:
	var test_name = "equip_weapon() equipa armas correctamente"

	var success = WeaponSystem.equip_weapon("sword_iron")

	if success and WeaponSystem.equipped_weapon != null:
		if WeaponSystem.equipped_weapon.weapon_id == "sword_iron":
			add_test_result(test_name, true, "Espada de hierro equipada")
		else:
			add_test_result(test_name, false, "Arma equipada incorrecta")
	else:
		add_test_result(test_name, false, "No se pudo equipar el arma")

func test_use_weapon() -> void:
	var test_name = "use_weapon() sin errores"

	WeaponSystem.equip_weapon("sword_wooden")
	var initial_dur = WeaponSystem.equipped_weapon_durability

	WeaponSystem.use_weapon()

	if WeaponSystem.equipped_weapon_durability < initial_dur:
		add_test_result(test_name, true, "Arma usada, durabilidad reducida")
	else:
		add_test_result(test_name, false, "Durabilidad no cambió")

func test_get_weapon_by_type() -> void:
	var test_name = "get_weapons_by_type() filtra correctamente"

	var swords = WeaponSystem.get_weapons_by_type(WeaponData.WeaponType.SWORD)

	if swords.size() == 0:
		add_test_result(test_name, false, "No se encontraron espadas")
		return

	# Verificar que todas son espadas
	var all_swords = true
	for weapon in swords:
		if weapon.weapon_type != WeaponData.WeaponType.SWORD:
			all_swords = false
			break

	if all_swords:
		add_test_result(test_name, true, "%d espadas encontradas" % swords.size())
	else:
		add_test_result(test_name, false, "Hay armas de otros tipos")

## ============================================================================
## UTILIDADES
## ============================================================================

func add_test_result(test_name: String, passed: bool, message: String = "") -> void:
	test_results.append({"name": test_name, "passed": passed, "message": message})

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
	print("RESULTADOS - WEAPON SYSTEM")
	print("=".repeat(80))
	print("Total: %d | ✅ Pasadas: %d | ❌ Fallidas: %d" % [passed_tests + failed_tests, passed_tests, failed_tests])
	print("Éxito: %.1f%%" % ((float(passed_tests) / (passed_tests + failed_tests)) * 100))
	print("=".repeat(80) + "\n")
