#!/bin/bash

# ============================================================================
# Script para abrir el proyecto en Godot Editor
# ============================================================================

echo "🎮 Multi Ninja Espacial - Abriendo en Godot..."
echo ""

# Rutas comunes de Godot en macOS
GODOT_PATHS=(
    "/Applications/Godot.app/Contents/MacOS/Godot"
    "/Applications/Godot_v4.app/Contents/MacOS/Godot"
    "/Applications/Godot_v4.2.app/Contents/MacOS/Godot"
    "/Applications/Godot_mono.app/Contents/MacOS/Godot"
    "$HOME/Applications/Godot.app/Contents/MacOS/Godot"
    "/usr/local/bin/godot"
)

# Buscar Godot instalado
GODOT_PATH=""
for path in "${GODOT_PATHS[@]}"; do
    if [ -f "$path" ]; then
        GODOT_PATH="$path"
        echo "✅ Godot encontrado en: $GODOT_PATH"
        break
    fi
done

# Si no se encuentra, preguntar al usuario
if [ -z "$GODOT_PATH" ]; then
    echo "❌ No se encontró Godot en las rutas comunes."
    echo ""
    echo "Por favor, descarga Godot 4.2+ desde:"
    echo "https://godotengine.org/download/macos/"
    echo ""
    echo "Opciones:"
    echo "1. Instalar Godot en /Applications/"
    echo "2. Especificar ruta manualmente"
    echo ""
    read -p "Ingresa la ruta completa a Godot (o Enter para salir): " custom_path

    if [ -n "$custom_path" ] && [ -f "$custom_path" ]; then
        GODOT_PATH="$custom_path"
    else
        echo "❌ Saliendo..."
        exit 1
    fi
fi

# Obtener directorio del proyecto
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_FILE="$PROJECT_DIR/project.godot"

# Verificar que existe project.godot
if [ ! -f "$PROJECT_FILE" ]; then
    echo "❌ Error: No se encontró project.godot en $PROJECT_DIR"
    exit 1
fi

echo ""
echo "📁 Proyecto: $PROJECT_DIR"
echo "🎮 Abriendo Godot Editor..."
echo ""

# Abrir Godot con el proyecto
"$GODOT_PATH" --editor "$PROJECT_FILE" &

echo "✅ Godot debería abrirse en unos segundos."
echo ""
echo "Siguiente paso: Crear las 7 escenas .tscn"
echo "Ver: GODOT_SETUP_INSTRUCTIONS.md"
echo ""
