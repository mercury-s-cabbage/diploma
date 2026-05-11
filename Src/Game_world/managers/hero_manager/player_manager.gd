extends Node

var coords_data: Dictionary = {}

var world: Node2D
var player: Node2D

var player_scene = preload("res://Src/Game_world/objects/characters/knife/the_knife_2d.tscn")
const Utils = preload("res://Src/Game_world/managers/utils.gd")

func _ready() -> void:
	pass

func set_world(world_node: Node2D):
	world = world_node
	
func set_progress(progress: Dictionary):
	coords_data = progress
	
	var coords: Vector2
	if coords_data.has("x") and coords_data.has("y"):
		coords = Vector2(coords_data["x"], coords_data["y"])
	else:
		coords = Vector2.ZERO
		
	if is_instance_valid(player):
		player.queue_free()
		player = null
#
	player = player_scene.instantiate()
	world.add_child(player)
	player.global_position = coords
	player.position_changed.connect(LocationLoader.update_world_request)

func get_progress():
	if is_instance_valid(player):
		coords_data["x"] = player.global_position.x
		coords_data["y"] = player.global_position.y
	return coords_data
