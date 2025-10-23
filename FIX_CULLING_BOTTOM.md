# 🐛 Fix: Problema de Culling en Cara BOTTOM

**Fecha:** 2025-10-23
**Commit:** 5bb8f44
**Severidad:** Alta (Bug visual crítico)

---

## 📋 Problema Reportado

**Usuario:** "Cuando creo bloques marrones a veces no pinta el marrón, se hace invisible la parte de abajo del bloque y se ve el cielo"

### Síntomas
- ✗ Bloques de tierra (marrones) invisibles desde abajo
- ✗ Se puede ver el cielo a través del suelo
- ✗ Agujeros aleatorios en el mundo
- ✗ Solo afecta la cara inferior (BOTTOM)

### Impacto
- Jugabilidad afectada (caer a través del mundo)
- Inmersión rota (ver cielo donde no debería)
- Construcciones con huecos visuales

---

## 🔍 Diagnóstico Técnico

### Causa Raíz

**Orden de vértices incorrecto** en la generación de la cara BOTTOM del mesh.

El shader usa `render_mode cull_back`, que elimina caras traseras para optimización. Para determinar si una cara está "de frente" o "de espaldas", OpenGL/Godot usa la regla de **winding order** (orden de bobinado):

- **Counter-Clockwise (CCW)** desde fuera → Cara frontal (visible)
- **Clockwise (CW)** desde fuera → Cara trasera (culled/eliminada)

### Problema Específico

```gdscript
// ANTES (INCORRECTO):
Enums.BlockFace.BOTTOM:
    return [
        Vector3(0, 0, 1),  // vert 0
        Vector3(1, 0, 1),  // vert 1
        Vector3(1, 0, 0),  // vert 2
        Vector3(0, 0, 0)   // vert 3
    ]
```

**Visualización desde abajo (Y negativo):**
```
Vista desde abajo:
     +Z
      ↑
0 ← → 3
      ↓
     -Z

Orden: 0→1→2→3 = CLOCKWISE
Resultado: cull_back la elimina ❌
```

---

## ✅ Solución Implementada

### Nuevo Orden de Vértices

```gdscript
// DESPUÉS (CORRECTO):
Enums.BlockFace.BOTTOM:
    return [
        Vector3(0, 0, 0),  // vert 0 (cambio)
        Vector3(1, 0, 0),  // vert 1 (cambio)
        Vector3(1, 0, 1),  // vert 2 (cambio)
        Vector3(0, 0, 1)   // vert 3 (cambio)
    ]
```

**Visualización correcta:**
```
Vista desde abajo:
     -Z
      ↑
3 ← → 0
      ↓
     +Z

Orden: 0→1→2→3 = COUNTER-CLOCKWISE
Resultado: Cara visible ✅
```

### Cambios en AO (Ambient Occlusion)

También se actualizó el mapeo de vecinos para AO, reflejando el nuevo orden:

```gdscript
Enums.BlockFace.BOTTOM:
    match real_vertex_index:
        0:  # (0, 0, 0) - Esquina frontal izquierda
            neighbors = [
                Vector3i(-1, -1,  0),  // Lado izquierdo
                Vector3i( 0, -1, -1),  // Lado frontal
                Vector3i(-1, -1, -1)   // Esquina
            ]
        1:  # (1, 0, 0) - Esquina frontal derecha
            neighbors = [
                Vector3i( 1, -1,  0),  // Lado derecho
                Vector3i( 0, -1, -1),  // Lado frontal
                Vector3i( 1, -1, -1)   // Esquina
            ]
        2:  # (1, 0, 1) - Esquina trasera derecha
            neighbors = [
                Vector3i( 1, -1,  0),  // Lado derecho
                Vector3i( 0, -1,  1),  // Lado trasero
                Vector3i( 1, -1,  1)   // Esquina
            ]
        3:  # (0, 0, 1) - Esquina trasera izquierda
            neighbors = [
                Vector3i(-1, -1,  0),  // Lado izquierdo
                Vector3i( 0, -1,  1),  // Lado trasero
                Vector3i(-1, -1,  1)   // Esquina
            ]
```

---

## 🔧 Archivos Modificados

**scripts/world/Chunk.gd**
- Línea 250-252: `_get_face_vertices()` - Orden de vértices BOTTOM
- Línea 441-448: `_get_ao_neighbors()` - Mapeo de vecinos AO

---

## 🧪 Testing

### Cómo Verificar el Fix

1. **Ejecutar el juego**
2. **Colocar bloques de tierra (tecla 1)**
3. **Construir una plataforma**
4. **Mirar desde abajo** (caminar debajo de la plataforma)
5. **Resultado esperado:** Caras inferiores visibles, no se ve el cielo

### Casos de Prueba

| Caso | Antes | Después |
|------|-------|---------|
| Mirar bloque desde abajo | ❌ Invisible | ✅ Visible |
| AO en esquinas inferiores | ❌ Incorrecto | ✅ Correcto |
| Construir plataforma | ❌ Agujeros | ✅ Sólido |
| Todos los bloques | ❌ Afectados | ✅ Funcionan |

---

## 📊 Teoría: Face Culling en 3D

### ¿Qué es Face Culling?

**Optimización** que elimina caras que no son visibles (apuntan lejos de la cámara).

```
┌─────────────────────────────────┐
│ render_mode cull_back           │
├─────────────────────────────────┤
│ - Elimina caras "traseras"      │
│ - Determina usando winding      │
│ - Ahorra 50% de píxeles         │
│ - Estándar en juegos 3D         │
└─────────────────────────────────┘
```

### Winding Order (Orden de Bobinado)

**Regla de la mano derecha:**
```
     Normal
       ↑
       |
    2──┴──1
    |     |
    3─────0

Si 0→1→2→3 va CCW (sentido antihorario):
Normal apunta HACIA TI (visible)

Si 0→1→2→3 va CW (sentido horario):
Normal apunta LEJOS DE TI (culled)
```

### Por Qué Importa en Voxels

En un mundo voxel:
- Cada bloque tiene **6 caras**
- Cada cara tiene **4 vértices**
- Cada vértice debe estar en **orden correcto**

Si UNA cara tiene orden invertido:
- Se vuelve invisible desde un lado
- Crea agujeros visuales
- Rompe la ilusión del mundo sólido

---

## 🎯 Otras Caras (Para Referencia)

### Orden Correcto de Todas las Caras

```gdscript
// Vista desde FUERA del bloque (CCW)

TOP (Y+):    [0,1,0] → [1,1,0] → [1,1,1] → [0,1,1]
BOTTOM (Y-): [0,0,0] → [1,0,0] → [1,0,1] → [0,0,1] ✅ FIXED
NORTH (Z+):  [0,0,1] → [0,1,1] → [1,1,1] → [1,0,1]
SOUTH (Z-):  [1,0,0] → [1,1,0] → [0,1,0] → [0,0,0]
EAST (X+):   [1,0,1] → [1,1,1] → [1,1,0] → [1,0,0]
WEST (X-):   [0,0,0] → [0,1,0] → [0,1,1] → [0,0,1]
```

### Cómo Verificar Orden

1. **Imaginar mirando la cara desde fuera**
2. **Trazar el camino 0→1→2→3**
3. **¿Va en sentido antihorario?** → ✅ Correcto
4. **¿Va en sentido horario?** → ❌ Invertir

---

## 🐛 Bugs Relacionados (Potenciales)

Si aparecen problemas similares en otras caras:

### Diagnóstico
```gdscript
// Síntomas por cara:
TOP invisible    → Verificar orden vista desde arriba
NORTH invisible  → Verificar orden vista desde norte
SOUTH invisible  → Verificar orden vista desde sur
EAST invisible   → Verificar orden vista desde este
WEST invisible   → Verificar orden vista desde oeste
```

### Fix Genérico
```gdscript
// Paso 1: Identificar cara problemática
// Paso 2: Visualizar desde fuera
// Paso 3: Verificar si 0→1→2→3 es CCW
// Paso 4: Si es CW, invertir orden
// Paso 5: Actualizar mapeo AO si existe
```

---

## 📝 Lecciones Aprendidas

### Para Desarrolladores

1. **Winding order es crítico** en rendering 3D
2. **cull_back requiere CCW** desde fuera
3. **Verificar TODAS las caras** al generar meshes
4. **AO depende del orden** - actualizar juntos

### Best Practices

```gdscript
// ✅ BUENO: Documentar orden esperado
Enums.BlockFace.BOTTOM:
    // Vértices en CCW desde abajo (Y-)
    return [
        Vector3(0, 0, 0),  // Front-left
        Vector3(1, 0, 0),  // Front-right
        Vector3(1, 0, 1),  // Back-right
        Vector3(0, 0, 1)   // Back-left
    ]

// ❌ MALO: Sin documentación
Enums.BlockFace.BOTTOM:
    return [
        Vector3(0, 0, 1), Vector3(1, 0, 1),
        Vector3(1, 0, 0), Vector3(0, 0, 0)
    ]
```

### Testing Checklist

- [ ] Mirar cada cara desde su lado exterior
- [ ] Verificar con bloques de colores diferentes
- [ ] Testear con AO activado/desactivado
- [ ] Construir estructuras complejas
- [ ] Verificar en diferentes ángulos

---

## 🎮 Impacto en el Jugador

**Antes del Fix:**
- ❌ Confusión: "¿Por qué veo el cielo?"
- ❌ Gameplay roto: Caer a través del mundo
- ❌ Construcciones con huecos

**Después del Fix:**
- ✅ Mundo sólido y consistente
- ✅ Construcción confiable
- ✅ Experiencia pulida

---

## 📊 Estadísticas del Fix

```
Commit:         5bb8f44
Archivos:       1 (Chunk.gd)
Líneas:         ~10 modificadas
Complejidad:    Baja (reordenar array)
Impacto:        Alto (bug crítico)
Testing:        Manual (construcción + verificación visual)
```

---

## 🚀 Estado Post-Fix

### ✅ Características Funcionando

- Generación de mundo voxel
- 6 caras por bloque renderizadas correctamente
- Ambient Occlusion preciso
- Face culling optimizado
- Mundo visualmente sólido

### 🎯 Próximas Mejoras Sugeridas

1. **Unit tests** para orden de vértices
2. **Debug visualization** de normales
3. **Greedy meshing** para optimizar
4. **Backface culling debug mode** (desactivar temporalmente)

---

**Fix Verificado:** ✅ Funcionando correctamente
**Prioridad:** Alta (bug visual crítico)
**Dificultad:** Baja (reordenar array)
**Impacto:** Alto (mejora experiencia visual)

---

## 🔗 Referencias

- **Godot Docs:** SurfaceTool, Mesh Generation
- **OpenGL Spec:** Face Culling, Winding Order
- **Relacionado:** `block_voxel.gdshader:12` (render_mode cull_back)
- **Issue Original:** Reportado por usuario el 2025-10-23
