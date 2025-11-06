# 🎮 CÓMO USAR LAS NUEVAS MEJORAS - Guía Rápida

## 🚀 INICIO RÁPIDO

### 1. Abrir el Proyecto
```bash
cd /Users/carlosgarcia/Documents/Proyectos/C++/multininjaespacial
# Abrir Godot y cargar el proyecto
```

### 2. Verificar Autoloads
En Godot: **Proyecto → Configuración del Proyecto → Autoload**

Deberías ver:
- ✅ ToolSystem
- ✅ CraftingSystem
- ✅ AchievementSystem
- ✅ Otros sistemas existentes

### 3. Verificar Inputs
En Godot: **Proyecto → Configuración del Proyecto → Mapa de Entrada**

Nuevos inputs:
- ✅ `toggle_crafting` (C)
- ✅ `toggle_achievements` (L)
- ✅ `cycle_tool` (Q)
- ✅ `interact` (E)

---

## 🔨 USAR HERRAMIENTAS

### En el Código (PlayerInteraction.gd u otro)

```gdscript
# Al iniciar el juego, equipar la mano
func _ready():
	ToolSystem.equip_tool(ToolData.ToolType.HAND)

# Al romper un bloque
func _break_block(block_type: Enums.BlockType, hardness: float):
	# Calcular tiempo con herramienta
	var break_time = ToolSystem.calculate_break_time(block_type, hardness)

	# Iniciar temporizador de rotura
	await get_tree().create_timer(break_time).timeout

	# Romper bloque
	chunk_manager.remove_block(block_pos)

	# Usar herramienta (gasta durabilidad)
	ToolSystem.use_equipped_tool()

	# Partículas
	var particles = ParticleEffects.create_block_break_particles(
		block_type,
		global_position
	)
	get_tree().root.add_child(particles)

# Cambiar herramienta con Q
func _input(event):
	if event.is_action_pressed("cycle_tool"):
		# Lógica para cambiar entre herramientas del inventario
		pass
```

### Craftear Herramienta

```gdscript
# Craftear pico de madera
if CraftingSystem.craft("wooden_pickaxe"):
	print("✅ Pico crafteado!")
	# Se equipará automáticamente si no hay herramienta

# Verificar si se puede craftear
if CraftingSystem.can_craft("stone_pickaxe"):
	print("✅ Puedes craftear pico de piedra")
else:
	print("❌ Necesitas más recursos")
```

---

## 🛠️ USAR CRAFTEO

### Abrir UI de Crafteo (Desde Player o GameWorld)

```gdscript
# En GameWorld.gd o donde tengas la UI
var crafting_ui = preload("res://scripts/ui/CraftingUI.gd").new()
add_child(crafting_ui)

# La UI se abre automáticamente con tecla C
```

### Añadir Receta Personalizada

```gdscript
# En CraftingSystem.gd, función _initialize_recipes()
recipes["mi_receta"] = {
	"name": "Mi Item Especial",
	"output": {"item": "special_item", "quantity": 1},
	"inputs": {
		"wood": 5,
		"crystal": 2
	},
	"icon": "✨",
	"description": "Un item mágico especial",
	"category": "tools"
}
```

---

## 🐑 SPAWEAR ANIMALES

### En GameWorld.gd o Script de Spawn

```gdscript
func _spawn_animals():
	var animal_scene = preload("res://scenes/entities/Animal.tscn")

	# Spawear 3 ovejas
	for i in range(3):
		var sheep = animal_scene.instantiate()
		sheep.animal_type = Animal.AnimalType.SHEEP
		sheep.animal_name = "Oveja " + str(i + 1)
		sheep.global_position = Vector3(
			randf_range(-20, 20),
			15,
			randf_range(-20, 20)
		)
		add_child(sheep)

	# Spawear conejo
	var rabbit = animal_scene.instantiate()
	rabbit.animal_type = Animal.AnimalType.RABBIT
	rabbit.animal_name = "Conejo Rápido"
	rabbit.global_position = Vector3(10, 15, 10)
	add_child(rabbit)

	# Spawear vaca
	var cow = animal_scene.instantiate()
	cow.animal_type = Animal.AnimalType.COW
	cow.animal_name = "Vaca Manchada"
	cow.global_position = Vector3(-10, 15, -10)
	add_child(cow)

	print("🐾 Animales spawneados!")

# Llamar en _ready()
func _ready():
	await get_tree().create_timer(2.0).timeout # Esperar que cargue mundo
	_spawn_animals()
```

### Interactuar con Animal

```gdscript
# En PlayerInteraction.gd
func _on_interact_pressed():
	var raycast = $RayCast3D
	if raycast.is_colliding():
		var collider = raycast.get_collider()

		# Si es un animal
		if collider is Animal:
			collider.interact()
			# Efecto de corazones
			var hearts = ParticleEffects.create_heart_particles(
				collider.global_position + Vector3(0, 1, 0)
			)
			get_tree().root.add_child(hearts)
```

---

## 👨 MEJORAR NPCs CON MODELOS HUMANOIDES

### En NPC.gd

```gdscript
func _ready():
	# Eliminar modelo viejo si existe
	if has_node("OldModel"):
		$OldModel.queue_free()

	# Generar nuevo modelo humanoide
	var tipo = "villager" if npc_type == NPCType.ALDEANO else "sage"
	var model = HumanoidModelGenerator.generate_humanoid(tipo, true)
	add_child(model)

	print("👤 Modelo humanoide creado para", npc_name)
```

### Personalizar Colores

```gdscript
# Generar con colores específicos
var model = HumanoidModelGenerator.generate_humanoid("villager", false)
# false = no aleatorio, usa colores predefinidos

# Para colores aleatorios
var model = HumanoidModelGenerator.generate_humanoid("sage", true)
```

---

## 🎨 USAR MATERIALES MEJORADOS

### En Chunk.gd o donde generes meshes

```gdscript
func _generate_block_mesh(block_type: Enums.BlockType):
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(1, 1, 1)

	# Aplicar material mejorado
	var material = MaterialLibrary.get_material_for_block(block_type)
	box_mesh.material = material

	mesh_instance.mesh = box_mesh
	return mesh_instance
```

### Limpiar Cache (Si cambias materiales)

```gdscript
# Llamar cuando sea necesario
MaterialLibrary.clear_cache()
```

---

## ✨ USAR EFECTOS DE PARTÍCULAS

### Rotura de Bloque

```gdscript
func _on_block_broken(block_type: Enums.BlockType, position: Vector3):
	var particles = ParticleEffects.create_block_break_particles(
		block_type,
		position
	)
	get_tree().root.add_child(particles)
	# Se auto-destruirá cuando termine
```

### Colocación de Bloque

```gdscript
func _on_block_placed(block_type: Enums.BlockType, position: Vector3):
	var particles = ParticleEffects.create_block_place_particles(
		block_type,
		position
	)
	get_tree().root.add_child(particles)
```

### Ganancia de Luz

```gdscript
func _on_luz_gained():
	var particles = ParticleEffects.create_luz_gain_particles(
		player.global_position
	)
	get_tree().root.add_child(particles)
```

### Logro Desbloqueado

```gdscript
# El AchievementSystem ya lo hace automáticamente,
# pero puedes llamarlo manualmente:

func _on_achievement_unlocked(achievement_id: String, achievement_data: Dictionary):
	var particles = ParticleEffects.create_achievement_particles(
		player.global_position + Vector3(0, 2, 0)
	)
	get_tree().root.add_child(particles)
```

### Herramienta Rota

```gdscript
# En ToolSystem, cuando una herramienta se rompe:
func _on_tool_broken():
	var particles = ParticleEffects.create_tool_break_particles(
		player.global_position + Vector3(0, 1.5, 0)
	)
	get_tree().root.add_child(particles)
```

### Rastro de Movimiento (Sprint)

```gdscript
# En PlayerMovement.gd
var movement_trail: GPUParticles3D = null

func _process(delta):
	if is_sprinting:
		if movement_trail == null:
			movement_trail = ParticleEffects.create_movement_trail(
				global_position,
				Color(0.5, 0.7, 1.0) # Azul
			)
			add_child(movement_trail)
		movement_trail.global_position = global_position
	else:
		if movement_trail:
			movement_trail.queue_free()
			movement_trail = null
```

---

## 🌍 CONFIGURAR CICLO DÍA/NOCHE

### En GameWorld.gd

```gdscript
func _ready():
	# El DayNightCycle ya existe y funciona
	# Puedes personalizarlo:

	var day_night = $DayNightCycle # O como lo tengas

	# Cambiar duración
	day_night.day_duration_minutes = 15.0  # 15 minutos de día
	day_night.night_duration_minutes = 7.0 # 7 minutos de noche

	# Hora de inicio (0.3 = mañana)
	day_night.start_time = 0.3

	# Pausar/reanudar ciclo
	day_night.enable_cycle = true

	# Conectar señales
	day_night.day_started.connect(_on_day_started)
	day_night.night_started.connect(_on_night_started)

func _on_day_started():
	print("☀️ ¡Es de día!")
	# Hacer que animales se despierten, etc.

func _on_night_started():
	print("🌙 ¡Es de noche!")
	# Hacer que animales duerman, spawn de enemigos, etc.
```

---

## 🏆 SISTEMA DE LOGROS

### Incrementar Estadísticas Automáticamente

```gdscript
# El sistema ya trackea automáticamente muchas cosas,
# pero puedes añadir más:

# Cuando colocas bloque
AchievementSystem.increment_stat("blocks_placed", 1)

# Cuando rompes bloque
AchievementSystem.increment_stat("blocks_broken", 1)

# Cuando rompes madera específicamente
if block_type == Enums.BlockType.MADERA:
	AchievementSystem.increment_stat("wood_broken", 1)

# Cuando visitas un bioma
AchievementSystem.add_to_array_stat("biomes_visited", "forest")

# Cuando caminas
AchievementSystem.increment_stat("distance_walked", distance)

# Cuando saltas
AchievementSystem.increment_stat("jumps", 1)
```

### Verificar Logro

```gdscript
# Verificar si un logro está desbloqueado
if AchievementSystem.is_achievement_unlocked("first_block"):
	print("✅ Ya desbloqueaste el primer bloque")

# Obtener progreso de un logro
var progress = AchievementSystem.get_achievement_progress("master_builder")
print("Progreso Maestro Constructor: ", progress * 100, "%")
```

---

## 📋 CHECKLIST DE INTEGRACIÓN

### En GameWorld.gd
- [ ] Añadir DayNightCycle (si no existe)
- [ ] Spawear animales en `_ready()`
- [ ] Añadir CraftingUI como hijo
- [ ] Conectar señales de logros

### En Player.gd
- [ ] Equipar herramienta inicial (HAND)
- [ ] Manejar input de cambio de herramienta (Q)
- [ ] Manejar input de crafteo (C)
- [ ] Manejar input de logros (L)

### En PlayerInteraction.gd
- [ ] Usar ToolSystem para calcular tiempo de rotura
- [ ] Usar ToolSystem.use_equipped_tool() al romper
- [ ] Añadir partículas al romper/colocar bloques
- [ ] Manejar interacción con animales (E)

### En Chunk.gd
- [ ] Usar MaterialLibrary para materiales de bloques
- [ ] Aplicar texturas procedurales

### En NPC.gd
- [ ] Reemplazar modelo viejo con HumanoidModelGenerator
- [ ] Añadir animaciones (futuro)

---

## 🐛 TROUBLESHOOTING

### "ToolSystem not found"
**Solución**: Verificar que esté en autoloads del project.godot
```
ToolSystem="*res://scripts/systems/ToolSystem.gd"
```

### "CraftingSystem not found"
**Solución**: Verificar autoload
```
CraftingSystem="*res://scripts/systems/CraftingSystem.gd"
```

### "Texturas no se ven"
**Solución**: Verificar que MaterialLibrary esté importando correctamente
```gdscript
var material = MaterialLibrary.get_material_for_block(Enums.BlockType.CESPED)
```

### "Partículas no aparecen"
**Solución**: Verificar que estás añadiendo a la escena root
```gdscript
get_tree().root.add_child(particles)
# NO: add_child(particles)
```

### "Animales no se mueven"
**Solución**: Verificar que tengan CharacterBody3D y CollisionShape3D
```gdscript
# Animal.gd hereda de CharacterBody3D
extends CharacterBody3D
```

---

## ✅ PRUEBAS RÁPIDAS

### Probar Herramientas
1. Abrir juego
2. Craftear pico de madera (C)
3. Romper piedra - debería ser más rápido
4. Ver durabilidad disminuir

### Probar Animales
1. Spawear oveja en GameWorld
2. Acercarse - debería huir
3. Presionar E cerca - corazones y +3 Luz

### Probar Crafteo
1. Presionar C
2. Ver categorías (Bloques, Herramientas, Decoración)
3. Seleccionar receta
4. Ver requisitos en verde/rojo
5. Craftear si tienes recursos

### Probar Logros
1. Presionar L
2. Ver lista de logros
3. Colocar bloques
4. Ver progreso actualizado
5. Desbloquear logro - ver notificación

### Probar Día/Noche
1. Esperar 10 minutos (o cambiar duración)
2. Ver transición de colores del cielo
3. Ver sol moverse
4. Ver cambio de iluminación

---

## 🎉 ¡LISTO PARA JUGAR!

Ahora tu juego **Multi Ninja Espacial** tiene:
- ✅ Sistema de herramientas funcional
- ✅ Crafteo completo con UI
- ✅ Animales vivos con IA
- ✅ NPCs humanoides realistas
- ✅ Materiales y texturas mejoradas
- ✅ Efectos visuales espectaculares
- ✅ Ciclo día/noche atmosférico
- ✅ Sistema de logros completo

**¡Disfruta construyendo tu mundo! 🚀🎮✨**

---

**Creado con Claude Code**
Versión: MVP 2.0
