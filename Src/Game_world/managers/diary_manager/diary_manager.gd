extends Node

var current_save = "0"
var path_to_saves = "res://Src/Game_world/managers/diary_manager/saves/save_"
var diary_state = {}
const Utils = preload("res://Src/Game_world/managers/utils.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.diary_update.connect(_on_diary_update)
	EventBus.set_save.connect(_on_save_setted)
	EventBus.save_created.connect(_on_save_created)
	EventBus.save_game.connect(_on_game_saved)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_topic_poins(topic: String) -> int:
	if not diary_state.has(topic):
		return 0

	var topic_data = diary_state[topic]
	if typeof(topic_data) != TYPE_DICTIONARY:
		return 0

	var points := 0
	for id in topic_data.keys():
		if topic_data[id]:
			points += 1
	return points

func _on_diary_update(topic: String, id: String):
	print("update")
	diary_state[topic][id] = true
	
func _on_save_setted(save_id: String):
	current_save = save_id
	diary_state = Utils.load_from_json(path_to_saves + 	current_save + ".json")
	
func _on_game_saved():
	print(diary_state)
	Utils.save_to_json(path_to_saves + current_save + ".json", diary_state)
	
func _on_save_created(save_id: String, current_save_id: String) -> void:
	var from_path: String = path_to_saves + current_save + ".json"
	var to_path: String = path_to_saves + save_id + ".json"
	print()
	var err := DirAccess.copy_absolute(from_path, to_path)
	if err != OK:
		push_error("Failed to copy save: %s -> %s, error %d" % [from_path, to_path, err])	

	
