extends Node

var saves_path: String = "res://Src/Game_world/managers/hero_manager/Saves/"
var current_save_path: String
var coords_data: Dictionary = {}

var world: Node2D
var player: Node2D

var player_scene = preload("res://Src/Game_world/objects/characters/knife/the_knife_2d.tscn")
const Utils = preload("res://Src/Game_world/managers/utils.gd")

func _ready() -> void:
	EventBus.set_save.connect(_on_save_setted)
	EventBus.save_game.connect(_on_game_saved)
	EventBus.save_created.connect(_on_save_created)

func _on_save_setted(save_id: String):
	current_save_path = saves_path + "save_" + save_id + ".json"
	coords_data = Utils.load_from_json(current_save_path)

	var coords: Vector2
	if coords_data.has("x") and coords_data.has("y"):
		coords = Vector2(coords_data["x"], coords_data["y"])
	else:
		coords = Vector2.ZERO

	if is_instance_valid(player):
		player.queue_free()
		player = null

	player = player_scene.instantiate()
	world.add_child(player)
	player.global_position = coords
	player.position_changed.connect(LocationLoader.update_world_request)

func _on_game_saved():
	coords_data["x"] = player.global_position.x
	coords_data["y"] = player.global_position.y
	Utils.save_to_json(current_save_path, coords_data)

func _on_save_created(save_id: String, current_save_id: String) -> void:
	var from_path := saves_path.path_join("save_%s.json" % current_save_id)
	var to_path := saves_path.path_join("save_%s.json" % save_id)
	var err := DirAccess.copy_absolute(from_path, to_path)
	if err != OK:
		push_error("Failed to copy save: %s -> %s, error %d" % [from_path, to_path, err])	

func set_world(world_node: Node2D):
	world = world_node
