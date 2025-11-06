extends Node
## Sistema de combate global
## Autoload: CombatSystem

## Señales
signal damage_dealt(attacker: Node, target: Node, damage: float, damage_type: WeaponData.DamageType)
signal enemy_killed(attacker: Node, enemy: Node)
signal critical_hit(attacker: Node, target: Node, damage: float)
signal status_effect_applied(target: Node, effect_type: String, duration: float)

## Configuración
var damage_numbers_enabled: bool = true
var knockback_enabled: bool = true
var critical_hit_sound_enabled: bool = true

## Registro de combates
var combat_log: Array[Dictionary] = []
var max_log_entries: int = 100

func _ready() -> void:
	print("⚔️ CombatSystem inicializado")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS DE ATAQUE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Realiza un ataque cuerpo a cuerpo
func melee_attack(attacker: Node3D, weapon: WeaponData, target: Node3D) -> Dictionary:
	if not weapon or not target:
		return {"success": false, "reason": "Invalid parameters"}

	# Verificar alcance
	var distance = attacker.global_position.distance_to(target.global_position)
	if distance > weapon.attack_range:
		return {"success": false, "reason": "Out of range"}

	# Calcular si es crítico
	var is_critical = weapon.roll_critical()

	# Calcular daño
	var damage = weapon.calculate_damage(is_critical)

	# Aplicar modificadores (de espalda para dagas, etc.)
	damage = _apply_attack_modifiers(attacker, target, weapon, damage, is_critical)

	# Aplicar daño al objetivo
	var damage_result = apply_damage(target, damage, weapon.damage_type, attacker)

	# Knockback
	if knockback_enabled and weapon.knockback > 0:
		apply_knockback(target, attacker, weapon.knockback)

	# Efectos de estado
	_apply_status_effects(target, weapon)

	# Robo de vida
	if weapon.life_steal > 0:
		_apply_life_steal(attacker, damage, weapon.life_steal)

	# Efectos visuales y sonoros
	_create_hit_effects(target, weapon, is_critical)

	# Reducir durabilidad del arma
	if WeaponSystem.equipped_weapon == weapon:
		WeaponSystem.use_weapon()

	# Logro: Luz Interior por uso de armas mágicas
	if weapon.damage_type == WeaponData.DamageType.MAGIC:
		if VirtueSystem:
			VirtueSystem.add_luz_manual(5, "Usar magia en combate")

	# Efecto especial del arma
	if weapon.roll_special_effect():
		_trigger_weapon_special_effect(attacker, target, weapon)

	# Emitir señal
	if is_critical:
		critical_hit.emit(attacker, target, damage)
	damage_dealt.emit(attacker, target, damage, weapon.damage_type)

	# Registrar en log
	_log_combat_event({
		"type": "melee_attack",
		"attacker": attacker.name,
		"target": target.name,
		"weapon": weapon.weapon_name,
		"damage": damage,
		"critical": is_critical,
		"time": Time.get_ticks_msec()
	})

	return {
		"success": true,
		"damage": damage,
		"critical": is_critical,
		"killed": damage_result.killed
	}

## Realiza un ataque a distancia
func ranged_attack(attacker: Node3D, weapon: WeaponData, target_position: Vector3) -> Dictionary:
	if not weapon or not weapon.is_ranged:
		return {"success": false, "reason": "Not a ranged weapon"}

	# Verificar munición/maná
	if weapon.ammo_type and not _has_ammo(attacker, weapon):
		return {"success": false, "reason": "No ammo"}

	if weapon.mana_cost > 0 and not weapon.can_use(_get_player_mana(attacker)):
		return {"success": false, "reason": "Not enough mana"}

	# Consumir munición/maná
	_consume_ammo(attacker, weapon)
	_consume_mana(attacker, weapon.mana_cost)

	# Crear proyectil
	var projectile = _create_projectile(attacker, weapon, target_position)

	# Efectos de disparo
	_create_fire_effects(attacker, weapon)

	# Reducir durabilidad
	if WeaponSystem.equipped_weapon == weapon:
		WeaponSystem.use_weapon()

	return {
		"success": true,
		"projectile": projectile
	}

## Aplica daño a una entidad
func apply_damage(target: Node, damage: float, damage_type: WeaponData.DamageType, attacker: Node = null) -> Dictionary:
	if not target:
		return {"success": false}

	# Buscar componente de salud
	var health_component = _get_health_component(target)
	if not health_component:
		return {"success": false, "reason": "No health component"}

	# Calcular resistencias
	var final_damage = _calculate_damage_reduction(target, damage, damage_type)

	# Aplicar daño
	var previous_health = health_component.current_health
	health_component.current_health -= final_damage
	health_component.current_health = max(0, health_component.current_health)

	# Número de daño flotante
	if damage_numbers_enabled:
		_create_damage_number(target, final_damage)

	# Verificar muerte
	var killed = health_component.current_health <= 0
	if killed and attacker:
		_handle_enemy_death(attacker, target)

	return {
		"success": true,
		"damage": final_damage,
		"previous_health": previous_health,
		"current_health": health_component.current_health,
		"killed": killed
	}

## Aplica knockback a un objetivo
func apply_knockback(target: Node3D, source: Node3D, force: float) -> void:
	if not target or not source:
		return

	# Calcular dirección
	var direction = (target.global_position - source.global_position).normalized()
	direction.y = 0.3  # Añadir componente vertical

	# Aplicar fuerza
	if target is CharacterBody3D:
		target.velocity += direction * force * 5.0
	elif target is RigidBody3D:
		target.apply_central_impulse(direction * force * 10.0)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# EFECTOS DE ESTADO
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Aplica efectos de estado del arma
func _apply_status_effects(target: Node, weapon: WeaponData) -> void:
	if weapon.apply_burn:
		apply_burn_effect(target, weapon.burn_damage_per_second, weapon.burn_duration)

	if weapon.apply_freeze:
		apply_freeze_effect(target, weapon.freeze_duration)

	if weapon.apply_poison:
		apply_poison_effect(target, weapon.poison_damage_per_second, weapon.poison_duration)

	if weapon.apply_stun:
		apply_stun_effect(target, weapon.stun_duration)

## Aplica efecto de quemadura
func apply_burn_effect(target: Node, damage_per_second: float, duration: float) -> void:
	var effect = {
		"type": "burn",
		"damage_per_second": damage_per_second,
		"duration": duration,
		"elapsed": 0.0
	}

	_add_status_effect(target, effect)
	_create_burn_particles(target)
	status_effect_applied.emit(target, "burn", duration)

## Aplica efecto de congelación
func apply_freeze_effect(target: Node, duration: float) -> void:
	var effect = {
		"type": "freeze",
		"duration": duration,
		"elapsed": 0.0,
		"original_speed": 1.0
	}

	# Guardar velocidad original
	if target.has_method("get_speed"):
		effect.original_speed = target.get_speed()

	# Reducir velocidad al 20%
	if target.has_method("set_speed"):
		target.set_speed(effect.original_speed * 0.2)

	_add_status_effect(target, effect)
	_create_freeze_particles(target)
	status_effect_applied.emit(target, "freeze", duration)

## Aplica efecto de veneno
func apply_poison_effect(target: Node, damage_per_second: float, duration: float) -> void:
	var effect = {
		"type": "poison",
		"damage_per_second": damage_per_second,
		"duration": duration,
		"elapsed": 0.0
	}

	_add_status_effect(target, effect)
	_create_poison_particles(target)
	status_effect_applied.emit(target, "poison", duration)

## Aplica efecto de aturdimiento
func apply_stun_effect(target: Node, duration: float) -> void:
	var effect = {
		"type": "stun",
		"duration": duration,
		"elapsed": 0.0
	}

	# Desactivar movimiento
	if target.has_method("set_can_move"):
		target.set_can_move(false)

	_add_status_effect(target, effect)
	_create_stun_particles(target)
	status_effect_applied.emit(target, "stun", duration)

## Añade un efecto de estado a un objetivo
func _add_status_effect(target: Node, effect: Dictionary) -> void:
	if not target.has_meta("status_effects"):
		target.set_meta("status_effects", [])

	var effects = target.get_meta("status_effects")
	effects.append(effect)

	# Conectar proceso si es la primera vez
	if effects.size() == 1:
		# Usar un timer para actualizar efectos de estado
		var timer = Timer.new()
		timer.wait_time = 0.1
		timer.timeout.connect(_on_status_effect_tick.bind(target))
		target.add_child(timer)
		timer.start()
		target.set_meta("status_effect_timer", timer)

## Actualiza efectos de estado (llamado por timer)
func _on_status_effect_tick(target: Node) -> void:
	if not target or not target.has_meta("status_effects"):
		return

	var effects = target.get_meta("status_effects")
	var delta = 0.1  # Timer de 0.1 segundos

	for i in range(effects.size() - 1, -1, -1):
		var effect = effects[i]
		effect.elapsed += delta

		# Aplicar daño por tiempo
		if effect.type == "burn" or effect.type == "poison":
			var damage = effect.damage_per_second * delta
			apply_damage(target, damage, WeaponData.DamageType.FIRE if effect.type == "burn" else WeaponData.DamageType.POISON)

		# Remover efecto si expiró
		if effect.elapsed >= effect.duration:
			_remove_status_effect(target, effect)
			effects.remove_at(i)

	# Limpiar si no hay más efectos
	if effects.is_empty():
		var timer = target.get_meta("status_effect_timer")
		if timer:
			timer.queue_free()
		target.remove_meta("status_effect_timer")
		target.remove_meta("status_effects")

## Remueve un efecto de estado
func _remove_status_effect(target: Node, effect: Dictionary) -> void:
	match effect.type:
		"freeze":
			if target.has_method("set_speed"):
				target.set_speed(effect.original_speed)
		"stun":
			if target.has_method("set_can_move"):
				target.set_can_move(true)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MODIFICADORES Y CÁLCULOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Aplica modificadores de ataque
func _apply_attack_modifiers(attacker: Node3D, target: Node3D, weapon: WeaponData, damage: float, _is_critical: bool) -> float:
	var modified_damage = damage

	# Ataque de espalda (dagas)
	if weapon.weapon_type == WeaponData.WeaponType.DAGGER:
		if _is_back_attack(attacker, target):
			modified_damage *= 3.0  # x3 daño de espalda

	# Ataque acuático (tridente)
	if weapon.weapon_id == "trident":
		if _is_underwater(target):
			modified_damage *= 1.5  # +50% bajo agua

	# Espada de cristal: siempre da Luz Interior
	if weapon.weapon_id == "sword_crystal":
		if VirtueSystem:
			VirtueSystem.add_luz_manual(10, "Golpe con Espada de Cristal")

	return modified_damage

## Verifica si es un ataque de espalda
func _is_back_attack(attacker: Node3D, target: Node3D) -> bool:
	var to_attacker = (attacker.global_position - target.global_position).normalized()
	var target_forward = -target.global_transform.basis.z.normalized()
	var dot = to_attacker.dot(target_forward)
	return dot > 0.5  # 60° de ángulo trasero

## Verifica si está bajo agua
func _is_underwater(_node: Node3D) -> bool:
	# TODO: Implementar detección de agua
	return false

## Calcula reducción de daño por resistencias
func _calculate_damage_reduction(_target: Node, damage: float, _damage_type: WeaponData.DamageType) -> float:
	# TODO: Implementar sistema de armadura y resistencias
	return damage

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROYECTILES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Crea un proyectil
func _create_projectile(attacker: Node3D, weapon: WeaponData, target_position: Vector3) -> Node3D:
	var projectile = load("res://scripts/entities/Projectile.gd").new() if ResourceLoader.exists("res://scripts/entities/Projectile.gd") else Node3D.new()

	projectile.position = attacker.global_position + Vector3(0, 1.5, 0)  # A la altura del pecho

	# Configurar proyectil
	if projectile.has_method("initialize"):
		var direction = (target_position - projectile.position).normalized()
		projectile.initialize(weapon, direction, attacker)

	# Añadir al mundo
	if attacker.get_parent():
		attacker.get_parent().add_child(projectile)

	return projectile

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# EFECTOS ESPECIALES DE ARMAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Dispara el efecto especial de un arma
func _trigger_weapon_special_effect(attacker: Node3D, target: Node3D, weapon: WeaponData) -> void:
	match weapon.weapon_id:
		"hammer_war":
			_hammer_ground_slam(attacker, weapon)
		"sword_lightning":
			_lightning_chain(target, weapon)
		"sword_holy":
			_holy_heal(attacker)

## Martillo: Golpe de tierra (AoE)
func _hammer_ground_slam(attacker: Node3D, weapon: WeaponData) -> void:
	# Crear onda de choque visual
	_create_shockwave_effect(attacker.global_position)

	# Dañar enemigos en área
	var enemies = _get_enemies_in_radius(attacker.global_position, weapon.area_radius)
	for enemy in enemies:
		apply_damage(enemy, weapon.base_damage * 0.5, weapon.damage_type, attacker)
		apply_knockback(enemy, attacker, weapon.knockback * 2.0)

## Espada de rayo: Cadena eléctrica
func _lightning_chain(initial_target: Node3D, weapon: WeaponData) -> void:
	var current_target = initial_target
	var hit_targets = [current_target]
	var max_chains = 3

	for i in range(max_chains):
		# Buscar siguiente objetivo cercano
		var next_target = _find_nearest_enemy(current_target, 5.0, hit_targets)
		if not next_target:
			break

		# Crear rayo visual
		_create_lightning_beam(current_target.global_position, next_target.global_position)

		# Aplicar daño reducido
		var chain_damage = weapon.base_damage * pow(0.7, i + 1)
		apply_damage(next_target, chain_damage, WeaponData.DamageType.LIGHTNING)

		hit_targets.append(next_target)
		current_target = next_target

## Espada sagrada: Curación
func _holy_heal(attacker: Node3D) -> void:
	var heal_amount = 5.0
	var health_component = _get_health_component(attacker)
	if health_component:
		health_component.current_health = min(
			health_component.current_health + heal_amount,
			health_component.max_health
		)
		_create_heal_particles(attacker)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# UTILIDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Obtiene el componente de salud
func _get_health_component(node: Node) -> Node:
	# Buscar en PlayerData para el jugador
	if node.name == "Player" or node.is_in_group("player"):
		return PlayerData if PlayerData else null

	# Buscar componente de salud en el nodo
	if node.has_node("HealthComponent"):
		return node.get_node("HealthComponent")

	# Buscar en el mismo nodo si tiene las propiedades
	if node.has("current_health") and node.has("max_health"):
		return node

	return null

## Aplica robo de vida
func _apply_life_steal(attacker: Node, damage: float, life_steal_percent: float) -> void:
	var heal = damage * life_steal_percent
	var health_component = _get_health_component(attacker)
	if health_component:
		health_component.current_health = min(
			health_component.current_health + heal,
			health_component.max_health
		)
		_create_life_steal_particles(attacker)

## Maneja la muerte de un enemigo
func _handle_enemy_death(attacker: Node, enemy: Node) -> void:
	enemy_killed.emit(attacker, enemy)

	# Logro
	if AchievementSystem:
		AchievementSystem.increment_stat("enemies_killed", 1)

	# Luz Interior
	if VirtueSystem:
		VirtueSystem.add_luz_manual(25, "Derrotar enemigo")

	# Efecto de muerte
	_create_death_effect(enemy)

## Verifica si tiene munición
func _has_ammo(_attacker: Node, _weapon: WeaponData) -> bool:
	# TODO: Verificar inventario
	return true

## Consume munición
func _consume_ammo(_attacker: Node, _weapon: WeaponData) -> void:
	# TODO: Reducir munición del inventario
	pass

## Obtiene maná del jugador
func _get_player_mana(_attacker: Node) -> int:
	if PlayerData and PlayerData.has("mana"):
		return PlayerData.mana
	return 100  # Default

## Consume maná
func _consume_mana(_attacker: Node, amount: int) -> void:
	if PlayerData and PlayerData.has("mana"):
		PlayerData.mana -= amount

## Obtiene enemigos en radio
func _get_enemies_in_radius(_center: Vector3, _radius: float) -> Array:
	var result = []
	var _space_state = get_tree().root.get_world_3d().direct_space_state
	# TODO: Implementar query de área
	return result

## Encuentra el enemigo más cercano
func _find_nearest_enemy(_from: Node3D, _max_distance: float, _exclude: Array) -> Node3D:
	# TODO: Implementar búsqueda de enemigos
	return null

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# EFECTOS VISUALES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Crea efectos de golpe
func _create_hit_effects(target: Node3D, weapon: WeaponData, is_critical: bool) -> void:
	if weapon.has_hit_particles:
		_create_hit_particles(target, weapon.hit_particle_color, is_critical)

	# Sonido
	if AudioManager:
		var sound = weapon.hit_sound if not is_critical else "critical_hit"
		AudioManager.play_sound(sound)

	# Congelar frame en crítico
	if is_critical:
		Engine.time_scale = 0.1
		await get_tree().create_timer(0.05).timeout
		Engine.time_scale = 1.0

## Crea efectos de disparo
func _create_fire_effects(attacker: Node3D, weapon: WeaponData) -> void:
	# Flash de boca
	_create_muzzle_flash(attacker)

	# Sonido
	if AudioManager:
		AudioManager.play_sound(weapon.swing_sound)

	# Retroceso visual
	if weapon.recoil > 0:
		_apply_camera_shake(weapon.recoil)

## Crea partículas de golpe
func _create_hit_particles(target: Node3D, color: Color, is_critical: bool) -> void:
	if ParticleEffects:
		var intensity = 2.0 if is_critical else 1.0
		ParticleEffects.create_hit_effect(target.global_position, color, intensity)

## Crea número de daño flotante
func _create_damage_number(_target: Node3D, _damage: float) -> void:
	# TODO: Implementar números flotantes
	pass

## Crea partículas de quemadura
func _create_burn_particles(target: Node3D) -> void:
	if ParticleEffects:
		ParticleEffects.create_fire_particles(target)

## Crea partículas de congelación
func _create_freeze_particles(target: Node3D) -> void:
	if ParticleEffects:
		ParticleEffects.create_ice_particles(target)

## Crea partículas de veneno
func _create_poison_particles(target: Node3D) -> void:
	if ParticleEffects:
		ParticleEffects.create_poison_particles(target)

## Crea partículas de aturdimiento
func _create_stun_particles(target: Node3D) -> void:
	if ParticleEffects:
		ParticleEffects.create_stun_particles(target)

## Crea efecto de muerte
func _create_death_effect(enemy: Node3D) -> void:
	if ParticleEffects:
		ParticleEffects.create_death_explosion(enemy.global_position)

## Crea partículas de robo de vida
func _create_life_steal_particles(attacker: Node3D) -> void:
	if ParticleEffects:
		ParticleEffects.create_heal_particles(attacker)

## Crea partículas de curación
func _create_heal_particles(target: Node3D) -> void:
	if ParticleEffects:
		ParticleEffects.create_heal_particles(target)

## Crea onda de choque
func _create_shockwave_effect(position: Vector3) -> void:
	if ParticleEffects:
		ParticleEffects.create_shockwave(position)

## Crea rayo eléctrico
func _create_lightning_beam(from: Vector3, to: Vector3) -> void:
	if ParticleEffects:
		ParticleEffects.create_lightning_beam(from, to)

## Crea flash de boca
func _create_muzzle_flash(attacker: Node3D) -> void:
	if ParticleEffects:
		ParticleEffects.create_muzzle_flash(attacker.global_position)

## Aplica shake de cámara
func _apply_camera_shake(_intensity: float) -> void:
	# TODO: Implementar shake de cámara
	pass

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# LOG DE COMBATE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Registra evento de combate
func _log_combat_event(event: Dictionary) -> void:
	combat_log.append(event)
	if combat_log.size() > max_log_entries:
		combat_log.remove_at(0)

## Obtiene el log de combate
func get_combat_log() -> Array[Dictionary]:
	return combat_log.duplicate()

## Limpia el log
func clear_combat_log() -> void:
	combat_log.clear()
