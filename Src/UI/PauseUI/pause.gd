extends CanvasLayer

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func show_menu() -> void:
	visible = true

func hide_menu() -> void:
	visible = false
