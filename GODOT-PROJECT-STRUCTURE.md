# 🏗️ Multi Ninja Espacial - Estructura de Proyecto Godot 4

> Arquitectura de carpetas para juego educativo cristiano sandbox espacial

**Motor**: Godot 4.2+
**Lenguaje**: GDScript
**Plataformas**: PC (Win/Mac/Linux), Android, iOS
**Público**: Niños 4-12 años

---

## 📂 Estructura de Carpetas Completa

```
MultiNinjaEspacial/
│
├── project.godot                      # Configuración del proyecto Godot
├── icon.svg                           # Icono del proyecto
├── export_presets.cfg                 # Configuración de exportación
│
├── addons/                            # Plugins de terceros
│   └── README.md                      # Lista de addons usados
│
├── assets/                            # TODOS los recursos del juego
│   │
│   ├── audio/                         # Audio y música
│   │   ├── music/
│   │   │   ├── menu_theme.ogg
│   │   │   ├── gameplay_peaceful.ogg
│   │   │   └── gameplay_adventure.ogg
│   │   ├── sfx/
│   │   │   ├── block_place.wav
│   │   │   ├── block_break.wav
│   │   │   ├── jump.wav
│   │   │   ├── collect_item.wav
│   │   │   └── virtue_unlocked.wav
│   │   └── voice/                     # Voces para tutorial
│   │       ├── tutorial_welcome.ogg
│   │       └── tutorial_blocks.ogg
│   │
│   ├── fonts/                         # Fuentes tipográficas
│   │   ├── ui_main.ttf               # Fuente principal UI
│   │   └── ui_title.ttf              # Fuente para títulos
│   │
│   ├── icons/                         # Iconos de UI
│   │   ├── blocks/                    # Iconos de bloques
│   │   │   ├── grass_block.png
│   │   │   ├── stone_block.png
│   │   │   ├── wood_block.png
│   │   │   ├── crystal_block.png
│   │   │   └── light_block.png
│   │   ├── items/                     # Iconos de items
│   │   │   ├── wood.png
│   │   │   ├── stone.png
│   │   │   └── crystal.png
│   │   └── virtues/                   # Iconos de virtudes
│   │       ├── fe.png
│   │       ├── trabajo.png
│   │       ├── amabilidad.png
│   │       ├── responsabilidad.png
│   │       └── honestidad.png
│   │
│   ├── materials/                     # Materiales PBR
│   │   ├── blocks/
│   │   │   ├── grass.tres
│   │   │   ├── stone.tres
│   │   │   ├── wood.tres
│   │   │   └── crystal.tres
│   │   └── environment/
│   │       ├── sky.tres
│   │       └── stars.tres
│   │
│   ├── models/                        # Modelos 3D
│   │   ├── characters/
│   │   │   ├── ninja.glb             # Modelo del ninja
│   │   │   └── ninja_animations.res
│   │   ├── blocks/                    # Meshes de bloques (si custom)
│   │   │   └── block_base.obj
│   │   └── props/                     # Props decorativos
│   │       ├── tree.glb
│   │       └── rock.glb
│   │
│   ├── shaders/                       # Shaders custom
│   │   ├── block_outline.gdshader
│   │   ├── water.gdshader
│   │   └── stars.gdshader
│   │
│   └── textures/                      # Texturas 2D/3D
│       ├── blocks/                    # Texturas de bloques
│       │   ├── grass_top.png
│       │   ├── grass_side.png
│       │   ├── stone.png
│       │   ├── wood.png
│       │   └── crystal.png
│       ├── ui/                        # Texturas de UI
│       │   ├── button_normal.png
│       │   ├── button_pressed.png
│       │   └── panel_background.png
│       └── environment/
│           ├── sky_gradient.png
│           └── stars.png
│
├── autoloads/                         # Singletons globales
│   ├── GameManager.gd                # Gestor principal del juego
│   ├── PlayerData.gd                 # Datos del jugador (inventario, virtudes)
│   ├── VirtueSystem.gd               # Sistema de virtudes y Luz Interior
│   ├── AudioManager.gd               # Gestor de audio global
│   ├── SaveSystem.gd                 # Sistema de guardado/cargado
│   └── MultiplayerManager.gd         # Gestor de multijugador
│
├── scenes/                            # Escenas del juego
│   │
│   ├── main/                          # Escenas principales
│   │   ├── Main.tscn                 # Escena root del juego
│   │   └── Main.gd
│   │
│   ├── ui/                            # Interfaces de usuario
│   │   ├── menus/
│   │   │   ├── MainMenu.tscn
│   │   │   ├── MainMenu.gd
│   │   │   ├── PauseMenu.tscn
│   │   │   ├── PauseMenu.gd
│   │   │   ├── SettingsMenu.tscn
│   │   │   └── SettingsMenu.gd
│   │   ├── hud/
│   │   │   ├── GameHUD.tscn          # HUD del juego
│   │   │   ├── GameHUD.gd
│   │   │   ├── HealthBar.tscn
│   │   │   ├── OxygenBar.tscn
│   │   │   └── ResourceDisplay.tscn
│   │   ├── inventory/
│   │   │   ├── InventoryUI.tscn
│   │   │   ├── InventoryUI.gd
│   │   │   └── ItemSlot.tscn
│   │   └── virtues/
│   │       ├── VirtueTreeUI.tscn     # Árbol de virtudes
│   │       ├── VirtueTreeUI.gd
│   │       └── VirtueNode.tscn
│   │
│   ├── player/                        # Personaje jugador
│   │   ├── Player.tscn
│   │   ├── Player.gd                 # Controlador principal
│   │   ├── PlayerMovement.gd         # Sistema de movimiento
│   │   ├── PlayerInteraction.gd      # Interacción con bloques
│   │   └── PlayerCamera.gd           # Control de cámara
│   │
│   ├── world/                         # Mundo del juego
│   │   ├── World.tscn                # Escena del mundo
│   │   ├── World.gd
│   │   ├── chunks/
│   │   │   ├── Chunk.tscn            # Chunk individual (16x16x16)
│   │   │   └── Chunk.gd
│   │   ├── blocks/
│   │   │   ├── Block.tscn            # Bloque base
│   │   │   └── Block.gd
│   │   └── generation/
│   │       ├── TerrainGenerator.gd   # Generador procedural
│   │       └── NoiseSettings.tres    # Configuración de ruido
│   │
│   ├── systems/                       # Sistemas del juego
│   │   ├── day_night/
│   │   │   ├── DayNightCycle.tscn
│   │   │   └── DayNightCycle.gd
│   │   ├── weather/
│   │   │   └── WeatherSystem.gd      # (Fase 3)
│   │   └── tutorial/
│   │       ├── TutorialManager.tscn
│   │       └── TutorialManager.gd
│   │
│   └── multiplayer/                   # Componentes multiplayer
│       ├── NetworkPlayer.tscn        # Jugador remoto
│       ├── NetworkPlayer.gd
│       └── ChatBox.tscn              # Chat con filtro
│
├── scripts/                           # Scripts GDScript generales
│   │
│   ├── core/                          # Scripts core del juego
│   │   ├── Constants.gd              # Constantes globales
│   │   ├── Enums.gd                  # Enumeraciones
│   │   └── Utils.gd                  # Funciones auxiliares
│   │
│   ├── data/                          # Definiciones de datos
│   │   ├── BlockData.gd              # Datos de tipos de bloques
│   │   ├── ItemData.gd               # Datos de items
│   │   ├── VirtueData.gd             # Datos de virtudes
│   │   └── PlayerStats.gd            # Stats del jugador
│   │
│   ├── managers/                      # Gestores específicos
│   │   ├── ChunkManager.gd           # Gestión de chunks
│   │   ├── BlockManager.gd           # Gestión de bloques
│   │   └── ParentalControlManager.gd # Control parental
│   │
│   └── multiplayer/                   # Scripts de red
│       ├── NetworkProtocol.gd        # Protocolo de red
│       ├── ChatFilter.gd             # Filtro de chat
│       └── ReportSystem.gd           # Sistema de reportes
│
├── resources/                         # Resources (archivos .tres)
│   ├── blocks/                        # Recursos de bloques
│   │   ├── grass_block.tres
│   │   ├── stone_block.tres
│   │   ├── wood_block.tres
│   │   ├── crystal_block.tres
│   │   └── light_block.tres
│   ├── items/
│   │   ├── wood_item.tres
│   │   ├── stone_item.tres
│   │   └── crystal_item.tres
│   └── virtues/
│       ├── virtue_fe.tres
│       ├── virtue_trabajo.tres
│       ├── virtue_amabilidad.tres
│       ├── virtue_responsabilidad.tres
│       └── virtue_honestidad.tres
│
├── tests/                             # Tests GDScript (GUT framework)
│   ├── unit/
│   │   ├── test_block_system.gd
│   │   ├── test_virtue_system.gd
│   │   └── test_inventory.gd
│   └── integration/
│       ├── test_multiplayer.gd
│       └── test_save_system.gd
│
├── docs/                              # Documentación del proyecto
│   ├── GDD.md                        # Game Design Document
│   ├── ARCHITECTURE.md               # Arquitectura técnica
│   ├── API.md                        # Documentación de API
│   └── ROADMAP.md                    # Roadmap de desarrollo
│
└── tools/                             # Herramientas de desarrollo
    ├── editor/
    │   └── BlockEditor.tscn          # Editor de bloques custom
    └── scripts/
        └── export_android.sh         # Script de exportación Android
```

---

## 🎯 Explicación de Carpetas Clave

### **autoloads/** (Singletons)
Contiene los gestores globales que persisten durante toda la sesión:
- `GameManager`: Estado global, cambio de escenas
- `PlayerData`: Inventario, recursos, progreso
- `VirtueSystem`: Luz Interior, árbol de virtudes
- `AudioManager`: Música y SFX
- `SaveSystem`: Guardado/carga de datos

### **scenes/player/**
Todo lo relacionado con el personaje:
- `Player.tscn`: Escena del jugador (CharacterBody3D)
- `PlayerMovement.gd`: Movimiento WASD + salto
- `PlayerInteraction.gd`: Colocar/destruir bloques
- `PlayerCamera.gd`: Cámara en primera/tercera persona

### **scenes/world/**
Generación y gestión del mundo voxel:
- `Chunk.tscn`: Chunk de 16x16x16 bloques
- `TerrainGenerator.gd`: Generación procedural con noise
- `Block.gd`: Lógica de bloques individuales

### **scripts/data/**
Definiciones de datos (Resources personalizados):
- `BlockData.gd`: Define propiedades de cada bloque
- `VirtueData.gd`: Define cada virtud (nombre, descripción, bonos)
- `ItemData.gd`: Items del inventario

---

## 🔧 Configuración de Godot Project

### **project.godot** (Configuración principal)

```ini
[application]
config/name="Multi Ninja Espacial"
config/description="Juego educativo cristiano sandbox espacial"
run/main_scene="res://scenes/main/Main.tscn"
config/features=PackedStringArray("4.2", "Forward+")
config/icon="res://icon.svg"

[autoload]
GameManager="*res://autoloads/GameManager.gd"
PlayerData="*res://autoloads/PlayerData.gd"
VirtueSystem="*res://autoloads/VirtueSystem.gd"
AudioManager="*res://autoloads/AudioManager.gd"
SaveSystem="*res://autoloads/SaveSystem.gd"
MultiplayerManager="*res://autoloads/MultiplayerManager.gd"

[display]
window/size/viewport_width=1280
window/size/viewport_height=720
window/size/mode=2
window/stretch/mode="viewport"

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
"events": [Object(InputEventMouseButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"button_mask":0,"position":Vector2(0, 0),"global_position":Vector2(0, 0),"factor":1.0,"button_index":2,"pressed":false,"double_click":false,"script":null)]
}
break_block={
"deadzone": 0.5,
"events": [Object(InputEventMouseButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"button_mask":0,"position":Vector2(0, 0),"global_position":Vector2(0, 0),"factor":1.0,"button_index":1,"pressed":false,"double_click":false,"script":null)]
}

[physics]
3d/default_gravity=9.8

[rendering]
renderer/rendering_method="forward_plus"
anti_aliasing/quality/msaa_3d=2
environment/defaults/default_clear_color=Color(0.05, 0.05, 0.15, 1)
```

---

## 📦 Addons Recomendados

### **Para MVP (Fase 1)**:

1. **GUT (Godot Unit Testing)**
   - URL: https://github.com/bitwes/Gut
   - Propósito: Tests unitarios

2. **Dialogue Manager** (opcional para tutorial)
   - URL: https://github.com/nathanhoad/godot_dialogue_manager
   - Propósito: Sistema de diálogos para tutoriales

### **Para Fase 2-3**:

3. **Nakama** (multiplayer backend opcional)
   - URL: https://heroiclabs.com/godot-nakama/
   - Propósito: Backend para multijugador con chat moderado

---

## 🎨 Convenciones de Nombres

### **Archivos**:
- Escenas: `PascalCase.tscn` (ej: `MainMenu.tscn`)
- Scripts: `PascalCase.gd` (ej: `PlayerMovement.gd`)
- Resources: `snake_case.tres` (ej: `grass_block.tres`)
- Assets: `snake_case.png/ogg/etc` (ej: `block_place.wav`)

### **Código GDScript**:
- Clases: `PascalCase` (ej: `class_name PlayerMovement`)
- Variables: `snake_case` (ej: `var player_health`)
- Constantes: `UPPER_SNAKE_CASE` (ej: `const MAX_HEALTH = 100`)
- Funciones: `snake_case` (ej: `func move_player()`)
- Señales: `snake_case` (ej: `signal health_changed`)

---

## 🚀 Siguiente Paso

Esta estructura está lista para el MVP. El siguiente paso es implementar:

1. **Autoloads principales** (GameManager, PlayerData)
2. **Escena del jugador** con movimiento básico
3. **Sistema de bloques** simple
4. **Generador de terreno** procedural

¿Quieres que continúe con el **Paso 2: Implementación de sistemas principales**?
