extends Node

var items: Dictionary[String, ItemData] = {}

func _ready():
	load_items()

func load_items() -> void:
	var paths := [
		"res://Src/Game_world/objects/items/branch.tres",
		"res://Src/Game_world/objects/items/coin.tres",
		"res://Src/Game_world/objects/items/blue_ribbon.tres",
		"res://Src/Game_world/objects/items/yellow_ribbon.tres",
		"res://Src/Game_world/objects/items/shagai.tres",
		"res://Src/Game_world/objects/items/thyme.tres",
		"res://Src/Game_world/objects/items/sable_skin.tres"
	]
	
	for path in paths:
		var item: ItemData = load(path)
		items[item.id] = item

func get_item_by_id(id: String) -> ItemData:
	return items.get(id, null)
