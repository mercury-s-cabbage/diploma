extends Node

var saves_list_path = "res://Src/Game_world/managers/save_manager/saves_list.json"
const Utils = preload("res://Src/Game_world/managers/utils.gd")

var paths_to_save: Dictionary = {
	"InventoryManager": "res://Src/Game_world/managers/inventory_manager/inventory_list/"
}

var saves_list: Array = []
@export var current_save: int = 0
@onready var inventory_manager: Node = get_node_or_null("../InventoryManager")

func _ready() -> void:
	saves_list = Utils.load_from_json(saves_list_path).ids
	
func save_game():
	var base_path: String = paths_to_save.get("InventoryManager", "")
	var save_path: String = base_path + "save_%d.json" % current_save
	inventory_manager.save_data(save_path)

func create_save(source_save_id: String) -> void:
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
	if not saves_data.has("ids"):
		saves_data["ids"] = {}

	saves_data["ids"][str(new_save_id)] = true
	Utils.save_to_json(saves_list_path, saves_data)

	current_save = new_save_id

	@warning_ignore("shadowed_variable_base_class")
	for name in paths_to_save.keys():
		var base_path: String = paths_to_save.get(name, "")
		var new_save_path: String = base_path + "save_%d.json" % current_save
		var source_path: String = base_path + "save_%s.json" % source_save_id

		var source_data = Utils.load_from_json(source_path)
		Utils.save_to_json(new_save_path, source_data)

		#load_save_to_manager(name, new_save_path)
		
	print("current_save = ", current_save)

func set_save(save_id: int):
	current_save = save_id
	load_save(inventory_manager, "InventoryManager")

func load_save(manager: Node, name: String):
	var base_path: String = paths_to_save.get(name, "")
	var save_path: String = base_path + "save_%d.json" % current_save
	manager.setup_save_file(save_path)
