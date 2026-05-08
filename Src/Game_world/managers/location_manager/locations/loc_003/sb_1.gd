extends Node2D

var current_state_file: String = ""
var save_path = "res://Src/Game_world/managers/location_manager/locations/loc_003/saves/"
var current_state = {}

@onready var dialogue_1 = $Area2D

const Utils = preload("res://Src/Game_world/managers/utils.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.save_location.connect(_save_location)
	current_state = Utils.load_from_json(save_path + "/" + current_state_file)
	if current_state.dialogues["1"] == false:
		dialogue_1.queue_free()


func setup_state_file(save_id: String) -> void:
	current_state_file = "save_%s.json" % save_id
	
func _save_location(loc_id):
	if loc_id == "loc_003":
		var data_path = save_path + "/" + current_state_file
		Utils.save_to_json(data_path, current_state)

func _on_area_2d_body_entered(body: Node2D) -> void:
	var baloon = preload("res://addons/dialogue_manager/user_balloons/balloon.tscn")
	DialogueManager.show_dialogue_balloon_scene(baloon, load("res://Src/Game_world/dialogues.dialogue"))
