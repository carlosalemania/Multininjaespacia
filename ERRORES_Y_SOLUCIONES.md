# 🐛 ERRORES Y SOLUCIONES - Multi Ninja Espacial

## 📚 Guía completa de todos los errores encontrados y cómo se resolvieron

---

## ❌ ERROR 1: Invalid operands to operator * (String and int)

### **Ubicación:** `scripts/main/Main.gd` línea 14

### **Error completo:**
```
Parse Error: Invalid operands to the * operator. No common type found
between "String" and "int".
At: res://scripts/main/Main.gd:14
```

### **Código problemático:**
```gdscript
print("=" * 60)  # Sintaxis de Python, NO funciona en GDScript
```

### **Causa raíz:**
GDScript NO soporta multiplicación de strings como Python. En Python `"=" * 60` produce 60 caracteres `=`, pero GDScript no tiene esta característica.

### **Soluciones intentadas:**

#### Intento 1: `.repeat()` method
```gdscript
print("=".repeat(60))
```
**Resultado:** No funcionó debido a problemas de caché de Godot.

#### Intento 2: Eliminar caché `.godot`
```bash
rm -rf .godot
```
**Resultado:** Godot seguía usando versión cacheada.

#### Intento 3: Reload Project
Desde Godot: Project → Reload Current Project
**Resultado:** Todavía no cargaba la nueva versión.

### **✅ SOLUCIÓN FINAL:**
Usar string literal manual:
```gdscript
print("============================================================")
print("Multi Ninja Espacial - Iniciando...")
print("============================================================")
```

### **Lección aprendida:**
- GDScript NO es Python, evitar sintaxis de Python
- Usar strings literales o `.repeat()` para repetición
- Si `.repeat()` no funciona, borrar `.godot` y reiniciar Godot completamente

---

## ❌ ERROR 2: Main.tscn sin script adjunto

### **Ubicación:** `scenes/main/Main.tscn`

### **Síntoma:**
El juego se iniciaba, mostraba el menú, pero el script `Main.gd` nunca se ejecutaba. No había errores en consola, simplemente el código en `_ready()` no corría.

### **Causa raíz:**
El archivo `.tscn` no tenía la referencia al script. Un archivo `.tscn` necesita explícitamente declarar qué script está adjunto al nodo.

### **Código faltante:**
```godot
[ext_resource type="Script" uid="uid://bsc2rag07ljcx" path="res://scripts/main/Main.gd" id="1_main"]

[node name="Main" type="Node"]
script = ExtResource("1_main")
```

### **✅ SOLUCIÓN:**
Añadir las líneas de ExtResource y script property al archivo `.tscn`.

### **Cómo prevenir:**
- Siempre crear escenas desde el editor de Godot (click derecho → Attach Script)
- Si editas `.tscn` manualmente, verificar que tenga `script = ExtResource(...)`
- Verificar en el Inspector que el script esté adjunto

---

## ❌ ERROR 3: ChunkManager - Condition '!is_inside_tree()' is true

### **Ubicación:** `scripts/world/ChunkManager.gd` (108 errores)

### **Error completo:**
```
E 0:00:01:0450   set_block: Condition "!is_inside_tree()" is true.
  <C++ Source>   scene/main/node.cpp:2570 @ set_block()
  <Stack Trace>  scripts/world/Chunk.gd:87 @ set_block()
                 scripts/world/ChunkManager.gd:143 @ _create_chunk()
```

### **Causa raíz:**
El Chunk se estaba inicializando (`chunk.initialize()`) ANTES de ser añadido al árbol de escena (`add_child()`). Los nodos en Godot deben estar en el árbol antes de llamar a métodos que dependen de `is_inside_tree()`.

### **Código problemático:**
```gdscript
func _create_chunk(chunk_pos: Vector3i) -> Chunk:
    var chunk = chunk_scene.instantiate()

    chunk.initialize(chunk_pos)  # ❌ ERROR: chunk no está en el árbol todavía
    add_child(chunk)              # Agregado después

    return chunk
```

### **✅ SOLUCIÓN:**
Invertir el orden - añadir al árbol PRIMERO, luego inicializar:
```gdscript
func _create_chunk(chunk_pos: Vector3i) -> Chunk:
    var chunk = chunk_scene.instantiate()

    # ✅ Añadir al árbol PRIMERO
    add_child(chunk)

    # ✅ Luego inicializar (ahora está en el árbol)
    chunk.initialize(chunk_pos)

    # Generar terreno
    if terrain_generator:
        terrain_generator.generate_chunk_terrain(chunk)

    chunks[chunk_pos] = chunk
    return chunk
```

### **Lección aprendida:**
- Siempre `add_child()` ANTES de llamar a métodos que necesitan el árbol
- `is_inside_tree()` retorna `true` solo después de `add_child()`
- Orden correcto: instanciar → add_child() → inicializar/configurar

---

## ❌ ERROR 4: AudioManager - Index p_bus = -1 is out of bounds

### **Ubicación:** `autoloads/AudioManager.gd`

### **Error completo:**
```
E 0:00:00:0242   set_bus_volume_db: Index p_bus = -1 is out of bounds (buses.size() = 1).
  <C++ Source>   servers/audio_server.cpp:450 @ set_bus_volume_db()
```

### **Causa raíz:**
Intentar acceder a buses de audio ("Music", "SFX") que no existen todavía. `AudioServer.get_bus_index()` retorna `-1` si el bus no existe.

### **Código problemático:**
```gdscript
func _update_music_volume() -> void:
    var bus_idx = AudioServer.get_bus_index("Music")
    # Si bus no existe, bus_idx = -1
    AudioServer.set_bus_volume_db(bus_idx, linear_to_db(music_volume))  # ❌ ERROR
```

### **✅ SOLUCIÓN:**
Añadir validación antes de usar el índice:
```gdscript
func _update_music_volume() -> void:
    var bus_idx = AudioServer.get_bus_index("Music")
    if bus_idx == -1:
        return  # ✅ Bus no existe, salir silenciosamente

    if music_muted:
        AudioServer.set_bus_volume_db(bus_idx, -80)
    else:
        AudioServer.set_bus_volume_db(bus_idx, linear_to_db(music_volume))

func _update_sfx_volume() -> void:
    var bus_idx = AudioServer.get_bus_index("SFX")
    if bus_idx == -1:
        return  # ✅ Bus no existe, salir silenciosamente

    if sfx_muted:
        AudioServer.set_bus_volume_db(bus_idx, -80)
    else:
        AudioServer.set_bus_volume_db(bus_idx, linear_to_db(sfx_volume))
```

### **Lección aprendida:**
- Siempre validar índices de buses de audio
- `get_bus_index()` retorna `-1` si no existe
- Usar `if bus_idx == -1: return` como guarda

---

## ❌ ERROR 5: GameManager - Parent node is busy adding/removing children

### **Ubicación:** `autoloads/GameManager.gd`

### **Error completo:**
```
E 0:00:02:0120   change_scene_to_file: Parent node is busy adding/removing children.
                 Use 'call_deferred' to avoid conflicts.
```

### **Causa raíz:**
Cambiar escenas durante `_ready()` o mientras Godot está procesando el árbol de escena causa conflictos. Godot no permite modificar el árbol mientras lo está recorriendo.

### **Código problemático:**
```gdscript
func change_scene(scene_path: String) -> void:
    get_tree().change_scene_to_file(scene_path)  # ❌ ERROR si se llama durante _ready()
```

### **✅ SOLUCIÓN:**
Usar `call_deferred()` para diferir la operación al siguiente frame:
```gdscript
func change_scene(scene_path: String) -> void:
    print("📦 Cambiando a escena: ", scene_path)
    scene_changed.emit(scene_path)
    get_tree().change_scene_to_file.call_deferred(scene_path)  # ✅ Diferido
```

### **Lección aprendida:**
- Usar `call_deferred()` para operaciones que modifican el árbol
- Especialmente importante en `_ready()`, `_process()`, y callbacks de señales
- También aplica a: `add_child()`, `remove_child()`, `queue_free()`

---

## ❌ ERROR 6: Player cayendo a través del mundo

### **Ubicación:** `scripts/core/Constants.gd` y `scripts/game/GameWorld.gd`

### **Síntoma:**
El jugador aparecía en el cielo y caía infinitamente. "el ojeto se fue poniendo pequeno y subio al cielo".

### **Causa raíz:**
Dos problemas:
1. `PLAYER_SPAWN_HEIGHT = 50.0` pero el terreno solo tenía 10-15 bloques de altura
2. El jugador se spawneaba ANTES de que los chunks se generaran

### **Código problemático:**
```gdscript
# Constants.gd
const PLAYER_SPAWN_HEIGHT: float = 50.0  # ❌ Demasiado alto

# GameWorld.gd
func _ready() -> void:
    _generate_world()
    _spawn_player()  # ❌ Inmediato, chunks no están listos
```

### **✅ SOLUCIÓN:**
1. Reducir altura de spawn:
```gdscript
# Constants.gd
const PLAYER_SPAWN_HEIGHT: float = 20.0  # ✅ Altura razonable
```

2. Esperar a que los chunks se generen:
```gdscript
# GameWorld.gd
func _ready() -> void:
    _generate_world()

    # ✅ Esperar 2 frames para que los chunks se generen
    await get_tree().process_frame
    await get_tree().process_frame

    _spawn_player()
```

3. Buscar superficie segura:
```gdscript
func _find_safe_spawn_position(default_pos: Vector3) -> Vector3:
    var block_x = int(default_pos.x)
    var block_z = int(default_pos.z)

    # Buscar desde arriba hacia abajo el primer bloque sólido
    for y in range(Constants.MAX_WORLD_HEIGHT - 1, -1, -1):
        var block_type = get_block(Vector3i(block_x, y, block_z))

        if block_type != Enums.BlockType.NONE:
            # Encontró terreno, spawn 2 bloques arriba
            return Vector3(float(block_x) + 0.5, float(y + 2), float(block_z) + 0.5)

    return default_pos
```

### **Lección aprendida:**
- Siempre esperar a que el terreno se genere antes de spawnear entidades
- Usar `await get_tree().process_frame` para esperar generación
- Implementar búsqueda de superficie segura para spawn dinámico
- Ajustar constantes según características del terreno

---

## ⚠️ WARNING 7: INTEGER_DIVISION usado sin división entera

### **Ubicación:** `autoloads/AudioManager.gd`

### **Warning:**
```
W 0:00:00:0412   GDScript: The result of dividing '/' two integers will be
                 truncated. Use '/' for float division or '//' for integer division.
```

### **Código problemático:**
```gdscript
var time_minutes = int(time / 60)  # ❌ División entera sin //
var time_seconds = int(time % 60)
```

### **✅ SOLUCIÓN:**
Usar `//` para división entera explícita:
```gdscript
var time_minutes = time // 60  # ✅ División entera explícita
var time_seconds = time % 60
```

### **Lección aprendida:**
- Usar `//` para división entera
- Usar `/` solo para división con decimales
- GDScript 4.x es más estricto con tipos

---

## ⚠️ WARNING 8: UNUSED_PARAMETER en funciones con parámetros no usados

### **Ubicación:** Varios archivos

### **Warning:**
```
W 0:00:00:0412   GDScript: Parameter 'param_name' is never used in the function.
```

### **✅ SOLUCIÓN:**
Prefijo con `_` para indicar que es intencional:
```gdscript
# ❌ Antes
func my_callback(param1, param2, param3):
    print(param1)  # Solo usa param1

# ✅ Después
func my_callback(param1, _param2, _param3):
    print(param1)  # param2 y param3 marcados como intencionalmente no usados
```

O eliminar parámetros no usados si no son necesarios.

---

## 🗂️ ERROR 9: Godot Cache Problems (archivos no se recargan)

### **Síntoma:**
Cambios en archivos `.gd` no se reflejan en Godot, incluso después de guardar y recargar.

### **Causa raíz:**
Godot cachea archivos compilados en la carpeta `.godot/`. A veces este caché se corrompe o no se actualiza.

### **✅ SOLUCIONES (en orden de severidad):**

#### Opción 1: Reload Current Project
```
Project → Reload Current Project
```
Funciona para cambios pequeños.

#### Opción 2: Cerrar y reabrir Godot
Cerrar completamente Godot (Cmd+Q en Mac) y volver a abrir.

#### Opción 3: Eliminar caché (MÁS EFECTIVO)
```bash
cd /Users/carlosgarcia/Desktop/Proyectos/C++/multininjaespacial
rm -rf .godot
```
Luego abrir Godot y esperar 60 segundos mientras reimporta todo.

### **Cuándo usar cada opción:**
- Cambios menores → Reload Project
- Cambios en scripts → Cerrar/reabrir Godot
- Cambios estructurales o errores persistentes → Eliminar `.godot`

### **Lección aprendida:**
- La carpeta `.godot` es regenerable, seguro eliminarla
- Siempre hacer backup antes de cambios grandes
- Considerar añadir `.godot` a `.gitignore` (ya debería estar)

---

## 🎨 ERROR 10: Colores de bloques no se actualizaban

### **Ubicación:** `scripts/core/Utils.gd`

### **Síntoma:**
Cambios en `get_block_color()` no se reflejaban en el juego, los bloques seguían con colores viejos.

### **Causa raíz:**
Los meshes de chunks ya generados no se regeneraban automáticamente cuando cambiaban los colores.

### **✅ SOLUCIÓN:**
Eliminar chunks existentes para forzar regeneración:
```bash
rm -rf .godot
```

Luego en el futuro, implementar sistema de regeneración:
```gdscript
# En ChunkManager.gd
func regenerate_all_chunks() -> void:
    for chunk_pos in chunks:
        var chunk = chunks[chunk_pos]
        chunk.regenerate_mesh()  # Método que fuerza regeneración de mesh
```

### **Lección aprendida:**
- Cambios en datos estáticos (colores, constantes) requieren regeneración
- Considerar hot-reload para desarrollo
- Documentar qué cambios requieren eliminar `.godot`

---

## 🌍 ERROR 11: Biomas no se aplicaban correctamente

### **Ubicación:** `scripts/world/TerrainGenerator.gd`

### **Síntoma:**
Todos los bloques eran del mismo tipo, sin variación de biomas.

### **Causa raíz:**
`BiomeSystem` no estaba inicializado antes de usarse.

### **✅ SOLUCIÓN:**
Inicializar BiomeSystem en `_ready()`:
```gdscript
# TerrainGenerator.gd
func _ready() -> void:
    noise = FastNoiseLite.new()
    noise.seed = world_seed
    noise.noise_type = FastNoiseLite.TYPE_PERLIN
    noise.frequency = noise_frequency

    # ✅ Inicializar sistema de biomas
    BiomeSystem.initialize(world_seed)
```

### **Lección aprendida:**
- Autoloads pueden necesitar inicialización explícita
- Llamar `initialize()` en `_ready()` de quien lo usa primero
- Verificar que sistemas dependientes estén listos

---

## 🏗️ ERROR 12: Estructuras generándose en el aire

### **Ubicación:** `scripts/world/StructureGenerator.gd`

### **Síntoma:**
Templos, casas y torres flotando sin base sólida.

### **Causa raíz:**
La altura de spawn de estructuras no consideraba la altura del terreno real.

### **✅ SOLUCIÓN:**
Calcular altura del terreno antes de generar estructura:
```gdscript
static func try_generate_random_structures(chunk: Chunk, chunk_pos: Vector3i) -> void:
    if not Utils.random_chance(0.1):  # 10% chance
        return

    # Obtener altura del terreno en el centro del chunk
    var center_x = 8  # Centro del chunk 16x16
    var center_z = 8

    # Buscar primer bloque sólido desde arriba
    var terrain_height = 10  # Default
    for y in range(30, 0, -1):
        var block = chunk.get_block(Vector3i(center_x, y, center_z))
        if block != Enums.BlockType.NONE:
            terrain_height = y
            break

    # Generar estructura EN la superficie
    var base_pos = Vector3i(center_x, terrain_height + 1, center_z)

    # Generar estructura...
```

### **Lección aprendida:**
- Siempre calcular altura del terreno antes de generar estructuras
- Buscar desde arriba hacia abajo para encontrar superficie
- Añadir +1 a la altura para que la estructura esté SOBRE el terreno

---

## 📦 RESUMEN DE MEJORES PRÁCTICAS

### ✅ GDScript
1. **NO usar sintaxis de Python** (`"=" * 60` no funciona)
2. **Usar `//` para división entera**, `/` para decimales
3. **Prefijo `_` en parámetros no usados** para evitar warnings
4. **Validar índices** antes de usarlos (buses, arrays, etc.)

### ✅ Godot Scene Tree
1. **`add_child()` ANTES de inicializar** nodos que necesitan estar en el árbol
2. **`call_deferred()` para cambios de escena** y modificaciones del árbol
3. **`await get_tree().process_frame`** para esperar generación de contenido

### ✅ Godot Cache
1. **Eliminar `.godot`** cuando hay problemas persistentes
2. **Reload Project** para cambios menores
3. **Cerrar/reabrir Godot** para cambios de scripts

### ✅ Generación de Mundo
1. **Inicializar sistemas** (BiomeSystem) antes de usarlos
2. **Calcular altura del terreno** antes de generar estructuras
3. **Esperar generación de chunks** antes de spawnear entidades
4. **Validar posiciones de spawn** (buscar superficie segura)

### ✅ Audio
1. **Validar índices de buses** (`if bus_idx == -1: return`)
2. **Crear buses en Project Settings** antes de usarlos

### ✅ Archivos .tscn
1. **Siempre adjuntar scripts** con ExtResource
2. **Verificar en Inspector** que el script esté adjunto
3. **Crear escenas desde el editor** cuando sea posible

---

## 🎓 LECCIONES CLAVE PARA FUTUROS PROYECTOS

### 1. **Orden de Inicialización**
```
1. Autoloads (_ready de cada autoload)
2. Escena principal (Main)
3. Nodos hijos (en orden jerárquico)
4. ✅ Siempre inicializar dependencias ANTES de usarlas
```

### 2. **Orden de Operaciones con Nodos**
```
1. instantiate()
2. add_child()        ← CRÍTICO: hacer ANTES de inicializar
3. initialize()
4. configurar propiedades
```

### 3. **Manejo de Errores Async**
```gdscript
# ✅ Siempre esperar generación antes de usar
func _ready():
    _generate_content()
    await get_tree().process_frame  # Esperar 1 frame
    await get_tree().process_frame  # Esperar otro frame para seguridad
    _use_content()
```

### 4. **Validación Defensiva**
```gdscript
# ✅ Siempre validar antes de usar
var bus_idx = AudioServer.get_bus_index("Music")
if bus_idx == -1:
    return

var chunk = chunks.get(chunk_pos)
if not chunk:
    return

if not is_inside_tree():
    return
```

### 5. **Cache de Godot**
```bash
# ✅ Comando para resetear todo
rm -rf .godot
```
Usar cuando:
- Cambios en constantes/enums no se reflejan
- Errores persistentes después de fixes
- Colores/recursos no se actualizan

---

## 📝 CHECKLIST DE DEBUGGING

Cuando encuentres un error:

- [ ] **Leer el error completo** (ubicación, tipo, mensaje)
- [ ] **Verificar orden de operaciones** (add_child antes de inicializar?)
- [ ] **Validar índices/referencias** (null checks, -1 checks)
- [ ] **Revisar inicialización** (autoloads, sistemas dependientes)
- [ ] **Probar eliminar `.godot`** (si cambios no se reflejan)
- [ ] **Usar `call_deferred`** (si error de "busy adding/removing children")
- [ ] **Añadir `await process_frame`** (si depende de generación async)
- [ ] **Documentar solución** (añadir a este archivo!)

---

## 🔮 ERRORES FUTUROS POTENCIALES

### Posibles problemas que pueden surgir:

1. **Multithreading con chunks**
   - Solución: Usar mutex o Semaphore para acceso concurrente

2. **Memoria con muchos chunks**
   - Solución: Implementar chunk unloading (cargar/descargar según distancia del jugador)

3. **Lag al generar estructuras grandes**
   - Solución: Generar en múltiples frames con yield/await

4. **Colisiones no detectadas**
   - Solución: Verificar CollisionShape3D está en el árbol y configurado

5. **NPCs atravesando bloques**
   - Solución: Usar NavigationRegion3D y actualizar mesh de navegación

---

**Este documento debe actualizarse con cada nuevo error encontrado.**

Formato para nuevos errores:
```markdown
## ❌ ERROR X: Título descriptivo

### **Ubicación:** archivo.gd línea X

### **Error completo:**
```
Mensaje de error completo
```

### **Causa raíz:**
Explicación de por qué ocurre

### **Código problemático:**
```gdscript
código con error
```

### **✅ SOLUCIÓN:**
```gdscript
código corregido
```

### **Lección aprendida:**
- Punto clave 1
- Punto clave 2
```

---

**Fecha de creación:** 2025
**Versión de Godot:** 4.5.1 stable
**Proyecto:** Multi Ninja Espacial
