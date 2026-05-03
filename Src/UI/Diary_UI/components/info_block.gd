extends PanelContainer

@export_multiline var info_text: String
@export var capture: String
@export var box_style: StyleBoxTexture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/MarginContainer/info_text.text = info_text
	$VBoxContainer/MarginContainer2/caption.text = capture
	add_theme_stylebox_override("panel", box_style)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
