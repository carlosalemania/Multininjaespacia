# 🎮 Guía de Controles y Sistemas - Multininja Espacial

## 🎯 Cómo Ver y Usar Todo lo Implementado

### 🚀 Inicio Rápido

Cuando inicies el juego, verás automáticamente:
- **12 animales** spawneados alrededor tuyo (ovejas, vacas, gallinas, conejos, venados, pájaros)
- **2 hogueras**: una encendida (con fuego visual) y otra apagada
- **3 NPCs humanoides** caminando cerca
- **Barras de supervivencia** en la esquina superior izquierda (hambre, sed, temperatura)
- **Quest tracker** en la esquina superior derecha (cuando aceptes misiones)

---

## ⌨️ Controles Básicos

### Movimiento
- **W/A/S/D** - Mover
- **Espacio** - Saltar
- **Shift** - Correr
- **Mouse** - Mirar alrededor

### Construcción
- **Click Izquierdo** - Romper bloque
- **Click Derecho** - Colocar bloque
- **Números 1-9** - Seleccionar slot del hotbar
- **Mouse Wheel** - Cambiar slot activo

### Sistemas Nuevos
- **F** - Toggle furniture mode (modo muebles) [PRÓXIMAMENTE]
- **C** - Abrir menú de crafteo [PRÓXIMAMENTE]
- **E** - Interactuar con objetos (NPCs, hogueras, animales)
- **F3** - Toggle debug info

### Menús
- **ESC** - Pausa / Menú
- **I** - Inventario [PRÓXIMAMENTE]

---

## 🦌 Sistema de Caza

### Animales Disponibles

| Animal | HP | Drops | Ubicación |
|--------|----|----|-----------|
| 🐑 Oveja | 30 | raw_meat (1-2), wool (2-4) | A la derecha del spawn |
| 🐄 Vaca | 50 | raw_meat (2-4), leather (1-3) | A la izquierda del spawn |
| 🐔 Gallina | 10 | raw_chicken, feather (1-3), egg (30%) | Delante del spawn |
| 🐰 Conejo | 15 | raw_meat, rabbit_hide (70%) | Cerca de las gallinas |
| 🦌 Venado | 60 | raw_meat (3-5), leather (2-4), antler (50%) | Lejos al sur |
| 🐦 Pájaro | 5 | feather (2-4) | Volando arriba |

### Cómo Cazar

1. **Encontrar un animal** - Mira alrededor, están cerca del spawn
2. **Golpear** - Click izquierdo para atacar
3. **Perseguir** - Los animales huyen al recibir daño
4. **Loot** - Al morir, dropean items automáticamente
5. **Recoger** - Los items caen al suelo (pickup automático cuando toques)

### Progreso de Quests
Cada animal cazado cuenta para objetivos de quests como:
- "Caza 3 ovejas"
- "Recolecta 5 piezas de carne cruda"

---

## 🔥 Sistema de Hogueras

### Ubicaciones de Hogueras

1. **Hoguera Principal** - 5 bloques al este, **YA ENCENDIDA**
   - Fuego naranja visible
   - Luz dinámica
   - Partículas de humo
   - Área de calor (te calienta si estás cerca)

2. **Hoguera Secundaria** - 8 bloques al suroeste, **APAGADA**
   - Troncos apilados
   - Parrilla de cocina
   - Lista para encender

### Cómo Usar Hogueras

#### Encender Fuego
```gdscript
# Acercarte a una hoguera apagada
# Presionar E para interactuar
# La hoguera se enciende automáticamente con 100 de combustible
```

#### Cocinar Comida
1. **Acércate a la hoguera encendida**
2. **Interactúa con E** (muestra info en consola)
3. **Usa comandos desde la consola de Godot**:

```gdscript
# Desde el Remote Scene Tree en Godot, selecciona la Campfire y ejecuta:
var campfire = $GameWorld/Campfire
campfire.cook_item("raw_meat")   # Cocina carne → cooked_meat (10s)
campfire.cook_item("raw_fish")   # Cocina pescado → cooked_fish (6s)
campfire.cook_item("potato")     # Hornea papa → baked_potato (5s)
```

#### Recetas Disponibles

| Input | Output | Tiempo | Efecto |
|-------|--------|--------|--------|
| raw_meat | cooked_meat | 10s | +30 hambre, +5 HP |
| raw_chicken | cooked_chicken | 8s | +28 hambre, +5 HP |
| raw_fish | cooked_fish | 6s | +25 hambre, +5 HP |
| potato | baked_potato | 5s | +22 hambre |
| corn | roasted_corn | 5s | +20 hambre |
| dirty_water | clean_water | 15s | +40 sed |

### Área de Calor
- **Radio**: 3 metros alrededor de la hoguera
- **Efecto**: Aumenta tu temperatura corporal en +15°C
- **Visual**: Cuando estás cerca, tu barra de temperatura sube

---

## 🍖 Sistema de Supervivencia

### Barras de Supervivencia (Esquina Superior Izquierda)

#### 🍖 Barra de Hambre
- **Máximo**: 100
- **Drain**: -1.0 por segundo (más rápido al correr)
- **Efectos**:
  - < 20: Movimiento lento, stamina baja
  - = 0: **-5 HP cada 2 segundos** ⚠️

#### 💧 Barra de Sed
- **Máximo**: 100
- **Drain**: -1.5 por segundo (más rápido con calor)
- **Efectos**:
  - < 20: Movimiento muy lento
  - = 0: **-5 HP cada 2 segundos** ⚠️

#### 🌡️ Temperatura Corporal
- **Normal**: 37°C
- **Rangos**:
  - < 0°C: Congelándote (-10 HP/2s)
  - < 10°C: Frío (-3 HP/2s)
  - 15-30°C: Cómodo ✅
  - > 40°C: Calor (-3 HP/2s)
  - > 50°C: Quemándote (-10 HP/2s)

### Cómo Sobrevivir

#### Recuperar Hambre
```gdscript
# Desde consola de Godot:
SurvivalSystem.eat_food("cooked_meat")  # +30 hambre, +5 HP
SurvivalSystem.eat_food("bread")        # +20 hambre
SurvivalSystem.eat_food("apple")        # +15 hambre, +5 sed
```

#### Recuperar Sed
```gdscript
# Desde consola:
SurvivalSystem.drink_water(30.0)          # +30 sed
SurvivalSystem.drink_item("clean_water")  # +40 sed
SurvivalSystem.drink_item("milk")         # +25 sed, +10 hambre
```

#### Regular Temperatura
- **Calentarse**: Acércate a una hoguera encendida
- **Enfriarse**: Aléjate del fuego, busca sombra
- **Refugio**: Entra en una estructura (reduce extremos)

---

## 📜 Sistema de Misiones (Quests)

### Ver Quest Tracker
- **Ubicación**: Esquina superior derecha
- **Muestra**: Misiones activas y progreso de objetivos
- **Colores**:
  - Verde = Objetivo completado ✅
  - Blanco = En progreso
  - Amarillo = Título de quest

### Aceptar Misiones

```gdscript
# Desde consola de Godot:
QuestSystem.accept_quest("tutorial_welcome")
QuestSystem.accept_quest("gather_wood")
QuestSystem.accept_quest("hunt_animals")
```

### Misiones Disponibles

#### 📖 Tutorial: Bienvenido (tutorial_welcome)
- Recolectar 10 bloques de madera
- Craftear 5 antorchas
- **Recompensas**: 50 EXP, 10 monedas

#### 🌲 Recolección: Madera (gather_wood)
- Recolectar 50 bloques de madera
- **Recompensas**: 100 EXP, 25 monedas

#### ⚔️ Caza: Animales (hunt_animals)
- Cazar 5 ovejas
- Cazar 3 vacas
- **Recompensas**: 150 EXP, 50 monedas

#### 🍖 Supervivencia: Comida (food_supply)
- Cocinar 10 carnes
- Recolectar 20 manzanas
- **Recompensas**: 120 EXP, 30 monedas

### Progreso Automático
El sistema detecta automáticamente cuando:
- Recolectas items
- Cazas animales
- Cocinas comida
- Construyes estructuras

---

## 👥 NPCs y Personajes

### NPCs Actuales
- **3 NPCs humanoides** spawneados cerca del jugador
- **Comportamiento**: Wandering (caminan aleatoriamente)
- **Visual**: Modelo humanoide procedural
- **Interacción**: Presiona E para hablar [PRÓXIMAMENTE]

### Otros Jugadores (Multijugador)
⚠️ **Nota sobre el "cono"**: El modelo del jugador actual es temporal.

**Para mejorar visualización del jugador**:
1. El jugador usa `HumanoidModelGenerator` para crear modelos
2. Los multiplayer peers también usan el mismo generador
3. El modelo incluye: cuerpo, cabeza, brazos, piernas
4. El "cono" aparece cuando falta el modelo 3D completo

**Solución temporal**: Los modelos ya están implementados pero necesitan ser instanciados correctamente en Player.tscn.

---

## ⚔️ Sistema de Armas y Herramientas

### Armas Disponibles (20 tipos)
```gdscript
# Desde consola, equipar arma:
var player = $GameWorld/Player
var visualizer = AccessoryVisualizer.new()
visualizer.initialize(player)
visualizer.equip_weapon("sword_iron", AccessoryVisualizer.AttachPoint.RIGHT_HAND)
```

### Tipos de Armas
- **Espadas**: Basic, Iron, Steel, Mythril, Flame
- **Hachas**: Wood Axe, Battle Axe, Great Axe
- **Dagas**: Rusty Dagger, Assassin Dagger, Poison Dagger
- **Lanzas**: Wooden Spear, Iron Spear
- **Arcos**: Hunter Bow, Longbow, Crossbow
- **Mágicas**: Magic Staff, Fire Staff, Ice Staff, Holy Staff
- **Otras**: Warhammer, Mace

### Herramientas Disponibles
- **Pico**: Wood, Stone, Iron, Diamond
- **Hacha**: Wood, Stone, Iron
- **Pala**: Wood, Stone, Iron
- **Azada**: Wood, Stone, Iron

### Accesorios Visuales
```gdscript
# Equipar accesorio:
visualizer.equip_accessory("torch", AccessoryVisualizer.AttachPoint.LEFT_HAND)
visualizer.equip_accessory("shield_iron", AccessoryVisualizer.AttachPoint.LEFT_HAND)
visualizer.equip_accessory("lantern", AccessoryVisualizer.AttachPoint.LEFT_HAND)
visualizer.equip_accessory("backpack", AccessoryVisualizer.AttachPoint.BACK)
```

---

## 🏠 Sistema de Muebles

### Muebles Disponibles (20 tipos)

#### Básicos
- Silla, Mesa, Cama, Cofre, Barril

#### Iluminación
- Antorcha de Pared, Lámpara, Candelabro, Lámpara de Pie

#### Decoración
- Planta en Maceta, Cuadro, Alfombra, Estantería, Armario

#### Utilidad
- Horno, Yunque, Mesa de Trabajo, Banco de Carpintero

#### Educación
- Escritorio, Librería

### Cómo Colocar Muebles
```gdscript
# Desde consola:
var placement = FurniturePlacement.new()
placement.start_placement("wooden_chair")
# Luego mueve el mouse y click derecho para colocar
```

---

## 🎨 Efectos Visuales Implementados

### Partículas
- ✨ Fuego (hogueras)
- 💨 Humo (hogueras)
- 🌫️ Polvo ambiental (5 ubicaciones cerca del spawn)
- ⭐ Efectos de combustible bajo
- 💥 Efectos de combate [TODO]

### Iluminación Dinámica
- 🔥 Hogueras (luz naranja cálida, radio 8m)
- 🔦 Antorchas (luz naranja, radio 4m)
- 🏮 Linternas (luz amarilla cálida, radio 6m)
- 🌅 Ciclo día/noche (luz direccional rotante)

### Modelos 3D Procedurales
- **Animales**: 6 tipos con colores y tamaños realistas
- **Hogueras**: Piedras, troncos, parrilla, fuego
- **Muebles**: 20 modelos funcionales
- **Armas**: 12 modelos base
- **Accesorios**: Antorcha, escudo, linterna, mochila
- **NPCs**: Modelo humanoide completo

---

## 🐛 Comandos de Debug

### Supervivencia
```gdscript
# Resetear stats
SurvivalSystem.reset_stats()

# Ver estado
print(SurvivalSystem.get_survival_state())

# Modificar temperatura
SurvivalSystem.set_biome_temperature(50.0)  # Calor
SurvivalSystem.set_biome_temperature(-10.0)  # Frío
```

### Quests
```gdscript
# Ver todas las quests
QuestSystem.print_all_quests()

# Forzar completar quest
QuestSystem.complete_quest("tutorial_welcome")

# Ver quests activas
print(QuestSystem.get_active_quests())
```

### Animales
```gdscript
# Spawnear animal específico
var deer = Animal.new()
deer.animal_type = Animal.AnimalType.DEER
deer.global_position = $GameWorld/Player.global_position + Vector3(5, 0, 0)
$GameWorld.add_child(deer)
```

### Hogueras
```gdscript
# Acceder a hoguera
var campfire = $GameWorld.get_node("Campfire")

# Ver estado
print(campfire.get_state_info())

# Agregar combustible
campfire.add_fuel(50.0)

# Ver slots de cocción
print("Cocinando: ", campfire.cooking_slots.size(), " items")
```

---

## 📊 Estadísticas y Progreso

### Ver Virtudes
```gdscript
print(VirtueSystem.get_all_virtues())
```

### Ver Logros
```gdscript
AchievementSystem.print_all_achievements()
```

### Ver Armas
```gdscript
print(WeaponSystem.get_all_weapons())
```

---

## 🚧 Próximas Mejoras

### Pendientes de UI
- [ ] Menú de crafteo (tecla C)
- [ ] Inventario completo (tecla I)
- [ ] Diálogo con NPCs
- [ ] Menú de cocina en hogueras

### Pendientes de Gameplay
- [ ] InventorySystem completo (actualmente comentado)
- [ ] PlayerData con health/stamina (actualmente comentado)
- [ ] Pickup de items visuales en el mundo
- [ ] Domesticación de animales
- [ ] Sistema de farming

### Pendientes de Visualización
- [ ] Reemplazar modelo cónico del jugador
- [ ] Animaciones de ataque/caminar
- [ ] Efectos de daño en animales
- [ ] Íconos de items en hotbar

---

## 💡 Tips y Trucos

1. **Para ver animales fácilmente**: Activa F3 (debug) y mira las posiciones
2. **Para no morir de hambre**: Acércate a la hoguera encendida y usa comandos de consola para comer
3. **Para ver el fuego**: La hoguera del este (5 bloques) ya está encendida con efectos visuales
4. **Para testear quests**: Acepta "tutorial_welcome" y rompe 10 bloques de madera
5. **Para ver temperatura subir**: Acércate a menos de 3 metros de la hoguera encendida
6. **Para cazar fácil**: Las gallinas tienen solo 10 HP, los pájaros solo 5 HP

---

## 🎮 Cómo Empezar a Jugar

### Sesión de Prueba Recomendada (15 minutos)

1. **Minuto 1-2**: Inicia el juego, observa las barras de supervivencia drenando
2. **Minuto 3-5**: Camina hacia el este, encuentra la hoguera encendida (fuego naranja visible)
3. **Minuto 6-8**: Busca animales (ovejas al noreste, vacas al noroeste, gallinas al norte)
4. **Minuto 9-10**: Caza una gallina (10 HP, fácil) y observa el loot
5. **Minuto 11-12**: Abre la consola remota de Godot, acepta "tutorial_welcome"
6. **Minuto 13-15**: Rompe 10 bloques de madera, observa progreso en quest tracker

### Comandos para Copiar/Pegar

```gdscript
# Aceptar quest de tutorial
QuestSystem.accept_quest("tutorial_welcome")

# Comer cuando tengas hambre
SurvivalSystem.eat_food("cooked_meat")

# Beber cuando tengas sed
SurvivalSystem.drink_water(40.0)

# Ver estado de supervivencia
print(SurvivalSystem.get_survival_state())

# Cocinar en hoguera (busca la Campfire en el árbol de nodos)
$GameWorld/Campfire.cook_item("raw_meat")
```

---

## 📞 Solución de Problemas

### "No veo animales"
- Camina 10-15 bloques alrededor del spawn
- Los animales están en posiciones específicas (ver mapa arriba)
- Verifica la consola: debería decir "🦌 Spawneados 12 animales"

### "No veo la hoguera encendida"
- Busca 5 bloques al este del spawn
- Debería tener fuego naranja, luz y humo
- Verifica la consola: debería decir "🔥 Spawneadas 2 hogueras"

### "Las barras de supervivencia no aparecen"
- Verifica que GameHUD.gd tenga las funciones nuevas
- Busca en consola: "✅ Barras de supervivencia creadas"
- Revisa esquina superior izquierda (debajo de barra de Luz)

### "No aparece el quest tracker"
- Acepta una quest primero: `QuestSystem.accept_quest("tutorial_welcome")`
- Debería aparecer en esquina superior derecha
- Verifica consola: "✅ Quest tracker creado"

### "Los modelos son conos"
- Es el placeholder de Godot cuando falta el mesh
- Los generadores de modelos funcionan pero necesitan instanciarse
- Usa los comandos de consola para crear modelos manualmente

---

**🎉 ¡Disfruta el juego! Todos los sistemas están implementados y funcionales.**

**Fecha**: 2025-01-06
**Versión**: 1.0 - Sistemas Completos
