extends Node

var location_data_path = "res://Src/Game_world/managers/location_manager/locations/"
var location_data = {}

const Utils = preload("res://Src/Game_world/managers/utils.gd")

func _ready() -> void:
	pass
	#EventBus.set_save.connect(_on_save_setted)

func load_loc(loc_id: String, save_id: String) -> String: 
	
	location_data = Utils.load_from_json(location_data_path + loc_id) 
	
	if not location_data is Dictionary or not location_data.has("SB_1"):
		push_error("location_data недоступен или нет ключа 'SB_1': ", location_data)
		return ""
		
	var scene_path = location_data["SB_1"]["bg"]
	if not ResourceLoader.exists(scene_path):
		push_error("Сцена не найдена: " + scene_path)
		return ""
		
	ResourceLoader.load_threaded_request(scene_path)
	return scene_path
