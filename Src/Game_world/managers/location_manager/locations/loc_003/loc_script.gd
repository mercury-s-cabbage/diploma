extends LocationBase

@onready var dialogue_1 = $Area2D

const BALLOON_SCENE = preload("res://addons/dialogue_manager/user_balloons/balloon.tscn")
const DIALOGUE_RESOURCE = preload("res://Src/Game_world/dialogues.dialogue")

func _setup_location() -> void:
	set_location_id("loc_003")
	set_save_path("res://Src/Game_world/managers/location_manager/locations/loc_003/saves")

func _create_default_state() -> Dictionary:
	return {
		"picked_items": {},
		"characters": {},
		"sprites": {},
		"dialogues": {
			"1": true
		}
	}

func _apply_loaded_state() -> void:
	if current_state.dialogues.get("1", true) == false:
		dialogue_1.queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		DialogueManager.show_dialogue_balloon_scene(BALLOON_SCENE, DIALOGUE_RESOURCE)


func _on_quest_2_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		EventBus.start_quest.emit("002")
