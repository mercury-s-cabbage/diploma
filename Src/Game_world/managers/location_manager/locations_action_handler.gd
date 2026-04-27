extends Resource

var current_save_id = "0"

func _ready() -> void:
	EventBus.set_save.connect(_on_save_setted)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_save_setted():
	pass
