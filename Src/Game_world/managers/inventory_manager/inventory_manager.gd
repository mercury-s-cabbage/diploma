extends Node

const Utils = preload("res://Src/Game_world/managers/utils.gd")

@export var inventory_list_path: String = "res://Src/Game_world/managers/inventory_manager/inventory_list/save_default.json"
var inventory_list: Dictionary 

func _ready() -> void:
	EventBus.item_acquired.connect(_on_item_acquired)
	
func setup_save_file(path: String) -> void:
	inventory_list_path = path
	inventory_list = Utils.load_from_json(inventory_list_path)
	EventBus.inventory_changed.emit()
	
func save_data(path: String) -> void:
	Utils.save_to_json(path, inventory_list)

func _on_item_acquired(item: ItemData, count: int) -> void:
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


		
