# ============================================================================
# ParticleEffects.gd - Sistema de Partículas y Efectos Visuales
# ============================================================================
# Efectos visuales épicos para herramientas, crafteo, logros y magia
# ============================================================================

extends Node
class_name ParticleEffects

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# EFECTOS DE HERRAMIENTAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Crea partículas al romper bloque con herramienta
static func create_tool_break_effect(world: Node3D, position: Vector3, tool_type, block_type) -> void:
	var particles = GPUParticles3D.new()
	particles.position = position
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 0.8
	particles.amount = 20
	particles.lifetime = 1.0

	# Material de partículas
	var material = ParticleProcessMaterial.new()

	# Color según herramienta
	var tool_color = MagicTool.get_particle_color(tool_type)
	material.color = tool_color

	# Física
	material.gravity = Vector3(0, -9.8, 0)
	material.initial_velocity_min = 2.0
	material.initial_velocity_max = 5.0
	material.spread = 45.0
	material.scale_min = 0.1
	material.scale_max = 0.3

	# Fade out
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 1, 1, 1))
	gradient.add_point(1.0, Color(1, 1, 1, 0))
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture

	particles.process_material = material

	# Mesh (cubo pequeño)
	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.1, 0.1, 0.1)
	particles.draw_pass_1 = mesh

	world.add_child(particles)

	# Auto-destruir después de 2 segundos
	await world.get_tree().create_timer(2.0).timeout
	particles.queue_free()


## Crea brillo continuo alrededor de herramienta
static func create_tool_glow(tool_type) -> OmniLight3D:
	var light = OmniLight3D.new()
	light.name = "ToolGlow"

	var glow_color = MagicTool.get_glow_color(tool_type)
	light.light_color = glow_color
	light.light_energy = 0.5
	light.omni_range = 3.0
	light.omni_attenuation = 2.0

	return light


## Efecto de trail mágico al mover herramienta
static func create_magic_trail(world: Node3D, start_pos: Vector3, end_pos: Vector3, tool_type) -> void:
	var particles = GPUParticles3D.new()
	particles.position = start_pos
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 10
	particles.lifetime = 0.5

	var material = ParticleProcessMaterial.new()
	material.color = MagicTool.get_particle_color(tool_type)
	material.gravity = Vector3.ZERO
	material.initial_velocity_min = 0.0
	material.initial_velocity_max = 0.0

	# Fade rápido
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 1, 1, 0.8))
	gradient.add_point(1.0, Color(1, 1, 1, 0))
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture

	particles.process_material = material

	var mesh = SphereMesh.new()
	mesh.radius = 0.05
	mesh.height = 0.1
	particles.draw_pass_1 = mesh

	world.add_child(particles)

	await world.get_tree().create_timer(1.0).timeout
	particles.queue_free()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# EFECTOS DE HABILIDADES ESPECIALES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Efecto de explosión para Martillo del Trueno
static func create_thunder_explosion(world: Node3D, position: Vector3) -> void:
	# Partículas amarillas eléctricas
	var particles = GPUParticles3D.new()
	particles.position = position
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 50
	particles.lifetime = 0.5

	var material = ParticleProcessMaterial.new()
	material.color = Color(1.0, 1.0, 0.3)  # Amarillo eléctrico
	material.gravity = Vector3.ZERO
	material.initial_velocity_min = 5.0
	material.initial_velocity_max = 10.0
	material.spread = 180.0

	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 1, 1, 1))
	gradient.add_point(1.0, Color(1, 1, 1, 0))
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture

	particles.process_material = material

	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.1, 0.1, 0.1)
	particles.draw_pass_1 = mesh

	world.add_child(particles)

	# Flash de luz
	var light = OmniLight3D.new()
	light.position = position
	light.light_color = Color(1.0, 1.0, 0.5)
	light.light_energy = 3.0
	light.omni_range = 10.0
	world.add_child(light)

	# Fade out de luz
	var tween = world.create_tween()
	tween.tween_property(light, "light_energy", 0.0, 0.5)

	await world.get_tree().create_timer(1.0).timeout
	particles.queue_free()
	light.queue_free()


## Efecto de transmutación (Varita Mágica)
static func create_transmute_effect(world: Node3D, position: Vector3) -> void:
	# Partículas púrpuras girando
	var particles = GPUParticles3D.new()
	particles.position = position
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 30
	particles.lifetime = 1.0

	var material = ParticleProcessMaterial.new()
	material.color = Color(0.8, 0.3, 1.0)  # Púrpura mágico
	material.gravity = Vector3(0, 2.0, 0)  # Sube
	material.initial_velocity_min = 1.0
	material.initial_velocity_max = 2.0
	material.spread = 45.0

	# Rotación
	material.angular_velocity_min = -180.0
	material.angular_velocity_max = 180.0

	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 1, 1, 1))
	gradient.add_point(1.0, Color(1, 1, 1, 0))
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture

	particles.process_material = material

	var mesh = SphereMesh.new()
	mesh.radius = 0.1
	particles.draw_pass_1 = mesh

	world.add_child(particles)

	await world.get_tree().create_timer(2.0).timeout
	particles.queue_free()


## Efecto de congelación (Hacha de Hielo)
static func create_freeze_effect(world: Node3D, position: Vector3) -> void:
	# Partículas azules cristalinas
	var particles = GPUParticles3D.new()
	particles.position = position
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 40
	particles.lifetime = 1.0

	var material = ParticleProcessMaterial.new()
	material.color = Color(0.5, 0.8, 1.0)  # Azul hielo
	material.gravity = Vector3(0, -5.0, 0)
	material.initial_velocity_min = 2.0
	material.initial_velocity_max = 4.0
	material.spread = 60.0

	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 1, 1, 1))
	gradient.add_point(1.0, Color(1, 1, 1, 0))
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture

	particles.process_material = material

	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.05, 0.2, 0.05)  # Cristales de hielo
	particles.draw_pass_1 = mesh

	world.add_child(particles)

	await world.get_tree().create_timer(2.0).timeout
	particles.queue_free()


## Efecto de teletransporte
static func create_teleport_effect(world: Node3D, position: Vector3) -> void:
	# Partículas turquesas en espiral
	var particles = GPUParticles3D.new()
	particles.position = position
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 50
	particles.lifetime = 0.8

	var material = ParticleProcessMaterial.new()
	material.color = Color(0.0, 1.0, 0.8)  # Turquesa
	material.gravity = Vector3(0, 5.0, 0)  # Sube rápido
	material.initial_velocity_min = 3.0
	material.initial_velocity_max = 6.0
	material.spread = 30.0

	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 1, 1, 1))
	gradient.add_point(1.0, Color(1, 1, 1, 0))
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture

	particles.process_material = material

	var mesh = SphereMesh.new()
	mesh.radius = 0.08
	particles.draw_pass_1 = mesh

	world.add_child(particles)

	await world.get_tree().create_timer(1.5).timeout
	particles.queue_free()


## Efecto de deformación de realidad (Guantelete Infinito)
static func create_reality_warp_effect(world: Node3D, position: Vector3) -> void:
	# Múltiples colores cambiantes
	var particles = GPUParticles3D.new()
	particles.position = position
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 0.9
	particles.amount = 100
	particles.lifetime = 2.0

	var material = ParticleProcessMaterial.new()
	material.color = Color(0.5, 0.0, 1.0)  # Púrpura cósmico
	material.gravity = Vector3.ZERO
	material.initial_velocity_min = 8.0
	material.initial_velocity_max = 15.0
	material.spread = 180.0

	# Colores que cambian
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1.0, 0.3, 1.0, 1))  # Rosa
	gradient.add_point(0.5, Color(0.3, 0.8, 1.0, 1))  # Azul
	gradient.add_point(1.0, Color(1.0, 1.0, 0.3, 0))  # Amarillo fade
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture

	particles.process_material = material

	var mesh = SphereMesh.new()
	mesh.radius = 0.15
	particles.draw_pass_1 = mesh

	world.add_child(particles)

	# Luz cósmica pulsante
	var light = OmniLight3D.new()
	light.position = position
	light.light_color = Color(0.5, 0.0, 1.0)
	light.light_energy = 5.0
	light.omni_range = 15.0
	world.add_child(light)

	var tween = world.create_tween()
	tween.tween_property(light, "light_energy", 0.0, 2.0)

	await world.get_tree().create_timer(3.0).timeout
	particles.queue_free()
	light.queue_free()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# EFECTOS DE CRAFTEO
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Efecto al craftear exitosamente
static func create_craft_success_effect(world: Node3D, position: Vector3, tier: String) -> void:
	var tier_colors = {
		"common": Color(0.6, 0.6, 0.6),
		"uncommon": Color(0.3, 0.8, 0.3),
		"rare": Color(0.3, 0.6, 1.0),
		"epic": Color(0.7, 0.3, 1.0),
		"legendary": Color(1.0, 0.6, 0.0),
		"divine": Color(1.0, 0.2, 0.2)
	}

	var particles = GPUParticles3D.new()
	particles.position = position
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 30
	particles.lifetime = 1.5

	var material = ParticleProcessMaterial.new()
	material.color = tier_colors.get(tier, Color.WHITE)
	material.gravity = Vector3(0, 1.0, 0)
	material.initial_velocity_min = 2.0
	material.initial_velocity_max = 4.0
	material.spread = 45.0

	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 1, 1, 1))
	gradient.add_point(1.0, Color(1, 1, 1, 0))
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture

	particles.process_material = material

	var mesh = SphereMesh.new()
	mesh.radius = 0.1
	particles.draw_pass_1 = mesh

	world.add_child(particles)

	await world.get_tree().create_timer(2.0).timeout
	particles.queue_free()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# EFECTOS DE LOGROS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Efecto al desbloquear logro
static func create_achievement_effect(world: Node3D, position: Vector3, tier: String) -> void:
	var tier_colors = {
		"bronze": Color(0.8, 0.5, 0.2),
		"silver": Color(0.75, 0.75, 0.75),
		"gold": Color(1.0, 0.84, 0.0),
		"diamond": Color(0.4, 0.8, 1.0)
	}

	# Explosión de partículas
	var particles = GPUParticles3D.new()
	particles.position = position + Vector3(0, 1, 0)
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 0.7
	particles.amount = 50
	particles.lifetime = 2.0

	var material = ParticleProcessMaterial.new()
	material.color = tier_colors.get(tier, Color.YELLOW)
	material.gravity = Vector3(0, -2.0, 0)
	material.initial_velocity_min = 5.0
	material.initial_velocity_max = 10.0
	material.spread = 180.0

	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 1, 1, 1))
	gradient.add_point(1.0, Color(1, 1, 1, 0))
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture

	particles.process_material = material

	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.1, 0.1, 0.1)
	particles.draw_pass_1 = mesh

	world.add_child(particles)

	# Luz brillante
	var light = OmniLight3D.new()
	light.position = position + Vector3(0, 1, 0)
	light.light_color = tier_colors.get(tier, Color.YELLOW)
	light.light_energy = 2.0
	light.omni_range = 8.0
	world.add_child(light)

	var tween = world.create_tween()
	tween.tween_property(light, "light_energy", 0.0, 2.0)

	await world.get_tree().create_timer(3.0).timeout
	particles.queue_free()
	light.queue_free()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# EFECTOS AMBIENTALES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Efecto de ganancia de Luz Interior
static func create_luz_gain_effect(world: Node3D, position: Vector3) -> void:
	var particles = GPUParticles3D.new()
	particles.position = position
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 20
	particles.lifetime = 1.5

	var material = ParticleProcessMaterial.new()
	material.color = Color(1.0, 1.0, 0.7)  # Luz dorada
	material.gravity = Vector3(0, 3.0, 0)  # Sube
	material.initial_velocity_min = 1.0
	material.initial_velocity_max = 2.0
	material.spread = 20.0

	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 1, 1, 1))
	gradient.add_point(1.0, Color(1, 1, 1, 0))
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture

	particles.process_material = material

	var mesh = SphereMesh.new()
	mesh.radius = 0.08
	particles.draw_pass_1 = mesh

	world.add_child(particles)

	await world.get_tree().create_timer(2.0).timeout
	particles.queue_free()


## Efecto de colocación de bloque
static func create_block_place_effect(world: Node3D, position: Vector3, block_color: Color) -> void:
	var particles = GPUParticles3D.new()
	particles.position = position
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 10
	particles.lifetime = 0.5

	var material = ParticleProcessMaterial.new()
	material.color = block_color
	material.gravity = Vector3(0, -9.8, 0)
	material.initial_velocity_min = 1.0
	material.initial_velocity_max = 3.0
	material.spread = 45.0
	material.scale_min = 0.05
	material.scale_max = 0.1

	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 1, 1, 0.8))
	gradient.add_point(1.0, Color(1, 1, 1, 0))
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture

	particles.process_material = material

	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.05, 0.05, 0.05)
	particles.draw_pass_1 = mesh

	world.add_child(particles)

	await world.get_tree().create_timer(1.0).timeout
	particles.queue_free()
