extends Node2D

@onready var image: Sprite2D = $Img3077
var img2: Texture2D = preload("res://Src/Game_world/environment/decor/images/IMG_3078.PNG")

var player_in_zone := false

func _process(_delta: float) -> void:
	if player_in_zone and Input.is_action_just_pressed("Interact"):
		image.texture = img2

func _on_interaction_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_zone = false


func _on_interaction_zone_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("Player"):
		player_in_zone = true
