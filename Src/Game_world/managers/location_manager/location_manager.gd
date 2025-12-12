extends Node

''' Мэнеджер отвечает за бесшовную подгрузку локаций по мере прохождения игроком контента'''

# Список всех локаций с координатами
var locations_data = []
var area_size = Vector2(600, 600) # Размер видимой области вокруг игрока
var active_locations := [] # Список тех локаций, которые реально подгружены
var world: Node2D = null # Контейнер, куда будут добавляться локации

@onready var tile_container: Node2D

func _ready():
	load_locations_from_json("res://Src/Game_world/managers/location_manager/locations.json")
	


func set_world(world_node: Node2D) -> void:
	world = world_node

# предварительная загрузка списка локаций из файла
func load_locations_from_json(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		var data = JSON.parse_string(text)
		if typeof(data) == TYPE_DICTIONARY and data.has("locations"):
			locations_data = data["locations"]
		else:
			push_error("JSON-файл локаций имеет неверный формат")
	else:
		push_error("Файл локаций не найден или не может быть открыт: " + path)

# принимает позицию игрока и размер области интереса, возвращает все локации, которые в нее попадают
func get_locations_in_area(area_pos: Vector2) -> Array:
	var result = []
	for loc in locations_data:
		var loc_pos = Vector2(loc["position"][0], loc["position"][1])
		var loc_size = Vector2(loc["size"][0], loc["size"][1])
		if rects_intersect(area_pos, area_size, loc_pos, loc_size):
			result.append(loc)
	return result

# считает, пересекаются ли на карте две области
func rects_intersect(pos1, size1, pos2, size2) -> bool:
	return (pos1.x < pos2.x + size2.x and
			pos1.x + size1.x > pos2.x and
			pos1.y < pos2.y + size2.y and
			pos1.y + size1.y > pos2.y)

# НОВОЕ: Находит локацию по мировым координатам игрока из сохранения
func get_location_by_world_pos(world_pos: Vector2) -> Dictionary:
	var closest_loc = null
	var min_dist = INF
	
	# Ищем ближайшую локацию к позиции из сохранения
	for loc in locations_data:
		var loc_pos = Vector2(loc["position"][0], loc["position"][1])
		var loc_size = Vector2(loc["size"][0], loc["size"][1])
		
		# Проверяем, находится ли позиция внутри локации
		if rects_intersect(world_pos, Vector2(1,1), loc_pos, loc_size):
			var dist = world_pos.distance_to(loc_pos + loc_size / 2)
			if dist < min_dist:
				min_dist = dist
				closest_loc = loc
	
	# Если не нашли точную - берём ближайшую
	if not closest_loc and locations_data.size() > 0:
		closest_loc = locations_data[0]
	
	return {
		"location": closest_loc,
		"world_pos": world_pos,
		"is_valid": closest_loc != null
	}

# НОВОЕ: Загружает игрока из сохранения по пути к файлу
func load_player_from_save(save_path: String) -> Dictionary:
	var file = FileAccess.open(save_path, FileAccess.READ)
	if not file:
		push_error("Файл сохранения не найден: " + save_path)
		return {}
	
	var text = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(text)
	if typeof(data) == TYPE_DICTIONARY and data.has("player_position"):
		var pos = Vector2(data["player_position"][0], data["player_position"][1])
		return get_location_by_world_pos(pos)
	
	push_error("В файле сохранения нет player_position")
	return {}

# НОВОЕ: Инициализация мира с загрузкой стартовой локации
func initialize_world_from_save(save_path: String) -> Vector2:
	var spawn_data = load_player_from_save(save_path)
	
	if spawn_data.is_valid and spawn_data.location:
		# Загружаем стартовую локацию первой
		_load_location(spawn_data.location)
		active_locations.append(spawn_data.location)
		
		# Обновляем область вокруг стартовой позиции
		#update_player_position(spawn_data.world_pos)
		return spawn_data.world_pos
	
	# Fallback: первая локация
	if locations_data.size() > 0:
		_load_location(locations_data[0])
		active_locations.append(locations_data[0])
		return Vector2(locations_data[0]["position"][0], locations_data[0]["position"][1])
	
	return Vector2.ZERO

func update_player_position(player_pos: Vector2) -> void:
	# Рассчитываем область интереса вокруг игрока
	var area_pos = player_pos - area_size / 2  # Центрируем область вокруг игрока
	var need_locations = get_locations_in_area(area_pos)
	
	# Список имен уже активных локаций для проверки
	var current_names = []
	for loc in active_locations:
		current_names.append(loc["name"])
	
	# Подгружаем новые локации
	for loc in need_locations:
		if loc["name"] not in current_names:
			_load_location(loc)
			active_locations.append(loc)
	
	# Выгружаем ушедшие локации
	for loc in active_locations.duplicate():
		if loc not in need_locations:
			_unload_location(loc)
			active_locations.erase(loc)

# Загружаем локацию (пример, нужно доработать под вашу архитектуру)
func _load_location(loc):
	var scene = load(loc["scene_path"]).instantiate()
	world.add_child(scene)
	scene.position = Vector2(loc["position"][0], loc["position"][1])

# Выгружаем локацию 
func _unload_location(loc):
	for child in get_children():
		if child.position == Vector2(loc["position"][0], loc["position"][1]):
			child.queue_free()
