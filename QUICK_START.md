# 🚀 Quick Start - Multi Ninja Espacial

**Tiempo estimado: 15-20 minutos hasta jugar**

---

## 🎯 Paso 1: Abrir Godot (1 minuto)

### Opción A: Script Automático
```bash
cd /Users/carlosgarcia/Desktop/Proyectos/C++/multininjaespacial
./open_godot.sh
```

### Opción B: Manual
1. Abrir Godot 4.2+
2. Click en **"Import"**
3. Seleccionar: `project.godot` (esta carpeta)
4. Click en **"Import & Edit"**

**✅ Godot se abrirá con TODO ya configurado:**
- Autoloads ✅
- Input Map ✅
- Settings ✅

---

## 🎬 Paso 2: Crear 7 Escenas (15 minutos)

Sigue **GODOT_SETUP_INSTRUCTIONS.md** paso a paso.

### Resumen Ultra-Rápido:

#### 1. Main.tscn (30 seg)
- New Scene → Node → "Main"
- Script: `scripts/main/Main.gd`
- Save: `scenes/main/Main.tscn`

#### 2. Player.tscn (3 min)
- New Scene → CharacterBody3D → "Player"
- Script: `scripts/player/Player.gd`
- Añadir:
  - CollisionShape3D (CapsuleShape, H:1.8, R:0.3)
  - Node3D → "CameraController" (script, pos 0,1.6,0)
    - Camera3D (Current ✅)
  - Node → "PlayerMovement" (script)
  - Node → "PlayerInteraction" (script)
- Save: `scenes/player/Player.tscn`

#### 3. Chunk.tscn (30 seg)
- New Scene → Node3D → "Chunk"
- Script: `scripts/world/Chunk.gd`
- Save: `scenes/world/Chunk.tscn`

#### 4. GameWorld.tscn (4 min)
- New Scene → Node3D → "GameWorld"
- Script: `scripts/game/GameWorld.gd`
- Añadir:
  - WorldEnvironment (New Environment)
  - DirectionalLight3D (Shadow ✅)
  - Node3D → "ChunkManager" (script)
  - Node → "TerrainGenerator" (script)
  - Instance → Player.tscn
- Save: `scenes/game/GameWorld.tscn`

#### 5. MainMenu.tscn (3 min)
- New Scene → Control → "MainMenu" (Layout: Center)
- Script: `scripts/ui/MainMenu.gd`
- Añadir VBoxContainer:
  - Label "TitleLabel" (text: "Multi Ninja Espacial", size: 48)
  - Button "NewGameButton" (text: "Nueva Partida")
  - Button "ContinueButton" (text: "Continuar")
  - Button "OptionsButton" (text: "Opciones")
  - Button "QuitButton" (text: "Salir")
- Save: `scenes/menus/MainMenu.tscn`

#### 6. GameHUD.tscn (3 min)
- New Scene → Control → "GameHUD" (Layout: Full Rect)
- Script: `scripts/ui/GameHUD.gd`
- Añadir:
  - Panel → "Crosshair" (Layout: Center, Size: 20x20)
  - MarginContainer → "TopLeft" (Layout: Top Left)
    - VBoxContainer
      - ProgressBar → "LuzBar" (Size: 200x30, Max: 1000)
        - Label → "LuzLabel" (text: "✨ Luz: 0 / 1000")
  - MarginContainer → "TopCenter"
    - Label → "BlockInfoLabel" (visible: false)
  - MarginContainer → "TopRight"
    - VBoxContainer → "DebugPanel" (visible: false)
  - CenterContainer → "Center"
    - ProgressBar → "BreakProgress" (visible: false)
  - MarginContainer → "Bottom" (Layout: Bottom Center)
    - HBoxContainer → "Hotbar"
- Save: `scenes/ui/GameHUD.tscn`

#### 7. PauseMenu.tscn (2 min)
- New Scene → Control → "PauseMenu" (Layout: Full Rect)
- Script: `scripts/ui/PauseMenu.gd`
- Añadir Panel (Layout: Center, Size: 400x500):
  - VBoxContainer (Margins: 20):
    - Label "TitleLabel" (text: "PAUSA")
    - Button "ResumeButton" (text: "Reanudar")
    - Button "SaveButton" (text: "Guardar")
    - Button "OptionsButton" (text: "Opciones")
    - Button "MainMenuButton" (text: "Menú Principal")
- Save: `scenes/ui/PauseMenu.tscn`

#### 8. Integrar HUD en GameWorld (1 min)
- Abrir `GameWorld.tscn`
- Añadir CanvasLayer
  - Instance → GameHUD.tscn
  - Instance → PauseMenu.tscn
- Save

---

## 🎮 Paso 3: ¡Jugar! (Inmediato)

1. **Presiona F5** (o click en Play ▶️)
2. Deberías ver el **MainMenu**
3. Click en **"Nueva Partida"**
4. Espera 5-10 segundos (generando mundo)
5. **¡Ya estás jugando!**

### Controles:
- **WASD**: Mover
- **Mouse**: Mirar
- **Space**: Saltar
- **Click Izquierdo**: Colocar bloque
- **Click Derecho (mantener)**: Romper bloque
- **1-9**: Cambiar slot
- **ESC**: Pausar
- **F3**: Debug info

---

## ⚠️ Si Algo Falla

### "Main scene not found"
- En Project Settings → Application → Run → Main Scene
- Establecer: `res://scenes/main/Main.tscn`

### "Player cae infinitamente"
- Normal, espera 5-10 segundos mientras se genera el terreno
- Si sigue cayendo, verificar GameWorld.gd:_ready() llama a `_generate_world()`

### "Autoload error"
- Ya están configurados en project.godot
- Verificar: Project Settings → Autoload (deberían aparecer 5)

### "Input not working"
- Ya está configurado en project.godot
- Verificar: Project Settings → Input Map

---

## 🔊 Audio (OPCIONAL)

**El juego funciona SIN audio.**

Si quieres añadir sonido:
- Ver **AUDIO_PLACEHOLDERS.md**
- No es necesario para primera prueba

---

## ✅ Checklist Final

- [ ] Godot abierto con el proyecto
- [ ] 7 escenas .tscn creadas
- [ ] F5 presionado
- [ ] MainMenu visible
- [ ] Click en "Nueva Partida"
- [ ] Mundo generado
- [ ] Puedo moverme con WASD
- [ ] Puedo colocar/romper bloques
- [ ] ¡JUGANDO! 🎉

---

## 🎉 ¡Listo!

**Si llegaste hasta aquí, el juego está funcionando.**

### Próximos pasos (opcional):
- Añadir audio (AUDIO_PLACEHOLDERS.md)
- Exportar para web (README.md)
- Añadir más bloques
- Mejorar gráficos

---

## 📚 Documentación Completa

- **GODOT_SETUP_INSTRUCTIONS.md** - Instrucciones detalladas
- **SCENE_ASSEMBLY_GUIDE.md** - Guía completa de escenas
- **PROJECT_SUMMARY.md** - Resumen técnico
- **AUTOMATED_SETUP_COMPLETE.md** - Qué ya está hecho

---

**¿Dudas? Todos los scripts están comentados en español. Revisa el código!**

**¡A construir y hacer brillar tu Luz Interior! ✨**
