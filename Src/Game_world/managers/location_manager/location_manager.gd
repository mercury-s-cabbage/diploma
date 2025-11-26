extends Node

''' Мэнеджер отвечает за бесшовную подгрузку локаций по мере прохождения игроком контента'''

# Список всех локаций с координатами
var locations_data = []
var area_size = Vector2(600, 600) # Размер видимой области вокруг игрока
var active_locations := [] # Список тех локаций, которые реально подгружены

func _ready():
	load_locations_from_json("res://Src/Game_world/managers/location_manager/locations.json")
	# Пример использования: получить локации вокруг игрока

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
func get_locations_in_area(area_pos: Vector2, area_size: Vector2) -> Array:
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

func update_player_position(player_pos: Vector2) -> void:
	# Рассчитываем область интереса вокруг игрока
	var area_pos = player_pos - area_size / 2  # Центрируем область вокруг игрока
	var need_locations = get_locations_in_area(area_pos, area_size)
	
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
	# Здесь код загрузки сцены, например:
	var scene = load(loc["scene_path"]).instantiate()
	add_child(scene)
	scene.position = Vector2(loc["position"][0], loc["position"][1])
	# Можно хранить ссылку на инстанс, если нужно освободить его при выгрузке

# Выгружаем локацию (пример, доработайте под вашу архитектуру)
func _unload_location(loc):
	# Здесь освобождаем сцену, например ищем её по координатам/имени
	for child in get_children():
		if child.position == Vector2(loc["position"][0], loc["position"][1]):
			child.queue_free()
