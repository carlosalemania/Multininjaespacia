extends Node3D
class_name Projectile
## Proyectil de arma a distancia

## Señales
signal hit_target(target: Node3D, damage: float)
signal hit_terrain(position: Vector3)
signal projectile_destroyed

## Configuración
var weapon_data: WeaponData
var direction: Vector3 = Vector3.FORWARD
var shooter: Node3D = null
var speed: float = 30.0
var damage: float = 10.0
var gravity_enabled: bool = true
var max_lifetime: float = 10.0
var pierce_count: int = 0  # Cuántos enemigos puede atravesar

## Estado
var velocity: Vector3 = Vector3.ZERO
var lifetime: float = 0.0
var has_hit: bool = false
var hit_count: int = 0

## Referencias
var mesh_instance: MeshInstance3D
var light: OmniLight3D
var trail: GPUParticles3D
var area: Area3D

func _ready() -> void:
	_setup_collision()
	_setup_visuals()

## Inicializa el proyectil
func initialize(weapon: WeaponData, dir: Vector3, from: Node3D) -> void:
	weapon_data = weapon
	direction = dir.normalized()
	shooter = from
	speed = weapon.projectile_speed
	damage = weapon.base_damage
	gravity_enabled = weapon.projectile_gravity

	# Configurar velocidad inicial
	velocity = direction * speed

	# Orientar hacia la dirección
	look_at(global_position + direction, Vector3.UP)

func _physics_process(delta: float) -> void:
	if has_hit:
		return

	# Actualizar lifetime
	lifetime += delta
	if lifetime >= max_lifetime:
		_destroy()
		return

	# Aplicar gravedad
	if gravity_enabled:
		velocity.y -= 9.8 * delta

	# Mover proyectil
	var motion = velocity * delta
	global_position += motion

	# Orientar hacia la dirección de movimiento
	if velocity.length() > 0.1:
		look_at(global_position + velocity.normalized(), Vector3.UP)

	# Raycast para detectar colisiones
	_check_collision(motion)

## Configura el área de colisión
func _setup_collision() -> void:
	area = Area3D.new()
	area.collision_layer = 0
	area.collision_mask = 3  # Capa 1 (enemigos) y 2 (terreno)
	add_child(area)

	var shape = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 0.1
	shape.shape = sphere
	area.add_child(shape)

	area.body_entered.connect(_on_body_entered)
	area.area_entered.connect(_on_area_entered)

## Configura los visuales del proyectil
func _setup_visuals() -> void:
	if not weapon_data:
		_create_default_projectile()
		return

	match weapon_data.weapon_type:
		WeaponData.WeaponType.BOW:
			_create_arrow()
		WeaponData.WeaponType.CROSSBOW:
			_create_bolt()
		WeaponData.WeaponType.GUN:
			_create_bullet()
		WeaponData.WeaponType.MAGIC_STAFF:
			_create_magic_projectile()
		_:
			_create_default_projectile()

	# Trail de partículas
	if weapon_data.has_trail:
		_create_trail()

	# Luz si es mágico
	if weapon_data.damage_type == WeaponData.DamageType.MAGIC or weapon_data.has_glow:
		_create_light()

## Crea una flecha
func _create_arrow() -> void:
	mesh_instance = MeshInstance3D.new()
	var mesh = CylinderMesh.new()
	mesh.top_radius = 0.01
	mesh.bottom_radius = 0.01
	mesh.height = 0.5
	mesh_instance.mesh = mesh

	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.6, 0.4, 0.2)
	mesh_instance.material_override = mat

	mesh_instance.rotation_degrees = Vector3(90, 0, 0)
	add_child(mesh_instance)

	# Punta
	var tip = MeshInstance3D.new()
	var tip_mesh = BoxMesh.new()
	tip_mesh.size = Vector3(0.02, 0.1, 0.02)
	tip.mesh = tip_mesh

	var tip_mat = StandardMaterial3D.new()
	tip_mat.albedo_color = Color.GRAY
	tip_mat.metallic = 0.8
	tip.material_override = tip_mat

	tip.position = Vector3(0, 0.3, 0)
	add_child(tip)

## Crea una saeta de ballesta
func _create_bolt() -> void:
	mesh_instance = MeshInstance3D.new()
	var mesh = CylinderMesh.new()
	mesh.top_radius = 0.015
	mesh.bottom_radius = 0.015
	mesh.height = 0.4
	mesh_instance.mesh = mesh

	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.5, 0.3, 0.2)
	mesh_instance.material_override = mat

	mesh_instance.rotation_degrees = Vector3(90, 0, 0)
	add_child(mesh_instance)

## Crea una bala
func _create_bullet() -> void:
	mesh_instance = MeshInstance3D.new()
	var mesh = SphereMesh.new()
	mesh.radius = 0.05
	mesh_instance.mesh = mesh

	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.YELLOW
	mat.metallic = 1.0
	mat.roughness = 0.2
	mesh_instance.material_override = mat

	add_child(mesh_instance)

## Crea un proyectil mágico
func _create_magic_projectile() -> void:
	mesh_instance = MeshInstance3D.new()
	var mesh = SphereMesh.new()
	mesh.radius = 0.15
	mesh_instance.mesh = mesh

	var mat = StandardMaterial3D.new()
	mat.albedo_color = weapon_data.secondary_color if weapon_data else Color.MAGENTA
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.7
	mat.emission_enabled = true
	mat.emission = weapon_data.glow_color if weapon_data else Color.MAGENTA
	mat.emission_energy_multiplier = 2.0
	mesh_instance.material_override = mat

	add_child(mesh_instance)

## Crea proyectil por defecto
func _create_default_projectile() -> void:
	mesh_instance = MeshInstance3D.new()
	var mesh = SphereMesh.new()
	mesh.radius = 0.1
	mesh_instance.mesh = mesh

	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.WHITE
	mesh_instance.material_override = mat

	add_child(mesh_instance)

## Crea trail de partículas
func _create_trail() -> void:
	trail = GPUParticles3D.new()
	trail.amount = 20
	trail.lifetime = 0.5
	trail.explosiveness = 0.0

	var particle_mat = ParticleProcessMaterial.new()
	particle_mat.direction = -direction
	particle_mat.spread = 5.0
	particle_mat.initial_velocity_min = 0.5
	particle_mat.initial_velocity_max = 1.0
	particle_mat.gravity = Vector3.ZERO
	particle_mat.scale_min = 0.05
	particle_mat.scale_max = 0.1
	particle_mat.color = weapon_data.trail_color if weapon_data else Color.WHITE

	trail.process_material = particle_mat

	var sphere = SphereMesh.new()
	sphere.radius = 0.03
	trail.draw_pass_1 = sphere

	add_child(trail)

## Crea luz
func _create_light() -> void:
	light = OmniLight3D.new()
	light.light_color = weapon_data.glow_color if weapon_data else Color.WHITE
	light.light_energy = 1.5
	light.omni_range = 3.0
	add_child(light)

## Verifica colisiones con raycast
func _check_collision(motion: Vector3) -> void:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position - motion,
		global_position
	)
	query.collision_mask = 3
	query.exclude = [shooter] if shooter else []

	var result = space_state.intersect_ray(query)
	if result:
		_on_collision(result)

## Callback de colisión con Body
func _on_body_entered(body: Node3D) -> void:
	if body == shooter:
		return

	if has_hit and pierce_count <= 0:
		return

	_handle_hit(body)

## Callback de colisión con Area
func _on_area_entered(area: Area3D) -> void:
	var body = area.get_parent()
	if body == shooter:
		return

	if has_hit and pierce_count <= 0:
		return

	_handle_hit(body)

## Maneja colisión de raycast
func _on_collision(result: Dictionary) -> void:
	var collider = result.collider
	if collider == shooter:
		return

	_handle_hit(collider, result.position)

## Maneja el impacto
func _handle_hit(target: Node, hit_position: Vector3 = Vector3.ZERO) -> void:
	hit_count += 1

	# Verificar si es enemigo o terreno
	if target.is_in_group("enemies") or target.has_method("take_damage"):
		# Golpe a enemigo
		_hit_enemy(target)

		# Si puede atravesar, continuar
		if hit_count <= pierce_count:
			return
	else:
		# Golpe a terreno
		_hit_terrain(hit_position if hit_position != Vector3.ZERO else global_position)

	has_hit = true
	_destroy()

## Golpea a un enemigo
func _hit_enemy(enemy: Node) -> void:
	# Aplicar daño usando CombatSystem
	if CombatSystem:
		var is_critical = weapon_data.roll_critical() if weapon_data else false
		var final_damage = damage * (weapon_data.critical_multiplier if is_critical else 1.0)

		CombatSystem.apply_damage(
			enemy,
			final_damage,
			weapon_data.damage_type if weapon_data else WeaponData.DamageType.PHYSICAL,
			shooter
		)

		# Knockback
		if weapon_data and weapon_data.knockback > 0:
			CombatSystem.apply_knockback(enemy, self, weapon_data.knockback * 0.5)

		# Efectos de estado
		if weapon_data:
			if weapon_data.apply_burn:
				CombatSystem.apply_burn_effect(enemy, weapon_data.burn_damage_per_second, weapon_data.burn_duration)
			if weapon_data.apply_freeze:
				CombatSystem.apply_freeze_effect(enemy, weapon_data.freeze_duration)
			if weapon_data.apply_poison:
				CombatSystem.apply_poison_effect(enemy, weapon_data.poison_damage_per_second, weapon_data.poison_duration)

	# Efectos de impacto
	_create_impact_effects(enemy.global_position if enemy is Node3D else global_position)

	# Señal
	hit_target.emit(enemy, damage)

## Golpea el terreno
func _hit_terrain(position: Vector3) -> void:
	_create_impact_effects(position)
	hit_terrain.emit(position)

## Crea efectos de impacto
func _create_impact_effects(position: Vector3) -> void:
	# Partículas
	if ParticleEffects:
		var color = weapon_data.hit_particle_color if weapon_data else Color.WHITE
		ParticleEffects.create_hit_effect(position, color)

	# Sonido
	if AudioManager and weapon_data:
		AudioManager.play_sound(weapon_data.hit_sound)

## Destruye el proyectil
func _destroy() -> void:
	projectile_destroyed.emit()

	# Mantener trail un poco más
	if trail:
		trail.emitting = false

	# Fade out
	if mesh_instance:
		var tween = create_tween()
		tween.tween_property(mesh_instance, "scale", Vector3.ZERO, 0.2)
		tween.tween_callback(queue_free)
	else:
		queue_free()
