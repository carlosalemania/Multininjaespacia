# ============================================================================
# Constants.gd - Constantes Globales del Juego
# ============================================================================
# Archivo con todas las constantes usadas en Multi Ninja Espacial
# ============================================================================

extends Node
class_name Constants

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MUNDO Y BLOQUES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Tamaño de cada chunk (en bloques)
const CHUNK_SIZE: int = 10

## Altura máxima del mundo (en bloques)
const MAX_WORLD_HEIGHT: int = 30

## Tamaño de cada bloque individual (en unidades de Godot)
const BLOCK_SIZE: float = 1.0

## Mundo inicial (en chunks)
const WORLD_SIZE_CHUNKS: int = 10  # 10x10 chunks = 100x100 bloques

## Distancia de renderizado (en chunks)
const RENDER_DISTANCE: int = 3  # Renderiza 3 chunks alrededor del jugador

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# JUGADOR
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Velocidad de movimiento del jugador (unidades/segundo)
const PLAYER_SPEED: float = 5.0

## Velocidad de sprint (multiplicador)
const PLAYER_SPRINT_MULTIPLIER: float = 1.5

## Fuerza de salto
const JUMP_FORCE: float = 8.0

## Gravedad (unidades/segundo²)
const GRAVITY: float = 30.0

## Sensibilidad del mouse (grados/pixel)
const MOUSE_SENSITIVITY: float = 0.1

## Altura del jugador (para spawn inicial)
const PLAYER_SPAWN_HEIGHT: float = 50.0

## Alcance para interactuar con bloques (metros)
const INTERACTION_RANGE: float = 5.0

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# INVENTARIO
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Número de slots en el inventario
const INVENTORY_SIZE: int = 9

## Stack máximo por slot
const MAX_STACK_SIZE: int = 99

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SISTEMA DE LUZ INTERIOR (VIRTUDES)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Luz inicial al crear partida nueva
const STARTING_LUZ: int = 0

## Luz máxima acumulable
const MAX_LUZ: int = 1000

## Luz por construir 10 bloques seguidos
const LUZ_POR_CONSTRUCCION: int = 5

## Luz por recolectar 20 recursos
const LUZ_POR_RECOLECCION: int = 3

## Luz por minuto de juego (sin trampa)
const LUZ_POR_MINUTO: int = 2

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# GUARDADO
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Clave para LocalStorage
const SAVE_KEY: String = "multininjaespacial_save_v1"

## Intervalo de auto-guardado (segundos)
const AUTO_SAVE_INTERVAL: float = 120.0  # 2 minutos

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# AUDIO
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Volumen por defecto de música (0.0 - 1.0)
const DEFAULT_MUSIC_VOLUME: float = 0.5

## Volumen por defecto de SFX (0.0 - 1.0)
const DEFAULT_SFX_VOLUME: float = 0.7

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# UI
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Duración de mensajes de tutorial (segundos)
const TUTORIAL_MESSAGE_DURATION: float = 10.0

## Tiempo de fade de notificaciones (segundos)
const NOTIFICATION_FADE_TIME: float = 0.5

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# GENERACIÓN DE TERRENO
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Semilla para generación procedural (0 = aleatoria)
const TERRAIN_SEED: int = 0

## Escala del ruido Perlin (afecta tamaño de colinas)
const NOISE_SCALE: float = 0.1

## Altura base del terreno (en bloques)
const BASE_TERRAIN_HEIGHT: int = 10

## Amplitud de las colinas (en bloques)
const HILL_AMPLITUDE: int = 5

## Número de árboles a generar
const TREE_COUNT: int = 8

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# OPTIMIZACIÓN WEB
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## FPS objetivo
const TARGET_FPS: int = 60

## Activar VSync
const VSYNC_ENABLED: bool = true

## Uso de threads para generación de chunks (desactivado en web)
const USE_THREADS: bool = false
