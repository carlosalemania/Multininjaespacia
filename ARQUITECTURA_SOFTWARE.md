# 🏗️ ARQUITECTURA DE SOFTWARE - Multi Ninja Espacial

## 📐 Experiencia de Ingeniería y Arquitectura

Este documento captura todas las **decisiones arquitectónicas, patrones de diseño, y lecciones de ingeniería de software** aplicadas en este proyecto.

---

## 🎯 VISIÓN ARQUITECTÓNICA GENERAL

### Principios Fundamentales Aplicados

#### 1. **Separation of Concerns (SoC)**
```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                       │
│  (UI, GameHUD, MainMenu, PauseMenu)                         │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                     GAME LOGIC LAYER                         │
│  (GameWorld, Player, NPCs, Interactions)                    │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                     DOMAIN LAYER                             │
│  (Enums, Constants, Utils, Systems)                         │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                     DATA LAYER                               │
│  (SaveSystem, PlayerData, ChunkManager)                     │
└─────────────────────────────────────────────────────────────┘
```

#### 2. **Single Responsibility Principle (SRP)**
Cada clase tiene **una única razón para cambiar**:
- `ChunkManager` → Solo gestiona chunks
- `TerrainGenerator` → Solo genera terreno
- `BiomeSystem` → Solo calcula biomas
- `AchievementSystem` → Solo gestiona logros

#### 3. **Dependency Inversion Principle (DIP)**
Los módulos de alto nivel no dependen de módulos de bajo nivel:
```gdscript
# ✅ CORRECTO: GameWorld depende de abstracción
class GameWorld:
    var chunk_manager: ChunkManager  # Interfaz/contrato
    var terrain_generator: TerrainGenerator

    func place_block(pos, type):
        chunk_manager.place_block(pos, type)  # No conoce implementación

# ❌ INCORRECTO: GameWorld conociendo detalles de implementación
class GameWorld:
    func place_block(pos, type):
        # Acceso directo a estructuras internas
        var chunk = chunks_dict[chunk_pos]
        chunk.blocks[local_pos] = type
```

#### 4. **Open/Closed Principle (OCP)**
Abierto para extensión, cerrado para modificación:
```gdscript
# Sistema de herramientas extensible sin modificar código existente
const TOOL_DATA: Dictionary = {
    ToolType.WOODEN_PICKAXE: { ... },
    ToolType.DIAMOND_PICKAXE: { ... },
    # ✅ Nuevas herramientas se añaden sin modificar lógica existente
    ToolType.NEW_SUPER_TOOL: { ... }
}
```

---

## 🧩 PATRONES DE DISEÑO IMPLEMENTADOS

### 1. **Singleton Pattern (Autoloads)**

**Problema:** Necesitamos acceso global a sistemas centrales sin pasar referencias por todo el árbol.

**Solución:** Godot Autoloads (variante de Singleton)

```gdscript
# Configuración en project.godot
[autoload]
GameManager="*res://autoloads/GameManager.gd"
PlayerData="*res://autoloads/PlayerData.gd"
AchievementSystem="*res://autoloads/AchievementSystem.gd"

# Uso desde cualquier parte
func on_block_broken():
    AchievementSystem.increment_stat("blocks_broken", 1)
    PlayerData.add_to_inventory(block_type, 1)
```

**Ventajas:**
- ✅ Acceso global sin acoplamiento
- ✅ Una sola instancia garantizada
- ✅ Inicialización ordenada por Godot

**Desventajas conocidas:**
- ⚠️ Puede crear dependencias ocultas
- ⚠️ Dificulta testing unitario
- ⚠️ Estado global puede causar bugs sutiles

**Mitigación:**
- Usar señales para comunicación cuando sea posible
- Mantener autoloads sin estado cuando sea factible
- Documentar dependencias claramente

---

### 2. **Observer Pattern (Signals)**

**Problema:** Componentes necesitan reaccionar a eventos sin conocerse directamente.

**Solución:** Sistema de señales de Godot

```gdscript
# Emisor (no conoce a receptores)
class AchievementSystem:
    signal achievement_unlocked(achievement_id, achievement_data)

    func _unlock_achievement(id, data):
        achievement_unlocked.emit(id, data)

# Receptor (se subscribe al evento)
class GameHUD:
    func _ready():
        AchievementSystem.achievement_unlocked.connect(_on_achievement)

    func _on_achievement(id, data):
        show_notification(data.name)
```

**Ventajas:**
- ✅ Desacoplamiento total
- ✅ Múltiples observadores sin modificar emisor
- ✅ Fácil de extender

**Casos de uso en el proyecto:**
1. `GameManager.scene_changed` → UI escucha cambios de escena
2. `AchievementSystem.achievement_unlocked` → UI muestra notificación
3. `DayNightCycle.time_period_changed` → GameWorld ajusta comportamiento
4. `PlayerData.luz_changed` → UI actualiza barra

---

### 3. **Factory Pattern (Generación Procedural)**

**Problema:** Crear objetos complejos (chunks, estructuras, árboles) con lógica variable.

**Solución:** Factory methods

```gdscript
# ChunkManager actúa como Factory
class ChunkManager:
    func _create_chunk(chunk_pos: Vector3i) -> Chunk:
        var chunk = chunk_scene.instantiate()
        add_child(chunk)  # ORDEN CRÍTICO
        chunk.initialize(chunk_pos)

        # Delegar generación al generador especializado
        if terrain_generator:
            terrain_generator.generate_chunk_terrain(chunk)

        return chunk

# StructureGenerator actúa como Factory
class StructureGenerator:
    static func try_generate_random_structures(chunk, pos):
        var structure_type = _select_random_structure()
        match structure_type:
            "temple": _generate_templo(chunk, pos)
            "house": _generate_casa(chunk, pos)
            "tower": _generate_torre(chunk, pos)
```

**Ventajas:**
- ✅ Encapsula lógica de creación compleja
- ✅ Fácil añadir nuevos tipos sin modificar código
- ✅ Centraliza configuración

---

### 4. **Strategy Pattern (Herramientas y Habilidades)**

**Problema:** Diferentes herramientas tienen comportamientos diferentes al romper bloques.

**Solución:** Strategy pattern con diccionario de comportamientos

```gdscript
class MagicTool:
    const TOOL_DATA: Dictionary = {
        ToolType.WOODEN_PICKAXE: {
            "speed_multiplier": 2.0,
            "special_ability": ""
        },
        ToolType.HAMMER_OF_THUNDER: {
            "speed_multiplier": 5.0,
            "special_ability": "area_break_3x3"
        }
    }

    static func apply_special_ability(tool_type, world, pos, player):
        var ability = TOOL_DATA[tool_type].special_ability
        match ability:
            "area_break_3x3": _break_area_3x3(world, pos)
            "transmute": _transmute_block(world, pos)
            "reality_warp": _reality_warp(world, pos)
```

**Ventajas:**
- ✅ Comportamientos intercambiables
- ✅ Fácil añadir nuevas estrategias
- ✅ Algoritmos encapsulados

---

### 5. **State Pattern (GameManager)**

**Problema:** El juego tiene diferentes estados (MENU, LOADING, PLAYING, PAUSED) con comportamientos distintos.

**Solución:** Enum de estados con transiciones controladas

```gdscript
class GameManager:
    enum GameState { MENU, LOADING, PLAYING, PAUSED, GAME_OVER }
    var current_state: GameState = GameState.MENU

    func change_state(new_state: GameState):
        _exit_state(current_state)
        current_state = new_state
        _enter_state(new_state)
        state_changed.emit(new_state)

    func _enter_state(state: GameState):
        match state:
            GameState.PLAYING:
                AudioManager.play_gameplay_music()
                Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
            GameState.PAUSED:
                get_tree().paused = true
```

**Ventajas:**
- ✅ Transiciones explícitas y controladas
- ✅ Comportamiento específico por estado
- ✅ Fácil debugging de flujo

---

### 6. **Data-Driven Design (Configuración Externa)**

**Problema:** Balancear juego requiere cambiar constantemente valores numéricos.

**Solución:** Datos separados de lógica en diccionarios constantes

```gdscript
# ✅ Datos centralizados y fáciles de modificar
const BLOCK_HARDNESS: Dictionary = {
    BlockType.TIERRA: 0.5,
    BlockType.PIEDRA: 2.0,
    BlockType.ORO: 4.0
}

const ACHIEVEMENTS: Dictionary = {
    "first_block": {
        "requirement": 1,
        "reward_luz": 5,
        "tier": "bronze"
    }
}

const RECIPES: Dictionary = {
    "diamond_pickaxe": {
        "ingredients": { ORO: 3, CRISTAL: 5 },
        "luz_cost": 100
    }
}
```

**Ventajas:**
- ✅ Cambios de balance sin tocar código
- ✅ Fácil de extender (JSON/CSV en futuro)
- ✅ Diseñadores pueden modificar sin programar

---

## 🏛️ ARQUITECTURA DE SISTEMAS

### Sistema de Chunks (Spatial Partitioning)

**Problema:** Mundo infinito no puede estar todo en memoria.

**Solución:** Chunk-based world con carga/descarga dinámica

```
Arquitectura de Chunks:
┌──────────────────────────────────────────────────────────┐
│                    ChunkManager                          │
│  - Dictionary<Vector3i, Chunk> chunks                    │
│  - Genera chunks según posición del jugador              │
│  - Cachea chunks cercanos                                │
└────────────────┬─────────────────────────────────────────┘
                 │
                 │ gestiona
                 ▼
┌──────────────────────────────────────────────────────────┐
│                       Chunk                              │
│  - Array3D[16][30][16] blocks                           │
│  - MeshInstance3D visual_mesh                           │
│  - StaticBody3D collision_body                          │
└────────────────┬─────────────────────────────────────────┘
                 │
                 │ contiene
                 ▼
        ┌──────────────────┐
        │  Individual Block │
        │  (Enums.BlockType)│
        └──────────────────┘
```

**Decisiones clave:**
1. **Tamaño de chunk: 16x30x16**
   - Razón: Balance entre granularidad y overhead
   - 16x16 XZ → Múltiplo común, fácil de indexar
   - 30 Y → Altura máxima del mundo

2. **Greedy Meshing**
   - Combina caras adyacentes del mismo tipo
   - Reduce triángulos de 6 caras × N bloques a 1 cara × área
   - Mejora rendimiento ~90%

3. **Chunk Pooling (futuro)**
   - Reutilizar chunks descargados en lugar de destruir
   - Reduce garbage collection

**Complejidad:**
- Generación: O(16 × 30 × 16) = O(7680) por chunk
- Búsqueda de bloque: O(1) con hash map
- Mesh generation: O(N) donde N = bloques visibles

---

### Sistema de Generación Procedural

**Pipeline de generación:**

```
1. Semilla del mundo (seed)
         ↓
2. Perlin Noise (FastNoiseLite)
         ↓
3. BiomeSystem.get_biome_at(x, z)
         ↓
4. TerrainGenerator.generate_chunk_terrain()
         ↓
5. StructureGenerator.try_generate_structures()
         ↓
6. Chunk.generate_mesh()
         ↓
7. Chunk visible en el mundo
```

**Algoritmos utilizados:**

#### Perlin Noise
```gdscript
noise = FastNoiseLite.new()
noise.seed = world_seed
noise.noise_type = FastNoiseLite.TYPE_PERLIN
noise.frequency = 0.05

# Valor entre -1.0 y 1.0
var noise_value = noise.get_noise_2d(world_x, world_z)
var normalized = (noise_value + 1.0) / 2.0  # 0.0 a 1.0

# Mapear a altura
var height = int(lerp(min_height, max_height, normalized))
```

**Características:**
- ✅ Determinístico (misma semilla = mismo mundo)
- ✅ Continuo (sin discontinuidades bruscas)
- ✅ Eficiente (O(1) por coordenada)

#### Bioma Selection (Multi-layer Noise)
```gdscript
# Noise para temperatura
var temp_noise = get_noise_2d(x * 0.003, z * 0.003)

# Noise para humedad
var humidity_noise = get_noise_2d(x * 0.004, z * 0.004)

# Mapeo a bioma
if temp < -0.2: return NIEVE
elif humidity > 0.3: return BOSQUE
elif temp > 0.3: return PLAYA
else: return MONTANAS
```

---

### Sistema de Logros (Achievement System)

**Arquitectura:**

```
┌────────────────────────────────────────────────────────┐
│              AchievementSystem (Autoload)              │
├────────────────────────────────────────────────────────┤
│  Stats: Dictionary<String, float>                     │
│    - blocks_placed: 0                                  │
│    - blocks_broken: 0                                  │
│    - distance_walked: 0.0                              │
│                                                        │
│  Achievements: Dictionary<String, AchievementData>     │
│    - first_block: { requirement: 1, ... }             │
│                                                        │
│  Unlocked: Array<String>                              │
│    - ["first_block", "explorer", ...]                 │
└────────────────────────────────────────────────────────┘
         │                           │
         │ emit signal               │ check unlocks
         ▼                           ▼
┌──────────────────┐        ┌──────────────────┐
│  GameHUD         │        │  Player actions  │
│  - show_popup    │        │  - place_block() │
│  - play_sound    │        │  - break_block() │
└──────────────────┘        └──────────────────┘
```

**Patrón de tracking:**
```gdscript
# 1. Acción del jugador
func place_block(pos, type):
    world.place_block(pos, type)

    # 2. Incrementar estadística
    AchievementSystem.increment_stat("blocks_placed", 1)

    # 3. Sistema verifica automáticamente todos los logros
    # 4. Si alguno se desbloquea, emite señal
    # 5. UI escucha señal y muestra notificación
```

**Ventajas arquitectónicas:**
- ✅ Desacoplado de gameplay (no afecta lógica de juego)
- ✅ Extensible (nuevos logros sin modificar código)
- ✅ Persistente (se guarda con SaveSystem)

---

### Sistema de Crafteo (Recipe System)

**Arquitectura:**

```
Recipe Structure:
{
    "diamond_pickaxe": {
        "ingredients": { ORO: 3, CRISTAL: 5, METAL: 2 },
        "luz_cost": 100,
        "result": MagicTool.ToolType.DIAMOND_PICKAXE,
        "tier": "legendary"
    }
}

Validation Flow:
┌─────────────────┐
│ can_craft(id)?  │
└────────┬────────┘
         │
         ▼
┌────────────────────────────────┐
│ Check ingredients in inventory │
└────────┬───────────────────────┘
         │
         ▼
┌────────────────────────────────┐
│ Check Luz Interior sufficient  │
└────────┬───────────────────────┘
         │
         ▼
┌────────────────────────────────┐
│ Return true/false              │
└────────────────────────────────┘

Crafting Flow:
┌─────────────────┐
│ craft_item(id)  │
└────────┬────────┘
         │
         ▼
┌────────────────────────────────┐
│ Consume ingredients            │
└────────┬───────────────────────┘
         │
         ▼
┌────────────────────────────────┐
│ Consume Luz Interior           │
└────────┬───────────────────────┘
         │
         ▼
┌────────────────────────────────┐
│ Give result to player          │
└────────┬───────────────────────┘
         │
         ▼
┌────────────────────────────────┐
│ Increment achievement stat     │
└────────────────────────────────┘
```

**Transaction Pattern:**
```gdscript
func craft_item(recipe_id):
    # Validación atómica
    if not can_craft(recipe_id):
        return false

    # Transacción (todo o nada)
    var recipe = RECIPES[recipe_id]

    # Consumir recursos
    for block_type in recipe.ingredients:
        PlayerData.remove_from_inventory(block_type, amount)
    PlayerData.add_luz(-recipe.luz_cost)

    # Dar resultado
    PlayerData.add_tool(recipe.result)

    # Side effects
    AchievementSystem.increment_stat("items_crafted", 1)
    AudioManager.play_sfx(SoundType.MAGIC_CAST)

    return true
```

---

## 🔄 MANEJO DE ESTADO Y CICLO DE VIDA

### Godot Node Lifecycle

**Orden crítico de inicialización:**

```
Engine Start
    ↓
Autoloads _ready() (orden en project.godot)
    ↓
Main Scene _ready()
    ↓
Child Nodes _ready() (top to bottom)
    ↓
_enter_tree() → _ready() → _process()
```

**Lección crítica aprendida:**
```gdscript
# ❌ INCORRECTO
func _create_chunk(pos):
    var chunk = chunk_scene.instantiate()
    chunk.initialize(pos)  # ❌ chunk no está en árbol
    add_child(chunk)

# ✅ CORRECTO
func _create_chunk(pos):
    var chunk = chunk_scene.instantiate()
    add_child(chunk)       # ✅ Primero añadir al árbol
    chunk.initialize(pos)  # ✅ Luego inicializar
```

**Razón:** `is_inside_tree()` solo retorna `true` después de `add_child()`.

---

### Async Operations y Race Conditions

**Problema:** Chunk generation es async, player spawn es síncrono.

**Solución:** Await frames para sincronización

```gdscript
func _ready():
    _generate_world()  # Inicia generación

    # ✅ Esperar a que chunks se generen
    await get_tree().process_frame
    await get_tree().process_frame

    _spawn_player()  # Ahora chunks están listos
```

**Por qué 2 frames:**
1. Frame 1: ChunkManager crea chunks
2. Frame 2: Chunks generan mesh y colisión
3. Frame 3: Safe para spawner entities

---

## 🎨 ARQUITECTURA DE EFECTOS VISUALES

### Particle System Architecture

```
ParticleEffects (Static Class)
    │
    ├─ Tool Effects
    │   ├─ create_tool_break_effect()
    │   ├─ create_tool_glow()
    │   └─ create_magic_trail()
    │
    ├─ Special Ability Effects
    │   ├─ create_thunder_explosion()
    │   ├─ create_transmute_effect()
    │   ├─ create_freeze_effect()
    │   └─ create_reality_warp_effect()
    │
    ├─ Crafting Effects
    │   └─ create_craft_success_effect()
    │
    └─ Achievement Effects
        └─ create_achievement_effect()
```

**Pattern: Self-Cleaning Particles**
```gdscript
static func create_effect(world, position):
    var particles = GPUParticles3D.new()
    particles.one_shot = true
    particles.emitting = true
    world.add_child(particles)

    # ✅ Auto-destruir después de completar
    await world.get_tree().create_timer(2.0).timeout
    particles.queue_free()
```

**Ventajas:**
- ✅ Sin memory leaks (auto-cleanup)
- ✅ No requiere gestión manual
- ✅ Performa bien (GPU particles)

---

## 🌐 ARQUITECTURA DE MUNDO ABIERTO

### Spatial Indexing

**Problema:** Buscar bloques en mundo infinito es O(N).

**Solución:** Hash map con coordenadas de chunk

```gdscript
# Convertir posición de bloque a chunk
func world_to_chunk_position(world_pos: Vector3i) -> Vector3i:
    return Vector3i(
        floori(float(world_pos.x) / CHUNK_SIZE),
        floori(float(world_pos.y) / CHUNK_SIZE),
        floori(float(world_pos.z) / CHUNK_SIZE)
    )

# Búsqueda O(1)
var chunks: Dictionary = {}  # Dictionary<Vector3i, Chunk>

func get_block(world_pos: Vector3i) -> BlockType:
    var chunk_pos = world_to_chunk_position(world_pos)
    var chunk = chunks.get(chunk_pos)
    if not chunk:
        return BlockType.NONE

    var local_pos = world_pos - chunk_pos * CHUNK_SIZE
    return chunk.get_block(local_pos)
```

**Complejidad:**
- Búsqueda: O(1) average, O(N) worst case (hash collision)
- Inserción: O(1)
- Eliminación: O(1)

---

### LOD (Level of Detail) - Futuro

**Arquitectura propuesta:**

```
Player Position
    ↓
┌───────────────────────────────────────┐
│  Distance-based LOD System            │
├───────────────────────────────────────┤
│  0-32m:   Full detail (all blocks)    │
│  32-64m:  Medium (simplified mesh)    │
│  64-128m: Low (billboard/impostor)    │
│  128m+:   Unloaded                    │
└───────────────────────────────────────┘
```

---

## 🧪 TESTING Y DEBUGGING

### Debugging Strategies Aplicadas

#### 1. Defensive Programming
```gdscript
# ✅ Siempre validar antes de usar
func get_block(pos: Vector3i) -> BlockType:
    if not is_inside_tree():
        push_warning("Chunk not in tree")
        return BlockType.NONE

    if not _is_valid_position(pos):
        push_warning("Invalid position: ", pos)
        return BlockType.NONE

    return blocks[pos.x][pos.y][pos.z]
```

#### 2. Null Safety
```gdscript
# ✅ Usar get() con default en lugar de []
var chunk = chunks.get(chunk_pos)  # Retorna null si no existe
if chunk:
    chunk.do_something()

# ✅ Verificar referencias antes de usar
if terrain_generator and terrain_generator.has_method("generate"):
    terrain_generator.generate_chunk_terrain(chunk)
```

#### 3. Assertion Pattern
```gdscript
func initialize(chunk_pos: Vector3i):
    assert(is_inside_tree(), "Chunk debe estar en árbol antes de inicializar")
    assert(chunk_pos.y >= 0, "Chunk Y debe ser >= 0")
    self.chunk_position = chunk_pos
```

---

## 📊 PERFORMANCE Y OPTIMIZACIÓN

### Memory Management

**Godot Memory Model:**
```
Stack (local variables)
    ↓
Heap (objetos con new())
    ↓
Scene Tree (nodos con add_child())
    ↓
Godot Resource Manager (texturas, meshes)
```

**Estrategias aplicadas:**

#### 1. Object Pooling (concepto)
```gdscript
# Futuro: Pool de chunks para reutilizar
var chunk_pool: Array[Chunk] = []

func get_chunk_from_pool() -> Chunk:
    if chunk_pool.size() > 0:
        return chunk_pool.pop_back()  # Reutilizar
    else:
        return Chunk.new()  # Crear nuevo

func return_chunk_to_pool(chunk: Chunk):
    chunk.clear()
    chunk_pool.append(chunk)
```

#### 2. Lazy Initialization
```gdscript
# ✅ Crear solo cuando se necesita
var _day_night_cycle: DayNightCycle = null

func get_day_night_cycle() -> DayNightCycle:
    if not _day_night_cycle:
        _day_night_cycle = DayNightCycle.new()
        add_child(_day_night_cycle)
    return _day_night_cycle
```

#### 3. Greedy Meshing (Chunk Optimization)
```
Sin optimización:       Con Greedy Meshing:
6 caras × 7680 bloques  ~1000 caras (combinadas)
= 46,080 triángulos     = ~2000 triángulos
                        90% reducción! ✅
```

---

## 🔐 SEGURIDAD Y VALIDACIÓN

### Input Validation

```gdscript
# ✅ Validar bounds antes de acceder a arrays
func set_block(pos: Vector3i, type: BlockType):
    if pos.x < 0 or pos.x >= CHUNK_SIZE:
        return false
    if pos.y < 0 or pos.y >= MAX_HEIGHT:
        return false
    if pos.z < 0 or pos.z >= CHUNK_SIZE:
        return false

    blocks[pos.x][pos.y][pos.z] = type
    return true
```

### Safe Resource Loading

```gdscript
# ✅ Verificar que recursos existan
func load_safe(path: String):
    if not FileAccess.file_exists(path):
        push_error("Archivo no encontrado: ", path)
        return null

    var resource = load(path)
    if not resource:
        push_error("No se pudo cargar: ", path)
        return null

    return resource
```

---

## 🎓 LECCIONES DE ARQUITECTURA

### 1. **Composition over Inheritance**

```gdscript
# ❌ EVITAR: Herencia profunda
class Entity extends Node3D
class LivingEntity extends Entity
class Player extends LivingEntity  # 3 niveles

# ✅ PREFERIR: Composición
class Player extends CharacterBody3D:
    var movement_component: PlayerMovement
    var interaction_component: PlayerInteraction
    var camera_component: CameraController
```

**Por qué:**
- Más flexible (componentes intercambiables)
- Más testeable (componentes aislados)
- Menos acoplamiento

---

### 2. **Explicit Dependencies**

```gdscript
# ❌ EVITAR: Dependencias implícitas
class Player:
    func _ready():
        var world = get_parent()  # ¿Quién es parent?

# ✅ PREFERIR: Dependencias explícitas
class Player:
    @export var world: GameWorld  # Claro y verificable

    func _ready():
        assert(world != null, "Player requiere GameWorld")
```

---

### 3. **Fail Fast Principle**

```gdscript
# ✅ Detectar errores temprano
func initialize(chunk_pos: Vector3i):
    if not is_inside_tree():
        push_error("CRITICAL: Chunk not in tree!")
        return

    if chunk_pos.y < 0:
        push_error("CRITICAL: Invalid chunk Y")
        return

    # Continuar solo si todo está OK
```

---

### 4. **Immutability Where Possible**

```gdscript
# ✅ Constantes para datos que no cambian
const CHUNK_SIZE: int = 16
const MAX_WORLD_HEIGHT: int = 30

# ✅ Diccionarios constantes
const BLOCK_COLORS: Dictionary = { ... }

# ❌ Evitar variables globales mutables sin necesidad
var global_counter: int = 0  # Difícil de rastrear cambios
```

---

### 5. **Clear API Boundaries**

```gdscript
# ✅ API pública clara
class ChunkManager:
    # Métodos públicos
    func place_block(pos: Vector3i, type: BlockType) -> bool
    func remove_block(pos: Vector3i) -> bool
    func get_block(pos: Vector3i) -> BlockType

    # Métodos privados (prefijo _)
    func _create_chunk(pos: Vector3i) -> Chunk
    func _destroy_chunk(chunk: Chunk) -> void
```

---

## 📚 REFERENCIAS Y RECURSOS

### Patrones de Diseño Aplicados
- **Gang of Four (GoF) Patterns:**
  - Singleton (Autoloads)
  - Observer (Signals)
  - Factory (Chunk creation)
  - Strategy (Tool behaviors)
  - State (GameState)

### Principios SOLID
- ✅ **S**ingle Responsibility
- ✅ **O**pen/Closed
- ✅ **L**iskov Substitution
- ✅ **I**nterface Segregation
- ✅ **D**ependency Inversion

### Game Programming Patterns
- Spatial Partitioning (Chunks)
- Data-Driven Design (JSON-like configs)
- Object Pool (futuro)
- Dirty Flag (mesh regeneration)
- Component Pattern (Player components)

---

## 🚀 ESCALABILIDAD FUTURA

### Arquitectura para Multijugador

```
┌─────────────────────────────────────────────────────┐
│                  Network Layer                      │
│  - NetworkManager (autoload)                        │
│  - Replication de chunks                            │
│  - Sync de player positions                         │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│                  Authority System                    │
│  - Server = authoridad de chunks                    │
│  - Clients = predicción optimista                   │
│  - Rollback en caso de desync                       │
└─────────────────────────────────────────────────────┘
```

### Arquitectura para Modding

```
┌─────────────────────────────────────────────────────┐
│                    Mod Loader                       │
│  - Lee mods desde res://mods/                      │
│  - Valida scripts                                   │
│  - Inyecta en puntos de extensión                  │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│                 Extension Points                     │
│  - new_block_types[]                                │
│  - new_tools[]                                      │
│  - new_biomes[]                                     │
│  - custom_structures[]                              │
└─────────────────────────────────────────────────────┘
```

---

## 🎯 CONCLUSIONES DE ARQUITECTURA

### Lo que funcionó bien ✅

1. **Autoloads para sistemas globales**
   - Fácil acceso sin pasar referencias
   - Inicialización ordenada

2. **Signals para desacoplamiento**
   - Componentes independientes
   - Fácil de extender

3. **Data-driven design**
   - Balance sin tocar código
   - Fácil experimentación

4. **Chunk-based world**
   - Mundo infinito con memoria finita
   - Buena performance

5. **Separation of concerns**
   - Cada sistema tiene responsabilidad clara
   - Fácil de mantener

### Lo que mejoraría 🔄

1. **Testing automatizado**
   - Añadir unit tests para sistemas críticos
   - Integration tests para generación de mundo

2. **Dependency Injection**
   - Reducir dependencias de autoloads
   - Más testeable

3. **ECS (Entity Component System)**
   - Para muchas entidades (NPCs, enemigos)
   - Mejor performance con cache locality

4. **Profiling tools**
   - Monitorear performance en runtime
   - Detectar bottlenecks

5. **Documentation as code**
   - Docstrings en todas las funciones públicas
   - Generar docs automáticas

---

## 📖 GLOSARIO DE ARQUITECTURA

**Autoload:** Singleton de Godot que se inicializa al inicio y persiste toda la sesión.

**Chunk:** Subdivisión espacial del mundo para optimización de memoria y rendering.

**Signal:** Patrón Observer de Godot para comunicación desacoplada entre nodos.

**Greedy Meshing:** Algoritmo de optimización que combina caras adyacentes similares.

**Spatial Partitioning:** Técnica de dividir espacio 3D para búsquedas eficientes.

**Procedural Generation:** Generación algorítmica de contenido usando semillas determinísticas.

**Data-Driven Design:** Separar datos de lógica para fácil modificación sin recompilar.

---

**Este documento representa la experiencia arquitectónica completa del proyecto.**

**Fecha:** 2025
**Versión del Proyecto:** 1.0
**Engine:** Godot 4.5.1
**Paradigma:** OOP + ECS híbrido
**Patrones:** 10+ patrones de diseño aplicados
**Principios:** SOLID + Game Programming Patterns
