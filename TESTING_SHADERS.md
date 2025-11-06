# 🧪 GUÍA DE TESTING - Sistema de Shaders

## 📋 Objetivo

Verificar que el sistema de shaders (Ambient Occlusion + Fog + Iluminación) funciona correctamente en Godot 4.x.

---

## ✅ CHECKLIST DE TESTING

### 1. Verificación de Archivos

Antes de probar en Godot, confirma que todos los archivos existen:

```bash
# Shader
ls -lh shaders/block_voxel.gdshader

# Texture Atlas
ls -lh assets/textures/block_atlas.png
ls -lh assets/textures/block_atlas.png.import

# Scripts
ls -lh scripts/world/Chunk.gd
ls -lh scripts/rendering/TextureAtlasManager.gd
```

**Expected Output:**
```
✅ shaders/block_voxel.gdshader (~6 KB)
✅ assets/textures/block_atlas.png (~65 KB)
✅ assets/textures/block_atlas.png.import (~700 bytes)
✅ scripts/world/Chunk.gd (~15 KB)
✅ scripts/rendering/TextureAtlasManager.gd (~8 KB)
```

---

### 2. Testing en Godot Editor

#### Paso 1: Abrir Proyecto
```bash
cd /Users/carlosgarcia/Desktop/Proyectos/C++/multininjaespacial
# Abrir con Godot 4.x
```

#### Paso 2: Verificar Output Console
Al abrir el proyecto, la consola NO debe mostrar:
- ❌ Errores de shader compilation
- ❌ Errores de texture loading
- ❌ Errores de script parsing

**Errores Comunes:**
```
❌ "Can't load shader: res://shaders/block_voxel.gdshader"
   → Solución: Verificar que el archivo existe
   → Verificar sintaxis GLSL

❌ "Invalid set index 'shader' with value of type 'Shader'"
   → Solución: Verificar que shader es Shader (no ShaderMaterial)

❌ "Texture not found: res://assets/textures/block_atlas.png"
   → Solución: Regenerar atlas con generate_atlas.py
```

#### Paso 3: Iniciar Escena de Juego
```
1. Abrir scenes/main/GameWorld.tscn
2. Presionar F5 (Run Project)
3. Esperar generación de chunks
```

---

### 3. Verificaciones Visuales

#### Test 1: Ambient Occlusion Visible
**Qué Buscar:**
- Esquinas de bloques deben verse más oscuras
- Hendiduras entre bloques deben tener sombras
- Bloques expuestos deben verse más brillantes

**Cómo Verificar:**
```
1. Acércate a una pared de bloques
2. Observa las esquinas donde se juntan 3 bloques
3. Debe haber gradiente de oscuridad

Esperado:
  ┌───┬───┐
  │ ▓ │ ▓ │  <- Esquinas oscuras (AO = 0.3)
  │   │   │
  └─▓─┴─▓─┘  <- Junturas oscuras

Real sin AO:
  ┌───┬───┐
  │   │   │  <- Todo igual de brillante
  │   │   │
  └───┴───┘
```

**Si no ves AO:**
```gdscript
# Debug: Verificar que AO está activado
var chunk = get_node("ChunkManager").get_child(0)
var material = chunk.mesh_instance.get_surface_override_material(0)
print("AO enabled: ", material.get_shader_parameter("enable_ao"))
print("AO strength: ", material.get_shader_parameter("ao_strength"))

# Activar AO manualmente
material.set_shader_parameter("enable_ao", true)
material.set_shader_parameter("ao_strength", 0.8)  # Más intenso para testing
```

#### Test 2: Fog Atmosférico Visible
**Qué Buscar:**
- Chunks lejanos deben verse más azulados/grises
- Transición gradual entre cerca (nítido) y lejos (difuminado)
- Color de fog debe ser configurable

**Cómo Verificar:**
```
1. Aléjate volando (modo creativo o cámara libre)
2. Observa chunks a diferentes distancias
3. Debe haber gradiente de nitidez

Distancia:
  10m → Nítido
  45m → 50% fog
  80m → 100% fog (color de fog completo)
```

**Si no ves Fog:**
```gdscript
# Debug: Verificar fog
var material = chunk.mesh_instance.get_surface_override_material(0)
print("Fog enabled: ", material.get_shader_parameter("enable_fog"))
print("Fog start: ", material.get_shader_parameter("fog_start"))
print("Fog end: ", material.get_shader_parameter("fog_end"))

# Activar fog manualmente con valores extremos (más visible)
material.set_shader_parameter("enable_fog", true)
material.set_shader_parameter("fog_color", Color(1.0, 0.0, 0.0, 1.0))  # Rojo intenso
material.set_shader_parameter("fog_start", 5.0)   # Empieza muy cerca
material.set_shader_parameter("fog_end", 30.0)    # Termina cerca
```

#### Test 3: Iluminación Funciona
**Qué Buscar:**
- Caras perpendiculares al sol deben verse más brillantes
- Caras opuestas al sol deben verse más oscuras
- Debe haber diferencia entre arriba (TOP) y abajo (BOTTOM)

**Cómo Verificar:**
```
1. Observa un bloque desde varios ángulos
2. La cara TOP debe verse más brillante (si DirectionalLight3D apunta hacia abajo)
3. Caras laterales deben tener brillo intermedio

Esperado (con sol desde arriba):
  ┌───────┐
  │ ☀️ TOP │  <- Muy brillante (NdotL ≈ 1.0)
  ├───────┤
  │ SIDE  │  <- Brillo medio (NdotL ≈ 0.5)
  └───────┘
   BOTTOM    <- Oscuro (NdotL ≈ 0.0)
```

**Si no ves iluminación:**
```gdscript
# Debug: Verificar parámetros de luz
var material = chunk.mesh_instance.get_surface_override_material(0)
print("Ambient light: ", material.get_shader_parameter("ambient_light"))
print("Sun intensity: ", material.get_shader_parameter("sun_intensity"))

# Aumentar contraste de iluminación
material.set_shader_parameter("ambient_light", 0.1)   # Menos luz ambiente
material.set_shader_parameter("sun_intensity", 2.0)   # Sol muy intenso
```

**Asegúrate de tener DirectionalLight3D:**
```
1. Abrir GameWorld.tscn
2. Verificar que existe nodo DirectionalLight3D
3. Si no existe, crearlo:
   - Add Node → DirectionalLight3D
   - Rotar para que apunte hacia abajo (0, -1, 0)
   - Energy = 1.0
   - Color = blanco
```

---

### 4. Testing de Parámetros Dinámicos

#### Test 4: Cambiar AO en Runtime
**Script de Prueba:**
```gdscript
# Añadir a GameWorld.gd o script de debug

func _input(event):
	if event.is_action_pressed("ui_page_up"):
		_adjust_ao(0.1)  # Aumentar AO
	if event.is_action_pressed("ui_page_down"):
		_adjust_ao(-0.1)  # Disminuir AO

func _adjust_ao(delta: float) -> void:
	var chunk_manager = get_node("ChunkManager")
	for chunk in chunk_manager.get_children():
		var material = chunk.mesh_instance.get_surface_override_material(0)
		if material:
			var current = material.get_shader_parameter("ao_strength")
			var new_value = clamp(current + delta, 0.0, 1.0)
			material.set_shader_parameter("ao_strength", new_value)
			print("AO Strength: ", new_value)
```

**Verificar:**
- Page Up → Esquinas más oscuras
- Page Down → Esquinas más claras

#### Test 5: Cambiar Fog en Runtime
**Script de Prueba:**
```gdscript
func _input(event):
	if event.is_action_pressed("ui_home"):
		_toggle_fog_preset("day")
	if event.is_action_pressed("ui_end"):
		_toggle_fog_preset("night")

func _toggle_fog_preset(preset: String) -> void:
	var chunk_manager = get_node("ChunkManager")
	for chunk in chunk_manager.get_children():
		var material = chunk.mesh_instance.get_surface_override_material(0)
		if material:
			match preset:
				"day":
					material.set_shader_parameter("fog_color", Color(0.7, 0.8, 0.9))
					material.set_shader_parameter("fog_start", 30.0)
					material.set_shader_parameter("fog_end", 120.0)
					print("Fog: DIA CLARO")
				"night":
					material.set_shader_parameter("fog_color", Color(0.05, 0.05, 0.15))
					material.set_shader_parameter("fog_start", 5.0)
					material.set_shader_parameter("fog_end", 40.0)
					print("Fog: NOCHE")
```

**Verificar:**
- Home → Fog azul claro, empieza lejos
- End → Fog oscuro, empieza cerca

---

### 5. Performance Testing

#### Test 6: Medir FPS con Shaders
**Cómo Medir:**
```
1. Activar estadísticas: Debug → Visible Collision Shapes (F9)
2. Observar FPS en esquina superior izquierda
3. Generar 10 chunks
4. Volar entre chunks

Benchmarks Esperados:
- 10 chunks: ~950 FPS (vs ~1000 sin shader)
- 50 chunks: ~400 FPS (vs ~420 sin shader)
- 100 chunks: ~180 FPS (vs ~200 sin shader)

Degradación esperada: ~5-10%
```

**Si FPS baja >20%:**
```gdscript
# Optimizar desactivando fog temporalmente
material.set_shader_parameter("enable_fog", false)

# Si AO es el problema, desactivarlo
material.set_shader_parameter("enable_ao", false)

# Verificar si hay múltiples luces (muy costoso)
# LIGHT shader se ejecuta por cada luz
# Recomendación: Máximo 2-3 DirectionalLight3D
```

#### Test 7: Draw Calls
**Verificar que sigue siendo 1 draw call por chunk:**
```
1. Debug → Visible Collision Shapes
2. Renderizar → Debug → Wireframe Mode
3. Observar que cada chunk es 1 mesh continuo
4. NO debe haber separación por bloques

Expected: 1 draw call por chunk (mismo que antes)
```

---

### 6. Testing de Edge Cases

#### Test 8: Chunks en Bordes (Seams)
**Verificar que NO hay costuras visuales:**
```
1. Caminar entre 2 chunks
2. Observar la línea divisoria
3. NO debe haber gap o diferencia de iluminación

Si hay seam:
  → Problema: AO no calcula vecinos inter-chunk
  → Solución: Verificar _is_block_solid() en Chunk.gd
  → Debe llamar a chunk_manager.get_block() para vecinos externos
```

#### Test 9: Bloques Transparentes (Futuro)
**Preparación para cristal/agua:**
```
Actualmente NO soportado (SHADING_MODE_UNSHADED)

Para soporte futuro:
1. Cambiar a render_mode blend_mix
2. Añadir ALPHA al shader
3. Configurar CULL_DISABLED para cristal
```

---

## 🐛 DEBUGGING COMÚN

### Problema 1: Shader No Carga
**Síntoma:** Material es blanco/rosa
**Solución:**
```gdscript
# Verificar errores de shader
var shader = load("res://shaders/block_voxel.gdshader")
if shader:
	print("✅ Shader cargado")
else:
	print("❌ Error cargando shader")

# Verificar sintaxis GLSL
# Abrir block_voxel.gdshader en Godot
# Si hay errores, aparecerán en Output
```

### Problema 2: AO Todo Oscuro o Todo Claro
**Síntoma:** Todos los vértices tienen mismo AO
**Solución:**
```gdscript
# Debug: Imprimir valores de AO
# En Chunk.gd, _calculate_vertex_ao():
func _calculate_vertex_ao(...) -> float:
	# ... código existente ...
	var ao = match filled_count: ...
	print("AO: pos=%v face=%d vertex=%d → ao=%f" % [local_pos, face, vertex_index, ao])
	return ao

# Verificar output:
# Debe mostrar variedad de valores (0.3, 0.5, 0.8, 1.0)
# Si todos son 1.0 → _is_block_solid() siempre retorna false
```

### Problema 3: Fog No Visible
**Síntoma:** Todo nítido sin importar distancia
**Solución:**
```gdscript
# Debug: Verificar que distance se calcula bien
# En block_voxel.gdshader, añadir línea temporal:

void fragment() {
	// DEBUG: Mostrar distancia como color
	// ALBEDO = vec3(vertex_distance / 100.0);  // Uncomment para debug
	// return;  // Salir temprano para ver solo distancia

	// ... resto del código ...
}

# Esperado:
# Cerca = negro (distance=0)
# Lejos = blanco (distance=100+)
```

### Problema 4: Performance Muy Bajo
**Síntoma:** FPS cae >30%
**Solución:**
```gdscript
# 1. Desactivar fog temporalmente
material.set_shader_parameter("enable_fog", false)

# 2. Reducir luces a 1 DirectionalLight3D
# 3. Verificar que no hay leaks de chunks
var chunks = chunk_manager.get_child_count()
print("Chunks activos: ", chunks)  # No debe crecer indefinidamente

# 4. Profile con Godot Profiler
# Debug → Profiler → Start
# Verificar GPU time
```

---

## 📊 RESULTADOS ESPERADOS

### Visual Quality
- ✅ **AO:** Esquinas 30-70% más oscuras que caras expuestas
- ✅ **Fog:** Transición suave entre fog_start y fog_end
- ✅ **Lighting:** Diferencia 50-100% entre cara iluminada y sombra

### Performance
- ✅ **FPS:** Degradación <10% comparado con shader básico
- ✅ **Draw Calls:** 1 por chunk (sin cambio)
- ✅ **Memoria:** +0 KB (shader compila a GPU)

### Funcionalidad
- ✅ **Parámetros:** Todos configurables en runtime
- ✅ **Presets:** Cambio instantáneo entre día/noche
- ✅ **Escalabilidad:** Funciona con 1-100+ chunks

---

## 🎯 TESTING COMPLETO CHECKLIST

```
Archivos:
  [x] Shader exists (block_voxel.gdshader)
  [x] Texture atlas exists (block_atlas.png)
  [x] Chunk.gd modificado correctamente
  [x] TextureAtlasManager.gd existe

Godot Editor:
  [ ] Proyecto abre sin errores
  [ ] Shader compila sin errores
  [ ] Texture importa correctamente
  [ ] GameWorld.tscn corre sin errores

Efectos Visuales:
  [ ] AO visible en esquinas
  [ ] Fog visible a distancia
  [ ] Iluminación diferencial visible
  [ ] Texturas se muestran correctamente

Parámetros:
  [ ] enable_ao funciona
  [ ] ao_strength configurable
  [ ] enable_fog funciona
  [ ] fog_color configurable
  [ ] fog_start/end configurables
  [ ] ambient_light configurable
  [ ] sun_intensity configurable

Performance:
  [ ] FPS degradación <10%
  [ ] Draw calls = 1 por chunk
  [ ] Sin memory leaks
  [ ] Funciona con 50+ chunks

Edge Cases:
  [ ] Sin seams entre chunks
  [ ] AO calcula vecinos inter-chunk
  [ ] Fog funciona en todas direcciones
```

---

## 🚀 NEXT STEPS

Una vez que todos los tests pasen:

1. **Documentar resultados** en SESION_COMPLETA.md
2. **Tomar screenshots** para documentación visual
3. **Crear video demo** mostrando AO + Fog
4. **Git commit** con mensaje detallado
5. **Push a GitHub**

---

**Última Actualización:** 2025-10-20
**Versión:** 1.0
**Status:** ✅ Listo para Testing

---

**¡Happy Testing!** 🧪✨
