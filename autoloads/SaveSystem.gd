# ============================================================================
# SaveSystem.gd - Sistema de Guardado (LocalStorage para Web)
# ============================================================================
# Singleton que guarda/carga datos usando LocalStorage del navegador
# ============================================================================

extends Node

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SEÑALES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Emitida cuando se guarda exitosamente
signal game_saved

## Emitida cuando se carga exitosamente
signal game_loaded

## Emitida si falla el guardado
signal save_failed(error: String)

## Emitida si falla la carga
signal load_failed(error: String)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Timer para auto-guardado
var _auto_save_timer: float = 0.0

## ¿Hay datos guardados disponibles?
var has_save_data: bool = false

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	print("💾 SaveSystem inicializado")

	# Verificar si hay datos guardados
	has_save_data = _check_save_exists()

	if has_save_data:
		print("✅ Partida guardada encontrada")
	else:
		print("ℹ️ No hay partida guardada")


func _process(delta: float) -> void:
	# Auto-guardado cada 2 minutos (solo si estamos jugando)
	if GameManager.current_state == Enums.GameState.PLAYING:
		_auto_save_timer += delta

		if _auto_save_timer >= Constants.AUTO_SAVE_INTERVAL:
			save_game()
			_auto_save_timer = 0.0
			print("💾 Auto-guardado ejecutado")


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# GUARDAR
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Guarda el estado completo del juego
func save_game() -> bool:
	print("💾 Guardando partida...")

	# Crear diccionario con todos los datos
	var save_data: Dictionary = {
		"version": "1.0",
		"timestamp": Time.get_unix_time_from_system(),
		"player_data": PlayerData.to_dict(),
		"game_time": GameManager.play_time,
		# TODO: Añadir datos del mundo (bloques modificados)
	}

	# Convertir a JSON
	var json_string = JSON.stringify(save_data)

	# Guardar en LocalStorage (solo web)
	if OS.has_feature("web"):
		var success = _save_to_localstorage(json_string)
		if success:
			game_saved.emit()
			print("✅ Partida guardada exitosamente")
			return true
		else:
			save_failed.emit("Error al guardar en LocalStorage")
			print("❌ Error al guardar")
			return false
	else:
		# En desktop, guardar en archivo
		var success = _save_to_file(json_string)
		if success:
			game_saved.emit()
			print("✅ Partida guardada exitosamente (archivo)")
			return true
		else:
			save_failed.emit("Error al guardar en archivo")
			print("❌ Error al guardar")
			return false


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CARGAR
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Carga el estado del juego guardado
func load_game() -> bool:
	print("📂 Cargando partida...")

	var json_string: String = ""

	# Cargar desde LocalStorage (web) o archivo (desktop)
	if OS.has_feature("web"):
		json_string = _load_from_localstorage()
	else:
		json_string = _load_from_file()

	if json_string.is_empty():
		load_failed.emit("No hay datos guardados")
		print("❌ No se encontraron datos guardados")
		return false

	# Parsear JSON
	var json = JSON.new()
	var parse_result = json.parse(json_string)

	if parse_result != OK:
		load_failed.emit("Datos corruptos")
		print("❌ Error al parsear JSON: ", json.get_error_message())
		return false

	var save_data = json.get_data() as Dictionary

	# Verificar versión
	if not save_data.has("version"):
		load_failed.emit("Formato de guardado inválido")
		print("❌ Formato inválido")
		return false

	# Cargar datos del jugador
	if save_data.has("player_data"):
		PlayerData.from_dict(save_data.player_data)

	# Cargar tiempo de juego
	if save_data.has("game_time"):
		GameManager.play_time = save_data.game_time

	# TODO: Cargar datos del mundo

	game_loaded.emit()
	print("✅ Partida cargada exitosamente")
	return true


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# UTILIDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Verifica si existe una partida guardada
func _check_save_exists() -> bool:
	if OS.has_feature("web"):
		var data = _load_from_localstorage()
		return not data.is_empty()
	else:
		return FileAccess.file_exists("user://savegame.json")


## Borra la partida guardada
func delete_save() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("localStorage.removeItem('" + Constants.SAVE_KEY + "');")
		print("🗑️ Partida guardada eliminada (LocalStorage)")
	else:
		if FileAccess.file_exists("user://savegame.json"):
			DirAccess.remove_absolute("user://savegame.json")
			print("🗑️ Partida guardada eliminada (archivo)")

	has_save_data = false


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# LOCALSTORAGE (WEB)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Guarda en LocalStorage del navegador
func _save_to_localstorage(json_string: String) -> bool:
	if not OS.has_feature("web"):
		return false

	# Usar JavaScriptBridge para acceder a localStorage
	var code = "localStorage.setItem('" + Constants.SAVE_KEY + "', '" + json_string.replace("'", "\\'") + "');"
	JavaScriptBridge.eval(code)

	return true


## Carga desde LocalStorage del navegador
func _load_from_localstorage() -> String:
	if not OS.has_feature("web"):
		return ""

	# Usar JavaScriptBridge para leer localStorage
	var code = "localStorage.getItem('" + Constants.SAVE_KEY + "');"
	var result = JavaScriptBridge.eval(code)

	if result == null:
		return ""

	return str(result)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ARCHIVO (DESKTOP)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Guarda en archivo local (para desktop)
func _save_to_file(json_string: String) -> bool:
	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)

	if file == null:
		print("❌ Error al abrir archivo para escritura: ", FileAccess.get_open_error())
		return false

	file.store_string(json_string)
	file.close()

	return true


## Carga desde archivo local (para desktop)
func _load_from_file() -> String:
	if not FileAccess.file_exists("user://savegame.json"):
		return ""

	var file = FileAccess.open("user://savegame.json", FileAccess.READ)

	if file == null:
		print("❌ Error al abrir archivo para lectura: ", FileAccess.get_open_error())
		return ""

	var content = file.get_as_text()
	file.close()

	return content
