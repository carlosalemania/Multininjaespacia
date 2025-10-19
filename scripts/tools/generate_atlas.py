#!/usr/bin/env python3
"""
Generador de Texture Atlas Placeholder
Crea un atlas de 256x256 con tiles de 16x16 para los bloques del juego
"""

from PIL import Image, ImageDraw
import random

ATLAS_SIZE = 256
TILE_SIZE = 16
TILES_PER_ROW = 16

# Colores basados en el juego (RGB 0-255)
TILE_COLORS = {
    # Fila 0
    (0, 0): (115, 71, 46),    # TIERRA - marrón
    (1, 0): (107, 112, 117),  # PIEDRA - gris
    (2, 0): (133, 94, 66),    # MADERA - marrón claro
    (3, 0): (237, 214, 158),  # ARENA - amarillo

    # Fila 1
    (0, 1): (89, 191, 64),    # CESPED TOP - verde
    (1, 1): (102, 140, 56),   # CESPED SIDE - verde/marrón
    (2, 1): (51, 140, 38),    # HOJAS - verde oscuro

    # Fila 2
    (0, 2): (77, 204, 255),   # CRISTAL - cyan
    (1, 2): (255, 194, 8),    # ORO - dorado
    (2, 2): (217, 222, 232),  # PLATA - plateado
    (3, 2): (166, 171, 176),  # METAL - gris metálico

    # Fila 3
    (0, 3): (250, 250, 255),  # NIEVE - blanco
    (1, 3): (153, 217, 242),  # HIELO - cyan claro
}

def add_texture_detail(base_color, x, y, tile_size):
    """Añade variación y detalles a un pixel para simular textura"""
    r, g, b = base_color

    # Variación aleatoria sutil
    variation = random.randint(-12, 12)
    r = max(0, min(255, r + variation))
    g = max(0, min(255, g + variation))
    b = max(0, min(255, b + variation))

    # Borde oscuro para visualizar tiles
    if x == 0 or y == 0 or x == tile_size - 1 or y == tile_size - 1:
        r, g, b = int(r * 0.7), int(g * 0.7), int(b * 0.7)

    return (r, g, b, 255)

def generate_atlas():
    """Genera el texture atlas completo"""
    print("🎨 Generando texture atlas placeholder...")

    # Crear imagen RGBA
    image = Image.new('RGBA', (ATLAS_SIZE, ATLAS_SIZE), (255, 0, 255, 255))
    pixels = image.load()

    # Llenar tiles con colores definidos
    for tile_pos, base_color in TILE_COLORS.items():
        tile_x, tile_y = tile_pos
        start_x = tile_x * TILE_SIZE
        start_y = tile_y * TILE_SIZE

        for x in range(TILE_SIZE):
            for y in range(TILE_SIZE):
                color = add_texture_detail(base_color, x, y, TILE_SIZE)
                pixels[start_x + x, start_y + y] = color

    # Llenar tiles vacíos con checkerboard magenta (para debug)
    for tile_x in range(TILES_PER_ROW):
        for tile_y in range(TILES_PER_ROW):
            if (tile_x, tile_y) not in TILE_COLORS:
                start_x = tile_x * TILE_SIZE
                start_y = tile_y * TILE_SIZE

                # Checkerboard magenta/púrpura
                checkerboard = (204, 0, 204) if (tile_x + tile_y) % 2 == 0 else (153, 0, 153)

                for x in range(TILE_SIZE):
                    for y in range(TILE_SIZE):
                        color = add_texture_detail(checkerboard, x, y, TILE_SIZE)
                        pixels[start_x + x, start_y + y] = color

    # Guardar imagen
    output_path = "../../assets/textures/block_atlas.png"
    image.save(output_path)

    print(f"✅ Atlas generado: {output_path}")
    print(f"📊 Tamaño: {ATLAS_SIZE}x{ATLAS_SIZE} pixels")
    print(f"📦 Tiles: {TILES_PER_ROW}x{TILES_PER_ROW} ({TILE_SIZE}x{TILE_SIZE} cada uno)")
    print(f"🎨 Tiles con textura: {len(TILE_COLORS)}")
    print(f"💜 Tiles placeholder: {TILES_PER_ROW * TILES_PER_ROW - len(TILE_COLORS)}")

if __name__ == "__main__":
    generate_atlas()
