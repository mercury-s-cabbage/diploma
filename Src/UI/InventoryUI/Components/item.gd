extends PanelContainer

@onready var item_box = $"."

@onready var normal_box: StyleBox = get_theme_stylebox("panel").duplicate()
@onready var focus_box: StyleBox = preload("res://Src/UI/Res/focus_box_texture.tres")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_mouse_entered() -> void:
	add_theme_stylebox_override("panel", focus_box)


func _on_mouse_exited() -> void:
	add_theme_stylebox_override("panel", normal_box)


func _on_gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pass
