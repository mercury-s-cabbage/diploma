extends Node

@export var quests_directory: String = "res://Src/Game_world/managers/quest_manager/quests"
@export var progress_file: String = "res://Src/Game_world/managers/quest_manager/progress.json"
var progress: Dictionary

var available_quests: Dictionary = {}  # id -> path/to/quest.json Все существующие квесты в игре
var active_quests: Dictionary = {}     # id -> QuestData (loaded) Квесты, которые игрок принял
var tracked_signals: Dictionary = {} # сигналы, которые отслеживаются квестами в данный момент
# tracked_signals:
# {
#   "_on_npc_talked": [
#       {"quest_id": "001", "values": ["steve", "accept"]},
#       {"quest_id": "002", "values": ["bob", "refuse"]}
#   ]
# }



func _ready():
	load_quest_paths(quests_directory)
	progress = load_from_json(progress_file)
	# подключаем сигналы, которые будут триггерить квесты
	EventBus.npc_talk_accepted.connect(_on_npc_talk_accepted)
	EventBus.item_acquired.connect(_on_item_acquired)
	EventBus.area_entered.connect(_on_area_entered)
	EventBus.enemy_killed.connect(_on_enemy_killed)
	EventBus.start_quest.connect(_on_start_quest)

# при загрузке создаем словарь id квеста -> путь к нему
func load_quest_paths(dir_path: String):
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

# пришел сигнал-запрос на запуск квеста
func _on_start_quest(id: String):
	# загружаем данные нужного квеста
	var quest_path = available_quests[id]
	var quest_data = load_quest_data(quest_path)
	quest_data.current_step = 0
	quest_data.progress = {}
	
	register_quest_signals(quest_data, 0)
	# отправляем сигнал о том, что был загружен новый квест
	progress[id]["status"] = 1
	active_quests[id] = quest_data
	EventBus.quest_started.emit(id, quest_data)

func register_quest_signals(quest_data: Dictionary, step_id: int) -> void:
	if not quest_data.has("id") or not quest_data.has("steps"):
		return

	var quest_id: String = str(quest_data["id"])
	var steps: Dictionary = quest_data["steps"]
	
	remove_quest_signals(quest_id)

	if not steps.has(str(step_id)):
		return

	var step_data: Dictionary = steps[str(step_id)]
	if not step_data.has("signals"):
		return

	var signals_data: Dictionary = step_data["signals"]

	for signal_name in signals_data.keys():
		var handler_name := "_on_%s" % signal_name

		if not tracked_signals.has(handler_name):
			tracked_signals[handler_name] = []
		
		for tracked_values in signals_data[signal_name]:
			var entry := {
				"quest_id": quest_id,
				"values": tracked_values.duplicate()
			}

			tracked_signals[handler_name].append(entry)

# удаляет все отслеживания сигналов для квеста с quest_id
func remove_quest_signals(quest_id: String) -> void:
	for handler_name in tracked_signals.keys():
		var entries: Array = tracked_signals[handler_name]
		for i in range(entries.size() - 1, -1, -1):
			var entry = entries[i]
			if entry is Dictionary and str(entry.get("quest_id", "")) == quest_id:
				entries.remove_at(i)
		if entries.is_empty():
			tracked_signals.erase(handler_name)
			
# загружаем квест из json-файла по требованию
func load_quest_data(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("JSON Parse Error: %s" % json.get_error_message())
		return {}
	return json.data	

func end_quest(quest_id: String):
	remove_quest_signals(quest_id)
	progress[quest_id]["status"] = 2
	active_quests.erase(quest_id)
	# TODO: на этом месте надо сохранять прогресс
	print("end quest ", quest_id)
	
	
		
func update_quest(quest_id: String):
	var step = str(int(progress[quest_id]["current_step"]))
	for sig in (progress[quest_id][step]):
		for aim in progress[quest_id][step][sig]:
			if progress[quest_id][step][sig][aim] == 0:
				return
	var new_step = progress[quest_id]["current_step"] + 1
	progress[quest_id]["current_step"] = new_step
	if new_step == active_quests[quest_id]["k_steps"]:
		end_quest(quest_id)
		return
	register_quest_signals(active_quests[quest_id], new_step)
	print("step changed: ", new_step)
	
	
func _on_area_entered(zone_id: String):
	if "_on_area_entered" in tracked_signals.keys():
		for quest in tracked_signals["_on_area_entered"]:
			var quest_id = quest["quest_id"]
			if quest["values"][0] == zone_id:
				var step = str(int(progress[quest_id]["current_step"]))
				print("aimed ", zone_id)
				progress[quest_id][step]["area_entered"][zone_id] = 1
				update_quest(quest_id)
			

# пришел сигнал о разговоре с npc
func _on_npc_talk_accepted(npc_id: String, outcome: String):
	pass

func _on_item_acquired(item_id: String, count: int):
	pass



func _on_enemy_killed(enemy_type: String):
	pass

func complete_step(quest: Dictionary) -> bool:
	return 0

func complete_quest(quest_id: String):
	pass

func load_state(state: Dictionary):
	pass

func load_from_json(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		var data = JSON.parse_string(text)
		if typeof(data) == TYPE_DICTIONARY:
			return data
		else:
			push_error("JSON-файл имеет неверный формат")
	else:
		push_error("The file was not found or could not be opened: " + path)
	return []
