extends Node

const Utils = preload("res://Src/Game_world/managers/utils.gd")
var current_save_id = "0"

# данные всех менеджеров локаций: id, coords, size, path
var data_path = "res://Src/Game_world/managers/location_manager/locations_data.json"
var locations_data = [] 

# квадратная область, пересечение которой выгружает или загружает локацию
var load_area_size = Vector2(5000, 5000)
var unload_area_size = Vector2(4000, 4000)

var world: Node2D = null
# id: Node
var current_locations: = {}

# при запуске загружаем данные локаций из json
func _ready() -> void:
	EventBus.set_save.connect(_on_save_setted)
	EventBus.location_loaded.connect(_initiate_location)
	EventBus.save_game.connect(_save_current_locations)
	locations_data = Utils.load_from_json(data_path)["locations_managers"]

# в _process отслеживаем, не загрузились ли инстансы локаций в их менеджеров
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass

func _initiate_location(loc_id: String, scene_path: String):
	var scene = ResourceLoader.load_threaded_get(scene_path)
	var instance = scene.instantiate()
	instance.setup_state_file(current_save_id)
			
	for loc in locations_data:
		if loc["id"] == loc_id:
			instance.position = Vector2(loc["coords"][0], loc["coords"][1])
			break
					
	world.add_child(instance)
	current_locations[loc_id] = instance

func _save_current_locations():
	for loc_id in current_locations:
		EventBus.save_location.emit(loc_id)

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
func update_current_locations(new_locations_ids: Array):
	var to_remove: Array = []

	for loc_id in current_locations.keys():
		if loc_id not in new_locations_ids:
			to_remove.append(loc_id)

	for loc_id in to_remove:
		var loc_instance = current_locations[loc_id]
		if is_instance_valid(loc_instance):
			#EventBus.save_location.emit(loc_id)
			EventBus.save_game.emit()
			loc_instance.queue_free()
		current_locations.erase(loc_id)

	for loc_id in new_locations_ids:
		if loc_id not in current_locations:
			for loc in locations_data:
				if loc["id"] == loc_id:
					EventBus.load_location.emit(loc_id, current_save_id)
					break
					
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
	
func set_world(world_node: Node2D) -> void:
	world = world_node

func _on_save_setted(save_id: String):
	current_save_id = save_id
	update_current_locations([])

	
		
		

	

	
