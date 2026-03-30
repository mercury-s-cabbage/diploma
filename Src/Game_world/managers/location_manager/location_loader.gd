extends Node

# данные всех менеджеров локаций
var data_path = "res://Src/Game_world/managers/location_manager/locations_data.json"
var locations_data = []

# квадратная область, пересечение которой выгружает или загружает локацию
var load_area_size = Vector2(600, 600)
var unload_area_size = Vector2(800, 800)

# инстансы менеджеров локаций
var world: Node2D = null
var current_locations: = {}

# при запуске загружаем данные локаций из json
func _ready() -> void:
	locations_data = load_locations_from_json(data_path)

# первоначальная загрузка данных о менеджерах скриптов из json
func load_locations_from_json(path: String) -> Array:
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		var data = JSON.parse_string(text)
		if typeof(data) == TYPE_DICTIONARY and data.has("locations"):
			return data["locations"]
		else:
			push_error("JSON-файл локаций имеет неверный формат")
	else:
		push_error("The location file was not found or could not be opened: " + path)
	return []

# получаем локации, которые своими координатами пересекаются с зоной area_size
func get_locations_in_area(player_pos: Vector2, area_size: Vector2) -> Array:
	var result = []
	# прямоугольник зоны вокруг игрока
	var player_rect = Rect2(
		player_pos - area_size / 2,  
		area_size)
	
	for loc in locations_data:
		var loc_coords = Vector2(loc["coords"][0], loc["coords"][1])
		var loc_size = Vector2(loc["size"][0], loc["size"][1])
		# прямоугольник локации
		var loc_rect = Rect2(loc_coords, loc_size)
		
		# если прямоугольники пересекаются — добавляем ID локации
		if player_rect.intersects(loc_rect):
			result.append(loc["id"])  # или loc.id, если поле называется id
	
	return result

# найти актуальный список СЦЕН локаций, которые должны быть инстанцированы 
func find_current_locations(load_zone: Array, unload_zone: Array) -> Array:
	var new_ids: Array = current_locations.keys()
	
	# убираем все, что вышло из зоны отгрузки
	for loc_id in unload_zone:
		var idx = new_ids.find(loc_id)
		if idx != -1:
			new_ids.remove_at(idx)

	# грузим все, что зашло в зону загрузки
	for loc_id in load_zone:
		if loc_id not in new_ids:
			new_ids.append(loc_id)
	
	return new_ids

# возвращает инстанс менеджера локации
func get_location_instance(loc_id: String) -> Node:
	# уже есть — просто вернуть
	if current_locations.has(loc_id):
		return current_locations[loc_id]
	
	var loc_data: Dictionary = {}
	for loc in locations_data:
		if loc["id"] == loc_id:
			loc_data = loc
			break
			
	if loc_data.is_empty():
		push_error("Location data not found for id: %s" % loc_id)
		return null

	# грузим скрипт/сцену по loc_path
	var res = load(loc_data["loc_path"])
	if res == null:
		push_error("Cannot load location resource: %s" % loc_data["loc_path"])
		return null

	var instance = null
	
	if res is Script:
		instance = res.new()
	else:
		push_error("Unsupported location resource type for: %s" % loc_data["loc_path"])
		return null
	current_locations[loc_id] = instance

	return instance

# проходит по всем текущим локациям. Загружает незагруженные, неиспользуемые - отгружает
func update_current_locations(new_locations_ids:  Array):
	for loc_id in current_locations:
		if loc_id not in new_locations_ids:
			var loc_instance = current_locations[loc_id]
			if loc_instance.has_method("unload_loc"):
				loc_instance.unload_loc()

				
	for loc_id in new_locations_ids:
		if loc_id not in current_locations:
			# создаем инстанс менеджера локации
			var loc_instance = get_location_instance(loc_id)
			if loc_instance and loc_instance.has_method("load_loc"):
				var scene = loc_instance.load_loc()
				print("scene = ", scene)
				world.add_child(scene)

func set_world(world_node: Node2D) -> void:
	world = world_node
	
func update_world_request(player_pos: Vector2):
	var load_zone = get_locations_in_area(player_pos, load_area_size)
	var unload_zone = get_locations_in_area(player_pos, unload_area_size)
	var new_locs = find_current_locations(load_zone, unload_zone)
	update_current_locations(new_locs)
	
