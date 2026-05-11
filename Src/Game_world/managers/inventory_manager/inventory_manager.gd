extends Node

const Utils = preload("res://Src/Game_world/managers/utils.gd")

#@export var saves_path: String = "res://Src/Game_world/managers/inventory_manager/inventory_list/"
#var current_save_path: String
var inventory_list: Dictionary 

func _ready() -> void:
	EventBus.item_acquired.connect(_on_item_acquired)

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

func set_progress(progress: Dictionary):
	inventory_list = progress
	EventBus.update_inventory_ui.emit(inventory_list)

func get_progress():
	return inventory_list
		
