# 🚀 MEJORAS DEL SISTEMA DE SHADERS

## 📋 Resumen

Mejoras y optimizaciones implementadas sobre el sistema de shaders base, incluyendo presets dinámicos, controles de debug y AO mejorado.

---

## ✨ NUEVAS CARACTERÍSTICAS

### 1. Sistema de Presets Dinámicos (`ShaderPresets.gd`)

**Archivo:** `scripts/rendering/ShaderPresets.gd`

**Funcionalidad:**
Sistema de presets visuales que permite cambiar instantáneamente entre diferentes configuraciones atmosféricas.

**9 Presets Disponibles:**

| Preset | Descripción | Uso Recomendado |
|--------|-------------|-----------------|
| `CLEAR_DAY` | Día claro con cielo azul | Gameplay principal, exploración |
| `CLOUDY_DAY` | Día nublado gris | Transición día/tormenta |
| `SUNSET` | Atardecer con tonos naranjas | Cinemáticas, eventos especiales |
| `NIGHT` | Noche oscura | Gameplay nocturno, horror |
| `CAVE` | Cueva muy oscura | Dungeons, exploración subterránea |
| `FOGGY` | Niebla densa (Silent Hill) | Ambiente misterioso/terror |
| `DESERT_DAY` | Desierto caluroso con haze | Bioma desierto |
| `SNOW_STORM` | Tormenta de nieve blanca | Bioma nieve, eventos climáticos |
| `UNDERWATER` | Efecto submarino azul | Bioma océano |

**API Pública:**

```gdscript
# Aplicar preset a un material
ShaderPresets.apply_preset(material, ShaderPresets.Preset.CLEAR_DAY)

# Aplicar preset a todos los chunks
ShaderPresets.apply_preset_to_all_chunks(chunk_manager, ShaderPresets.Preset.NIGHT)

# Interpolar entre dos presets (transición suave)
ShaderPresets.lerp_presets(material, Preset.DAY, Preset.NIGHT, 0.5)  # 50% día, 50% noche

# Obtener información de preset
var name = ShaderPresets.get_preset_name(Preset.SUNSET)  # "Atardecer"
var desc = ShaderPresets.get_preset_description(Preset.CAVE)

# Aplicar parámetros custom
var custom_params = {
	"ao_strength": 0.9,
	"fog_color": Color(1.0, 0.0, 0.0),  # Fog rojo
	"fog_start": 1.0
}
ShaderPresets.apply_custom_params(material, custom_params)

# Detectar preset actual
var current = ShaderPresets.detect_current_preset(material)
```

**Ejemplos de Uso:**

#### Ciclo Día/Noche
```gdscript
extends Node

var time_of_day: float = 0.0  # 0.0 = medianoche, 0.5 = mediodía

func _process(delta):
	time_of_day += delta / 60.0  # 1 día = 60 segundos
	if time_of_day > 1.0:
		time_of_day -= 1.0

	_update_lighting()

func _update_lighting():
	var chunk_manager = get_node("ChunkManager")

	if time_of_day < 0.25:  # 0:00 - 6:00 (Noche)
		ShaderPresets.apply_preset_to_all_chunks(chunk_manager, ShaderPresets.Preset.NIGHT)
	elif time_of_day < 0.35:  # 6:00 - 8:24 (Amanecer)
		var t = (time_of_day - 0.25) / 0.1  # 0.0 - 1.0
		for chunk in chunk_manager.get_children():
			var mat = chunk.mesh_instance.get_surface_override_material(0)
			ShaderPresets.lerp_presets(mat, Preset.NIGHT, Preset.CLEAR_DAY, t)
	elif time_of_day < 0.75:  # 8:24 - 18:00 (Día)
		ShaderPresets.apply_preset_to_all_chunks(chunk_manager, ShaderPresets.Preset.CLEAR_DAY)
	elif time_of_day < 0.85:  # 18:00 - 20:24 (Atardecer)
		var t = (time_of_day - 0.75) / 0.1
		for chunk in chunk_manager.get_children():
			var mat = chunk.mesh_instance.get_surface_override_material(0)
			ShaderPresets.lerp_presets(mat, Preset.CLEAR_DAY, Preset.SUNSET, t)
	else:  # 20:24 - 0:00 (Noche)
		var t = (time_of_day - 0.85) / 0.15
		for chunk in chunk_manager.get_children():
			var mat = chunk.mesh_instance.get_surface_override_material(0)
			ShaderPresets.lerp_presets(mat, Preset.SUNSET, Preset.NIGHT, t)
```

#### Sistema de Clima Dinámico
```gdscript
extends Node

enum Weather {
	CLEAR,
	CLOUDY,
	FOGGY,
	SNOW_STORM
}

var current_weather: Weather = Weather.CLEAR

func change_weather(new_weather: Weather):
	var chunk_manager = get_node("ChunkManager")

	match new_weather:
		Weather.CLEAR:
			ShaderPresets.apply_preset_to_all_chunks(chunk_manager, Preset.CLEAR_DAY)
		Weather.CLOUDY:
			ShaderPresets.apply_preset_to_all_chunks(chunk_manager, Preset.CLOUDY_DAY)
		Weather.FOGGY:
			ShaderPresets.apply_preset_to_all_chunks(chunk_manager, Preset.FOGGY)
		Weather.SNOW_STORM:
			ShaderPresets.apply_preset_to_all_chunks(chunk_manager, Preset.SNOW_STORM)

	current_weather = new_weather
	print("Clima cambiado a: ", Weather.keys()[new_weather])
```

---

### 2. Controles de Debug (`ShaderDebugControls.gd`)

**Archivo:** `scripts/debug/ShaderDebugControls.gd`

**Funcionalidad:**
Script de debug que permite ajustar todos los parámetros de shader en tiempo real durante desarrollo.

**Cómo Usar:**
1. Añadir como nodo hijo en GameWorld.tscn
2. Ejecutar el juego (F5)
3. Usar teclado para ajustar parámetros en vivo

**Controles de Teclado:**

#### Presets
- `[1-9]` → Cambiar preset directo
  - 1 = Día Claro
  - 2 = Día Nublado
  - 3 = Atardecer
  - 4 = Noche
  - 5 = Cueva
  - 6 = Niebla Densa
  - 7 = Desierto
  - 8 = Tormenta Nieve
  - 9 = Submarino
- `[P]` → Ciclar entre presets

#### Ambient Occlusion
- `[Page Up]` → Aumentar AO strength (+0.1)
- `[Page Down]` → Disminuir AO strength (-0.1)
- `[O]` → Toggle AO on/off

#### Fog
- `[Home]` → Aumentar fog_start (+5m)
- `[End]` → Disminuir fog_start (-5m)
- `[Insert]` → Aumentar fog_end (+10m)
- `[Delete]` → Disminuir fog_end (-10m)
- `[F]` → Toggle Fog on/off

#### Iluminación
- `[+]` → Aumentar ambient_light (+0.1)
- `[-]` → Disminuir ambient_light (-0.1)
- `[*]` → Aumentar sun_intensity (+0.2)
- `[/]` → Disminuir sun_intensity (-0.2)

#### Info
- `[I]` → Imprimir parámetros actuales
- `[L]` → Listar todos los presets
- `[H]` → Mostrar ayuda

**Configuración:**
```gdscript
# En Inspector de Godot
@export var enabled: bool = true  # Activar/desactivar
@export var chunk_manager: Node = null  # Auto-detect si null
@export var show_ui: bool = true  # Mostrar UI (futuro)
```

**Workflow de Desarrollo:**
1. Ejecutar juego
2. Presionar `[1]` para Día Claro
3. Presionar `[Page Up]` varias veces para ver efecto de AO
4. Presionar `[End]` para acercar fog
5. Presionar `[I]` para ver valores actuales
6. Encontrar valores deseados
7. Copiar valores a configuración final

---

### 3. AO Mejorado con Mapeo Preciso

**Archivo:** `scripts/world/Chunk.gd` (modificado)

**Mejora:**
Reemplazo del cálculo simplificado de AO por un mapeo completo y preciso de vecinos por cada combinación cara+vértice.

**Antes (Simplificado):**
```gdscript
# Usaba mismos 3 vecinos cardinales para todos los vértices
neighbors = [
	Vector3i(1, 0, 0),  # Este
	Vector3i(0, 1, 0),  # Arriba
	Vector3i(0, 0, 1)   # Norte
]
```

**Después (Preciso):**
```gdscript
# Cada vértice de cada cara tiene sus 3 vecinos específicos
match face:
	Enums.BlockFace.TOP:
		match vertex_index:
			0:  # Esquina específica
				neighbors = [
					Vector3i(0, 1, 1),   # Side 1
					Vector3i(-1, 1, 0),  # Side 2
					Vector3i(-1, 1, 1)   # Corner diagonal
				]
			# ... otros 3 vértices
	# ... otras 5 caras
```

**Beneficios:**
- ✅ AO más preciso y realista
- ✅ Esquinas correctamente oscurecidas
- ✅ Hendiduras con profundidad visual
- ✅ Compatible con algoritmo estándar de AO voxel

**Algoritmo Mejorado:**
```gdscript
# Para cada vértice:
# 1. Obtener 3 vecinos (side1, side2, corner)
# 2. Verificar si son sólidos
# 3. Calcular AO según fórmula estándar:

if (side1_solid && side2_solid):
	ao = 0.0  # Muy oscuro (esquina bloqueada)
else:
	filled_count = side1_solid + side2_solid + corner_solid
	ao = (3 - filled_count) / 3.0
	# 0 vecinos → ao = 1.0 (brillante)
	# 1 vecino  → ao = 0.67
	# 2 vecinos → ao = 0.33
	# 3 vecinos → ao = 0.0 (oscuro)
```

**Comparación Visual:**
```
ANTES (Simplified AO):
┌───┬───┐
│ ▒ │ ▒ │  ← AO inconsistente
│   │   │
└───┴───┘

DESPUÉS (Precise AO):
┌───┬───┐
│ ▓ │ ▓ │  ← Esquinas correctamente oscuras
│ ▒ │ ▒ │  ← Bordes con gradiente
└─▓─┴─▓─┘  ← Hendiduras oscuras
```

---

## 📊 MÉTRICAS

**Código Añadido:**
- ShaderPresets.gd: 450 líneas
- ShaderDebugControls.gd: 350 líneas
- Chunk.gd (AO mejorado): +120 líneas
- **Total:** ~920 líneas

**Documentación:**
- MEJORAS_SHADERS.md: ~600 líneas (este archivo)

**Performance:**
- Presets: O(chunks) aplicación, instantáneo
- Debug Controls: <1ms overhead cuando enabled=false
- AO Mejorado: Sin cambio (mismo número de checks)

---

## 🎓 LECCIONES ARQUITECTÓNICAS

### 1. Patrón Strategy con Presets

**Problema:** Cambiar múltiples parámetros de shader manualmente es tedioso.

**Solución:** Presets como "estrategias" predefinidas.

```gdscript
# ❌ SIN Strategy Pattern
material.set_shader_parameter("ao_strength", 0.3)
material.set_shader_parameter("fog_color", Color(0.7, 0.8, 0.9))
material.set_shader_parameter("fog_start", 40.0)
material.set_shader_parameter("fog_end", 150.0)
material.set_shader_parameter("ambient_light", 0.7)
material.set_shader_parameter("sun_intensity", 1.5)
# ... repetir para cada chunk

# ✅ CON Strategy Pattern
ShaderPresets.apply_preset_to_all_chunks(chunk_manager, Preset.CLEAR_DAY)
```

### 2. Separation of Concerns

**Debug vs Production Code:**
```gdscript
# ShaderDebugControls.gd tiene @export var enabled: bool
# En producción: enabled = false → 0 overhead
# En desarrollo: enabled = true → controles completos

# NO contamina código de producción con debug UI
```

### 3. Data-Driven Design

**Preset Configs como Data:**
```gdscript
# Toda la configuración en Dictionary
const PRESET_CONFIGS: Dictionary = {
	Preset.CLEAR_DAY: {
		"name": "Día Claro",
		"ao_strength": 0.3,
		"fog_color": Color(0.7, 0.8, 0.9),
		# ...
	}
}

# Añadir nuevo preset = añadir entry en Dictionary
# NO requiere cambiar lógica de aplicación
```

### 4. Progressive Enhancement

**AO Evolution:**
```
Fase 1: Sin AO
  └─> Fase 2: AO simplificado (3 vecinos fijos)
      └─> Fase 3: AO preciso (mapeo completo) ✅

Cada fase funciona, pero mejora calidad visual
```

---

## 🚀 USO RECOMENDADO

### Durante Desarrollo
1. Añadir `ShaderDebugControls` a escena principal
2. Ajustar parámetros en vivo con teclado
3. Presionar `[I]` para ver valores finales
4. Copiar valores a código de producción
5. Desactivar `enabled = false` antes de release

### En Producción
1. Usar `ShaderPresets` para cambios atmosféricos
2. Integrar con sistema de ciclo día/noche
3. Integrar con sistema de clima
4. Usar `lerp_presets()` para transiciones suaves

### Para Modding
1. Exponer `ShaderPresets.apply_custom_params()`
2. Permitir a modders crear presets custom vía JSON
3. Cargar presets custom al inicio del juego

---

## 📖 EJEMPLOS AVANZADOS

### Transición Suave de Clima
```gdscript
extends Node

var transition_timer: float = 0.0
var transition_duration: float = 5.0  # 5 segundos
var from_preset: ShaderPresets.Preset
var to_preset: ShaderPresets.Preset
var is_transitioning: bool = false

func start_weather_transition(new_weather: ShaderPresets.Preset):
	from_preset = ShaderPresets.detect_current_preset(get_first_chunk_material())
	to_preset = new_weather
	transition_timer = 0.0
	is_transitioning = true

func _process(delta):
	if is_transitioning:
		transition_timer += delta
		var progress = clampf(transition_timer / transition_duration, 0.0, 1.0)

		var chunk_manager = get_node("ChunkManager")
		for chunk in chunk_manager.get_children():
			var material = chunk.mesh_instance.get_surface_override_material(0)
			ShaderPresets.lerp_presets(material, from_preset, to_preset, progress)

		if progress >= 1.0:
			is_transitioning = false
```

### Sistema de Eventos Atmosféricos
```gdscript
extends Node

signal weather_changed(new_weather: String)

func _ready():
	weather_changed.connect(_on_weather_changed)

func trigger_storm():
	emit_signal("weather_changed", "storm")

func _on_weather_changed(weather: String):
	var chunk_manager = get_node("ChunkManager")

	match weather:
		"storm":
			ShaderPresets.apply_preset_to_all_chunks(chunk_manager, Preset.FOGGY)
			_spawn_rain_particles()
		"clear":
			ShaderPresets.apply_preset_to_all_chunks(chunk_manager, Preset.CLEAR_DAY)
		"blizzard":
			ShaderPresets.apply_preset_to_all_chunks(chunk_manager, Preset.SNOW_STORM)
			_spawn_snow_particles()
```

---

## ✅ CHECKLIST DE INTEGRACIÓN

**Para Usar Presets:**
- [ ] Añadir ShaderPresets.gd a proyecto
- [ ] Verificar que está en autoload (opcional)
- [ ] Llamar `apply_preset_to_all_chunks()` desde código
- [ ] Probar todos los presets en runtime

**Para Usar Debug Controls:**
- [ ] Añadir ShaderDebugControls.gd a proyecto
- [ ] Crear nodo Node en GameWorld
- [ ] Asignar script ShaderDebugControls.gd
- [ ] Ejecutar y presionar [H] para ayuda
- [ ] Ajustar enabled=false para builds de producción

**Para AO Mejorado:**
- [ ] Ya incluido en Chunk.gd ✅
- [ ] No requiere configuración adicional
- [ ] Automático al generar meshes

---

## 🔗 REFERENCIAS

**Archivos Relacionados:**
- `scripts/rendering/ShaderPresets.gd`
- `scripts/debug/ShaderDebugControls.gd`
- `scripts/world/Chunk.gd` (método `_get_ao_neighbors()`)
- `shaders/block_voxel.gdshader`

**Documentación:**
- `SISTEMA_SHADERS.md` → Arquitectura base del shader
- `TESTING_SHADERS.md` → Cómo probar shaders
- `INDICE_DOCUMENTACION.md` → Navegación completa

---

**Última Actualización:** 2025-10-20
**Versión:** 1.0
**Status:** ✅ Implementado y Documentado

---

**¡Sistema de shaders con mejoras completas!** 🚀✨
