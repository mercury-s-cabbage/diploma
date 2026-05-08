extends Node2D

var current_state_file: String = ""
var save_path = "res://Src/Game_world/managers/location_manager/locations/loc_002/saves/"
var current_state = {}

const Utils = preload("res://Src/Game_world/managers/utils.gd")

@onready var Branch3 = $Branch3
@onready var Branch4 = $Branch4
@onready var Branch5 = $Branch5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.save_location.connect(_save_location)
	EventBus.item_acquired.connect(_on_item_acquired)
	current_state = Utils.load_from_json(save_path + "/" + current_state_file)
	if current_state.picked_items["Branch3"] == false:
		Branch3.queue_free()
	if current_state.picked_items["Branch4"] == false:
		Branch4.queue_free()
	if current_state.picked_items["Branch5"] == false:
		Branch5.queue_free()
	
func _save_location(loc_id):
	if loc_id == "loc_002":
		var data_path = save_path + "/" + current_state_file
		Utils.save_to_json(data_path, current_state)
		
func _on_item_acquired(_item: ItemData, _count: int, instance_id: String):
	if current_state.picked_items.has(instance_id) and current_state.picked_items[instance_id]:
		current_state.picked_items[instance_id] = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		EventBus.area_entered.emit("field")

func _on_banya_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		EventBus.area_entered.emit("banya")
		
func setup_state_file(save_id: String) -> void:
	current_state_file = "save_%s.json" % save_id

func _on_001_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		EventBus.start_quest.emit("001")
