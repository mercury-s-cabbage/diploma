extends Node

# данные всех менеджеров локаций: id, coords, size, path
var data_path = "res://Src/Game_world/managers/location_manager/locations_managers.json"
var locations_managers_data = [] 

# квадратная область, пересечение которой выгружает или загружает локацию
var load_area_size = Vector2(2000, 2000)
var unload_area_size = Vector2(3000, 3000)

var world: Node2D = null
# id: Node
var current_locations: = {}

# id: путь
var pending_loads: Dictionary = {}

# при запуске загружаем данные локаций из json
func _ready() -> void:
	locations_managers_data = load_locations_from_json(data_path)

# в _process отслеживаем, не загрузились ли инстансы локаций в их менеджеров
func _process(delta: float) -> void:
	var finished = [] # чтобы позже удалить из ожидания
	for loc_id in pending_loads:
		var scene_path = pending_loads[loc_id]
		var status = ResourceLoader.load_threaded_get_status(scene_path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var scene = ResourceLoader.load_threaded_get(scene_path)
			var instance = scene.instantiate()
			world.add_child(instance)
			current_locations[loc_id] = instance  
			finished.append(loc_id)
			
		elif status == ResourceLoader.THREAD_LOAD_FAILED:
			print("Failed to load: ", scene_path)
			finished.append(loc_id)
			
	for loc_id in finished:
		pending_loads.erase(loc_id)

# ОСНОВНАЯ ФУНКЦИЯ!! Срабатывает на изменения позиции игрока
func update_world_request(player_pos: Vector2):
	# получаем список id локаций в ближайшей зоне (загрузки)
	var load_zone = get_locations_in_area(player_pos, load_area_size)
	# получаем список id локаций в дальней зоне (отгрузки)
	var unload_zone = get_locations_in_area(player_pos, unload_area_size)
	# с учетом этого считаем, какие локации должны быть загружены сейчас
	var new_locs = find_current_locations(load_zone, unload_zone)
	update_current_locations(new_locs)

# найти актуальный список СЦЕН локаций, которые должны быть инстанцированы 
func find_current_locations(load_zone: Array, unload_zone: Array) -> Array:
	# позже изменим на актуальный список
	var new_ids: Array = current_locations.keys()
	
	for loc_id in load_zone:
		if loc_id not in new_ids:
			new_ids.append(loc_id)
	
	for loc_id in new_ids:
		if loc_id not in load_zone and loc_id not in unload_zone:
			var idx = new_ids.find(loc_id)
			new_ids.remove_at(idx)
	
	return new_ids
	
# проходит по всем текущим локациям. Загружает незагруженные, неиспользуемые - отгружает
func update_current_locations(new_locations_ids:  Array):
	for loc_id in current_locations:
		if loc_id not in new_locations_ids:
			var loc_instance = current_locations[loc_id]
			if is_instance_valid(loc_instance):
				loc_instance.queue_free()
				current_locations.erase(loc_id)
				
	for loc_id in new_locations_ids:
		if loc_id not in current_locations:
			var res
			for loc in locations_managers_data:
				if loc["id"] == loc_id:
					res = load(loc["loc_path"])
					break
			var loc_instance = res.new()
			if loc_instance and loc_instance.has_method("load_loc"):
				var scene_path = loc_instance.load_loc()
				if scene_path:
					pending_loads[loc_id] = scene_path
					
# получаем локации, которые своими координатами пересекаются с зоной area_size
func get_locations_in_area(player_pos: Vector2, area_size: Vector2) -> Array:
	var result = []
	# прямоугольник зоны вокруг игрока
	var player_rect = Rect2(
		player_pos - area_size / 2,  
		area_size)
	
	for loc in locations_managers_data:
		var loc_coords = Vector2(loc["coords"][0], loc["coords"][1])
		var loc_size = Vector2(loc["size"][0], loc["size"][1])
		# прямоугольник локации
		var loc_rect = Rect2(loc_coords, loc_size)
		
		# если прямоугольники пересекаются — добавляем ID локации
		if player_rect.intersects(loc_rect):
			result.append(loc["id"])  # или loc.id, если поле называется id
	
	return result
	
func set_world(world_node: Node2D) -> void:
	world = world_node
	
# первоначальная загрузка данных о менеджерах скриптов из json
func load_locations_from_json(path: String) -> Array:
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		var data = JSON.parse_string(text)
		if typeof(data) == TYPE_DICTIONARY and data.has("locations_managers"):
			return data["locations_managers"]
		else:
			push_error("JSON-файл локаций имеет неверный формат")
	else:
		push_error("The location file was not found or could not be opened: " + path)
	return []
	
