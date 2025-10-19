# 🔊 Audio Placeholders - Guía de Implementación

## Estado Actual

El juego está diseñado para funcionar **con o sin archivos de audio**.

Los scripts de `AudioManager.gd` ya incluyen verificaciones:
```gdscript
if not FileAccess.file_exists(sfx_path):
    return  # No hace nada si el archivo no existe
```

**Esto significa que el juego funcionará perfectamente sin audio.**

---

## Opción 1: Sin Audio (Recomendado para Primera Prueba)

**✅ No hagas nada.**

El juego funcionará sin problemas. Los llamados a `AudioManager.play_sfx()` simplemente no reproducirán nada.

**Ventajas**:
- ✅ Listo para jugar inmediatamente
- ✅ No necesitas buscar/generar archivos
- ✅ Puedes añadir audio después

---

## Opción 2: Audio Silencioso (Para Evitar Warnings en Consola)

Si quieres evitar mensajes de "archivo no encontrado" en la consola de Godot:

### Usando Godot Editor (Método Más Fácil):

1. **Abrir Godot**
2. **FileSystem** → Click derecho en `assets/audio/music/`
3. **Create New → Resource → AudioStreamOGGVorbis**
4. Guardar como `menu_theme.ogg`
5. Repetir para `gameplay_theme.ogg`
6. Repetir para los 7 SFX en `assets/audio/sfx/`

Esto creará archivos vacíos que Godot puede cargar sin errores.

---

## Opción 3: Generar Audio Real con Herramientas Online

### Para Música:

**Música Gratis y Legal**:
1. Ir a [incompetech.com](https://incompetech.com/music/royalty-free/)
2. Buscar "Peaceful" para menú, "Adventure" para gameplay
3. Descargar MP3
4. Convertir a OGG online: [convertio.co](https://convertio.co/mp3-ogg/)
5. Copiar a `assets/audio/music/`

### Para SFX:

**Efectos de Sonido Gratis**:
1. Ir a [freesound.org](https://freesound.org) (requiere cuenta gratis)
2. Buscar:
   - "block place" → `block_place.ogg`
   - "block break" → `block_break.ogg`
   - "coin collect" → `collect.ogg`
   - "chime success" → `luz_gain.ogg`
   - "button click" → `button_click.ogg`
   - "menu open" → `menu_open.ogg`
   - "menu close" → `menu_close.ogg`
3. Descargar WAV/MP3 y convertir a OGG
4. Copiar a `assets/audio/sfx/`

---

## Opción 4: Generar SFX con jsfxr (Online, 30 segundos)

**Generador de Sonidos Retro**: [jfxr.frozenfractal.com](https://jfxr.frozenfractal.com)

### Instrucciones Rápidas:

1. **Abrir jsfxr**
2. **Para cada sonido**:

   **block_place.ogg**:
   - Preset: "Pickup/Coin"
   - Export → WAV → Convertir a OGG

   **block_break.ogg**:
   - Preset: "Hit/Hurt"
   - Export → WAV → Convertir a OGG

   **collect.ogg**:
   - Preset: "Powerup"
   - Export → WAV → Convertir a OGG

   **luz_gain.ogg**:
   - Preset: "Pickup/Coin" (pitch más alto)
   - Export → WAV → Convertir a OGG

   **button_click.ogg**:
   - Preset: "Blip/Select"
   - Export → WAV → Convertir a OGG

   **menu_open.ogg**:
   - Preset: "Powerup"
   - Export → WAV → Convertir a OGG

   **menu_close.ogg**:
   - Preset: "Hit/Hurt" (suave)
   - Export → WAV → Convertir a OGG

3. **Convertir todos a OGG**:
   - Opción A: [convertio.co](https://convertio.co/wav-ogg/)
   - Opción B: `ffmpeg -i input.wav -c:a libvorbis output.ogg`

---

## Estructura Final de Audio

```
assets/audio/
├── music/
│   ├── menu_theme.ogg        (2-3 minutos, loop)
│   └── gameplay_theme.ogg    (3-5 minutos, loop)
└── sfx/
    ├── block_place.ogg       (0.2 segundos)
    ├── block_break.ogg       (0.3 segundos)
    ├── collect.ogg           (0.5 segundos)
    ├── luz_gain.ogg          (0.7 segundos)
    ├── button_click.ogg      (0.1 segundos)
    ├── menu_open.ogg         (0.3 segundos)
    └── menu_close.ogg        (0.2 segundos)
```

---

## Configuración en Godot (Si Añades Audio Después)

Una vez que tengas los archivos OGG:

1. **Copiar archivos** a las carpetas correspondientes
2. **En Godot**: Los archivos aparecerán automáticamente en FileSystem
3. **Click derecho** en cada `.ogg` → **Import**
4. Para música:
   - Inspector → **Loop**: ✅ Enabled
5. **Reimportar** si es necesario

---

## Verificación de Audio

### En el Script:

Los scripts ya están configurados. Solo verifica que las rutas sean correctas:

`AudioManager.gd`:
```gdscript
const MUSIC_MENU: String = "res://assets/audio/music/menu_theme.ogg"
const MUSIC_GAMEPLAY: String = "res://assets/audio/music/gameplay_theme.ogg"

var SFX_PATHS: Dictionary = {
    Enums.SoundType.BLOCK_PLACE: "res://assets/audio/sfx/block_place.ogg",
    Enums.SoundType.BLOCK_BREAK: "res://assets/audio/sfx/block_break.ogg",
    # ... etc
}
```

---

## Mi Recomendación

### Para Primera Prueba (HOY):
**✅ Opción 1: Sin Audio**
- Simplemente presiona F5 y juega
- El audio no es crítico para verificar que todo funcione

### Más Adelante (Cuando Tengas Tiempo):
**✅ Opción 3: Audio Real de Freesound/Incompetech**
- Mejor calidad
- Gratis y legal
- Más profesional

### Si Tienes 30 Minutos Ahora:
**✅ Opción 4: jsfxr para SFX + Incompetech para Música**
- Rápido de generar
- Suficientemente bueno para MVP
- Retro/chiptune (puede quedar bien con el estilo low-poly)

---

## Licencias (Importante)

### Música de Incompetech:
- Licencia: Creative Commons Attribution 3.0
- **Debes incluir**: "Music by Kevin MacLeod (incompetech.com)"

### SFX de Freesound:
- Verificar licencia individual de cada sonido
- Mayoría son CC0 (dominio público) o CC-BY (atribución)

### SFX de jsfxr:
- Dominio público
- Puedes usar libremente

---

## Siguiente Paso

**Para jugar AHORA**:
```bash
cd /Users/carlosgarcia/Desktop/Proyectos/C++/multininjaespacial
./open_godot.sh
# Crear las 7 escenas
# Presionar F5
# ¡Jugar sin audio! (funcionará perfectamente)
```

**Para añadir audio DESPUÉS**:
- Seguir Opción 3 o 4 cuando tengas tiempo
- Copiar archivos a `assets/audio/`
- Reimportar en Godot
- Listo!

---

**El audio es 100% opcional para la primera prueba. ¡Prueba el juego ya!** 🎮
