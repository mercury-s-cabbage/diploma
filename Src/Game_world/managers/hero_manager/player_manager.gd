extends Node

var coords: Vector2 = Vector2.ZERO
var coords_path: String = ""
var coords_data = {}
var world: Node2D
var player: Node2D

const Utils = preload("res://Src/Game_world/managers/utils.gd")

func setup_save_file(path: String) -> void:
	coords_path = path
	coords_data = Utils.load_from_json(coords_path)

	if coords_data.has("x") and coords_data.has("y"):
		coords = Vector2(coords_data["x"], coords_data["y"])
	else:
		coords = Vector2.ZERO

func set_world(world_node: Node2D) -> void:
	world = world_node

func spawn_player(player_scene: PackedScene) -> Node2D:
	if world == null:
		push_error("World is not set")
		return null

	player = player_scene.instantiate()
	world.add_child(player)
	player.global_position = coords
	return player

func save_data(path: String) -> void:
	if player == null:
		push_error("Player is not set")
		return

	var data := {
		"x": player.global_position.x,
		"y": player.global_position.y
	}
	Utils.save_to_json(path, data)
