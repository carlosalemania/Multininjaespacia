# ============================================================================
# generate_placeholder_atlas.gd - Generador de Atlas Placeholder
# ============================================================================
# Script de utilidad para generar un texture atlas placeholder con colores
# Este script se ejecuta con: Godot --script generate_placeholder_atlas.gd
# ============================================================================

@tool
extends EditorScript

const ATLAS_SIZE = 256
const TILE_SIZE = 16
const TILES_PER_ROW = 16

## Colores placeholder basados en los colores actuales del juego
const TILE_COLORS = {
	# Fila 0
	Vector2i(0, 0): Color(0.45, 0.28, 0.18),  # TIERRA - marrón
	Vector2i(1, 0): Color(0.42, 0.44, 0.46),  # PIEDRA - gris
	Vector2i(2, 0): Color(0.52, 0.37, 0.26),  # MADERA - marrón claro
	Vector2i(3, 0): Color(0.93, 0.84, 0.62),  # ARENA - amarillo

	# Fila 1
	Vector2i(0, 1): Color(0.35, 0.75, 0.25),  # CESPED TOP - verde
	Vector2i(1, 1): Color(0.40, 0.55, 0.22),  # CESPED SIDE - verde/marrón
	Vector2i(2, 1): Color(0.2, 0.55, 0.15),   # HOJAS - verde oscuro

	# Fila 2
	Vector2i(0, 2): Color(0.3, 0.8, 1.0),     # CRISTAL - cyan
	Vector2i(1, 2): Color(1.0, 0.76, 0.03),   # ORO - dorado
	Vector2i(2, 2): Color(0.85, 0.87, 0.91),  # PLATA - plateado
	Vector2i(3, 2): Color(0.65, 0.67, 0.69),  # METAL - gris metálico

	# Fila 3
	Vector2i(0, 3): Color(0.98, 0.98, 1.0),   # NIEVE - blanco
	Vector2i(1, 3): Color(0.6, 0.85, 0.95),   # HIELO - cyan claro
}

func _run():
	print("🎨 Generando texture atlas placeholder...")

	# Crear imagen
	var image = Image.create(ATLAS_SIZE, ATLAS_SIZE, false, Image.FORMAT_RGBA8)

	# Llenar con colores placeholder
	for tile_pos in TILE_COLORS.keys():
		var color = TILE_COLORS[tile_pos]
		_fill_tile(image, tile_pos, color)

	# Llenar tiles vacíos con patrón de checkerboard
	for x in range(TILES_PER_ROW):
		for y in range(TILES_PER_ROW):
			var pos = Vector2i(x, y)
			if not TILE_COLORS.has(pos):
				var checkerboard_color = Color(0.8, 0.0, 0.8) if (x + y) % 2 == 0 else Color(0.6, 0.0, 0.6)
				_fill_tile(image, pos, checkerboard_color)

	# Guardar imagen
	var save_path = "res://assets/textures/block_atlas.png"
	var error = image.save_png(save_path)

	if error == OK:
		print("✅ Atlas generado: ", save_path)
		print("📊 Tamaño: ", ATLAS_SIZE, "x", ATLAS_SIZE, " pixels")
		print("📦 Tiles: ", TILES_PER_ROW, "x", TILES_PER_ROW, " (", TILE_SIZE, "x", TILE_SIZE, " cada uno)")
	else:
		push_error("❌ Error al guardar atlas: ", error)


func _fill_tile(image: Image, tile_pos: Vector2i, base_color: Color) -> void:
	var start_x = tile_pos.x * TILE_SIZE
	var start_y = tile_pos.y * TILE_SIZE

	for x in range(TILE_SIZE):
		for y in range(TILE_SIZE):
			# Añadir variación sutil para simular textura
			var variation = randf_range(-0.05, 0.05)
			var color = base_color.lightened(variation)

			# Añadir borde oscuro para visualizar tiles
			if x == 0 or y == 0 or x == TILE_SIZE - 1 or y == TILE_SIZE - 1:
				color = color.darkened(0.3)

			image.set_pixel(start_x + x, start_y + y, color)
