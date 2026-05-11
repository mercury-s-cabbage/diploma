extends Node2D

@onready var image: Sprite2D = $Img3075
var img2: Texture2D = preload("res://Src/Game_world/environment/decor/images/IMG_3076.PNG")

var player_in_zone := false

func _process(_delta: float) -> void:
	if player_in_zone and Input.is_action_just_pressed("Interact"):
		image.texture = img2

func _on_interaction_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_zone = true

func _on_interaction_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_zone = false
