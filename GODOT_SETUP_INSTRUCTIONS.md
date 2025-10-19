# 🎮 Instrucciones de Setup en Godot

## ✅ Archivos Ya Creados

- ✅ `project.godot` - Configuración del proyecto (autoloads + input map incluidos)
- ✅ Todas las carpetas necesarias (`scenes/`, `assets/`, etc.)
- ✅ Todos los scripts `.gd` (21 archivos)
- ✅ Toda la documentación

## 📝 Pasos a Seguir en Godot Editor

### 1. Abrir el Proyecto

1. **Abrir Godot 4.2+**
2. Click en **"Import"**
3. Navegar a esta carpeta: `/Users/carlosgarcia/Desktop/Proyectos/C++/multininjaespacial`
4. Seleccionar el archivo `project.godot`
5. Click en **"Import & Edit"**

**El proyecto se abrirá con:**
- ✅ Autoloads ya configurados
- ✅ Input Map ya configurado
- ✅ Configuración de display/rendering lista

### 2. Crear las Escenas (7 escenas .tscn)

Ahora solo necesitas crear las escenas siguiendo `SCENE_ASSEMBLY_GUIDE.md`.

Te las resumo aquí:

---

## 🎬 ESCENA 1: Main.tscn

**Ubicación**: `scenes/main/Main.tscn`

1. Click derecho en FileSystem → New Scene
2. Seleccionar **Node** como raíz
3. Renombrar a "Main"
4. En el Inspector → Script → Cargar `res://scripts/main/Main.gd`
5. **Ctrl+S** → Guardar como `res://scenes/main/Main.tscn`

**✅ Listo!** Esta escena es muy simple.

---

## 🎬 ESCENA 2: Player.tscn

**Ubicación**: `scenes/player/Player.tscn`

### Jerarquía:
```
Player (CharacterBody3D)
├── CollisionShape3D (CapsuleShape3D)
├── CameraController (Node3D)
│   └── Camera3D
├── PlayerMovement (Node)
└── PlayerInteraction (Node)
```

### Pasos:

1. **New Scene → CharacterBody3D** → Renombrar a "Player"
2. **Asignar script**: `res://scripts/player/Player.gd`

3. **Añadir CollisionShape3D**:
   - Click en Player → Botón "+" → CollisionShape3D
   - En Inspector → Shape → New CapsuleShape3D
   - Height: 1.8, Radius: 0.3

4. **Añadir CameraController**:
   - Click en Player → Botón "+" → Node3D
   - Renombrar a "CameraController"
   - Asignar script: `res://scripts/player/CameraController.gd`
   - Position: (0, 1.6, 0)
   - Click en CameraController → Botón "+" → Camera3D
   - En Camera3D → Inspector → marcar **"Current"** ✅

5. **Añadir PlayerMovement**:
   - Click en Player → Botón "+" → Node
   - Renombrar a "PlayerMovement"
   - Asignar script: `res://scripts/player/PlayerMovement.gd`

6. **Añadir PlayerInteraction**:
   - Click en Player → Botón "+" → Node
   - Renombrar a "PlayerInteraction"
   - Asignar script: `res://scripts/player/PlayerInteraction.gd`

7. **Ctrl+S** → Guardar como `res://scenes/player/Player.tscn`

---

## 🎬 ESCENA 3: Chunk.tscn

**Ubicación**: `scenes/world/Chunk.tscn`

1. New Scene → **Node3D** → Renombrar a "Chunk"
2. Asignar script: `res://scripts/world/Chunk.gd`
3. **Ctrl+S** → Guardar como `res://scenes/world/Chunk.tscn`

**✅ Listo!** El mesh y colisión se generan dinámicamente en el script.

---

## 🎬 ESCENA 4: GameWorld.tscn

**Ubicación**: `scenes/game/GameWorld.tscn`

### Jerarquía:
```
GameWorld (Node3D)
├── WorldEnvironment
├── DirectionalLight3D
├── ChunkManager (Node3D)
├── TerrainGenerator (Node)
└── Player (instancia de Player.tscn)
```

### Pasos:

1. **New Scene → Node3D** → Renombrar a "GameWorld"
2. **Asignar script**: `res://scripts/game/GameWorld.gd`

3. **Añadir WorldEnvironment**:
   - Click en GameWorld → Botón "+" → WorldEnvironment
   - En Inspector → Environment → **New Environment**

4. **Añadir DirectionalLight3D**:
   - Click en GameWorld → Botón "+" → DirectionalLight3D
   - Position: (0, 10, 0)
   - Rotation: (-45, 45, 0)
   - Inspector → Shadow → **Enabled** ✅

5. **Añadir ChunkManager**:
   - Click en GameWorld → Botón "+" → Node3D
   - Renombrar a "ChunkManager"
   - Asignar script: `res://scripts/world/ChunkManager.gd`

6. **Añadir TerrainGenerator**:
   - Click en GameWorld → Botón "+" → Node
   - Renombrar a "TerrainGenerator"
   - Asignar script: `res://scripts/world/TerrainGenerator.gd`

7. **Instanciar Player**:
   - Click en GameWorld → Botón de cadena (Instance Child Scene)
   - Seleccionar `res://scenes/player/Player.tscn`

8. **Ctrl+S** → Guardar como `res://scenes/game/GameWorld.tscn`

---

## 🎬 ESCENA 5: MainMenu.tscn

**Ubicación**: `scenes/menus/MainMenu.tscn`

### Jerarquía:
```
MainMenu (Control)
└── VBoxContainer
    ├── TitleLabel (Label)
    ├── NewGameButton (Button)
    ├── ContinueButton (Button)
    ├── OptionsButton (Button)
    └── QuitButton (Button)
```

### Pasos:

1. **New Scene → Control** → Renombrar a "MainMenu"
2. **Asignar script**: `res://scripts/ui/MainMenu.gd`
3. En Inspector → Layout → **Center** (para centrar en pantalla)

4. **Añadir VBoxContainer**:
   - Click en MainMenu → Botón "+" → VBoxContainer
   - Inspector → Theme Overrides → Constants → Separation: 20

5. **Añadir TitleLabel**:
   - Click en VBoxContainer → Botón "+" → Label
   - Renombrar a "TitleLabel"
   - Inspector → Text: "Multi Ninja Espacial"
   - Theme Overrides → Font Sizes → Font Size: 48
   - Horizontal Alignment: Center

6. **Añadir 4 botones**:

   **NewGameButton**:
   - VBoxContainer → Botón "+" → Button
   - Renombrar a "NewGameButton"
   - Text: "Nueva Partida"
   - Custom Minimum Size: (200, 50)

   **ContinueButton**:
   - Text: "Continuar"
   - Custom Minimum Size: (200, 50)

   **OptionsButton**:
   - Text: "Opciones"
   - Custom Minimum Size: (200, 50)

   **QuitButton**:
   - Text: "Salir"
   - Custom Minimum Size: (200, 50)

7. **Ctrl+S** → Guardar como `res://scenes/menus/MainMenu.tscn`

---

## 🎬 ESCENA 6: GameHUD.tscn

**Ubicación**: `scenes/ui/GameHUD.tscn`

Esta escena es la más compleja. Aquí una versión simplificada:

### Estructura Mínima:
```
GameHUD (Control)
├── Crosshair (Panel) - centrado
├── TopLeft (MarginContainer)
│   └── VBoxContainer
│       └── LuzBar (ProgressBar)
│           └── LuzLabel (Label)
├── TopCenter (MarginContainer)
│   └── BlockInfoLabel (Label)
├── TopRight (MarginContainer)
│   └── DebugPanel (VBoxContainer)
├── Center (CenterContainer)
│   └── BreakProgress (ProgressBar)
└── Bottom (MarginContainer)
    └── Hotbar (HBoxContainer)
```

### Pasos Simplificados:

1. **New Scene → Control** → Renombrar a "GameHUD"
2. **Asignar script**: `res://scripts/ui/GameHUD.gd`
3. Layout → **Full Rect**

4. **Crosshair** (Panel centrado):
   - Añadir Panel
   - Renombrar a "Crosshair"
   - Layout: Center
   - Custom Minimum Size: (20, 20)

5. **TopLeft** (para Luz):
   - Añadir MarginContainer → Renombrar "TopLeft"
   - Layout: Top Left
   - Margins: Left=20, Top=20
   - Añadir VBoxContainer hijo
   - Añadir ProgressBar hijo del VBox → Renombrar "LuzBar"
   - Custom Minimum Size: (200, 30)
   - Max Value: 1000
   - Añadir Label hijo del LuzBar → Renombrar "LuzLabel"
   - Text: "✨ Luz: 0 / 1000"

6. **TopCenter**:
   - MarginContainer → Renombrar "TopCenter"
   - Layout: Top Center
   - Añadir Label hijo → Renombrar "BlockInfoLabel"
   - Visible: false

7. **TopRight** (Debug):
   - MarginContainer → Renombrar "TopRight"
   - Layout: Top Right
   - Margins: Right=-20, Top=20
   - Añadir VBoxContainer hijo → Renombrar "DebugPanel"
   - Visible: false

8. **Center** (Break Progress):
   - CenterContainer → Renombrar "Center"
   - Layout: Center
   - Añadir ProgressBar hijo → Renombrar "BreakProgress"
   - Custom Minimum Size: (200, 20)
   - Visible: false

9. **Bottom** (Hotbar):
   - MarginContainer → Renombrar "Bottom"
   - Layout: Bottom Center
   - Margin Bottom: -20
   - Añadir HBoxContainer hijo → Renombrar "Hotbar"
   - Separation: 5

10. **Ctrl+S** → Guardar como `res://scenes/ui/GameHUD.tscn`

---

## 🎬 ESCENA 7: PauseMenu.tscn

**Ubicación**: `scenes/ui/PauseMenu.tscn`

### Jerarquía:
```
PauseMenu (Control)
└── Panel
    └── VBoxContainer
        ├── TitleLabel (Label)
        ├── ResumeButton (Button)
        ├── SaveButton (Button)
        ├── OptionsButton (Button)
        └── MainMenuButton (Button)
```

### Pasos:

1. **New Scene → Control** → Renombrar a "PauseMenu"
2. **Asignar script**: `res://scripts/ui/PauseMenu.gd`
3. Layout → **Full Rect**

4. **Añadir Panel**:
   - Control → Botón "+" → Panel
   - Layout: Center
   - Custom Minimum Size: (400, 500)

5. **Añadir VBoxContainer al Panel**:
   - Panel → VBoxContainer
   - Margins: 20 (todos los lados)
   - Separation: 20

6. **Añadir TitleLabel**:
   - VBoxContainer → Label
   - Renombrar "TitleLabel"
   - Text: "PAUSA"
   - Font Size: 32
   - Horizontal Alignment: Center

7. **Añadir 4 botones** (igual que MainMenu):
   - ResumeButton: "Reanudar"
   - SaveButton: "Guardar"
   - OptionsButton: "Opciones"
   - MainMenuButton: "Menú Principal"

8. **Ctrl+S** → Guardar como `res://scenes/ui/PauseMenu.tscn`

---

## 🎮 INTEGRAR HUD Y PAUSEMENU EN GAMEWORLD

1. **Abrir GameWorld.tscn**
2. **Añadir CanvasLayer**:
   - GameWorld → Botón "+" → CanvasLayer
3. **Instanciar GameHUD**:
   - CanvasLayer → Botón de cadena → `res://scenes/ui/GameHUD.tscn`
4. **Instanciar PauseMenu**:
   - CanvasLayer → Botón de cadena → `res://scenes/ui/PauseMenu.tscn`
5. **Ctrl+S** para guardar

---

## ✅ VERIFICACIÓN FINAL

### Checklist de Escenas:
- [ ] `scenes/main/Main.tscn`
- [ ] `scenes/player/Player.tscn`
- [ ] `scenes/world/Chunk.tscn`
- [ ] `scenes/game/GameWorld.tscn`
- [ ] `scenes/menus/MainMenu.tscn`
- [ ] `scenes/ui/GameHUD.tscn`
- [ ] `scenes/ui/PauseMenu.tscn`

### Verificar en Project Settings:
- [ ] Application → Run → Main Scene apunta a `res://scenes/main/Main.tscn`
- [ ] Autoload → 5 autoloads configurados ✅ (ya configurado en project.godot)
- [ ] Input Map → Todas las acciones configuradas ✅ (ya configurado en project.godot)

---

## 🚀 PRIMER TEST

1. **Presiona F5** (o click en Play)
2. Deberías ver el MainMenu
3. Click en "Nueva Partida"
4. Esperar ~5 segundos mientras se genera el mundo
5. Deberías aparecer en un terreno generado proceduralmente
6. Probar:
   - WASD para mover
   - Mouse para mirar
   - Space para saltar
   - Click izquierdo para colocar bloques
   - Click derecho (mantener) para romper bloques
   - ESC para pausar

---

## ⚠️ SI HAY ERRORES

### Error: "Invalid get index 'has_method'"
- **Solución**: Verificar que `player.world = self` esté en GameWorld.gd:_ready()

### Error: "Autoload no encontrado"
- **Solución**: Verificar rutas en Project Settings → Autoload

### Error: "Scene not found"
- **Solución**: Verificar que todas las escenas .tscn estén creadas y guardadas

### Player cae infinitamente:
- **Solución**: Verificar que ChunkManager genere el mundo en GameWorld.gd

---

## 📦 OPCIONAL: Añadir Assets de Audio

1. Descargar sonidos gratis de:
   - [freesound.org](https://freesound.org)
   - [opengameart.org](https://opengameart.org)

2. Convertir a OGG (Godot prefiere OGG):
   ```bash
   ffmpeg -i input.wav -c:a libvorbis output.ogg
   ```

3. Copiar a `assets/audio/music/` y `assets/audio/sfx/`

4. Los scripts ya están configurados para buscarlos allí

---

## 🎉 ¡LISTO!

Una vez creadas las 7 escenas, el juego estará **100% funcional**.

Si tienes dudas sobre alguna escena específica, consulta `SCENE_ASSEMBLY_GUIDE.md` para instrucciones más detalladas.

**¡A construir y hacer brillar tu Luz Interior! ✨**
