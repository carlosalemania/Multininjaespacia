# ============================================================================
# Configuración del Input Map para Multi Ninja Espacial
# ============================================================================
# Este archivo documenta todas las acciones de input que deben configurarse
# en Godot 4.2+ en Project Settings → Input Map
# ============================================================================

## MOVIMIENTO

### move_forward
- **Tecla**: W
- **Tipo**: Keyboard
- **Descripción**: Mover hacia adelante

### move_backward
- **Tecla**: S
- **Tipo**: Keyboard
- **Descripción**: Mover hacia atrás

### move_left
- **Tecla**: A
- **Tipo**: Keyboard
- **Descripción**: Mover a la izquierda

### move_right
- **Tecla**: D
- **Tipo**: Keyboard
- **Descripción**: Mover a la derecha

### jump
- **Tecla**: Space
- **Tipo**: Keyboard
- **Descripción**: Saltar

---

## INTERACCIÓN CON BLOQUES

### place_block
- **Botón**: Mouse Button Left (Button Index: 1)
- **Tipo**: Mouse
- **Descripción**: Colocar bloque

### break_block
- **Botón**: Mouse Button Right (Button Index: 2)
- **Tipo**: Mouse
- **Descripción**: Romper bloque (mantener presionado)

---

## INVENTARIO (Slots 1-9)

### slot_1
- **Tecla**: 1 (Keypad 1 también)
- **Tipo**: Keyboard
- **Descripción**: Seleccionar slot 1 (Tierra)

### slot_2
- **Tecla**: 2
- **Tipo**: Keyboard
- **Descripción**: Seleccionar slot 2 (Piedra)

### slot_3
- **Tecla**: 3
- **Tipo**: Keyboard
- **Descripción**: Seleccionar slot 3 (Madera)

### slot_4
- **Tecla**: 4
- **Tipo**: Keyboard
- **Descripción**: Seleccionar slot 4 (Cristal)

### slot_5
- **Tecla**: 5
- **Tipo**: Keyboard
- **Descripción**: Seleccionar slot 5 (Metal)

### slot_6
- **Tecla**: 6
- **Tipo**: Keyboard
- **Descripción**: Seleccionar slot 6 (Vacío)

### slot_7
- **Tecla**: 7
- **Tipo**: Keyboard
- **Descripción**: Seleccionar slot 7 (Vacío)

### slot_8
- **Tecla**: 8
- **Tipo**: Keyboard
- **Descripción**: Seleccionar slot 8 (Vacío)

### slot_9
- **Tecla**: 9
- **Tipo**: Keyboard
- **Descripción**: Seleccionar slot 9 (Vacío)

---

## UI Y PAUSA

### ui_cancel
- **Tecla**: Escape (ESC)
- **Tipo**: Keyboard
- **Descripción**: Pausar juego / Cerrar menú
- **Nota**: Esta acción ya existe por defecto en Godot, solo verificar que esté mapeada a ESC

### toggle_inventory
- **Tecla**: E
- **Tipo**: Keyboard
- **Descripción**: Abrir/cerrar inventario completo

### toggle_debug
- **Tecla**: F3
- **Tipo**: Keyboard
- **Descripción**: Mostrar información de debug (opcional)

---

## CÓMO CONFIGURAR EN GODOT:

1. Abrir Godot Editor
2. Ir a **Project → Project Settings**
3. Seleccionar la pestaña **Input Map**
4. Para cada acción:
   - Escribir el nombre de la acción en "Add New Action"
   - Click en "Add"
   - Click en el botón "+" a la derecha de la acción creada
   - Seleccionar el tipo de input (Keyboard o Mouse)
   - Presionar la tecla/botón correspondiente
   - Click en "OK"

---

## EJEMPLO DE CONFIGURACIÓN EN project.godot:

```ini
[input]

move_forward={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":87,"physical_keycode":0,"key_label":0,"unicode":0,"echo":false,"script":null)
]
}
move_backward={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":83,"physical_keycode":0,"key_label":0,"unicode":0,"echo":false,"script":null)
]
}
move_left={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":65,"physical_keycode":0,"key_label":0,"unicode":0,"echo":false,"script":null)
]
}
move_right={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":68,"physical_keycode":0,"key_label":0,"unicode":0,"echo":false,"script":null)
]
}
jump={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":32,"physical_keycode":0,"key_label":0,"unicode":0,"echo":false,"script":null)
]
}
place_block={
"deadzone": 0.5,
"events": [Object(InputEventMouseButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"button_mask":0,"position":Vector2(0, 0),"global_position":Vector2(0, 0),"factor":1.0,"button_index":1,"canceled":false,"pressed":false,"double_click":false,"script":null)
]
}
break_block={
"deadzone": 0.5,
"events": [Object(InputEventMouseButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"button_mask":0,"position":Vector2(0, 0),"global_position":Vector2(0, 0),"factor":1.0,"button_index":2,"canceled":false,"pressed":false,"double_click":false,"script":null)
]
}
```

---

## KEYCODES DE REFERENCIA:

- **W**: 87
- **A**: 65
- **S**: 83
- **D**: 68
- **Space**: 32
- **ESC**: 4194305
- **E**: 69
- **F3**: 4194332
- **1-9**: 49-57
- **Mouse Left**: Button Index 1
- **Mouse Right**: Button Index 2
