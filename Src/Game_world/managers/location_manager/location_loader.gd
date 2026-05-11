extends Node

const Utils = preload("res://Src/Game_world/managers/utils.gd")

var locations_data_file := "res://Src/Game_world/managers/location_manager/locations_data.json"
var locations_data: Array = []

var current_save_id := "0"
var world: Node2D = null

var load_area_size := Vector2(5000, 5000)
var unload_area_size := Vector2(4000, 4000)

# локации, загрузки которых мы ждем
var pending_loads: Dictionary = {}
# уже загруженные локации id: instance
var current_locations: Dictionary = {}

func _ready() -> void:
	#EventBus.create_save_request.connect(_on_save_created)
	EventBus.save_game_request.connect(_save_current_locations)
	locations_data = Utils.load_from_json(locations_data_file).get("locations", [])

# постоянно проверяем, не загрузились ли локации, которые мы ждем
func _process(_delta: float) -> void:
	var finished: Array = []

	for loc_id in pending_loads:
		var scene_path = pending_loads[loc_id]
		var status = ResourceLoader.load_threaded_get_status(scene_path)
		if status == ResourceLoader.THREAD_LOAD_LOADED or status == ResourceLoader.THREAD_LOAD_FAILED:
			finished.append(loc_id)
			initiate_location(loc_id, scene_path)
	for loc_id in finished:
		pending_loads.erase(loc_id)

func set_world(world_node: Node2D) -> void:
	world = world_node

func set_progress(progress: Dictionary) -> void:
	current_save_id = progress["save_id"]
	update_current_locations([])

# Обновляет список инстанцированных локаций
func update_current_locations(new_locations_ids: Array) -> void:
	var to_remove: Array = []

	for loc_id in current_locations.keys():
		if loc_id not in new_locations_ids:
			to_remove.append(loc_id)

	for loc_id in to_remove:
		var loc_instance = current_locations[loc_id]
		if is_instance_valid(loc_instance):
			loc_instance.queue_free()
		current_locations.erase(loc_id)

	for loc_id in new_locations_ids:
		if loc_id not in current_locations:
			_load_loc(loc_id, current_save_id)
			
func get_progress():
	return {"save_id": current_save_id}

func _get_location_info(loc_id: String) -> Dictionary:
	for loc in locations_data:
		if loc["id"] == loc_id:
			return loc
	return {}
	
func _load_loc(loc_id: String, _save_id: String) -> void:
	if loc_id in pending_loads:
		return

	var location_info = _get_location_info(loc_id)
	if location_info.is_empty():
		push_error("Не найдена информация о локации: " + loc_id)
		return

	var scene_path: String = location_info.get("scene_path", "")
	if scene_path.is_empty():
		push_error("Не задан путь к сцене для локации: " + loc_id)
		return

	if not ResourceLoader.exists(scene_path):
		push_error("Сцена не найдена: " + scene_path)
		return

	ResourceLoader.load_threaded_request(scene_path)
	pending_loads[loc_id] = scene_path

func initiate_location(loc_id: String, scene_path: String) -> void:
	var scene = ResourceLoader.load_threaded_get(scene_path)
	if scene == null:
		push_error("Не удалось загрузить сцену: " + scene_path)
		return

	var instance = scene.instantiate()
	instance.setup_state_file(current_save_id)

	var loc_info = _get_location_info(loc_id)
	if not loc_info.is_empty():
		instance.position = Vector2(loc_info["coords"][0], loc_info["coords"][1])

	world.add_child(instance)
	current_locations[loc_id] = instance

func _save_current_locations() -> void:
	print("_save_current_locations()")
	for loc_id in current_locations.keys():
		EventBus.save_location.emit(loc_id)

func update_world_request(player_pos: Vector2) -> void:
	var load_zone = get_locations_in_area(player_pos, load_area_size)
	var unload_zone = get_locations_in_area(player_pos, unload_area_size)
	var new_locs = find_current_locations(load_zone, unload_zone)
	update_current_locations(new_locs)

func find_current_locations(load_zone: Array, unload_zone: Array) -> Array:
	var new_ids: Array = current_locations.keys()

	for loc_id in load_zone:
		if loc_id not in new_ids:
			new_ids.append(loc_id)

	for loc_id in new_ids.duplicate():
		if loc_id not in load_zone and loc_id not in unload_zone:
			new_ids.erase(loc_id)

	return new_ids

func get_locations_in_area(player_pos: Vector2, area_size: Vector2) -> Array:
	var result: Array = []
	var player_rect = Rect2(player_pos - area_size / 2, area_size)

	for loc in locations_data:
		var loc_coords = Vector2(loc["coords"][0], loc["coords"][1])
		var loc_size = Vector2(loc["size"][0], loc["size"][1])
		var loc_rect = Rect2(loc_coords, loc_size)

		if player_rect.intersects(loc_rect):
			result.append(loc["id"])

	return result


	

	
