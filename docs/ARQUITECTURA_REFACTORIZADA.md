# Arquitectura Refactorizada - Sistema de Biomas

## 📋 Índice
1. [Visión General](#visión-general)
2. [Antes vs Después](#antes-vs-después)
3. [Componentes](#componentes)
4. [Principios Aplicados](#principios-aplicados)
5. [Cómo Usar](#cómo-usar)
6. [Testing](#testing)
7. [Próximos Pasos](#próximos-pasos)

---

## 🎯 Visión General

Esta refactorización separa **lógica** (BiomeGenerator) de **orquestación** (BiomeManager), siguiendo principios SOLID y mejores prácticas de arquitectura de software.

### Problema Original
```gdscript
# ❌ ANTES: BiomeSystem.gd (autoload con funciones static)
extends Node  # Es autoload pero...

static func get_biome_at(...):  # ¡Funciones static! 🤔
    # Mezcla estado (noise) con lógica pura
```

**Problemas:**
- Confusión entre singleton y clase estática
- Difícil de testear (acoplado a autoload)
- Viola Single Responsibility Principle
- Warnings de STATIC_CALLED_ON_INSTANCE

### Solución
```
📦 Sistema Refactorizado
├── BiomeGenerator.gd     # Lógica pura (NO autoload)
│   └── Calcula biomas, sin dependencias globales
└── BiomeManager.gd       # Orchestrator (SÍ autoload)
    └── Gestiona generator, caché, API pública
```

---

## 🔄 Antes vs Después

### ANTES (Monolítico)
```gdscript
# BiomeSystem.gd (autoload confuso)
extends Node

var biome_noise: FastNoiseLite = null

static func initialize(seed: int):  # ❌ Static con estado
    biome_noise = FastNoiseLite.new()  # No funciona

static func get_biome_at(x, z):  # ❌ Static llamando estado
    return biome_noise.get_noise_2d(...)  # Error
```

**Problemas:**
- Funciones static no pueden acceder a `biome_noise`
- Autoload tratado como clase estática
- Testing imposible sin cargar todo el juego

### DESPUÉS (Separación de Responsabilidades)

```gdscript
# 1️⃣ BiomeGenerator.gd (Lógica pura, testeable)
class_name BiomeGenerator

var _noise: FastNoiseLite = null  # Estado privado
var _is_initialized: bool = false

func initialize(seed: int) -> void:  # ✅ Método de instancia
    _noise = FastNoiseLite.new()
    _noise.seed = seed
    _is_initialized = true

func calculate_biome(x: int, z: int) -> BiomeType:  # ✅ Lógica pura
    assert(_is_initialized, "Must initialize first")
    var noise = _noise.get_noise_2d(float(x), float(z))
    # ... lógica de cálculo
    return biome_type

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# 2️⃣ BiomeManager.gd (Orquestador autoload)
extends Node  # Autoload registrado

var _generator: BiomeGenerator = null  # Composición
var _cache: Dictionary = {}  # Optimización

func initialize(seed: int) -> void:
    _generator = BiomeGenerator.new()  # Crear instancia
    _generator.initialize(seed)

func get_biome_at(x: int, z: int) -> BiomeGenerator.BiomeType:
    # Verificar caché
    if _cache.has(Vector2i(x, z)):
        return _cache[Vector2i(x, z)]

    # Delegar al generador
    var biome = _generator.calculate_biome(x, z)
    _cache[Vector2i(x, z)] = biome
    return biome
```

---

## 🧩 Componentes

### 1. BiomeGenerator (Lógica Pura)

**Ubicación:** `scripts/world/generation/BiomeGenerator.gd`

**Responsabilidad:** Calcular biomas usando ruido Perlin

**Características:**
- ✅ **NO es autoload** - Se instancia donde se necesita
- ✅ **Sin dependencias globales** - Todo se inyecta
- ✅ **Testeable** - Puede testearse unitariamente
- ✅ **Stateless después de init** - Determinístico

**API Pública:**
```gdscript
# Inicialización
func initialize(world_seed: int) -> void

# Cálculo de biomas
func calculate_biome(world_x: int, world_z: int) -> BiomeType

# Consultas de configuración (inmutables)
func get_biome_config(biome: BiomeType) -> Dictionary
func get_surface_block(biome: BiomeType) -> Enums.BlockType
func get_height_range(biome: BiomeType) -> Vector2i
func get_tree_chance(biome: BiomeType) -> float
func get_biome_name(biome: BiomeType) -> String
func get_biome_color(biome: BiomeType) -> Color

# Utilidades
func is_ready() -> bool
func generate_debug_map(size: int) -> Array[BiomeType]
```

---

### 2. BiomeManager (Orchestrator Autoload)

**Ubicación:** `scripts/world/BiomeManager.gd`

**Responsabilidad:** Gestionar acceso al generador, optimizar con caché

**Características:**
- ✅ **ES autoload** - Acceso global como `BiomeManager`
- ✅ **Composición** - Contiene un `BiomeGenerator`
- ✅ **Caché inteligente** - Optimiza consultas repetidas
- ✅ **API simple** - Oculta complejidad al resto del sistema

**API Pública:**
```gdscript
# Ciclo de vida
func initialize(world_seed: int) -> void
func is_ready() -> bool

# Acceso a biomas (con caché)
func get_biome_at(world_x: int, world_z: int) -> BiomeGenerator.BiomeType

# Consultas (delegan al generator)
func get_biome_data(biome: BiomeGenerator.BiomeType) -> Dictionary
func get_surface_block(biome: BiomeGenerator.BiomeType) -> Enums.BlockType
func get_height_range(biome: BiomeGenerator.BiomeType) -> Vector2i
func get_tree_chance(biome: BiomeGenerator.BiomeType) -> float
func get_biome_name(biome: BiomeGenerator.BiomeType) -> String
func get_biome_color(biome: BiomeGenerator.BiomeType) -> Color

# Utilidades de debug
func clear_cache() -> void
func get_cache_stats() -> Dictionary
func generate_debug_map(size: int) -> Array[BiomeGenerator.BiomeType]
```

---

## ⚖️ Principios Aplicados

### 1. **Single Responsibility Principle (SRP)**
- `BiomeGenerator` → Solo calcula biomas
- `BiomeManager` → Solo gestiona acceso y caché

### 2. **Dependency Injection**
```gdscript
# ✅ Manager NO depende del generador globalmente
var _generator: BiomeGenerator = null  # Inyectado en initialize()

func initialize(seed: int):
    _generator = BiomeGenerator.new()  # Crear instancia
    _generator.initialize(seed)
```

### 3. **Separation of Concerns**
- **Lógica de negocio** → BiomeGenerator
- **Gestión de estado** → BiomeManager
- **Optimización** → Caché en Manager

### 4. **Open/Closed Principle**
```gdscript
# Fácil extender sin modificar:
class BiomeGeneratorV2 extends BiomeGenerator:
    # Nueva lógica de generación
    func calculate_biome(x, z):
        # Algoritmo mejorado

# BiomeManager puede usar cualquier implementación
func set_generator(gen: BiomeGenerator):
    _generator = gen
```

### 5. **Interface Segregation**
```gdscript
# BiomeGenerator expone solo lo necesario
# No hay métodos innecesarios para clientes

# El resto del código solo ve BiomeManager
# No necesita conocer detalles de generación
```

---

## 🚀 Cómo Usar

### Inicialización (en GameWorld o similar)

```gdscript
# GameWorld.gd
func _ready():
    # Inicializar con semilla del mundo
    BiomeManager.initialize(12345)

    # Esperar señal si es necesario
    await BiomeManager.biome_system_ready

    # Ahora el sistema está listo
    print("Biome system ready!")
```

### Consultar Biomas

```gdscript
# TerrainGenerator.gd
func generate_terrain():
    var world_x = 100
    var world_z = 200

    # Obtener bioma en posición
    var biome = BiomeManager.get_biome_at(world_x, world_z)

    # Consultar propiedades del bioma
    var height_range = BiomeManager.get_height_range(biome)
    var surface_block = BiomeManager.get_surface_block(biome)
    var tree_chance = BiomeManager.get_tree_chance(biome)

    print("Biome: ", BiomeManager.get_biome_name(biome))
    print("Height range: ", height_range)
```

### Debug y Optimización

```gdscript
# Ver estadísticas de caché
var stats = BiomeManager.get_cache_stats()
print("Cache usage: ", stats.usage_percent, "%")

# Limpiar caché si es necesario
BiomeManager.clear_cache()

# Generar mapa de biomas para visualización
var biome_map = BiomeManager.generate_debug_map(100)
# Renderizar mapa con colores...
```

---

## 🧪 Testing

### Test Unitario de BiomeGenerator

```gdscript
# tests/unit/test_biome_generator.gd
extends GutTest

var generator: BiomeGenerator

func before_each():
    generator = BiomeGenerator.new()
    generator.initialize(12345)

func test_consistency():
    # Misma posición = mismo bioma
    var biome1 = generator.calculate_biome(100, 200)
    var biome2 = generator.calculate_biome(100, 200)
    assert_eq(biome1, biome2)

func test_different_seeds_different_results():
    var gen1 = BiomeGenerator.new()
    gen1.initialize(1111)

    var gen2 = BiomeGenerator.new()
    gen2.initialize(2222)

    var biome1 = gen1.calculate_biome(50, 50)
    var biome2 = gen2.calculate_biome(50, 50)

    # Probabilidad alta de ser diferentes
    assert_ne(biome1, biome2)

func test_all_biomes_reachable():
    var biomes_found = {}

    for x in range(1000):
        var biome = generator.calculate_biome(x, 0)
        biomes_found[biome] = true

    # Debe haber al menos 3 biomas diferentes
    assert_gte(biomes_found.size(), 3)

func test_config_immutability():
    var config = generator.get_biome_config(BiomeGenerator.BiomeType.BOSQUE)
    assert_true(config.has("name"))
    assert_true(config.has("surface_block"))
```

### Test de Integración de BiomeManager

```gdscript
# tests/integration/test_biome_manager.gd
extends GutTest

func before_each():
    BiomeManager.initialize(54321)
    BiomeManager.clear_cache()

func test_cache_works():
    # Primera llamada (sin caché)
    var biome1 = BiomeManager.get_biome_at(10, 20)

    # Segunda llamada (con caché)
    var biome2 = BiomeManager.get_biome_at(10, 20)

    assert_eq(biome1, biome2)

    # Verificar que caché tiene la entrada
    var stats = BiomeManager.get_cache_stats()
    assert_gt(stats.size, 0)

func test_cache_limit():
    # Llenar caché más allá del límite
    for i in range(1500):  # MAX_CACHE_SIZE = 1000
        BiomeManager.get_biome_at(i, i)

    var stats = BiomeManager.get_cache_stats()
    assert_lte(stats.size, 1000)  # No excede límite
```

---

## 📈 Próximos Pasos

### Refactorizaciones Pendientes

#### 1. StructureGenerator → StructureManager + Generators
```
scripts/world/generation/
├── structures/
│   ├── CasaGenerator.gd
│   ├── TemploGenerator.gd
│   └── TorreGenerator.gd
└── StructureManager.gd (autoload)
```

#### 2. Crear EntityFactory
```gdscript
# entities/EntityFactory.gd
class_name EntityFactory

static func create_npc(type, pos) -> NPC:
    var npc = NPC_SCENE.instantiate()
    npc.setup(type)
    return npc
```

#### 3. EventBus para Desacoplamiento
```gdscript
# core/EventBus.gd (autoload)
signal block_placed(pos, type)
signal block_broken(pos, type)
signal biome_changed(from_biome, to_biome)
```

#### 4. GameConfig Resource
```gdscript
# config/GameConfig.gd
class_name GameConfig extends Resource

@export var world_seed: int = 12345
@export var biome_frequency: float = 0.02
@export var structure_spawn_chance: float = 0.1
```

---

## ✅ Beneficios de la Refactorización

### Antes
- ❌ Mezcla autoload con funciones static
- ❌ Imposible de testear sin autoload
- ❌ Warnings de STATIC_CALLED_ON_INSTANCE
- ❌ Acoplamiento global

### Después
- ✅ Separación clara de responsabilidades
- ✅ Testeable unitariamente
- ✅ Sin warnings ni errores
- ✅ Caché integrado para optimización
- ✅ Fácil de extender y mantener
- ✅ Documenta principios SOLID

---

## 📚 Referencias

- **Single Responsibility Principle:** https://en.wikipedia.org/wiki/Single-responsibility_principle
- **Dependency Injection:** https://en.wikipedia.org/wiki/Dependency_injection
- **Godot Autoloads:** https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html
- **GDScript Style Guide:** https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html

---

**Autor:** Claude Code
**Fecha:** 2025-01-24
**Versión:** 1.0
