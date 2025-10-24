# ============================================================================
# AchievementUI.gd - Manager de UI de Logros
# ============================================================================
# Autoload que gestiona notificaciones y panel de logros
# ============================================================================

extends CanvasLayer

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# COMPONENTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var achievement_panel: AchievementPanel
var notification_container: Control

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROPIEDADES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Cola de logros pendientes de mostrar
var notification_queue: Array[Dictionary] = []

## ¿Hay una notificación mostrándose actualmente?
var is_showing_notification: bool = false

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS GODOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func _ready() -> void:
	# Crear contenedor para notificaciones
	notification_container = Control.new()
	notification_container.name = "NotificationContainer"
	notification_container.anchors_preset = Control.PRESET_FULL_RECT
	notification_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(notification_container)

	# Crear panel de logros
	achievement_panel = AchievementPanel.new()
	achievement_panel.name = "AchievementPanel"
	add_child(achievement_panel)

	# Conectar señal del sistema de logros
	AchievementSystem.achievement_unlocked.connect(_on_achievement_unlocked)

	print("🎨 AchievementUI inicializado")


func _process(_delta: float) -> void:
	# Procesar cola de notificaciones
	if not is_showing_notification and notification_queue.size() > 0:
		_show_next_notification()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MÉTODOS PRIVADOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Callback cuando se desbloquea un logro
func _on_achievement_unlocked(achievement_id: String, achievement_data: Dictionary) -> void:
	# Agregar a cola
	notification_queue.append({
		"id": achievement_id,
		"data": achievement_data
	})


## Muestra la siguiente notificación de la cola
func _show_next_notification() -> void:
	if notification_queue.is_empty():
		return

	var notification_data = notification_queue.pop_front()
	is_showing_notification = true

	# Crear notificación
	var notif = AchievementNotification.new()
	notification_container.add_child(notif)

	# Mostrar logro
	notif.show_achievement(notification_data.id, notification_data.data)

	# Esperar a que termine y marcar como no mostrando
	await get_tree().create_timer(5.0).timeout
	is_showing_notification = false
