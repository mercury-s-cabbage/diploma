extends Node2D

class_name PickedItem

@export var item_count: int 
@export var item_name: String = ""
@export var item_id: String = ""

@onready var label: Label = $Label

var player_inside := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = item_name
	label.visible = false

func _process(delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("Interact"):
		pickup()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_inside = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_inside = false

func pickup() -> void:
	queue_free()
	EventBus.emit_signal("item_acquired", item_id, item_count)

func _on_area_2d_mouse_entered() -> void:
	if player_inside:
		label.visible = true
		
func _on_area_2d_mouse_exited() -> void:
	if player_inside:
		label.visible = false
