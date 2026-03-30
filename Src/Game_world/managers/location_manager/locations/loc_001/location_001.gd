extends Node

var location_data_file = "res://Src/Game_world/managers/location_manager/locations/loc_001/location_data_001.json"
var current_state_file = "res://Src/Game_world/managers/location_manager/locations/loc_001/current_state_001.json"
var location_data = {}
var current_state = {}
var scene_node: Node = null

func load_loc() -> Node:  # ← Node вместо PackedScene
	location_data = load_from_json(location_data_file) 
	current_state = load_from_json(current_state_file)
	if not location_data is Dictionary or not location_data.has("SB_1"):
		push_error("location_data недоступен или нет ключа 'SB_1': ", location_data)
		return null
		
	var scene_path = location_data["SB_1"]["bg"]
	if not ResourceLoader.exists(scene_path):
		push_error("Сцена не найдена: " + scene_path)
		return null
		
	var scene = load(scene_path) as PackedScene
	var instance = scene.instantiate()
	
	scene_node = instance
	return instance

func load_from_json(path: String) -> Dictionary:  # ← Dictionary!
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Не удалось открыть файл: " + path)
		return {}
		
	var text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(text)
	
	if parse_result == OK and json.data is Dictionary:
		return json.data as Dictionary
	else:
		push_error("Ошибка JSON в %s: %s" % [path, json.get_error_message()])
		return {}

func unload_loc() -> void:
		if scene_node and scene_node.is_inside_tree():
			scene_node.queue_free()  # удаляем из world
			scene_node = null
	
