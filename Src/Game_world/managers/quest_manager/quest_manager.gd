extends Node

var available_quests: Dictionary = {}  # id -> path/to/quest.json Все существующие квесты в игре
var active_quests: Dictionary = {}     # id -> QuestData (loaded) Квесты, которые игрок принял

signal quest_failed(quest_id: String)
signal quest_started(quest_id: String, quest_data: Dictionary)  # + данные!
signal quest_updated(quest_id: String, step_index: int, step_data: Dictionary)
signal quest_completed(quest_id: String, rewards: Dictionary)

@export var quests_directory: String = "res://Src/Game_world/managers/quest_manager/quests"

func _ready():
	load_quest_paths(quests_directory)
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
	print("Loaded %d quest paths" % available_quests.size())

func _on_start_quest(id: String):
	# загружаем данные нужного квеста
	var quest_path = available_quests[id]
	var quest_data = load_quest_data(quest_path)
	quest_data.current_step = 0
	quest_data.progress = {}
	
	# отправляем сигнал о том, что появился новый квест
	quest_started.emit(id, quest_data)
	print("start")
	
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

# пришел сигнал о разговоре с npc
func _on_npc_talk_accepted(npc_id: String, outcome: String):
	pass

func _on_item_acquired(item_id: String, count: int):
	for quest_id in active_quests:
		var quest = active_quests[quest_id]
		if advance_step(quest, {"type": "collect_item", "item_id": item_id, "count": count}):
			check_completion(quest_id)

func _on_area_entered(zone_id: String):
	for quest_id in active_quests:
		var quest = active_quests[quest_id]
		if advance_step(quest, {"type": "enter_zone", "zone_id": zone_id}):
			check_completion(quest_id)

func _on_enemy_killed(enemy_type: String):
	for quest_id in active_quests:
		var quest = active_quests[quest_id]
		if advance_step(quest, {"type": "kill_enemy", "enemy_type": enemy_type}):
			check_completion(quest_id)

func advance_step(quest: Dictionary, event: Dictionary) -> bool:
	var step = quest.steps[quest.current_step]
	if step.type == event.type:
		match step.type:
			"collect_item":
				if step.target.item_id == event.item_id:
					var current = quest.progress.get(step.id, 0)
					quest.progress[step.id] = current + event.count
					if quest.progress[step.id] >= step.target.required_count:
						return complete_step(quest)
			"enter_zone":
				if step.target.zone_id == event.zone_id:
					return complete_step(quest)
			"talk_npc":
				if step.target.npc_id == event.get("npc_id", ""):
					if event.outcome in step.target.success_dialog_outcomes:
						return complete_step(quest)
					elif event.outcome in step.target.fail_dialog_outcomes:
						fail_quest(quest.id)
						return false
	return false

func complete_step(quest: Dictionary) -> bool:
	var step = quest.steps[quest.current_step]
	apply_reward(step.reward)
	quest.current_step += 1
	quest_updated.emit(quest.id, quest.current_step - 1, 100)
	print("Completed step %d of quest %s" % [quest.current_step - 1, quest.id])
	return quest.current_step >= quest.steps.size()

func check_completion(quest_id: String):
	var quest = active_quests[quest_id]
	if quest.current_step >= quest.steps.size():
		complete_quest(quest_id)

func complete_quest(quest_id: String):
	var quest = active_quests[quest_id]
	apply_reward(quest.rewards)
	quest_completed.emit(quest_id, quest.rewards)
	active_quests.erase(quest_id)
	print("Completed quest: %s" % quest_id)

func fail_quest(quest_id: String):
	quest_failed.emit(quest_id)
	active_quests.erase(quest_id)
	print("Failed quest: %s" % quest_id)

func apply_reward(reward: Dictionary):
	if reward.has("xp"):
		pass
	if reward.has("gold"):
		pass
	if reward.has("items"):
		for item in reward.items:
			pass

# API для UI/сохранений
func get_quest_status(quest_id: String) -> Dictionary:
	if active_quests.has(quest_id):
		return {
			"id": quest_id,
			"status": "active",
			"current_step": active_quests[quest_id].current_step,
			"steps_count": active_quests[quest_id].steps.size(),
			"title": active_quests[quest_id].title
		}
	return {"id": quest_id, "status": "inactive"}

func save_state() -> Dictionary:
	var state = {}
	for quest_id in active_quests:
		state[quest_id] = {
			"current_step": active_quests[quest_id].current_step,
			"progress": active_quests[quest_id].progress
		}
	return state

func load_state(state: Dictionary):
	for quest_id in state:
		if available_quests.has(quest_id):
			var quest_data = load_quest_data(available_quests[quest_id])
			quest_data.current_step = state[quest_id].current_step
			quest_data.progress = state[quest_id].progress
			active_quests[quest_id] = quest_data
