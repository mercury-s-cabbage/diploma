extends Button

@export var button_text: String
@export var save_id: String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$".".text = button_text


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	SaveManager.set_save(save_id)
	EventBus.toggle_ui_pause.emit(get_tree().get_first_node_in_group("pause_ui"))
