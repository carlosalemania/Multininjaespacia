extends Resource
class_name WeaponData
## Datos de un arma (cuerpo a cuerpo o distancia)

enum WeaponType {
	SWORD,          # Espada
	AXE,            # Hacha
	DAGGER,         # Daga
	SPEAR,          # Lanza
	BOW,            # Arco
	CROSSBOW,       # Ballesta
	GUN,            # Arma de fuego
	MAGIC_STAFF,    # Báculo mágico
	HAMMER,         # Martillo
	SCYTHE,         # Guadaña
	WHIP,           # Látigo
	TRIDENT         # Tridente
}

enum WeaponTier {
	BASIC,          # Madera, Piedra
	COMMON,         # Hierro
	RARE,           # Oro, Diamante
	EPIC,           # Netherite
	LEGENDARY,      # Cristal, Mágico
	MYTHIC          # Supremo
}

enum DamageType {
	PHYSICAL,       # Daño físico
	FIRE,           # Fuego
	ICE,            # Hielo
	LIGHTNING,      # Rayo
	MAGIC,          # Mágico
	POISON,         # Veneno
	HOLY,           # Sagrado
	DARK            # Oscuridad
}

enum AttackPattern {
	SINGLE,         # Un golpe
	COMBO,          # Combo de golpes
	THRUST,         # Estocada
	SLASH,          # Tajo
	SWEEP,          # Barrido
	PROJECTILE,     # Proyectil
	BEAM,           # Rayo
	AREA            # Área
}

## Identificación
@export var weapon_id: String = ""
@export var weapon_name: String = ""
@export var description: String = ""
@export var icon: String = "⚔️"

## Tipo y Tier
@export var weapon_type: WeaponType = WeaponType.SWORD
@export var tier: WeaponTier = WeaponTier.BASIC

## Estadísticas de Combate
@export var base_damage: float = 10.0
@export var damage_type: DamageType = DamageType.PHYSICAL
@export var attack_speed: float = 1.0  # Ataques por segundo
@export var attack_range: float = 2.0  # Metros
@export var knockback: float = 1.0
@export var critical_chance: float = 0.05  # 5%
@export var critical_multiplier: float = 1.5  # x1.5 daño

## Durabilidad
@export var max_durability: int = 100
@export var durability_cost_per_hit: int = 1
@export var is_unbreakable: bool = false

## Efectos Especiales
@export var has_special_effect: bool = false
@export var special_effect_name: String = ""
@export var special_effect_chance: float = 0.1  # 10%
@export var special_effect_duration: float = 5.0  # Segundos

## Efectos de Estado
@export var apply_burn: bool = false
@export var burn_damage_per_second: float = 2.0
@export var burn_duration: float = 5.0

@export var apply_freeze: bool = false
@export var freeze_duration: float = 2.0

@export var apply_poison: bool = false
@export var poison_damage_per_second: float = 3.0
@export var poison_duration: float = 5.0

@export var apply_stun: bool = false
@export var stun_duration: float = 1.0

## Vida y Maná
@export var life_steal: float = 0.0  # % de daño que cura
@export var mana_cost: int = 0  # Coste de maná por uso

## Patrón de Ataque
@export var attack_pattern: AttackPattern = AttackPattern.SINGLE
@export var combo_hits: int = 1  # Número de golpes en combo
@export var area_radius: float = 0.0  # Radio de ataque de área
@export var sweep_angle: float = 0.0  # Ángulo de barrido (grados)

## Proyectiles (para arcos, armas de fuego, etc.)
@export var is_ranged: bool = false
@export var projectile_speed: float = 30.0
@export var projectile_gravity: bool = true
@export var projectile_count: int = 1  # Múltiples proyectiles
@export var ammo_type: String = ""  # "arrow", "bullet", etc.
@export var max_ammo: int = 0  # Clip/Carcaj
@export var reload_time: float = 2.0

## Armas de fuego específicas
@export var is_automatic: bool = false
@export var fire_rate: float = 0.1  # Segundos entre disparos
@export var recoil: float = 0.0
@export var accuracy: float = 1.0  # 1.0 = perfecto, 0.0 = muy impreciso

## Visual
@export var model_scale: Vector3 = Vector3.ONE
@export var primary_color: Color = Color.WHITE
@export var secondary_color: Color = Color.GRAY
@export var blade_color: Color = Color.SILVER
@export var handle_color: Color = Color(0.4, 0.2, 0.1)  # Marrón
@export var glow_color: Color = Color.WHITE
@export var has_glow: bool = false
@export var glow_intensity: float = 1.0

## Partículas
@export var has_trail: bool = false
@export var trail_color: Color = Color.WHITE
@export var has_hit_particles: bool = true
@export var hit_particle_color: Color = Color.RED

## Sonido
@export var swing_sound: String = "sword_swing"
@export var hit_sound: String = "sword_hit"
@export var special_sound: String = ""

## Crafteo
@export var craft_requirements: Dictionary = {}
@export var unlock_requirement: String = ""  # Logro requerido

## Valor
@export var sell_value: int = 10
@export var rarity_multiplier: float = 1.0

## Métodos Auxiliares

## Calcula el daño total considerando crítico
func calculate_damage(is_critical: bool = false) -> float:
	var damage = base_damage
	if is_critical:
		damage *= critical_multiplier
	return damage

## Verifica si un ataque es crítico
func roll_critical() -> bool:
	return randf() < critical_chance

## Verifica si se activa el efecto especial
func roll_special_effect() -> bool:
	if not has_special_effect:
		return false
	return randf() < special_effect_chance

## Obtiene el DPS (Daño Por Segundo)
func get_dps() -> float:
	return base_damage * attack_speed

## Obtiene el color del tier
func get_tier_color() -> Color:
	match tier:
		WeaponTier.BASIC:
			return Color.GRAY
		WeaponTier.COMMON:
			return Color.WHITE
		WeaponTier.RARE:
			return Color(0.3, 0.7, 1.0)  # Azul
		WeaponTier.EPIC:
			return Color(0.7, 0.3, 1.0)  # Púrpura
		WeaponTier.LEGENDARY:
			return Color(1.0, 0.6, 0.0)  # Naranja
		WeaponTier.MYTHIC:
			return Color(1.0, 0.2, 0.2)  # Rojo
	return Color.WHITE

## Obtiene el nombre del tier
func get_tier_name() -> String:
	match tier:
		WeaponTier.BASIC:
			return "Básica"
		WeaponTier.COMMON:
			return "Común"
		WeaponTier.RARE:
			return "Rara"
		WeaponTier.EPIC:
			return "Épica"
		WeaponTier.LEGENDARY:
			return "Legendaria"
		WeaponTier.MYTHIC:
			return "Mítica"
	return "Desconocida"

## Obtiene descripción completa del arma
func get_full_description() -> String:
	var desc = weapon_name + " (" + get_tier_name() + ")\n\n"
	desc += description + "\n\n"
	desc += "⚔️ Daño: " + str(base_damage) + "\n"
	desc += "⚡ Velocidad: " + str(attack_speed) + " ataques/seg\n"
	desc += "📏 Alcance: " + str(attack_range) + "m\n"
	desc += "💎 Durabilidad: " + str(max_durability) + "\n"

	if critical_chance > 0:
		desc += "🎯 Crítico: " + str(critical_chance * 100) + "% (x" + str(critical_multiplier) + ")\n"

	if has_special_effect:
		desc += "✨ Efecto: " + special_effect_name + "\n"

	if apply_burn:
		desc += "🔥 Incendio: " + str(burn_damage_per_second) + "/seg por " + str(burn_duration) + "seg\n"

	if apply_freeze:
		desc += "❄️ Congelación: " + str(freeze_duration) + "seg\n"

	if apply_poison:
		desc += "🟢 Veneno: " + str(poison_damage_per_second) + "/seg por " + str(poison_duration) + "seg\n"

	if life_steal > 0:
		desc += "💚 Robo de vida: " + str(life_steal * 100) + "%\n"

	if is_ranged:
		desc += "🏹 Munición: " + ammo_type + " (" + str(max_ammo) + ")\n"

	return desc

## Verifica si el arma puede ser usada
func can_use(player_mana: int = 0) -> bool:
	if mana_cost > 0 and player_mana < mana_cost:
		return false
	return true
