extends Button

@export var theme_id: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
		
func _on_pressed() -> void:
	EventBus.diary_theme_pressed.emit(theme_id)
