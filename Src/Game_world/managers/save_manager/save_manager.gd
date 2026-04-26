extends Node

var saves_list_path = "res://Src/Game_world/managers/save_manager/saves_list.json"
const Utils = preload("res://Src/Game_world/managers/utils.gd")

var paths_to_save: Dictionary = {
	"InventoryManager": "res://Src/Game_world/managers/inventory_manager/inventory_list/",
	"PlayerManager": "res://Src/Game_world/managers/hero_manager/Saves/"
}

var saves_list: Array = []
@export var current_save: int = 0
@onready var inventory_manager: Node = get_node_or_null("../InventoryManager")
@onready var player_manager: Node = get_node_or_null("../PlayerManager")

func _ready() -> void:
	saves_list = Utils.load_from_json(saves_list_path).ids
	
func save_game():
	var base_path: String = paths_to_save.get("InventoryManager", "")
	var save_path: String = base_path + "save_%d.json" % current_save
	inventory_manager.save_data(save_path)

func create_save(source_save_id: int) -> void:
	var existing_ids: Array[int] = []
	for s in saves_list:
		existing_ids.append(int(s))
	existing_ids.sort()

	var new_save_id := 1
	for id in existing_ids:
		if id == new_save_id:
			new_save_id += 1
		elif id > new_save_id:
			break

	var saves_data: Dictionary = Utils.load_from_json(saves_list_path)
	saves_data.ids.append(str(new_save_id))
	Utils.save_to_json(saves_list_path, saves_data)
	current_save = new_save_id

	for save_name in paths_to_save.keys():
		var base_path: String = paths_to_save.get(save_name, "")
		var new_save_path: String = base_path + "save_%d.json" % current_save
		var source_path: String = base_path + "save_%s.json" % source_save_id

		var source_data = Utils.load_from_json(source_path)
		Utils.save_to_json(new_save_path, source_data)
		

func set_save(save_id: int):
	current_save = save_id
	load_save(inventory_manager, "InventoryManager")
	load_save(player_manager, "PlayerManager")

func load_save(manager: Node, manager_name: String):
	var base_path: String = paths_to_save.get(manager_name, "")
	var save_path: String = base_path + "save_%d.json" % current_save
	manager.setup_save_file(save_path)
