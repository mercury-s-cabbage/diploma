extends Node2D
class_name LocationBase

var location_id: String
var save_path: String = ""
var current_state_file: String = ""
var current_state: Dictionary = {}

const Utils = preload("res://Src/Game_world/managers/utils.gd")

func _ready() -> void:
	_connect_signals()
	_setup_location()
	_load_state()
	_apply_loaded_state()

# Присоединение к сигналам
func _connect_signals() -> void:
	EventBus.save_location.connect(_on_save_location)
	EventBus.item_acquired.connect(_on_item_acquired)

# Установка location_id и save_path
func _setup_location() -> void:
	pass

# Устанавливается менеджером при загрузке
func setup_state_file(save_id: String) -> void:
	current_state_file = "save_%s.json" % save_id

func set_location_id(id: String) -> void:
	location_id = id

func set_save_path(path: String) -> void:
	save_path = path

func _load_state() -> void:
	if current_state_file.is_empty():
		current_state = {}
		return

	var data_path := "%s/%s" % [save_path, current_state_file]
	current_state = Utils.load_from_json(data_path)

	if current_state.is_empty():
		current_state = _create_default_state()

func _create_default_state() -> Dictionary:
	return {}

func _apply_loaded_state() -> void:
	pass

func _on_item_acquired(_item: ItemData, _count: int, instance_id: String) -> void:
	if current_state.has("picked_items") and current_state.picked_items.has(instance_id):
		current_state.picked_items[instance_id] = false

func _on_save_location(loc_id: String) -> void:
	if loc_id != location_id:
		return

	var data_path := "%s/%s" % [save_path, current_state_file]
	Utils.save_to_json(data_path, current_state)
