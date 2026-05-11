extends LocationBase

@onready var Branch3 = $Branch3
@onready var Branch4 = $Branch4
@onready var Branch5 = $Branch5

func _setup_location() -> void:
	set_location_id("loc_002")
	set_save_path("res://Src/Game_world/managers/location_manager/locations/loc_002/saves")

func _create_default_state() -> Dictionary:
	return {
		"picked_items": {
			"Branch3": true,
			"Branch4": true,
			"Branch5": true
		},
		"characters": {},
		"sprites": {}
	}

func _apply_loaded_state() -> void:
	if current_state.picked_items.get("Branch3", true) == false:
		Branch3.queue_free()
	if current_state.picked_items.get("Branch4", true) == false:
		Branch4.queue_free()
	if current_state.picked_items.get("Branch5", true) == false:
		Branch5.queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		EventBus.area_entered.emit("field")

func _on_banya_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		EventBus.area_entered.emit("banya")

func _on_001_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		EventBus.start_quest.emit("001")
