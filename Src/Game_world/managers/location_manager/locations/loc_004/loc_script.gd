extends LocationBase

func _setup_location() -> void:
	set_location_id("loc_004")
	set_save_path("res://Src/Game_world/managers/location_manager/locations/loc_004/saves")

func _create_default_state() -> Dictionary:
	return {
		"picked_items": {},
		"characters": {},
		"sprites": {},
		"dialogues": {}
	}
