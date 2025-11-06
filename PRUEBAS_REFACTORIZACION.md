# 🧪 Guía de Pruebas - Sistema de Biomas Refactorizado

## 📋 Checklist de Verificación

### Fase 1: Tests Automáticos ✓

#### Ejecutar Test Suite
1. Abrir Godot
2. Abrir la escena: `tests/TestBiomeSystem.tscn`
3. Presionar F6 o "Ejecutar Escena Actual"
4. Verificar que todos los tests pasen en la consola

**Resultado Esperado:**
```
🧪 INICIANDO TESTS DEL SISTEMA DE BIOMAS REFACTORIZADO

📋 Test 1: Inicialización del Sistema
   ✅ Sistema inicializado correctamente

📋 Test 2: Consistencia de Biomas
   ✅ Biomas consistentes en todas las posiciones

📋 Test 3: Diversidad de Biomas
   ✅ Se encontraron X tipos de biomas diferentes

📋 Test 4: Configuración de Bloques por Bioma
   ✅ Todos los biomas tienen bloques correctamente configurados

📋 Test 5: Sistema de Caché
   ✅ Sistema de caché funciona correctamente

📋 Test 6: Rangos de Altura por Bioma
   ✅ Todos los rangos de altura son válidos

📋 Test 7: Integración con TerrainGenerator
   ✅ BiomeManager proporciona todos los datos necesarios

✅ TODOS LOS TESTS PASARON
```

---

### Fase 2: Tests Manuales en Juego 🎮

#### Test 1: Cargar el Juego
- [ ] Abrir escena principal: `scenes/main/Main.tscn`
- [ ] Presionar F5 o "Ejecutar Proyecto"
- [ ] **Verificar:** Juego carga sin errores
- [ ] **Verificar:** No hay warnings en consola sobre BiomeSystem

**❌ Si falla:** Revisar consola para errores de inicialización

---

#### Test 2: Generación de Terreno
- [ ] El mundo se genera correctamente
- [ ] Hay variedad visual en el terreno (diferentes colores/texturas)
- [ ] No hay huecos ni bloques faltantes

**Qué buscar:**
- **Tierra** (verde/marrón) → Bioma BOSQUE
- **Arena** (amarillo) → Bioma DESIERTO o PLAYA
- **Piedra** (gris) → Bioma MONTAÑA
- **Cristal** (morado) → Bioma CRISTAL (raro)

**❌ Si falla:**
- Verificar en consola: `BiomeManager inicializado`
- Verificar: TerrainGenerator se inicializa después

---

#### Test 3: Diferentes Alturas por Bioma
- [ ] Montañas son más altas que playas
- [ ] Playas están a nivel bajo (cerca de Y=4-6)
- [ ] Bosques tienen altura media (Y=8-12)

**Cómo verificar:**
1. Activar coordenadas en pantalla (F3 o debug UI)
2. Caminar por diferentes biomas
3. Observar valor Y de posición del jugador

**❌ Si falla:** BiomeManager.get_height_range() no funciona

---

#### Test 4: Bloques Subterráneos Correctos
- [ ] Cavar en desierto → encuentra arena por algunos bloques, luego piedra
- [ ] Cavar en bosque → encuentra piedra inmediatamente bajo tierra
- [ ] Bloques profundos (Y < altura - 3) son siempre piedra

**Cómo verificar:**
1. Equipar herramienta
2. Cavar verticalmente hacia abajo en diferentes biomas
3. Observar secuencia de bloques

**❌ Si falla:**
- `get_underground_block()` o `get_deep_block()` no funcionan
- Revisar TerrainGenerator._get_block_type_for_biome()

---

#### Test 5: Árboles Spawn según Bioma
- [ ] Bosques tienen MUCHOS árboles (~3% probabilidad)
- [ ] Desiertos tienen POCOS o ningún árbol (~0.1%)
- [ ] Montañas tienen algunos árboles (~1%)
- [ ] Playas tienen pocos árboles (~0.5%)
- [ ] Cristales NO tienen árboles (0%)

**Cómo verificar:**
1. Volar por el mundo (modo noclip si disponible)
2. Contar árboles en diferentes biomas
3. Comparar densidad

**❌ Si falla:** BiomeManager.get_tree_chance() no funciona

---

#### Test 6: NPCs Spawneados Correctamente
- [ ] 3 NPCs aparecen al inicio (Anciano, Constructor, Minera)
- [ ] NPCs no están enterrados en el suelo
- [ ] NPCs tienen colores distintivos
- [ ] Puedes interactuar con ellos (tecla E)

**Cómo verificar:**
1. Mirar alrededor del spawn point
2. Buscar cápsulas de colores (NPCs)
3. Acercarse y presionar E para interactuar

**❌ Si falla:** NPCManager spawn order (add_child antes de position)

---

#### Test 7: Performance y Caché
- [ ] Juego corre fluido (>30 FPS)
- [ ] No hay stuttering al caminar por el mundo
- [ ] Generación de chunks es rápida

**Cómo verificar:**
1. Activar FPS counter (F3 o debug)
2. Caminar rápidamente por el mundo
3. Observar FPS y tiempos de carga

**Verificar en consola:**
```
BiomeManager cache stats:
  - Size: X/1000
  - Usage: Y%
```

**❌ Si falla:** Caché no está funcionando (llamar a BiomeManager.get_cache_stats())

---

### Fase 3: Tests de Regresión 🔄

#### Verificar que funcionalidades existentes NO se rompieron

- [ ] Sistema de logros funciona
- [ ] Colocar bloques funciona
- [ ] Romper bloques funciona
- [ ] Sistema de misiones funciona
- [ ] Herramientas mágicas funcionan
- [ ] Efectos de partículas funcionan
- [ ] Audio funciona (sonidos de bloques, UI)

**❌ Si alguno falla:** Revisar si depende de BiomeSystem (ahora BiomeManager)

---

## 🐛 Troubleshooting

### Error: "BiomeManager not initialized"
**Solución:**
1. Verificar que `project.godot` tiene:
   ```ini
   BiomeManager="*res://scripts/world/BiomeManager.gd"
   ```
2. Verificar que TerrainGenerator llama `BiomeManager.initialize(seed)` en `_ready()`

### Error: "Cannot access property 'underground_block'"
**Solución:**
- BiomeGenerator.BIOME_DATA falta propiedades
- Verificar que TODOS los biomas tienen: `surface_block`, `underground_block`, `deep_block`

### Error: "Class 'BiomeSystem' could not be found"
**Solución:**
- Buscar referencias antiguas a `BiomeSystem` en el código
- Reemplazar por `BiomeManager`
- Archivo viejo: `scripts/world/BiomeSystem.gd.old`

### Warning: "STATIC_CALLED_ON_INSTANCE"
**Solución:**
- Verificar que BiomeManager NO tiene funciones `static`
- Verificar que BiomeGenerator NO es autoload

### Terreno se ve todo igual (sin variedad)
**Solución:**
1. Verificar seed en GameWorld: `BiomeManager.initialize(world_seed)`
2. Verificar que BiomeGenerator.calculate_biome() retorna valores diferentes
3. Ejecutar test_biome_diversity() para verificar

### FPS bajo / stuttering
**Solución:**
1. Verificar caché: `BiomeManager.get_cache_stats()`
2. Si caché está lleno constantemente, incrementar MAX_CACHE_SIZE
3. Reducir WORLD_SIZE_CHUNKS si es necesario

---

## 📊 Métricas Esperadas

### Performance
- **FPS:** >30 (idealmente 60)
- **Tiempo de generación de mundo:** <5 segundos
- **Uso de caché:** <50% en mundo pequeño (10x10 chunks)

### Diversidad
- **Biomas encontrados en 100x100 área:** 3-5 tipos diferentes
- **Bioma más común:** Bosque (~40-50%)
- **Bioma más raro:** Cristal (<10%)

### Correctitud
- **Tests pasados:** 7/7
- **Errores en consola:** 0
- **Warnings:** 0 (excepto deprecations de Godot)

---

## ✅ Criterios de Aceptación

Para considerar la refactorización exitosa:

1. ✓ **Todos los tests automáticos pasan** (7/7)
2. ✓ **Juego carga sin errores**
3. ✓ **Terreno se genera con variedad visual**
4. ✓ **Diferentes biomas tienen diferentes alturas**
5. ✓ **Bloques subterráneos correctos por bioma**
6. ✓ **Árboles spawn según probabilidad del bioma**
7. ✓ **NPCs aparecen correctamente**
8. ✓ **Performance es aceptable** (>30 FPS)
9. ✓ **Funcionalidades existentes NO se rompieron**
10. ✓ **Sin warnings de STATIC_CALLED_ON_INSTANCE**

---

## 📝 Reporte de Resultados

Después de ejecutar las pruebas, documenta:

```markdown
## Resultados de Pruebas - Sistema de Biomas Refactorizado

**Fecha:** [FECHA]
**Tester:** [NOMBRE]

### Tests Automáticos
- Test 1 (Inicialización): ☐ PASS ☐ FAIL
- Test 2 (Consistencia): ☐ PASS ☐ FAIL
- Test 3 (Diversidad): ☐ PASS ☐ FAIL
- Test 4 (Bloques): ☐ PASS ☐ FAIL
- Test 5 (Caché): ☐ PASS ☐ FAIL
- Test 6 (Alturas): ☐ PASS ☐ FAIL
- Test 7 (Integración): ☐ PASS ☐ FAIL

### Tests Manuales
- Carga de juego: ☐ PASS ☐ FAIL
- Generación terreno: ☐ PASS ☐ FAIL
- Alturas variadas: ☐ PASS ☐ FAIL
- Bloques subterráneos: ☐ PASS ☐ FAIL
- Spawn de árboles: ☐ PASS ☐ FAIL
- NPCs: ☐ PASS ☐ FAIL
- Performance: ☐ PASS ☐ FAIL

### Tests de Regresión
- Logros: ☐ PASS ☐ FAIL
- Colocar bloques: ☐ PASS ☐ FAIL
- Romper bloques: ☐ PASS ☐ FAIL
- Misiones: ☐ PASS ☐ FAIL
- Herramientas: ☐ PASS ☐ FAIL
- Partículas: ☐ PASS ☐ FAIL
- Audio: ☐ PASS ☐ FAIL

### Métricas
- FPS promedio: _____
- Tiempo de generación: _____ s
- Biomas encontrados: _____
- Uso de caché: _____%

### Problemas Encontrados
[Describir cualquier problema, error o comportamiento inesperado]

### Conclusión
☐ Refactorización EXITOSA - Listo para continuar
☐ Refactorización NECESITA AJUSTES - Ver problemas arriba
```

---

## 🚀 Siguiente Paso

Una vez que **TODOS** los criterios de aceptación estén ✅:

**Continuar con:** Refactorización de StructureGenerator usando el mismo patrón
- Crear `StructureGeneratorBase` (lógica pura)
- Crear `StructureManager` (orchestrator autoload)
- Separar generadores específicos (Casa, Templo, Torre, Altar)

**No continuar si:** Hay problemas sin resolver en el sistema de biomas
