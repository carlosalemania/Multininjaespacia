class_name WeaponModelGenerator
## Generador de modelos 3D procedurales para armas

## Genera el modelo 3D completo de un arma
static func generate_weapon(weapon_data: WeaponData) -> Node3D:
	match weapon_data.weapon_type:
		WeaponData.WeaponType.SWORD:
			return _generate_sword(weapon_data)
		WeaponData.WeaponType.AXE:
			return _generate_axe(weapon_data)
		WeaponData.WeaponType.DAGGER:
			return _generate_dagger(weapon_data)
		WeaponData.WeaponType.SPEAR:
			return _generate_spear(weapon_data)
		WeaponData.WeaponType.BOW:
			return _generate_bow(weapon_data)
		WeaponData.WeaponType.CROSSBOW:
			return _generate_crossbow(weapon_data)
		WeaponData.WeaponType.GUN:
			return _generate_gun(weapon_data)
		WeaponData.WeaponType.MAGIC_STAFF:
			return _generate_magic_staff(weapon_data)
		WeaponData.WeaponType.HAMMER:
			return _generate_hammer(weapon_data)
		WeaponData.WeaponType.SCYTHE:
			return _generate_scythe(weapon_data)
		WeaponData.WeaponType.WHIP:
			return _generate_whip(weapon_data)
		WeaponData.WeaponType.TRIDENT:
			return _generate_trident(weapon_data)

	# Fallback: espada básica
	return _generate_sword(weapon_data)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ESPADAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

static func _generate_sword(weapon_data: WeaponData) -> Node3D:
	var root = Node3D.new()
	root.name = "Sword"

	# Hoja (blade)
	var blade = MeshInstance3D.new()
	blade.name = "Blade"
	blade.mesh = BoxMesh.new()
	blade.mesh.size = Vector3(0.1, 1.2, 0.02)

	var blade_mat = StandardMaterial3D.new()
	blade_mat.albedo_color = weapon_data.blade_color
	blade_mat.metallic = 0.8
	blade_mat.roughness = 0.2

	# Brillo mágico
	if weapon_data.has_glow:
		blade_mat.emission_enabled = true
		blade_mat.emission = weapon_data.glow_color
		blade_mat.emission_energy_multiplier = weapon_data.glow_intensity

	blade.material_override = blade_mat
	blade.position = Vector3(0, 0.7, 0)
	root.add_child(blade)

	# Guarda (crossguard)
	var guard = MeshInstance3D.new()
	guard.name = "Guard"
	guard.mesh = BoxMesh.new()
	guard.mesh.size = Vector3(0.4, 0.08, 0.08)

	var guard_mat = StandardMaterial3D.new()
	guard_mat.albedo_color = weapon_data.secondary_color
	guard_mat.metallic = 0.7
	guard_mat.roughness = 0.3

	guard.material_override = guard_mat
	guard.position = Vector3(0, 0.1, 0)
	root.add_child(guard)

	# Mango (handle)
	var handle = MeshInstance3D.new()
	handle.name = "Handle"
	handle.mesh = CylinderMesh.new()
	handle.mesh.top_radius = 0.04
	handle.mesh.bottom_radius = 0.04
	handle.mesh.height = 0.3

	var handle_mat = StandardMaterial3D.new()
	handle_mat.albedo_color = weapon_data.handle_color
	handle_mat.roughness = 0.7

	handle.material_override = handle_mat
	handle.position = Vector3(0, -0.05, 0)
	root.add_child(handle)

	# Pomo (pommel)
	var pommel = MeshInstance3D.new()
	pommel.name = "Pommel"
	pommel.mesh = SphereMesh.new()
	pommel.mesh.radius = 0.06
	pommel.mesh.height = 0.12

	var pommel_mat = StandardMaterial3D.new()
	pommel_mat.albedo_color = weapon_data.secondary_color
	pommel_mat.metallic = 0.6

	pommel.material_override = pommel_mat
	pommel.position = Vector3(0, -0.22, 0)
	root.add_child(pommel)

	# Añadir luz si tiene glow
	if weapon_data.has_glow:
		var light = OmniLight3D.new()
		light.light_color = weapon_data.glow_color
		light.light_energy = weapon_data.glow_intensity * 0.5
		light.omni_range = 2.0
		light.position = Vector3(0, 0.7, 0)
		root.add_child(light)

	return root

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HACHAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

static func _generate_axe(weapon_data: WeaponData) -> Node3D:
	var root = Node3D.new()
	root.name = "Axe"

	# Mango
	var handle = MeshInstance3D.new()
	handle.name = "Handle"
	handle.mesh = CylinderMesh.new()
	handle.mesh.top_radius = 0.05
	handle.mesh.bottom_radius = 0.06
	handle.mesh.height = 1.0

	var handle_mat = StandardMaterial3D.new()
	handle_mat.albedo_color = weapon_data.handle_color
	handle_mat.roughness = 0.8

	handle.material_override = handle_mat
	handle.position = Vector3(0, 0, 0)
	root.add_child(handle)

	# Cabeza del hacha (principal)
	var blade = MeshInstance3D.new()
	blade.name = "Blade"
	blade.mesh = BoxMesh.new()
	blade.mesh.size = Vector3(0.6, 0.4, 0.08)

	var blade_mat = StandardMaterial3D.new()
	blade_mat.albedo_color = weapon_data.blade_color
	blade_mat.metallic = 0.9
	blade_mat.roughness = 0.2

	blade.material_override = blade_mat
	blade.position = Vector3(0.2, 0.5, 0)
	blade.rotation_degrees = Vector3(0, 0, 15)
	root.add_child(blade)

	# Filo (edge) - más delgado
	var edge = MeshInstance3D.new()
	edge.name = "Edge"
	edge.mesh = BoxMesh.new()
	edge.mesh.size = Vector3(0.1, 0.35, 0.02)

	var edge_mat = StandardMaterial3D.new()
	edge_mat.albedo_color = Color.SILVER
	edge_mat.metallic = 1.0
	edge_mat.roughness = 0.1

	edge.material_override = edge_mat
	edge.position = Vector3(0.45, 0.5, 0)
	edge.rotation_degrees = Vector3(0, 0, 15)
	root.add_child(edge)

	# Refuerzo
	var backing = MeshInstance3D.new()
	backing.name = "Backing"
	backing.mesh = BoxMesh.new()
	backing.mesh.size = Vector3(0.2, 0.3, 0.06)

	var backing_mat = StandardMaterial3D.new()
	backing_mat.albedo_color = weapon_data.secondary_color
	backing_mat.metallic = 0.6

	backing.material_override = backing_mat
	backing.position = Vector3(-0.05, 0.5, 0)
	root.add_child(backing)

	return root

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DAGAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

static func _generate_dagger(weapon_data: WeaponData) -> Node3D:
	var root = Node3D.new()
	root.name = "Dagger"

	# Hoja (más corta y puntiaguda)
	var blade = MeshInstance3D.new()
	blade.name = "Blade"
	blade.mesh = BoxMesh.new()
	blade.mesh.size = Vector3(0.06, 0.5, 0.015)

	var blade_mat = StandardMaterial3D.new()
	blade_mat.albedo_color = weapon_data.blade_color
	blade_mat.metallic = 0.9
	blade_mat.roughness = 0.1

	blade.material_override = blade_mat
	blade.position = Vector3(0, 0.35, 0)
	root.add_child(blade)

	# Punta
	var tip = MeshInstance3D.new()
	tip.name = "Tip"
	tip.mesh = BoxMesh.new()
	tip.mesh.size = Vector3(0.04, 0.15, 0.01)

	tip.material_override = blade_mat
	tip.position = Vector3(0, 0.65, 0)
	root.add_child(tip)

	# Guarda pequeña
	var guard = MeshInstance3D.new()
	guard.name = "Guard"
	guard.mesh = BoxMesh.new()
	guard.mesh.size = Vector3(0.2, 0.04, 0.06)

	var guard_mat = StandardMaterial3D.new()
	guard_mat.albedo_color = weapon_data.secondary_color
	guard_mat.metallic = 0.7

	guard.material_override = guard_mat
	guard.position = Vector3(0, 0.1, 0)
	root.add_child(guard)

	# Mango (corto)
	var handle = MeshInstance3D.new()
	handle.name = "Handle"
	handle.mesh = CylinderMesh.new()
	handle.mesh.top_radius = 0.03
	handle.mesh.bottom_radius = 0.03
	handle.mesh.height = 0.2

	var handle_mat = StandardMaterial3D.new()
	handle_mat.albedo_color = weapon_data.handle_color
	handle_mat.roughness = 0.8

	handle.material_override = handle_mat
	handle.position = Vector3(0, 0, 0)
	root.add_child(handle)

	return root

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# LANZAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

static func _generate_spear(weapon_data: WeaponData) -> Node3D:
	var root = Node3D.new()
	root.name = "Spear"

	# Asta larga
	var shaft = MeshInstance3D.new()
	shaft.name = "Shaft"
	shaft.mesh = CylinderMesh.new()
	shaft.mesh.top_radius = 0.03
	shaft.mesh.bottom_radius = 0.04
	shaft.mesh.height = 1.8

	var shaft_mat = StandardMaterial3D.new()
	shaft_mat.albedo_color = weapon_data.handle_color
	shaft_mat.roughness = 0.7

	shaft.material_override = shaft_mat
	shaft.position = Vector3(0, 0, 0)
	root.add_child(shaft)

	# Punta de lanza
	var spearhead = MeshInstance3D.new()
	spearhead.name = "Spearhead"
	spearhead.mesh = BoxMesh.new()
	spearhead.mesh.size = Vector3(0.12, 0.4, 0.03)

	var spearhead_mat = StandardMaterial3D.new()
	spearhead_mat.albedo_color = weapon_data.blade_color
	spearhead_mat.metallic = 0.9
	spearhead_mat.roughness = 0.2

	spearhead.material_override = spearhead_mat
	spearhead.position = Vector3(0, 1.1, 0)
	root.add_child(spearhead)

	# Punta aguda
	var tip = MeshInstance3D.new()
	tip.name = "Tip"
	tip.mesh = BoxMesh.new()
	tip.mesh.size = Vector3(0.06, 0.2, 0.02)

	tip.material_override = spearhead_mat
	tip.position = Vector3(0, 1.35, 0)
	root.add_child(tip)

	# Conector metal
	var socket = MeshInstance3D.new()
	socket.name = "Socket"
	socket.mesh = CylinderMesh.new()
	socket.mesh.top_radius = 0.04
	socket.mesh.bottom_radius = 0.03
	socket.mesh.height = 0.15

	var socket_mat = StandardMaterial3D.new()
	socket_mat.albedo_color = weapon_data.secondary_color
	socket_mat.metallic = 0.7

	socket.material_override = socket_mat
	socket.position = Vector3(0, 0.9, 0)
	root.add_child(socket)

	return root

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ARCOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

static func _generate_bow(weapon_data: WeaponData) -> Node3D:
	var root = Node3D.new()
	root.name = "Bow"

	# Cuerpo del arco (superior)
	var limb_top = MeshInstance3D.new()
	limb_top.name = "LimbTop"
	limb_top.mesh = CylinderMesh.new()
	limb_top.mesh.top_radius = 0.02
	limb_top.mesh.bottom_radius = 0.03
	limb_top.mesh.height = 0.6

	var limb_mat = StandardMaterial3D.new()
	limb_mat.albedo_color = weapon_data.primary_color
	limb_mat.roughness = 0.6

	limb_top.material_override = limb_mat
	limb_top.position = Vector3(0, 0.55, 0)
	limb_top.rotation_degrees = Vector3(0, 0, -20)
	root.add_child(limb_top)

	# Cuerpo del arco (inferior)
	var limb_bottom = MeshInstance3D.new()
	limb_bottom.name = "LimbBottom"
	limb_bottom.mesh = CylinderMesh.new()
	limb_bottom.mesh.top_radius = 0.03
	limb_bottom.mesh.bottom_radius = 0.02
	limb_bottom.mesh.height = 0.6

	limb_bottom.material_override = limb_mat
	limb_bottom.position = Vector3(0, -0.55, 0)
	limb_bottom.rotation_degrees = Vector3(0, 0, 20)
	root.add_child(limb_bottom)

	# Empuñadura
	var grip = MeshInstance3D.new()
	grip.name = "Grip"
	grip.mesh = CylinderMesh.new()
	grip.mesh.top_radius = 0.04
	grip.mesh.bottom_radius = 0.04
	grip.mesh.height = 0.25

	var grip_mat = StandardMaterial3D.new()
	grip_mat.albedo_color = weapon_data.handle_color
	grip_mat.roughness = 0.8

	grip.material_override = grip_mat
	grip.position = Vector3(0, 0, 0)
	root.add_child(grip)

	# Cuerda
	var string = MeshInstance3D.new()
	string.name = "String"
	string.mesh = CylinderMesh.new()
	string.mesh.top_radius = 0.005
	string.mesh.bottom_radius = 0.005
	string.mesh.height = 1.4

	var string_mat = StandardMaterial3D.new()
	string_mat.albedo_color = Color(0.9, 0.9, 0.85)

	string.material_override = string_mat
	string.position = Vector3(-0.15, 0, 0)
	root.add_child(string)

	return root

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BALLESTAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

static func _generate_crossbow(weapon_data: WeaponData) -> Node3D:
	var root = Node3D.new()
	root.name = "Crossbow"

	# Cuerpo principal (stock)
	var stock = MeshInstance3D.new()
	stock.name = "Stock"
	stock.mesh = BoxMesh.new()
	stock.mesh.size = Vector3(0.08, 0.7, 0.06)

	var stock_mat = StandardMaterial3D.new()
	stock_mat.albedo_color = weapon_data.primary_color
	stock_mat.roughness = 0.7

	stock.material_override = stock_mat
	stock.position = Vector3(0, 0, 0)
	root.add_child(stock)

	# Arco horizontal
	var bow = MeshInstance3D.new()
	bow.name = "Bow"
	bow.mesh = BoxMesh.new()
	bow.mesh.size = Vector3(0.8, 0.08, 0.04)

	var bow_mat = StandardMaterial3D.new()
	bow_mat.albedo_color = weapon_data.handle_color
	bow_mat.roughness = 0.6

	bow.material_override = bow_mat
	bow.position = Vector3(0, 0.35, 0)
	root.add_child(bow)

	# Mecanismo de disparo
	var trigger = MeshInstance3D.new()
	trigger.name = "Trigger"
	trigger.mesh = BoxMesh.new()
	trigger.mesh.size = Vector3(0.08, 0.15, 0.15)

	var trigger_mat = StandardMaterial3D.new()
	trigger_mat.albedo_color = weapon_data.secondary_color
	trigger_mat.metallic = 0.7

	trigger.material_override = trigger_mat
	trigger.position = Vector3(0, -0.1, 0.05)
	root.add_child(trigger)

	# Riel de saeta
	var rail = MeshInstance3D.new()
	rail.name = "Rail"
	rail.mesh = BoxMesh.new()
	rail.mesh.size = Vector3(0.04, 0.4, 0.02)

	var rail_mat = StandardMaterial3D.new()
	rail_mat.albedo_color = weapon_data.secondary_color
	rail_mat.metallic = 0.8

	rail.material_override = rail_mat
	rail.position = Vector3(0, 0.15, 0)
	root.add_child(rail)

	return root

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ARMAS DE FUEGO
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

static func _generate_gun(weapon_data: WeaponData) -> Node3D:
	var root = Node3D.new()
	root.name = "Gun"

	# Determinar tipo de arma por ID
	var is_shotgun = "shotgun" in weapon_data.weapon_id

	# Cañón
	var barrel = MeshInstance3D.new()
	barrel.name = "Barrel"
	barrel.mesh = CylinderMesh.new()
	barrel.mesh.top_radius = 0.03 if not is_shotgun else 0.05
	barrel.mesh.bottom_radius = 0.03 if not is_shotgun else 0.05
	barrel.mesh.height = 0.4 if not is_shotgun else 0.6

	var barrel_mat = StandardMaterial3D.new()
	barrel_mat.albedo_color = weapon_data.primary_color
	barrel_mat.metallic = 0.9
	barrel_mat.roughness = 0.2

	barrel.material_override = barrel_mat
	barrel.position = Vector3(0, 0.2, 0)
	barrel.rotation_degrees = Vector3(90, 0, 0)
	root.add_child(barrel)

	# Cuerpo (slide/receiver)
	var body = MeshInstance3D.new()
	body.name = "Body"
	body.mesh = BoxMesh.new()
	body.mesh.size = Vector3(0.08, 0.25, 0.1)

	var body_mat = StandardMaterial3D.new()
	body_mat.albedo_color = weapon_data.secondary_color
	body_mat.metallic = 0.7
	body_mat.roughness = 0.3

	body.material_override = body_mat
	body.position = Vector3(0, 0, 0)
	root.add_child(body)

	# Empuñadura
	var grip = MeshInstance3D.new()
	grip.name = "Grip"
	grip.mesh = BoxMesh.new()
	grip.mesh.size = Vector3(0.06, 0.2, 0.08)

	var grip_mat = StandardMaterial3D.new()
	grip_mat.albedo_color = Color.BLACK
	grip_mat.roughness = 0.8

	grip.material_override = grip_mat
	grip.position = Vector3(0, -0.15, 0.02)
	grip.rotation_degrees = Vector3(15, 0, 0)
	root.add_child(grip)

	# Gatillo
	var trigger = MeshInstance3D.new()
	trigger.name = "Trigger"
	trigger.mesh = BoxMesh.new()
	trigger.mesh.size = Vector3(0.03, 0.06, 0.02)

	var trigger_mat = StandardMaterial3D.new()
	trigger_mat.albedo_color = Color.GRAY
	trigger_mat.metallic = 0.8

	trigger.material_override = trigger_mat
	trigger.position = Vector3(0, -0.08, 0.05)
	root.add_child(trigger)

	# Mira frontal
	var sight = MeshInstance3D.new()
	sight.name = "Sight"
	sight.mesh = BoxMesh.new()
	sight.mesh.size = Vector3(0.02, 0.04, 0.02)

	var sight_mat = StandardMaterial3D.new()
	sight_mat.albedo_color = Color.RED
	sight_mat.emission_enabled = true
	sight_mat.emission = Color.RED
	sight_mat.emission_energy_multiplier = 0.5

	sight.material_override = sight_mat
	sight.position = Vector3(0, 0.06, 0.3)
	root.add_child(sight)

	# Cargador (si es pistola)
	if not is_shotgun:
		var magazine = MeshInstance3D.new()
		magazine.name = "Magazine"
		magazine.mesh = BoxMesh.new()
		magazine.mesh.size = Vector3(0.05, 0.15, 0.06)

		magazine.material_override = body_mat
		magazine.position = Vector3(0, -0.25, 0.02)
		root.add_child(magazine)

	return root

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BÁCULOS MÁGICOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

static func _generate_magic_staff(weapon_data: WeaponData) -> Node3D:
	var root = Node3D.new()
	root.name = "MagicStaff"

	# Asta del báculo
	var shaft = MeshInstance3D.new()
	shaft.name = "Shaft"
	shaft.mesh = CylinderMesh.new()
	shaft.mesh.top_radius = 0.025
	shaft.mesh.bottom_radius = 0.035
	shaft.mesh.height = 1.5

	var shaft_mat = StandardMaterial3D.new()
	shaft_mat.albedo_color = weapon_data.primary_color
	shaft_mat.roughness = 0.5

	shaft.material_override = shaft_mat
	shaft.position = Vector3(0, 0, 0)
	root.add_child(shaft)

	# Cristal superior (grande)
	var crystal = MeshInstance3D.new()
	crystal.name = "Crystal"
	crystal.mesh = SphereMesh.new()
	crystal.mesh.radius = 0.12
	crystal.mesh.height = 0.24

	var crystal_mat = StandardMaterial3D.new()
	crystal_mat.albedo_color = weapon_data.secondary_color
	crystal_mat.metallic = 0.0
	crystal_mat.roughness = 0.0
	crystal_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	crystal_mat.albedo_color.a = 0.7
	crystal_mat.emission_enabled = true
	crystal_mat.emission = weapon_data.glow_color
	crystal_mat.emission_energy_multiplier = 2.0

	crystal.material_override = crystal_mat
	crystal.position = Vector3(0, 0.85, 0)
	root.add_child(crystal)

	# Anillos decorativos
	for i in range(3):
		var ring = MeshInstance3D.new()
		ring.name = "Ring" + str(i)
		ring.mesh = TorusMesh.new()
		ring.mesh.inner_radius = 0.03
		ring.mesh.outer_radius = 0.05

		var ring_mat = StandardMaterial3D.new()
		ring_mat.albedo_color = Color.GOLD
		ring_mat.metallic = 1.0
		ring_mat.roughness = 0.2
		ring_mat.emission_enabled = true
		ring_mat.emission = weapon_data.glow_color
		ring_mat.emission_energy_multiplier = 0.5

		ring.material_override = ring_mat
		ring.position = Vector3(0, 0.2 + i * 0.25, 0)
		ring.rotation_degrees = Vector3(90, 0, 0)
		root.add_child(ring)

	# Luz mágica
	var light = OmniLight3D.new()
	light.light_color = weapon_data.glow_color
	light.light_energy = 2.0
	light.omni_range = 3.0
	light.position = Vector3(0, 0.85, 0)
	root.add_child(light)

	# Partículas flotantes
	var particles = GPUParticles3D.new()
	particles.amount = 20
	particles.lifetime = 2.0
	particles.explosiveness = 0.0
	particles.randomness = 0.3

	# Process material
	var particle_mat = ParticleProcessMaterial.new()
	particle_mat.direction = Vector3(0, 1, 0)
	particle_mat.spread = 45.0
	particle_mat.initial_velocity_min = 0.2
	particle_mat.initial_velocity_max = 0.5
	particle_mat.gravity = Vector3(0, 0.1, 0)
	particle_mat.scale_min = 0.02
	particle_mat.scale_max = 0.05
	particle_mat.color = weapon_data.glow_color

	particles.process_material = particle_mat

	# Draw pass
	var sphere = SphereMesh.new()
	sphere.radius = 0.02
	particles.draw_pass_1 = sphere

	particles.position = Vector3(0, 0.85, 0)
	root.add_child(particles)

	return root

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MARTILLOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

static func _generate_hammer(weapon_data: WeaponData) -> Node3D:
	var root = Node3D.new()
	root.name = "Hammer"

	# Mango largo
	var handle = MeshInstance3D.new()
	handle.name = "Handle"
	handle.mesh = CylinderMesh.new()
	handle.mesh.top_radius = 0.04
	handle.mesh.bottom_radius = 0.05
	handle.mesh.height = 1.2

	var handle_mat = StandardMaterial3D.new()
	handle_mat.albedo_color = weapon_data.handle_color
	handle_mat.roughness = 0.7

	handle.material_override = handle_mat
	handle.position = Vector3(0, 0, 0)
	root.add_child(handle)

	# Cabeza del martillo (grande y cuadrada)
	var head = MeshInstance3D.new()
	head.name = "Head"
	head.mesh = BoxMesh.new()
	head.mesh.size = Vector3(0.35, 0.25, 0.25)

	var head_mat = StandardMaterial3D.new()
	head_mat.albedo_color = weapon_data.blade_color
	head_mat.metallic = 0.8
	head_mat.roughness = 0.4

	head.material_override = head_mat
	head.position = Vector3(0, 0.7, 0)
	root.add_child(head)

	# Pico trasero
	var spike = MeshInstance3D.new()
	spike.name = "Spike"
	spike.mesh = BoxMesh.new()
	spike.mesh.size = Vector3(0.25, 0.1, 0.1)

	spike.material_override = head_mat
	spike.position = Vector3(-0.25, 0.7, 0)
	root.add_child(spike)

	# Conexión
	var socket = MeshInstance3D.new()
	socket.name = "Socket"
	socket.mesh = CylinderMesh.new()
	socket.mesh.top_radius = 0.06
	socket.mesh.bottom_radius = 0.05
	socket.mesh.height = 0.15

	var socket_mat = StandardMaterial3D.new()
	socket_mat.albedo_color = weapon_data.secondary_color
	socket_mat.metallic = 0.7

	socket.material_override = socket_mat
	socket.position = Vector3(0, 0.6, 0)
	socket.rotation_degrees = Vector3(0, 0, 90)
	root.add_child(socket)

	return root

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# GUADAÑAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

static func _generate_scythe(weapon_data: WeaponData) -> Node3D:
	var root = Node3D.new()
	root.name = "Scythe"

	# Mango muy largo
	var handle = MeshInstance3D.new()
	handle.name = "Handle"
	handle.mesh = CylinderMesh.new()
	handle.mesh.top_radius = 0.03
	handle.mesh.bottom_radius = 0.04
	handle.mesh.height = 1.6

	var handle_mat = StandardMaterial3D.new()
	handle_mat.albedo_color = weapon_data.handle_color
	handle_mat.roughness = 0.7

	handle.material_override = handle_mat
	handle.position = Vector3(0, 0, 0)
	root.add_child(handle)

	# Hoja curva
	var blade = MeshInstance3D.new()
	blade.name = "Blade"
	blade.mesh = BoxMesh.new()
	blade.mesh.size = Vector3(0.8, 0.15, 0.02)

	var blade_mat = StandardMaterial3D.new()
	blade_mat.albedo_color = weapon_data.blade_color
	blade_mat.metallic = 0.9
	blade_mat.roughness = 0.1

	blade.material_override = blade_mat
	blade.position = Vector3(0.3, 0.9, 0)
	blade.rotation_degrees = Vector3(0, 0, -30)
	root.add_child(blade)

	# Conexión
	var neck = MeshInstance3D.new()
	neck.name = "Neck"
	neck.mesh = CylinderMesh.new()
	neck.mesh.top_radius = 0.025
	neck.mesh.bottom_radius = 0.035
	neck.mesh.height = 0.3

	var neck_mat = StandardMaterial3D.new()
	neck_mat.albedo_color = weapon_data.secondary_color
	neck_mat.metallic = 0.7

	neck.material_override = neck_mat
	neck.position = Vector3(0, 0.85, 0)
	neck.rotation_degrees = Vector3(0, 0, 60)
	root.add_child(neck)

	return root

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# LÁTIGOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

static func _generate_whip(weapon_data: WeaponData) -> Node3D:
	var root = Node3D.new()
	root.name = "Whip"

	# Mango
	var handle = MeshInstance3D.new()
	handle.name = "Handle"
	handle.mesh = CylinderMesh.new()
	handle.mesh.top_radius = 0.03
	handle.mesh.bottom_radius = 0.04
	handle.mesh.height = 0.3

	var handle_mat = StandardMaterial3D.new()
	handle_mat.albedo_color = weapon_data.handle_color
	handle_mat.roughness = 0.8

	handle.material_override = handle_mat
	handle.position = Vector3(0, -0.15, 0)
	root.add_child(handle)

	# Látigo en segmentos
	var whip_mat = StandardMaterial3D.new()
	whip_mat.albedo_color = weapon_data.primary_color
	whip_mat.roughness = 0.6

	for i in range(8):
		var segment = MeshInstance3D.new()
		segment.name = "Segment" + str(i)
		segment.mesh = CylinderMesh.new()
		var radius = 0.02 - (i * 0.002)
		segment.mesh.top_radius = radius
		segment.mesh.bottom_radius = radius + 0.002
		segment.mesh.height = 0.15

		segment.material_override = whip_mat
		segment.position = Vector3(0, 0.05 + i * 0.14, 0)
		segment.rotation_degrees = Vector3(0, 0, i * 3)  # Ligera curva
		root.add_child(segment)

	return root

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TRIDENTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

static func _generate_trident(weapon_data: WeaponData) -> Node3D:
	var root = Node3D.new()
	root.name = "Trident"

	# Asta
	var shaft = MeshInstance3D.new()
	shaft.name = "Shaft"
	shaft.mesh = CylinderMesh.new()
	shaft.mesh.top_radius = 0.03
	shaft.mesh.bottom_radius = 0.04
	shaft.mesh.height = 1.5

	var shaft_mat = StandardMaterial3D.new()
	shaft_mat.albedo_color = weapon_data.handle_color
	shaft_mat.roughness = 0.5

	shaft.material_override = shaft_mat
	shaft.position = Vector3(0, 0, 0)
	root.add_child(shaft)

	# Material de las puntas
	var prong_mat = StandardMaterial3D.new()
	prong_mat.albedo_color = weapon_data.blade_color
	prong_mat.metallic = 0.9
	prong_mat.roughness = 0.2

	if weapon_data.has_glow:
		prong_mat.emission_enabled = true
		prong_mat.emission = weapon_data.glow_color
		prong_mat.emission_energy_multiplier = 0.8

	# Punta central
	var prong_center = MeshInstance3D.new()
	prong_center.name = "ProngCenter"
	prong_center.mesh = BoxMesh.new()
	prong_center.mesh.size = Vector3(0.06, 0.4, 0.02)

	prong_center.material_override = prong_mat
	prong_center.position = Vector3(0, 0.95, 0)
	root.add_child(prong_center)

	# Punta izquierda
	var prong_left = MeshInstance3D.new()
	prong_left.name = "ProngLeft"
	prong_left.mesh = BoxMesh.new()
	prong_left.mesh.size = Vector3(0.05, 0.35, 0.02)

	prong_left.material_override = prong_mat
	prong_left.position = Vector3(-0.15, 0.88, 0)
	prong_left.rotation_degrees = Vector3(0, 0, -15)
	root.add_child(prong_left)

	# Punta derecha
	var prong_right = MeshInstance3D.new()
	prong_right.name = "ProngRight"
	prong_right.mesh = BoxMesh.new()
	prong_right.mesh.size = Vector3(0.05, 0.35, 0.02)

	prong_right.material_override = prong_mat
	prong_right.position = Vector3(0.15, 0.88, 0)
	prong_right.rotation_degrees = Vector3(0, 0, 15)
	root.add_child(prong_right)

	# Base de las puntas
	var base = MeshInstance3D.new()
	base.name = "Base"
	base.mesh = CylinderMesh.new()
	base.mesh.top_radius = 0.04
	base.mesh.bottom_radius = 0.03
	base.mesh.height = 0.1

	var base_mat = StandardMaterial3D.new()
	base_mat.albedo_color = weapon_data.secondary_color
	base_mat.metallic = 0.7

	base.material_override = base_mat
	base.position = Vector3(0, 0.7, 0)
	root.add_child(base)

	# Luz si tiene glow
	if weapon_data.has_glow:
		var light = OmniLight3D.new()
		light.light_color = weapon_data.glow_color
		light.light_energy = 1.0
		light.omni_range = 2.5
		light.position = Vector3(0, 0.95, 0)
		root.add_child(light)

	return root

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# UTILIDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Crea un material básico de metal
static func _create_metal_material(color: Color) -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = 0.8
	mat.roughness = 0.3
	return mat

## Crea un material básico de madera
static func _create_wood_material(color: Color) -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.7
	return mat
