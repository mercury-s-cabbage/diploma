extends LocationBase

@onready var Branch1 = $Branch1
@onready var Branch2 = $Branch2

func _setup_location() -> void:
	set_location_id("loc_001")
	save_path = "res://Src/Game_world/managers/location_manager/locations/loc_001/saves"
	# current_state_file передаётся менеджером через setup_state_file()

func _create_default_state() -> Dictionary:
	return {
		"picked_items": {
			"Branch1": true,
			"Branch2": true
		},
		"characters": {},
		"sprites": {}
	}

func _apply_loaded_state() -> void:
	if current_state.picked_items.get("Branch1", true) == false:
		Branch1.queue_free()
	if current_state.picked_items.get("Branch2", true) == false:
		Branch2.queue_free()
