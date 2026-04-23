extends PanelContainer

@onready var item_box = $"."

@onready var normal_box: StyleBox = get_theme_stylebox("panel").duplicate()
@onready var focus_box: StyleBox = preload("res://Src/UI/Res/Textures/focus_box_texture.tres")

@export var item_name: String = "Таинственный предмет"
@export var count: int = 1
@export var price: int = 0
@export var icon: CompressedTexture2D 

func _ready() -> void:
	$HBoxContainer/Control/HBoxContainer/Price.text = str(price)
	$HBoxContainer/Control/HBoxContainer/Quantity.text = str(count)
	$HBoxContainer/MarginContainer/Name.text = name
	$HBoxContainer/MarginContainer2/TextureRect.texture = icon

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
