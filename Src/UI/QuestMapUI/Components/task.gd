extends Control

@export var quest_name: String = "Название квеста"
@export_multiline() var main_text: String = "Общее описание квеста"
@export_multiline() var step_text: String = "Шаг квеста"
@export var box_theme: StyleBoxTexture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%main_text.text = main_text
	%add_text.text = step_text
	%Name.text = quest_name
	$".".add_theme_stylebox_override("panel", box_theme)
	$".".reset_size()

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass
	
func set_step_text(new_text: String):
	print(new_text)
	%add_text.text = new_text
