# ============================================================================
# AudioManager.gd - Gestor de Audio
# ============================================================================
# Singleton que gestiona música de fondo y efectos de sonido
# ============================================================================

extends Node

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SEÑALES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Emitida cuando cambia el volumen de música
signal music_volume_changed(volume: float)

## Emitida cuando cambia el volumen de SFX
signal sfx_volume_changed(volume: float)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Reproductor de música de fondo
var _music_player: AudioStreamPlayer = null

## Pool de reproductores de SFX (para múltiples sonidos simultáneos)
var _sfx_players: Array[AudioStreamPlayer] = []

## Número máximo de SFX simultáneos
const MAX_SFX_PLAYERS: int = 8

## Volumen de música (0.0 - 1.0)
var music_volume: float = 0.7

## Volumen de SFX (0.0 - 1.0)
var sfx_volume: float = 0.8

## ¿Música muteada?
var music_muted: bool = false

## ¿SFX muteados?
var sfx_muted: bool = false

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SONIDOS PROCEDURALES (Generados en memoria, no requieren archivos)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Cache de sonidos procedurales generados
var _procedural_sounds: Dictionary = {}

## Música de menú principal (placeholder - sin implementar)
const MUSIC_MENU: String = ""

## Música de gameplay (placeholder - sin implementar)
const MUSIC_GAMEPLAY: String = ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	print("🔊 AudioManager inicializado")

	# Crear reproductor de música
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)

	# Crear pool de reproductores de SFX
	for i in range(MAX_SFX_PLAYERS):
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.bus = "SFX"
		add_child(sfx_player)
		_sfx_players.append(sfx_player)

	# Generar sonidos procedurales
	_generate_procedural_sounds()

	# Aplicar volúmenes iniciales
	_update_music_volume()
	_update_sfx_volume()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÚSICA
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Reproduce música de fondo (con crossfade suave)
func play_music(music_path: String, fade_duration: float = 1.0) -> void:
	# Si ya está sonando esta música, ignorar
	if _music_player.stream and _music_player.stream.resource_path == music_path:
		return

	# Verificar si el archivo existe
	if not FileAccess.file_exists(music_path):
		print("⚠️ Música no encontrada: ", music_path)
		return

	# Cargar nueva música
	var new_stream = load(music_path) as AudioStream
	if new_stream == null:
		print("❌ Error al cargar música: ", music_path)
		return

	# Fade out de la música actual
	if _music_player.playing:
		var fade_out_tween = create_tween()
		fade_out_tween.tween_property(_music_player, "volume_db", -80, fade_duration)
		fade_out_tween.tween_callback(_music_player.stop)

		# Esperar fade out antes de cambiar
		await fade_out_tween.finished

	# Asignar nueva música
	_music_player.stream = new_stream

	# Fade in de la nueva música
	_music_player.volume_db = -80
	_music_player.play()

	var fade_in_tween = create_tween()
	fade_in_tween.tween_property(_music_player, "volume_db", linear_to_db(music_volume), fade_duration)

	print("🎵 Reproduciendo música: ", music_path)


## Detiene la música con fade out
func stop_music(fade_duration: float = 1.0) -> void:
	if not _music_player.playing:
		return

	var tween = create_tween()
	tween.tween_property(_music_player, "volume_db", -80, fade_duration)
	tween.tween_callback(_music_player.stop)

	print("🔇 Deteniendo música")


## Pausa la música
func pause_music() -> void:
	_music_player.stream_paused = true


## Reanuda la música
func resume_music() -> void:
	_music_player.stream_paused = false


## Cambia el volumen de la música (0.0 - 1.0)
func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0)
	_update_music_volume()
	music_volume_changed.emit(music_volume)


## Mutea/desmutea la música
func toggle_music_mute() -> void:
	music_muted = not music_muted
	_update_music_volume()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# EFECTOS DE SONIDO
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Reproduce un efecto de sonido
func play_sfx(sound_type: Enums.SoundType, pitch_variation: float = 0.1) -> void:
	if sfx_muted:
		return

	# Obtener stream procedural del cache
	if not _procedural_sounds.has(sound_type):
		print("⚠️ SoundType no encontrado: ", sound_type)
		return

	var stream = _procedural_sounds[sound_type]

	# Buscar un reproductor libre
	var player = _get_free_sfx_player()
	if player == null:
		# Todos ocupados, usar el primero (interrumpir)
		player = _sfx_players[0]

	# Configurar y reproducir
	player.stream = stream
	player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	player.play()


## Reproduce un SFX desde una ruta específica
func play_sfx_path(sfx_path: String, pitch_variation: float = 0.0) -> void:
	if sfx_muted:
		return

	if not FileAccess.file_exists(sfx_path):
		return

	var stream = load(sfx_path) as AudioStream
	if stream == null:
		return

	var player = _get_free_sfx_player()
	if player == null:
		player = _sfx_players[0]

	player.stream = stream
	player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	player.play()


## Cambia el volumen de SFX (0.0 - 1.0)
func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)
	_update_sfx_volume()
	sfx_volume_changed.emit(sfx_volume)


## Mutea/desmutea los SFX
func toggle_sfx_mute() -> void:
	sfx_muted = not sfx_muted
	_update_sfx_volume()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PRIVADOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Busca un reproductor de SFX libre
func _get_free_sfx_player() -> AudioStreamPlayer:
	for player in _sfx_players:
		if not player.playing:
			return player
	return null


## Actualiza el volumen de música en el bus
func _update_music_volume() -> void:
	var bus_idx = AudioServer.get_bus_index("Music")
	if bus_idx == -1:
		return  # Bus no existe aún

	if music_muted:
		AudioServer.set_bus_volume_db(bus_idx, -80)
	else:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(music_volume))


## Actualiza el volumen de SFX en el bus
func _update_sfx_volume() -> void:
	var bus_idx = AudioServer.get_bus_index("SFX")
	if bus_idx == -1:
		return  # Bus no existe aún

	if sfx_muted:
		AudioServer.set_bus_volume_db(bus_idx, -80)
	else:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(sfx_volume))


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HELPERS DE MÚSICA POR CONTEXTO
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Reproduce música del menú principal
func play_menu_music() -> void:
	play_music(MUSIC_MENU)


## Reproduce música de gameplay
func play_gameplay_music() -> void:
	play_music(MUSIC_GAMEPLAY)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# GENERACIÓN DE SONIDOS PROCEDURALES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Genera todos los sonidos procedurales en memoria
func _generate_procedural_sounds() -> void:
	print("🎵 Generando sonidos procedurales...")

	# Generar sonidos usando ProceduralSounds
	_procedural_sounds[Enums.SoundType.BLOCK_PLACE] = ProceduralSounds.generate_block_place()
	_procedural_sounds[Enums.SoundType.BLOCK_BREAK] = ProceduralSounds.generate_block_break()
	_procedural_sounds[Enums.SoundType.COLLECT] = ProceduralSounds.generate_collect()
	_procedural_sounds[Enums.SoundType.LUZ_GAIN] = ProceduralSounds.generate_luz_gain()
	_procedural_sounds[Enums.SoundType.BUTTON_CLICK] = ProceduralSounds.generate_button_click()
	_procedural_sounds[Enums.SoundType.MENU_OPEN] = ProceduralSounds.generate_menu_open()
	_procedural_sounds[Enums.SoundType.MENU_CLOSE] = ProceduralSounds.generate_menu_close()

	print("✅ Sonidos procedurales generados: ", _procedural_sounds.size(), " sonidos")
