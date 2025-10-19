# 🌐 Multi Ninja Espacial - Estructura de Proyecto Web

> Arquitectura optimizada para juego educativo cristiano en navegador

**Motor**: Godot 4.2+
**Plataforma**: Web (HTML5/WebAssembly)
**Tamaño objetivo**: <50 MB
**Público**: Niños 4-12 años

---

## 📂 Estructura de Carpetas Completa

```
MultiNinjaEspacial/
│
├── .gitignore                         # Ignorar archivos de build y temporales
├── .gitattributes                     # Configuración Git (LFS para assets grandes)
├── project.godot                      # Configuración principal de Godot
├── icon.svg                           # Icono del proyecto (128x128)
├── export_presets.cfg                 # Configuración de exportación web
│
├── README.md                          # Documentación del proyecto
├── CHANGELOG.md                       # Registro de cambios por versión
├── LICENSE                            # Licencia (MIT o CC)
│
├── addons/                            # Plugins de Godot (si es necesario)
│   └── .gitkeep
│
├── assets/                            # RECURSOS DEL JUEGO
│   │
│   ├── audio/                         # Audio y música
│   │   ├── music/
│   │   │   ├── menu_theme.ogg        # Música del menú (loop)
│   │   │   └── gameplay.ogg          # Música de juego (loop tranquilo)
│   │   └── sfx/
│   │       ├── block_place.wav       # Sonido de colocar bloque
│   │       ├── block_break.wav       # Sonido de romper bloque
│   │       ├── collect.wav           # Sonido de recolectar recurso
│   │       └── luz_gain.wav          # Sonido al ganar Luz Interior
│   │
│   ├── fonts/                         # Fuentes tipográficas
│   │   ├── ui_main.ttf               # Fuente principal (legible, amigable)
│   │   └── ui_title.ttf              # Fuente para títulos
│   │
│   ├── icons/                         # Iconos UI (64x64px)
│   │   ├── block_tierra.png
│   │   ├── block_piedra.png
│   │   ├── block_madera.png
│   │   ├── block_cristal.png
│   │   ├── block_metal.png
│   │   └── luz_icon.png              # Icono de Luz Interior
│   │
│   ├── models/                        # Modelos 3D (low-poly, .glb)
│   │   ├── player/
│   │   │   └── ninja_simple.glb      # Personaje ninja low-poly
│   │   ├── environment/
│   │   │   ├── tree_simple.glb       # Árbol básico
│   │   │   └── rock.glb              # Roca decorativa
│   │   └── .gitkeep
│   │
│   ├── shaders/                       # Shaders custom (opcional)
│   │   └── block_outline.gdshader    # Shader para outline de bloques
│   │
│   └── textures/                      # Texturas (512x512px máximo)
│       ├── blocks/
│       │   ├── tierra.png            # Textura de bloque tierra
│       │   ├── piedra.png            # Textura de bloque piedra
│       │   ├── madera.png            # Textura de bloque madera
│       │   ├── cristal.png           # Textura de bloque cristal
│       │   └── metal.png             # Textura de bloque metal
│       ├── ui/
│       │   ├── button_normal.png
│       │   ├── button_hover.png
│       │   ├── button_pressed.png
│       │   └── panel.png
│       └── environment/
│           ├── sky_gradient.png      # Gradiente de cielo
│           └── stars.png             # Estrellas de fondo
│
├── autoloads/                         # Scripts singleton (autoload)
│   ├── GameManager.gd                # Gestor global del juego
│   ├── PlayerData.gd                 # Datos del jugador (inventario, luz)
│   ├── VirtueSystem.gd               # Sistema de Luz Interior
│   ├── SaveSystem.gd                 # Sistema de guardado (LocalStorage)
│   └── AudioManager.gd               # Gestor de audio global
│
├── scenes/                            # Escenas del juego
│   │
│   ├── main/
│   │   ├── Main.tscn                 # Escena raíz (cambio de escenas)
│   │   └── Main.gd
│   │
│   ├── menus/
│   │   ├── MainMenu.tscn             # Menú principal
│   │   ├── MainMenu.gd
│   │   ├── PauseMenu.tscn            # Menú de pausa
│   │   ├── PauseMenu.gd
│   │   └── OptionsMenu.tscn          # Menú de opciones
│   │
│   ├── game/
│   │   ├── GameWorld.tscn            # Escena del mundo de juego
│   │   ├── GameWorld.gd
│   │   └── .gitkeep
│   │
│   ├── player/
│   │   ├── Player.tscn               # Jugador (CharacterBody3D)
│   │   ├── Player.gd                 # Script principal del jugador
│   │   ├── PlayerMovement.gd         # Lógica de movimiento
│   │   ├── PlayerInteraction.gd      # Interacción con bloques
│   │   └── PlayerCamera.gd           # Control de cámara FPS
│   │
│   ├── world/
│   │   ├── Chunk.tscn                # Chunk de bloques (10x10x10)
│   │   ├── Chunk.gd
│   │   ├── Block.tscn                # Bloque individual (instance)
│   │   └── Block.gd
│   │
│   └── ui/
│       ├── HUD.tscn                  # HUD del juego (in-game)
│       ├── HUD.gd
│       ├── Inventory.tscn            # UI de inventario
│       ├── Inventory.gd
│       ├── LuzBar.tscn               # Barra de Luz Interior
│       ├── Tutorial.tscn             # Mensajes de tutorial
│       └── Crosshair.tscn            # Mira central
│
├── scripts/                           # Scripts GDScript reutilizables
│   │
│   ├── core/
│   │   ├── Constants.gd              # Constantes globales
│   │   ├── Enums.gd                  # Enumeraciones (BlockType, etc.)
│   │   └── Utils.gd                  # Funciones auxiliares
│   │
│   ├── managers/
│   │   ├── ChunkManager.gd           # Gestión de chunks (spawn/despawn)
│   │   ├── BlockManager.gd           # Gestión de tipos de bloques
│   │   └── TerrainGenerator.gd       # Generador procedural (Perlin Noise)
│   │
│   └── data/
│       ├── BlockData.gd              # Definición de datos de bloques
│       └── PlayerStats.gd            # Stats del jugador
│
├── resources/                         # Resources personalizados (.tres)
│   ├── blocks/
│   │   ├── tierra_block.tres         # Resource de bloque tierra
│   │   ├── piedra_block.tres
│   │   ├── madera_block.tres
│   │   ├── cristal_block.tres
│   │   └── metal_block.tres
│   └── .gitkeep
│
├── tests/                             # Tests (GUT framework)
│   ├── unit/
│   │   ├── test_block_system.gd
│   │   └── test_virtue_system.gd
│   └── integration/
│       └── test_save_system.gd
│
├── docs/                              # Documentación adicional
│   ├── GDD.md                        # Game Design Document (web version)
│   ├── ARCHITECTURE.md               # Arquitectura técnica
│   └── WEB_OPTIMIZATION.md           # Guía de optimización web
│
├── web/                               # Archivos específicos para web
│   ├── index.html                    # HTML custom para embed
│   ├── styles.css                    # Estilos de la página
│   ├── loading.gif                   # Gif de carga
│   └── favicon.ico                   # Favicon
│
└── builds/                            # Builds exportados (ignorado en Git)
    ├── web/                          # Build HTML5
    │   ├── index.html
    │   ├── index.js
    │   ├── index.wasm
    │   ├── index.pck
    │   └── index.worker.js
    └── .gitkeep
```

---

## 📝 Descripción de Carpetas Principales

### **assets/** - Recursos del Juego
Contiene TODOS los recursos multimedia (audio, texturas, modelos, fuentes).

**Subcarpetas**:
- `audio/`: Música (OGG para web) y efectos de sonido (WAV cortos)
- `fonts/`: Fuentes TTF para UI (legibles en pantallas pequeñas)
- `icons/`: Iconos de UI de 64x64px (PNG transparente)
- `models/`: Modelos 3D en formato GLB (optimizados para web)
- `textures/`: Texturas PNG comprimidas (512x512px máximo)
- `shaders/`: Shaders GLSL custom (opcional para efectos especiales)

**Optimización web**:
- Texturas comprimidas (PNG-8 cuando sea posible)
- Modelos <10k polígonos
- Audio OGG comprimido (128kbps)

---

### **autoloads/** - Singletons Globales
Scripts que persisten durante toda la sesión y son accesibles desde cualquier escena.

**Archivos**:
1. **GameManager.gd**
   - Gestiona cambio de escenas
   - Estado global del juego (MENU, PLAYING, PAUSED)
   - Maneja eventos globales

2. **PlayerData.gd**
   - Inventario del jugador (Dictionary)
   - Recursos recolectados
   - Posición actual
   - Luz Interior acumulada

3. **VirtueSystem.gd**
   - Lógica del sistema de Luz Interior
   - Detección de acciones positivas
   - Cálculo de recompensas

4. **SaveSystem.gd**
   - Guardar/cargar datos en LocalStorage
   - Serialización JSON
   - Auto-guardado cada 2 minutos

5. **AudioManager.gd**
   - Reproducir música/SFX
   - Control de volumen global
   - Fade in/out de música

---

### **scenes/** - Escenas de Godot

#### **scenes/main/**
- `Main.tscn`: Escena raíz que nunca se destruye, maneja cambio entre menús y juego

#### **scenes/menus/**
- `MainMenu.tscn`: Pantalla inicial con botones "Jugar", "Opciones", "Créditos"
- `PauseMenu.tscn`: Menú que aparece al presionar ESC (Reanudar/Opciones/Salir)
- `OptionsMenu.tscn`: Volumen, sensibilidad de mouse

#### **scenes/game/**
- `GameWorld.tscn`: Escena del mundo de juego (contiene terreno, jugador, UI)

#### **scenes/player/**
- `Player.tscn`: CharacterBody3D con cámara, collider, scripts de movimiento

#### **scenes/world/**
- `Chunk.tscn`: Chunk de 10x10x10 bloques (MeshInstance3D generado dinámicamente)
- `Block.tscn`: (Opcional) Representación individual de bloque

#### **scenes/ui/**
- `HUD.tscn`: HUD in-game (barra de Luz, inventario rápido, crosshair)
- `Inventory.tscn`: Panel de inventario completo (se abre con TAB)
- `Tutorial.tscn`: Mensajes flotantes para guiar al jugador

---

### **scripts/** - Scripts GDScript Reutilizables

#### **scripts/core/**
- `Constants.gd`: Constantes globales (CHUNK_SIZE = 10, MAX_BUILD_HEIGHT = 30)
- `Enums.gd`: Enumeraciones (BlockType.TIERRA, BlockType.PIEDRA, etc.)
- `Utils.gd`: Funciones auxiliares (world_to_chunk_position(), etc.)

#### **scripts/managers/**
- `ChunkManager.gd`: Carga/descarga chunks según posición del jugador
- `BlockManager.gd`: Lógica de colocación/rompimiento de bloques
- `TerrainGenerator.gd`: Genera terreno con Perlin Noise

#### **scripts/data/**
- `BlockData.gd`: Clase que define propiedades de cada tipo de bloque
- `PlayerStats.gd`: Stats del jugador (velocidad, salto, etc.)

---

### **resources/** - Resources Personalizados
Archivos `.tres` (Godot Resource) que definen datos de bloques, items, etc.

**Ejemplo**:
```
tierra_block.tres:
- texture: res://assets/textures/blocks/tierra.png
- dureza: 1.0
- drop_item: "madera"
- nombre: "Tierra"
```

---

### **web/** - Archivos Específicos para Web
Archivos HTML/CSS para customizar la página de embed del juego.

**Archivos**:
- `index.html`: HTML custom con logo, instrucciones, mensaje de carga
- `styles.css`: Estilos de la página (centrar canvas, colores corporativos)
- `loading.gif`: Animación mientras carga el juego
- `favicon.ico`: Icono de la pestaña del navegador

---

### **builds/** - Builds Exportados
Carpeta ignorada en Git (`.gitignore`), contiene los builds generados.

**Subcarpetas**:
- `web/`: Build HTML5 (index.html, .wasm, .pck)
- (En futuro: `android/`, `windows/`, etc.)

---

## ⚙️ Configuración de project.godot

```ini
[application]
config/name="Multi Ninja Espacial"
config/description="Juego educativo cristiano sandbox espacial"
run/main_scene="res://scenes/main/Main.tscn"
config/features=PackedStringArray("4.2", "GL Compatibility")
boot_splash/bg_color=Color(0.05, 0.05, 0.2, 1)
config/icon="res://icon.svg"

[autoload]
GameManager="*res://autoloads/GameManager.gd"
PlayerData="*res://autoloads/PlayerData.gd"
VirtueSystem="*res://autoloads/VirtueSystem.gd"
SaveSystem="*res://autoloads/SaveSystem.gd"
AudioManager="*res://autoloads/AudioManager.gd"

[display]
window/size/viewport_width=1280
window/size/viewport_height=720
window/size/mode=2
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"

[input]
move_forward={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":87,"physical_keycode":0,"unicode":0,"echo":false,"script":null)]
}
move_backward={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":83,"physical_keycode":0,"unicode":0,"echo":false,"script":null)]
}
move_left={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":65,"physical_keycode":0,"unicode":0,"echo":false,"script":null)]
}
move_right={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":68,"physical_keycode":0,"unicode":0,"echo":false,"script":null)]
}
jump={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":32,"physical_keycode":0,"unicode":0,"echo":false,"script":null)]
}
place_block={
"deadzone": 0.5,
"events": [Object(InputEventMouseButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"button_mask":0,"position":Vector2(0, 0),"global_position":Vector2(0, 0),"factor":1.0,"button_index":1,"pressed":false,"double_click":false,"script":null)]
}
break_block={
"deadzone": 0.5,
"events": [Object(InputEventMouseButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"button_mask":0,"position":Vector2(0, 0),"global_position":Vector2(0, 0),"factor":1.0,"button_index":2,"pressed":false,"double_click":false,"script":null)]
}
pause={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":4194305,"physical_keycode":0,"unicode":0,"echo":false,"script":null)]
}
toggle_inventory={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":9,"physical_keycode":0,"unicode":0,"echo":false,"script":null)]
}

[rendering]
renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
anti_aliasing/quality/msaa_3d=2
textures/vram_compression/import_etc2_astc=true
```

---

## 🔧 Configuración de export_presets.cfg

```ini
[preset.0]

name="Web"
platform="Web"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="builds/web/index.html"
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false

[preset.0.options]

custom_template/debug=""
custom_template/release=""
variant/extensions_support=false
vram_texture_compression/for_desktop=true
vram_texture_compression/for_mobile=false
html/export_icon=true
html/custom_html_shell=""
html/head_include=""
html/canvas_resize_policy=2
html/focus_canvas_on_start=true
html/experimental_virtual_keyboard=false
progressive_web_app/enabled=false
progressive_web_app/offline_page=""
progressive_web_app/display=1
progressive_web_app/orientation=0
progressive_web_app/icon_144x144=""
progressive_web_app/icon_180x180=""
progressive_web_app/icon_512x512=""
progressive_web_app/background_color=Color(0, 0, 0, 1)
```

---

## 📄 .gitignore

```gitignore
# Godot-specific
.import/
export.cfg
export_presets.cfg
*.translation

# Build outputs
builds/
*.exe
*.pck
*.zip
*.dmg
*.apk
*.ipa

# Editor
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Temporales
*.tmp
*.bak
```

---

## 📄 README.md Inicial

```markdown
# 🎮 Multi Ninja Espacial

> Juego educativo cristiano sandbox espacial para niños de 4-12 años

**Estado**: MVP en desarrollo
**Plataforma**: Web (HTML5)
**Motor**: Godot 4.2+

---

## ✨ Características

- 🌍 Mundo 3D procedural con bloques voxel
- 🏗️ Sistema de construcción con 5 tipos de bloques
- 💡 Sistema de "Luz Interior" (recompensas por acciones positivas)
- 💾 Guardado local en el navegador
- 🎮 Controles simples (WASD + Mouse)

---

## 🚀 Quick Start

### Requisitos
- Godot 4.2+ instalado
- Navegador web moderno (Chrome, Firefox, Safari)

### Ejecutar en Editor
1. Abrir el proyecto en Godot
2. Presionar F5 o "Run Project"

### Exportar para Web
1. Project → Export
2. Seleccionar preset "Web"
3. Export Project
4. Abrir `builds/web/index.html` en navegador

---

## 📂 Estructura del Proyecto

```
MultiNinjaEspacial/
├── assets/         # Texturas, audio, modelos
├── autoloads/      # Singletons (GameManager, PlayerData, etc.)
├── scenes/         # Escenas de Godot
├── scripts/        # Scripts GDScript reutilizables
└── web/            # Archivos HTML/CSS custom
```

Ver [GODOT-WEB-STRUCTURE.md](GODOT-WEB-STRUCTURE.md) para detalles completos.

---

## 🎯 Roadmap

- [x] Estructura del proyecto
- [ ] Sistema de movimiento del jugador
- [ ] Sistema de bloques (colocar/romper)
- [ ] Generación procedural de terreno
- [ ] Sistema de inventario
- [ ] Sistema de Luz Interior
- [ ] Guardado local (LocalStorage)
- [ ] UI completa (menús + HUD)
- [ ] Tutorial integrado
- [ ] Audio (música + SFX)

---

## 📝 Licencia

[MIT / Creative Commons] (por definir)

---

## 👨‍💻 Desarrollador

Carlos Garcia
[Tu contacto / GitHub]
```

---

## ✅ Archivos .gitkeep

Crea archivos `.gitkeep` en carpetas vacías para que Git las trackee:

```bash
# En terminal (macOS/Linux)
touch addons/.gitkeep
touch assets/models/.gitkeep
touch resources/.gitkeep
touch builds/.gitkeep
```

---

## 🚀 Siguiente Paso

Con esta estructura lista, el **PASO 2** es crear los **autoloads** y el **controlador del jugador**.

¿Quieres que continúe con el **PASO 2: Scripts Base** (GameManager, PlayerData, Player.gd)?
