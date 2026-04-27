extends Node2D

var current_state_file: String = ""
var save_path = "res://Src/Game_world/managers/location_manager/locations/loc_001/saves/"
var current_state = {}

const Utils = preload("res://Src/Game_world/managers/utils.gd")

@onready var Branch1 = $Branch1
@onready var Branch2 = $Branch2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.save_location.connect(_save_location)
	EventBus.item_acquired.connect(_on_item_acquired)
	current_state = Utils.load_from_json(save_path + "/" + current_state_file)
	if current_state.picked_items["Branch1"] == false:
		Branch1.queue_free()
	if current_state.picked_items["Branch2"] == false:
		Branch2.queue_free()

func setup_state_file(save_id: String) -> void:
	current_state_file = "save_%s.json" % save_id
	
func _save_location(loc_id):
	if loc_id == "loc_001":
		var data_path = save_path + "/" + current_state_file
		Utils.save_to_json(data_path, current_state)
		
func _on_item_acquired(_item: ItemData, _count: int, instance_id: String):
	if current_state.picked_items[instance_id]:
		current_state.picked_items[instance_id] = false
		print("item add")
