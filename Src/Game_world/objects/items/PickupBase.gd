extends  Area2D
class_name PickupBase

@export var item_id: String
@export var display_name: String
@export var icon: Sprite2D
@export var label: Label 

var player_inside := false

func _ready() -> void:
	label.text = display_name
	label.visible = false

func _process(delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("interact"):
		pickup()

func pickup() -> void:
	queue_free()
