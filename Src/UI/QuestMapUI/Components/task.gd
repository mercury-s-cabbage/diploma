extends Control

@export var quest_name: String = "Название квеста"
@export_multiline() var main_text: String = "Общее описание квеста"
@export_multiline() var step_text: String = "Шаг квеста"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/MarginContainer2/main_text.text = main_text
	$VBoxContainer/MarginContainer3/add_text.text = step_text
	$VBoxContainer/MarginContainer/Name.text = quest_name


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass
	
func set_step_text(new_text: String):
	print(new_text)
	$VBoxContainer/MarginContainer3/add_text.text = new_text
