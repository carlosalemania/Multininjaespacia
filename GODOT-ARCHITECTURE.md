# 🏛️ Multi Ninja Espacial - Arquitectura de Sistemas

> Diagrama de dependencias y arquitectura técnica del juego educativo

**Motor**: Godot 4.2+
**Patrón**: MVC Modificado + Sistema de Entidades

---

## 🔷 Diagrama de Sistemas Principales

```
┌─────────────────────────────────────────────────────────────────┐
│                        AUTOLOADS (Singletons)                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ GameManager  │  │  PlayerData  │  │VirtueSystem  │          │
│  │              │  │              │  │              │          │
│  │ - Estado     │  │ - Inventario │  │ - Luz        │          │
│  │ - Escenas    │  │ - Stats      │  │ - Árbol      │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
│         │                  │                  │                  │
│  ┌──────┴──────┐  ┌────────┴────────┐  ┌────┴─────────┐        │
│  │AudioManager │  │  SaveSystem     │  │Multiplayer   │        │
│  │             │  │                 │  │Manager       │        │
│  │ - Música    │  │ - JSON/Binary   │  │              │        │
│  │ - SFX       │  │ - Encriptación  │  │ - P2P/Server │        │
│  └─────────────┘  └─────────────────┘  └──────────────┘        │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                         CAPA DE ESCENAS                          │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐    │
│  │                    Main.tscn (Root)                     │    │
│  └──────────────────────┬─────────────────────────────────┘    │
│                         │                                       │
│          ┌──────────────┼──────────────┐                       │
│          │              │               │                       │
│    ┌─────▼────┐   ┌────▼─────┐   ┌────▼─────┐                 │
│    │   UI     │   │  Player  │   │  World   │                 │
│    │  Layer   │   │          │   │          │                 │
│    │          │   │  ┌───────┴────────┐     │                 │
│    │ - HUD    │   │  │   Movement     │     │                 │
│    │ - Menus  │   │  │   Interaction  │     │                 │
│    │ - Chat   │   │  │   Camera       │     │                 │
│    └──────────┘   │  └────────────────┘     │                 │
│                   │                          │                 │
│                   │                ┌─────────▼─────────┐       │
│                   │                │  Chunk System     │       │
│                   │                │                   │       │
│                   │                │ - Generation      │       │
│                   │                │ - Rendering       │       │
│                   │                │ - Collisions      │       │
│                   │                └───────────────────┘       │
│                   └──────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      CAPA DE DATOS (Resources)                   │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  BlockData   │  │  ItemData    │  │ VirtueData   │          │
│  │              │  │              │  │              │          │
│  │ - ID         │  │ - ID         │  │ - ID         │          │
│  │ - Texture    │  │ - Icon       │  │ - Nombre     │          │
│  │ - Dureza     │  │ - Stack      │  │ - Bonus      │          │
│  │ - Drops      │  │ - Value      │  │ - Costo Luz  │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Flujo de Datos

### **1. Inicio del Juego**

```
Usuario lanza juego
    ↓
Main.tscn se carga
    ↓
Autoloads se inicializan (en orden):
  1. Constants.gd (constantes globales)
  2. GameManager.gd (estado del juego)
  3. PlayerData.gd (datos del jugador)
  4. VirtueSystem.gd (sistema de virtudes)
  5. AudioManager.gd (audio global)
  6. SaveSystem.gd (sistema de guardado)
  7. MultiplayerManager.gd (red)
    ↓
GameManager carga MainMenu.tscn
    ↓
Usuario elige "Nuevo Juego"
    ↓
GameManager carga World.tscn + Player.tscn
    ↓
TerrainGenerator genera chunks iniciales
    ↓
Player spawns en posición (0, 50, 0)
    ↓
GameHUD se muestra
    ↓
¡Juego comienza!
```

### **2. Colocación de Bloque**

```
Usuario presiona botón derecho del mouse
    ↓
PlayerInteraction.gd detecta input
    ↓
Raycast desde cámara detecta hit con bloque
    ↓
Calcula posición adyacente para nuevo bloque
    ↓
Verifica en PlayerData si tiene bloque en inventario
    ↓
Si tiene:
  - Llama a ChunkManager.place_block(position, block_type)
  - ChunkManager actualiza mesh del chunk
  - PlayerData reduce cantidad en inventario
  - AudioManager reproduce "block_place.wav"
  - VirtueSystem verifica si acción da Luz
    ↓
HUD actualiza UI de inventario
```

### **3. Sistema de Virtudes**

```
Jugador completa acción positiva
    ↓
Sistema detecta acción (ej: compartir recursos)
    ↓
VirtueSystem.add_light(cantidad)
    ↓
VirtueSystem emite señal "light_changed"
    ↓
VirtueTreeUI actualiza barra de progreso
    ↓
Si alcanza threshold:
  - VirtueSystem desbloquea nueva habilidad
  - Muestra notificación en HUD
  - AudioManager reproduce "virtue_unlocked.wav"
  - PlayerData actualiza virtudes activas
```

---

## 🧩 Dependencias entre Sistemas

### **Mapa de Dependencias**

```
GameManager (no depende de nada, núcleo)
    ↓
PlayerData ← VirtueSystem
    ↓
SaveSystem (usa PlayerData, GameManager)
    ↓
AudioManager (independiente, usado por todos)
    ↓
MultiplayerManager → GameManager, PlayerData

Player.gd → PlayerData, VirtueSystem, AudioManager
World.gd → ChunkManager, TerrainGenerator
ChunkManager → BlockManager
UI Scenes → PlayerData, VirtueSystem, GameManager
```

### **Reglas de Dependencia**

✅ **Permitido**:
- Escenas → Autoloads (siempre)
- Autoloads → otros Autoloads (solo si es necesario)
- Scripts → Resources (siempre)

❌ **Prohibido**:
- Autoloads → Escenas (crear dependencia circular)
- Resources → Scripts (los Resources son datos puros)

---

## 🎯 Sistemas Principales y Responsabilidades

### **1. GameManager (Autoload)**

**Responsabilidad**: Orquestar el estado global del juego

```gdscript
# Funciones principales:
- change_scene(scene_path: String)
- pause_game()
- resume_game()
- quit_game()

# Propiedades:
- current_state: GameState (MENU, PLAYING, PAUSED)
- current_world: World
- is_multiplayer: bool
```

**Señales**:
- `game_paused`
- `game_resumed`
- `scene_changed(new_scene: String)`

---

### **2. PlayerData (Autoload)**

**Responsabilidad**: Almacenar datos del jugador

```gdscript
# Propiedades:
- player_name: String
- health: int
- oxygen: int
- inventory: Dictionary  # {block_id: cantidad}
- virtues: Dictionary     # {virtue_id: level}
- luz_interior: int       # Puntos de Luz

# Funciones:
- add_item(item_id: String, amount: int)
- remove_item(item_id: String, amount: int)
- has_item(item_id: String, amount: int) -> bool
- take_damage(amount: int)
- heal(amount: int)
```

**Señales**:
- `health_changed(new_health: int)`
- `inventory_changed`
- `luz_changed(new_luz: int)`

---

### **3. VirtueSystem (Autoload)**

**Responsabilidad**: Gestionar virtudes y Luz Interior

```gdscript
# Propiedades:
- luz_interior: int
- virtues_unlocked: Array[String]
- virtue_levels: Dictionary

# Funciones:
- add_luz(amount: int, reason: String)
- unlock_virtue(virtue_id: String) -> bool
- level_up_virtue(virtue_id: String)
- get_virtue_bonus(virtue_id: String) -> float

# Constantes:
- VIRTUE_FE = "fe"
- VIRTUE_TRABAJO = "trabajo"
- VIRTUE_AMABILIDAD = "amabilidad"
- VIRTUE_RESPONSABILIDAD = "responsabilidad"
- VIRTUE_HONESTIDAD = "honestidad"
```

**Señales**:
- `luz_gained(amount: int, reason: String)`
- `virtue_unlocked(virtue_id: String)`
- `virtue_leveled_up(virtue_id: String, new_level: int)`

---

### **4. ChunkManager (Script)**

**Responsabilidad**: Gestionar chunks del mundo

```gdscript
# Propiedades:
- chunks: Dictionary  # {Vector3i: Chunk}
- render_distance: int = 8

# Funciones:
- get_chunk_at(world_pos: Vector3) -> Chunk
- place_block(world_pos: Vector3, block_type: String)
- break_block(world_pos: Vector3) -> String
- generate_chunk(chunk_pos: Vector3i)
- unload_distant_chunks(player_pos: Vector3)
```

---

### **5. TerrainGenerator (Script)**

**Responsabilidad**: Generar terreno proceduralmente

```gdscript
# Propiedades:
- noise: FastNoiseLite
- seed: int
- height_scale: float = 20.0

# Funciones:
- generate_chunk_data(chunk_pos: Vector3i) -> Array
- get_block_at(world_pos: Vector3) -> String
```

---

## 📊 Diagrama de Clases (Principales)

```
┌──────────────────┐
│   CharacterBody3D │
└────────┬─────────┘
         │ extends
         ▼
┌─────────────────────────┐
│      Player.gd          │
├─────────────────────────┤
│ - health: int           │
│ - oxygen: int           │
│ - velocity: Vector3     │
├─────────────────────────┤
│ + _physics_process()    │
│ + take_damage()         │
│ + interact()            │
└────────┬────────────────┘
         │ tiene
         ▼
┌─────────────────────────┐
│ PlayerMovement.gd       │
├─────────────────────────┤
│ - speed: float          │
│ - jump_force: float     │
├─────────────────────────┤
│ + handle_movement()     │
│ + jump()                │
└─────────────────────────┘

┌──────────────────┐
│      Node3D      │
└────────┬─────────┘
         │ extends
         ▼
┌─────────────────────────┐
│      Chunk.gd           │
├─────────────────────────┤
│ - chunk_pos: Vector3i   │
│ - blocks: Array[Block]  │
│ - mesh: MeshInstance3D  │
├─────────────────────────┤
│ + generate_mesh()       │
│ + place_block()         │
│ + break_block()         │
└─────────────────────────┘

┌──────────────────┐
│    Resource      │
└────────┬─────────┘
         │ extends
         ▼
┌─────────────────────────┐
│   BlockData.gd          │
├─────────────────────────┤
│ - id: String            │
│ - texture: Texture2D    │
│ - hardness: float       │
│ - drops: ItemData       │
├─────────────────────────┤
│ + get_mesh() -> Mesh    │
└─────────────────────────┘
```

---

## 🔐 Principios de Diseño

### **1. Separación de Responsabilidades**

- **Autoloads**: Gestión global, sin lógica de gameplay específica
- **Escenas**: Lógica específica del componente
- **Resources**: Solo datos, sin lógica

### **2. Comunicación por Señales**

Preferir señales sobre referencias directas:

```gdscript
# ❌ MAL (acoplamiento fuerte)
PlayerData.health -= 10
HUD.update_health_bar()

# ✅ BIEN (desacoplado)
PlayerData.take_damage(10)  # Emite signal health_changed
# HUD escucha la señal y se actualiza automáticamente
```

### **3. Data-Driven Design**

Usar Resources para definir datos:

```gdscript
# ❌ MAL (hardcoded)
if block_type == "grass":
    hardness = 1.0
    texture = load("res://...")

# ✅ BIEN (data-driven)
var block_data = load("res://resources/blocks/grass_block.tres")
var hardness = block_data.hardness
var texture = block_data.texture
```

### **4. Modularidad**

Cada sistema debe poder probarse independientemente:

```gdscript
# Cada script tiene una única responsabilidad
PlayerMovement.gd  # Solo movimiento
PlayerInteraction.gd  # Solo interacción con bloques
PlayerCamera.gd  # Solo control de cámara
```

---

## 🚀 Próximos Pasos

Con esta arquitectura definida, el siguiente paso es:

1. **Crear los Autoloads principales**
2. **Implementar el sistema de bloques**
3. **Crear el generador de terreno**
4. **Implementar el jugador con movimiento**

¿Quieres que continúe con el **Paso 3: Roadmap de Desarrollo en 4 Fases**?
