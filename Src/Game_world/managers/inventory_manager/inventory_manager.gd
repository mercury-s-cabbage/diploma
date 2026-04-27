extends Node

const Utils = preload("res://Src/Game_world/managers/utils.gd")

@export var saves_path: String = "res://Src/Game_world/managers/inventory_manager/inventory_list/"
var current_save_path: String
var inventory_list: Dictionary 

func _ready() -> void:
	EventBus.item_acquired.connect(_on_item_acquired)
	EventBus.set_save.connect(_on_save_setted)
	EventBus.save_game.connect(_on_game_saved)
	EventBus.save_created.connect(_on_save_created)

func _on_save_setted(save_id: String):
	current_save_path = saves_path + "save_" + save_id + ".json"
	inventory_list = Utils.load_from_json(current_save_path)
	EventBus.update_inventory_ui.emit(inventory_list)
		
func _on_game_saved() -> void:
	Utils.save_to_json(current_save_path, inventory_list)

func _on_save_created(save_id: String, current_save_id: String) -> void:
	var from_path := saves_path.path_join("save_%s.json" % current_save_id)
	var to_path := saves_path.path_join("save_%s.json" % save_id)
	var err := DirAccess.copy_absolute(from_path, to_path)
	if err != OK:
		push_error("Failed to copy save: %s -> %s, error %d" % [from_path, to_path, err])	
	
func _on_item_acquired(item: ItemData, count: int, _instance_id) -> void:
	if inventory_list.has(item.id):
		inventory_list[item.id] += count
	else:
		inventory_list[item.id] = count
	
func _on_item_give_away(item_id: String, count: int) -> bool:
	if inventory_list[item_id] < count:
		return false
	else:
		inventory_list[item_id] -= count
		return true


		
