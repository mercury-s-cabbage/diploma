extends Node

var saves_list_path = "res://Src/Game_world/managers/save_manager/saves_list.json"
const Utils = preload("res://Src/Game_world/managers/utils.gd")

var saves_data: Dictionary = {}
var current_save: String = "0"

func _ready() -> void:
	saves_data = Utils.load_from_json(saves_list_path)
	
func save_game():
	EventBus.save_game.emit()

func create_save(source_save_id: String):
	# подбираем свободный номер сохранения
	saves_data.ids.sort()
	var new_save_id := 1
	for id in saves_data.ids:
		if int(id) == new_save_id:
			new_save_id += 1
		elif int(id) > new_save_id:
			break
			
	saves_data.ids.append(str(new_save_id))
	Utils.save_to_json(saves_list_path, saves_data)
	EventBus.save_created.emit(str(new_save_id), current_save)
	current_save = str(new_save_id)
	EventBus.set_save.emit(current_save)

# заменяет текущий файл для сохранения на другой
func set_save(save_id: String):
	current_save = save_id
	EventBus.set_save.emit(save_id)

# вносит изменения в отображение согласно новым файлам сохранений
func load_save(manager: Node, manager_name: String):
	EventBus.load_save.emit()
