extends Resource

var location_data_file = "res://Src/Game_world/managers/location_manager/locations/loc_004/location_data_004.json"
var location_data = {}

func load_loc() -> String:  # ← Node вместо PackedScene
	location_data = load_from_json(location_data_file) 
	if not location_data is Dictionary or not location_data.has("SB_1"):
		push_error("location_data недоступен или нет ключа 'SB_1': ", location_data)
		return ""
		
	var scene_path = location_data["SB_1"]["bg"]
	if not ResourceLoader.exists(scene_path):
		push_error("Сцена не найдена: " + scene_path)
		return ""
		
	ResourceLoader.load_threaded_request(scene_path)
	return scene_path

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
