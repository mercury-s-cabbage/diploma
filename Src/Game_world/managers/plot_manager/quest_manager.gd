extends Node

@export var quests_directory: String = "res://Src/Game_world/managers/plot_manager/quests"
@export var progress_file_path: String = "res://Src/Game_world/managers/plot_manager/saves/save_"

var progress: Dictionary = {}
var current_save: String = "0"

const Utils = preload("res://Src/Game_world/managers/utils.gd")

var available_quests: Dictionary = {}
var active_quests: Dictionary = {}
var tracked_signals: Dictionary = {}

func _ready():
	EventBus.set_save.connect(_on_save_setted)
	EventBus.save_created.connect(_on_save_created)
	EventBus.save_game.connect(_on_game_saved)
	EventBus.area_entered.connect(_on_area_entered)
	EventBus.start_quest.connect(_on_start_quest)

func _on_save_setted(save_id: String):
	current_save = save_id
	load_quest_paths(quests_directory)
	progress = Utils.load_from_json(progress_file_path + save_id + ".json")
	normalize_progress()
	restore_active_quests_from_progress()
	EventBus.update_quest_ui.emit(progress)

func _on_save_created(curr_save_id: String, prev_save_id: String):
	var prev_path := progress_file_path + prev_save_id + ".json"
	var curr_path := progress_file_path + curr_save_id + ".json"

	var dir_path := progress_file_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)

	var err := DirAccess.copy_absolute(prev_path, curr_path)
	if err != OK:
		push_error("Failed to copy save file from %s to %s. Error: %s" % [prev_path, curr_path, err])
		return

	current_save = curr_save_id
	progress = Utils.load_from_json(curr_path)
	normalize_progress()
	restore_active_quests_from_progress()
	EventBus.update_quest_ui.emit(progress)

func _on_game_saved():
	if progress.is_empty():
		push_warning("Progress is empty, nothing to save.")
		return

	var save_path: String = progress_file_path + current_save + ".json"
	var dir_path := progress_file_path.get_base_dir()

	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)

	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open save file for writing: %s" % save_path)
		return

	file.store_string(JSON.stringify(progress, "\t"))
	file.close()

func normalize_progress():
	for quest_id in progress.keys():
		if typeof(progress[quest_id]) != TYPE_DICTIONARY:
			continue
		progress[quest_id]["status"] = int(progress[quest_id].get("status", 0))
		progress[quest_id]["current_step"] = int(progress[quest_id].get("current_step", 0))

func restore_active_quests_from_progress():
	active_quests.clear()
	tracked_signals.clear()

	for quest_id in progress.keys():
		var quest_progress: Dictionary = progress[quest_id]
		if int(quest_progress.get("status", 0)) != 1:
			continue
		if not available_quests.has(quest_id):
			continue

		var quest_data := load_quest_data(available_quests[quest_id])
		if quest_data.is_empty():
			continue

		active_quests[quest_id] = quest_data
		var step_id := int(quest_progress.get("current_step", 0))
		register_quest_signals(quest_data, step_id)

func load_quest_paths(dir_path: String):
	available_quests.clear()
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".json"):
				var quest_id = file_name.replace(".json", "")
				available_quests[quest_id] = dir_path + "/" + file_name
			file_name = dir.get_next()
		dir.list_dir_end()

func _on_start_quest(id: String):
	if active_quests.has(id):
		return
	if not available_quests.has(id):
		push_error("Quest not found: %s" % id)
		return
	if not progress.has(id):
		push_error("Progress not found for quest: %s" % id)
		return

	var quest_data = load_quest_data(available_quests[id])
	if quest_data.is_empty():
		return

	active_quests[id] = quest_data
	progress[id]["status"] = 1
	progress[id]["current_step"] = 0
	register_quest_signals(quest_data, 0)
	EventBus.quest_started.emit(id, quest_data)
	EventBus.update_quest_ui.emit(progress)

func load_quest_data(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open quest file: %s" % path)
		return {}

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("JSON Parse Error: %s" % json.get_error_message())
		return {}
	return json.data

func register_quest_signals(quest_data: Dictionary, step_id: int) -> void:
	var quest_id: String = str(quest_data["id"])
	var steps: Dictionary = quest_data.get("steps", {})

	remove_quest_signals(quest_id)

	if not steps.has(str(step_id)):
		push_error("Step not found: quest=%s step=%s" % [quest_id, str(step_id)])
		return

	var step_data: Dictionary = steps[str(step_id)]
	var signals_data: Dictionary = step_data.get("signals", {})

	for signal_name in signals_data.keys():
		var handler_name := "_on_%s" % signal_name
		if not tracked_signals.has(handler_name):
			tracked_signals[handler_name] = []

		for tracked_values in signals_data[signal_name]:
			tracked_signals[handler_name].append({
				"quest_id": quest_id,
				"values": tracked_values.duplicate()
			})

func remove_quest_signals(quest_id: String) -> void:
	for handler_name in tracked_signals.keys():
		var entries: Array = tracked_signals[handler_name]
		for i in range(entries.size() - 1, -1, -1):
			var entry = entries[i]
			if entry is Dictionary and str(entry.get("quest_id", "")) == quest_id:
				entries.remove_at(i)
		if entries.is_empty():
			tracked_signals.erase(handler_name)

func update_quest(quest_id: String):
	if not progress.has(quest_id) or not active_quests.has(quest_id):
		return

	var step_id := str(int(progress[quest_id]["current_step"]))
	if not progress[quest_id].has(step_id):
		return

	for sig in progress[quest_id][step_id].keys():
		for aim in progress[quest_id][step_id][sig].keys():
			if int(progress[quest_id][step_id][sig][aim]) == 0:
				return

	var new_step := int(progress[quest_id]["current_step"]) + 1
	progress[quest_id]["current_step"] = new_step

	if new_step >= int(active_quests[quest_id].get("k_steps", 0)):
		end_quest(quest_id)
		return

	register_quest_signals(active_quests[quest_id], new_step)
	EventBus.quest_step_changed.emit(quest_id, new_step)
	EventBus.update_quest_ui.emit(progress)

func end_quest(quest_id: String):
	remove_quest_signals(quest_id)
	progress[quest_id]["status"] = 2
	active_quests.erase(quest_id)
	EventBus.quest_ended.emit(quest_id)
	EventBus.update_quest_ui.emit(progress)
	_on_game_saved()

func _on_area_entered(zone_id: String):
	if not tracked_signals.has("_on_area_entered"):
		return

	var matched_quests: Array = []
	for quest in tracked_signals["_on_area_entered"]:
		var quest_id = quest["quest_id"]
		if not active_quests.has(quest_id):
			continue
		if quest["values"].size() > 0 and quest["values"][0] == zone_id:
			matched_quests.append(quest_id)

	for quest_id in matched_quests:
		var step_id := str(int(progress[quest_id]["current_step"]))
		if not progress[quest_id].has(step_id):
			continue
		progress[quest_id][step_id]["area_entered"][zone_id] = 1
		update_quest(quest_id)
