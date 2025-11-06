# 🪑 Sistema de Muebles y Decoración - Multi Ninja Espacial

## 📋 Índice

1. [Visión General](#visión-general)
2. [Características](#características)
3. [Arquitectura del Sistema](#arquitectura-del-sistema)
4. [Muebles Implementados](#muebles-implementados)
5. [Guía de Uso](#guía-de-uso)
6. [Integración](#integración)
7. [API de Desarrollo](#api-de-desarrollo)
8. [Ejemplos](#ejemplos)

---

## 🎯 Visión General

El Sistema de Muebles permite a los jugadores decorar sus construcciones con una variedad de artefactos funcionales y decorativos. Cada mueble tiene modelos 3D procedurales, interacciones únicas, y efectos visuales como iluminación.

### ✨ Características Principales

- **20 Muebles Esenciales** implementados en 8 categorías
- **Modelos 3D Procedurales** generados en runtime
- **Interacciones Variadas**: sentarse, dormir, almacenar, leer, encender/apagar
- **Iluminación Dinámica** con lámparas y antorchas
- **Sistema de Colocación** con preview y rotación
- **UI Moderna** con tabs por categoría
- **Efectos Visuales** y sonidos
- **Integración con Logros** y sistema de Luz Interior

---

## 🏗️ Arquitectura del Sistema

### Componentes Principales

```
📁 scripts/
├── 📁 items/
│   └── FurnitureData.gd           # Recurso con datos de muebles
├── 📁 systems/
│   ├── FurnitureSystem.gd         # Sistema global (Autoload)
│   └── FurniturePlacement.gd      # Sistema de colocación
├── 📁 entities/
│   └── FurnitureEntity.gd         # Instancia de mueble en el mundo
├── 📁 rendering/
│   └── FurnitureModelGenerator.gd # Generador de modelos 3D
└── 📁 ui/
    └── FurnitureUI.gd             # Interfaz de selección
```

### Flujo de Datos

```
Usuario → FurnitureUI → FurniturePlacement → FurnitureEntity
                              ↓
                        FurnitureSystem
                              ↓
                   FurnitureModelGenerator
```

---

## 🪑 Muebles Implementados

### 1. Muebles Básicos (5)

| Mueble | ID | Icono | Tamaño | Interacción |
|--------|-------|-------|--------|-------------|
| Cama Simple | `bed_simple` | 🛏️ | 2x1x1 | Dormir |
| Mesa de Madera | `table_wood` | 🪵 | 1x1x1 | Ninguna |
| Silla de Madera | `chair_wood` | 🪑 | 1x1x1 | Sentarse |
| Sofá | `sofa` | 🛋️ | 2x1x1 | Sentarse |
| Escritorio | `desk` | 🗄️ | 2x1x1 | Estación de trabajo |

### 2. Almacenamiento (3)

| Mueble | ID | Icono | Tamaño | Slots |
|--------|-------|-------|--------|-------|
| Cofre de Madera | `chest_wood` | 📦 | 1x1x1 | 20 |
| Estantería | `bookshelf` | 📚 | 1x2x1 | 0 |
| Armario | `wardrobe` | 🚪 | 1x2x1 | 30 |

### 3. Iluminación (3)

| Mueble | ID | Icono | Rango de Luz | Color |
|--------|-------|-------|--------------|-------|
| Lámpara de Pie | `lamp_floor` | 💡 | 8m | Amarillo |
| Lámpara de Mesa | `lamp_table` | 🕯️ | 5m | Amarillo |
| Antorcha de Pared | `torch_wall` | 🔥 | 6m | Naranja |

### 4. Decoración (4)

| Mueble | ID | Icono | Tamaño | Especial |
|--------|-------|-------|--------|----------|
| Planta en Maceta | `potted_plant` | 🪴 | 1x1x1 | Verde |
| Cuadro | `painting` | 🖼️ | 1x1x1 | Montado en pared |
| Alfombra | `rug` | 🧶 | 2x1x2 | En el suelo |
| Jarrón | `vase` | 🏺 | 1x1x1 | Decorativo |

### 5. Cocina (3)

| Mueble | ID | Icono | Tamaño | Función |
|--------|-------|-------|--------|---------|
| Estufa | `stove` | 🔥 | 1x1x1 | Cocinar |
| Refrigerador | `fridge` | 🧊 | 1x2x1 | Almacenar comida |
| Mesa de Cocina | `kitchen_table` | 🍽️ | 1x1x1 | Preparar |

### 6. Educación (2)

| Mueble | ID | Icono | Tamaño | Interacción |
|--------|-------|-------|--------|-------------|
| Biblioteca | `library` | 📖 | 3x3x1 | Leer |
| Atril | `lectern` | 📜 | 1x1x1 | Leer |

**Total: 20 muebles esenciales**

---

## 🎮 Guía de Uso

### Controles

| Tecla | Acción |
|-------|--------|
| **F** | Entrar/salir del modo colocación |
| **R** | Rotar mueble (en modo colocación) |
| **Click Izq** | Colocar mueble |
| **Click Der** | Remover mueble |
| **E** | Interactuar con mueble |

### Modo Colocación

1. Presiona **F** para entrar en modo colocación
2. Aparecerá un preview del mueble seleccionado
3. Mueve el mouse para posicionar
4. Presiona **R** para rotar
5. Preview verde = puede colocar, rojo = no puede
6. Click izquierdo para colocar
7. Presiona **F** nuevamente para salir

### Interacciones

#### 🛏️ Cama (Dormir)
- Presiona **E** al apuntar a la cama
- Avanza el tiempo hasta la mañana
- Restaura toda tu vida
- **+10 Luz Interior**

#### 🪑 Silla/Sofá (Sentarse)
- Presiona **E** para sentarte
- **+5 Luz Interior** (descanso)
- TODO: Animación de sentarse

#### 📦 Cofre (Almacenar)
- Presiona **E** para abrir
- Accede a 20/30 espacios de almacenamiento
- TODO: UI de inventario

#### 💡 Lámpara (Encender/Apagar)
- Presiona **E** para toggle
- Ilumina el área con OmniLight3D
- Ahorra energía apagando cuando no uses

#### 📚 Biblioteca/Atril (Leer)
- Presiona **E** para leer
- **+3 Luz Interior** (sabiduría)
- TODO: UI de lectura

#### 🗄️ Escritorio (Crafteo)
- Presiona **E** para usar
- Abre menú de crafteo
- Filtra recetas por estación de trabajo

---

## 🔧 Integración

### 1. Añadir Muebles al GameWorld

```gdscript
# En GameWorld.gd _ready()
extends Node3D

@onready var furniture_ui: FurnitureUI = $UI/FurnitureUI

func _ready():
    # La FurnitureUI ya está conectada con FurnitureSystem (autoload)
    pass

func _input(event):
    # Toggle UI de muebles con alguna tecla
    if event.is_action_pressed("toggle_furniture_ui"):
        furniture_ui.toggle()
```

### 2. Añadir FurnitureUI a la Escena

Opción A: **Programáticamente**
```gdscript
# En tu script del mundo
var furniture_ui = FurnitureUI.new()
add_child(furniture_ui)
```

Opción B: **En el Editor**
1. Crear nodo `Control` en la UI
2. Adjuntar script `FurnitureUI.gd`
3. La UI se genera automáticamente

### 3. Conectar con PlayerInteraction

Ya está integrado! El sistema se inicializa automáticamente en `PlayerInteraction._ready()`:

```gdscript
# PlayerInteraction.gd
func _ready():
    _setup_furniture_placement()
```

---

## 💻 API de Desarrollo

### FurnitureSystem (Autoload Global)

```gdscript
# Obtener un mueble
var furniture_data = FurnitureSystem.get_furniture("bed_simple")

# Obtener todos los muebles
var all_furniture = FurnitureSystem.get_all_furniture()

# Obtener IDs de todos los muebles
var ids = FurnitureSystem.get_all_furniture_ids()

# Verificar si un mueble existe
if FurnitureSystem.has_furniture("table_wood"):
    print("Mesa disponible")

# Registrar colocación
FurnitureSystem.place_furniture("sofa", Vector3i(10, 5, 10))

# Remover colocación
FurnitureSystem.remove_furniture(Vector3i(10, 5, 10))

# Obtener muebles colocados
var placed = FurnitureSystem.get_placed_furniture()
```

### FurnitureEntity

```gdscript
# Crear mueble
var furniture = FurnitureEntity.new()
var data = FurnitureSystem.get_furniture("lamp_floor")
furniture.initialize(data, false)  # false = no es preview
world.add_child(furniture)

# Colocar en posición
furniture.place(Vector3(10, 0, 10), Vector3i(10, 0, 10))

# Rotar mueble
furniture.rotate_furniture()  # Rota 90°
furniture.set_rotation_index(2)  # Rota a 180°

# Interactuar
furniture.interact(player)

# Obtener información
var info = furniture.get_info()
print(info)

# Remover
furniture.remove_furniture()
```

### FurniturePlacement

```gdscript
# Obtener desde PlayerInteraction
var placement = player_interaction.get_furniture_placement()

# Activar modo colocación
placement.toggle_placement_mode()

# Seleccionar mueble
placement.select_furniture("chair_wood")

# Obtener muebles colocados
var count = placement.get_furniture_count()
var by_category = placement.get_furniture_by_category(
    FurnitureData.FurnitureCategory.LIGHTING
)

# Limpiar todos (debug)
placement.clear_all_furniture()

# Guardar estado
var data = placement.save_furniture_data()
SaveSystem.save_furniture(data)

# Cargar estado
var loaded_data = SaveSystem.load_furniture()
placement.load_furniture_data(loaded_data)
```

### FurnitureModelGenerator

```gdscript
# Generar modelo 3D
var model = FurnitureModelGenerator.generate_furniture(furniture_data)
add_child(model)

# Generar mueble específico
var bed = FurnitureModelGenerator._generate_bed(furniture_data)
var lamp = FurnitureModelGenerator._generate_lamp_floor(furniture_data)
var chest = FurnitureModelGenerator._generate_chest(furniture_data)
```

---

## 📝 Ejemplos

### Ejemplo 1: Crear una Casa con Muebles

```gdscript
extends Node3D

func create_house():
    var placement = $Player/PlayerInteraction.get_furniture_placement()

    # Colocar cama
    placement.select_furniture("bed_simple")
    _place_at(placement, Vector3(5, 0, 5))

    # Colocar mesa y sillas
    placement.select_furniture("table_wood")
    _place_at(placement, Vector3(8, 0, 5))

    placement.select_furniture("chair_wood")
    _place_at(placement, Vector3(7, 0, 5))
    _place_at(placement, Vector3(9, 0, 5))

    # Colocar lámpara
    placement.select_furniture("lamp_floor")
    _place_at(placement, Vector3(5, 0, 8))

func _place_at(placement: FurniturePlacement, pos: Vector3):
    # Simular colocación
    var furniture_data = FurnitureSystem.get_furniture(placement.selected_furniture_id)
    var furniture = FurnitureEntity.new()
    furniture.initialize(furniture_data, false)
    furniture.place(pos, Vector3i(pos))
    get_parent().add_child(furniture)
```

### Ejemplo 2: Sistema de Logro "Decorador"

```gdscript
# Agregar a AchievementSystem
func _init_furniture_achievements():
    achievements["decorator"] = {
        "id": "decorator",
        "name": "Decorador",
        "description": "Coloca 50 muebles",
        "icon": "🎨",
        "stat": "furniture_placed",
        "target": 50,
        "reward_luz": 50
    }

# Se incrementa automáticamente en FurniturePlacement
# cuando se coloca un mueble:
# AchievementSystem.increment_stat("furniture_placed", 1)
```

### Ejemplo 3: Mueble Personalizado

```gdscript
# Crear nuevo mueble en FurnitureSystem._initialize_furniture()
furniture_library["tv"] = _create_tv()

func _create_tv() -> FurnitureData:
    var data = FurnitureData.new()
    data.furniture_id = "tv"
    data.furniture_name = "Televisor"
    data.description = "Entretenimiento moderno"
    data.icon = "📺"
    data.category = FurnitureData.FurnitureCategory.ENTERTAINMENT
    data.size = Vector3i(2, 1, 1)
    data.interaction_type = FurnitureData.InteractionType.TURN_ON_OFF
    data.interaction_text = "Ver TV"
    data.primary_color = Color.BLACK
    data.secondary_color = Color.DARK_GRAY
    data.craft_requirements = {
        "metal": 10,
        "cristal": 5,
        "plastico": 8
    }
    return data

# Luego crear el generador en FurnitureModelGenerator
static func _generate_tv(furniture_data: FurnitureData) -> Node3D:
    var root = Node3D.new()

    # Pantalla
    var screen = MeshInstance3D.new()
    screen.mesh = BoxMesh.new()
    screen.mesh.size = Vector3(1.8, 1.0, 0.1)
    var screen_mat = StandardMaterial3D.new()
    screen_mat.albedo_color = Color.BLACK
    screen_mat.emission_enabled = true
    screen_mat.emission = Color(0.2, 0.5, 1.0)  # Azul brillante
    screen_mat.emission_energy = 0.5
    screen.material_override = screen_mat
    screen.position = Vector3(0, 0.5, 0)
    root.add_child(screen)

    # Base
    var base = MeshInstance3D.new()
    base.mesh = CylinderMesh.new()
    base.mesh.top_radius = 0.3
    base.mesh.bottom_radius = 0.4
    base.mesh.height = 0.2
    var base_mat = _create_wood_material()
    base.material_override = base_mat
    base.position = Vector3(0, 0.1, 0)
    root.add_child(base)

    return root
```

---

## 🎨 Personalización

### Cambiar Colores de Muebles

```gdscript
# En tiempo de ejecución
var furniture = $FurnitureEntity
furniture.update_colors(Color.RED, Color.DARK_RED)
```

### Añadir Efectos Especiales

```gdscript
# En FurnitureEntity.interact()
func _handle_custom_interaction():
    # Crear partículas
    ParticleEffects.create_sparkle_effect(global_position)

    # Buff temporal
    if VirtueSystem:
        VirtueSystem.add_luz(15, "Interacción especial")

    # Sonido único
    AudioManager.play_sound("special_furniture")
```

---

## 📊 Estadísticas

### Código Implementado

- **FurnitureData.gd**: 83 líneas
- **FurnitureSystem.gd**: ~350 líneas (archivo anterior)
- **FurnitureEntity.gd**: 285 líneas
- **FurniturePlacement.gd**: 440 líneas
- **FurnitureModelGenerator.gd**: ~800 líneas (20 modelos)
- **FurnitureUI.gd**: 490 líneas
- **PlayerInteraction.gd**: +80 líneas (integración)

**Total: ~2,528 líneas de código**

### Muebles

- **20 muebles esenciales** implementados
- **8 categorías** diferentes
- **150+ ideas** en brainstorming (LLUVIA_IDEAS_ARTEFACTOS.md)

### Interacciones

- 6 tipos de interacción diferentes
- Iluminación dinámica en 3 muebles
- Almacenamiento en 2 muebles
- Efectos visuales y sonoros

---

## 🚀 Próximos Pasos

### Corto Plazo
- [ ] Implementar UI de almacenamiento (cofres, armarios)
- [ ] Añadir animación de sentarse
- [ ] Implementar verificación de recursos en crafteo
- [ ] Añadir sonidos únicos por mueble

### Mediano Plazo
- [ ] Expandir a 50+ muebles (desde brainstorming)
- [ ] Implementar muebles mágicos con efectos especiales
- [ ] Sistema de mejora de muebles (tiers)
- [ ] Muebles craftables con recetas

### Largo Plazo
- [ ] Muebles con animaciones (puertas que se abren, cajones)
- [ ] Sistema de electricidad (conectar lámparas)
- [ ] Muebles multiplayer (varios jugadores pueden usar)
- [ ] Marketplace de muebles personalizados

---

## 🐛 Troubleshooting

### El preview no aparece
- Verifica que FurnitureSystem esté registrado como autoload
- Asegúrate de que la cámara esté correctamente configurada
- Revisa que `toggle_furniture_mode` esté mapeado en project.godot

### Los muebles no tienen colisión
- Verifica que `is_solid` esté en `true` en FurnitureData
- Asegúrate de que no sea un preview (`is_preview = false`)
- Revisa que StaticBody3D se esté creando correctamente

### La luz del mueble no funciona
- Verifica `emits_light = true` en FurnitureData
- Asegúrate de que `light_range` y `light_energy` tengan valores > 0
- Revisa que OmniLight3D se esté añadiendo al modelo

### No puedo interactuar con muebles
- Verifica que `interaction_type` no sea `NONE`
- Asegúrate de que el Area3D del mueble esté en la capa correcta
- Revisa que la tecla **E** esté mapeada como `interact`

---

## 📚 Referencias

### Archivos Relacionados
- `LLUVIA_IDEAS_ARTEFACTOS.md` - Brainstorming de 150+ muebles
- `NUEVAS_MEJORAS_GRAFICAS.md` - Mejoras visuales generales
- `COMO_USAR_MEJORAS.md` - Guía de integración de sistemas

### Sistemas Integrados
- **VirtueSystem** - Luz Interior y progresión
- **AchievementSystem** - Logros de decoración
- **CraftingSystem** - Crafteo de muebles
- **PlayerData** - Inventario y recursos
- **SaveSystem** - Guardado de estado

---

## 🙏 Créditos

Sistema de Muebles diseñado e implementado para **Multi Ninja Espacial**.

Desarrollado con ❤️ usando **Godot 4.2+** y **GDScript**.

**Fecha de implementación**: Noviembre 2025

---

## 📜 Licencia

Este sistema es parte del proyecto Multi Ninja Espacial.

---

**¡Que la Luz Interior brille en tus construcciones! ✨🪑**
