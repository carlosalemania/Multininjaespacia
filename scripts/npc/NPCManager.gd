# ============================================================================
# NPCManager.gd - Gestor de NPCs y Diálogos
# ============================================================================
# Gestiona spawn de NPCs y UI de diálogos
# ============================================================================

extends Node3D
class_name NPCManager

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ESCENAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const NPC_SCENE = preload("res://scenes/npc/NPC.tscn")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Lista de NPCs spawneados
var spawned_npcs: Array[NPC] = []

## UI de diálogo
var dialogue_ui: DialogueUI

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	# Crear UI de diálogo
	_create_dialogue_ui()

	print("🧍 NPCManager inicializado")


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PÚBLICOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Spawnea un NPC en una posición
func spawn_npc(npc_type: NPCData.NPCType, position: Vector3, can_wander: bool = false) -> NPC:
	var npc_instance = NPC_SCENE.instantiate() as NPC
	npc_instance.npc_type = npc_type
	npc_instance.can_wander = can_wander
	npc_instance.global_position = position

	add_child(npc_instance)
	spawned_npcs.append(npc_instance)

	# Conectar señal de interacción
	npc_instance.npc_interacted.connect(_on_npc_interacted)

	print("✅ NPC spawneado: ", NPCData.get_npc_name(npc_type), " en ", position)

	return npc_instance


## Spawnea 3 NPCs iniciales en el mundo
func spawn_initial_npcs(player_position: Vector3) -> void:
	# Calcular posiciones alrededor del jugador
	var offset_distance = 10.0

	# NPC 1: Anciano (al frente)
	var elder_pos = player_position + Vector3(0, 0, offset_distance)
	spawn_npc(NPCData.NPCType.ELDER, elder_pos, false)

	# NPC 2: Constructor (a la derecha)
	var builder_pos = player_position + Vector3(offset_distance, 0, 0)
	spawn_npc(NPCData.NPCType.BUILDER, builder_pos, true)

	# NPC 3: Minera (a la izquierda)
	var miner_pos = player_position + Vector3(-offset_distance, 0, 0)
	spawn_npc(NPCData.NPCType.MINER, miner_pos, true)

	print("🎉 3 NPCs iniciales spawneados alrededor del jugador")


## Obtiene todos los NPCs spawneados
func get_all_npcs() -> Array[NPC]:
	return spawned_npcs.duplicate()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PRIVADOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Crea la UI de diálogo
func _create_dialogue_ui() -> void:
	dialogue_ui = DialogueUI.new()
	dialogue_ui.name = "DialogueUI"

	# Buscar el nodo CanvasLayer más cercano o crearlo
	var canvas_layer = get_tree().root.get_node_or_null("GameWorld/CanvasLayer")
	if not canvas_layer:
		canvas_layer = CanvasLayer.new()
		canvas_layer.name = "UILayer"
		get_tree().root.add_child(canvas_layer)

	canvas_layer.add_child(dialogue_ui)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SEÑALES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Callback cuando un NPC es interactuado
func _on_npc_interacted(npc: NPC) -> void:
	if dialogue_ui:
		dialogue_ui.show_dialogue(npc)
