extends Node

@export var StoryBeat: int
var current_triggers: Array

var default_sb_file: String = "res://Src/Game_world/managers/plot_manager/sb_triggers_default.json"
var sb_info: Dictionary

func _ready() -> void:
	sb_info = load_from_json(default_sb_file)
	StoryBeat = define_current_sb()
	current_triggers = sb_info[str(StoryBeat+1)]["depends"]
	EventBus.quest_ended.connect(_on_quest_ended)

func _process(delta: float) -> void:
	pass

func define_current_sb() -> int:
	for sb in sb_info.keys():
		if sb_info[sb]["status"] == 1:
			return int(sb)
	return 0
	
func _on_quest_ended(quest_id: String):
	if quest_id not in current_triggers:
		pass
	else:
		var change_sb = 1
		for q in current_triggers:
			if QuestManager.progress[q]["status"] != 2:
				change_sb = 0
				break
		if change_sb:
			change_sb(StoryBeat+1)

func change_sb(new_sb: int):
	sb_info[str(StoryBeat)]["status"] = 2
	StoryBeat = new_sb
	sb_info[str(new_sb)]["status"] = 1
	
func load_from_json(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		var data = JSON.parse_string(text)
		if typeof(data) == TYPE_DICTIONARY:
			return data
		else:
			push_error("JSON-файл локаций имеет неверный формат")
	else:
		push_error("The location file was not found or could not be opened: " + path)
	return []
