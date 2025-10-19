# 🗺️ Multi Ninja Espacial - Roadmap de Desarrollo

> Plan de desarrollo en 4 fases desde MVP hasta lanzamiento

**Estimación total**: 8-11 meses (1-2 desarrolladores)
**Metodología**: Desarrollo iterativo con entrega incremental

---

## 📊 Resumen Ejecutivo

| Fase | Nombre | Duración | Objetivo | Entregable |
|------|--------|----------|----------|------------|
| **Fase 1** | MVP Jugable | 3-4 meses | Prototipo funcional | Demo jugable 1 planeta |
| **Fase 2** | Sistema de Virtudes | 2-3 meses | Mecánica educativa | Alpha con progresión |
| **Fase 3** | Multijugador | 2-3 meses | Juego cooperativo | Beta con multiplayer |
| **Fase 4** | Lanzamiento | 1 mes | Pulido y marketing | Versión 1.0 |

---

## 🎯 FASE 1: MVP JUGABLE (3-4 meses)

**Objetivo**: Crear un prototipo jugable con mecánicas core funcionales

### **Sprint 1: Fundaciones (2-3 semanas)**

#### **Semana 1: Setup y Arquitectura**
- [ ] Crear proyecto Godot 4.2
- [ ] Implementar estructura de carpetas completa
- [ ] Configurar autoloads (GameManager, PlayerData, AudioManager)
- [ ] Crear constantes globales (Constants.gd, Enums.gd)
- [ ] Setup de control de versiones (Git + .gitignore)

**Entregable**: Proyecto base configurado

#### **Semana 2-3: Sistema de Bloques Básico**
- [ ] Implementar BlockData (Resource)
  - Propiedades: ID, textura, dureza, drops
  - 5 bloques iniciales: Grass, Stone, Wood, Crystal, Light
- [ ] Crear Block.gd (script de bloque individual)
- [ ] Implementar Chunk.gd (16x16x16 bloques)
  - Generación de mesh con greedy meshing
  - Sistema de coordenadas world → chunk
- [ ] Crear ChunkManager.gd
  - Diccionario de chunks activos
  - Funciones: place_block(), break_block(), get_block_at()

**Entregable**: Sistema de bloques funcional (sin rendering optimizado)

---

### **Sprint 2: Jugador y Movimiento (2-3 semanas)**

#### **Semana 4-5: Controlador de Jugador**
- [ ] Crear Player.tscn (CharacterBody3D)
  - Modelo temporal (cápsula)
  - Collider
  - Cámara (Camera3D)
- [ ] Implementar PlayerMovement.gd
  - Movimiento WASD
  - Salto con gravedad
  - Sprint (Shift)
  - Detección de suelo
- [ ] Implementar PlayerCamera.gd
  - Cámara en primera persona
  - Look con mouse
  - Sensibilidad configurable

**Entregable**: Jugador se mueve fluidamente en 3D

#### **Semana 6: Interacción con Bloques**
- [ ] Implementar PlayerInteraction.gd
  - Raycast para detectar bloques
  - Colocar bloque (botón derecho)
  - Romper bloque (botón izquierdo)
  - Preview de bloque a colocar
- [ ] Sistema de inventario básico
  - Array de 10 slots
  - Add/remove items
  - Persistencia temporal (no guardado aún)

**Entregable**: Jugador puede colocar y romper bloques

---

### **Sprint 3: Generación de Terreno (2-3 semanas)**

#### **Semana 7-8: Generador Procedural**
- [ ] Implementar TerrainGenerator.gd
  - FastNoiseLite para heightmap
  - Generación de capa de grass (top)
  - Generación de piedra (debajo)
  - Spawn de árboles simples
- [ ] Sistema de chunks infinitos
  - Generar chunks alrededor del jugador
  - Unload chunks lejanos (render distance)
  - Thread pool para generación asíncrona

**Entregable**: Mundo procedural infinito

#### **Semana 9: Optimización de Rendering**
- [ ] Implementar Greedy Meshing
  - Combinar caras adyacentes del mismo tipo
  - Reducir draw calls
- [ ] Frustum culling
  - Solo renderizar chunks visibles
- [ ] LOD básico (opcional)

**Entregable**: 60 FPS con 8 chunks de render distance

---

### **Sprint 4: UI y Gameplay Básico (2-3 semanas)**

#### **Semana 10-11: HUD y Menús**
- [ ] Crear GameHUD.tscn
  - Barra de vida
  - Barra de oxígeno
  - Hotbar de inventario (slots 1-9)
  - Crosshair
- [ ] Crear MainMenu.tscn
  - Botón "Nuevo Juego"
  - Botón "Configuración"
  - Botón "Salir"
- [ ] Crear PauseMenu.tscn
  - Menú con ESC
  - Reanudar/Configuración/Salir

**Entregable**: UI funcional

#### **Semana 12: Ciclo Día/Noche y Audio**
- [ ] Implementar DayNightCycle.gd
  - DirectionalLight3D que rota
  - Cambio de color de ambiente
  - Duración configurable (default 20 min)
- [ ] Integrar AudioManager
  - Música de fondo
  - SFX (colocar bloque, romper bloque, salto)
- [ ] Sistema de recursos básico
  - Recolectar madera al romper bloque wood
  - Recolectar piedra al romper bloque stone

**Entregable**: MVP jugable completo

---

### **Hito Fase 1: Demo Jugable**

**Checklist**:
- [ ] Jugador se mueve en mundo 3D
- [ ] Puede colocar y romper bloques
- [ ] Terreno se genera proceduralmente
- [ ] Inventario funciona (10 slots)
- [ ] Ciclo día/noche activo
- [ ] Audio implementado
- [ ] 60 FPS en PC mid-range

**Decisión**: ¿Continuar a Fase 2 o iterar en MVP?

---

## 🌟 FASE 2: SISTEMA DE VIRTUDES (2-3 meses)

**Objetivo**: Implementar mecánica educativa de virtudes y Luz Interior

### **Sprint 5: Sistema de Luz Interior (2-3 semanas)**

#### **Semana 13-14: Core de Virtudes**
- [ ] Crear VirtueSystem.gd (Autoload)
  - Variable `luz_interior: int`
  - Función `add_luz(amount, reason)`
  - Diccionario de virtudes desbloqueadas
- [ ] Crear VirtueData.gd (Resource)
  - Propiedades: ID, nombre, descripción, icono, costo_luz
  - 5 virtudes: Fe, Trabajo, Amabilidad, Responsabilidad, Honestidad
- [ ] Implementar detección de acciones
  - Ayudar a jugador → +10 Luz
  - Completar construcción → +5 Luz
  - Compartir recursos → +3 Luz

**Entregable**: Sistema de Luz funcional (sin UI)

#### **Semana 15: UI de Virtudes**
- [ ] Crear VirtueTreeUI.tscn
  - Árbol de habilidades visual
  - 5 ramas (una por virtud)
  - Nodos desbloqueables
- [ ] Implementar progreso de Luz
  - Barra de progreso en HUD
  - Notificación al ganar Luz
  - Efecto visual (partículas)
- [ ] Crear VirtueNode.tscn (nodo individual)
  - Icono de virtud
  - Estado: Bloqueado/Disponible/Desbloqueado
  - Tooltip con descripción

**Entregable**: UI de virtudes completa

---

### **Sprint 6: Habilidades de Virtudes (2-3 semanas)**

#### **Semana 16-17: Implementar Bonos**
- [ ] **Virtud: Fe**
  - Nivel 1: Escudo temporal (5s invulnerabilidad) cada 60s
  - Nivel 2: Regeneración de vida +1 HP/10s
  - Nivel 3: Resurrección 1 vez por día
- [ ] **Virtud: Trabajo**
  - Nivel 1: Velocidad de construcción +20%
  - Nivel 2: Durabilidad de bloques +30%
  - Nivel 3: Doble drops al romper bloques
- [ ] **Virtud: Amabilidad**
  - Nivel 1: Radio de ayuda expandido (detectar jugadores cerca)
  - Nivel 2: Curación al ayudar (+5 HP al jugador ayudado)
  - Nivel 3: Buff de equipo (+10% stats a todos cerca)
- [ ] **Virtud: Responsabilidad**
  - Nivel 1: Consumo de oxígeno -20%
  - Nivel 2: Inventario +5 slots extra
  - Nivel 3: Auto-save cada 5 min
- [ ] **Virtud: Honestidad**
  - Nivel 1: XP bonus +10%
  - Nivel 2: Revelar recursos cercanos (X-ray temporal)
  - Nivel 3: Multiplicador de Luz +2x

**Entregable**: Todas las virtudes tienen efectos funcionales

#### **Semana 18: Balanceo y Tutorial**
- [ ] Crear TutorialManager.gd
  - Sistema de pasos guiados
  - Tooltips en primera vez
  - Introducción a Luz Interior
- [ ] Balancear costos de Luz
  - Testear progresión
  - Ajustar valores
- [ ] Crear misiones introductorias
  - "Construye tu primera casa" → +10 Luz
  - "Recolecta 50 bloques de madera" → +5 Luz

**Entregable**: Sistema de virtudes balanceado con tutorial

---

### **Sprint 7: Sistema de Guardado (1-2 semanas)**

#### **Semana 19-20: Persistencia**
- [ ] Implementar SaveSystem.gd
  - Guardar PlayerData (inventario, salud, Luz, virtudes)
  - Guardar chunks modificados
  - Formato JSON para desarrollo, binario para producción
  - Encriptación básica (AES)
- [ ] Auto-save cada 5 minutos
- [ ] Guardar al salir del juego
- [ ] Cargar al inicio

**Entregable**: Sistema de guardado funcional

---

### **Hito Fase 2: Alpha con Progresión**

**Checklist**:
- [ ] Sistema de Luz Interior implementado
- [ ] UI de virtudes funcional
- [ ] 5 virtudes con 3 niveles cada una
- [ ] Tutorial guía al jugador
- [ ] Guardado/carga funciona
- [ ] Juego balanceado (1-2 horas para desbloquear primera virtud)

**Decisión**: Testeo con usuarios (niños 4-12 años)

---

## 🌐 FASE 3: MULTIJUGADOR Y CONTENIDO (2-3 meses)

**Objetivo**: Implementar multijugador cooperativo seguro para niños

### **Sprint 8: Fundaciones de Red (2-3 semanas)**

#### **Semana 21-22: Networking Básico**
- [ ] Implementar MultiplayerManager.gd
  - Godot High-Level Multiplayer API
  - Modo Host (peer-to-peer)
  - Modo Cliente
- [ ] Crear NetworkPlayer.tscn
  - Réplica del jugador remoto
  - Interpolación de movimiento
  - Sincronización de animaciones
- [ ] Sincronizar bloques
  - RPC para place_block() y break_block()
  - Sincronizar chunks modificados

**Entregable**: 2 jugadores pueden verse y moverse

#### **Semana 23: Sincronización de Datos**
- [ ] Sincronizar inventarios (solo ver, no compartir aún)
- [ ] Sincronizar Luz Interior (mostrar barra del otro jugador)
- [ ] Sincronizar acciones (animaciones de colocar/romper)
- [ ] Implementar ownership de bloques
  - Solo el host puede modificar bloques por defecto
  - Permisos compartidos opcionales

**Entregable**: Multijugador funcional básico

---

### **Sprint 9: Seguridad Infantil (2-3 semanas)**

#### **Semana 24-25: Chat con Filtro**
- [ ] Crear ChatBox.tscn
  - Input de texto
  - Historial de mensajes
  - Filtro de palabras (lista negra)
- [ ] Implementar ChatFilter.gd
  - Lista de palabras prohibidas (configurable)
  - Reemplazo automático con "***"
  - Modo "Solo Emojis" (opcional)
- [ ] Sistema de reportes
  - Botón "Reportar jugador"
  - Log de reportes para moderación

**Entregable**: Chat seguro implementado

#### **Semana 26: Control Parental**
- [ ] Crear ParentalControlManager.gd
  - Límite de tiempo de juego (configurable)
  - Restringir multijugador (solo familia)
  - Código de invitación para partidas privadas
- [ ] UI de configuración parental
  - Protegida con PIN
  - Configurar filtros de chat
  - Ver reportes

**Entregable**: Controles parentales funcionales

---

### **Sprint 10: Contenido Adicional (2 semanas)**

#### **Semana 27-28: Modo Éxodo (Campaña)**
- [ ] Crear MissionSystem.gd
  - Lista de misiones
  - Progreso de misiones
  - Recompensas (Luz, items)
- [ ] Diseñar 10 misiones iniciales:
  1. "Construye un refugio" → +20 Luz
  2. "Recolecta 100 cristales" → +15 Luz
  3. "Ayuda a otro jugador 3 veces" → +25 Luz
  4. "Explora 5 biomas diferentes" → +30 Luz
  5. ...
- [ ] Implementar sistema de logros
  - 20 logros básicos
  - Badges en UI

**Entregable**: Modo campaña con 10 misiones

---

### **Hito Fase 3: Beta Multijugador**

**Checklist**:
- [ ] Multijugador para 2-8 jugadores funcional
- [ ] Chat con filtro de palabras
- [ ] Control parental configurado
- [ ] 10 misiones jugables
- [ ] Sin bugs críticos de red
- [ ] Latencia < 100ms en LAN

**Decisión**: Beta testing con familias

---

## 🚀 FASE 4: LANZAMIENTO (1 mes)

**Objetivo**: Pulir, marketing y lanzamiento

### **Sprint 11: Pulido (2 semanas)**

#### **Semana 29-30: Bug Fixing y Optimización**
- [ ] Corregir bugs reportados en beta
- [ ] Optimizar para dispositivos móviles
  - Reducir draw calls
  - Texturas comprimidas
  - LOD agresivo
- [ ] Añadir efectos de jugo (juice)
  - Partículas al romper bloques
  - Screen shake sutil
  - Transiciones suaves de UI
- [ ] Pulir audio
  - Mezcla de volúmenes
  - Música adaptativa
- [ ] Localización básica
  - Español (nativo)
  - Inglés

**Entregable**: Juego pulido y optimizado

---

### **Sprint 12: Marketing y Lanzamiento (2 semanas)**

#### **Semana 31: Preparación de Lanzamiento**
- [ ] Crear página de Steam/Itch.io
  - Descripción del juego
  - Screenshots (10+)
  - Trailer (1-2 min)
- [ ] Configurar precios
  - PC: $5-10 USD
  - Móvil: Gratis con ads opcionales
- [ ] Preparar press kit
  - Logo high-res
  - Screenshots
  - Información de prensa
- [ ] Configurar analytics
  - Godot Analytics
  - Telemetría básica (crashes, uso)

**Entregable**: Materiales de marketing listos

#### **Semana 32: Lanzamiento**
- [ ] Lanzar en Itch.io (día 1)
- [ ] Lanzar en Steam (día 7)
- [ ] Lanzar en móviles (día 14)
- [ ] Campaña en redes sociales
  - Twitter/X
  - YouTube (trailers)
  - Comunidades cristianas
- [ ] Contactar iglesias y escuelas cristianas
- [ ] Preparar soporte post-lanzamiento

**Entregable**: Versión 1.0 lanzada

---

### **Hito Fase 4: Lanzamiento Público**

**Checklist**:
- [ ] Juego disponible en 3+ plataformas
- [ ] Página de tienda activa
- [ ] Trailer publicado
- [ ] Soporte técnico listo
- [ ] Sin bugs críticos
- [ ] Métricas de analytics configuradas

---

## 📊 Resumen de Recursos

### **Equipo Recomendado**

| Rol | Cantidad | Responsabilidad |
|-----|----------|-----------------|
| **Desarrollador Godot** | 1-2 | Programación, sistemas |
| **Artista 3D** | 1 (freelance) | Modelos, texturas |
| **Diseñador de Audio** | 1 (freelance) | Música, SFX |
| **Tester** | 2-3 (voluntarios) | QA, feedback |

### **Presupuesto Estimado** (Indie)

| Ítem | Costo |
|------|-------|
| Godot (gratis) | $0 |
| Assets (modelos, texturas) | $200-500 |
| Audio (freelance) | $500-1000 |
| Steam Direct Fee | $100 |
| Apple Developer Account | $99/año |
| Google Play Developer | $25 |
| Marketing | $500-1000 |
| **Total** | **$1,424-2,724** |

### **Tiempo Total**

- **Mínimo**: 8 meses (equipo de 2, full-time)
- **Promedio**: 11 meses (equipo de 1-2, part-time)
- **Máximo**: 15 meses (solo, part-time)

---

## 🎯 Métricas de Éxito

### **MVP (Fase 1)**:
- [ ] 10 jugadores de prueba completan 30 min sin bugs

### **Alpha (Fase 2)**:
- [ ] 50 jugadores testean virtudes
- [ ] Feedback positivo sobre progresión (>70%)

### **Beta (Fase 3)**:
- [ ] 100 jugadores en multijugador
- [ ] 0 reportes de contenido inapropiado en chat
- [ ] Padres aprueban controles (>80%)

### **Lanzamiento (Fase 4)**:
- [ ] 1,000 descargas en primera semana
- [ ] Rating >4.0/5.0 en tiendas
- [ ] Cobertura en 5+ medios cristianos

---

## 🔄 Plan de Post-Lanzamiento

### **Versión 1.1 (1 mes post-lanzamiento)**:
- [ ] Añadir 3 planetas nuevos
- [ ] 20 misiones adicionales
- [ ] Sistema de clanes/guilds

### **Versión 1.2 (3 meses post-lanzamiento)**:
- [ ] Modo PvE cooperativo (luchar enemigos)
- [ ] Sistema de mascotas
- [ ] Editor de niveles

### **Versión 2.0 (6 meses post-lanzamiento)**:
- [ ] Streaming seguro integrado (para padres)
- [ ] Kits escolares (para usar en clase)
- [ ] API para desarrolladores

---

## ✅ Próximos Pasos Inmediatos

**Para empezar HOY**:

1. **Crear proyecto Godot 4.2**
2. **Implementar estructura de carpetas**
3. **Crear autoloads básicos** (GameManager, PlayerData)
4. **Implementar BlockData Resource**
5. **Crear Player.tscn con movimiento básico**

¿Quieres que genere el código GDScript para estos componentes iniciales? 🚀
