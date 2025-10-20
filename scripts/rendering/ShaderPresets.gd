# ============================================================================
# ShaderPresets.gd - Sistema de Presets Visuales para Shaders
# ============================================================================
# Clase estática que permite cambiar rápidamente entre configuraciones
# visuales predefinidas (día, noche, cueva, atardecer, etc.)
# ============================================================================

extends Node
class_name ShaderPresets

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENUMERACIONES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Presets visuales disponibles
enum Preset {
	CLEAR_DAY,      ## Día claro con cielo azul
	CLOUDY_DAY,     ## Día nublado con fog medio
	SUNSET,         ## Atardecer con tonos cálidos
	NIGHT,          ## Noche estrellada oscura
	CAVE,           ## Cueva muy oscura con AO fuerte
	FOGGY,          ## Niebla densa (estilo Silent Hill)
	DESERT_DAY,     ## Desierto caluroso con haze
	SNOW_STORM,     ## Tormenta de nieve
	UNDERWATER,     ## Efecto submarino
	CUSTOM          ## Configuración personalizada
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONFIGURACIONES DE PRESETS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Configuraciones de cada preset
## Cada preset define todos los parámetros del shader
const PRESET_CONFIGS: Dictionary = {
	Preset.CLEAR_DAY: {
		"name": "Día Claro",
		"description": "Cielo azul brillante con fog ligero",
		# AO
		"enable_ao": true,
		"ao_strength": 0.3,
		# Fog
		"enable_fog": true,
		"fog_color": Color(0.7, 0.8, 0.9, 1.0),  # Azul cielo
		"fog_start": 40.0,
		"fog_end": 150.0,
		# Lighting
		"ambient_light": 0.7,
		"sun_intensity": 1.5
	},

	Preset.CLOUDY_DAY: {
		"name": "Día Nublado",
		"description": "Día gris con fog medio",
		# AO
		"enable_ao": true,
		"ao_strength": 0.4,
		# Fog
		"enable_fog": true,
		"fog_color": Color(0.6, 0.6, 0.65, 1.0),  # Gris nublado
		"fog_start": 20.0,
		"fog_end": 80.0,
		# Lighting
		"ambient_light": 0.5,
		"sun_intensity": 0.9
	},

	Preset.SUNSET: {
		"name": "Atardecer",
		"description": "Tonos naranjas y cálidos",
		# AO
		"enable_ao": true,
		"ao_strength": 0.4,
		# Fog
		"enable_fog": true,
		"fog_color": Color(0.9, 0.5, 0.3, 1.0),  # Naranja atardecer
		"fog_start": 20.0,
		"fog_end": 80.0,
		# Lighting
		"ambient_light": 0.5,
		"sun_intensity": 0.8
	},

	Preset.NIGHT: {
		"name": "Noche Estrellada",
		"description": "Oscuridad con fog denso",
		# AO
		"enable_ao": true,
		"ao_strength": 0.6,
		# Fog
		"enable_fog": true,
		"fog_color": Color(0.05, 0.05, 0.15, 1.0),  # Azul muy oscuro
		"fog_start": 10.0,
		"fog_end": 50.0,
		# Lighting
		"ambient_light": 0.15,
		"sun_intensity": 0.2  # Luna tenue
	},

	Preset.CAVE: {
		"name": "Cueva Oscura",
		"description": "Muy oscuro con AO intenso",
		# AO
		"enable_ao": true,
		"ao_strength": 0.8,
		# Fog
		"enable_fog": true,
		"fog_color": Color(0.0, 0.0, 0.0, 1.0),  # Negro total
		"fog_start": 2.0,
		"fog_end": 15.0,
		# Lighting
		"ambient_light": 0.05,
		"sun_intensity": 0.0  # Sin sol
	},

	Preset.FOGGY: {
		"name": "Niebla Densa",
		"description": "Fog muy denso (Silent Hill)",
		# AO
		"enable_ao": true,
		"ao_strength": 0.5,
		# Fog
		"enable_fog": true,
		"fog_color": Color(0.5, 0.5, 0.5, 1.0),  # Gris niebla
		"fog_start": 2.0,
		"fog_end": 20.0,
		# Lighting
		"ambient_light": 0.3,
		"sun_intensity": 0.4
	},

	Preset.DESERT_DAY: {
		"name": "Desierto Caluroso",
		"description": "Haze amarillento con calor",
		# AO
		"enable_ao": true,
		"ao_strength": 0.2,  # Menos AO (luz intensa)
		# Fog
		"enable_fog": true,
		"fog_color": Color(0.9, 0.8, 0.6, 1.0),  # Amarillo arena
		"fog_start": 30.0,
		"fog_end": 100.0,
		# Lighting
		"ambient_light": 0.8,
		"sun_intensity": 1.8  # Sol muy intenso
	},

	Preset.SNOW_STORM: {
		"name": "Tormenta de Nieve",
		"description": "Blanco intenso con fog denso",
		# AO
		"enable_ao": true,
		"ao_strength": 0.3,
		# Fog
		"enable_fog": true,
		"fog_color": Color(0.9, 0.9, 0.95, 1.0),  # Blanco nieve
		"fog_start": 5.0,
		"fog_end": 30.0,
		# Lighting
		"ambient_light": 0.6,
		"sun_intensity": 0.5
	},

	Preset.UNDERWATER: {
		"name": "Submarino",
		"description": "Efecto bajo el agua",
		# AO
		"enable_ao": true,
		"ao_strength": 0.5,
		# Fog
		"enable_fog": true,
		"fog_color": Color(0.1, 0.3, 0.5, 1.0),  # Azul profundo
		"fog_start": 5.0,
		"fog_end": 25.0,
		# Lighting
		"ambient_light": 0.4,
		"sun_intensity": 0.6
	}
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# API PÚBLICA
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Aplica un preset a un material de shader
## @param material ShaderMaterial al que aplicar el preset
## @param preset Preset a aplicar
static func apply_preset(material: ShaderMaterial, preset: Preset) -> void:
	if not material or not material.shader:
		push_error("ShaderPresets: Material inválido o sin shader")
		return

	if not PRESET_CONFIGS.has(preset):
		push_error("ShaderPresets: Preset %d no existe" % preset)
		return

	var config = PRESET_CONFIGS[preset]

	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# APLICAR PARÁMETROS DE AO
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	material.set_shader_parameter("enable_ao", config.get("enable_ao", true))
	material.set_shader_parameter("ao_strength", config.get("ao_strength", 0.4))

	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# APLICAR PARÁMETROS DE FOG
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	material.set_shader_parameter("enable_fog", config.get("enable_fog", true))
	material.set_shader_parameter("fog_color", config.get("fog_color", Color.WHITE))
	material.set_shader_parameter("fog_start", config.get("fog_start", 10.0))
	material.set_shader_parameter("fog_end", config.get("fog_end", 80.0))

	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	# APLICAR PARÁMETROS DE ILUMINACIÓN
	# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	material.set_shader_parameter("ambient_light", config.get("ambient_light", 0.6))
	material.set_shader_parameter("sun_intensity", config.get("sun_intensity", 1.0))

	print("✅ ShaderPresets: Aplicado preset '%s'" % config.get("name", "Unknown"))


## Aplica un preset a todos los chunks de un ChunkManager
## @param chunk_manager ChunkManager que contiene los chunks
## @param preset Preset a aplicar
static func apply_preset_to_all_chunks(chunk_manager: Node, preset: Preset) -> void:
	if not chunk_manager:
		push_error("ShaderPresets: ChunkManager inválido")
		return

	var chunks_updated = 0

	for child in chunk_manager.get_children():
		if child is Chunk:
			var chunk: Chunk = child
			if chunk.mesh_instance:
				var material = chunk.mesh_instance.get_surface_override_material(0)
				if material is ShaderMaterial:
					apply_preset(material, preset)
					chunks_updated += 1

	var preset_name = PRESET_CONFIGS[preset].get("name", "Unknown")
	print("✅ ShaderPresets: Aplicado '%s' a %d chunks" % [preset_name, chunks_updated])


## Obtiene la configuración de un preset
## @param preset Preset del que obtener configuración
## @return Dictionary con la configuración completa
static func get_preset_config(preset: Preset) -> Dictionary:
	if PRESET_CONFIGS.has(preset):
		return PRESET_CONFIGS[preset]
	return {}


## Obtiene el nombre de un preset
## @param preset Preset del que obtener nombre
## @return String con el nombre del preset
static func get_preset_name(preset: Preset) -> String:
	var config = get_preset_config(preset)
	return config.get("name", "Unknown")


## Obtiene la descripción de un preset
## @param preset Preset del que obtener descripción
## @return String con la descripción del preset
static func get_preset_description(preset: Preset) -> String:
	var config = get_preset_config(preset)
	return config.get("description", "")


## Obtiene todos los presets disponibles
## @return Array de nombres de presets
static func get_all_preset_names() -> Array[String]:
	var names: Array[String] = []
	for preset in Preset.values():
		if preset != Preset.CUSTOM:
			names.append(get_preset_name(preset))
	return names


## Aplica parámetros custom a un material
## @param material ShaderMaterial al que aplicar
## @param params Dictionary con parámetros custom
static func apply_custom_params(material: ShaderMaterial, params: Dictionary) -> void:
	if not material or not material.shader:
		push_error("ShaderPresets: Material inválido")
		return

	# Aplicar cada parámetro que esté en el dictionary
	for key in params.keys():
		material.set_shader_parameter(key, params[key])

	print("✅ ShaderPresets: Aplicados %d parámetros custom" % params.size())


## Interpola entre dos presets (transición suave)
## @param material ShaderMaterial al que aplicar
## @param from_preset Preset inicial
## @param to_preset Preset final
## @param weight Factor de interpolación (0.0 = from, 1.0 = to)
static func lerp_presets(material: ShaderMaterial, from_preset: Preset, to_preset: Preset, weight: float) -> void:
	if not material or not material.shader:
		push_error("ShaderPresets: Material inválido")
		return

	var config_from = get_preset_config(from_preset)
	var config_to = get_preset_config(to_preset)

	if config_from.is_empty() or config_to.is_empty():
		push_error("ShaderPresets: Presets inválidos para lerp")
		return

	# Interpolar fog_color
	var fog_from: Color = config_from.get("fog_color", Color.WHITE)
	var fog_to: Color = config_to.get("fog_color", Color.WHITE)
	material.set_shader_parameter("fog_color", fog_from.lerp(fog_to, weight))

	# Interpolar valores float
	var params_to_lerp = [
		"ao_strength",
		"fog_start",
		"fog_end",
		"ambient_light",
		"sun_intensity"
	]

	for param in params_to_lerp:
		var value_from = config_from.get(param, 0.0)
		var value_to = config_to.get(param, 0.0)
		var lerped_value = lerpf(value_from, value_to, weight)
		material.set_shader_parameter(param, lerped_value)

	# Booleans se aplican del preset destino cuando weight > 0.5
	if weight > 0.5:
		material.set_shader_parameter("enable_ao", config_to.get("enable_ao", true))
		material.set_shader_parameter("enable_fog", config_to.get("enable_fog", true))
	else:
		material.set_shader_parameter("enable_ao", config_from.get("enable_ao", true))
		material.set_shader_parameter("enable_fog", config_from.get("enable_fog", true))


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# UTILIDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Imprime todos los presets disponibles con sus configuraciones
static func print_all_presets() -> void:
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("  SHADER PRESETS DISPONIBLES")
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

	for preset in Preset.values():
		if preset == Preset.CUSTOM:
			continue

		var config = get_preset_config(preset)
		print("\n🎨 %s (%d)" % [config.get("name", ""), preset])
		print("   %s" % config.get("description", ""))
		print("   AO: %s (strength: %.2f)" % [config.get("enable_ao"), config.get("ao_strength")])
		print("   Fog: %s (start: %.1f, end: %.1f)" % [
			config.get("enable_fog"),
			config.get("fog_start"),
			config.get("fog_end")
		])
		print("   Light: ambient=%.2f, sun=%.2f" % [
			config.get("ambient_light"),
			config.get("sun_intensity")
		])

	print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")


## Obtiene el preset actual de un material (aproximación)
## @param material ShaderMaterial a analizar
## @return Preset que más se parece, o CUSTOM si no coincide
static func detect_current_preset(material: ShaderMaterial) -> Preset:
	if not material or not material.shader:
		return Preset.CUSTOM

	# Obtener parámetros actuales
	var current_fog_color: Color = material.get_shader_parameter("fog_color")
	var current_fog_start: float = material.get_shader_parameter("fog_start")
	var current_ambient: float = material.get_shader_parameter("ambient_light")

	# Comparar con cada preset
	for preset in Preset.values():
		if preset == Preset.CUSTOM:
			continue

		var config = get_preset_config(preset)
		var preset_fog: Color = config.get("fog_color", Color.WHITE)
		var preset_start: float = config.get("fog_start", 10.0)
		var preset_ambient: float = config.get("ambient_light", 0.6)

		# Tolerancia para comparación
		var color_match = current_fog_color.is_equal_approx(preset_fog)
		var start_match = abs(current_fog_start - preset_start) < 1.0
		var ambient_match = abs(current_ambient - preset_ambient) < 0.05

		if color_match and start_match and ambient_match:
			return preset

	return Preset.CUSTOM
