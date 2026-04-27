extends Node

var locations_data_path = "res://Src/Game_world/managers/location_manager/locations/"

const Utils = preload("res://Src/Game_world/managers/utils.gd")

# id: путь
var pending_loads: Dictionary = {}

func _ready() -> void:
	EventBus.load_location.connect(_load_loc)
	EventBus.save_created.connect(_on_save_created)

func _process(delta: float) -> void:
	var finished = [] # чтобы позже удалить из ожидания
	for loc_id in pending_loads:
		var scene_path = pending_loads[loc_id]
		var status = ResourceLoader.load_threaded_get_status(scene_path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			EventBus.location_loaded.emit(loc_id, scene_path)
			finished.append(loc_id)	
		elif status == ResourceLoader.THREAD_LOAD_FAILED:
			finished.append(loc_id)
	for loc_id in finished:
		pending_loads.erase(loc_id)

func _load_loc(loc_id: String, save_id: String): 
	if loc_id not in pending_loads:
		var location_data = Utils.load_from_json(locations_data_path + loc_id + "/location_data.json") 
			
		var scene_path = location_data["SB_1"]
		if not ResourceLoader.exists(scene_path):
			push_error("Сцена не найдена: " + scene_path)
			return ""
		
		ResourceLoader.load_threaded_request(scene_path)
		pending_loads[loc_id] = scene_path

func _on_save_created(save_id: String, current_save_id: String):
	var dir = DirAccess.open(locations_data_path)
	if dir == null:
		push_error("Не удалось открыть папку локаций: " + locations_data_path)
		return

	for loc_id in DirAccess.get_directories_at(locations_data_path):
		var saves_dir = locations_data_path.path_join(loc_id).path_join("saves")
		var source_path = saves_dir.path_join("save_%s.json" % current_save_id)
		var target_path = saves_dir.path_join("save_%s.json" % save_id)

		DirAccess.make_dir_recursive_absolute(saves_dir)

		if not FileAccess.file_exists(source_path):
			push_warning("Нет исходного сейва для копирования: " + source_path)
			continue

		var source_text = FileAccess.get_file_as_string(source_path)
		var source_data = JSON.parse_string(source_text)

		if source_data == null:
			push_warning("Не удалось распарсить JSON: " + source_path)
			continue

		var target_file = FileAccess.open(target_path, FileAccess.WRITE)
		if target_file == null:
			push_error("Не удалось создать файл: " + target_path)
			continue

		target_file.store_string(JSON.stringify(source_data, "\t"))
		target_file.close()
