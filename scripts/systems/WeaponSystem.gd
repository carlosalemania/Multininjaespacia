extends Node
## Sistema global de armas
## Autoload: WeaponSystem

## Señales
signal weapon_equipped(weapon_data: WeaponData)
signal weapon_unequipped
signal weapon_durability_changed(weapon_id: String, durability: int)
signal weapon_broken(weapon_id: String)

## Biblioteca de armas
var weapon_library: Dictionary = {}

## Arma equipada actualmente
var equipped_weapon: WeaponData = null
var equipped_weapon_durability: int = 0

func _ready() -> void:
	_initialize_weapons()
	print("⚔️ WeaponSystem inicializado con ", weapon_library.size(), " armas")

## Inicializa todas las armas del MVP
func _initialize_weapons() -> void:
	# ESPADAS (4)
	weapon_library["sword_wood"] = _create_sword_wood()
	weapon_library["sword_stone"] = _create_sword_stone()
	weapon_library["sword_iron"] = _create_sword_iron()
	weapon_library["sword_diamond"] = _create_sword_diamond()

	# ESPADAS MÁGICAS (3)
	weapon_library["sword_crystal"] = _create_sword_crystal()
	weapon_library["sword_fire"] = _create_sword_fire()
	weapon_library["sword_ice"] = _create_sword_ice()

	# OTRAS ARMAS CUERPO A CUERPO (4)
	weapon_library["axe_battle"] = _create_axe_battle()
	weapon_library["dagger_iron"] = _create_dagger_iron()
	weapon_library["spear_iron"] = _create_spear_iron()
	weapon_library["hammer_war"] = _create_hammer_war()

	# ARMAS A DISTANCIA (4)
	weapon_library["bow_basic"] = _create_bow_basic()
	weapon_library["crossbow"] = _create_crossbow()
	weapon_library["pistol"] = _create_pistol()
	weapon_library["shotgun"] = _create_shotgun()

	# ARMAS ESPECIALES (2)
	weapon_library["trident"] = _create_trident()
	weapon_library["magic_staff"] = _create_magic_staff()

	# Total: 20 armas

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ESPADAS BÁSICAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _create_sword_wood() -> WeaponData:
	var weapon = WeaponData.new()
	weapon.weapon_id = "sword_wood"
	weapon.weapon_name = "Espada de Madera"
	weapon.description = "Una espada simple hecha de madera. Ideal para principiantes."
	weapon.icon = "🪵"

	weapon.weapon_type = WeaponData.WeaponType.SWORD
	weapon.tier = WeaponData.WeaponTier.BASIC

	weapon.base_damage = 5.0
	weapon.attack_speed = 1.6
	weapon.attack_range = 2.0
	weapon.max_durability = 60
	weapon.knockback = 0.5

	weapon.primary_color = Color(0.6, 0.4, 0.2)
	weapon.blade_color = Color(0.5, 0.35, 0.2)
	weapon.handle_color = Color(0.4, 0.2, 0.1)

	weapon.craft_requirements = {
		"madera": 2,
		"palo": 1
	}
	weapon.sell_value = 5

	return weapon

func _create_sword_stone() -> WeaponData:
	var weapon = WeaponData.new()
	weapon.weapon_id = "sword_stone"
	weapon.weapon_name = "Espada de Piedra"
	weapon.description = "Una espada tosca pero efectiva, hecha de piedra."
	weapon.icon = "🪨"

	weapon.weapon_type = WeaponData.WeaponType.SWORD
	weapon.tier = WeaponData.WeaponTier.BASIC

	weapon.base_damage = 8.0
	weapon.attack_speed = 1.4
	weapon.attack_range = 2.0
	weapon.max_durability = 132
	weapon.knockback = 0.7

	weapon.primary_color = Color.DARK_GRAY
	weapon.blade_color = Color(0.4, 0.4, 0.4)
	weapon.handle_color = Color(0.4, 0.2, 0.1)

	weapon.craft_requirements = {
		"piedra": 2,
		"palo": 1
	}
	weapon.sell_value = 10

	return weapon

func _create_sword_iron() -> WeaponData:
	var weapon = WeaponData.new()
	weapon.weapon_id = "sword_iron"
	weapon.weapon_name = "Espada de Hierro"
	weapon.description = "Una espada de hierro bien forjada. Equilibrada y confiable."
	weapon.icon = "⚔️"

	weapon.weapon_type = WeaponData.WeaponType.SWORD
	weapon.tier = WeaponData.WeaponTier.COMMON

	weapon.base_damage = 12.0
	weapon.attack_speed = 1.5
	weapon.attack_range = 2.2
	weapon.max_durability = 250
	weapon.knockback = 0.8
	weapon.critical_chance = 0.05

	weapon.primary_color = Color.SILVER
	weapon.blade_color = Color(0.7, 0.7, 0.8)
	weapon.handle_color = Color(0.3, 0.15, 0.05)

	weapon.craft_requirements = {
		"hierro": 2,
		"palo": 1
	}
	weapon.sell_value = 30

	return weapon

func _create_sword_diamond() -> WeaponData:
	var weapon = WeaponData.new()
	weapon.weapon_id = "sword_diamond"
	weapon.weapon_name = "Espada de Diamante"
	weapon.description = "Una espada legendaria forjada con diamantes puros. Inmensamente poderosa."
	weapon.icon = "💎"

	weapon.weapon_type = WeaponData.WeaponType.SWORD
	weapon.tier = WeaponData.WeaponTier.RARE

	weapon.base_damage = 18.0
	weapon.attack_speed = 1.6
	weapon.attack_range = 2.3
	weapon.max_durability = 1561
	weapon.knockback = 1.0
	weapon.critical_chance = 0.10
	weapon.critical_multiplier = 2.0

	weapon.primary_color = Color(0.4, 0.8, 1.0)
	weapon.blade_color = Color(0.5, 0.9, 1.0)
	weapon.handle_color = Color(0.2, 0.2, 0.3)
	weapon.has_glow = true
	weapon.glow_color = Color(0.5, 0.9, 1.0)
	weapon.glow_intensity = 0.5

	weapon.has_trail = true
	weapon.trail_color = Color(0.4, 0.8, 1.0)

	weapon.craft_requirements = {
		"diamante": 2,
		"palo": 1
	}
	weapon.sell_value = 500

	return weapon

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ESPADAS MÁGICAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _create_sword_crystal() -> WeaponData:
	var weapon = WeaponData.new()
	weapon.weapon_id = "sword_crystal"
	weapon.weapon_name = "Espada de Cristal"
	weapon.description = "Una espada imbuida con energía de Luz Interior. Cada golpe purifica el alma."
	weapon.icon = "💠"

	weapon.weapon_type = WeaponData.WeaponType.SWORD
	weapon.tier = WeaponData.WeaponTier.LEGENDARY
	weapon.damage_type = WeaponData.DamageType.MAGIC

	weapon.base_damage = 20.0
	weapon.attack_speed = 1.8
	weapon.attack_range = 2.5
	weapon.max_durability = 800
	weapon.knockback = 1.2
	weapon.critical_chance = 0.15

	weapon.has_special_effect = true
	weapon.special_effect_name = "Purificación (+10 Luz Interior)"
	weapon.special_effect_chance = 1.0  # Siempre

	weapon.primary_color = Color(0.8, 0.9, 1.0)
	weapon.blade_color = Color.CYAN
	weapon.handle_color = Color(0.6, 0.7, 0.9)
	weapon.has_glow = true
	weapon.glow_color = Color.CYAN
	weapon.glow_intensity = 1.5

	weapon.has_trail = true
	weapon.trail_color = Color(0.5, 0.8, 1.0)

	weapon.craft_requirements = {
		"cristal": 5,
		"diamante": 1,
		"palo": 1
	}
	weapon.sell_value = 1000

	return weapon

func _create_sword_fire() -> WeaponData:
	var weapon = WeaponData.new()
	weapon.weapon_id = "sword_fire"
	weapon.weapon_name = "Espada de Fuego"
	weapon.description = "Una espada ardiente que incendia a los enemigos. Forjada en lava pura."
	weapon.icon = "🔥"

	weapon.weapon_type = WeaponData.WeaponType.SWORD
	weapon.tier = WeaponData.WeaponTier.LEGENDARY
	weapon.damage_type = WeaponData.DamageType.FIRE

	weapon.base_damage = 16.0
	weapon.attack_speed = 1.6
	weapon.attack_range = 2.3
	weapon.max_durability = 500
	weapon.knockback = 1.0

	weapon.apply_burn = true
	weapon.burn_damage_per_second = 4.0
	weapon.burn_duration = 5.0

	weapon.primary_color = Color.ORANGE_RED
	weapon.blade_color = Color.RED
	weapon.handle_color = Color(0.3, 0.1, 0.0)
	weapon.has_glow = true
	weapon.glow_color = Color.ORANGE
	weapon.glow_intensity = 2.0

	weapon.has_trail = true
	weapon.trail_color = Color.ORANGE_RED

	weapon.craft_requirements = {
		"hierro": 2,
		"lava_bucket": 1,
		"fuego_esencia": 3
	}
	weapon.sell_value = 800

	return weapon

func _create_sword_ice() -> WeaponData:
	var weapon = WeaponData.new()
	weapon.weapon_id = "sword_ice"
	weapon.weapon_name = "Espada de Hielo"
	weapon.description = "Una espada helada que congela a los enemigos. Forjada en las profundidades árticas."
	weapon.icon = "❄️"

	weapon.weapon_type = WeaponData.WeaponType.SWORD
	weapon.tier = WeaponData.WeaponTier.LEGENDARY
	weapon.damage_type = WeaponData.DamageType.ICE

	weapon.base_damage = 16.0
	weapon.attack_speed = 1.7
	weapon.attack_range = 2.3
	weapon.max_durability = 500
	weapon.knockback = 0.5

	weapon.apply_freeze = true
	weapon.freeze_duration = 2.0

	weapon.primary_color = Color.LIGHT_CYAN
	weapon.blade_color = Color.CYAN
	weapon.handle_color = Color(0.3, 0.4, 0.5)
	weapon.has_glow = true
	weapon.glow_color = Color.CYAN
	weapon.glow_intensity = 1.5

	weapon.has_trail = true
	weapon.trail_color = Color.LIGHT_BLUE

	weapon.craft_requirements = {
		"hierro": 2,
		"hielo_eterno": 1,
		"hielo_esencia": 3
	}
	weapon.sell_value = 800

	return weapon

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# OTRAS ARMAS CUERPO A CUERPO
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _create_axe_battle() -> WeaponData:
	var weapon = WeaponData.new()
	weapon.weapon_id = "axe_battle"
	weapon.weapon_name = "Hacha de Batalla"
	weapon.description = "Un hacha pesada diseñada para combate. Golpes lentos pero devastadores."
	weapon.icon = "🪓"

	weapon.weapon_type = WeaponData.WeaponType.AXE
	weapon.tier = WeaponData.WeaponTier.COMMON

	weapon.base_damage = 15.0
	weapon.attack_speed = 0.8
	weapon.attack_range = 2.5
	weapon.max_durability = 250
	weapon.knockback = 2.0
	weapon.critical_chance = 0.10
	weapon.critical_multiplier = 2.5

	weapon.primary_color = Color.SILVER
	weapon.blade_color = Color.DARK_GRAY
	weapon.handle_color = Color(0.4, 0.2, 0.1)

	weapon.craft_requirements = {
		"hierro": 3,
		"palo": 2
	}
	weapon.sell_value = 40

	return weapon

func _create_dagger_iron() -> WeaponData:
	var weapon = WeaponData.new()
	weapon.weapon_id = "dagger_iron"
	weapon.weapon_name = "Daga de Hierro"
	weapon.description = "Una daga rápida y letal. Perfecta para ataques furtivos."
	weapon.icon = "🔪"

	weapon.weapon_type = WeaponData.WeaponType.DAGGER
	weapon.tier = WeaponData.WeaponTier.COMMON

	weapon.base_damage = 8.0
	weapon.attack_speed = 2.5
	weapon.attack_range = 1.5
	weapon.max_durability = 150
	weapon.knockback = 0.3
	weapon.critical_chance = 0.25  # 25% crítico
	weapon.critical_multiplier = 3.0  # x3 de espalda

	weapon.has_special_effect = true
	weapon.special_effect_name = "Ataque Furtivo (x3 daño de espalda)"

	weapon.primary_color = Color.SILVER
	weapon.blade_color = Color.GRAY
	weapon.handle_color = Color.BLACK

	weapon.craft_requirements = {
		"hierro": 1,
		"cuero": 1
	}
	weapon.sell_value = 25

	return weapon

func _create_spear_iron() -> WeaponData:
	var weapon = WeaponData.new()
	weapon.weapon_id = "spear_iron"
	weapon.weapon_name = "Lanza de Hierro"
	weapon.description = "Una lanza con largo alcance. Puede ser lanzada."
	weapon.icon = "🔱"

	weapon.weapon_type = WeaponData.WeaponType.SPEAR
	weapon.tier = WeaponData.WeaponTier.COMMON

	weapon.base_damage = 14.0
	weapon.attack_speed = 1.2
	weapon.attack_range = 4.0  # Largo alcance
	weapon.max_durability = 200
	weapon.knockback = 1.5

	weapon.attack_pattern = WeaponData.AttackPattern.THRUST

	weapon.has_special_effect = true
	weapon.special_effect_name = "Lanzable (Click Derecho)"

	weapon.primary_color = Color.SILVER
	weapon.blade_color = Color.DARK_GRAY
	weapon.handle_color = Color(0.5, 0.3, 0.2)

	weapon.craft_requirements = {
		"hierro": 1,
		"palo": 2
	}
	weapon.sell_value = 35

	return weapon

func _create_hammer_war() -> WeaponData:
	var weapon = WeaponData.new()
	weapon.weapon_id = "hammer_war"
	weapon.weapon_name = "Martillo de Guerra"
	weapon.description = "Un martillo masivo que rompe armaduras. Golpe de tierra causa AoE."
	weapon.icon = "🔨"

	weapon.weapon_type = WeaponData.WeaponType.HAMMER
	weapon.tier = WeaponData.WeaponTier.RARE

	weapon.base_damage = 25.0
	weapon.attack_speed = 0.6
	weapon.attack_range = 2.0
	weapon.max_durability = 400
	weapon.knockback = 3.0

	weapon.attack_pattern = WeaponData.AttackPattern.AREA
	weapon.area_radius = 3.0

	weapon.has_special_effect = true
	weapon.special_effect_name = "Golpe de Tierra (AoE 3m)"
	weapon.special_effect_chance = 0.3

	weapon.primary_color = Color.DARK_GRAY
	weapon.blade_color = Color.DIM_GRAY
	weapon.handle_color = Color(0.3, 0.2, 0.1)

	weapon.craft_requirements = {
		"hierro": 5,
		"diamante": 1,
		"palo": 2
	}
	weapon.sell_value = 200

	return weapon

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ARMAS A DISTANCIA
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _create_bow_basic() -> WeaponData:
	var weapon = WeaponData.new()
	weapon.weapon_id = "bow_basic"
	weapon.weapon_name = "Arco Básico"
	weapon.description = "Un arco simple pero efectivo. Dispara flechas a distancia."
	weapon.icon = "🏹"

	weapon.weapon_type = WeaponData.WeaponType.BOW
	weapon.tier = WeaponData.WeaponTier.BASIC

	weapon.base_damage = 15.0
	weapon.attack_speed = 0.8
	weapon.attack_range = 50.0
	weapon.max_durability = 384
	weapon.knockback = 0.5

	weapon.is_ranged = true
	weapon.projectile_speed = 40.0
	weapon.projectile_gravity = true
	weapon.ammo_type = "arrow"
	weapon.max_ammo = 1  # Carga 1 flecha
	weapon.reload_time = 1.2

	weapon.primary_color = Color(0.4, 0.2, 0.1)
	weapon.secondary_color = Color.TAN

	weapon.craft_requirements = {
		"palo": 3,
		"cuerda": 3
	}
	weapon.sell_value = 20

	return weapon

func _create_crossbow() -> WeaponData:
	var weapon = WeaponData.new()
	weapon.weapon_id = "crossbow"
	weapon.weapon_name = "Ballesta"
	weapon.description = "Una ballesta potente. Mayor daño que el arco pero recarga más lenta."
	weapon.icon = "🎯"

	weapon.weapon_type = WeaponData.WeaponType.CROSSBOW
	weapon.tier = WeaponData.WeaponTier.COMMON

	weapon.base_damage = 25.0
	weapon.attack_speed = 0.5
	weapon.attack_range = 60.0
	weapon.max_durability = 326
	weapon.knockback = 1.5

	weapon.is_ranged = true
	weapon.projectile_speed = 60.0
	weapon.projectile_gravity = true
	weapon.ammo_type = "bolt"
	weapon.max_ammo = 1
	weapon.reload_time = 2.5

	weapon.primary_color = Color(0.3, 0.2, 0.1)
	weapon.secondary_color = Color.DARK_GRAY

	weapon.craft_requirements = {
		"palo": 3,
		"hierro": 1,
		"cuerda": 2
	}
	weapon.sell_value = 50

	return weapon

func _create_pistol() -> WeaponData:
	var weapon = WeaponData.new()
	weapon.weapon_id = "pistol"
	weapon.weapon_name = "Pistola"
	weapon.description = "Un arma de fuego básica. Dispara balas con precisión moderada."
	weapon.icon = "🔫"

	weapon.weapon_type = WeaponData.WeaponType.GUN
	weapon.tier = WeaponData.WeaponTier.COMMON

	weapon.base_damage = 12.0
	weapon.attack_speed = 2.0
	weapon.attack_range = 30.0
	weapon.max_durability = 500
	weapon.knockback = 0.3

	weapon.is_ranged = true
	weapon.is_automatic = false
	weapon.projectile_speed = 100.0
	weapon.projectile_gravity = false
	weapon.ammo_type = "bullet"
	weapon.max_ammo = 12
	weapon.reload_time = 1.5
	weapon.fire_rate = 0.5
	weapon.accuracy = 0.9
	weapon.recoil = 0.1

	weapon.primary_color = Color.DARK_GRAY
	weapon.secondary_color = Color.BLACK

	weapon.craft_requirements = {
		"hierro": 3,
		"polvora": 2,
		"madera": 1
	}
	weapon.sell_value = 100

	return weapon

func _create_shotgun() -> WeaponData:
	var weapon = WeaponData.new()
	weapon.weapon_id = "shotgun"
	weapon.weapon_name = "Escopeta"
	weapon.description = "Dispara múltiples perdigones. Devastadora a corta distancia."
	weapon.icon = "💥"

	weapon.weapon_type = WeaponData.WeaponType.GUN
	weapon.tier = WeaponData.WeaponTier.RARE

	weapon.base_damage = 8.0  # x8 perdigones = 64 total
	weapon.attack_speed = 0.5
	weapon.attack_range = 15.0
	weapon.max_durability = 400
	weapon.knockback = 2.0

	weapon.is_ranged = true
	weapon.is_automatic = false
	weapon.projectile_speed = 80.0
	weapon.projectile_gravity = false
	weapon.projectile_count = 8  # 8 perdigones
	weapon.ammo_type = "shell"
	weapon.max_ammo = 6
	weapon.reload_time = 3.0
	weapon.fire_rate = 2.0
	weapon.accuracy = 0.6  # Baja precisión
	weapon.recoil = 0.5

	weapon.primary_color = Color.DIM_GRAY
	weapon.secondary_color = Color(0.3, 0.2, 0.1)

	weapon.craft_requirements = {
		"hierro": 4,
		"polvora": 3,
		"madera": 2
	}
	weapon.sell_value = 250

	return weapon

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ARMAS ESPECIALES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _create_trident() -> WeaponData:
	var weapon = WeaponData.new()
	weapon.weapon_id = "trident"
	weapon.weapon_name = "Tridente"
	weapon.description = "Un arma acuática legendaria. Efectiva bajo el agua y lanzable."
	weapon.icon = "🔱"

	weapon.weapon_type = WeaponData.WeaponType.TRIDENT
	weapon.tier = WeaponData.WeaponTier.RARE

	weapon.base_damage = 18.0
	weapon.attack_speed = 1.3
	weapon.attack_range = 3.0
	weapon.max_durability = 250
	weapon.knockback = 1.2

	weapon.attack_pattern = WeaponData.AttackPattern.THRUST

	weapon.has_special_effect = true
	weapon.special_effect_name = "Poder Acuático (+50% daño bajo agua)"

	weapon.primary_color = Color.CYAN
	weapon.blade_color = Color.STEEL_BLUE
	weapon.handle_color = Color.DARK_CYAN

	weapon.craft_requirements = {
		"prismatico": 3,
		"diamante": 1
	}
	weapon.sell_value = 300

	return weapon

func _create_magic_staff() -> WeaponData:
	var weapon = WeaponData.new()
	weapon.weapon_id = "magic_staff"
	weapon.weapon_name = "Báculo Mágico"
	weapon.description = "Un báculo que canaliza energía mágica. Lanza proyectiles de maná."
	weapon.icon = "🪄"

	weapon.weapon_type = WeaponData.WeaponType.MAGIC_STAFF
	weapon.tier = WeaponData.WeaponTier.LEGENDARY
	weapon.damage_type = WeaponData.DamageType.MAGIC

	weapon.base_damage = 12.0
	weapon.attack_speed = 1.5
	weapon.attack_range = 40.0
	weapon.max_durability = 500
	weapon.knockback = 0.5

	weapon.is_ranged = true
	weapon.projectile_speed = 35.0
	weapon.projectile_gravity = false
	weapon.mana_cost = 10

	weapon.primary_color = Color.PURPLE
	weapon.secondary_color = Color.MAGENTA
	weapon.has_glow = true
	weapon.glow_color = Color.MAGENTA
	weapon.glow_intensity = 2.0

	weapon.has_trail = true
	weapon.trail_color = Color.PURPLE

	weapon.craft_requirements = {
		"cristal": 3,
		"palo": 2,
		"libro": 1
	}
	weapon.sell_value = 500

	return weapon

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PÚBLICOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Obtiene un arma por ID
func get_weapon(weapon_id: String) -> WeaponData:
	return weapon_library.get(weapon_id, null)

## Verifica si existe un arma
func has_weapon(weapon_id: String) -> bool:
	return weapon_library.has(weapon_id)

## Obtiene todos los IDs de armas
func get_all_weapon_ids() -> Array:
	return weapon_library.keys()

## Obtiene todas las armas
func get_all_weapons() -> Dictionary:
	return weapon_library.duplicate()

## Obtiene armas por tipo
func get_weapons_by_type(weapon_type: WeaponData.WeaponType) -> Array:
	var result = []
	for weapon_id in weapon_library:
		var weapon = weapon_library[weapon_id]
		if weapon.weapon_type == weapon_type:
			result.append(weapon)
	return result

## Obtiene armas por tier
func get_weapons_by_tier(tier: WeaponData.WeaponTier) -> Array:
	var result = []
	for weapon_id in weapon_library:
		var weapon = weapon_library[weapon_id]
		if weapon.tier == tier:
			result.append(weapon)
	return result

## Equipa un arma
func equip_weapon(weapon_id: String) -> bool:
	var weapon = get_weapon(weapon_id)
	if not weapon:
		return false

	equipped_weapon = weapon
	equipped_weapon_durability = weapon.max_durability
	weapon_equipped.emit(weapon)
	return true

## Desequipa el arma actual
func unequip_weapon() -> void:
	equipped_weapon = null
	equipped_weapon_durability = 0
	weapon_unequipped.emit()

## Obtiene el arma equipada
func get_equipped_weapon() -> WeaponData:
	return equipped_weapon

## Usa el arma equipada (reduce durabilidad)
func use_weapon() -> void:
	if not equipped_weapon or equipped_weapon.is_unbreakable:
		return

	equipped_weapon_durability -= equipped_weapon.durability_cost_per_hit
	weapon_durability_changed.emit(equipped_weapon.weapon_id, equipped_weapon_durability)

	if equipped_weapon_durability <= 0:
		weapon_broken.emit(equipped_weapon.weapon_id)
		unequip_weapon()

## Repara un arma
func repair_weapon(weapon_id: String, amount: int) -> void:
	if equipped_weapon and equipped_weapon.weapon_id == weapon_id:
		equipped_weapon_durability = min(
			equipped_weapon_durability + amount,
			equipped_weapon.max_durability
		)
		weapon_durability_changed.emit(weapon_id, equipped_weapon_durability)

## Obtiene la durabilidad actual del arma equipada
func get_weapon_durability() -> int:
	return equipped_weapon_durability

## Obtiene el porcentaje de durabilidad
func get_weapon_durability_percent() -> float:
	if not equipped_weapon:
		return 0.0
	return float(equipped_weapon_durability) / float(equipped_weapon.max_durability)
