extends CanvasLayer

@onready var Yaroslava: Node = $Yaroslava
@onready var Hubi: Node = $Hubi
@onready var Volk: Node = $Volk

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.update_hero_ui.connect(_on_hero_ui_updated)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_menu() -> void:
	visible = true

func hide_menu() -> void:
	visible = false

func _on_hero_ui_updated(progress: Dictionary):
	print(progress)


func _on_hubi_button_pressed() -> void:
	Volk.visible = false
	Yaroslava.visible = false
	Hubi.visible = true

func _on_yaroslava_button_pressed() -> void:
	Volk.visible = false
	Yaroslava.visible = true
	Hubi.visible = false
	
func _on_volk_button_pressed() -> void:
	Volk.visible = true
	Yaroslava.visible = false
	Hubi.visible = false
