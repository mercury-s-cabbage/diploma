extends Node2D

var current_state_file = "res://Src/Game_world/managers/location_manager/locations/loc_001/saves/save_0.json"
var current_state = {}

const Utils = preload("res://Src/Game_world/managers/utils.gd")

@onready var Branch1 = $Branch1
@onready var Branch2 = $Branch2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_state = Utils.load_from_json(current_state_file)
	if current_state.picked_items["Branch1"] == false:
		Branch1.queue_free()
	if current_state.picked_items["Branch2"] == false:
		Branch2.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
