extends Node

var location_data_file = "res://Src/Game_world/managers/location_manager/locations/loc_1/location_data_001.json"
var current_state_file = "res://Src/Game_world/managers/location_manager/locations/loc_1/current_state_001.json"
var location_data = {}
var current_state = {}

func _ready() -> void:
	location_data = load_from_json(location_data_file) 
	current_state = load_from_json(current_state_file)

func _process(delta: float) -> void:
	pass

func load_loc() -> PackedScene:
	var scene_path = location_data["SB_1"]["bg"]
	var scene = load(scene_path) as PackedScene
	var instance = scene.instantiate()
	return instance
	
func unload_loc() -> void:
	pass
	
func load_from_json(path: String) -> Array:
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		var data = JSON.parse_string(text)
		if typeof(data) == TYPE_DICTIONARY:
			return data
	return []
