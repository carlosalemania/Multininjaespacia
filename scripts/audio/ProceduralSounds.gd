# ============================================================================
# ProceduralSounds.gd - Generador de Sonidos Procedurales
# ============================================================================
# Genera sonidos simples sin archivos de audio usando AudioStreamGenerator
# ============================================================================

extends Node
class_name ProceduralSounds

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONSTANTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const SAMPLE_RATE = 22050  # Hz
const AMPLITUDE = 0.3  # Volumen (0.0 - 1.0)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PÚBLICOS - GENERADORES DE SONIDOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Genera sonido de colocar bloque (tono corto y sólido)
static func generate_block_place() -> AudioStreamWAV:
	return _generate_tone(300.0, 0.08, 0.6)  # 300 Hz, 80ms


## Genera sonido de romper bloque (tono más bajo y áspero)
static func generate_block_break() -> AudioStreamWAV:
	return _generate_noise_burst(0.12, 0.4)  # 120ms de ruido


## Genera sonido de recolectar item (tono ascendente)
static func generate_collect() -> AudioStreamWAV:
	return _generate_sweep(400.0, 800.0, 0.15, 0.5)  # 400Hz → 800Hz, 150ms


## Genera sonido de ganar luz (campanita brillante)
static func generate_luz_gain() -> AudioStreamWAV:
	return _generate_tone(800.0, 0.2, 0.4)  # 800 Hz, 200ms


## Genera sonido de click de botón (clic corto)
static func generate_button_click() -> AudioStreamWAV:
	return _generate_tone(600.0, 0.05, 0.3)  # 600 Hz, 50ms


## Genera sonido de abrir menú (whoosh)
static func generate_menu_open() -> AudioStreamWAV:
	return _generate_sweep(200.0, 400.0, 0.1, 0.3)


## Genera sonido de cerrar menú (whoosh invertido)
static func generate_menu_close() -> AudioStreamWAV:
	return _generate_sweep(400.0, 200.0, 0.1, 0.3)


## Genera sonido de pasos (tono bajo y corto)
static func generate_footstep() -> AudioStreamWAV:
	return _generate_noise_burst(0.06, 0.2)  # 60ms de ruido bajo


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PRIVADOS - GENERADORES DE ONDAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Genera un tono simple de frecuencia constante
static func _generate_tone(frequency: float, duration: float, amplitude: float = AMPLITUDE) -> AudioStreamWAV:
	var sample_count = int(SAMPLE_RATE * duration)
	var data = PackedByteArray()
	data.resize(sample_count * 2)  # 16-bit = 2 bytes per sample

	for i in range(sample_count):
		# Sine wave
		var t = float(i) / float(SAMPLE_RATE)
		var sample_value = sin(2.0 * PI * frequency * t)

		# Envelope (fade out para evitar clicks)
		var envelope = 1.0
		if i > sample_count * 0.7:  # Fade out últimos 30%
			envelope = 1.0 - ((i - sample_count * 0.7) / (sample_count * 0.3))

		sample_value *= envelope * amplitude

		# Convertir a 16-bit signed integer
		var sample_int = int(sample_value * 32767.0)
		sample_int = clampi(sample_int, -32768, 32767)

		# Little-endian 16-bit
		data[i * 2] = sample_int & 0xFF
		data[i * 2 + 1] = (sample_int >> 8) & 0xFF

	var stream = AudioStreamWAV.new()
	stream.data = data
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false

	return stream


## Genera un sweep (frecuencia variable)
static func _generate_sweep(start_freq: float, end_freq: float, duration: float, amplitude: float = AMPLITUDE) -> AudioStreamWAV:
	var sample_count = int(SAMPLE_RATE * duration)
	var data = PackedByteArray()
	data.resize(sample_count * 2)

	for i in range(sample_count):
		var t = float(i) / float(SAMPLE_RATE)
		var progress = float(i) / float(sample_count)

		# Interpolación lineal de frecuencia
		var frequency = lerp(start_freq, end_freq, progress)

		var sample_value = sin(2.0 * PI * frequency * t)

		# Envelope
		var envelope = 1.0
		if i > sample_count * 0.7:
			envelope = 1.0 - ((i - sample_count * 0.7) / (sample_count * 0.3))

		sample_value *= envelope * amplitude

		var sample_int = int(sample_value * 32767.0)
		sample_int = clampi(sample_int, -32768, 32767)

		data[i * 2] = sample_int & 0xFF
		data[i * 2 + 1] = (sample_int >> 8) & 0xFF

	var stream = AudioStreamWAV.new()
	stream.data = data
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false

	return stream


## Genera ruido blanco (para efectos percusivos)
static func _generate_noise_burst(duration: float, amplitude: float = AMPLITUDE) -> AudioStreamWAV:
	var sample_count = int(SAMPLE_RATE * duration)
	var data = PackedByteArray()
	data.resize(sample_count * 2)

	for i in range(sample_count):
		# Random noise
		var sample_value = randf_range(-1.0, 1.0)

		# Envelope (decay rápido)
		var envelope = 1.0 - (float(i) / float(sample_count))
		envelope = pow(envelope, 2.0)  # Decay exponencial

		sample_value *= envelope * amplitude

		var sample_int = int(sample_value * 32767.0)
		sample_int = clampi(sample_int, -32768, 32767)

		data[i * 2] = sample_int & 0xFF
		data[i * 2 + 1] = (sample_int >> 8) & 0xFF

	var stream = AudioStreamWAV.new()
	stream.data = data
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false

	return stream


## Genera sonido de herramienta según tier
static func generate_tool_sound(tier: String) -> AudioStreamWAV:
	match tier:
		"common":  # Madera - Sonido grave
			return _generate_tone(250.0, 0.15, 0.5)
		"uncommon":  # Piedra - Sonido medio
			return _generate_tone(350.0, 0.13, 0.55)
		"rare":  # Hierro - Sonido metálico
			return _generate_tone(450.0, 0.12, 0.6)
		"epic":  # Oro - Sonido agudo brillante
			return _generate_sweep(400.0, 800.0, 0.1, 0.65)
		"legendary":  # Diamante - Sonido cristalino
			return _generate_sweep(600.0, 1200.0, 0.08, 0.7)
		"divine":  # Guantelete - Sonido cósmico
			return _generate_sweep(200.0, 1500.0, 0.15, 0.75)
		_:
			return _generate_tone(300.0, 0.12, 0.5)

