extends Node
class_name MaterialLibrary
## Biblioteca de materiales mejorados para bloques con texturas procedurales

## Cache de materiales generados
static var material_cache: Dictionary = {}

## Generar o recuperar material para un tipo de bloque
static func get_material_for_block(block_type: Enums.BlockType) -> StandardMaterial3D:
	# Si ya existe en cache, devolverlo
	if block_type in material_cache:
		return material_cache[block_type]

	# Crear nuevo material
	var material = _create_material_for_block(block_type)
	material_cache[block_type] = material
	return material

## Crear material específico para cada tipo de bloque
static func _create_material_for_block(block_type: Enums.BlockType) -> StandardMaterial3D:
	var material = StandardMaterial3D.new()

	match block_type:
		Enums.BlockType.CESPED:
			# Césped verde vibrante con textura
			material.albedo_color = Color(0.35, 0.75, 0.25)
			material.roughness = 0.9
			material.metallic = 0.0
			material.albedo_texture = _generate_grass_texture()

		Enums.BlockType.TIERRA:
			# Tierra rica oscura
			material.albedo_color = Color(0.45, 0.28, 0.18)
			material.roughness = 0.95
			material.metallic = 0.0
			material.albedo_texture = _generate_dirt_texture()

		Enums.BlockType.PIEDRA:
			# Piedra gris azulada moderna
			material.albedo_color = Color(0.42, 0.44, 0.46)
			material.roughness = 0.85
			material.metallic = 0.1
			material.albedo_texture = _generate_stone_texture()

		Enums.BlockType.MADERA:
			# Madera de roble cálido
			material.albedo_color = Color(0.52, 0.37, 0.26)
			material.roughness = 0.9
			material.metallic = 0.0
			material.albedo_texture = _generate_wood_texture()

		Enums.BlockType.HOJAS:
			# Hojas verde bosque oscuro
			material.albedo_color = Color(0.2, 0.55, 0.15)
			material.roughness = 0.95
			material.metallic = 0.0
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			material.albedo_texture = _generate_leaves_texture()

		Enums.BlockType.CRISTAL:
			# Cristal aqua brillante transparente
			material.albedo_color = Color(0.3, 0.8, 1.0, 0.6)
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			material.roughness = 0.1
			material.metallic = 0.3
			material.refraction_enabled = true
			material.refraction_scale = 0.1
			material.emission_enabled = true
			material.emission = Color(0.2, 0.6, 0.8)
			material.emission_energy = 0.3

		Enums.BlockType.METAL:
			# Metal plateado moderno
			material.albedo_color = Color(0.7, 0.72, 0.75)
			material.roughness = 0.3
			material.metallic = 0.9
			material.albedo_texture = _generate_metal_texture()

		Enums.BlockType.ORO:
			# Oro dorado intenso
			material.albedo_color = Color(1.0, 0.76, 0.03)
			material.roughness = 0.25
			material.metallic = 1.0
			material.emission_enabled = true
			material.emission = Color(0.8, 0.6, 0.0)
			material.emission_energy = 0.2

		Enums.BlockType.PLATA:
			# Plata lunar brillante
			material.albedo_color = Color(0.85, 0.87, 0.91)
			material.roughness = 0.2
			material.metallic = 1.0

		Enums.BlockType.ARENA:
			# Arena dorada playa
			material.albedo_color = Color(0.93, 0.84, 0.62)
			material.roughness = 0.95
			material.metallic = 0.0
			material.albedo_texture = _generate_sand_texture()

		Enums.BlockType.NIEVE:
			# Nieve blanca cristalina pura
			material.albedo_color = Color(0.98, 0.98, 1.0)
			material.roughness = 0.7
			material.metallic = 0.0
			material.emission_enabled = true
			material.emission = Color(0.9, 0.95, 1.0)
			material.emission_energy = 0.1

		Enums.BlockType.HIELO:
			# Hielo glacial transparente
			material.albedo_color = Color(0.6, 0.85, 0.95, 0.7)
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			material.roughness = 0.05
			material.metallic = 0.2
			material.refraction_enabled = true
			material.refraction_scale = 0.15

	return material

## Generar textura procedural de césped
static func _generate_grass_texture() -> ImageTexture:
	var size = 64
	var image = Image.create(size, size, false, Image.FORMAT_RGB8)

	var noise = FastNoiseLite.new()
	noise.seed = 42
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.1

	for x in range(size):
		for y in range(size):
			var noise_value = noise.get_noise_2d(x, y)
			var brightness = 0.35 + noise_value * 0.1
			var color = Color(brightness * 0.3, brightness, brightness * 0.25)
			image.set_pixel(x, y, color)

	return ImageTexture.create_from_image(image)

## Generar textura procedural de tierra
static func _generate_dirt_texture() -> ImageTexture:
	var size = 64
	var image = Image.create(size, size, false, Image.FORMAT_RGB8)

	var noise = FastNoiseLite.new()
	noise.seed = 123
	noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	noise.frequency = 0.08

	for x in range(size):
		for y in range(size):
			var noise_value = noise.get_noise_2d(x, y)
			var brightness = 0.4 + noise_value * 0.15
			var color = Color(brightness * 0.45, brightness * 0.28, brightness * 0.18)
			image.set_pixel(x, y, color)

	return ImageTexture.create_from_image(image)

## Generar textura procedural de piedra
static func _generate_stone_texture() -> ImageTexture:
	var size = 64
	var image = Image.create(size, size, false, Image.FORMAT_RGB8)

	var noise = FastNoiseLite.new()
	noise.seed = 456
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.12

	for x in range(size):
		for y in range(size):
			var noise_value = noise.get_noise_2d(x, y)
			var brightness = 0.42 + noise_value * 0.08
			var color = Color(brightness * 0.42, brightness * 0.44, brightness * 0.46)
			image.set_pixel(x, y, color)

	return ImageTexture.create_from_image(image)

## Generar textura procedural de madera
static func _generate_wood_texture() -> ImageTexture:
	var size = 64
	var image = Image.create(size, size, false, Image.FORMAT_RGB8)

	# Vetas verticales
	for x in range(size):
		for y in range(size):
			var vein_pattern = sin(x * 0.3) * 0.1
			var brightness = 0.5 + vein_pattern
			var color = Color(brightness * 0.52, brightness * 0.37, brightness * 0.26)
			image.set_pixel(x, y, color)

	return ImageTexture.create_from_image(image)

## Generar textura procedural de hojas
static func _generate_leaves_texture() -> ImageTexture:
	var size = 64
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)

	var noise = FastNoiseLite.new()
	noise.seed = 789
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.15

	for x in range(size):
		for y in range(size):
			var noise_value = noise.get_noise_2d(x, y)
			var brightness = 0.3 + noise_value * 0.2
			var alpha = 0.9 if noise_value > -0.3 else 0.6  # Algunas áreas semi-transparentes
			var color = Color(brightness * 0.2, brightness * 0.55, brightness * 0.15, alpha)
			image.set_pixel(x, y, color)

	return ImageTexture.create_from_image(image)

## Generar textura procedural de metal
static func _generate_metal_texture() -> ImageTexture:
	var size = 64
	var image = Image.create(size, size, false, Image.FORMAT_RGB8)

	var noise = FastNoiseLite.new()
	noise.seed = 321
	noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	noise.frequency = 0.2

	for x in range(size):
		for y in range(size):
			var noise_value = noise.get_noise_2d(x, y)
			var brightness = 0.7 + noise_value * 0.05
			var color = Color(brightness * 0.7, brightness * 0.72, brightness * 0.75)
			image.set_pixel(x, y, color)

	return ImageTexture.create_from_image(image)

## Generar textura procedural de arena
static func _generate_sand_texture() -> ImageTexture:
	var size = 64
	var image = Image.create(size, size, false, Image.FORMAT_RGB8)

	var noise = FastNoiseLite.new()
	noise.seed = 654
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.1

	for x in range(size):
		for y in range(size):
			var noise_value = noise.get_noise_2d(x, y)
			var brightness = 0.9 + noise_value * 0.08
			var color = Color(brightness * 0.93, brightness * 0.84, brightness * 0.62)
			image.set_pixel(x, y, color)

	return ImageTexture.create_from_image(image)

## Limpiar cache de materiales
static func clear_cache() -> void:
	material_cache.clear()
