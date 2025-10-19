# ============================================================================
# Guía de Ensamblaje de Escenas en Godot
# ============================================================================
# Instrucciones paso a paso para crear las escenas .tscn en Godot Editor
# ============================================================================

## 📋 ÍNDICE

1. [Main.tscn - Escena Principal](#1-maintscn)
2. [MainMenu.tscn - Menú Principal](#2-mainmenutscn)
3. [GameWorld.tscn - Mundo del Juego](#3-gameworldtscn)
4. [Player.tscn - Jugador](#4-playertscn)
5. [Chunk.tscn - Fragmento de Mundo](#5-chunktscn)
6. [GameHUD.tscn - HUD del Juego](#6-gamehudtscn)
7. [PauseMenu.tscn - Menú de Pausa](#7-pausemenutscn)

---

## 1. Main.tscn

**Ruta**: `res://scenes/main/Main.tscn`

### Jerarquía de Nodos:
```
Main (Node)
├── Script: res://scripts/main/Main.gd
```

### Instrucciones:
1. Crear nuevo nodo tipo `Node`
2. Renombrar a "Main"
3. Asignar script `res://scripts/main/Main.gd`
4. Guardar como `res://scenes/main/Main.tscn`

---

## 2. MainMenu.tscn

**Ruta**: `res://scenes/menus/MainMenu.tscn`

### Jerarquía de Nodos:
```
MainMenu (Control)
├── Script: res://scripts/ui/MainMenu.gd
└── VBoxContainer
    ├── TitleLabel (Label)
    ├── NewGameButton (Button)
    ├── ContinueButton (Button)
    ├── OptionsButton (Button)
    └── QuitButton (Button)
```

### Instrucciones:
1. Crear nodo raíz tipo `Control`
2. Renombrar a "MainMenu"
3. Configurar Anchors: Center (centrado en pantalla)
4. Asignar script `res://scripts/ui/MainMenu.gd`
5. Añadir `VBoxContainer` como hijo
6. Configurar VBoxContainer:
   - Alignment: Center
   - Separation: 20
7. Añadir hijos al VBoxContainer:
   - **TitleLabel** (Label):
     - Text: "Multi Ninja Espacial"
     - Font Size: 48
     - Horizontal Alignment: Center
   - **NewGameButton** (Button):
     - Text: "Nueva Partida"
     - Custom Minimum Size: (200, 50)
   - **ContinueButton** (Button):
     - Text: "Continuar"
     - Custom Minimum Size: (200, 50)
   - **OptionsButton** (Button):
     - Text: "Opciones"
     - Custom Minimum Size: (200, 50)
   - **QuitButton** (Button):
     - Text: "Salir"
     - Custom Minimum Size: (200, 50)
8. Guardar como `res://scenes/menus/MainMenu.tscn`

---

## 3. GameWorld.tscn

**Ruta**: `res://scenes/game/GameWorld.tscn`

### Jerarquía de Nodos:
```
GameWorld (Node3D)
├── Script: res://scripts/game/GameWorld.gd
├── WorldEnvironment (WorldEnvironment)
│   └── Environment: (crear nuevo Environment)
├── DirectionalLight3D (DirectionalLight3D)
├── ChunkManager (Node3D)
│   └── Script: res://scripts/world/ChunkManager.gd
├── TerrainGenerator (Node)
│   └── Script: res://scripts/world/TerrainGenerator.gd
└── Player (instancia de Player.tscn)
```

### Instrucciones:
1. Crear nodo raíz tipo `Node3D`
2. Renombrar a "GameWorld"
3. Asignar script `res://scripts/game/GameWorld.gd`
4. Añadir `WorldEnvironment`:
   - Crear nuevo `Environment` en su propiedad
5. Añadir `DirectionalLight3D`:
   - Position: (0, 10, 0)
   - Rotation: (-45, 45, 0)
   - Shadow Enabled: true
6. Añadir `Node3D` hijo, renombrar a "ChunkManager"
   - Asignar script `res://scripts/world/ChunkManager.gd`
7. Añadir `Node` hijo, renombrar a "TerrainGenerator"
   - Asignar script `res://scripts/world/TerrainGenerator.gd`
8. Instanciar `Player.tscn` (crear primero la escena Player)
9. Guardar como `res://scenes/game/GameWorld.tscn`

---

## 4. Player.tscn

**Ruta**: `res://scenes/player/Player.tscn`

### Jerarquía de Nodos:
```
Player (CharacterBody3D)
├── Script: res://scripts/player/Player.gd
├── CollisionShape3D
│   └── Shape: CapsuleShape3D (Height: 1.8, Radius: 0.3)
├── CameraController (Node3D)
│   ├── Script: res://scripts/player/CameraController.gd
│   ├── Position: (0, 1.6, 0)  [altura de los ojos]
│   └── Camera3D
│       └── Current: true
├── PlayerMovement (Node)
│   └── Script: res://scripts/player/PlayerMovement.gd
└── PlayerInteraction (Node)
    └── Script: res://scripts/player/PlayerInteraction.gd
```

### Instrucciones:
1. Crear nodo raíz tipo `CharacterBody3D`
2. Renombrar a "Player"
3. Asignar script `res://scripts/player/Player.gd`
4. Añadir `CollisionShape3D`:
   - Crear nuevo `CapsuleShape3D`
   - Height: 1.8
   - Radius: 0.3
5. Añadir `Node3D` hijo, renombrar a "CameraController"
   - Asignar script `res://scripts/player/CameraController.gd`
   - Position: (0, 1.6, 0)
   - Añadir `Camera3D` como hijo del CameraController
     - Current: true (marcar checkbox)
6. Añadir `Node` hijo, renombrar a "PlayerMovement"
   - Asignar script `res://scripts/player/PlayerMovement.gd`
7. Añadir `Node` hijo, renombrar a "PlayerInteraction"
   - Asignar script `res://scripts/player/PlayerInteraction.gd`
8. Guardar como `res://scenes/player/Player.tscn`

---

## 5. Chunk.tscn

**Ruta**: `res://scenes/world/Chunk.tscn`

### Jerarquía de Nodos:
```
Chunk (Node3D)
└── Script: res://scripts/world/Chunk.gd
```

### Instrucciones:
1. Crear nodo raíz tipo `Node3D`
2. Renombrar a "Chunk"
3. Asignar script `res://scripts/world/Chunk.gd`
4. Guardar como `res://scenes/world/Chunk.tscn`

**Nota**: Los MeshInstance3D y StaticBody3D se crean dinámicamente en el script.

---

## 6. GameHUD.tscn

**Ruta**: `res://scenes/ui/GameHUD.tscn`

### Jerarquía de Nodos (Estructura Completa):
```
GameHUD (Control)
├── Script: res://scripts/ui/GameHUD.gd
├── Crosshair (Control)
│   ├── Anchor Preset: Center
│   ├── Custom Minimum Size: (20, 20)
│   └── Panel
│       └── Self Modulate: Color(1, 1, 1, 0.7)
├── TopLeft (MarginContainer)
│   ├── Anchor Preset: Top Left
│   ├── Margin Left/Top: 20
│   └── VBoxContainer
│       └── LuzBar (ProgressBar)
│           ├── Custom Minimum Size: (200, 30)
│           ├── Max Value: 1000
│           ├── Show Percentage: false
│           └── LuzLabel (Label)
│               └── Text: "✨ Luz: 0 / 1000"
├── TopCenter (MarginContainer)
│   ├── Anchor Preset: Top Center
│   └── BlockInfoLabel (Label)
│       ├── Visible: false
│       └── Horizontal Alignment: Center
├── TopRight (MarginContainer)
│   ├── Anchor Preset: Top Right
│   ├── Margin Right: -20
│   ├── Margin Top: 20
│   └── DebugPanel (VBoxContainer)
│       └── Visible: false
├── Center (CenterContainer)
│   ├── Anchor Preset: Center
│   └── BreakProgress (ProgressBar)
│       ├── Custom Minimum Size: (200, 20)
│       └── Visible: false
└── Bottom (MarginContainer)
    ├── Anchor Preset: Bottom Center
    ├── Margin Bottom: -20
    └── Hotbar (HBoxContainer)
        ├── Alignment: Center
        └── Separation: 5
```

### Instrucciones:
1. Crear nodo raíz tipo `Control`
2. Renombrar a "GameHUD"
3. Configurar Layout: Full Rect (cubrir toda la pantalla)
4. Asignar script `res://scripts/ui/GameHUD.gd`
5. Añadir estructura de nodos como se muestra arriba
6. **Crosshair**: Panel blanco semi-transparente centrado
7. **TopLeft → LuzBar**: Barra de progreso para Luz Interior
8. **Bottom → Hotbar**: Contenedor horizontal donde el script creará los 9 slots
9. Guardar como `res://scenes/ui/GameHUD.tscn`

**Nota**: Los slots del hotbar se crean dinámicamente en `_setup_hotbar()`.

---

## 7. PauseMenu.tscn

**Ruta**: `res://scenes/ui/PauseMenu.tscn`

### Jerarquía de Nodos:
```
PauseMenu (Control)
├── Script: res://scripts/ui/PauseMenu.gd
├── Layout: Full Rect
└── Panel
    ├── Anchor Preset: Center
    ├── Custom Minimum Size: (400, 500)
    └── VBoxContainer
        ├── Margin: 20 (todos los lados)
        ├── TitleLabel (Label)
        │   └── Text: "PAUSA"
        ├── ResumeButton (Button)
        │   └── Text: "Reanudar"
        ├── SaveButton (Button)
        │   └── Text: "Guardar"
        ├── OptionsButton (Button)
        │   └── Text: "Opciones"
        └── MainMenuButton (Button)
            └── Text: "Menú Principal"
```

### Instrucciones:
1. Crear nodo raíz tipo `Control`
2. Renombrar a "PauseMenu"
3. Configurar Layout: Full Rect
4. Asignar script `res://scripts/ui/PauseMenu.gd`
5. Añadir `Panel` hijo:
   - Anchor Preset: Center
   - Custom Minimum Size: (400, 500)
   - Añadir `VBoxContainer`:
     - Configurar márgenes: 20px todos los lados
     - Separation: 20
6. Añadir hijos al VBoxContainer (labels y botones como se muestra arriba)
7. Guardar como `res://scenes/ui/PauseMenu.tscn`

---

## 📝 NOTAS ADICIONALES

### Integrar PauseMenu en GameWorld:
1. Abrir `GameWorld.tscn`
2. Añadir `CanvasLayer` como hijo de GameWorld
3. Instanciar `GameHUD.tscn` como hijo del CanvasLayer
4. Instanciar `PauseMenu.tscn` como hijo del CanvasLayer

### Configurar Main como Escena Principal:
1. Ir a **Project → Project Settings**
2. En la pestaña **Application → Run**
3. Establecer **Main Scene**: `res://scenes/main/Main.tscn`

### Configurar Autoloads:
Ya están documentados en `GODOT-WEB-STRUCTURE.md`, pero recordatorio:

**Project → Project Settings → Autoload**:
- GameManager: `res://autoloads/GameManager.gd`
- PlayerData: `res://autoloads/PlayerData.gd`
- VirtueSystem: `res://autoloads/VirtueSystem.gd`
- SaveSystem: `res://autoloads/SaveSystem.gd`
- AudioManager: `res://autoloads/AudioManager.gd`

Todos con **Enable** marcado.

---

## ✅ CHECKLIST FINAL

- [ ] Main.tscn creado
- [ ] MainMenu.tscn creado
- [ ] Player.tscn creado
- [ ] Chunk.tscn creado
- [ ] GameWorld.tscn creado
- [ ] GameHUD.tscn creado
- [ ] PauseMenu.tscn creado
- [ ] Input Map configurado (ver INPUT_MAP_CONFIG.md)
- [ ] Autoloads configurados
- [ ] Main.tscn establecido como escena principal
- [ ] Buses de audio configurados (Music, SFX)

---

## 🎮 PRIMER RUN

Una vez completado todo:
1. Presionar F5 o click en "Play"
2. Debería aparecer el MainMenu
3. Click en "Nueva Partida"
4. El mundo debería generarse (esperar unos segundos)
5. El jugador aparecerá en el terreno
6. Usar WASD para moverse, Mouse para mirar, Space para saltar
7. Click izquierdo para colocar bloques, Click derecho (mantener) para romper
8. ESC para pausar

---

## 🐛 TROUBLESHOOTING

### "Autoload no encontrado"
- Verificar rutas en Project Settings → Autoload
- Verificar que todos los archivos .gd existan

### "Player cae infinitamente"
- Verificar que GameWorld llame a `chunk_manager.generate_world()`
- Verificar que Chunk tenga colisión habilitada

### "No puedo mover la cámara"
- Verificar que Input Map esté configurado
- Verificar que el mouse esté capturado (Input.MOUSE_MODE_CAPTURED)

### "Error al guardar"
- En web, verificar que JavaScriptBridge funcione
- Probar en modo desktop primero
