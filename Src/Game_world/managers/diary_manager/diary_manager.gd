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

# Считает количество найденных знаний по конкретной теме
func get_topic_poins(topic: String) -> int:
	return 10

# Делает активным новое знание
func _on_diary_update(topic: String, id: String):
	diary_state[topic][id] = true
	EventBus.update_diary_ui.emit(diary_state)

# Создает новый файл сохранения
func _on_save_setted(save_id: String):
	current_save = save_id
	diary_state = Utils.load_from_json(path_to_saves + 	current_save + ".json")
	EventBus.update_diary_ui.emit(diary_state)

# Сохраняет в файл все, что игрок узнал
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

	
