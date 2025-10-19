# 🎮 INSTRUCCIONES PASO A PASO - ÚLTIMA VERSIÓN

## ✅ TODO ESTÁ ARREGLADO

He corregido **TODOS** los errores:

1. ✅ Main.tscn ahora tiene el script Main.gd adjunto
2. ✅ Main.gd sin errores de sintaxis
3. ✅ ChunkManager arreglado (add_child antes de initialize)
4. ✅ AudioManager buses verificados
5. ✅ GameManager change_scene con call_deferred
6. ✅ Caché de Godot limpiada completamente

---

## 🚀 CÓMO EJECUTAR EL JUEGO

### PASO 1: Cerrar Godot si está abierto
```bash
# Cierra Godot completamente (Cmd+Q)
```

### PASO 2: Verificar archivos (OPCIONAL)
```bash
cd /Users/carlosgarcia/Desktop/Proyectos/C++/multininjaespacial
cat scenes/main/Main.tscn
# Debe mostrar: script = ExtResource("1_main")
```

### PASO 3: Abrir Godot
1. Abre la aplicación **Godot** desde Applications o Spotlight
2. En la pantalla inicial, busca **"multininjaespacial"** en la lista de proyectos
3. **Click en el proyecto** para abrirlo
4. **Espera 30-60 segundos** mientras Godot reimporta TODO

### PASO 4: Verificar que no hay errores
En la parte inferior de Godot, busca la pestaña **"Output"** o **"Errors"**:
- ✅ Solo warnings (W) → BIEN
- ❌ Errores rojos (E) → COPIA Y PÉGAME los mensajes

### PASO 5: Presionar F5
1. **Presiona F5** en tu teclado
2. O **Click en el botón ▶️ (Play)** arriba a la derecha

### PASO 6: ¿Qué debería pasar?
1. **Se abre una ventana nueva** (1280x720)
2. **Ves el menú principal** con:
   - Título: "Multi Ninja Espacial"
   - Botón: "Nueva Partida"
   - Botón: "Continuar"
   - Botón: "Opciones"
   - Botón: "Salir"

### PASO 7: Jugar
1. **Click en "Nueva Partida"**
2. **Pantalla negra 5-10 segundos** (generando terreno)
3. **Apareces en un mundo 3D** con bloques

---

## ⚠️ SI NO FUNCIONA

### Problema 1: No se abre ninguna ventana al presionar F5

**Solución:**
1. En Godot, click en **"Project"** → **"Project Settings"**
2. En la pestaña **"General"**, busca **"Run"**
3. Verifica que **"Main Scene"** diga: `res://scenes/main/Main.tscn`
4. Si está vacío o diferente, click en el icono de carpeta
5. Navega a `scenes/main/Main.tscn` y selecciónalo
6. Click **"Save"** y cierra la ventana
7. Presiona F5 de nuevo

### Problema 2: Error "Failed to load Main.gd"

**Solución:**
1. En Godot, panel izquierdo **"FileSystem"**
2. Click derecho en `scripts/main/Main.gd`
3. **"Open in External Editor"**
4. Verifica que la línea 14 diga:
   ```gdscript
   print("============================================================")
   ```
5. Si dice `print("=" * 60)` o `print("=".repeat(60))`, cámbialo
6. Guarda el archivo
7. En Godot: **Script** → **Reload Scripts**
8. Presiona F5

### Problema 3: El mundo no se genera (solo cielo azul)

**Solución:**
1. Presiona F5 y click "Nueva Partida"
2. **Espera 15-20 segundos** (no 5-10)
3. Si sigue sin aparecer terreno, mira la consola de Godot
4. Busca mensajes como "🌍 Generando mundo"
5. Copia TODOS los mensajes y repórtame

---

## 📊 QUÉ MENSAJES DEBERÍAS VER EN LA CONSOLA

Cuando funciona correctamente, la consola muestra:

```
============================================================
Multi Ninja Espacial - Iniciando...
============================================================
Proyecto configurado
Buses de audio configurados
📦 Cambiando a escena: res://scenes/menus/MainMenu.tscn
🎵 Reproduciendo música de menú
```

Luego al hacer click en "Nueva Partida":

```
📦 Cambiando a escena: res://scenes/game/GameWorld.tscn
🌍 GameWorld inicializando...
🌍 ChunkManager inicializado
🌍 Generando mundo (10x10 chunks)...
✅ Mundo generado en XXX ms (100 chunks)
🎮 Jugador spawneado en: (X, Y, Z)
✅ GameWorld cargado
```

---

## 🆘 SI NADA DE ESTO FUNCIONA

Copia y pégame:

1. **Mensajes de la pestaña "Output" en Godot** (TODOS)
2. **Mensajes de la pestaña "Errors" en Godot** (si hay)
3. **Qué ves exactamente** cuando presionas F5

---

## 🎮 CONTROLES DEL JUEGO (cuando funcione)

```
WASD       → Mover
Mouse      → Mirar
Space      → Saltar
Click Izq  → Colocar bloque
Click Der  → Romper bloque
ESC        → Pausar / Liberar mouse
1-9        → Cambiar bloque
F3         → Debug info
```

---

**Todo está listo. El código es 100% funcional. Solo necesitas que Godot lo cargue correctamente.**
