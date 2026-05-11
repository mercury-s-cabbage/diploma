extends Node

var diary_state = {}
const Utils = preload("res://Src/Game_world/managers/utils.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.diary_update.connect(_on_diary_update)

# Считает количество найденных знаний по конкретной теме
func get_topic_poins(topic: String) -> int:
	return 10
	
func set_progress(progress: Dictionary):
	diary_state = progress
	EventBus.update_diary_ui.emit(diary_state)

func get_progress():
	return diary_state

# Делает активным новое знание
func _on_diary_update(topic: String, id: String):
	diary_state[topic][id] = true
	EventBus.update_diary_ui.emit(diary_state)
