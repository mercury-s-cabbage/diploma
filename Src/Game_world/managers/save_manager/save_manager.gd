extends Node

var saves_list_path := "res://Src/Game_world/managers/save_manager/saves_list.json"
const Utils = preload("res://Src/Game_world/managers/utils.gd")
var saves_path := "res://Src/Game_world/managers/save_manager/saves/"

var saves_data: Dictionary = {}
var current_save: String = "0"

var managers_to_save: Dictionary = {
	"Locations": LocationLoader,
	"Inventory": InventoryManager,
	"PlayerData": PlayerManager,
	"QuestsProgress": QuestManager,
	"Diary": DiaryManager
}

var pending_save: Dictionary = {}
var expected_keys: Array = []
var save_in_progress := false

func _ready() -> void:
	EventBus.save_game_request.connect(_on_save_game_request)
	EventBus.create_save_request.connect(_on_create_save_request)
	EventBus.load_save_request.connect(_on_load_save_request)
	saves_data = Utils.load_from_json(saves_list_path)

func get_save_file() -> String:
	return saves_path + "save_" + current_save + ".json"
	
func _on_load_save_request(save_id: String) -> void:
	var load_file_path := saves_path + "save_" + save_id + ".json"
	var file := FileAccess.open(load_file_path, FileAccess.READ)
	if file == null:
		push_error("Can't open save file: %s" % load_file_path)
		return

	var parsed = JSON.parse_string(file.get_as_text())
	file.close()

	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Save file is not a Dictionary: %s" % load_file_path)
		return

	current_save = save_id

	for manager_name in managers_to_save:
		if parsed.has(manager_name):
			managers_to_save[manager_name].set_progress(parsed[manager_name])
		else:
			push_warning("Missing progress for manager: %s" % manager_name)
	
func _on_save_game_request() -> void:
	if save_in_progress:
		return
	save_in_progress = true
	pending_save.clear()
	expected_keys = managers_to_save.keys()

	for manager_name in managers_to_save:
		var info = managers_to_save[manager_name].get_progress()
		if info == null:
			_abort_save("No data from %s" % manager_name)
			return
		pending_save[manager_name] = info

	_finish_save()

func _finish_save() -> void:
	for key in expected_keys:
		if not pending_save.has(key):
			_abort_save("Missing save part: %s" % key)
			return

	var file_path := get_save_file()
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		_abort_save("Can't open file: %s" % file_path)
		return

	file.store_string(JSON.stringify(pending_save, "\t"))
	file.close()
	save_in_progress = false

func _abort_save(reason: String) -> void:
	push_error("Save failed: " + reason)
	pending_save.clear()
	save_in_progress = false

func _on_create_save_request() -> void:
	if not saves_data.has("ids"):
		saves_data["ids"] = []

	var ids: Array = saves_data["ids"]
	var new_save_id := 1
	ids.sort()

	for id in ids:
		var num_id := int(id)
		if num_id == new_save_id:
			new_save_id += 1
		elif num_id > new_save_id:
			break

	var new_save_id_str := str(new_save_id)
	var new_save_file := saves_path + "save_" + new_save_id_str + ".json"

	var current_save_file := get_save_file()
	var file := FileAccess.open(current_save_file, FileAccess.READ)
	if file == null:
		push_error("Can't open current save file: %s" % current_save_file)
		return

	var current_data_text := file.get_as_text()
	file.close()

	var new_file := FileAccess.open(new_save_file, FileAccess.WRITE)
	if new_file == null:
		push_error("Can't create new save file: %s" % new_save_file)
		return

	new_file.store_string(current_data_text)
	new_file.close()

	ids.append(new_save_id_str)
	ids.sort()
	Utils.save_to_json(saves_list_path, saves_data)

	current_save = new_save_id_str
