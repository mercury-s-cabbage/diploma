extends Node

var items: Dictionary[String, ItemData] = {}

func _ready():
	load_items()

func load_items() -> void:
	var paths := [
		"res://Src/Game_world/objects/items/branch.tres",
		"res://Src/Game_world/objects/items/coin.tres"
	]
	
	for path in paths:
		var item: ItemData = load(path)
		items[item.id] = item

func get_item_by_id(id: String) -> ItemData:
	return items.get(id, null)
