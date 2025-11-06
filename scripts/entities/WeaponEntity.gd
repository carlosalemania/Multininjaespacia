extends Node3D
class_name WeaponEntity
## Entidad de un arma en el mundo (drop, pickup, display)

## Señales
signal picked_up(weapon_data: WeaponData, picker: Node)
signal dropped(weapon_data: WeaponData, position: Vector3)

## Datos del arma
var weapon_data: WeaponData
var current_durability: int = 0
var is_pickup: bool = true
var is_equipped: bool = false

## Referencias
var model_root: Node3D
var collision_shape: CollisionShape3D
var area: Area3D
var label: Label3D

## Animación
var rotate_speed: float = 45.0  # Grados por segundo
var bob_speed: float = 2.0
var bob_amount: float = 0.2
var initial_y: float = 0.0
var time: float = 0.0

func _ready() -> void:
	initial_y = position.y
	if weapon_data and is_pickup:
		_setup_pickup()

## Inicializa el arma
func initialize(data: WeaponData, as_pickup: bool = true, durability: int = -1) -> void:
	weapon_data = data
	is_pickup = as_pickup
	current_durability = durability if durability >= 0 else weapon_data.max_durability

	# Generar modelo 3D
	_generate_model()

	# Configurar como pickup si aplica
	if is_pickup:
		_setup_pickup()

func _process(delta: float) -> void:
	if not is_pickup:
		return

	time += delta

	# Rotación
	rotation_degrees.y += rotate_speed * delta

	# Bobbing (flotación)
	position.y = initial_y + sin(time * bob_speed) * bob_amount

## Genera el modelo 3D del arma
func _generate_model() -> void:
	if not weapon_data:
		return

	# Usar el generador de modelos
	model_root = WeaponModelGenerator.generate_weapon(weapon_data)
	model_root.name = "Model"
	add_child(model_root)

	# Aplicar escala
	model_root.scale = weapon_data.model_scale * 0.8  # Slightly smaller cuando está en el suelo

## Configura el arma como pickup
func _setup_pickup() -> void:
	# Área de detección
	area = Area3D.new()
	area.name = "PickupArea"
	area.collision_layer = 0
	area.collision_mask = 2  # Capa del jugador
	add_child(area)

	var shape = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 1.0
	shape.shape = sphere
	area.add_child(shape)

	area.body_entered.connect(_on_body_entered)

	# Etiqueta flotante
	_create_label()

	# Efecto de brillo si es raro+
	if weapon_data.tier >= WeaponData.WeaponTier.RARE:
		_create_glow_effect()

## Crea la etiqueta flotante
func _create_label() -> void:
	label = Label3D.new()
	label.name = "Label"
	label.text = weapon_data.weapon_name
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.font_size = 24
	label.outline_size = 4
	label.modulate = weapon_data.get_tier_color()
	label.position = Vector3(0, 1.5, 0)
	add_child(label)

## Crea efecto de brillo para armas raras
func _create_glow_effect() -> void:
	var particles = GPUParticles3D.new()
	particles.name = "GlowParticles"
	particles.amount = 10
	particles.lifetime = 2.0
	particles.explosiveness = 0.0

	var particle_mat = ParticleProcessMaterial.new()
	particle_mat.direction = Vector3(0, 1, 0)
	particle_mat.spread = 45.0
	particle_mat.initial_velocity_min = 0.2
	particle_mat.initial_velocity_max = 0.5
	particle_mat.gravity = Vector3(0, 0.5, 0)
	particle_mat.scale_min = 0.05
	particle_mat.scale_max = 0.1
	particle_mat.color = weapon_data.get_tier_color()

	particles.process_material = particle_mat

	var sphere = SphereMesh.new()
	sphere.radius = 0.03
	particles.draw_pass_1 = sphere

	add_child(particles)

	# Luz
	var light = OmniLight3D.new()
	light.light_color = weapon_data.get_tier_color()
	light.light_energy = 0.5
	light.omni_range = 2.0
	add_child(light)

## Callback cuando un cuerpo entra en el área
func _on_body_entered(body: Node3D) -> void:
	if not is_pickup:
		return

	# Verificar si es el jugador
	if body.is_in_group("player") or body.name == "Player":
		pickup(body)

## Recoge el arma
func pickup(picker: Node) -> void:
	if not is_pickup:
		return

	# Añadir al inventario del jugador
	if picker.has_method("add_weapon"):
		picker.add_weapon(weapon_data, current_durability)
	elif PlayerData:
		# Guardar en PlayerData si no tiene método directo
		if not PlayerData.has("weapons"):
			PlayerData.set("weapons", [])
		PlayerData.weapons.append({
			"weapon_id": weapon_data.weapon_id,
			"durability": current_durability
		})

	# Efecto visual
	_create_pickup_effect()

	# Sonido
	if AudioManager:
		AudioManager.play_sound("item_pickup")

	# Logro
	if AchievementSystem:
		AchievementSystem.increment_stat("weapons_collected", 1)

		# Logros especiales para armas legendarias/míticas
		if weapon_data.tier >= WeaponData.WeaponTier.LEGENDARY:
			if VirtueSystem:
				VirtueSystem.add_luz_manual(100, "Obtener arma legendaria: " + weapon_data.weapon_name)

	# Mensaje al jugador
	_show_pickup_message()

	# Emitir señal
	picked_up.emit(weapon_data, picker)

	# Destruir
	queue_free()

## Dropea el arma en una posición
static func drop_weapon(weapon_id: String, world_position: Vector3, parent: Node, durability: int = -1) -> WeaponEntity:
	var weapon_data = WeaponSystem.get_weapon(weapon_id)
	if not weapon_data:
		push_error("Arma no encontrada: " + weapon_id)
		return null

	var weapon_entity = WeaponEntity.new()
	weapon_entity.initialize(weapon_data, true, durability)
	weapon_entity.position = world_position
	parent.add_child(weapon_entity)

	# Impulso aleatorio
	var impulse = Vector3(randf_range(-2, 2), 5, randf_range(-2, 2))
	weapon_entity.velocity = impulse

	weapon_entity.dropped.emit(weapon_data, world_position)

	return weapon_entity

## Para aplicar física de drop
var velocity: Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	if velocity.length() > 0.1:
		# Aplicar gravedad
		velocity.y -= 9.8 * delta

		# Mover
		position += velocity * delta

		# Fricción
		velocity.x *= 0.95
		velocity.z *= 0.95

		# Detener si toca el suelo
		if position.y <= 0.5:
			position.y = 0.5
			velocity = Vector3.ZERO

## Crea efecto de pickup
func _create_pickup_effect() -> void:
	if ParticleEffects:
		ParticleEffects.create_sparkle_effect(global_position)

## Muestra mensaje de pickup
func _show_pickup_message() -> void:
	var tier_name = weapon_data.get_tier_name()
	var message = "Obtenido: " + weapon_data.icon + " " + weapon_data.weapon_name + " (" + tier_name + ")"
	print(message)
	# TODO: Mostrar en UI

## Equipa el arma (para renderizado en primera persona)
func equip(hand_position: Node3D) -> void:
	is_pickup = false
	is_equipped = true

	# Remover componentes de pickup
	if area:
		area.queue_free()
		area = null

	if label:
		label.queue_free()
		label = null

	# Posicionar en la mano
	if hand_position:
		reparent(hand_position)
		position = Vector3.ZERO
		rotation = Vector3.ZERO

	# Ajustar escala para primera persona
	if model_root:
		model_root.scale = weapon_data.model_scale

## Desequipa el arma
func unequip() -> void:
	is_equipped = false
	if model_root:
		model_root.visible = false

## Muestra el arma
func show_weapon() -> void:
	if model_root:
		model_root.visible = true

## Oculta el arma
func hide_weapon() -> void:
	if model_root:
		model_root.visible = false

## Obtiene información del arma
func get_info() -> String:
	if not weapon_data:
		return "Arma desconocida"

	return weapon_data.get_full_description() + "\n\nDurabilidad: " + str(current_durability) + "/" + str(weapon_data.max_durability)

## Repara el arma
func repair(amount: int) -> void:
	current_durability = min(current_durability + amount, weapon_data.max_durability)

## Reduce la durabilidad
func damage_durability(amount: int = 1) -> bool:
	current_durability -= amount
	if current_durability <= 0:
		_break_weapon()
		return true  # Rota
	return false

## Rompe el arma
func _break_weapon() -> void:
	# Efecto de rotura
	if ParticleEffects:
		ParticleEffects.create_break_effect(global_position)

	# Sonido
	if AudioManager:
		AudioManager.play_sound("weapon_break")

	# Mensaje
	print("¡" + weapon_data.weapon_name + " se ha roto!")

	# Si está equipada, desequipar
	if is_equipped:
		WeaponSystem.unequip_weapon()

	queue_free()

## Serializa el arma para guardado
func serialize() -> Dictionary:
	return {
		"weapon_id": weapon_data.weapon_id,
		"durability": current_durability,
		"position": {
			"x": position.x,
			"y": position.y,
			"z": position.z
		}
	}

## Deserializa el arma desde datos guardados
static func deserialize(data: Dictionary, parent: Node) -> WeaponEntity:
	var weapon_data = WeaponSystem.get_weapon(data.weapon_id)
	if not weapon_data:
		return null

	var weapon_entity = WeaponEntity.new()
	weapon_entity.initialize(weapon_data, true, data.durability)

	if data.has("position"):
		var pos = data.position
		weapon_entity.position = Vector3(pos.x, pos.y, pos.z)

	parent.add_child(weapon_entity)

	return weapon_entity
