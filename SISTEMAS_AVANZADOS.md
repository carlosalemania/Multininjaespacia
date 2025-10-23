# 🌍 SISTEMAS AVANZADOS - Multi Ninja Espacial

## 📋 Resumen

Sistemas avanzados de rendering atmosférico y gestión de tiempo/clima con integración completa entre shaders, ciclo día/noche y clima dinámico.

---

## ✨ SISTEMAS IMPLEMENTADOS

### 1. PresetTransitionManager

**Archivo:** `scripts/rendering/PresetTransitionManager.gd`

**Propósito:**
Gestor centralizado de transiciones suaves entre presets de shaders con múltiples tipos de curvas de easing.

**Características:**
- ✅ Transiciones automáticas con timing configurable
- ✅ 6 tipos de curvas de easing (Linear, Ease In, Ease Out, Ease In Out, Bounce, Elastic)
- ✅ Sistema de señales (started, finished, progress)
- ✅ Pause/Resume de transiciones
- ✅ Auto-detección de ChunkManager
- ✅ Cache de materiales para performance

**API:**

```gdscript
# Crear e inicializar
var transition_mgr = PresetTransitionManager.new()
add_child(transition_mgr)

# Transición básica
transition_mgr.transition_to(ShaderPresets.Preset.NIGHT)

# Transición con duración custom
transition_mgr.transition_to(ShaderPresets.Preset.SUNSET, 5.0)

# Transición con curva específica
transition_mgr.transition_to(
	ShaderPresets.Preset.CAVE,
	3.0,
	PresetTransitionManager.TransitionType.EASE_IN_OUT
)

# Cambio instantáneo (sin transición)
transition_mgr.snap_to(ShaderPresets.Preset.CLEAR_DAY)

# Control de reproducción
transition_mgr.pause_transition()
transition_mgr.resume_transition()

# Queries
var progress = transition_mgr.get_progress()  # 0.0 - 1.0
var is_active = transition_mgr.is_active()

# Refresh (útil si se generan nuevos chunks)
transition_mgr.refresh_materials()
```

**Señales:**

```gdscript
# Conectar a señales
transition_mgr.transition_started.connect(func(from, to):
	print("Transición: %s → %s" % [from, to])
)

transition_mgr.transition_finished.connect(func(preset):
	print("Terminado: %s" % preset)
)

transition_mgr.transition_progress.connect(func(progress):
	# Actualizar UI, etc.
	print("Progreso: %.1f%%" % (progress * 100.0))
)
```

**Tipos de Easing:**

| Tipo | Descripción | Uso Recomendado |
|------|-------------|-----------------|
| `LINEAR` | Constante, sin aceleración | Transiciones mecánicas |
| `EASE_IN` | Acelera al inicio | Zoom in, apariciones |
| `EASE_OUT` | Desacelera al final | Zoom out, desapariciones |
| `EASE_IN_OUT` | Acelera y desacelera (smooth) | **Día/noche, clima (default)** |
| `BOUNCE` | Rebote al final | Efectos juguetones |
| `ELASTIC` | Overshoot elástico | Efectos dramáticos |

---

### 2. WeatherSystem

**Archivo:** `scripts/world/WeatherSystem.gd`

**Propósito:**
Sistema de clima dinámico con transiciones automáticas basadas en probabilidades.

**Características:**
- ✅ 8 tipos de clima (Clear, Cloudy, Rainy, Stormy, Snowy, Blizzard, Foggy, Sandstorm)
- ✅ Cambios automáticos con probabilidades configurables
- ✅ Integración con PresetTransitionManager
- ✅ Duración variable de cada clima (min/max)
- ✅ Sistema de señales (weather_changed, storm_started/ended)
- ✅ Control manual o automático

**Tipos de Clima:**

| Clima | Preset Shader | Efecto | Uso |
|-------|---------------|--------|-----|
| `CLEAR` | CLEAR_DAY | Cielo azul despejado | Gameplay normal |
| `CLOUDY` | CLOUDY_DAY | Nublado gris | Transición |
| `RAINY` | FOGGY | Fog medio + lluvia | Ambiente lluvioso |
| `STORMY` | FOGGY | Fog denso + rayos | Eventos dramáticos |
| `SNOWY` | SNOW_STORM | Nieve | Bioma nieve |
| `BLIZZARD` | SNOW_STORM | Ventisca intensa | Tormenta nieve |
| `FOGGY` | FOGGY | Niebla densa | Misterio/terror |
| `SANDSTORM` | DESERT_DAY | Fog amarillo arena | Bioma desierto |

**API:**

```gdscript
# Crear e inicializar
var weather = WeatherSystem.new()
add_child(weather)

# Conectar con transition manager
weather.transition_manager = get_node("PresetTransitionManager")

# Cambio manual de clima
weather.set_weather(WeatherSystem.Weather.RAINY)  # Con transición
weather.set_weather(WeatherSystem.Weather.STORMY, true)  # Instantáneo

# Queries
var current = weather.get_current_weather()
var name = weather.get_current_weather_name()
var is_storm = weather.is_stormy()

# Atajos
weather.force_clear_weather()
weather.force_storm()

# Control automático
weather.set_dynamic_enabled(true)  # Activar cambios automáticos
weather.set_dynamic_enabled(false)  # Solo manual

# Timer
var time_left = weather.get_time_until_next_change()
```

**Configuración:**

```gdscript
@export var enable_dynamic_weather: bool = true
@export var min_weather_duration: float = 60.0  # 1 minuto mínimo
@export var max_weather_duration: float = 300.0  # 5 minutos máximo
@export var transition_duration: float = 5.0  # Transiciones de 5s
```

**Señales:**

```gdscript
# Cambio de clima
weather.weather_changed.connect(func(old, new):
	print("Clima: %s → %s" % [old, new])
)

# Tormentas
weather.storm_started.connect(func():
	print("¡Comienza tormenta!")
	# Activar efectos de partículas, sonidos, etc.
)

weather.storm_ended.connect(func():
	print("Tormenta terminada")
)
```

**Probabilidades de Transición:**

El sistema usa una tabla de probabilidades para transiciones realistas:

```
CLEAR → CLEAR (70%) | CLOUDY (20%) | RAINY (5%) | FOGGY (5%)
CLOUDY → CLEAR (30%) | CLOUDY (30%) | RAINY (30%) | STORMY (10%)
RAINY → CLOUDY (40%) | RAINY (30%) | STORMY (20%) | CLEAR (10%)
STORMY → RAINY (50%) | CLOUDY (30%) | CLEAR (20%)
```

Esto crea patrones realistas:
- Días despejados tienden a seguir despejados
- Lluvia puede evolucionar a tormenta
- Tormentas eventualmente se calman

---

### 3. DayNightCycle (Integrado)

**Archivo:** `scripts/world/DayNightCycle.gd`

**Propósito:**
Ciclo día/noche con integración de shaders via PresetTransitionManager.

**Mejoras Añadidas:**
- ✅ Integración con PresetTransitionManager
- ✅ Sincronización automática de presets con periodo del día
- ✅ Transiciones suaves entre Dawn/Day/Dusk/Night

**Nueva API:**

```gdscript
var day_night = get_node("DayNightCycle")
var transition_mgr = get_node("PresetTransitionManager")

# Conectar sistemas
day_night.connect_preset_manager(transition_mgr)

# Ahora el ciclo día/noche automáticamente cambia los shaders:
# DAWN → SUNSET preset (tonos naranjas)
# DAY → CLEAR_DAY preset (cielo azul)
# DUSK → SUNSET preset (atardecer)
# NIGHT → NIGHT preset (oscuro)
```

**Mapeo Periodo → Preset:**

| Periodo | Horas | Preset | Efecto Visual |
|---------|-------|--------|---------------|
| DAWN | 5:00 - 7:00 | SUNSET | Amanecer naranja |
| DAY | 7:00 - 17:00 | CLEAR_DAY | Día azul brillante |
| DUSK | 17:00 - 19:00 | SUNSET | Atardecer naranja |
| NIGHT | 19:00 - 5:00 | NIGHT | Noche oscura |

---

## 🔗 INTEGRACIÓN COMPLETA

### Arquitectura del Sistema

```
┌──────────────────────────────────────────────────────┐
│                  GAME WORLD                           │
│                                                       │
│  ┌─────────────────┐  ┌──────────────────────────┐  │
│  │ DayNightCycle   │  │ WeatherSystem            │  │
│  │                 │  │                          │  │
│  │ - Hora actual   │  │ - Clima actual           │  │
│  │ - Periodo       │  │ - Timer automático       │  │
│  │ - Sol/Luna      │  │ - Probabilidades         │  │
│  └────────┬────────┘  └──────────┬───────────────┘  │
│           │                      │                   │
│           │ time_period_changed  │ set_weather()     │
│           │                      │                   │
│           ▼                      ▼                   │
│  ┌─────────────────────────────────────────────┐    │
│  │   PresetTransitionManager                    │    │
│  │                                              │    │
│  │  - transition_to(preset, duration, type)    │    │
│  │  - Curvas de easing                         │    │
│  │  - Signals (started, progress, finished)    │    │
│  └──────────────────────┬───────────────────────┘   │
│                         │                            │
│                         │ lerp_presets()             │
│                         ▼                            │
│  ┌─────────────────────────────────────────────┐    │
│  │   ShaderPresets                             │    │
│  │                                              │    │
│  │  - 9 presets predefinidos                   │    │
│  │  - apply_preset(), lerp_presets()           │    │
│  └──────────────────────┬───────────────────────┘   │
│                         │                            │
│                         │ set_shader_parameter()     │
│                         ▼                            │
│  ┌─────────────────────────────────────────────┐    │
│  │   ChunkManager → Chunks                     │    │
│  │                                              │    │
│  │   - ShaderMaterial en cada chunk            │    │
│  │   - Parámetros: AO, Fog, Light              │    │
│  └──────────────────────┬───────────────────────┘   │
│                         │                            │
│                         ▼                            │
│  ┌─────────────────────────────────────────────┐    │
│  │   GPU (block_voxel.gdshader)                │    │
│  │                                              │    │
│  │   - Vertex: Calcular distancia, AO          │    │
│  │   - Fragment: Aplicar efectos               │    │
│  │   - Light: Diffuse lighting                 │    │
│  └──────────────────────────────────────────────┘   │
│                                                      │
│                 ↓ RESULTADO VISUAL ↓                 │
│                                                      │
│    🌅 Amanecer → ☀️ Día → 🌇 Atardecer → 🌙 Noche   │
│              + 🌧️ Lluvia / ⛈️ Tormenta              │
│                                                      │
└──────────────────────────────────────────────────────┘
```

### Setup Completo en GameWorld

```gdscript
# GameWorld.gd
extends Node3D

# Referencias
@onready var chunk_manager = $ChunkManager
@onready var day_night_cycle = $DayNightCycle
@onready var preset_transition_manager = $PresetTransitionManager
@onready var weather_system = $WeatherSystem

func _ready():
	# 1. Asegurar que PresetTransitionManager tiene referencia a ChunkManager
	preset_transition_manager.chunk_manager = chunk_manager

	# 2. Conectar DayNightCycle con PresetTransitionManager
	day_night_cycle.connect_preset_manager(preset_transition_manager)

	# 3. Conectar WeatherSystem con PresetTransitionManager
	weather_system.transition_manager = preset_transition_manager

	# 4. Configurar clima dinámico
	weather_system.enable_dynamic_weather = true
	weather_system.min_weather_duration = 60.0  # 1 min
	weather_system.max_weather_duration = 300.0  # 5 min

	# 5. Conectar señales (opcional - para eventos)
	day_night_cycle.time_period_changed.connect(_on_time_period_changed)
	weather_system.weather_changed.connect(_on_weather_changed)
	weather_system.storm_started.connect(_on_storm_started)

func _on_time_period_changed(period: DayNightCycle.TimePeriod):
	match period:
		DayNightCycle.TimePeriod.DAWN:
			print("🌅 ¡Amanece! Hora de explorar")
		DayNightCycle.TimePeriod.NIGHT:
			print("🌙 Noche... cuidado con los enemigos")

func _on_weather_changed(old_weather, new_weather):
	print("Clima cambió: %s → %s" % [old_weather, new_weather])

func _on_storm_started():
	print("⛈️ ¡Tormenta! Busca refugio")
	# Activar partículas de lluvia, sonidos, etc.
```

---

## 🎮 EJEMPLOS DE USO

### Ejemplo 1: Evento Climático al Entrar a Bioma

```gdscript
# BiomeDetector.gd
extends Area3D

@export var biome_type: String = "desert"

func _on_body_entered(body):
	if body.name == "Player":
		var weather = get_node("/root/GameWorld/WeatherSystem")

		match biome_type:
			"desert":
				weather.set_weather(WeatherSystem.Weather.SANDSTORM)
			"snow":
				weather.set_weather(WeatherSystem.Weather.SNOWY)
			"mountain":
				weather.set_weather(WeatherSystem.Weather.FOGGY)
			_:
				weather.set_weather(WeatherSystem.Weather.CLEAR)
```

### Ejemplo 2: Boss Fight con Clima Dramático

```gdscript
# Boss.gd
extends CharacterBody3D

signal boss_appeared
signal boss_defeated

var weather: WeatherSystem

func _ready():
	weather = get_node("/root/GameWorld/WeatherSystem")

	boss_appeared.connect(func():
		# Desactivar clima automático
		weather.set_dynamic_enabled(false)

		# Forzar tormenta con transición dramática
		var transition_mgr = get_node("/root/GameWorld/PresetTransitionManager")
		transition_mgr.transition_to(
			ShaderPresets.Preset.FOGGY,
			3.0,
			PresetTransitionManager.TransitionType.ELASTIC  # Dramático
		)
	)

	boss_defeated.connect(func():
		# Volver a clima despejado
		weather.force_clear_weather()

		# Reactivar clima automático
		weather.set_dynamic_enabled(true)
	)
```

### Ejemplo 3: Ciclo Día/Noche Acelerado para Testing

```gdscript
# Debug.gd
extends Node

func _input(event):
	if event.is_action_pressed("debug_fast_time"):
		var day_night = get_node("/root/GameWorld/DayNightCycle")
		day_night.set_time_scale(10.0)  # 10x velocidad
		print("⏱️ Tiempo acelerado 10x")

	if event.is_action_pressed("debug_set_night"):
		var day_night = get_node("/root/GameWorld/DayNightCycle")
		day_night.set_time(0.0)  # Medianoche
		print("🌙 Forzar medianoche")
```

---

## 📊 MÉTRICAS Y PERFORMANCE

**Código Añadido:**
- PresetTransitionManager.gd: 350 líneas
- WeatherSystem.gd: 280 líneas
- DayNightCycle.gd (integración): +65 líneas
- **Total:** ~695 líneas

**Performance:**
- PresetTransitionManager: O(chunks) por transición, amortizado por cache
- WeatherSystem: O(1) cambio de clima
- DayNightCycle: Sin overhead adicional

**Memory:**
- Cache de materiales: ~8 bytes × chunks
- Insignificante comparado con meshes

---

## 🎓 LECCIONES ARQUITECTÓNICAS

### 1. Patrón Observer

**DayNightCycle emite señales, sistemas las consumen:**

```gdscript
# Publisher
day_night_cycle.time_period_changed.emit(new_period)

# Subscriber
preset_transition_manager.connects(day_night_cycle.time_period_changed, _update_shader)
```

**Beneficio:** Desacoplamiento total, fácil añadir nuevos subscribers.

### 2. Patrón Facade

**PresetTransitionManager oculta complejidad de transiciones:**

```gdscript
# SIN Facade (complejo):
for chunk in chunks:
	var from_config = ShaderPresets.get_preset_config(from_preset)
	var to_config = ShaderPresets.get_preset_config(to_preset)
	for param in params:
		var from_value = from_config[param]
		var to_value = to_config[param]
		var lerped = lerp(from_value, to_value, apply_easing(progress))
		chunk.material.set_shader_parameter(param, lerped)

# CON Facade (simple):
transition_manager.transition_to(preset, duration, easing_type)
```

### 3. Data-Driven Design

**Probabilidades de clima en Dictionary:**

```gdscript
const WEATHER_TRANSITIONS: Dictionary = {
	Weather.CLEAR: { Weather.CLOUDY: 0.2, ... },
	# Añadir nuevo clima = añadir entries
	# No cambiar lógica de selección
}
```

### 4. Separation of Concerns

**Cada sistema tiene responsabilidad única:**
- DayNightCycle → Tiempo y sol/luna
- WeatherSystem → Clima y transiciones automáticas
- PresetTransitionManager → Transiciones visuales
- ShaderPresets → Configuraciones predefinidas

---

## ✅ CHECKLIST DE INTEGRACIÓN

**Setup Inicial:**
- [ ] Crear nodo PresetTransitionManager en GameWorld
- [ ] Crear nodo WeatherSystem en GameWorld
- [ ] Verificar que DayNightCycle existe

**Conexiones:**
- [ ] `preset_transition_manager.chunk_manager = chunk_manager`
- [ ] `day_night_cycle.connect_preset_manager(preset_transition_manager)`
- [ ] `weather_system.transition_manager = preset_transition_manager`

**Configuración:**
- [ ] Ajustar `weather_system.enable_dynamic_weather`
- [ ] Ajustar `weather_system.min/max_weather_duration`
- [ ] Ajustar `day_night_cycle.day_duration` y `time_scale`

**Testing:**
- [ ] Observar transiciones día/noche automáticas
- [ ] Esperar cambios de clima automáticos
- [ ] Probar cambios manuales de clima
- [ ] Verificar señales (conectar prints)

---

## 🔗 REFERENCIAS

**Archivos Relacionados:**
- `scripts/rendering/PresetTransitionManager.gd`
- `scripts/world/WeatherSystem.gd`
- `scripts/world/DayNightCycle.gd`
- `scripts/rendering/ShaderPresets.gd`
- `shaders/block_voxel.gdshader`

**Documentación:**
- `SISTEMA_SHADERS.md` → Base de shaders
- `MEJORAS_SHADERS.md` → Presets y controles
- `INDICE_DOCUMENTACION.md` → Navegación completa

---

**Última Actualización:** 2025-10-20
**Versión:** 1.0
**Status:** ✅ Implementado y Documentado

---

**¡Sistemas avanzados de atmósfera completamente integrados!** 🌍✨
