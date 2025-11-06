# 🎮 Sistemas de Supervivencia y Misiones

## 📜 Quest System (Sistema de Misiones)

### Características Principales

- **Tipos de Misiones**:
  - `MAIN` - Misiones principales de la historia
  - `SIDE` - Misiones secundarias opcionales
  - `DAILY` - Misiones diarias que se resetean
  - `TUTORIAL` - Misiones de introducción
  - `REPEATABLE` - Misiones que se pueden repetir

- **Tipos de Objetivos**:
  - `COLLECT` - Recolectar items (ej: 50 madera)
  - `KILL` - Cazar/matar enemigos (ej: 5 ovejas)
  - `CRAFT` - Craftear items (ej: 1 pico de hierro)
  - `BUILD` - Construir estructuras (ej: 10 muebles)
  - `TALK` - Hablar con NPCs
  - `EXPLORE` - Explorar ubicaciones
  - `SURVIVE` - Sobrevivir X tiempo
  - `DELIVER` - Entregar items a NPC

### Misiones Implementadas

#### Tutorial
1. **Bienvenido al Mundo** - Aprende controles básicos
   - Moverse con WASD
   - Recolectar 5 madera
   - Craftear pico de madera
   - Recompensa: 50 EXP, 10 monedas, 3 antorchas

2. **Sobrevive la Primera Noche** - Construye refugio
   - Construir refugio básico
   - Crear hoguera
   - Conseguir 3 comidas
   - Recompensa: 100 EXP, 25 monedas, cama + 5 antorchas

#### Misiones Principales
3. **El Gran Explorador** - Explora biomas
   - Bosque, Desierto, Montañas
   - Recompensa: 250 EXP, mapa + brújula

4. **El Cazador** - Domina la caza
   - Cazar 5 ovejas, 3 vacas
   - Craftear arco
   - Recompensa: 300 EXP, 50 flechas + 10 carnes cocidas

#### Misiones Secundarias
5. **Recolector Experto** - Recolecta recursos
   - 50 madera, 30 piedra, 10 hierro
   - Recompensa: 150 EXP, 75 monedas

6. **Chef en Formación** - Aprende a cocinar
   - 5 carnes cocidas, 3 panes, 2 guisos
   - Recompensa: 200 EXP, horno

7. **Constructor Maestro** - Construye base
   - 20 paredes, 10 muebles, 5 luces
   - Recompensa: 350 EXP, 2 cofres

#### Misiones Diarias
8. **Recolección Diaria** - Recursos diarios
   - 20 madera, 15 piedra
   - Recompensa: 50 EXP, 25 monedas

9. **Cacería Diaria** - Caza animales
   - 10 animales cualquiera
   - Recompensa: 75 EXP, 5 carnes cocidas

### Uso del Sistema

```gdscript
# Aceptar quest
QuestSystem.accept_quest("tutorial_welcome")

# Notificar progreso
QuestSystem.notify_item_collected("wood", 5)
QuestSystem.notify_enemy_killed("sheep")
QuestSystem.notify_item_crafted("wooden_pickaxe", 1)
QuestSystem.notify_built("campfire")
QuestSystem.notify_area_explored("forest")

# Completar quest
QuestSystem.complete_quest("tutorial_welcome")

# Trackear quest en HUD
QuestSystem.track_quest("main_01_explorer")
```

---

## 🌡️ Survival System (Sistema de Supervivencia)

### Stats de Supervivencia

#### Hambre (Hunger)
- **Máximo**: 100.0
- **Drain rate**: 1.0 puntos/segundo (1.5x al correr)
- **Efectos**:
  - < 20: Regeneración de stamina reducida (50%)
  - = 0: Daño 5 HP cada 2 segundos

#### Sed (Thirst)
- **Máximo**: 100.0
- **Drain rate**: 1.5 puntos/segundo (más rápido con calor)
- **Efectos**:
  - < 20: Velocidad reducida (80%)
  - = 0: Daño 5 HP cada 2 segundos

#### Temperatura Corporal
- **Normal**: 37°C
- **Rangos**:
  - `< 0°C` - Freezing: Daño 10 HP/2s
  - `0-10°C` - Cold: Daño 3 HP/2s, velocidad -10%
  - `15-30°C` - Comfortable: Sin efectos
  - `40-50°C` - Hot: Daño 3 HP/2s, sed drena +50%
  - `> 50°C` - Burning: Daño 10 HP/2s

### Alimentos (25+ items)

#### Carnes
- `raw_meat` → +10 hambre
- `cooked_meat` → +30 hambre, +5 HP
- `steak` → +40 hambre, +10 HP
- `raw_chicken` → +8 hambre
- `cooked_chicken` → +25 hambre, +5 HP
- `raw_fish` → +8 hambre
- `cooked_fish` → +25 hambre, +5 HP

#### Vegetales
- `apple` → +15 hambre, +5 sed
- `bread` → +20 hambre
- `carrot` → +12 hambre
- `potato` → +10 hambre
- `baked_potato` → +22 hambre

#### Comidas Elaboradas
- `stew` → +45 hambre, +15 HP, +10 sed
- `soup` → +35 hambre, +20 sed
- `pie` → +40 hambre, +10 HP

#### Snacks
- `berries` → +8 hambre, +3 sed
- `mushroom` → +5 hambre (puede ser venenoso)

### Bebidas

- `water_bottle` → +30 sed
- `dirty_water` → +20 sed (puede enfermar)
- `clean_water` → +40 sed
- `milk` → +25 sed, +10 hambre
- `juice` → +35 sed, +5 hambre
- `tea` → +30 sed, +5 HP
- `coffee` → +25 sed (buff de velocidad futuro)

### Uso del Sistema

```gdscript
# Comer/beber
SurvivalSystem.eat_food("cooked_meat")
SurvivalSystem.drink_item("water_bottle")
SurvivalSystem.drink_water(30.0)

# Control de temperatura
SurvivalSystem.set_biome_temperature(20.0)
SurvivalSystem.set_near_heat_source(true)
SurvivalSystem.set_in_shelter(true)

# Estado
var state = SurvivalSystem.get_survival_state()
print(state.hunger_percentage)  # 0-100%
print(state.is_starving)        # bool
print(state.temperature)        # float
```

### Señales

```gdscript
SurvivalSystem.hunger_changed.connect(func(value, max_value):
    update_hunger_bar(value, max_value)
)

SurvivalSystem.temperature_changed.connect(func(temp):
    update_temp_indicator(temp)
)

SurvivalSystem.player_starving.connect(func(is_starving):
    show_warning("¡Hambre crítica!")
)
```

---

## 🔥 Campfire (Hoguera/Fogata)

### Características

#### Sistema de Fuego
- **Combustible máximo**: 300 segundos (5 minutos)
- **Consumo**: 1 punto/segundo
- **Área de calor**: 3 metros de radio
- **Efectos visuales**:
  - Partículas de fuego (50 partículas)
  - Luz dinámica con flicker
  - Partículas de humo
  - Luz naranja/amarilla

#### Sistema de Cocina
- **Slots simultáneos**: 4
- **Recetas disponibles**: 8+
  - `raw_meat` → `cooked_meat` (10s)
  - `raw_chicken` → `cooked_chicken` (8s)
  - `raw_fish` → `cooked_fish` (6s)
  - `potato` → `baked_potato` (5s)
  - `corn` → `roasted_corn` (5s)
  - `dirty_water` → `clean_water` (15s)

### Uso

```gdscript
# Crear hoguera
var campfire = Campfire.new()
add_child(campfire)

# Encender
campfire.light_fire(100.0)  # 100 puntos de combustible

# Agregar combustible
campfire.add_fuel(50.0)

# Cocinar
campfire.cook_item("raw_meat")

# Señales
campfire.fire_started.connect(func():
    print("Fuego encendido")
)

campfire.item_cooked.connect(func(item_id):
    print("Cocción completa: ", item_id)
)
```

---

## 🦌 Sistema de Caza

### Animales y Loot

#### Oveja (Sheep)
- **Health**: 30 HP
- **Loot**:
  - `raw_meat` (1-2, 100%)
  - `wool` (2-4, 100%)

#### Vaca (Cow)
- **Health**: 50 HP
- **Loot**:
  - `raw_meat` (2-4, 100%)
  - `leather` (1-3, 100%)

#### Gallina (Chicken)
- **Health**: 10 HP
- **Loot**:
  - `raw_chicken` (1, 100%)
  - `feather` (1-3, 80%)
  - `egg` (0-1, 30%)

#### Conejo (Rabbit)
- **Health**: 15 HP
- **Loot**:
  - `raw_meat` (1, 100%)
  - `rabbit_hide` (1, 70%)

#### Venado (Deer)
- **Health**: 60 HP
- **Loot**:
  - `raw_meat` (3-5, 100%)
  - `leather` (2-4, 100%)
  - `antler` (1-2, 50%)

#### Pájaro (Bird)
- **Health**: 5 HP
- **Loot**:
  - `feather` (2-4, 100%)

### Mecánicas de Caza

```gdscript
# Causar daño
animal.take_damage(10.0, player)

# El animal huye al recibir daño
# Los drops se generan automáticamente al morir

# Señales
animal.animal_damaged.connect(func(damage):
    show_damage_number(damage)
)

animal.animal_killed.connect(func(type, position):
    QuestSystem.notify_enemy_killed(type)
    spawn_blood_particles(position)
)
```

---

## 🔄 Integración entre Sistemas

### Flujo de Juego Típico

1. **Inicio del Juego**
   - Quest "Bienvenido al Mundo" se activa automáticamente
   - SurvivalSystem comienza a drenar hambre/sed

2. **Tutorial**
   - Jugador recolecta madera → QuestSystem.notify_item_collected()
   - Craftea pico → QuestSystem.notify_item_crafted()
   - Completa quest → Recibe recompensas

3. **Supervivencia**
   - Hambre baja → Necesita cazar animales
   - Caza oveja → Animal.die() → Dropea raw_meat
   - raw_meat → Inventario → QuestSystem.notify_item_collected()

4. **Cocina**
   - Construye hoguera → QuestSystem.notify_built("campfire")
   - Cocina carne → Campfire.cook_item("raw_meat")
   - Come carne cocida → SurvivalSystem.eat_food("cooked_meat")

5. **Temperatura**
   - Noche/frío → Temperatura baja
   - Cerca de hoguera → Campfire heat_area detecta player
   - SurvivalSystem.set_near_heat_source(true) → Temperatura sube

### Conexiones entre Sistemas

```
QuestSystem ←→ Animal (notify_enemy_killed)
QuestSystem ←→ Campfire (notify_built, notify_item_crafted)
QuestSystem ←→ InventorySystem (notify_item_collected)

SurvivalSystem ←→ Campfire (set_near_heat_source)
SurvivalSystem ←→ Animal (eat_food with meat drops)
SurvivalSystem ←→ PlayerData (take_damage, heal)

Animal ←→ InventorySystem (loot drops)
Animal ←→ CombatSystem (take_damage)

Campfire ←→ InventorySystem (cooked items)
```

---

## 📊 Estadísticas de Implementación

- **Total de archivos**: 4 nuevos
- **Líneas de código**: ~1,500
- **Quests**: 10+ implementadas
- **Alimentos/Bebidas**: 25+
- **Recetas de cocina**: 8+
- **Tipos de animales**: 6
- **Items de loot**: 15+
- **Señales/eventos**: 20+

---

## 🚀 Próximos Pasos Sugeridos

### Corto Plazo
- [ ] UI para Quest Tracker en HUD
- [ ] Barras de hambre/sed/temperatura en HUD
- [ ] Menú de cocina en Campfire
- [ ] Indicadores visuales de daño en animales
- [ ] Sistema de items físicos en el mundo (drops)

### Mediano Plazo
- [ ] Sistema de buffs/debuffs temporales
- [ ] Enfermedades (por comida podrida, agua sucia)
- [ ] Sistema de clima (lluvia, nieve, calor extremo)
- [ ] Domesticación de animales
- [ ] Más recetas de cocina avanzadas

### Largo Plazo
- [ ] Sistema de farming/agricultura
- [ ] NPCs que dan quests
- [ ] Quest branching (decisiones)
- [ ] Sistema de reputación
- [ ] Eventos dinámicos del mundo

---

## 🐛 Debugging

### Comandos Útiles

```gdscript
# Debug Quest System
print(QuestSystem.get_debug_info())

# Debug Survival System
print(SurvivalSystem.get_survival_state())

# Reset Survival Stats
SurvivalSystem.reset_stats()

# Test Quest
QuestSystem.accept_quest("tutorial_welcome")
QuestSystem.notify_item_collected("wood", 5)

# Test Animal
animal.take_damage(100.0)  # Matar instantáneamente
```

### Logs Importantes

El sistema genera logs claros:
```
🐑 Animal spawneado: Sheep (SHEEP)
🩸 Sheep recibió 10.0 de daño (20.0/30.0 HP)
💀 Sheep ha muerto
  🎁 Drop: 2 x raw_meat
  🎁 Drop: 3 x wool
📜 Quest aceptada: Bienvenido al Mundo
📊 Bienvenido al Mundo: 5/5 Recolecta 5 madera
✅ Quest completada: Bienvenido al Mundo
🔥 Fuego encendido
🍳 Cocinando: raw_meat → cooked_meat
✅ Cocción completada: cooked_meat
🍖 Comido: cooked_meat (+30 hambre)
```

---

**Documentación generada**: $(date +"%Y-%m-%d")
**Versión**: 1.0
**Sistemas**: QuestSystem, SurvivalSystem, Campfire, Animal (caza)
